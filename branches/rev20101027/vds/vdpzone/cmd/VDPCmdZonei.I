/* ----------------------------------------------------------------------------
 * I/VDS
 *
 * File :       vds/vdpzone/cmd/VDPCmdZonei.I
 *
 * Description:
 *      Implementation of the following methods.
 *              my_init
 *		VDPSelectZones
 *
 * Dependencies:
 *
 * History:
 *
 *      12/19/95        MSM             Creation
 *	9/19/96		msm		Command not executed if PME not enabled.
 *	10/03/96	msm		Command displays an error box if
 *					file is revised or frozen.
 *	10/22/96	msm		Error processing for VDPGetFileState
 *
 *      Feb 16 '98      SSR             Fix TR # 179800480
 *      Feb 16 '98      SSR             Fix TR # 179800480
  --------------------------------------------------------------------------*/

class implementation VDPCmdZone;

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
#include "dpdef.h"
#include "dpmacros.h"
#include "griomacros.h"
#include "execmsg.h"

#include "vdsmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"
#include "VDPdef.h"
#include "VDPdm2.h"
#include "VDPzone.h"
#include "VDPZnFrmDf.h"

#include "FI.h"

%safe
#include "VX_FIproto.h"
%endsafe


from VDPZnMgr import    VDPgetZoneList;
from GRgraphics import  GRdisplay;

/*+me
------------------------------------------------------------------------------
  Public Message my_init

  Abstract
	This method initialises the instance of the command object.

  Arguments
	IGRlong		*sts		0	Return Code

  Notes/Remarks

  Status/Return Code

	status == OM_S_SUCCESS
------------------------------------------------------------------------------
-me*/

method my_init ( long *sts )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i;
    struct VDPPlCtxTST  *TypST=NULL;
    IGRint		nbTST=0, nbZoneST=0;
    IGRlong		msg;
    OMuword     curOs;
    IGRint      fileState=0;
    IGRchar     errmsg[256];

    SetProc( VDPCmdZone.my_init ); Begin

    *sts = VD_SUCCESS;

    me->window_id.objid = NULL_OBJID;

    if( IsPmeEnabled() == FALSE )
    {
	UI_status("PME server connection required");
	*sts = VD_ERROR;
	me->state = _terminate;
	return status;
    }

    ex$get_cur_mod( osnum = &curOs );

    status = VDPGetFileState( &msg, curOs, &fileState );
    if ( !(status & 1))
    {
        *sts = VD_ERROR;
	me->state = _terminate;
	goto wrapup;
    }
    if( fileState == VDP_FILE_REVISED )
    {
        strcpy(errmsg,"The current design file is revised in PME. It should also be revised in PDU. ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
        *sts = VD_ERROR;
        me->state = _terminate;
	return status;
    }
    else if( fileState == VDP_FILE_FROZEN )
    {
        strcpy(errmsg,"The current design file is frozen in PME. It should be revised before further executing PME commands ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
        *sts = VD_ERROR;
        me->state = _terminate;
	return status;
    }

    /* Query the directory subsystem for all the Zones */
    status = _VD_SEND_MY( VDPCmdZone.VDPSelectZones( sts ));
    if (( !status & 1) || *sts == VD_RESTART_CMD )
    {
	UI_status( "Error encountered: command terminated" );
	me->state = _terminate;
	goto wrapup;
    }

    __DBGpr_int( "Number of Placed Zones", me->nbPlacedZones );

    if( !me->nbPlacedZones )
    {
     	UI_status( "No Zones have been defined in this file");
        // SSR TR # 179800480
    }

    /* Initialise the main form with all the Zones that belong to this file */
    FIfld_set_num_rows( VD_FP0, G_MCF, me->nbPlacedZones );
    for( i = 0; i < me->nbPlacedZones; i++ )
    {
	FIfld_set_text( VD_FP0, G_MCF, i, 0, me->zones[i].ZoneCtx.Name, FALSE );
	FIfld_set_text( VD_FP0, G_MCF, i, 1, me->zones[i].ZoneCtx.SubTypeDesc, FALSE );
	FIfld_set_text( VD_FP0, G_MCF, i, 2, me->zones[i].ZoneCtx.CtxDesc, FALSE );
    }

    /* Disable Modify & Delete buttons */
    FIg_disable ( VD_FP0, G_MODIFY_BTN );
    FIg_disable ( VD_FP0, G_DELETE_BTN );

    __DBGpr_com(" Initialised Main form " );

    /* Query all the Types and SubTypes and save in command's instance */

    status = VDPgetCtxTypeSubTypes( &msg, &nbTST, &TypST ); 
    __DBGpr_int("Number of Type SubType :", nbTST );

    status = om$vla_set_dimension( varray = me->CtxTST,
				   size   = nbTST );
    for ( i =0; i < nbTST; i++ )
	if( TypST[i].Type == 'Z' ) 
	{
	  /*  printf( "Index = %d, type = %c\n", i, TypST[i].Type ); */
/*
	    memcpy( &me->CtxTST[nbZoneST++], &TypST[i], sizeof (struct VDPPlCtxTST) );
*/
	    me->CtxTST[nbZoneST].Type = TypST[i].Type;
	    me->CtxTST[nbZoneST].SubType = TypST[i].SubType;
	    strcpy(me->CtxTST[nbZoneST].SubTypeDesc, TypST[i].SubTypeDesc );
	    strcpy(me->CtxTST[nbZoneST++].ClassName, TypST[i].ClassName );
	}

    status = om$vla_set_dimension( varray = me->CtxTST,
				   size   = nbZoneST );
    CheckRC( status, 1 ); 

    FIfld_set_num_rows( VD_FP1, G_ZONE_SUBTYPE, nbZoneST );
    for(i = 0; i < nbZoneST; i++ )
    {
	FIfld_set_list_text( VD_FP1, G_ZONE_SUBTYPE, i, 0, me->CtxTST[i].SubTypeDesc, FALSE );
	__DBGpr_str( "Description ", me->CtxTST[i].SubTypeDesc );
	__DBGpr_str( " Class Name ", me->CtxTST[i].ClassName );
    }

    FIf_display( VD_FP0 );
wrapup :
    _FREE( TypST );

    End
    return OM_S_SUCCESS;
}

/*+me
-----------------------------------------------------------------------------
    Public Message VDPSelectZones

    Abstract
	This method selects all the zones contained in the design file.

    Arguments
	IGRlong		*sts		0	Return Code

    Notes/Remarks

    Status/Return Code

	*sts   = VD_SUCCESS
	status = OM_S_SUCCESS
-----------------------------------------------------------------------------
-me*/
method VDPSelectZones ( long	*sts )
{
    IGRint		i, ind, nbZones = 0;
    IGRlong		status = OM_S_SUCCESS;
    IGRlong		msg;
    struct GRid		ZoneListId;
    struct VDPzone	*ZoneObjs=NULL;

    SetProc ( VDPCmdZone.VDPSelectZones); Begin
    *sts = VD_SUCCESS;

    /* Get the List of Zones Objects */
    status = VDPGetZoneListId( &msg, &ZoneListId );
    __CheckRC ( status, msg, "VDPGetZoneListId", wrapup );

    __DBGpr_obj("Zone List ", ZoneListId );

    /* Set the command's instance with the Zone's instance */
    status = _VD_SEND_OBJ( ZoneListId, VDPZnMgr.VDPgetZoneList ( 
						&msg, 
						&nbZones,
						&ZoneObjs ));
    __CheckRC( status, msg, "VDPZnMgr.VDPgetZoneList", wrapup );

    __DBGpr_int ( "Number of Zones ", nbZones );

    /* Set the instance data with the zones */
    status = om$vla_set_dimension (varray = me->zones, size = nbZones );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    me->nbPlacedZones=0;
    for( i = 0 ; i < nbZones ; i++ )
    {
	if( ZoneObjs[i].ZoneId.objid != NULL_OBJID )
	{
    	    memcpy ( &me->zones[me->nbPlacedZones], &ZoneObjs[i], sizeof( struct VDPzone));

	    me->nbPlacedZones++;
	}
    }
    __DBGpr_int( "Number of Placed Zones ", me->nbPlacedZones );

    ind = me->nbPlacedZones;
    for( i = 0 ; i < nbZones ; i++ )
	if( ZoneObjs[i].ZoneId.objid == NULL_OBJID )
    	    memcpy ( &me->zones[ind++], &ZoneObjs[i], sizeof( struct VDPzone));


wrapup:

    _FREE( ZoneObjs );
    End
    return OM_S_SUCCESS;
}

method VDPqueryClass( long *msg; IGRchar *ZoneClass )
{
    IGRint                      nbCtx=0;
    IGRlong                     status = OM_S_SUCCESS;
    struct  VDPNameDesc         *Contexts;

    SetProc( VDPCmdZone.VDPqueryClass ); Begin

    *msg = MSSUCC;
    __DBGpr_str( "Querying on Class name", ZoneClass );

    /* For now it is placement contexts but later it should be zones */

    status = VDPgetZoneContexts( msg, ZoneClass, &nbCtx, &Contexts );
    __CheckRC ( status, *msg, "VDPgetContexts", wrapup );

    __DBGpr_int("Number of contexts :", nbCtx );

    status = om$vla_set_dimension( varray = me->ZoneNameDesc,
                                  size    = nbCtx );
    CheckRC( status, 1 );

    memcpy ( me->ZoneNameDesc, Contexts, nbCtx * sizeof (struct VDPNameDesc) );

wrapup :
    _FREE(Contexts);

    End
    return OM_S_SUCCESS;
}

method update ( long *sts )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i;

    SetProc( VDPCmdZone.update ); Begin

    *sts = VD_SUCCESS;

    /* Query the directory subsystem for all the Zones */
    status = _VD_SEND_MY( VDPCmdZone.VDPSelectZones( sts ));
    if (( !status & 1) || *sts == VD_RESTART_CMD )
    {
	UI_status( "Error encountered: command terminated" );
	me->state = _terminate;
	goto wrapup;
    }

    __DBGpr_int( "Number of Placed Zones", me->nbPlacedZones );

    if( !me->nbPlacedZones )
    {
	UI_status( "No Zones exist");
	/*goto wrapup; */
    }

    /* Initialise the main form with all the Zones that belong to this file */
    FIfld_set_num_rows( VD_FP0, G_MCF, me->nbPlacedZones );
    for( i = 0; i < me->nbPlacedZones; i++ )
    {
	FIfld_set_text( VD_FP0, G_MCF, i, 0, me->zones[i].ZoneCtx.Name, FALSE );
	FIfld_set_text( VD_FP0, G_MCF, i, 1, me->zones[i].ZoneCtx.SubTypeDesc, FALSE );
	FIfld_set_text( VD_FP0, G_MCF, i, 2, me->zones[i].ZoneCtx.CtxDesc, FALSE );
    }

wrapup:
    End
    return OM_S_SUCCESS;
}

method store_solid ( long	*sts )
{
    IGRlong		msg, status = OM_S_SUCCESS;
    enum GRdpmode	dpmode;

    SetProc( VDPCmdZone.store_solid ); Begin
    *sts = VD_SUCCESS;

    me->gr_objenv.obj_id.objid  = me->event1.located_object[0].located_obj.objid;
    me->gr_objenv.obj_id.osnum  = me->event1.located_object[0].located_obj.osnum;
    me->gr_objenv.mod_env       = me->event1.located_object[0].module_info;


    dpmode = GRbdhe;
    status = om$send ( msg = message GRgraphics.GRdisplay (
                                        &msg,
                                        &me->gr_objenv.mod_env.md_env.matrix_type,
                                        me->gr_objenv.mod_env.md_env.matrix,
                                        &dpmode,
                                        &me->ModuleInfo.md_id ),
                        targetid = me->gr_objenv.obj_id.objid,
                        targetos = me->gr_objenv.obj_id.osnum );

    __CheckRC ( status, msg, "GRgraphics.GRdisplay", wrapup );


wrapup:

    End
    return OM_S_SUCCESS;
}

end implementation VDPCmdZone;
