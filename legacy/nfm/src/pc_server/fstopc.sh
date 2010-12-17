# This script 
#	1 . changes any occurrence of NFMfs to NFMpcfs       
#       2.  the function name is changed
# files affected :
#   NFMciitem.c NFMcoitem.c NFMciset.c NFMcoset.c
#   NFMcpitmfile.c NFMcpsetfile.c
#   NFMms.c 
# NFMciitem.c  -> NFMcheckin_item

echo "copying NFMciitem.c"
cp ../nfmu/NFMciitem.c .
sed "
s/NFMfs/NFMpcfs/g
s/NFMrm_co_files/NFMpcrm_co_files/g
s/NFMcheckin_item/NFMpccheckin_item/g
s/NFMbuild_microstation_set/NFMpcbuild_microstation_set/g
/NFMdisconnect/d
s/long _NFMclean_fcat_records/long _NFMpcdiscard/g" NFMciitem.c > NFMpcciitem.c
touch_date ../nfmu/NFMciitem.c NFMpcciitem.c

rm NFMciitem.c
echo "NFMpcciitem.c done"
echo ""

# NFMcoitem.c -> NFMcheckout_item
echo "copying NFMcoitem.c"
cp ../nfmu/NFMcoitem.c .
sed -e s/NFMfs/NFMpcfs/g -e s/NFMcheckout_item/NFMpccheckout_item/g -e s/NFMrm_co_files/NFMpcrm_co_files/g -e /NFMdisconnect/d  NFMcoitem.c > NFMpccoitem.c
touch_date ../nfmu/NFMcoitem.c NFMpccoitem.c
rm NFMcoitem.c
echo "NFMpccoitem.c done"
echo ""

# NFMcancoitem.c -> NFMcancel_check_out_item
echo "copying NFMcancoitem.c"
cp ../nfmu/NFMcancoitem.c .
sed -e s/NFMfs/NFMpcfs/g -e s/NFMcancel_check_out_item/NFMpccancel_check_out_item/g -e s/NFMrm_co_files/NFMpcrm_co_files/g -e /NFMdisconnect/d NFMcancoitem.c > NFMpccanco_i.c
touch_date ../nfmu/NFMcancoitem.c NFMpccanco_i.c
rm NFMcancoitem.c
echo "NFMpccanco_i.c done"
echo ""

# NFMciset.c -> NFMcheckin_set
echo "copying NFMciset.c"
cp ../nfmu/NFMciset.c .
sed -e s/NFMfs/NFMpcfs/g -e s/NFMrm_co_files/NFMpcrm_co_files/g -e s/NFMcheckin_set/NFMpccheckin_set/g -e s/NFMupdate_microstation_file/NFMpcupdate_microstation_file/g -e /NFMdisconnect/d NFMciset.c> NFMpcciset.c
touch_date ../nfmu/NFMciset.c NFMpcciset.c
rm NFMciset.c
echo "NFMpcciset.c done"
echo ""

# NFMcoset.c -> NFMcheckout_set
echo "copying NFMcoset.c"
cp ../nfmu/NFMcoset.c .
sed -e s/NFMfs/NFMpcfs/g -e s/NFMcheckout_set/NFMpccheckout_set/g -e s/NFMrm_co_files/NFMpcrm_co_files/g  -e /NFMdisconnect/d NFMcoset.c > NFMpccoset.c
touch_date ../nfmu/NFMcoset.c NFMpccoset.c
rm NFMcoset.c
echo "NFMpccoset.c done"
echo ""

# NFMcancoset.c -> NFMcancel_check_out_set
echo "copying NFMcancoset.c"
cp ../nfmu/NFMcancoset.c .
sed -e s/NFMfs/NFMpcfs/g -e s/NFMcancel_check_out_set/NFMpccancel_check_out_set/g -e s/NFMrm_co_files/NFMpcrm_co_files/g -e /NFMdisconnect/d NFMcancoset.c > NFMpccanco_s.c
touch_date ../nfmu/NFMcancoset.c NFMpccanco_s.c
rm NFMcancoset.c
echo "NFMpccanco_s.c done"
echo ""

# NFMcpitmfile.c
echo "copying NFMcpitmfile.c"
cp ../nfmu/NFMcpitmfile.c .
sed -e s/NFMfs/NFMpcfs/g -e \
s/NFMcopy_item_files/NFMpccopy_item_files/g -e \
s/NFMrm_co_files/NFMpcrm_co_files/g -e \
/NFMdisconnect/d NFMcpitmfile.c > NFMpccpitmf.c
touch_date ../nfmu/NFMcpitmfile.c NFMpccpitmf.c
rm NFMcpitmfile.c
echo "NFMpccpitmf.c done"
echo ""

# NFMcpsetfile.c -> NFMcopy_set_files 
echo "copying NFMcpsetfile.c"
cp ../nfmu/NFMcpsetfile.c .
sed -e s/NFMfs/NFMpcfs/g -e \
s/NFMcopy_set_files/NFMpccopy_set_files/g  -e \
s/NFMrm_co_files/NFMpcrm_co_files/g -e \
/NFMdisconnect/d NFMcpsetfile.c> NFMpccpsetf.c
touch_date ../nfmu/NFMcpsetfile.c NFMpccpsetf.c
rm NFMcpsetfile.c
echo "NFMcpsetf.c done"
echo ""

# NFMms.c -> NFMupdate_microstation_file NFMbuild_microstation_set
echo "copying NFMms.c"
cp ../cmdtools/NFMms.c .
sed -e s/NFMfs/NFMpcfs/g -e \
s/NFMupdate_microstation_file/NFMpcupdate_microstation_file/g -e \
s/NFMbuild_microstation_set/NFMpcbuild_microstation_set/g -e \
s/_NFMdelete_file_LFM/_NFMpcdelete_file_LFM/g NFMms.c > NFMpcms.c
touch_date ../cmdtools/NFMms.c NFMpcms.c
rm NFMms.c
echo "NFMpcms.c done\n"



