command_string GRC_M_UpdPtsLst,CO_update_parts_list,GRUpPrLs
class          COpart
product_name   "$SOURCE"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$GRNUC/co/spec"
path           "."
start_state    START
options	       "siT"
 
state_table

#include <grmessage.h>
#include <lcdef.h>
#include <FI.h>
#include <toolco.h>
#include "partco.h"

state START

    execute true (sts, CO_IS_PARTS_LIST)
    
    on RETURN_CODE = TRUE
        state UPDATE_LIST
        
    on RETURN_CODE = FALSE
        do status_key  GR_I_NoPtLstDef
        state terminate
        
    on ELSE
        do status_key GR_E_ErrEncCmdTrm
        state terminate
        
state UPDATE_LIST    
    
    execute update_partslist (sts)

    on RETURN_CODE = MSSUCC
        do status_key  GR_I_PtsLstUpd
        state terminate

    on ELSE
        do status_key GR_E_ErrEncCmdTrm
        state terminate
