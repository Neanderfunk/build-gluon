#!/bin/sh

set -e

if [ ! -d gluon ]; then
  git clone https://github.com/freifunk-gluon/gluon
else
  (cd gluon; git reset --hard; git pull)
fi

if [ ! -d site-ffnef ]; then
  git clone https://github.com/Neanderfunk/site-ffnef
else
  (cd site-ffnef; git reset --hard; git pull)
fi

if [ ! -d site-ffho ]; then
  git clone https://git.c3pb.de/freifunk-pb/site-ffho.git
else
  (cd site-ffho; git reset --hard; git pull)
fi

cd gluon

for sitedir in ../site-ffnef/*; do
  cp $sitedir/modules.incomplete $sitedir/modules
  grep -v ^GLUON_SITE_FEEDS= ../site-ffho/modules >> $sitedir/modules

  outputdir=out/$(basename $sitedir)
  mkdir -p $outputdir
  params="GLUON_SITEDIR=$PWD/$sitedir GLUON_OUTPUTDIR=$outputdir GLUON_BRANCH=experimental"
  echo $params
  make update $params
  #make GLUON_TARGET=ar71xx-generic $params clean V=s # not mentioned in doc
  echo CONFIG_CCACHE=y >> include/config
  make GLUON_TARGET=ar71xx-generic $params V=s
  make manifest $params
done
#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest

#rm -rf /where/to/put/this/experimental
#cp -r images /where/to/put/this/experimental
