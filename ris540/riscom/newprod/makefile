SHELL=/bin/ksh

prods:
	@mk_test
	@$(MAKE) $(TARGET)

#----------------------------------------------------------------------

c100 c400:
	@mk_test
	@$(MAKE) dp cli utl infds infns orads orans ingds ingns db2 os400

sco:
	@mk_test
	@$(MAKE) dp cli infds orads ingds sybds db2

sun:
	@mk_test
	@$(MAKE) dp cli utl infds infns orads orans

Sol2:
	@mk_test
	@$(MAKE) dp cli utl orads orans sybds

Soli:
	@mk_test
	@$(MAKE) dp cli utl infds infns 

hpux:
	@mk_test
	@$(MAKE) dp cli utl orads orans

#----------------------------------------------------------------------

dp risdp:
	@mk_test
	@make.prd $(TARGET) risdp

cli riscli:
	@mk_test
	@make.prd $(TARGET) riscli

utl risutl:
	@mk_test
	@make.prd $(TARGET) risutl

#----------------------------------------------------------------------

infds risinfds:
	@mk_test
	@make.prd $(TARGET) risinfds

infns risinfns:
	@mk_test
	@make.prd $(TARGET) risinfns

orads risorads:
	@mk_test
	@make.prd $(TARGET) risorads

orans risorans:
	@mk_test
	@make.prd $(TARGET) risorans

ingds risingds:
	@mk_test
	@make.prd $(TARGET) risingds

ingns risingns:
	@mk_test
	@make.prd $(TARGET) risingns

sybds rissybds:
	@mk_test
	@make.prd $(TARGET) rissybds

#----------------------------------------------------------------------

db2 risdb2ds:
	@mk_test
	@case $(TARGET) in \
		"c100"|"c400"|"sco") make.prd $(TARGET) risdb2ds ;; \
	esac ;

os400 risos4ds:
	@mk_test
	@case $(TARGET) in \
		"c100"|"c400") make.prd $(TARGET) risos4ds ;; \
	esac ;

#----------------------------------------------------------------------
