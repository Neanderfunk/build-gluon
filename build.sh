##!/bin/sh

set -e

revision="$1"
branch="$2"

GLUON_TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic"

cd $branch

if [ ! -d gluon ]; then
  git clone --no-checkout https://github.com/freifunk-gluon/gluon
  (cd gluon; git checkout -b beta v2015.1.2)
fi

#(cd gluon
#git fetch origin
#git reset --hard v2015.1.2)

if [ ! -d site-ffnef ]; then
  git clone https://github.com/Neanderfunk/site-ffnef $branch
else
  (cd site-ffnef; git reset --hard; git pull)
fi

if [ ! -d site-ffho ]; then
  git clone https://git.c3pb.de/freifunk-pb/site-ffho.git
else
  (cd site-ffho; git reset --hard; git pull)
fi

cd gluon
mkdir -p out

for sitedir in ../site-ffnef/*; do
#for sitedir in ../site-ffnef/ffnef-met ../site-ffnef/ffnef-rat; do
#for sitedir in ../site-ffnef/ffnef-met; do
  cp $sitedir/modules.incomplete $sitedir/modules
  #grep -v ^GLUON_SITE_FEEDS= ../site-ffho/modules >> $sitedir/modules

  outputdir=out/$(basename $sitedir)
  mkdir -p $outputdir/images
  params="GLUON_SITEDIR=$PWD/$sitedir GLUON_IMAGEDIR=$PWD/$outputdir/images GLUON_OUTPUTDIR=$PWD/$outputdir GLUON_BRANCH=$branch"
  echo params: $params
  #make GLUON_TARGET=ar71xx-generic $params clean V=s # really necessary?
  make GLUON_TARGET=$target update $params
  for target in $GLUON_TARGETS
  do
	  #echo CONFIG_CCACHE=y >> include/config
      make GLUON_TARGET=$target $params V=s -j8
  done
  make manifest $params
done

chmod go+rX -R $outputdir

#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest
