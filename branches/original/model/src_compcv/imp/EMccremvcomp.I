/*
Abstract
    This method removes a component from a composite curve.  This method
    will handle any disjointness problems.

Arguments
    *msg       IGRlong            error return code
    *md_env    struct GRmd_env    module environment of the object

Notes
    EMS_S_Success    returns if all goes well
    EMS_E_Fail       returns if any other error occurs

Files
    EMccremvcomp.I

History
    dhm    03/14/88    creation date.
    dhm    04/06/88    added GR_NOTIFY_LISTENERS.
*/

class implementation GRcompcurve;

#include "EMScc.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "gr.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "godef.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

#define DROP_ALL_2        1
#define DROP_ALL_3        2
#define DROP_FIRST_2      3
#define DROP_LAST_2       4
#define FIRST_LAST        5
#define OPEN_DROP_CONN    6
#define CLOSED_DROP_CONN  7
#define OPEN_CONN         8
#define END_CONN          9
#define BEG_CONN          10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method GRremove_components(IGRlong *msg; struct GRmd_env *md_env;
                           IGRint *num_objects; struct GRobj_env drp_obj[])
{
  IGRlong      status, msg_loc;
  IGRuint      count, my_owner_count, drp_ind;
  IGRint       i, j, drop_case, beg_inx, end_inx;
  IGRlong      inx;
  IGRboolean   is_closed;
  GRobjid      *objects;
  GRclassid    myclass;
  struct GRid  my_GRid, my_owner, comp_id;
  OM_S_CHANSELECT   to_comps, chan_to_owners;
  OM_S_OBJECT_LINKAGE ownlist, *list;
  struct GRprops    props;

  /*
   * Initalize
   */

  status = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * If this composite has an owner, any disconnection of components from this
   * composite causes them to be connected to this owner. In theory, the
   * components keep travelling upwards in the ownership tree, until they
   * exit due to no owners being present for the current owner. Keep track
   * of this owner.
   */

  EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
  my_owner_count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_owners,
   count = &my_owner_count, size = 1, list = &ownlist);
  if (my_owner_count)
    {
    my_owner.objid = ownlist.S_objid;
    my_owner.osnum = OM_Gw_current_OS;
    }

  /*
   * Iterate over all the drop objects until all
   * have been processed.
   */

  EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &to_comps,
   count = &count);
  if (!count)
    goto ret_end;
  
  objects = (GRobjid *) alloca (count * sizeof (GRobjid));
  list = (OM_p_OBJECT_LINKAGE) alloca (count * sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!(objects || list), *msg, EMS_E_NoStackMemory, ret_end);

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  for (i = 0; i < (*num_objects); i++)
  {
   /*
    * Obtain the list of all the component objects
    */

    count = 0;
    om$get_channel_count (object = me, p_chanselect = &to_comps,
     count = &count);

    if (!count)
      {
      om$send (mode = OM_e_wrt_message, msg = message Root.delete (TRUE),
       targetid = my_id);
      goto ret_end;
      }
  
    om$get_channel_objects (object = me, p_chanselect = &to_comps,
     count = &count, size = count, list = list);
    for (j=0; j<count; j++)
      objects[j] = list[j].S_objid;

    /*
     * Get the index of the current drop object.
     */

    status = om$get_index(object_c = me,
                          p_chanselect = &to_comps,
                          objid = drp_obj[i].obj_id.objid,
                          indexaddr = &drp_ind);
    if (status == OM_W_NOTONCHAN)
    {
        status = OM_S_SUCCESS;
        continue;
    }
    EMerr_hndlr(!(1&status), status, OM_E_ABORT, ret_end);

    /*
     * Get the geometry properties of the composite
     * to test for closed and open cases.
     */

    status = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                           &md_env->md_env.matrix_type,
                           md_env->md_env.matrix, &props),
                     targetid = my_id);
    EMomerr_exit(status, ret_end);
    EMerr_hndlr(EMis_error(msg_loc), *msg, EMS_E_Fail, ret_end);

    is_closed = props.phy_closed;

    /*
     * Handle all possible cases.  If there's only 2 objects, drop all of
     * them.  If obj is the first or last objects, then just drop it.  If
     * composite is open, there are several cases. First, if obj is middle
     * one of 3, then drop all objects.  If obj is second from front or 
     * last, then drop first or last two.  If obj is somewhere in middle
     * of a large composite (more than 4 objects), I need to drop all
     * objects before the drop obj and make a new composite out of them;
     * then drop obj.  If the composite is closed, then I need to either
     * drop the objects before obj and put them back on composite at the
     * rear; or drop the objects after obj and put them on the composite at
     * the front; and then drop the obj.
     */

    if (count == 2)
    {
       beg_inx = 0;
       end_inx = 1;
       drop_case = DROP_ALL_2;
    }  /* end if 2 */

    else if ( (drp_ind == 0) || (drp_ind == count - 1) )
    {
       beg_inx = drp_ind;
       end_inx = drp_ind;
       drop_case = FIRST_LAST;
    }  /* end if first or last */

    else if ( !(is_closed) )  /* if open */
    {
       if ( (count == 3) && (drp_ind == 1) )
       {
          beg_inx = 0;
          end_inx = 2;
          drop_case = DROP_ALL_3;
       }  /* end drop all */

       else if ( (count > 3) && (drp_ind == 1) )
       {
          beg_inx = 0;
          end_inx = 1;
          drop_case = DROP_FIRST_2;
       }  /* end drop first 2 */

       else if ( (count > 3) && (drp_ind == count - 2) )
       {
          beg_inx = drp_ind;
          end_inx = count - 1;
          drop_case = DROP_LAST_2;
       }  /* end drop last 2 */

       else if ( (count > 4) && ((drp_ind > 1) && (drp_ind < count - 2)) )
       {
          beg_inx = 0;
          end_inx = drp_ind;
          drop_case = OPEN_DROP_CONN;
       }  /* end drop of middle object */

       else  /* something went wrong */
       {
          *msg = EMS_E_Fail;
          goto ret_end;
       }

    }  /* end if open */

    else
    {
       beg_inx = 0;
       end_inx = drp_ind;
       drop_case = CLOSED_DROP_CONN;
    }  /* end if closed */

    switch (drop_case)
    {
      case DROP_ALL_2:
      case DROP_ALL_3:
      case DROP_FIRST_2:
      case DROP_LAST_2:
      case FIRST_LAST:
      {
         status = om$send(msg = message GRconnector.GRdisconn(&msg_loc,
                                &my_GRid),
                          p_chanselect = &to_comps,
                          from = beg_inx,
                          to = end_inx);
         EMomerr_exit(status, ret_end);
         EMerr_hndlr(EMis_error(msg_loc), *msg, EMS_E_Fail, ret_end);

         if (drop_case == DROP_ALL_2 || drop_case == DROP_ALL_3)
           om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
            targetid = my_id);

         if (my_owner_count)
         {
           inx = MAXINT;
           for (j=beg_inx; j<end_inx; j++)
           {
             status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                       &my_owner, &inx), targetid = objects[j]);
             EMerr_hndlr (EMSerror(status & msg_loc), *msg, EMS_E_Fail,
              ret_end);
           }
         }

         break;
      }


      case OPEN_DROP_CONN:
      case CLOSED_DROP_CONN:
      {
         if (drop_case == OPEN_DROP_CONN)
         {
           struct GRvg_construct     constr;
           struct IGRdisplay         active_display;

           EMinitvgcnstr (&msg_loc, md_env, &active_display, NULL, &constr);
           EMgetvgcnstr (NULL, NULL, NULL, DEFAULT_GR_LEVEL, NULL, NULL, NULL,
                         &constr);

           om$get_classid (object = me, p_classid = &myclass);
           status = om$construct (classid = myclass, p_objid = &comp_id.objid,
                     msg = message GRgraphics.GRconstruct (&constr));
           EMerr_hndlr (EMSerror (status & msg_loc), *msg, EMS_E_Fail,
                        ret_end);
           comp_id.osnum = OM_Gw_current_OS;

           if (my_owner_count)
           {
             inx = MAXINT;
             status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                       &my_owner, &inx), targetid = comp_id.objid);
             EMerr_hndlr (EMSerror(status & msg_loc), *msg, EMS_E_Fail,
              ret_end);
           }
         }
         else
           comp_id = my_GRid;

         status = om$send(msg = message GRconnector.GRdisconn(&msg_loc,
                                &my_GRid),
                          p_chanselect = &to_comps,
                          from = beg_inx,
                          to = end_inx);
         EMomerr_exit(status, ret_end);
         EMerr_hndlr(EMis_error(msg_loc), *msg, EMS_E_Fail, ret_end);

         if (my_owner_count)
         {
           inx = MAXINT;
           status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                     &my_owner, &inx), targetid = objects[drp_ind]);
           EMerr_hndlr (EMSerror(status & msg_loc), *msg, EMS_E_Fail,
            ret_end);
         }

         inx = MAXINT;
         for (j = 0; j < end_inx; j++)
         {
            status = om$send(msg = message GRconnector.GRrigidconn(
                      &msg_loc, &comp_id, &inx), targetid = objects[j]);
            EMerr_hndlr(EMis_error(status & msg_loc), *msg, EMS_E_Fail,
             ret_end);
         }

         break;
      }


      default:
      {
         *msg = EMS_E_Fail;
         goto ret_end;
      }
    }  /* end switch drop_case */


    /*
     * Post the abstract data if the composite
     * was originally closed
     */

    if (props.phy_closed)
    {
       IGRchar   *geometry;
       GRobjid   new_id;
       struct    GRpost_info info;

       geometry = NULL;
       info.construct_flag = FALSE;
       status = om$send(msg = message GRvg.GRpostabsg(&msg_loc, md_env,
                              &info, geometry, &new_id),
                        targetid = my_id);
       EMomerr_exit(status, ret_end);
       EMerr_hndlr(EMis_error(msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  }  /* end for loop over all drp_obj's */


ret_end:
  GR_NOTIFY_LISTENERS(msg, &status, GR_CHANNEL_USED);
  return(status);

}

end  implementation GRcompcurve;
