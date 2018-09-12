#!/bin/sh
mkdir -p stats306
chmod -R 777 stats306
rm -rf stats306
git clone --depth 1 https://github.com/terhorst/stats306 stats306
chmod -R a=rX stats306
cp stats306/.README.txt ./README.txt
mkdir -p 'problem sets'
rsync -av --ignore-existing stats306/ps* 'problem sets/'
chmod -R a=rwX 'problem sets'
