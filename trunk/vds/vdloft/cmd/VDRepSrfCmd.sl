/* $Id: VDRepSrfCmd.sl,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdloft/cmd/VDRepSrfCmd.sl
 *
 * Description:    Command to repair surfaces whose poles are too close
 *
 *                 This command looks at the surface in the u direction
 *                 and then in the v direction to see whether the poles
 *                 are closer than a CHT.  Should this be the case a new
 *                 surface is created with the offending poles spread
 *                 out beyond CHT.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDRepSrfCmd.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/01/29  20:10:42  pinnacle
# TR_179702387: converted file from Loft to VDS
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/

command_string	VDC_M_RepSurf, 0, VDRepSrf
command_table	"vds.cmd"
class		VDRepSrfCmd
super_class	VDS_LOCATE 
product_name	"$VDS"
options         "siTC"

start_state	GETSURF

specification

instance {

/*c	Same as superclass + **/

  short	NewLevel ;

}

implementation

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "vsplatedef.h"
#include "bsparameters.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "EMSssprops.h"
#include "VDmsg.h"

	//local defines for default type and value of edge attributes

#define		TYPE	"R"
#define		VALUE	"0"


/********************** start DEBUGGING*********************************

#define vsDEBUG         1
#define vserrDEBUG      1

********************** end DEBUGGING*********************************/

#include "vsdbgmacros.h"

/*c	External Functions ****/
/*c defined in include files */

/*c  External Methods ****/

from  NDmacro		import	ACreturn_foot;
from  NDnode		import	ASreturn_go;

/*c	Extern variables ***/

/*c	threexternal vars.. ***/
extern GRclassid	OPP_EMSsubbs_class_id,
                        OPP_VDplate_class_id,
                        OPP_NDnode_class_id;

/*c	Define the state transitions... *****/

state_table

#include	"VDmsg.h"
#include	"OMerrordef.h"



state GETSURF
	message			"Repair Surface"
	prompt_key		VD_P_SurfPlate
	accept_key		VD_M_SurfPlate
	locate_eligible		"+EMSsubbs"
	locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER |
				 LC_FLEX_COMP  | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	filter			locate

	on EX_OBJID or EX_DATA	do VDstoreLocate( &me->ret )
				do VDstoreResponse( &me->ret )
				do VDstoreList( &me->ret, 1, 1)
				do VDProcessSrfs( &me->ret )
				on RETURN_CODE = OM_S_SUCCESS
				   do status "Surface repaired"
				   state .
				state .


at delete do status ""

/*c  That's all folks, now the actions (methods) ****/

action RepairSurface( struct GRobj_env * TheSurf ) extern 

action VDProcessSrfs( IGRlong * ret )
{
 struct GRid
			 base_surf;		//the surf for the edge attribs

 struct GRobj_env	SurfObj;

 IGRint			
			current_obj;		//current obj being processed

 IGRlong		l_msg;	  // require int return, long for method!*/

 IGRchar		*	name = NULL;

 OMuword                TEMP_cl;		//classid of current object

 status	=	OM_E_INVARG;  // message return codes*/
 if ( !ret ) goto wrapup;			//no argument, so leave

 *ret		= VD_S_SUCCESS;
 
 for ( current_obj=0;current_obj<me->Cnt1;++current_obj ){
     SurfObj = me->Lst1[current_obj];
     base_surf = SurfObj.obj_id; 

    __DBGpr_int( "Locate returned objects",  me->Cnt1);
    __DBGpr_obj( "got object",  base_surf );


                // retrieve the support surface of the plate

     om$get_classid( osnum           = SurfObj._osnum  ,
                     objid           = SurfObj._objid  ,
                     p_classid       = &TEMP_cl      ) ;

   if( om$is_ancestry_valid( superclassid = OPP_NDnode_class_id,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

        __DBGpr_obj( "got reference object before ret_go",SurfObj.obj_id );

        status = om$send( msg  = message NDnode.ASreturn_go(
                                        &base_surf,
                                        &SurfObj._matrix_type,
                                         SurfObj._matrix ),
                        senderid = NULL_OBJID,
                        targetid = SurfObj._objid,
                        targetos = SurfObj._osnum );

        __CheckRC( status, 1, "PlEd:return_go", next_object );

        status = om$get_classid( osnum   = base_surf.osnum  ,
                                 objid   = base_surf.objid  ,
                                 p_classid       = &TEMP_cl      ) ;
        __CheckRC( status, 1, "PlEd:get_classid", next_object );

    }  // end if its a reference object

     if( om$is_ancestry_valid( superclassid  = OPP_EMSsubbs_class_id,
                               subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

                __DBGpr_com("its a surface!");
		SurfObj.obj_id = base_surf;
     }

     else{
                __DBGpr_com("not an EMSsubbs!");
		SurfObj.obj_id.objid = NULL_OBJID ;
     }


		// so, fix it.

     status = om$send( msg	= message VDRepSrfCmd.RepairSurface( &SurfObj ),
                       targetid = my_id );

     __CheckRC( status, 1, "Repair cmd:Repair Surface", next_object );


next_object:		////////////////// GOTO

	status = OM_S_SUCCESS;

 } //c end for on located objects


 if ( status&1 )	goto quit ;	// keep compiler quiet


wrapup:			////////////// cleanup GOTO

    return ( status );
    
} /*c end method Repair Surface*/

/*******++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*******/

/********************	end of command object 			***************/
