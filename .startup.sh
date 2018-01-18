#!/bin/sh
git clone https://github.com/terhorst/stats306 || (cd stats306 ; git stash; git pull; git stash pop)
R -e 'install.packages("hexbin", repos="https://cran.cnr.berkeley.edu")'
