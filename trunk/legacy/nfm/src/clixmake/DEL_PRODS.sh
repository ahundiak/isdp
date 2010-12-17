#######################################################################
#   
#  To Deliver the NFM Products
#
#                                                -- Jujare, 15 FEB 1995

#######################################################################
export PROF=.profile
# Get the Version Number from $PROF

  if ! egrep -e 'VERSION=[0-9]+(.[0-9]+)*[      ]*$' $PROF 1>/dev/null 2>&1
  then
      echo "Error: Check Version variable in $PROF"
      exit 1
  fi

  export VER_DIR=$(egrep -e '^VERSION=.*' $PROF |
              sed -e 's/VERSION=//g' -e 's/[.]//g')

  export DEL_DIR=$HOME/$VER_DIR
  export DATE_STAMP=`date '+%m%d0000'`

cd $DEL_DIR
for dir in deliver_ui2 deliver_srv2 deliver_dp2
do
  cd $dir; echo "\n\n\t\t D E L I V E R I N G - $dir \n\n";
  deliver.sh $DATE_STAMP; cd - ;
  echo "\n\n\t\t D E L I V E R E D - $dir \n\n";
done

