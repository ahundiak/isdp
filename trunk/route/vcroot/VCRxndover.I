/* $Id: VCRxndover.I,v 1.3 2001/02/20 01:11:26 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcroot / VCRxndover.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCRxndover.I,v $
 *  Revision 1.3  2001/02/20 01:11:26  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/11 22:17:16  anand
 *  SP merge
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *  Initial import to CVS
 *
# Revision 1.1  2000/05/04  23:10:22  pinnacle
# Created: route/vcroot/VCRxndover.I by aharihar for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.8  1997/08/15  12:41:08  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.7  1997/08/12  21:51:58  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/14  21:58:16  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/22  15:00:14  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/19  13:05:58  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.3  1997/04/28  21:47:58  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/19  15:53:54  pinnacle
# Replaced: vcroot/VCRxndover.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:14:30  pinnacle
# Created: vcroot/VCRxndover.I by hverstee for cabling
#
 *
 * History:
 *  MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *  06/07/96    hv	Initial
 *  May 4 2k	Anand	TR 179901314 - Update of cable elements do not update
 *  			symbology.
 *
 *************************************************************************/

class implementation VCRoot;

#include "grmacros.h"
#include "vrdbgmacros.h"

extern IGRboolean   dynamics_in_progress;

/*
#define MY_DEBUG  1
*/


method NDget_objects (int    type;
               struct GRid  *list;
                      int    size;
               struct GRid **buffer;
                      int    ifrom;
                      int    ito;
                      int   *count)
{
  IGRint      status;

  if ((type & ND_CHILDREN) && (dynamics_in_progress))
  { /*   No children while in dynamics     */
    *count = 0;
    status = OM_S_SUCCESS;
  }
  else
  { /* Normal behaviour */
    status =
    om$send ( msg = message VDSroot.NDget_objects
                                ( type, list, size, buffer, ifrom, ito, count ),
             mode = OM_e_wrt_message,
         targetid = my_id );
  }

  return status;
}/* end NDget_objects */



method NDupdate(int      *msg;
                int       cn_type;
                int       count;
         struct GRid     *parents;
                int      *parent_state;
         struct GRid     *context;
         struct GRid     *new_objid;
         struct GRmd_env *md_env)
{
  IGRint   status;
  struct GRid MyGrId;

  SetProc( VCRoot_NDupdate ); Begin

#ifdef XFORM_SETTER
  { /*     @@@@@     TBD    @@@@@  recheck this     */
    /*     cf ROUTE, xform only update, if we ever need this, avoid
           recompute when only attributes changed                     */

    IGRint   i;

    status =
    om$send (msg = message VCRoot.VCSetStatus (VC_XFORM_ONLY, ~VC_XFORM_ONLY),
        targetid = my_id);

    /* -- Check whether parents attributes have changed -- */

    for (i=0; i<me->nVCAttr && !bVC_IS_PID(me->xform_chan) ; i++)
    {
      if (parent_state[i] != ND_COMP_SAME )
      {
        status =
        om$send (msg = message VCRoot.VCSetStatus(VC_XFORM_ONLY,VC_XFORM_ONLY),
            targetid = my_id);

        break;
      }
    }/* end loop on parent_state */
  }
#endif

  /* -- Go back to normal process -- */

  status =
  om$send (msg = message VDSroot.NDupdate
                             ( msg, cn_type, count, parents, parent_state,
                               context, new_objid, md_env ),
      targetid = my_id,
      mode     = OM_e_wrt_message );

  /* Below lines added by Anand for TR 179901314 */
  MyGrId.objid = my_id;
  MyGrId.osnum = OM_Gw_current_OS;

  /* First erase the old graphics */
  gr$display_object ( object_id = &MyGrId, md_env = md_env, mode = GRbe );

  /* Request Symbology update */
  status =
  om$send (msg = message VCRoot.VDputAttrDrivenSymb ( (IGRlong *) msg, 
						      md_env, NULL ),
      targetid = my_id );

  /* Finally redraw new graphics */
  gr$display_object ( object_id = &MyGrId, md_env = md_env, mode = GRbd );

  End
  /* Above lines added by Anand for TR 179901314 */
  return status;

}/* end of NDupdate */

method NDdelete(struct GRmd_env *md_env)
{
  IGRint                  status;
  struct GRid             my_grid;

  if( !IF_NULL_OBJID(md_env->md_id.objid) )
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    /*    Update tag number mgt if necessary */

    status =
    om$send (msg = message NDnode.NDnotify_disconnect(my_grid),
    p_chanselect = &ND_father);

    status =
    om$send (msg = message Root.wild_disconnect(ND_father),
        targetid = my_id);
    as$status(action = RET_STATUS);
  }

#ifdef MY_DEBUG
  printf ("NDdelete env objid %d, myself %d\n",md_env->md_id.objid, my_id);
#endif

  status =
  om$send(msg = message VDSroot.NDdelete (md_env),
         mode = OM_e_wrt_message,
     targetid = my_id);

  return(status);
}

method NDcopy (IGRlong    *msg;
               IGRint      cp_type;
        struct GRmd_env   *fr_env;
        struct GRmd_env   *to_env;
        struct GRid       *newobjid)

{   /*  normally we do not allow a copy    ???? */
  IGRint    status;

  status =
  om$send (msg = message VDSroot.NDcopy
                   (msg,cp_type,fr_env,to_env,newobjid),
          mode = OM_e_wrt_message,
      targetid = my_id );

  return (OM_S_SUCCESS);
}


end implementation VCRoot;

