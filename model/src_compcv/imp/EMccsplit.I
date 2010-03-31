class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ma.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"

method GRsplit(IGRlong *msg; struct GRmd_env *env; IGRpoint point; struct
               GRparms *parm; GRobjid *c1, *c2; IGRshort *num)

/*
Abstract
	This method splits  a composite curve at the given point.

Arguments

Notes

Files
	EMccsplit.I

History
	dhm		10/22/87		Creation date.
	dhm		12/21/87		converted to 1.1
	dhm		04/05/88        added GR_NOTIFY_LISTENERS.
    dhm     04/18/88        rewrote to improve performance.
    dhm     07/20/88        changed to drop thru the split element,
                            if needed, to fix a GRrigidconn problem.
    dhm     08/05/88        added GRidchanged.
*/

{
 extern  IGRlong  EFclose_endpnt();
  IGRlong       msg_loc, status, size, bytes_out;
  IGRshort	active_level, num_ret;
  IGRboolean    start_flag, end_flag, is_near_begin, make_new_comp;
  OMuint        index;
  IGRint        close_end, last_ind, num_objects, ret_count,
                from_inx, to_inx;
  IGRlong	i;
  IGRchar       errmsg[EMMAXERRMSG_LEN];
  GRobjid       crv1, crv2, cc, new_comp, new_id;
  OMuword       classid;
  IGRuint   count;
  OM_S_CHANSELECT   to_comps;
  struct GRid       *objects, my_GRid, split_ele;
  struct IGRdisplay	active_display;
  struct GRvg_construct		construct_list;
  IGRchar           *geometry;
  struct GRpost_info        info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GRsplit\n");
  *num = 0;
  *c1 = NULL_OBJID;
  *c2 = NULL_OBJID;
  num_objects = 0;
  crv1 = NULL;
  crv2 = NULL;
  new_comp = NULL;
  cc = NULL;
  objects = NULL;
  is_near_begin = TRUE;
  make_new_comp = TRUE;
  my_GRid.osnum = OM_Gw_current_OS;
  geometry = NULL;
  info.construct_flag = FALSE;

  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Check to see if point is on one of the end points of the composite.
   */

  status = EFclose_endpnt(&msg_loc, my_id, env, my_id, point, &start_flag,
                          &end_flag);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (start_flag || end_flag)
  {
    *msg = MSINARG;
    goto ret_end;
  }

  /*
   * Get the number of components on the composite channel and
   * set last_ind accordingly.
   */

  status = om$get_channel_count(object = me,
                                p_chanselect = &to_comps,
                                count = &count);
  EMomerr_hndlr(status, ret_end, errmsg);

  last_ind = count - 1;

  /*
   * Get the index of the object on which
   * point (and parm) lies.
   */

  status = om$get_index(object_c = me,
                        p_chanselect = &to_comps,
                        objid = parm->leaf_id.objid,
                        indexaddr = &index);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Set the flags for whether or not the split point is on the 
   * start or end point of the component curve.
   */

  status = EFclose_endpnt(&msg_loc, my_id, env,
                          parm->leaf_id.objid, point,
                          &start_flag, &end_flag);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Copy the composite curve.  Only want to perform
   * operations on the copy so that the original is 
   * left intake in the event of an error occurs.
   */

  status = om$send(msg = message GRgraphics.GRcopy(&msg_loc,
                         env, env, &cc),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * If I just need to drop off the curve, then I don't need
   * to construct a new composite curve.
   */

  if ( (index == 0) || (index == 1 && start_flag) || (index == last_ind) ||
       (index == (last_ind - 1) && end_flag) )
         make_new_comp = FALSE;

  /*
   * Construct the new composite if make_new_comp is true.
   */

  if (make_new_comp)
  {
    size = sizeof(struct IGRdisplay);
    gr$get_active_display(msg = &msg_loc, 
                          sizbuf = &size,
                          buffer = &active_display,
                          nret = &bytes_out);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    size = sizeof(IGRshort);
    gr$get_active_level(msg = &msg_loc,
                        sizbuf = &size,
                        buffer = &active_level,
                        nret = &bytes_out);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    construct_list.msg        = &msg_loc;
    construct_list.class_attr = NULL;
    construct_list.level      = active_level;
    construct_list.display    = &active_display;
    construct_list.env_info   = env;
    construct_list.newflag    = FALSE;
    construct_list.name       = NULL;
    construct_list.properties = GRIS_NEW | GRIS_LOCATABLE 
                                         | GRIS_DISPLAYABLE;

    status = om$construct(classid = OPP_GRcompcurve_class_id,
                          osnum = env->md_id.osnum,
                          p_objid = &new_comp,
                          msg = message GRgraphics.GRconstruct(
                                &construct_list));
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }  /* end if make_new_comp */

  /*
   * Determine which end of the composite the split point is closes to.
   */

  close_end = last_ind - index;
  if ( (close_end == index) && (end_flag) )
    is_near_begin = FALSE;
  else if (close_end < index)
    is_near_begin = FALSE;

  /*
   * Set up the number of objects to drop and the indexes to drop from.
   * For just two components split at their connection point, drop both
   * of them.  If it is near the beginning, drop from first component
   * thru the component to split or the one just before it if split pnt
   * is at the start pnt of the component.  If it is near the end, drop
   * from the component to be split or from the one after it thru the
   * last component.
   */

  if ( (count == 2) && (start_flag || end_flag) )
  {
    from_inx = 0;
    to_inx = 1;
    num_objects = 2;
  }
  else if (is_near_begin)
  {
    from_inx = 0;
    if (start_flag)
    {
      to_inx = index - 1;
      num_objects = index;
    }
    else
    {
      to_inx = index;
      num_objects = index + 1;
    }
  }
  else
  {
    to_inx = last_ind;
    if (end_flag)
    {
      from_inx = index + 1;
      num_objects = last_ind - index;
    }
    else
    {
      from_inx = index;
      num_objects = count - index;
    }
    index = 0;  /* index of split point will be 0 after the disconnects */
  }

  /*
   * Get the objects to be dropped and drop them.
   */

  if (num_objects > 0)
  {
    objects = (struct GRid *) om$malloc(size = num_objects *
                                               sizeof(struct GRid));
    EMerr_hndlr(!objects, *msg, MSNOMEM, ret_end);

    status = om$send(msg = message GRowner.GRget_components(&msg_loc,
                           env, objects, num_objects, &ret_count, from_inx,
                           to_inx),
                     targetid = cc);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    my_GRid.objid = cc;
    status = om$send(msg = message GRconnector.GRdisconn(&msg_loc,
                           &my_GRid),
                     senderid = cc,
                     p_chanselect = &to_comps,
                     from = from_inx,
                     to = to_inx);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    /*
     * Connect the objects, except for the object to be split,
     * onto new_comp if make_new_comp is true.
     */

    if (make_new_comp)
    {
      from_inx = 0;
      to_inx = num_objects;

      if (!start_flag && !end_flag)
      {
        if (is_near_begin)
          to_inx = num_objects - 1;
        else
          from_inx = 1;
      }

      my_GRid.objid = new_comp;
      for (i = from_inx; i < to_inx; i++)
      {
        status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                               &my_GRid, &i),
                         targetid = objects[i].objid,
                         targetos = objects[i].osnum);
        EMomerr_hndlr(status, ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL,ret_end);
      }
    }
  }  /* end if num_objects > 0 */

  /*
   * Split the curve if it isn't at the start or end point.
   * Connect the new halves onto new_comp and cc if need be.  Return 
   * new curves in c1 and c2.
   */

  if (!start_flag && !end_flag)
  {
    status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                           env, point, parm, &crv1, &crv2, &num_ret),
                     targetid = objects[index].objid,
                     targetos = objects[index].osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    if (is_near_begin)
    {
      if (make_new_comp)
      {
        i = OM_K_MAXINT;
        my_GRid.objid = new_comp;
        status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                               &my_GRid, &i),
                         targetid = crv1,
                         targetos = parm->leaf_id.osnum);
        EMomerr_hndlr(status, ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL,ret_end);

        *c1 = new_comp;
      }
      else
        *c1 = crv1;

      i = 0;
      my_GRid.objid = cc;
      status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                             &my_GRid, &i),
                       targetid = crv2,
                       targetos = parm->leaf_id.osnum);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL,ret_end);

      *c2 = cc;
      *num = 2;
    }  /* end if is_near_begin */
    else
    {
      i = OM_K_MAXINT;
      my_GRid.objid = cc;
      status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                             &my_GRid, &i),
                       targetid = crv1,
                       targetos = parm->leaf_id.osnum);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL,ret_end);

      *c1 = cc;

      if (make_new_comp)
      {
        i = 0;
        my_GRid.objid = new_comp;
        status = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                               &my_GRid, &i),
                         targetid = crv2,
                         targetos = parm->leaf_id.osnum);
        EMomerr_hndlr(status, ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL,ret_end);

        *c2 = new_comp;
      }
      else
        *c2 = crv2;

      *num = 2;
    }

  }  /* end if (!start_flag && !end_flag) */

  else  /* split at a connection point (start or end of split component) */
  {
    if (is_near_begin)
    {
      if (make_new_comp)
        *c1 = new_comp;
      else
        *c1 = objects[0].objid;

      if (count == 2)
        *c2 = objects[1].objid;
      else
        *c2 = cc;

      *num = 2;
    }
    else
    {
      if (count == 2)
        *c1 = objects[0].objid;
      else
        *c1 = cc;

      if (make_new_comp)
        *c2 = new_comp;
      else
        *c2 = objects[num_objects - 1].objid;

      *num = 2;
    }
  }  /* end else at start or end of split component */

  /*
   * Post the abstract geometry if the new curve is a composite.
   * This sets the planar and closed bits in the instance data.
   */

  status = om$get_classid(objid = *c1,
                          p_classid = &classid);
  EMomerr_hndlr(status, ret_end, errmsg);

  if (classid == OPP_GRcompcurve_class_id)
  {
    status = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                           env, &info, geometry, &new_id),
                     targetid = *c1);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }

  status = om$get_classid(objid = *c2,
                          p_classid = &classid);
  EMomerr_hndlr(status, ret_end, errmsg);

  if (classid == OPP_GRcompcurve_class_id)
  {
    status = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                           env, &info, geometry, &new_id),
                     targetid = *c2);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }


ret_end:
  if ( (*msg != MSSUCC) ||  !(status&1) )
  {
    *num = 0;  /* set back to 0 */
  
    if (crv1)
    {
       status = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                        senderid = my_id,
                        targetid = crv1);
        EMomerr_hndlr_action(status, ;, errmsg);
        EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
    }

    if (crv2)
    {
       status = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                        senderid = my_id,
                        targetid = crv2);
        EMomerr_hndlr_action(status, ;, errmsg);
        EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
    }

    if (cc)
    {
       status = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                        senderid = my_id,
                        targetid = cc);
        EMomerr_hndlr_action(status, ;, errmsg);
        EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
    }

    if (objects)
    {
       for (i = 0; i < num_objects; i++)
       {
         status = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                          senderid = my_id,
                          targetid = objects[i].objid);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
       }
    }

    if (new_comp)
    {
       status = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                        senderid = my_id,
                        targetid = new_comp);
        EMomerr_hndlr_action(status, ;, errmsg);
        EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
    }

  }  /* end msg != MSSUCC */
  else
  {
    /*
     * Send the owners a GRidchanged message so they can process new id's.
     */

    struct GRid   newids[2];

    newids[0].osnum = OM_Gw_current_OS;
    newids[0].objid = *c1;
    newids[1].osnum = OM_Gw_current_OS;
    newids[1].objid = *c2;
    status = om$send(msg = message GRgraphics.GRidchanged(&msg_loc, 
                           num, newids),
                     targetid = my_id);
    EMomerr_hndlr_action(status, ;, errmsg);
    EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

    /*
     * Delete the original composite curve.
     */

    status = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                     targetid = my_id);
    EMomerr_hndlr_action(status, ;, errmsg);
    EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

  }

  if (objects) om$dealloc(ptr = objects);

  GR_NOTIFY_LISTENERS(msg, &status, GR_CLIPPED);
  return(status);

}  /* end of GRsplit method */

end implementation GRcompcurve;
