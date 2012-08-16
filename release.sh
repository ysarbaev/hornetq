#!/bin/bash

# Builds deb package for HornetQ server

HORNETQ_VERSION=`cat pom.xml | grep '<version>' | head -n 1 | sed 's/[<,>,version,\/]//g' | sed 's/\s//g'`

SOURCE_DIR=distribution/hornetq/target/hornetq-$HORNETQ_VERSION-bin/hornetq-$HORNETQ_VERSION

TARGET_DIR=deb

DEB_DIR=$TARGET_DIR/DEBIAN

DEB_NAME="hornetq_"$HORNETQ_VERSION"_all.deb"

CONFIG_TEMPLATES_DIR=$SOURCE_DIR/config/stand-alone/non-clustered

ETC=$TARGET_DIR/etc/hornetq

LIB=$TARGET_DIR/usr/lib/hornetq

if [ ! -e $SOURCE_DIR ]; then
	echo "Can not find $SOURCE_DIR, try to run mvn install -Prelease package";
	exit 6
fi

mkdir -p $TARGET_DIR

# Copy template stuff
cp -r DEBIAN $TARGET_DIR

# Control
sed -i "s/\$VERSION/$HORNETQ_VERSION/" "$DEB_DIR/control"

# Copyright
cp "$SOURCE_DIR/licenses/LGPL.txt" "$DEB_DIR/copyright"

# Changelog
touch "$DEB_DIR/changelog"

# Conffiles
mkdir -p "$ETC/config"

cp $CONFIG_TEMPLATES_DIR/* $ETC/config/

ls $ETC/config | xargs -n1 echo "/etc/hornetq/config/" | sed "s/\s//" > "$DEB_DIR/conffiles"

# All jars, so, etc
mkdir -p $LIB

cp -r $SOURCE_DIR/lib $LIB
cp -r $SOURCE_DIR/licenses $LIB
cp -r $SOURCE_DIR/schema $LIB

cp $SOURCE_DIR/bin/*.so $LIB

# Check sums
md5deep -rl usr >> DEBIAN/md5sums
md5deep -rl etc >> DEBIAN/md5sums

# Build deb
fakeroot dpkg-deb --build $TARGET_DIR

mv $TARGET_DIR".deb" $DEB_NAME

# Clean up
rm -rf $TARGET_DIR
