/*
  DESCRIPTION

    This function classifies all the vertex configurations in a
    rounding operation. An option to always use the general-blend
    solution whenever possible is supported - EMS_RND_BLENDALL.

  HISTORY

    KNAP : 12/10/93 : Creation. Code has been added to classify open 
                      vertices. The rest of the code is a re-write of a
                      portion of code from EMround().
    SS   : 28/10/93 : Made the code exactly map to a slightly modified
                      version of KNAP's classification chart.
*/

class implementation EMSsfrndbool;

%safe
#include <math.h>
%endsafe
#include "msmacros.h"
#include "OMmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "EMSopt.h"
#include "ECmsg.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "emsedgedef.h"

#define FIRST  0
#define SECOND 1

extern IGRboolean WANT_POST220_BEHAVIOR;
from EMSedge import EMget_props;

#argsused

enum EMSvertex_config EMget_vtx_config (options, vtx_rnd_info, os)
IGRushort options;
struct EMSvtx_rnd_info *vtx_rnd_info;
GRspacenum os;
{
  IGRboolean no_variable_radii, homogenous_vtx, global_homogenous_vtx;
  IGRboolean same_radii_atvtx, open_vtx, at_stop;
  IGRushort loc_opts, ed_props;
  IGRshort mattyp;
  IGRuint count;
  IGRint i, inx, firstprev_i, firstnext_i, firstrnd_i, other_non_neutral_i;
  IGRint num_vtx_edges, num_rounded_eds, num_neutral_eds, num_non_neutral_eds;
  IGRint *rounded_eds_inx, *neutral_eds_inx, *non_neutral_eds_inx, edge_inx;
  IGRlong msg_loc, stat;
  IGRdouble bastol, this_radius, radius, *radofcrv;
  IGRmatrix mat;
  struct EMSedge_rnd_info **edge_infos, *edge_info;
  enum EMSedge_config edge_config, *edge_configs;
  enum EMSvertex_config vtx_config;
  OM_S_CHANSELECT chan_to_common;
  extern IGRdouble EMedradofcrv();

  /*
   * Initialize the output vertex-config to unknown
   * classification.
   */

  vtx_config = EMSvertex_not_implemented;

  /*
   * If the option to use general blend whenever possible, return
   * this as the config. Today, every possible type of situation is
   * theoretically supported by the general-blend.
   */

  if (options & EMS_RND_BLENDALL)
    {
    vtx_config = EMSvertex_general_blend;
    goto ret_end;
    }

  /*
   * A cyclic order to the edges at this vertex is already defined. Obtain
   * the indices of the edges that are rounded and of those that are neutral
   * and of those that are non-neutral. Only those that are non-neutral
   * will be rounded.
   */

  num_vtx_edges = vtx_rnd_info->num_edges;
  edge_configs = vtx_rnd_info->edge_configs;
  edge_infos = vtx_rnd_info->edge_infos;

  num_rounded_eds = 0;
  rounded_eds_inx = (IGRint *) alloca (num_vtx_edges * sizeof (IGRint));
  for (i=0; i<num_vtx_edges; i++)
    if (edge_infos[i])
      rounded_eds_inx[num_rounded_eds++] = i;
  if (!num_rounded_eds)
    goto ret_end;

  firstrnd_i = rounded_eds_inx[FIRST];
  firstprev_i = firstrnd_i == FIRST ? num_vtx_edges-1 : firstrnd_i-1;
  firstnext_i = firstrnd_i == num_vtx_edges-1 ? FIRST : firstrnd_i+1;

  num_neutral_eds = 0;
  num_non_neutral_eds = 0;
  neutral_eds_inx = (IGRint *) alloca (num_vtx_edges * sizeof (IGRint));
  non_neutral_eds_inx = (IGRint *) alloca (num_vtx_edges * sizeof (IGRint));
  for (i=0; i<num_vtx_edges; i++)
    if (edge_configs[i] == EMSedge_neutral ||
        edge_configs[i] == EMSedge_neutral_convex ||
        edge_configs[i] == EMSedge_neutral_concave)
      neutral_eds_inx[num_neutral_eds++] = i;
    else
      non_neutral_eds_inx[num_non_neutral_eds++] = i;

  /*
   * Are all the edges at this vertex either concave or convex?
   */

  homogenous_vtx = TRUE;
  edge_config = edge_configs[FIRST];
  for (i=1; i<num_vtx_edges; i++)
    if (edge_config != edge_configs[i])
      {
      homogenous_vtx = FALSE;
      break;
      }

  /*
   * If there are any neutral edges, and all the non-neutral edges are
   * homogenous, then it may be important to know if the vertex is
   * 'globally' homogenous. Note that if the vertex is homogenous then it is
   * also globally homogenous, trivially. In case of a non-trivial,
   * global homogeneity, we may require the radii of curvature of the
   * non-neutral edges at this vertex.
   */

  global_homogenous_vtx = TRUE;
  if (!homogenous_vtx)
    {
    if (num_neutral_eds)
      {
      edge_config = edge_configs[non_neutral_eds_inx[FIRST]];
      for (i=1; i<num_non_neutral_eds; i++)
        if (edge_config != edge_configs[non_neutral_eds_inx[i]])
          {
          global_homogenous_vtx = FALSE;
          break;
          }

      if (global_homogenous_vtx)
        for (i=0; i<num_neutral_eds; i++)
          if ((edge_config == EMSedge_convex && 
               edge_configs[neutral_eds_inx[i]] != EMSedge_neutral_convex) ||
              (edge_config == EMSedge_concave && 
               edge_configs[neutral_eds_inx[i]] != EMSedge_neutral_concave))
            {
            global_homogenous_vtx = FALSE;
            break;
            }

      if (global_homogenous_vtx)
        {
        EMidmatrix (&msg_loc, &mattyp, mat);
        radofcrv = (IGRdouble *) alloca (num_vtx_edges * sizeof (IGRdouble));
        for (i=0; i<num_non_neutral_eds; i++)
          {
          inx = non_neutral_eds_inx[i];
          radofcrv[inx] = 0.0;
          loc_opts = vtx_rnd_info->edge_stops[inx] ? EMS_O_Stop : EMS_O_Start;
          radofcrv[inx] = EMedradofcrv (&msg_loc, loc_opts, &mattyp, mat,
                           vtx_rnd_info->edge_ids[inx], os, NULL);
          }
        }
      }
    else
      global_homogenous_vtx = FALSE;
    }

  /*
   * Do any of the edges have a variable radius fillet on them?
   */

  no_variable_radii = TRUE;
  for (i=0; i<num_rounded_eds; i++)
    if (edge_infos[rounded_eds_inx[i]]->props & EMSfillet_is_variable_radius )
      {
      no_variable_radii = FALSE;
      break;
      }

  /*
   * Are all the radii of the fillets at the vertex the same?
   */

  at_stop = vtx_rnd_info->edge_stops[firstrnd_i];
  edge_info = edge_infos[firstrnd_i];
  radius = at_stop ? edge_info->other_radius : edge_info->radius;
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
  same_radii_atvtx = TRUE;
  for (i=0; i<num_rounded_eds; i++)
    {
    at_stop = vtx_rnd_info->edge_stops[rounded_eds_inx[i]];
    edge_info = edge_infos[rounded_eds_inx[i]];
    this_radius = at_stop ? edge_info->other_radius : edge_info->radius;
    if (fabs (this_radius - radius) > bastol)
      {
      same_radii_atvtx = FALSE;
      break;
      }
    }

  /*
   * Is this an open vertex, ie, with atleast an edge that does not have
   * a common edge?
   */

  open_vtx = FALSE;
  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  for (i=0; i<num_vtx_edges; i++)
    {
    count = 0;
    om$get_channel_count (objid = vtx_rnd_info->edge_ids[i], osnum = os,
     p_chanselect = &chan_to_common, count = &count);
    if (!count)
      {
      open_vtx = TRUE;
      break;
      }
    }
 
  /*
   * The following classification of the vertex is primarily based on 
   * the number of edges at the vertex being rounded. Within this, a finer
   * look is taken at how many edges are there at the vertex and what each
   * of their state is.
   */

  if (num_rounded_eds == 1)
    {
    /*
     * With a single edge being rounded, the default is create a 
     * single-patch vertex solution. The exceptions are coded below. These
     * could result in open-vertex, general-trim, 3edge-single-trim or
     * a general-blend solution.
     */

    vtx_config = EMSvertex_single_patch;

    if (num_vtx_edges == 2)
      {
      if (edge_configs[FIRST] != edge_configs[SECOND])
        vtx_config = EMSvertex_general_blend;
      }
    else if (num_vtx_edges == 3)
      {
      if (open_vtx)
        vtx_config = EMSvertex_open;
      else if (homogenous_vtx)
        vtx_config = EMSvertex_general_trim;
      else if (global_homogenous_vtx)
        {
        if (num_neutral_eds == 1)
          {          
          other_non_neutral_i = firstrnd_i == non_neutral_eds_inx[FIRST] ?
                                 non_neutral_eds_inx[SECOND] : 
                                 non_neutral_eds_inx[FIRST];
          if (radofcrv[firstrnd_i] > 10 * radofcrv[other_non_neutral_i])
            vtx_config = EMSvertex_general_trim;
          }
        }
      else if (WANT_POST220_BEHAVIOR)
        {
        if (!num_neutral_eds &&
            edge_configs[firstprev_i] == edge_configs[firstnext_i] &&
            !IF_NULL_OBJID (EMget_common_sf (
             vtx_rnd_info->edge_ids[firstprev_i],
             vtx_rnd_info->edge_ids[firstnext_i], OM_Gw_current_OS)))
          vtx_config = EMSvertex_3edge_single_trim;
        }
      }
    else if (num_vtx_edges > 3)
      {
      if (edge_configs[firstrnd_i] == edge_configs[firstprev_i] &&
          edge_configs[firstrnd_i] == edge_configs[firstnext_i])
        vtx_config = EMSvertex_general_trim;
      }
    }

  else if (num_rounded_eds == 2)
    {
    /*
     * When two edges are being rounded the default is tangent-trim.
     * The exceptions to this are coded below. These special situations result
     * in a 2edge-cx-1edge-cv or a general-blend solution.
     */

    vtx_config = EMSvertex_tangent_trim;

    if (num_vtx_edges == 2)
      {
      if (!same_radii_atvtx ||
          edge_configs[FIRST] != edge_configs[SECOND])
        vtx_config = EMSvertex_general_blend;
      }
    else if (num_vtx_edges == 3)
      {
      if (num_neutral_eds)
        {
        if (!same_radii_atvtx ||
            edge_configs[rounded_eds_inx[FIRST]] != 
             edge_configs[rounded_eds_inx[SECOND]])
          vtx_config = EMSvertex_general_blend;
        }
      else
        {
        if (homogenous_vtx)
          vtx_config = EMSvertex_general_trim;
        else if (edge_configs[rounded_eds_inx[FIRST]] == 
                  edge_configs[rounded_eds_inx[SECOND]])
          vtx_config = EMSvertex_2edge_cx_1edge_cv;
        else
          vtx_config = EMSvertex_general_blend;
        }
      }
    else if (num_vtx_edges == 4)
      {
      if (!same_radii_atvtx ||
           num_neutral_eds != 2 ||
           neutral_eds_inx[SECOND] != neutral_eds_inx[FIRST] + 2)
        {
        if (homogenous_vtx)
          vtx_config = EMSvertex_general_trim;
        else
          vtx_config = EMSvertex_general_blend;
        }
      }
    else
      {
      if (homogenous_vtx)
        vtx_config = EMSvertex_general_trim;
      else
        vtx_config = EMSvertex_general_blend;
      }
    }

  else if (num_rounded_eds == 3)
    {
    /*
     * When the number of edges being rounded is three, the
     * default is the rolling-ball solution. Exceptions to this rule
     * are coded below. These special situations result in a spherical-
     * patch or a general-trim or a general-blend.
     */

    vtx_config = EMSvertex_3edge_rolling_ball;

    if (num_vtx_edges == 3)
      {
      if (no_variable_radii)
        {
        if (homogenous_vtx && same_radii_atvtx)
          vtx_config = EMSvertex_spherical_blend;
        }
      else
        vtx_config = EMSvertex_general_blend;
      }
    else
      {
      if (homogenous_vtx)
        vtx_config = EMSvertex_general_trim;
      else
        {
        vtx_config = EMSvertex_general_blend;
        for (i=0; i<num_vtx_edges; i++)
          {
          if (!edge_infos[i])
            {
            edge_inx = i;
            break;
            }
          }
        stat = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                                 &ed_props),
                                 senderid = NULL_OBJID,
                                 targetos = os,
                                 targetid = vtx_rnd_info->edge_ids[edge_inx]);
        if (ed_props & EMED_SEAM)
          vtx_config = EMSvertex_3edge_rolling_ball;
        }
      }
    }

  else
    {
    /*
     * If 4 or more edges are rounded at a vertex, the default is the
     * general-blend solution. Exceptions to this are coded below. The
     * special situation that can come about here is one of
     * general-trim.
     */

    vtx_config = EMSvertex_general_blend;

    if (num_vtx_edges > num_rounded_eds)
      {
      if (homogenous_vtx)
        vtx_config = EMSvertex_general_trim;
      }
    }

ret_end:
  return (vtx_config);
}

end implementation EMSsfrndbool;

