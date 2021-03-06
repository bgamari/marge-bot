# pylint: disable=too-many-branches,too-many-statements
import logging as log
from time import sleep

from . import git
from .commit import Commit
from .job import MergeJob, CannotMerge, SkipMerge
from .merge_request import MergeRequest
from .pipeline import Pipeline


class CannotBatch(Exception):
    pass


class BatchMergeJob(MergeJob):
    BATCH_BRANCH_NAME = 'wip/marge_bot_batch_merge_job'

    def __init__(self, *, api, user, project, repo, options, merge_requests):
        super().__init__(api=api, user=user, project=project, repo=repo, options=options)
        self._merge_requests = merge_requests

    def remove_batch_branch(self):
        log.info('Removing local batch branch')
        try:
            self._repo.remove_branch(BatchMergeJob.BATCH_BRANCH_NAME)
        except git.GitError:
            pass

    def close_batch_mr(self):
        log.info('Closing batch MRs')
        params = {
            'author_id': self._user.id,
            'labels': BatchMergeJob.BATCH_BRANCH_NAME,
            'state': 'opened',
            'order_by': 'created_at',
            'sort': 'desc',
        }
        batch_mrs = MergeRequest.search(
            api=self._api,
            project_id=self._project.id,
            params=params,
        )
        for batch_mr in batch_mrs:
            log.info('Closing batch MR !%s', batch_mr.iid)
            batch_mr.close()

    def create_batch_mr(self, target_branch):
        log.info('Creating batch MR')
        params = {
            'source_branch': BatchMergeJob.BATCH_BRANCH_NAME,
            'target_branch': target_branch,
            'title': 'Marge Bot Batch MR - DO NOT TOUCH',
            'labels': BatchMergeJob.BATCH_BRANCH_NAME,
        }
        batch_mr = MergeRequest.create(
            api=self._api,
            project_id=self._project.id,
            params=params,
        )
        log.info('Batch MR !%s created', batch_mr.iid)
        return batch_mr

    def get_mrs_with_common_target_branch(self, target_branch):
        log.info('Filtering MRs with target branch %s', target_branch)
        return [
            merge_request for merge_request in self._merge_requests
            if merge_request.target_branch == target_branch
        ]

    def ensure_mergeable_mr(self, merge_request):
        super().ensure_mergeable_mr(merge_request)

        if self._project.only_allow_merge_if_pipeline_succeeds:
            ci_status = self.get_mr_ci_status(merge_request)
            if ci_status != 'success' and ci_status != 'skipped':
                raise CannotBatch('This MR has not passed CI.')
            return ci_status

    def get_mergeable_mrs(self, merge_requests):
        log.info('Filtering mergeable MRs')
        mergeable_mrs = []
        for merge_request in merge_requests:
            try:
                ci_status = self.ensure_mergeable_mr(merge_request)
            except (CannotBatch, SkipMerge) as ex:
                log.warning('Skipping unbatchable MR: "%s"', ex)
            except CannotMerge as ex:
                log.warning('Skipping unmergeable MR: "%s"', ex)
                self.unassign_from_mr(merge_request)
                merge_request.comment("I couldn't merge this branch: {}".format(ex))
            else:
                # Put the MRs with skipped CI at the front so that CI for the whole
                # batch isn't skipped. If they have all skipped CI then skipping CI for
                # the batch is OK.
                if ci_status == 'success':
                    mergeable_mrs.append(merge_request)
                else: # ci_status == 'skipped'
                    mergeable_mrs.insert(0,merge_request)
        return mergeable_mrs

    def push_batch(self):
        log.info('Pushing batch branch')
        self._repo.push(BatchMergeJob.BATCH_BRANCH_NAME, force=True)

    def ensure_mr_not_changed(self, merge_request):
        log.info('Ensuring MR !%s did not change', merge_request.iid)
        changed_mr = MergeRequest.fetch_by_iid(
            merge_request.project_id,
            merge_request.iid,
            self._api,
        )
        error_message = 'The {} changed whilst merging!'
        for attr in ('source_branch', 'source_project_id', 'target_branch', 'target_project_id', 'sha'):
            if getattr(changed_mr, attr) != getattr(merge_request, attr):
                raise CannotMerge(error_message.format(attr.replace('_', ' ')))

    def accept_mr(
        self,
        merge_request,
        expected_remote_target_branch_sha,
        source_repo_url=None,
    ):
        log.info('Fusing MR !%s', merge_request.iid)
        approvals = merge_request.fetch_approvals()

        # Make sure latest commit in remote <target_branch> is the one we tested against
        new_target_sha = Commit.last_on_branch(self._project.id, merge_request.target_branch, self._api).id
        if new_target_sha != expected_remote_target_branch_sha:
            raise CannotBatch('Someone was naughty and by-passed marge')

        # FIXME: we should only add tested-by for the last MR in the batch
        #_, _, actual_sha = self.update_from_target_branch_and_push(
        #    merge_request,
        #    source_repo_url=source_repo_url,
        #)

        #sha_now = Commit.last_on_branch(
        #    merge_request.source_project_id, merge_request.source_branch, self._api,
        #).id
        # Make sure no-one managed to race and push to the branch in the
        # meantime, because we're about to impersonate the approvers, and
        # we don't want to approve unreviewed commits
        #    raise CannotMerge('Someone pushed to branch while we were trying to merge')
        #if sha_now != actual_sha:
        #    log.warning('Mismatched SHA: %s', sha_now)
        #    log.warning('Mismatched SHA: %s', actual_sha)


        # As we're not using the API to merge the MR, we don't strictly need to reapprove it. However,
        # it's a little weird to look at the merged MR to find it has no approvals, so let's do it anyway.
        self.maybe_reapprove(merge_request, approvals)

        # update_from_target_branch_and_push rebased using the gitlab API
        # but now  we have to refetch the remote to get the changes
        # and update the local branch.
        _, source_repo_url, merge_request_remote = self.fetch_source_project(merge_request)
        # For some reason, the fetch_source_project method doesn't fetch origin
        self._repo.fetch('origin')
        self._repo.remove_branch(merge_request.source_branch)
        self._repo.checkout_branch(
            merge_request.source_branch,
            '%s/%s' % (merge_request_remote, merge_request.source_branch),
        )

        # Rebase source branch onto target branch
        self.fuse(
            merge_request.source_branch,
            merge_request.target_branch,
            source_repo_url=source_repo_url,
            local=True,
        )

        # This switches git to <target_branch>
        final_sha = self._repo.fast_forward(
            merge_request.target_branch,
            merge_request.source_branch,
            local=True
        )

        # Don't force push in case the remote has changed.
        self._repo.push(merge_request.target_branch, force=False)

        sleep(2)

        # At this point Gitlab should have recognised the MR as being accepted.
        log.info('Successfully merged MR !%s', merge_request.iid)
        merge_request.comment('Merged in %s' % final_sha)
        merge_request.close()
        log.info('Sleeping 30s for good luck')
        sleep(30)

        # Gitlab API has no way to query pending/running pipelines
        #pipelines = Pipeline.pipelines_by_branch(
        #    api=self._api,
        #    project_id=merge_request.source_project_id,
        #    branch=merge_request.source_branch,
        #    status='pending',
        #)
        #for pipeline in pipelines:
        #    pipeline.cancel()

        #pipelines = Pipeline.pipelines_by_branch(
        #    api=self._api,
        #    project_id=merge_request.source_project_id,
        #    branch=merge_request.source_branch,
        #    status='running',
        #)
        #for pipeline in pipelines:
        #    pipeline.cancel()

        return final_sha

    def execute(self):
        # Cleanup previous batch work
        self.remove_batch_branch()
        self.close_batch_mr()

        target_branch = self._merge_requests[0].target_branch
        merge_requests = self.get_mrs_with_common_target_branch(target_branch)
        merge_requests = self.get_mergeable_mrs(merge_requests)

        if len(merge_requests) <= 1:
            # Either no merge requests are ready to be merged, or there's only one for this target branch.
            # Let's raise an error to do a basic job for these cases.
            raise CannotBatch('not enough ready merge requests')

        self._repo.fetch('origin')

        # Save the sha of remote <target_branch> so we can use it to make sure
        # the remote wasn't changed while we're testing against it
        remote_target_branch_sha = self._repo.get_commit_hash('origin/%s' % target_branch)

        self._repo.checkout_branch(target_branch, 'origin/%s' % target_branch)
        self._repo.checkout_branch(BatchMergeJob.BATCH_BRANCH_NAME, 'origin/%s' % target_branch)

        working_merge_requests = []

        for merge_request in merge_requests:
            try:
                _, source_repo_url, merge_request_remote = self.fetch_source_project(merge_request)
                self._repo.checkout_branch(
                    merge_request.source_branch,
                    '%s/%s' % (merge_request_remote, merge_request.source_branch),
                )

                # Update <source_branch> on latest <batch> branch so it contains previous MRs
                self.fuse(
                    merge_request.source_branch,
                    BatchMergeJob.BATCH_BRANCH_NAME,
                    source_repo_url=source_repo_url,
                    local=True,
                )

                # Update <batch> branch with MR changes
                self._repo.fast_forward(
                    BatchMergeJob.BATCH_BRANCH_NAME,
                    merge_request.source_branch,
                    local=True,
                )

                # We don't need <source_branch> anymore. Remove it now in case another
                # merge request is using the same branch name in a different project.
                # FIXME: is this actually needed?
                #self._repo.remove_branch(merge_request.source_branch)
            except git.GitError:
                log.warning('Skipping MR !%s, got conflicts while rebasing', merge_request.iid)
                continue
            else:
                working_merge_requests.append(merge_request)
        if len(working_merge_requests) <= 1:
            raise CannotBatch('not enough ready merge requests')
        if self._project.only_allow_merge_if_pipeline_succeeds:
            # This switches git to <batch> branch
            self.push_batch()
            batch_mr = self.create_batch_mr(
                target_branch=target_branch,
            )
            for merge_request in working_merge_requests:
                merge_request.comment('I will attempt to batch this MR (!{})...'.format(batch_mr.iid))
            try:
                self.wait_for_ci_to_pass(batch_mr)
            except CannotMerge as err:
                for merge_request in working_merge_requests:
                    merge_request.comment(
                        'Batch MR !{batch_mr_iid} failed: {error} I will retry later...'.format(
                            batch_mr_iid=batch_mr.iid,
                            error=err.reason,
                        ),
                    )
                raise CannotBatch(err.reason) from err
        for merge_request in working_merge_requests:
            try:
                # FIXME: this should probably be part of the merge request
                _, source_repo_url, merge_request_remote = self.fetch_source_project(merge_request)
                self.ensure_mr_not_changed(merge_request)
                self.ensure_mergeable_mr(merge_request)
                remote_target_branch_sha = self.accept_mr(
                    merge_request,
                    remote_target_branch_sha,
                    source_repo_url=source_repo_url,
                )
            except CannotBatch as err:
                merge_request.comment(
                    "I couldn't merge this branch: {error} I will retry later...".format(
                        error=str(err),
                    ),
                )
                raise
            except SkipMerge:
                # Raise here to avoid being caught below - we don't want to be unassigned.
                raise
            except CannotMerge as err:
                self.unassign_from_mr(merge_request)
                merge_request.comment("I couldn't merge this branch: %s" % err.reason)
                raise
