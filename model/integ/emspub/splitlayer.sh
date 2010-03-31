#
# script to split the ems public layer into sun, sgi and clipper layers
#
#  Tim McKee  6/7/93
#
NEWHOME=/usr9/v24
for prod in grnuc model mds ems emscaf emscde emscff emspam emspcs emspfd emsppp draft iems bspmath exnuc
 do 
    cd $prod
    rm $NEWHOME/ws_ems.sun/$prod/*
    splitproduct.sh product.sun $NEWHOME/ws_ems.sun/$prod
    rm $NEWHOME/ws_ems.sgi/$prod/*
    splitproduct.sh product.sgi $NEWHOME/ws_ems.sgi/$prod
    rm $NEWHOME/ws_ems.clip/$prod/*
    splitproduct.sh product.clip $NEWHOME/ws_ems.clip/$prod
    cd ..
 done
cd dignuc
rm $NEWHOME/ws_ems.clip/dignuc/*
echo "Linking dignuc to clipper area"
ln * $NEWHOME/ws_ems.clip/dignuc
