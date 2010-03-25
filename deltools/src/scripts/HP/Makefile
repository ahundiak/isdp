RFILES = Ingrinit runcd inqlgexist
RDIR   = ../../prod.hp

all: ../Ingrinit ../runcd ../inqlgexist

release: ../Ingrinit ../runcd ../inqlgexist
	(cd .. ; find $(RFILES) -print | cpio -pvmd $(RDIR))
	touch release

clean:
