/* $Id: VDCmdItmSti.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/cmd/VDCmdItmSti.I
 *
 * Description:
 *		By selecting a visualization/annotation object, the system
 *		returns the owner object for processing.
 *		Implemented for VDdrw2dVw, VDdrw3dVw and VDitem.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdItmSti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/11  11:28:44  pinnacle
# Replaced: vddraw/cmd/VDCmdItmSti.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/09/18  16:31:24  pinnacle
# Created: vddraw/cmd/VDCmdItmSti.I by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/15/95	HF		creation date
 *	09/11/97	vini		method to push the objects selected 
 * 					by the fence in a queue.
 * -------------------------------------------------------------------*/

class implementation VDCmdDrwVw;

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
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vdsetmacros.h"

from	GRgrset		import	GSobject_add;

from	VDSroot		import	VDgetObjDef;
from	GRvg		import	GRgetattr;

extern	GRclassid	OPP_GRgrset_class_id,
			OPP_VDdrwObj_class_id,
			OPP_VDitem_class_id,
			OPP_VDitemSet_class_id;
extern	GRclassid	OPP_VDdrawing_class_id;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDPushObject ( long * sts )
{
  int				 status = OM_S_SUCCESS;
  struct GRid			 Obj_Id;

  Obj_Id = me->event1.located_object[0].located_obj;

  if ( DMancestry_valid ( Obj_Id , OPP_VDdrwObj_class_id ) )
  {
    status =
    om$send (	msg	 = message VDCmdDrwVw.VDPushDrwOnQueue (sts),
		targetid = my_id );
  }
  else if ( DMancestry_valid ( Obj_Id , OPP_VDitem_class_id ) )
  {
    status =
    om$send (	msg	 = message VDCmdDrwVw.VDPushItemOnQueue (sts),
		targetid = my_id );
  }
  else if ( DMancestry_valid ( Obj_Id , OPP_VDdrawing_class_id ) )
  {
    status =
    om$send (   msg      = message VDCmdDrwVw.VDPushDrwingOnQueue (sts),
                targetid = my_id );
  }

  return OM_S_SUCCESS;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	/*
	 * Method to put the objects in a queue by selecting them using fence
	 */

method VDPushObjectByFence ( long * sts )
{

        int                     status = OM_S_SUCCESS;
        int                     nbIDDobj = 0;
        int                     i;
        struct GRobj_env        fence,
                                *IDDobj ;

        fence._grid     = me->event1.located_object[0].located_obj ;
        fence.mod_env   = me->event1.located_object[0].module_info ;

        vd_$process_fence(      msg             = &me->ret,
                                fence           = &fence,
                                classList       = me->locate_eligible,
                                p_count         = &nbIDDobj,
                                p_content       = &IDDobj,
                                response        = me->response,
                                response_data   = me->response_data ) ;
         if( *me->response != EX_DATA || !nbIDDobj ) {
                goto wrapup ; }

        for(i=0; i<nbIDDobj; i=i+1)
        {
        if ( DMancestry_valid ( IDDobj[i]._grid , OPP_VDdrwObj_class_id ) )
          {
            status =
            om$send (   msg      = message VDCmdDrwVw.VDPushDrwOnQueue (sts),
                targetid = my_id );
          }
        else if ( DMancestry_valid ( IDDobj[i]._grid  , OPP_VDitem_class_id ) )
          {
           status =
           om$send (   msg      = message VDCmdDrwVw.VDPushItemOnQueue (sts),
                                 targetid = my_id );
          }
        else if ( DMancestry_valid ( IDDobj[i]._grid , OPP_VDdrawing_class_id ))
          {
           status =
            om$send (   msg      = message VDCmdDrwVw.VDPushDrwingOnQueue (sts),
                targetid = my_id );
          }

        }

        wrapup:
          return OM_S_SUCCESS;
}

 
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDPushItemOnQueue ( long * sts )
{
  int				 status = OM_S_SUCCESS;

  IGRlong			 msg;
  IGRlong			 size;
  IGRint			 response;
  int				 NbSets = 0;
  struct GRid			 grSet, ItemId,
				*SetId = NULL;
  struct GRmd_env		 setEnv ;

  OM_S_CHANSELECT		 to_set;

  status =
  dp$erase_hilite (	msg	= &msg,
			osnum	= me->ModuleInfo.md_id.osnum);

  status = om$make_chanselect (	channame	= "VDitem.to_bomset",
				p_chanselect	= &to_set );
  as$status( action = GOTO_VALUE, value = quit );

  ItemId = me->event1.located_object[0].located_obj;

  /*
   * Find the ItemSet to which this Item is connected ...
   */

  status = VDGetGridsFromChan_of_Class ( &msg, ItemId, &to_set,
					OPP_VDitemSet_class_id, &NbSets, &SetId );

  if( SetId->objid == NULL_OBJID || NbSets != 1 )
  {
    me->ret = OM_E_ABORT;
    goto quit;
  }

  status =
  VD_MakeGRsetOfItemSet (	&msg,
				&me->ModuleInfo,
				 SetId,
				&me->event1.located_object[0].module_info,
				&grSet,
				&setEnv );
  /*
   * Set event structure.
   */
  me->event1.num_id			= 1;
  me->event1.num_val			= 0;
  me->event1.response			= 0;
  me->event1.subtype			= GRst_LOCATE;
  me->event1.located_object[0].located_obj = grSet;
  me->event1.located_object[0].module_info = setEnv;

  response = EX_OBJID;

  size = sizeof( struct GRevent );

  status =
  ex$putque(	msg	= &msg,
		response= &response,
		byte	= &size,
		buffer	= (IGRchar *)&me->event1.event );
  as$status();

  me->ret = OM_S_SUCCESS ;

quit:

  _FREE ( SetId );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VD_MakeGRsetOfItemSet
(
  long				*msg,
  struct	GRmd_env	*mdEnv,		/* Current ModuleInfo		*/
  struct	GRid		*elmId,		/* Input Object			*/
  struct	GRmd_env	*elmEnv,	/* Input Environment		*/
  struct	GRid		*grSet,		/* Set Output Object		*/
  struct	GRmd_env	*setEnv		/* Set Output Environment	*/
)
{
  /*
   * This function will check if object is an graphical set.
   * If not, the object and graphical set will be made and the
   * object will be added to this set as one component.
   */
  long			 status = OM_S_SUCCESS ;
  int			 i, NbItems = 0,
			 envProperties = 0 ;
  struct GRid		 svSet,
			*ItemIds = NULL ;
  OM_S_CHANSELECT	 to_items ;

  *msg = MSSUCC ;

  status = om$make_chanselect (	channame	= "VDitemSet.to_items",
				p_chanselect	= &to_items );
  as$status( action = GOTO_VALUE, value = wrapup );

  if( DMancestry_valid ( *elmId , OPP_GRgrset_class_id ) )
  {
    /*
     * Copy the object.
     */
    *grSet	= *elmId ;
    *setEnv	= *elmEnv ;
    goto wrapup ;
  }
  else
  {
    /*
     * Create a new GRgrset & GRsvset ...
     */
    status = LCgsinit( mdEnv, grSet, &svSet );
    if( !(status & 1 ))
    {
      /*
       * Return the input object.
       */
      *grSet  = *elmId ;
      *setEnv = *elmEnv ;
      goto wrapup ;
    }

    status = VDGetGridsFromChan_of_Class ( msg, *elmId, &to_items,
					OPP_VDitem_class_id, &NbItems, &ItemIds );

    /*
     * Add the ItemIds to the list.
     */
    for ( i=0; i < NbItems; i++ )
    {
      status =
      _VD_SEND_OBJN ( *grSet, GRgrset.GSobject_add(	msg,
							&ItemIds[i],
							elmEnv,
							&envProperties,
							NULL, NULL ));
      as$status();
    }
  }

  wrapup :

  _FREE ( ItemIds );

  return status ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDCmdDrwVw;
