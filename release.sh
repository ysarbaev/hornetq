#!/bin/bash

# Builds deb package for HornetQ server

HORNETQ_VERSION=`cat pom.xml | grep '<version>' | head -n 1 | sed 's/[<,>,version,\/]//g' | sed 's/\s//g'`

SOURCE_DIR=distribution/hornetq/target/hornetq-$HORNETQ_VERSION-bin/hornetq-$HORNETQ_VERSION

TARGET_DIR=.deb

DEB_DIR=$TARGET_DIR/DEBIAN

DEB_NAME="hornetq_"$HORNETQ_VERSION"_all.deb"

CONFIG_TEMPLATES_DIR=$SOURCE_DIR/config/stand-alone/non-clustered

ETC=$TARGET_DIR/etc/hornetq

LIB=$TARGET_DIR/usr/lib/hornetq

JARS=$TARGET_DIR/usr/share/hornetq

if [ ! -e $SOURCE_DIR ]; then
	echo "Can not find $SOURCE_DIR, try to run mvn install -Prelease package";
	exit 6
fi

mkdir -p $TARGET_DIR

# Copy template stuff
cp -r deb/* $TARGET_DIR

# Control
sed -i "s/\$VERSION/$HORNETQ_VERSION/" "$DEB_DIR/control"

# Conffiles
mkdir -p "$ETC/config"

cp $CONFIG_TEMPLATES_DIR/* $ETC/config/

ls $ETC/config | xargs -n1 echo "/etc/hornetq/config/" | sed "s/\s//" > "$DEB_DIR/conffiles"
echo "/etc/init.d/hornetq" >> "DEB_DIR/conffiles"

# All jars, so, etc
mkdir -p $LIB

cp -r $SOURCE_DIR/lib $JARS
cp -r $SOURCE_DIR/licenses $LIB
cp -r $SOURCE_DIR/schema $LIB

cp $SOURCE_DIR/bin/*.so $LIB

# Check sums
CURRENT_DIR=`pwd`
cd $TARGET_DIR

md5deep -rl usr >> DEBIAN/md5sums
md5deep -rl etc >> DEBIAN/md5sums

cd $CURRENT_DIR

# Permissions

find $TARGET_DIR/etc -type d | xargs -n1 chmod 0755
find $TARGET_DIR/usr -type d | xargs -n1 chmod 0755

find $TARGET_DIR/etc -type f | xargs -n1 chmod 0644
find $TARGET_DIR/usr -type f | xargs -n1 chmod 0644

chmod 0644 $DEB_DIR/conffiles
chmod 0644 $DEB_DIR/md5sums

chmod 0755 $TARGET_DIR/etc/init.d/hornetq 


# Build deb
fakeroot dpkg-deb --build $TARGET_DIR

mv $TARGET_DIR".deb" $DEB_NAME

# Verify
lintian $DEB_NAME

# Clean up
rm -rf $TARGET_DIR
