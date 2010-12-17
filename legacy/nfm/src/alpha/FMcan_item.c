#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "DEBUG.h"
#include "WFcommands.h"

extern   struct NFMwf_info   NFAwf_info;
extern   struct NFMoperation NFAoperation;

long cancel_checkout_item ()

{

long   status;
long   catalog_no = -1;
int    confirm;
static char *fname = "NFAcancel_check_out_item";

    SCdisplay_msg ("Working..");    

    NFAconfirm( "cancel check out for this item", &confirm );
    if( confirm == 0 )
        return( NFI_S_SUCCESS );

    SCdisplay_msg ("Working..");

    NFAset_global_config_info( NFM_WORKFLOW, CANCEL_ITEM_CHECKOUT,
	   		       NFMworkflow, "", "NFM" );

    status = NFMRcancel_check_out_item( NFMcatalog, catalog_no, NFMitem,
		NFMrev, NFAwf_info, NFAoperation );

    _NFIdebug(( fname, "Return from NFMRcancel_check_out_item -> 0x%.8x\n", 
		    status));
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



