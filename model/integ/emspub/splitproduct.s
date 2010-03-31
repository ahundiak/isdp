# script to split products into separate directories
# splitproduct.sh <product.def file> <newprod target directory>
#                 you must be in the directory of the newprod files for them
#                 to be linked correctly
#
# Tim McKee June 7, 1993
#

# check input 
if [ "$#" != "2" ]
 then
  echo "$0 : Invalid number of arguments"
  echo "      usage : $0 <product.def file> <newprod target directory>"
  exit 1
fi

# get file list
FILELIST=`sed -n "/^#FILE INFORMATION/,/^#END OF FILE INFORMATION/p" $1 | grep -v "FILE INFORMATION" | cut -d' ' -f1 | tr -d "#" `

for file in $FILELIST
do 
 echo "linking $file to $2"
 ln $file $2
done
# special processing for product.def
rm $2/product.def
ln $1 $2/product.def
