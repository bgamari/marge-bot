# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 3.6 -r requirements.txt -C .cache
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python36;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            sed -i               -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"                  $out/${pkgs.python35.sitePackages}/pip/req/req_install.py
          '';
        });
      };
  };

  commonBuildInputs = [];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python36-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable}               python3
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs //                                            { meta = drv.meta; });
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {

    "ConfigArgParse" = python.mkDerivation {
      name = "ConfigArgParse-0.14.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/ea/f0ade52790bcd687127a302b26c1663bf2e0f23210d5281dbfcd1dfcda28/ConfigArgParse-0.14.0.tar.gz"; sha256 = "2e2efe2be3f90577aca9415e32cb629aa2ecd92078adbe27b53a03e53ff12e91"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/bw2/ConfigArgParse";
        license = licenses.mit;
        description = "A drop-in replacement for argparse that allows options to also be set via config files and/or environment variables.";
      };
    };



    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"; sha256 = "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyyaml.org/wiki/PyYAML";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "astroid" = python.mkDerivation {
      name = "astroid-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/df/d1/b45e0bbfe0ad2253b1d589afd09f94fcf4407b4c7c5fc4d3e3540cc13c75/astroid-2.1.0.tar.gz"; sha256 = "35b032003d6a863f5dcd7ec11abd5cd5893428beaa31ab164982403bcb311f22"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."lazy-object-proxy"
      self."six"
      self."typed-ast"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/PyCQA/astroid";
        license = licenses.lgpl3;
        description = "An abstract syntax tree for Python with inference support.";
      };
    };



    "atomicwrites" = python.mkDerivation {
      name = "atomicwrites-1.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/ed/a311712ef6b4355035489f665e63e1a73f9eb371929e3c98e5efd451069e/atomicwrites-1.2.1.tar.gz"; sha256 = "ec9ae8adaae229e4f8446952d204a3e4b5fdd2d099f9be3aaf556120135fb3ee"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/untitaker/python-atomicwrites";
        license = licenses.mit;
        description = "Atomic file writes.";
      };
    };



    "attrs" = python.mkDerivation {
      name = "attrs-18.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0f/9e/26b1d194aab960063b266170e53c39f73ea0d0d3f5ce23313e0ec8ee9bdf/attrs-18.2.0.tar.gz"; sha256 = "10cbf6e27dbce8c30807caf056c8eb50917e0eaafe86347671b57254006c3e69"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."coverage"
      self."pytest"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.attrs.org/";
        license = licenses.mit;
        description = "Classes Without Boilerplate";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2018.11.29";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed/certifi-2018.11.29.tar.gz"; sha256 = "47f9c83ef4c0c621eaef743f133f09fa8a74a9b75f037e8624f83bd1b6626cb7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };



    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };



    "coverage" = python.mkDerivation {
      name = "coverage-4.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fb/af/ce7b0fe063ee0142786ee53ad6197979491ce0785567b6d8be751d2069e8/coverage-4.5.2.tar.gz"; sha256 = "ab235d9fe64833f12d1334d29b558aacedfbca2356dfb9691f2d0d38a8a7bfb4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/ned/coveragepy";
        license = licenses.asl20;
        description = "Code coverage measurement for Python";
      };
    };



    "dateparser" = python.mkDerivation {
      name = "dateparser-0.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e7/87/fc2ab653e628e2e51e00115bc9cb14c31afdd03acb710f137056a1c13f7c/dateparser-0.7.0.tar.gz"; sha256 = "940828183c937bcec530753211b70f673c0a9aab831e43273489b310538dff86"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."python-dateutil"
      self."pytz"
      self."regex"
      self."tzlocal"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/scrapinghub/dateparser";
        license = licenses.bsdOriginal;
        description = "Date parsing library designed to parse dates from HTML pages";
      };
    };



    "flake8" = python.mkDerivation {
      name = "flake8-3.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d0/27/c0d1274b86a8f71ec1a6e4d4c1cfe3b20d6f95b090ec7545320150952c93/flake8-3.6.0.tar.gz"; sha256 = "6a35f5b8761f45c5513e3405f110a86bea57982c3b75b766ce7b65217abe1670"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."mccabe"
      self."pycodestyle"
      self."pyflakes"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://gitlab.com/pycqa/flake8";
        license = licenses.mit;
        description = "the modular source code checker: pep8, pyflakes and co";
      };
    };



    "humanize" = python.mkDerivation {
      name = "humanize-0.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/e0/e512e4ac6d091fc990bbe13f9e0378f34cf6eecd1c6c268c9e598dcf5bb9/humanize-0.5.1.tar.gz"; sha256 = "a43f57115831ac7c70de098e6ac46ac13be00d69abbf60bdcac251344785bb19"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/jmoiron/humanize";
        license = licenses.mit;
        description = "python humanize utilities";
      };
    };



    "idna" = python.mkDerivation {
      name = "idna-2.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"; sha256 = "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };



    "isort" = python.mkDerivation {
      name = "isort-4.3.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/de/a628d16fdba0d38cafb3d7e34d4830f2c9cb3881384ce5c08c44762e1846/isort-4.3.4.tar.gz"; sha256 = "b9c40e9750f3d77e6e4d441d8b0266cf555e7cdabdcff33c4fd06366ca761ef8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/timothycrosley/isort";
        license = licenses.mit;
        description = "A Python utility / library to sort Python imports.";
      };
    };



    "lazy-object-proxy" = python.mkDerivation {
      name = "lazy-object-proxy-1.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/08/23c0753599bdec1aec273e322f277c4e875150325f565017f6280549f554/lazy-object-proxy-1.3.1.tar.gz"; sha256 = "eb91be369f945f10d3a49f5f9be8b3d0b93a4c2be8f8a5b83b0571b8123e0a7a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/ionelmc/python-lazy-object-proxy";
        license = licenses.bsdOriginal;
        description = "A fast and thorough lazy object proxy.";
      };
    };



    "maya" = python.mkDerivation {
      name = "maya-0.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4e/90/e0e298b495164475331cc3fda906c640c9098a49fc933172fe5826393185/maya-0.6.1.tar.gz"; sha256 = "7f53e06d5a123613dce7c270cbc647643a6942590dba7a19ec36194d0338c3f4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."dateparser"
      self."humanize"
      self."pendulum"
      self."pytz"
      self."snaptime"
      self."tzlocal"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kennethreitz/maya";
        license = licenses.mit;
        description = "Datetimes for Humans.";
      };
    };



    "mccabe" = python.mkDerivation {
      name = "mccabe-0.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/06/18/fa675aa501e11d6d6ca0ae73a101b2f3571a565e0f7d38e062eec18a91ee/mccabe-0.6.1.tar.gz"; sha256 = "dd8d182285a0fe56bace7f45b5e7d1a6ebcbf524e8f3bd87eb0f125271b8831f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pycqa/mccabe";
        license = licenses.mit;
        description = "McCabe checker, plugin for flake8";
      };
    };



    "more-itertools" = python.mkDerivation {
      name = "more-itertools-5.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dd/26/30fc0d541d9fdf55faf5ba4b0fd68f81d5bd2447579224820ad525934178/more-itertools-5.0.0.tar.gz"; sha256 = "38a936c0a6d98a38bcc2d03fdaaedaba9f412879461dd2ceff8d37564d6522e4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/erikrose/more-itertools";
        license = licenses.mit;
        description = "More routines for operating on iterables, beyond itertools";
      };
    };



    "pendulum" = python.mkDerivation {
      name = "pendulum-2.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5b/57/71fc910edcd937b72aa0ef51c8f5734fbd8c011fa1480fce881433847ec8/pendulum-2.0.4.tar.gz"; sha256 = "cf535d36c063575d4752af36df928882b2e0e31541b4482c97d63752785f9fcb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."python-dateutil"
      self."pytzdata"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pendulum.eustace.io";
        license = "";
        description = "Python datetimes made easy";
      };
    };



    "pluggy" = python.mkDerivation {
      name = "pluggy-0.8.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/38/e1/83b10c17688af7b2998fa5342fec58ecbd2a5a7499f31e606ae6640b71ac/pluggy-0.8.1.tar.gz"; sha256 = "8ddc32f03971bfdf900a81961a48ccf2fb677cf7715108f85295c67405798616"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pytest-dev/pluggy";
        license = licenses.mit;
        description = "plugin and hook calling mechanisms for python";
      };
    };



    "py" = python.mkDerivation {
      name = "py-1.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c7/fa/eb6dd513d9eb13436e110aaeef9a1703437a8efa466ce6bb2ff1d9217ac7/py-1.7.0.tar.gz"; sha256 = "bf92637198836372b520efcba9e020c330123be8ce527e535d185ed4b6f45694"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://py.readthedocs.io/";
        license = licenses.mit;
        description = "library with cross-python path, ini-parsing, io, code, log facilities";
      };
    };



    "pycodestyle" = python.mkDerivation {
      name = "pycodestyle-2.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/28/ad/cae9654d7fd64eb3d2ab2c44c9bf8dc5bd4fb759625beab99532239aa6e8/pycodestyle-2.4.0.tar.gz"; sha256 = "cbfca99bd594a10f674d0cd97a3d802a1fdef635d4361e1a2658de47ed261e3a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pycodestyle.readthedocs.io/";
        license = licenses.mit;
        description = "Python style guide checker";
      };
    };



    "pyflakes" = python.mkDerivation {
      name = "pyflakes-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/92/9e/386c0d9deef14996eb90d9deebbcb9d3ceb70296840b09615cb61b2ae231/pyflakes-2.0.0.tar.gz"; sha256 = "9a7662ec724d0120012f6e29d6248ae3727d821bba522a0e6b356eff19126a49"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/PyCQA/pyflakes";
        license = licenses.mit;
        description = "passive checker of Python programs";
      };
    };



    "pylint" = python.mkDerivation {
      name = "pylint-2.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/92/8e/e86eb8dbc10ee845b1c04ed9eaeafb981331f6db5dc05ba21555fcbe7595/pylint-2.2.2.tar.gz"; sha256 = "689de29ae747642ab230c6d37be2b969bf75663176658851f456619aacf27492"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."astroid"
      self."isort"
      self."mccabe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/PyCQA/pylint";
        license = licenses.gpl1;
        description = "python code static checker";
      };
    };



    "pytest" = python.mkDerivation {
      name = "pytest-4.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e2/1d/5aaae6a77d9699ebcc5cbed574c28272371b8915073a126a9ead961c8f6c/pytest-4.1.1.tar.gz"; sha256 = "c3c573a29d7c9547fb90217ece8a8843aa0c1328a797e200290dc3d0b4b823be"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."atomicwrites"
      self."attrs"
      self."more-itertools"
      self."pluggy"
      self."py"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.pytest.org/en/latest/";
        license = licenses.mit;
        description = "pytest: simple powerful testing with Python";
      };
    };



    "pytest-cov" = python.mkDerivation {
      name = "pytest-cov-2.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/54/16/4229c5514d12b25c3555ca775c7c3cade9a63da99b52fd5fc45962fa3d29/pytest-cov-2.6.1.tar.gz"; sha256 = "0ab664b25c6aa9716cbf203b17ddb301932383046082c081b9848a0edf5add33"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."coverage"
      self."pytest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pytest-dev/pytest-cov";
        license = licenses.bsdOriginal;
        description = "Pytest plugin for measuring coverage.";
      };
    };



    "pytest-flake8" = python.mkDerivation {
      name = "pytest-flake8-1.0.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2c/e4/e70ed255b56065f6264479dd38e60a739bd77ba03f70b14559250b46d62c/pytest-flake8-1.0.3.tar.gz"; sha256 = "b2c71fb6d469bae076a01c43d4a83485d740db6a8a00bad77e0657ed035e98d4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."flake8"
      self."pytest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/tholo/pytest-flake8";
        license = licenses.bsdOriginal;
        description = "pytest plugin to check FLAKE8 requirements";
      };
    };



    "pytest-pylint" = python.mkDerivation {
      name = "pytest-pylint-0.14.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/58/cc27a07b8a7715411415c0f42d9e7c24bd2c646748b7406d2e7507da085f/pytest-pylint-0.14.0.tar.gz"; sha256 = "7bfbb66fc6dc160193a9e813a7c55e5ae32028f18660deeb90e1cb7e980cbbac"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pylint"
      self."pytest"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/carsongee/pytest-pylint";
        license = licenses.mit;
        description = "pytest plugin to check source code with pylint";
      };
    };



    "pytest-runner" = python.mkDerivation {
      name = "pytest-runner-4.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9e/b7/fe6e8f87f9a756fd06722216f1b6698ccba4d269eac6329d9f0c441d0f93/pytest-runner-4.2.tar.gz"; sha256 = "d23f117be39919f00dd91bffeb4f15e031ec797501b717a245e377aee0f577be"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytest"
      self."pytest-flake8"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pytest-dev/pytest-runner";
        license = licenses.mit;
        description = "Invoke py.test as distutils command with dependency resolution";
      };
    };



    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.7.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"; sha256 = "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2018.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/af/be/6c59e30e208a5f28da85751b93ec7b97e4612268bb054d0dff396e758a90/pytz-2018.9.tar.gz"; sha256 = "d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };



    "pytzdata" = python.mkDerivation {
      name = "pytzdata-2018.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d9/27/04b261a2d24a2658159e502fb01e9579f7a42d7a1c51ca5023190dff126b/pytzdata-2018.7.tar.gz"; sha256 = "10c74b0cfc51a9269031f86ecd11096c9c6a141f5bb15a3b8a88f9979f6361e2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sdispater/pytzdata";
        license = "";
        description = "The Olson timezone database for Python.";
      };
    };



    "regex" = python.mkDerivation {
      name = "regex-2018.11.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/07/ee3e02770ed456a088b90da7c9b1e9aa227e3c956d37b845cef2aab93764/regex-2018.11.22.tar.gz"; sha256 = "79a6a60ed1ee3b12eb0e828c01d75e3b743af6616d69add6c2fde1d425a4ba3f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/mrabarnett/mrab-regex";
        license = licenses.psfl;
        description = "Alternative regular expression module, to replace re.";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38/requests-2.21.0.tar.gz"; sha256 = "502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."idna"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };



    "setuptools-scm" = python.mkDerivation {
      name = "setuptools-scm-3.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/54/85/514ba3ca2a022bddd68819f187ae826986051d130ec5b972076e4f58a9f3/setuptools_scm-3.2.0.tar.gz"; sha256 = "52ab47715fa0fc7d8e6cd15168d1a69ba995feb1505131c3e814eb7087b57358"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/setuptools_scm/";
        license = licenses.mit;
        description = "the blessed package to manage your versions by scm tags";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.12.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"; sha256 = "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/benjaminp/six";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };



    "snaptime" = python.mkDerivation {
      name = "snaptime-0.2.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/f4/cb818c9bfdac4605f13296f7fcfe068aee7d1c3aa89f8cc22a064c1fab20/snaptime-0.2.4.tar.gz"; sha256 = "e3f1eb89043d58d30721ab98cb65023f1a4c2740e3b197704298b163c92d508b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."python-dateutil"
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/zartstrom/snaptime";
        license = "";
        description = "Transform timestamps with a simple DSL";
      };
    };



    "typed-ast" = python.mkDerivation {
      name = "typed-ast-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/00/be/c3769a5d6a179c42eba04186dc7efeb165edf92f7b1582ccfe81cb17d7f9/typed-ast-1.2.0.tar.gz"; sha256 = "b4726339a4c180a8b6ad9d8b50d2b6dc247e1b79b38fe2290549c98e82e4fd15"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python/typed_ast";
        license = licenses.asl20;
        description = "a fork of Python 2 and 3 ast modules with type comment support";
      };
    };



    "tzlocal" = python.mkDerivation {
      name = "tzlocal-1.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cb/89/e3687d3ed99bc882793f82634e9824e62499fdfdc4b1ae39e211c5b05017/tzlocal-1.5.1.tar.gz"; sha256 = "4ebeb848845ac898da6519b9b31879cf13b6626f7184c496037b818e238f2c4e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/regebro/tzlocal";
        license = licenses.mit;
        description = "tzinfo object for the local timezone";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.24.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1/urllib3-1.24.1.tar.gz"; sha256 = "de9529817c93f27c8ccbfead6985011db27bd0ddfcdb2d86f3f663385c6a9c22"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };



    "wrapt" = python.mkDerivation {
      name = "wrapt-1.11.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/67/b2/0f71ca90b0ade7fad27e3d20327c996c6252a2ffe88f50a95bba7434eda9/wrapt-1.11.1.tar.gz"; sha256 = "4aea003270831cceb8a90ff27c4031da6ead7ec1886023b80ce0dfe0adf61533"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GrahamDumpleton/wrapt";
        license = licenses.bsdOriginal;
        description = "Module for decorators, wrappers and monkey patching.";
      };
    };

  };
  localOverridesFile = ./requirements_override.nix;
  overrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [

  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [overrides] else [] ) ++ commonOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )