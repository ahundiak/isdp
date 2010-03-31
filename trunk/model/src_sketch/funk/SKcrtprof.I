/*

Name
  SKcreate_profile

Abstract

Synopsis

Description
    This function processes all the constraints that were detected during
    the creation of a profile.  

Return Value

Notes

Index

Keywords
  profile

History
  ??????  : Siki : created (wild guess).
  8/20/92 : Rajiv Agrawal : Changed the behavior of PT_EVENT to create a
    			    coincident constraint in case no associative ground 
    			    was created.
  12/20/92 : Rajiv Agrawal : Added a call to auto-constrain a composite curve.
  08/24/93 : Rajiv Agrawal : Removed the kludge to create profile from a composite curve.
                             Handled in a separate routine EFconvert_to_profile.
  12/14/93 : Rajiv Agrawal : Changed the creation of a SKptpt to SKifptpt.

 */
  
class implementation SKmgr;

#include <alloca.h>
#include "asbox.h"
#include "nddef.h"
#include "bserr.h"
#include "bsparameters.h"

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define TOT_DEGREES_FREE_POINT 2

#define NUM_DEFPTS_ARC 3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKmgr_class_id;
extern GRclassid OPP_SKhorizvert_class_id, OPP_SKtangency_class_id;
extern GRclassid OPP_SKnormal_class_id, OPP_SKparallel_class_id;
extern GRclassid OPP_SKcollinear_class_id;
extern GRclassid OPP_SKfixang_class_id, OPP_SKrelang_class_id;
extern GRclassid OPP_SKifptpt_class_id, OPP_SKhvptpt_class_id;
extern GRclassid OPP_SKradial_class_id;
extern GRclassid OPP_SKcoincident_class_id;

from SKgeometry   import SKcreate_ptvars, SKcreate_self_constraints, SKgetmgr;
from SKconstraint import SKinit;
from SKvariable   import SKswap, SKgetmgr;
from EMSdatpln    import EMget_pln_info;

%safe
static int degrees_of_freedom ();
%endsafe

#argsused
long SKcreate_profile ( msg, opts, curve, md_env, datplane, datpoint, xyz_origin, x_axis, z_axis,
                        num_cnstr_ptinfo, cnstr_ptinfo, closed, skmgr )
long 		*msg;
IGRushort 	opts;
GRobjid 	curve;
struct GRmd_env *md_env;
struct GRid 	*datplane, *datpoint;
double 		*xyz_origin;
double 		*x_axis;
double 		*z_axis;
int 		num_cnstr_ptinfo;
struct SKcnstr_ptinfo *cnstr_ptinfo;
IGRboolean 	closed;
GRobjid 	*skmgr;
{
  IGRboolean            stat_func, aflag=0;
  char                  skclass_name[OM_K_MAXCLASS_LEN];
  unsigned short        cnstrprops, loc_opts;
  short                 first_pttype, pttype, action, grprops;
  OMuint		num_comps;
  int                   i, ptinx, num_ptvars, loc_num_ptvars, count;
  int                   num_deg_free;
  long                  own_inx, stat_OM, msg_loc;
  double                *loc_x_axis, *loc_z_axis, *loc_xyz_origin;
  IGRpoint              origpt;
  IGRvector             xvec, zvec;
  GRobjid               tempobj, *ptvars, loc_ptvars[4], assoc_vgpt;
  GRclassid             grclass, cnstrclass;
  GRspacenum            os;
  struct GRid           mgr_id, var1, var2, cnstrid;
  struct GRsymbology    symb;
  struct SKcnstr_ptinfo *p_cnstr_ptinfo;
  OM_S_CHANSELECT       chan_to_comps;
  OM_S_OBJECT_LINKAGE   *complist;
  extern int		SKmerge_curves();
  extern long		EFcreate_profile();
  extern int            SKplace_constraint(), SKget_degrees_of_freedom();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  aflag = pwIsActivationOn();
  
  ptvars = NULL;
  
  os = md_env->md_id.osnum;
  
  /*
   * If a datum plane has been passed in, the sketch must derive it's
   * plane from that entity. Else, the origin, x-axis and the z-axis are
   * expected to have been passed in.
   */
  
  if (datplane && datplane->objid != NULL_OBJID)
  {
    stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info(&msg_loc,
        NULL, md_env, xvec, NULL, zvec, origpt, NULL),
        targetid = datplane->objid, targetos = datplane->osnum,
        senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
    loc_x_axis = xvec;
    loc_z_axis = zvec;
    loc_xyz_origin = origpt;

    if(aflag)
    {
      /*
       * Transform the axes to the ref-space as SKinit that follows posts
       * the data directly. Therefore we have to hand over the data in
       * reference space.
       */
      stat_OM = RFtransform( md_env->md_env.matrix,
                             md_env->md_env.matrix_type,
                             TRUE,
                             loc_x_axis, NULL, loc_z_axis, loc_xyz_origin);
      EMerr_hndlr ( !(1&stat_OM), *msg, EMS_E_Fail, ret_end);
    }
  }
  else
  {
    loc_x_axis = x_axis;
    loc_z_axis = z_axis;
    loc_xyz_origin = xyz_origin;
  }
  
  /*
   * Construct the sketch manager, with the orientation. If a datum-plane
   * is driving this sketch, then connect this manager to the datum plane.
   */
  
  stat_OM = om$construct (classid = OPP_SKmgr_class_id, osnum = os,
                          p_objid = skmgr);
  EMomerr_exit (stat_OM, ret_end);

  mgr_id.objid = *skmgr;
  mgr_id.osnum = os;
  
  stat_OM = om$send (msg = message SKmgr.SKinit (&msg_loc, NULL, NULL,
                           loc_xyz_origin, loc_x_axis, loc_z_axis), 
                     targetid = mgr_id.objid, targetos = mgr_id.osnum, 
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  grprops = GRHAS_EXTERNAL_CONSTRAINT | GRIS_ASSOCIATIVE;
  action = 1;
  om$send (msg = message GRgraphics.GRchgprops (&msg_loc, &action, &grprops), 
           targetid = mgr_id.objid, targetos = mgr_id.osnum, 
           senderid = NULL_OBJID);
  
  om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb), targetid = curve,
           targetos = os, senderid = NULL_OBJID);
  om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
           targetid = *skmgr, targetos = os, senderid = NULL_OBJID);
  
  if (datplane && datplane->objid != NULL_OBJID)
  {
    stat_OM = om$send (msg = message NDnode.NDconnect (1,datplane,
        NULL_GRID, ND_ADD), targetid = *skmgr, targetos = os,
        senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  
  /*
   * Change the class of the incoming graphics curve to it's corresponding
   * variational class.
   */
  
  om$get_classid (objid = curve, osnum = os, p_classid = &grclass);
  stat_func = SKgetskclass (grclass, NULL, skclass_name);
  EMerr_hndlr (!stat_func, *msg, EMS_E_InvalidArg, ret_end);
  
  stat_OM = om$change_class (osnum = os, objid = curve, 
                             classname = skclass_name);
  EMomerr_exit (stat_OM, ret_end);
  
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  num_comps = 0;
  om$get_channel_count (objid = curve, osnum = os,
                        p_chanselect = &chan_to_comps, count = &num_comps);
  
  if (num_comps)
  {
    complist = (OM_p_OBJECT_LINKAGE) alloca (num_comps *
        sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!complist, *msg, EMS_E_NoStackMemory, ret_end);
  
    om$get_channel_objects (objid = curve, osnum = os,
        p_chanselect = &chan_to_comps, count = &num_comps, size = num_comps,
        list = complist);
  
    for (i=0; i<num_comps; i++)
    {
      tempobj = complist[i].S_objid;
      om$get_classid (objid = tempobj, osnum = os, p_classid = &grclass);
      stat_func = SKgetskclass (grclass, NULL, skclass_name);
      EMerr_hndlr (!stat_func, *msg, EMS_E_InvalidArg, ret_end);
  
      stat_OM = om$change_class (osnum = os, objid = tempobj, 
                                 classname = skclass_name);
      EMomerr_exit (stat_OM, ret_end);
    }
  }
  
  /*
   * Connect the curve onto the sketch manager as a component.
   */
  
  own_inx = 0;
  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                           &mgr_id, &own_inx),
                     targetid = curve, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  /*
   * Create the variational geometry point variables at the vertices
   * and other keypoints of the curve. With the creation of these, a
   * complete variational profile has been defined, but with no
   * constraints.
   */
  
  num_ptvars = 0;
  stat_OM = om$send (msg = message SKgeometry.SKcreate_ptvars (&msg_loc,
                 SK_PROCSKGR_PROCEND | (closed ? SK_PROCSKGR_CLOSED : NULL),
                 &md_env->md_env.matrix_type, md_env->md_env.matrix,
                 NULL, NULL, skmgr, &num_ptvars, &ptvars),
                 targetid = curve, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  stat_OM = om$send (msg = message SKgeometry.SKcreate_self_constraints
                 (&msg_loc, NULL, md_env, NULL, NULL),
                 targetid = curve, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  /*
   * Generate the constraints specified by the input cnstr_ptinfo. 
   */
  
  stat_OM = SKget_degrees_of_freedom (&msg_loc, mgr_id, &num_deg_free);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  if (cnstr_ptinfo)
  {
    /*
     * Preprocess:
     * Some amount of discretion is used while applying these constraints.
     * For example: if the profile is closed then, the two degrees of freedom
     * are already taken up by this fact. This implies that before coming
     * in to close the geometry should have two degrees of freedom. In the
     * case where we close with a line-segment there is nothing much to do,
     * except not use any constraints to determine the last point. But while
     * closing with an arc, the arc comes in with only one degree of freedom,
     * unless it's centre is free to change with atleast one degree of freedom.
     * Thus, while completing the profile with an arc, send a message to
     * it's centre to make sure that it has atleast one degree of freedom,
     * relative to the start-point of the arc.
     */
  
    if (closed)
    {
      num_cnstr_ptinfo--;
      p_cnstr_ptinfo = &cnstr_ptinfo[num_cnstr_ptinfo];
      if (num_comps > 1 &&
          (p_cnstr_ptinfo->pttype[FIRST] == PT_ONCIRC ||
          p_cnstr_ptinfo->pttype[SECOND] == PT_ONCIRC))
      {
        p_cnstr_ptinfo = &cnstr_ptinfo[num_cnstr_ptinfo-1];
        if (degrees_of_freedom (p_cnstr_ptinfo) == TOT_DEGREES_FREE_POINT)
        {
          p_cnstr_ptinfo->pttype[SECOND] = PT_NULL;
          if (degrees_of_freedom (p_cnstr_ptinfo) == TOT_DEGREES_FREE_POINT)
            p_cnstr_ptinfo->pttype[FIRST] = PT_NULL;
        }
      }
    }
  
    /* we take the minimum number of points (ECdraw gets confused at times) */
    if (num_cnstr_ptinfo != num_ptvars)
    {
      num_cnstr_ptinfo = num_cnstr_ptinfo < num_ptvars ? num_cnstr_ptinfo : num_ptvars;
      num_ptvars = num_cnstr_ptinfo;
    }
    /*
      EMerr_hndlr (num_cnstr_ptinfo != num_ptvars, *msg, EMS_E_InvalidArg,
       ret_end);
      */
  
    /*
     * Process:
     * Add the constraints specified. Keep track of the number of degrees
     * of freedom remaining.
     */
  
    loc_opts = opts | SK_OPT_MARK_AS_USERADD;
    for (ptinx=0; ptinx<num_cnstr_ptinfo && num_deg_free > 0; ptinx++)
    {
      for (i=FIRST; i<=SECOND; i++)
      {
        pttype = cnstr_ptinfo[ptinx].pttype[i];
        loc_num_ptvars = 0;
        switch (pttype)
        {
          case PT_HORIZ:
          case PT_VERT:
            OM_BLOCK_MOVE (&ptvars[ptinx-1], loc_ptvars, 2 * sizeof (GRobjid));
            loc_num_ptvars = 2;
            cnstrclass = OPP_SKhorizvert_class_id;
            cnstrprops = pttype == PT_HORIZ ? SK_HORIZONTAL : NULL;
            num_deg_free--;
            break;
    
          case PT_PT1_HORIZ:
          case PT_PT1_VERT:
            loc_ptvars[FIRST] = ptvars[FIRST];
            loc_ptvars[SECOND] = ptvars[ptinx];
            loc_num_ptvars = 2;
            cnstrclass = OPP_SKhorizvert_class_id;
            cnstrprops = pttype == PT_PT1_VERT ? NULL : SK_HORIZONTAL;
            num_deg_free--;
            break;
    
          case PT_TANGE:
            loc_ptvars[FIRST] = ptvars[ptinx-1];
            loc_ptvars[SECOND] = ptvars[ptinx-2];
            loc_ptvars[THIRD] = ptvars[ptinx];
            loc_num_ptvars = 3;
            cnstrclass = OPP_SKtangency_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_TANGM:
            loc_ptvars[FIRST] = ptvars[ptinx];
            loc_ptvars[SECOND] = ptvars[ptinx-1];
            /*
                 * 03/12/92 - HGB and JSD
                 * If we are at the end of the list, then we need to use the
                 * first point in the ptvar list
                 */
            if ( ptinx == num_ptvars - 1 )
              loc_ptvars[THIRD] = ptvars[0];
            else
              loc_ptvars[THIRD] = ptvars[ptinx+1];
            loc_num_ptvars = 3;
            cnstrclass = OPP_SKtangency_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_ORTHO:
            loc_ptvars[FIRST] = ptvars[ptinx-1];
            loc_ptvars[SECOND] = ptvars[ptinx-2];
            loc_ptvars[THIRD] = ptvars[ptinx];
            loc_num_ptvars = 3;
            cnstrclass = OPP_SKnormal_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_COLL:
            OM_BLOCK_MOVE (&ptvars[ptinx-2], loc_ptvars, 3 * sizeof (GRobjid));
            loc_num_ptvars = 3;
            cnstrclass = OPP_SKcollinear_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_DIST:
            OM_BLOCK_MOVE (&ptvars[ptinx-1], loc_ptvars, 2 * sizeof (GRobjid));
            loc_num_ptvars = 2;
            first_pttype = cnstr_ptinfo[ptinx].pttype[FIRST];
            if (i == SECOND &&
                (first_pttype == PT_HORIZ || first_pttype == PT_VERT))
            {
              cnstrclass = OPP_SKhvptpt_class_id;
              cnstrprops = first_pttype == PT_HORIZ ? SK_HORIZONTAL : NULL;
            }
            else
            {
              cnstrclass = OPP_SKifptpt_class_id;
              cnstrprops = NULL;
            }
            num_deg_free--;
            break;
    
          case PT_RADIUS:
            OM_BLOCK_MOVE (&ptvars[ptinx-1], loc_ptvars, 2 * sizeof (GRobjid));
            loc_num_ptvars = 2;
            cnstrclass = OPP_SKradial_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_ANGLE:
            OM_BLOCK_MOVE (&ptvars[ptinx-1], loc_ptvars, 2 * sizeof (GRobjid));
            loc_num_ptvars = 2;
            cnstrclass = OPP_SKfixang_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_SWEEP:
            loc_ptvars[FIRST] = ptvars[ptinx-1];
            loc_ptvars[SECOND] = ptvars[ptinx-2];
            loc_ptvars[THIRD] = ptvars[ptinx];
            loc_num_ptvars = 3;
            cnstrclass = OPP_SKrelang_class_id;
            cnstrprops = NULL;
            num_deg_free--;
            break;
    
          case PT_EVENT:
            if (num_deg_free < 2) 
              break;
            SKprocess_sketch_graphics (&msg_loc, 
                SK_PROCSKGR_GRAPHHANDLE | SK_PROCSKGR_MERGESK |
                SK_PROCSKGR_CHKCYCLE,
                md_env, &mgr_id, NULL, &cnstr_ptinfo[ptinx].event, NULL, NULL,
                &count, &assoc_vgpt);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (msg_loc == EMS_I_Cycle)
              break;
            
            /*
             * Delete the profile point in case an associative ground point
             * was created.  Otherwise place a coincident constraint. ra 8/20/92
             */
            if (msg_loc == EMS_I_Assoc)
            {
              stat_OM = om$send (msg = message SKvariable.SKswap (&msg_loc,
                  SK_UPDATE_DELETEOLD, assoc_vgpt),
                  targetid = ptvars[ptinx], targetos = os,
                  senderid = NULL_OBJID);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    
              ptvars[ptinx] = assoc_vgpt;
            }
            else
            {
              loc_ptvars[FIRST] = ptvars[ptinx];
              loc_ptvars[SECOND] = assoc_vgpt;
              loc_num_ptvars = 2;
              cnstrclass = OPP_SKcoincident_class_id;
              cnstrprops = NULL;  
            }
            num_deg_free -= 2;
            break;
    
          case PT_PROJEVENT:
            if (i != SECOND || ptinx < SECOND)
              break;
    
            SKprocess_sketch_graphics (&msg_loc, 
                SK_PROCSKGR_MERGESK | SK_PROCSKGR_CHKCYCLE,
                md_env, &mgr_id, NULL, &cnstr_ptinfo[ptinx].event, NULL, NULL,
                &count, &assoc_vgpt);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (msg_loc == EMS_I_Cycle)
              break;
    
            first_pttype = cnstr_ptinfo[ptinx].pttype[FIRST];
            if (first_pttype == PT_ONCIRC)
            {
              loc_ptvars[FIRST] = ptvars[ptinx-1];
              loc_ptvars[SECOND] = ptvars[ptinx];
              loc_ptvars[THIRD] = assoc_vgpt;
              loc_num_ptvars = 3;
              cnstrclass = OPP_SKcollinear_class_id;
              cnstrprops = NULL;
            }
            else if (first_pttype == PT_HORIZ || first_pttype == PT_VERT)
            {
              loc_ptvars[FIRST] = ptvars[ptinx];
              loc_ptvars[SECOND] = assoc_vgpt;
              loc_num_ptvars = 2;
              cnstrclass = OPP_SKhorizvert_class_id;
              cnstrprops = first_pttype == PT_VERT ? SK_HORIZONTAL : NULL;
            }
            else
            {
              loc_ptvars[FIRST] = ptvars[ptinx];
              loc_ptvars[SECOND] = ptvars[ptinx-1];
              loc_ptvars[THIRD] = assoc_vgpt;
              loc_num_ptvars = 3;
              cnstrclass = OPP_SKnormal_class_id;
              cnstrprops = NULL;
            }
            num_deg_free--;
            break;
    
          case PT_ONCIRC:
            num_deg_free--;
            break;
  
          case PT_MERGE:
            SKprocess_sketch_graphics (&msg_loc, 
                SK_PROCSKGR_GRAPHHANDLE | SK_PROCSKGR_MERGESK |
                SK_PROCSKGR_CHKCYCLE,
                md_env, &mgr_id, NULL, &cnstr_ptinfo[ptinx].event, NULL, NULL,
                &count, &assoc_vgpt);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (msg_loc == EMS_I_Cycle)
              break;
    
            var1.osnum = var2.osnum = os;
            var1.objid = assoc_vgpt;
            var2.objid = ptvars[ptinx];
            stat_OM = SKmerge_curves (&msg_loc, &var1, &var2);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
            if (om$is_objid_valid( osnum = var1.osnum, objid = var1.objid) == OM_S_SUCCESS) 
            {
              stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, skmgr),
                                 targetid = var1.objid, targetos = var1.osnum, 
                                 senderid = NULL_OBJID);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
            }
            else
            {
              stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, skmgr),
                                 targetid = var2.objid, targetos = var2.osnum, 
                                 senderid = NULL_OBJID);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
            }
            break;
        } /* Case closed */
  
        if (loc_num_ptvars)
        {
          stat_OM = SKplace_constraint (&msg_loc, loc_opts, cnstrclass, cnstrprops, md_env,
                                        loc_num_ptvars, loc_ptvars, &cnstrid);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          /*
           * In case of a single-parallel constraint, construct a dimension handle also.
           */
          if (cnstrclass == OPP_SKifptpt_class_id && cnstrid.objid != NULL_OBJID)
          {
            stat_OM = SKcreate_sngl_parallel (&msg_loc, md_env, cnstrid, loc_ptvars, 
                                              *datplane, 
                                              origpt); 
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
        }
      }
    }
  }
  
  if (!num_deg_free)
    *msg = EMS_I_FullyConstrained;
  
ret_end:
  if (ptvars)
    om$dealloc (ptr = ptvars);
  
  EMWRAPUP (*msg, stat_OM, "SKcreate_profile");
  return stat_OM;
}


static int degrees_of_freedom ( ptinfo )
struct SKcnstr_ptinfo *ptinfo;
{
  int i, degrees_of_freedom;

  degrees_of_freedom = 0;
  for (i=FIRST; i<=SECOND; i++)
    if (ptinfo->pttype[i] == PT_EVENT)
      degrees_of_freedom += 2;
    else if (ptinfo->pttype[i] != PT_NULL)
      degrees_of_freedom++;
      
  return degrees_of_freedom;
}

end implementation SKmgr;

