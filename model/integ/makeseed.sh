cd $EMS/config
rm seed_file
mv seed_file.eng seed_file.eng~
mv seed_file.met seed_file.met~
mv seed_dtl.eng seed_dtl.eng~
mv seed_dtl.met seed_dtl.met~
cd $EMS
cp $MODEL/ppl/cisrc/MakeSeedEng.u /tmp
echo "To create the english seed_file :"
echo "1. remove Window"
echo "2. ci=/tmp/MakeSeedEng.u"
echo "3. turn off grid"
echo "4. set color to green"
echo "5. set linear readout accuracy to 6"
echo "6. exit and save"
ems -cf $EMS/config/seed_file.eng 
cp $EMS/config/seed_file.eng $EMS/config/seed_file
cp $MODEL/ppl/cisrc/MakeSeedDtl.u /tmp
echo "To create the english detailing seed_file :"
echo "1. delete all view windows (i.e. right, top, iso and front)"
echo "2. ci=/tmp/MakeSeedDtl.u"
echo "3. make the reference plane that is planar to the top view active"
echo "4. turn off reference plane display"
echo "5. exit and save"
ems -cf $EMS/config/seed_dtl.eng 
rm $EMS/config/seed_file
cp $GRNUC/config/uom_table.met $GRNUC/config/uom_table
cp $MODEL/ppl/cisrc/MakeSeedMet.u /tmp
echo "\n\n\n\n"
echo "To create the metric seed_file :"
echo "1. remove Window"
echo "2. ci=/tmp/MakeSeedMet.u"
echo "3. turn off grid"
echo "4. set color to green"
echo "5. set linear readout accuracy to 6"
echo "6. exit and save"
ems -cf  $EMS/config/seed_file.met 
cp $EMS/config/seed_file.met $EMS/config/seed_file
echo "To create the metric detailing seed_file :"
echo "1. delete all view windows (i.e. right, top, iso and front)"
echo "2. ci=/tmp/MakeSeedDtl.u"
echo "3. make the reference plane that is planar to the top view active"
echo "4. turn off reference plane display"
echo "5. exit and save"
ems -cf $EMS/config/seed_dtl.met 
cp $GRNUC/config/uom_table.eng $GRNUC/config/uom_table
cp $EMS/config/seed_file.eng $EMS/config/seed_file
echo "\n\n\n\nDo you want to remove old seed_file.eng~, seed_file.met~,
seed_dtl.eng~ and seed_dtl.met~ [y]\b\b\c"
read ANS; : ${ANS:=y}
if [ ${ANS} = y ]
then
 rm $EMS/config/seed_file.eng~ $EMS/config/seed_file.met~ $EMS/config/seed_dtl.eng~ $EMS/config/seed_dtl.met~
fi
rm /tmp/MakeSeed*.[ue]
