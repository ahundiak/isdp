/* $Id */

/* ----------------------------------------------------------------------------
 * I/VDS
 * 
 * File :	vds/vdpenable/cmd/VDPCmdShEni.I
 *
 * Description:
 *	Implementation of the following methods.
 *		my_init
 *		VDPHighlightItems
 *		VDPSelectItems
 *
 * Dependencies:
 *
 * History:
 *
 *	12/10/95	MSM		Creation
 *	09/19/96	MSM		Command not executed if PME is not 
 *					enabled.
 *  01/01/98    SSR		TR # 179702658
 *  01/15/98	ah		Missing " from include "VDScheckdef.h
 *  08/14/98    SSR     Replaced "PME" with "AIM"
 *  24 nov 98	SSR	Added new case in form notification for showing
 *  			posting status. CR # 179801693
 *  26 AUG 99	SSR	New error code for posting status.
 *  02 DEC 99	SSR	CR # 898 two seperate lists for ERROR and SUCCESS
 *
 * --------------------------------------------------------------------------*/

class implementation VDPCmdShEn;

/*
#define vaimDEBUG
#define vaimerrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"
#include "exdef.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"

#include "vdsmacros.h"

#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"

#include "vdsetmacros.h"		/* for vd$filter_objects */
#include "coparamac.h"			/* for as$start_dence */

#include "VDCmdDef.h"
#include "VDPDatFrmDf.h"

#include "FI.h"

#include "vdparmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "ACdb_info.h"
#include "VDScheckdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "VDPtrTbl.h"


%safe
#include "VX_FIproto.h"
%endsafe

from VDPenabObj import VDPgetPMenabledList;
from VDPtrTbl import VDPprintTransTable;

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
    IGRint		i, nbItems = 0, found = 0;
    IGRchar		buffer[140], str[100], DirName[DI_PATH_MAX],
    			trTblName[DI_PATH_MAX];
    IGRlong		status = OM_S_SUCCESS;
    
    IGRint             	size,ret_size, TrSize, TrSizeCtr, errrow=0, sucrow=0;
    IGRlong             msg;
    struct GRmd_env     MdEnv;
    struct GRid         Obj, TrTblId;
    struct              ACrg_coll *Coll=NULL;
    struct ACobj_info_1 ObjInfo;
    OMuword		curOs;
    struct VDPtrObjList	*GlTrTbl = NULL;
    SetProc( VDPCmdShEn.my_init ); Begin

    if( IsPmeEnabled() == FALSE )
    {
      UI_status("AIM server connection required");
      *sts = VD_ERROR;
      me->state = _terminate;
      return OM_S_SUCCESS;
    }
    
    me->window_id.objid = NULL_OBJID; 
    
    FIg_set_state( VD_FP, G_HILITE_OPTION, FALSE );
    FIg_set_state( VD_FP, G_FIT_ITEM_CHK, FALSE );
    //FIg_erase ( VD_FP, 14 ); // CR # 179801693
    //FIg_erase ( VD_FP, 15 ); // CR # 179801693
    FIg_erase(VD_FP, G_ITEMLIST);
    // 02 dec 99 SSR changes for CR 898
    FIg_erase(VD_FP, G_ITEMLIST_SUCCESS);
    FIg_display(VD_FP, G_ITEMLIST_ERROR);
    FIg_set_state_on(VD_FP, G_TOG_ERROR);
    FIg_erase(VD_FP, G_ITEMLIST_STATUS);
    // end changes for CR 988
    
    status = _VD_SEND_MY( VDPCmdShEn.VDPSelectItems( sts ) );
    if( !(status & 1) )
    {
      UI_status( "Error encountered: command terminated" );
      me->state = _terminate;
      goto wrapup;
    } 
    nbItems = om$dimension_of( varray = me->locObjs );
    __DBGpr_int( "Number of items", nbItems ); 
    
    if(( !nbItems )|| (*sts == VD_RESTART_CMD ))
    {
      UI_status( "No AIM enabled items" );
      me->state = _terminate;
      goto wrapup;
    } 
    
    FIfld_set_num_rows( VD_FP, G_ITEMLIST, nbItems );
    FIfld_set_num_rows( VD_FP, G_ITEMLIST_STATUS, nbItems ); // CR # 179801693
    //FIfld_set_num_rows( VD_FP, 16, nbItems ); 
    //FIfld_set_num_rows( VD_FP, 20, nbItems );
    
    size = sizeof( struct GRmd_env ) ;
    gr$get_module_env(  msg    = &msg,
			sizbuf = &size,
			buffer = &MdEnv,
			nret   = &ret_size );
    Coll = _MALLOC ( 1, struct ACrg_coll );
    if ( Coll == NULL )
    {
      UI_status("Error no dynamic memory");
      return OM_E_NODYNMEM;
    } 
    
    TrTblId.objid = NULL_OBJID;// CR # 179801693
    ex$get_cur_mod ( osnum = &curOs );
    status = di$give_pathname( osnum = curOs,
				pathname = DirName );
    strcat ( DirName, SIR_GLOBAL_DIR );
    sprintf( trTblName, "%s%s", DirName, SIR_TRANS_LIST );
    status = di$translate ( objname = trTblName,
			p_objid = &TrTblId.objid,
			p_osnum = &TrTblId.osnum );

    if ( status == DIR_S_SUCCESS ) // CR # 179801693
    {
      status = _VD_SEND_OBJN(TrTblId, VDPtrTbl.VDPprintTransTable (&msg));
      GlTrTbl = (struct VDPtrObjList *)VDgetTrTable(); 
      TrSize = VDgetTrSize();
    }

    for( i = 0 ; i < nbItems ; i++ )
    {
	buffer[0] = '\0';
	LCget_info ( me->locObjs[i].obj_id.objid, 
		     me->locObjs[i].obj_id.osnum,
		     str);

        /* Finding the wet_weight; Fix for TR# 179603076 */
        Obj.objid = me->locObjs[i].obj_id.objid;
        Obj.osnum = me->locObjs[i].obj_id.osnum;
        status = VdsGet_db_info( &Obj, &ObjInfo, 1 );
 
        if(ObjInfo.quantity == EQUIPMENT_OBJ )
          strcpy(Coll[0].name,"wet_weight");
        else
          strcpy(Coll[0].name,"wet_wt");

        Coll[0].desc.type=AC_ATTRIB_DOUBLE;
        Coll[0].desc.value.att_exp =0.0;
        vd$review_params(   pMsg            = &msg,
                            pComponent      = &Obj,
                            pMdEnv          = &MdEnv,
                            pList           = Coll,
                            NbParams        = 1 );

        if(Coll[0].desc.type == AC_ATTRIB_DOUBLE)
          sprintf( buffer, "%s, Wet-Weight = %.3f",
                      str,Coll[0].desc.value.att_exp );
        else
          sprintf(buffer, "%s",str);

	FIfld_set_text( VD_FP, G_ITEMLIST, i, 0, buffer, FALSE );
	FIfld_set_text( VD_FP, G_ITEMLIST_STATUS, i, 0, buffer, FALSE );
	FIfld_set_text( VD_FP, G_ITEMLIST_STATUS, i, 1, "SUCCESS", FALSE );
	FIfld_set_value(VD_FP, G_ITEMLIST_STATUS, i, 2, i, FALSE);
	if(GlTrTbl)
	{
	  for(TrSizeCtr = 0; TrSizeCtr < TrSize; TrSizeCtr++)
	  {
	    if(Obj.objid == GlTrTbl[TrSizeCtr].VDSobjid)
	    {
	      FIfld_set_text(VD_FP, G_ITEMLIST_ERROR, errrow, 0, buffer, FALSE);
	      found = 1;
	      if(getPostingStatus(GlTrTbl[TrSizeCtr].ActionCode) == 1)
	      {
	        FIfld_set_text( VD_FP, G_ITEMLIST_STATUS, i,
		  		1, "UNPOSTED", FALSE );
		FIfld_set_text(VD_FP, G_ITEMLIST_ERROR, errrow,
		  		1, "UNPOSTED", FALSE);
		FIfld_set_value(VD_FP, G_ITEMLIST_ERROR, errrow, 2, i, FALSE);
	      }
	      if(getPostingStatus(GlTrTbl[TrSizeCtr].ActionCode) == 2)
	      {
	        FIfld_set_text( VD_FP, G_ITEMLIST_STATUS, i, 
		  		1, "ERROR", FALSE );
		FIfld_set_text(VD_FP, G_ITEMLIST_ERROR, errrow,
		  		1, "ERROR", FALSE);
		FIfld_set_value(VD_FP, G_ITEMLIST_ERROR, errrow, 2, i, FALSE);
	      }
	      //New error code SSR 26 AUG 99
	      if(getPostingStatus(GlTrTbl[TrSizeCtr].ActionCode) == 3)
	      {
	        FIfld_set_text( VD_FP, G_ITEMLIST_STATUS, i, 
		  		1, "ERR_DUP", FALSE );
		FIfld_set_text(VD_FP, G_ITEMLIST_ERROR, errrow,
		  		1, "ERR_DUP", FALSE);
		FIfld_set_value(VD_FP, G_ITEMLIST_ERROR, errrow, 2, i, FALSE);
	      }
	      errrow ++;
	    }
	  }
	}
	// CR 898
	if (found == 0)
	{
	  FIfld_set_text(VD_FP, G_ITEMLIST_SUCCESS, sucrow, 0, buffer, FALSE);
	  FIfld_set_text( VD_FP, G_ITEMLIST_SUCCESS, sucrow, 
	    		1, "SUCCESS", FALSE );
	  FIfld_set_value( VD_FP, G_ITEMLIST_SUCCESS, sucrow, 2, i, FALSE );
	  __DBGpr_com( " Added to success.");
	  sucrow ++;
	}
    } 

wrapup :
    if(Coll != NULL)
      _FREE( Coll );
    if(GlTrTbl != NULL)
      _FREE( GlTrTbl );
    *sts = VD_SUCCESS;
    End
    return OM_S_SUCCESS;

}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPSelectItems

  Abstract
	This method selects all the Enabled Items.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/
method VDPSelectItems( long	*sts )
{
    IGRint		i, nbObjs = 0;
    IGRlong		msg = 1,
			status = OM_S_SUCCESS;

    struct GRid         EnabListId;
    struct GRobj_env    *listObjs = NULL;
    OMuword             curOs;


    SetProc (VDPCmdShEn.VDPSelectItems); Begin
    *sts = VD_SUCCESS;

    /* Get the Enabled List ID */

    ex$get_cur_mod( osnum = &curOs );

    status = VDPGetEnabledListId ( &msg, curOs, &EnabListId );
    __CheckRC( status, msg, "VDPGetEnabledListId", wrapup );
    __DBGpr_obj( "Enabled List Id", EnabListId );

   /* Get all the PME Enabled OBJID's */

    status =
    _VD_SEND_OBJ ( EnabListId, VDPenabObj.VDPgetPMenabledList ( 
						&msg,
						&nbObjs,
						&listObjs ) );
    __DBGpr_int( "No of objects located", nbObjs );

    __CheckRC( status, msg, "VDPgetPMenabledList", wrapup );

    if( !nbObjs )
    {
	UI_status( "No AIM enabled objects found" );
        *sts = VD_RESTART_CMD;
        goto wrapup;
    }

    status = om$vla_set_dimension(  varray  = me->locObjs,
                                    size    = nbObjs );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    for( i = 0; i < nbObjs; i++ )
	me->locObjs[i] = listObjs[i];

wrapup :
    _FREE (listObjs);
    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status ("Error encountered : command terminated" );
    }

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
    IGRint              sel, pos, row, resp, err_opt, suc_opt,
			hlt_opt, fit_opt, post_opt, first_row = 0;
    double 		ori_row = 0.0;

    SetProc( VDPCmdShEn.form_notification ); Begin

    __DBGpr_int( " gadget_label ", gadget_label);
    switch (gadget_label)
    {
        case FI_CANCEL :
	    _VD_SEND_MY ( VDS_LOCATE.erase_hilite ( &msg ) );
	    resp = VD_FORM_CANCEL;
            ex$putque( msg             = &msg,
                       response        = &resp );
            break;

	case G_ITEMLIST_STATUS: // CR # 179801693
	case G_ITEMLIST_ERROR: // CR 898
	case G_ITEMLIST_SUCCESS:
	    /* get fit option */
	    FIg_get_state( VD_FP, G_FIT_ITEM_CHK, &fit_opt );
	    __DBGpr_int( "Fit Item option", fit_opt );

	    /* if fit enabled, and window_id is NULL_OBJID, get window input */

	    if( fit_opt && me->window_id.objid == NULL_OBJID )
	    {
	        status = _VD_SEND_MY( VDPCmdShEn.get_window( &msg ) );
		__CheckRC( status, msg, "get_window", wrapup );
	        __DBGpr_obj( "Window id", me->window_id );
	    }

	    /* get the selected item */

	    /*FIfld_get_active_row( VD_FP, 14, &row, &pos );
	    FIfld_get_select( VD_FP, 14, row, 0, &sel );
	    FIfld_get_value( VD_FP, 14, row, 2, ori_row, &sel, &pos );*/

	    FIfld_get_active_row( VD_FP, gadget_label, &row, &pos );
	    FIfld_get_value(VD_FP, gadget_label, row, 2, &ori_row, &sel, &pos );
	    FIfld_get_select( VD_FP, gadget_label, row, 0, &sel );
	    first_row = (int)ori_row;
	    /* erase highlighted objects */

	    _VD_SEND_MY ( VDS_LOCATE.erase_hilite ( &msg ) );

	    if( !sel )
	        break;

	    /* fit and hilight selected item */

	    //__DBGpr_obj( "Hilighting obj", me->locObjs[row].obj_id );
	    __DBGpr_obj( "Hilighting obj", me->locObjs[first_row].obj_id );

	    if( fit_opt )
	    {
		status = 
		vd$vw_fit_object(  object    = &me->locObjs[first_row].obj_id, 
				   md_env    = &me->locObjs[first_row].mod_env, 
				   ggid      = &me->window_id, 
				   factor    = 2.0, 
				   num_ggid  = 1 );
		CheckRC( status, 1 );
	    }

	    status = 
	    _VD_SEND_MY( VDPCmdShEn.dpLocObjAtIndex( &msg, first_row, GRhd ) );
	    CheckRC( status, msg );

	    break;
	case G_ITEMLIST :

	    /* Get Hilite option */

/*
	    FIg_get_state( VD_FP, G_HILITE_OPTION, &hlt_opt );
	    __DBGpr_int( "Highlight option", hlt_opt );

	    /* If hilite all then break *
	    if( !hlt_opt )
	        break;
*/

	    /* get fit option */
	    FIg_get_state( VD_FP, G_FIT_ITEM_CHK, &fit_opt );
	    __DBGpr_int( "Fit Item option", fit_opt );

	    /* if fit enabled, and window_id is NULL_OBJID, get window input */

	    if( fit_opt && me->window_id.objid == NULL_OBJID )
	    {
	        status = _VD_SEND_MY( VDPCmdShEn.get_window( &msg ) );
		__CheckRC( status, msg, "get_window", wrapup );
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

	    if( fit_opt )
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
	    _VD_SEND_MY( VDPCmdShEn.dpLocObjAtIndex( &msg, row, GRhd ) );
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

		status = _VD_SEND_MY( VDPCmdShEn.dpLocObjs( &msg, 0, GRhd ) );
		CheckRC( status, msg );
	    }
	    else
	    {
	        FIg_enable( VD_FP, G_FIT_ITEM_CHK );
	        _VD_SEND_MY ( VDS_LOCATE.erase_hilite ( &msg ) );
	    }
	
	    break;

	case 13:  // CR # 179801693

	    FIg_get_state( VD_FP, 13, &post_opt );
	    __DBGpr_int( "Fit Item option", post_opt );
	    if ( post_opt )
	    {
	      FIg_erase( VD_FP, G_ITEMLIST );
	      FIg_erase(VD_FP, G_ITEMLIST_ERROR);
	      FIg_erase(VD_FP, G_ITEMLIST_SUCCESS);
	      FIg_display( VD_FP, G_ITEMLIST_STATUS );
	    }
	    else
	    {
	      FIg_erase( VD_FP, G_ITEMLIST_STATUS );
	      FIg_erase(VD_FP, G_ITEMLIST_ERROR);
	      FIg_erase(VD_FP, G_ITEMLIST_SUCCESS);
	      FIg_display( VD_FP, G_ITEMLIST);
	    }

	    break;

	case G_TOG_ERROR: // CR 898
	    FIg_set_state_off(VD_FP,G_TOG_SUCC);
	    FIg_get_state(VD_FP, G_TOG_ERROR, &err_opt);
	    if(err_opt)
	    {
	      FIg_erase(VD_FP, G_ITEMLIST);
	      FIg_erase(VD_FP, G_ITEMLIST_SUCCESS);
	      FIg_erase(VD_FP,G_ITEMLIST_STATUS);
	      FIg_display(VD_FP, G_ITEMLIST_ERROR);
	    }
	    else
	    {
	      FIg_erase(VD_FP, G_ITEMLIST_SUCCESS);
	      FIg_erase(VD_FP, G_ITEMLIST_ERROR);
	      FIg_erase(VD_FP, G_ITEMLIST);
	      FIg_display(VD_FP, G_ITEMLIST_STATUS);
	    }
	    break;

	case G_TOG_SUCC: // CR 898
	    FIg_set_state_off(VD_FP, G_TOG_ERROR);
	    FIg_get_state(VD_FP, G_TOG_SUCC, &suc_opt);
	    if(suc_opt)
	    {
	      FIg_erase(VD_FP, G_ITEMLIST_ERROR);
	      FIg_erase(VD_FP,G_ITEMLIST_STATUS);
	      FIg_erase(VD_FP, G_ITEMLIST);
	      FIg_display(VD_FP, G_ITEMLIST_SUCCESS);
	    }
	    else
	    {
	      FIg_erase(VD_FP, G_ITEMLIST);
	      FIg_erase(VD_FP, G_ITEMLIST_SUCCESS);
	      FIg_erase(VD_FP,G_ITEMLIST_ERROR);
	      FIg_display(VD_FP, G_ITEMLIST_STATUS);
	    }
	    break;
	default :
	    break;
    }

wrapup:
    End
    return OM_S_SUCCESS;
}

method get_window( long *sts )
{
    IGRchar             winPrompt[] = "Identify window to fit item";
    IGRlong             msg;
    struct GRevent      event;

    SetProc( VDPCmdShEn.get_window ); Begin
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

end implementation VDPCmdShEn;
