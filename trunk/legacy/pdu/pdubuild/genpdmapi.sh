echo "linking PDMapilib.a"

ar -ruv ${PDM}/lib/${TARG}/PDMapilib.a \
	${PDM}/lib/${TARG}/PDMcicocp.a \
	${PDM}/lib/${TARG}/PDMfmgr.a \
	${PDM}/lib/${TARG}/PDMpdms.a \
	${PDM}/lib/${TARG}/PDMbom.a \
	${PDM}/lib/${TARG}/PDMris.a \
	${PDM}/lib/${TARG}/PDMpdmp.a \
	${PDM}/lib/${TARG}/PDMreports.a \
	${PDM}/lib/${TARG}/PDMmulfile.a \
	${PDM}/lib/${TARG}/PDMtools.a \
	${PDM}/lib/${TARG}/PDMmacros.a \
	${PDM}/lib/${TARG}/PDMass.a
		
echo "API archive library created successfully."
