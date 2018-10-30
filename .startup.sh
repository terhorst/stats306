#!/bin/sh
mkdir -p stats306
chmod -R 777 stats306
REPOSRC=https://github.com/terhorst/stats306
LOCALREPO=stats306

# We do it this way so that we can abstract if from just git later on
LOCALREPO_VC_DIR=$LOCALREPO/.git

if [ ! -d $LOCALREPO_VC_DIR ]
then
    git clone $REPOSRC $LOCALREPO
else
    cd $LOCALREPO
    git pull $REPOSRC
fi

chmod -R a=rX stats306
rm -f README.txt .Rprofile
cp stats306/.README.txt ./README.txt
cp stats306/.Rprofile .Rprofile
chmod 444 .Rprofile README.txt
mkdir -p 'problem sets'
rsync -av --ignore-existing stats306/ps* 'problem sets/'
chmod -R a=rwX 'problem sets'
