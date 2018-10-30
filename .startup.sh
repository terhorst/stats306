#!/bin/sh
mkdir -p stats306
chmod -R 777 stats306
./.clone_or_pull.sh https://github.com/terhorst/stats306 stats306
chmod -R a=rX stats306
rm -f README.txt .Rprofile
cp stats306/.README.txt ./README.txt
cp stats306/.Rprofile .Rprofile
chmod 444 .Rprofile README.txt
mkdir -p 'problem sets'
rsync -av --ignore-existing stats306/ps* 'problem sets/'
chmod -R a=rwX 'problem sets'
