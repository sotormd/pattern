{ pkgs, lib, ... }:

(import ./image.nix { inherit pkgs lib; }).nixos
