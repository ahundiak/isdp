class implementation SKvariable;

#include <alloca.h>
#include <math.h>
#include "exmacros.h"
#include "dp.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"
#include "nddef.h"
#include "ndmacros.h"

from SKmgr       import SKmergemgr, SKconstr_update, SKmgrprops, SKget_xymat;
from SKcompcurve import SKclose;
from GRconnector import GRrigidconn, GRdisconn;
from SKgeometry  import SKgetmgr, SKrecompute_yourself;
from GRgraphics  import GRconstruct, GRdelete, GRdisplay;
from GRconic     import GRgetarc;
from NDnode      import NDget_objects, NDchange_connect, NDchange_node;

extern GRclassid OPP_SKcompcurve_class_id, OPP_SKpoint_class_id;
/*

Name
  SKmerge_curves

Abstract

Synopsis
  long *msg		The return code					(OUT)
  struct GRid *var1,
              *var2	The list of variables/points to be merged	(IN)

Description
 This routine merges the curves connected to the variables. Those curves must be SKsomething 
 If they don't belong to the same SKmgr then SKmgr.SKmergemgr will be called first.
 If none of them is a composite curve then a composite curve will be created.
 If both of them are composite curves then one of them will be deleted. The
 point given in var2 must coincide in space with his var1 counterpart. 

Return Value

Notes
 1. The profile on which var1 lies controls the direction of the merged composite 
    curve.
 2. var1 is deleted upon completion of this routine if mgr1 and mgr2 are different.
    var2 is deleted if mgr1 and mgr2 are same (i.e. a closure is performed).
 3. The SKmgr of var2 (mgr2) is merged with SKmgr of var1 (mgr1) and
    deleted if it is different from mgr1.

 KNOWN BUGS:
   Does not attach the SKptvars to the SKmgr in the proper order when the components
   are added to form a new composite curve.
   Does not use the standard EMaddtocomp method to form a new composite curve.
   Sometimes a bspline can get messed up.
    
Index

Keywords
  profile,wireframe,merge

History
  ???????? : Henry Bequet  : Creation.
  05/27/93 : Rajiv Agrawal : Added finding orientation of the first curve on which var1
             lies so that the composite after merge has the same direction.
  11/04/93 : Rajiv Agrawal : Added GRIS_PLANAR property when a new compcurve is constructed.
  01/12/94 : Rajiv Agrawal : Index of var1 on the constraint is found before the constraint
                             is transferred to var2. (TR#119314981)
  02/12/94 : Rajiv Agrawal : In case when the profile is SKclosed, then remove constraints one
                             by one. (TR#119417119)

*/

SKmerge_curves (long *msg, struct GRid *var1, struct GRid *var2)
{
  int              i, j, stat_OM, erase = 0;
  OMuint	   count;  
  long             loc_msg, owner_index;
  struct GRid      mgr1, mgr2, composite, curve, curve1, curve2;
  GRclassid        classid;
  GRobjid          *curve_list;
  GRobjid     	   orient_first, orient_second;
  struct GRmd_env  md_env;
  OM_S_CHANSELECT  to_geoms, to_defpts, to_comps, to_constrs, to_vars, 
                   to_super_constrs, to_member_constrs, to_children;
  double           point1 [3], point2 [3];
  enum GRdpmode    dpmode;
  IGRboolean	   front_merge;
  GRobjid          *conflict_cnstr_objs = NULL;
  int              num_conflict_cnstr;
 
  
  *msg = EMS_S_Success;

  EMmake_chanselect ( SKvariable_to_geometries, &to_geoms );
  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
  EMmake_chanselect ( SKvariable_to_constraints, &to_constrs );
  EMmake_chanselect ( SKconstraint_to_variables, &to_vars );
  EMmake_chanselect ( SKconstraint_to_super_constrs, &to_super_constrs );
  EMmake_chanselect ( SKinterface_to_member_constrs, &to_member_constrs );
  EMmake_chanselect ( GRcmpowner_to_components, &to_comps );
  EMmake_chanselect ( NDchildren_children, &to_children );
 
  ex$get_cur_mod ( id = &md_env.md_id.objid, osnum = &md_env.md_id.osnum );
  EMidmatrix ( &loc_msg, &md_env.md_env.matrix_type, md_env.md_env.matrix );

  /*
   * Check it we are dealing with the same mgr.  If the managers are different, merge
   * them. This deletes mgr2.
   */
  mgr1.osnum = mgr2.osnum = var1->osnum;
  stat_OM = om$send ( msg = message SKvariable.SKgetmgr ( &loc_msg, &mgr1.objid ),
      senderid = NULL_OBJID, targetos = var1->osnum, targetid = var1->objid );
  EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
  stat_OM = om$send ( msg = message SKvariable.SKgetmgr ( &loc_msg, &mgr2.objid ),
      senderid = NULL_OBJID, targetos = var2->osnum, targetid = var2->objid );
  EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
  if (mgr1.objid != mgr2.objid)
  {
    stat_OM = om$send ( msg = message SKmgr.SKmergemgr ( &loc_msg, (short)0, &md_env, mgr2.objid ),
        senderid = NULL_OBJID, targetos = mgr1.osnum, targetid = mgr1.objid );
    EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
  }
  
  if (var1->objid != var2->objid)
  {
    /*
     * Check if the points we are trying to merge are identical in space
     */
    stat_OM = om$send ( msg = message SKvariable.SKgetvar ( &loc_msg, (unsigned short)0,
        &md_env.md_env.matrix_type, md_env.md_env.matrix, point1 ),
        senderid = NULL_OBJID, targetos = var1->osnum, targetid = var1->objid );
    EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
    stat_OM = om$send ( msg = message SKvariable.SKgetvar ( &loc_msg, (unsigned short)0,
        &md_env.md_env.matrix_type, md_env.md_env.matrix, point2 ),
        senderid = NULL_OBJID, targetos = var2->osnum, targetid = var2->objid );
    EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
    if (point1 [0] != point2 [0] || point1 [1] != point2 [1] || point1 [2] != point2 [2])
    {
      erase = 1;
      dpmode = GRbehe;
      om$send ( msg = message GRgraphics.GRdisplay ( &loc_msg,
          &md_env.md_env.matrix_type, md_env.md_env.matrix, &dpmode, &md_env.md_id ), 
          senderid = NULL_OBJID, targetid = mgr1.objid, targetos = mgr1.osnum );
    }

    /*
     * Make sure we have a composite curve
     */
    count = 0;
    curve_list = (GRobjid *)NULL;
    SKfind_curves ( &loc_msg, &count, &curve_list, var1->objid, &mgr1 );
    EMerr_hndlr ( EMSerror ( loc_msg ), *msg, EMS_E_Fail, ret_end );
    EMerr_hndlr (!curve_list, *msg, EMS_E_Fail, ret_end );
    curve1.osnum = mgr1.osnum;
    curve1.objid = curve_list [0];
    /*
     * Make sure we are not trying to add a point...
     */
    {
      GRclassid ClassId;

      stat_OM = om$get_classid ( osnum = curve1.osnum, objid = curve1.objid,
        p_classid = &ClassId );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      if (om$is_ancestry_valid ( subclassid = ClassId,
            superclassid = OPP_SKpoint_class_id ) == OM_S_SUCCESS)
      {
        /*
         * We just make sure that we don't have one and only one profile...
         */
        SKsplit_profile ( msg, &mgr1 );
        goto ret_end;
      }
    }

    count = 0;
    free ( curve_list );
    curve_list = (GRobjid *)NULL;
    SKfind_curves ( &loc_msg, &count, &curve_list, var2->objid, &mgr1 );
    EMerr_hndlr ( EMSerror ( loc_msg ), *msg, EMS_E_Fail, ret_end );
    EMerr_hndlr ( !curve_list, *msg, EMS_E_Fail, ret_end );
    curve2.osnum = mgr1.osnum;
    curve2.objid = curve_list [0];
    free ( curve_list );
    curve_list = (GRobjid *)NULL;
  }
  else
  {
    /*
     * The curves are both connected to the variable (var1 == var2)
     */
    count = 0;
    free ( curve_list );
    curve_list = (GRobjid *)NULL;
    SKfind_curves ( &loc_msg, &count, &curve_list, var2->objid, &mgr1 );
    EMerr_hndlr ( EMSerror ( loc_msg ) && (count == 2), *msg, EMS_E_Fail, ret_end );
    EMerr_hndlr ( !curve_list, *msg, EMS_E_Fail, ret_end );
    curve1.osnum = curve2.osnum = mgr1.osnum;
    curve2.objid = curve_list [0];
    curve2.objid = curve_list [1];
    free ( curve_list );
    curve_list = (GRobjid *)NULL;
  }

  if (curve1.objid == curve2.objid)
  {
    /*
     * just close the profile since both ptvars lie on the same curve.
     */
    stat_OM = om$send (msg = message SKcompcurve.SKclose ( &loc_msg, NULL, 
                              &md_env,  &num_conflict_cnstr, &conflict_cnstr_objs ), 
                       senderid = NULL_OBJID,
                       targetid = curve1.objid, targetos = curve1.osnum );
    if (loc_msg == EMS_I_Redundant)
    {
       /*
        * If there are some redundant constraints, then keep deleting
        * till the closure succeeds.
        */
       while (num_conflict_cnstr)
       {
          if (!erase)
          {
            dpmode = GRbehe;
            stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &loc_msg,
                                       &md_env.md_env.matrix_type, md_env.md_env.matrix, 
                                       &dpmode, &md_env.md_id ), 
                                targetos = curve1.osnum, 
                                targetid = conflict_cnstr_objs [0],
                                senderid = NULL_OBJID );
            EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), stat_OM, OM_E_ABORT, ret_end );
          }
          stat_OM = om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, &md_env ),
                              targetos = curve1.osnum, 
                              targetid = conflict_cnstr_objs [0],
                              senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_OMerror, ret_end );
          if (conflict_cnstr_objs)
          {
             om$dealloc (ptr = conflict_cnstr_objs);
             conflict_cnstr_objs = NULL;
          }
          num_conflict_cnstr = 0;
          stat_OM = om$send (msg = message SKcompcurve.SKclose ( &loc_msg, NULL, 
                                    &md_env,  &num_conflict_cnstr, &conflict_cnstr_objs ), 
                             senderid = NULL_OBJID,
                             targetid = curve1.objid, targetos = curve1.osnum );
          EMerr_hndlr (EMSerror (stat_OM & loc_msg), stat_OM, OM_E_ABORT, ret_end);
       }
    }
    else
      EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), stat_OM, OM_E_ABORT, ret_end );
    composite = curve1;
  }
  else
  {
    /*
     * The two curves to be merged are different. Determine the orientation for 
     * sorting the merged composite curve.
     */
    front_merge = FALSE;
    stat_OM = SKfind_origin (&loc_msg, *var1, &orient_first, &orient_second, TRUE);
    EMerr_hndlr (EMSerror (stat_OM & loc_msg), *msg, EMS_E_Fail, ret_end);
    /*
     * if the addition is being done at the front, then we need to
     * find the orientation from the curve being added.
     */
    if (orient_first == var1->objid)
    {
      front_merge = TRUE;
      stat_OM = SKfind_origin (&loc_msg, *var2, &orient_first, &orient_second, TRUE);
      EMerr_hndlr (EMSerror (stat_OM & loc_msg), *msg, EMS_E_Fail, ret_end);
      /*
       * if the first point turns out to be same as the one being
       * merged, then we need the back of the curve.
       */
      if (orient_first == var2->objid)
      {
        stat_OM = SKfind_origin (&loc_msg, *var2, &orient_second, &orient_first, FALSE);
        EMerr_hndlr (EMSerror (stat_OM & loc_msg), *msg, EMS_E_Fail, ret_end);
      }
    }
/* printf("orient first = %d, second = %d\n", orient_first, orient_second);  */
 
    /*
     * Check if a new composite curve has to be created.
     */  
    om$get_classid ( osnum = curve1.osnum, objid = curve1.objid, p_classid = &classid );
    if (om$is_ancestry_valid ( superclassid = OPP_SKcompcurve_class_id,
                               subclassid = classid ) == OM_S_SUCCESS)
    {
      composite.objid = curve1.objid; 
      composite.osnum = curve1.osnum;
      curve.objid = curve2.objid; 
      curve.osnum = curve2.osnum;
    }
    else
    {
      om$get_classid ( osnum = curve2.osnum, objid = curve2.objid, p_classid = &classid );
      if (om$is_ancestry_valid ( superclassid = OPP_SKcompcurve_class_id,
                                 subclassid = classid ) == OM_S_SUCCESS)
      {
        composite.objid = curve2.objid; 
        composite.osnum = curve2.osnum;
        curve.objid = curve1.objid; 
        curve.osnum = curve1.osnum;
      }
      else
      {
        struct GRvg_construct construct_list;
        
        construct_list.msg = &loc_msg;
        construct_list.env_info = &md_env;
        construct_list.newflag = 0;
        construct_list.level = 0;
        construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;
        construct_list.geometry = (char *)NULL;      
        construct_list.class_attr = NULL;
        construct_list.display = (struct IGRdisplay *)NULL;
        construct_list.name = (char *)NULL;
        composite.osnum = curve1.osnum;
        stat_OM = om$construct ( classid = OPP_SKcompcurve_class_id,
                                 msg = message GRgraphics.GRconstruct ( &construct_list ),
                                 osnum = curve1.osnum, p_objid = &composite.objid );
        EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
  
        /*
         * We disconnect the curve from the manager and then we connect the composite
         */
        stat_OM = om$send ( msg = message GRconnector.GRdisconn ( &loc_msg, &mgr1 ),
                            targetos = curve1.osnum, 
                            targetid = curve1.objid, 
                            senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
        owner_index = OM_K_MAXINT;
        stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &loc_msg,
                                  &mgr1, &owner_index ), 
                            targetos = composite.osnum, 
                            targetid = composite.objid, 
                            senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
        stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &loc_msg,
                                  &composite, &owner_index ), 
                            targetos = curve1.osnum, 
                            targetid = curve1.objid, 
                            senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
        curve.osnum = curve2.osnum; 
        curve.objid = curve2.objid;
      }
    }
  
    /*
     * For each variable pair, we connect the geometry of the second to the first one
     * then we connect the constraints and delete the second one. If the variables are
     * the same then we skip that part.  
     * All this technology exists in SKvariable.SKswap.  In the future we should try
     * to call that method.  (TO BE DONE)
     */
    if (var1->objid != var2->objid)
    {
      OMuint              nb_constrs;
      OM_S_OBJECT_LINKAGE *constraints, *list;
  
      stat_OM = om$get_channel_count ( osnum = var1->osnum, objid = var1->objid,
                                       p_chanselect = &to_constrs, count = &nb_constrs );
      EMerr_hndlr ( EMSerror ( stat_OM ) && nb_constrs, *msg, EMS_E_Fail, ret_end );
      constraints = (OM_S_OBJECT_LINKAGE *)alloca ( nb_constrs * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = constraints, size = nb_constrs, 
                                         count = &nb_constrs, 
                                         osnum = var1->osnum, 
                                         objid = var1->objid, 
                                         p_chanselect = &to_constrs );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );

      for (j = 0; j < nb_constrs; j++)
      {
        /*
         * Any constraint that didn't get deleted should be transferred to var2.  
         * The index where var1 used to be attached needs to be preserved since
         * some constraints rely on the order.  (TR#119314981)
         */
        if (om$is_objid_valid ( osnum = constraints [j].osnum, 
                                objid = constraints [j].S_objid ) == OM_S_SUCCESS)
        {
          OMuint tmp_index;
          stat_OM = om$get_index (osnum_c = constraints[j].osnum,
                                  objid_c = constraints[j].S_objid,
                                  p_chanselect = &to_vars, 
                                  objid = var1->objid, osnum2 = var1->osnum, 
                                  indexaddr = &tmp_index );
          EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
          stat_OM = om$send (msg = message Root.connect ( to_constrs, tmp_index,
                                   constraints [j].S_objid, constraints [j].osnum, 
                                   to_vars, 0 ), 
                             targetid = var2->objid, 
                             targetos = var2->osnum, 
                             senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
        }
      }

      /*
       * Attach the old geometric elements of var1 to var2.  
       * If the merge was done at the front, the geometries from var1 have to 
       * be attached after the geometries of var2 to maintain continuity.
       */
      stat_OM = om$get_channel_count ( osnum = var1->osnum, objid = var1->objid,
                                       p_chanselect = &to_geoms, count = &count );
      EMerr_hndlr ( EMSerror ( stat_OM ) && count, *msg, EMS_E_Fail, ret_end );
      list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = list, size = count, 
                                         count = &count, osnum = var1->osnum, 
                                         objid = var1->objid, 
                                         p_chanselect = &to_geoms );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      owner_index =  front_merge ? OM_K_MAXINT : 0;
      for (j = 0; j < count; j++)
      {
        int                 to_defpts_index; 
        OMuint 		    tmp_count;
        OM_S_OBJECT_LINKAGE tmp_points [4];
  
        stat_OM = om$get_channel_objects ( osnum = list [j].osnum, objid = list [j].S_objid,
                                           p_chanselect = &to_defpts, 
                                           size = 4, count = &tmp_count, 
                                           list = tmp_points );
        to_defpts_index =  (var1->objid == tmp_points [0].S_objid) ? 0 :
                           (var1->objid == tmp_points [1].S_objid) ? 1 : 
                           (var1->objid == tmp_points [2].S_objid) ? 2 : 3;
        
        stat_OM = om$send (msg = message Root.connect ( to_geoms, to_defpts_index,
                                 list [j].S_objid, list [j].osnum, to_defpts, owner_index), 
                           targetid = var2->objid, 
                           targetos = var2->osnum, 
                           senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
      }

      /*
       * Delete var1 .....
       */
      stat_OM = om$send (msg = message SKvariable.SKintdelete 
                               ( &loc_msg, NULL, &md_env ), 
                         targetid = var1->objid, 
                         targetos = var1->osnum, 
                         senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
      stat_OM = om$send (msg = message Root.delete ( 0 ), 
                         targetid = var1->objid, 
                         targetos = var1->osnum, 
                         senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
    }
    
    /*
     * We attach/merge composite and curve
     */
    om$get_classid ( osnum = curve.osnum, objid = curve.objid, p_classid = &classid );
    owner_index = OM_K_MAXINT;
    if (om$is_ancestry_valid ( superclassid = OPP_SKcompcurve_class_id,
                               subclassid = classid ) == OM_S_SUCCESS)
    {
      OMuint              count;
      int		  num_children;
      OM_S_OBJECT_LINKAGE *list;
      struct GRid         *children, *buffer;

      /*
       * Move the components
       */  
      stat_OM = om$get_channel_count ( osnum = curve.osnum, objid = curve.objid,
       p_chanselect = &to_comps, count = &count );
      EMerr_hndlr ( EMSerror ( stat_OM ) && count, *msg, EMS_E_Fail, ret_end );
      list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = list, size = count, 
          count = &count, osnum = curve.osnum, objid = curve.objid, 
          p_chanselect = &to_comps );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  
      for (i = 0; i < count; i++)
      {
        stat_OM = om$send ( msg = message GRconnector.GRdisconn ( &loc_msg, &curve ),
            targetos = list [i].osnum, targetid = list [i].S_objid, senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
        stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &loc_msg,
            &composite, &owner_index ), targetos = list [i].osnum, 
            targetid = list [i].S_objid, senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
      }
  
      /*
       * Move the children
       */
      stat_OM = om$send ( msg = message NDnode.NDget_objects ( ND_CHILDREN | ND_IN_BUF,
          NULL, 0, &buffer, 0, MAXINT, &num_children ), targetid = curve.objid,
          targetos = curve.osnum, senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      children = (struct GRid *)alloca ( num_children * sizeof ( struct GRid ) );
      memcpy ( (char *)children, (char *)buffer, num_children * sizeof ( struct GRid ) );

      for (i = 0; i < num_children; i++)
      {      
        stat_OM = om$send ( msg = message NDnode.NDchange_connect ( 1, &curve, &composite ),
            targetos = children [i].osnum, targetid = children [i].objid, 
            senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      }
      
      stat_OM = om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, &md_env ),
          targetos = curve.osnum, targetid = curve.objid, senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
    }
    else
    {
      stat_OM = om$send ( msg = message GRconnector.GRdisconn ( &loc_msg, &mgr1 ),
          targetos = curve.osnum, targetid = curve.objid, senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
      stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &loc_msg,
          &composite, &owner_index ), targetos = curve.osnum, 
          targetid = curve.objid, senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM && loc_msg ), *msg, EMS_E_Fail, ret_end );
    }

    /*
     * If the orient_first or second is *var1 then make it equal to *var2
     */
    if (orient_first == var1->objid)
      orient_first = var2->objid;
    else if (orient_second == var1->objid)
      orient_second = var2->objid;

    stat_OM = SKsort_composite ( &loc_msg, &mgr1, &composite, orient_first,
                                 orient_second, 1 );
    EMerr_hndlr ( EMSerror ( loc_msg && stat_OM ), *msg, EMS_E_Fail, ret_end );
  }

  if (erase)
  {
    dpmode = GRbd;
    om$send ( msg = message GRgraphics.GRdisplay ( &loc_msg,
        &md_env.md_env.matrix_type, md_env.md_env.matrix, &dpmode, &md_env.md_id ), 
        senderid = NULL_OBJID, targetid = mgr1.objid, targetos = mgr1.osnum );
  }

  stat_OM = om$send ( msg = message NDnode.NDchange_node ( NULL ),
      targetos = mgr1.osnum, targetid = mgr1.objid, senderid = NULL_OBJID );
  EMerr_hndlr ( EMSerror ( loc_msg && stat_OM ), *msg, EMS_E_Fail, ret_end );
      
ret_end:
  if (conflict_cnstr_objs)
    om$dealloc (ptr = conflict_cnstr_objs);

  EMWRAPUP ( *msg, stat_OM, "SKmerge_curves" );
  return stat_OM;
}

/*

Name
  SKfind_origin

Abstract
  Finds the first and second SKptvar of a composite curve given a point on it.
  
Synopsis
  long    	*msg	  Return code 						OUT
  struct GRid 	var	  Some point from the compcurve  			IN
  GRobjid 	*first, 
                *second   The SKpoints defining the required component       	OUT
  IGRboolean 	begin     Flag telling whether the front or 
                          the back-end is needed  				IN

Description

Return Value

Notes

Index

Keywords
  profile

History
  05/27/93 : Rajiv Agrawal : created

 */

SKfind_origin(msg, var, first, second, begin)
long            *msg;
struct GRid 	var;
GRobjid      	*first, *second;
IGRboolean 	begin;
{
  OMuint		count, num_comps, comp_no;
  long			stat_OM;
  GRobjid		geomid, compid;
  GRspacenum            geomos, compos;
  GRclassid		comp_class;
  OM_S_OBJECT_LINKAGE   points[4];
  OM_S_CHANSELECT       to_geoms, to_defpts, to_owners, chan_to_comps;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect ( SKvariable_to_geometries, &to_geoms );
  EMmake_chanselect ( GRconnector_to_owners, &to_owners );
  EMmake_chanselect ( GRcmpowner_to_components, &chan_to_comps);

  stat_OM = om$get_channel_count (objid = var.objid, osnum = var.osnum,
                                  p_chanselect = &to_geoms, count = &count);
  if (count)
  {
    stat_OM = om$get_objid_at_index ( objid = var.objid, osnum = var.osnum, 
                                      p_chanselect = &to_geoms, index = 0, 
                                      objidaddr = &geomid, osnumaddr = &geomos );
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
    stat_OM = om$get_channel_count (objid = geomid, osnum = geomos,
                                    p_chanselect = &to_owners, count = &count);
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
    if (count)
    {
      stat_OM = om$get_objid_at_index ( objid = geomid, osnum = geomos,
                                        p_chanselect = &to_owners, index = 0, 
                                        objidaddr = &compid, osnumaddr = &compos );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      /*
       * Check if the owner is a SKcompcurve.  In case of single SK-elements,
       * SKmgr is directly owns the geometry.  In that case, we do not change geomid.
       */
      stat_OM = om$get_classid ( osnum = compos, objid = compid, p_classid = &comp_class );
      if (om$is_ancestry_valid ( subclassid = comp_class,
              superclassid = OPP_SKcompcurve_class_id) == OM_S_SUCCESS)
      {
        stat_OM = om$get_channel_count ( objid = compid, osnum = compos,
                                         p_chanselect = &chan_to_comps, count = &num_comps);
        EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
        
        /*
         * switch the component no. depending on whether the front-end or
         * the back-end is needed.
         */
        if (begin)
          comp_no = 0;
        else
          comp_no = num_comps - 1;
          
        stat_OM = om$get_objid_at_index ( objid = compid, osnum = compos, 
           p_chanselect = &chan_to_comps, index = comp_no, 
           objidaddr = &geomid, osnumaddr = &geomos );
        EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      }
      /*
       * find the points connected to the first component.
       */
      EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
      stat_OM = om$get_channel_objects ( osnum = geomos, objid = geomid, 
                                         p_chanselect = &to_defpts, 
                                         count = &count, size = 4, list = points );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      *first = points[0].S_objid;
      *second = points[count-1].S_objid;
    }
  }
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "SKfind_origin");
  return stat_OM;
}

end implementation SKvariable;
