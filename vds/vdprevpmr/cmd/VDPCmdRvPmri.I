/* $Id */

/* ----------------------------------------------------------------------------
 * I/VDS
 * 
 * File :	vds/vdprevpmr/cmd/VDPCmdRvPmri.I
 *
 * Description:
 *	Implementation of the following methods.
 *		my_init
 *		form_notification
 *		get_window
 *
 * Dependencies:
 *
 * History:
 *
 *	12/10/95	MSM		Creation
 *	09/17/96	msm		Command not executed if PME is not 
 *					enabled.
 *
 * --------------------------------------------------------------------------*/

class implementation VDPCmdRvPmr;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "griomacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vdsmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "vdsetmacros.h"		/* for vd$filter_objects */
#include "coparamac.h"			/* for as$start_dence */

#include "VDCmdDef.h"
#include "VDPDatFrmDf.h"

#include "FI.h"

%safe
#include "VX_FIproto.h"
%endsafe

from VDPpmrWpkg import VDPgetWorkPkg;

/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  my_init ( long * sts )
{
    IGRint		i, nbObjs = 0, size = sizeof(struct GRmd_env);
    IGRchar		str[100];
    IGRlong		msg, status = OM_S_SUCCESS;
    OMuword		curOs;
    struct VDPwrkPkg1	*WorkPkgs=NULL;
    struct GRid         WrkPkgId;
    struct GRmd_env     mod_env;

    SetProc( VDPCmdRvPmr.my_init ); Begin

    if( IsPmeEnabled() == FALSE )
    {
        UI_status("PME server connection required");
        *sts = VD_ERROR;
        me->state = _terminate;
        return status;
    }

    me->window_id.objid = NULL_OBJID;

    FIg_set_state( VD_FP, G_HILITE_OPTION, FALSE );
    FIg_set_state( VD_FP, G_FIT_ITEM_CHK, FALSE );

    /* get the current module env */

    gr$get_module_env(  msg     = &msg,
                        sizbuf  = &size,
                        buffer  = &mod_env );

    ex$get_cur_mod( osnum = &curOs );

    /* Get the Work package ID */

    status = VDPGetWrkPkgId ( &msg, &WrkPkgId );
    __CheckRC( status, msg, "VDPGetWrkPkgId", wrapup );
    __DBGpr_obj( "Work package Id", WrkPkgId );

    status =
    _VD_SEND_OBJ ( WrkPkgId, VDPpmrWpkg.VDPgetWorkPkg (
						&msg,
						&nbObjs,
						&WorkPkgs ) );
    __DBGpr_int( "No of work packages", nbObjs );
    __CheckRC( status, msg, "VDPgetWorkPkg", wrapup );

    if( !nbObjs )
    {
	me->state = _terminate;
	UI_status ("No work packages found");
        goto wrapup;
    }
    __DBGpr_int( "Number of work Packages", nbObjs );

    status = om$vla_set_dimension( varray = me->locObjs, size = nbObjs );
    __CheckRC( status, 1, "vla_set_dimension", wrapup );

    FIfld_set_num_rows( VD_FP, G_ITEMLIST, nbObjs );
    for( i = 0 ; i < nbObjs ; i++ )
    {
	__DBGpr_int(" Objid :", WorkPkgs[i].objid );
	__DBGpr_str(" Notes :", WorkPkgs[i].Notes );

	me->locObjs[i].obj_id.objid = WorkPkgs[i].objid;
	me->locObjs[i].obj_id.osnum = curOs;
	me->locObjs[i].mod_env = mod_env;

	LCget_info ( me->locObjs[i].obj_id.objid, 
		     me->locObjs[i].obj_id.osnum,
		     str);
	FIfld_set_value(VD_FP, G_ITEMLIST, i, 0, (double)me->locObjs[i].obj_id.objid, FALSE );
	FIfld_set_text( VD_FP, G_ITEMLIST, i, 1, str, FALSE );
	FIfld_set_text( VD_FP, G_ITEMLIST, i, 2, WorkPkgs[i].Notes, FALSE );
    }

wrapup :
    for ( i = 0; i < nbObjs; i++ )
	_FREE(WorkPkgs[i].Notes);
    _FREE ( WorkPkgs );

    if (! (status & msg & 1))
	me->state = _terminate;
    *sts = VD_SUCCESS;
    End
    return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the required PME data form.

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input

 -------------------------------------------------------------------------
-mo*/

method form_notification( int      form_label;
                          int      gadget_label;
                          double   value;
                          char     *form_ptr )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRlong             msg;
    IGRint              sel, pos, row, resp,
			hlt_opt, fit_opt;


    SetProc( VDPCmdRvPmr.form_notification ); Begin

    switch (gadget_label)
    {
        case FI_CANCEL :
	    _VD_SEND_MY ( VDS_LOCATE.erase_hilite ( &msg ) );
	    resp = VD_FORM_CANCEL;
            ex$putque( msg             = &msg,
                       response        = &resp );
            break;

	case G_ITEMLIST :

	    /* Get Hilite option 

	    FIg_get_state( VD_FP, G_HILITE_OPTION, &hlt_opt );
	    __DBGpr_int( "Highlight option", hlt_opt );

	    /* If hilite all then break 
	    if( !hlt_opt )
	        break;
	    */

	    /* get fit option */
	    FIg_get_state( VD_FP, G_FIT_ITEM_CHK, &fit_opt );
	    __DBGpr_int( "Fit Item option", fit_opt );

	    /* if fit enabled, and window_id is NULL_OBJID, get window input */

	    if( fit_opt && me->window_id.objid == NULL_OBJID )
	    {
	        status = _VD_SEND_MY( VDPCmdRvPmr.get_window( &msg ) );
	        __DBGpr_obj( "Window id", me->window_id );
	    }

	    /* get the selected item */

	    FIfld_get_active_row( VD_FP, G_ITEMLIST, &row, &pos );
	    FIfld_get_select( VD_FP, G_ITEMLIST, row, 0, &sel );

	    /* erase highlighted objects */

	    _VD_SEND_MY ( VDS_LOCATE.erase_hilite ( &msg ) );

	    if( !sel )
	        break;

	    /* fit and hilight selected item */

	    __DBGpr_obj( "Hilighting obj", me->locObjs[row].obj_id );

	    if ( fit_opt )
	    {
		status = 
		vd$vw_fit_object(  object      = &me->locObjs[row].obj_id,
				   md_env      = &me->locObjs[row].mod_env,
				   ggid        = &me->window_id,
				   factor      = 2.0,
				   num_ggid    = 1 );
		CheckRC( status, 1 );
	    }

	    status = 
	    _VD_SEND_MY( VDPCmdRvPmr.dpLocObjAtIndex( &msg, row, GRhd ) );
	    CheckRC( status, msg );

	    break;

	case G_FIT_ITEM_CHK :
	    break;

	case G_HILITE_OPTION :
	    FIg_get_state( VD_FP, G_HILITE_OPTION, &hlt_opt );
	    if( hlt_opt )
	    {
		/* disable fit object */

	        FIg_set_state( VD_FP, G_FIT_ITEM_CHK, FALSE );
	        FIg_disable( VD_FP, G_FIT_ITEM_CHK );

		/* hilight all objects */

		status = _VD_SEND_MY( VDPCmdRvPmr.dpLocObjs( &msg, 0, GRhd ) );
		CheckRC( status, msg );
	    }
	    else
	    {
	        FIg_enable( VD_FP, G_FIT_ITEM_CHK );
	        _VD_SEND_MY ( VDS_LOCATE.erase_hilite ( &msg ) );
	    }
	
	default :
	    break;
    }

    End
    return OM_S_SUCCESS;
}


method get_window( long *sts )
{
    IGRchar             winPrompt[] = "Identify window to fit item";
    IGRlong             msg;
    struct GRevent      event;

    SetProc( VDPCmdRvPmr.get_window ); Begin
    *sts = MSSUCC;

    if( me->window_id.objid != NULL_OBJID )
        return OM_S_SUCCESS;

    /* erase the form */
    FIf_erase( VD_FP );

    while( 1 )
    {
        while(!co$getevent( msg                 = &msg,
                            event_mask          = ( GRm_DATA ),
                            prompt              = winPrompt,
                            response            = me->response,
                            response_data       = me->response_data,
                            event               = &event ) )
            ;

        if( ( msg&1 ) && (*me->response == EX_DATA) )
        {
            me->window_id.objid = event.event.button.objid;
            me->window_id.osnum = event.event.button.osnum;
            break;
        }
    }

    /* restore the form */
    FIf_display( VD_FP );

    End
    return OM_S_SUCCESS;
}

end implementation VDPCmdRvPmr;
