#!/bin/bash

# sudo loginctl enable-linger $USER
# systemctl enable --now --user apt-cacher-ng-image.timer

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

set -e

(set -x;
  mkdir -p $HOME/.config/systemd/user
  cp $SRC/apt-cacher-ng-image.{service,timer} $HOME/.config/systemd/user
  systemctl daemon-reload --user
)
