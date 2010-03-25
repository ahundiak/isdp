RFILES = Ingrinit runcd inqlgexist
RDIR   = ../../prod.rs6

all: ../Ingrinit ../runcd ../inqlgexist

release: ../Ingrinit ../runcd ../inqlgexist
	(cd .. ; find $(RFILES) -print | cpio -pvmd $(RDIR))
	touch release

clean:
