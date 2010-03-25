RFILES = Ingrinit runcd inqlgexist
RDIR   = ../../prod.solaris

all: ../Ingrinit ../runcd ../inqlgexist

release: ../Ingrinit ../runcd ../inqlgexist
	(cd .. ; find $(RFILES) -print | cpio -puvmd $(RDIR))
	touch release

clean:
