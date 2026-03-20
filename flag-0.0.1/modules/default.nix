{ pkgs, lib, ... }:

# the base nixos configuration with dm-verity
(import ./00-base.nix { inherit pkgs lib; }).nixos
