#
# checkspec_all.sh - check spec.m's and update them if needed
# 
#    Usage  : checkspec_all.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
#
MAKELIST=$MODEL/build/makelist

for file in `cat $MAKELIST` src_stub
do
  cd $MODEL/$file
  checkspec.sh >> /tmp/bldlog 2>&1
done
