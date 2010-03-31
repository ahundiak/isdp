class implementation EMSparamgm;

/*
  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "bsconic.h"
#include "EMSasopts.h"
#include "ndmacros.h"
#include "ma.h"
#include "ma2lnise.h"
#include "bsxlnpl.h"
#include "bssur_sur.h"
#include "bssfeval.h"
#include "bssf_pl_int.h"
#include "bsproj1.h"
#include "bsproj0.h"
#include "bspl_pl.h"
#include "bspl_cv_int.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmdstptcv.h"
#include "bsmdistptsf.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "bscvcv_int.h"
#include "bscrossp.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMScnstr import EMgetgeomlocus;

#define TOT_DOF_POINT	3
#define TOT_DOF_VECTOR	2

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1
#define Z 2

method EMsolve (IGRlong *msg; IGRushort opts;
                IGRint num_cnstrs; struct GRid *cnstrs;
                struct GRmd_env *md_env;
                struct EMSgeomdata *solvedgm;
                IGRint *num_conflict_cnstr; struct GRid conflict_cnstr[3];
                IGRint *num_undercnstr; IGRvector undercnstr_vecs[3])
{
  IGRshort mattyp;
  IGRint i, loc_num_undercnstr, conflict_index_pair[2];
  IGRlong stat_OM, msg_loc, solve_msg;
  IGRdouble *mat;
  IGRvector loc_undercnstr_vecs[3];
  struct EMSgeomdata geomdata[3], mygeom, loc_solvedgm;
  struct GRid my_GRid;
  OM_S_CHANSELECT chan_to_father;
  OM_S_OBJECT_LINKAGE *objlist;
  void EMsolvecnstr_pt(), EMsolvecnstr_vc();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!cnstrs)
    {
    EMmake_chanselect (NDfather_father, &chan_to_father);
    om$get_channel_count (object = me, p_chanselect = &chan_to_father,
     count = (OMuint *) &num_cnstrs);

    if (num_cnstrs)
      {
      objlist = (OM_p_OBJECT_LINKAGE) alloca (num_cnstrs *
                 sizeof (OM_S_OBJECT_LINKAGE));
     
      stat_OM = om$get_channel_objects (object = me,
                 p_chanselect = &chan_to_father, count = (OMuint *) &num_cnstrs,
                 size = num_cnstrs, list = objlist);
      EMomerr_exit (stat_OM, ret_end);

      cnstrs = (struct GRid *) alloca (num_cnstrs * sizeof (struct GRid));
      for (i=0; i<num_cnstrs; i++)
        {
        cnstrs[i].objid = objlist[i].S_objid;
        cnstrs[i].osnum = objlist[i].osnum;
        }
      }
    }


  /* 
   * These geometric entities can have only three degrees of freedom.
   * A constraint represents atleast one. So, more than three constraints is
   * an error condition in the data. Treat the first n-1 constraints as
   * conflicting with the last one.
   */

  if (num_cnstrs > 3)
    {
    *msg = EMS_I_Redundant;
    if (num_conflict_cnstr)
      *num_conflict_cnstr = num_cnstrs - 1;
    if (conflict_cnstr)
      OM_BLOCK_MOVE (cnstrs, conflict_cnstr, (num_cnstrs-1) * 
       sizeof (struct GRid));
    goto ret_end;
    }

  /*
   * If requested, check if a dependency cycle exists with the constraints
   */

  if (opts & EMSsolve_checkcycle)
    {
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    for (i=0; i<num_cnstrs; i++)
      {
      if (nd$dep_exist (l_root = &my_GRid, nb_root = 1,
           l_tip = &cnstrs[i], nb_tip = 1))
        {
        *msg = EMS_I_Cycle;
        if (num_conflict_cnstr)
          *num_conflict_cnstr = 1;
        if (conflict_cnstr)
          conflict_cnstr[0] = cnstrs[i];
        goto ret_end;
        }
      } 
    }

  /*
   * Obtain the geometric locii for each of the constraints.
   */

  mattyp = md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  for (i=0; i<num_cnstrs; i++)
    {
    stat_OM = om$send (msg = message EMScnstr.EMgetgeomlocus (&msg_loc,
               NULL, &mattyp, mat, &geomdata[i]), targetid = cnstrs[i].objid,
               targetos = cnstrs[i].osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Obtain this object's current geometry in model space
   */

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             &mattyp, mat, &mygeom), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Call the appropriate function that takes in different geometries as locii
   * for this geometry and tries to satisfy all of them. If not enough
   * locii to fully define the geometry, the closest definition is output.
   */

  if (mygeom.geomtype == GEOMDATA_POINT)
    {
    EMsolvecnstr_pt (&solve_msg, NULL, mygeom.point, num_cnstrs, geomdata,
     loc_solvedgm.point, 
     conflict_index_pair, &loc_num_undercnstr, loc_undercnstr_vecs);
    EMerr_hndlr (EMSerror (solve_msg), *msg, EMS_E_Fail, ret_end);
    loc_solvedgm.geomtype = GEOMDATA_POINT;
    }
  else if (mygeom.geomtype == GEOMDATA_VECTOR)
    {
    EMsolvecnstr_vc (&solve_msg, NULL, mygeom.vector, num_cnstrs, geomdata,
     loc_solvedgm.vector, 
     conflict_index_pair, &loc_num_undercnstr, loc_undercnstr_vecs);
    EMerr_hndlr (EMSerror (solve_msg), *msg, EMS_E_Fail, ret_end);
    loc_solvedgm.geomtype = GEOMDATA_VECTOR;
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}
  
  /*
   * Check for no-solution case or redundant case. If so, flag
   * this and return appropriate stuff.
   */

  if (solve_msg == EMS_I_NoSolution || solve_msg == EMS_I_Redundant)
    {
    *msg = solve_msg;
    if (num_conflict_cnstr)
      *num_conflict_cnstr = 2;
    if (conflict_cnstr)
      for (i=0; i<2; i++)
        conflict_cnstr[i] = cnstrs[conflict_index_pair[i]];
    goto ret_end;
    }

  /*
   * Return the result
   */

  if (solvedgm)
    OM_BLOCK_MOVE (&loc_solvedgm, solvedgm, sizeof (struct EMSgeomdata));
  if (solve_msg == EMS_I_UnderConstrained)
    {
    if (num_undercnstr)
      *num_undercnstr = loc_num_undercnstr;
    if (undercnstr_vecs)
      OM_BLOCK_MOVE (loc_undercnstr_vecs, undercnstr_vecs,
       loc_num_undercnstr * sizeof (IGRvector));
    }
  *msg = solve_msg;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpgmsolve.I");
  return (stat_OM);
}




/*
  DESCRIPTION
    
    The following function takes in a point and a set of locii. It tries
    to find the best solution that satisfies all of these at the same
    time. Any over-constraint is returned. If no solution, then the
    two constraints that did not intersect are returned. If under-constraint
    processing is requested this is done.

    Return code could be EMS_I_FullyConstrained, EMS_I_NoSolution,
    EMS_I_Redundant, EMS_I_UnderConstrained, EMS_E_Fail. 
    In the NoSolution and Conflicting cases the conflicting pair of locii is
    returned in the form of their indexes. In the case of UnderConstrained,
    the vectors in the direction of underconstraint are returned.

  HISTORY

    SS  :  03/19/91  :  Creation
*/

void EMsolvecnstr_pt (msg, opts, pt, num_locus, locus,
                      solved_pt, 
                      conflict_pair, num_undercnstr, undercnstr_vecs)
IGRlong *msg;
IGRushort opts;
IGRpoint pt;
IGRint num_locus;
struct EMSgeomdata *locus;
IGRpoint solved_pt;
IGRint *conflict_pair;
IGRint *num_undercnstr;
IGRvector undercnstr_vecs[3];
{
  IGRint i, j, k, count, inx, type1, type2, tmpconflict[2];
  IGRint num_grps, *num_intpts, num_intpt, num_intov, tmpnum_uncnstr;
  IGRlong msg_loc, bsflag, stat_func;
  IGRdouble par, par2, dumd, evals[4][3];
  IGRdouble *ptr, *ptr1, *ptr2;
  IGRdouble *intpts, *intpar1, *intpar2, *intovpts, *intov1, *intov2;
  IGRdouble *a_intpts, *a_intpar, *a_intov1, *a_intov2;
  IGRdouble ***sfsf_xyzpts, ***sf1_uvpts, ***sf2_uvpts;
  IGRdouble tol, mindist, tmpdist;
  IGRpoint intpt, tmppt;
  IGRvector intvec, tmpuncnstr_vec[3];
  struct EMSgeomdata red_locus, *locus1, *locus2, tmplocii[2];
  struct EMSpypoint pypoint;
  struct IGRpolyline polyline;
  struct IGRbsp_curve tmpcv;
  extern void EMcnvtpypts(), EMcnvtpybsn();

  *msg = EMS_I_FullyConstrained;
  stat_func = TRUE;

  *num_undercnstr = 0;

  intpts = intpar1 = intpar2 = intovpts = intov1 = intov2 = NULL;
  num_intpts = NULL;
  sfsf_xyzpts = sf1_uvpts = sf2_uvpts = NULL;
  tmpcv.poles = tmpcv.knots = NULL;

  red_locus.curve = NULL;
  red_locus.surface = NULL;

  if (num_locus)
    {
    /*
     * Taking two at a time, reduce the locus down to the simplest
     * geometry. This is the collective locus of the point. If
     * a redundancy or a no-solution is detected, obtain the indices of
     * of the incompatible constraints.
     */

    red_locus = locus[0];
    for (i=0; i<num_locus-1; i++)
      {
      type1 = red_locus.geomtype;
      type2 = locus[i+1].geomtype;

      if (type1 == GEOMDATA_POINT || type2 == GEOMDATA_POINT)
        *msg = EMS_I_Redundant;

      else if (type1 == GEOMDATA_LINE && type2 == GEOMDATA_LINE)
        {
        BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tol);
        msg_loc = EMS_E_Fail;
        MA2lnisect (&msg_loc, &red_locus.line.igr_line,
         &locus[i+1].line.igr_line, &tol, intpt, &par, &par2);
        if (msg_loc == MAINFSOLUTION || msg_loc == MSFAIL)
          {
          if (msg_loc == MAINFSOLUTION)
            *msg = EMS_I_Redundant;
          else
            *msg = EMS_I_NoSolution;
          }
        else
          {
          EMerr_hndlr (msg_loc != MSSUCC, *msg, EMS_E_InvalidCase, ret_end);

          OM_BLOCK_MOVE (intpt, red_locus.point, sizeof (IGRpoint));
          red_locus.geomtype = GEOMDATA_POINT;
          }
        }

      else if (type1 == GEOMDATA_PLANE && type2 == GEOMDATA_PLANE)
        {
        BSpl_pl (red_locus.plane.plane_pt, red_locus.plane.plane_vec,
         locus[i+1].plane.plane_pt, locus[i+1].plane.plane_vec, (IGRint *)&bsflag,
         intpt, intvec, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

        if (bsflag == BSCPARALLEL || bsflag == BSCCOINCIDENT)
          {
          if (bsflag == BSCPARALLEL)
            *msg = EMS_I_NoSolution;
          else
            *msg = EMS_I_Redundant;
          }
        else
          {
          ptr = red_locus.line.igr_line.point1 = red_locus.line.line_pt1;
          OM_BLOCK_MOVE (intpt, ptr, sizeof (IGRpoint));
          ptr = red_locus.line.igr_line.point2 = red_locus.line.line_pt2;
          OM_BLOCK_MOVE (intpt, ptr, sizeof (IGRpoint));
          for (j=X; j<=Z; j++)
            ptr[j] += intvec[j];
          red_locus.geomtype = GEOMDATA_LINE;
          }
        }

      else if (type1 == GEOMDATA_CURVE && type2 == GEOMDATA_CURVE)
        {
        BScvcv_int (&bsflag, red_locus.curve, locus[i+1].curve,
         &num_intpt, &intpts, &intpar1, &intpar2, 
         (IGRlong *)&num_intov, &intovpts, &intov1, &intov2);
        EMerr_hndlr (bsflag != BSSUCC, *msg, EMS_E_Fail, ret_end);

        if (!num_intpt || num_intov)
          {
          if (!num_intpt && !num_intov)
            *msg = EMS_I_NoSolution;
          else
            *msg = EMS_I_Redundant;
          }
        else
          {
          if (num_intpt > 1)
            {
            mindist = MAXDOUBLE;
            for (j=0, k=0; j<num_intpt; j++, k+=3)
              {
              if ((tmpdist = BSdistptpts (&msg_loc, pt, &intpts[k])) < mindist)
                {
                mindist = tmpdist;
                inx = j;
                }
              }
            }
          else
            inx = FIRST;

          OM_BLOCK_MOVE (&intpts[inx*3], red_locus.point, sizeof (IGRpoint));
          red_locus.geomtype = GEOMDATA_POINT;
          }
        }

      else if (type1 == GEOMDATA_SURFACE && type2 == GEOMDATA_SURFACE)
        {
        BSsur_sur (&bsflag, red_locus.surface, locus[i+1].surface,
         &dumd, &dumd, &num_grps, &num_intpts, 
         (IGRpoint ***)&sfsf_xyzpts, (BSpair ***)&sf1_uvpts, (BSpair ***)&sf2_uvpts);
        EMerr_hndlr (bsflag != BSSUCC && bsflag != BSCOINCIDENT, *msg,
         EMS_E_Fail, ret_end);

        if (!num_grps || bsflag == BSCOINCIDENT)
          {
          if (!num_grps && bsflag != BSCOINCIDENT)
            *msg = EMS_I_NoSolution;
          else
            *msg = EMS_I_Redundant;
          }
        else
          {
          if (num_grps > 1)
            {
            mindist = MAXDOUBLE;
            for (j=0; j<num_grps; j++)
              {
              polyline.num_points = num_intpts[j];
              polyline.points = (IGRdouble *) sfsf_xyzpts[i];
              EMcnvtpypts (&msg_loc, &polyline, 3, 1, pt, 0.0, &pypoint,
               &tmpdist);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
       
              if (tmpdist < mindist)
                {
                mindist = tmpdist;
                inx = j;
                }
              }
            }
          else
            inx = FIRST;

          polyline.num_points = num_intpts[inx];
          polyline.points = (IGRdouble *) sfsf_xyzpts[inx];
          tmpcv.poles = NULL;
          tmpcv.knots = NULL;
          EMcnvtpybsn (&msg_loc, 3, &polyline, &tmpcv);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          red_locus.curve = &tmpcv;
          red_locus.geomtype = GEOMDATA_CURVE;
          }
        }

      else if ((type1 == GEOMDATA_PLANE && type2 == GEOMDATA_LINE) ||
               (type1 == GEOMDATA_LINE && type2 == GEOMDATA_PLANE))
        {
        locus1 = type1 == GEOMDATA_LINE ? &locus[i+1] : &red_locus;
        locus2 = type1 == GEOMDATA_LINE ? &red_locus : &locus[i+1];

        BSxlnpl (&msg_loc, locus1->plane.plane_vec, locus1->plane.plane_pt,
         locus2->line.line_pt1, locus2->line.line_pt2,
         intpt);

        if (msg_loc != BSSUCC)
          {
          if (msg_loc == BSCOINCIDENT)
            *msg = EMS_I_Redundant;
          else
            *msg = EMS_I_NoSolution;
          }
        else
          {        
          OM_BLOCK_MOVE (intpt, red_locus.point, sizeof (IGRpoint));
          red_locus.geomtype = GEOMDATA_POINT;
          }
        }

      else if ((type1 == GEOMDATA_PLANE && type2 == GEOMDATA_CURVE) ||
               (type1 == GEOMDATA_CURVE && type2 == GEOMDATA_PLANE))
        {
        locus1 = type1 == GEOMDATA_PLANE ? &locus[i+1] : &red_locus;
        locus2 = type1 == GEOMDATA_PLANE ? &red_locus : &locus[i+1];

        count = locus1->curve->num_poles;
        a_intpts = (IGRdouble *) alloca (count * sizeof (IGRpoint));
        a_intpar = (IGRdouble *) alloca (count * sizeof (IGRdouble));
        a_intov1 = (IGRdouble *) alloca (count * sizeof (IGRdouble));
        a_intov2 = (IGRdouble *) alloca (count * sizeof (IGRdouble));
        EMerr_hndlr (!a_intpts || !a_intpar || !a_intov1 || !a_intov2,
         *msg, EMS_E_NoStackMemory, ret_end);
        BSpl_cv_int (&bsflag, locus1->curve,
         locus2->plane.plane_pt, locus2->plane.plane_vec,
         &num_intpt, a_intpts, a_intpar, &num_intov, a_intov1, a_intov2);
        EMerr_hndlr (bsflag != BSSUCC, *msg, EMS_E_Fail, ret_end);

        if (!num_intpt || num_intov)
          {
          if (!num_intpt && !num_intov)
            *msg = EMS_I_NoSolution;
          else
            *msg = EMS_I_Redundant;
          }
        else
          {
          if (num_intpt > 1)
            {
            mindist = MAXDOUBLE;
            for (j=0, k=0; j<num_intpt; j++, k+=3)
              {
              if ((tmpdist = BSdistptpts (&msg_loc, pt, &a_intpts[k])) <
                  mindist)
                {
                mindist = tmpdist;
                inx = j;
                }
              }
            }
          else
            inx = FIRST;

          OM_BLOCK_MOVE (&a_intpts[inx*3], red_locus.point, sizeof (IGRpoint));
          red_locus.geomtype = GEOMDATA_POINT;
          }
        }

      else if ((type1 == GEOMDATA_PLANE && type2 == GEOMDATA_SURFACE) ||
               (type1 == GEOMDATA_SURFACE && type2 == GEOMDATA_PLANE))
        {
        locus1 = type1 == GEOMDATA_SURFACE ? &locus[i+1] : &red_locus;
        locus2 = type1 == GEOMDATA_SURFACE ? &red_locus : &locus[i+1];

        BSsf_pl_int (locus1->plane.plane_pt, locus1->plane.plane_vec, 
         locus2->surface, FALSE, &num_grps, &num_intpts, (IGRpoint ***)&sfsf_xyzpts,
         (IGRvector ***)&dumd, (BSpair ***)&sf1_uvpts, &msg_loc);
        EMerr_hndlr (bsflag != BSSUCC && bsflag != BSCOINCIDENT, *msg,
         EMS_E_Fail, ret_end);

        if (!num_grps || msg_loc == BSCOINCIDENT)
          {
          if (msg_loc == BSCOINCIDENT)
            *msg = EMS_I_Redundant;
          else
            *msg = EMS_I_NoSolution;
          }
        else
          {        
          if (num_grps > 1)
            {
            mindist = MAXDOUBLE;
            for (j=0; j<num_grps; j++)
              {
              polyline.num_points = num_intpts[j];
              polyline.points = (IGRdouble *) sfsf_xyzpts[i];
              EMcnvtpypts (&msg_loc, &polyline, 3, 1, pt, 0.0, &pypoint,
               &tmpdist);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
       
              if (tmpdist < mindist)
                {
                mindist = tmpdist;
                inx = j;
                }
              }
            }
          else
            inx = FIRST;

          polyline.num_points = num_intpts[inx];
          polyline.points = (IGRdouble *) sfsf_xyzpts[inx];
          tmpcv.poles = NULL;
          tmpcv.knots = NULL;
          EMcnvtpybsn (&msg_loc, 3, &polyline, &tmpcv);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          red_locus.curve = &tmpcv;
          red_locus.geomtype = GEOMDATA_CURVE;
          }
        }

      else
        {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

      /*
       * If there was any conflict between the constraints or a no-solution
       * condition then we need to return the indices of the incompatible 
       * constraints.
       */
 
      if (*msg == EMS_I_Redundant || *msg == EMS_I_NoSolution)
        {
        conflict_pair[0] = i;
        conflict_pair[1] = i+1;

        if (i+1 == TOT_DOF_POINT-1)
          {
          /*
           * A reduced locus caused the problem. Try to find
           * which of the two locii which contributed to this 
           * reduced locus caused the conflict or no solution.
           */

          tmplocii[FIRST] = locus[i];
          tmplocii[SECOND] = locus[i+1];
          EMsolvecnstr_pt (&msg_loc, opts, pt, 2, tmplocii, tmppt,
           tmpconflict, &tmpnum_uncnstr, tmpuncnstr_vec);
          if (msg_loc != EMS_I_NoSolution && msg_loc != EMS_I_Redundant)
            {
            conflict_pair[0] = i-1;
            conflict_pair[1] = i+1;
            }
          }
        goto ret_end;
        }
      }

    /*
     * Project the point onto the reduced locus. If the reduced locus
     * is a point, then this point is itself the solution
     */

    if (red_locus.geomtype == GEOMDATA_POINT)
      OM_BLOCK_MOVE (red_locus.point, solved_pt, sizeof (IGRpoint));
    else if (red_locus.geomtype == GEOMDATA_LINE)
      {
      BSproj0 (&msg_loc, pt,
       (IGRpoint *)red_locus.line.line_pt1,
       solved_pt);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);

      *num_undercnstr = 1;
      ptr = undercnstr_vecs[FIRST];
      ptr1 = red_locus.line.line_pt1;
      ptr2 = red_locus.line.line_pt2;
      for (i=X; i<=Z; i++)
        ptr[i] = ptr2[i] - ptr1[i];
      BSnorvec (&msg_loc, ptr);
      *msg = EMS_I_UnderConstrained;
      }
    else if (red_locus.geomtype == GEOMDATA_PLANE)
      {
      BSproj1 (&msg_loc, pt,
       red_locus.plane.plane_vec, red_locus.plane.plane_pt,
       solved_pt);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);

      *num_undercnstr = 2;
      EMorthovec (red_locus.plane.plane_vec, undercnstr_vecs[FIRST]);
      BScrossp (&msg_loc, red_locus.plane.plane_vec, undercnstr_vecs[FIRST],
       undercnstr_vecs[SECOND]);
      BSnorvec (&msg_loc, undercnstr_vecs[SECOND]);
      *msg = EMS_I_UnderConstrained;
      }
    else if (red_locus.geomtype == GEOMDATA_CURVE)
      {
      BSmdstptcv (red_locus.curve, pt, &par, solved_pt, &mindist, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);

      *num_undercnstr = 1;
      BScveval (red_locus.curve, par, 1, evals, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);
      OM_BLOCK_MOVE (evals[1], undercnstr_vecs[FIRST], sizeof (IGRvector));
      BSnorvec (&msg_loc, undercnstr_vecs[FIRST]);
      *msg = EMS_I_UnderConstrained;
      }
    else if (red_locus.geomtype == GEOMDATA_SURFACE)
      {
      BSmdistptsf (&msg_loc, red_locus.surface, pt, &par, &par2, solved_pt,
       &mindist);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);

      *num_undercnstr = 2;
      BSsfeval (red_locus.surface, par, par2, 1, evals, &msg_loc);
      OM_BLOCK_MOVE (evals[1], undercnstr_vecs[FIRST], sizeof (IGRvector));
      BSnorvec (&msg_loc, undercnstr_vecs[FIRST]);
      OM_BLOCK_MOVE (evals[2], undercnstr_vecs[SECOND], sizeof (IGRvector));
      BSnorvec (&msg_loc, undercnstr_vecs[SECOND]);
      *msg = EMS_I_UnderConstrained;
      }
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
    }
  else
    {
    /*
     * No constraints on this point. So return the
     * same point back.
     */

    OM_BLOCK_MOVE (pt, solved_pt, sizeof (IGRpoint));
    *num_undercnstr = 3;
    for (i=FIRST; i<=THIRD; i++)
      {
      ptr = undercnstr_vecs[i];
      for (j=X; j<=Z; j++)
        ptr[j] = (i == j ? 1.0 : 0.0);
      }
    *msg = EMS_I_UnderConstrained;
    }

ret_end:
  if (intpts)
    om$dealloc (ptr = intpts);
  if (intpar1)
    om$dealloc (ptr = intpar1);
  if (intpar2)
    om$dealloc (ptr = intpar2);
  if (intovpts)
    om$dealloc (ptr = intovpts);
  if (intov1)
    om$dealloc (ptr = intov1);
  if (intov2)
    om$dealloc (ptr = intov2);
  if (tmpcv.poles)
    om$dealloc (ptr = tmpcv.poles);
  if (tmpcv.knots)
    om$dealloc (ptr = tmpcv.knots);
  if (num_intpts)
    om$dealloc (ptr = num_intpts);
 
 if (sfsf_xyzpts)
    {
    for (i=0; i<num_grps; i++)
      if (sfsf_xyzpts[i])
        om$dealloc (ptr = sfsf_xyzpts[i]);
    om$dealloc (ptr = sfsf_xyzpts[i]);
    }
  
  if (sf1_uvpts)
    {
    for (i=0; i<num_grps; i++)
      if (sf1_uvpts[i])
        om$dealloc (ptr = sf1_uvpts[i]);
    om$dealloc (ptr = sf1_uvpts[i]);
    }
  
  if (sf2_uvpts)
    {
    for (i=0; i<num_grps; i++)
      if (sf2_uvpts[i])
        om$dealloc (ptr = sf2_uvpts[i]);
    om$dealloc (ptr = sf2_uvpts[i]);
    }
  
  EMWRAPUP (*msg, stat_func, "EMsolvecnstr_pt");
  return;
}


/*
  DESCRIPTION
    
    The following function takes in a vector and a set of locii. These
    locii are either planes ot vectors. It tries to find the best solution
    that satisfies all of these at the same time. Any over-constraint is
    returned. If no solution, then the two constraints that did not intersect
    are returned.

    Return code could be EMS_I_FullyConstrained, EMS_I_UnderConstrained or
    EMS_I_NoSolution, EMS_I_Redundant or EMS_E_Fail. On conflict or no-solution
    the conflicting pair of locii is returned in the form of their indexes.

  HISTORY

    SS  :  07/08/91  :  Creation
*/

void EMsolvecnstr_vc (msg, opts, vc, num_locus, locus,
                      solved_vc, 
                      conflict_pair, num_undercnstr, undercnstr_vecs)
IGRlong *msg;
IGRushort opts;
IGRvector vc;
IGRint num_locus;
struct EMSgeomdata *locus;
IGRvector solved_vc;
IGRint *conflict_pair;
IGRint *num_undercnstr;
IGRvector undercnstr_vecs[3];
{
  IGRint i, type1, type2;
  IGRlong msg_loc, bsflag, stat_func;
  IGRdouble *p_ptr;
  IGRpoint intpt, tmppt;
  IGRvector intvec;
  struct EMSgeomdata red_locus;

  *msg = EMS_I_FullyConstrained;
  stat_func = TRUE;

  *num_undercnstr = 0;

  if (num_locus)
    {
    /*
     * Some constraints exist. The only constraint allowed are the ones
     * that produce vectors or planes as locii. Taking two at a time, reduce
     * the locus down to the simplest geometry. This is the collective locus
     * of the vector.
     */

    red_locus = locus[0];
    for (i=0; i<num_locus-1; i++)
      {
      type1 = red_locus.geomtype;
      type2 = locus[i+1].geomtype;

      if (type1 != GEOMDATA_VECTOR && type1 != GEOMDATA_PLANE &&
          type2 != GEOMDATA_VECTOR && type2 != GEOMDATA_PLANE)
        {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

      else if (type1 == GEOMDATA_PLANE && type2 == GEOMDATA_PLANE)
        {
        BSpl_pl (red_locus.plane.plane_pt, red_locus.plane.plane_vec,
         locus[i+1].plane.plane_pt, locus[i+1].plane.plane_vec, (IGRint *)&bsflag,
         intpt, intvec, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

        if (bsflag == BSCPARALLEL || bsflag == BSCCOINCIDENT)
          {
          if (bsflag == BSCPARALLEL)
            *msg = EMS_I_NoSolution;
          else
            *msg = EMS_I_Redundant;
          }
        else
          {
          OM_BLOCK_MOVE (intvec, red_locus.vector, sizeof (IGRvector));
          red_locus.geomtype = GEOMDATA_VECTOR;
          }
        }
      else
        *msg = EMS_I_Redundant;
      
      /*
       * If there was any conflict between the constraints or a no-solution
       * condition then we need to return the indices of the incompatible 
       * constraints.
       */
 
      if (*msg == EMS_I_Redundant || *msg == EMS_I_NoSolution)
        {
        conflict_pair[0] = i;
        conflict_pair[1] = i+1;

        /*
         * Since there are only two types of locii are allowed - vector or
         * plane - it follows that the first iteration will itself reduce
         * to the solution. So no more sophistication is required to
         * detect incompatible constraints.
         */

        goto ret_end;
        }
      }

    /*
     * Project the vector onto the reduced locus. If the reduced locus
     * is a vector, then this vector is itself the solution.
     */

    if (red_locus.geomtype == GEOMDATA_VECTOR)
      OM_BLOCK_MOVE (red_locus.vector, solved_vc, sizeof (IGRvector));
    else if (red_locus.geomtype == GEOMDATA_PLANE)
      {
      p_ptr = red_locus.plane.plane_pt;
      OM_BLOCK_MOVE (p_ptr, tmppt, sizeof (IGRpoint));
      for (i=X; i<=Z; i++)
        tmppt[i] += vc[i]; 
     
      BSproj1 (&msg_loc, tmppt,
       red_locus.plane.plane_vec, red_locus.plane.plane_pt,       
       tmppt);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);

      OM_BLOCK_MOVE (tmppt, solved_vc, sizeof (IGRvector));
      for (i=X; i<=Z; i++)
        solved_vc[i] -= p_ptr[i]; 
      BSnorvec (&msg_loc, solved_vc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_S_Fail, ret_end);

      *num_undercnstr = 1;
      EMorthovec (red_locus.plane.plane_vec, undercnstr_vecs[FIRST]);
      BSnorvec (&msg_loc, undercnstr_vecs[SECOND]);
      *msg = EMS_I_UnderConstrained;
      }
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
    }
  else
    {
    /*
     * No constraints on this vector. So return the same vector back.
     * There are two degrees of freedom left on this vector.
     */

    OM_BLOCK_MOVE (vc, solved_vc, sizeof (IGRvector));

    *num_undercnstr = 2;
    EMorthovec (solved_vc, undercnstr_vecs[FIRST]);
    BScrossp (&msg_loc, solved_vc, undercnstr_vecs[FIRST],
     undercnstr_vecs[SECOND]);
    BSnorvec (&msg_loc, undercnstr_vecs[SECOND]);
    *msg = EMS_I_UnderConstrained;
    }

ret_end:
  EMWRAPUP (*msg, stat_func, "EMsolvecnstr_vc");
  return;
}

end implementation EMSparamgm;

