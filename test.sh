#!/usr/bin/env bash

set -euo pipefail

git add .

nix build .#flag

cp result/flag*.raw ./flag.raw
chmod +w ./flag.raw
qemu-img resize -f raw ./flag.raw "+10G"

nix run .#qemu -- ./flag.raw
