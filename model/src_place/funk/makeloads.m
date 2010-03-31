whlibname = ${model_src_lib}/${libname}.o

${libname} : ${objects} ${whlibname}

${whlibname} : ${objects}
	@echo
	@echo ld
	@ld -r -VS ${version} -o $@ ${objects}
	@${TOUCHN} $@ $?
	@ls -ls $@
	@echo
