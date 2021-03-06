#!/bin/sh

set -e

umask 0022

revision="$1"
branch="$2"

GLUON_TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic \
x86-generic x86-kvm_guest x86-64 x86-xen_domu"

gluon_release=$(date '+%Y%m%d%H%M-broken') # same release for every community

cd $branch
if [ ! -d gluon ]; then
  git clone -b v2016.1.x https://github.com/freifunk-gluon/gluon
else
  (cd gluon; git reset --hard; git pull origin v2016.1.x)
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

if [ -d "$HOME/ccache" ]; then
  export PATH="$HOME/ccache:$PATH"
fi

first_run=true

for sitedir in ../site-ffnef/*; do
#for sitedir in ../site-ffnef/ffnef-met; do
  outputdir=out/$(basename $sitedir)
  params="GLUON_SITEDIR=$PWD/$sitedir GLUON_OUTPUTDIR=$PWD/$outputdir \
	GLUON_RELEASE=$gluon_release GLUON_BRANCH=experimental V=s"
  mkdir -p $outputdir

  if $first_run; then
    cp $sitedir/modules.incomplete $sitedir/modules
    grep -v ^GLUON_SITE_FEEDS= ../site-ffho/modules >> $sitedir/modules
  
    make update $params
    #make GLUON_TARGET=ar71xx-generic $params clean V=s # really necessary?
    echo CONFIG_CCACHE=y >> include/config
  fi

  for gluon_target in $GLUON_TARGETS
  do
  	  if $first_run; then
      	make GLUON_TARGET=$gluon_target $params
		first_modules=$outputdir/modules
	  else
      	make GLUON_TARGET=$gluon_target $params images
		rm -rf $outputdir/modules
		ln -s $first_modules $outputdir/modules
	  fi
  done
  make manifest $params
  if $first_run; then first_run=false; fi
done

chmod go+rX -R $outputdir

#contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest
