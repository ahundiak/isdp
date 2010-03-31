/*
  DESCRIPTION

    This function would handle the vertex situation where atleast one
    edge is not rounded. But this vertex needs to be a homogenous one.
    The fillets here are expected to be extended enough to intersect with
    other fillet and/or the appropriate surfaces at the vertex.

  ARGUMENTS

    fillet_inters - 	Input/Output: intersections on the fillets produced
                         as a result of processing here. Existing list
                         is appended to.
    model_inters - 	Input/Output: intersections on the model produced
                         as a result of processing here. Existing list
                         is appended to.

  ALGORITHM 

    First take any fillet at the vertex and intersect with all other fillets
    and all the surfaces meeting at this vertex other than the surface and
    common surface of the fillet. Continue this step for all the edges to be
    rounded at the vertex. The intersections thus generated on the fillets
    may not be fully useable as these may cross each other. These have to be
    processed and split up at the intersection points. 
    N.B.: Tracing performed later will only pick up the pieces that are
    relevant, deleting the irrelevant intersections. 
*/

class implementation EMSsfrndbool;

#include <math.h>
#include <alloca.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h"
#include "emsinterdef.h"

#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWapi/xyztol.h"
#include "PWapi/partol.h"
#include "PWapi/sfgeom.h"

#define U 0
#define V 1
#define W 2

#define FIRST  0
#define SECOND 1
#define LAST   1

#define START  0
#define STOP   1

#define THIS  0
#define OTHER 1

#define LO_U  0
#define HI_U  1

#define BUFF_SIZE 100

struct intobj_end
  {
  struct EMSintobj *intobj;
  IGRboolean geom_start;
  };

typedef struct intobj_end intobj_end4[4];

from EMSedge import EMget_vtx_sfs, EMget_bcxyz_geom, EMget_props;
from EMSsubbs import EMpartolbasis;

%safe
static void get_special_intersection_points(), get_intersection_points();
static void check_fillet_or_surf();
static void chg_int_new_stop();
static IGRboolean int_already_done(), other_ints_on_model(), adjacent_3();
static IGRboolean int_in_record(), endint_in_record();
static struct EMSintobj *get_sibling();
static void merge_adjacent_intobjs();
static IGRboolean IsNeutral(enum EMSedge_config);
%endsafe

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

IGRlong EMgeneral_trim (msg, options, construct_list,
                        vertex_info, fillet_patch, fillet_inters, model_inters)
IGRlong *msg;
IGRushort options;
struct GRvg_construct *construct_list;
struct EMSvtx_rnd_info *vertex_info;
struct GRid *fillet_patch;
struct EMSinters **fillet_inters, **model_inters;
{
  IGRboolean is_vtx_closed, is_inters, at_start, split, (*intatedge)[2];
  IGRboolean is_fillet, is_fillet1, is_fillet2, vtx_sf_inx, on_edge;
  IGRboolean other_srf_not_fill_sf, special_intersection, no_blend_solution,
             sngpch_solution, has_neutral_eds, multi_int=0;
  IGRushort world_options, param_options, trim_options, ed_props;
  IGRshort *mattyp;
  IGRint ii,i, j, k, l, uval, inx, non_round_inx, buff_size;
  IGRint num_edges, num_edges_rounded, num_vtx_sfs, num_int_already;
  IGRint this_fill_info_inx, other_fill_info_inx, other_srf_info_inx;
  IGRint *round_edge_inx, neutral_ed_inx, rounded_ed_inx, non_rounded_ed_inx;
  IGRint prev_inx=0, next_inx=0;
  IGRlong msg_loc, stat_OM;
  IGRlong num_inters;
  IGRdouble *vtx_pt, *mat, dumpar, mindist, uvtol, chttol, lentol;
  IGRpoint uvpts[2], endpts[2], dumpt;
  GRobjid *vtx_sfs;
  GRobjid this_fillet, other_fillet, other_other_fillet, other_srf, srfid;
  GRspacenum os;
  intobj_end4 *int_already, *tmp_already;
  struct IGRbsp_curve xyzcv;
  struct GRid other_id;
  struct GRmd_env *env;
  struct GRmdenv_info *mdenv_info;
  struct EMSinters *inters, *loc_fillet_inters, *loc_model_inters;
  struct EMSinters *tmp_loc_fillet_inters, *tmp_loc_model_inters;
  struct EMSinters *fillet_fillet_inters, *fillet_model_inters;
  struct EMSinters *model_fillet_inters;
  struct EMSintobj *intobj, *p_intobjs[2], *p_intobj, *split_intobjs[2][2];
  struct EMSintobj *counterpart_intobj;
  struct EMSdataselect other_data;
  struct EMSedge_rnd_info **edge_infos;
  struct EMSpypoint *p_splitinfos[2];
  struct EMSsftracedata fsftrc;
  enum EMSedge_config *edge_configs;
  void EMmergeinters(), EMkeep_mindist_intobj(), EMsfintedpar_free();
  extern IGRdouble EMget_fillet_int_data();
  extern IGRlong  EMweed_out_inters();

  IGRboolean save_pathway_trim, save_pathway_orient;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  p_splitinfos[FIRST] = NULL;
  p_splitinfos[SECOND] = NULL;
  loc_fillet_inters = NULL;
  loc_model_inters  = NULL;
  tmp_loc_fillet_inters = NULL;
  tmp_loc_model_inters  = NULL;
  fillet_fillet_inters = NULL;
  fillet_model_inters = NULL;
  model_fillet_inters = NULL;
  vtx_sfs = NULL;
  xyzcv.poles = xyzcv.knots = xyzcv.weights = NULL;

  num_edges = vertex_info->num_edges;
  edge_infos = vertex_info->edge_infos;
  edge_configs = vertex_info->edge_configs;
  vtx_pt = vertex_info->vtx_pt;
  env = construct_list->env_info;
  mdenv_info = &env->md_env;
  os = env->md_id.osnum;
  mattyp = &env->md_env.matrix_type;
  mat = env->md_env.matrix;
  no_blend_solution = FALSE;
  has_neutral_eds = FALSE;
  sngpch_solution = FALSE;
  num_edges_rounded = 0;

  for (i=0; i<num_edges; i++)
    {
    if (edge_infos[i])
      {
      rounded_ed_inx = i;
      num_edges_rounded++;
      continue;
      }
    if (edge_configs[i] == EMSedge_neutral ||
        edge_configs[i] == EMSedge_neutral_convex ||
        edge_configs[i] == EMSedge_neutral_concave)
      {
      neutral_ed_inx = i;
      has_neutral_eds = TRUE;
      }
    else if (!edge_infos[i])
      non_rounded_ed_inx = i;
    }
  if (num_edges == 3)
    {
    if (has_neutral_eds && (num_edges_rounded == 1))
      {
      EMget_fillet_int_data (&msg_loc, edge_infos[rounded_ed_inx],
                             vertex_info->edge_ids[non_rounded_ed_inx], os,
                             vertex_info->edge_stops[non_rounded_ed_inx],
                             NULL, NULL, NULL, NULL, dumpt);
      if (EMSerror(msg_loc))
        {
        sngpch_solution = TRUE;
        goto ret_end;
        }
      EMget_fillet_int_data (&msg_loc, edge_infos[rounded_ed_inx],
                             vertex_info->edge_ids[neutral_ed_inx], os,
                             vertex_info->edge_stops[neutral_ed_inx],
                             NULL, NULL, NULL, NULL, dumpt);
      if (EMSerror(msg_loc))
        {
        sngpch_solution = TRUE;
        goto ret_end;
        }
      }
    }
  else 
    {
    ed_props = 0;

    if (has_neutral_eds && (num_edges_rounded == 1))
    {
      /*
       * We go for a single patch solution if we have a seam edge adjacent to
       * the only rounded edge. Get the indices of the previous and next edge
       * and check if it is a seam. If the seam is on a vertex surface that is
       * not supporting the fillet, we can handle the condition.
       */
      prev_inx = (rounded_ed_inx == 0) ? (num_edges - 1) : (rounded_ed_inx - 1);
      next_inx = (rounded_ed_inx == (num_edges - 1)) ? 0 : (rounded_ed_inx + 1);

      if ( IsNeutral( edge_configs[prev_inx]))
      {
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                              &ed_props),
                              senderid = NULL_OBJID,
                              targetos = os,
                              targetid = vertex_info->edge_ids[prev_inx]);
      }
      else if ( IsNeutral( edge_configs[next_inx]))
      {
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                              &ed_props),
                              senderid = NULL_OBJID,
                              targetos = os,
                              targetid = vertex_info->edge_ids[next_inx]);
      }
    }

    if (ed_props & EMED_SEAM)
      sngpch_solution = TRUE;
    }

  /*
   * For this function to succeed, every fillet must have atleast one
   * intersection curve that touches it's U=0 boundary and another that
   * touches the U=1 (within 2 * cht). While these intersections are being
   * produced, keep track of this. After all intersections have been produced, 
   * check if each fillet satisfies this condition. Here initialize the array.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  intatedge = (IGRboolean (*)[]) alloca (num_edges * 2 * sizeof (IGRboolean));
  for (i=0; i<num_edges; i++)
    for (j=LO_U; j<=HI_U; j++)
      intatedge[i][j] = FALSE;

  /*
   * Set the options for subsequent calls to the intersection
   * functions. 
   */

  world_options = EMSINT_OUTPUT_WORLD;
  param_options = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT;
  for (i=0; i<num_edges; i++)
    if (edge_infos[i])
      {
      if (edge_configs[i] == EMSedge_convex)
        param_options |= EMSINT_ORIENT_RIGHT;
      break;
      }
  trim_options = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                  EMSINT_TRIM_HANDLESTOP;

  /*
   * Find the intersections on each fillet terminating at this vertex with
   * all the other fillets terminating at this vertex. The intersections
   * computed are between fillets so the "my" and the "other" intersection
   * lists are both "fillet_inters". Mark the intersections produced here
   * so that these may be recognizable later in the processing. Make a 
   * temporary list here, which can be merged into the real "fillet_inters"
   * if all succeeds.
   */

  for (i=0; i<num_edges; i++)
    {
    if (!edge_infos[i])
      continue;

    for (j=i+1; j<num_edges; j++)
      {
      if (!edge_infos[j])
        continue;

      other_data.datatype = EMSdata_object;
      other_id.objid = edge_infos[j]->fill_id;
      other_id.osnum = os;
      other_data.data.object= &other_id;

      save_pathway_trim = _pathway_trim;
      save_pathway_orient = _pathway_orient;
      _pathway_trim = 0;
      _pathway_orient = 0;

      num_inters = 0;
      stat_OM = om$send (msg = message EMSsurface.EMsfsfint (&msg_loc,
                 mattyp, mat, construct_list, &other_data, &env->md_env,
                 world_options, param_options, trim_options,
                 &num_inters, 
                 &loc_fillet_inters, &loc_fillet_inters),
		 senderid = NULL_OBJID,
		 targetid = edge_infos[i]->fill_id, targetos = os);

      _pathway_trim = save_pathway_trim;
      _pathway_orient = save_pathway_orient;

      EMerr_hndlr (EMSerror (stat_OM & msg_loc) || !num_inters, *msg,
       EMS_E_SurfaceError, ret_end );

      EMkeep_mindist_intobj (&msg_loc, mattyp, mat, loc_fillet_inters->cvs,
       vtx_pt);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 

      loc_fillet_inters->cvs->props |= 
       EMSintobj_tmpmarked;
      loc_fillet_inters->cvs->other_intobj_node->props |= 
       EMSintobj_tmpmarked;

      for (k=THIS; k<=OTHER; k++)
        {
        inx = k == THIS ? i : j;
        p_intobj = loc_fillet_inters->cvs;
        if (k == OTHER)
          p_intobj = p_intobj->other_intobj_node;

        EFmaptobnd (&msg_loc, NULL, edge_infos[inx]->fill_surf, 2 * chttol,
         &p_intobj->this_xyzintobj, &p_intobj->this_uvintobj);

        EMgetendpts_uv (&msg_loc, &p_intobj->this_uvintobj, FALSE, 1,
         uvpts[START], uvpts[STOP]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      
        uvtol = edge_infos[inx]->fill_surf_tol * chttol/lentol;
        for (l=START; l<=STOP; l++)
          for (uval=LO_U; uval<=HI_U; uval++)
            if (fabs (uvpts[l][U] - (IGRdouble) uval) < uvtol)
              intatedge[inx][uval] = TRUE;
        }

      EMmergeinters (&msg_loc, &fillet_fillet_inters, loc_fillet_inters);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
      loc_fillet_inters = NULL;
      }
    }

  /*
   * Check for a special situation here. If this is a 3-edge, homogenous vertex
   * and two of these edges are being rounded, check if the fillet-fillet
   * intersection is sufficient work at the vertex. That is, the intersections
   * run from U0 to U1 on both fillets and that the relevant endpoint of the
   * fillet-fillet intersection lies on the edge that is not being rounded.
   */

  num_edges_rounded = 0;
  round_edge_inx = (IGRint *) alloca (num_edges * sizeof (IGRint));
  inx = 0;
  for (i=0; i<num_edges; i++)
    if (edge_infos[i])
      {
      num_edges_rounded++;
      round_edge_inx[inx++] = i;
      }
    else
      non_round_inx = i;

  if (num_edges == 3 && num_edges_rounded == 2 &&
      (intatedge[round_edge_inx[FIRST]][LO_U] &&
       intatedge[round_edge_inx[FIRST]][HI_U] &&
       intatedge[round_edge_inx[SECOND]][LO_U] &&
       intatedge[round_edge_inx[SECOND]][HI_U]))
    {
    intobj = fillet_fillet_inters->cvs;
    EMgetendpts_xyz (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
     &intobj->this_xyzintobj, intobj->reversed, 1, 
     endpts[START], endpts[STOP]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, mdenv_info,
     NULL, NULL, 0, MAXINT, FALSE, NULL, &xyzcv), 
     targetid = vertex_info->edge_ids[non_round_inx], targetos = os,
     senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    on_edge = FALSE;
    for (i=START; i<=STOP; i++)
      {
      BSmdstptcv (&xyzcv, endpts[i], &dumpar, dumpt, &mindist, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      if (mindist <= chttol)
        {
        on_edge = TRUE;
        break;
        }
      }
    if (on_edge)
      goto Process_all_intersections;
    }

  /*
   * Obtain all the surfaces that have an edge terminating
   * at this vertex.
   */

  num_vtx_sfs = 0;
  stat_OM = om$send (msg = message EMSedge.EMget_vtx_sfs (&msg_loc, NULL,
             vertex_info->edge_stops[FIRST], &num_vtx_sfs, &vtx_sfs,
             &is_vtx_closed), senderid = NULL_OBJID,
             targetid = vertex_info->edge_ids[0], targetos = os); 
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
   ret_end);

  /*
   * Find the intersections on each fillet terminating at this vertex with
   * all the other vertex surfaces. Do not consider intersection between
   * the fillet and the two surfaces between which this fillet was
   * generated. If we gather up all such intersections for any given
   * fillet, they must collectively traverse from U=0 to U=1 at the
   * relevant end of the fillet. This is ensured by a little bit of
   * juggling of the end-data (within acceptable tolerances (cht)).
   */

  for (i=0; i<num_edges; i++)
    {
    if (!edge_infos[i])
      continue;

    for (j=0; j<num_vtx_sfs; j++)
      {
      if (IF_EQ_OBJID (vtx_sfs[j], edge_infos[i]->surf_id) ||
          IF_EQ_OBJID (vtx_sfs[j], edge_infos[i]->com_surf_id))
        continue;

      other_data.datatype = EMSdata_object;
      other_id.objid = vtx_sfs[j];
      other_id.osnum = os;
      other_data.data.object= &other_id;

      num_inters = 0;

      save_pathway_trim = _pathway_trim;
      save_pathway_orient = _pathway_orient;
      if (num_edges_rounded == 1) 
        _pathway_trim = 1;
      else
        _pathway_trim = 0;
      _pathway_orient = 0;

      stat_OM = om$send (msg = message EMSsurface.EMsfsfint (&msg_loc,
                 mattyp, mat, construct_list, &other_data, &env->md_env,
                 world_options, param_options, trim_options,
                 &num_inters,
                 &tmp_loc_fillet_inters, &tmp_loc_model_inters),
		 senderid = NULL_OBJID,
		 targetid = edge_infos[i]->fill_id, targetos = os);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc) || !num_inters,
                                          *msg, EMS_E_SurfaceError, ret_end);

      _pathway_trim = save_pathway_trim;
      _pathway_orient = save_pathway_orient;


      /*
       * If the number of intersections returned is >1, then try to merge
       * the intobjs to form on intobj which will be retained. EMsfsfint()
       * may return multiple intobjs depending on the conditions eg. over-
       * lapping intersections are split, but have to be retained. There-
       * fore merge them. This does away with the problem of blend solutions
       * instead of trim sloutions in many cases. Presently, go through this
       * only for single edge-rounded vertices.
       */
      if(num_inters > 1 && num_edges_rounded == 1)
      {
        IGRboolean are_identical = FALSE;
        IGRint num_keep_intobjs = 0, num_loc_intobjs=0, knt, index, count, cnt;
        struct EMSintobj *p_tmp_intobj=NULL;
        struct EMSintobj **keep_intobjs = NULL, **loc_keep_intobjs=NULL;
        struct EMSsftracedata loc_trace;

        /*
         * Get the intobjs on the fillet surface that are close to the
         * vertex point.
         */
        EMweed_out_inters(&msg_loc, NULL, env, vtx_pt,
                          tmp_loc_fillet_inters, &num_keep_intobjs,
                          &keep_intobjs, &are_identical );
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 

        /*
         * Trace the intobjs on the model surface.
         */
        save_pathway_trim = _pathway_trim;
        save_pathway_orient = _pathway_orient;
        _pathway_trim = 0;
        _pathway_orient = 0;

        EMintersect_surfaces (&msg_loc, NULL, &env->md_env, 0, NULL, NULL,
         EMS_SFINT_SKIPSFINT | EMS_SFINT_SKIPFIXING | EMS_SFINT_CHTTRACETOL,
         NULL, NULL, NULL, NULL, NULL, &tmp_loc_model_inters, NULL, &loc_trace,
         NULL, NULL, NULL, NULL);

        _pathway_trim = save_pathway_trim;
        _pathway_orient = save_pathway_orient;

        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
        EMerr_hndlr (loc_trace.num_grps < 1, *msg, EMS_E_InvalidCase, ret_end);

        /*
         * We can have only a maximum of num_keep_intobjs in loc_keep_intobjs.
         */
        loc_keep_intobjs = (struct EMSintobj **) malloc
                           (num_keep_intobjs * sizeof(struct EMSintobj *));
        EMerr_hndlr ( !loc_keep_intobjs, *msg, EMS_E_NoDynamicMemory, ret_end); 

        memset(loc_keep_intobjs, NULL,
               num_keep_intobjs * sizeof(struct EMSintobj *));

        for(knt=0; knt<loc_trace.num_grps; knt++)
        {
          for(index=0; index<loc_trace.num_subgrps_grp[knt]; index++)
          {
            num_loc_intobjs = 0;
            p_tmp_intobj = loc_trace.elems[knt][index];

            for(count=0; count<loc_trace.num_elems_subgrp[knt][index]; count++)
            {
              for(cnt=0; cnt<num_keep_intobjs; cnt++)
              {
                if(keep_intobjs[cnt]->other_intobj_node == p_tmp_intobj)
                {
                  loc_keep_intobjs[num_loc_intobjs] = p_tmp_intobj;
                  num_loc_intobjs ++;

                  break;
                }
              }

              p_tmp_intobj = p_tmp_intobj->next;
            }

            if(num_loc_intobjs > 1 && tmp_loc_model_inters->num_cvs > 1)
            {
              if(loc_trace.num_subgrps_grp[knt] > 1)
                multi_int = TRUE;

              merge_adjacent_intobjs ( &msg_loc, *mattyp, mat, num_loc_intobjs,
                                       loc_keep_intobjs, tmp_loc_model_inters,
                                       tmp_loc_fillet_inters);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
            }
          }
        }

        EMsfinttrace_free( &msg_loc, loc_trace.num_grps,
              loc_trace.num_subgrps_grp, loc_trace.num_elems_subgrp,
              loc_trace.elems, loc_trace.subgrp_rev, loc_trace.elem_rev,
              loc_trace.grp_closed, loc_trace.subgrp_closed );
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
      }

      if(!multi_int)
      {
        EMkeep_mindist_intobj (&msg_loc, mattyp, mat,
                               tmp_loc_fillet_inters->cvs, vtx_pt);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
      }

      tmp_loc_fillet_inters->cvs->props |= 
       EMSintobj_tmpmarked;
      tmp_loc_fillet_inters->cvs->other_intobj_node->props |= 
       EMSintobj_tmpmarked;

      EMmergeinters (&msg_loc, &loc_fillet_inters, tmp_loc_fillet_inters);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
      tmp_loc_fillet_inters = NULL;

      EMmergeinters (&msg_loc, &loc_model_inters, tmp_loc_model_inters);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
      tmp_loc_model_inters = NULL;
      }

    save_pathway_trim = _pathway_trim;
    save_pathway_orient = _pathway_orient;
    _pathway_trim = 0;
    _pathway_orient = 0;

    EMintersect_surfaces (&msg_loc, NULL, &env->md_env, 0, NULL, NULL,
     EMS_SFINT_SKIPSFINT | EMS_SFINT_SKIPFIXING | EMS_SFINT_CHTTRACETOL,
     NULL, NULL, NULL, NULL, NULL, &loc_fillet_inters, NULL, &fsftrc,
     NULL, NULL, NULL, NULL);

    _pathway_trim = save_pathway_trim;
    _pathway_orient = save_pathway_orient;

    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (!fsftrc.num_grps || fsftrc.num_subgrps_grp[FIRST] != 1, *msg, 
     EMS_E_InvalidCase, ret_end);

    p_intobj = fsftrc.elems[FIRST][FIRST];
    p_intobjs[FIRST] = p_intobj;
    while (p_intobj->next)
      p_intobj = p_intobj->next;
    p_intobjs[LAST] = p_intobj;

    EMsfinttrace_free (&msg_loc, fsftrc.num_grps, fsftrc.num_subgrps_grp,
     fsftrc.num_elems_subgrp, fsftrc.elems, fsftrc.subgrp_rev, fsftrc.elem_rev,
     fsftrc.grp_closed, fsftrc.subgrp_closed);

    uvtol = edge_infos[i]->fill_surf_tol;
    for (inx=FIRST; inx<=SECOND; inx++)
      {
      EFmaptobnd (&msg_loc, NULL, edge_infos[i]->fill_surf, 2 * chttol,
       &p_intobjs[inx]->this_xyzintobj, &p_intobjs[inx]->this_uvintobj);

      EMgetendpts_uv (&msg_loc, &p_intobjs[inx]->this_uvintobj, FALSE, 1,
       uvpts[START], uvpts[STOP]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      
      for (k=START; k<=STOP; k++)
        for (uval=LO_U; uval<=HI_U; uval++)
          if (fabs (uvpts[k][U] - (IGRdouble) uval) < uvtol)
            intatedge[i][uval] = TRUE;
      }

    EMmergeinters (&msg_loc, &fillet_model_inters, loc_fillet_inters);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
    loc_fillet_inters = NULL;

    EMmergeinters (&msg_loc, &model_fillet_inters, loc_model_inters);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
    loc_model_inters = NULL;
    }

  /*
   * Check if each fillet has had atleast one intersection curve terminating
   * at it's U=0 and U=1 edge respectively.
   */

  Process_all_intersections:
  for (i=0; i<num_edges; i++)
    {
    if (!edge_infos[i])
      continue;
    EMerr_hndlr (!(intatedge[i][LO_U] && intatedge[i][HI_U]), *msg,
     EMS_E_Fail, ret_end);
    }

  /*
   * Merge all the piece-wise generated fillet intersections and the model
   * intersections into the incoming "fillet_inters" and "model_inters".
   * After this point the incoming intersection list has been changed.
   * Therefore, no solution can be re-started afresh.
   */

  no_blend_solution = TRUE;

  EMmergeinters (&msg_loc, fillet_inters, fillet_fillet_inters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
  fillet_fillet_inters = NULL;

  EMmergeinters (&msg_loc, fillet_inters, fillet_model_inters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
  fillet_model_inters = NULL;

  EMmergeinters (&msg_loc, model_inters, model_fillet_inters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
  model_fillet_inters = NULL;


  /*
   * None of the intersections on the fillets, obtained during the processing
   * of the vertices must cross each other. If at all, these intersection
   * make contact with each other, it is at their ends. To ensure this,
   * intersections are intersected with each other and split up at the
   * intersection points. Some cases of intersection-interaction are special
   * and are handled as such.
   *
   * Procedure:
   * a) Only those sets of intersections are considered which have been
   *    generated above.
   * b) For each intersection:
   *    Check for an intersection with the rest of the intersections
   *    on this surface produced while processing this vertex.
   *    On finding intersections, split the intersection at the intersection
   *    point.
   *    NB: A pair whose counterpart intersections lie on the model, cannot
   *    intersect each other except at the end-points. Therefore, these
   *    are rejected as candidates for splitting against each other. Also,
   *    a pair formed by two pieces of intersections which have resulted
   *    from the same splitting operation need not be intersected with
   *    each other. We assume that an intersection curve intersects another
   *    only at one point. A list is maintained of the sets of resulting split
   *    intersections and this list along with the fact that the resulting
   *    intersections from a split are linked by the noconnect-property
   *    is used to check if a prospective pair of intersections should be
   *    tried for intersection at all.
   */
  
  buff_size = BUFF_SIZE;
  int_already = (intobj_end4 *) alloca (buff_size * sizeof (intobj_end4));
  EMerr_hndlr (!int_already, *msg, EMS_E_NoStackMemory, ret_end);
  num_int_already = 0;

  p_splitinfos[FIRST] = NULL;
  p_splitinfos[SECOND] = NULL;

  loc_fillet_inters = *fillet_inters;
  while (loc_fillet_inters)
    {
    this_fillet = loc_fillet_inters->this_obj.objid;
    check_fillet_or_surf (&msg_loc, num_edges, edge_infos, 0, NULL,
     this_fillet, &this_fill_info_inx, NULL, &is_fillet);
    if (msg_loc == EMS_I_Found && is_fillet)
      {
      uvtol = edge_infos[this_fill_info_inx]->fill_surf_tol;

      p_intobjs[FIRST] = loc_fillet_inters->cvs;
      while (p_intobjs[FIRST])
        {
        if (! (p_intobjs[FIRST]->props & EMSintobj_tmpmarked))
          goto First_Next;

        p_intobjs[SECOND] = p_intobjs[FIRST]->next;
        while (p_intobjs[SECOND])
          {
          if (!(p_intobjs[SECOND]->props & EMSintobj_tmpmarked) ||
              other_ints_on_model (p_intobjs, *model_inters) ||
              int_already_done (num_int_already, int_already, p_intobjs))
            goto Second_Next;

          is_inters = FALSE;
          p_splitinfos[FIRST] = NULL;
          p_splitinfos[SECOND] = NULL;

          /*
           * Special cases might arise when some fore-knowledge of the
           * intersection exists. The fillet surface being processed currently
           * is f1:
           * a) This is when a fillet-surface intersection (f1-s),
           *    interacts with a fillet-fillet (f1-f2) intersection, wherein
           *    the surface - s, is one of the surfaces for the fillet f2.
           *    An intersection between such data will be a tangential
           *    end-point and it is determined by projection. So check if the
           *    end-point of (f1-f2) lies on (f1-s). If it does, there is
           *    an end-point intersection, else there isn't any intersection
           *    at all.
           * b) This is the case where three intersection curves meet at a
           *    point in xyz-space. The three curves that potentially meet
           *    are (f1-f2), (f1-s) and (f2-s), wherein, the surface - s is
           *    a surface at the vertex but is not a defining surface for
           *    either f1 or f2. Also f1 and f2 must have a common defining
           *    surface. This is a case of a triple surface intersection.
           *    The situation would be as follows - We have
           *    a fillet-fillet (f1-f2) intersection that has already been
           *    split by an intersection point P found on the other fillet
           *    surface - f2. The intersection point P was the result of an
           *    intersection between (f2-f1) and (f2-s). Now we are
           *    intersecting a resultant piece of (f1-f2) with the
           *    intersection curve (f1-s). So check if the end-point
           *    of (f1-f2) lies on (f1-s). If it does, there is an end-point
           *    intersection, else there isn't any intersection at all.
           * c) This is the case where three intersection curves meet at a
           *    point in xyz-space. The three curves that potentially meet
           *    are (f1-f2), (f1-f3) and (f2-f3), wherein, the three surfaces -
           *    f1, f2 and f3 are on fillets on consecutive edges at the vtx.
           *    This is a case of a triple surface intersection. The situation
           *    would be as follows -  We have a fillet-fillet (f1-f2)
           *    intersection that has already been split by an intersection 
           *    point P found on the other fillet surface - f2. The
           *    intersection point P was the result of an intersection between
           *    (f2-f1) and (f2-f3). Now we are intersecting a resultant piece
           *    of (f1-f2) with the intersection curve (f1-s). So check if
           *    the end-point of (f1-f2) lies on (f1-f3). If it does, there
           *    is an end-point intersection, else there isn't any
           *    intersection at all.
           * An assumption, being made in these special case intersections
           * is that the curves intersect only in one place. Care needs to be
           * taken since the order in which these intersections occur in the
           * list could be random. In the non-special case call the brute
           * force method.
           */

          special_intersection = FALSE;
          other_srf = NULL_OBJID;
          if (p_intobj = p_intobjs[FIRST]->other_intobj_node)
            {
            srfid = p_intobj->this_obj_node->this_obj.objid;
            check_fillet_or_surf (&msg_loc, 
             num_edges, edge_infos, num_vtx_sfs, vtx_sfs,
             srfid, &inx, &vtx_sf_inx, &is_fillet1);
            if (msg_loc == EMS_I_Found)
              {
              if (p_intobj = p_intobjs[SECOND]->other_intobj_node)
                {           
                if (is_fillet1)
                  {
                  other_fillet = srfid;
                  other_fill_info_inx = inx;
                  }
                else
                  {
                  other_srf = srfid;
                  other_srf_info_inx = inx;
                  other_srf_not_fill_sf = vtx_sf_inx;
                  }
                srfid = p_intobj->this_obj_node->this_obj.objid;
                check_fillet_or_surf (&msg_loc, num_edges, edge_infos, 
                 num_vtx_sfs, vtx_sfs, srfid, &inx, &vtx_sf_inx, &is_fillet2);
                if (msg_loc == EMS_I_Found)
                  {
                  if (is_fillet1 ^ is_fillet2)
                    {
                    if (is_fillet2)
                      {
                      other_fillet = srfid;
                      other_fill_info_inx = inx;
                      }
                    else
                      {
                      other_srf = srfid;
                      other_srf_info_inx = inx;
                      other_srf_not_fill_sf = vtx_sf_inx;
                      }
                    inx = is_fillet2 ? FIRST : SECOND;

                    /*
                     * Check for the special case (a)
                     */

                    if (!other_srf_not_fill_sf &&
                        (edge_infos[other_fill_info_inx]->surf_id == 
                          other_srf ||
                         edge_infos[other_fill_info_inx]->com_surf_id == 
                          other_srf))
                      {
                      /*
                       * Establishes surface - s, as one of the defining
                       * of the other fillet.
                       */

                      special_intersection = TRUE;
                      }

                    /*
                     * Check for the special case (b)
                     */

                    else if (other_srf_not_fill_sf ||
                             (edge_infos[other_fill_info_inx]->surf_id != 
                               other_srf &&
                              edge_infos[other_fill_info_inx]->com_surf_id != 
                               other_srf))
                      {
                      /*
                       * Find an intersection curve on f2 which is a result
                       * of intersection with s, ie, find an f2-s and try to
                       * establish that this intersection curve - f2-s,
                       * is a result of a split with f2-f1 (which is the
                       * counterpart of the current f1-f2 being looked at).
                       */

                      counterpart_intobj = p_intobjs[!inx]->other_intobj_node;
                      p_intobj = counterpart_intobj->this_obj_node->cvs;
                      while (p_intobj)
                        {
                        if (p_intobj->other_intobj_node->
                             this_obj_node->this_obj.objid == other_srf)
                          {
                          split_intobjs[FIRST][FIRST] = counterpart_intobj;
                          split_intobjs[FIRST][SECOND] = p_intobj;
                          if (int_already_done (num_int_already, int_already,
                               split_intobjs[FIRST]))
                            {
                            special_intersection = TRUE;
                            break;
                            }
                          }
                        p_intobj = p_intobj->next;
                        }
                      }
                    }

                  /*
                   * Check for special case (c):
                   */

                  else if (is_fillet1 && is_fillet2 &&
                           adjacent_3 (num_edges, this_fill_info_inx,
                            other_fill_info_inx, inx))
                    {
                    /*
                     * At this point, we are not sure whether to assign
                     * other_fillet as f2 and other_other_fillet as f3
                     * or vice-versa. We will start by assuming other_fillet
                     * is f2 and if does not work out, flip them around.
                     * Below, assume that "inx" is the index for intobj
                     * related to f3. So, "!inx" is the index related to
                     * f2. Thus, other_other_fillet is the fillet associated
                     * with FIRST and other_fillet is associated with SECOND.
                     */

                    other_other_fillet = other_fillet;
                    other_fillet = srfid;

                    for (inx=FIRST; inx<=SECOND; inx++)
                      {
                      /*
                       * Find an intersection curve on f2 which is a result
                       * of intersection with f3, ie, find an f2-f3 and
                       * establish that this intersection curve - f2-f3,
                       * is a result of a split with f2-f1 (which is the
                       * counterpart of the current f1-f2 being looked at).
                       */

                      counterpart_intobj = p_intobjs[!inx]->other_intobj_node;
                      p_intobj = counterpart_intobj->this_obj_node->cvs;
                      while (p_intobj)
                        {
                        if (p_intobj->other_intobj_node->this_obj_node->
                            this_obj.objid == other_other_fillet)
                          {
                          split_intobjs[FIRST][FIRST] = counterpart_intobj;
                          split_intobjs[FIRST][SECOND] = p_intobj;
                          if (int_already_done (num_int_already, int_already,
                               split_intobjs[FIRST]))
                            {
                            special_intersection = TRUE;
                            break;
                            }
                          }
                        p_intobj = p_intobj->next;
                        }

                      /*
                       * If this is not a special intersection case, maybe
                       * the reason is that f2 and f3 are swapped. Swap
                       * them around for the second try. 
                       */

                      if (!special_intersection)
                        other_other_fillet = other_fillet;
                      else
                        break;
                      }
                    }
                  }
                }
              }
            }

          if (special_intersection)
            {
            get_special_intersection_points (&msg_loc, mdenv_info,
             uvtol, p_intobjs[inx], p_intobjs[!inx], 
             &is_inters, &p_splitinfos[inx], &p_splitinfos[!inx]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            }
          else
            {
            get_intersection_points (&msg_loc, uvtol,
             &p_intobjs[FIRST]->this_uvintobj, 
             &p_intobjs[SECOND]->this_uvintobj, 
             p_intobjs[FIRST]->reversed, p_intobjs[SECOND]->reversed,
             &is_inters,
             &p_splitinfos[FIRST], &p_splitinfos[SECOND]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            }

          if (is_inters)
            {
            if (num_int_already+2 > buff_size)
              {
              tmp_already = (intobj_end4 *) alloca ((buff_size+BUFF_SIZE)*
                             sizeof (intobj_end4));
              EMerr_hndlr (!tmp_already, *msg, EMS_E_NoStackMemory, ret_end);
              OM_BLOCK_MOVE (int_already, tmp_already,
               buff_size * sizeof (intobj_end4));
              int_already = tmp_already;
              buff_size += BUFF_SIZE;
              }

            for (i=FIRST; i<=SECOND; i++)
              {
              EMsplit_sf_intobj_uv (&msg_loc, EMSintobj_split_noconnectuv,
               mdenv_info, p_intobjs[i], p_splitinfos[i], NULL, 
               split_intobjs);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
              if (msg_loc == EMS_I_Useless)
                {
                split = FALSE;
                at_start = p_splitinfos[i]->props & EMS_PYPT_ATSTART ?
                            TRUE : FALSE;
                }
              else
                split = TRUE;


              if (split)
                {
                chg_int_new_stop (num_int_already, int_already,
                 split_intobjs[THIS][START], split_intobjs[THIS][STOP]);
                chg_int_new_stop (num_int_already, int_already,
                 split_intobjs[OTHER][START], split_intobjs[OTHER][STOP]);
                }

              inx = i * 2;
              for (j=START; j<=STOP; j++)
                {
                int_already[num_int_already][inx+j].intobj = 
                 split_intobjs[THIS][j];
                int_already[num_int_already][inx+j].geom_start = 
                 split ? (j == START ? FALSE : TRUE) : at_start;

                int_already[num_int_already+1][inx+j].intobj = 
                 split_intobjs[OTHER][j];
                int_already[num_int_already+1][inx+j].geom_start = 
                 split ? (j == START ? FALSE : TRUE) : at_start;
                }
              }
            num_int_already += 2;
            }
         /* fix for mlk */
            for(ii =  FIRST; ii<= SECOND;ii++)
              if(p_splitinfos[ii])
                {
                EMpypoint_free (p_splitinfos[ii], MAXINT);
                p_splitinfos[ii] = NULL;
                }
            

          Second_Next:
          p_intobjs[SECOND] = p_intobjs[SECOND]->next;
          }
        First_Next:
        p_intobjs[FIRST] = p_intobjs[FIRST]->next;
        }
      }
    loc_fillet_inters = loc_fillet_inters->next;
    }

  /*
   * Unmark all the intersections in the intersection
   * lists
   */

  for (inters=*fillet_inters, i=FIRST; i<=SECOND; inters=*model_inters, i++)
    while (inters)
      {
      intobj = inters->cvs;
      while (intobj)
        {
        intobj->props &= ~EMSintobj_tmpmarked;
        intobj = intobj->next;
        }
      inters = inters->next;
      }    

ret_end:
  for(ii =  FIRST; ii<= SECOND;ii++)
     if(p_splitinfos[ii])
       {
       EMpypoint_free (p_splitinfos[ii], MAXINT);
       p_splitinfos[ii] = NULL;
       }
  EMinters_data_free (&msg_loc, fillet_fillet_inters, MAXINT, NULL,
   EMsfintedpar_free);
  EMinters_free (fillet_fillet_inters, MAXINT);

  EMinters_data_free (&msg_loc, fillet_model_inters, MAXINT, NULL,
   EMsfintedpar_free);
  EMinters_free (fillet_model_inters, MAXINT);

  EMinters_data_free (&msg_loc, model_fillet_inters, MAXINT, NULL,
   EMsfintedpar_free);
  EMinters_free (model_fillet_inters, MAXINT);

  EMinters_free (loc_fillet_inters, MAXINT);
  EMinters_free (tmp_loc_fillet_inters, MAXINT);

  EMinters_free (loc_model_inters, MAXINT);
  EMinters_free (tmp_loc_model_inters, MAXINT);

  if (vtx_sfs)
    om$dealloc (ptr = vtx_sfs);

  if (xyzcv.poles)
    om$dealloc (ptr = xyzcv.poles);
  if (xyzcv.knots)
    om$dealloc (ptr = xyzcv.knots);
  if (xyzcv.weights)
    om$dealloc (ptr = xyzcv.weights);

  if (EMSerror (*msg) && !no_blend_solution && !sngpch_solution)
    stat_OM = EMget_n_sided_blend (msg, options, construct_list,
                vertex_info, fillet_patch, fillet_inters, model_inters);

  if (sngpch_solution)
    stat_OM = EMsingle_patch (msg, options, construct_list,
                vertex_info, fillet_patch, fillet_inters, model_inters);

  EMWRAPUP (*msg, stat_OM, "EMgeneral_trim");
  return (stat_OM);
}




static void get_special_intersection_points (msg, mdenv_info, uvtol,
                                             intobj1, intobj2, 
                                             is_inters,
                                             splitinfo1, splitinfo2)
IGRlong *msg;
struct GRmdenv_info *mdenv_info;
IGRdouble uvtol;
struct EMSintobj *intobj1, *intobj2;
IGRboolean *is_inters;
struct EMSpypoint **splitinfo1, **splitinfo2;
{
  IGRint endinx;
  IGRlong msg_loc, stat_OM;
  IGRdouble xyztol, chttol, lentol, mindists[2], mindist;
  IGRpoint fint_endpts[2], dumpt, uvpt;
  struct EMSintobj *p_intobj;
  struct EMSpypoint sint_projpts[2], *p_pypt;
  struct EMSpypoint *EMpypoint_malloc();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *is_inters = FALSE;
  *splitinfo1 = *splitinfo2 = NULL;

  EMgetendpts_xyz (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
   &intobj2->this_xyzintobj, intobj2->reversed, 1, 
   fint_endpts[START], fint_endpts[STOP]);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  sint_projpts[START].next = &sint_projpts[STOP];
  sint_projpts[STOP].next = NULL;
  EMprojectpt (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
   &intobj1->this_xyzintobj, 2, fint_endpts, chttol, sint_projpts, mindists);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  xyztol = chttol * 10.0;
  mindist = mindists[START];
  endinx = START;
  if (mindists[STOP] < mindist)
    {
    mindist = mindists[STOP];
    endinx = STOP;
    }
  if (mindist < xyztol)
    {
    if (sint_projpts[endinx].props & EMS_PYPT_ATMIDDLE)
      {
      EMgetendpts_uv (&msg_loc, &intobj2->this_uvintobj, intobj2->reversed, 1, 
       endinx == START ? uvpt : dumpt, endinx == START ? dumpt : uvpt);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      uvpt[W] = 0.0;

      BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
      uvtol *= chttol / lentol;

      p_pypt = sint_projpts;
      EMprojectpt (&msg_loc, NULL, NULL, &intobj1->this_uvintobj, 1, uvpt,
       uvtol, p_pypt, &mindist);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      if (p_pypt->props & EMS_PYPT_ATMIDDLE)
        {
        *msg = EMS_I_Found;

        *splitinfo1 = EMpypoint_malloc (&msg_loc, 1);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

        /**     *(*splitinfo1) = *p_pypt;  **/

        /* Fix for TR#119526369 */
          OM_BLOCK_MOVE(p_pypt->point, (*splitinfo1)->point, sizeof(IGRpoint));
          (*splitinfo1)->param = p_pypt->param;
          (*splitinfo1)->span_inx =  p_pypt->span_inx;
          (*splitinfo1)->props = p_pypt->props;
          (*splitinfo1)->info = p_pypt->info;
          (*splitinfo1)->next = NULL;

/* fix for mlk */
        (*splitinfo1)->props |=  EMS_PYPT_MALLOCED;

        *splitinfo2 = EMpypoint_malloc (&msg_loc, 1);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        (*splitinfo2)->props = EMS_PYPT_ATEND | EMS_PYPT_MALLOCED;
        if ((endinx == START) ^ (intobj2->reversed))
          (*splitinfo2)->props |= EMS_PYPT_ATSTART;
        else
          (*splitinfo2)->props |= EMS_PYPT_ATSTOP;

        EMend_modify_data (&msg_loc, mdenv_info, &intobj2->this_uvintobj,
         intobj2->reversed ? !(endinx == START) : (endinx == START),
         p_pypt->point);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        if (p_intobj = get_sibling (intobj2, endinx))
          {
	  EMend_modify_data (&msg_loc, mdenv_info, &p_intobj->this_uvintobj, 
	   p_intobj->reversed ? (endinx == START) : !(endinx == START), 
	   p_pypt->point);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          }

        *is_inters = TRUE;
        }
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "get_spec_int_pts");
  return;
}


#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
static void get_intersection_points (msg, uvtol, intdata1, intdata2,
                                     reversed1, reversed2,
                                     is_inters, intinfo1, intinfo2)
IGRlong *msg;
IGRdouble uvtol;
struct EMSdataselect *intdata1, *intdata2;
IGRboolean reversed1, reversed2;
IGRboolean *is_inters;
struct EMSpypoint **intinfo1, **intinfo2;
{
  IGRushort data1_props, options;
  IGRint num_inters;
  IGRlong msg_loc, stat_func;
  struct EMSpypoint *p_pypt;
  struct EMSsfintedpar *p_epar;
  struct EMSpypoint *EMpypoint_malloc();
  void EMsfintedpar_free();

  *msg = EMS_S_Success;
  stat_func = TRUE;

  *is_inters = FALSE;

  p_epar = NULL;

  /*
   * Only data in the form of 2D-polyline format is processed
   * in this function
   */

  EMerr_hndlr (intdata1->datatype != EMSdata_poly2d || 
   intdata2->datatype != EMSdata_poly2d, *msg, EMS_E_InvalidArg, ret_end);

  data1_props = EMED_OPEN;
  if (reversed1)
    data1_props |= EMED_REVERSED;
  options = EMS_INTER_STOPPT | EMS_INTER_STARTPT | 
             EMS_INTER_CUTTING | EMS_INTER_ONEOFTWO;
  num_inters = 0;
  EM2dpycutint (&msg_loc, 
   intdata1->data.poly->num_points, intdata1->data.poly->points,
   data1_props, NULL,
   intdata2->data.poly->num_points, intdata2->data.poly->points,
   NULL, options, uvtol, NULL, NULL, NULL_OBJID, NULL,
   &num_inters, &p_epar, intinfo2);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if ( num_inters )
    {
    /* 
     * The intersection info returned for the first data is in
     * EMSsfintedpar format. Convert it into EMSpypoint format for
     * output. If there are more than one intersections, ignore them
     * taking only the first one into account. It is considered highly
     * unlikely that more than one intersection will result.
     */
       
    *is_inters = TRUE;

    p_pypt = *intinfo1 = EMpypoint_malloc (&msg_loc, 1);
    EMerr_hndlr (!p_pypt, *msg, EMS_E_NoDynamicMemory, ret_end);
    OM_BLOCK_MOVE (p_epar->point, p_pypt->point, 2 * sizeof (IGRdouble));
    p_pypt->span_inx = p_epar->edgepar.span_inx;
    p_pypt->param = p_epar->edgepar.param;
    if (p_epar->intloc == EMScvint_middle)
      p_pypt->props = EMS_PYPT_ATMIDDLE;
    else
      {
      p_pypt->props = EMS_PYPT_ATEND;
      if (p_epar->intloc == EMScvint_rtend)
        p_pypt->props |= EMS_PYPT_ATSTOP;
      else
        p_pypt->props |= EMS_PYPT_ATSTART;
      }
    }

ret_end:
  if (p_epar)
    EMsfintedpar_free (p_epar, MAXINT);

  EMWRAPUP (*msg, stat_func, "get_int_pts");
  return;
}


static void check_fillet_or_surf (msg, num_edges, ed_rnd_info, 
                                  num_vtx_sfs, vtx_sfs,
                                  srfobj, info_inx, vtx_sf_inx, is_fillet)
IGRlong *msg;
IGRint num_edges;
struct EMSedge_rnd_info **ed_rnd_info;
IGRint num_vtx_sfs;
GRobjid *vtx_sfs;
GRobjid srfobj;
IGRint *info_inx;
IGRboolean *vtx_sf_inx;
IGRboolean *is_fillet;
{
  IGRint inx;

  *msg = EMS_S_Success;

  for (inx=0; inx<num_edges; inx++)
    {
    if (!ed_rnd_info[inx])
      continue;

    if (ed_rnd_info[inx]->surf_id == srfobj ||
        ed_rnd_info[inx]->com_surf_id == srfobj)
      {
      *is_fillet = FALSE;
      *info_inx = inx;
      if (vtx_sf_inx)
        *vtx_sf_inx = FALSE;
      *msg = EMS_I_Found;
      break;
      }
    else if (ed_rnd_info[inx]->fill_id == srfobj)
      {
      *is_fillet = TRUE;
      *info_inx = inx;
      if (vtx_sf_inx)
        *vtx_sf_inx = FALSE;
      *msg = EMS_I_Found;
      break;
      }
    }

  if (*msg != EMS_I_Found && num_vtx_sfs)
    {
    for (inx=0; inx<num_vtx_sfs; inx++)
      if (vtx_sfs[inx] == srfobj)
        {
        *is_fillet = FALSE;
        *info_inx = inx;
        if (vtx_sf_inx)
          *vtx_sf_inx = TRUE;
        *msg = EMS_I_Found;
        break;
        }
    }

  return;
}

static IGRboolean other_ints_on_model (intobj_pair, model_inters)
struct EMSintobj *intobj_pair[2];
struct EMSinters *model_inters;
{
  IGRint i, count;
  struct EMSinters *p_inters, *test_inters;
  struct EMSintobj *p_intobj;

  count = 0;
  for (i=FIRST; i<=SECOND; i++)
    {
    p_intobj = intobj_pair[i]->other_intobj_node;
    if (!p_intobj)
      break;

    test_inters = p_intobj->this_obj_node;
    p_inters = model_inters;
    while (p_inters)
      {
      if (p_inters == test_inters)
        {
        count++;
        break;
        }
      p_inters = p_inters->next;
      }
    }

  return (count == 2);
}

#define IS_IN_SET	1
#define IS_CHECKED	2

static IGRboolean int_already_done (num_int_already, int_already, intobj_pair)
IGRint num_int_already;
intobj_end4 *int_already;
struct EMSintobj *intobj_pair[2];
{
  IGRboolean found, stat_func;
  IGRshort *trans_set;
  IGRint i, j, k;
  struct EMSintobj *first_obj, *second_obj;
  struct intobj_end *p_intend;

  /*
   * Create and init an array that holds information on which records are
   * part of the transitive closure set for one of the objects in
   * intobj_pair.
   */

  trans_set = (IGRboolean *) alloca (num_int_already * sizeof (IGRshort));
  for (i=0; i<num_int_already; i++)
    trans_set[i] = NULL;

  /*
   * Find all the records that contain the first element. If none found
   * then return FALSE.
   */

  first_obj = intobj_pair[FIRST];
  found = FALSE;
  for (i=0; i<num_int_already; i++)
    if (int_in_record (int_already[i], first_obj))
      {
      trans_set[i] = IS_IN_SET;
      found = TRUE;
      }
  EMerr_hndlr (!found, stat_func, FALSE, ret_end);

  /*
   * The elements in a given record are considered to have end-point
   * continuity, since the elements are created by splitting at the
   * common point. Besides the above record(s) there may be other's that
   * have elements that are end-point continuous at this point. All these
   * records put together imply a transitive closure set. Find this
   * set.
   */

  while (found)
    {
    found = FALSE;
    for (i=0; i<num_int_already; i++)
      {
      if (trans_set[i] == IS_IN_SET)
        {
        for (j=0; j<4; j++)
          {
          p_intend = &int_already[i][j];
          for (k=0; k<num_int_already; k++)
            if (!trans_set[k] && 
                (endint_in_record (int_already[k], 
                  p_intend->intobj, p_intend->geom_start) ||
                 endint_in_record (int_already[k], 
                  p_intend->intobj->other_intobj_node, p_intend->geom_start)))
              {
              trans_set[k] = IS_IN_SET;
              found = TRUE;
              }
          }
        trans_set[i] = IS_CHECKED;
        }
      }
    }

  /*
   * Check if the "second" object belongs to this transitive closure
   * set of the "first". If so, then return TRUE, else FALSE.
   */

  second_obj = intobj_pair[SECOND];
  found = FALSE;
  for (i=0; i<num_int_already; i++)
    if (trans_set[i] && int_in_record (int_already[i], second_obj))
      {
      found = TRUE;
      break;
      }

ret_end:
  return (found);
}


static IGRboolean int_in_record (int_record, intobj)
intobj_end4 int_record;
struct EMSintobj *intobj;
{
  IGRboolean found;
  IGRint i;

  found = FALSE;
  for (i=0; i<4; i++)
    if (int_record[i].intobj == intobj)
      {
      found = TRUE;
      break;
      }
  
  return (found);
}

static IGRboolean endint_in_record (int_record, intobj, geom_start)
intobj_end4 int_record;
struct EMSintobj *intobj;
IGRboolean geom_start;
{
  IGRboolean found;
  IGRint i;

  found = FALSE;
  for (i=0; i<4; i++)
    if (int_record[i].intobj == intobj &&
        int_record[i].geom_start == geom_start)
      {
      found = TRUE;
      break;
      }
  
  return (found);
}

static void chg_int_new_stop (num_int_already, int_already, old_int, new_int)
IGRint num_int_already;
intobj_end4 *int_already;
struct EMSintobj *old_int, *new_int;
{
  IGRint i, j;

  for (i=0; i<num_int_already; i++)
    for (j=0; j<4; j++)
      if (int_already[i][j].intobj == old_int &&
          !int_already[i][j].geom_start)
        int_already[i][j].intobj = new_int;

  return;
}



static struct EMSintobj *get_sibling (intobj, which_end)
struct EMSintobj *intobj;
IGRboolean which_end;
{
  if (which_end == START &&
      intobj->bwd &&
      (intobj->props & EMSintobj_bwd_noconnectuv))
    return (intobj->bwd);
  else if (which_end == STOP &&
           intobj->fwd &&
           (intobj->props & EMSintobj_fwd_noconnectuv))
    return (intobj->fwd);
  else
    return (NULL);
}



static IGRboolean adjacent_3 (num, inx1, inx2, inx3)
IGRint num, inx1, inx2, inx3;
{
  IGRint count;
 
  count = 0;
  if (EMis_circadj (num, inx1, inx2))
    count++;
  if (EMis_circadj (num, inx2, inx3))
    count++;
  if (EMis_circadj (num, inx3, inx1))
    count++;
  return (count >= 2);
}  


static void merge_adjacent_intobjs(msg, mattyp, mat, num_intobjs,
                                   intobjs, inters1, inters2)
IGRlong *msg;
IGRshort mattyp;
IGRmatrix mat;
IGRint num_intobjs;
struct EMSintobj **intobjs;
struct EMSinters *inters1, *inters2;
{
  IGRint inx=0, knt=0;
  IGRlong msg_loc;
  IGRdouble chttol, uvtol;
  GRobjid sfid;
  GRspacenum osn;
  struct IGRbsp_surface *p_bspsf=NULL;

  struct EMSintobj *p_out_intobj=NULL, *p_tmp_intobj=NULL, *p_next_intobj=NULL;
  struct EMSsfintedpar *p_par=NULL, *p_tmppar=NULL;

  extern struct EMSintobj *EMdelintobj();
  extern struct EMSintobj *EMintobj_malloc();
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern void EMmergeintobjs();
  extern void EMgetincinfo();
  extern void EMaddintobj();

  msg_loc = EMS_S_Success;
  chttol = pwActiveXYZChtTol();

  p_out_intobj = EMintobj_malloc(&msg_loc, 1);
  EMerr_hndlr(!p_out_intobj || !(1 & msg_loc), *msg,
              EMS_E_NoDynamicMemory, wrapup);

  p_out_intobj->other_intobj_node = EMintobj_malloc(&msg_loc, 1);
  EMerr_hndlr(!(p_out_intobj->other_intobj_node) || !(1 & msg_loc), *msg,
              EMS_E_NoDynamicMemory, wrapup);

  p_out_intobj->other_intobj_node->other_intobj_node = p_out_intobj;

  EMmergeintobjs (&msg_loc, mattyp, mat, num_intobjs, intobjs, p_out_intobj);
  EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

  for(knt=0; knt<2; knt++)
  {
    p_bspsf = NULL;
    p_tmp_intobj = knt == 0 ? p_out_intobj : p_out_intobj->other_intobj_node;
    sfid = knt==0 ? inters1->this_obj.objid : inters2->this_obj.objid;
    osn = knt==0 ? inters1->this_obj.osnum : inters2->this_obj.osnum;
      
    p_tmppar = EMsfintedpar_malloc(&msg_loc, 2);
    EMerr_hndlr( !(1 & msg_loc) || !p_tmppar || !p_tmppar->next,
                *msg, EMS_E_NoDynamicMemory, wrapup);

    PW_GetSfBspsfStack(sfid, osn, mattyp, mat, p_bspsf);
    EMerr_hndlr (!p_bspsf, *msg, EMS_E_Fail, wrapup);

    uvtol = pwGetParTolSf(p_bspsf, chttol);

    for(inx=0; inx<2; inx++)
    {
      p_par = inx==0 ? p_tmppar : p_tmppar->next;

      EMgetincinfo (&msg_loc, osn, &(p_tmp_intobj->this_uvintobj),
                    (inx==0 ? FALSE : TRUE), NULL, &mattyp, mat, sfid,
                    chttol, uvtol, p_par);
      EMerr_hndlr (!(1&msg_loc), *msg, EMS_E_Fail, wrapup);
    }

    p_tmp_intobj->more_info = (IGRchar *)p_tmppar;
    p_tmppar = NULL;
  }

  for(knt=0; knt<num_intobjs; knt++)
  {
    p_tmp_intobj = intobjs[knt];

    EMdelintobj(&msg_loc, p_tmp_intobj);
    EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);
  }

  EMaddintobj(&msg_loc, inters1, TRUE, p_out_intobj);
  EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

  EMaddintobj(&msg_loc, inters2, TRUE, p_out_intobj->other_intobj_node);
  EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

wrapup:
  return;
}

static IGRboolean IsNeutral
(
  enum EMSedge_config edge_config
)
{
  if(edge_config == EMSedge_neutral        ||
     edge_config == EMSedge_neutral_convex ||
     edge_config == EMSedge_neutral_concave )
    return(TRUE);

  return(FALSE);
}


end implementation EMSsfrndbool;
