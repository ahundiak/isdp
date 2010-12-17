########################################################################
#
#  Automating the Build Procedure of NFM
#
#  1) Changes the Version Number in .profile
#  2) Runs makeversion to create NFMdate.h & NFMversion.h
#  3) Creates LOG/version.nfm file with New Version
#
#  Usage:
#      1) .  CH_VER
#                    ( OR )
#      2) CH_VER;   . .profile
#                                                -- Jujare, 15 FEB 1995
#
########################################################################

# Change PROF to .profile after testing successfully
# PROF=.profile

set -v
export PROF=.profile

# Get a Temporary Directory  

  if [ ! -d $HOME/tmp ]
  then 
      if ! mkdir $HOME/tmp  2>/dev/null
      then
         TMP__DIR="/tmp"
      fi
  else
      TMP__DIR="$HOME/tmp"
  fi

# Save a copy of $PROF in Temporary Directory

  echo "Your $PROF is stored in $TMP__DIR/$PROF.$$";
  cat $PROF > $TMP__DIR/$PROF.$$;


# Get the Version Number from $PROF 

  if ! egrep -e 'VERSION=[0-9]+(.[0-9]+)*[ 	]*$' $PROF 1>/dev/null 2>&1
  then
      echo "Error: Check Version variable in $PROF"
      exit 1
  fi

  export OLD_VER
  OLD_VER=$(egrep -e '^VERSION=.*' $PROF | 
              sed -e 's/VERSION=//g' -e 's/[.]//g')
  echo $OLD_VER  | read OLD_VER 

  echo "OLD_VER is <$OLD_VER>"

# Get New Version Number and
# Append New Version Number with 0's if required

  export NEW_VER
  NEW_VER=$(expr "$OLD_VER" + 1)
  OLD_NUM_CHAR=$(expr $(echo "$OLD_VER" | wc -c) - 1) 
  NEW_NUM_CHAR=$(expr $(echo "$NEW_VER" | wc -c) - 1) 

  i=$( expr $OLD_NUM_CHAR - $NEW_NUM_CHAR )
  while [ "$i" -gt "0" ]
  do
      NEW_VER="0$NEW_VER"
      i=$(expr $i - 1)
  done

# Add the dots (.) to version number and 
# Create New $PROF FILE

  i=$NEW_VER
  export num="`echo $i | cut -c1,2`"
  i=${i##??};

#echo "$num     $i"

  while [ "$i" != "" ] 
  do
    export num="$num.`echo $i | cut -c1,2`"
    i=${i##??};
# echo "$num     $i"
  done
  
  echo "NEW_VER is <$NEW_VER>"

  export NEW_VER_D=$num

#echo "NEW_VER_D is $NEW_VER_D"
  sed -e "s/^VERSION=.*/VERSION=$NEW_VER_D/p" $PROF > $PROF.new

  mv $PROF.new $PROF
  mv $OLD_VER  $NEW_VER

  ( cd $NEW_VER/version; VERSION="$NEW_VER_D"  makeversion )

  echo $NEW_VER > LOG/version.nfm
