/*
  DESCRIPTION

    This method is intended to process the intersection between two 
    coincident planar surfaces. The method is invoked on one of these
    surfaces, giving the other as as an argument.

  BUGS

    In the event a double check is being performed and some coincident
    edges are found, a kluge is put in to avoid excessive coding. This
    involves the call to EMgetcoinceds without specifying tha correct
    part of the edge being looked at.

  HISTORY

    SS  :  late 87   :  Creation
    SS  :  01/04/88  :  Added support for double-checking which performs
                        extensive checking for coincident edges in the
                        "vicinity" of the boundary of the coincident planes.
    SM  :  24-Oct-89 :  Moved following options from EMlscvbool.I to
			here --
			(double_check ?
                        (EMImpBnd_DegenerateBdrys | EMImpBnd_BdryIsArea) : 
			NULL).
    NP/SM:6/12/92    :  Sending in EMImpBnd_BdryIsArea option to the
			cvboolean method if "PROCOVERLAP" trimming option
			is set so that overlappiong boundaries on planes
			will be correctly split.
    NP  :  24-Aug-92 :  Modified for ANSI compliance. 
    SM  :  24-Jan-93 :  Modified channel sends of EMtree_traverse to loops
                        of loopsetid1 and loopsetid2 to targetid/targetos
                        sends, to handle the fact that construct_os can be
                        different than the os of either operands.
    NP  :  11-Mar-93 :  Equality check for "srfid" and "my_id" expanded to 
                        include respective object space numbers too. Can be a 
                        potential problem since objid's could be same for 
                        different objects across object spaces.
*/

class implementation EMSsubbs;

%safe
#include <math.h>
%endsafe
#include "EMS.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSssprops.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsimpdef.h"

/*
 * A factor used on tolerance to make it safe to be used in checking
 * if a given point lies on an edge or not.
 */

#define ONEDGE_TOL_FACTOR  3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define U_SAMPLE_POINT 0.485
#define V_SAMPLE_POINT 0.485

#define U 0
#define V 1

#define X 0
#define Y 1
#define Z 2

#define START 0
#define STOP  1

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_EMSedge_class_id;
extern GRclassid OPP_EMSloop_class_id, OPP_EMSloopset_class_id;

from EMSboundary import EMdebug_display, EMtpcopy;
from EMSboundary import EMtree_traverse, EMgetsurface_info;
from EMSboundary import EMcoincedges, EMget_edges;
from EMSloopset import EMcvboolean;
from EMSloop import EMset_props, EMreverse;
from EMSedge import EMsfintdata, EMptproject, EMsplityourself;

method EMbdryint  (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args;
                   struct GRid *other_obj;
                   struct GRmdenv_info *other_datenv;
                   IGRushort outworld_options;
                   IGRushort outparam_options;
                   IGRushort trim_options;
                   IGRlong *num_inters;
                   struct EMSinters **my_inters; 
                   struct EMSinters **other_inters)
{
  IGRboolean stat_func, sfrev, same_side, found, in_world;
  IGRboolean double_check, coincidence_known;
  IGRushort oriented1, oriented2;
  IGRushort proc_info, lssplit_options = NULL;
  IGRshort *curr_xform_mattyp;
  IGRint i, j, dumint, num_xyzedges, num_coinc;
  IGRuint  count;
  IGRlong msg_loc, send_rc, stat_OM, stat_tmp;
  IGRdouble upar, vpar, natnorm1[2][3], natnorm2[2][3];
  IGRdouble lentol, partol, crosstol;
  IGRdouble dotp, dist, xyzpt[3], *curr_xform_mat;
  GRobjid loopsetid1, loopsetid2;
  GRobjid srfid, uvedge, splitedges[2];
  GRspacenum os, construct_os;
  struct GRmd_env xform_env1, xform_env2;
  struct GRmdenv_info inv_info1, inv_info2;
  struct GRid my_obj, *xyzedges;
  struct IGRbsp_surface sfdef1, sfdef2;
  struct EMSpartolbasis partolb;
  struct EMSpypoint *splitpts, *pyptr;
  struct EMSsfintedpar *splitepars, *eptr, *subsepars, *incinfo, *tempptr;
  struct EMSsfintedpar *split_info[2], ept;
  struct EMSproj_info proj_info;
  struct EMSinters *inters_loc, **ptr_inters_loc;
  struct EMSintobj *intobj_loc;
  enum EMSbooltype boolop;
  OM_S_CHANSELECT chan_to_loops, chan_to_assoc, chan_to_commedge;
  OM_S_OBJECT_LINKAGE objlist;
  void EMtoplnxform(), EMpypoint_free();
  extern IGRboolean BSdistptpl();
  extern IGRdouble BSdotp();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  loopsetid1 = NULL_OBJID;
  loopsetid2 = NULL_OBJID;
  xyzedges = NULL;
  splitpts = NULL;
  splitepars = NULL;
  subsepars = NULL;
  coincidence_known = trim_options & EMSINT_TRIM_COPLANAR;
  double_check = trim_options & EMSINT_TRIM_MOREPRECISE;

  if (const_args)
    construct_os = const_args->env_info->md_id.osnum;
  else
    construct_os = OM_Gw_current_OS;

  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &sfdef1),
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &sfdef2),
             targetid = other_obj->objid, targetos = other_obj->osnum);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  /*
   * Preliminary validation that checks for this object and the 
   * incoming data to be planar. If the coincidence-property is already
   * known - no check.
   */

  EMerr_hndlr (! sfdef1.planar, *msg, EMS_I_InvalidCase, ret_end);
  EMerr_hndlr (! sfdef2.planar, *msg, EMS_I_InvalidArg, ret_end);
    
  /*
   * Both the natural normals must point along the same line. 
   */

  upar = U_SAMPLE_POINT;
  vpar = V_SAMPLE_POINT;
  stat_OM = om$send (msg = message EMSsubbs.EMsftanorm (&msg_loc, mattyp, mat,
             const_args, 1, &upar, 1, &vpar, 1.0, NULL, FALSE, TRUE,
             (IGRdouble *) natnorm1, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  for (i=X; i<=Z; i++)
    natnorm1[1][i] = natnorm1[1][i] - natnorm1[0][i];

  stat_OM = om$send (msg = message EMSsubbs.EMsftanorm (&msg_loc, 
             &other_datenv->matrix_type, other_datenv->matrix, const_args,
             1, &upar, 1, &vpar, 1.0, NULL, FALSE, TRUE,
             (IGRdouble *) natnorm2, NULL), targetid = other_obj->objid, 
             targetos = other_obj->osnum);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  for (i=X; i<=Z; i++)
    natnorm2[1][i] = natnorm2[1][i] - natnorm2[0][i];

  /*
   * Check for both the planes being exactly the same
   */

  BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, crosstol);
  dotp = BSdotp (&msg_loc, natnorm1[1], natnorm2[1]);
  EMerr_hndlr (!coincidence_known && 1.0 - fabs (dotp) > crosstol, *msg,
   EMS_E_InvalidArg, ret_end);

  stat_func = BSdistptpl (&msg_loc, natnorm1[0], natnorm2[0], natnorm2[1],
               &dist);
  EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  EMerr_hndlr (!coincidence_known && dist > lentol, *msg, 
   EMS_E_InvalidArg, ret_end);

  /*
   * Compute the matrices for the two surface-objects that take them from
   * world co-ordinate space into the Z=0 plane. Also computed are the inverse
   * matrices that transform the Z=0 plane into the local-coordinate space
   * of the particular object-space (this is a partial inverse; it is
   * more useful since this matrix can be used in conjunction with 
   * environment matrix for the particular space in the various methods).
   *
   * The matrices are computed using the plane information for this surface. 
   * The normal for the other surface might be directionally opposite
   * to this one. This is corrected later in the processing by a reversal
   * of geometry.
   */

  EMtoplnxform (&msg_loc, natnorm1[0], natnorm1[1], mattyp, mat,
   &xform_env1.md_env.matrix_type, xform_env1.md_env.matrix, 
   &inv_info1.matrix_type, inv_info1.matrix, &lentol);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

  EMtoplnxform (&msg_loc, natnorm1[0], natnorm1[1], &other_datenv->matrix_type,
   other_datenv->matrix, &xform_env2.md_env.matrix_type, 
   xform_env2.md_env.matrix, &inv_info2.matrix_type, inv_info2.matrix,
   &lentol);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

  /*
   * Extract the model-space loopsets from the existing parametric-space
   * ones, using the above matrices.
   */
  
  stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&send_rc,
             message EMSboundary.EMtpcopy (&msg_loc, &xform_env1,
             OM_Gw_current_OS, construct_os, EMS_COPY_XYZ | EMS_COPY_PRIMEDGE,
             &loopsetid1)), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc & send_rc), *msg,
   EMS_E_LoopsetError, ret_end);

  stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&send_rc,
             message EMSboundary.EMtpcopy (&msg_loc, &xform_env2,
             other_obj->osnum, construct_os,
             EMS_COPY_XYZ | EMS_COPY_PRIMEDGE,
             &loopsetid2)), targetid = other_obj->objid, 
             targetos = other_obj->osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc & send_rc), *msg,
   EMS_E_LoopsetError, ret_end);

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);

  if (dotp < 0.0)
    {
    /*
     * The normal of the input surface is directionally opposite to that
     * of this surfaces normal. The loops are directionally reversed to
     * preserve consistency. Their loop-types (P or C) should be
     * maintained (since the area/hole properties do not change).
     */

    stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
               message EMSloop.EMreverse (&msg_loc), MAXINT, 1,
               &OPP_EMSloop_class_id, TRUE, NULL, NULL, NULL),
               targetid = loopsetid2, targetos = construct_os);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc & send_rc), *msg, EMS_E_LoopError,
     ret_end);

    stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
               message EMSloop.EMset_props (&msg_loc, EMLP_PLOOP, 
               EMS_O_TOGGLE), MAXINT, 1, &OPP_EMSloop_class_id, TRUE, NULL,
               NULL, NULL), targetid = loopsetid2, targetos = construct_os);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc | send_rc), *msg, EMS_E_LoopError,
     ret_end);

    sfrev = TRUE;
    }
  else
    sfrev = FALSE; 

  /*
   * Perform the intersection Boolean operation on these xy-curves and obtain
   * the resultant loopset in loopsetid1. If no intersection exists between
   * the two sets of areas, return.
   */

  boolop = EMSbool_intersect;
  partolb.tol = lentol;
  partolb.is_valid = TRUE;

  if (trim_options & EMSINT_TRIM_PROCOVERLAP)
    lssplit_options = EMImpBnd_BdryIsArea;
  if (double_check)
    lssplit_options |= (EMImpBnd_DegenerateBdrys | EMImpBnd_BdryIsArea);

  stat_OM = om$send (msg = message EMSloopset.EMcvboolean (&msg_loc, boolop, 
             loopsetid2, (double_check ? EMS_SFINT_DOUBLECHECK : NULL),
             lssplit_options, NULL, NULL, NULL, NULL, &partolb), 
             targetid = loopsetid1, targetos = construct_os);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopsetError,
   ret_end);
  loopsetid2 = NULL_OBJID;
  if (msg_loc == EMS_I_NoIntersection)
    goto ret_end;

  /*
   * If the option to perform a double-check is on, check for the following
   * condition: Each edge of the above output loopset corresponds to
   * a uv-edge on the planar surface, which in turn corresponds to it's
   * common edge. In some cases, the common-edge may be geometrically
   * overlapping some other edges in it's uv-space. If such overlapping edges
   * exist and if they have a partial overlap (only a part of the edge
   * overlaps the common-edge), the xyz-edge of the output loopset must
   * be split such that the resulting pieces now have a complete overlap with
   * all geomtrically coincident edges. This needs to be done in order
   * to satisfy the assumption being made by the edge-processing method
   * being called next, that all xyz-edges correspond to a definite set of
   * uv-edges and vice-versa.
   */

 if (double_check)
   {
   dumint = 0;
   num_xyzedges = 0;
   stat_OM = om$send (msg = message EMSboundary.EMget_edges (&msg_loc,
              MAXINT, EMS_OPT_NONDEG_NONSEAM, &xyzedges, &dumint,
              &num_xyzedges), targetid = loopsetid1, 
              targetos = construct_os);
   EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopsetError,
    ret_end);

   stat_OM = EMmake_chanselect (GRnotify_notification, &chan_to_assoc);
   EMomerr_exit (stat_OM, ret_end);

   stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_commedge);
   EMomerr_exit (stat_OM, ret_end);

   for (i=0; i<num_xyzedges; i++)
     {
     stat_OM = om$get_channel_objects (osnum = construct_os, 
                objid = xyzedges[i].objid, p_chanselect = &chan_to_assoc,
                list = &objlist, size = 1, count = &count);
     EMomerr_exit (stat_OM, ret_end);
     EMerr_hndlr (stat_OM == OM_I_LISTOVFLOW, *msg, EMS_E_InvalidCase,
      ret_end);
     uvedge = objlist.S_objid;
     os = objlist.osnum;

     stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
                &srfid, NULL), targetid = uvedge, targetos = os);
     EMomerr_exit (stat_OM, ret_end);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

     if ((IF_EQ_OBJID (srfid, my_id)) && (os == OM_Gw_current_OS))
       {
       partolb.mattyp = mattyp;
       partolb.mat = mat;
       curr_xform_mattyp = &xform_env1.md_env.matrix_type;
       curr_xform_mat = xform_env1.md_env.matrix;
       }
     else
       {
       partolb.mattyp = &other_datenv->matrix_type;
       partolb.mat = other_datenv->matrix;
       curr_xform_mattyp = &xform_env2.md_env.matrix_type;
       curr_xform_mat = xform_env2.md_env.matrix;
       }
     partolb.in_world = TRUE;
     partolb.is_valid = FALSE;

     stat_OM = om$get_channel_objects (osnum = os, objid = uvedge,
                p_chanselect = &chan_to_commedge, list = &objlist, size = 1,
                count = &count);
     EMomerr_exit (stat_OM, ret_end);
     uvedge = objlist.S_objid;

     /*
      * The coincidence with other edges within the surface must be checked
      * with only that portion of the edge which corresponds to the
      * xyz-edge. But to get the partinfo involves extensive coding for
      * little gain. So until the need explicitly arises avoid it.
      */

     num_coinc = 0;
     splitpts = NULL;
     splitepars = NULL;
     stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
                message EMSboundary.EMcoincedges (&msg_loc, uvedge, NULL,
                NULL, NULL, &partolb, &num_coinc, &splitpts, &splitepars),
                MAXINT, 1, &OPP_EMSloopset_class_id, EMStreetrav_up,
                NULL, NULL, NULL), targetid = uvedge, targetos = os);
     EMomerr_exit (stat_OM, ret_end);
     EMerr_hndlr (EMSerror (stat_OM & msg_loc & send_rc), *msg, 
      EMS_E_EdgeError, ret_end);
     partol = partolb.tol;

     if (num_coinc)
       {
       pyptr = splitpts;
       eptr = splitepars;
       for (j=0; j<num_coinc*2; j++)
         {
         if (pyptr->props & EMS_PYPT_ATMIDDLE)
           {
           stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info 
                      (&msg_loc, &srfid, NULL), targetid = uvedge,
                      targetos = os);
           EMomerr_exit (stat_OM, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

           stat_OM = om$send (msg = message GRvg.EMptatpr (&msg_loc, 
                      curr_xform_mattyp, curr_xform_mat, pyptr->point, 2,
                      xyzpt), targetid = srfid, targetos = os);
           EMomerr_exit (stat_OM, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

           partolb.is_valid = TRUE;
           partolb.tol = lentol;
           stat_OM = om$send (msg = message EMSedge.EMptproject (&msg_loc,
                      xyzpt, 1, &proj_info, NULL, &partolb), 
                      targetid = xyzedges[i].objid, targetos = construct_os);
           EMomerr_exit (stat_OM, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

           /*
            * Since the coincidence was found with respect to the full-edge
            * it is possible that this point does not really lie on the
            * edge. Check for this, and only if the point lies on the edge
            * peform the split.
            */

           if (proj_info.dist < lentol * ONEDGE_TOL_FACTOR)
             {
             ept.intloc = proj_info.location;
             ept.edgepar = proj_info.param;
             ept.point[U] = proj_info.proj_pt[U];
             ept.point[V] = proj_info.proj_pt[V];
             split_info[0] = &ept;
             split_info[1] = NULL;

             stat_OM = om$send (msg = message EMSedge.EMsplityourself 
                        (&msg_loc, split_info, NULL, NULL, splitedges, NULL,
                        NULL, NULL, &partolb, NULL, NULL, NULL, NULL), 
                        targetid = xyzedges[i].objid, targetos = construct_os);
             EMomerr_exit (stat_OM, ret_end);
             EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, 
              ret_end);

             /*
              * Store the information about this point on the edge along
              * with it's coincident point, as a pair in an EMSsfintedpar
              * linked list. Later, after processing the intersections,
              * the incidence info contained in the intersection list can
              * be substituted with the "coincidence" info. The "coincidence"
              * info is the one that gives the correct topology. This can be
              * visualized if one imagines the position of the final 
              * intersection inside the loopset. It is going to be touching
              * the "coincident" vertex.
              */

             EMmkeparlist (&msg_loc, &subsepars, EMScvint_middle, uvedge,
              pyptr->span_inx, pyptr->param, pyptr->point, NULL, FALSE);
             EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

             EMmkeparlist (&msg_loc, &subsepars, eptr->intloc, eptr->edgeid,
              eptr->edgepar.span_inx, eptr->edgepar.param, eptr->point, 
              eptr->info, FALSE);
             EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
             }
           }
         pyptr = pyptr->next;
         eptr = eptr->next;
         }
       
       EMpypoint_free (splitpts, MAXINT);
       splitpts = NULL;
       EMsfintedpar_free (splitepars, MAXINT);
       splitepars = NULL;
       }
     }
   }

  /*
   * Extract the results of this operation into an intersection-list
   * and exit.
   *
   * Information about the "directed" normals is required by the 
   * data extraction method (it always returns oriented data - one way or the
   * other). The "pos_orient" field, along with the natural normals should
   * give an idea of how the normals are directed - whether along
   * the same direction or opposite.
   */

  oriented1 = sfdef1.pos_orient ? 0x1 : 0x0;
  oriented2 = sfdef2.pos_orient ? 0x1 : 0x0;
  if (dotp < 0.0)
    same_side = (oriented1 ^ oriented2) ? TRUE : FALSE;
  else
    same_side = (oriented1 ^ oriented2) ? FALSE : TRUE;
  
  /*
   * Pass in the information about the relative positioning of the volumes
   * bounded by the coincident planes - whether they are on the same side
   * or not. Also, give the information about which of the two involved
   * surfaces is the primary operand in this operation (eg: in A-int-B,
   * the primary operand is A). 
   */

  proc_info = NULL;
  if (! (trim_options & EMSINT_TRIM_OPSWITCHED))
    proc_info |= EMSsfint_edge_primary1;
  if (same_side)
    proc_info |= EMSsfint_edge_sameside;

  my_obj.objid = my_id;
  my_obj.osnum = OM_Gw_current_OS;
  stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
             message EMSedge.EMsfintdata (&msg_loc, &my_obj, FALSE, 
             &xform_env1.md_env, &inv_info1, other_obj, sfrev, 
             &xform_env2.md_env, &inv_info2, proc_info, const_args,
             outworld_options, outparam_options, trim_options, num_inters,
             my_inters, other_inters), MAXINT, 1, &OPP_EMSedge_class_id,
             TRUE, NULL, NULL, NULL), 
             targetid = loopsetid1, targetos = construct_os);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc | send_rc), *msg, EMS_E_LoopsetError,
   ret_end);

  /*
   * If double-check is on, there might be some intersection incidence
   * information generated within this function that might need to be
   * be substituted for corresponding information generated on some 
   * of the coincident edges. Only intersections marked as produced
   * by coincident-plane processing and which are non-deletable need be
   * looked at.
   */

  if (double_check && subsepars)
    {
    for (i=FIRST; i<=SECOND; i++)
      {
      if (ptr_inters_loc = i == FIRST ? my_inters : other_inters)
        inters_loc = *ptr_inters_loc;
      else
        continue;

      while (inters_loc)
        {
        in_world = TRUE;
        stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                   i == FIRST ? mattyp : &other_datenv->matrix_type,
                   i == FIRST ? mat : other_datenv->matrix,
                   &in_world, TRUE, &partol), 
                   targetid = inters_loc->this_obj.objid,
                   targetos = inters_loc->this_obj.osnum);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

        intobj_loc = inters_loc->cvs;
        while (intobj_loc)
          {
          if ((intobj_loc->props & EMSintobj_coincident) &&
              !(intobj_loc->props & EMSintobj_deletable))
            {
            incinfo = (struct EMSsfintedpar *) intobj_loc->more_info;
            if (incinfo)
              {
              for (j=FIRST; j<=SECOND; j++)
                {
                eptr = subsepars;
                found = FALSE;
                while (!found && eptr)
                  {
                  if (eptr->edgeid == incinfo->edgeid &&
                      eptr->intloc == incinfo->intloc &&
                      EM2ddistptpt (eptr->point, incinfo->point) <= partol)
                    {
                    tempptr = incinfo->next;
                     *incinfo = *eptr->next;
                    incinfo->next = tempptr;
                    found = TRUE;
                    }
                  eptr = eptr->next->next;
                  }
                incinfo = incinfo->next;
                }
              }
            }
          intobj_loc = intobj_loc->next;
          }
        inters_loc = inters_loc->next;
        }
      }
    }

ret_end:
  if (! IF_NULL_OBJID (loopsetid1))
    stat_tmp = om$send (msg = message Root.delete (TRUE), 
                targetid = loopsetid1, targetos = construct_os);
             
  if (! IF_NULL_OBJID (loopsetid2))
    stat_tmp = om$send (msg = message Root.delete (TRUE), 
                targetid = loopsetid2, targetos = construct_os);

  if (xyzedges)
    om$dealloc (ptr = xyzedges);

  if (splitpts)
    EMpypoint_free (splitpts, MAXINT);
  if (splitepars)
    EMsfintedpar_free (splitepars, MAXINT);
  if (subsepars)
    EMsfintedpar_free (subsepars, MAXINT);

  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMbdryint");
  return (stat_OM);
}

end implementation EMSsubbs;
