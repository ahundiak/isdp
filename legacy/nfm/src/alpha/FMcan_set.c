#include "machine.h"
#include "NFMerrordef.h"
#include "SCstruct.h"
#include "NFMRextern.h"
#include "DEBUG.h"
#include "WFcommands.h"

extern   struct NFMwf_info   NFAwf_info;

long cancel_checkout_set ()

{
long   status;
long   catalog_no = -1;
long   set_no = -1;
long   level  = 0;
int    confirm;
struct NFMoperation *operation;

static char *fname = "NFAcancel_check_out_set";

    NFAconfirm( "cancel checkout for this set", &confirm );
    if( confirm == 0 )
        return( NFI_S_SUCCESS );

    SCdisplay_msg ("Working..");

    operation = (struct NFMoperation *)calloc(2,(sizeof(struct NFMoperation)));

    operation->transfer = NFM_CONDITIONAL_TRANSFER;
    operation->delete   = NFM_CONDITIONAL_DELETE;
    operation->purge    = NFM_PURGE;
    strncpy( operation->catalog, NFMcatalog, NFM_CATALOGNAME );
    operation->catalog_no = -1;
    strncpy( operation->item_name, NFMset, NFM_ITEMNAME );
    strncpy( operation->item_rev, NFMset_rev, NFM_ITEMREV );

    NFAset_global_config_info( NFM_WORKFLOW, CANCEL_SET_CHECKOUT,
                               NFMworkflow, "", "NFM" );

    status = NFMRcancel_check_out_set( NFMcatalog, catalog_no, NFMset,
		NFMset_rev, set_no, NFAwf_info, NFM_SAME_OPERATION, 
		operation, level );

    _NFIdebug(( fname, "Return from NFMRcheckout_set -> 0x%.8x\n", 
		    status));

/**
   Display multiple status'
*/
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


