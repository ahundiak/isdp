all: \
	directories \
	BTREE \
	DIR \
	GROUP

directories:
	@if test ! -d ./lib; then mkdir ./lib; fi

BTREE: $(TARGET)/om/IGRdir/btree/makefile
	@cd $(TARGET)/om/IGRdir/btree; \
	pwd; \
	$(MAKE)

$(TARGET)/om/IGRdir/btree/makefile: $(EXNUC)/om/IGRdir/btree/btree.m
	cd $(EXNUC)/om/IGRdir/btree; \
	$(MAKEMAKE) btree.m $(TARGET)/om/IGRdir/btree/makefile

DIR: $(TARGET)/om/IGRdir/dir/makefile
	@cd $(TARGET)/om/IGRdir/dir; \
	pwd; \
	$(MAKE)

$(TARGET)/om/IGRdir/dir/makefile: $(EXNUC)/om/IGRdir/dir/dir.m
	cd $(EXNUC)/om/IGRdir/dir; \
	$(MAKEMAKE) dir.m $(TARGET)/om/IGRdir/dir/makefile

GROUP: $(TARGET)/om/IGRdir/group/makefile
	@cd $(TARGET)/om/IGRdir/group; \
	pwd; \
	$(MAKE)

$(TARGET)/om/IGRdir/group/makefile: $(EXNUC)/om/IGRdir/group/group.m
	cd $(EXNUC)/om/IGRdir/group; \
	$(MAKEMAKE) group.m $(TARGET)/om/IGRdir/group/makefile
