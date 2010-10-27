#!/bin/ksh

# print_file.sh
# -------------
#	print a report with 132 columns
#
# 	usage: print_file.sh  [<qpr flags>]  <files>
#
#	    <qpr flags>
#		-t 			ignored - set by this script
#		all other flags 	passed on to qpr
#

# Queue Selection
# ---------------
#  The print queue may be specified by default, with flags, or in this script
#	Default:	defined by QPR_QUEUE environment variable
#	Flag:		"-q <queue name>"
#	Script:		modify this script by explicitly adding the 
#				-q flag to every qpr call


# Print options
# -------------
#   1. Print as text file using compressed mode
#	  This is the default option.  
#	  Assumes you can print files using "qpr -t text"
#	     (print server is running IP/TEXT metafile interpreter)
#
#   2. Print as postscript file in either landscape or portrait mode
#	  This is available as an option.  
#	  Requires:
#	      - postscript print server running IP/SCRIPT metafile interpreter,
#	      	  	ie - you can print files using "qpr -t script"
#	      - va2ps on the system
#		    available from newprod:
#			 load VTOOLS (SS01198)
#			 choose Environ V option, select va2ps
#  3. Print using other available file formats
#	This must be added to this script.
#
#   Select printer option in function Print below

#---------------------------------------------------
# function Print
#	print a single report file $1
Print () {

#   choose only one of the following 3 options
	echo ""

	# Option 1: print text file
	# -----------------------
 	#	portrait mode, 66 lines/page, 12pt compressed
	#   This line is enabled (not commented out) by default
	echo "PrepText $1 | qpr -t text $flags"
	PrepText $1 | qpr -t text $flags
	
	
	# Option 2: print postscript file
	# -------------------------------
	#	portrait mode, up to 108 lines/page
	#	font size set to maximum value to avoid line wrapping
	#  This line is disabled (commented out) by default
	#echo "va2ps -F6.7 -nn -nh -ns -p $1 | qpr -t script $flags"
	#va2ps -F6.7 -nn -nh -ns -p $1 | qpr -t script $flags
	
	
	# Option 3: print postscript file
	# -------------------------------
	#	landscape mode, up to 78 lines/page, font size 6.8
	#  This line is disabled (commented out) by default
	#echo "va2ps -nn -nh -ns -w $1 | qpr -t script $flags"
	#va2ps -nn -nh -ns -w $1 | qpr -t script $flags
}

#------------------------------------------------------
# function PrepText 
#    prepares text file for printing with 132 columns 
# 	adds IP/TEXT printer control characters to file 
#	(see IP_TEXT README file for complete list of control characters)
PrepText () {

    # turn on compressed mode - '\15', octal 17
    print -n \\017
    
    # echo file contents
    cat $1
    
    # turn off compressed mode - '\18', octal 22
    print -n \\022
}

#------------------------------------------------------
# Main 

qflag=0
flags=
usage="  usage: $0 [<qpr flags>] <report files>"

# check arguments
if [ $# -eq 0 ]; then echo "$usage" ; exit 1; fi

# read flags
for arg in $*
	do case $1 in

	-t )	shift; shift; echo "  $0: -t option ignored";;
	-mb )	flags="$flags $1"; shift;;
	-me )	flags="$flags $1"; shift;;
	-R )	flags="$flags $1"; shift;;
	-s* )	flags="$flags $1"; shift;;
	-x )	flags="$flags $1"; shift;;
	-z )	flags="$flags $1"; shift;;
	-q )	qflag=1;flags="$flags $1 $2"; shift; shift;;
	-* )	flags="$flags $1 $2"; shift; shift;;
	* )	break;
	esac
done
	

# check files, environment
if [ $# -eq 0 ]
	then echo "  $0: no files specified";  exit 1
elif [ qflag -eq 0 -a -z "$QPR_QUEUE" ]
	then 	echo "  $0: No default queue is defined" ;
		echo "	Environment variable QPR_QUEUE defines default queue"; 
		exit 1
fi

# loop over files
for file in $*
	do if [ ! -f $file ]
		then echo "  $0: No such report file: $file"; continue
	else
		Print $file
	fi
done
