target: SFCoConvPl.S SFCoConvBm.S SFCoStfndPl.S SFCoDefOpt.S SFCoSfCv.S mkfile
	grmake -r -k -f mkfile

SFCoConvPl.S : SFCoConvPl.sl \
	${STRFEM}/include/SFmsg.h ${STRFEM}/include/SFcmd.h
	$(EXNUC)/bin/slic -C -p${STRFEM}/spec SFCoConvPl.sl

SFCoConvBm.S : SFCoConvBm.sl \
	${STRFEM}/include/SFmsg.h ${STRFEM}/include/SFcmd.h
	$(EXNUC)/bin/slic -C -p${STRFEM}/spec SFCoConvBm.sl

SFCoStfndPl.S : SFCoStfndPl.sl \
	${STRFEM}/include/SFmsg.h ${STRFEM}/include/SFcmd.h
	$(EXNUC)/bin/slic -C -p${STRFEM}/spec SFCoStfndPl.sl

SFCoDefOpt.S : SFCoDefOpt.sl \
	${STRFEM}/include/SFmsg.h ${STRFEM}/include/SFcmd.h
	$(EXNUC)/bin/slic -C -p${STRFEM}/spec SFCoDefOpt.sl

SFCoSfCv.S : SFCoSfCv.sl \
	${STRFEM}/include/SFmsg.h ${STRFEM}/include/SFcmd.h
	$(EXNUC)/bin/slic -C -p${STRFEM}/spec SFCoSfCv.sl

mkfile : strfem.m
	grmakemake strfem.m mkfile
