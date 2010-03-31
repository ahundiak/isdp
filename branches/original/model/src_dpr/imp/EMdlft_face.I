/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdlift;

#include "EMS.h"
#include <stdio.h>
%safe
#include <math.h>
%endsafe
#include "EMSlmdef.h"
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emsmapdef.h"
#include "EMSopt.h"
#include "emsedgedef.h"
#include "bsicmpcvoff.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#include "emslpinitdef.h"
#include "emsmacros.h"
#include "bssfeval.h"
#include "bssfarrevn.h"
#include "bsptcvgen.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"

from EMSsubbs      import    EMpartolbasis;
from EMSboundary   import    EMget_edges, EMget_objid, EMcheck_props,
                             EMtree_traverse;
from EMSloopset    import    EMget_loops, EMtreemod, EMnesting;
from EMSloop       import    EMget_props, EMset_props, EMgivenestinfo,
                             EMtreemod; 
from EMSedge       import    EMget_props_type, EMget_bcxyz_geom, EMget_props;

extern OMuword OPP_EMSplane_class_id, OPP_EMSsolid_class_id;

%safe
static int EMsm_merge_open_loops();
%endsafe

struct EMSmerge_info
{
 GRobjid edgeid;
 IGRboolean atstart;
 struct EMSlft_edmtch_info lfted;
};

method EMlift_face (
        IGRlong                         *EMmsg;
        struct  GRmd_env                *md_env;
        struct  GRvg_construct          *construct_list;
        struct  EMSdlft_info            *dlift_info;
        IGRushort               dis_options;
        GRobjid                         **display_ids;
        IGRint                          *display_count)
/*

History  

  Hari  07/06/95      Fix for the intel crash. ABW problem. TR#119525291

  Sudha 06/23/93      Modified for BSprototype ansification

  SM    04/11/92      My earlier fix, does not handle lift with some draft
                      angle to loops containing seams. Major code changes 
                      are required to handle this. Untill then, I have added
                      code to check whether the drafted loopset is valid
                      (no open loops and no external C loops). If invalid
                      deactivate is done at the end.
  SM    04/02/92      Loops containing seams of original surface were ending
		      up as open on the lifted surface (plane). Added code
		      to detect and merge.
  03/31/92    DLB Added check to ensure all edge draft angles are in a 
                    consistent direction.  
  03/03/92    DLB Added EFfix_parent_child_relationship call to fix up
                  assoc graph when an associative surface is removed.
  DLB   01/07/91      Turn off ACTIVE bit in loops on surf removed.
  DLB   09/09/91      Added display parameters.
  DLB   06/29/91      Connect drafted surface to MAXINT.
  Jack  03-June-91    Modified to work with 2.0.1 Horizon Loops.  Also
                      changed error message to specify this method.
  Inasu 19/04/90      Fix for TR 90N0601.
  BL    10/12/89      Replaced the origin surface by the drafted surface 
                      in struct dlist_info for further use.
  RC    05/03/89      While calculating rsdraft_angle, use ed_draft_angle
                      only if it has a offset code of BSCONSTOFF. 
                      The edges with offset code other than BSCONSTOFF
                      will have junk draft angle values.
  SM    28-Mar-89     Argument change in EMget_loops_for_imposition.
                      Function renamed as EMget_mapped_data().
  DLB   07/26/88      Added code to set EMSIS_INACTIVE bit in surface props.
  RC    03/17/88      Creation Date

*/

{
  struct EMSlft_edv0v1_info    edv0v1_info;
  struct EMSlft_edmtch_info    ed_u0s, ed_u1s, last_ed_u1s, 
                               lp_ed_u0s, lp_ed_u1s;
  struct EMSlft_edcn_info      ed_cn_info;
  struct EMSlft_edsp_info      ed_sp_info;
  struct EMSlft_lpmod_info     lps_mod_info;
  struct EMSlft_sfrmvd_info    sfrmvd_info;

  union  EMSssi_table          ssi_table;
  struct EMSlftssi_table    *my_info;

  struct GRid                  sf_GRid, dsf_GRid, my_GRid, clip_ls, 
                               sf_owner_GRid, ed_GRid,
                               next_ed_GRid, old_ed_GRid, new_ed_GRid, 
                               cm_ed_GRid, cm_ed_sf_GRid;

  struct EMSnest_info          nesting;
  struct EMSpartolbasis        partolbasis;
  struct EMSdlft_lp_info       *cur_lp_info;
  struct IGRbsp_surface        *sf_geom, *dsf_geom, *cm_ed_sfgm;
  struct IGRbsp_curve          pt_crv, *eds_oldgm, **eds_oldgm_ptr,
                               **deds_gm, *old_crv, cm_ed_oldgm;

  struct EMSdlft_ed_info       *cur_ed_info, *old_ed_info, pt_ed_info;

  struct GRsymbology           dsf_symb;
  struct IGRdisplay            *nsf_dis_att;

  OM_S_CHANSELECT              to_comps_chan, to_owners_chan, cm_ed_chan,
                               lp_ed_chan, sf_ls_chan, ls_sf_chan,
                               to_outter, ls_lp_chan;

  enum  GRdpmode               Display_Mode;
  IGRdouble                    u, v, dvec_dot_snrml, 
                               *draft_angles, rsdraft_angle,
                               *mlc_draft_angles, junction_pt[3], 
                               from_pt[3], to_pt[3], offset_vec[3], 
                               pt_poles[6], pt_knots[4], sf_pt[3], 
                               sf_nrml[3], udraft_angle;

 extern  IGRdouble  fabs();

IGRlong                      OM_stat;
IGRlong   mthd_stat, rc, sf_size, owner_index;

  IGRint                       INITIAL_SIZE, 
                               BUF_INC, dsf_lps_arrsz, sf_lps_arrsz, 
                               cur_lp, num_lp_eds, cur_ed,
                               eds_oldgm_arrsz, draft_angles_arrsz, 
                               off_codes_arrsz, deds_gm_arrsz,
                               *table, table_arrsz, num_lp_deds, stat, 
                               num_imp_lps, i, 
                               next_ed_idx, 
                               lp_ed_types_arrsz, lp_ded_types_arrsz,
                               array_size, work_ed = 1,
                               *mlc_off_codes, *off_codes;

  OMuint                       num_cm_ed, composite_idx;
  extern IGRint                EMget_mapped_data();
  
  OMuword                      sf_classid, my_classid;

  IGRushort            lp_props, options, ls_props, ed_props;

  IGRshort                     ed_constraint, nsf_level;

  GRobjid                      *dsf_lps, *sf_lps, sf_ls_id, 
                               dsf_ls_id, lp_parent;

  IGRboolean                   status, right_side, create_dsf,
                               cntinue, overlap_exists, last_ed_sf_created, 
                               is_sf_sp_plane, first_ed_sf_created, 
                               merged = FALSE, isinvalid = FALSE;

  IGRuchar             *lp_ed_types, *lp_ded_types;



 extern void   EFdraftcv(),
                               EFmemory_allocation(), EFcreate_lft_sf1(),
                               EFtrim_cm_ed_sf1(), 
                               EFdoes_new_sf_overlaps_cm_ed_sf (),
                               EFget_drafted_sf_geom (),
                               EFrmv_inacteds_actcm_eds ();

 void EFget_offset_edge_cv_type(), EFget_offset_fillet_cv_type();
 struct EMSmerge_info *merge_info = NULL;
 IGRint		num_merge_info = 0;

  /* ************************************************************ */

OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

ed_cn_info.num_eds = ed_cn_info.array_size = 0;
ed_cn_info.ed_ids = NULL;

ed_sp_info.num_eds = ed_sp_info.eds_arrsz = 0;
ed_sp_info.num_sp_eds = ed_sp_info.sp_eds_arrsz = 0;
ed_sp_info.ed_ids = ed_sp_info.sp_eds = NULL;
ed_sp_info.sp_eds_pred = NULL;

edv0v1_info.num_eds = edv0v1_info.array_size = 0;
edv0v1_info.ed_ids = NULL;

ed_u0s.num_eds = ed_u0s.array_size = 0;
ed_u0s.ed_ids = ed_u0s.sf_ids = NULL;

ed_u1s.num_eds = ed_u1s.array_size = 0;
ed_u1s.ed_ids = ed_u1s.sf_ids = NULL;

last_ed_u1s.num_eds = last_ed_u1s.array_size = 0;
last_ed_u1s.ed_ids = last_ed_u1s.sf_ids = NULL;

lp_ed_u0s.num_eds = lp_ed_u0s.array_size = 0;
lp_ed_u0s.ed_ids = lp_ed_u0s.sf_ids = NULL;

lp_ed_u1s.num_eds = lp_ed_u1s.array_size = 0;
lp_ed_u1s.ed_ids = lp_ed_u1s.sf_ids = NULL;

sf_geom = dsf_geom = NULL;

lps_mod_info.num_sfs = lps_mod_info.sf_arrsz = 0;
lps_mod_info.num_lps_added = lps_mod_info.num_lps_rmvd = 0;
lps_mod_info.lps_added_arrsz = lps_mod_info.lps_rmvd_arrsz = 0;
lps_mod_info.sf_ids = lps_mod_info.lp_added_ids = NULL;
lps_mod_info.lp_rmvd_ids = NULL;
lps_mod_info.lps_added_prsf = lps_mod_info.lps_rmvd_prsf = NULL;

sfrmvd_info.num_compsf = sfrmvd_info.compsf_arrsz = 0;
sfrmvd_info.num_sf_rmvd = sfrmvd_info.sf_arrsz = 0;
sfrmvd_info.compsf_ids = sfrmvd_info.sf_ids = NULL;
sfrmvd_info.num_sf_prcompsf = sfrmvd_info.sf_idx = NULL;

eds_oldgm = NULL;
eds_oldgm_ptr = NULL;
deds_gm = NULL;

mlc_draft_angles = NULL;
mlc_off_codes = NULL;
table = NULL;

dsf_lps = NULL;
sf_lps = NULL;

lp_ed_types = lp_ded_types = NULL;

last_ed_sf_created = FALSE;      /* Initially set to false */
dsf_lps_arrsz = sf_lps_arrsz = 0;
eds_oldgm_arrsz = 0;
draft_angles_arrsz = 0;
off_codes_arrsz = 0;
deds_gm_arrsz = 0;
table_arrsz = 0;
lp_ed_types_arrsz = 0;
lp_ded_types_arrsz = 0;

pt_crv.poles = pt_poles;
pt_crv.weights = NULL;
pt_crv.knots = pt_knots;
pt_crv.bdrys = NULL;

clip_ls.objid = NULL_OBJID;
sf_GRid = dlift_info->sf_GRid;
my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;
dsf_GRid.osnum = OM_Gw_current_OS;

me->operation_type = EMS_LIFT_FACE_W_DRAFT;

OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 
OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

{ /*INTENTIONAL BLOCK*/
  IGRboolean dont_have_it;

  OM_stat = EFwork_the_display(&mthd_stat, dis_options,
                               sf_GRid.objid,
                               display_ids, display_count,
                               &dont_have_it);
  if (!(1 & OM_stat & mthd_stat)) goto wrapup;

  if (dont_have_it)
  {
    /*
     * Erase the common edge's surface.
     */
    Display_Mode = GRbehe;
    OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                            &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &Display_Mode,
                            &md_env->md_id),
                      targetid = sf_GRid.objid,
                      targetos = sf_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  }
}

/*
 * Extract the surface's geometry. This will be used to
 * extract its edges geometry.
 */

ex$message(msgnumb = EMS_I_ModifyingSurface)
OM_stat = om$send (msg = message GRvg.GRgetsize(&mthd_stat,
                      &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                      &sf_size),
                    targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup); 

sf_geom = (struct IGRbsp_surface *) om$malloc ( size = sf_size);
EMerr_hndlr (!sf_geom,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

OM_stat = om$send ( msg = message GRvg.GRgetgeom(&mthd_stat,
                     &md_env->md_env.matrix_type, md_env->md_env.matrix,
                     (IGRchar *) sf_geom),
                    targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup); 

u = v = 0.5;
BSsfarrevn (&rc, sf_geom, 1, &u, 1, &v, sf_pt, sf_nrml);
EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

dvec_dot_snrml = BSdotp (&rc, dlift_info->draft_vec, sf_nrml);
EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

/*
 * o Get the drafted surface geometry.
 * o Construct EMSplane object with the drafted_geom.
 * o connect the drafted surface to me.
 */

OM_stat = om$get_classid (objid = sf_GRid.objid, osnum = sf_GRid.osnum,
                          p_classid = &sf_classid);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = om$is_ancestry_valid (subclassid = sf_classid,
                                superclassid = OPP_EMSplane_class_id);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

is_sf_sp_plane = (OM_stat == OM_S_SUCCESS) ? TRUE : FALSE;

EFget_drafted_sf_geom ( &rc, sf_geom, is_sf_sp_plane, 
             dlift_info->draft_vec, dlift_info->mx_exlp_dangle, 
             &dsf_geom);
EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

/*
 * The drafted surface is of class EMSplane and should have the
 * same symbology as that of original surface.
 */

OM_stat = om$send (msg = message GRvg.GRgetsymb (&mthd_stat, &dsf_symb),
                    targetid = sf_GRid.objid);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_OMerror,wrapup);

nsf_level = construct_list->level;
nsf_dis_att = construct_list->display;

construct_list->newflag = FALSE;
construct_list->level = dsf_symb.level;
construct_list->display = &dsf_symb.display_attr;
construct_list->geometry = (IGRchar *) dsf_geom;

OM_stat =  om$construct (classid = OPP_EMSplane_class_id,
                         p_objid = &dsf_GRid.objid, 
                         msg = message GRgraphics.GRconstruct (
                          construct_list) );
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

/* if the plane has a loopset at this point we want to delete it
   since we will create a new one later.
 */
OM_stat = om$send(msg = message EMSsurface.EMdelete_boundary(
                                      &mthd_stat,
                                      md_env,
                                      &(md_env->md_id),
                                      &dsf_GRid),
                  targetid = dsf_GRid.objid,
                  targetos = dsf_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

construct_list->level = nsf_level;
construct_list->display = nsf_dis_att;

owner_index = OM_K_MAXINT;
OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                    &my_GRid, &owner_index),
                   targetid = dsf_GRid.objid);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

if (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE) owner_index = 2;
else owner_index = 1;

/* get partolbasis */
status = EFsspbtol_by_geom(&mthd_stat, dsf_geom, &partolbasis);
EMerr_hndlr (!status, *EMmsg, EMS_E_SurfaceError, wrapup);

partolbasis.in_world = partolbasis.is_valid = TRUE;
partolbasis.mattyp = &md_env->md_env.matrix_type;
partolbasis.mat = md_env->md_env.matrix;

INITIAL_SIZE = BUF_INC = dlift_info->num_lps;
EFmemory_allocation (&rc, (IGRchar **) &dsf_lps, 
                      dlift_info->num_lps, &dsf_lps_arrsz, 
                      sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

EFmemory_allocation (&rc, (IGRchar **) &sf_lps, 
                      dlift_info->num_lps, &sf_lps_arrsz, 
                      sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

/*
 * allocate space to save edges/old_new_cm_ed ids.
 * At the most there will be dlift_info->num_ed_infos
 * edges and there will be 4 objid entries per edge.
 */

edv0v1_info.array_size = (dlift_info->num_ed_infos) * 4;
edv0v1_info.ed_ids = (GRobjid *) om$malloc (
             size = edv0v1_info.array_size * sizeof(GRobjid) );
EMerr_hndlr (!edv0v1_info.ed_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

/*
 * For Each loop,
 *  o Get the geometry of all of its edges in the loop's
 *    logical direction.
 *  o Offset the loop.
 *  o For each edge of the loop:
 *    o Check if it has a common edge. 
 *      If so, and the constraint is not EMS_LC_AUTO_COINCIDENCE,
 *      construct a drafted surface. If the constraint is
 *      EMS_LC_AUTO_COINCIDENCCE, check if the drafted surface
 *      to be constructed will overlap the common edge's surface.
 *      If so, trim the common edge's surface with the boundary of
 *      drafted surface.
 *    o Perform edge matching.
 */
merge_info = (struct EMSmerge_info *) om$malloc(size = dlift_info->num_lps
             * 2 * sizeof(struct EMSmerge_info));
EMerr_hndlr (!merge_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

for(i=0; i<2*dlift_info->num_lps; i++)
 {
  merge_info[i].edgeid = NULL_OBJID;
  merge_info[i].atstart = FALSE;
  merge_info[i].lfted.num_eds = merge_info[i].lfted.array_size = 0;
  merge_info[i].lfted.ed_ids =  merge_info[i].lfted.sf_ids = NULL;
 }

for (cur_lp = 0; cur_lp < dlift_info->num_lps; cur_lp++)
{
  IGRboolean cur_lp_seam = FALSE;
  OMuint count;
  IGRushort edprops = NULL;

  cur_lp_info = &dlift_info->lps_info[cur_lp];
  num_lp_eds = cur_lp_info->num_eds;
  lp_ed_u0s.num_eds = 0;
  lp_ed_u1s.num_eds = 0;

  cur_lp_seam = FALSE;

  OM_stat = om$get_channel_count(objid = cur_lp_info->lp_GRid.objid, 
            p_chanselect = &lp_ed_chan, count = &count);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_LoopError,wrapup);

  for (cur_ed = 0; cur_ed < count; cur_ed++)
   {
    OM_stat = om$send (msg = message EMSedge.EMget_props (
                        &mthd_stat, &edprops), p_chanselect = &lp_ed_chan, 
              senderid = cur_lp_info->lp_GRid.objid, 
              from = cur_ed, to = cur_ed);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);
    if(edprops & EMED_SEAM)
     {
      cur_lp_seam = TRUE;
      break;
     }
   }

  INITIAL_SIZE = BUF_INC = num_lp_eds;
  array_size = eds_oldgm_arrsz;

  EFmemory_allocation (&rc, (IGRchar ***) &eds_oldgm_ptr, num_lp_eds, 
                       &array_size, sizeof(struct IGRbsp_curve *), 
                        INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);
  
  EFmemory_allocation (&rc, (IGRchar **) &eds_oldgm, num_lp_eds, 
                       &eds_oldgm_arrsz, sizeof(struct IGRbsp_curve), 
                        INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);
  
  for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++)
  {
    eds_oldgm_ptr[cur_ed] = &eds_oldgm[cur_ed];
    cur_ed_info = &cur_lp_info->eds_info[cur_ed];
    ed_GRid = cur_ed_info->ed_GRid;
        
    eds_oldgm[cur_ed].poles = NULL;
    eds_oldgm[cur_ed].knots = NULL;
    eds_oldgm[cur_ed].weights = NULL;
    eds_oldgm[cur_ed].bdrys = NULL;

    OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (
                        &mthd_stat, &md_env->md_env, &sf_GRid,
                         sf_geom, NULL, MAXINT, FALSE, NULL,
                        eds_oldgm_ptr[cur_ed]),
                       senderid = NULL_OBJID, 
                       targetid = ed_GRid.objid, 
                       targetos = ed_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

  } /* for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++) */

  /*
   * Draft the loop.
   * The right side argument for Draft function means whether
   * the (tan_vec * draft_vec) is towards the offset direction
   * side or not. tan_vec is the vector tangent to the loop
   * at a given point. This information is extracted by looking
   * at:
   * a) Relationship of draft vector w.r.t to surface's natural
   *    normal i.e., they are in the same direction or opposite
   *    to each other.
   * b) Type of the loop i.e., P_LOOP or C_LOOP.
   * c) Draft angle sign i.e. +ve or -ve. +ve sign means
   *    that the loop needs to be stretched. While -ve sign
   *    signifies that loop needs to be shrunk.
   *
   *   Since a loop's logical direction (which represents tan_vec)
   *   has a fixed relationship with surface's natural normal,
   *   the right_side
   *   can be trivially calculated in the following manner.
   *
   *   p -- P_LOOP,   c -- C_LOOP,   dv -- draft_vec,  sn -- sf_nrml
   *
   *   +ve, -ve -- draft angle signs.
   *
   *   ==============================================================
   *         |  p/dv=sn  |  p/dv!=sn  |  c/dv=sn  |  c/dv!sn
   *         |           |            |           |
   *   ==============================================================
   *
   *     +ve |    F      |      T     |     T     |      F
   *         |           |            |           |
   *   ______________________________________________________________
   *
   *     -ve |    T      |      F     |     F     |      T
   *         |           |            |           |
   *   ______________________________________________________________
   *
   */

   right_side = TRUE;

   if (cur_lp_info->is_uniform)
   {
     udraft_angle = fabs(cur_lp_info->draft_angle);
     rsdraft_angle = cur_lp_info->draft_angle;
     draft_angles = &udraft_angle;
   }
   else
   {
      IGRshort draft_positive=-1; /* -1 indicates unknown draft dir *
                                   *  0 indicates negative draft    *
                                   *  1 indicates positive draft    */

      INITIAL_SIZE = BUF_INC = num_lp_eds;
      EFmemory_allocation (&rc, (IGRchar **) &mlc_draft_angles, 
                            num_lp_eds, &draft_angles_arrsz, 
                            sizeof(IGRdouble), INITIAL_SIZE, BUF_INC);
      EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);
  
      rsdraft_angle = 0.;
      draft_angles = mlc_draft_angles;
      for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++)
      {
        cur_ed_info = &cur_lp_info->eds_info[cur_ed];

        if (cur_ed_info->offset_code == BSCONSTOFF &&
            cur_ed_info->draft_angle != 0.0)
        {
          if (draft_positive == -1)
          {
            /*Record draft direction to ensure that all draft angles are
             * consistent.  This check must be made because the code requires
             * that all edge draft angles be consistently positive or negative.
             * DLB 3/31/92. 
             */
            if (cur_ed_info->draft_angle > 0.0)
              draft_positive = TRUE;
            else 
              draft_positive = FALSE;
          }
          else
          {
            /*Check for change in draft direction.  If found just set it
             *  to 0.
             */
            if ((cur_ed_info->draft_angle > 0.0 && !draft_positive) ||
                (cur_ed_info->draft_angle < 0.0 && draft_positive))
            {
              cur_ed_info->draft_angle = 0.0;
            }
          }
        }

        draft_angles[cur_ed] = fabs(cur_ed_info->draft_angle);

        if (cur_ed_info->draft_angle != 0. && 
            cur_ed_info->offset_code == BSCONSTOFF) 
          rsdraft_angle = cur_ed_info->draft_angle;
      } /* for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++) */
    
    } /* else for if (cur_lp_info->is_uniform) */

   if ( rsdraft_angle != 0.)
   {
     OM_stat = om$send (msg = message EMSloop.EMget_props (  
                         &mthd_stat, &lp_props),
                        targetid = cur_lp_info->lp_GRid.objid,
                        targetos = cur_lp_info->lp_GRid.osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

     if (dvec_dot_snrml > 0.)
     {
        if (lp_props & EMLP_PLOOP)
          right_side = rsdraft_angle > 0. ? FALSE : TRUE;
        else 
          right_side = rsdraft_angle > 0. ? TRUE : FALSE;
 
     } /* if (dvec_dot_snrml) */
     else
     {
        if (lp_props & EMLP_PLOOP)
          right_side = rsdraft_angle > 0. ? TRUE : FALSE;
        else 
          right_side = rsdraft_angle > 0. ? FALSE : TRUE;
 
     } /* else for if (dvec_dot_snrml) */

   } /* if ( dlift_info->mx_exlp_dangle != 0.) */

    if (num_lp_eds == 1)
      off_codes = &cur_lp_info->eds_info[0].offset_code;
    else
    {
      EFmemory_allocation (&rc, (IGRchar **) &mlc_off_codes, 
                            num_lp_eds, &off_codes_arrsz, 
                            sizeof(IGRint), INITIAL_SIZE, BUF_INC);
      EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);
  
      off_codes = mlc_off_codes;  
      for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++)
      {
        cur_ed_info = &cur_lp_info->eds_info[cur_ed];
        off_codes[cur_ed] = cur_ed_info->offset_code;

      } /* for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++) */
    
    } /* else for if (num_lp_eds == 1) */

    INITIAL_SIZE = num_lp_eds*2;
    BUF_INC = num_lp_eds;

    /* Allocating proper memory for deds_gm & table as expected by
       BScmpcvoff() in EFdraftcv() . Hari
     */

    EFmemory_allocation (&rc, (IGRchar ***) &deds_gm,
                          (1 + num_lp_eds * 2), &deds_gm_arrsz,
                          sizeof(struct IGRbsp_curve *),
                          INITIAL_SIZE, BUF_INC);
    EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

    EFmemory_allocation (&rc, (IGRchar **) &table,
                          (num_lp_eds * 2 + 1), &table_arrsz,
                          sizeof(IGRint),
                          INITIAL_SIZE, BUF_INC);
    EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

    /*
     * draft the loop
     */

    EFdraftcv(&rc, num_lp_eds, eds_oldgm_ptr, right_side, 
              dlift_info->draft_vec, cur_lp_info->is_uniform, 
              draft_angles, off_codes, !cur_lp_seam, cur_lp_info->fillet,
             &num_lp_deds, deds_gm, table);

    if( !(1 & rc) || !num_lp_deds || rc == EMS_I_InvalidArg || 
	rc == EMS_I_BSerror || rc == EMS_I_Fail)
    {
     /* The following code is added to fix 90N601 */
     
     OM_stat = om$send (msg = message GRconnector.GRdisconn(&mthd_stat,
                              &my_GRid),
                        targetid = dsf_GRid.objid);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     OM_stat = om$send (msg = message GRgraphics.GRdelete(&mthd_stat, md_env),
                            targetid = dsf_GRid.objid);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     *EMmsg = EMS_E_Fail; 
    /* Fix over */
     goto wrapup;
    }
/*
    EMerr_hndlr (!(1&rc) || !num_lp_deds, *EMmsg, EMS_E_Fail, wrapup);
*/
    /* 
     * Now the loop has been drafted .i.e., offset and translated. 
     * o Get the edge types of the original as well as drafted loop. 
     * o Map the loop onto the drafted surface. 
     * o Save the lp and its copy on the drafted surface. 
     *   This information will be used to nest the loops on 
     *   to drafted surface. 
     */

    INITIAL_SIZE = BUF_INC = num_lp_eds; 
    EFmemory_allocation (&rc, (IGRuchar **) &lp_ed_types,  
                          num_lp_eds, 
                         &lp_ed_types_arrsz, sizeof(IGRchar), 
                         INITIAL_SIZE, BUF_INC); 
    EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

    for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++)
    {
      
      OM_stat = om$send (msg = message EMSedge.EMget_props_type (
                          &mthd_stat, &ed_props, &lp_ed_types[cur_ed]),
                 targetid = cur_lp_info->eds_info[cur_ed].ed_GRid.objid); 
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      cur_ed_info = &cur_lp_info->eds_info[cur_ed];
      cur_ed_info->ed_cv_type = lp_ed_types[cur_ed];
      cur_ed_info->ed_sf_type = EMS_C_DRAFTED_SF;

    } /* for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++) */

    INITIAL_SIZE = BUF_INC = num_lp_deds; 
    EFmemory_allocation (&rc, (IGRuchar **) &lp_ded_types,  
                          num_lp_deds, 
                         &lp_ded_types_arrsz, sizeof(IGRchar), 
                         INITIAL_SIZE, BUF_INC); 
    EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

    for (cur_ed = 0; cur_ed < num_lp_deds; cur_ed++) 
    { 
      if (table[cur_ed] < 0)
        EFget_offset_fillet_cv_type (&rc, table[cur_ed], 
                                   &lp_ded_types[cur_ed]); 
      else 
        EFget_offset_edge_cv_type ( &rc, lp_ed_types[table[cur_ed]],
                      cur_lp_info->fillet, &lp_ded_types[cur_ed]);

      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    } /* for (cur_ed = 0; cur_ed < num_lp_deds; cur_ed++) */

    options = NULL | EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
              EMMapBnd_NoClip | EMMapBnd_NoTraceClipFix |
              EMMapBnd_NoValidate | EMMapBnd_NoFixing | 
              EMMapBnd_NoCurveType | EMMapBnd_SurfIsPlane;

    {
     struct EMSgetlp_output		junk;
     struct EMSgetlp_planar_info	planar_info;

     planar_info.edge_types = lp_ded_types;
     planar_info.curve_info = NULL;
     planar_info.out_edges = NULL;
     planar_info.num_out_edges = NULL;

     junk.num_objs = 0;
     junk.objs = &dsf_lps[cur_lp];
     stat = EMget_mapped_data(num_lp_deds, deds_gm, NULL, NULL,
                     dsf_geom, &partolbasis.tol, md_env, NULL, NULL, 
                     &junk, NULL, clip_ls, options, &planar_info, &rc);
     num_imp_lps = junk.num_objs;
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
    }
   if (num_imp_lps != 1)
   {
      fprintf (stderr, " Got screwed up in mapping loops onto drafted sf \n");
      *EMmsg = EMS_E_Fail;
      goto wrapup;

   } /* if (num_imp_lps != 1) */

   sf_lps[cur_lp] = cur_lp_info->lp_GRid.objid;

   /*
    * For each edge of the loop
    * o If it has a common edge
    *    o And if no EMS_LC_AUTO_COINCIDENCE requested, create
    *      a drafted surface.
    *    o Else if EMS_LC_AUTO_COINCIDENCE is requested,
    *      check if the new drafted surface would coincide
    *      with the edge's common edge's surface. If so, trim
    *      the common edge's surface with drafted surface boundary.
    */

   for (cur_ed = 0; cur_ed < num_lp_deds; cur_ed++, work_ed++)
   {
     cm_ed_sfgm = NULL;
     cm_ed_oldgm.poles = cm_ed_oldgm.knots = NULL;
     cm_ed_oldgm.weights = NULL;

     /*
      * If the table return code for the ded < 0, it
      * an indication of new fillet constructed during
      * offset. In such a case no coincidence check
      * will be made as there is no edge on the original
      * lp whose offset is the fillet. Further a drafted
      * surface for a fillet will be constructed only if the last
      * edge and the next edges of the original loop
      * create drfated surfaces i.e., both of them have
      * common edges.
      */

     if (table[cur_ed] < 0)
     {
       create_dsf = TRUE;
       if (last_ed_sf_created)
       {
         next_ed_idx = (cur_ed == num_lp_deds - 1) ? 
                        table[0] : table[cur_ed+1];
         if (next_ed_idx == 0) 
         {
           if (!first_ed_sf_created) create_dsf = FALSE;
         }
         else
         {
            next_ed_GRid = cur_lp_info->eds_info[next_ed_idx].ed_GRid;

            OM_stat = om$get_channel_count (objid = next_ed_GRid.objid,
                    osnum = next_ed_GRid.osnum, 
                    p_chanselect = &cm_ed_chan, count = &num_cm_ed);
            EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
    
            if (!num_cm_ed) create_dsf = FALSE;

         } /* else for if (!next_ed_idx) */

       } /* if (last_ed_sf_created) */

       else
          create_dsf = FALSE;

       if (create_dsf)
       {
         OM_BLOCK_MOVE ( eds_oldgm[next_ed_idx].poles, junction_pt, 
                         sizeof(IGRpoint));
         if (eds_oldgm[next_ed_idx].rational)
           for (i = 0; i < 3; i++)
             junction_pt[i] /= eds_oldgm[next_ed_idx].weights[0];

         BSptcvgen (junction_pt, 2, FALSE, &pt_crv, &rc);
         EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         pt_ed_info.ed_GRid.objid = NULL_OBJID;
         pt_ed_info.ed_GRid.osnum = OM_Gw_current_OS;
         pt_ed_info.ed_sf_type = EMS_C_DRAFTED_SF;
         pt_ed_info.ed_cv_type = EMpoint;
         pt_ed_info.draft_angle = 5.;
         pt_ed_info.offset_code = BSCONSTOFF;

         old_crv = &pt_crv;
         old_ed_info = &pt_ed_info;
         ed_constraint = FALSE;

       } /* if (create_dsf) */
  
     } /* if (table[cur_ed] < 0) */

     else
     {
        old_ed_info = &cur_lp_info->eds_info[table[cur_ed]];
        old_ed_GRid = old_ed_info->ed_GRid;
       
        OM_stat = om$get_channel_count (osnum = old_ed_GRid.osnum,
                  objid = old_ed_GRid.objid, p_chanselect = &cm_ed_chan,
                  count = &num_cm_ed);
        EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup );

        if (num_cm_ed)
        {
          old_crv = &eds_oldgm[table[cur_ed]];
          create_dsf = TRUE;
          ed_constraint = cur_ed_info->ed_constraint_type;
        }
        else 
          create_dsf = FALSE;

     } /* else for if (table[cur_ed] < 0) */

     if (create_dsf)
     {
       if (cur_ed == 0) 
         first_ed_sf_created = TRUE;

       last_ed_sf_created = TRUE;
       OM_stat = om$get_objid_at_index (objid = dsf_lps[cur_lp],
                            p_chanselect = &lp_ed_chan, index = cur_ed,
                            objidaddr = &new_ed_GRid.objid, 
                            osnumaddr = &new_ed_GRid.osnum);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

       cntinue = TRUE;

       while(cntinue)
       {
          switch (ed_constraint)
          {
            /*
             * check if the surface to be constructed by the edge
             * is going to be coincident with the common edge's
             * surface. If so, trim the common edge's surface.
             * Otherwise, construct a new surface. The draft
             * vector used to check coincidency is vector
             * joining mid points of original curve and its 
             * offset counterpart.
             */

            case EMS_LC_AUTO_COINCIDENCE:
         
             if(!isinvalid)
              {
               if (table[cur_ed] < 0)
                {ex$message(msgnumb = EMS_I_CheckFilletSfOverlap);}
               else
	        {ex$message(msgnumb = EMS_I_CheckEdgeOverlap,
	                   var = `work_ed`, type = "%d");}
              }

              BScveval (old_crv, 0.5, 0, (IGRpoint *)&from_pt[0], &rc);
              EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

              BScveval (deds_gm[cur_ed], 0.5, 0, (IGRpoint *)&to_pt[0], &rc);
              EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

              for ( i = 0; i < 3; i++)
                offset_vec[i] = to_pt[i] - from_pt[i];
                            
              EFdoes_new_sf_overlaps_cm_ed_sf (&rc, old_ed_GRid,
                   offset_vec, md_env, &overlap_exists, 
                   &cm_ed_GRid, &cm_ed_sf_GRid, &cm_ed_sfgm, 
                   &cm_ed_oldgm);
              EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

              if (overlap_exists)
              {
	       if(!isinvalid)
	        {
                 if (table[cur_ed] < 0)
                  {ex$message(msgnumb = EMS_I_FilletSfTrimAdjSf);}
                 else
	          {ex$message(msgnumb = EMS_I_EdgeTrimAdjSf, var = `work_ed`, 
	                      type = "%d");}
	        }
                 cntinue = FALSE;
                 
                 EFtrim_cm_ed_sf1 (&rc, NULL, old_ed_info, 
                     new_ed_GRid, sf_GRid,
                     dsf_GRid, dsf_geom, deds_gm[cur_ed], 
                     dlift_info->draft_vec, cm_ed_GRid, cm_ed_sf_GRid, 
                     cm_ed_sfgm, &cm_ed_oldgm, md_env, &ed_u0s, &ed_u1s,
                     &last_ed_u1s, 
                     (cur_ed == num_lp_deds - 1) ? &lp_ed_u0s : NULL,
                     &edv0v1_info, &ed_sp_info, 
                     &lps_mod_info, &ed_cn_info, &sfrmvd_info,
                     dis_options, display_ids, display_count);

                 /* If interference was detected with the common surface
                    (i.e the lift face operation caused the face to be
                     lifted through the hole regions of the common surface)
                    we need to recover.
                    This is accomplished by ignoring the error for now, 
                    completing the operation as if there was no error and
                    no overlap with the common surface, and then undoing
                    at the end.
                 */
                 if(rc == EMS_E_IntersectTrim)
                  {
	           isinvalid = TRUE;
	           rc = EMS_S_Success;
                   ex$message(msgnumb = EMS_E_InvIntfWComSurf);
	           ed_constraint = NULL;
	           cntinue = TRUE;
	          }
                 EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

              } /* if (overlap_exists) */

              else
                 ed_constraint = NULL;

              break;

            /*
             * If there are no constraints applied on the edge or
             * if the check for the auto coincidence was requested
             * but it does not result in overlapping conditions, 
             * create a lifted surface.
             */

            default:
              if(!isinvalid)
               {
                if (table[cur_ed] < 0)
                 {ex$message(msgnumb = EMS_I_CreateDftFilletToFillGap);}
                else
                 {ex$message(msgnumb = EMS_I_EdgeCreateDftSfToFillGap, 
                          var = `work_ed`, type = "%d");}
               }
               cntinue = FALSE;
               EFcreate_lft_sf1 (&rc, NULL, old_ed_info, 
                        new_ed_GRid, my_GRid, 
                        old_crv, deds_gm[cur_ed], sf_geom, 
                        dsf_geom, dlift_info->draft_vec, md_env, 
                        construct_list, &edv0v1_info, &ed_u0s, &ed_u1s,
                        dis_options, display_ids, display_count, 
                        (table[cur_ed]<0?MAXINT:owner_index++));
               EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

          } /* switch (ed_constraint) */

        } /* while(cntinue) */

        /*
         * Now a new surface has been constructed or the 
         * common edge's surface has been trimmed. Next
         * job is to establish topology between ed_u0s
         * of the current edge's sf/cm_ed_trimmed_sf and
         * ed_u1s corresponding the last edge.
         */

        /*
         * The ed_u0s of the first edge may match with ed_u1s 
         * of the last edge of the loop. Therfore save them.
         */

        if (!cur_ed && ed_u0s.num_eds)
        {
            EFsave_edges_for_edge_matching (&rc, &ed_u0s, &lp_ed_u0s);
            EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
 
        } /* if (!cur_ed && ed_u0s.num_eds) */
 
        if ( (cur_ed == num_lp_deds - 1)  && 
             lp_ed_u0s.num_eds && ed_u1s.num_eds )
        {
            EFsave_edges_for_edge_matching (&rc, &ed_u1s, &lp_ed_u1s);
            EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if ( (cur_ed == num_lp_deds - 1)  && 
                  lp_ed_u0s.num_eds && ed_u1s.num_eds ) */

        /*
         * If the edge is not the first edge of the loop
         * perform edge matching between last_ed_u1s and
         * current ed_u0s.
         */
       
        if (cur_ed && last_ed_u1s.num_eds && ed_u0s.num_eds)
        {
          EFed_match (&rc, &last_ed_u1s, &ed_u0s, OM_Gw_current_OS, 
                       md_env, &ed_cn_info);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if (cur_ed && last_ed_u1s.num_eds && ed_u0s.num_eds) */
  
        /*
         * If the edge is not the last edge of the current 
         * subloop, save its ed_u1s
         * as last_ed_u1s. As they will be used to perform
         * edge matching with ed_u0s of the next edge of the 
         * subloop. 
         */

        if ( cur_ed != num_lp_deds - 1 && ed_u1s.num_eds)
        {
           EFsave_edges_for_edge_matching (&rc, &ed_u1s, &last_ed_u1s);
           EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if ( cur_ed !== num_lp_deds && ed_u1s.num_eds) */
        else
          last_ed_u1s.num_eds = 0;

        /* Save the begin and end for the loop for possible mergers later.
        */
        if(!cur_ed && ed_u0s.num_eds)
         {
	  GRspacenum junk;
	
	  /* Begin point of first edge.
	  */
          OM_stat = om$get_objid_at_index (objid = dsf_lps[cur_lp],
                    p_chanselect = &lp_ed_chan, index = cur_ed,
                    objidaddr = &merge_info[num_merge_info].edgeid, 
                            osnumaddr = &junk);
          EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);
          merge_info[num_merge_info].atstart = TRUE;
          EFsave_edges_for_edge_matching (&rc, &ed_u0s, 
	   &merge_info[num_merge_info++].lfted);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
         }

        if( (cur_ed == (num_lp_deds - 1)) && ed_u1s.num_eds)
         {
	  GRspacenum junk;

	  /* End point of the last edge.
	  */
          OM_stat = om$get_objid_at_index (objid = dsf_lps[cur_lp],
                    p_chanselect = &lp_ed_chan, index = cur_ed,
                    objidaddr = &merge_info[num_merge_info].edgeid, 
                            osnumaddr = &junk);
          EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);
          merge_info[num_merge_info].atstart = FALSE;
          EFsave_edges_for_edge_matching (&rc, &ed_u1s, 
	   &merge_info[num_merge_info++].lfted);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
         }

        ed_u0s.num_eds = 0;
        ed_u1s.num_eds = 0;

     } /* if (create_dsf) */
     else
     {
        last_ed_sf_created = FALSE;
        if (!cur_ed) first_ed_sf_created = FALSE;

     } /* else for if (create_dsf) */

     if (cm_ed_sfgm) om$dealloc (ptr = cm_ed_sfgm);

     if (cm_ed_oldgm.poles) om$dealloc(ptr=cm_ed_oldgm.poles);
     if (cm_ed_oldgm.knots) om$dealloc(ptr=cm_ed_oldgm.knots);
     if (cm_ed_oldgm.weights) om$dealloc(ptr=cm_ed_oldgm.weights);

   } /* for (cur_ed = 0; cur_ed < num_lp_deds; cur_ed++) */

   /*
    * For each loop, perform edge matching between
    * lp_edu0 and lp_edu1 if both have any edges.
    */

   if (lp_ed_u0s.num_eds && lp_ed_u1s.num_eds)
   {

       EFed_match (&rc, &lp_ed_u0s, &lp_ed_u1s, OM_Gw_current_OS, md_env, 
                   &ed_cn_info);
       EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

   } /* if (lp_edu0.num_eds && lp_edu1.num_eds) */

   for (cur_ed = 0; cur_ed < num_lp_eds; cur_ed++)
   {
     if (eds_oldgm[cur_ed].poles) 
                om$dealloc (ptr = eds_oldgm[cur_ed].poles);
     if (eds_oldgm[cur_ed].knots) 
                om$dealloc (ptr = eds_oldgm[cur_ed].knots);
     if (eds_oldgm[cur_ed].weights) 
                om$dealloc (ptr = eds_oldgm[cur_ed].weights);
     if (eds_oldgm[cur_ed].bdrys) 
                om$dealloc (ptr = eds_oldgm[cur_ed].bdrys);

   } /* for (cur_ed = 0; cur_ed < num_lp_eds; cur_eds++) */

   for (cur_ed = 0; cur_ed < num_lp_deds; cur_ed++)
     BSfreecv (&rc, deds_gm[cur_ed]);

} /* for (cur_lp = 0; cur_lp < dlift_info->num_lps; cur_lp++) */

/*
 * Nest the drafted versions of the loops of the surface being
 * lifted onto the loopset of the surface's drafted version.
 * For each loop,
 * o Get the nestinfo the drafted loop.
 * o Find out the parent of the original loop.
 * o Find the parent's offset verison id.
 * o nest the drafted loop into its drafted parent.
 */

OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                    &sf_ls_id),
                   senderid = sf_GRid.objid, p_chanselect = &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError, wrapup);

OM_stat = om$construct (classid = OPP_EMSloopset_class_id,
                        p_objid = &dsf_ls_id);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

OM_stat = om$send (msg = message Root.connect (ls_sf_chan, NULL,
                    dsf_GRid.objid, dsf_GRid.osnum, sf_ls_chan, NULL),
                   targetid = dsf_ls_id);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

/* SM 4/2/92
   If the original surface had loops containing seams, we will end up with
   open pieces on the drafted surface (plane) since we ignored seam
   edges. The loops in the array dsf_lps therefore need to be scanned for
   possible mergers.
*/
if(sf_geom->u_phy_closed || sf_geom->v_phy_closed)
 {
  IGRlong locsts;

  (void) EMsm_merge_open_loops(&locsts, dlift_info->num_lps, dsf_lps, 
         &merged, &partolbasis, merge_info, num_merge_info, &ed_cn_info, 
         md_env, dsf_geom);
 /* EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);*/
 }

for(cur_lp = 0; cur_lp < dlift_info->num_lps; cur_lp++)
{
  if(IF_NULL_OBJID(dsf_lps[cur_lp])) continue;

  /* SM 4/2/92 - If some merging took place, do geometrical nesting test
     on the new surface since there is no one-to-one correspondence between
     original and drafted-sf loops.
     SM 4/11/92 - If the drafted loop is open, flag it as an error condition
     and perform undo at the end.
  */

  OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( &mthd_stat,
                     &nesting),
                    targetid= dsf_lps[cur_lp]);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);
  if(nesting.lp_props & EMLP_OPEN) isinvalid = TRUE;

  if(merged)
   {
    OM_stat = om$send(msg = message EMSloopset.EMnesting(&mthd_stat, &nesting, 
              &partolbasis), targetid = dsf_ls_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

    if( IF_EQ_OBJID(nesting.parent, dsf_ls_id) )
      OM_stat = om$send(msg = message EMSloopset.EMtreemod( &mthd_stat, 
                        &nesting, ADD_CHILD, &partolbasis),
                       targetid = dsf_ls_id);
    else
      OM_stat = om$send(msg = message EMSloop.EMtreemod(
                       &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                      targetid = nesting.parent);

    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

   }
  else
   {
    OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                      &lp_parent),
                     senderid = sf_lps[cur_lp],
                     p_chanselect = &to_outter);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if( IF_EQ_OBJID(lp_parent, sf_ls_id) )
     {
      nesting.parent = dsf_ls_id;

      OM_stat = om$send(msg = message EMSloopset.EMtreemod( &mthd_stat, 
                        &nesting, ADD_CHILD, &partolbasis),
                       targetid = dsf_ls_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

     } /* if( IF_EQ_OBJID(lp_parent, sf_ls_id) ) */

    else
     {
      for (i = 0; i < dlift_info->num_lps; i++)
       if (lp_parent == sf_lps[i])
       {
         nesting.parent = dsf_lps[i];
         break;

       } /* if (lp_parent == sf_lps[i]) */

       OM_stat = om$send(msg = message EMSloop.EMtreemod(
                          &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
		                 targetid = nesting.parent);

        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

    } /* else for if( IF_EQ_OBJID(lp_parent, sf_ls_id) ) */

  }

} /* for(cur_lp = 0; cur_lp < slift_info->num_lps; cur_lp++) */

/*
 * it may be possible that drfated surface's loopset are natural after
 * this process. Make a check for this and set the EMLS_NATURAL
 * bit appropriately.
 */

ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
lp_props = ed_props = NULL;

OM_stat = om$send (msg = message EMSboundary.EMcheck_props (&mthd_stat,
                    &ls_props, &lp_props, &ed_props), 
                   targetid = dsf_ls_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

/* Does the drafted loopset have any external C loops? If is flag it as
   invalid.
*/
{
 OMuint lscount = 0, i;
 IGRushort lpprops = NULL;

 OM_stat = om$get_channel_count(objid = dsf_ls_id, 
           p_chanselect = &ls_lp_chan, count = &lscount);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
 for(i=0; i<lscount; i++)
  {
   OM_stat = om$send(msg = message EMSloop.EMget_props(&mthd_stat, &lpprops), 
             senderid = dsf_ls_id, p_chanselect = &ls_lp_chan, 
             from = i, to = i);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
   if( (!(lpprops & EMLP_PLOOP)) || (lpprops & EMLP_OPEN))
    {
     isinvalid = TRUE;
     break;
    }
  }

}

/*
 * If there is only one loop, check if it is natural
 */

if (dlift_info->num_lps == 1)
{
 ls_props = ed_props = NULL;
 lp_props = EMLP_NATURAL;

 OM_stat = om$send (msg = message EMSboundary.EMcheck_props (&mthd_stat,
                    &ls_props, &lp_props, &ed_props), 
                   targetid = dsf_lps[0]);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
}

if (dis_options & EMS_DO_DISPLAY)
{
  if (dis_options & EMS_DONT_REDRAW)
  {
    /*Add the surface to the list.*/
    OM_stat = EFwork_the_display(&mthd_stat, dis_options, dsf_GRid.objid,
                                 display_ids, display_count, NULL);
    if (!(1 & OM_stat & mthd_stat)) goto wrapup;                  
  }
  else
  {
    /*
     * The drafted surface's topology has been established.
     * Display it.
     */
    Display_Mode = GRbd;
    OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                        &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &Display_Mode,
                        &md_env->md_id),
                       targetid = dsf_GRid.objid);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  }
}

/*
 * BL: 10/12/89	:  Here, I replace the origin surface by the drafted 
 *		   surface in struct dlist_info for some purpose.
 */

dlift_info->sf_GRid = dsf_GRid;

/* 
 * The surface has been replaced by its drafted version. 
 * 
 * o Get the surface owner's id.
 * o Get the surface's index w.r.t. its owner.
 * o Disconnect the surface from its owner.
 * o Make the surface Non_locatable and Non_displayable.
 */

OM_stat = om$get_objid_at_index (objid = sf_GRid.objid,
                  p_chanselect = &to_owners_chan,
                  index = 0, objidaddr = &sf_owner_GRid.objid,
                  osnumaddr = &sf_owner_GRid.osnum);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

OM_stat = om$get_index (osnum_c = sf_owner_GRid.osnum,
                        objid_c = sf_owner_GRid.objid,
                        p_chanselect = &to_comps_chan,
                        objid = sf_GRid.objid,
                        indexaddr = &composite_idx);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                    &sf_owner_GRid),
                   targetid = sf_GRid.objid);
EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

EFsetsfstate(&mthd_stat, sf_GRid.objid, sf_GRid.osnum, EMS_O_OFF);
EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

/*maintain graph relationship*/
OM_stat = EFfix_parent_child_relationship(EMmsg, 
                                          sf_GRid.objid, sf_owner_GRid.objid,
                                          OM_Gw_current_OS, TRUE, NULL);
if (!(1 & OM_stat & *EMmsg)) goto wrapup;

/*
 * Deactivate the surface's loops
 */

OM_stat = om$send(msg = message EMSboundary.EMtree_traverse(&mthd_stat, 
                                message EMSloop.EMset_props(&mthd_stat,
                                        EMLP_ACTIVE, EMS_O_OFF), 
                                MAXINT, 1, &OPP_EMSloop_class_id, TRUE, NULL,
                                NULL, NULL),
                  senderid = sf_GRid.objid,
                  p_chanselect = &sf_ls_chan); 
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

INITIAL_SIZE = BUF_INC = 10;
array_size = sfrmvd_info.compsf_arrsz;
EFmemory_allocation (&rc, (IGRchar **) &sfrmvd_info.compsf_ids, 
                      1, &array_size, sizeof(GRobjid), 
                      INITIAL_SIZE, BUF_INC);
EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
      
EFmemory_allocation (&rc, (IGRchar **) &sfrmvd_info.num_sf_prcompsf, 
                      1, &sfrmvd_info.compsf_arrsz, sizeof(IGRint), 
                      INITIAL_SIZE, BUF_INC);
EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

array_size = sfrmvd_info.sf_arrsz;
EFmemory_allocation (&rc, (IGRchar **) &sfrmvd_info.sf_ids, 
                      1, &array_size, sizeof(GRobjid), 
                      INITIAL_SIZE, BUF_INC);
EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
      
EFmemory_allocation (&rc, (IGRchar **) &sfrmvd_info.sf_idx, 
                      1, &sfrmvd_info.sf_arrsz, sizeof(IGRint), 
                      INITIAL_SIZE, BUF_INC);
EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
      
sfrmvd_info.num_compsf = 1;
sfrmvd_info.compsf_ids[0] = sf_owner_GRid.objid;
sfrmvd_info.num_sf_prcompsf[0] = 1;
sfrmvd_info.sf_ids[0] = sf_GRid.objid;
sfrmvd_info.sf_idx[0] = composite_idx;
sfrmvd_info.num_sf_rmvd = 1;

/*
 * It may be possible that some of the edges of the loops taken out
 * or the surfaces taken out are inactive and are still connected
 * active common edges. This will prevent the active common edges from
 * being able to connect to another edge though it should be allowed
 * to. Thus in such a situation, replace the active common edges
 * with their compressed copied in their respective loops. Also,
 * save the replacement information in ed_sp_info.
 *
 * The above mentioned situation exists if the object being worked upon
 * is not a solid. In case of a solid, the above situation can
 * not arise as it will create hole regions and thus violates it
 * closeness property.
 */

OM_stat = om$get_classid (object = me, p_classid = &my_classid);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = om$is_ancestry_valid (subclassid = my_classid, 
                                superclassid = OPP_EMSsolid_class_id);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

if (OM_stat != OM_S_SUCCESS)
{
  EFrmv_inacteds_actcm_eds (&rc, md_env, OM_Gw_current_OS, &sfrmvd_info, 
                            &lps_mod_info, &ed_sp_info);
  EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

} /* if (OM_stat != OM_S_SUCCESS) */

/*
 * Processing is finished. Time to save the information
 * save state purposes.
 * The save state information comprises of:
 *
 * 1. Composite id from which the surface has been taken out
 *    and surface out id.
 * 2. Num of surfaces affected. Num of loops in/out per sf.
 * 3. Num edges affected. Num of edges replaced per edge and their
 *    ids.
 * 4. Num of edges whose common edges moved and their ids.
 * 5. Num of edges whose common edges are replaced by other edges.
 *    and their ids.
 */

 my_info = &ssi_table.lft_info;

 my_info->num_composites = sfrmvd_info.num_compsf;
 my_info->composite_ids = sfrmvd_info.compsf_ids;
 my_info->num_surfaces_out = sfrmvd_info.num_sf_prcompsf;
 my_info->surface_out_ids = sfrmvd_info.sf_ids;
 my_info->composite_indices = sfrmvd_info.sf_idx;

 my_info->num_sf_lifted = 0;
 my_info->sf_lifted_ids = NULL;
 my_info->num_sf_affected = lps_mod_info.num_sfs;
 my_info->sf_affctd_ids = lps_mod_info.sf_ids;
 my_info->num_regions_in = lps_mod_info.lps_added_prsf;
 my_info->region_in_ids = lps_mod_info.lp_added_ids;
 my_info->num_regions_out = lps_mod_info.lps_rmvd_prsf;
 my_info->region_out_ids = lps_mod_info.lp_rmvd_ids;
 my_info->num_eds_rplcd = ed_sp_info.num_eds;
 my_info->ed_rplcd_ids = ed_sp_info.ed_ids;
 my_info->num_eds_in = ed_sp_info.sp_eds_pred;
 my_info->ed_in_ids = ed_sp_info.sp_eds;
 my_info->num_eds_wcm_md = edv0v1_info.num_eds;
 my_info->ed_mcm_ed_ids = edv0v1_info.ed_ids;
 my_info->num_ed_wmv_cm = ed_cn_info.num_eds;
 my_info->ed_ced_ids = ed_cn_info.ed_ids;
 my_info->num_eds_wcm_eds = 0;
 my_info->ed_cm_ed_ids = NULL;

 OM_stat = om$send (msg = message EMSdpr.EMputSSI( &mthd_stat, 
                     &ssi_table), targetid = my_id);

 /* SM 4/11/92 - Drafted lift for loops spanning original surface's seam
    is not handled. This has been flagged by the 'isinvalid' flag which was
    set if any drafted loop was found to be open. In such a case perform
    undo.
 */
 if(isinvalid)
  {
   IGRshort deact_opt = EMS_DO_DISPLAY;
   GRobjid *locdisplay_ids = NULL;
   IGRint locdisplay_count = 0, i;
   IGRlong locmsg;

   /* If recomputing, perform UNDO SAVE. If initial placement, perform
      UNDO_DELETE.
   */
   if(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)
    deact_opt |= EMS_UNDO_SAVE;

   OM_stat = om$send(msg = message EMSdpr.EMdeactivate(&mthd_stat, 
             &deact_opt, md_env, &locdisplay_ids, &locdisplay_count), 
             targetid = my_id);

   Display_Mode = GRbd;
   for(i=0; i<locdisplay_count; i++)
    (void) om$send (msg = message GRgraphics.GRdisplay (&locmsg,
           &md_env->md_env.matrix_type, md_env->md_env.matrix, &Display_Mode,
           &md_env->md_id), targetid = locdisplay_ids[i]);
    
   if(locdisplay_ids) om$dealloc(ptr = locdisplay_ids);
   locdisplay_ids = NULL;
   *EMmsg = EMS_E_Fail;
  }

wrapup:

if(!isinvalid)
 ex$message(msgnumb = EMS_I_ClearStatusField)

if (edv0v1_info.ed_ids) om$dealloc (ptr = edv0v1_info.ed_ids);

if (ed_u0s.ed_ids) om$dealloc (ptr = ed_u0s.ed_ids);
if (ed_u0s.sf_ids) om$dealloc (ptr = ed_u0s.sf_ids);

if (ed_u1s.ed_ids) om$dealloc (ptr = ed_u1s.ed_ids);
if (ed_u1s.sf_ids) om$dealloc (ptr = ed_u1s.sf_ids);

if (last_ed_u1s.ed_ids) om$dealloc (ptr = last_ed_u1s.ed_ids);
if (last_ed_u1s.sf_ids) om$dealloc (ptr = last_ed_u1s.sf_ids);

if (lp_ed_u0s.ed_ids) om$dealloc (ptr = lp_ed_u0s.ed_ids);
if (lp_ed_u0s.sf_ids) om$dealloc (ptr = lp_ed_u0s.sf_ids);

if (lp_ed_u1s.ed_ids) om$dealloc (ptr = lp_ed_u1s.ed_ids);
if (lp_ed_u1s.sf_ids) om$dealloc (ptr = lp_ed_u1s.sf_ids);

for(i=0; i<num_merge_info; i++)
 {
  if(merge_info[i].lfted.ed_ids) om$dealloc(ptr = merge_info[i].lfted.ed_ids);
  if(merge_info[i].lfted.sf_ids) om$dealloc(ptr = merge_info[i].lfted.sf_ids);
 }
if(merge_info) om$dealloc(ptr = merge_info);

if (ed_cn_info.ed_ids) om$dealloc (ptr = ed_cn_info.ed_ids);

if (ed_sp_info.ed_ids) om$dealloc (ptr = ed_sp_info.ed_ids);
if (ed_sp_info.sp_eds) om$dealloc (ptr = ed_sp_info.sp_eds);
if (ed_sp_info.sp_eds_pred) om$dealloc (ptr = ed_sp_info.sp_eds_pred);

if (lps_mod_info.sf_ids) om$dealloc( ptr = lps_mod_info.sf_ids); 
if (lps_mod_info.lp_added_ids) 
                  om$dealloc( ptr = lps_mod_info.lp_added_ids);
if (lps_mod_info.lp_rmvd_ids) 
                  om$dealloc( ptr = lps_mod_info.lp_rmvd_ids);
if (lps_mod_info.lps_added_prsf) 
                  om$dealloc( ptr = lps_mod_info.lps_added_prsf);
if (lps_mod_info.lps_rmvd_prsf) 
                  om$dealloc( ptr = lps_mod_info.lps_rmvd_prsf);

if (sfrmvd_info.compsf_ids )
                  om$dealloc (ptr = sfrmvd_info.compsf_ids);
if (sfrmvd_info.sf_ids )
                  om$dealloc (ptr = sfrmvd_info.sf_ids);
if (sfrmvd_info.num_sf_prcompsf)
                  om$dealloc (ptr = sfrmvd_info.num_sf_prcompsf);
if (sfrmvd_info.sf_idx)
                  om$dealloc (ptr = sfrmvd_info.sf_idx);

if (sf_geom) om$dealloc (ptr = sf_geom);
if (dsf_geom) BSfreesf (&rc, dsf_geom);

if (eds_oldgm) om$dealloc (ptr = eds_oldgm);
if (eds_oldgm_ptr) om$dealloc (ptr = eds_oldgm_ptr);
if (deds_gm) om$dealloc (ptr = deds_gm);
if (mlc_draft_angles) om$dealloc (ptr = mlc_draft_angles);
if (mlc_off_codes) om$dealloc (ptr = mlc_off_codes);
if (table) om$dealloc (ptr = table);
if (dsf_lps) om$dealloc (ptr = dsf_lps);
if (sf_lps) om$dealloc (ptr = sf_lps);
if (lp_ed_types) om$dealloc (ptr = lp_ed_types);
if (lp_ded_types) om$dealloc (ptr = lp_ded_types);

EMWRAPUP(*EMmsg, OM_stat, "In EMSsfdlift.EMlift_face");

return (OM_stat);

}

/*
 * Given the edge_cv_type and the fillet option, the following
 * function returns its offset edge's curve type.
 */

void EFget_offset_edge_cv_type (
       EFmsg,
       ed_cv_type,
       fillet,
       off_ed_cv_type)

   IGRlong            *EFmsg;
   IGRuchar           ed_cv_type, *off_ed_cv_type;
   IGRboolean         fillet;
{
   *EFmsg = EMS_S_Success;

   switch (ed_cv_type)
   {
     case EMcircular_arc:
     case EMcircle:
     case EMinfinite_line:
     case EMlinesegment:
     case EMpoint:

      *off_ed_cv_type = ed_cv_type;
      break;

     case EMlinestring:
     case EMorthogonal_linestring:
     case EMorthogonal_polygon:
     case EMplanar_linestring:
     case EMpolygon:

       if (fillet) *off_ed_cv_type = EMfreeform_curve;
       else *off_ed_cv_type = ed_cv_type;
       break;

     default:
        *off_ed_cv_type = EMfreeform_curve;

   } /* end switch (ed_cv_type) */

   return;

} /* void EFget_offset_edge_cv_type () */

/* 
 * Given the type of the fillet curve constructed 
 * during an offset of a curve, the following 
 * function returns the appropriate edge_cv_type. 
 */

void EFget_offset_fillet_cv_type ( 
     EFmsg, 
     fillet_type, 
     off_ed_cv_type)

  IGRlong          *EFmsg; 
  IGRint           fillet_type; 
  IGRuchar *off_ed_cv_type;

{ 
  *EFmsg = EMS_S_Success;

  switch (fillet_type) 
  { 
    case BSCVLINE: 
      *off_ed_cv_type = EMlinesegment;
      break;

    case BSCVLINESTR: 
      *off_ed_cv_type = EMlinestring; 
      break;

    case BSCVCIRCARC: 
      *off_ed_cv_type = EMcircular_arc; 
      break;

    default: 
      *off_ed_cv_type = EMfreeform_curve;

  } /* switch (fillet_type) */

  return;

} /* void EFget_offset_fillet_cv_type () */

from EMSloop import EMlpinit, EMendpts;


static EMsm_merge_open_loops(EMmsg, num_lps, lps, merged, partol, merge_info, 
       num_merge_info, ed_cn_info, md_env, dsf_geom)
IGRlong *EMmsg;
IGRint num_lps;
GRobjid *lps;
IGRboolean *merged;
struct EMSpartolbasis *partol;
struct EMSmerge_info *merge_info;
IGRint num_merge_info;
struct EMSlft_edcn_info *ed_cn_info;
struct GRmd_env *md_env;
struct IGRbsp_surface *dsf_geom;
{
 IGRlong 	  	sts = OM_S_SUCCESS, rc;
 IGRushort	lpprops = NULL;
 IGRint			i, j, m, n;
 OMuint                 commed, num_newed;
 IGRdouble		thislp_stop[2], searchlp_begin[2], lentol, cht, 
			thislp_stopxyz[3], searchlp_beginxyz[3];
 IGRboolean		atleast_one_match = FALSE, matched = FALSE;
 OM_S_CHANSELECT	to_lp, to_ed, to_comm;
 OM_S_OBJECT_LINKAGE	*newed = NULL;
 GRobjid		exist_firsted, exist_lasted;
 GRspacenum		junk;

 *EMmsg = EMS_S_Success;
 sts = EFextract_par(BSTOLLENVEC,partol->tol,&lentol, EMmsg);
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 cht *= 2;

 EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 EMmake_chanselect(EMSedge_to_owner, &to_lp);
 EMmake_chanselect(EMSedge_to_common_edge, &to_comm);

 *merged = FALSE;

 /* Unreverse all the loops for simplicity.
 */
 for(i=0; i<num_lps; i++)
  {
   sts = EMunreverse_loop(EMmsg, lps[i], OM_Gw_current_OS);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 atleast_one_match = TRUE;
 while(atleast_one_match)
  {
   atleast_one_match = FALSE;

   if(newed) om$dealloc(ptr = newed);
   newed = NULL;

   for(i=0; i<num_lps; i++)  
    {
     if(IF_NULL_OBJID(lps[i])) continue;

     sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
           senderid = NULL_OBJID, targetid = lps[i]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(!(lpprops & EMLP_OPEN)) continue;

     /* Since this loop is open, find another open loop with matching
        begin point with this loop's end point.
     */
     sts = om$send(msg = message EMSloop.EMendpts(EMmsg, NULL, thislp_stop, 
	   NULL, NULL), targetid = lps[i], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     for(j=0; j<num_lps; j++)
      {
       if( (IF_NULL_OBJID(lps[j])) || (IF_EQ_OBJID(lps[j], lps[i])))
        continue;

       sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
             senderid = NULL_OBJID, targetid = lps[j]);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(!(lpprops & EMLP_OPEN)) continue;

       sts = om$send(msg = message EMSloop.EMendpts(EMmsg, searchlp_begin, 
	     NULL, NULL, NULL), targetid = lps[j], senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       matched = FALSE;
       if(EM2ddistptpt(thislp_stop, searchlp_begin) > lentol)
        {
	 struct EMSdataselect thised, searched, surfdata;
         struct GRid thised_GRid, searched_GRid;
         OMuint count = 0;
         IGRdouble dist;

         /* Check points to be within 2*cht in modelspace. If so then ok.
         */

         BSsfeval(dsf_geom, thislp_stop[0], thislp_stop[1], 0, (IGRpoint *)&thislp_stopxyz[0],
                  &rc);
         if(rc != BSSUCC) goto nomatch;
         BSsfeval(dsf_geom, searchlp_begin[0], searchlp_begin[1], 0, 
                  (IGRpoint *)&searchlp_beginxyz[0], &rc);
         if(rc != BSSUCC) goto nomatch;

         dist = BSdistptpt (&rc, thislp_stopxyz, searchlp_beginxyz);
         if(dist > cht) goto nomatch;

         matched = TRUE;

         /* extend the edges in uv space to close gap if any.
         */
         sts = om$get_channel_count(objid = lps[i], p_chanselect = &to_ed, 
               count = &count);
         if(!(1&sts)) goto nomatch;

         sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, 
               &thised_GRid.objid), senderid = lps[i], p_chanselect = &to_ed, 
               from = count - 1, to = count-1);
         if(!(1&*EMmsg&sts)) goto nomatch;

         sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, 
               &searched_GRid.objid), senderid = lps[j], p_chanselect = &to_ed,
               from = 0, to = 0);
         if(!(1&*EMmsg&sts)) goto nomatch;
         thised_GRid.osnum = searched_GRid.osnum = OM_Gw_current_OS;
         thised.datatype = searched.datatype = EMSdata_object;
         thised.data.object = &thised_GRid;
         searched.data.object = &searched_GRid;
         surfdata.datatype = EMSdata_surface;
         surfdata.data.surface = dsf_geom;

         sts = EMextend_intdata(EMmsg, &thised, &searched, TRUE, FALSE, partol,
               NULL, &surfdata, md_env->md_env.matrix, 
               &md_env->md_env.matrix_type);
         if(!(1&*EMmsg&sts)) goto nomatch;

        }
       else matched = TRUE;

nomatch:

       sts = OM_S_SUCCESS;
       *EMmsg = EMS_S_Success;

       if(!matched) continue;

       /* Found a continuing loop. Merge its edges with mine, delete it and
          set the corresponding array location to NULL_OBJID. Also check
          whether the current loop has become closed as a result.

          When merging first and last edges of the new loop, do edge matching
          between the corresponding u edges of the lifted surface.

       */
       sts = om$get_channel_count(objid = lps[i], p_chanselect = &to_ed, 
	     count = &num_newed);
       if(!(1&sts)) goto wrapup;

       exist_firsted = exist_lasted = NULL_OBJID;

       sts = om$get_objid_at_index(objid = lps[i], p_chanselect = &to_ed, 
             index = 0, objidaddr = &exist_firsted, osnumaddr = &junk);
       if(!(1&sts)) goto wrapup;

       sts = om$get_objid_at_index(objid = lps[i], p_chanselect = &to_ed, 
             index = num_newed-1,objidaddr = &exist_lasted, osnumaddr = &junk);
       if(!(1&sts)) goto wrapup;

       sts = om$get_channel_count(objid = lps[j], p_chanselect = &to_ed, 
	     count = &num_newed);
       if(!(1&sts)) goto wrapup;
       newed = (OM_S_OBJECT_LINKAGE *) om$malloc(size = num_newed * 
                sizeof(OM_S_OBJECT_LINKAGE));
       EMerr_hndlr(!newed, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       sts = om$get_channel_objects(objid = lps[j], p_chanselect = &to_ed, 
             list = newed, size = num_newed, count = &num_newed);
       if(!(1&sts)) goto wrapup;

       sts = om$send(msg = message Root.wild_disconnect(to_ed), 
             senderid = NULL_OBJID, targetid = lps[j]);
       if(!(1&sts)) goto wrapup;

       for(m=0; m<num_newed; m++)
        {
         sts = om$send(msg = message Root.connect(to_lp, MAXINT, lps[i], 
	       OM_Gw_current_OS, to_ed, NULL), senderid = lps[i], 
	       targetid = newed[m].S_objid);
	 if(!(1&sts)) goto wrapup;
	
	 if(!m)
	  {
	   struct EMSlft_edmtch_info *mtch1 = NULL, *mtch2 = NULL;
	
	   /* End point of the last existing edge.
	   */
	   for(n=0; n<num_merge_info; n++)
	     if( (merge_info[n].edgeid == exist_lasted) &&
	         (merge_info[n].edgeid != NULL_OBJID) &&
	         (!merge_info[n].atstart))
	      {
	       mtch1 = &merge_info[n].lfted;
	       break;
	      }
	   /* Begin point of the edge being merged.
	   */
	   for(n=0; n<num_merge_info; n++)
	     if( (merge_info[n].edgeid == newed[m].S_objid) &&
	         (merge_info[n].edgeid != NULL_OBJID) &&
		 (merge_info[n].atstart))
	      {
	       mtch2 = &merge_info[n].lfted;
	       break;
	      }
	
	   if(mtch1 && mtch2 && (mtch1->num_eds == 1) && (mtch2->num_eds== 1))
	    {
	     sts = om$get_channel_count(objid = mtch1->ed_ids[0], 
	           p_chanselect = &to_comm, count = &commed);
	     if(!(1&sts)) goto wrapup;
	     if(commed) goto skip_match1;
	     sts = om$get_channel_count(objid = mtch2->ed_ids[0], 
	           p_chanselect = &to_comm, count = &commed);
	     if(!(1&sts)) goto wrapup;
	     if(commed) goto skip_match1;
             EFed_match (EMmsg, mtch1, mtch2, OM_Gw_current_OS, md_env, 
                         ed_cn_info);
             if(!(1&*EMmsg)) goto wrapup;
	    }
	
	  } /* if(!m) */

	 if(m == (num_newed - 1))
	  {
	   struct EMSlft_edmtch_info *mtch1 = NULL, *mtch2 = NULL;

	   /* Begin point of the first existing edge.
	   */
	   for(n=0; n<num_merge_info; n++)
	     if( (merge_info[n].edgeid == exist_firsted) &&
	         (merge_info[n].edgeid != NULL_OBJID) &&
	         (merge_info[n].atstart))
	      {
	       mtch1 = &merge_info[n].lfted;
	       break;
	      }
	   
	   /* End point of the last edge being merged.
	   */
	   for(n=0; n<num_merge_info; n++)
	     if( (merge_info[n].edgeid == newed[m].S_objid) &&
	         (merge_info[n].edgeid != NULL_OBJID) &&
	         (!merge_info[n].atstart))
	      {
	       mtch2 = &merge_info[n].lfted;
	       break;
	      }
	
	   if(mtch1 && mtch2 && (mtch1->num_eds == 1) && (mtch2->num_eds== 1))
	    {
	     sts = om$get_channel_count(objid = mtch1->ed_ids[0], 
	           p_chanselect = &to_comm, count = &commed);
	     if(!(1&sts)) goto wrapup;
	     if(commed) goto skip_match1;
	     sts = om$get_channel_count(objid = mtch2->ed_ids[0], 
	           p_chanselect = &to_comm, count = &commed);
	     if(!(1&sts)) goto wrapup;
	     if(commed) goto skip_match1;
             EFed_match (EMmsg, mtch1, mtch2, OM_Gw_current_OS, md_env, 
                         ed_cn_info);
             if(!(1&*EMmsg)) goto wrapup;
	    }
	
	  } /* if(!m) */
	         	
skip_match1:
	;
        } /* for(m=0; m<num_newed; m++) */
       
       sts = om$send(msg = message Root.delete(TRUE), senderid = NULL_OBJID, 
	     targetid = lps[j]);
       if(!(1&sts)) goto wrapup;
       lps[j] = NULL_OBJID;
      
       sts = om$send(msg = message EMSloop.EMlpinit(EMmsg, NULL, partol, 
	     EMLpInit_IgnoreInProps), targetid = lps[i], senderid =NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;

       atleast_one_match = TRUE;
       *merged = TRUE;
       break;

      } /* for(j=0; j<num_lps; j++) */

     if(atleast_one_match) break;

    } /* for(i=0; i<num_lps; i++) */

  } /* while(atleast_one_match) */

wrapup:

if(newed) om$dealloc(ptr = newed);
return(sts);
}

end implementation EMSsfdlift;
