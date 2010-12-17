#ar -x ${INGRHOME}/lib/libUMS.a UMSgbkey.o UMSkeyby.o UMSmsgco.o
#mv UMS*.o ${PDU}/lib/${TARG}
#ar -x ${DBA}/lib/script.a SOL_fcall.o
#
echo "${EXNUC}/bin/opl -d Pdu -o OMprodinit.C ${PDU}/lib/${TARG}/PDUspec.a"
${EXNUC}/bin/opl -d Pdu -o OMprodinit.C ${PDU}/lib/${TARG}/PDUspec.a
#vi OMprodinit.C
SED_FILE=${PDU}/ldpdu/sed_isl
TMP_OMPRODINIT_FILE=${PDU}/ldpdu/omprod.tmp
echo "sed -f ${SED_FILE} OMprodinit.C > ${TMP_OMPRODINIT_FILE}"
sed -f ${SED_FILE} OMprodinit.C > ${TMP_OMPRODINIT_FILE}
echo "mv ${TMP_OMPRODINIT_FILE} OMprodinit.C"
mv ${TMP_OMPRODINIT_FILE} OMprodinit.C
echo "${EXNUC}/bin/omcpp -I${EXNUC}/include OMprodinit.C > OMprodinit.c"
${EXNUC}/bin/omcpp -I${EXNUC}/include OMprodinit.C > OMprodinit.c
echo "cc -Xc -c -o OMprodinit.o -I$EXNUC/include OMprodinit.c"
cc -Xc -c -o OMprodinit.o -I$EXNUC/include OMprodinit.c
echo "mv OMprodinit.o ${PDU}/lib/${TARG}/OMprodinit.o"
mv OMprodinit.o ${PDU}/lib/${TARG}/OMprodinit.o
echo "${EXNUC}/bin/version.sh"
${EXNUC}/bin/version.sh

echo "cc -Xa -c -o PDUver.o -I${EXNUC}/include PDUver.c"
cc -Xa -c -o PDUver.o -I${EXNUC}/include PDUver.c
echo "mv PDUver.o ${PDU}/lib/${TARG}/PDUver.o"
mv PDUver.o ${PDU}/lib/${TARG}/PDUver.o

echo "cc -Xa -c -o PDUnfmstub.o PDUnfmstub.c"
cc -Xa -c -o PDUnfmstub.o PDUnfmstub.c
echo "mv PDUnfmstub.o ${PDU}/lib/${TARG}/PDUnfmstub.o"
mv PDUnfmstub.o ${PDU}/lib/${TARG}/PDUnfmstub.o

echo "cc ${COMPOPT} -c -o solstub.o solstub.c"
cc ${COMPOPT} -c -o solstub.o solstub.c
echo "cp solstub.o ${PDM}/lib/${TARG}"
cp solstub.o ${PDM}/lib/${TARG}
echo "mv solstub.o ${PDU}/lib/${TARG}"
mv solstub.o ${PDU}/lib/${TARG}

# The FORMS fixes were delivered in XFORMS 01.02.05.00 and EMS is linking with
#01.02.05.06, so you should not have to link mcf.so or fieldTrack.so for
#Solaris Intel.
# 10/11/95 - Fix is not showing up in current build.  MJG

echo "linking forms.so"
echo
ld -z text -G -o ${PDU}/config/dload/patch/forms.so \
${PDU}/lib/isl/fieldTrack.o  \
	${PDU}/lib/isl/mcf.o
 
#echo
#ls -lsat ${PDU}/config/dload/patch/forms.so
#echo

echo
echo "linking PDUimage.so"
echo 
#ld -z text -G -o ${PDU}/config/dload/init/PDUimage.so \
ld -z text -G -o ${PDU}/config/dload/init/PDUimage.so \
	${PDU}/spec/*.o \
	${PDU}/design/*.o \
	${PDU}/catalogs/*.o \
	${PDU}/parts/*.o \
	${PDU}/assembly/*.o \
	${PDU}/reports/*.o \
	${PDU}/tools/*.o \
	${PDU}/filemgr/*.o \
	${PDU}/init/*.o \
	${PDU}/misc/*.o \
	${PDU}/pdmr/*.o \
	${PDU}/macros/*.o \
	${PDU}/kernal/*.o \
	${NPAL}/src/funk/*.o \
	${NPAL}/src/pdmr/*.o \
	${NPAL}/src/pdmr/svs/*.o \
	${NPAL}/src/ris/*.o \
	${PDM}/ass/*.o \
	${PDM}/bom/*.o \
	${PDM}/cicocp/*.o \
	${PDM}/fmgr/*.o \
	${PDM}/mulfile/*.o \
	${PDM}/pdmp/*.o \
	${PDM}/pdms/*.o \
	${PDM}/reports/*.o \
	${PDM}/ris/*.o \
	${PDM}/tools/*.o \
	${PDM}/macros/*.o \
	${PDM}/tli/gethost.o \
        ${PDU}/lib/${TARG}/OMprodinit.o \
        ${PDU}/lib/${TARG}/PDUver.o \
        ${PDU}/lib/${TARG}/UMSgbkey.o \
        ${PDU}/lib/${TARG}/UMSkeyby.o \
        ${PDU}/lib/${TARG}/UMSmsgco.o \
        ${PDU}/lib/${TARG}/PDUnfmstub.o \
        ${PDU}/lib/${TARG}/solstub.o \
	${RIS}/lib/ris.a \
	${NFM}/lib/${TARG}/NFMRtic.o \
	${DBA}/lib/${TARG}/report.a \
	${DBA}/lib/${TARG}/script.a \
	${DBA}/lib/${TARG}/dbnuc.a \
	${DBA}/lib/${TARG}/dbforms.a \
	${DBA}/lib/${TARG}/gui.a \
	${DBA}/lib/${TARG}/nucleus.a \
	${NFM}/lib/${TARG}/libnfma.a \
        ${NFM}/lib/${TARG}/libnfmu.a \
        ${NFM}/lib/${TARG}/libnfmlists.a \
        ${NFM}/lib/${TARG}/libnfmsac.a \
        ${NFM}/lib/${TARG}/libcmdtools.a \
        ${NFM}/lib/${TARG}/libnfmwf.a \
        ${NFM}/lib/${TARG}/libdbtools.a \
        ${NFM}/lib/${TARG}/libnfmtools.a \
        ${NFM}/lib/${TARG}/libnfmsql.a \
        ${NFM}/lib/${TARG}/libfilexfer.a \
        ${NFM}/lib/${TARG}/libsystools.a \
        ${NFM}/lib/${TARG}/libnfmmem.a \
        ${NFM}/lib/${TARG}/libnfmnet.a \
        ${NFM}/lib/${TARG}/libtli.a \
        ${NFM}/lib/${TARG}/libnfmerr.a \
        ${NFM}/lib/${TARG}/libnfmalter.a


echo
echo
echo "PDU/PDM image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/*.so
echo
