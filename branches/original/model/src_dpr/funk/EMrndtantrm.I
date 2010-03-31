/*
  DESCRIPTION

    This function handles a 2, 3 or 4 edge vertex with none, one or two of the
    edges, respectively, being neutral. The neutral edge(s), if any, must occur
    inbetween the non-neutral ones. Both the non-neutral edges are being 
    rounded with the same radii occurring at the vertex and both the edges
    have the same convexity/concavity. This criteria ensures that the two
    fillets will meet each other tangentially at a common curve, usually, an
    iso-curve.

  ARGUMENTS

    fillet_patch	- Input/Output: Id of the composite surface to which
                           the blends/patches generated herein
                           will be appended to.

    fillet_inters	- Input/Output: The "intersections" between the
                           the fillets and the patches generated herein
                           are recorded in this list.

    model_inters	- Input/Output: The "intersections" between the
                           the fillets/patches and the model generated herein
                           are recorded in this list.

  HISTORY

    Inasu  :  Long ago   :  Creation
    SS     :  08/27/92   :  Re-write
    Janaka :  12/12/92   :  Added 4-edge vertex case.
                            Removed the mapping of the v-constant iso curve
                            of one fillet to the second fillet.  Now, the
                            intersection between the two fillets are obtained
                            as two independant v constant iso curves extracted
                            from each of the fillets.
    Janaka : 02/25/93    :  2-vertex case appeared to have been broken due to
                            the change on 12/12/92.  Fixed that.
    NP     :  05/27/93   :  Funtction "EMmkintlist" is now called by a new
                            name, "EMmakeintlist", due to addition of two new
                            curve type parameters.
                            NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN THE
                                  CALL (CURRENTLY SET TO NULL).
    Sudha     06/23/93      Modified for BSprototype ansification
    Janaka : 07/09/93    :  Replaced the rolling ball solution for non-
                            homogeneous case, with general blend.
    Janaka : 08/20/93    :  On failure, attempt to do a general blend.
    SS     : 10/26/93    :  Re-write
*/

class implementation EMSsfrndbool;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsedgedef.h"
#include "emssfintdef.h"
#include "bssfkttol2.h"
#include "bsrev_cv.h"
#include "bsparameters.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

#define FIRST  0
#define SECOND 1

#define THIS_FILLET  0
#define OTHER_FILLET 1

#define START  0
#define STOP   1

#argsused

IGRlong EMtangent_trim (msg, options, const_list, vtx_rnd_info,
                        fillet_patch, fillet_inters, model_inters)
IGRlong *msg;
IGRushort options;
struct GRvg_construct *const_list;
struct EMSvtx_rnd_info *vtx_rnd_info;
struct GRid *fillet_patch;
struct EMSinters **fillet_inters, **model_inters;
{
  IGRboolean other_reversed;
  IGRshort edtyp_count;
  IGRint i, inx, neutral_inx[2], rnded_inx[2], num_vtx_edges;
  IGRlong msg_loc, stat;
  IGRdouble radius, temp_rad, chktol;
  IGRpoint pt1, pt2, pt3, endpts[2][2];
  IGRvector vec;
  struct GRid ids[2];
  struct GRmdenv_info *mdenv_info;
  struct EMSedge_rnd_info **edge_infos;
  struct EMSdataselect xyzdata[2], uvdata[2];
  struct EMSsfintedpar *bdry_parms[2];
  enum EMSedge_config *edge_configs;

  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern struct EMSintobj *EMmakeintlist();
  extern IGRlong EMget_n_sided_blend();
  extern IGRdouble EMget_fillet_int_data();
  extern IGRdouble EMget_fillet_minpt_data();
  extern IGRdouble EMget_fillet_intpln_data();

  *msg = EMS_S_Success;
  stat = TRUE;

  for (i=FIRST; i<=SECOND; i++)
    {
    bdry_parms[i] = NULL;
    xyzdata[i].datatype = EMSdata_null;
    }

  mdenv_info = &const_list->env_info->md_env;

  /*
   * Check for the legal vertex cases:
   * - 3-edge vertex with 1 neutral.
   * - 4-edge vertex with 2 neutral such that the following configuration.
   *   occurs.  neutral-convex/concave-neutral-convex/concave.
   * - 2-vertex.
   * Note that in all cases, both the non-neutral edges are rounded and
   * with the same radius at the vertex. Both the edges being rounded have
   * to be of the same convexity/concavity.
   */

  num_vtx_edges = vtx_rnd_info->num_edges;
  EMerr_hndlr (num_vtx_edges < 2 || num_vtx_edges > 4, *msg, EMS_E_InvalidArg,
   ret_end);
  neutral_inx[FIRST] = neutral_inx[SECOND] = UNDEFINED;
  edge_configs = vtx_rnd_info->edge_configs;
  for (i=FIRST; i<num_vtx_edges; i++)
    if (edge_configs[i] != EMSedge_convex &&
        edge_configs[i] != EMSedge_concave)
      {
      if (neutral_inx[FIRST] == UNDEFINED)
        neutral_inx[FIRST] = i;
      else if( num_vtx_edges == 4 && neutral_inx[SECOND] == UNDEFINED )
        {
        neutral_inx[SECOND] = i;
        EMerr_hndlr (i != (neutral_inx[FIRST]+2)%num_vtx_edges, *msg,
         EMS_E_InvalidArg, ret_end);
        }
      else
        {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
      }

  edge_infos = vtx_rnd_info->edge_infos;
  for (i=FIRST; i<num_vtx_edges; i++)
    {EMerr_hndlr (i != neutral_inx[FIRST] && i != neutral_inx[SECOND] &&
      !edge_infos[i], *msg, EMS_E_InvalidArg, ret_end);}

  edtyp_count = 0;
  radius = UNDEFINED;
  inx = 0;
  for (i=FIRST; i<num_vtx_edges; i++)
    if (i != neutral_inx[FIRST] && i != neutral_inx[SECOND] )
      {
      edtyp_count += (edge_configs[i] == EMSedge_convex ? 1 : -1);
      rnded_inx[inx++] = i;
      temp_rad = vtx_rnd_info->edge_stops[i] ? 
                  edge_infos[i]->other_radius : edge_infos[i]->radius;
      if (radius == UNDEFINED)
        radius = temp_rad;
      else
        {EMerr_hndlr (radius != temp_rad, *msg, EMS_E_InvalidArg, ret_end);}
      }
  EMerr_hndlr (abs (edtyp_count) != 2, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Go about obtaining the set of uv curves (one on each fillet) and the
   * corresponding xyz-curve, that will truncate the fillets and also serve
   * as the junction between the two.
   */

  if (num_vtx_edges == 2)
    {
    for (inx=THIS_FILLET; inx<=OTHER_FILLET; inx++)
      {
      EMget_fillet_minpt_data (&msg_loc, edge_infos[rnded_inx[inx]],
       vtx_rnd_info->vtx_pt, OM_Gw_current_OS, 
       vtx_rnd_info->edge_stops[rnded_inx[inx]],
       &uvdata[inx], &xyzdata[inx]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
  else if (num_vtx_edges == 3)
    {
    for (inx=THIS_FILLET; inx<=OTHER_FILLET; inx++)
      {
      EMget_fillet_int_data (&msg_loc, edge_infos[rnded_inx[inx]],
       vtx_rnd_info->edge_ids[neutral_inx[FIRST]],
       OM_Gw_current_OS, vtx_rnd_info->edge_stops[rnded_inx[inx]],
       NULL, &uvdata[inx], &xyzdata[inx], NULL, NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
  else 
    {
    for (inx=THIS_FILLET; inx<=OTHER_FILLET; inx++)
      {
      EMget_fillet_int_data (&msg_loc, edge_infos[rnded_inx[inx]],
       vtx_rnd_info->edge_ids[neutral_inx[FIRST]],
       OM_Gw_current_OS, vtx_rnd_info->edge_stops[rnded_inx[inx]],
       NULL, NULL, NULL, NULL, pt1);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      EMget_fillet_int_data (&msg_loc, edge_infos[rnded_inx[inx]],
       vtx_rnd_info->edge_ids[neutral_inx[SECOND]],
       OM_Gw_current_OS, vtx_rnd_info->edge_stops[rnded_inx[inx]],
       NULL, NULL, NULL, NULL, pt2);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      EMgetsfnorm (&msg_loc, edge_infos[rnded_inx[inx]]->fill_surf,
       pt1, NULL, NULL, vec);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      OM_BLOCK_MOVE (pt1, pt3, sizeof (IGRpoint));
      for (i=X; i<=Z; i++)
        pt3[i] += vec[i] * radius;

      EMget_fillet_intpln_data (&msg_loc, NULL, edge_infos[rnded_inx[inx]],
       pt1, pt2, pt3, NULL,
       OM_Gw_current_OS, vtx_rnd_info->edge_stops[rnded_inx[inx]],
       &uvdata[inx], &xyzdata[inx], NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  /*
   * The orientation of the uv-data is correctly returned above,
   * but each may be opposed to the other. In order to have
   * all three pieces of data (uvdata[FIRST], uvdata[SECOND] and
   * xyzdata flow consistently, we may have to physically reverse the
   * other uv-data and note this fact. The logic is based on the fact
   * that common-edges of "consistently" oriented surfaces flow in 
   * opposite directions (a la winged-edge topology).
   */

  if ((edge_infos[rnded_inx[FIRST]]->fill_surf->pos_orient ?
       0x1 : 0x0) ^ 
      (edge_infos[rnded_inx[SECOND]]->fill_surf->pos_orient ?
       0x1 : 0x0))
    other_reversed = FALSE;
  else
    {
    EMdata_reverse (&uvdata[OTHER_FILLET]);
    EMdata_reverse (&xyzdata[OTHER_FILLET]);
    other_reversed = TRUE;
    }

  /*
   * Due to inexactness beyond tolerance limits of the geometries involved,
   * the end-points of the xyzdata on the two fillets may not match up within
   * cht. This causes problems downstream. In such a case, we construe a 
   * failure.
   */

  for (i=THIS_FILLET; i<=OTHER_FILLET; i++)
    {
    EMgetendpts_xyz (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
     &xyzdata[i], FALSE, 1, endpts[START][i], endpts[STOP][i]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chktol);
  chktol *= 2;
  for (i=START; i<=STOP; i++)
    EMerr_hndlr (!EMis_geomequal_3dpt (endpts[i][THIS_FILLET],
     endpts[i][OTHER_FILLET], chktol), *msg, EMS_E_OutOfBounds, ret_end);

  /*
   * Add the curves obtained into the fillets intersection list.
   */

  for (i=THIS_FILLET; i<=OTHER_FILLET; i++)
    {
    ids[i].objid = edge_infos[rnded_inx[i]]->fill_id;
    ids[i].osnum = OM_Gw_current_OS;

    bdry_parms[i] = EMsfintedpar_malloc (&msg_loc, 2);
    EMerr_hndlr (!bdry_parms[i], *msg, EMS_E_NoDynamicMemory,
     ret_end);
    }

  EMmakeintlist (&msg_loc, fillet_inters, fillet_inters,
   &ids[THIS_FILLET], &ids[OTHER_FILLET], NULL, NULL, NULL, NULL,
   &xyzdata[THIS_FILLET], &uvdata[THIS_FILLET], &uvdata[OTHER_FILLET],
   FALSE, other_reversed, 
   bdry_parms[THIS_FILLET], bdry_parms[OTHER_FILLET],
   EMSintobj_isocurve | EMSintobj_tangent, 
   EMSintobj_isocurve | EMSintobj_tangent,
   NULL, NULL, 
   TRUE, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  bdry_parms[THIS_FILLET] = NULL;
  bdry_parms[OTHER_FILLET] = NULL;

ret_end:
  for (i=FIRST; i<=SECOND; i++)
    if (bdry_parms[i])
      EMsfintedpar_free (bdry_parms[i], MAXINT);
  EMdataselect_data_free (&msg_loc, &xyzdata[OTHER_FILLET], 1);

  if (EMSerror (*msg))
    stat = EMget_n_sided_blend (msg, options, const_list,
            vtx_rnd_info, fillet_patch, fillet_inters, model_inters);
     
  EMWRAPUP (*msg, stat, "EMtangent_trim");
  return (stat);
}

end implementation EMSsfrndbool;
