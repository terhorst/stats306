#!/bin/sh
rm -rf stats306_master
git clone https://github.com/terhorst/stats306 stats306_master
chmod -R 555 stats306_master
cp stats306_master/.README.txt ./README.txt
