/* $Id: VDRepSrfCmdi.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdloft/cmd/VDRepSrfCmdi.I
 *
 * Description: Checks ancestry of surface object and calls repair method.
 *
 *		Added VLstoreList, VLstoreResponse and VLstoreLocate from
 *		VLlocateCmdi.I and renamed to VD.
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDRepSrfCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/01/29  20:11:14  pinnacle
# TR_179702387: converted file from Loft to VDS
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/


class implementation VDRepSrfCmd;



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
#include "bsparameters.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "EMSssprops.h"
#include "VDmsg.h"

	//local defines for default type and value of edge attributes

#define		TYPE	"R"
#define		VALUE	"0"


/********************** start DEBUGGING*********************************

#define vdsDEBUG         1
#define vdserrDEBUG      1

********************** end DEBUGGING*********************************/

#include "v_dbgmacros.h"

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


#define _GETSURF 0


method VDProcessSrfs ( IGRlong * ret )
{
  int		  status = OM_S_SUCCESS;

 struct GRid
			 base_surf;		//the surf for the edge attribs

 struct GRobj_env	SurfObj;

 IGRint			
			current_obj;		//current obj being processed

 OMuword                TEMP_cl;		//classid of current object

 status	=	OM_E_INVARG;  // message return codes*/
 if ( !ret ) goto wrapup;			//no argument, so leave

 *ret		= VD_S_SUCCESS;
 
 for ( current_obj=0;current_obj<me->Cnt1;++current_obj ){
     SurfObj = me->Lst1[current_obj];
     base_surf = SurfObj.obj_id; 

    __DBGpr_int( "Locate returned objects",  me->Cnt1);
    __DBGpr_obj( "got object",  base_surf );


                // retrieve the support surface

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
    
quit:
  return OM_S_SUCCESS;
}


method VDstoreList ( IGRlong * sts ; IGRint make_indx ; IGRint flag )
{

		IGRint		count, size=sizeof(struct GRobj_env);
	struct	GRobj_env	*list;
		IGRint		i;
	struct	GRid		Source;

	/* Initialize */
        *sts    = OM_S_SUCCESS;
	list = NULL;

	/* Build located objects list */
	switch (me->Response) {

		case EX_DATA :
			count   = 1;
			list    = (struct GRobj_env *) om$malloc (size = size);
			list[0] = me->Loc_env;
			break;

		case EX_OBJID :
			vd_$process_fence (
					   msg		 = sts,
			   		   fence	 = &me->Loc_env,
			   		   classList     = me->locate_eligible,
			   		   p_count	 = &count,
			   		   p_content	 = &list,
			   		   response      = me->response,
			   		   response_data = me->response_data );
			break;

		default :
			printf( "Unknown response <%d>\n", me->Response);
			goto quit;
	}

	/* Make objects sources (if wanted) */
	if (make_indx) {
		for ( i=0; i<count; i++) {
			as$make_source ( go_grid = list[i].obj_id,
					 mod_env = &list[i].mod_env,
					 as_os   = me->Current.md_id.osnum,
					 as_grid = &Source );
			list[i].obj_id  = Source;
			list[i].mod_env = me->Current;
		}
	}

	/* Allocate memory and load data in instance arrays */
	if (count > 0) {
		switch (flag) {
			case 1:
				me->Cnt1 = count;
				me->Lst1 = (struct GRobj_env *) om$malloc
					   (size = (me->Cnt1)*size);
				for (i=0;i<me->Cnt1;i++) me->Lst1[i] = list[i];
				break;
			case 2:
				me->Cnt2 = count;
				me->Lst2 = (struct GRobj_env *) om$malloc
					   (size = (me->Cnt2)*size);
				for (i=0;i<me->Cnt2;i++) me->Lst2[i] = list[i];
				break;
			case 3:
				me->Cnt3 = count;
				me->Lst3 = (struct GRobj_env *) om$malloc
					   (size = (me->Cnt3)*size);
				for (i=0;i<me->Cnt3;i++) me->Lst3[i] = list[i];
				break;
			default:
				printf ("False value %d\n", flag);
				*sts = MSFAIL;
		}
	}

quit:
	if (list)	{ om$dealloc (ptr = list); list = NULL; }

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */
method VDstoreResponse ( long * sts )
{

	me->Response = me->event1.response;
        *sts = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VDstoreLocate ( long * sts )
{
        me->VDwindow.osnum    = me->event1.event.button.osnum;
        me->VDwindow.objid    = me->event1.event.button.objid;
        me->AcceptPoint[0]  = me->event1.event.button.x;
        me->AcceptPoint[1]  = me->event1.event.button.y;
        me->AcceptPoint[2]  = me->event1.event.button.z;
        me->Loc_env.obj_id  = me->event1.located_object[0].located_obj;
        me->Loc_env.mod_env = me->event1.located_object[0].module_info;
        *sts = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}

end implementation VDRepSrfCmd;
