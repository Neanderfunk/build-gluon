#!/bin/sh

set -e

if [ ! -d gluon ]; then
  git clone https://github.com/freifunk-gluon/gluon
else
  (cd gluon; git pull)
fi

if [ ! -d site-ffnef ]; then
  git clone https://github.com/Neanderfunk/site-ffnef
else
  (cd site-ffnef; git pull)
fi

cd gluon
make update
make GLUON_TARGET=ar71xx-generic clean # not mentioned in doc

for sitedir in ../site-ffnef/*; do
  make GLUON_TARGET=ar71xx-generic \
    GLUON_SITEDIR=$sitedir GLUON_OUTPUTDIR=$(basename $sitedir) \
    GLUON_BRANCH=experimental
 make manifest GLUON_BRANCH=experimental \
    GLUON_SITEDIR=$sitedir GLUON_OUTPUTDIR=$(basename $sitedir)
done
#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest

#rm -rf /where/to/put/this/experimental
#cp -r images /where/to/put/this/experimental
