SRC
$(EXNUC)/dict

NOSUFFIXES

DEFINE
CCDEF

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/include
$(EXNUC)/spec
$(EXNUC)/om/spec
$(X11_INC_PATH)
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif


SPECIAL

DDPOPT = $(DOPT1)

DDP = $(BASE)/bin/ddp
CCD = $(BASE)/bin/ccd
CTD = $(BASE)/bin/ctd

include $(TARGET)/dict/speclist

template_d=$(TARGET)/dict/OMrtree_temp.d $(TARGET)/dict/IGEcolor2_te.d 

$(TARGET)/config/class_defns: $(class_d) $(template_d)
	cat $(class_d) $(template_d) > $(TARGET)/config/class_defns
	rm -f v.* *.

$(class_d):
	@if [ "$(WHY)" ]; then echo "\t$@: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$? -> $(@F:.d=)."; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(DDP) $(DDPOPT) $(IPATH) $?"; fi; \
	 $(DDP) $(DDPOPT) $(IPATH) $?; \
	 if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=). -> $(@F:.d=).c"; \
         else \
             echo "\t$(CCD) $(@F:.d=) > $(@F:.d=).c"; \
         fi; \
	 $(CCD) $(@F:.d=) > $(@F:.d=).c; \
	 if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$(@F:.d=.c) -> $(@F:.d=)"; \
	 else \
	     echo "\t$(CCDEF) $(EXECOPT) -o $(@F:.d=) $(@F:.d=.c)"; \
	 fi; \
	 $(CCDEF) $(EXECOPT) -o $(@F:.d=) $(@F:.d=.c); \
         if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=) -> $(@F)"; \
         else \
             echo "\t./$(@F:.d=)"; \
         fi; \
         ./$(@F:.d=); \
	 if [ "$(COPT)" != "-g" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\tremoving $(@F:.d=.c) $(@F:.d=)"; \
	     else \
	         echo "\trm $(@F:.d=.c) $(@F:.d=)"; \
	     fi; \
	     rm $(@F:.d=.c) $(@F:.d=); \
	 else \
	     if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@F:.d=.c) $(@F:.d=)"; fi; \
	 fi
	 @echo

$(template_d):
	@if [ "$(WHY)" ]; then echo "\t$@: $?"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$? -> $(@F:.d=).S"; \
         else \
             echo "\tif test \"$(?D)\" != \"$(TARGET)/dict\"; then cp $? $(TARGET)/dict; fi"; \
             echo "\t$(CTD) $(@F:.d=)"; \
         fi; \
         if test "$(?D)" != "$(TARGET)/dict"; then cp $? $(TARGET)/dict; fi; \
	 $(CTD) $(@F:.d=); \
         if test -n "$(VERBOSE_RULES)"; \
         then \
             echo "\tif test \"$(?D)\" != \"$(TARGET)/dict\"; then rm $(TARGET)/dict/$(?F); fi"; \
         fi; \
         if test "$(?D)" != "$(TARGET)/dict"; then rm $(TARGET)/dict/$(?F); fi; \
	 if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=).S -> $(@F:.d=)."; \
         else \
	     echo "\t$(DDP) $(DDPOPT) $(IPATH) $(@F:.d=).S"; \
         fi; \
	 $(DDP) $(DDPOPT) $(IPATH) $(@F:.d=).S; \
	 if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=). -> $(@F:.d=).c"; \
         else \
             echo "\t$(CCD) $(@F:.d=) > $(@F:.d=).c"; \
         fi; \
	 $(CCD) $(@F:.d=) > $(@F:.d=).c; \
	 if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$(@F:.d=.c) -> $(@F:.d=)"; \
	 else \
	     echo "\t$(CCDEF) $(EXECOPT) -o $(@F:.d=) $(@F:.d=.c)"; \
	 fi; \
	 $(CCDEF) $(EXECOPT) -o $(@F:.d=) $(@F:.d=.c); \
         if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=) -> $(@F)"; \
         else \
             echo "\t./$(@F:.d=)"; \
         fi; \
         ./$(@F:.d=); \
	 if [ "$(COPT)" != "-g" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\tremoving $(@F:.d=.c) $(@F:.d=) $(@F:.d=).S"; \
	     else \
	         echo "\trm $(@F:.d=.c) $(@F:.d=) $(@F:.d=).S"; \
	     fi; \
	     rm $(@F:.d=.c) $(@F:.d=) $(@F:.d=).S; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@F:.d=.c) $(@F:.d=) $(@F:.d=).S"; fi; \
	 fi
	 @echo

include $(TARGET)/dict/specdep

$(TARGET)/dict/OMrtree_temp.d: $(EXNUC)/dict/OMrtree_temp.T
$(TARGET)/dict/IGEcolor2_te.d: $(EXNUC)/dict/IGEcolor2_te.T

END_SPECIAL
