#set -x
# delta_out -- icom copy out ckins since a given date
#
passwd=`grep root /etc/passwd | awk -F: '{print $2}'`
if [ "$passwd" ]
then
  my_id=`ps -l -p $$ | awk '{print $3}'`
  my_id=`echo $my_id | awk '{print $2}'`
  if [ "$my_id" -ne 0 ]
  then
    echo "Must be super-user to execute!"
    exit 0
  fi
fi

my_dir=/usr/icom/scripts

if [ $# -lt 1 ]
then
  echo "usage: $0 <date> <product> [dir] [srv.usr.pw] [node.usr.pw to notify ...]"
  echo "  defaults if - or \"\""
  echo "    date:   today"
  echo "    to_dir: $dflt_dir"
  echo "    server: $dflt_srv"
  exit 1
fi
echo $1
echo $2
echo $3
echo $4


today=`date +%m%d%y`
dat="$1"
if [ "$dat" = "-" ]
then dat=""
fi
if [ ! "$dat" ]
then dat=$today
fi
dat=`echo $dat | tr -d '/- '`

prod=pdu22

to_dir=$3

server=$4

cpfl=$my_dir/icomcopy.out
namefl=$my_dir/names.out
outfl=$my_dir/icomshow.out
#wadfile=d_${prod}.$today
wadfile=pdu22.$today

rm $my_dir/icomshow.out

echo "show since $dat > $outfl"
icom.x <<- END
	show -c ckin -s $dat -o $outfl /$prod
	END
echo "show -c ckin -s $dat -o $outfl /$prod"

awk "/Object :/ {print \"copy -d \" \$3 \" $to_dir\" substr (\$3, 6)}" $outfl \
    | sort -u > $cpfl

awk '{print $3}' $cpfl > $namefl
echo

echo "cleaning $to_dir"
su root <<- END
  rm -r $to_dir
  mkdir $to_dir
END

$my_dir/mk_dirs2 $to_dir

icom.x < $cpfl

cd $to_dir
echo "changing owner and group"
su root <<-END
find . -exec chown icom {} \;
find . -exec chgrp users {} \;
END
echo "backing up $PWD to $wadfile"
find . -depth -exec touch {} \;
echo "sending $wadfile"
find . -depth -print | cpio -ovc | compress | fmu $server send '-' $wadfile

echo "`basename $0` finished"
