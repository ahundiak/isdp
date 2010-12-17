echo "linking PDUapilib.a"
echo

ar -ruv ${PDM}/lib/${TARG}/PDUapilib.a \
	${PDU}/lib/${TARG}/NFMRtic.o \
	${PDU}/init/PDUstorage.o \
	${PDU}/init/PDUuser.o \
	${PDU}/init/PDUpdm_exec.o \
	${PDU}/init/PDUrefresh.o \
	${PDU}/pdmr/PDMrexec.o \
	${PDU}/tools/PDUform.o \
	${PDU}/design/PDUdebug.o \
	${PDU}/design/PDUrefresh.o \
	${PDU}/design/PDUdsgnapi.o \
	${PDU}/filemgr/PDUfileapi.o \
	${PDU}/pdmr/PDMrapi.o \
	${PDU}/filemgr/PDUgen_valid.o \
	${PDU}/pdmr/PDMrtools.o \
	${PDU}/catalogs/PDUvalidate.o \
	${PDU}/catalogs/PDUbuff.o \
	${PDU}/catalogs/PDUdyn_attr.o \
	${PDU}/catalogs/PDUcatapi.o \
	${PDU}/design/PDUmessage.o \
	${PDU}/parts/PDUpartsapi.o \
	${PDU}/pdmr/PDMrwf.o \
	${PDU}/misc/PDUmiscapi.o \
	${PDU}/filemgr/PDUsv_refrsh.o \
	${PDU}/tools/PDUbfr_tools.o \
	${PDU}/tools/PDUupdat_buf.o \
	${PDU}/tools/PDUtoolsapi.o \
	${PDU}/filemgr/PDUwrkst_mgr.o \
	${PDU}/pdmr/PDMrdebug.o \
	${PDU}/pdmr/PDMrpart.o \
	${PDU}/design/PDUvalid.o \
	${PDU}/pdmr/PDMrfmgr.o \
	${PDU}/pdmr/PDMrassy.o \
	${PDU}/pdmr/PDMrpart_p.o \
	${PDU}/assembly/PDUassyapi.o \
	${PDU}/reports/PSUcom_tls.o \
	${PDU}/pal/src/pdmr/CID.o \
	${PDU}/pal/src/funk/PALtools.o \
	${PDU}/pal/src/pdmr/PDMgetstat.o \
	${PDU}/pal/src/pdmr/PDMsrcatr.o \
	${PDU}/pal/src/pdmr/conditiony.o \
	${PDU}/pal/src/pdmr/conditionl.o \
	${PDU}/pal/src/pdmr/svs/viewy.o \
	${PDU}/pal/src/pdmr/svs/viewl.o \
	${PDU}/pal/src/pdmr/svs/condy.o \
	${PDU}/pal/src/pdmr/svs/condl.o \
	${PDU}/pal/src/pdmr/svs/svs.o \
	${PDU}/kernal/PDMglobals.o \
	${PDU}/kernal/PDUglobals.o

echo "API archive library created successfully."
