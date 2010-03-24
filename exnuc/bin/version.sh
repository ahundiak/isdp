set -e
trap "rm -rf \"$PRODUCT_NAME\"ver.c" 1 2 3 15

echo "#include \"version.h\"" > "$PRODUCT_NAME"ver.c
nawk '{ printf "INGR_S_PRODUCT_DEF %s = {\"I/%-8s%-12s%9s\",0,\"%s\",0};\n",XX, X, Y, D, ID; exit }' \
  X=$PRODUCT_NAME Y=`echo $PRODUCT_VERSION | cut -c1-11 ` \
  XX=${PRODUCT_NAME}_appl_version_id D=`date '+%d-%h-%y'` ID=$IDnumber \
  >> "$PRODUCT_NAME"ver.c <<-EOF
1
EOF
