#!/bin/sh

set -e

revision="$1"
branch="$2"

cd $branch

if [ ! -d gluon ]; then
  git clone https://github.com/freifunk-gluon/gluon v2015.1
else
  (cd gluon; git pull)
fi

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

#for sitedir in ../site-ffnef/*; do
for sitedir in ../site-ffnef/ffnef-met ../site-ffnef/ffnef-rat; do
  cp $sitedir/modules.incomplete $sitedir/modules
  grep -v ^GLUON_SITE_FEEDS= ../site-ffho/modules >> $sitedir/modules

  outputdir=out/$(basename $sitedir)
  mkdir -p $outputdir
  params="GLUON_SITEDIR=$PWD/$sitedir GLUON_OUTPUTDIR=$PWD/$outputdir GLUON_BRANCH=$branch"
  echo $params
  make update $params
  #make GLUON_TARGET=ar71xx-generic $params clean V=s # really necessary?
  echo CONFIG_CCACHE=y >> include/config
  for target in \
  	  ar71xx-generic ar71xx-nand mpc85xx-generic \
	  x86-generic x86-kvm_guest x86-64 x86-xen_domu
  do
  	  #echo $revision $params
      make GLUON_TARGET=$target $params V=s -j8
  done
  make manifest $params
done

chmod go+rX -R $outputdir

#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest
