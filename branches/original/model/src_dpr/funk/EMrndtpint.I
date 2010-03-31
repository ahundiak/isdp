/*
 * This file contains a collection of functions to handle topological
 * interactions specific to the rounding functionality.
 */
class implementation EMSsfrndbool;
%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "msmacros.h"
#include "emsedgedef.h"
#include "EMSdef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSrndtp.h"
#include "EMSrnd.h"
#include "bsgeom_cvsf.h"
#include "EMSrndprotyp.h"
#include "REgencompsf.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "EMSmsgdef.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "bstypes.h"
#include "bsmdistptsf.h"
#include "bsmdistptcv.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsconstprcv.h"
#include "bsarclength.h"
#include "bsalloccv.h"
#include "bssfeval.h"
#include "bssfevaln.h"
#include "bspartofcv.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bstagsort.h"
#include "bsdotp.h"
#include "bsrevsf_v.h"

#include "PWminimum.h"
#include "PWgmdata.h"                 /* PATHWAY */
#include "PWgmint.h"
#include "PWerror.h"
#include "PWapi/edintpts.h"
#include "PWapi/partol.h"
#include "PWapi/eded.h"
#include "PWapi/sfuptrav.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/xyztol.h"
#include "PWapi/edprops.h"
#include "PWapi/mapcvonsf.h"
#include "PWapi/uvcvprops.h"
#include "PWapi/sfbnds.h"

#define CONST_U  1
#define CONST_V  2

#define U0 0
#define V1 1
#define U1 2
#define V0 3

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define LAST   1

#define START 0
#define STOP  1

#define THIS  0
#define OTHER 1

#define FILLET 0
#define MODEL  1

#define FWD 0
#define BWD 1

#define ZERO     0
#define NEGATIVE 1
#define POSITIVE 2

from EMSloopset  import EMlsparttrim;
from EMSloop     import EMget_edges;
from EMSedge     import EMchkconvex, EMinternalpt, EMptproject, EMget_props;
from EMSboundary import EMgetsurface_info, EMget_objid;
from EMSsubbs    import EMget_edges;

/*
 * Static functions' declarations.
 */
%safe
static IGRboolean MapAndTrimCurve
(
  IGRlong *,
  struct GRmd_env *,
  struct IGRbsp_curve *,
  GRobjid,
  struct IGRbsp_surface *,
  IGRint *,
  struct EMSdataselect **,
  IGRint **,
  IGRint **,
  IGRint **,
  struct EMSsfintedpar ***,
  struct EMSpypoint ***
);
static IGRboolean CheckEndInteraction
(
  struct EMSdataselect *,
  struct EMSpypoint *,
  struct IGRbsp_surface *,
  IGRint *
);
static IGRboolean check_on_edge 
(
  struct EMSsfintedpar *, 
  GRobjid
);
static enum EMSedge_config EMget_edge_config
( 
  IGRlong *,
  struct GRmd_env *,
  GRobjid
);
static void CopyInfo
(
  struct EMStansf_rnd_info *,
  struct EMSedge_rnd_info *
);
static struct EMStansf_rnd_info *FilletExists
(
  GRobjid,
  GRobjid,
  IGRpoint,
  struct EMStansf_rnd_info *
);
static IGRint GetAreaCrossInteractions
(
  struct EMStansf_rnd_info *,
  IGRint *,
  struct EMSrnd_tpint_info ***,
  IGRint **
);
static void GetTopoInfoOnFillet
(
  IGRlong *,
  struct GRmd_env *,
  struct EMStansf_rnd_info *,
  struct EMSrnd_tpint_info **,
  struct EMSpypoint *,
  struct EMSdataselect *,
  IGRint
);
static IGRlong GenerateFillet
(
  IGRlong *,
  IGRushort,
  struct GRvg_construct *,
  struct EMSedge_rnd_info  *,
  IGRdouble *,
  struct EMStansf_rnd_info *,
  struct GRid *
);
static void get_part_nat_edge_split_info
(
  IGRlong  *,
  struct GRmd_env *,
  IGRdouble,
  IGRdouble,
  struct EMSinters *,
  GRobjid,
  IGRshort,
  GRobjid,
  struct EMSintobj **,
  struct EMSintobj **,
  IGRdouble *,
  IGRdouble *
);
static IGRint SortInteractionsAlongFillet
(
  IGRint,
  struct EMSrnd_tpint_info **,
  IGRint *
);
static IGRint ConnectFilletToComposite
(
  GRobjid,
  struct GRid *
);
static IGRint CreateIntersections
(
  IGRushort,
  struct GRmd_env *,
  struct EMSedge_rnd_info *,
  struct EMSinters **,
  struct EMSinters **,
  struct GRid *
);
static IGRint WeedOutInteractionPoints
(
  struct GRmd_env *,
  struct EMSinters *,
  struct EMStansf_rnd_info *
);
static struct EMSrnd_tpint_info *GetNextIntptOnIso
(
  IGRint,
  IGRlong,
  IGRlong,
  struct EMSrnd_tpint_info *
);
static struct EMSrnd_tpint_info *ArrangeInteractionsInList
(
  IGRint,
  struct EMSrnd_tpint_info **
);
static IGRint CreateDummyInteractions
(
  struct EMStansf_rnd_info *
);
static IGRint GetPointOnGeneratedSurface
(
  struct EMSrnd_tpint_info *,
  struct EMStansf_rnd_info *,
  struct EMStansf_rnd_info *,
  IGRdouble *,
  IGRdouble *
);
static IGRint CheckInteractionEdgeConfig
(
  IGRlong *,
  struct GRmd_env *,
  GRobjid
);
static IGRint OrientFillet
(
  struct GRmd_env *,
  struct EMStansf_rnd_info *,
  struct EMStansf_rnd_info **
);
static IGRint ProcessSeamCross
(
  struct EMStansf_rnd_info *,
  struct EMSinters *
);
static IGRint FilletFilletInt
(
  IGRushort,
  struct GRmd_env *,
  struct EMStansf_rnd_info *,
  struct EMSinters **
);
static IGRint FilletModelInt
(
  IGRushort,
  struct GRmd_env *,
  struct EMStansf_rnd_info *,
  struct EMSinters **,
  struct EMSinters **, 
  struct EMSedge_rnd_info *
);
static IGRint RemoveFilletSfs
(
  struct GRmd_env *,
  struct GRid *,
  struct EMStansf_rnd_info *,
  struct EMSinters *
);
static IGRint SetFwdBwdPointers
(
  struct EMSrnd_tpint_info *,
  struct EMSrnd_tpint_info *,
  struct EMSintobj *,
  IGRint
);
static struct EMStansf_rnd_info *EMtp_get_fillets
(
  IGRlong *,
  IGRushort,
  struct GRvg_construct *,
  struct EMSedge_rnd_info *,
  struct EMStansf_rnd_info *,
  GRobjid,
  GRobjid,
  IGRpoint,
  struct EMSinters *,
  struct GRid *
);
%endsafe

extern struct EMSsfintedpar *EMsfintedpar_malloc();
extern struct EMSintobj *EMmakeintlist();


/*
  DESCRIPTION

   This function takes in edge rounding information and and converts it
   to a format convenient for detection of inteactions.
   the fillet interacts with any of the tangent edges. If so, it
   generates extra-topological information and stores it into
   the fillet information structure.
  
  HISTORY

  Aditya  03/09/96 : Creation
*/

IGRlong EMget_rnd_topology_int_data (msg, options, const_list, edge_rnd_info,
                                     fillet_composite, fillet_inters,
                                     model_inters)
IGRlong                 *msg;
IGRushort               options;
struct GRvg_construct   *const_list;
struct EMSedge_rnd_info *edge_rnd_info;
struct GRid             *fillet_composite;
struct EMSinters        **fillet_inters, **model_inters;
{
  IGRlong    msg_loc, status=FALSE;
  IGRdouble  chttol, bastol, uvchttol;
  IGRpoint   xyzpt[1];

  struct IGRbsp_surface    *p_fillet=NULL;
  BSrc                     rc;

  struct GRmd_env          *p_md_env=NULL;
  GRspacenum               os;
  GRobjid                  sfid1=NULL_OBJID, sfid2=NULL_OBJID;

  struct EMStansf_rnd_info *tansf_rnd_info=NULL, *p_tansf=NULL;

  PWresult                 PWsts = PW_K_Success;
  PWpoint2d                edmidpt;

  *msg = EMS_S_Success;
  msg_loc = EMS_S_Success;
  status = OM_S_SUCCESS;

  p_md_env = const_list->env_info;
  os = p_md_env->md_id.osnum;

  BSEXTRACTPAR (&rc, BSTOLLENVEC, bastol);
  BSEXTRACTPAR (&rc, BSTOLCHRDHT, chttol);

  edge_rnd_info->tansf_rnd_info=NULL; 

  p_fillet = edge_rnd_info->fill_surf;
  uvchttol = edge_rnd_info->fill_surf_tol * chttol / bastol;

  /*
   * Create a EMStansf_rnd_info node for the base fillet and attach it to
   * EMSedge_rnd_info. There may be a slight redundancy in data stored, but
   * this is being done for the sake of generalized handling of the 
   * interactions for all cases.
   */
  tansf_rnd_info = (struct EMStansf_rnd_info *)
                    malloc(sizeof(struct EMStansf_rnd_info));
  EMerr_hndlr(!tansf_rnd_info, *msg, EMS_E_NoDynamicMemory, wrapup);

  EMtansf_rnd_info_init (tansf_rnd_info);

  /*
   * This fillet is marked as the base fillet by this function.
   */
  CopyInfo(tansf_rnd_info, edge_rnd_info);

  sfid1 = tansf_rnd_info->tansf1.objid;
  sfid2 = tansf_rnd_info->tansf2.objid;

  /*
   * First a EMStansf_rnd_info structure is created for this fillet, henceforth
   * called the base fillet. Most of the fields in this structure contain the
   * same info as that in the EMSedge_rnd_info struct, but this helps in
   * applying a general method for all fillets that are generated including
   * the base fillet
   */

   PWsts = pwEdInternalPts( edge_rnd_info->edge_id, os, 1, &edmidpt);
   EMerr_hndlr(IsError(PWsts), *msg, EMS_E_EdgeError, wrapup);

   BSsfeval(edge_rnd_info->surf, edmidpt[0], edmidpt[1], 0, xyzpt, &rc);
   EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

   p_tansf = EMtp_get_fillets(&msg_loc, options, const_list, edge_rnd_info,
                              tansf_rnd_info, sfid1, sfid2, xyzpt[0], 
                              *fillet_inters, fillet_composite);
   EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

   /*
    * Generate intersections on the fillet and model from the interaction
    * information.
    */
   status = CreateIntersections( options, p_md_env, edge_rnd_info,
                                 fillet_inters, model_inters,
                                 fillet_composite);
   EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, wrapup);

wrapup:

  /*
   * Delete the tansf_rnd_info list as we don't need it any more.
   */
  EMtansf_rnd_info_free (edge_rnd_info->tansf_rnd_info);
  edge_rnd_info->tansf_rnd_info = NULL;

  EMWRAPUP (*msg, status, "EMget_rnd_topology_int_data");
  return (status);
}

/*
 DESCRIPTION
 The main function that drives topology interaction processing. Called
 recursively to generate fillets between the relevant model surfaces
 that are determined by a marching technique.

 ALGORITHM

 - Input : Edge information, the supporting model surfaces, a xyz point
   that will decide the fillets that need to be kept, and other data
   lists.

 - Determine if a fillet between the supporting model surfaces tansf1_id
   and tansf2_id already exists close to the incoming xyz point. If it
   doesn't, generate the fillet. If it does, return if its processing
   has been completed else continue. Orient the fillet to match the
   orientation of the base fillet.

 - Extract u=0 and u=1 iso curves (or use the shortened xyz iso curves
   if this is the base fillet.) and map them onto the corresponding
   supporting surface. Trim the uv curves against the loopsets.

 - If the number of area cross overs is 1 -> no interaction. Check if
   an interaction is at the end of the iso curve. If it is at the end
   and the fillet is closed, we will handle it, else error out. 

 - From the trim info on the supporting surfaces generate interaction
   on the fillet surface for both the isos.

 - Merge and sort the interaction info on the fillet along the increasing
   v parameter direction of the fillet (this is our marching direction).

 - Check if the configuration of the interacting edges on the model surfaces
   are acceptable. Interactions with non-tangent edges are not handled
   and are an error condition.

 - Classify the interactions and keep only those that are common area
   overlaps of the interactions. These are the regions that need to be
   kept on this fillet.

 - March along the interaction list and for each interaction at an edge
   on the model get the common edge surface. This will be new supporting
   surface on that iso. The supporting surface on the other other iso
   is also set ( either the existing surface or common-edge surface if
   there is a coincident interaction).

 - Call this function recursively with the two new supporting surfaces.

 - Processing of this fillet surface is complete when all the interactions
   have been processed.

 HISTORY

   Aditya 09/03/96 - Creation.
*/

static struct EMStansf_rnd_info *EMtp_get_fillets 
( 
  IGRlong *msg,
  IGRushort options,
  struct GRvg_construct   *const_list,
  struct EMSedge_rnd_info *edge_rnd_info,
  struct EMStansf_rnd_info *tansf_info,
  GRobjid tansf1_id,
  GRobjid tansf2_id,
  IGRpoint xyzpt,
  struct EMSinters *fillet_inters,
  struct GRid *fillet_composite
)
{
  IGRshort    tp_interaction[2], iso_dir;
  IGRint      inx=0, knt=0, count=0, tp_stat=0, num_cvs, *p_count=NULL;
  IGRint      end_type=0;
  IGRint      num_sort=0, curr_iso=0, *p_isoinx=NULL, index;
  IGRint      num_nat_edges=0, iso_index;
  IGRdouble   bastol, chttol, uvtol, uvchttol, isopar=0.0, upar[2], vpar[2];
  IGRlong     msg_loc;
  IGRboolean  coinc=FALSE;
  IGRboolean  tst_plan=FALSE, next_processed=0, inter0, inter1;
  IGRpoint    refpt;
  PWobjid     *p_natedges=NULL;
  PWosnum     os;
  PWresult    PWsts=PW_K_Success;
  BSrc        rc;

  GRobjid     curr_tansf1, curr_tansf2, intedge, comm_edge;
  GRobjid     sfid, bdry_edge=NULL_OBJID;
  struct GRmd_env *p_md_env=NULL;

  struct EMSdataselect      xyzdata, *p_uvdata=NULL, *p_uvcvs=NULL;
  struct EMSpypoint         **p_bdrys=NULL;
  struct EMSsfintedpar      **p_intedpar=NULL;
  struct EMSintobj          *p_bwd_intobj[2]={NULL,NULL},
                            *p_fwd_intobj[2]={NULL,NULL};
  struct EMSinters          *p_inters=NULL;

  struct EMStansf_rnd_info  *p_tansf=NULL, *p_headtansf=NULL, *p_temp=NULL;
  struct EMStansf_rnd_info  *p_lasttansf=NULL, *p_rettansf=NULL;
  struct EMSrnd_tpint_info  *p_tpint=NULL, **p_sorttpint=NULL;
  struct EMSrnd_tpint_info  *p_intarr[2]={NULL,NULL}, *p_tmpint=NULL;

  struct IGRbsp_curve      *p_iso=NULL, *p_trimcv=NULL;
  struct IGRbsp_surface    *p_sfgeom=NULL, *p_fillet=NULL;

  msg_loc = EMS_S_Success;
  os = const_list->env_info->md_id.osnum;
  p_md_env = const_list->env_info;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);

  p_headtansf = edge_rnd_info->tansf_rnd_info;
  p_inters = fillet_inters;

  if( !(p_tansf = FilletExists(tansf1_id, tansf2_id, xyzpt, p_headtansf)))
  {
    /*
     * If a fillet does not already exist between the incoming supporting
     * faces, allocate space for a tansf_rnd_info atruct and generate the
     * fillet.
     */
    p_tansf = (struct EMStansf_rnd_info *)
               malloc ( sizeof(struct EMStansf_rnd_info));
    EMerr_hndlr (!p_tansf, *msg, EMS_E_NoDynamicMemory, wrapup);

    EMtansf_rnd_info_init (p_tansf);

    p_tansf->tansf1.objid = tansf1_id;
    p_tansf->tansf2.objid = tansf2_id;

    GenerateFillet ( &msg_loc, options, const_list, edge_rnd_info,
                                    xyzpt, p_tansf, fillet_composite);
    EMerr_hndlr (!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

    tp_stat = OrientFillet( p_md_env, tansf_info, &p_tansf);
    EMerr_hndlr (!(1&tp_stat), *msg, EMS_E_SurfaceError, wrapup);

    /*
     * Of the new set of fillets, get the one closest to the 'keep'
     * point.
     */
    p_temp = FilletExists(tansf1_id, tansf2_id, xyzpt, p_tansf);
    EMerr_hndlr (!p_temp, *msg, EMS_E_Fail, wrapup);

    /*
     * Attach the new nodes to  the end of the tansf_rnd_info struct list.
     */
    p_lasttansf = p_headtansf;
    while(p_lasttansf->next)
      p_lasttansf = p_lasttansf->next;

    p_lasttansf->next = p_tansf;

    /* Use the 'closest' node from here onwards.*/
    p_tansf = p_temp;
  }
  else
  {
    /*
     * If the fillet already exists and we have processed it do no more.
     * Go back with a smile.
     */
    if(p_tansf->props & EMSrnd_tansf_processing ||
       p_tansf->props & EMSrnd_fillet_processed)
    {
      tp_stat = 1;
      msg_loc = EMS_S_Success;
      goto wrapup;
    }
  }

  /*
   * Mark the current node as being processed.
   */
  p_tansf->props |= EMSrnd_tansf_processing;
  uvtol = p_tansf->fillet.tol;

  p_fillet = p_tansf->fillet.geom;
  tp_interaction[0] = tp_interaction[1] = FALSE;

  /*
   * For the base fillet we need to get the extent of the fillet that matters
   * after vertex processing. Also, the corresponding fwd & bwd intobjs
   * are returned. These should be used for generating intersections on the
   * base fillet and are therefore saved. The use of get_part_nat_edge_info()
   * to return the extents between the vertex-processing intobjs and the
   * intobjs themselves is good, as we maintain correct orientation of loops
   * on the fillets and gain accuracy.
   */
  if(p_tansf->props & EMSrnd_base_fillet)
  {
    uvchttol = pwGetParTolSf( p_fillet, chttol);

    PWsts = pwGetSfEds( p_tansf->fillet.objid, os, FALSE, FALSE, FALSE,
                        &num_nat_edges, &p_natedges);
    EMerr_hndlr (IsError(PWsts), *msg, EMS_E_Fail, wrapup);

    upar[0] = 0.0;
    upar[1] = 1.0;
    tst_plan = TRUE;

    /*
     * Constant U direction.
     */
    iso_dir = 1;

    BSalloccv (p_fillet->v_order, p_fillet->v_num_poles, p_fillet->rational, 0,
               &p_iso, &rc);
    EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

    for( index=0; index<2; index++)
    {
      iso_index = index==0 ? 0 : 2;
      get_part_nat_edge_split_info (&msg_loc, p_md_env, uvchttol,
                                    chttol, p_inters,
                                    p_tansf->fillet.objid,
                                    index, p_natedges[iso_index],
                                    &p_bwd_intobj[index], &p_fwd_intobj[index],
                                    &vpar[0], &vpar[1]);
      EMerr_hndlr (!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

      /*
       * Check if the orientation after vertex processing is correct.
       * Otherwise the fillet might flip.
       */
      EMerr_hndlr((iso_index == 0 && vpar[0] > vpar[1]) ||
                  (iso_index == 2 && vpar[0] < vpar[1]),
                  *msg, EMS_E_Fail, wrapup);

      /*
       * Extract the constt u parameter curve.
       */
      BSconstprcv (&rc, p_fillet, &iso_dir, &upar[index], &tst_plan, p_iso);
      EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

      BSalloccv (p_fillet->v_order,
                 p_fillet->v_num_poles + 2 * p_fillet->v_order - 1,
                 p_fillet->rational, 0, &p_trimcv, &rc);
      EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

      /*
       * Extract the partial curve between the limits as returned by
       * get_part_nat_edge_info().
       */
      BSpartofcv (&rc, p_iso,
                  iso_index == 2 ? vpar[1] : vpar[0],
                  (vpar[0] + vpar[1]) / 2.0,
                  iso_index == 2 ? vpar[0] : vpar[1],
                  p_trimcv);
      EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

      p_tansf->fill_isocvs[index] = p_trimcv;
      p_trimcv = NULL;
    }

    if(p_iso)
    {
      BSfreecv(&rc, p_iso);
      p_iso = NULL;
    }
  }

  /*
   * Get the u0 and u1 isos of the fillet, map them onto the corresponding
   * supporting surface and put them in the EMStansf_rnd_info structure for
   * this fillet.
   */
  for (inx=0; inx<2; inx++)
  {
    count = 0;
    p_iso = NULL;

    /*
     * Get the u0 and u1 isos of the fillet, map them onto the corresponding
     * supporting surface and put them in the EMStansf_rnd_info structure for
     * this fillet.
     */

    if(!(p_tansf->props & EMSrnd_base_fillet))
    {
      /*
       * Extract the const u curves.
       */
      iso_dir = 1;
      isopar = inx==0 ? 0.0 : 1.0;
      tst_plan = FALSE;

      BSalloccv (p_fillet->v_order, p_fillet->v_num_poles,
                 p_fillet->rational, 0, &p_iso, &rc);
      EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

      BSconstprcv(&rc, p_fillet, &iso_dir, &isopar, &tst_plan, p_iso);
      EMerr_hndlr (BSERROR(rc), *msg, EMS_E_SurfaceError, wrapup);

      p_tansf->fill_isocvs[inx] = p_iso;
      p_iso = NULL;
    }

    p_iso = p_tansf->fill_isocvs[inx];

    if(!p_iso) continue;

    sfid = inx==0 ? p_tansf->tansf1.objid : p_tansf->tansf2.objid;
    p_sfgeom = inx==0 ? p_tansf->tansf1.geom : p_tansf->tansf2.geom;

    num_cvs = 0;
    MapAndTrimCurve(&msg_loc, p_md_env, p_iso, sfid,
                    p_sfgeom, &num_cvs,
                    &p_uvcvs, &p_count,
                    (IGRint **)NULL, (IGRint **)NULL,
                    &p_intedpar, &p_bdrys);
    EMerr_hndlr(!(1&msg_loc) || !num_cvs || !p_count || !p_bdrys,
                *msg, EMS_E_Fail, wrapup);

    if(num_cvs > 1)
      tp_interaction[inx] = TRUE;

    xyzdata.datatype = EMSdata_curve3d;
    xyzdata.data.curve = p_iso;

    for(knt=0; knt<num_cvs; knt++)
    {
      /*
       * Process the trim information for topological interactions.
       * This will be done only when count is greater than 1. If count==0
       * the curve lies in a hole and we don't have to process it.
       */
      if (p_count[knt] > 1)
      {
        tp_interaction[inx] = TRUE;
      }

      if(p_count[knt] < 1)
        continue;
 
      /*
       * Do the end interaction checks only for the base fillet. End
       * interaction is allowed for secondary fillets and closed base
       * fillets where the interaction region straddles the seam.
       */
      if(p_tansf->props & EMSrnd_base_fillet)
      {
        if(!CheckEndInteraction(&xyzdata, p_bdrys[knt], p_sfgeom, &end_type))
        {
          if(edge_rnd_info->props & EMSfillet_ed_is_xyz_closed &&
             p_fillet->v_phy_closed)
          {
            if((end_type & EMSrnd_tpint_start) &&
               (end_type & EMSrnd_tpint_stop))
              p_tansf->props |= EMSrnd_seam_cross_fillet;

            tp_interaction[inx] = TRUE;
            tp_stat = ProcessSeamCross(p_tansf, p_inters);
            EMerr_hndlr( !(1&tp_stat), *msg, EMS_E_Fail,wrapup);
          }
          else
          {
            EMerr_hndlr( TRUE, *msg, EMS_E_NotSupported,wrapup);
          }
        }
        else if((edge_rnd_info->props & EMSfillet_ed_is_xyz_closed) &&
                p_fillet->v_phy_closed)
        {
          tp_stat = ProcessSeamCross(p_tansf, p_inters);
          EMerr_hndlr( !(1&tp_stat), *msg, EMS_E_Fail,wrapup);
        }
      }

      p_uvdata = &p_uvcvs[knt];

     /*
      * Transfer the interaction information on the supporting surfaces
      * to the fillet.
      */
      GetTopoInfoOnFillet(&msg_loc, p_md_env, p_tansf, &p_intarr[inx],
                          p_bdrys[knt], p_uvdata, inx);
      EMerr_hndlr( !(1&msg_loc), *msg, EMS_E_Fail, wrapup);

     /*
      * Free the uv curve memory here. We are going to regenerate it in
      * FilletModelInt(). This is an area for future optimization where
      * we carry this information along and avoid mapping again.
      */
      EMdataselect_data_free( &msg_loc, p_uvdata, 1);
      p_uvdata->datatype = EMSdata_null;

    } /* for(knt=0... */

    /*
     * Free the xyz curves too. We will get them from the interaction
     * extents in FilletModelInt().
     */
    if(p_iso)
    {
      BSfreecv(&rc, p_iso);
      p_iso = NULL;
      p_tansf->fill_isocvs[inx] = NULL;
    }

    if(p_count) free(p_count);
    p_count = NULL;

    if(p_uvcvs) free(p_uvcvs);
    p_uvcvs = NULL;

    p_bdrys = NULL;
    p_intedpar = NULL;

  } /* for(inx=0... */

  /*
   * If this fillet has a topological interaction, we need to generate the
   * fillet and tangential edge information for all the interactions that
   * occur during the rounding of this edge.
   */

   p_fillet = p_tansf->fillet.geom;

   /*
    * Attach the tpint nodes to the EMStansf_rnd_info node as a single
    * list and get ready to sort them.
    */
   EMerr_hndlr(!p_intarr[0] || !p_intarr[1], *msg,
               EMS_E_Fail, wrapup);

   p_tpint = p_intarr[0];

   while(p_tpint->next)
     p_tpint = p_tpint->next;

   p_tpint->next = p_intarr[1];

   p_tansf->tpint_info = p_intarr[0];

   /*
    * Sort the parametric points on the two isos of the fillet along
    * its length. 
    */
   num_sort = 0;

   p_tpint = p_tansf->tpint_info;
   while(p_tpint)
   {
     num_sort++;
     p_tpint = p_tpint->next;
   }

   p_sorttpint = (struct EMSrnd_tpint_info **)
                  malloc (num_sort * sizeof(struct EMSrnd_tpint_info *));
   p_isoinx = (IGRint *) malloc (num_sort * sizeof(IGRint));
   EMerr_hndlr(!p_sorttpint || !p_isoinx, *msg, EMS_E_NoDynamicMemory, wrapup);

   count=0;
   p_tpint = p_tansf->tpint_info;
   while(p_tpint)
   {
     p_isoinx[count] = p_tpint->iso_inx;
     p_sorttpint[count++] = p_tpint;
     p_tpint = p_tpint->next;
   }

   tp_stat = SortInteractionsAlongFillet(num_sort, p_sorttpint, p_isoinx);
   EMerr_hndlr(!(1&tp_stat), *msg, EMS_E_Fail, wrapup);

   if(p_tansf->props & EMSrnd_base_fillet &&
      !(p_tansf->props & EMSrnd_seam_cross_fillet))
   {
     for(inx=0; inx<2; inx++)
     {
       struct EMSrnd_tpint_info *p_first=NULL, *p_last=NULL;

       p_tpint = p_tansf->tpint_info;
       while(p_tpint)
       {
         if(p_tpint->iso_inx == inx)
         {
           if(!p_first) p_first = p_tpint;
           p_last = p_tpint;
         }
         p_tpint = p_tpint->next;
       }

       p_first->intobj = inx ? p_fwd_intobj[inx] : p_bwd_intobj[inx];
       p_last->intobj =  inx ? p_bwd_intobj[inx] : p_fwd_intobj[inx];

       p_first->props |= inx ? EMSrnd_tpint_start : EMSrnd_tpint_stop;
       p_last->props |= inx ? EMSrnd_tpint_stop : EMSrnd_tpint_start;

       p_first->props |= EMSrnd_tpint_nointers;
       p_last->props |= EMSrnd_tpint_nointers;
     }
   }

   if((p_tansf->props & EMSrnd_base_fillet) && 
      !tp_interaction[0] && !tp_interaction[1])
   {
     EMerr_hndlr(TRUE, *msg, EMS_S_Success, wrapup);
   }

  /*
   * Yahoo! interaction found.
   */
   edge_rnd_info->props |= EMSrnd_tp_interaction;

   /*
    * Here we check to see if there are valid interactions that lie between
    * the end intpts that have come from vertex processing. This is construed
    * to be an end interaction case and is not currently supported. Done by
    * checking for points between intpts that are marked nointers.
    */
   inter0 = inter1 = FALSE;
   for(inx=0; inx<num_sort; inx++)
   {
     p_tpint = p_sorttpint[inx];

     if(inter0 && inter1)
     {
       inter0 = inter1 = FALSE;
     }

     if(p_tpint->props & EMSrnd_tpint_nointers)
     {
       if(p_tpint->iso_inx==0)
         inter0 = TRUE;
       else
         inter1 = TRUE;
     }
     else
     {
       if(inter0 ^ inter1)
         EMerr_hndlr(TRUE, *msg, EMS_E_NotSupported, wrapup);
     }
   }

   /*
    * Get the interaction points that matter. Interaction points that lie
    * within 'hole' overlaps on the two isos are discarded. Also interaction
    * points that have the same param value on the 2 isos are marked.
    * Mark those intpts that are not in the p_sorttpint array as deletable.
    * We don't delete them now as we might be able to get information from
    * them.
    */
   tp_stat = GetAreaCrossInteractions(p_tansf, &num_sort,
                                      &p_sorttpint, &p_isoinx);
   EMerr_hndlr(!(1&tp_stat), *msg, EMS_E_Fail, wrapup);

   /*
    * Arrange the tpint_info list in the sorted order.
    */
   p_tansf->tpint_info = ArrangeInteractionsInList(num_sort, p_sorttpint);

   for(p_tpint = p_tansf->tpint_info; p_tpint; p_tpint = p_tpint->next)
   {
     if(p_tpint->props & (EMSrnd_tpint_deletable | EMSrnd_tpint_nointers))
       continue;

     bdry_edge = NULL_OBJID;
     bdry_edge = p_tpint->int_edge;

     /* 
      * Check if the edge configurations of the interacting boundary edges
      * are supported.
      */
     tp_stat = CheckInteractionEdgeConfig(&msg_loc, p_md_env, bdry_edge);

     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);
     EMerr_hndlr(!tp_stat, *msg, EMS_E_NotSupported, wrapup);
   }

   /*
    * At this point all the interactions have their properties set. We now
    * need to generate dummy interaction points, corresponding to 'true'
    * interactions, on the opposite iso. These dummy interactions determine
    * the limits for creating intersection curves between the model and the
    * surface. 'num_sort' need not be incremented after inserting dummy nodes
    * as in the following loop, we need to only consider non-dummy nodes.
    */
   tp_stat = CreateDummyInteractions(p_tansf);
   EMerr_hndlr(!(1&tp_stat), *msg, EMS_E_Fail, wrapup);

   /*
    * Now march through the sorted interaction points and generate
    * fillets and other info by calling this fn, EMtp_get_fillets()
    * with one of the current supporting surfaces and the common edge
    * surface of the interaction edge. This is the loop that does the
    * 'marching' along interactions.
    */

   for(inx=0; inx<num_sort; inx++)
   {
     coinc = FALSE;
     next_processed = FALSE;
     p_tmpint = NULL;
     p_tpint = p_sorttpint[inx];
     curr_iso = p_isoinx[inx];

     if(p_tpint->props & (EMSrnd_tpint_deletable |
                          EMSrnd_tpint_dummy |
                          EMSrnd_tpint_nointers)) 
       continue;

     intedge = p_tpint->int_edge;
     if(intedge == NULL_OBJID)
       continue;

     comm_edge = pwGetCommonEd(intedge, os);

     /*
      * If either due to an error or int_edge being a free edge, we do not
      * have a common edge, error out as topological handling at free
      * edges is not contemplated.
      */
     EMerr_hndlr(NULL_OBJID==comm_edge, *msg, EMS_E_NotSupported, wrapup);

     /*
      * Get the surface on which comm_edge lies.
      */
     sfid = pwGetSfOfEd(comm_edge, os);
     EMerr_hndlr(NULL_OBJID==sfid, *msg, EMS_E_SurfaceError, wrapup);

     /*
      * Setup the new supporting faces.
      */
     curr_tansf1 = tansf1_id;
     curr_tansf2 = tansf2_id;

     if(curr_iso == 0)
       curr_tansf1 = sfid;
     else
       curr_tansf2 = sfid;

     /*
      * If the next 'true' interaction point is coincident with the current
      * one, the other supporting face is also reset.
      */
     if((inx+1 < num_sort) &&
        (p_sorttpint[inx+1]->props & EMSrnd_tpint_coinc) &&
        p_sorttpint[inx+1]->int_edge != NULL_OBJID &&
        p_sorttpint[inx+1]->iso_inx != p_sorttpint[inx]->iso_inx)
     {
       p_tmpint = p_sorttpint[inx+1];

       comm_edge = pwGetCommonEd(p_sorttpint[inx+1]->int_edge, os);
       EMerr_hndlr(NULL_OBJID==comm_edge, *msg, EMS_E_NotSupported, wrapup);

       sfid = pwGetSfOfEd(comm_edge, os);
       EMerr_hndlr(NULL_OBJID==sfid, *msg, EMS_E_SurfaceError, wrapup);

       if(curr_iso == 0)
         curr_tansf2 = sfid;
       else
         curr_tansf1 = sfid;

       coinc = TRUE;
       next_processed = TRUE;
     }

     BSsfeval(p_fillet, p_tpint->int_pt[0], p_tpint->int_pt[1], 0, &refpt, &rc);
     EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

     p_rettansf = EMtp_get_fillets(&msg_loc, options, const_list, edge_rnd_info,
                                   p_tansf, curr_tansf1, curr_tansf2,
                                   refpt, p_inters, fillet_composite);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

     if( !(p_tpint->props & EMSrnd_tpint_area_start))
     {
       if(!(p_tpint->props & EMSrnd_tpint_at_seam))
         p_tpint->gen_tansf = p_rettansf;
     }

     if(p_tmpint && !(p_tmpint->props & EMSrnd_tpint_area_start))
     {
       if(!(p_tmpint->props & EMSrnd_tpint_at_seam))
         p_tmpint->gen_tansf = p_rettansf;
     }

     if(next_processed) inx++;
   }

   p_tansf->props &= ~EMSrnd_tansf_processing;
   p_tansf->props |= EMSrnd_fillet_processed;


wrapup:
  if(p_natedges) free(p_natedges);
  if(p_sorttpint) free(p_sorttpint);
  if(p_isoinx) free(p_isoinx);
  if(p_iso)
  {
    BSfreecv(&rc, p_iso);
    p_iso = NULL;
  }

  if(!(1 & tp_stat & *msg))
  {
    if(p_uvcvs)
    {
      EMdataselect_data_free( &msg_loc, p_uvcvs, num_cvs);
      free(p_uvcvs);
    }
    p_uvcvs = NULL;

    if(p_count) free(p_count);

    if(p_bdrys)
    {
      for(knt=0; knt<num_cvs; knt++)
      {
        if(p_bdrys[knt])
        {
          EMpypoint_free( p_bdrys[knt], MAXINT);
          p_bdrys[knt] = NULL;
        }
      }
      free(p_bdrys);
    }
    p_bdrys = NULL;
  }

  EMWRAPUP ( *msg, tp_stat, "EMtp_get_fillets");
  return (p_tansf);
}

/*--------------Static Functions-----------------------------*/

static IGRint CreateIntersections 
(
  IGRushort options,
  struct GRmd_env *md_env,
  struct EMSedge_rnd_info *edge_rnd_info,
  struct EMSinters **fillet_inters,
  struct EMSinters **model_inters,
  struct GRid *fillet_composite
)
{
  IGRlong msg_loc=EMS_S_Success;
  IGRint sts=1;
  struct EMSinters *p_filletinters=NULL, *p_modelinters=NULL;
  struct EMStansf_rnd_info *p_tansf=NULL;

  if(edge_rnd_info->props & EMSrnd_tp_interaction)
  {
    p_tansf = edge_rnd_info->tansf_rnd_info;
    while(p_tansf)
    {
      p_tansf->props &= ~EMSrnd_fillet_processed;
      p_tansf = p_tansf->next;
    }

    p_tansf = edge_rnd_info->tansf_rnd_info;
    sts = FilletFilletInt( options, md_env, p_tansf, &p_filletinters);
    EMerr_hndlr (!(1 & sts), sts, FALSE, wrapup);
  }

  p_tansf = edge_rnd_info->tansf_rnd_info;
  sts = FilletModelInt( options, md_env, p_tansf,
                        &p_filletinters, &p_modelinters, edge_rnd_info);
  EMerr_hndlr (!(1 & sts), sts, FALSE, wrapup);

  EMcmpinters( &msg_loc, fillet_inters);
  EMcmpinters( &msg_loc, model_inters);
  /*
   * Here we have the final intersection lists that were generated by
   * topological interactions. We need to check to see if there are
   * some EMStansf_rnd_info nodes whose fillets were included in the
   * fillet_composite but have no intersctions generated on them. We
   * unconditionally remove such fillets from the composite.
   */
  EMmergeinters (&msg_loc, fillet_inters, p_filletinters);
  EMerr_hndlr (!(1 & msg_loc), sts, FALSE, wrapup);
  p_filletinters = NULL;

  sts = RemoveFilletSfs(md_env, fillet_composite,
                        p_tansf, *fillet_inters);
  EMerr_hndlr (!(1 & sts), sts, FALSE, wrapup);


  EMmergeinters (&msg_loc, model_inters, p_modelinters);
  EMerr_hndlr (!(1 & msg_loc), sts, FALSE, wrapup);
  p_modelinters = NULL;

wrapup:
  if(!(1&sts&msg_loc))
  {
    if(p_filletinters) EMinters_free(p_filletinters, MAXINT);
    if(p_modelinters) EMinters_free(p_modelinters, MAXINT);
  }

  return(sts);
}


/*
 * Generates intersections between fillets ( base or secondary) that 
 * participate in an interaction.
*/

static IGRint FilletFilletInt
(
  IGRushort options,
  struct GRmd_env *md_env,
  struct EMStansf_rnd_info *tansf_info,
  struct EMSinters **fillet_inters
)
{
  IGRboolean done=0, tst_plan=TRUE, reverse2=0;
  IGRshort isodir=0;
  IGRint sts=1, inx;
  IGRulong props1=0, props2=0;
  IGRlong msg_loc=EMS_S_Success;
  IGRdouble u_par, v_par, other_upar, other_vpar;
  IGRpoint xyzpt;
  GRobjid fillet_id;
  GRspacenum os;
  struct GRid this_sf, other_sf;

  BSrc rc;
  struct IGRbsp_curve *p_isocv=NULL;
  struct IGRbsp_surface *p_fillet=NULL;
  struct IGRpolyline *p_poly=NULL;

  struct EMSdataselect xyzdata, this_uvdata, other_uvdata;
  struct EMSsfintedpar *p_parms1=NULL, *p_parms2=NULL;
  struct EMStansf_rnd_info *p_tansf=NULL, *p_gentansf=NULL;
  struct EMSrnd_tpint_info *p_tpint=NULL;
  struct EMSinters *p_filletinters=NULL;

  os = md_env->md_id.osnum;
  p_tansf = tansf_info;

  p_filletinters = *fillet_inters;

  while(!done && !(p_tansf->props & EMSrnd_fillet_processed))
  {
    fillet_id = p_tansf->fillet.objid;
    p_fillet = p_tansf->fillet.geom;

    sts = WeedOutInteractionPoints(md_env, p_filletinters, p_tansf);

    /*
     * Generate Intersections on this fillet and the secondary fillet
     * that was generated from each interaction point.
     */
    for(p_tpint = p_tansf->tpint_info;
        p_tpint;
        p_tpint->props |= EMSrnd_tpint_processed, p_tpint=p_tpint->next)
    {
      if(p_tpint->props & (EMSrnd_tpint_deletable |
                           EMSrnd_tpint_dummy |
                           EMSrnd_tpint_processed))
        continue;

      /*
       * Removed the coinc case from the above statement.
       */

      /*
       * The only intpts that will not have a gentansf are at the ends
       * and those with the propety, EMSrnd_tpint_area_start set.
       */
      p_gentansf = p_tpint->gen_tansf;

      /*
       * Fillet-fillet intersections need to be generated only if this
       * intpt has generated a secondary fillet or if there are no 
       * existing intersections close to this interaction. If this in
       * intpt is on a seam edge we don't need to generate fillet-fillet
       * intersections. Only fillet-model inters on both sides of the
       * fillet.
       */
      if(p_gentansf && !(p_tpint->props & EMSrnd_tpint_nointers))
      {
        /*
         * Generate intersections between the fillets.
         * Create an intobj on this fillet surface. Extract an v=constt iso
         * cv on this surface for the xyzdata. Create a 2pt poly for the
         * uvdata on both surfaces.
         */
        u_par = p_tpint->iso_inx==0 ? 0.0 : 1.0;
        v_par = p_tpint->int_pt[1];
 
        /*
         * Generate the xyz data.
         */
        BSalloccv (p_fillet->u_order, p_fillet->u_num_poles,
                   p_fillet->rational, 0, &p_isocv, &rc);
        EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
 
        tst_plan = TRUE;
        isodir = 2;
        BSconstprcv (&rc, p_fillet, &isodir, &v_par, &tst_plan, p_isocv);
        EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
 
        xyzdata.datatype = EMSdata_curve3d;
        xyzdata.data.curve = p_isocv;
 
        /*
         * Generate the uvdata on this surface and other surface.
         */
 
        BSsfeval(p_fillet, u_par, v_par, 0, (IGRpoint *)xyzpt, &rc);
        EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
 
        /*
         * Get the interaction point in the parametric space of the
         * other surface. Currently we are not checking if the parameters
         * on the other surface are close to a natural edge or not. If
         * they are close, we could use the edge_id for the uvdata.
        BSmdistptsf (&rc, p_gentansf->fillet.geom, xyzpt,
                     &other_upar, &other_vpar, dumpt, &dist);
        EMerr_hndlr(BSERROR(rc) || dist > xyztol, sts, FALSE, wrapup);
         */

        sts = GetPointOnGeneratedSurface(p_tpint, p_tansf, p_gentansf,
                                         &other_upar, &other_vpar);
        EMerr_hndlr(!(1&sts), sts, FALSE, wrapup);
 
        /* For this fillet and other fillet surface */
        for(inx=0; inx<2; inx++)
        {
          p_poly = (struct IGRpolyline *)malloc(sizeof(struct IGRpolyline));
          EMerr_hndlr(!p_poly, sts, FALSE, wrapup);
 
          p_poly->points=NULL;
          p_poly->points = (IGRdouble *)malloc(4*sizeof(IGRdouble));
          EMerr_hndlr(!p_poly->points, sts, FALSE, wrapup);
 
          p_poly->num_points = 2;
          p_poly->points[0] = 0.0;
 
          p_poly->points[1] = p_poly->points[3] = inx==0 ? v_par : other_vpar;
 
          p_poly->points[2] = 1.0;
 
          if(inx==0)
          {
            this_uvdata.datatype = EMSdata_poly2d;
            this_uvdata.data.poly = p_poly;
          }
          else
          {
            other_uvdata.datatype = EMSdata_poly2d;
            other_uvdata.data.poly = p_poly;
            if(p_gentansf->fillet.geom->pos_orient ^ p_fillet->pos_orient)
              EMdata_reverse (&other_uvdata);
          }
          p_poly=NULL;
        }
        p_parms1 = EMsfintedpar_malloc(&msg_loc, (IGRint)2);
        p_parms2 = EMsfintedpar_malloc(&msg_loc, (IGRint)2);
        EMerr_hndlr(!p_parms1 || !p_parms2, sts, FALSE, wrapup);
 
        props1 = props2 = EMSintobj_isocurve |
                          EMSintobj_marked   |
                          EMSintobj_tangent;

        /*
         * Do the fillet fillet settings for chamfers have to be
         * different?
          if(!(options & EMS_RND_CHAMFER))
          {
            props1 |= EMSintobj_tangent;
            props2 |= EMSintobj_tangent;
          }
         */
 
        this_sf.objid = fillet_id;
        other_sf.objid = p_tpint->gen_tansf->fillet.objid;
        this_sf.osnum = other_sf.osnum = os;
 
        reverse2= !(p_gentansf->fillet.geom->pos_orient ^ p_fillet->pos_orient);
 
        EMmakeintlist (&msg_loc, &p_filletinters, &p_filletinters,
                     &this_sf, &other_sf, NULL, NULL,
                     NULL, NULL, &xyzdata, &this_uvdata, &other_uvdata,
                     FALSE, reverse2, p_parms1, p_parms2,
                     props1, props2, NULL, NULL, TRUE, FALSE);
        EMerr_hndlr (!(1&msg_loc), sts, FALSE, wrapup);
        p_parms1 = p_parms2 = NULL;
        p_isocv=NULL;

      } /* if(p_gentansf...*/

      if(p_tpint->props & EMSrnd_tpint_area_start) continue;

      if(p_gentansf)
      {
        p_tpint->props |= EMSrnd_tpint_processed;
        break;
      }
    }

    /*
     * If p_tpint==NULL this is the last interaction point on this
     * surface. Which means that all the interactions have already
     * been processed.
     */
    if(!p_tpint) p_tansf->props |= EMSrnd_fillet_processed;

    if(!p_gentansf) done=TRUE;
    else p_tansf = p_gentansf;

  } /* while(.. */

  *fillet_inters = p_filletinters;

wrapup:
  return(sts);
}

/*
 * Generates intersections between the fillets and model by extracting
 * proper portions of the boundaries on the fillets and mapping them onto
 * the model surfaces.
 */

static IGRint FilletModelInt 
(
  IGRushort options,
  struct GRmd_env *md_env,
  struct EMStansf_rnd_info *tansf_info,
  struct EMSinters **fillet_inters,
  struct EMSinters **model_inters,
  struct EMSedge_rnd_info *p_edge_rnd_info
)
{
  IGRboolean done=0, tst_plan=TRUE, reverse1=0, reverse2=0;
  IGRshort isodir=0;
  IGRint sts=1, inx, num_cvs=0;
  IGRint *int_cross=NULL, *p_props=NULL;
  IGRulong props1=0, props2=0;
  IGRlong msg_loc=EMS_S_Success;
  IGRdouble par, chttol, uvchttol;
  GRobjid fillet_id;
  GRspacenum os;
  struct GRid this_sf, other_sf;


  BSrc rc;
  struct IGRbsp_curve *p_isocv=NULL, *p_partcv=NULL;
  struct IGRbsp_surface *p_fillet=NULL, *p_sfgeom=NULL;
  struct IGRpolyline *p_poly=NULL;

  struct EMSdataselect xyzdata, this_uvdata, other_uvdata, *p_uvdata=NULL;
  struct EMSsfintedpar *p_parms1=NULL, *p_parms2=NULL, **p_par=NULL;
  struct EMSsfintedpar *p_tmppar=NULL;
  struct EMStansf_rnd_info *p_tansf=NULL;
  struct EMSrnd_tpint_info *p_tpint=NULL, *p_nextintpt=NULL;
  struct EMSintobj *p_intobj=NULL;
  struct EMSinters *p_modelinters=NULL, *p_filletinters;

  os = md_env->md_id.osnum;
  p_modelinters = *model_inters;
  p_filletinters = *fillet_inters;

  chttol = pwActiveXYZChtTol();

  /* 
   * Generate intersections between this fillet and the model, i.e.
   * the fillet's supporting surfaces.
   */

  p_tansf = tansf_info;

  while(p_tansf)
  {
    sts = WeedOutInteractionPoints( md_env, p_filletinters, p_tansf);
    EMerr_hndlr ( !(1 & sts), sts, FALSE, wrapup);

    p_fillet = p_tansf->fillet.geom;
    fillet_id = p_tansf->fillet.objid;
    uvchttol = pwGetParTolSf( p_fillet, chttol);

    /* For the two isos */
    for(inx=0; inx<2; inx++)
    {
      p_tpint = p_nextintpt = NULL;
      done = FALSE;
      p_sfgeom = inx==0 ? p_tansf->tansf1.geom : p_tansf->tansf2.geom;

      p_tpint = p_tansf->tpint_info;
      while(p_tpint)
      {
        if(p_tpint->iso_inx == inx &&
           p_tpint->props & EMSrnd_tpint_nointers)
          break;
        p_tpint = p_tpint->next;
      }

      if(!p_tpint) continue;

      BSalloccv (p_fillet->v_order, p_fillet->v_num_poles,
                 p_fillet->rational, 0, &p_isocv, &rc);
      EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
    
      isodir = 1;
      tst_plan = TRUE;
      par = (inx==0) ? 0.0 : 1.0;

      BSconstprcv (&rc, p_fillet, &isodir, &par, &tst_plan, p_isocv);
      EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);

      while(!done)
      {
        p_intobj = NULL;
        props1 = props2 = 0;
        p_nextintpt = GetNextIntptOnIso( inx, EMSrnd_tpint_nointers |
                                         EMSrnd_tpint_at_seam,
                                         EMSrnd_tpint_deletable, p_tpint);
        EMerr_hndlr(p_nextintpt==p_tpint, sts, FALSE, wrapup);

        if(!p_nextintpt)
        {
          break;
        }

        /*
         * The coinc property indicates that an interaction node is
         * coincident with its previous node. If the following condition
         * is true, then we will have a zero length intersection curve.
         */
        if(p_tpint->next == p_nextintpt &&
           p_nextintpt->props & EMSrnd_tpint_coinc)
        {
          p_tpint = p_nextintpt;
          continue;
        }

        /* 
         * Get uvdata on the fillet between p_nextintpt and p_intpt.
         */
        p_poly = (struct IGRpolyline *)malloc(sizeof(struct IGRpolyline));
        EMerr_hndlr(!p_poly, sts, FALSE, wrapup);

        p_poly->points=NULL;
        p_poly->points = (IGRdouble *)malloc(4*sizeof(IGRdouble));
        EMerr_hndlr(!p_poly->points, sts, FALSE, wrapup);
    
        p_poly->num_points = 2;
        p_poly->points[0] = p_poly->points[2] = inx==0 ? 0.0 : 1.0;
        p_poly->points[1] = inx==0 ? p_tpint->int_pt[1]:p_nextintpt->int_pt[1];
        p_poly->points[3] = inx==0 ? p_nextintpt->int_pt[1]:p_tpint->int_pt[1];
    
        this_uvdata.datatype = EMSdata_poly2d;
        this_uvdata.data.poly = p_poly;
    
        /*
         * Set xyz properties on the fillet intersection curve, this_uvdata.
         */
        if(!pwIsSamePt2d ( p_tpint->int_pt, p_nextintpt->int_pt, uvchttol))
        {
          if(pwIsSamePt (p_tpint->xyzpt, p_nextintpt->xyzpt, chttol))
            props1 |= EMSintobj_xyz_closed;
        }

        this_sf.objid = fillet_id;
        this_sf.osnum = os;
    
        /* reverse1 = !(p_sfgeom->pos_orient ^ p_fillet->pos_orient); */
        reverse1 = FALSE;
    
        /*
         * Get uvdata on the supporting face between p_nextintpt and p_intpt.
         */
        other_sf.objid = inx==0 ? p_tansf->tansf1.objid : p_tansf->tansf2.objid;
        other_sf.osnum = os;

#ifdef INTERACTION_OPTIMIZED
       /*
        * Code within this will not be used at the moment. When interaction
        * rounding comes in for optimization we use this code. This code
        * was initially used even for non-interaction (run-of-the-mill)
        * rounding. Now we are pretty sure that only interaction cases will
        * dare to pass thru here. So, the overhead of regenerating the
        * data.
        */

        if(p_edge_rnd_info->props & EMSrnd_tp_interaction)
        {
#endif
          /*
           * We now have the limits between which we hve to extract
           * the intersection curves. Extract the u=constt iso curve on
           * the fillet for xyzdata, create uvdata for fillet and uvdata
           * on the correct supporting face by extracting a portion of the
           * uv data in the EMStansf_rnd_info node.
           */
    
          BSalloccv (p_isocv->order,
                     p_isocv->num_poles + 2 * p_isocv->order - 1,
                     p_isocv->rational, 0, &p_partcv, &rc);
          EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
      
          BSpartofcv (&rc, p_isocv, p_tpint->int_pt[1],
                      (p_nextintpt->int_pt[1] + p_tpint->int_pt[1])/2.0,
                      p_nextintpt->int_pt[1], p_partcv);
          EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
    
          xyzdata.datatype = EMSdata_curve3d;
          xyzdata.data.curve = p_partcv;

          if(inx == 1) EMdata_reverse (&xyzdata);

          num_cvs = 0;
          MapAndTrimCurve( &msg_loc, md_env, p_partcv,
                           other_sf.objid,
                           p_sfgeom, &num_cvs,
                           &p_uvdata, &int_cross,
                           &p_props, NULL,
                           &p_par, NULL);
          EMerr_hndlr(!(1&msg_loc) || !(num_cvs==1),
                       sts, FALSE, wrapup);

          other_uvdata = *p_uvdata;
          p_tmppar = p_par[0];

#ifdef INTERACTION_OPTIMIZED
        }
        else
        {
          PWresult PWsts = PW_K_Success;
          struct PWcvdata cvdata;

          xyzdata.datatype = EMSdata_curve3d;
          xyzdata.data.curve = p_tansf->fill_isocvs[inx];
          p_tansf->fill_isocvs[inx] = NULL;

          /*
           * Hand over the model uv data to p_uvdata and set it to
           * EMSdata_null in the tansf node as it should not be freed
           * after topology interaction processing.
           */
          other_uvdata = p_tansf->fill_isocvs_onsfs[inx];
          p_uvdata = &other_uvdata;
          p_tansf->fill_isocvs_onsfs[inx].datatype = EMSdata_null;
          num_cvs = 1;

          if(inx == 1)
          {
            EMdata_reverse (&xyzdata);
            EMdata_reverse (p_uvdata);
          }

          /*
           * Trim the uvdata against the surface to get the trim information.
           */
          MapAndTrimCurve( &msg_loc, md_env, NULL,
                           other_sf.objid,
                           p_sfgeom, &num_cvs,
                           &p_uvdata, &int_cross,
                           NULL, NULL,
                           &p_par, NULL);
          EMerr_hndlr(!(1&msg_loc) || num_cvs!=1, sts, FALSE, wrapup);

          p_props = (IGRint *)malloc(sizeof(IGRint));
          EMerr_hndlr(!p_props, sts, FALSE, wrapup);

          pwMoveEMSCvdata ( p_uvdata, &cvdata);

          PWsts = pwGetUvCvdataProps ( &cvdata, p_sfgeom,
                                       chttol, uvchttol, p_props);
          EMerr_hndlr (IsError(PWsts), sts, FALSE, wrapup);

          pwMoveCvdataEMS ( &cvdata, p_uvdata);

          p_tmppar = p_par[0];
        }
#endif

        if(tansf_info->props & EMSrnd_base_fillet)
        {
          sts = check_and_adjust_bdry_parms( &msg_loc, md_env, p_uvdata,
                                             inx == 0 ? TRUE : FALSE,
                                             p_edge_rnd_info, p_tmppar);
          EMerr_hndlr( !( 1 & sts & msg_loc ), sts, FALSE, wrapup );
        }
 
        p_parms2 = p_tmppar;

        if(p_props)
        {
          if(p_props[0] & EMED_ISO)
            props2 |= EMSintobj_isocurve;
          if(p_props[0] & EMED_DEGENERATE)
            props2 |= EMSintobj_uvdegenerate;
          if(p_props[0] & EMED_XYZ_CLOSED)
            props2 |= EMSintobj_xyz_closed;
          if(p_props[0] & EMED_NATURAL)
            props2 |= EMSintobj_overlap;
          if(p_props[0] & EMED_SEAM)
            props2 |= EMSintobj_seam;

          free(p_props);
          p_props = NULL;
        }

        /*
         * Do not free the mapped data as it is now in other_uvdata.
         */
        /* EMdataselect_data_free(&msg_loc, &p_uvdata[0], 1); */
        p_uvdata = NULL;
  
        if(int_cross) free(int_cross);
        int_cross = NULL;
  
        if(p_par) free(p_par);
        p_par = NULL;

        reverse2 = !(p_sfgeom->pos_orient ^ p_fillet->pos_orient);
        /*
         * Create the intobj nodes on the fillet and the model supporting
         * faces.
         */
 
        props1 |= EMSintobj_isocurve | EMSintobj_marked |
                  EMSintobj_exact_atstart | EMSintobj_exact_atstop;

        if(!(options & EMS_RND_CHAMFER))
        {
          props1 |= EMSintobj_tangent;
          props2 |= EMSintobj_tangent;
        }
    
        p_parms1 = EMsfintedpar_malloc(&msg_loc, (IGRint)2);
        if(!p_parms2)
          p_parms2 = EMsfintedpar_malloc(&msg_loc, (IGRint)2);
        EMerr_hndlr(!p_parms1 || !p_parms2, sts, FALSE, wrapup);
    
        p_intobj = EMmakeintlist (&msg_loc, &p_filletinters, &p_modelinters,
                                  &this_sf, &other_sf, NULL, NULL,
                                  NULL, NULL, &xyzdata,
                                  &this_uvdata, &other_uvdata,
                                  reverse1, reverse2, p_parms1, p_parms2,
                                  props1, props2, NULL, NULL, TRUE, FALSE);
        EMerr_hndlr (!(1&msg_loc) || !p_intobj, sts, FALSE, wrapup);
        p_parms1 = p_parms2 = NULL;
        p_partcv = NULL;
        p_poly=NULL;

        SetFwdBwdPointers( p_tpint, p_nextintpt, p_intobj, inx);
    
        p_tpint = GetNextIntptOnIso( inx, EMSrnd_tpint_nointers |
                                          EMSrnd_tpint_at_seam,
                                     EMSrnd_tpint_deletable, p_nextintpt);
        EMerr_hndlr(p_nextintpt==p_tpint, sts, FALSE, wrapup);
    
        if(!p_tpint)
        {
          break;
        }
  
      } /* while.. */

      BSfreecv(&rc, p_isocv);
      EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
      p_isocv = NULL;
    
    } /* for(... */
    p_tansf = p_tansf->next;
  }

  *model_inters = p_modelinters;
  *fillet_inters = p_filletinters;

wrapup:
  if(!(1&sts))
  {
    if(p_partcv) BSfreecv(&rc, p_partcv);
  }

  return(sts);
}

/*
 * Create a EMSrnd_tpint_info list, in the order of the sorted array
 * that is input.
 */
static struct EMSrnd_tpint_info *ArrangeInteractionsInList
(
  IGRint num_sort,
  struct EMSrnd_tpint_info **p_sorttpint
)
{
  IGRint inx;
  struct EMSrnd_tpint_info *p_tpint=NULL, *p_head=NULL;
  
  p_head = p_tpint = p_sorttpint[0];

  for(inx=1; inx<num_sort; inx++)
  {
    if(!p_tpint) break;
    if(!p_sorttpint[inx]) continue;

    p_tpint->next = p_sorttpint[inx];
    p_tpint = p_tpint->next;
    p_tpint->next = NULL;
  }

  return(p_head);
}

static struct EMSrnd_tpint_info *GetNextIntptOnIso
(
  IGRint iso_inx,
  IGRlong props,
  IGRlong no_props,
  struct EMSrnd_tpint_info *tpint
)
{
  struct EMSrnd_tpint_info *p_tpint=NULL, *p_temp=NULL;

  if(!(p_temp = tpint)) goto wrapup;

  p_temp = NULL;
  for(p_tpint=tpint->next; p_tpint; p_tpint=p_tpint->next)
  {
    if(p_tpint->props & no_props)
      continue;

    if(p_tpint->iso_inx != iso_inx) continue;

    if(p_tpint->props & props)
    {
      p_temp = p_tpint;
      break;
    }
  }

wrapup:
 return(p_temp);
}

/*
 * On the fillets we don't need to keep those interactions that are
 * very close to existing fillet-fillet intersections. Hunt them
 * down and mark so that no intersections are generated from them on
 * the fillet.
 */
static IGRint WeedOutInteractionPoints
(
  struct GRmd_env *p_mdenv,
  struct EMSinters *inters_node,
  struct EMStansf_rnd_info *tansf_info
)
{
  IGRint    sts=1;
  IGRlong   msg_loc=EMS_S_Success;
  IGRdouble squvtol=0.0, sqchttol=0.0, chttol;
  IGRdouble start_uv[2], stop_uv[2];
  IGRpoint  start_xyz, stop_xyz;
  BSrc rc;

  GRobjid fillet_id=NULL_OBJID;

  struct IGRbsp_surface     *p_fillet=NULL;
  struct EMSinters          *p_inters=NULL;
  struct EMSintobj          *p_intobj=NULL;
  struct EMSrnd_tpint_info  *p_tpint=NULL;

  chttol = pwActiveXYZChtTol();
  sqchttol = chttol * chttol;

  p_fillet = tansf_info->fillet.geom;
  fillet_id = tansf_info->fillet.objid;
  squvtol = tansf_info->fillet.tol * tansf_info->fillet.tol;

  for(p_inters = inters_node; p_inters; p_inters = p_inters->next)
    if(p_inters->this_obj.objid == fillet_id)
      break;

  /*
   * It is entirely possible that we may not find a inters node
   * corresponding to the fillet. So return without error.
   */
  if(p_inters && p_inters->cvs)
    p_intobj = p_inters->cvs;
  else
    EMerr_hndlr(TRUE, sts, TRUE, wrapup);

  for(; p_intobj; p_intobj = p_intobj->next)
  {
    if(p_intobj->props & EMSintobj_deletable)
      continue;

    sts = EMgetendpts_uv( &msg_loc, &p_intobj->this_uvintobj,
                          p_intobj->reversed, 1,
                          start_uv, stop_uv);
    EMerr_hndlr(!(1&sts&msg_loc), sts, FALSE, wrapup);

    if(p_intobj->this_xyzintobj.datatype != EMSdata_null)
    {
      sts = EMgetendpts_xyz( &msg_loc, &p_mdenv->md_env.matrix_type,
                             p_mdenv->md_env.matrix,
                             &p_intobj->this_xyzintobj, 
                             p_intobj->reversed, 1,
                             start_xyz, stop_xyz);
      EMerr_hndlr(!(1&sts&msg_loc), sts, FALSE, wrapup);
    }
    else
    {
      BSsfeval(p_fillet, start_uv[0], start_uv[1],
               0, (IGRpoint *)start_xyz, &rc);
      EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);

      BSsfeval(p_fillet, stop_uv[0], stop_uv[1],
               0, (IGRpoint *)stop_xyz, &rc);
      EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
    }

    for(p_tpint=tansf_info->tpint_info; p_tpint; p_tpint=p_tpint->next)
    {
      if(p_tpint->props & EMSrnd_tpint_deletable ||
         p_tpint->props & EMSrnd_tpint_nointers)
        continue;

      if(pwDistSqPtPt2d(p_tpint->int_pt, start_uv) < squvtol)
      {
        p_tpint->props |= EMSrnd_tpint_nointers |
                          EMSrnd_tpint_start;
        p_tpint->intobj = p_intobj;
      }
      else if(pwDistSqPtPt2d(p_tpint->int_pt, stop_uv) < squvtol)
      {
        p_tpint->props |= EMSrnd_tpint_nointers |
                          EMSrnd_tpint_stop;
        p_tpint->intobj = p_intobj;
      }

      /*
       * Do a double check to determine whether they are within cht in xyz.
       */
      if(!(p_tpint->props & EMSrnd_tpint_nointers))
      {
        if(BSdistptpts(&rc, start_xyz, p_tpint->xyzpt) < sqchttol)
        {
          p_tpint->props |= EMSrnd_tpint_nointers |
                            EMSrnd_tpint_start;
          p_tpint->intobj = p_intobj;
        }
        else if(BSdistptpts(&rc, stop_xyz, p_tpint->xyzpt) < sqchttol)
        {
          p_tpint->props |= EMSrnd_tpint_nointers |
                            EMSrnd_tpint_stop;
          p_tpint->intobj = p_intobj;
        }
      }
    }
  }

wrapup:
  return(sts);
}


static IGRint GetAreaCrossInteractions
(
  struct EMStansf_rnd_info *p_tansf,
  IGRint *num_sort,
  struct EMSrnd_tpint_info ***p_sorttpint,
  IGRint **p_isoinx
)
{
  IGRint sts=TRUE, inx=0, count=0, *p_newinx=NULL;
  IGRint *p_inx=NULL, iso_inhole[2]={1,1}, tmpinx=0;
  IGRboolean keep_int=TRUE, area_start=FALSE;
  IGRdouble chttol, sqchttol, upar, vpar, uvtol;
  IGRpoint *p_other_xyzpt=NULL;
  BSrc rc;

  struct EMSrnd_tpint_info **p_tpint=NULL, **p_newarr=NULL, *p_tmptp=NULL;
  struct EMSpypoint *p_pypt=NULL, *p_pynext=NULL;

  chttol = pwActiveXYZChtTol();
  sqchttol = chttol * chttol;
  uvtol = p_tansf->fillet.tol;

  p_tpint = *p_sorttpint;
  p_inx = *p_isoinx;

  p_newinx = (IGRint *)malloc(*num_sort * sizeof(IGRint));
  p_newarr = (struct EMSrnd_tpint_info **)
             malloc(*num_sort * sizeof(struct EMSrnd_tpint_info *));
  EMerr_hndlr(!p_newarr || !p_newinx, sts, 0, wrapup);

  p_other_xyzpt = (IGRpoint *)malloc(*num_sort * sizeof(IGRpoint));
  EMerr_hndlr(!p_other_xyzpt, sts, 0, wrapup);

  for(inx=0; inx<*num_sort; inx++)
  {
    /*
     * Get the xyz pt corresponding to the other ens of the interaction
     * iso.
     */
    upar = p_tpint[inx]->iso_inx ? 0.0 : 1.0;
    vpar = p_tpint[inx]->int_pt[1];

    BSsfeval(p_tansf->fillet.geom, upar, vpar, 0, &p_other_xyzpt[inx], &rc);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  }

  /*
   * Check first for coincident interactions on the fillet. Mark such
   * interactions with EMSrnd_tpint_coinc, which implies that this intpt
   * is coincident with its previous intpt. If two coincident 
   * interactions arise on the same iso, they can both be ignored and
   * marked deletable. But if they are coincident because they come from
   * interactions on seam edges, do a topological area-hole flipping
   * check as when we cross a seam the first interaction should go from
   * area to hole and the next one should go from hole to area. This is
   * in spite of the parametric sorting, where we could have tolerance
   * problems.
   */
  for(inx=1; inx<*num_sort; inx++)
  {
    if((p_tpint[inx]->int_pt[1] - p_tpint[inx-1]->int_pt[1]) < uvtol  ||
       BSdistptpts(&rc, p_tpint[inx]->xyzpt, p_tpint[inx-1]->xyzpt)<sqchttol ||
       BSdistptpts(&rc, p_tpint[inx]->xyzpt, p_other_xyzpt[inx-1]) <sqchttol ||
       BSdistptpts(&rc, p_other_xyzpt[inx], p_tpint[inx-1]->xyzpt) <sqchttol)
    {
      if(p_inx[inx] == p_inx[inx-1])
      {

        if(p_tpint[inx]->props & EMSrnd_tpint_at_seam &&
           p_tpint[inx-1]->props & EMSrnd_tpint_at_seam)
        {
          p_pypt = (struct EMSpypoint *)p_tpint[inx-1]->trim_info;
          p_pynext = (struct EMSpypoint *)p_tpint[inx]->trim_info;

          if((p_pypt->props &  EMS_PYPT_HOLEAREA) &&
             (p_pynext->props & EMS_PYPT_AREAHOLE))
          {
            p_tmptp = p_tpint[inx-1];
            p_tpint[inx-1] = p_tpint[inx];
            p_tpint[inx] = p_tmptp;
          }
          /*
           * Mark the seam interactions as coincident only if they are
           * close to each other in uv, to avoid marking them if they
           * are close to each other lying at either ends of a closed
           * xyz curve.
           */
          if((p_tpint[inx]->int_pt[1] - p_tpint[inx-1]->int_pt[1]) < uvtol )
            p_tpint[inx]->props |= EMSrnd_tpint_coinc;
          continue;
        }
        else
        {
          p_tpint[inx-1]->props |= EMSrnd_tpint_deletable;
          p_tpint[inx]->props |= EMSrnd_tpint_deletable;
          continue;
        }
      }
      /*
       * If the previous interaction is not a 'true' interaction i.e. its
       * int_edge is NULL_OBJID, do not mark this as a coincident interaction
       * rather, swap the two nodes in the array. This simplifies processing
       * downstream.
       */
      if(p_tpint[inx-1]->int_edge == NULL_OBJID)
      {
        p_tmptp = p_tpint[inx-1];
        p_tpint[inx-1] = p_tpint[inx];
        p_tpint[inx] = p_tmptp;
        p_tpint[inx]->props |= EMSrnd_tpint_coinc;

        tmpinx = p_inx[inx-1];
        p_inx[inx-1] = p_inx[inx];
        p_inx[inx] = tmpinx;
      }
      else
        p_tpint[inx]->props |= EMSrnd_tpint_coinc;
    }
  }


  for(inx=0; inx<*num_sort; inx++)
  {
    keep_int = FALSE;
    area_start = FALSE;

    if(p_tpint[inx]->props & EMSrnd_tpint_deletable)
    {
      p_newarr[count] = p_tpint[inx];
      p_newinx[count++] = p_inx[inx];
      continue;
    }

    p_pypt = (struct EMSpypoint *)p_tpint[inx]->trim_info;

    if(p_pypt->props &  EMS_PYPT_AREAAREA)
    {
      if(p_inx[inx] == 0) iso_inhole[0] = FALSE;
      else iso_inhole[1] = FALSE;
    }
    else if(p_pypt->props & (EMS_PYPT_HOLEAREA))
    {
      if(p_inx[inx] == 0) iso_inhole[0] = FALSE;
      else iso_inhole[1] = FALSE;
      area_start = TRUE;

      /*
       * If this is the first interaction and the next is a coincident
       * interaction, keep this guy. This is being done as we are not yet
       * ready with the info about the next interaction.
       */
      /* if(inx==0) */
      {
        if(*num_sort > inx+1)
        {
          if(p_tpint[inx+1]->props & EMSrnd_tpint_coinc ||
             p_tpint[inx+1]->props & EMSrnd_tpint_nointers)
            keep_int = TRUE;
        }
      }
    }
    else if(p_pypt->props & (EMS_PYPT_AREAHOLE))
    {
      /*
       * If interaction is transitioning from area->hole on one of the
       * isos, we will want to keep the interaction if interaction on 
       * the other iso is in area.
       */
      if(p_inx[inx] == 0)
      {
        iso_inhole[0] = TRUE;
        if(!iso_inhole[1]) keep_int = TRUE;
      }
      else
      {
        iso_inhole[1] = TRUE;
        if(!iso_inhole[0]) keep_int = TRUE;
      }
    }
    else if(p_pypt->props & (EMS_PYPT_HOLEHOLE))
    {
      if(p_inx[inx] == 0) iso_inhole[0] = TRUE;
      else iso_inhole[1] = TRUE;

      p_tpint[inx]->props |= EMSrnd_tpint_deletable;
    }

    /*
     * We also need to keep coincident interactions and interactions
     * that are close to existing intersections.
     */
    if(p_tpint[inx]->props & EMSrnd_tpint_coinc ||
       (!iso_inhole[0] && !iso_inhole[1]) ||
       keep_int ||
       p_tpint[inx]->props & EMSrnd_tpint_nointers)
    {
      p_newarr[count] = p_tpint[inx];
      p_newinx[count] = p_inx[inx];

      if(area_start)
        p_newarr[count]->props |= EMSrnd_tpint_area_start;

      count++;
    }
    else
    {
      p_newarr[count] = p_tpint[inx];
      p_newinx[count] = p_inx[inx];
      p_newarr[count]->props |= EMSrnd_tpint_deletable;
      count ++;
    }
  }

  *num_sort = count;
  memcpy(*p_sorttpint, p_newarr, count * sizeof(struct EMSrndtpint_info *));
  memcpy(*p_isoinx, p_newinx, count * sizeof(IGRint));

wrapup:

  if(p_newarr) free(p_newarr);
  if(p_newinx) free(p_newinx);
  if(p_other_xyzpt) free(p_other_xyzpt);

  return(sts);
}


/*
  DESCRIPTION

   This function takes in topological interaction information 
   and generates the rolling ball fillets, their u0 & u1 isos and 
   the mapped isos on the supporting surfaces information needed,
   and stores them into the tansf_rnd_info structure.

  ARGUMENTS

   edge_rnd_info       - Input: Edge round information.
 
   inx                 - Input: Index to the fillet iso for which
                                interaction is taking place.

   bdry_edge           - Input: Boundary on the model with which
                                interaction is taking place.

   tansf_rnd_info      - Output: Tangential topological interaction
                                 information. Memory has to be allocated
                                 by the caller. 

   fillet_composite    - Input/Output: Fillet composite grid to which
                                 rolling ball fillet is attached.

  NOTES
  The responsibility of sending in the surface_ids of the supporting
  faces in order that the u0 parameter matches the u0 of the base fillet
  is with the caller.

  HISTORY

  Aditya  05/3/1996    Creation

*/

static IGRlong GenerateFillet 
(
  IGRlong *msg,
  IGRushort options,
  struct GRvg_construct *const_list,
  struct EMSedge_rnd_info  *edge_rnd_info,
  IGRdouble  *xyzpt,
  struct EMStansf_rnd_info *tansf_rnd_info,
  struct GRid *fillet_composite
)
{
  IGRshort    *mattyp=NULL;
  IGRboolean  is_chamfer=0;
  IGRint      index=0, size=0, num_fillets=0;
  IGRlong     stat, msg_loc;
  IGRushort   loc_opts;
  IGRdouble   *mat=NULL, radius;
  IGRdouble   chttol, bastol;

  GRspacenum       os;
  GRobjid          *fillet_ids=NULL;
  struct GRid      tmpid, sfid1, sfid2;
  struct GRmd_env  *md_env=NULL;

  struct EMSpartolbasis     partolbasis;
  struct EMStansf_rnd_info  *p_tansf=NULL, *p_temp=NULL;

  BSrc   rc = FALSE;
  struct IGRbsp_surface    *p_srf=NULL, **fillet_geoms=NULL,
                           *sf1=NULL, *sf2=NULL;

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  md_env = const_list->env_info;
  os = md_env->md_id.osnum;
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;

  partolbasis.in_world = TRUE;
  partolbasis.mattyp = mattyp;
  partolbasis.mat = mat;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);

  radius = edge_rnd_info->radius;
  p_tansf = tansf_rnd_info;

  for(index=0; index<2; index++)
  {
    tmpid.objid = index==0 ? p_tansf->tansf1.objid : p_tansf->tansf2.objid;
    tmpid.osnum = os;

    size = 0;
    p_srf=NULL;

    EMgetvggeom (&msg_loc, mattyp, mat, &tmpid, 
                (IGRchar **)&p_srf, NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

    if(index==0)
    {
       p_tansf->tansf1.geom = p_srf;
       p_tansf->tansf1.tol = pwGetParTolSf( p_srf, bastol);
    }
    else
    {
       p_tansf->tansf2.geom = p_srf;
       p_tansf->tansf2.tol = pwGetParTolSf( p_srf, bastol);
    }

  } /* for(index.... */

  /* 
   * Generate a rolling ball fillet between the tangential
   * surface and the other defining surface of the edge being
   * rounded(fillet). Store this information in to the tansf_rnd_info
   * structure.  Input the defining surfaces for the
   * new fillet such that the u0/u1 of the new fillet matches
   * with the u0/u1 of that of the original fillet. This is the 
   * convention adopted. 
   */

  sf1 = p_tansf->tansf1.geom;
  sfid1.objid = p_tansf->tansf1.objid;
  sfid1.osnum = os;

  sf2 = p_tansf->tansf2.geom;
  sfid2.objid = p_tansf->tansf2.objid;
  sfid2.osnum = os;

  loc_opts = EMS_FIL_BOUND_SURF | EMS_FIL_SURF_ORIENTED;
             /* EMS_FIL_SINGLE_FILLET | EMS_FIL_DEFAULT_RHO; */

  if (edge_rnd_info->edge_config == EMSedge_convex)
  {
    loc_opts |= sf1->pos_orient ? EMS_FIL_NATURAL_NORMAL1 : NULL;
    loc_opts |= sf2->pos_orient ? EMS_FIL_NATURAL_NORMAL2 : NULL;
  }
  else
  {
    loc_opts |= sf1->pos_orient ? NULL : EMS_FIL_NATURAL_NORMAL1;
    loc_opts |= sf2->pos_orient ? NULL : EMS_FIL_NATURAL_NORMAL2;
  }

  if(options & EMS_RND_CHAMFER)
  {
    is_chamfer = TRUE;
    loc_opts &= ~EMS_FIL_DEFAULT_RHO;
  }
  else
  {
    loc_opts |= EMS_FIL_DEFAULT_RHO;
  }

  /*
   * Memory for outputs are being malloced by the function, we have to
   * free the memory.
   */
  if(!(edge_rnd_info->props & EMSfillet_is_variable_radius))
  {
    stat = EMcreate_fillet_surf1_to_surf2_const_rad (&msg_loc, 
           loc_opts, const_list, &sfid1, sf1, &sfid2, sf2,
           radius, 0.0, FALSE, NULL, NULL, NULL, NULL,
           NULL, NULL, xyzpt, is_chamfer, 0.0, &num_fillets, &fillet_ids,
           &fillet_geoms, NULL, NULL);
    EMerr_hndlr (!(1&stat&msg_loc) || num_fillets<1, *msg, EMS_E_Fail, wrapup);
  }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, wrapup);

  p_tansf->fillet.objid = fillet_ids[0];
  p_tansf->fillet.geom = fillet_geoms[0];
  fillet_geoms[0] = NULL;
  p_tansf->fillet.tol = pwGetParTolSf( p_tansf->fillet.geom, bastol);

  /*
   * Connect the new fillet that has been generated, to the fillet_composite.
   */
  stat = ConnectFilletToComposite( fillet_ids[0], fillet_composite);
  EMerr_hndlr(!(1&stat), *msg, EMS_E_Fail, wrapup);

  if(num_fillets > 1)
  {
    p_temp = p_tansf;

    for(index=1; index<num_fillets; index++)
    {
      p_temp->next = (struct EMStansf_rnd_info *)
             malloc ( sizeof(struct EMStansf_rnd_info));
      EMerr_hndlr (!p_temp->next, *msg, EMS_E_NoDynamicMemory, wrapup);

      p_temp = p_temp->next;

      EMtansf_rnd_info_init (p_temp);

      p_temp->props = EMSrnd_multi_fillet;
      p_temp->tansf1 = tansf_rnd_info->tansf1;
      p_temp->tansf2 = tansf_rnd_info->tansf2;

      p_temp->fillet.objid = fillet_ids[index];
      p_temp->fillet.geom = fillet_geoms[index];
      fillet_geoms[index] = NULL;
      p_temp->fillet.tol = pwGetParTolSf( p_temp->fillet.geom, bastol);

      /*
       * Connect the new fillet that has been generated, to the 
       * fillet_composite.
       */
      stat = ConnectFilletToComposite( fillet_ids[index], fillet_composite);
      EMerr_hndlr(!(1&stat), *msg, EMS_E_Fail, wrapup);
    }
  }


wrapup:
  if(fillet_ids) free(fillet_ids);
  if(fillet_geoms)
  {
    for(index=0; index<num_fillets; index++)
      if(fillet_geoms[index])
        BSfreesf(&rc, fillet_geoms[index]);

    free(fillet_geoms);
  }

  return (stat);
}


/*
 * DESCRIPTION
 * Here the EMSpypoint data from trimming is meaningfully converted to
 * topological interaction information on the fillet surface and put into
 * a list of EMSrnd_tpint_info structs.
 *
 * The uv parameters on the supporting surface are mapped to uv parameters
 * on the fillet surface and the corresponding interacting edge id.
 *
 * Aditya  01/18/96   Creation.
 */

static void GetTopoInfoOnFillet
(
  IGRlong *msg,
  struct GRmd_env *p_mdenv,
  struct EMStansf_rnd_info *tansf_info,
  struct EMSrnd_tpint_info **tpint_info,
  struct EMSpypoint *pypts,
  struct EMSdataselect *p_data,
  IGRint index
)
{
   IGRboolean             first=TRUE;
   IGRint                 span_inx=0;
   IGRlong                msg_loc=1, sts=1, props=0;
   IGRdouble              chttol=0, dist=0, u_par=0, v_par=0, par[2], dist1=0.0;
   IGRdouble              int_par[2], param, uvchttol, sqchttol, bastol;
   IGRpoint               point, dum_pt, seam_pt;
   struct IGRbsp_surface  *p_fillet=NULL, *p_sfgeom=NULL;
   GRobjid                edgeid=NULL_OBJID;
   GRspacenum             os;
   BSrc  rc;

   struct EMSsfintedpar      *p_parms=NULL;
   struct EMSpypoint         *p_pypt=NULL;
   struct EMSrnd_tpint_info  *p_tpint=NULL, *p_head=NULL;

   extern struct EMSrnd_tpint_info *EMtpint_info_malloc();

   BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
   BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
   sqchttol = chttol * chttol;

   *msg = EMS_S_Success;
   msg_loc = EMS_S_Success;
   os = p_mdenv->md_id.osnum;

   p_fillet = tansf_info->fillet.geom;

   p_sfgeom = index==0 ? tansf_info->tansf1.geom : tansf_info->tansf2.geom;
   uvchttol = (chttol/bastol)* 
              (index==0 ? tansf_info->tansf1.tol : tansf_info->tansf2.tol);

   for ( p_pypt = pypts; p_pypt; p_pypt = p_pypt->next)
   {
     if(!(p_parms = (struct EMSsfintedpar *)p_pypt->info))
       continue;

     props = 0;

     if(p_parms->edgeid == NULL_OBJID)
     {
       edgeid = NULL_OBJID;
       /*
        * If we don't have interaction information, such as cases where
        * the trim curve doesn't intersect an edge or end point of curve
        * is in area or hole and not on boundary, evaluate the curve at
        * the param in the pypt and create an interaction point node.
        */
       span_inx = p_pypt->span_inx;
       param = p_pypt->param;

       sts = EMeval_data (&msg_loc, p_mdenv, p_data,
                          span_inx, param, FALSE, point);
       EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, wrapup);

       memcpy(int_par, point, 2*sizeof(IGRdouble));
       /*
        * int_par now has the uv parameters on the surface at which the
        * curve endpoints lie.
        */
     }
     else
     {
       int_par[0] = p_parms->point[0];
       int_par[1] = p_parms->point[1];
       edgeid = p_parms->edgeid;

       if(pwIsEdSeam(edgeid, os))
         props |= EMSrnd_tpint_at_seam;
     }

     u_par = v_par = 0.0;

     /*
      * Evaluate the supporting surface of the fillet at the interaction
      * point to get an xyzpt. Project the xyzpt onto the fillet to get
      * the corresponding uv parameters of the interaction on the fillet.
      */

     BSsfeval (p_sfgeom, int_par[0], int_par[1],
               0,(IGRpoint *)point, &rc);
     EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

     BSmdistptsf (&rc, p_fillet, point, &u_par, &v_par, dum_pt, &dist);
     EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

     /*
      * If the fillet is closed and the interaction point is close to
      * its seam, then we have to decide on which side of the seam of
      * the fillet the interaction point is to fall.
      */
     if(p_fillet->v_phy_closed)
     {
       /*
        * Check if point is close to the seam.
        */
       par[0] = index==0 ? 0.0 : 1.0;
       par[1] = 0.0;

       BSsfeval( p_fillet, par[0], par[1], 0, (IGRpoint *)seam_pt, &rc);
       EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

       dist1 = BSdistptpts(&rc, seam_pt, point);
       if(dist1 < sqchttol)
       {
         /*
          * This interaction point is close to the seam of the fillet.
          * Which also means that the py_point classification can only
          * be start or stop.
          */
         dist = 0.0;
         u_par = index==0 ? 0.0 : 1.0;

         if(p_pypt->props & EMS_PYPT_ATSTART)
         {
           v_par = 0.0;
         }
         else if(p_pypt->props & EMS_PYPT_ATSTOP)
         {
           v_par = 1.0;
         }
         else
           EMerr_hndlr( TRUE, *msg, EMS_E_Fail, wrapup);
       }
     }

     EMerr_hndlr(dist>chttol, *msg, EMS_E_Fail, wrapup);

     if(p_head == NULL)
     {
       p_head = EMtpint_info_malloc(&msg_loc, 1);
       EMerr_hndlr(!(1&msg_loc) || !p_head, *msg,
                   EMS_E_NoDynamicMemory, wrapup);

       p_tpint = p_head;
     }
     else
     {
       p_tpint->next = EMtpint_info_malloc(&msg_loc, 1);
       EMerr_hndlr(!(1&msg_loc) || !(p_tpint->next), *msg,
                   EMS_E_NoDynamicMemory, wrapup);

       p_tpint = p_tpint->next;
     }

     p_tpint->int_edge = edgeid;
     p_tpint->int_pt[0] = index==0 ? 0.0 : 1.0 /*u_par*/;
     p_tpint->int_pt[1] = v_par;
     p_tpint->trim_info = p_pypt;
     p_tpint->iso_inx = index;
     p_tpint->props = props;

     if(first)
     {
       p_tpint->props |= EMSrnd_tpint_head;
       first = FALSE;
     }

     BSsfeval(p_fillet, u_par, v_par, 0,(IGRpoint *)&(p_tpint->xyzpt[0]), &rc);
     EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);
   } /* while(... */

   /*
    * Append the new list to the end of the incoming interaction points list.
    */

   if(!(*tpint_info))
     *tpint_info = p_head;
   else
   {
     p_tpint = *tpint_info;
     while(p_tpint->next)
      p_tpint = p_tpint->next;
     p_tpint->next = p_head;
   }

wrapup:
  if(!(1&*msg))
  {
    EMtpint_info_free (&msg_loc, p_head, MAXINT);
    p_head=NULL;
  }

  return;
}


static enum EMSedge_config EMget_edge_config (msg, md_env, edge)
IGRlong    *msg;
struct GRmd_env  *md_env;
GRobjid    edge;
{
  IGRlong stat, msg_loc;
  IGRboolean is_convex, is_neutral;
  IGRdouble angmeas;
  enum EMSedge_config edge_config;
  GRspacenum os;

  edge_config = EMSedge_undefined;
  *msg = EMS_S_Success;
  os = md_env->md_id.osnum;

  stat = om$send (msg = message EMSedge.EMchkconvex (&msg_loc,
               EMSchkconvex_global | EMSchkconvex_nextgeomsf,
               &md_env->md_env.matrix_type, md_env->md_env.matrix, 
               EMS_ZEROANGLE_DEG_MAX, &is_convex, &is_neutral, &angmeas),
               senderid = NULL_OBJID,
               targetid = edge, targetos = os);
  EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_EdgeError, wrapup);

  if (msg_loc == EMS_I_NotFound)
    edge_config = EMSedge_undefined;
  else
    edge_config = !is_neutral ? (is_convex ? EMSedge_convex : EMSedge_concave):
                   (fabs (2.0 - angmeas) < EMS_ZEROANGLE_DEG_MAX ?
                    EMSedge_neutral : (is_convex ? EMSedge_neutral_convex : 
                                       EMSedge_neutral_concave));
wrapup:
 
  return (edge_config);
}


/*
 Gets the smallest part of a given natural edge on a surface that is
 contained between an incoming and an outgoing intobj as the parameters
 on the fillet surface. Also returns the intobjs.
*/

static void get_part_nat_edge_split_info 
(
  IGRlong  *msg,
  struct GRmd_env *md_env,
  IGRdouble par_tol,
  IGRdouble xyz_tol,
  struct EMSinters *inters,
  GRobjid sfobj,
  IGRshort nat_edge_loc,
  GRobjid nat_edge,
  struct EMSintobj **bwd,
  struct EMSintobj **fwd,
  IGRdouble *bwd_v,
  IGRdouble *fwd_v
)
{
  IGRboolean is_equal, lower_bound, update;
  IGRshort mattyp;
  IGRint i, j, bndinx, endinx, sign;
  IGRlong stat_OM, msg_loc;
  IGRdouble endpts[2][2][2], tanvec[2][2], dumpt[2];
  IGRdouble bndpts[2][2], nat_edge_vec[2], discr_dotp[2];
  IGRdouble endv, bndv, dotp;
  IGRdouble *mat, disc_vec[2][2], other_endpts[2][2];
  struct EMSinters *p_inters;
  struct EMSintobj *p_intobj, *continuity_ptr[2], *cur_intobj;
  struct EMSsfintedpar *sfintedpars[2], *p_sfintedpar;

  extern IGRdouble EM2ddotp();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize local variables
   */

  mattyp = md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  switch (nat_edge_loc)
    {
    case FIRST:
      bndpts[FIRST][U] = 0.0;
      bndpts[FIRST][V] = 0.0;
      bndpts[SECOND][U] = 0.0;
      bndpts[SECOND][V] = 1.0;
      nat_edge_vec[U] = 0.0;
      nat_edge_vec[V] = 1.0;
      break;

    case SECOND:
      bndpts[FIRST][U] = 1.0;
      bndpts[FIRST][V] = 1.0;
      bndpts[SECOND][U] = 1.0;
      bndpts[SECOND][V] = 0.0;
      nat_edge_vec[U] = 0.0;
      nat_edge_vec[V] = -1.0;
      break;

    default:
      *msg = EMS_E_InvalidArg;
      goto ret_end;
    }
  continuity_ptr[FWD] = NULL;
  continuity_ptr[BWD] = NULL;

  discr_dotp[FIRST] = MAXDOUBLE;
  discr_dotp[SECOND] = MAXDOUBLE;

  /*
   * Obtain the list of EMSintobj pointers for the given surface. Every
   * intersection curve is looked up for being a candidate and the best
   * candidate retained. There are two positions that need to be filled.
   * One, the incoming edge and the other the outgoing one. The incoming
   * intersection will have it's end tangent yielding a positive cross-
   * product with the natural edge. The one with the highest (or lowest)
   * V value in such categories is the correct candidate. In the case
   * of a tie, the dot-product is used to decide. In this latter case,
   * the tangent that will ultimately yield the minimum area is chosen.
   * This translates to the minimum dot-product.
   */

  p_inters = inters;
  while (p_inters)
    if (IF_EQ_OBJID (p_inters->this_obj.objid, sfobj))
      break;
    else
      p_inters = p_inters->next;
  EMerr_hndlr (!p_inters, *msg, EMS_E_InvalidArg, ret_end);

  p_intobj = p_inters->cvs;
  while( p_intobj )
  {

    if (!(p_intobj->props & EMSintobj_tmpmarked))
    {
      EMgetendpts_uv (&msg_loc, &p_intobj->this_uvintobj, p_intobj->reversed,
                      2, endpts[START], endpts[STOP]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      
      for (i=START; i<=STOP; i++) 
      {
        endinx = i == START ? SECOND : FIRST;
        for (j=U; j<=V; j++)
          tanvec[i][j] = endpts[i][endinx][j] - endpts[i][!endinx][j];
      }
  
      p_sfintedpar = (struct EMSsfintedpar *) p_intobj->more_info;
      if (!p_sfintedpar)
      {
        p_sfintedpar = EMsfintedpar_malloc (&msg_loc, (IGRint)2);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        p_intobj->more_info = (IGRchar *) p_sfintedpar;
      }
  
      sfintedpars[START] = p_intobj->reversed ?
                            p_sfintedpar->next : p_sfintedpar;
      sfintedpars[STOP] = p_intobj->reversed ?
                            p_sfintedpar : p_sfintedpar->next;
      for (i=START; i<=STOP; i++)
      {
        if (IF_NULL_OBJID (sfintedpars[i]->edgeid))
        {
          EMgetincinfo (&msg_loc, OM_Gw_current_OS, NULL_OBJID, FALSE,
           endpts[i][FIRST], &mattyp, mat, sfobj,
           xyz_tol, par_tol, sfintedpars[i]);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
  
        if (check_on_edge (sfintedpars[i], nat_edge))
        {
          sign = EM2dcrossp ( &par_tol, nat_edge_vec, tanvec[i], NULL, NULL);
          if (sign == ZERO)
          {
            EMgetendpts_uv (&msg_loc, &p_intobj->this_uvintobj,
                            p_intobj->reversed, 1, 
                            i == START ? dumpt : endpts[i][SECOND], 
                            i == START ? endpts[i][SECOND] : dumpt);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
            endinx = i == START ? SECOND : FIRST;
            for (j=U; j<=V; j++)
              tanvec[i][j] = endpts[i][endinx][j] - endpts[i][!endinx][j];
  
            sign = EM2dcrossp ( &par_tol, nat_edge_vec, tanvec[i], NULL, NULL);
            if (sign == ZERO)
            {
              if ((nat_edge_loc == FIRST && endpts[i][FIRST][V] < 0.5) ||
                  (nat_edge_loc == SECOND && endpts[i][FIRST][V] > 0.5))
                sign = POSITIVE;
              else
                sign = NEGATIVE;
            }
          }
  
          endv = endpts[i][FIRST][V];
          if ((nat_edge_loc == FIRST && sign == POSITIVE) || 
              (nat_edge_loc == SECOND && sign == NEGATIVE))
          {
            bndinx = nat_edge_loc == FIRST ? FIRST : SECOND;
            lower_bound = FALSE;
          }
          else
          {
            bndinx = nat_edge_loc == FIRST ? SECOND : FIRST;
            lower_bound = TRUE;
          }
          bndv = bndpts[bndinx][V];
  
          if ((is_equal = fabs (endv - bndv) <= par_tol ? TRUE : FALSE ) || 
              (lower_bound == TRUE ? endv < bndv : endv > bndv))
          {
            dotp = EM2ddotp( tanvec[i], nat_edge_vec );
            /*
             * In case of is_equal == TRUE, and identical dot products, a
             * different criteria is required to break the tie of 'v' value.
             */
                update = FALSE;
                if( is_equal == TRUE && 
		      continuity_ptr[ sign == POSITIVE ? BWD : FWD ] &&
                         fabs( dotp - discr_dotp[ bndinx] ) < 0.001 )
                {
                   disc_vec[FIRST][0] = endpts[STOP][FIRST][0] -
					  endpts[START][FIRST][0];
                   disc_vec[FIRST][1] = endpts[STOP][FIRST][1] -
					  endpts[START][FIRST][1];
  
                   cur_intobj = continuity_ptr[ sign == POSITIVE
					     ? BWD : FWD ];
                   EMgetendpts_uv (&msg_loc, &cur_intobj->this_uvintobj,
				   cur_intobj->reversed,
                                   1, other_endpts[START], other_endpts[STOP]);
                   EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
                   disc_vec[SECOND][0] = other_endpts[STOP][0] -
					                other_endpts[START][0];
                   disc_vec[SECOND][1] = other_endpts[STOP][1] -
					                other_endpts[START][1];
  
                   if( EM2ddotp( disc_vec[0], nat_edge_vec ) <
                                EM2ddotp( disc_vec[1], nat_edge_vec ) )
                   {
                      bndpts[bndinx][V] = endv;
                      continuity_ptr[sign == POSITIVE ? BWD : FWD] = p_intobj;
                      discr_dotp[ bndinx ] = dotp;
                   }
                 }
                 else if ( is_equal == FALSE || dotp < discr_dotp[ bndinx ] )
                 {
                     bndpts[bndinx][V] = endv;
                     continuity_ptr[sign == POSITIVE ? BWD : FWD] = p_intobj;
                     discr_dotp[ bndinx] = dotp;
                 }
            }
        }
      }
    }
      p_intobj = p_intobj->next;
  }

  /*
   * Fill the output structure with the current information
   */

  *fwd = continuity_ptr[FWD];
  *bwd = continuity_ptr[BWD];
  *bwd_v = bndpts[FIRST][V];
  *fwd_v = bndpts[SECOND][V];

ret_end:
  EMWRAPUP (*msg, stat_OM, "get_part_nat_edge_split_info");
  return;
}



/*
   Description
     This function checks for the configuration of the current edge and
     that of the next interacting edge and returns TRUE if the combination
     is acceptable, else it returns FALSE.

     Returns FALSE for the following edge configuration combinations:
      . If the interacting edge/boundary configuration is concave/convex.
*/
static IGRint CheckInteractionEdgeConfig(msg, md_env, edge_id)
IGRlong *msg;
struct GRmd_env *md_env;
GRobjid edge_id;
{
    enum EMSedge_config edge_config;
    IGRint status=TRUE;
    IGRlong msg_loc;

    msg_loc = EMS_S_Success;

    if(edge_id != NULL_OBJID)
    {
      edge_config = EMget_edge_config (&msg_loc, md_env, edge_id);
      EMerr_hndlr (!(1&msg_loc),*msg, EMS_E_EdgeError, wrapup);

      if ((edge_config == EMSedge_convex) || 
          (edge_config == EMSedge_concave))
      {
        status = FALSE;
        EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, wrapup);
      }
    }

wrapup:

   return(status);
}

/*
 * Copy the relevant fields of the EMSedge_rnd_info into EMtansf_rnd_info
 * for the base fillet and connect EMtansf_rnd_info to EMSedge_rnd_info.
 */
static void CopyInfo
(
  struct EMStansf_rnd_info *tansf_rnd_info,
  struct EMSedge_rnd_info *edge_rnd_info
)
{
   tansf_rnd_info->tansf1.objid = edge_rnd_info->surf_id;
   tansf_rnd_info->tansf1.geom = edge_rnd_info->surf;
   tansf_rnd_info->tansf1.tol = edge_rnd_info->surf_tol;

   tansf_rnd_info->tansf2.objid = edge_rnd_info->com_surf_id;
   tansf_rnd_info->tansf2.geom = edge_rnd_info->com_surf;
   tansf_rnd_info->tansf2.tol = edge_rnd_info->com_surf_tol;

   tansf_rnd_info->fillet.objid = edge_rnd_info->fill_id;
   tansf_rnd_info->fillet.geom = edge_rnd_info->fill_surf;
   tansf_rnd_info->fillet.tol = edge_rnd_info->fill_surf_tol;

   tansf_rnd_info->fill_isocvs[0] = NULL;
   tansf_rnd_info->fill_isocvs[1] = NULL;

   tansf_rnd_info->props = EMSrnd_base_fillet;

   /*
    * Connect the EMStansf_rnd_info of the base fillet to the EMSedge_rnd_info.
    */
   edge_rnd_info->tansf_rnd_info = tansf_rnd_info;

   return;
}

static struct EMStansf_rnd_info *FilletExists
(
  GRobjid tansf1_id,
  GRobjid tansf2_id,
  IGRpoint xyzpt,
  struct EMStansf_rnd_info *tansf_info
)
{
  IGRlong msg_loc=EMS_S_Success;
  IGRdouble chttol=0.0, dist=0.0, mindist=MAXDOUBLE;
  IGRdouble u, v; 
  IGRpoint basept;

  struct EMStansf_rnd_info *p_tansf=NULL, *p_temp=NULL;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
      
  p_tansf = tansf_info;

  while(p_tansf)
  {
    if((tansf1_id == p_tansf->tansf1.objid && 
        tansf2_id == p_tansf->tansf2.objid) ||
       (tansf1_id == p_tansf->tansf2.objid &&
        tansf2_id == p_tansf->tansf1.objid))
    {
      /*
       * It is possible to generate split fillets between two surfaces.
       * We retain only one part during generation. Now we might need the
       * other parts. If a fillet has been generated that is close to the
       * test point, we return with success.
       */

      BSmdistptsf(&msg_loc, p_tansf->fillet.geom, xyzpt, &u, &v, basept, &dist);
      EMerr_hndlr(BSERROR(msg_loc), p_tansf, NULL, wrapup);

      if(dist <= mindist)
      {
        mindist = dist;
        p_temp = p_tansf;
      }
    }
    p_tansf = p_tansf->next;
  }

wrapup:

  return(p_temp);
}

/*
 * Create dummy interactions corresponding to "true" interaction points,
 * on the other iso such that they have the same v parameter but with
 * u parameter so that they lie on the other iso. Mark them as dummies.
 */
static IGRint CreateDummyInteractions
(
  struct EMStansf_rnd_info *p_tansf
)
{
  IGRint sts=1;
  IGRlong msg_loc=EMS_S_Success;
  BSrc rc=BSSUCC;
  struct EMSrnd_tpint_info *p_tpint=NULL, *p_next=NULL, *p_tmpint=NULL;

  extern struct EMSrnd_tpint_info *EMtpint_info_malloc();

  p_tpint = p_tansf->tpint_info;
  for(p_tpint = p_tansf->tpint_info; p_tpint; p_tpint = p_tpint->next)
  {
    if(p_tpint->props & (EMSrnd_tpint_deletable |
                         EMSrnd_tpint_coinc     |
                         EMSrnd_tpint_at_seam   |
                         EMSrnd_tpint_dummy     |
                         EMSrnd_tpint_nointers))
      continue;

    /*
     * If the next interaction is coincident with this one, we don't
     * need a dummy node.
     */
    if(p_tpint->next && (p_tpint->next->props & EMSrnd_tpint_coinc))
      continue;

    p_next = p_tpint->next;
    p_tmpint = EMtpint_info_malloc(&msg_loc, 1);
    EMerr_hndlr(!p_tmpint || !(1&msg_loc), sts, FALSE, wrapup);

    p_tmpint->int_edge = NULL_OBJID;
    p_tmpint->int_pt[0] = 1.0 - p_tpint->int_pt[0];
    p_tmpint->int_pt[1] = p_tpint->int_pt[1];

    BSsfeval(p_tansf->fillet.geom, p_tmpint->int_pt[0], p_tmpint->int_pt[1],
             0,(IGRpoint *)&(p_tmpint->xyzpt[0]), &rc);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);

    p_tmpint->props |= EMSrnd_tpint_dummy;
    p_tmpint->gen_tansf = NULL;
    p_tmpint->iso_inx = !p_tpint->iso_inx;
    p_tmpint->next = p_next;

    p_tpint->next = p_tmpint;
  }

wrapup:
  return(sts);
}

static IGRint SortInteractionsAlongFillet
(
  IGRint num_elem,
  struct EMSrnd_tpint_info **sorttpint,
  IGRint *isoinx
)
{
  IGRint inx=0, sts=TRUE, *p_indices=NULL, *p_isoinx=NULL;
  IGRdouble *p_vparam=NULL;
  BSrc rc;
  struct EMSrnd_tpint_info **p_tmpint=NULL;

  p_tmpint = (struct EMSrnd_tpint_info **)
             malloc(num_elem * sizeof(struct EMSrnd_tpint_info *));
  p_vparam = (IGRdouble *)malloc(num_elem * sizeof(IGRdouble));
  p_indices = (IGRint *)malloc(num_elem * sizeof(IGRint));
  p_isoinx = (IGRint *)malloc(num_elem * sizeof(IGRint));

  EMerr_hndlr(!p_tmpint || !p_vparam || !p_indices || !p_isoinx,
              sts, FALSE, wrapup);

  for(inx=0; inx<num_elem; inx++)
    p_vparam[inx] = sorttpint[inx]->int_pt[1];

  BStagsort(&rc, &num_elem, p_vparam, p_indices);
  EMerr_hndlr(BSERROR(rc),  sts, FALSE, wrapup);

  for(inx=0; inx<num_elem; inx++)
  {
    p_tmpint[inx] = sorttpint[p_indices[inx]];
    p_isoinx[inx] = isoinx[p_indices[inx]];
  }

  memcpy(sorttpint, p_tmpint, num_elem * sizeof(struct EMSrnd_tpint_info *));
  memcpy(isoinx, p_isoinx, num_elem * sizeof(IGRint));

wrapup:
  if(p_vparam) free(p_vparam);
  if(p_indices) free(p_indices);
  if(p_tmpint) free(p_tmpint);
  if(p_isoinx) free(p_isoinx);
  
  return(sts);
}


/*
 * CheckEndInteraction():
 * This function checks whether a given boundary list from trimming matches
 * the extents of the xyz curve from which was derived. This is done by
 * checking if the first and last points match the corresponding end points
 * of the xyz curve. Also returned is information about the end at which the
 * boundary point doesn't match in xyz. This info is not returned for seam
 * edges as the mapped uv curve would have been split across the seam.
 */

static IGRboolean CheckEndInteraction
(
  struct EMSdataselect *xyzdata,
  struct EMSpypoint * py,
  struct IGRbsp_surface * srf,
  IGRint *end_type
)
{
  IGRboolean atbdry=TRUE, found;
  IGRshort inx;
  IGRlong msg_loc;
  IGRdouble chttol;
  IGRpoint sfpt, endpts[2];
  struct EMSpypoint *p_pypt=NULL;
  struct EMSsfintedpar *p_par=NULL;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);  
  p_pypt = py;

  EMgetendpts_xyz (&msg_loc, NULL, NULL, xyzdata, FALSE, 1, 
                   endpts[START], endpts[STOP]);
  EMerr_hndlr (!(1&msg_loc), atbdry, FALSE, wrapup);

  found = FALSE;
  *end_type = 0;

  for(inx=0; inx<2; inx++)
  {
    /*if (!(p_pypt->props & (EMS_PYPT_ATSTART | EMS_PYPT_ATSTOP)))*/
    {
      BSsfeval (srf, p_pypt->point[U], p_pypt->point[V], 0,
                (IGRpoint *)sfpt, &msg_loc);
      EMerr_hndlr (BSERROR(msg_loc), atbdry, FALSE, wrapup);

      if (BSdistptpt (&msg_loc, sfpt, endpts[inx]) >= chttol)
      {
        found = TRUE;

        if(p_par = (struct EMSsfintedpar *) p_pypt->info)
        {
          if(!pwIsEdSeam(p_par->edgeid, OM_Gw_current_OS))
          {
            if(inx)
              *end_type |= EMSrnd_tpint_stop;
            else
              *end_type |= EMSrnd_tpint_start;
          }
        }
      }
    }

    /* Get the last node. */
    while(p_pypt->next)
      p_pypt = p_pypt->next;
  }

  EMerr_hndlr (found, atbdry, FALSE, wrapup);

wrapup:
  return (atbdry);
}
 

static IGRboolean check_on_edge (sfintedpar, edge)
struct EMSsfintedpar *sfintedpar;
GRobjid edge;
{
  IGRboolean stat_func;
  IGRushort dum_props;
  IGRint edge_returned, dum_num;
  IGRlong msg_loc, stat_OM;
  GRobjid nxtedge;

  stat_func = FALSE;

  if (!IF_NULL_OBJID (sfintedpar->edgeid))
    {
    if (sfintedpar->edgeid == edge)
      stat_func = TRUE;
    else if (sfintedpar->intloc == EMScvint_rtend ||
             sfintedpar->intloc == EMScvint_lfend)
      {
      stat_OM = EMgetnxtedges (&msg_loc, NULL, 
                 sfintedpar->edgeid, OM_Gw_current_OS,
                 sfintedpar->intloc == EMScvint_rtend ? TRUE : FALSE,
                 1, &edge_returned, &nxtedge, &dum_props, &dum_num);
      EMerr_hndlr (!(1&stat_OM&msg_loc) || !edge_returned, stat_func, FALSE,
       ret_end);

      if (nxtedge == edge)
        stat_func = TRUE;
      }
    }

ret_end:
  return (stat_func);
}

/*
 * Connects all the secondary fillets to the fillet_composite.
 */
static IGRint ConnectFilletToComposite
(
  GRobjid fillet_id,
  struct GRid *fillet_composite
)
{
  IGRint sts=1;
  IGRlong msg_loc=EMS_S_Success, index;

  index = MAXINT;

  sts = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                                                          fillet_composite,
                                                          &index),
            targetid = fillet_id,
            targetos = fillet_composite->osnum,
            senderid = NULL_OBJID);
   EMerr_hndlr (!(1 & sts & msg_loc), sts, FALSE, wrapup);

wrapup:
  return(sts);
}

static IGRint GetPointOnGeneratedSurface
(
  struct EMSrnd_tpint_info *tpint,
  struct EMStansf_rnd_info *this_tansf,
  struct EMStansf_rnd_info *other_tansf,
  IGRdouble *upar,
  IGRdouble *vpar
)
{
  IGRint sts=1;
  IGRdouble par[2], dist=0.0, mindist=MAXDOUBLE;
  IGRpoint xyzpt, sfpt, basept;

  BSrc rc;
  struct IGRbsp_surface *p_srf=NULL;

  struct EMSsfintedpar *p_parms=NULL;
  struct EMSpypoint *p_pypt=NULL;
  struct EMSrnd_tpint_info *p_tpint=NULL, *p_tmptp=NULL;

  p_pypt = tpint->trim_info;
  if(p_pypt)
    p_parms = (struct EMSsfintedpar *)p_pypt->info;

  if(p_parms)
  {
    par[0] = p_parms->point[0];
    par[1] = p_parms->point[1];
    p_srf = tpint->iso_inx==0 ?
            this_tansf->tansf1.geom : this_tansf->tansf2.geom;
  }
  else
  {
    par[0] = tpint->int_pt[0];
    par[1] = tpint->int_pt[1];
    p_srf = this_tansf->fillet.geom;
  }

  BSsfeval (p_srf, par[0], par[1], 0, (IGRpoint *)sfpt, &rc);
  EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);

  p_srf = other_tansf->fillet.geom;

  for(p_tpint = other_tansf->tpint_info; p_tpint; p_tpint=p_tpint->next)
  {
    /*
     * We need to check only those interactions that are on the same
     * isos on both the fillets.
     */
    if(tpint->iso_inx != p_tpint->iso_inx)
      continue;

    if(p_tpint->props & (EMSrnd_tpint_deletable |
                         EMSrnd_tpint_dummy |
                         EMSrnd_tpint_nointers |
                         EMSrnd_tpint_processed))
      continue;

    par[0] = p_tpint->int_pt[0];
    par[1] = p_tpint->int_pt[1];

    BSsfeval (p_srf, par[0], par[1], 0, (IGRpoint *)xyzpt, &rc);
    EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
 
    dist = BSdistptpts(&rc, sfpt, xyzpt);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);

    if(dist < mindist)
    {
      p_tmptp = p_tpint;
      mindist = dist;
    }
  }

  if(p_tmptp)
  {
    *upar = p_tmptp->int_pt[0];
    *vpar = p_tmptp->int_pt[1];
  }
  else
  {
    BSmdistptsf(&rc, p_srf, sfpt, upar, vpar, basept, &dist);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  }

wrapup:
  return(sts);
}

/*
  Reverse the surface orientation of the fillet surface in this_tansf so
  that is has the same orientaion as that in tansf_info.
*/
  

static IGRint OrientFillet
(
  struct GRmd_env *p_md_env,
  struct EMStansf_rnd_info *tansf_info,
  struct EMStansf_rnd_info **this_tansf
)
{
  IGRboolean reversed = FALSE;
  IGRint sts=1, num=0;
  IGRlong msg_loc=EMS_S_Success;
  IGRdouble filuv[2], baseuv[2], dist=0.0, dot_p=0.0, bastol=0.0;
  IGRdouble chttol=0.0;
  IGRvector filvec[1], basevec[1];
  IGRpoint xyzpt, dumpt;
  BSrc rc=BSSUCC;
  struct IGRbsp_surface *p_srf=NULL;
  PWosnum os;
  GRobjid fillet_id=NULL_OBJID;
  struct GRpost_info info;
  struct EMStansf_rnd_info *p_tansf=NULL, *p_next=NULL, *p_prev=NULL;

  chttol = pwActiveXYZChtTol();
  p_tansf = *this_tansf;

  while(p_tansf)
  {
    /*
     * Evaluate the normal to the surface on this and the previous fillet
     * at the uv points corresponding to the xyz point being sent in.
     */
    filuv[0] = filuv[1] = 0.0;
  
    BSsfeval (p_tansf->fillet.geom, filuv[0], filuv[1], 0,
              (IGRpoint *)xyzpt, &rc);
    EMerr_hndlr (BSERROR(rc), sts, FALSE, wrapup);
  
    BSmdistptsf (&rc, tansf_info->fillet.geom, xyzpt,
                 &baseuv[0], &baseuv[1], dumpt, &dist);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  
    /*
     * Map back to get good points if the distance is greater than chttol.
     * This ensures that the evaluation points on the two surfaces are as
     * close to each other as possible without the cost of finding minimum
     * distance between the surfaces.
     */
    if(dist > chttol)
    {
      BSmdistptsf (&rc, p_tansf->fillet.geom, dumpt,
                   &filuv[0], &filuv[1], dumpt, &dist);
      EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
    }
  
    BSsfevaln(tansf_info->fillet.geom, baseuv[0], baseuv[1],
              1, &num, dumpt, basevec, &rc);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  
    BSsfevaln(p_tansf->fillet.geom, filuv[0], filuv[1],
              1, &num, dumpt, filvec, &rc);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  
    dot_p = BSdotp( &rc, filvec[0], basevec[0]);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  
    if(dot_p > 0.0)
    {
      /*
       * Both the surfaces are oriented consistently.
       */
      p_tansf = p_tansf->next;
      continue;
    }
    else
      reversed = TRUE;
  
    os = p_md_env->md_id.osnum;
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
  
    /*
     * If the surfaces are inconsistently oriented, then we need to
     * reverse the surface v parametrization.
     */
    p_srf = p_tansf->fillet.geom;
  
    BSrevsf_v(&rc, p_srf);
    EMerr_hndlr(BSERROR(rc), sts, FALSE, wrapup);
  
    /*
     * We have to flip the pos_orient for this surface as we changing the
     * surface natural normal's orientation.
     */
    p_srf->pos_orient = !p_srf->pos_orient;
  
    fillet_id = p_tansf->fillet.objid;
    info.construct_flag = FALSE;
    p_tansf->fillet.geom = p_srf;
    p_tansf->fillet.tol = pwGetParTolSf( p_tansf->fillet.geom, bastol);
  
  
    sts = om$send(msg= message GRvg.GRpostabsg(&msg_loc, p_md_env, &info,
                                               (IGRchar *)p_srf,
                                               &p_tansf->fillet.objid),
                  senderid = NULL_OBJID,
                  targetid = fillet_id,
                  targetos = os);
    EMerr_hndlr(!(1&msg_loc&sts), sts, FALSE, wrapup);
  
    p_tansf = p_tansf->next;
  }

  /*
   * If the surface orientations are reversed, also reverse the list
   * as we want to maintain the flow direction between the geometry of
   * the surfaces and the data structures.
   */
  if(reversed)
  {
    p_prev = NULL;
    p_tansf = *this_tansf;
    p_next = p_tansf->next;

    while(p_next)
    {
      p_tansf->next = p_prev;
      p_prev = p_tansf;
      p_tansf = p_next;
      p_next = p_tansf->next;
    }
    p_tansf->next = p_prev;

    *this_tansf = p_tansf;
  }

wrapup:
  return(sts);
}

/*
 * For fillets that have an interaction across the seam, we have to 
 * delete the two seam intobjs generated by vertex processing as they
 * will be consumed by the secondary fillet.
 */

static IGRint ProcessSeamCross
(
  struct EMStansf_rnd_info *tansf_info,
  struct EMSinters *inters
)
{
  IGRint sts=1;
  IGRlong msg_loc=1;
  struct EMStansf_rnd_info *p_tansf=NULL;
  struct EMSinters *p_inter=NULL;
  struct EMSintobj *p_intobj=NULL;

  p_tansf = tansf_info;

  p_inter = inters;
  while(p_inter)
  {
    if(p_inter->this_obj.objid == p_tansf->fillet.objid)
    {
      /*
       * Unset the EMSinters_loopcreated property as we need to create
       * additional edges on this surface. This property is set during
       * vertex processing for closed fillets.
       */
      p_inter->props &= ~EMSinters_loopcreated;

      if(p_tansf->props & EMSrnd_seam_cross_fillet)
      {
      /*
       * This being a seam_cross_fillet, the secondary fillet will "consume"
       * the intersections on its seams. Therefore we have to mark these
       * intobjs as deletable.
       */
        p_intobj = p_inter->cvs;
        while(p_intobj)
        {
          if(p_intobj->this_obj_node->this_obj.objid ==
             p_intobj->other_intobj_node->this_obj_node->this_obj.objid 
             || (p_intobj->props & EMSintobj_seam))
          {
            p_intobj->props |= EMSintobj_deletable;
            /*
             * There is a bug in EMdelintobj_selective that gives an error
             * when an inters node with only deletable seam intobjs is passed
             * in. I am not touching that code, but rather fooling the
             * system by removing reference to its other node.
             */
            p_intobj->other_intobj_node = NULL;
          }
          p_intobj = p_intobj->next;
        }
        break;
      }
    }
    p_inter = p_inter->next;
  }

  EMdelintobj_selective(&msg_loc, NULL, inters, EMSintobj_deletable,NULL);
  EMerr_hndlr(!(1&msg_loc), sts, FALSE, wrapup);

wrapup:
  return(sts);
}

/*
  Function to map given xyzdata onto a surface and to trim the mapped uv
  curve against the loopset of the surface. Outputs the trim information
  and properties of the mapped curves and a count of the area crossings.
  Returns all the uv curves if the xyz curve maps to more than one uv 
  curve on the surface.

  Only mapping can be performed by sending trim_parms and py_bdrys as NULL.
  If only trimming is required, xyzdata should be NULL and uvcurves should
  be input in uvdata array of size num_cvs.
*/

static IGRboolean MapAndTrimCurve 
(
  IGRlong *msg,
  struct GRmd_env *md_env,
  struct IGRbsp_curve *xyzcv,
  GRobjid sfid,
  struct IGRbsp_surface *sfgeom,
  IGRint *num_cvs,
  struct EMSdataselect **uvdata,
  IGRint **count,
  IGRint **p_props,
  IGRint **p_types,
  struct EMSsfintedpar ***trim_parms,
  struct EMSpypoint ***py_bdrys
)
{
  IGRboolean found = FALSE;
  IGRshort mattyp=0;
  IGRint inx=0, num_uvcv=0, *p_uvcv_props=NULL, *p_xyzcv_type=NULL;
  IGRlong stat=1, msg_loc;
  IGRdouble bastol, uvchttol, sftol, chttol;

  GRspacenum os;
  struct EMSpartolbasis partolbasis;
  OM_S_CHANSELECT chan_to_loopset;
  struct EMSdataselect *p_uvdata=NULL;
 
  PWresult PWsts;
  struct PWcvdata *p_cvdata=NULL, *p_uvcv=NULL;
  struct PWsfdata sfdata;

  PWsts=PW_K_Success;
  *msg = EMS_S_Success;
  partolbasis.in_world = TRUE;
  mattyp = md_env->md_env.matrix_type;
  os = md_env->md_id.osnum;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

  sftol = pwGetParTolSf( sfgeom, bastol);

  if(xyzcv)
  {
    p_cvdata = (struct PWcvdata *) malloc (sizeof(struct PWcvdata));
    EMerr_hndlr (!p_cvdata, *msg, EMS_E_Fail, wrapup);

    p_cvdata->datatype = PWcvdata_bspcv;
    p_cvdata->data.p_bspcv = xyzcv;

    sfdata.datatype = PWsfdata_bspsf;
    sfdata.data.p_bspsf = sfgeom;

    PWsts = pwMapXyzCvToUvOfSf( p_cvdata, &sfdata, chttol,
                                &num_uvcv, &p_uvcv,
                                &p_uvcv_props, &p_xyzcv_type);
    if(p_cvdata) free(p_cvdata);
    p_cvdata = NULL;
    EMerr_hndlr (IsError(PWsts) || !num_uvcv, *msg, EMS_E_Fail, wrapup);

    p_uvdata = (struct EMSdataselect *)
              malloc(num_uvcv * sizeof(struct EMSdataselect));
    EMerr_hndlr (!p_uvdata, *msg, EMS_E_NoDynamicMemory, wrapup);

    for(inx=0; inx<num_uvcv; inx++)
    {
      pwMoveCvdataEMS ( &p_uvcv[inx], &p_uvdata[inx]);
    }
    *num_cvs = num_uvcv;
    if(uvdata)
      *uvdata = p_uvdata;

    if(p_props)
      *p_props = p_uvcv_props;
    else if(p_uvcv_props)
    {
      free(p_uvcv_props);
      p_uvcv_props = NULL;
    }

    if(p_types)
      *p_types = p_xyzcv_type;
    else if(p_xyzcv_type)
    {
      free(p_xyzcv_type);
      p_xyzcv_type = NULL;
    }
  }

  if(trim_parms || py_bdrys)
  {
    EMerr_hndlr (!num_cvs, *msg, EMS_E_InvalidArg, wrapup);

    if(count)
    {
      *count = (IGRint *)malloc(*num_cvs * sizeof(IGRint));
      EMerr_hndlr (!(*count), *msg, EMS_E_NoDynamicMemory, wrapup);
    }

    if(trim_parms)
    {
      *trim_parms = (struct EMSsfintedpar **)
                    malloc(*num_cvs * sizeof(struct EMSsfintedpar *));
      EMerr_hndlr (!(*trim_parms), *msg, EMS_E_NoDynamicMemory, wrapup);
    }

    if(py_bdrys)
    {
      *py_bdrys = (struct EMSpypoint **)
                    malloc(*num_cvs * sizeof(struct EMSpypoint *));
      EMerr_hndlr (!(*py_bdrys), *msg, EMS_E_NoDynamicMemory, wrapup);
    }

    partolbasis.mattyp = &md_env->md_env.matrix_type;
    partolbasis.is_valid = TRUE;
    partolbasis.mat = md_env->md_env.matrix;
    uvchttol = pwGetParTolSf( sfgeom, chttol);
    partolbasis.tol = uvchttol;

    for(inx=0; inx<*num_cvs; inx++)
    {
      p_uvdata = &(*uvdata)[inx];
      /*
       * Removed trim option 'EMS_INTER_BDRYISAREA'.
       */
      stat = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                                    p_uvdata, &partolbasis, 
                                    NULL, &(*count)[inx],
                                    py_bdrys ? &(*py_bdrys)[inx] : NULL,
                                    trim_parms ? &(*trim_parms)[inx] : NULL),
                      p_chanselect = &chan_to_loopset,
                      senderid = sfid);
      EMerr_hndlr (!(1 & stat & msg_loc), *msg, EMS_E_Fail, wrapup);
    }
  }
    
  wrapup:
    if(!(1 & *msg & stat))
    {
      if(py_bdrys)
      {
        EMpypoint_free(*py_bdrys, 0);
        *py_bdrys = NULL;
      }
      if(trim_parms)
      {
        EMsfintedpar_free(*trim_parms, 0);
        *trim_parms = NULL;
      }
      if(*count)
      {
        free(*count);
        *count=NULL;
      }
    }
  return (found);
}

/*
  Find all the surfaces in the secondary fillets list that don not have
  any intersections on them (i.e. those that are not in  the inters list).
  Disconnect and delete all such surfaces from the fillet composite as 
  they will not be part of the final rounded model.
*/

static IGRint RemoveFilletSfs
(
  struct GRmd_env *md_env,
  struct GRid *fillet_composite,
  struct EMStansf_rnd_info *tansf_info,
  struct EMSinters *p_filletinters
)
{
  IGRboolean found;
  IGRlong msg_loc;
  IGRint sts=1;
  GRspacenum os;
  GRobjid fillet_id=NULL_OBJID;
  struct EMStansf_rnd_info *p_tansf=NULL, *p_prev=NULL;
  struct EMSinters *p_inters=NULL;

  msg_loc = EMS_S_Success;

  p_prev = tansf_info;
  for(p_tansf = tansf_info; p_tansf; p_prev = p_tansf, p_tansf = p_tansf->next)
  {
     fillet_id = p_tansf->fillet.objid;
     found = FALSE;
     if(p_filletinters)
       os = p_filletinters->this_obj.osnum;
     else
       os = OM_Gw_current_OS;

     for(p_inters = p_filletinters; p_inters; p_inters = p_inters->next)
     {
       if(fillet_id == p_inters->this_obj.objid)
       {
         found = TRUE;
         break;
       }
     }

     /*
      * This fillet was not in the inters list. Disconnect it from the
      * fillet composite.
      */
     if(!found)
     {
        sts = om$send( msg = message GRconnector.GRdisconn( &msg_loc,
                                                            fillet_composite),
                       senderid = NULL_OBJID,
                       targetid = fillet_id,
                       targetos = os);
        EMerr_hndlr(!(1&sts&msg_loc), sts, FALSE, wrapup);

        /*
         * Delete only the surface object here. The node is removed by
         * cleanup later.
         */
        sts = om$send( msg = message GRgraphics.GRdelete( &msg_loc, md_env),
                       senderid = NULL_OBJID,
                       targetid = fillet_id,
                       targetos = os);
        EMerr_hndlr(!(1&sts&msg_loc), sts, FALSE, wrapup);

        p_tansf->fillet.objid = NULL_OBJID;
     }
  }

wrapup:
  return(sts);
}

static IGRint SetFwdBwdPointers
(
  struct EMSrnd_tpint_info *p_tpint,
  struct EMSrnd_tpint_info *p_nextintpt,
  struct EMSintobj *p_intobj,
  IGRint iso_inx
)
{
  /*
   * Set the fwd and bwd pointers for this intobj, from the
   * incidence info available in the EMSrnd_tpint_info nodes.
   */

  if(iso_inx == 0)
  {
    if((p_tpint->props & EMSrnd_tpint_stop) && p_tpint->intobj)
    {
      p_intobj->bwd = p_tpint->intobj;
      p_intobj->props |= EMSintobj_bwd_connectuv;
      p_intobj->props &= ~EMSintobj_bwd_noconnectuv;

      p_tpint->intobj->fwd = p_intobj;
      p_tpint->intobj->props |= EMSintobj_fwd_connectuv;
      p_tpint->intobj->props &= ~EMSintobj_fwd_noconnectuv;
    }

    if((p_nextintpt->props & EMSrnd_tpint_start) && p_nextintpt->intobj)
    {
      p_intobj->fwd = p_nextintpt->intobj;
      p_intobj->props |= EMSintobj_fwd_connectuv;
      p_intobj->props &= ~EMSintobj_fwd_noconnectuv;

      p_nextintpt->intobj->bwd = p_intobj;
      p_nextintpt->intobj->props |= EMSintobj_bwd_connectuv;
      p_nextintpt->intobj->props &= ~EMSintobj_bwd_noconnectuv;
    }
  }
  else
  {
    if((p_tpint->props & EMSrnd_tpint_start) && p_tpint->intobj)
    {
      p_intobj->fwd = p_tpint->intobj;
      p_intobj->props |= EMSintobj_fwd_connectuv;
      p_intobj->props &= ~EMSintobj_fwd_noconnectuv;

      p_tpint->intobj->bwd = p_intobj;
      p_tpint->intobj->props |= EMSintobj_bwd_connectuv;
      p_tpint->intobj->props &= ~EMSintobj_bwd_noconnectuv;
    }

    if((p_nextintpt->props & EMSrnd_tpint_stop) && p_nextintpt->intobj)
    {
      p_intobj->bwd = p_nextintpt->intobj;
      p_intobj->props |= EMSintobj_bwd_connectuv;
      p_intobj->props &= ~EMSintobj_bwd_noconnectuv;

      p_nextintpt->intobj->fwd = p_intobj;
      p_nextintpt->intobj->props |= EMSintobj_fwd_connectuv;
      p_nextintpt->intobj->props &= ~EMSintobj_fwd_noconnectuv;
    }
  }

  return 1;
}

end implementation EMSsfrndbool;
