#####################################################################
#
#  For Changing the README and product.def files in 
#  Deliver directories 
#                                                         -- Jujare


#####################################################################
#  Before using the script change the following variables

  export VER_DIR=03050218
  export OLD_VER=03.05.02.17
  export NEW_VER=03.05.02.18
  export OLD_DATE=26-May-1995
#
#

  export NEW_DATE=$(date '+%d-%b-%Y')
  export DEL_DIR=$HOME/$VER_DIR
cd $DEL_DIR

for dir in deliver_ui2 deliver_srv2 deliver_dp2
do
  cd $dir;
  sed    -e "s/$OLD_VER/$NEW_VER/g" \
         -e "s/$OLD_DATE/$NEW_DATE/g" README  > README.t

  cp README.t README
  sed    -e "s/$OLD_VER/$NEW_VER/g" \
         -e "s/$OLD_DATE/$NEW_DATE/g" product.def > product.def.t

  cp product.def.t product.def
  cd - ;
done

