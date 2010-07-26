#!/bin/ksh
# Make sure source/model/build/model.env is sources

model_dirlist.sh

cd $MODEL

find ./src*  -name '*.S' -exec ln {} spec \;
find ./ve    -name '*.S' -exec ln {} spec \;
find ./hsurf -name '*.S' -exec ln {} spec \;

cd $MODEL/config/english/messages/src
grmake -rk

cd $MODEL

SLICLIST=$MODEL/build/sliclist
for file in `cat $SLICLIST`
do
  cd $MODEL/$file
  pwd
  grmake -rk > /tmp/bldlog 2>&1
done