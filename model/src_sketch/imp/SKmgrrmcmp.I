class implementation SKmgr;

#include <alloca.h>
#include "msdef.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"

extern GRclassid OPP_SKpoint_class_id, OPP_SKline_class_id, OPP_SKarc_class_id,
                 OPP_SKcompcurve_class_id, OPP_SKcircle_class_id;

/*

Name
  SKmgr.GRremove_components

Abstract
  Deletes a segment out of a profile.
  
Synopsis
  See GRowner.S
  
Description
  Method to remove a component out of a profile.  Removes the centerpoint of the
  arc and circle as well.  All the constraints on the centerpt are also deleted.
  The actual deletion is done by the GRdelete method.
  
Return Value

Notes

Index

Keywords
  profile, delete component

History
  ???????  : Henry Bequet  : creation
  06/01/93 : Rajiv Agrawal : Added check for split profile.
  06/10/93 : Rajiv Agrawal : Massive cleanup and changed the deletion of arc/circle
                             centerpt.
  09/01/93 : Rajiv Agrawal : Add code so that a full compcurve can be removed.
                             Also better deletion of the centerpt.
  06/01/94 : Sudha         : check the classid before deleting the additional 
			     SKpoint connected to SKptvar (TR#119315116).

 */
method GRremove_components ( long *msg; struct GRmd_env *mod_env; int *num_objects; 
                             struct GRobj_env objects [] )
{
  int                   i, k, inx, start_inx, end_inx;
  long                  stat_OM, msg_loc;
  OMuint                num_comps, count2;
  OM_S_CHANSELECT       to_comps, to_owners;
  OM_S_OBJECT_LINKAGE   *ptobjs, gmobjs [2];
  GRclassid             classid; 
  struct GRprops        props;
  struct GRid           ptobj, composite, mgr_grid;
  enum GRdpmode         dpmode;
  IGRushort             geom_type;
  OM_S_CHANSELECT       to_geometries, to_defpts;
  OMuint                num_pts, num_geoms;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
  EMmake_chanselect ( SKvariable_to_geometries, &to_geometries );

  for (i = 0; i < *num_objects; i++)
  {
    /*
     * Make sure that guy is an SKline, SKpoint, SKarc, SKcircle or SKbpsline
     */
    SKgetgeomtype(objects [i].obj_id.objid, objects [i].obj_id.osnum, &geom_type);
    if (geom_type & SK_ANYGEOM) 
    {
      /*
       * If we delete an arc/circle/bspline, then we need to get rid of the extra
       * SKpoints that were created.  Centerpt for arcs and circles and 
       * all points other than the end-poles for a b-spline.
       */
      if (geom_type & SK_ARC || geom_type & SK_CIRCLE || geom_type & SK_BSPLINE)
      {
        stat_OM = om$get_channel_count ( osnum = objects [i].obj_id.osnum, 
                                         objid = objects [i].obj_id.objid,
                                         p_chanselect = &to_defpts,
                                         count = &num_pts );
        if (!num_pts || !(stat_OM & 1)) goto ret_end;
        
        ptobjs = (OM_S_OBJECT_LINKAGE *) alloca (num_pts * sizeof ( OM_S_OBJECT_LINKAGE ));
        stat_OM = om$get_channel_objects ( list = ptobjs, size = num_pts, count = &num_pts,
                                           osnum = objects [i].obj_id.osnum, 
                                           objid = objects [i].obj_id.objid,
                                           p_chanselect = &to_defpts );
        if (!(stat_OM & 1)) goto ret_end;

        start_inx = 1;
        end_inx = 1;
        if (geom_type & SK_BSPLINE)
        {
          start_inx = 1;
          end_inx = 2;
        }
        for (inx = start_inx; inx <= end_inx; inx++) 
        {
          /*
           * Find the SKpoint connected to the additional SKptvar and delete it.
           */
          stat_OM = om$get_channel_objects ( list = gmobjs, size = 2, count = &num_geoms,
                                             osnum = ptobjs [inx].osnum, 
                                             objid = ptobjs [inx].S_objid, 
                                             p_chanselect = &to_geometries );
          if (!(stat_OM & 1)) goto ret_end;
          
	  for ( k = 0; k < num_geoms; k ++) 
	  {
             /* check classid before delete */

             stat_OM = om$get_classid( osnum = gmobjs[k].osnum,
 				       objid = gmobjs[k].S_objid,
				       p_classid = &classid);

             if ( classid == OPP_SKpoint_class_id ) 
             {
                dpmode = GRbe;
                stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc, 
                                    		&mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                                    		&dpmode, &mod_env->md_id), 
                              	    targetid = gmobjs [k].S_objid, 
                              	    targetos = gmobjs [k].osnum );
                stat_OM = om$send ( msg = message GRgraphics.GRdelete ( msg, mod_env ),
       	                            targetid = gmobjs [k].S_objid, 
                                    targetos = gmobjs [k].osnum );
                if (!(stat_OM & 1)) goto ret_end;
             }
          }
        }
      }
      else if (geom_type & SK_POINT)
      {
        /*
         * If the deleted component is a point, make sure we do not delete 
         * a point that is connected to more than one geometry thru an SKptvar
         * e.g. centerpt of an arc/circle, controlling pt of a b-spline.
         */
        stat_OM = om$get_objid_at_index ( osnum = objects [i].obj_id.osnum, 
                                          objid = objects [i].obj_id.objid,
                                          p_chanselect = &to_defpts,
                                          index = 0,
                                          objidaddr = &ptobj.objid, 
                                          osnumaddr = &ptobj.osnum );
        if (!(stat_OM & 1)) goto ret_end;
        stat_OM = om$get_channel_count ( osnum = ptobj.osnum, 
                                         objid = ptobj.objid, 
                                         p_chanselect = &to_geometries,
            				 count = &num_geoms );
        if (num_geoms > 1)
        {
          ex$message (msgnumb = EMS_S_CannotDeletePoint);
          goto ret_end;
        }
      }

      composite.objid = NULL_OBJID;
      /*
       * Get the geometry properties of the owning composite curve
       * to test for closed and open cases.
       */
      if (geom_type & SK_LINE || geom_type & SK_ARC || geom_type & SK_BSPLINE) 
      {
        EMmake_chanselect (GRconnector_to_owners, &to_owners);
        stat_OM = om$get_objid_at_index (objid = objects [i].obj_id.objid, 
                                         osnum = objects [i].obj_id.osnum,
                                         p_chanselect = &to_owners, 
                                         index = 0,
                                         objidaddr = &composite.objid,
                                         osnumaddr = &composite.osnum);
  
        if (!IF_NULL_OBJID(composite.objid))
        {
          om$get_classid ( osnum = composite.osnum, objid = composite.objid, 
                           p_classid = &classid );
          if (om$is_ancestry_valid ( subclassid = classid, 
              superclassid = OPP_SKcompcurve_class_id ) == OM_S_SUCCESS)
          {
            stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                    &mod_env->md_env.matrix_type,
                                    mod_env->md_env.matrix, &props),
                              targetid = composite.objid, 
                              targetos = composite.osnum);
            EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
          }
          else
            composite.objid = NULL_OBJID;
        }
      }

      /*
       * Delete the profile element
       */
      stat_OM = om$send ( msg = message GRgraphics.GRdelete ( &msg_loc, mod_env ),
                          targetid = objects [i].obj_id.objid, 
                          targetos = objects [i].obj_id.osnum );
      EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      
      /*
       * If the deleted element was a part of a closed composite curve, then we
       * need to update its properties by posting the new geometry.
       */
      if (composite.objid != NULL_OBJID && props.phy_closed)
      {
        IGRchar   *geometry;
        GRobjid   new_id;
        struct    GRpost_info info;

        geometry = NULL;
        info.construct_flag = FALSE;
        stat_OM = om$send(msg = message GRvg.GRpostabsg
                               (&msg_loc, mod_env, &info, geometry, &new_id),
                          targetid = composite.objid,
                          targetos = composite.osnum);
        EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
    else if (geom_type & SK_COMPCURVE)
    {
      /*
       * Collect all the objects and send them a remove components.
       */
      EMmake_chanselect ( GRcmpowner_to_components, &to_comps );
      stat_OM = om$get_channel_count ( objid = objects [i].obj_id.objid,
                                       osnum = objects [i].obj_id.osnum,
                                       p_chanselect = &to_comps, 
                                       count = &num_comps );
      if (!(stat_OM & 1)) goto ret_end;
      if (num_comps)
      {
        OM_S_OBJECT_LINKAGE  *list;
        struct GRobj_env     *comp_objects;
        
        list = (OM_S_OBJECT_LINKAGE *)alloca ( num_comps * sizeof ( OM_S_OBJECT_LINKAGE ) );
        comp_objects = (struct GRobj_env *) alloca (num_comps * sizeof (struct GRobj_env));
        stat_OM = om$get_channel_objects ( list = list, size = num_comps, count = &num_comps,
                                           objid = objects [i].obj_id.objid,
                                           osnum = objects [i].obj_id.osnum,
                                           p_chanselect = &to_comps );
        if (!(stat_OM & 1)) goto ret_end;
        
        for (i = 0; i < num_comps; i++)
        {
          comp_objects[i].obj_id.objid = list[i].S_objid;
          comp_objects[i].obj_id.osnum = list[i].osnum;
        }

        stat_OM = om$send ( msg = message SKmgr.GRremove_components 
                                  (&msg_loc, mod_env, (int *)&num_comps, comp_objects),
                            targetid = my_id );
      } 
    }
    else
    {
      EMerr_hndlr ( TRUE, *msg, EMS_I_InvalidCase, ret_end );
    }
  }
            
  /*
   * An empty SKmgr or an SKmgr connected to an empty composite curve
   * has no reason to exist.
   */
  EMmake_chanselect ( GRcmpowner_to_components, &to_comps );
  stat_OM = om$get_channel_count ( objid = my_id, 
                                   p_chanselect = &to_comps, 
                                   count = &num_comps );
  if (!(stat_OM & 1)) goto ret_end;

  if (num_comps)
  {
    OM_S_OBJECT_LINKAGE  *list;
    
    list = (OM_S_OBJECT_LINKAGE *)alloca ( num_comps * sizeof ( OM_S_OBJECT_LINKAGE ) );
    stat_OM = om$get_channel_objects ( list = list, size = num_comps, count = &num_comps,
                                       objid = my_id, p_chanselect = &to_comps );
    if (!(stat_OM & 1)) goto ret_end;
    
    for (i = 0; i < num_comps; i++)
    {
      /*
       * Check if any underlying composite curve is also empty.  If so, delete it.
       * The case when the composite curve has only element has to be done.  In
       * this case, the composite curve should be deleted and the component shd
       * be directly attached to the SKmgr (TO BE DONE)
       */
      om$get_classid ( objid = list [i].S_objid, p_classid = &classid );
      if (om$is_ancestry_valid ( superclassid = OPP_SKcompcurve_class_id,
                                 subclassid = classid ) == OM_S_SUCCESS)
      {
        stat_OM = om$get_channel_count ( objid = list [i].S_objid, 
                                         p_chanselect = &to_comps, 
                                         count = &count2 );
        if (!(stat_OM & 1)) goto ret_end;
        
        if (!count2)
        {
          stat_OM = om$send ( msg = message GRgraphics.GRdelete ( msg, mod_env ),
                              targetid = list [i].S_objid );
          if (!(stat_OM & 1)) goto ret_end;
          num_comps--;
        }
      }    
    }
  }

  if (!num_comps)
  {
    stat_OM = om$send ( msg = message GRgraphics.GRdelete ( msg, mod_env ),
                        targetid = my_id );
    if (!(stat_OM & 1)) goto ret_end;
  }
  else
  {
    /*
     * Since we may have split a composite curve, we need to check if we can
     * split the profile as well.
     */
    mgr_grid.osnum = OM_Gw_current_OS;
    mgr_grid.objid = my_id;
    stat_OM = SKsplit_profile ( &msg_loc, &mgr_grid );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKmgr.GRremove_components" );
  return stat_OM;
}

end implementation SKmgr;
