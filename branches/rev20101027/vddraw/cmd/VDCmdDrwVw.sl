/* $Id: VDCmdDrwVw.sl,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/cmd/VDCmdDrwVw.sl
 *
 * Description:
 *		By selection of one visualization object, the system
 *		return the owner object for processing.
 *		Implemented for VDdrw2dVw and VDdrw3dVw.
 *		The Item management will concidered.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDrwVw.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/11  11:27:54  pinnacle
# Replaced: vddraw/cmd/VDCmdDrwVw.sl for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1996/05/29  15:54:16  pinnacle
# Replaced: vddraw/cmd/VDCmdDrwVw.sl for:  by azuurhou for vds.240
#
# Revision 1.8  1996/03/27  20:57:26  pinnacle
# Replaced: vddraw/cmd/VDCmdDrwVw.sl for:  by v240_int for vds.240
#
# Revision 1.7  1995/09/29  19:49:44  pinnacle
# Replaced: ./vddraw/cmd/VDCmdDrwVw.sl for:  by azuurhou for vds.240
#
# Revision 1.6  1995/09/18  16:30:28  pinnacle
# Replaced: vddraw/cmd/VDCmdDrwVw.sl for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/07/29  14:58:28  pinnacle
# Replaced: vddraw/cmd/VDCmdDrwVw.sl for:  by azuurhou for vds.240
#
# Revision 1.4  1995/07/25  21:01:38  pinnacle
# Replaced: vddraw/cmd/VDCmdDrwVw.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:19:46  pinnacle
# Created: vddraw/cmd/VDCmdDrwVw.sl by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/24/95	adz		creation date
 *	03/26/96	adz		Permit locate reference files
 *	05/29/96	adz		Change the locate_rtree into loc_class.
 *	09/11/97	vini		Added the method to put drawing object 
 *					in queue. Permit to locate the objects 
 * 					by a fence,window, etc.
 * -------------------------------------------------------------------*/

command_string		VDC_M_GtDrwVolSt,0,VDPushDrw
class			VDCmdDrwVw
super_class		VDS_LOCATE
product_name		"$VDS"
command_table		"vds.cmd"

start_state		start

/*
 ****************************************************************************
 *	Specification Area
 ****************************************************************************
 */

specification

instance

{
}

/*
 ****************************************************************************
 *	Implementation Area
 ****************************************************************************
 */
implementation

#include <stdio.h>
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "griodef.h"
#include "grio.h"
#include "igr.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "VDmsg.h"
#include "vds.h"
#include "vddrwattr.h"
#include "vdsetmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"


from	VDSroot		import	VDgetObjDef;
from	GRvg		import	GRgetattr;


/*
 ****************************************************************************
 *	State Table Area
 ****************************************************************************
 */

state_table

#include    "VDmsg.h"

state start

	message_key	VD_M_GtDrwVolSt	
	prompt_key	VD_P_SlDrwVolSt
	locate_class	"+VDdrwObj,VDitem,VDdrawing"
	locate_owner   	"LC_RIGID_OWNER | LC_FLEX_OWNER |
			 LC_REF_OBJECTS |
			 LC_RIGID_COMP  | LC_FLEX_COMP |"

	mask		"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP |
			 GRm_SPECIFIED_OBJ "
 	filter		locate

	on EX_DATA or EX_STRING 

	    do VDPushObject

		on ERROR
		do status_key	VD_S_InvProcessing		state terminate	
								state terminate
	
	on EX_OBJID

	    do  VDPushObjectByFence

                on ERROR
                do status_key   VD_S_InvProcessing              state terminate
                                                                state terminate


/* ======================================================================== */

action VDPushDrwOnQueue
{
	IGRlong			msg;
	IGRlong			size;
	IGRint			response;
	IGRint			option = 0xFFFF ;
	struct GRid		setId, drwId, drwVwId ;
	struct GRmd_env		setEnv ;
	GRname			infoString ;
	VDobjDef		objDef ;
	VDpartAttr		attr ;

	SetProc( VDPushDrwOnQueue ); Begin

	status =
	dp$erase_hilite(	msg   = &msg,
				osnum = me->ModuleInfo.md_id.osnum);

        /*
         * find the control object and object type.
         */
	drwId = me->event1.located_object[0].located_obj;

        status =
        _VD_SEND_OBJ( drwId, VDSroot.VDgetObjDef( &msg, &objDef ));
        __CheckRC( status, msg, "VDSroot.VDgetObjDef", quit );

        drwVwId.objid = NULL_OBJID ;
        status = VDdrw_GetChannelOwner( &msg, &drwId, objDef.type, &drwVwId );
        __CheckRC( status, msg, "VDdrw_GetChannelOwner", quit );

        if( drwVwId.objid == NULL_OBJID ){
                me->ret = OM_E_ABORT;
                goto quit;
        }

        status =
        _VD_SEND_OBJ( drwVwId, VDSroot.VDgetObjDef( &msg, &objDef ));
        __CheckRC( status, msg, "VDSroot.VDgetObjDef", quit );

	attr.Iwant = VD_I_drwInternalName ;
	status =
	_VD_SEND_OBJ( drwVwId, GRvg.GRgetattr( &msg, (char *)&attr ));
	__CheckRC( status, msg, "GRvg.GRgetattr", quit );

	sprintf( infoString, "%s - [%s]", VDmsgkey2string( objDef.info ),
					  attr.aString );
	UI_status( infoString );

        status =
        VD_MakeGRsetOfObject(   &msg,
                                &me->ModuleInfo,
                                &drwVwId,
                                &me->event1.located_object[0].module_info,
                                &setId,
                                &setEnv,
                                option );

        status =
	vd$filter_objects(	msg	= &msg,
				setId	= &setId );
				
	/*
	 * Set event structure.
	 */
	me->event1.num_id			= 1;
 	me->event1.num_val			= 0;
	me->event1.response			= 0;
	me->event1.subtype			= GRst_LOCATE;
	me->event1.located_object[0].located_obj = setId;
	me->event1.located_object[0].module_info = setEnv;

	response = EX_OBJID;
 
	size = sizeof( struct GRevent );

	status =
	ex$putque(	msg      = &msg,
			response = &response,
     	 		byte     = &size,
     	 		buffer   = (IGRchar *)&me->event1.event );
	as$status();

	me->ret = OM_S_SUCCESS ;
	End ;
}

action VDPushDrwingOnQueue

{
        IGRlong         msg;
        IGRlong                 size;
        IGRint                  response;
        IGRint                  option = 0xFFFF ;
        struct GRid             setId, drwingId ;
        struct GRmd_env         setEnv ;

        SetProc( VDPushDrwingOnQueue ); Begin

        status =
        dp$erase_hilite(        msg   = &msg,
                                osnum = me->ModuleInfo.md_id.osnum);

        drwingId = me->event1.located_object[0].located_obj;

        status =
        VD_MakeGRsetOfObject(   &msg,
                                &me->ModuleInfo,
                                &drwingId,
                                &me->event1.located_object[0].module_info,
                                &setId,
                                &setEnv,
                                option );

        status =
        vd$filter_objects(      msg     = &msg,
                                setId   = &setId );

        me->event1.num_id                       = 1;
        me->event1.num_val                      = 0;
        me->event1.response                     = 0;
        me->event1.subtype                      = GRst_LOCATE;
        me->event1.located_object[0].located_obj = setId;
        me->event1.located_object[0].module_info = setEnv;

        response = EX_OBJID;

        size = sizeof( struct GRevent );

        status =
        ex$putque(      msg      = &msg,
                        response = &response,
                        byte     = &size,
                        buffer   = (IGRchar *)&me->event1.event );
        as$status();

        me->ret = OM_S_SUCCESS ;

        return OM_S_SUCCESS ;

        End ;

}

action VDPushObject		extern

action VDPushObjectByFence      extern

action VDPushItemOnQueue	extern


