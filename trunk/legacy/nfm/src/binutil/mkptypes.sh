echo "$1:"
echo "#ifndef $1_PROTO_H" > $2/$1proto.h
echo "#define $1_PROTO_H" >> $2/$1proto.h
echo "" >> $2/$1proto.h
mkptypes -e -p __$1 *.*c >> $2/$1proto.h
echo "" >> $2/$1proto.h
echo "#endif" >> $2/$1proto.h
