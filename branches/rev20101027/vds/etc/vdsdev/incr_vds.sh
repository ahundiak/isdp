# $Id: incr_vds.sh,v 1.1.1.1 2001/01/04 21:07:29 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vdsdev/incr_vds.sh 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: incr_vds.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:07:29  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

#
# Filename :		incr_vds.sh
# Revision date :	93/03/12
# Description :		I/VDS releases certification process
# 
# How it works :
# ============
#                 ---------------------
# 
# Developers area        vds             latest integration
#                        devcert         certified by developers
# 
#                 ---------------------
# 
# 3D modeling team        precert         temporary location before certif
#                         vdscert         certified by the 3D modeling
#                         vdspload        PLOAD release of VDS
# 
#                 ---------------------
# 

echo "\n"
echo "		------------------------------------------------------"
echo "		Running \"I/VDS releases certification process\" utility"
echo "		------------------------------------------------------"
echo "\n"
 
# -1) List of products customization

	# product_list="vds struct route" 
	product_list="vds23"

# 0) List of environments customization

	host_vdsdev=vdsdev
	user_vdsdev=vds23
	pwd_vdsdev=vds

	host_devcert=vdsdev
	user_devcert=devcert
	pwd_devcert=devcert

	host_precert=vdsdev
	user_precert=precert
	pwd_precert=precert

	host_vdscert=vdsdev
	user_vdscert=vdscert
	pwd_vdscert=vdscert

	host_vdspload=vdsdev
	user_vdspload=vdspload
	pwd_vdspload=vdspload

# 1) Get current environment

	host_current=`uname -n`
	user_current=`basename $HOME`

# 2) Depending on which location we are

case "$user_current" in

   "$user_vdsdev")					# genesis

      source=$host_vdsdev.$user_vdsdev.$pwd_vdsdev
      target=$host_devcert.$user_devcert.$pwd_devcert

      echo "This command will copy product files from $source"
      echo "		to $target "
      echo "Do you wish to continue ? (y/n)"

      read answer
      if [ "$answer" != "y" ]
         then
         echo "Command aborted on your request..."
         exit 2
         fi

      for product in $product_list
         do	
	    if [ "$product" = "vds23" ]
		then 
		    product="vds"
	    fi
            echo "Send product files for $product ? (y/n)"

            read answer
            if [ "$answer" != "y" ]
               then
               continue
               fi

	    echo "Starting sending product files for $product..."
            fmu -v -a $target send $HOME/ws_s/$product/* ws_s/$product

	    echo "Updating install.sh"

	    opt="s/VDS_DEVEL=\"y\"/VDS_DEVEL=\"n\"/"
	    /bin/sed -e "${opt}" $HOME/ws_s/$product/install.sh > \
				   $HOME/ws_s/$product/install1.sh
	    fmu -v -a $target send $HOME/ws_s/$product/install1.sh \
					 ws_s/$product/install.sh
	    rm -f $HOME/ws_s/$product/install1.sh

	    if [ "$product" = "vds" ] ; then
		echo "Remove non-runtime files"
		fmu -a $target comm rm ws_s/$product/lib*.p
		fmu -a $target comm rm ws_s/$product/devel.p
		fmu -a $target comm rm ws_s/$product/Src*.p
	    fi
            echo "\n"
         done

      break ;;

   "$user_devcert")					# second stage

      source=$host_devcert.$user_devcert.$pwd_devcert
      target=$host_precert.$user_precert.$pwd_precert

      echo "This command will copy product files from $source"
      echo "		to $target"
      echo "Do you wish to continue ? (y/n)"

      read answer
      if [ "$answer" != "y" ]
         then
         echo "Command aborted on your request..."
         exit 2
         fi

      for product in $product_list
         do	
            echo "Send product files for $product ? (y/n)"

            read answer
            if [ "$answer" != "y" ]
               then
               continue
               fi

	    echo "Starting sending product files for $product..."
            set -x
            fmu -v -a $target send $HOME/ws_s/$product/* ws_s/$product
            set +x
            echo "\n"
         done

      break ;;

   "$user_precert")					# temporary stage

      source=$host_precert.$user_precert.$pwd_precert
      target=$host_vdscert.$user_vdscert.$pwd_vdscert

      echo "This command will copy product files from $source"
      echo "		to $target"
      echo "Do you wish to continue ? (y/n)"

      read answer
      if [ "$answer" != "y" ]
         then
         echo "Command aborted on your request..."
         exit 2
         fi

      for product in $product_list
         do	
            echo "Send product files for $product ? (y/n)"

            read answer
            if [ "$answer" != "y" ]
               then
               continue
               fi

	    echo "Starting sending product files for $product..."
            set -x
            fmu -v -a $target send $HOME/ws_s/$product/* ws_s/$product
            set +x
            echo "\n"
         done

      break ;;

   "$user_vdscert")					# fourth stage

      source=$host_vdscert.$user_vdscert.$pwd_vdscert
      target=$host_vdspload.$user_vdspload.$pwd_vdspload

      echo "This command will copy product files from $source"
      echo "		to $target"
      echo "Do you wish to continue ? (y/n)"

      read answer
      if [ "$answer" != "y" ]
         then
         echo "Command aborted on your request..."
         exit 2
         fi

      for product in $product_list
         do	
            echo "Send product files for $product ? (y/n)"

            read answer
            if [ "$answer" != "y" ]
               then
               continue
               fi

	    echo "Starting sending product files for $product..."
            set -x
            fmu -v -a $target send $HOME/ws_s/$product/* ws_s/$product
            set +x
            echo "\n"
         done

      break ;;

   "$user_vdspload")					# ultimate stage

      echo "This location is for the PLOAD release => no increment needed \n"
      exit 2
      break ;;

   *)
      echo "Invalid environment : user $user_current at node $host_current\n"
      exit 2
      break ;;

   esac

# 3) Initialize server location

set -x
fmu -v -a $target com bin/initprod2
set +x
echo "\n"
