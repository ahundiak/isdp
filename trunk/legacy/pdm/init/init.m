SOURCE
PDMi_dbg.c
PDMi_file.c
PDMi_main.c
PDMi_rtns.c
PDMi_table.c
PDMi_tmplt.c
PDMcp_env.c
PDMdebug.c

INCLUDE
$PDM/include
$PDM/pdmapi/include
$PDU/include
$NFM/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMinit.a
ARCHIVE
