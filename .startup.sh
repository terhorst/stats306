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


rm -f core.ZMQ*
chmod -R a=rX $LOCALREPO
rm -f README.txt .Rprofile
cp "$LOCALREPO/.README.txt" ./README.txt
cp "$LOCALREPO/.Rprofile" .Rprofile
chmod 444 .Rprofile README.txt
rsync --ignore-existing -ra "$LOCALREPO/lectures" lectures
rsync -av --ignore-existing "$LOCALREPO/problem sets" "problem sets"
chmod -R a=rwX 'problem sets'
chmod -R a=rwX 'lectures'
