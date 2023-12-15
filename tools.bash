#!/bin/bash -ex
# Copyright (c) 2014-2015 Arduino LLC
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

source build.conf

mkdir -p toolsdir/bin
cd toolsdir
TOOLS_PATH=`pwd`
cd bin
TOOLS_BIN_PATH=`pwd`
cd ../../

export PATH="$TOOLS_BIN_PATH:$PATH"

if [ -z "$MAKE_JOBS" ]; then
	MAKE_JOBS="2"
fi

if [[ ! -f autoconf-${AUTOCONF_VERSION}.tar.bz2  ]] ;
then
	wget $AUTOCONF_SOURCE
fi

tar xfjv autoconf-${AUTOCONF_VERSION}.tar.bz2

cd autoconf-${AUTOCONF_VERSION}

find -name Makefile.in -exec sed -i "/^pkgdatadir/s:$:-${AUTOCONF_VERSION}:" {} +

CONFARGS="--prefix=$TOOLS_PATH --program-suffix=-${AUTOCONF_VERSION}"

./configure $CONFARGS

nice -n 10 make -j $MAKE_JOBS pkgdatadir="${TOOLS_PATH}/share/autoconf-${AUTOCONF_VERSION}"

make install

cd -

if [[ ! -f automake-${AUTOMAKE_VERSION}.tar.bz2  ]] ;
then
	wget $AUTOMAKE_SOURCE
fi

tar xfjv automake-${AUTOMAKE_VERSION}.tar.bz2

cd automake-${AUTOMAKE_VERSION}

patch -p1 < ../automake-patches/0001-fix-perl-522.patch

cp ../config.guess-am-1.11.4 lib/config.guess
./bootstrap

CONFARGS="--prefix=$TOOLS_PATH"

./configure $CONFARGS

# Prevent compilation problem with docs complaining about @itemx not following @item
cp doc/automake.texi doc/automake.texi2
cat doc/automake.texi2 | $SED -r 's/@itemx/@c @itemx/' >doc/automake.texi
rm doc/automake.texi2

nice -n 10 make -j $MAKE_JOBS

make install

cd -

if [[ ! -f autoconf-${GCC_AUTOCONF_VERSION}.tar.xz  ]] ;
then
	wget $GCC_AUTOCONF_SOURCE
fi

tar xfJv autoconf-${GCC_AUTOCONF_VERSION}.tar.xz

cd autoconf-${GCC_AUTOCONF_VERSION}

find -name Makefile.in -exec sed -i "/^pkgdatadir/s:$:-${GCC_AUTOCONF_VERSION}:" {} +

CONFARGS="--prefix=$TOOLS_PATH --program-suffix=-${GCC_AUTOCONF_VERSION}"

./configure $CONFARGS

nice -n 10 make -j $MAKE_JOBS pkgdatadir="${TOOLS_PATH}/share/autoconf-${GCC_AUTOCONF_VERSION}"

make install

cd -

if [[ ! -f automake-${GCC_AUTOMAKE_VERSION}.tar.xz  ]] ;
then
	wget $GCC_AUTOMAKE_SOURCE
fi

tar xfJv automake-${GCC_AUTOMAKE_VERSION}.tar.xz

cd automake-${GCC_AUTOMAKE_VERSION}

cp ../config.guess-am-1.11.4 lib/config.guess
./bootstrap

CONFARGS="--prefix=$TOOLS_PATH"

./configure $CONFARGS

# Prevent compilation problem with docs complaining about @itemx not following @item
cp doc/automake.texi doc/automake.texi2
cat doc/automake.texi2 | $SED -r 's/@itemx/@c @itemx/' >doc/automake.texi
rm doc/automake.texi2

nice -n 10 make -j $MAKE_JOBS

make install

cd -

rm -f "${TOOLS_BIN_PATH}/autoconf"
wget -O "${TOOLS_BIN_PATH}/autoconf" https://raw.githubusercontent.com/gentoo/autotools-wrappers/main/ac-wrapper.sh
chmod a+x "${TOOLS_BIN_PATH}/autoconf"

rm -f "${TOOLS_BIN_PATH}/automake"
wget -O "${TOOLS_BIN_PATH}/automake" https://raw.githubusercontent.com/gentoo/autotools-wrappers/main/am-wrapper.sh
chmod a+x "${TOOLS_BIN_PATH}/automake"

for x in auto{header,m4te,reconf,scan,update} ifnames; do
	ln -sfv "${TOOLS_BIN_PATH}/autoconf" "${TOOLS_BIN_PATH}/$x"
done

ln -sfv "${TOOLS_BIN_PATH}/automake" "${TOOLS_BIN_PATH}/aclocal"
