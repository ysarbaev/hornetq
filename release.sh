#!/bin/bash

# Builds deb package for HornetQ server

HORNETQ_VERSION=`cat pom.xml | grep '<version>' | head -n 1 | sed 's/[<,>,version,\/]//g' | sed 's/\s//g'`

SOURCE=distribution/hornetq/target/hornetq-$HORNETQ_VERSION-bin/hornetq-$HORNETQ_VERSION

NAME=hornetq

TARGET=.deb

DEB=$TARGET/DEBIAN

DEB_NAME="hornetq_"$HORNETQ_VERSION"_all.deb"

CONFIG_TEMPLATES=$SOURCE/config/stand-alone/non-clustered

ETC=$TARGET/etc/$NAME

LIB=$TARGET/usr/lib/$NAME

JARS=$TARGET/usr/share/$NAME

COPYRIGHT=$TARGET/usr/share/doc/$NAME

if [ ! -e $SOURCE ]; then
	echo "Can not find $SOURCE, try to run mvn install -Prelease package";
	exit 6
fi

mkdir -p $DEB
mkdir -p $ETC
mkdir -p $ETC/config
mkdir -p $LIB
mkdir -p $JARS
mkdir -p $COPYRIGHT

# Copy template stuff
cp -r deb/* $TARGET

# Control
sed -i "s/\$VERSION/$HORNETQ_VERSION/" "$DEB/control"

# Conffiles
cp $CONFIG_TEMPLATES/* $ETC/config/

# Copyright
cat $SOURCE/licenses/LICENSE.txt > $COPYRIGHT/copyright

ls $ETC/config | xargs -n1 echo "/etc/hornetq/config/" | sed "s/\s//" > "$DEB/conffiles"
echo "/etc/init.d/hornetq" >> "$DEB/conffiles"

# All jars, so, etc

cp -r $SOURCE/lib $JARS
cp -r $SOURCE/licenses $LIB
cp -r $SOURCE/schema $LIB

cp $SOURCE/bin/*.so $LIB

# Check sums
CURRENT=`pwd`
cd $TARGET

md5deep -rl usr >> DEBIAN/md5sums
md5deep -rl etc >> DEBIAN/md5sums

cd $CURRENT

# Permissions

find $TARGET/etc -type d | xargs -n1 chmod 0755
find $TARGET/usr -type d | xargs -n1 chmod 0755

find $TARGET/etc -type f | xargs -n1 chmod 0644
find $TARGET/usr -type f | xargs -n1 chmod 0644

chmod 0644 $DEB/conffiles
chmod 0644 $DEB/md5sums

chmod 0755 $TARGET/etc/init.d/hornetq 


# Build deb
fakeroot dpkg-deb --build $TARGET

mv $TARGET".deb" $DEB_NAME

# Verify
lintian $DEB_NAME

# Clean up
rm -rf $TARGET
