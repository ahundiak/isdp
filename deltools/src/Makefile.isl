PLAT	= isl
WSDIR	= ../FINAL/${PLAT}
TEMPLE	= `whence temple`

CC	= cc
CP	= cp

DIRS	= catalog cdprof dates free getanswer nabdr newprod node \
	  remove rm_pg scripts


release: clobber depend all strip package

depend:
	@for i in ${DIRS}; do \
		(echo "$$i:"; \
		 cd $$i/INTEL_SOLARIS; \
		 ${MAKE} $@ CC=${CC}); \
	done

all:
	@for i in ${DIRS}; do \
		(echo "$$i:"; \
		 cd $$i/INTEL_SOLARIS; \
		 ${MAKE} $@ CC=${CC}); \
	done

strip:
	@for i in ${DIRS}; do \
		(echo "$$i:"; \
		 cd $$i/INTEL_SOLARIS; \
		 ${MAKE} $@ CC=${CC}); \
	done;

clean:
	@for i in ${DIRS}; do \
		(echo "$$i:"; \
		 cd $$i/INTEL_SOLARIS; \
		 ${MAKE} $@ CC=${CC}); \
	done;

clear:
	@for i in ${DIRS}; do \
		(echo "$$i:"; \
		 cd $$i/INTEL_SOLARIS; \
		 ${MAKE} $@ CC=${CC}); \
	done;

clobber: clean clear


package:
	@if [ ! -d ${WSDIR} ]; \
	then \
		mkdir -p ${WSDIR}; \
	fi
	@awk '{print $$1}' ../deliv/dtdata.${PLAT} > ../dtfiles.${PLAT}
	@perl ${TEMPLE} -t ../prod ../deliv/dtdata.${PLAT}
	@cd ../prod;
		cat ../dtfiles.${PLAT} | cpio -ocv | compress -fv > ${WSDIR}/deltools.${PLAT}
	@rm -f ../dtfiles.${PLAT}
	@if [ ! ../deliv/README -ef ${WSDIR}/README ]; \
	then \
		rm -f ${WSDIR}/README; \
		${CP} ../deliv/README ${WSDIR}; \
	fi
	@if [ ! ../deliv/p.def.${PLAT} -ef ${WSDIR}/product.def ]; \
	then \
		rm -f ${WSDIR}/product.def; \
		${CP} ../deliv/p.def.${PLAT} ${WSDIR}; \
	fi
	@if [ ! ../deliv/install.${PLAT} -ef ${WSDIR}/install.${PLAT} ]; \
	then \
		rm -f ${WSDIR}/install.${PLAT}; \
		${CP} ../deliv/install.${PLAT} ${WSDIR}; \
	fi
	@if [ ! ../deliv/remove.${PLAT} -ef ${WSDIR}/remove.${PLAT} ]; \
	then \
		rm -f ${WSDIR}/remove.${PLAT}; \
		${CP} ../deliv/remove.${PLAT} ${WSDIR}; \
	fi
	@if [ ! ../deliv/newprod.${PLAT} -ef ${WSDIR}/newprod.${PLAT} ]; \
	then \
		rm -f ${WSDIR}/newprod.${PLAT}; \
		${CP} ../deliv/newprod.${PLAT} ${WSDIR}; \
	fi
