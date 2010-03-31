class implementation SKmgr;

#include <alloca.h>
#include <math.h>
#include "igrtypedef.h"
#include "emsdef.h"
#include "msmacros.h"
#include "dimplcmacros.h"
#include "dimdef.h"
#include "dimangular.h"
#include "comisc.h"
#include "EMSopt.h"
#include "expression.h"
#include "ECmsg.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bslldist.h"

#define FIRST       0
#define CLOCK_IS_ON 0

from SKvariable	  import SKgetvar;

extern GRclassid OPP_SKpoint_class_id, OPP_SKline_class_id, OPP_SKarc_class_id, OPP_SKcircle_class_id;
extern GRclassid OPP_SKcompcurve_class_id;
extern GRclassid OPP_SKifptpt_class_id, OPP_SKhvptpt_class_id, OPP_SKasptgrnd_class_id;
extern GRclassid OPP_SKradial_class_id, OPP_SKequal_class_id;
extern GRclassid OPP_SKfixang_class_id, OPP_SKrelang_class_id;
extern GRclassid OPP_SKparallel_class_id, OPP_SKnormal_class_id, OPP_SKtangency_class_id;
extern GRclassid OPP_SKcollinear_class_id, OPP_SKifcol_class_id;
extern GRclassid OPP_SKhorizvert_class_id;
extern GRclassid OPP_SKexplicit_class_id;

/*

Name
  SKauto_constrain

Abstract

Synopsis

Description
    Finds and adds the following constraints to a wireframe element or a profile.
    1. Horizontal/vertical
    2. Normal and tangency 
    3. Equality between two line segements.
    4. Equality between two arcs
    5. Parallelism between two line segements.
    6. Single parallel dimensions.
    7. Angular dimensions.
    8. Ground constraints.
    9. Self constraints on arcs - 90 and 270 degrees only.

Return Value

Notes

Index

Keywords

History
  12/12/92 : Rajiv Agrawal : created
  07/02/93 : Sudha         : Modified for BSprototypes ansification
  10/20/93 : Rajiv Agrawal : Added code to Autoconstrain all the underlying 
			     components of the profile.
  01/20/94 : Rajiv Agrawal : Under severe pressure from the ERB, removed the 
			     clock.  Maybe somebody will allow it for EMS 4.  
			     (TR119415936)
  01/09/95  : Satya         : Fix for TR 119416368 -- Avoid going into
                             place_constraint method for collinear line segments

 */


/*
 * This structure represents an SKline, SKarc, or SKbspline.
 */
struct component
{
  GRobjid   objid	/* The objid of the component				*/;
  IGRushort gmtype	/* geometry type i.e. Line, Arc, or Bspline		*/;
  int	    num_pts	/* number of connected ptvars				*/;
  GRobjid   p[4]	/* The first, second, third, and fourth SKptvar	objid	*/;
};

#if CLOCK_IS_ON
#define UPDATE_CLOCK \
     if (cnstr_grid.objid != NULL_OBJID) \
     { \
        dof--; \
        ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` ); \
        if (clock_active) \
          SKclock_cursor(); \
     }
#else
#define UPDATE_CLOCK \
     if (cnstr_grid.objid != NULL_OBJID) \
     { \
        dof--; \
        ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` ); \
     }
#endif

#argsused
long SKauto_constrain(long            *msg,
                      IGRushort       opts, 
                      struct GRmd_env *md_env, 
                      struct GRid     mgr_id,
                      int             constraint_mask)
{
  IGRboolean		*invalid = NULL, is_horiz, is_vert, is_parallel;
  IGRboolean            clock_active = FALSE;
  IGRushort		loc_opts, cnstrprops;
  OMuint 		count, num_curves;
  int			i, j, num_comps = 0, num_vgpts, dof, old_dof, mask;
  int                   curvinx, endinx;
  long 			stat_OM, msg_loc;
  double		pts[9];
  double 		*length, lentol, dotp, mdist;
  struct component	*comp_list = NULL;
  IGRvector 		*line_vec = NULL, *arc_vec = NULL;
  IGRpoint		centpt, *beg_point = NULL, tmp_p1, tmp_p2;
  IGRshort 		planmattyp;
  IGRmatrix 		planmat;
  GRclassid		sk_classid, cnstrclass;
  GRobjid   		vgpts[4];
  struct GRid 		sk_curve, cnstr_grid, planid, ptvar, *temp_list = NULL;
  struct GRprops 	properties;
  OM_S_CHANSELECT 	to_components, chan_to_defpts, to_geom, chan_to_parent;
  OM_S_OBJECT_LINKAGE   ptlinkage[4];
  extern void		SKgetgeomtype();
  extern int		SKgetautomask();
  extern int            SKplace_constraint();
  extern void		SKclock_cursor(), SKreset_cursor();
  extern void 		IGEactivate_stop_sign(), IGEdeactivate_stop_sign();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = SKget_degrees_of_freedom (&msg_loc, mgr_id, &dof);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  
  if (dof == 0)
  {
    ex$message (msgnumb = EMS_S_FullyConstrained);
    goto ret_end;    
  }
  
  if (dof > 10) 
  {
    ex$message (msgnumb = EMS_P_ClearPromptField );
#if CLOCK_IS_ON
    SKclock_cursor();
#endif
    IGEactivate_stop_sign();
    clock_active = TRUE;
  }

  old_dof = dof;
  if (!constraint_mask)
    mask = SKgetautomask();
  else
    mask = constraint_mask;
    
  EMmake_chanselect ( GRcmpowner_to_components, &to_components );
  EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
  EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
  
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    
  /*
   * Find the underlying composite curve or SKgeometry element.
   * Avoid any SKpoint objects (centers of arcs, circles and other points).
   */
  
  stat_OM = om$get_channel_count (objid = mgr_id.objid, osnum = mgr_id.osnum,
                                  p_chanselect = &to_components,
                                  count = &num_curves);
  EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  
  for (curvinx = 0; curvinx < num_curves; curvinx++) 
  {
    stat_OM = om$get_objid_at_index ( objid = mgr_id.objid, osnum = mgr_id.osnum,
                                      p_chanselect = &to_components, index = curvinx, 
                                      objidaddr = &sk_curve.objid, osnumaddr = &sk_curve.osnum );
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  
    stat_OM = om$get_classid (objid = sk_curve.objid, osnum = sk_curve.osnum,
                              p_classid = &sk_classid);
    EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);
    
    /*
     * Skip an SKpoint that is part of some other geometry e.g. arc/circle/bspline
     */
    if (sk_classid == OPP_SKpoint_class_id)
    {
      om$get_objid_at_index ( objid = sk_curve.objid, osnum = sk_curve.osnum,
                              p_chanselect = &chan_to_defpts,
                              index = 0,
                              objidaddr = &ptvar.objid, osnumaddr = &ptvar.osnum );
      om$get_channel_count ( objid = ptvar.objid, osnum = ptvar.osnum,
                             p_chanselect = &to_geom,
                             count = &count );
      if (count > 1)
        continue;
    }
  
    /*
     * Get the components of the composite curve.
     */
    if (sk_classid == OPP_SKcompcurve_class_id)
    {
      stat_OM = om$send  ( msg =  message GRowner.GRget_number_components 
                                  (&msg_loc, &num_comps),
                           targetid = sk_curve.objid, targetos = sk_curve.osnum,
                           senderid = NULL_OBJID);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
      EMerr_hndlr ( !num_comps, *msg, EMS_I_InvalidCase, ret_end );
        
      temp_list = (struct GRid *) alloca (num_comps * sizeof (struct GRid));
      comp_list = (struct component *) alloca (num_comps * sizeof(struct component));
      stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, NULL, 
                               temp_list, num_comps, &num_comps, 0, MAXINT),
                         targetid = sk_curve.objid, targetos = sk_curve.osnum,
                         senderid = NULL_OBJID);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  
      for (i = 0; i < num_comps; i++)
        comp_list[i].objid = temp_list[i].objid;
    }
    else
    {
      num_comps = 1;
      comp_list = (struct component *) alloca (num_comps * sizeof(struct component));
      comp_list[0].objid = sk_curve.objid;
    }
  
    /*
     * Build the list of ptvars connected to each component
     */
    for (i = 0; i < num_comps; i++)
    {
      SKgetgeomtype(comp_list[i].objid, sk_curve.osnum, &comp_list[i].gmtype);
      stat_OM = om$get_channel_objects (list = ptlinkage, size = 4, 
                                        objid = comp_list[i].objid, osnum = sk_curve.osnum,
                                        p_chanselect = &chan_to_defpts,
                                        count = &count);
      EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
      
      comp_list[i].num_pts = count;
      for (j = 0; j < comp_list[i].num_pts; j++)
        comp_list[i].p[j] = ptlinkage[j].S_objid;
    }
  
    /*
     * Build a list of the segment lengths and the direction vectors.
     */  
  
    length   = (double *) alloca (num_comps * sizeof(double));
    line_vec = (IGRvector *) alloca (num_comps * sizeof (IGRvector));
    arc_vec = (IGRvector *) alloca (num_comps * sizeof (IGRvector));
    invalid   = (IGRboolean *) alloca (num_comps * sizeof (IGRboolean));
    beg_point = (IGRpoint *) alloca (num_comps * sizeof (IGRpoint));
    EMerr_hndlr (!length || !line_vec || !arc_vec || !invalid || !beg_point, 
                 *msg, EMS_E_NoStackMemory, ret_end);
        
    for (i = 0; i < num_comps; i++)
    {
      if (comp_list[i].gmtype & SK_LINE || comp_list[i].gmtype & SK_ARC)
      {
        endinx = comp_list[i].gmtype & SK_LINE ? 2 : 3;
        for (j = 0; j < endinx; j++)
        {
          stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL, NULL, NULL,
                                   &pts[3*j]),
                             targetid = comp_list[i].p[j],
                             targetos = sk_curve.osnum,
                             senderid = NULL_OBJID);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
        }
        OM_BLOCK_MOVE (pts, beg_point[i], sizeof (IGRpoint));
        length[i] = BSdistptpt(&msg_loc, &pts[0], &pts[3]);
        BSmkvec(&msg_loc, line_vec[i], &pts[0], &pts[3]);
        BSnorvec(&msg_loc, line_vec[i]);   
        if (comp_list[i].gmtype & SK_ARC)
        {
          BSmkvec (&msg_loc, arc_vec[i], &pts[3], &pts[6]);
          BSnorvec (&msg_loc, arc_vec[i]);
        }
      }
    }
  
    /*
     * Check for horizontal/vertical lines
     */
    
    loc_opts = SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY;
 
    if (dof > 0 && (mask & SK_AUTO_HORIZONTAL))
    {
      for (i = 0; i < num_comps; i++)
      {
        if (comp_list[i].gmtype & SK_LINE)
        {
          is_horiz = is_vert = FALSE;
          if (fabs (line_vec[i][1])  < lentol)
            is_horiz = TRUE;
          else if (fabs(line_vec[i][0])  < lentol)
              is_vert = TRUE;
          
          if (is_horiz || is_vert)
          {
            cnstrprops = NULL;
            vgpts[0] = comp_list[i].p[0];
            vgpts[1] = comp_list[i].p[1];
            if (is_horiz)
              cnstrprops = SK_HORIZONTAL;
          
            stat_OM = SKplace_constraint (&msg_loc, loc_opts, OPP_SKhorizvert_class_id, 
                                          cnstrprops, md_env, 2, vgpts, &cnstr_grid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
            if (cnstr_grid.objid != NULL_OBJID)
            {
              ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` );
              dof--;
            }
          }
        }
      }
    }
    
    /*
     * Check for 90 or 270 deg arcs.
     */
    if (dof > 0 && (mask & SK_AUTO_NORMAL))
    {
      cnstrclass = OPP_SKnormal_class_id;
      for (i = 0; i < num_comps; i++)
      {
        if (comp_list[i].gmtype & SK_ARC)
        {
          dotp = BSdotp (&msg_loc, line_vec[i], arc_vec[i]);
          EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);
          if (fabs(dotp)  < lentol) 
          {
            vgpts[0] = comp_list[i].p[0];
            vgpts[1] = comp_list[i].p[1];
            vgpts[2] = comp_list[i].p[1];
            vgpts[3] = comp_list[i].p[2];
            stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                          4, vgpts, &cnstr_grid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
            UPDATE_CLOCK;
          }
        }
      }
    }    
    
    stat_OM = om$send (msg = message GRvg.GRgeomprops(&msg_loc,
                             &md_env->md_env.matrix_type, md_env->md_env.matrix,
                             &properties),
                       targetid = sk_curve.objid, targetos = sk_curve.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, OM_E_ABORT, ret_end );

    /*
     * Check for Normal constraints between line segments.
     */
    if (num_comps > 1 && dof > 0 && (mask & SK_AUTO_NORMAL))
    {
      cnstrclass = OPP_SKnormal_class_id;
      endinx = (properties.phy_closed ? num_comps : num_comps - 1);       
      for (i = 0; i < endinx && dof > 0; i++)
      {
        j = (i == num_comps - 1 ? 0 : i+1);
        if (comp_list[i].gmtype & SK_LINE && comp_list[j].gmtype & SK_LINE)
        {
          dotp = BSdotp (&msg_loc, line_vec[i], line_vec[j]);
          EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);
          if (fabs(dotp)  < lentol) 
          {
            vgpts[0] = comp_list[i].p[0];
            vgpts[1] = comp_list[i].p[1];
            vgpts[2] = comp_list[j].p[0];
            vgpts[3] = comp_list[j].p[1];
            stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                          4, vgpts, &cnstr_grid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
            UPDATE_CLOCK;
          }
        }
      }
    }
    
    /*
     * Check for tangency constraints between adjacent profile segments.
     */
    
    if (num_comps > 1 && dof > 0 && (mask & SK_AUTO_TANGENT))
    {
      cnstrclass = OPP_SKtangency_class_id;
      endinx = (properties.phy_closed ? num_comps : num_comps - 1);       
      for (i = 0; i < endinx && dof > 0; i++)
      {
        j = (i == num_comps - 1 ? 0 : i+1);
        if (comp_list[i].gmtype & SK_LINE && comp_list[j].gmtype & SK_ARC)
        {
          dotp = BSdotp (&msg_loc, line_vec[i], line_vec[j]);
          EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);
          if (fabs(dotp)  < lentol) 
          {
            vgpts[0] = comp_list[i].p[1];
            vgpts[1] = comp_list[i].p[0];
            vgpts[2] = comp_list[j].p[1];
          }
          else
            continue;
        }
        else if (comp_list[i].gmtype & SK_ARC && comp_list[j].gmtype & SK_LINE)
        {
          dotp = BSdotp (&msg_loc, arc_vec[i], line_vec[j]);
          EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);
          if (fabs(dotp)  < lentol) 
          {
            vgpts[0] = comp_list[i].p[2];
            vgpts[1] = comp_list[i].p[1];
            vgpts[2] = comp_list[j].p[1];
          }
          else
            continue;
        }
        else if (comp_list[i].gmtype & SK_ARC && comp_list[j].gmtype & SK_ARC)
        {
          dotp = BSdotp (&msg_loc, arc_vec[i], line_vec[j]);
          EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);
          if (fabs(1 - fabs(dotp))  < lentol) 
          {
            vgpts[0] = comp_list[i].p[2];
            vgpts[1] = comp_list[i].p[1];
            vgpts[2] = comp_list[j].p[1];
          }
          else
            continue;
        }
        else
         continue;
        stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                      3, vgpts, &cnstr_grid);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
        UPDATE_CLOCK;
      }
    }
    /*
     * Check for equal lines and arc-segments.
     */
    if (num_comps > 1 && dof > 0 && (mask & SK_AUTO_EQUALITY) )
    {
      cnstrclass = OPP_SKequal_class_id;
      for (i = 0; i < num_comps; i++)
        invalid[i] = FALSE;
  
      for (i = 0; i < num_comps-1 && dof > 0; i++)
      {
        if (!invalid[i] && (comp_list[i].gmtype & SK_LINE || comp_list[i].gmtype & SK_ARC))
        {
          vgpts[0] = comp_list[i].p[0];
          vgpts[1] = comp_list[i].p[1];
          for (j = i+1; j < num_comps && dof > 0; j++)
          {
            if (!invalid[j] && (comp_list[i].gmtype & comp_list[j].gmtype) &&
                (fabs(length[i] - length[j]) < lentol) )
            {
              /*
               * equality detected ....
               */
              vgpts[2] = comp_list[j].p[0];
              vgpts[3] = comp_list[j].p[1];
              stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                            4, vgpts, &cnstr_grid);
              EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
              UPDATE_CLOCK;
              if (cnstr_grid.objid != NULL_OBJID) 
                invalid[j] = TRUE;  /* make the line invalid for further comparisons */
            }
          }
        }
      }
    }
  
    /*
     * Check for parallel line segments.
     */
    if (num_comps > 1 && dof > 0 && (mask & SK_AUTO_PARALLEL)) 
    {
      for (i = 0; i < num_comps; i++)
        invalid[i] = FALSE;
      for (i = 0; i < num_comps-1 && dof > 0; i++)
      {
        if (!invalid[i] && (comp_list[i].gmtype & SK_LINE))
        {
          vgpts[0] = comp_list[i].p[0];
          vgpts[1] = comp_list[i].p[1];
          for (j = i+1; j < num_comps && dof > 0; j++)
          {
            if (!invalid[j] && (comp_list[j].gmtype & SK_LINE))
            {
              BSlldist(&msg_loc, beg_point[i], beg_point[j], 
                       line_vec[i], line_vec[j], &is_parallel, &mdist, tmp_p1, tmp_p2);
              if (is_parallel) 
              {
                vgpts[2] = comp_list[j].p[0];
                vgpts[3] = comp_list[j].p[1];
                if (fabs(mdist) > lentol)
                {
                  cnstrclass = OPP_SKparallel_class_id;
                  num_vgpts = 4;
                }
                else
                {
                  if (vgpts[0] == vgpts[2] || vgpts[0] == vgpts[3] ||
                      vgpts[1] == vgpts[2] || vgpts[1] == vgpts[3]) 
                  {
                    cnstrclass = OPP_SKcollinear_class_id;  // lines with a common point 
                    num_vgpts = 3;
                    vgpts[2] = comp_list[j].p[1];
                  }
                  else
                  {
                    cnstrclass = OPP_SKifcol_class_id;                    
                    num_vgpts = 4;
                  }
                }
                stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                              num_vgpts, vgpts, &cnstr_grid);
                EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
                UPDATE_CLOCK;
                if (cnstr_grid.objid != NULL_OBJID) 
                  invalid[j] = TRUE;  /* make this line invalid */
              }
            }
          }
        }
      }
    }
  
    /*
     * Place Single Parallel dimensions for lines and Radial dimensions for arcs.
     */
    planid.objid = NULL_OBJID;
    EMmake_chanselect (NDfather_father, &chan_to_parent);
    stat_OM = om$send (msg = message NDnode.ASreturn_go (&planid, &planmattyp,planmat), 
                       targetos = mgr_id.osnum,
                       senderid = mgr_id.objid, 
                       p_chanselect = &chan_to_parent,
                       from = FIRST, to = FIRST);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
    
    stat_OM = SKfind_centroid (&msg_loc, md_env, mgr_id, centpt);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    
    if (mask & SK_AUTO_SINGLE) 
    {
      for (i = 0; i < num_comps && dof > 0 ; i++)
      {
        if (comp_list[i].gmtype & SK_LINE)
        {
          vgpts[0] = comp_list[i].p[0];
          vgpts[1] = comp_list[i].p[1];
          if (fabs(line_vec[i][1]) < lentol)
          {
            cnstrprops = SK_HORIZONTAL;
            cnstrclass = OPP_SKhvptpt_class_id;
            stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, cnstrprops, 
                                          md_env, 2, vgpts, &cnstr_grid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
          else if (fabs(line_vec[i][0]) < lentol)
          {
            cnstrclass = OPP_SKhvptpt_class_id;
            stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                          2, vgpts, &cnstr_grid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
          else 
          {
            cnstrclass = OPP_SKifptpt_class_id;
            stat_OM = SKplace_constraint (&msg_loc, NULL, cnstrclass, NULL, md_env,
                                          2, vgpts, &cnstr_grid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
            if (cnstr_grid.objid != NULL_OBJID) 
            {
              stat_OM = SKcreate_sngl_parallel (&msg_loc, md_env, cnstr_grid, vgpts, planid, 
                                                centpt); 
              EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
            }
          }
          UPDATE_CLOCK;
        }
        else if (comp_list[i].gmtype & SK_ARC || comp_list[i].gmtype & SK_CIRCLE )
        {
          vgpts[0] = comp_list[i].p[0];
          vgpts[1] = comp_list[i].p[1];
          cnstrclass = OPP_SKradial_class_id;
          stat_OM = SKplace_constraint (&msg_loc, loc_opts | SK_OPT_CHECK_UNITS, 
                                        cnstrclass, NULL, md_env,
                                        2, vgpts, &cnstr_grid);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          UPDATE_CLOCK;
        }
      }
    }
    
    /*
     * Place angular dimensions.
     */
    if (dof > 0 && mask & SK_AUTO_ANGULAR) 
    {
      cnstrclass = OPP_SKrelang_class_id;
      num_vgpts = 4;
      for (i = 0; i < num_comps - 1 && dof > 0; i++)
      {
        if ((comp_list[i].gmtype & SK_LINE) && (comp_list[i+1].gmtype & SK_LINE))
        {
          vgpts[0] = comp_list[i].p[0];
          vgpts[1] = comp_list[i].p[1];
          vgpts[2] = comp_list[i+1].p[0];
          vgpts[3] = comp_list[i+1].p[1];
	  /*
           * Avoid placing the constraint in case of collinear line segments
           * --   01/09/95 --- Satya
           */
          if ((fabs(line_vec[i][0] - line_vec[i+1][0]) < lentol)
          &&(fabs(line_vec[i][1] - line_vec[i+1][1]) < lentol)
          &&(fabs(line_vec[i][2] - line_vec[i+1][2]) < lentol))
             continue;

          stat_OM = SKplace_constraint (&msg_loc, NULL, cnstrclass, NULL, md_env,
                                        num_vgpts, vgpts, &cnstr_grid);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          if (cnstr_grid.objid != NULL_OBJID) 
          {
            stat_OM = SKcreate_relang (&msg_loc, md_env, cnstr_grid, vgpts, planid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
          UPDATE_CLOCK;
        }
      }
  
      /*
       * Angular constraint on the first segement.  If the curve is open, then an
       * absolute angle is placed.  Else a relative angle between the last line seg
       * and the first line seg.
       */
      if (dof > 0 && (num_comps >= 1) && (comp_list[0].gmtype & SK_LINE))
      {
  
        cnstr_grid.objid = NULL_OBJID;
        if (properties.phy_closed && (comp_list[num_comps-1].gmtype & SK_LINE)) 
        {
          num_vgpts = 4;
          vgpts[0] = comp_list[num_comps-1].p[0];
          vgpts[1] = comp_list[num_comps-1].p[1];
          vgpts[2] = comp_list[0].p[0];
          vgpts[3] = comp_list[0].p[1];
  
          cnstrclass = OPP_SKrelang_class_id;
          stat_OM = SKplace_constraint (&msg_loc, NULL, cnstrclass, NULL, md_env,
                                        num_vgpts, vgpts, &cnstr_grid);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          if (cnstr_grid.objid != NULL_OBJID) 
          {
            stat_OM = SKcreate_relang (&msg_loc, md_env, cnstr_grid, vgpts, planid);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
          UPDATE_CLOCK;
        }
  
        if (cnstr_grid.objid == NULL_OBJID)    /* either the curve was open or the
                                                  relative angle conflicts .. try an absolute angle */
        {     
          num_vgpts = 2;
          vgpts[0] = comp_list[0].p[0];
          vgpts[1] = comp_list[0].p[1];
  
          cnstrclass = OPP_SKfixang_class_id;
          stat_OM = SKplace_constraint (&msg_loc, loc_opts | SK_OPT_CHECK_UNITS, 
                                        cnstrclass, NULL, md_env,
                                        num_vgpts, vgpts, &cnstr_grid);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          UPDATE_CLOCK;
        }
      }
    }
    
    ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` );
    /*
     * Check if we can place a ground constraint at the first point.  
     * Switch to center point in case of arc/cicle.
     */
    cnstrclass = OPP_SKasptgrnd_class_id;
    if (dof >= 2 && mask & SK_AUTO_GROUND)
    {
      if ((comp_list[0].gmtype & SK_ARC) || (comp_list[0].gmtype & SK_CIRCLE))
        vgpts[0] = comp_list[0].p[1];
      else
        vgpts[0] = comp_list[0].p[0];
  
      stat_OM = SKplace_constraint(&msg_loc, loc_opts, cnstrclass, NULL, md_env,
                                   1, vgpts, &cnstr_grid);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    
      if (cnstr_grid.objid != NULL_OBJID) 
      {
        dof = dof - 2;
        ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` );
      }
    }
  }
  
  if (dof == old_dof)
    ex$message ( msgnumb = EMS_S_NoNewConstraintsAdded);
  if (dof > 0)
    ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` )
  else
    ex$message ( msgnumb = EMS_S_FullyConstrained);
  
ret_end:
  if (clock_active) 
  {
#if CLOCK_IS_ON
    SKreset_cursor();
#endif
    IGEdeactivate_stop_sign();
  }
  if (*msg == EMS_E_Stop)
    *msg = EMS_S_Success;
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKauto_constrain");
  return (stat_OM);
}

end implementation SKmgr;
