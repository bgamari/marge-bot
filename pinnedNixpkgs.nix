let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  pkgs = import (fetchFromGitHub {
                   owner  = "NixOS";
                   repo   = "nixpkgs";
                   rev    = "74b7aae3afde80f4627ae92a695073e167ccc39a";
                   sha256 = "13qn5knvyiifrs8hjhbvcl2fddqz3gxniwlm598hxcmkfdxal9k1";
                 }) {};
in pkgs
