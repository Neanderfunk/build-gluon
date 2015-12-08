#!/bin/sh

set -e

if [ ! -d gluon ]; then
  git clone https://github.com/freifunk-gluon/gluon
  cd gluon
  mkdir site
  git clone https://github.com/Neanderfunk/site-ffnef site
else
  cd gluon
fi

git pull
(cd site && git pull)
make update
#make clean
make -j1 GLUON_TARGET=ar71xx-generic GLUON_BRANCH=experimental
#make manifest GLUON_BRANCH=experimental
#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest

#rm -rf /where/to/put/this/experimental
#cp -r images /where/to/put/this/experimental
