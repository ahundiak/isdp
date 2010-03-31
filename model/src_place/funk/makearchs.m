whlibname = ${model_src_lib}/${libname}.a

${libname} : ${objects} ${whlibname}

${whlibname} : ${objects}
	@echo
	@ld -VS ${version} -o $*.v > /dev/null
	@echo ar
	@ar rsuv $@ $*.v ${objects}
	@${TOUCHN} $@ $?
	@ls -ls $@
	@echo
