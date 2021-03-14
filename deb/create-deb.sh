#!/bin/bash

set -e

. ddarch-deb.conf

destDir="$installDir/usr/local/bin"
mkdir -p "$destDir" ||:
cp ../ddarch "$destDir"/

mkdir -p "$metaDir" ||:
cd $metaDir

echo "$description" > description-pak

cat > install.sh <<EOL
#!/bin/bash
cp -r $installDir/* /
EOL

chmod +x install.sh

checkinstall \
--install=no \
--fstrans=yes \
--requires="$requires" \
--pkgversion=$pkgVersion \
--pkgsource="$repo" \
--pkgname=$project \
--pkglicense=$license \
--maintainer="$maintainer" \
--pkgarch=all \
--deldesc=no \
--nodoc \
./install.sh

