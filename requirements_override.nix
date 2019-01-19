{ pkgs, python }:

let

  removeDependencies = names: deps:
    with builtins; with pkgs.lib;
      filter
      (drv: all
        (suf:
          ! hasSuffix ("-" + suf)
          (parseDrvName drv.name).name
        )
        names
      )
      deps;

in self: super: {

  "astroid" = python.overrideDerivation super."astroid" (old: {
    buildInputs = old.buildInputs ++ [ self."pytest-runner" ];
  });

  "py" = python.overrideDerivation super."py" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
  });

  # From default overrides
  "mccabe" = python.overrideDerivation super."mccabe" (old: {
    buildInputs = old.buildInputs ++ [ self."pytest-runner" ];
  });

  "python-dateutil" = python.overrideDerivation super."python-dateutil" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
  });

  # From default overrides
  "pluggy" = python.overrideDerivation super."pluggy" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
  });

  "pytest" = python.overrideDerivation super."pytest" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
  });

  # Due to https://github.com/garbas/nixpkgs-python/issues/31
  "attrs" = python.overrideDerivation super."attrs" (old: {
    propagatedBuildInputs = removeDependencies [ "pytest" ] old.propagatedBuildInputs;
  });

  "flake8" = python.overrideDerivation super."flake8" (old: {
    #propagatedBuildInputs = removeDependencies [ "mccabe" ] old.propagatedBuildInputs;
    buildInputs = old.buildInputs ++ [ self."pytest-runner" ];
  });

  "pytest-runner" = python.overrideDerivation super."pytest-runner" (old: {
    propagatedBuildInputs = removeDependencies [ "mccabe" "pytest-flake8" ] old.propagatedBuildInputs;
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
  });

  "pylint" = python.overrideDerivation super."pylint" (old: {
    buildInputs = old.buildInputs ++ [ self."pytest-runner" ];
  });

  "pytest-pylint" = python.overrideDerivation super."pytest-pylint" (old: {
    buildInputs = old.buildInputs ++ [ self."pytest-runner" ];
  });

}
