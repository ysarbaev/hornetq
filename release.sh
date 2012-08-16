#!/bin/bash

# Builds deb package for HornetQ server

HORNETQ_VERSION = grep "<version>" pom.xml | head -n 1 | sed "s/[<,>,version,\/]//g"

SOURCE_DIR = "./distribution/hornetq/target/$HORNETQ_VERSION-bin/$HORNETQ_VERSION"

TARGET_DIR = "./deb"

DEB_DIR = "$TARGET_DIR/DEBIAN"

DEB_NAME = "hornetq_$HORNETQ_VERSION_all.deb"

CONFIG_TEMPLATES_DIR = "$SOURCE_DIR/config/standalone/non-clustered"

ETC = "$TARGET_DIR/etc/hornetq"

LIB = "$TARGET_DIR/usr/lib/hornetq"

if [ ! -e $SOURCE_DIR ] then
	echo "Can not find $SOURCE_DIR, try to run mvn install -Prelease package"
	exit 1
fi

mkdir $TARGET_DIR

# Copy template stuff
cp -r DEBIAN $TARGET_DIR

# Control
sed -i "s/VERSION/$HORNETQ_VERSION/" "$DEB_DIR/control"

# Copyright
cp "$SOURCE_DIR/licenses/LGPL.txt" "$DEB_DIR/copyright"

# Changelog
touch "$DEB_DIR/changelog"

# Conffiles
mkdir -p "$ETC/config"

cp "$CONFIG_TEMPLATES_DIR/*" "$ETC/config"

ls $ETC | xargs -n1 echo "/etc/hornetq/config/" | sed "s/\s//" > "$DEB_DIR/conffiles"

mkdir "$LIB"

cp -r "$SOURCE_DIR/lib" "$LIB"
cp -r "$SOURCE_DIR/licenses" "$LIB"
cp -r "$SOURCE_DIR/schemas" "$LIB"

cp "$SOURCE_DIR/bin/*.so" "$LIB"


# Build deb

fakeroot dpkg-deb --build $TARGET_DIR

mv "*.deb" $DEB_NAME

