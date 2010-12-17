#include <PDUextdef.h>
#include <MEMstruct.h>

int PDMassy_members=0;
struct child_info *PDMchildren_list = NULL;
struct child_info *PDMlast_child = NULL;
struct set_info1 *PDMassy_mem_list = NULL;
struct sto_info *PDMsto_list = NULL;
MEMptr catno_type = NULL;
int PDU_IS_LOGGED_IN = 0;
int              PDMdebug_on = 0;
int              PDM_debug_on = 0;
char             PDM_DEBUG_FILE[80] = "/usr/tmp/pdm.dbg";
char             PDU_DEBUG_FILE[80] = "/usr/tmp/pdu.dbg";
int  PDMtime_enabled=0;
char PDMtimestamp_buffer[4096]="";
char PDMtimestamp_file[256] = "";
int  PDMtime_value = 0;


