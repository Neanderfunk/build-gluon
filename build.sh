#!/bin/sh

set -e

if [ ! -d gluon ]; then
  git clone https://github.com/freifunk-gluon/gluon
  cd gluon
  mkdir site
  git clone https://github.com/Neanderfunk/site-ffnef site
fi
