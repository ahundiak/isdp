class implementation SKequal;

/*
Name
  SKcreate_geom

Abstract
   Create equality constraint geometry
  
Synopsis

Description

  
Return Value

Notes
  
Index

Keywords

History

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
	Sudha  :  12/21/93  :  fix tr#119301030. Flag is_circle is being set
			       to TRUE irrespective of geometry type.
        Satya  :  01/09/95  :  Fix for TR# 119313712 - Non Associative Arcs were
                               not handled at all. So the geometric handle used
                               to go hayway. Made lot of modifications and also
                               added a new function get_non_assoc_geom().
        Satya  :  01/09/95  :  Fix for TR# 119420327 - Profile Arcs placed 
			       across parallel Reference planes were not 
			       handled properly
        Satya  :  05/15/95  :  Lines and Circles in above cases are now handled here.
        		       
*/

%safe
#include <math.h>
#include <values.h>
%endsafe
#include "OMmacros.h"
#include "bserr.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include <alloca.h>
#include "marotmx.h"
#include "maptsxfor.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define FOURTH 3
#define FIFTH  4

#define PARL_REF_OBJ 1
#define NON_ASSOC_OBJ 2

#define IS_CIRCLE   1
#define IS_ARC      2
#define IS_NON_ARC  3
#define IS_NON_CIRCLE 4

#define X 0
#define Y 1
#define Z 2

from SKmgr import SKgetornt, SKget_xymat;
from SKvariable import SKgetvar, SKgetmgr;
from SKgmhndlpt import SKinit;
from GRcurve import GRmidpoint, GRendpts;
from NDnode import ASreturn_go;

extern GRclassid OPP_SKinterface_class_id, OPP_SKgeometry_class_id;
extern GRclassid OPP_SKline_class_id, OPP_SKcircle_class_id;
extern GRclassid OPP_SKarc_class_id,OPP_GR3dcirarc_class_id;
extern GRclassid OPP_SKasptgrnd_class_id,OPP_ASsource_class_id;
extern GRclassid OPP_EMSpointer_class_id;
extern GRclassid OPP_GR3dcircle_class_id,OPP_GR3dlineseg_class_id;
typedef GRobjid GRobjpair[2];
typedef IGRpoint IGRptpair[2];

%safe
static IGRlong get_non_assoc_geom();
%endsafe

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort *mattyp, xy_xyz_mattyp, disp_level;
  IGRuint count, num_eq_cnstrs;
  IGRint n, i, j, k, num_pairs, sgn1, sgn2;
  IGRint num_gmhndls;
  IGRlong one=1, index, stat_OM, msg_loc;
  IGRdouble *mat, len, disp_len, rotangle, ptcv_knots[4];
  IGRdouble *pt1, *pt2;
  IGRpoint midpt, squarepts[5], ptcv_poles[2];
  IGRptpair *ptvals;
  IGRvector vec, rot_vec, zaxis;
  IGRmatrix xy_xyz_mat, rotmat;
  GRobjid mgrobj, gmhndl, dumobj, geomid, *gmhndls,geomidtmp;
  GRobjpair *ptids;
  GRclassid myclass, objclass;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct GRparms ref_parms;
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_memcnstrs, chan_to_cnstrvars, chan_to_defpts;
  OM_S_OBJECT_LINKAGE *cnstrlist, ptptlist[3], ptlist[3];
  IGRpoint	dumpt,pt;
  GRobjid mgrobj1; 
  IGRint  flag;
  IGRint  size_obj;
  IGRuint count_obj;
  IGRint  curve_type;
  IGRboolean aflag = 0;
  IGRlong sts = 1;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  gmhndls = NULL;

  aflag = pwIsActivationOn();
  /*
   * Obtain the individual constraints that make up this constraint.
   * Only in the case of interface-equal constraint will there be
   * more than one constraint. In a plain equal constraint, this 
   * object is itself the constraint required.
   */

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
       superclassid = OPP_SKinterface_class_id) == OM_S_SUCCESS)
    {
    EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memcnstrs);
    num_eq_cnstrs = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_memcnstrs,
     count = &num_eq_cnstrs);
    EMerr_hndlr (!num_eq_cnstrs, *msg, EMS_E_InvalidCase, ret_end);

    cnstrlist = (OM_p_OBJECT_LINKAGE) alloca (num_eq_cnstrs *
                 sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!cnstrlist, *msg, EMS_E_NoStackMemory, ret_end);

    om$get_channel_objects (object = me, p_chanselect = &chan_to_memcnstrs,
     count = &num_eq_cnstrs, size = num_eq_cnstrs, list = cnstrlist);
    }
  else
    {
    cnstrlist = (OM_p_OBJECT_LINKAGE) alloca (sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!cnstrlist, *msg, EMS_E_NoStackMemory, ret_end);

    num_eq_cnstrs = 1;
    cnstrlist[0].S_objid = my_id;
    cnstrlist[0].osnum = OM_Gw_current_OS;
    }

  /*
   * Get the list of point variables defining this super equal
   * constraint. 
   */

  ptids = (GRobjpair *) alloca ((num_eq_cnstrs * 4) * sizeof (GRobjid));
  EMerr_hndlr (!ptids, *msg, EMS_E_NoStackMemory, ret_end);

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
  num_pairs = 0;
  for (i=0; i<num_eq_cnstrs; i++)
    {
    count = 0;
    om$get_channel_objects (objid = cnstrlist[i].S_objid,
     p_chanselect = &chan_to_cnstrvars, count = &count, size = 3,
     list = ptptlist);
    EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

    for (j=FIRST; j<=SECOND; j++)
      {
      count = 0;
      om$get_channel_objects (objid = ptptlist[j].S_objid,
       p_chanselect = &chan_to_cnstrvars, count = &count, size = 3,
       list = ptlist);
      EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

      for (k=FIRST; k<=SECOND; k++)
        ptids[num_pairs][k] = ptlist[k].S_objid;
      num_pairs++;
      }
    }

  /*
   * Get the world coordinate of all of my points. This array is looked
   * at as a pair of points. In case a pair belongs to an arc, the point
   * values of the pair are adjusted with a view to placing the handle
   * with the correct orientation by simulating the pair making up the
   * "correct" line segment. Same with circles.
   */

  ptvals = (IGRptpair *) alloca (num_pairs * 2 * sizeof (IGRpoint));
  EMerr_hndlr (!ptvals, *msg, EMS_E_NoStackMemory, ret_end);

  stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &mgrobj),
             targetid = ptids[FIRST][FIRST]);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc, 
             SK_OPT_GET_XY_TO_XYZ, mattyp, mat, &xy_xyz_mattyp, xy_xyz_mat),
             targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  for (i=0; i<num_pairs; i++)
  {
    geomid = NULL_OBJID;
    flag = NULL;
    curve_type = NULL;
    SKget_included_geom (&msg_loc, NULL, ptids[i], OPP_SKgeometry_class_id,&geomid);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    if(geomid != NULL_OBJID)
      geomidtmp = geomid;
    /*
     * In case of non associative objects and associative objects placed across parallel
     * reference planes the above function  give the geomid as NULL_OBJID -- Satya
     */
    if(geomid == NULL_OBJID)
    {
      get_non_assoc_geom(ptids[i][FIRST],&geomid,&flag);
      /* If the above function also could not determine the correct 
         graphic object, place the geometric handle on the last valid
         geometry selected -- TR# 119527566 -- Satya
      */
      if(geomid == NULL_OBJID)
      {
        geomid = geomidtmp;
      }  
    }
    if(flag != NON_ASSOC_OBJ)
    {
      om$get_classid (objid = geomid, p_classid = &objclass);
      if (om$is_ancestry_valid (subclassid = objclass,
          superclassid = OPP_SKline_class_id) != OM_S_SUCCESS)
      {
        if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_SKcircle_class_id) != OM_S_SUCCESS)
        {
          if (om$is_ancestry_valid (subclassid = objclass,
              superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS)
          {
	      curve_type = IS_ARC;
              count = 0;
              om$get_channel_objects (objid = geomid,
                                      p_chanselect = &chan_to_defpts, 
                                      size = 3, count = &count,
                                      list = ptlist);
              EMerr_hndlr (count != 3, *msg, EMS_E_InvalidArg, ret_end);
              ptids[i][FIRST] = ptlist[FIRST].S_objid;
              ptids[i][SECOND] = ptlist[THIRD].S_objid;
          }
        }
        else
          curve_type = IS_CIRCLE;
      }
    }
    /*
     * In case of associative objects , for geomid computed get the corresponding ptids
     */
    if((flag == PARL_REF_OBJ) && (curve_type != IS_ARC))
    {
        count_obj = 0;
        size_obj = 3;
        om$get_channel_objects (objid = geomid,
                              p_chanselect = &chan_to_defpts, 
                              size = size_obj, count = &count_obj,
                              list = ptlist);
        if(count_obj == 0)
          goto ret_end;
        ptids[i][FIRST] = ptlist[FIRST].S_objid;
        ptids[i][SECOND] = ptlist[SECOND].S_objid;
    }
    if(flag == NON_ASSOC_OBJ)  
    {
      om$get_classid (objid = geomid, p_classid = &objclass);
      if (om$is_ancestry_valid (subclassid = objclass,
         superclassid = OPP_GR3dlineseg_class_id) != OM_S_SUCCESS)
      {
        if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_GR3dcircle_class_id) != OM_S_SUCCESS)
        {
          if (om$is_ancestry_valid (subclassid = objclass,
              superclassid = OPP_GR3dcirarc_class_id) == OM_S_SUCCESS)
            curve_type = IS_NON_ARC;
        }
        else
          curve_type = IS_NON_CIRCLE;
      }
    }
    if(flag == PARL_REF_OBJ)
    {
      stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &mgrobj1),
                         targetid = ptids[SECOND][FIRST]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc, 
                         SK_OPT_GET_XY_TO_XYZ, mattyp, mat, &xy_xyz_mattyp, xy_xyz_mat),
                         targetid = mgrobj1);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    for (j=FIRST; j<=SECOND; j++)
    {
      stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                         SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat,
                         ptvals[i][j]), targetid = ptids[i][j]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    if(flag == NON_ASSOC_OBJ)
    {
        stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                          mattyp, mat, dumpt, pt), targetid = geomid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        for (k=0;k<=2;k++)
        {
          ptvals[1][0][k] = dumpt[k];
          ptvals[1][1][k] = pt[k];
    
        }
        if(curve_type == IS_NON_CIRCLE)
        {
          stat_OM = om$send (msg = message GRcurve.GRmidpoint (&msg_loc,
                             mattyp, mat, &ref_parms, midpt), targetid = geomid);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
          for(k=0;k<=2;k++)
            ptvals[1][1][k] = midpt[k];
        }
    }
   /*
    *  Here the ptvals should hold the vals of end points of the arcs , so calculte
    *  the same somehow for the non associative arc also
    */
    if ((curve_type == IS_ARC) || (curve_type == IS_NON_ARC))
    {
        stat_OM = om$send (msg = message GRcurve.GRmidpoint (&msg_loc,
                  mattyp, mat, &ref_parms, midpt), targetid = geomid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

        pt1 = ptvals[i][FIRST];
        pt2 = ptvals[i][SECOND];
        for (k=X; k<=Z; k++)
        {
          len = (pt2[k] - pt1[k]) / 2.0;
          pt1[k] = midpt[k] - len;
          pt2[k] = midpt[k] + len;
        }
    } 
    if ((curve_type == IS_CIRCLE) || (curve_type == IS_NON_CIRCLE))
    {
      pt1 = ptvals[i][FIRST];
      pt2 = ptvals[i][SECOND];
      for (k=X; k<=Z; k++)
        pt1[k] += (pt1[k] - pt2[k]);
    }
  }
  /*
   * For every set of two points compute a geometric handle point denoted
   * by a square on the segment.
   */

  stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, NULL, NULL,
             zaxis), targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  if(aflag)
  {
    /*
     * SKgetornt gets the axis vectors in ref-space. consciously transform them
     * to model space.
     */
    sts = RFtransform(md_env->md_env.matrix , md_env->md_env.matrix_type,
                      FALSE, NULL, NULL, zaxis, NULL);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  rotangle = M_PI / 2.0;
  MArotmx (&msg_loc, zaxis, &rotangle, rotmat);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id, 0, &num_gmhndls, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (num_gmhndls && num_gmhndls != num_pairs, *msg, EMS_E_InvalidArg, ret_end);

  if (!num_gmhndls)
    {
    EMinitvgcnstr (&msg_loc, md_env, &disp_attr, NULL, &cnstr_list);
    EMgetvgcnstr (NULL, NULL, md_env, disp_level, &disp_attr, NULL, NULL,
     &cnstr_list);

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    }

  disp_len /= 2.0;
  for (n=0; n<num_pairs; n++)
    {
    /*
     * Compute the 4 points for the square on the segment.
     */

    for (i=X; i<=Z; i++)
      {
      vec[i] = ptvals[n][SECOND][i] - ptvals[n][FIRST][i];
      midpt[i] = ptvals[n][FIRST][i] + vec[i] / 2.0;
      }
    BSnorvec (&msg_loc, vec);
    MAptsxform (&msg_loc, &one, rotmat, vec, rot_vec);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

    for (i=FIRST; i<=FOURTH; i++)
      {
      sgn1 = (i == FIRST || i == FOURTH) ? 1.0 : -1.0;
      sgn2 = (i == FIRST || i == SECOND) ? 1.0 : -1.0;
      for (k=X; k<=Z; k++)
        squarepts[i][k] = midpt[k] + 
                           (sgn1 * disp_len * vec[k]) + 
                           (sgn2 * disp_len * rot_vec[k]);
      }
    OM_BLOCK_MOVE (squarepts[FIRST], squarepts[FIFTH], sizeof (IGRpoint));
    if(aflag)
    {
      /*
       * The crosspts have been computed in model space. But as the geometric
       * handle's SKinit needs them in ref-space, transform them to ref-space
       * by the inverse of mat.
       */
       int num_pts = 5;
       sts = RFinverse_pts( md_env->md_env.matrix, num_pts, squarepts);
       EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
    }


    BSptcvgen (midpt, 2, FALSE, &ptcv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    if (!num_gmhndls)
      {
      cnstr_list.geometry = (IGRchar *) &ptcv;
      stat_OM = om$construct (classid = OPP_SKgmhndlpt_class_id,
                 msg = message GRgraphics.GRconstruct (&cnstr_list),
                 p_objid = &gmhndl);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      index = OM_K_MAXINT;
      stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                 &my_grid, &index), targetid = gmhndl);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {
      gmhndl = gmhndls[n];

      post_info.construct_flag = FALSE;
      stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
                 &post_info, (IGRchar *) &ptcv, &dumobj), targetid = gmhndl);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = om$send (msg = message GRvg.GRchgdp (&msg_loc, &disp_attr),
                 targetid = gmhndl);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    stat_OM = om$send (msg = message SKgmhndlpt.SKinit (&msg_loc, NULL,
               SK_CNSTR_EQUALLEN, 5, squarepts, 0, NULL), targetid = gmhndl);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  if (gmhndls)
    om$dealloc (ptr = gmhndls);

  EMWRAPUP (*msg, stat_OM, "SKequal.SKcreate_geom");
  return (stat_OM);
}

/*
Name
  get_non_assoc_geom

Abstract
  Get the Geometric Objects ID (geomid) 
  
Synopsis

Description
   In case of non associative objects and associative objects placed across parallel
   reference planes the computation of geometric objid is done here
  
Return Value
   stat_OM = OM_S_SUCCESS -- If everything is successful.
   stat_OM = FALSE -- Failure case
Notes
  
Index

Keywords

History

	Satya  : 03/17/94  : Creation
	Satya  : 06/27/94  : Included a case wherein Circular Arcs placed across Reference
	                     Planes are also handled here
	Satya  : 05/15/95  : Lines and Circles were not handled previously.
	                     Non Assoc objects can also be part of EMSpointer objects in 
	                     addition to ASsource objects. This was not handled previously. 
*/ 
	
IGRlong get_non_assoc_geom(ptvarid,geomid,flag)
GRobjid	*geomid;  /** INPUT **/
GRobjid ptvarid;  /** OUTPUT **/
IGRint  *flag;
{

  IGRint	  count,count1,i,j;
  OM_S_CHANSELECT chan_to_cnstrs, chan_to_parent;  
  GRspacenum	  dum_os;
  IGRmatrix       planmat;
  GRclassid       objclass;
  GRobjid	  cnstr_id,src_id;
  struct GRid	  non_assoc_obj;
  IGRlong	  stat_OM;
  IGRshort	  mattyp;
  
  stat_OM = OM_S_SUCCESS;
  EMmake_chanselect (SKvariable_to_constraints, &chan_to_cnstrs);
  EMmake_chanselect (NDfather_father, &chan_to_parent);
  count = 0;
  om$get_channel_count (objid = ptvarid, p_chanselect = &chan_to_cnstrs,
                        count = (OMuint *)&count);
  if (!count)
    goto ret_end;
  for (i=0; i<count; i++)
  {
    stat_OM = om$get_objid_at_index (objid = ptvarid, p_chanselect = &chan_to_cnstrs, 
                           index = i, objidaddr = &cnstr_id, osnumaddr = &dum_os);
    if ( !(1 & stat_OM) ) goto ret_end; 
    stat_OM = om$get_classid (objid = cnstr_id, p_classid = &objclass);
    if ( !(1 & stat_OM) ) goto ret_end; 
    if (om$is_ancestry_valid (subclassid = objclass,
           superclassid = OPP_SKasptgrnd_class_id) == OM_S_SUCCESS)
    {
      count1=0;
      om$get_channel_count (objid = cnstr_id, p_chanselect = &chan_to_parent,
                        count = (OMuint *)&count1);
      if(!count1)
      { 
      	stat_OM = FALSE;
        goto ret_end;
      }
      for(j=0; j<count1; j++)
      {
        stat_OM = om$get_objid_at_index (objid = cnstr_id, 
                    p_chanselect = &chan_to_parent, 
                    index = j, objidaddr = &src_id, osnumaddr = &dum_os);
        if ( !(1 & stat_OM) ) goto ret_end; 
        stat_OM = om$get_classid (objid = src_id, p_classid = &objclass);
        if ( !(1 & stat_OM) ) goto ret_end; 
        /*
         * In case of Profiles placed across parallel reference planes this is the correct
         * geomid -- Satya -- 27th June 1994
         */
        if ( (om$is_ancestry_valid (subclassid = objclass,
             superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS)  ||
             (om$is_ancestry_valid (subclassid = objclass,
             superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS) || 
             (om$is_ancestry_valid (subclassid = objclass,
             superclassid = OPP_SKline_class_id) == OM_S_SUCCESS) )
        {
          *geomid = src_id;
          *flag = PARL_REF_OBJ;
          goto ret_end;
        }
        if ((om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS) ||
            (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMSpointer_class_id) == OM_S_SUCCESS))
        {
          stat_OM = om$send (msg = message NDnode.ASreturn_go (&non_assoc_obj, &mattyp,planmat),
				targetid = src_id,targetos = dum_os,senderid = NULL_OBJID);
          if ( !(1 & stat_OM) ) goto ret_end; 
          stat_OM = om$get_classid (objid = non_assoc_obj.objid, p_classid = &objclass);
          if ( !(1 & stat_OM) ) goto ret_end; 
          if ( (om$is_ancestry_valid (subclassid = objclass,
               superclassid = OPP_GR3dcirarc_class_id) == OM_S_SUCCESS) ||
               (om$is_ancestry_valid (subclassid = objclass,
               superclassid = OPP_GR3dcircle_class_id) == OM_S_SUCCESS) || 
               (om$is_ancestry_valid (subclassid = objclass,
               superclassid = OPP_GR3dlineseg_class_id) == OM_S_SUCCESS) )
          {
            *geomid = non_assoc_obj.objid;
            *flag = NON_ASSOC_OBJ;
	    goto ret_end;
          }
        }
      }
    }
  }
ret_end:
	return(stat_OM);  
}
end implementation SKequal;
