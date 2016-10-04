#!/bin/sh

set -e

umask 0022

revision="$1"
branch="$2"

GLUON_TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic \
x86-generic x86-kvm_guest x86-64 x86-xen_domu"

#GLUON_TARGETS=ar71xx-generic

gluon_release=$(date '+%Y%m%d%H%M') # same release for every community

signing_key=6664E7BDA6B669881EC52E7516EF3F64CB201D9C # Matthias Schiffer <mschiffer@universe-factory.net>
gpg --recv-key $signing_key

cd $branch
if [ ! -d gluon ]; then
  git clone -b v2016.2.x https://github.com/freifunk-gluon/gluon
else
  (cd gluon; git reset --hard; git pull origin v2016.2.x)
fi

(cd gluon; git verify-commit --raw v2016.2.x 2>&1)|grep  "^\[GNUPG:\] VALIDSIG $signing_key"

if [ ! -d site-ffnef ]; then
  git clone -b v2016.2.x https://github.com/Neanderfunk/site-ffnef
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
  imagedir=out/$(basename $sitedir)
  moduledir=out/modules

  params0="GLUON_SITEDIR=$PWD/$sitedir \
	GLUON_MODULEDIR=$PWD/$moduledir \
	GLUON_IMAGEDIR=$PWD/$imagedir \
	GLUON_RELEASE=$gluon_release V=s"
  params="$params0 GLUON_BRANCH=stable"

  mkdir -p $imagedir $moduledir
  
  rm -rf build/*/profiles/*/root/

  if $first_run; then
    cp $sitedir/modules.incomplete $sitedir/modules
    grep -v ^GLUON_SITE_FEEDS= ../site-ffho/modules >> $sitedir/modules
  
    make update $params
  fi

  for gluon_target in $GLUON_TARGETS
  do
  	  if $first_run; then
	    make GLUON_TARGET=$gluon_target $params clean V=s
	  fi

     make GLUON_TARGET=$gluon_target $params
  done
  make manifest $params0 GLUON_BRANCH=stable
  make manifest $params0 GLUON_BRANCH=beta
  make manifest $params0 GLUON_BRANCH=experimental
  if $first_run; then first_run=false; fi
done

chmod go+rX -R $imagedir

#contrib/sign.sh $SECRETKEY images/sysupgrade/stable.manifest
