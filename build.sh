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
[ -z "$NO_GNUPG_KEY_CHECK" ] && gpg --recv-key $signing_key

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

rm -rf site-ffnef-rebootly
cp -a site-ffnef site-ffnef-rebootly
sed -i '$ a GLUON_SITE_PACKAGES += gluon-weeklyreboot ' \
	site-ffnef-rebootly/*/site.mk # append at the end of file
#sed -i -r 's/^(GLUON_SITE_PACKAGES :=)/\1 gluon-weeklyreboot/' site-ffnef-rebootly/*/site.mk

#if [ ! -d site-ffho ]; then
#  git clone https://git.c3pb.de/freifunk-pb/site-ffho.git
#else
#  (cd site-ffho; git reset --hard; git pull)
#fi

cd gluon

if [ -d "$HOME/ccache" ]; then
  export PATH="$HOME/ccache:$PATH"
fi

first_run=true

for sitedir in ../site-ffnef/*; do
#for sitedir in ../site-ffnef/ffnef-met; do
  sitename=$(basename $sitedir)
  sitedir_rebootly=$PWD/../site-ffnef-rebootly/$sitename
  imagedir=out/$sitename
  imagedir_rebootly=out/$(basename $sitedir)-rebootly
  moduledir=out/modules

  params0=" \
	GLUON_MODULEDIR=$PWD/$moduledir \
	GLUON_RELEASE=$gluon_release V=s"
	#GLUON_IMAGEDIR=$PWD/$imagedir \
  outpar="GLUON_IMAGEDIR=$PWD/$imagedir"
  stapar="GLUON_BRANCH=stable"
  params="GLUON_SITEDIR=$PWD/$sitedir $params0 $stapar"
  params_rebootly="GLUON_SITEDIR=$sitedir_rebootly $params0 $stapar"

  rm -rf $imagedir $imagedir_rebootly $moduledir
  mkdir -p $imagedir $imagedir_rebootly $moduledir
  
  rm -rf build/*/profiles/*/root/

  if $first_run; then
    cp -a $sitedir/modules.incomplete $sitedir/modules
    cp -a $sitedir/modules.incomplete $sitedir_rebootly/modules
    #grep -v ^GLUON_SITE_FEEDS= ../site-ffho/modules >> $sitedir/modules
  
    make update $params_rebootly
  fi

  make GLUON_TARGET=ar71xx-generic V=s $params_rebootly \
  	GLUON_IMAGEDIR=$imagedir_rebootly $stapar \
	clean \
	image/tl-wr841n-v9 image/tl-wr841nd-v3 image/tl-wr841nd-v5 \
 	image/tl-wr841nd-v7 image/tl-wr841n-v8 image/tl-wr841n-v9 \
 	image/tl-wr841n-v10 image/tl-wr841n-v11 image/tl-wr841n-v12
  
  for gluon_target in $GLUON_TARGETS
  do
  	  if $first_run; then
	    make GLUON_TARGET=$gluon_target $params clean V=s
	  fi

     make GLUON_TARGET=$gluon_target $params
  done
  make manifest GLUON_SITEDIR=$PWD/$sitedir $params0 $outpar GLUON_BRANCH=stable
  make manifest GLUON_SITEDIR=$PWD/$sitedir $params0 $outpar GLUON_BRANCH=beta
  make manifest GLUON_SITEDIR=$PWD/$sitedir $params0 $outpar GLUON_BRANCH=experimental
  if $first_run; then first_run=false; fi
done

chmod go+rX -R $imagedir

#contrib/sign.sh $SECRETKEY images/sysupgrade/stable.manifest
