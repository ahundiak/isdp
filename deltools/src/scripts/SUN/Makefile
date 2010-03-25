RFILES = Ingrinit runcd inqlgexist
RDIR   = ../../prod.sun

all: ../Ingrinit ../runcd ../inqlgexist

release: ../Ingrinit ../runcd ../inqlgexist
	(cd .. ; find $(RFILES) -print | cpio -pvmd $(RDIR))
	touch release

clean:
