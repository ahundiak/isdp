if [ "$1" = "-y" ]
then
  echo "-y switch no longer supported!"
  exit 256
fi
if [ "$1" = "-c" ]
 then 
   CP="cp"
else
   CP="ln"
fi
echo "promoting from $1 to $HOME  ----   OK? <y/n> [n]\b\b\c"
read ANS; : ${ANS:=n}
if [ $ANS != y ]
 then 
   echo ***ABORTING***
fi
echo
for d in *
do
	if [ -d $1/$d ]
	then
		if [ -f $1/$d/install.sh ] || [ -f $1/$d/install.sun ]
		then
			cd $1/$d
			echo "in ${PWD}"
			echo			
			bname=`basename $1/$d`
			echo "promote ${bname} [y]?\c "
			read ans
			if [ "$ans" != "n" ]
			then
				echo
				echo "${CP}ing * to ${HOME}/${bname}"
				$CP * ${HOME}/${bname}
				echo "finished"
				echo
			fi
			cd -
		fi
	fi
done
