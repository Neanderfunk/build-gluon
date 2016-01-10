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
  (cd site-ffnef; rm -f */modules; git pull)
fi

if [ ! -d site-ffho ]; then
  git clone https://git.c3pb.de/freifunk-pb/site-ffho.git
else
  (cd site-ffho; git pull)
fi

cd gluon

if [ -d ../site-ffnef/ffnef-met ]; then
  default_site=../site-ffnef/ffnef-met
else
  for sitedir in ../site-ffnef/*; do
     default_site=$sitedir
     break
  done
fi


for sitedir in ../site-ffnef/*; do
  cat ../site-ffho/modules >> $sitedir/modules

  outputdir=out/$(basename $sitedir)
  mkdir -p $outputdir
  params="GLUON_SITEDIR=$PWD/$sitedir GLUON_OUTPUTDIR=$outputdir GLUON_BRANCH=experimental"
  echo $params
  make update $params
  #make GLUON_TARGET=ar71xx-generic $params clean V=s # not mentioned in doc
  make GLUON_TARGET=ar71xx-generic $params V=s
  make manifest $params
done
#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest

#rm -rf /where/to/put/this/experimental
#cp -r images /where/to/put/this/experimental
