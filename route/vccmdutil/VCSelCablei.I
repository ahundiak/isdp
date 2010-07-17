
/* $Id: VCSelCablei.I,v 1.3 2001/02/20 01:10:26 build Exp $  */

/*************************************************************************
 * I/ROUTe
 *
 * File:  vccmdutil/VCSelCablei.I
 *
 * Description:
 *      Implementation file for pocket menu command to select the cables
 *		connected/attached to the Guide/Termianl/Point
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCSelCablei.I,v $
 *  Revision 1.3  2001/02/20 01:10:26  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/11 20:34:06  anand
 *  SP merge
 *
# Revision 1.1  2000/04/10  20:51:14  pinnacle
# Created: route/vccmdutil/VCSelCablei.I by apazhani for Service Pack
#
# Revision 1.1  2000/04/07  20:06:14  pinnacle
# Added for SPX
#
# Revision 1.1  2000/03/10  23:09:30  pinnacle
# Added for CR179800048
#
 *
 * History:
 *  03/09/2000    Alwin		Creation   
 *  04/07/2000    Alwin		Added me->state=_terminate to stop command exec.   
 *
 *************************************************************************/

class implementation VCSelCable;

#include <stdio.h>
#include "nddef.h"
#include "ndmacros.h"
#include "exmacros.h"
#include "AS_status.h"

#include "asbox.h"
#include "VDmem.h"
#include "coparamac.h"
#include "VCCmdDef.h"

#include <math.h>
#include "vrdbgmacros.h"
#include "VCdefine.h"

from  NDnode        import  NDget_objects;
from  GRgrset       import  GSobject_add, GSadd;
from  GRsvset       import  GSsvinit;

extern	GRclassid	OPP_VCGuide_class_id;
extern	GRclassid	OPP_VCTerm_class_id;
extern	GRclassid	OPP_VCCable_class_id;
extern	GRclassid	OPP_GRpoint_class_id;
extern	GRclassid	OPP_GRsvset_class_id;

method VCinit( long *sts )
{
  SetProc( Md VCinit ); Begin 

  __DBGpr_int( " Any command running ", ex$is_cmd_stack_empty() );

  *sts = me->ret = VC_RTC_ALLOK;

  if( ex$is_cmd_stack_empty() )
  {
	UI_status( "Invoke this from within a Command !!! " );
    *sts = VC_ERROR;
	me->ret = VC_ERROR;
	me->state = _terminate; // to terminate the command
	__DBGpr_com( " You can't run this command stand alone " );
    End
    return OM_S_SUCCESS;
  }
  End
  return OM_S_SUCCESS;
}

#include "grgsmacros.h"
#include "grdpbmacros.h"
#include "GMerrordef.h"

/* ----------------------------------------------
 *  Create a graphic set which contains a saveset
 *  O: *grset_id, graphic set id
 *  O: mod_info, object space id plus transformation matrix
 */

/* The function has been copied from $VDS/vdpocket/cmd */
IGRlong VCCreateGRgrset(struct GRobj_env *grsetOE)
{
  IGRlong retFlag = 0;
  IGRlong sts = MSSUCC;
  IGRlong msg = OM_S_SUCCESS;

  SetProc(VCCreateGRgrset); Begin

  gr$get_module_env(buffer = &grsetOE->mod_env);

  grsetOE->obj_id.osnum = grsetOE->mod_env.md_id.osnum;

  /* Construct save set, defines module environment */
  sts = gr$gsinit(
    msg       = &msg,
    senderid  = NULL_OBJID,
    flag      = 2,
    p_objid   = &grsetOE->obj_id.objid,
    osnum     =  grsetOE->obj_id.osnum
  );

  if( !(sts & 1) ){
    om$report_error( sts = sts );
    goto wrapup;
  }
  __DBGpr_int("graphics set id", grsetOE->obj_id.objid);

  /* Performs any needed clipping */
  sts = gr$gspost_processing(
    msg = &msg,
    senderid  = NULL_OBJID,
    object_id = &grsetOE->obj_id
  );

  if( !( sts & 1 )){
    om$report_error( sts = sts );
    goto wrapup;
  }

  /* Define current select set */
  sts = gr$gsput_select_set(
    msg           = &msg,
    mod_env       = &grsetOE->mod_env,
    select_set_id = &grsetOE->obj_id
  );

  if( !( sts & 1 )){
    om$report_error(sts = sts);
    goto wrapup;
  }

  retFlag = 1;


  wrapup:

  End

  return retFlag;

} /* VCCreateGRgrset */

method VCGetCables ( long *sts )
{
  IGRlong  			status, i;
  IGRlong 			retmsg;
  GRclassid			parentClassId;
  struct GRid		CompId;

  SetProc( Md VCGetCables ); Begin

  *sts = VC_RTC_ALLOK;

  CompId = me->event1.located_object[0].located_obj;

  if( CompId.objid == NULL_OBJID )
  {
     UI_status( "Component Location Error :-( " );
	 *sts = OM_E_ABORT;
     End
     return ( OM_S_SUCCESS );
  }

  __DBGpr_obj( " Located ObjectId ", CompId );
  om$get_classid (objid = CompId.objid,
                  osnum = CompId.osnum,
              p_classid = &parentClassId );

  if( ( om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VCGuide_class_id )
                                      == OM_S_SUCCESS ) || 
      ( om$is_ancestry_valid( subclassid = parentClassId,
						   		superclassid = OPP_VCTerm_class_id )
									   == OM_S_SUCCESS ) ||
      ( om$is_ancestry_valid( subclassid = parentClassId,
						   		superclassid = OPP_GRpoint_class_id )
									   == OM_S_SUCCESS ) 
	)
  {
	IGRint              response;
	IGRlong             size;
	struct  GRevent     event;
	IGRint				nCount=0;
	struct GRid  		*buffer;
	struct GRobj_env	grsetOE;
	struct GRid			svset_obj;

	 /* From the Guide/Terminal object, get all the cables object connected */
    status =
    om$send (msg = message NDnode.NDget_objects
                                ( ND_CHILDREN | ND_IN_BUF, NULL, 0,
                                 &buffer, 0, OM_K_MAXINT, &nCount ),
				targetid = CompId.objid,
				targetos = CompId.osnum);
	as$status();

	if( nCount > 0 )
	{
		IGRint 				env_prop, exception_type;
		struct GRmd_env 	loc_env;
		struct GRid			grset_obj;
		OM_S_CHANSELECT 	from_svset; 
		OM_S_CHANSELECT 	to_grset;

		//Create a GRgrset to store the Cables and send that as output to
		//que to the calling command

		status = VCCreateGRgrset( &grsetOE );

		grset_obj = grsetOE.obj_id;
		__DBGpr_obj( " Graphics set ", grset_obj );

		for( i=0; i<nCount; i++ )
		{
			GRclassid		ChildClassId;
			IGRint  		env_prop;

			__DBGpr_obj( " Child ObjectId ", buffer[i] );
			om$get_classid (objid = buffer[i].objid,
							osnum = buffer[i].osnum,
						p_classid = &ChildClassId );

			if( om$is_ancestry_valid( subclassid = ChildClassId,
									  superclassid = OPP_VCCable_class_id )
												== OM_S_SUCCESS ) 
			{
				__DBGpr_obj( " Cable Object Id ", buffer[i] );

				env_prop = 0;
				status = om$send( msg = message GRgrset.GSobject_add( &retmsg, 
									&buffer[i], &grsetOE.mod_env,
									 &env_prop, NULL,NULL),
						targetid = grsetOE.obj_id.objid,
						targetos = grsetOE.obj_id.osnum );
				as$status();
			}
		}

		event.num_id = 1;
		event.num_val = 0;
		event.response = EX_DATA;
		event.subtype = GRst_LOCATE;
		event.located_object[0].located_obj = grsetOE.obj_id;
		event.located_object[0].module_info = grsetOE.mod_env;

		size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

		/*
		 * Put EX_OBJID event on front of software queue
		 */
		response = EX_OBJID;
		ex$putque(      msg = sts,
						response = &response,
						byte     = &size,
						buffer   = (IGRchar *)&event.event.button );
	}
  } 

  End
  return (OM_S_SUCCESS);
}

end implementation VCSelCable;
