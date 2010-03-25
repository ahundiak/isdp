RFILES = Ingrinit getmenus inqlgexist runcd
RDIR   = ../../prod.sco

all: ../Ingrinit ../getmenus ../inqlgexist ../runcd

release: ../Ingrinit ../getmenus ../inqlgexist ../runcd
	(cd ..; find $(RFILES) -print | cpio -pvmd $(RDIR))
	touch release

clean:
