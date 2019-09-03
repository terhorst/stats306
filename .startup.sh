#!/bin/bash -x
exec > .log.txt 2>&1
REPOSRC=https://github.com/terhorst/stats306
LOCALREPO=.stats306_fresh

# We do it this way so that we can abstract if from just git later on
LOCALREPO_VC_DIR=$LOCALREPO/.git

if [ ! -d $LOCALREPO_VC_DIR ]
then
    git clone --depth 1 $REPOSRC $LOCALREPO
else
    cd $LOCALREPO
    chmod -R 777 .
    rm -f .git/index.lock
    git fetch
    git reset --hard origin/master
    cd ..
fi

rsync --ignore-existing -ra .stats306_fresh stats306

chmod -R a=rX $LOCALREPO
rm -f README.txt .Rprofile
cp $LOCALREPO/.README.txt ./README.txt
cp $LOCALREPO/.Rprofile .Rprofile
chmod 444 .Rprofile README.txt
chmod 744 -R stats306
mkdir -p 'problem sets'
rsync -av --ignore-existing .stats306_fresh/ps* 'problem sets/'
chmod -R a=rwX 'problem sets'
rm -f core.ZMQ*
