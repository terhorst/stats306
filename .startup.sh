#!/bin/sh
rm -rf stats306
git clone https://github.com/terhorst/stats306 stats306
chmod -R 555 stats306
cp stats306/.README.txt ./README.txt
mkdir -p 'problem sets'
rsync -ar --ignore-existing stats306/ps* problem\ sets/
