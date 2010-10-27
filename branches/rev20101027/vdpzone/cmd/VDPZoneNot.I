/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdpzone/cmd/VDPZoneNot.I
 *
 * Description:
 *      Implementation of the following method for VDPCmdZone :
 *              form_notification
 *
 * Dependencies:
 *
 * History:
 *
 *      12/21/95        MSM             Creation
 *	 4/25/96	MSM		Added functionality to select 
 *					associative objects as zones.
 *	10/01/96	MRA		Added mising argument to VDdispMVform()
 *	10/01/96	MRA		Intilaized model view graphic objid to
 *					NULL_OBJID.
 *	11/05/96	Ravi		Corrected the arguments for VDPmeCheckin
 *					func.
 *
 *	Feb 26 1998	SSR		TR # 1799800484
 */

class implementation VDPCmdZone;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"

#include "VDPZnFrmDf.h"

#define	MAIN	0
#define SUB	1

#define VD_LOC_SOLID	1000

extern GRclassid	OPP_EMSsolid_class_id;
extern GRclassid	OPP_EMSsurface_class_id;
extern GRclassid	OPP_GRcurve_class_id;
extern GRclassid	OPP_GR3dpoint_class_id;
extern GRclassid	OPP_VDmdlview_class_id;
extern GRclassid	OPP_ACpretend_class_id;

from VDmdlview import   VDmv_display_solid;
from NDnode  import     NDget_objects;
from ACpretend import   ACreturn_foot;
/*
from GRgraphics import  GRputname;
*/

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the main zone form

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input

  Algorithm


--------------------------------------------------------------------------
-mo*/

method form_notification( int      form_label;
                          int      gadget_label;
                          double   value;
                          char     *form_ptr )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRlong             msg, sts1;
    IGRint              i, sel, pos, row,
                        resp, sts, len, num_rows=0;
    IGRchar		SubTypeDesc[VDPDESC_LEN], ZoneClass[VDPCLASS_NAME_LEN],
			ZoneName[VDPNAME_LEN], tmpstr[20], FileId[VDPOBID_LEN];
    IGRint		NbCtxTST, SubType, NbZones,
			num_mv_sel, nbLocObjs=0;
    IGRchar		filename[20];
    struct GRid		*mv_ids = NULL, gr_obj;
    struct GRmd_env	*mv_envs = NULL;
    enum GRdpmode   	dpmode;
    struct GRobj_env	*LocObjs=NULL;
    struct VDPzone      ZoneInfo;
    OMuword		curOs;
    IGRboolean		bSingMulti = TRUE;
    IGRboolean          TrSav=FALSE;

    SetProc ( VDPCmdZone.form_notification ); Begin

    msg = MSSUCC;

    FIfld_set_text( VD_FP0, FI_MSG_FIELD, 0, 0 , "", FALSE );
    FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0 , "", FALSE );
    UI_status(" ");

    if ( form_label == MAIN )
    {
	switch (gadget_label)
	{
	case FI_ACCEPT :
	case FI_CANCEL :

	    resp = VD_FORM_CANCEL;
	    ex$putque( msg	= &msg,
	               response = &resp );
	    break;

	case G_MCF :

	    /* get the row selected */
            FIfld_get_active_row( VD_FP0, G_MCF, &row, &pos );
            FIfld_get_select( VD_FP0, G_MCF, row, 0, &sel );

            dp$erase_hilite ( msg = &msg );

            dpmode = GRhd;
	    if(!sel) 
		break;
	
	    __DBGpr_obj ( "Highlighting Zone ", me->zones[row].ZoneId );

	    /* Send a highlight message to the VDS Object. */

	    status = VDPhighlightZone ( &msg, me->zones[row].ZoneId, dpmode ); 
	    CheckRC( status, msg );

	    gr_obj.objid = NULL_OBJID;
	    status = VDPgetGraphicalObject ( &msg, me->zones[row].ZoneId, &gr_obj ); 
	    if ( gr_obj.objid == NULL_OBJID )
	    {
		FIg_enable( VD_FP0, G_MODIFY_BTN );
		FIg_enable( VD_FP0, G_DELETE_BTN );
	    }
	    else
	    {
		FIg_disable( VD_FP0, G_MODIFY_BTN );
		FIg_disable( VD_FP0, G_DELETE_BTN );
	    }
	    CheckRC( status, msg );

	    break;

	case G_DEFINE_BTN :
	    /* Temporarily disable the form */
	    FIg_disable( VD_FP0, FI_CTRL_GROUP );
	    FIg_disable( VD_FP0, G_MAIN_GROUP );

	    /* Clear out the active Zone data */
	    me->activeZone.ZoneType = ZONE_TYPE_NOTDEF;
	    me->activeZone.ZoneId.objid = NULL_OBJID;
	    me->activeZone.ZoneCtx.Type = 'N';
	    me->activeZone.ZoneCtx.SubType = -1;
	    me->activeZone.ZoneCtx.SubTypeDesc[0]='\0';
	    me->activeZone.ZoneCtx.Name[0]='\0';
	    me->activeZone.ZoneCtx.CtxDesc[0]='\0';
	    me->activeZone.ZoneCtx.CtxId[0]='\0';

	    FIfld_set_text( VD_FP1,G_ZONE_NAME,0,0,"",FALSE );
	    FIfld_set_text( VD_FP1,G_ZONE_SUBTYPE,0,0,"",FALSE );
	    FIfld_set_text( VD_FP1,G_DESCRIPTION,0,0,"",FALSE );
	    FIfld_set_text( VD_FP1,G_ZONE_GEOMETRY,0,0,"",FALSE );
	    FIfld_set_list_num_rows (VD_FP1, G_ZONE_NAME, 0, 0);

	    /* Process the sub form */
	    me->form_state = S_DEFINE;
	    status = om$send(msg = message CEO.display_form_by_label
						     (SUB,&sts),
		    targetid = my_id);

	    break;

	case G_MODIFY_BTN :
	    FIg_disable( VD_FP0, FI_CTRL_GROUP );
	    FIg_disable( VD_FP0, G_MAIN_GROUP );

	    FIfld_get_active_row( VD_FP0, G_MCF, &row, &pos );
	    FIfld_get_select( VD_FP0, G_MCF, row, 0, &sel );

	    if(!sel) 
	    {
		UI_status ( "No Zone Selected" );
		break;
	    }

	    FIfld_set_text( VD_FP1,G_ZONE_NAME,0,0,me->zones[row].ZoneCtx.Name,FALSE );
	    FIfld_set_text( VD_FP1,G_ZONE_SUBTYPE,0,0,me->zones[row].ZoneCtx.SubTypeDesc,FALSE );
	    FIfld_set_text( VD_FP1,G_DESCRIPTION,0,0, me->zones[row].ZoneCtx.CtxDesc,FALSE );

	    me->activeZone.ZoneType = me->zones[row].ZoneType;
	    me->activeZone.ZoneId = me->zones[row].ZoneId;
	    me->activeZone.ZoneCtx.Type = 'Z';
	    me->activeZone.ZoneCtx.SubType=me->zones[row].ZoneCtx.SubType;
	    strcpy( me->activeZone.ZoneCtx.SubTypeDesc, me->zones[row].ZoneCtx.SubTypeDesc );
	    strcpy( me->activeZone.ZoneCtx.Name, me->zones[row].ZoneCtx.Name );
	    strcpy( me->activeZone.ZoneCtx.CtxDesc, me->zones[row].ZoneCtx.CtxDesc);
	    strcpy( me->activeZone.ZoneCtx.CtxId, me->zones[row].ZoneCtx.CtxId );

	    FIg_disable( VD_FP1, G_ZONE_NAME );
	    FIg_disable( VD_FP1, G_ZONE_SUBTYPE );
	    FIg_disable( VD_FP1, G_DESCRIPTION );

	    FIfld_set_text( VD_FP1,G_ZONE_GEOMETRY,0,0,"",FALSE );

	    /* Process the sub form */
	    me->form_state = S_MODIFY;
	    status = om$send(msg = message CEO.display_form_by_label
						     (SUB,&sts),
		    targetid = my_id);

	    break;

	case G_DELETE_BTN :
	    FIfld_set_text( VD_FP0, FI_MSG_FIELD, 0, 0 ,"Delete not implemented", FALSE );
	    break;

        case G_DISPLAY_BTN :
	    FIfld_get_num_rows ( VD_FP0, G_MCF, &num_rows );

	    for ( i =0; i < num_rows; i++ )
		FImcf_set_select( VD_FP0, G_MCF, i, TRUE );

	    dp$erase_hilite ( msg = &msg );

	    dpmode = GRhd;
	    /* Get all the selected ones from the MCF and highlight them */
	    for ( i =0; i < num_rows; i++ )
	    {
	        __DBGpr_obj ( "Highlighting Object ", me->zones[i].ZoneId );

	        /* Send a highlight message to the VDS Object. */
	        status = VDPhighlightZone ( &msg, me->zones[i].ZoneId, dpmode);
	    }

	    break;

        case G_VALIDATE_BTN :
	    /* Get the selected zones from the MCF and validate them */

	    break;
	case G_RELNSHIP_BTN :

	    FIfld_get_active_row( VD_FP0, G_MCF, &row, &pos );
	    FIfld_get_select( VD_FP0, G_MCF, row, 0, &sel );

	    if(!sel) 
	    {
		UI_status ( "No Zone Selected" );
		break;
	    }
	
	    __DBGpr_obj ( "Processing Object ", me->zones[row].ZoneId );

	    status = VDSget_filename( filename );
	    __DBGpr_str( "Filename ", filename );

	    status = ex$save_module( ftype = EX_visible, filename = &filename[1] );
	    /*__CheckRC ( status, 1, "ex$save_module", wrapup ); */

	    UI_status ( "Posting Objects to the PME database " );
	    status = VDPmeCheckin( &msg, TrSav );
	    
	    if ( ! (status & 1) )
		UI_status ("No items were found. Posting failed" );

	    /*  continue with posting of relationships.
		__CheckRC ( status, msg, "VDPmeCheckin", wrapup ); */

	    gr_obj.objid = NULL_OBJID;
	    status = VDPgetGraphicalObject ( &msg, me->zones[row].ZoneId, &gr_obj ); 
	    CheckRC( status, msg );
	    status = VDSelectElementsinVolume ( &msg,
					/*	me->zones[row].ZoneId, */
						gr_obj,
						me->activeZone.ZoneType,
						0.0,
						NULL, 
						my_id,
						&me->located_chansel,
						me->ModuleInfo,
						&nbLocObjs,
						&LocObjs );
	    __DBGpr_int( "Number of Elements in Volume ", nbLocObjs );

	    __CheckRC ( status, msg, "VDPSelectElementsinVolume", wrapup );

	    /* Send the zone id, File id & list of Objects for posting the
		relationship */

	    for ( i=0; i < nbLocObjs; i++ )
		__DBGpr_obj ( "Obj Id ", LocObjs[i].obj_id );

	    status = VDPpostSpatialRelnship (   &msg,
						VDPTZONE_CODE,
	    				/*	me->zones[row].ZoneCtx.CtxId,*/
						me->zones[row].ZoneId,
						nbLocObjs,
						LocObjs );
	    __CheckRC ( status, msg, "VDPpostZoneRelnship", wrapup );

	    dp$erase_hilite ( msg = &msg );
	    //UI_status (" " ); TR # 179800484 SSR

	    break;

	default :
	    break;
	}
    }
    else /* for the SUB_FORM */
    {
	switch (gadget_label)
	{
	case G_ZONE_GEOMETRY :

	    FIg_get_text( VD_FP1, G_ZONE_GEOMETRY, tmpstr );
	    if( !strcmp(tmpstr, "Model View" ) )
	    {
	        FIg_disable( VD_FP1, FI_CTRL_GROUP );
		num_mv_sel = 0;
		sts1 = VDdispMVform( &msg,
				     bSingMulti,
				     &num_mv_sel,
				     &mv_ids,
				     &mv_envs,
				     NULL,
				     NULL );
		__DBGpr_int("Num of Model Views selected ", num_mv_sel );
		if( num_mv_sel )
		{
		    __DBGpr_obj("Model View Object", mv_ids[0] ); 

		    me->activeZone.ZoneType = VDP_MDLVW_ZONE;
		    me->gr_objenv.obj_id = mv_ids[0];
		    me->gr_objenv.mod_env = mv_envs[0];
		}
		else
		 me->gr_objenv.obj_id.objid = NULL_OBJID;
		 /* TR179603236 - 30 Sep 96 */

		if ( mv_ids ) free ( mv_ids );
		if ( mv_envs ) free ( mv_envs );
	        FIg_enable( VD_FP1, FI_CTRL_GROUP );
	    }

	    if( !strcmp(tmpstr,"Solid" ))
	    {
		me->locate_eligible_thing.w_count = 1;
		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
		om$vla_set_dimension( varray = me->eligible_classids,
			    size   = me->locate_eligible_thing.w_count );
		me->eligible_classids[0] = OPP_EMSsolid_class_id;
		me->locate_eligible_thing.p_classes = me->eligible_classids;
		me->locate_eligible = &me->locate_eligible_thing;
		strcpy( me->prompt, "Locate Solid" );
		strcpy( me->reloc_prompt, "Solid not Found" );

	        resp = VD_LOC_SOLID;
	        ex$putque( msg	= &msg,
			   response = &resp );
		break;
	    }
	    if( !strcmp( tmpstr,"Plane/surface"))
	    {
		me->locate_eligible_thing.w_count = 1;
		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
		om$vla_set_dimension( varray = me->eligible_classids,
			    size   = me->locate_eligible_thing.w_count );
		me->eligible_classids[0] = OPP_EMSsurface_class_id;
		me->locate_eligible_thing.p_classes = me->eligible_classids;
		me->locate_eligible = &me->locate_eligible_thing;
		strcpy( me->prompt, "Locate Surface" );
		strcpy( me->reloc_prompt, "Surface not Found" );

	        resp = VD_LOC_SOLID;
	        ex$putque( msg	= &msg,
			   response = &resp );
		break;
	    }
	    if( !strcmp( tmpstr,"Line/curve"))
	    {
		me->locate_eligible_thing.w_count = 1;
		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
		om$vla_set_dimension( varray = me->eligible_classids,
			    size   = me->locate_eligible_thing.w_count );
		me->eligible_classids[0] = OPP_GRcurve_class_id;
		me->locate_eligible_thing.p_classes = me->eligible_classids;
		me->locate_eligible = &me->locate_eligible_thing;
		strcpy( me->prompt, "Locate Line/Curve" );
		strcpy( me->reloc_prompt, "Line/Curve not Found" );

	        resp = VD_LOC_SOLID;
	        ex$putque( msg	= &msg,
			   response = &resp );
		break;
	    }
	    if( !strcmp( tmpstr,"Point"))
	    {
		me->locate_eligible_thing.w_count = 1;
		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
		om$vla_set_dimension( varray = me->eligible_classids,
			    size   = me->locate_eligible_thing.w_count );
		me->eligible_classids[0] = OPP_GR3dpoint_class_id;
		me->locate_eligible_thing.p_classes = me->eligible_classids;
		me->locate_eligible = &me->locate_eligible_thing;
		strcpy( me->prompt, "Locate Point" );
		strcpy( me->reloc_prompt, "Point not Found" );

	        resp = VD_LOC_SOLID;
	        ex$putque( msg	= &msg,
			   response = &resp );
		break;
	    }

/* For later
	    if( !strcmp( tmpstr,"None"))
	    {
		ex$get_cur_mod( osnum = &curOs );

		status = di$give_pathname(  osnum           = curOs,
					    pathname        = DirName );
		CheckRC( status, 1 );
		__DBGpr_str( "Path name", DirName );

		sprintf( Name,"%s%s%s\0", DirName, PME_GLOBAL_DIR, me->activeZone.ZoneCtx.Name );
		__DBGpr_str( "Name :", Name );
		status = exp$create( exp_name	= Name,
				     exp_syntax = me->activeZone.ZoneCtx.Name,
				     osnum	= curOs,
				     p_exp_id	= &exp_id,
				     type_req	= EXP_TEXT );
		CheckRC ( status, 1 );

		me->activeZone.ZoneId.objid = exp_id.objid;
		me->activeZone.ZoneId.osnum = exp_id.osnum;

		break;
	    }
*/
	    break;

	case G_ZONE_SUBTYPE :
	    FIfld_get_text( VD_FP1, G_ZONE_SUBTYPE,0,0,VDPDESC_LEN,SubTypeDesc, &sel,&pos);
            if(SubTypeDesc[0] == '\0' ) break;

            NbCtxTST = om$dimension_of( varray = me->CtxTST );
            VDPGetContextSubTypeCode (  'Z',
					SubTypeDesc,
					me->CtxTST,
					NbCtxTST,
					&SubType);

	    /* If the Subtype is different from the Old one then clear the
	     * other fields. */
	    if( me->activeZone.ZoneCtx.SubType != SubType )
	    {
		me->activeZone.ZoneCtx.SubTypeDesc[0] = '\0';
		me->activeZone.ZoneCtx.Name[0]='\0';
		me->activeZone.ZoneCtx.CtxDesc[0] ='\0';
		me->activeZone.ZoneCtx.CtxId[0] = '\0';

		FIfld_set_text( VD_FP1,G_ZONE_NAME,0,0,"",FALSE );
                FIfld_set_text( VD_FP1,G_DESCRIPTION, 0,0,"",FALSE );

		FIfld_set_list_num_rows (VD_FP1, G_ZONE_NAME, 0, 0);

		me->activeZone.ZoneCtx.Type = 'Z';
		me->activeZone.ZoneCtx.SubType = SubType;
		strcpy( me->activeZone.ZoneCtx.SubTypeDesc,SubTypeDesc);

		ZoneClass[0] = '\0';
		VDPGetClassNameGivenTST('Z',
					SubType,
					me->CtxTST,
					NbCtxTST,
					ZoneClass );
		__DBGpr_str ( "Zone Class", ZoneClass );

		/* query the database for Zone names, descriptions & ids */

		status =
		_VD_SEND_MY( VDPCmdZone.VDPqueryClass( &msg, ZoneClass ) );
		CheckRC( status, msg );

		/* Fill the associated list */
		NbZones = om$dimension_of( varray = me->ZoneNameDesc );
		__DBGpr_int("Number of Unplaced Zones", NbZones );

		row = 0;
		for( i = 0; i < NbZones; i++ )
                    FIfld_set_list_text( VD_FP1, G_ZONE_NAME, row++,0,
                                        me->ZoneNameDesc[i].CtxName, FALSE );
	    }

	    break;

	case G_ZONE_NAME :
	    FIfld_get_text(VD_FP1, G_ZONE_NAME, 0, 0, VDPNAME_LEN, ZoneName, &sel, &pos );
	    NbZones = om$dimension_of( varray = me->ZoneNameDesc );
	    __DBGpr_int("Number of Zones", NbZones );
             for ( i=0; i < NbZones; i++ )
             {
		__DBGpr_str( "Zone Selected", ZoneName );
		__DBGpr_str( "Context Name", me->ZoneNameDesc[i].CtxName);
		__DBGpr_str( "Context Desc", me->ZoneNameDesc[i].CtxDesc);

                if(!strcmp(ZoneName,me->ZoneNameDesc[i].CtxName))
		{
                   FIfld_set_text( VD_FP1, G_DESCRIPTION, 0, 0, me->ZoneNameDesc[i].CtxDesc, FALSE );
		   strcpy( me->activeZone.ZoneCtx.Name, ZoneName );
		   strcpy( me->activeZone.ZoneCtx.CtxDesc, me->ZoneNameDesc[i].CtxDesc );
		   strcpy( me->activeZone.ZoneCtx.CtxId, me->ZoneNameDesc[i].CtxId );
		   __DBGpr_str(" Zone Name ",  me->activeZone.ZoneCtx.Name );
                   break;
		}
             }
	    break;

	case FI_ACCEPT :

	    /* Validate the Inputs */
	    FIfld_get_text_length( VD_FP1, G_ZONE_NAME, 0, 0, &len );
	    if( len == 1 )
	    {
		FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0, "Zone Name must be set", FALSE );
		return OM_E_ABORT;
	    }

	    FIfld_get_text_length( VD_FP1, G_ZONE_SUBTYPE, 0, 0, &len );
	    if( len == 1 )
	    {
		FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0, "Zone Subtype must be set", FALSE );
		return OM_E_ABORT;
	    }

	    ZoneInfo.ZoneType = me->activeZone.ZoneType;
	    ZoneInfo.ZoneCtx  = me->activeZone.ZoneCtx;

	    if ( me->gr_objenv.obj_id.objid == NULL_OBJID )
	    {
		FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0, "Geometry must be selected", FALSE );
		return OM_E_ABORT;
	    }
	    if(me->form_state == S_DEFINE )
	    {
		status = VDPconstructZoneObject( &msg,
						&me->gr_objenv.obj_id,
						&me->gr_objenv.mod_env,
						&ZoneInfo );
		__CheckRC ( status, msg, "VDPconstructZoneObject", wrapup );

		me->activeZone.ZoneId.objid = ZoneInfo.ZoneId.objid;
		me->activeZone.ZoneId.osnum = ZoneInfo.ZoneId.osnum;

		__DBGpr_obj( "Zone object", me->activeZone.ZoneId );

		if ( me->activeZone.ZoneId.objid == NULL_OBJID )
		{
		    FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0, "Zone Object Not created", FALSE );
		    return OM_E_ABORT;
		}

/*
		status =
		_VD_SEND_OBJ( me->activeZone.ZoneId, GRgraphics.GRputname 
					( &msg, me->activeZone.ZoneCtx.Name ));
		CheckRC( status, msg );
*/

		ex$get_cur_mod( osnum = &curOs );
		status = VDPGetFileId( &msg, curOs, FileId );
		__CheckRC( status, msg,"VDPGetFileId", wrapup );

		__DBGpr_obj( "Zone Object", me->activeZone.ZoneId );
		__DBGpr_str( "Zone Context", me->activeZone.ZoneCtx.CtxId );
		__DBGpr_str(" Zone Name ",  me->activeZone.ZoneCtx.Name );

		/* Add the VDS Zone Id to PME server */

		status =  VDPplaceSpatialContext ( &msg, 
						'Z',
						me->activeZone.ZoneCtx.CtxId, 
						FileId, 
						me->activeZone.ZoneId.objid );
		if( !(status & msg & 1 ))
		UI_status ("Zone not posted");
		__CheckRC( status, msg, "VDPplaceSpatialContext", wrapup );

		/* Add to the Placed Zones */

		status = _VD_SEND_MY( VDPCmdZone.update( &msg ) );
		__CheckRC( status, msg, "VDPCmdZone.update", wrapup );

	    /* No break because it should continue and process */
	    }
	    else if(me->form_state == S_MODIFY )
	    {
		ZoneInfo.ZoneId = me->activeZone.ZoneId;
		status = VDPconnectZonetoGRobj( &msg,
						&me->gr_objenv.obj_id,
						&me->gr_objenv.mod_env,
						ZoneInfo );
		__CheckRC ( status, msg, "VDPconstructZoneObject", wrapup );

	    }

	case FI_CANCEL :

	    FIf_erase( VD_FP1);
	    FIf_display( VD_FP0);

	    /* Re-enable gadgets on the main form */
	    FIg_enable( VD_FP0, FI_CTRL_GROUP );
	    FIg_enable( VD_FP0, G_MAIN_GROUP );
	    FIg_disable( VD_FP0, G_MODIFY_BTN );
	    FIg_disable( VD_FP0, G_DELETE_BTN );

	    break;

	default :
	    break;
	}
    }

wrapup :

    if (! (status & msg & 1)) 
	me->state = _terminate;

    _FREE( LocObjs );

    End
    return OM_S_SUCCESS;
}

/*
 *  This function returns the graphical object for a given zone.
 */

IGRint VDPgetGraphicalObject ( IGRlong		*msg,
			       struct GRid	ZoneId,
			       struct GRid	*gr_obj )
{
    IGRlong		status=OM_S_SUCCESS;
    GRclassid		ClassId;
    IGRint		count=0;
    IGRshort		mat_type;
    IGRdouble		matrix[16];
    struct GRid		pretend_obj;

    SetProc ( VDPgetGraphicalObject ); Begin

    *msg = MSSUCC;

    gr_obj->objid = NULL_OBJID;
    status =
    _VD_SEND_OBJN( ZoneId, NDnode.NDget_objects(  ND_ROOT,
						gr_obj,
						1,
						NULL,
						0,
						OM_K_MAXINT,
						&count ) );
    __CheckRC( status, 1, "message NDnode.NDget_objects", wrapup );
    om$get_classid (objid = gr_obj->objid,
		    osnum = gr_obj->osnum,
		    p_classid = &ClassId );

    if ( om$is_ancestry_valid
			( subclassid   = ClassId,
			  superclassid = OPP_ACpretend_class_id )
	     == OM_S_SUCCESS )
    {
	pretend_obj.objid = gr_obj->objid;
	pretend_obj.osnum = gr_obj->osnum;
	status =
	_VD_SEND_OBJN( pretend_obj, ACpretend.ACreturn_foot ( msg,
							 "",
							 gr_obj,
							 &mat_type,
							 matrix ) );
	__CheckRC( status, 1, "message ACpretend.ACreturn_foot", wrapup );
	__DBGpr_com(" ACpretend object ");
    }
    __DBGpr_obj ("Graphical Object", *gr_obj );

wrapup :
    End
    return status;
}

/* 
 * This function highlights the specified zone.
 */

IGRint	VDPhighlightZone ( IGRlong  	*msg, 
			   struct GRid	ZoneId, 
			   enum GRdpmode dpmode  )
{
    IGRlong		status=OM_S_SUCCESS;
    GRclassid		ClassId;
    struct GRid		gr_obj;
    IGRint		count=0;
    IGRshort		mat_type;
    IGRdouble		matrix[16];
    struct GRid		pretend_obj;

    SetProc ( VDPhighlightZone ); Begin

    /* If the graphical object is a model view send a display message
       to the model view; else send a dp$display message to the 
       object */

    *msg = MSSUCC;
    gr_obj.objid = NULL_OBJID;
    status =
    _VD_SEND_OBJN( ZoneId, NDnode.NDget_objects(  ND_ROOT,
                                        &gr_obj,
                                        1,
                                        NULL,
                                        0,
                                        OM_K_MAXINT,
                                        &count ) );
    __CheckRC( status, 1, "message NDnode.NDget_objects", wrapup );

    __DBGpr_obj ( "Graphic Object", gr_obj );

    if ( gr_obj.objid == NULL_OBJID )
    {
	UI_status( "Associated Graphical Object is deleted" );
	goto wrapup;
    }

    om$get_classid (objid = gr_obj.objid,
		    osnum = gr_obj.osnum,
		    p_classid = &ClassId );

    if ( om$is_ancestry_valid
			( subclassid   = ClassId,
			  superclassid = OPP_VDmdlview_class_id )
	     == OM_S_SUCCESS )
    {
	status = _VD_SEND_OBJN(gr_obj,
			VDmdlview.VDmv_display_solid ( msg, &dpmode ));
	__CheckRC ( status, *msg, "VDmdlview.VDmv_display_solid", wrapup );
    }
    else if ( om$is_ancestry_valid
			( subclassid   = ClassId,
			  superclassid = OPP_ACpretend_class_id )
	     == OM_S_SUCCESS )
    {
	pretend_obj.objid = gr_obj.objid;
	pretend_obj.osnum = gr_obj.osnum;
	status =
	_VD_SEND_OBJN( pretend_obj, ACpretend.ACreturn_foot ( msg,
							 "",
							 &gr_obj,
							 &mat_type,
							 matrix ) );
	__CheckRC( status, 1, "message ACpretend.ACreturn_foot", wrapup );
	__DBGpr_com(" ACpretend object ");
	status = gr$display_object ( object_id = &gr_obj,
				  mode = dpmode );
	CheckRC( status, 1 );
    }
    else
    {
	status = gr$display_object ( object_id = &gr_obj,
				  mode = dpmode );
	CheckRC( status, 1 );
    }

wrapup:
    End
    return status;
}

end implementation VDPCmdZone;
