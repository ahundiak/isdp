/* Command definition section */
options			"t"
product_name		"$GRNUC"
class			COceocmds
super_class		CEO
start_state       	terminate


/* OPP section */
/* Specification section .. code for .S file */

specification

instance 
{
}


/* implementation section - code for .I file */

implementation


#include "dpfile.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "lcdef.h"
#include "grio.h"
#include "lc.h"

%safe

#if defined(__STDC__) || defined(__cplusplus)
/* definition needed for LCpost.h prototypes */

struct LC_sd_node
{
    IGRint use_node;
    struct LC_sd_criteria *data;
    struct LC_sd_node *next;
    struct LC_sd_node *prev;
};
#endif

/* include these files when a naming convention for protypes is in place */

#include "dpexbell.h"
#include "LCpost.h"

%endsafe

/* External variable declaration for dynamics */

extern struct
 { 
     IGRboolean dyn_on;
     IGRboolean mod_flag;
 } dyn_params;


from IGEgragad import DPdelayonoff, DPinquire;

action bell_onoff
{

  int	set0_inq1;
  int   bell_value;

	set0_inq1 = 1;
	DPsetinq_bell(set0_inq1,&bell_value);
	if (!bell_value)
	{
	    bell_value = TRUE;
	    set0_inq1 = 0;
	    DPsetinq_bell(set0_inq1,&bell_value);
	    ex$message ( msgnumb = GR_I_BellOn);
	}
	else
	{
	    bell_value = FALSE;
	    set0_inq1 = 0;
	    DPsetinq_bell(set0_inq1,&bell_value);
	    ex$message ( msgnumb = GR_I_BellOff);
	}

	*sts = OM_S_SUCCESS;

}		/* end action */

/*
Name
        action2

Description
        This action is invoked through the session startup command GRMDrftSst.
*/

action action2
{
    // Create a stop process to display the stop sign
    GRcreate_stopsign();

    // initialize some locate code
    LCpost_function();

    // kill the command
    *me->response = TERMINATE;
}


action action1
{


    struct  GRid           modid;    /* current module's objid and osnum  */
    struct  GRid           colid;    /* color's objid and osnum  */
    struct  GRid	   lvlid;    /* DPlvldir objid and osnum  */
    struct  GRid	   fontid;   /* font manager objid and osnum  */
    struct  GRid	   gradpid;  /* GRadp objid and osnum  */


    /*
     *  construct the super IGEcolor if it doesn't exist
     */

    ex$get_cur_mod(id = &modid.objid,
                   osnum = &modid.osnum);


    status = ex$get_super(mod_id = modid.objid,
                          mod_osnum = modid.osnum,
                          super_name = "IGECOLOR2",
                          create = TRUE,
                          super_class = "IGEcolor2",
                          super_id = &colid.objid,
                          super_osnum = &colid.osnum);

    status = ex$get_super(mod_id = modid.objid,
                          mod_osnum = modid.osnum,
                          super_name = "DPLVLDIR",
                          create = TRUE,
                          super_class = "DPlvldir",
                          super_id = &lvlid.objid,
                          super_osnum = &lvlid.osnum);


    status = ex$get_super(mod_id = modid.objid,
                          mod_osnum = modid.osnum,
                          super_name = "GRFONTMGR",
                          create = TRUE,
                          super_class = "GRfm",
                          super_id = &fontid.objid,
                          super_osnum = &fontid.osnum);

    if( !ex$is_batch() )
    {
        status = ex$get_super(mod_id = modid.objid,
                          mod_osnum = modid.osnum,
                          super_name = "GRADP",
                          create = TRUE,
                          super_class = "GRadp",
                          super_id = &gradpid.objid,
                          super_osnum = &gradpid.osnum);
    }


    return ( OM_S_SUCCESS );
}		/* end action1 */
