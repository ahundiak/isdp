. $PDU/design/cob/startup

echo "removing old command files"
$EXNUC/bin/slic -VC -t COpdu.sl
$EXNUC/bin/slic -VC -si locate_org.sl
$EXNUC/bin/slic -VC -si locate_cs.sl
$EXNUC/bin/slic -VC -si cregra.sl
$EXNUC/bin/slic -VC -si files.sl
$EXNUC/bin/slic -VC -si internal.sl
$EXNUC/bin/slic -VC -si checkin.sl
$EXNUC/bin/slic -VC -si checkout.sl
$EXNUC/bin/slic -VC -si canclchkout.sl
$EXNUC/bin/slic -VC -si enter_view.sl
$EXNUC/bin/slic -VC -si input_point.sl
$EXNUC/bin/slic -VC -si locate_part.sl
$EXNUC/bin/slic -VC -si login.sl
$EXNUC/bin/slic -VC -si external.sl

mv ../../config/command_table ../../config/tables
cp COpdu.S ..
cp COpdu.S ../../spec
mv COpdui.I ..
rm TFI*

$EXNUC/bin/slic -VC -si input_point.sl
$EXNUC/bin/slic -VC -si canclchkout.sl
$EXNUC/bin/slic -VC -si login.sl
$EXNUC/bin/slic -VC -si internal.sl
$EXNUC/bin/slic -VC -si external.sl
rm COpdu.S

cd ../../spec
rm *.o
rm makefile
#rm $PDU/lib/PDUspec.a
echo ""
if [ "$TARG" = "Sol2" ]
then
$GRNUC/bin/grmakemake -i $PDU/include/sol2_igno -D __Sol2__ spec.m
elif [ "$TARG" = "isl" ]
then
$GRNUC/bin/grmakemake -i $PDU/include/isl_igno -D __Sol2__ spec.m
else
#grmakemake is used due to constraints from GRNUC
echo "PDU - GRMAKEMAKE on CLIPPER for SPEC (Reactive is not applicable)"
#grmakemake is used due to conditions within 2.4 GRNUCDP
$GRNUC/bin/grmakemake -i $PDU/include/clip_igno spec.m
fi

if [ ! -f $PDU/spec/makefile ]
then
   echo WARNING...WARNING
   echo
   echo There is not a makefile in the $PDU/spec directory
   echo
   exit 1
fi
echo "Run make in $PDU/spec"
echo
#grmake is used due to conditions within 2.4 GRNUCDP
$GRNUC/bin/grmake

cd -
