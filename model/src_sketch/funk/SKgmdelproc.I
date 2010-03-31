class implementation SKgeometry;

#include <alloca.h>

from GRowner 	  import GRget_number_components, GRget_components;
from SKconstraint import SKgetmajconstrs;

extern GRclassid  OPP_DMsrc_class_id, OPP_SKimplicit_class_id, OPP_SKexplicit_class_id;
/*

Name
  SKdelete_geom_constrs

Abstract
  This function deletes all the implicit geometric constraints acting on a profile
  segment.
  
Synopsis
   long *msg, 			return code				OUT
   struct GRmd_env *md_env, 	module env				IN
   struct GRid geomid		grid of the SKgeometry element  	IN

Description
  This function finds the constraints acting on the endpoints of the profile
  segment and then deletes those that involve both the vertices.
  
Return Value

Notes
  
Index

Keywords
  profile, delete, constraints
  
History
  06/21/93 : Rajiv Agrawal : created
  11/18/93 : GMK	   : TR # 119313194, For SKarc the ptvar index is changed from
  			     last ptvar index to center ptvar index which is used to get 
  			     the constraints list.
  01/12/94 : Sudha : Use malloc instead of alloca for getting the major constraints.
                     (TR119301030)
 09/08/94: Vidya: moved the initialisation of major_constrs variable
                  to the beginning of the function to avoid a crash
                  fixes the TR 119419103

 */

SKdelete_geom_constrs( long *msg, struct GRmd_env *md_env, struct GRid geomid )
{
  OMuint              	num_pts, num_cnstrs;
  int                 	i, j, stat_OM;
  long                	msg_loc;
  enum GRdpmode       	dpmode;
  GRclassid 		cnstr_class;
  GRobjid 		*major_constrs[2];
  int 			num_major_constrs[2];
  OM_S_CHANSELECT     	to_defpts, to_constrs;
  OM_S_OBJECT_LINKAGE   ptobjs [4];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  num_pts = 0;
 
  /* fix for TR 119419103 */ 
  for (i=0; i<2; i++)
  {
    major_constrs[i] = NULL;
    num_major_constrs[i] = 0;
  }

  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
  stat_OM = om$get_channel_objects ( list = ptobjs, 
				     size = 4, 
				     count = &num_pts,
                                     objid = geomid.objid,
                                     osnum = geomid.osnum, 
                                     p_chanselect = &to_defpts );
  EMerr_hndlr ( EMSerror (stat_OM) || num_pts < 1, *msg, EMS_E_Fail, ret_end );
  
  EMmake_chanselect ( SKvariable_to_constraints, &to_constrs );
  num_cnstrs = 0;
  stat_OM = om$get_channel_count ( objid = ptobjs[0].S_objid,
                                   osnum = ptobjs[0].osnum, 
                                   p_chanselect = &to_constrs,
                                   count = &num_cnstrs );
  if (!(stat_OM & 1)) goto ret_end;

  if (num_cnstrs)
  {
    /*
     * Get constraints on the starting vertex.
     */
    major_constrs[0] = (GRobjid *) om$malloc (size = num_cnstrs * sizeof (GRobjid));
    EMerr_hndlr ( !major_constrs[0], *msg, EMS_E_NoStackMemory, ret_end );

    stat_OM = om$send (msg = message SKconstraint.SKgetmajconstrs (&msg_loc,
            					                   NULL, 
								   num_cnstrs,
							           &num_major_constrs[0], 
								   &major_constrs[0]),
                       p_chanselect = &to_constrs,
                       targetos = ptobjs [0].osnum,
                       senderid = ptobjs [0].S_objid);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    
    if (num_pts > 1)
    {
      IGRint pt_index;
      /*
       * Get constraints on the ending vertex. 
       * If the geometry element is SKarc (i.e num of ptvars is three),
       * it is better to take the constraints from the first and center point ptvars. 
       * TR # 119313194 --- GMK 
       */
      if ( num_pts == 3 )
        pt_index = 1;       /* center ptvar index */
      else
        pt_index = num_pts - 1;
        
      stat_OM = om$get_channel_count ( objid = ptobjs[pt_index].S_objid,
                                       osnum = ptobjs[pt_index].osnum, 
                                       p_chanselect = &to_constrs,
                                       count = &num_cnstrs );
      if (num_cnstrs)
      {
        major_constrs[1] = (GRobjid *) om$malloc (size = num_cnstrs * sizeof (GRobjid));
        EMerr_hndlr ( !major_constrs[1], *msg, EMS_E_NoStackMemory, ret_end );
  
        stat_OM = om$send (msg = message SKconstraint.SKgetmajconstrs (&msg_loc,
                                 				       NULL, 
								       num_cnstrs, 
								       &num_major_constrs[1], 
								       &major_constrs[1]),
                           p_chanselect = &to_constrs,
                           targetos = ptobjs [pt_index].osnum,
                           senderid = ptobjs [pt_index].S_objid);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
      }
    }
    else
    {
      /*
       * We are dealing with an SKpoint.  Delete all the constraints.
       */
      num_major_constrs[1] = num_major_constrs[0];
      major_constrs[1] = major_constrs[0];
    }
    /*
     * find the common implicit constraints between the first and the last vertex.
     */
    for(i=0; i < num_major_constrs[0]; i++)
    {
      for (j=0; j < num_major_constrs[1]; j++)
      {
        if (major_constrs[0][i] == major_constrs[1][j])
        {
          om$get_classid ( osnum = ptobjs[0].osnum, 
                           objid = major_constrs[0][i], 
                           p_classid = &cnstr_class );
          if (om$is_ancestry_valid ( subclassid = cnstr_class,
                                     superclassid = OPP_SKimplicit_class_id) == OM_S_SUCCESS)
          {
            dpmode = GRbe;

            stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc, 
                                      		&md_env->md_env.matrix_type,
                                      		md_env->md_env.matrix, &dpmode,
                                      		&md_env->md_id), 
                                targetos = ptobjs[0].osnum,
                                targetid = major_constrs[0][i],
                                senderid = NULL_OBJID);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

            stat_OM = om$send ( msg = message GRgraphics.GRdelete(&msg_loc, 
								  md_env),
                                targetos = ptobjs[0].osnum,
                                targetid = major_constrs[0][i],
                                senderid = NULL_OBJID);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
          break;
        }
      }
    }
  }

ret_end:

  /*
   * free major constraints array if they got reallocated
   */
  if (major_constrs[0])
    om$dealloc (ptr = major_constrs[0]);
  if (major_constrs[1] && major_constrs[1] != major_constrs[0])
    om$dealloc (ptr = major_constrs[1]);

  EMWRAPUP (*msg, stat_OM, "SKdelete_geom_constrs");
  return stat_OM;
}

/*

Name
  SKdelete_dimensions

Abstract
  Function to delete any dimensions connected to a SKgeometry element.
  
Synopsis
   long *msg, 			return code				OUT
   struct GRmd_env *md_env, 	module env				IN
   struct GRid geomid		grid of the SKgeometry element  	IN

Description
  Dimensional constraints such as single-parallel, radial, etc. are connected
  to the profile element thru a DMsrc object on the father-child channel.
  The actual dimension handle is a child of the DMsrc object and is owned
  by the SKconstraint object.  Other children of the profile element are
  moved to root.

Return Value

Notes

Index

Keywords
  delete,dimension,profile

History
  ???????  : Henry Bequet  : created
  06/02/93 : Rajiv Agrawal : converted to a function from embedded code.

 */

SKdelete_dimensions( long *msg, struct GRmd_env *md_env, struct GRid geomid )
{
  OMuint              count1;
  int                 i, stat_OM;
  long                msg_loc;
  struct GRid         src_grid;
  GRclassid           class_id;
  enum GRdpmode       dpmode;
  OM_S_CHANSELECT     to_children, to_owners;
  OM_S_OBJECT_LINKAGE *children;
  extern IGRboolean   ASbroadcast_in_progress;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  msg_loc = OM_S_SUCCESS;
  count1 = 0;

  if (!ASbroadcast_in_progress)
  {
    EMmake_chanselect ( GRconnector_to_owners, &to_owners );
    EMmake_chanselect ( NDchildren_children, &to_children );

    stat_OM = om$get_channel_count(objid = geomid.objid, 
				   osnum = geomid.osnum,
                                   p_chanselect = &to_children,
                                   count = &count1);
    if ((stat_OM & 1) && count1)
    {
      children = (OM_S_OBJECT_LINKAGE *)alloca(count1 * sizeof(OM_S_OBJECT_LINKAGE));

      stat_OM = om$get_channel_objects( p_chanselect = &to_children, 
                                        objid = geomid.objid, 
				  	osnum = geomid.osnum,
                                        list = children, 
					size = count1, 
					count = &count1);

      for (i = 0; i < count1; i++)
      {    
        om$get_classid(osnum = children[i].osnum,
                       objid = children[i].S_objid, 
                       p_classid = &class_id);

        if (om$is_ancestry_valid(subclassid = class_id, 
                                 superclassid = OPP_DMsrc_class_id) == OM_S_SUCCESS)
        {
          int                 i2;
          OMuint              count2 = 0;
          OM_S_OBJECT_LINKAGE *children2;

          /*
           * The children of DMsrc are owned by the SKconstraint.
           */
          stat_OM = om$get_channel_count(objid = children[i].S_objid,
                                         osnum = children[i].osnum,
                                         p_chanselect = &to_children,
                                         count = &count2);
          if ((stat_OM & 1) && count2)
          {
            children2 = (OM_S_OBJECT_LINKAGE *)alloca(count2 * sizeof(OM_S_OBJECT_LINKAGE));

            stat_OM = om$get_channel_objects(p_chanselect = &to_children, 
                                             objid = children[i].S_objid,
                                             osnum = children[i].osnum,
                                             list = children2,
                                             size = count2,
                                             count = &count2);
            for (i2 = 0; i2 < count2; i2++)
            {
              int                 i3;
              OMuint              count3 = 0;
              OM_S_OBJECT_LINKAGE *owners;
          
              /*
               * We want the owners that are sub-class of SKexplicit
               */
              stat_OM = om$get_channel_count(objid = children2[i2].S_objid,
                                             osnum = children2[i2].osnum,
                                             p_chanselect = &to_owners, 
                                             count = &count3);
              if ((stat_OM & 1) && count3)
              {
                owners = (OM_S_OBJECT_LINKAGE *)alloca(count3 * sizeof(OM_S_OBJECT_LINKAGE));

                om$get_channel_objects(p_chanselect = &to_owners, 
                                       objid = children2[i2].S_objid,
                                       osnum = children2[i2].osnum,
                                       list = owners,
                                       size = count3,
                                       count = &count3);
                for (i3 = 0; i3 < count3; i3++)
                {
                  om$get_classid(osnum = owners[i3].osnum,
                                 objid = owners[i3].S_objid, 
                                 p_classid = &class_id);

                  if (om$is_ancestry_valid(subclassid = class_id, 
                                           superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS)
                  {
                    /*
                     * Erase and delete the constraint.
                     */
                    dpmode = GRbehe;
                    stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
	                                             &md_env->md_env.matrix_type, 
        	                                     md_env->md_env.matrix, &dpmode,
                	                             &md_env->md_id), 
                                       targetos = owners[i3].osnum,
                                       targetid = owners[i3].S_objid,
                                       senderid = NULL_OBJID);
                    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

                    stat_OM = om$send (msg = message GRgraphics.GRdelete(&msg_loc, 
									 md_env),
                                       targetos = owners[i3].osnum,
                                       targetid = owners[i3].S_objid,
                                       senderid = NULL_OBJID);
                    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

                  }
                }
              }
            }
          }
        }
        stat_OM = om$send (msg = message NDnode.NDmove_to_root ( &msg_loc, 
								 &src_grid, 
								 md_env ),
                           targetos = children [i].osnum, 
                           targetid = children [i].S_objid,
                           senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
      }
    }
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKdelete_dimensions" );
  return stat_OM;
}

/*

Name
  SKcheck_composite

Abstract

Synopsis

Description
 This procedure checks if the composite is not split (i.e. open in
 two places). If it is the case then a new composite is created and
 attached to the SKmgr.

Return Value

Notes

Index

Keywords

History
  ???????? : Henry Bequet  : created
  06/21/93 : Rajiv Agrawal : Added documentation and cleanup.

 */

SKcheck_composite ( msg, composite, md_env )
long        *msg      	/* The return code				OUT */;
struct GRid *composite	/* The composite that needs to be checked	IN  */;
struct GRmd_env *md_env	/* The module env				IN  */;
{
  int                 stat_OM, i, nb_components, hole_index;
  OMuint              nb_points;
  long                msg_loc = OM_S_SUCCESS;
  GRobjid             first_point, last_point;
  GRobjid             orient_first = NULL_OBJID, orient_second = NULL_OBJID;
  struct GRid         mgr, *components;
  OM_S_CHANSELECT     to_defpts;
  OM_S_OBJECT_LINKAGE points [4];
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * We get the components of the composite
   */
  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );

  stat_OM = om$send  ( msg =  message GRowner.GRget_number_components (&msg_loc, 
								       &nb_components),
                       targetid = composite->objid, 
		       targetos = composite->osnum,
                       senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  if (nb_components < 3)
    goto ret_end;

  components = (struct GRid *) alloca ( nb_components * sizeof ( struct GRid) );

  stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, 
							     md_env, 
                           				     components, 
							     nb_components, 
							     &nb_components, 
							     0, 
							     MAXINT),
                     targetid = composite->objid, 
		     targetos = composite->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  /*
   * Find a starting component ... a component with some points.
   */
  for (i = 0, nb_points = 0; (!nb_points) && (i < nb_components); i++)
  {
    stat_OM = om$get_channel_objects ( osnum = components [i].osnum, 
                                       objid = components [i].objid, 
                                       p_chanselect = &to_defpts, 
                                       count = &nb_points, 
                                       size = 4, list = points );
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  }
  
  /*
   * We traverse the components until we find a hole in the list.
   */
  if (i < nb_components)
  {
    first_point = points [0].S_objid;
    last_point = points [nb_points - 1].S_objid;
    hole_index = -1;

    for (; i < nb_components; i++)
    {
      stat_OM = om$get_channel_objects ( osnum = components [i].osnum, 
                                         objid = components [i].objid, 
                                         p_chanselect = &to_defpts, 
                                         count = &nb_points, 
                                         size = 4, list = points );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      /*
       * If the component has no points on it, it must be the deleted one.
       */
      if (!nb_points) continue;
      /*
       * If the last point recorded so far does not match the first point of this
       * component, we have located a hole.
       */
      if (last_point != points [0].S_objid)
      {
        if (hole_index == -1)
        {
          /*
           * Its the first hole ... just mark it
           */
          hole_index = i;
          orient_first = points[0].S_objid;
          orient_second = points[nb_points - 1].S_objid;
        }
        else
        {
          /*
           * Second hole, we have a new composite curve from hole_index to i.
           */
          SKsplit_composite ( &msg_loc, components, hole_index, i, composite );
          hole_index = -1;
          
          /*
           * We can stop because, by design, we can only add one composite curve at a time.
           */
          break;
        }
      }
  
      last_point = points [nb_points - 1].S_objid;
    }
  
    /*
     * If the last point is not the first point then we have a hole at the beginning
     * of the composite.
     */  
    if ((last_point != first_point) && (hole_index != -1))
      SKsplit_composite ( &msg_loc, components, hole_index, i, composite );
    else
    {  
      /*
       * We must make sure that the composite is still sorted properly. Do not compute
       * the profile after sorting since there is an invalid (deleted) object in the 
       * geometry. That object will go away as soon as we are out of this method and
       * the CO will send the compute message.  Sorting has to be done only in the
       * case when only one interior hole was found i.e. a closed composite curve is
       * being opened. If the composite was split, then it is sorted.
       */
      if (hole_index != -1 && hole_index != nb_components)
      {
        stat_OM = om$send ( msg = message SKgeometry.SKgetmgr ( &msg_loc, 
								&mgr.objid ),
                            senderid = NULL_OBJID, 
                            targetos = composite->osnum, 
                            targetid = composite->objid );
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

        mgr.osnum = composite->osnum;
        SKsort_composite ( &msg_loc, &mgr, composite, orient_first, orient_second, 0 );
        EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );

      }
    }
  }
  
ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKcheck_composite" );
  return stat_OM;
}

/*

Name
  SKsplit_composite

Abstract

Synopsis
  long              *msg 	   return message			OUT
  struct GRid	    *components	   list of components			IN 
  int               first, last	   assembling order i.e. first and last 
  				   indices in the old composite curve	IN 
  struct GRid       *composite     existing composite curve		IN 

Description
 This routine splits an existing (SK)composite into two. The components
 for the new composite are in components [first:last-1]. The reason
 for having this routine is to prevent "broken" (i.e. open in two places) 
 composites after the deletion of an SKline or an SKarc.

Return Value

Notes

Index

Keywords

History
  ???????? : Henry Bequet  : created
  06/12/93 : Rajiv Agrawal : Massive cleanup and fixed an uninitialized variable
  		             owner_index in SKsplit_composite routine.  This was 
  		             a severe bug as the composite was getting assembled
  		             wrongly.  The bug showed up only when the code was 
  		             compiled in debug.

 */

SKsplit_composite ( msg, components, first, last, composite )
long                *msg;
struct GRid	    *components;
int                 first, last;
struct GRid         *composite;
{
  int             i, stat_OM;
  OM_S_CHANSELECT to_owners, to_comps;
  long            msg_loc, owner_index = OM_K_MAXINT;
  struct GRid     mgr, new_composite;
  short           action, mask;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  msg_loc = OM_S_SUCCESS;
  
  /*
   * We construct and copy the existing composite
   */
  stat_OM = om$construct_and_copy ( obj_osnum = composite->osnum, 
                                    objid = composite->objid, 
                                    p_objid = &new_composite.objid );
  EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  new_composite.osnum = composite->osnum;

  /*
   * We connect the new composite to the SKmgr. Don't forget to reset the
   * properties to tell that the new composite doesn't have a rigid owner (yet).
   */
  EMmake_chanselect ( GRconnector_to_owners, &to_owners );
  EMmake_chanselect ( GRcmpowner_to_components, &to_comps );

  stat_OM = om$send ( msg = message SKgeometry.SKgetmgr ( &msg_loc, 
							  &mgr.objid ),
                      senderid = NULL_OBJID, 
                      targetos = components [first].osnum, 
                      targetid = components [first].objid );
  EMerr_hndlr ( EMSerror ( stat_OM && msg_loc ), *msg, EMS_E_Fail, ret_end );
  mgr.osnum = composite->osnum;

  action = 0;
  mask = GR_RIGID_RELATIONSHIP;
  stat_OM = om$send ( msg = message GRgraphics.GRchgprops ( &msg_loc, 
							    &action, 
							    &mask ),
                      senderid = NULL_OBJID, 
                      targetos = new_composite.osnum, 
                      targetid = new_composite.objid );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &msg_loc,
				                              &mgr, 
							      &owner_index ), 
                      senderid = NULL_OBJID, 
                      targetos = composite->osnum, 
                      targetid = new_composite.objid );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  
  /*
   * We connect the specified components to the new composite
   */
  for (i = first; i < last; i++)
  {
    stat_OM = om$send ( msg = message GRconnector.GRdisconn ( &msg_loc, 
							      composite ),
                        targetos = components [i].osnum, 
                        targetid = components [i].objid, 
                        senderid = NULL_OBJID );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

    stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &msg_loc,
                                                                &new_composite, 
								&owner_index ), 
                        targetos = components [i].osnum, 
                        targetid = components [i].objid, 
                        senderid = NULL_OBJID );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKsplit_composite" );
  return stat_OM;
}

end implementation SKgeometry;
