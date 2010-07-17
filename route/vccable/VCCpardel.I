
/* $Id: VCCpardel.I,v 1.3 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCpardel.I
 *
 * Description:
 *
 *      Overridden method NDparent_deleted
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCpardel.I,v $
 *      Revision 1.3  2002/05/08 15:48:22  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.2  2001/02/20 01:09:00  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  19:57:34  pinnacle
# Replaced: vccable/VCCpardel.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/07/29  14:55:02  pinnacle
# Replaced: vccable/VCCpardel.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/06  22:55:16  pinnacle
# Replaced: vccable/VCCpardel.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:48:58  pinnacle
# Created: vccable/VCCpardel.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      07/08/96    hv          Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
*/
 
#include "exdef.h"
#include "nddef.h"
#include "godef.h"
#include "ndmacros.h"
#include "vrdbgmacros.h"

/**********************************************************************

   Doc: VCCable.NDparent_deleted

   Abstract: This message is sent whenever a parent is deleted. This
  is overriden so as to update the instance data and keep the
  VRMLink object alive.

   History:
  15 Oct 93  Manyam  Creation

   Return Status:
  OM_S_SUCCESS  success

***********************************************************************/

method NDparent_deleted(
         IGRlong    *msg;            /* I/O - return status  */
         IGRint      count_deleted;  /* I - num of deleted parents */
  struct GRid        list_deleted [];/* I - GRid list of parents(deleted)*/
  struct GRid       *new_obj;        /* O - newobject  */
  struct GRmd_env   *md_env          /* I - Module Env of the link  */
		       )
{
  IGRint        status;
  IGRint        i;
  IGRchar	NDstate;

  SetProc(VCCable_NDparent_deleted); Begin;

  status = OM_S_SUCCESS;
  __DBGpr_objlist("Parent getting deleted",count_deleted,list_deleted);

  /* See if simply checking for ND_DONT_MVRT flag and
   * calling superclass works or not. */

  /* It won't work. Commented as #if 0. See below why */

#if 0
  status = om$send( msg	     = message NDnode.NDget_state( &NDstate ),
		    targetid = my_id );

  if( NDstate & ND_DONT_MVRT )
  {
      status = om$send( msg  = message NDnode.NDparent_deleted( msg,
								count_deleted,
								list_deleted,
								new_obj,
								md_env ),
			mode = OM_e_wrt_message,
			targetid = my_id);
      as$status();

      End;
      return status;
  }

#endif

  /* If the above didn't work, go through parents-being-deleted list to be
   * doubly sure (Ah! Paranoia!). */

  /* It was good to be paranoid! What if the subcable is connected to a
   * terminal? It would still move to root. Can we have that? No way! */

  for (i=0; i< count_deleted; i++)
  {
      GRclassid		ClassId;
      extern GRclassid	OPP_VCCable_class_id;

      status = om$get_classid( objid	= list_deleted[i].objid,
			       osnum	= list_deleted[i].osnum,
			       p_classid= &ClassId );
      as$status();

      if( om$is_ancestry_valid( subclassid = ClassId,
				superclassid = OPP_VCCable_class_id )
							      == OM_S_SUCCESS )
      {
	  /* One of my parents who is getting deleted is a cable. Therefore,
	   * schedule myself to be deleted ! */

	  struct GRid 	mygrid;

	  mygrid.objid = my_id;
	  mygrid.osnum = OM_Gw_current_OS;

	  /* do the wait batch */
	  nd$wait_batch(	type       = GR_DELETED, 
				l_object   = &mygrid,
				nb_obj     = 1);

	  End;
	  return status;
      }
  }


  /*A Detach these parents */  

  for (i=0; i< count_deleted; i++)
  {
    status = 
    om$send( msg   = message VCCable.VCCbDetach (msg, &list_deleted[i]),
          targetid = my_id);
  }

  /*A and do default processing (if any)   */

/*   Apparently the NDnode.NDparent_deleted method is overzealous
     when the parent was already detached. It removes all parents
     in this case ---- so forget about this garbage, all's done
     that needs to be done ..........................................

  status =
  om$send( msg   = message NDnode.NDparent_deleted
                     (msg, count_deleted, list_deleted, new_obj, md_env),
           mode  = OM_e_wrt_message,
        targetid = my_id);
  as$status();
.........................................................................*/

End;
  return (status);
}

end implementation VCCable;
