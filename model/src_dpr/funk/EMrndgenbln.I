class implementation EMSsfrndbool;

#include <math.h>

#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"
#include "bstypes.h"
#include "prototypes/bscvcvint.h"
#include "prototypes/bsconstprcv.h"
#include "prototypes/bscveval.h"
#include "prototypes/bsalloccv.h"
#include "prototypes/bsfreecv.h"
#include "prototypes/bssfarrevn.h"
#include "prototypes/bsmdistptsf.h"
#include "prototypes/bsiarcln.h"
#include "prototypes/bssfarrev1.h"
#include "prototypes/bscrossp.h"
#include "prototypes/bsdotp.h"
#include "prototypes/bsprptoncv.h"
#include "prototypes/bsnorvec.h"
#include "prototypes/bssfploutcv.h"
#include "prototypes/bsmergarrcv.h"
#include "OMmacros.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSrnd.h"
/*
#include "EMSrndprotyp.h"
*/

from EMSboundary import  EMgetsurface_info;
from EMSsubbs	 import	 EMget_int_data, EMget_edges;
from EMSedge     import  EMget_edge_length, EMxyz_endpt, EMptalong, EMget_props;

%safe
static void get_prev_and_next_index();
%endsafe

#define	FIRST	0
#define	SECOND	1

#define U	0
#define	V	1

#define U0	0
#define	V1	1
#define U1	2
#define V0	3

#define CONST_U	1
#define CONST_V	2

#define FILLET_U0	0.0
#define FILLET_U1	1.0

#define PARAM_V0	0.0
#define PARAM_V1	1.0

#define CV_1		0
#define CV_2		1

#define MODEL_SURFACE	0
#define BLEND_PATCH	1

#define REAL_VALUE_ACCURACY	0.0001
#define DELTA_V			0.001

#define SETBACK_FRACTION_1	0.1
#define SETBACK_FRACTION_2	0.2
#define SETBACK_FRACTION_3	0.5
#define SETBACK_FRACTION_4	1.25

#define UPPER_ANG_BOUND		PI*25.0/180.0

#define MAX_TO_STACK_ALLOC	8

typedef IGRdouble point2d[2];

/*
 * This structure defines a single blend group, by its start and the end blend
 * curves, and the number of blend curves in the group.
 */
struct EMSrnd_blend_group
  {
  IGRint  num_elems;
  struct  EMSrnd_blend_curve_info *start_of_grp, *end_of_grp;
  };

/*
 * If consecutive edges are rounded, we route the bound curves to round vertex.
 * This structure stores the start and end bound indices for each group.
 */
struct EMSrnd_grp_info 
  {
  IGRint  start_bnd_inx;
  IGRint  end_bnd_inx;
  };

/* 
  DESCRIPTION

    This function provides the vital functionality of a n-sided blend at a 
    m-vertex. It creates the bounding curves for such a vertex, and constructs
    an appropriate blend surface. The design of this function is motivated by 
    the desire to provide a blend that 'looks' nice to an user.The algorithmic
    determination of what 'looks' nice requires the determination of a
    functional relationship between some independant variables, and the blend,
    which is not a trivial. Consequently, the algorithm is base on some
    heuritics, designed to provide the 'expected' result in the obvious
    situations, and to provide 'acceptable' results in other cases. Heuristics
    that govern the 'acceptability' of the blend may produce a solution that
    might not be entirely satisfactory to the user. Consequently, the
    provision of a blend editing capability is anticipated (perhaps, post 4.0).
    Clearly, manual editing of a blend is not advisable in the associative
    world. Set back distances, blend curve geometries, etc. might not be
    suitable for new model geometry (unless the change to the model did not
    have any effect on the blend).

    Some of the parameters which determine the geometry of the blend are
    . The angle measure between surfaces along an edge.  If a fillet exists
         along this edge, then the arc lengths of the fillet cross section arcs
         is a function of this angle [thus, the arclength can vary between zero
         (where the two surfaces are tangent), to PI*fillet_radius/2 (where the
         two surfaces are orthogonal)].
    . Included angle between an edge, and its neghbors [this is useful only
         when the edge geometry is linear (or nearly linear) in a neighborhood
         of the vertex].
    . Curvature of the edges at the vertex (again a local measure).


  ARGUMENTS
    fillet_patch        - Input/Output: Id of the composite surface to which
                           the blends/patches generated herein
                           will be appended to.

    fillet_inters       - Input/Output: The "intersections" between the
                           the fillets and the patches generated herein
                           are recorded in this list.If fillet_patch->objid
                           is NULL_OBJID then a composite is created within
                           this function.

    model_inters        - Input/Output: The "intersections" between the
                           the fillets/patches and the model generated herein
                           are recorded in this list.

  ALGORITHM
    Peruse the comments at each STEP.
    Also there is a collection of support functions in ./EMrndblnsupp.I

  HISTORY

    KNAP   : Aug '5, 1994 : Re-write. Added several enhancements which
                            generate smoother 4-sided blends. Also added
                            checks to validate the blend curves/surfaces.
                            Fixed umpteen bugs. A major portion got into
                            EMS 3 and EMS 3.1.

    Janaka : Apr 21, 1993 : Re-write:
                            . The actual creation of the blend was seperated
                              from the creation of input blend curves. This
                              enables others to obtain a blend, provided the
                              blend curves are known.
                            . The blend boundary curve generation now
                              accommodates any n-vertex, and includes fillet
                              refinement where appropriate.
                            . A single blend surface is generated in case of 3
                              or 4 bounding curves.

    Janaka : Oct 13, 1992 : Re-write (on a Friday the 13th!!).
                            . Primarily, the ruled surfaces were replaced by
                              true blend surfaces, with tangential continuity
                              across patch boundaries.

                            Unfortunately all this work never really got into
                            a release (indecision on behalf of certification),
                            which is really demoralising!!.

    Inasu  : ???          : Original.
*/

#argsused

IGRlong EMget_n_sided_blend (EMmsg, options, construct_list, vtx_rnd_info,
                             fillet_patch, fillet_inters, model_inters)

IGRlong 		*EMmsg;
IGRushort		options;
struct GRvg_construct	*construct_list;
struct EMSvtx_rnd_info	*vtx_rnd_info;
struct GRid		*fillet_patch;
struct EMSinters	**fillet_inters, **model_inters;
{
  IGRushort     ed_props;
  IGRboolean    int_found, is_legal, vtx_bln_continuity_exists, 
                com_ed_end_stop, donot_trim, transcv_to_rnd_vtx, 
                tmp_found, consec_edges_rnded, bln_cvs_are_valid, 
                curvatures_are_same, all_edges_are_rounded=FALSE,
                has_neutral_eds=FALSE, use_blend_cv_iso = FALSE,
                bln_cv_extracted_iso = FALSE, homogenous_vtx = FALSE;
  IGRshort	mat_type;
  IGRlong	msg, stat;
  IGRint	num_vtx_eds, i, j, k, m, rnded_ed_inx, not_rnded_ed_inx,
                num_eds_rnded, rnded_ed_int_pt_location, inx,
                not_rnded_ed_int_pt_location, num_bln_cvs, 
                crnt_ed_inx, num_bln_grps, ed_inx[2], max_bnd_cvs,
                num_bnd_cvs_in_grp, num_eds_ret, num_eds_skipped,
                sng_ed_rnded_inx, non_rounded_eds, m_prev_i, m_next_i,
		tmp_count, num_bln_cvs_added = 0;
  IGRdouble	ed_ends[2][3]; /* Changed to IGRdouble */
  IGRpoint      rnd_vtx, pt_xyz, *mid_points = NULL;
  IGRdouble	*def_setback = NULL, *matrix, cht_tol, min_dist, bas_tol, 
                uv_params[2], offset_dist;
  IGRvector	sf_normal;
  GRspacenum	os;
  GRobjid	tmp_ed_ids[2], *bln_sf_ids = NULL, *bln_sf_ed_ids = NULL,
                next_ed, next_ed_com_ed_id, ed_com_ed_id;

  OM_S_CHANSELECT 	to_common_ed;
  OM_S_OBJECT_LINKAGE	chan_objects[1];
  OMuint	 	count;

  enum   EMSedge_config       *edge_configs = NULL, ed_config;
  struct EMSedge_rnd_info     **ed_infos, *tmp_ed_infos[2];
  struct GRmd_env             *md_env;
  struct GRmdenv_info         *mdenv_info;
  struct EMSdataselect        model_uv_dataselect[2], bln_uv_dataselect, 
                              xyz_dataselect;
  struct GRid                 model_GRid, bln_GRid, *bln_uv_GRid = NULL;
  struct EMSsfintedpar	      *model_uv_incident_info[2], *bln_uv_incident_info;
  struct EMSpypoint           split_pt;
  struct EMSinters            *loc_fillet_inters, *loc_model_inters;

  struct EMSedge_blend_info   *ed_bln_info, *tmp_ed_bln_info[2],
                              *two_ed_bln_infos[2];
  struct IGRbsp_curve	      **bln_bnd_cv_geoms_array, **bln_sf_ed_geoms;
  struct IGRbsp_surface	      **bln_tan_sf_geoms_array, *bln_sf_geom;

  struct EMSrnd_blend_curve_info  *bln_cvs_info = NULL, *end_of_list = NULL, 
                                  *tmp_ptr1 = NULL, *grp_start_ptr = NULL,
                                  *tmp_ptr2 = NULL, *bln_bnd_cv_ptr = NULL;

  IGRchar                         *rnd_grp_start_ptr[12];
  struct EMSrnd_blend_group	  *bln_grps = NULL;
  struct EMSrnd_grp_info          *rnd_grp_info = NULL;
  IGRint                          kk, num_rnd_grps=0;

  struct EMSsfintedpar*	      EMsfintedpar_malloc();
  void                        EMget_rnd_included_data(), EMsfintedpar_free(),
                              EMmergeinters(), EMdataselect_data_free(),
                              EMinters_free(), EMinters_data_free();
  struct EMSintobj            *EMmakeintlist();
  extern IGRboolean EMare_edges_curvatures_same();


  *EMmsg = EMS_S_Success;
  stat= OM_S_SUCCESS;
  BSEXTRACTPAR (&msg, BSTOLLENVEC, bas_tol);
  BSEXTRACTPAR (&msg, BSTOLCHRDHT, cht_tol);
  md_env = construct_list->env_info;
  mdenv_info = &md_env->md_env;
  mat_type = mdenv_info->matrix_type;
  matrix = mdenv_info->matrix;
  os = md_env->md_id.osnum;
  
  bln_cvs_info = NULL;
  end_of_list = NULL;
  bln_bnd_cv_ptr = NULL;
 
  bln_sf_ed_geoms = NULL;
  bln_sf_geom = NULL;
  bln_uv_incident_info = NULL;
 
  loc_fillet_inters = NULL;
  loc_model_inters = NULL;

  for ( i=FIRST; i<=SECOND; i++)
    {
    model_uv_incident_info[i] = NULL;
    tmp_ed_bln_info[i] = NULL;
    two_ed_bln_infos[i] = NULL;
    model_uv_dataselect[i].datatype = EMSdata_null;
    tmp_ed_infos[i] = NULL;
    }
 
  max_bnd_cvs = 0;
  num_bln_grps = 0;
  bln_grps = NULL;
  sng_ed_rnded_inx = UNDEFINED;
 
  EMmake_chanselect( EMSedge_to_common_edge, &to_common_ed );

  ed_infos = vtx_rnd_info->edge_infos;
  edge_configs = vtx_rnd_info->edge_configs;
  num_vtx_eds = vtx_rnd_info->num_edges;
  OM_BLOCK_MOVE (vtx_rnd_info->vtx_pt, rnd_vtx, sizeof(IGRpoint));
  def_setback = (IGRdouble *)alloca (num_vtx_eds * sizeof(IGRdouble));
  ed_bln_info = (struct EMSedge_blend_info *)alloca (num_vtx_eds *
                                sizeof( struct EMSedge_blend_info));

  /*
   * Instantiate edge blend inforation with what ever is known.
   */
  for (i=0; i<num_vtx_eds; i++)
    {
    for (j=FIRST; j<=SECOND; j++)
      {
      ed_bln_info[i].setback_pt_stat[j]     = setback_pt_undefined;
      ed_bln_info[i].counter_part[j]        = UNDEFINED;
      ed_bln_info[i].fillet_int_iso[j]      = UNDEFINED;
      ed_bln_info[i].setback_pts_refined[j] = FALSE;
      ed_bln_info[i].bln_cv_props[j]        = EMSrnd_bln_trans_cv_unknown;
      }
    ed_bln_info[i].blend_cv_type = blend_curve_undefined;
    ed_bln_info[i].default_setback = UNDEFINED;

    /* 
     * For each logical edge determine the FIRST and SECOND edges in the cyclic
     * order defined by vertex edges.
     */
    stat = EMgetnxtedges (&msg, EMSvtxedges_nodegenerate,
             vtx_rnd_info->edge_ids[i], os, vtx_rnd_info->edge_stops[i],
             1, &num_eds_ret, &next_ed, &ed_props, &num_eds_skipped);
    EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    count = 0;
    stat = om$get_channel_objects (objid = vtx_rnd_info->edge_ids[i],
              p_chanselect = &to_common_ed, osnum = os, count = &count,
              size = 1, list = chan_objects );
    EMerr_hndlr (!(1 & stat) || count != 1, *EMmsg, EMS_E_Fail, wrapup);
    ed_com_ed_id = chan_objects[FIRST].S_objid;

    count = 0;
    stat = om$get_channel_objects (
              objid = vtx_rnd_info->edge_ids[ (i+1)%num_vtx_eds ],
              p_chanselect = &to_common_ed, osnum = os,
              count = &count, size = 1, list = chan_objects);
    EMerr_hndlr (!(1 & stat) || count != 1, *EMmsg, EMS_E_Fail, wrapup);
    next_ed_com_ed_id = chan_objects[FIRST].S_objid;

    /*
     * Get the edge's end points, its common edge's end points, and the
     * latter's edge end configuration w.r.t the round vertex.
     */
    stat = om$send (msg = message EMSedge.EMxyz_endpt (&msg, NULL,
              mdenv_info, NULL, NULL, vtx_rnd_info->edge_stops[i] == TRUE ?
              NULL : ed_ends[FIRST], vtx_rnd_info->edge_stops[i] == TRUE ?
              ed_ends[FIRST] : NULL, ed_infos[i] ? &ed_infos[i]->surf : NULL),
              senderid = NULL_OBJID, targetid = vtx_rnd_info->edge_ids[i],
              targetos = os);
    EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);

    stat = om$send (msg = message EMSedge.EMget_props (&msg, &ed_props),
              senderid = NULL_OBJID, targetos = os, targetid = ed_com_ed_id);
    EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    com_ed_end_stop = ((vtx_rnd_info->edge_stops[i] == TRUE ? 1 : 0) ^
                       (ed_props & EMED_REVERSE_CONNECT ? 1 : 0)) ? TRUE :
                       FALSE;

    stat = om$send (msg = message EMSedge.EMxyz_endpt (&msg, NULL, mdenv_info,
              NULL, NULL, com_ed_end_stop == TRUE ? NULL : ed_ends[SECOND],
              com_ed_end_stop == TRUE ? ed_ends[SECOND] : NULL,
              ed_infos[i] ? &ed_infos[i]->com_surf : NULL ),
              senderid = NULL_OBJID, targetid = ed_com_ed_id, targetos = os);

    if (IF_EQ_OBJID (next_ed, vtx_rnd_info->edge_ids [(i+1)%num_vtx_eds]) ==
                     TRUE ||
        IF_EQ_OBJID (next_ed, next_ed_com_ed_id) == TRUE)
      {
      ed_bln_info[i].FIRST_is_dominant    = TRUE;
      ed_bln_info[i].ed_ids[FIRST]        = vtx_rnd_info->edge_ids[i];
      ed_bln_info[i].ed_ids[SECOND]       = ed_com_ed_id;
      ed_bln_info[i].rnd_end_stop[FIRST]  = vtx_rnd_info->edge_stops[i];
      ed_bln_info[i].rnd_end_stop[SECOND] = com_ed_end_stop;
      OM_BLOCK_MOVE (ed_ends[FIRST], ed_bln_info[i].rnd_end_vtx[FIRST],
                     3*sizeof( IGRdouble));
      OM_BLOCK_MOVE (ed_ends[SECOND], ed_bln_info[i].rnd_end_vtx[SECOND],
                     3*sizeof( IGRdouble));
      if (ed_infos[i])
      if (ed_infos[i])
        {
        ed_bln_info[i].fillet_int_iso[FIRST]  = FILLET_U0;
        ed_bln_info[i].fillet_int_iso[SECOND] = FILLET_U1;
        }
      }
    else
      {
      ed_bln_info[i].FIRST_is_dominant    = FALSE;
      ed_bln_info[i].ed_ids[FIRST]        = ed_com_ed_id;
      ed_bln_info[i].ed_ids[SECOND]       = vtx_rnd_info->edge_ids[i];
      ed_bln_info[i].rnd_end_stop[SECOND] = vtx_rnd_info->edge_stops[i];
      ed_bln_info[i].rnd_end_stop[FIRST]  = com_ed_end_stop;
      OM_BLOCK_MOVE (ed_ends[FIRST], ed_bln_info[i].rnd_end_vtx[SECOND],
                     3*sizeof(IGRdouble));
      OM_BLOCK_MOVE (ed_ends[SECOND], ed_bln_info[i].rnd_end_vtx[FIRST],
                     3*sizeof(IGRdouble));
      if (ed_infos[i])
        {
        ed_bln_info[i].fillet_int_iso[FIRST]  = FILLET_U1;
        ed_bln_info[i].fillet_int_iso[SECOND] = FILLET_U0;
        }
      }
    }

  /* 
   * STEP 1
   *
   * Determine:
   *  . Number of edges rounded at this vertex.
   *  . The default set back distance for each edge at the round vertex.
   *    This is used only when an attempt to generate the set back points
   *    by other means have failed.
   *  . If a blend curve is generated inside a hole, or the blend curve is
   *    expanding an outer boundary of a surface, then such blend curves
   *    should not be trimmed against the surface (EMlsparttrim() yeilds
   *    incorrect results!!!). Detect such vertex conditions.
   *
   * Detect also the following situations when consecutive edges are
   * rounded. In all these cases, the  transition curves go to vertex.
   * If atleast one edge is not rounded, and consecutive edges exist,
   * Then find all such groups ( if multiple ), having consecutive 
   * edges (rounded), and store their bounding non-rounded edges.
   * If these bounding edges are homogenous, then we can simply route,
   * the transition curves to round vertex.
   *  -------- KNAP (Blend Enhancement)
   */

  num_eds_rnded=0;
  for (i=0; i<num_vtx_eds; i++)
    {
    /*
     * If the ith edge has a fillet, derive the setback from the
     * fillet radius. If variable radius rounding, then ensure that the 
     * correct radius was obtained.
     */
    if (ed_infos[i])
      {
      num_eds_rnded++;
      sng_ed_rnded_inx = i; 
      ed_bln_info[i].default_setback = ed_infos[i]->radius;
      if (ed_infos[i]->props & EMSfillet_is_variable_radius &&
                               vtx_rnd_info->edge_stops[i] == TRUE)
        ed_bln_info[i].default_setback = ed_infos[i]->other_radius;
        ed_bln_info[i].default_setback *= SETBACK_FRACTION_3;
      }
    /*
     * If the ith edge does not have a fillet, or the fillet radius (in
     * case of variable radius) is zero at this end, use the edge length
     * measure as the default setback distance.
     */
    if (ed_bln_info[i].default_setback < REAL_VALUE_ACCURACY)
      {
      stat = om$send (msg = message EMSedge.EMget_edge_length (&msg, 
                (IGRushort) 0, mdenv_info, NULL, NULL, NULL,
                &ed_bln_info[i].default_setback ), senderid = NULL_OBJID,
                targetid = vtx_rnd_info->edge_ids[i], targetos = os);
      EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_EdgeError, wrapup);
      ed_bln_info[i].default_setback *= SETBACK_FRACTION_1;
      }
    }

  donot_trim = FALSE;
  if (vtx_rnd_info->num_edges == 3 && num_eds_rnded == 1)
    {
    if ((vtx_rnd_info->edge_configs[sng_ed_rnded_inx] == EMSedge_concave
         && vtx_rnd_info->edge_configs [(sng_ed_rnded_inx+1)%num_vtx_eds] == 
         EMSedge_convex && vtx_rnd_info->edge_configs
         [sng_ed_rnded_inx ? sng_ed_rnded_inx-1 : num_vtx_eds-1] == 
         EMSedge_convex) ||
        (vtx_rnd_info->edge_configs[sng_ed_rnded_inx] == EMSedge_convex
         && vtx_rnd_info->edge_configs [(sng_ed_rnded_inx+1)%num_vtx_eds] ==
         EMSedge_concave && vtx_rnd_info->edge_configs
         [sng_ed_rnded_inx ? sng_ed_rnded_inx-1 : num_vtx_eds-1] == 
         EMSedge_concave))

       donot_trim = TRUE;
    }
    if ((vtx_rnd_info->vtx_config == EMSvertex_general_trim) &&
        (num_eds_rnded == 1) && num_vtx_eds == 3)
      bln_cv_extracted_iso = TRUE;
     
  /*
   * Code to detect the cases for Blend enhancement.
   * This enhancement is when te nuber of vertex edges are greater than 3.
   * --- KNAP
   */

  k = 0;
  kk = 0;
  non_rounded_eds =0;
  num_eds_rnded =0;
  consec_edges_rnded = FALSE;
  transcv_to_rnd_vtx = FALSE;
  curvatures_are_same = FALSE;

  /*
   * Extract some of the useful information about vertex under consideration.
   */
  for (i=0; i<num_vtx_eds; i++)
    {
    j = (i+1)%num_vtx_eds;
    if (ed_infos[i])
      num_eds_rnded ++;
    if (ed_infos[i] && ed_infos[j])
      consec_edges_rnded = TRUE;
    if (!ed_infos[i])
      non_rounded_eds ++;
    if ((edge_configs[i]==EMSedge_neutral) ||
        (edge_configs[i]==EMSedge_neutral_convex) ||
        (edge_configs[i]==EMSedge_neutral_concave))
      has_neutral_eds = TRUE;
    }
  if (num_eds_rnded == num_vtx_eds)
    all_edges_are_rounded = TRUE;

  rnd_grp_info = (struct EMSrnd_grp_info *)alloca (num_vtx_eds * 
		                   sizeof (struct EMSrnd_grp_info));

  if ((num_vtx_eds > 3) && non_rounded_eds && consec_edges_rnded)
    {
    for (i=0; i<num_vtx_eds; i++)
      {
      if (ed_infos[i])
        {
        tmp_found = FALSE;
        for (m = i+1; m<num_vtx_eds; m++)
          {
          if (ed_infos[m])
            continue;
          tmp_found = TRUE;
          rnd_grp_info[k].end_bnd_inx = m;
          break;
          }
        if (!tmp_found)
          {
          if (ed_infos[0])
            break;
          else
            {
            tmp_found = TRUE;
            rnd_grp_info[k].end_bnd_inx = 0;
            }
          }
        if (!tmp_found)
          break;
        kk = i;
        i = m;
        while (TRUE)
          {
          if (ed_infos[kk])
            {
            if ((kk%num_vtx_eds) == 0)
              kk = num_vtx_eds - 1;
            else
              kk--;
            }
          else
            {
            rnd_grp_info[k].start_bnd_inx = kk;
            break;
            }
          }
        k++;
        }
      }
    tmp_found = TRUE;
    for (i=0; i<k ; i++)
      {
      if (edge_configs[rnd_grp_info[i].start_bnd_inx] ==
                       edge_configs[rnd_grp_info[i].end_bnd_inx])
        continue;
      else
        {
        if ((edge_configs[rnd_grp_info[i].start_bnd_inx] == 
		   EMSedge_neutral) || 
            (edge_configs[rnd_grp_info[i].start_bnd_inx] == 
	           EMSedge_neutral_concave)|| 
	    (edge_configs[rnd_grp_info[i].start_bnd_inx] ==
	           EMSedge_neutral_convex))
          {
	  if ((edge_configs[rnd_grp_info[i].end_bnd_inx] == 
	           EMSedge_neutral) ||
              (edge_configs[rnd_grp_info[i].end_bnd_inx] == 
		   EMSedge_neutral_concave)|| 
	      (edge_configs[rnd_grp_info[i].end_bnd_inx] ==
	           EMSedge_neutral_convex))
            continue;
	  }
	else
	  {
          tmp_found = FALSE;
          break;
	  }
        }
      }
    num_rnd_grps = k;
    if (tmp_found)
      transcv_to_rnd_vtx = TRUE;
    }

  /*
   * When the start bound and end bound edges are same (single)
   * We consider this single group as two separate groups, the
   * formation of these two groups is facilitated by those edges
   * which make an included angle of 180. i.e the edges are
   * collinear at the vertex. Else we set the transcv_to_rnd_vtx to
   * false. The above situations arise when the number of edges
   * to be rounded are one less than the number of vertex edges.
   *   ------------ KNAP ( Blend Enhancement )
   */
  if (transcv_to_rnd_vtx && (num_eds_rnded == (num_vtx_eds - 1)) 
      && (num_rnd_grps == 1))
    {
    for ( m = 0; m < num_vtx_eds; m++ )
      {
      get_prev_and_next_index ( num_vtx_eds, m, &m_prev_i, &m_next_i );
      if ( ed_infos[m] && ed_infos[m_next_i])
        {
        curvatures_are_same = EMare_edges_curvatures_same (&msg, md_env,
                                rnd_vtx, ed_infos[m]->edge_id,
                                ed_infos[m_next_i]->edge_id);
        EMerr_hndlr( EMSerror( msg ), *EMmsg, EMS_E_Fail, wrapup );
        if (curvatures_are_same)
          {
          ed_bln_info[m].bln_cv_props[FIRST] = EMSrnd_bln_trans_cv_to_rnd_vtx;
          ed_bln_info[m_next_i].bln_cv_props[SECOND] =
                                EMSrnd_bln_trans_cv_to_rnd_vtx;
          num_rnd_grps ++;
          break;
          }
        }
      }
      if (!curvatures_are_same)
        transcv_to_rnd_vtx = FALSE;
    }
  /*
   * If the number of vertex edges are 3, and consecutive edges
   * are rounded, and the non-rounded edge is neutral, then also we need to 
   * route the transition curves to round vertex.
   */
  if ((num_vtx_eds == 3) && consec_edges_rnded && has_neutral_eds)
    {
    for (i=0;i<num_vtx_eds; i++)
      {
      j=(i+1)%num_vtx_eds;
      if (ed_infos[i] && ed_infos[j])
      break;
      }
    if (edge_configs[i]!=edge_configs[j])
      {
      transcv_to_rnd_vtx = TRUE;
      use_blend_cv_iso = TRUE;
      }
    num_rnd_grps = 1;
    }

  if (all_edges_are_rounded && num_vtx_eds > 3)
    {
    homogenous_vtx = TRUE;
    ed_config = edge_configs[FIRST];
    for (i=1; i<num_vtx_eds; i++)
      if (ed_config != edge_configs[i])
        {
        homogenous_vtx = FALSE;
        break;
        }
    }

  if ((vtx_rnd_info->vtx_config == EMSvertex_3edge_rolling_ball)
      && !has_neutral_eds)
    options = EMSrnd_bln_cv_donot_trim;
  else
    options = NULL;

  /* 
   * STEP 2
   *
   * Construct the set back points along each edge. If the edge has a
   * fillet, then the points will be on the two fillet isos, u0 and u1. Else
   * they will be on the edge and its common edge. In any case, these
   * correspond to the CYCLIC order defined by the edges at the round vertex.
   */
  for (k = 0, i = num_vtx_eds - 1; k < num_vtx_eds; k++, i = j)
    {
    /*
     * If the ith edge, and the jth edge are both not rounded, then
     * possibly the previous neighbor of the ith edge generated a set
     * back point. In any case, check and adjust the setback point
     * (generating one at default set back, if required) on the ith edge.
     * This check is undefined for the first.
     *
     * If the flag transcv_to_rnd_vtx is TRUE, then set the default
     * set-back on edge to zero as we will not be generating any transition
     * to the edge.
     * ------ KNAP (Blend Enhanement).
     */

    j = (i+1)%num_vtx_eds;
    if (!ed_infos[i] && !ed_infos[j] && k)
      {
      if (transcv_to_rnd_vtx)
        {
        ed_bln_info[i].default_setback = 0.0;
        ed_bln_info[j].default_setback = 0.0;
        }
      stat = EMfix_setback_on_edge (&msg, md_env, &ed_bln_info[i]);
      EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);

      /*
       * When doing next to last edge, do the last also.
       */
      if (j == num_vtx_eds - 1)
        {
        stat = EMfix_setback_on_edge (&msg, md_env, &ed_bln_info[j]);
        EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);
        }
      continue;
      }

    /*
     * Either both, ith edge and the (i+1)th edge, are rounded, or only one
     * of them is rounded. In either case, attempt to generate the
     * intersection information.
     */
    if (ed_infos[i] && ed_infos[j])
      {
      two_ed_bln_infos[FIRST] = &ed_bln_info[i];
      two_ed_bln_infos[SECOND] = &ed_bln_info[j];
      stat = EMget_ed1_ed2_int_info (&msg, (IGRushort) 0, md_env,
               ed_infos[i], ed_infos[j], &int_found, two_ed_bln_infos);
      /*
       * In case of failure to obtain an intersection, continue processing
       * (there is the possibility of the other side generating a set back
       * point, or there is the default set back).
       */

      if (int_found == TRUE)
        {
        /*
         * Validate the intersection point on both fillets.  If the
         * intersection is legal, then record its values for the ith and
         * the jth edges.
         */
        for (m = i, inx = 0, rnded_ed_int_pt_location = FIRST; inx < 2;
                m = j, inx++, rnded_ed_int_pt_location = SECOND)
          {
          stat = EMvalidate_int (&msg, (IGRushort) 0, ed_infos[m],
                   rnd_vtx, vtx_rnd_info->edge_stops[m],
                   ed_bln_info[m].setback_pts_uv [rnded_ed_int_pt_location][V],
                   &is_legal);
          /*
           * Here again, continue processing on failure (i.e. set back
           * point not being found here is not fatal, since there are
           * other means (admittably adhoc) of obtaining one).
           */
          if (is_legal == FALSE)
            break;
          }
        if (is_legal == TRUE)
          {
          ed_bln_info[i].setback_pt_stat[FIRST] = 
          ed_bln_info[j].setback_pt_stat[SECOND] = setback_pt_defined;
          ed_bln_info[i].counter_part[FIRST] = j;
          ed_bln_info[j].counter_part[SECOND] = i;
          if (curvatures_are_same)
            {
            if (ed_bln_info[i].bln_cv_props[FIRST] &
                               EMSrnd_bln_trans_cv_to_rnd_vtx)
              ed_bln_info[i].counter_part[FIRST] = UNDEFINED;
            if (ed_bln_info[j].bln_cv_props[SECOND] &
                               EMSrnd_bln_trans_cv_to_rnd_vtx)
              ed_bln_info[j].counter_part[SECOND] = UNDEFINED;
            }
          }
        }
      }
    else
      {
      /*
       * fillet_edge intersection.
       */
      rnded_ed_inx = ed_infos[i] ? i : j;
      not_rnded_ed_inx = ed_infos[i] ? j : i;
      rnded_ed_int_pt_location = rnded_ed_inx == i ? FIRST : SECOND;
      not_rnded_ed_int_pt_location = rnded_ed_inx == i ? SECOND : FIRST;

      two_ed_bln_infos[FIRST] = &ed_bln_info[i];
      two_ed_bln_infos[SECOND] = &ed_bln_info[j];        
      stat = EMget_ed1_ed2_int_info (&msg, (IGRushort)0, md_env,
               ed_infos[i], ed_infos[j], &int_found, two_ed_bln_infos);
      /*
       * In case of failure to obtain an intersection, continue processing
       * (there is the possibility of the other side generating a set back
       * point, or there is the default set back). Also, the set back point
       * on the edge is recorded as valid, since it can be a candidate for
       * 'where to set back from' on the edge.
       */

      if (1 & stat & msg)
        ed_bln_info[not_rnded_ed_inx].setback_pt_stat
                   [not_rnded_ed_int_pt_location] = setback_pt_defined;

      if (int_found == TRUE)
        {
        stat = EMvalidate_int (&msg, (IGRushort)0,
                 ed_infos[ rnded_ed_inx ], rnd_vtx,
                 vtx_rnd_info->edge_stops[ rnded_ed_inx ],
                 ed_bln_info[rnded_ed_inx].setback_pts_uv
                 [rnded_ed_int_pt_location][V], &is_legal);
        /*
         * Here again, continue processing on failure (i.e. set back point
         * not being found here is not fatal, since there are other means
         * of obtaining one).
         */

        if (use_blend_cv_iso && transcv_to_rnd_vtx)
          is_legal = FALSE;
        if (is_legal || bln_cv_extracted_iso)
          {
          stat = EMadjust_setback_pt_along_fillet_iso (&msg,
                   vtx_rnd_info->edge_stops[rnded_ed_inx],
                   ed_infos[rnded_ed_inx],
                   ed_bln_info[rnded_ed_inx].default_setback,
                   ed_bln_info[rnded_ed_inx].setback_pts_uv
                   [rnded_ed_int_pt_location],
                   ed_bln_info[rnded_ed_inx].setback_pts_xyz
                   [rnded_ed_int_pt_location]);
          if (1 & stat & msg)
            ed_bln_info[ rnded_ed_inx ].setback_pt_stat
                    [ rnded_ed_int_pt_location ] = setback_pt_defined;
          if ( bln_cv_extracted_iso )
            {
            ed_bln_info [rnded_ed_inx].bln_cv_props
                 [rnded_ed_int_pt_location] =
                          EMSrnd_bln_trans_cv_extracted_iso_curve;
            ed_bln_info[not_rnded_ed_inx].bln_cv_props
                 [not_rnded_ed_int_pt_location] =
                          EMSrnd_bln_trans_cv_extracted_iso_curve;
            }
          }
        }
      else if (bln_cv_extracted_iso)
        {
        ed_bln_info[not_rnded_ed_inx].default_setback =
                        ed_infos[rnded_ed_inx]->radius;
        if (ed_infos[rnded_ed_inx]->props & EMSfillet_is_variable_radius)
          {
          if (vtx_rnd_info->edge_stops[rnded_ed_inx])
            ed_bln_info[not_rnded_ed_inx].default_setback =
                       ed_infos[rnded_ed_inx]->other_radius;
          }
        ed_bln_info[not_rnded_ed_inx].default_setback *= SETBACK_FRACTION_4;
        }
      }

    /*
     * Finalize the set back points on the ith edge (all processing
     * to obtain special set back points completed on this edge).
     * Take a rain check on the jth edge (it will be delivered in
     * the next iteration. Unlike K-Mart, this is guaranteed!).  The
     * set back points status on the ith edge would be one of the following.
     *     . No set back points.
     *     . One set back point.
     *     . Two set back points.
     *
     * The transition curve from fillet iso to its round vertex
     * is decided as follows (ONLY WHEN transcv_to_rnd_vtx is TRUE ).
     * If the m'th edge under consideration's, next edge (m_next_i )
     * is also rounded, then mark the bln_cv_props for the FIRST
     * iso of the m'th edge as EMSrnd_bln_trans_cv_undefined. Else
     * mark the transition as EMSrnd_bln_trans_cv_to_rnd_vtx. 
     * Similarly if the m'th previous edge is also rounded, then
     * mark the SECOND iso's bln_cv_props as EMSrnd_bln_trans_cv_undefined.
     * Else mark the transition to EMSrnd_bln_trans_cv_to_rnd_vtx.
     *  --------   KNAP ( Blend Enhancement )
     */
       
    if (k)
      {
      /* ignore the very first iteration, since i=0 th edge
       * will not have had the opportunity to create two set
       * back points.  Setback points for that edge is fixed
       * after the final iteration.
       */
      for (m = i, inx = 0; inx < 2; m = j, inx++)
        {
        if (ed_infos[m])
          {
          if (transcv_to_rnd_vtx)
            {
	    get_prev_and_next_index (num_vtx_eds, m, &m_prev_i, &m_next_i);
            if (ed_infos[m_prev_i])
	      {
	      if (!(ed_bln_info[m].bln_cv_props[SECOND] &
		                   EMSrnd_bln_trans_cv_to_rnd_vtx))
		ed_bln_info[m].bln_cv_props[SECOND] =
		               EMSrnd_bln_trans_cv_undefined;
	      }
	    else
	      ed_bln_info[m].bln_cv_props[SECOND] =
	                     EMSrnd_bln_trans_cv_to_rnd_vtx;

            if (ed_infos[m_next_i])
	      {
	      if (!(ed_bln_info[m].bln_cv_props[FIRST] &
	                           EMSrnd_bln_trans_cv_to_rnd_vtx))
		ed_bln_info[m].bln_cv_props[FIRST] =
		               EMSrnd_bln_trans_cv_undefined;
	      }
	    else
	      ed_bln_info[m].bln_cv_props[FIRST] =
		             EMSrnd_bln_trans_cv_to_rnd_vtx;
            }
          stat = EMfix_setback_on_fillet (&msg, md_env, ed_infos,
                   ed_bln_info, vtx_rnd_info, m, 
	           ed_bln_info[m].default_setback);
          EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
        else
          { 
	  /*
	   * If transcv_to_rnd_vtx is TRUE, then set the default set back
	   * to zero and the props for FIRST and SECOND iso curves as
	   * EMSrnd_bln_trans_cv_undefined.
	   */
	  if (transcv_to_rnd_vtx)
	    {
	    ed_bln_info[m].default_setback = 0.0;
	    ed_bln_info[m].bln_cv_props[FIRST] =
	                   EMSrnd_bln_trans_cv_undefined;
	    ed_bln_info[m].bln_cv_props[SECOND] =
	                   EMSrnd_bln_trans_cv_undefined;
            }
          stat = EMfix_setback_on_edge (&msg, md_env, &ed_bln_info[m]);
          EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);
          }

        /*
         * During the fixing of set back points of the next to last edge
         * also do the last edge (this edge could not have been done
         * until the construction of both set back points was attempted).
         */
        if (i != num_vtx_eds - 2) break;
        }
      }
    }
    
  /* 
   * STEP 3
   *
   * Construct the blend bounding curves. There are two kinds of bounding 
   * curves. One set flowing on the fillets and another on the model surfaces.
   * . On a fillet
   *   . Obtain an infinite plane, such that it passes through each of the
   *     set back points on the fillet, and its FIRST set back point normal
   *     is on plane.
   *   . Intersect this plane with the fillet. This will yeild the ith xyz
   *     blend curve, and the corresponding intersection (uv curve) on the
   *     fillet.
   *   . If the xyz curve is a line string, then fit a bsp curve through it.
   *     This is necessary, since the blend function accepts only bsp
   *     curves. The resulting bsp curve will be within cht tolerance
   *     to the fillet.  The curve fitting function requires that the
   *     parameterization of the xyz and the uv curves be consistant.
   *   . Ensure that both curves flow from SECOND setback point to the FIRST
   *     setback point.
   *   . Record the ith fillet surface as the surface to which the ith blend
   *     surface should be tangent along the ith xyz blend curve.
   *
   * . On the model surfaces
   *   These blend curves exist on model surfaces (sf) that are bounded by:
   *   . two edges
   *   . an edge, and an iso of a fillet
   *   . two isos of two fillets.
   *   Let the two bounding geometries be cv1 (FIRST) and cv2 (SECOND).
   *   Then, the blend between cv1 and cv2 is obtained as a curve on 'sf'
   *   such that it is tangent to cv1 and cv2, where the tangency is towards
   *   the round vertex, at the set back points on cv1, and cv2.
   *   Ensure that the parameterization of the xyz and the uv curves are
   *   consistant with the cyclic order defined by the edges at the vertex.
   *
   * During each iteration, first, if required (this edge might not be
   * rounded), generate the blend curve on the fillet. Then, if required
   * (if a set back point has a counter part, then blend transition from the
   * ith edge to the (i+1)th edge does not require a blend curve on the model),
   * generate the blend curve on the model surface.
   */
  num_bln_cvs = 0;
  vtx_bln_continuity_exists = TRUE;
  for (i = 0; i<num_vtx_eds; i++)
    {
    inx = (i+1)%num_vtx_eds;
    if (ed_infos[i])
      {
      /* 
       * ith edge is rounded, thus it is possible to generate a bound
       * blend curve on it.
       */
      EMgenerate_blend_bound_curve_on_fillet (&msg, md_env, vtx_rnd_info,
        &ed_bln_info[i], ed_infos[i], i, &bln_bnd_cv_ptr);
      EMerr_hndlr (EMSerror (msg), *EMmsg, EMS_E_Fail, wrapup);

      bln_bnd_cv_ptr->prev = end_of_list;
      if (end_of_list)
        end_of_list->next = bln_bnd_cv_ptr;
      else
        bln_cvs_info = bln_bnd_cv_ptr;

      end_of_list = bln_bnd_cv_ptr;
      bln_bnd_cv_ptr = NULL;

      ++num_bln_cvs;

      /* 
       * If a blend transition is to be made from this fillet, to the
       * cyclic next (either edge or fillet), then create the blend curve
       * on the model surface.
       */
      if (ed_bln_info[i].counter_part[FIRST] == UNDEFINED)
        {
        /* 
         * There are at most two transition blend curves (from the ith
         * edge to the next).  It may be one.  Note that the blend curve
         * list cannot be empty, since the ith edge does have a fillet,
         * and a blend curve on it was just created.
         *
	 * We need not enter this portion of code for 
	 * transcv_to_rnd_vtx=TRUE , because for for such cases, the
	 * control is slightly different from that of original blend 
	 * flow. This is made so that the blend enhancement and the
	 * original blend code can co-exist.
	 */

        if ((ed_bln_info[i].bln_cv_props[FIRST] &
                            EMSrnd_bln_trans_cv_to_rnd_vtx) &&
             !transcv_to_rnd_vtx)
          {
          bln_bnd_cv_ptr = NULL;
          stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                   ed_infos[i], &ed_bln_info[i], TRUE, FALSE, &bln_bnd_cv_ptr);
          EMerr_hndlr (!(1 & stat & msg) || !bln_bnd_cv_ptr, *EMmsg, EMS_E_Fail,
                       wrapup );
          bln_bnd_cv_ptr->prev = end_of_list;
          end_of_list->next = bln_bnd_cv_ptr;
          end_of_list = bln_bnd_cv_ptr;
          num_bln_cvs++;
 
          /* 
           * Moving forward and reaching this condition indicates a
           * termination to the blend curve creation.
           */
          vtx_bln_continuity_exists = FALSE;
          break;
          }
        else
          {
          for (j=FIRST, k=i; j<=SECOND; j++, k=inx)
            {
            tmp_ed_infos[j] = ed_infos[k];
            tmp_ed_ids[j] = ed_bln_info[k].ed_ids[j];
            tmp_ed_bln_info[j] = &ed_bln_info[k];
            ed_inx[j] = k;
            }

          /*
           * By this time we have already established type of transition
	   * to be made to the iso curve ( IN STEP 2 ), for cases belonging
	   * to transcv_to_rnd_vtx = TRUE.
	   * Also, we will be routing only the FISRT iso transition curve
	   * to round vertex. If the next edge is also rounded check if its
	   * SECOND iso's props for EMSrnd_bln_trans_cv_to_rnd_vtx. If so
	   * generate that transition also. --- KNAP
	   */
  
	  if (transcv_to_rnd_vtx)
            {
            if (ed_bln_info[i].bln_cv_props[FIRST] &
                               EMSrnd_bln_trans_cv_to_rnd_vtx)
              {
              bln_bnd_cv_ptr = NULL;
              stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                       ed_infos[i], &ed_bln_info[i], TRUE, FALSE,
                       &bln_bnd_cv_ptr);
              EMerr_hndlr (!(1 & stat & msg) || !bln_bnd_cv_ptr, *EMmsg, 
                           EMS_E_Fail, wrapup);
              bln_bnd_cv_ptr->prev = end_of_list;
              end_of_list->next = bln_bnd_cv_ptr;
              end_of_list = bln_bnd_cv_ptr;
              num_bln_cvs++;

	      if (ed_infos[inx])
                {
                if (ed_bln_info[inx].bln_cv_props[SECOND] &
                                     EMSrnd_bln_trans_cv_to_rnd_vtx)
                  {
                  bln_bnd_cv_ptr = NULL;
                  stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                           ed_infos[inx], &ed_bln_info[inx], FALSE, TRUE,
                           &bln_bnd_cv_ptr);
                  EMerr_hndlr (!(1& stat & msg) || !bln_bnd_cv_ptr, *EMmsg, 
                               EMS_E_Fail, wrapup);
                  bln_bnd_cv_ptr->prev = end_of_list;
                  end_of_list->next = bln_bnd_cv_ptr;
                  end_of_list = bln_bnd_cv_ptr;
                  num_bln_cvs++;
                  }
		}
              }
            }
          else
            {
            bln_bnd_cv_ptr = NULL;
            stat = EMget_bln_cv_from_fillet_or_edge (&msg, options,
                     md_env, tmp_ed_infos, tmp_ed_ids, tmp_ed_bln_info,
                     &bln_bnd_cv_ptr);
            if ((1 & stat & msg))
              {
              bln_bnd_cv_ptr->prev = end_of_list;
              end_of_list->next = bln_bnd_cv_ptr;
              end_of_list = bln_bnd_cv_ptr;
              num_bln_cvs++;
              }
            else
              {
              /*
               * An error indicates an illdefined transition blend curve from
               * the ith fillet's FIRST iso to its neighbor. Force that iso to
               * the round vertex.  If the neighbor had a fillet, force its
               * SECOND iso to the round vertex, else record the fact that the
               * neighbor has an undefined SECOND transition.
               */
              bln_bnd_cv_ptr = NULL;
              vtx_bln_continuity_exists = FALSE;
              stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                       ed_infos[i], &ed_bln_info[i], TRUE, FALSE, 
                       &bln_bnd_cv_ptr);
              EMerr_hndlr (!(1 & stat & msg) || !bln_bnd_cv_ptr, *EMmsg, 
                           EMS_E_Fail, wrapup);
              bln_bnd_cv_ptr->prev = end_of_list;
              end_of_list->next = bln_bnd_cv_ptr;
              end_of_list = bln_bnd_cv_ptr;

              ++num_bln_cvs;
              if (ed_infos[inx])
                {
                bln_bnd_cv_ptr = NULL;
                stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                         ed_infos[inx], &ed_bln_info[inx], FALSE, TRUE,
                         &bln_bnd_cv_ptr);
                EMerr_hndlr (!(1 & stat & msg) || !bln_bnd_cv_ptr, *EMmsg, 
                             EMS_E_Fail, wrapup);
                bln_bnd_cv_ptr->prev = end_of_list;
                end_of_list->next = bln_bnd_cv_ptr;
                end_of_list = bln_bnd_cv_ptr;
                ++num_bln_cvs;
                }
              else
                {
                /* Other edge has no fillet.  So just record the fact that
                 * it has no SECOND transition.
                 */
                 ed_bln_info[inx].bln_cv_props[SECOND] =
                                  EMSrnd_bln_trans_cv_undefined;
                }
              }
            }
          }
        }
      }
    else
      {
      /*
       * The ith edge does not have a fillet.
       *
       * Now, following are the possibilities.
       *
       * . If there was no transition blend curve from the i-1 th edge (or
       *   its fillet) to the ith edge, then there is no point in making
       *   one from the ith edge to its next.  In such cases, if the next is
       *   not rounded, then merely record that next does not have a previous
       *   transition.  If next has a fillet, then force that fillet's SECOND
       *   iso to the vertex.
       *
       * . A previous transition for the ith edge exists.  Attempt to make
       *   the next transition from this edge, to its next edge (or the next
       *   fillet's SECOND iso). If that succeeds, then o.k.  Else, it is
       *   necessary to move back (in the direction opposite to the cyclic
       *   ordering of vertex edges), performing the following.
       *   . Delete the ith edge's previous transition curve.  Repeat for
       *     each i-1 th edge until an edge with a fillet is encountered.
       *     If that fillet already had a transition from its FIRST iso,
       *     then create a new transition from its FIRST iso to the round
       *     vertex.  If the FIRST transition did not exist (i.e. the
       *     forward cycle has not reached that edge yet), then merely mark
       *     the FIRST transition on that fillet to be
       *     EMSrnd_bln_trans_cv_to_rnd_vtx.  The subsequent forward cycle
       *     will create the appropriate transition curve (avoiding its
       *     creation here maintains the order in the blend curve list).
       */
   
      if (transcv_to_rnd_vtx)
        goto Next;

      if ((ed_bln_info[i].bln_cv_props[SECOND] & EMSrnd_bln_trans_cv_exists)
           && !transcv_to_rnd_vtx)
        {
        /* 
         * Previous transition is defined.  First, attempt to construct the
         * next transition.
         */
        for (j=FIRST, k=i; j<=SECOND; j++, k=inx)
          {
          tmp_ed_infos[j] = ed_infos[k];
          tmp_ed_ids[j] = ed_bln_info[k].ed_ids[j];
          tmp_ed_bln_info[j] = &ed_bln_info[k];
          ed_inx[j] = k;
          }
        bln_bnd_cv_ptr = NULL;
        stat = EMget_bln_cv_from_fillet_or_edge (&msg,
                 i == (sng_ed_rnded_inx + 1)%num_vtx_eds ? 
                 (donot_trim == TRUE ? EMSrnd_bln_cv_donot_trim : (IGRushort)0)
                 : (IGRushort) 0, md_env, tmp_ed_infos, tmp_ed_ids,
                 tmp_ed_bln_info, &bln_bnd_cv_ptr);
        if ((1 & stat & msg))
          {
          bln_bnd_cv_ptr->prev = end_of_list;
          if (end_of_list)
            end_of_list->next = bln_bnd_cv_ptr;
          else
            bln_cvs_info = bln_bnd_cv_ptr;
    
          end_of_list = bln_bnd_cv_ptr;
          bln_bnd_cv_ptr = NULL;
          }
        else
          {
          /*
           * Attempt to obtained the next transition failed.  Undo all
           * previous transitions upto an edge with a fillet.  if that
           * fillet's FIRST iso transition exists, then create a new
           * one to make it go to the round vertex.  Else, merely mark
           * the FIRST iso transition to be EMSrnd_bln_trans_cv_to_rnd_vtx.
           * Unwind the blend curve that just failed to construct.
           */
          bln_bnd_cv_ptr = NULL;
          vtx_bln_continuity_exists = FALSE;
          if (end_of_list)
            end_of_list->next = NULL;
          ed_bln_info[i].bln_cv_props[FIRST] = EMSrnd_bln_trans_cv_undefined;
          
          crnt_ed_inx = i;
          while (end_of_list)
            {
            /*
             * Undo the 'crnt_ed_inx' SECOND transition (which is also
             * that edge's previous edge's FIRST transition).
             * Undo of previous transitions terminates on reaching
             * an edge with a fillet.
             * Also, Determine the previous edge index (accommodating
             * the possibility of moving around the round vertex, in
             * the direction opposite to the cyclic order of vertex
             * edges).
             */
            ed_bln_info[crnt_ed_inx].bln_cv_props[SECOND] =
                                     EMSrnd_bln_trans_cv_undefined;
            EMerr_hndlr (crnt_ed_inx == inx, *EMmsg, EMS_E_Fail, wrapup);
            crnt_ed_inx = (num_vtx_eds + --crnt_ed_inx) % num_vtx_eds;

            if (ed_infos[crnt_ed_inx])
              {
              if (end_of_list)
                {
                bln_bnd_cv_ptr = end_of_list;
                end_of_list = end_of_list->prev;
                EMdealloc_rnd_blend_curve_info (&msg, bln_bnd_cv_ptr, 
                  (IGRint)1);
                bln_bnd_cv_ptr->prev = bln_bnd_cv_ptr->next = NULL;
                om$dealloc (ptr = bln_bnd_cv_ptr);
                bln_bnd_cv_ptr = NULL;
                /*
                 * Force this fillet's FIRST iso to the round vertex.
                 */
                stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                         ed_infos[crnt_ed_inx], &ed_bln_info[crnt_ed_inx],
                         TRUE, FALSE, &bln_bnd_cv_ptr);
                EMerr_hndlr (!(1 & stat & msg) || !bln_bnd_cv_ptr, *EMmsg, 
                             EMS_E_Fail, wrapup);
                bln_bnd_cv_ptr->prev = end_of_list;
                end_of_list->next = bln_bnd_cv_ptr;
                end_of_list = bln_bnd_cv_ptr;
                }
              else
                ed_bln_info[ crnt_ed_inx ].bln_cv_props[FIRST] |=
                                           EMSrnd_bln_trans_cv_to_rnd_vtx;
              break;
              }
            else
              {
              if (end_of_list)
                {
                bln_bnd_cv_ptr = end_of_list;
                end_of_list = end_of_list->prev;
                EMdealloc_rnd_blend_curve_info (&msg, bln_bnd_cv_ptr,(IGRint)1);
                bln_bnd_cv_ptr->prev = bln_bnd_cv_ptr->next = NULL;
                om$dealloc (ptr = bln_bnd_cv_ptr);
                bln_bnd_cv_ptr = NULL;
                }
              if (end_of_list)
                end_of_list->next = NULL;
              --num_bln_cvs;
              ed_bln_info[crnt_ed_inx].bln_cv_props[FIRST] |=
                                       EMSrnd_bln_trans_cv_undefined;
              }
            }
          }
          ++num_bln_cvs;
        }

Next:
      /*
       * Here we will route the SECOND iso transition curve to round 
       * vertex.
       */
      if ((ed_bln_info[i].bln_cv_props[SECOND] & EMSrnd_bln_trans_cv_undefined)
           || transcv_to_rnd_vtx)
        {
        if (ed_infos[inx])
          {
          /*
           * Force the i+1 th fillet's SECOND iso to the round vertex(since
           * continuity about the round vertex is non-existant).
           */
          stat = EMget_bln_cvs_to_rnd_vtx (&msg, (IGRushort)0, md_env,
                   ed_infos[inx], &ed_bln_info[inx], FALSE, TRUE,
                   &bln_bnd_cv_ptr);
          EMerr_hndlr (!(1 & stat & msg) || !bln_bnd_cv_ptr, *EMmsg, 
                       EMS_E_Fail, wrapup);
          bln_bnd_cv_ptr->prev = end_of_list;
          if (end_of_list)
            end_of_list->next = bln_bnd_cv_ptr;
          else
            bln_cvs_info = bln_bnd_cv_ptr;
    
          end_of_list = bln_bnd_cv_ptr;
          bln_bnd_cv_ptr = NULL;
          ++num_bln_cvs;
          }
        else
          ed_bln_info[inx].bln_cv_props[SECOND] |=
                                       EMSrnd_bln_trans_cv_undefined;
        }
      }
    }

  /* 
   * Convert the list of blend curves into a cyclic list (begining will
   * always be well defined by 'bln_cvs_info').
   */
  bln_cvs_info->prev = end_of_list;
  end_of_list->next = bln_cvs_info;

  /*
   * Some validation of blend curves is required in case of vertex with all
   * the edges are rounded, then the blend curves will be on the fillets only.
   * If the curves are tangentially positional continuous, refine the blend 
   * curves on the fillets, refining the setback points. This would mean that
   * new fillet iso-iso transitions are to be inserted into the existing list.
   */
  if (homogenous_vtx && all_edges_are_rounded)
    {
    EMvalidate_blend_bound_curves (&msg, md_env, &bln_cvs_info, ed_bln_info, 
      vtx_rnd_info, ed_infos, &bln_cvs_are_valid, &num_bln_cvs_added);
    EMerr_hndlr (!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
    num_bln_cvs += num_bln_cvs_added;
    }

  /* 
   * STEP 4
   *
   * The blend curves obtained may define one or more groups. Traverse the
   * blend curves list forming as many groups as possible (the groups here
   * have no connection what so ever to those obtained by tracing an
   * intersection list).
   *
   * Let the start transition blend curve of the first group be 'bln_cvs_info'.
   * Begining here, traverse the list backwards searching for a fillet such 
   * that its SECOND iso transition is from the vertex.
   * If such a fillet is found, take that transition blend curve as the
   * start of the first group. Now, begining from here (which could be
   * 'bln_cvs_info' itself), form the first group by traversing forward
   * (i.e. in the cyclic direction defined by the vertex edges)in the list.
   * This is continued until
   * . a fillet is found such that the transition from its FIRST iso is
   *   to the round vertex.  Thus, there may be more than one group of
   *   blend curves at this vertex.  Set the new start to the next
   *   blend curve in the list, and repeat the search until all blend
   *   curves in the list are exhausted (note that only in the very first
   *   group formation, it is necessary go back ward searching for a
   *   start).
   * . The traversal reached the start (only one group at this vertex)
   *
   * NOTE: a single group does is a necessary, but NOT a sufficient
   *       condition for the round vertex consumption.
   *
   * NOTE: If the 0th edge had a fillet, then 'bln_cvs_info' would
   *       point to its blend curve, else if the edge had FIRST blend
   *       curve, it would point to that.  In the latter case, if the
   *       edge had no transition curves, then 'bln_cvs_info' would
   *       point to the blend curve of very next edge that has a fillet.
   */
    /* Determine the start of the first group.  This may require a
     * reverse traversal of the transition curve list.
     */
    grp_start_ptr = bln_cvs_info;
    if (vtx_bln_continuity_exists == FALSE)
      for ( ;TRUE; grp_start_ptr = grp_start_ptr->prev)
        {
        if (grp_start_ptr->props & EMSrnd_bln_trans_cv_from_rnd_vtx)
          break;
        EMerr_hndlr (grp_start_ptr->prev == bln_cvs_info, *EMmsg, EMS_E_Fail,
                     wrapup);
        }
    /*
     * The number of SECOND iso transition curves, will be equal to the 
     * number of round groups ( consecutive ). Store the addresses of 
     * these transition in temporary character array "rnd_grp_start_ptr".
     * These curves will form the start of each blend groups.
     */
    if (transcv_to_rnd_vtx)
      {
      tmp_count = 0;
      for ( ;TRUE; grp_start_ptr = grp_start_ptr->prev)
        {
        if (grp_start_ptr->props & EMSrnd_bln_trans_cv_from_rnd_vtx)
	  {
	  rnd_grp_start_ptr[tmp_count] = ( IGRchar *) grp_start_ptr;
	  tmp_count++;
	  }
        if (tmp_count == num_rnd_grps)
	  break;
        }
      }

    /*
     * Allocate space for blend groups (even this will be far too
     * much!!.  The average number of blend groups expected at a vertex
     * would be around 1~3). Also don't panick, number of blend groups
     * are not allowed to exceed MAX_TO_STACK_ALLOC.
     */
    bln_grps = (struct EMSrnd_blend_group *) alloca
                (MAX_TO_STACK_ALLOC * sizeof( struct EMSrnd_blend_group));

    if (vtx_bln_continuity_exists == TRUE)
      {
      /*
       * I am setting vtx_bln_continuity_exists to TRUE, for implementation
       * convenience so that it is stand alone. In fact, this flag should 
       * be FALSE and the whole of the following code can be a part of the 
       * else construct for vtx_bln_continuity_exists = FALSE.
       * Traverse the blend curves list to form as many closed groups
       * as the number of round groups ( consecutive ). 
       *  ------- KNAP ( Blend Enhancement ).
       */
      if (transcv_to_rnd_vtx)
	{
	num_bln_grps = num_rnd_grps; 
	for (i=0; i<num_bln_grps; i++)
	  {
	  bln_grps[i].start_of_grp = 
	              (struct EMSrnd_blend_curve_info *)rnd_grp_start_ptr[i];
          j = 1;  /* Number of elements within a blend group. */
	  tmp_ptr1 =  bln_grps[i].start_of_grp;
	  do
            {
            ++j;
	    tmp_ptr1 = tmp_ptr1->next;
            if (tmp_ptr1->props & EMSrnd_bln_trans_cv_to_rnd_vtx)
              {
              /*
               * Detected an end of a blend group.
               */
              bln_grps[i].end_of_grp = tmp_ptr1;
              bln_grps[i].num_elems = j;
              bln_grps[i].start_of_grp->prev = bln_grps[i].end_of_grp;
              bln_grps[i].end_of_grp->next = bln_grps[i].start_of_grp;
	      }
            }
            while (!(tmp_ptr1->props & EMSrnd_bln_trans_cv_to_rnd_vtx));
          }
	}
      else
	{
        num_bln_grps = 1;
        bln_grps[0].start_of_grp = grp_start_ptr;
        bln_grps[0].end_of_grp = grp_start_ptr->prev;
        bln_grps[0].num_elems = num_bln_cvs;
        }
      }
    else
      {
      bln_grps[0].start_of_grp = grp_start_ptr;
      i = 1;	/* Number of elements within a blend group. */
      for (tmp_ptr1 = (bln_grps[0].start_of_grp)->next;
           tmp_ptr1 != bln_grps[0].start_of_grp;)
        {
        ++i;
        if (tmp_ptr1->props & EMSrnd_bln_trans_cv_to_rnd_vtx)
          {
          /*
           * Detected an end of a blend group.
           */
          bln_grps[num_bln_grps].end_of_grp = tmp_ptr1;
          bln_grps[num_bln_grps].num_elems = i;
          /* Make this group cyclic. */
          bln_grps[num_bln_grps].start_of_grp->prev = 
                                 bln_grps[num_bln_grps].end_of_grp;
          bln_grps[num_bln_grps].end_of_grp->next = 
                                 bln_grps[num_bln_grps].start_of_grp;
          ++num_bln_grps;
          EMerr_hndlr (num_bln_grps == MAX_TO_STACK_ALLOC, *EMmsg, EMS_E_Fail,
                       wrapup);
          bln_grps[num_bln_grps].start_of_grp = tmp_ptr1->next;
          i = 1; /* Initialized for next blend group. */
          tmp_ptr1 = tmp_ptr1->next;
          continue;
          }
          tmp_ptr1 = tmp_ptr1->next;
        }
      }


  /* 
   * STEP 5
   *
   * Traverse the list of blend groups, and for each group, create surface
   * geometries. This depends on the number of bounding curves within each
   * blend group.
   * . If the number of bounding curves within a group is 3 or 4, then create
   *   a single surface. In this case, there is no need to split the blend
   *   curves on model surfaces (fillets included).
   * . If the number of bounding curves within a group is greater than 4, then
   *   create that many surface patches. The composite of these pacthes is the
   *   blend.  In this case, due to the methodology followed in the creation of
   *   constituent patches, it is necessary to split each of the bounding
   *   curves on model surfaces (including fillets).
   *
   * After creating the blend, add the bounding curves, add the corresponding
   * blend edges to the intersection list.
   */
  /* Allocate memory for blend surface related elements (accommodation
   * of the largest blend group prevents repeated allocations).
   */
  max_bnd_cvs = bln_grps[0].num_elems;
  for (i=1; i<num_bln_grps; i++)
    if (bln_grps[i].num_elems > max_bnd_cvs)
      max_bnd_cvs = bln_grps[i].num_elems;

  bln_tan_sf_geoms_array = (struct IGRbsp_surface **) alloca
                           (max_bnd_cvs * sizeof (struct IGRbsp_surface *));
  bln_bnd_cv_geoms_array = (struct IGRbsp_curve **) alloca
                           (max_bnd_cvs * sizeof (struct IGRbsp_curve *));
  bln_sf_ed_ids = (GRobjid *) alloca (2*max_bnd_cvs * sizeof(GRobjid));
  bln_sf_ids = (GRobjid *) alloca (2*max_bnd_cvs * sizeof(GRobjid));
  mid_points = (IGRpoint *) alloca (max_bnd_cvs * sizeof(IGRpoint));
  bln_sf_ed_geoms = (struct IGRbsp_curve **) alloca
                    (2*max_bnd_cvs * sizeof(struct IGRbsp_curve *));

  for (i=0; i<max_bnd_cvs; i++)
     bln_sf_ed_geoms[i] = NULL;

  for (i=0; i<num_bln_grps; i++)
    {
    /* 
     * Ensure model space position continuity of all the bounding curves
     * This is done by forcing the start point of each blend bounding curve
     * to be concident with the end point of its cyclic previous bounding
     * curve. Also collect the blend curves and the tangent surfaces into 
     * arrays suitable for constructing the blend.
     */
    num_bnd_cvs_in_grp = bln_grps[i].num_elems;
    tmp_ptr2 = bln_grps[i].start_of_grp;
    for (j=0; j<num_bnd_cvs_in_grp; j++)
      {
      EMmake_curves_pos_continuous (tmp_ptr2->prev->xyz_geom,
                                    tmp_ptr2->xyz_geom);
      bln_bnd_cv_geoms_array[j] = tmp_ptr2->xyz_geom;
      bln_tan_sf_geoms_array[j] = tmp_ptr2->tangent_sf_geom;
      tmp_ptr2 = tmp_ptr2->next;
      }
    /*
     * Obtain the oriented surface normal at the end of the first
     * bound curve.  This is used to orient the newly created blend
     * surfces.
     */
    tmp_ptr2 = bln_grps[i].start_of_grp;
    if (tmp_ptr2->uv1.datatype == EMSdata_curve3d)
      {
      inx = tmp_ptr2->uv1.data.curve->num_poles - 1;
      OM_BLOCK_MOVE (&tmp_ptr2->uv1.data.curve->poles[inx*2], uv_params,
                     sizeof(point2d));
      if (tmp_ptr2->uv1.data.curve->rational &&
               tmp_ptr2->uv1.data.curve->weights)
        for (j=0; j<2; j++)
          uv_params[j] /= tmp_ptr2->uv1.data.curve->weights[inx];
      }
    else
      {
      inx = tmp_ptr2->uv1.data.poly->num_points - 1;
      OM_BLOCK_MOVE (&tmp_ptr2->uv1.data.poly->points[inx*2], uv_params,
                     sizeof(point2d));
      }
    BSsfarrevn (&msg, tmp_ptr2->tangent_sf_geom, (IGRint)1, &uv_params[U],
                (IGRint)1, &uv_params[V], pt_xyz, sf_normal);
    if (tmp_ptr2->tangent_sf_geom->pos_orient == FALSE)
      for (j=0; j<3; j++)
        sf_normal[j] = -sf_normal[j];

    if (num_bnd_cvs_in_grp <= 4)
      {
      /*
       * Create a single single blend surface. 
       */
      stat = EMcreate_3or4cv_blend_surface (&msg, (IGRushort)0, construct_list,
               num_bnd_cvs_in_grp, bln_bnd_cv_geoms_array,
               bln_tan_sf_geoms_array, &sf_normal, fillet_patch, bln_sf_ed_ids,
               bln_sf_ed_geoms, bln_sf_ids );
      EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);

      /* 
       * Ensure that there is a one-to-one correspondence between the
       * bound edges, and the output arrays (facilitates subsequent
       * processing).
       */
      for (j=1; j<num_bnd_cvs_in_grp; j++)
        bln_sf_ids[j] = bln_sf_ids[0];
      }
    else
      {
      /*
       * Make as many blend surfaces as the number of elements in this group,
       * and make a composite blend out of these.
       */
      /*
       * Need to do something intelligent here (requested Dieter
       * for some tools).
       */
      offset_dist = 0.0;
      stat = EMget_blend_sf (&msg, (IGRushort)0, construct_list,
               num_bnd_cvs_in_grp, bln_bnd_cv_geoms_array,
               bln_tan_sf_geoms_array, &sf_normal, offset_dist, fillet_patch,
               NULL, NULL, bln_sf_ed_ids, bln_sf_ed_geoms, bln_sf_ids,
               mid_points);
      EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);
      }

    /* 
     * . Add the intersections into the intersection lists.  If the number
     *   of bound curves is greater than 4, this would require each bound
     *   curve, and its counterpart on the model surface, to be split at the
     *   mid-point of the bound curve. In the following, in case of a split,
     *   FIRST referes to the first segment in the cyclic direction, and
     *   SECOND, the second segment in that direction (for no splits, only
     *   FIRST is meaningful).
     *   m .. indexes over each ORIGINAL (unsplit) bound curves (so can be
     *        used to index over 'mid_points' etc.).
     *   j .. indexes over split elements (i.e. blend edge ids, blend
     *        surface patches, etc.).
     */
    for (j=0, m=0, tmp_ptr2 = bln_grps[i].start_of_grp; m < num_bnd_cvs_in_grp;
         tmp_ptr2 = tmp_ptr2->next, m++)
      {
      model_GRid.objid = tmp_ptr2->tangent_sf_id;
      model_GRid.osnum = bln_GRid.osnum = os;
      if (num_bnd_cvs_in_grp <= 4)
        {
        /* 
         * Collect the incident information for the start and the end
         * of the uv curve that is on a model surface.
         */
        OM_BLOCK_MOVE (&tmp_ptr2->uv1, &model_uv_dataselect[FIRST],
                       sizeof(struct EMSdataselect));
        tmp_ptr2->incident_info[FIRST]->next = tmp_ptr2->incident_info[SECOND];
        model_uv_incident_info[FIRST] = tmp_ptr2->incident_info[FIRST];
        }
      else
        {
        BSmdistptsf (&msg, tmp_ptr2->tangent_sf_geom, mid_points[m],
                     &uv_params[0], &uv_params[1], pt_xyz, &min_dist);
        EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
                
        stat = EMprojectpt (&msg, &mat_type, matrix, &tmp_ptr2->uv1, (IGRint)1,
                 uv_params, bas_tol, &split_pt, &min_dist);
        EMerr_hndlr (!(1 & msg & stat), *EMmsg, EMS_E_Fail, wrapup);

        OM_BLOCK_MOVE (split_pt.point, pt_xyz, sizeof(IGRpoint));
        EMsplit_data (&msg, &md_env->md_env, &tmp_ptr2->uv1,
          (IGRint)split_pt.span_inx, split_pt.param, FALSE, pt_xyz,
          &model_uv_dataselect[FIRST],&model_uv_dataselect[SECOND]);
        EMerr_hndlr (!(1 & stat), *EMmsg, EMS_E_Fail, wrapup);

        /* 
         * Collect the incident information. Needs two pairs, one
         * for each segment.
         */
        model_uv_incident_info[FIRST] = tmp_ptr2->incident_info[FIRST];
        tmp_ptr2->incident_info[FIRST]->next = EMsfintedpar_malloc (&msg, 1);
        EMerr_hndlr (!tmp_ptr2->incident_info[FIRST]->next, *EMmsg,
                     EMS_E_NoDynamicMemory, wrapup);
        model_uv_incident_info[SECOND] = EMsfintedpar_malloc (&msg, 1);
        EMerr_hndlr (!model_uv_incident_info[SECOND], *EMmsg,
                     EMS_E_NoDynamicMemory, wrapup);
        model_uv_incident_info[SECOND]->next = tmp_ptr2->incident_info[SECOND];
        }

      /*
       * Add to the local inters lists.
       */
      for (k=FIRST; k<=SECOND; k++)
        {
        bln_GRid.objid = bln_sf_ids[ j ];
        stat = EMgetvggeom (&msg, &mat_type, matrix, &bln_GRid,
                 (IGRchar *) &bln_sf_geom, NULL);
        EMerr_hndlr (!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);

        xyz_dataselect.datatype = EMSdata_curve3d;
        xyz_dataselect.data.curve = bln_sf_ed_geoms[j];

        bln_uv_GRid = (struct GRid *) om$malloc (size = sizeof(struct GRid));
        EMerr_hndlr (!bln_uv_GRid, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        bln_uv_GRid->osnum = os;
        bln_uv_GRid->objid = bln_sf_ed_ids[j];

        bln_uv_dataselect.datatype = EMSdata_object;
        bln_uv_dataselect.data.object = bln_uv_GRid;

        /* 
         * Create two empty incident information packets for the
         * blend sf uv edge.
         */
        bln_uv_incident_info = EMsfintedpar_malloc (&msg, 2);
        EMerr_hndlr (!bln_uv_incident_info, *EMmsg, EMS_E_NoDynamicMemory, 
                     wrapup);
        EMmakeintlist (&msg, tmp_ptr2->ed_info ? &loc_fillet_inters :
          &loc_model_inters, &loc_fillet_inters, &model_GRid, &bln_GRid, NULL,
          NULL, NULL, EMSinters_loopcreated, &xyz_dataselect,
          &model_uv_dataselect[k], &bln_uv_dataselect,
          tmp_ptr2->tangent_sf_geom->pos_orient == bln_sf_geom->pos_orient ?
          TRUE : FALSE, FALSE, (IGRchar *)model_uv_incident_info[k],
          (IGRchar *)bln_uv_incident_info, 
          (IGRulong) EMSintobj_marked | EMSintobj_tangent,
          (IGRulong) EMSintobj_marked | EMSintobj_tangent, NULL, NULL,
          TRUE, FALSE);
        EMerr_hndlr (!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);

        bln_uv_GRid = NULL;
        bln_uv_incident_info = NULL;
        tmp_ptr2->incident_info[FIRST] =
        tmp_ptr2->incident_info[SECOND] = NULL;
        om$dealloc (ptr = bln_sf_geom);
        bln_sf_geom = NULL;
        bln_sf_ed_geoms[j] = NULL;
        ++j;
        if (num_bnd_cvs_in_grp <= 4)
          {
          tmp_ptr2->uv1.datatype = EMSdata_null;
          break;
          }
        }
      }
    }

  EMmergeinters (&msg, fillet_inters, loc_fillet_inters);
  EMerr_hndlr (!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  loc_fillet_inters = NULL;
   
  EMmergeinters (&msg, model_inters, loc_model_inters);
  EMerr_hndlr (!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  loc_model_inters = NULL;

wrapup:

  /* 
   * All blend surfaces created within this function are always placed
   * inside the composite.  On error, removing these are left to
   * whoever is removing the composite surface.
   */
  /* The blend surface object inside the inters node is removed whenever the
   * composite surface is removed (the inersection list being NULL is
   * accommodated within the following free functions).
   */
  EMinters_data_free (&msg, loc_fillet_inters, (IGRint) 0, NULL,
    EMsfintedpar_free);
  EMinters_free (loc_fillet_inters, (IGRint)0);

  EMinters_data_free (&msg, loc_model_inters, (IGRint) 0, NULL,
    EMsfintedpar_free);
  EMinters_free( loc_model_inters, ( IGRint ) 0 );

  for (i=0; i<num_bln_grps; i++)
    {
    EMdealloc_rnd_blend_curve_info (&msg, bln_grps[i].start_of_grp, (IGRint)0);
    om$dealloc (ptr = bln_grps[i].start_of_grp);
    }

  if (bln_sf_ed_geoms)
    for (i=0; i<max_bnd_cvs; i++)
  if (bln_sf_ed_geoms[i])
    BSfreecv (&msg, bln_sf_ed_geoms[i]);
  if (bln_sf_geom)
    BSfreesf( &msg, bln_sf_geom );

  if (bln_uv_GRid)
    om$dealloc (ptr = bln_uv_GRid);

  if (bln_uv_incident_info)
    EMsfintedpar_free (bln_uv_incident_info, (IGRint)0);

  EMWRAPUP (*EMmsg, stat, "EMget_n_sided_blend");
  return (stat);
}

static void get_prev_and_next_index (num, crnt_inx, prev_inx, next_inx)
IGRint         num;
IGRint         crnt_inx;
IGRint         *prev_inx;
IGRint         *next_inx;
{
  if (crnt_inx == num - 1)
    {
    *prev_inx = crnt_inx - 1;
    *next_inx = 0;
    }
  else if (crnt_inx == 0)
    {
    *prev_inx = num - 1;
    *next_inx = crnt_inx + 1;
    }
  else
    {
    *prev_inx = crnt_inx - 1;
    *next_inx = crnt_inx + 1;
    }
}

end implementation EMSsfrndbool;

