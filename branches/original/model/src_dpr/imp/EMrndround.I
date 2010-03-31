/*
  DESCRIPTION

    The message is the highest level message to be called to perform rounding
    as a boolean operation. The edges sent in as arguments are all assumed
    to be dominant and non-neutral (non-tangent) edges.

  HISTORY:

    Inasu  : Circa 91 : Creation
    SS     : Circa 92 : Re-write
    Janaka : 01/15/93 : Modifications to accomodate Phoenix user interface
                        work.
    WBC    : 01/11/93 : Replace the call to BSmdistptsf with a call
                        to BSprptarrsf.
    Janaka : 11/03/92 : Pass EMS_RND_CHECK_CURV_PROB as an option to
                        EMcrfilletsurf() function, so that function can check
                        for curvature problems on the fillets.
    NP     : 05/27/93 : Funtction "EMmkintlist" is now called by a new
                        name, "EMmakeintlist", due to addition of two new
                        curve type parameters.
                        NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN THE
                              CALL (CURRENTLY SET TO NULL).
    Sudha    06/23/93   Modified for BSprototype ansification
    Aditya : 08/25/95 : Calling EMmapcvxyz_to_uv_mod(), instead of
                        EMmapcvxyz_to_uv(), with the mid-point of the edge
                        whose isos are being mapped onto the supporting faces.
    Aditya : 07/15/96 : Changes for handling topological interactions.
                        Mapping of curves onto the model now takes place in
                        the interaction handling function if the _process_tply
                        flag is TRUE. Imposing boundaries onto the fillets is
                        now done in the function
                        EMimpose_boundaries_on_fillet_blends.
*/

class implementation EMSsfrndbool;

%safe
#include <math.h>
%endsafe
#include "msmacros.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "ECmsg.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "emsedgedef.h"
#include "REgencompsf.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "bsgeom_cvsf.h"
#include "EMSrndprotyp.h"
#include "EMSbnddef.h"
#include "prototypes/bssfincord.h"
#include "bssfptseval.h"
#include "bssfkttol2.h"
#include "bssfincord.h"
#include "bsrev_cv.h"
#include "bsptcvgen.h"
#include "bspartofcv.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"
#include "timerdef.h"

#include "PWminimum.h"
%safe
#include "PWapi/sfgeom.h"
#include "PWapi/partol.h"
%endsafe

#define MAX_TO_STACKALLOC	10
#define BUFF_SIZE		100

#define START  0
#define STOP   1

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define THIS   0
#define OTHER  1

#define X 0
#define Y 1
#define Z 2

#define U  0
#define V  1
#define W  2

#define CONST_U  1
#define CONST_V  2

#define U0 0
#define V1 1
#define U1 2
#define V0 3

#define FILLET  0
#define MODEL   1
#define NATEDS	2

#define FWD 0
#define BWD 1

#define ZERO     0
#define NEGATIVE 1
#define POSITIVE 2

#define WBC_USE_NEW_MATH 0

typedef IGRboolean bool2[2];

from EMSboundary import EMgetsurface_info;
from EMSedge import EMchkconvex, EMget_props, EMxyz_endpt, EMget_bcxyz_geom;
from EMSedge import EMgetvtxedges, EMinternalpt, EMset_props, EMptproject;
from EMSedge import EMptalong;
from EMSloop import EMtreemod, EMset_props;
from EMSloopset import EMlsparttrim, EMtreemod;
from EMSsubbs import EMget_edges, EMpartolbasis;

extern IGRboolean _keep_fillets_patches; /* Defined in
                                          * src_testco/imp/ECdbgsendi.I
                                          */
extern OMuword OPP_EMSgencompsf_class_id;
extern IGRint rnd_with_blns_only; /* Defined in src_testco/imp/ECdbgsendi.I */

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;
extern IGRboolean _process_tply_interaction;


%safe
static void get_part_nat_edge_split_info();
static void check_fillet_or_surf(), modify_endpt_onto_neutral_edge();
static IGRboolean check_on_edge(), is_degen_end_at_vertex(), chkatend();
extern IGRlong check_and_adjust_bdry_parms();
static IGRboolean check_fillet_fillet_interaction();
static IGRboolean _process_tply=0;
%endsafe

typedef IGRdouble PT_IN_UV[2];

#argsused

method EMround (IGRlong *msg; IGRushort options;
                struct GRvg_construct *const_list;
                struct GRid *model_id;
                IGRint num_edges;
                struct EMSrnd_boundary_input *edges;
		IGRchar status_str[];
                IGRint *display_count; GRobjid **display_ids;
                struct EMSrnd_error *rnderror)
{
  IGRboolean is_convex, is_neutral, processing_v0, onsrf, tst_plan;
  IGRboolean *vtx_edge_ends, vtx_edge_ends_mem[MAX_TO_STACKALLOC];
  IGRboolean no_interaction=TRUE;
  IGRchar *ptr;
  IGRushort props, ed_props, loc_opts, fill_props, *propsptr;
  IGRushort filopts;
  IGRshort *mattyp, isodir, ctrline_type;
  IGRint four=4, i, j, k;
  IGRint count, tmpinx, inx, endinx, entity_num;
  IGRint blksize, array_size, num_surf_edges;
  IGRint num_vtx_edges;
  IGRint *fsf_type = NULL;
  IGRlong msg_loc, stat_OM;
  IGRdouble *mat, *pt, *pts, angmeas, radius, rho_val=0.0;
  IGRdouble u[2], v[2], uvtol, chttol, bastol, uvchttol, sf_uv[2];
  IGRdouble other_radius, extdist[2], *endpt[2], edge_mid_pt[2];
  IGRpoint dumpt, endpts[2], midpts[2], midpts_xyz[2], srf_pt;
  GRobjid *vtx_edges, vtx_edges_mem[MAX_TO_STACKALLOC];
  GRobjid *objptr, nateds[4];
  GRobjid fill_patch, edge_id;
  GRspacenum os;
  bool2 *end_procd;
  struct IGRbsp_surface *fsrf, *srf, **srfptr, *srfptr_mem[1];
  struct IGRbsp_curve *alloc_crv1, *alloc_crv2, *ctrline_cv, intcv, *p_intcv;
  struct IGRpolyline *py;
  struct GRmd_env *md_env;
  struct GRmdenv_info *mdenv_info;
  struct GRid *idptr, tmpid, other_tmpid, ids[6], fill_patch_id;
  struct GRid *fillet_surf_nat_edges, *V0_edge_object, *V1_edge_object;
  struct EMSedge_rnd_info *p_edge_rnd_info, *edge_rnd_info;
  struct EMSintobj *p_intobj;
  struct EMSinters *fillet_inters, *model_inters;
  struct EMSinters *p_fillet_inters=NULL, *p_model_inters=NULL;
  struct EMSinters *p_inters, *tmp_inters;
  struct EMSvtx_rnd_info *vtx_rnd_info;
  struct EMSpartolbasis partolbasis;
  struct EMSintobj *fwd, *bwd;
  struct EMSsftracedata sftrace;
  struct EMSsfintedpar *bdry_parms[2];
  struct EMSsfintedpar *V0_more_info, *V1_more_info;
  struct EMSpypoint *py_bdry;
  struct EMSdataselect uv_data[2], xyzdata;
  struct BSgeom_bsp_surf geom_surface;
  enum GRdpmode dpmode;
  OM_S_OBJECT_LINKAGE comm_list[1];
  OM_S_CHANSELECT chan_to_loopset, chan_to_common;
  extern void EMsfintedpar_free();
  extern enum EMSvertex_config EMget_vtx_config();
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern struct EMSintobj *EMmakeintlist();
  extern IGRlong EMimpose_boundaries_on_fillet_blends ();

  IGRboolean save_pathway_trim, save_pathway_orient;

  if (_use_timers)
    start_timer (T_EMROUND);

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  fillet_inters = NULL;
  model_inters = NULL;
  edge_rnd_info = NULL;
  end_procd = NULL;
  vtx_rnd_info = NULL;
  vtx_edge_ends = NULL;
  vtx_edges = NULL;
  alloc_crv1 = NULL;
  alloc_crv2 = NULL;
  fillet_surf_nat_edges= NULL;
  V0_edge_object = NULL;
  V1_edge_object = NULL;
  V0_more_info = NULL;
  V1_more_info = NULL;
  bdry_parms[FIRST] = bdry_parms[SECOND] = NULL;
  py_bdry = NULL;
  sf_uv[0] = sf_uv[1] = 0.0;
  intcv.poles = intcv.knots = intcv.weights = NULL;

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  BSEXTRACTPAR( &msg_loc, BSTOLLENVEC, bastol );

  ctrline_cv = NULL;
  ctrline_type = 0;

  /*
   * Initialize the local working variables
   */

  md_env = const_list->env_info;
  mdenv_info = &md_env->md_env;
  os = md_env->md_id.osnum;
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  partolbasis.in_world = TRUE;
  partolbasis.mattyp = mattyp;
  partolbasis.mat = mat;
  fill_patch_id.objid = NULL_OBJID;
  fill_patch = NULL_OBJID;
  geom_surface.sfgen_cv = NULL;

  /*
   * STEP 1: Construct the array of round edge information.
   */

  if (num_edges <= MAX_TO_STACKALLOC)
    edge_rnd_info = (struct EMSedge_rnd_info *) alloca (num_edges *
                     sizeof (struct EMSedge_rnd_info));
  else
    edge_rnd_info = (struct EMSedge_rnd_info *) om$malloc (size = num_edges *
                     sizeof (struct EMSedge_rnd_info));
  EMerr_hndlr (!edge_rnd_info, *msg, EMS_E_NoStackMemory, ret_end);

  for (i=0; i<num_edges; i++)
    {
    edge_rnd_info[i].surf = NULL;
    edge_rnd_info[i].com_surf = NULL;
    edge_rnd_info[i].start_vtx = NULL;
    edge_rnd_info[i].stop_vtx = NULL;
    edge_rnd_info[i].fill_id = NULL_OBJID;
    edge_rnd_info[i].fill_surf = NULL;
    edge_rnd_info[i].fill_surf_tol = 0.0;
    edge_rnd_info[i].fill_isocvs[0] = NULL;
    edge_rnd_info[i].fill_isocvs[1] = NULL;
    edge_rnd_info[i].fill_isocvs_onsfs[0].datatype = EMSdata_null;
    edge_rnd_info[i].fill_isocvs_onsfs[1].datatype = EMSdata_null;
    edge_rnd_info[i].more_info = NULL;
    edge_rnd_info[i].tansf_rnd_info = NULL;
    }

  /*
   * Fill up the information passed in as well as implied by the input.
   */

  for (i=0; i<num_edges; i++)
    {
    edge_rnd_info[i].edge_id = edges[i].boundary_id.objid;
    edge_rnd_info[i].props = edges[i].props;
    edge_rnd_info[i].options = edges[i].options;
    edge_rnd_info[i].radius = edges[i].radius.val;
    edge_rnd_info[i].other_radius =
                              edges[i].props & EMSfillet_is_variable_radius ?
                               edges[i].other_radius.val : edges[i].radius.val;
    edge_rnd_info[i].rho_value =
                           edges[i].props & EMSfillet_rho_specified ?
                            edges[i].rho_value.val : 0.0;
    /*
     * Obtain the surface info for this edge.
     */

    partolbasis.is_valid = FALSE;
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               &edge_rnd_info[i].surf_id, &partolbasis),
               targetid = edge_rnd_info[i].edge_id );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    edge_rnd_info[i].surf_tol = partolbasis.tol;

    tmpid.objid = edge_rnd_info[i].surf_id;
    tmpid.osnum = OM_Gw_current_OS;
    EMgetvggeom (&msg_loc, mattyp, mat, &tmpid, &edge_rnd_info[i].surf, 
     NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Obtain this edge's common edge's surface info.
     */

    partolbasis.is_valid = FALSE;
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               &edge_rnd_info[i].com_surf_id, &partolbasis), 
               senderid = edge_rnd_info[i].edge_id,
               p_chanselect = &chan_to_common);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    edge_rnd_info[i].com_surf_tol = partolbasis.tol;

    tmpid.objid = edge_rnd_info[i].com_surf_id;
    tmpid.osnum = OM_Gw_current_OS;
    EMgetvggeom (&msg_loc, mattyp, mat, &tmpid, &edge_rnd_info[i].com_surf,
     NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Obtain this edges configuration
     */

    stat_OM = om$send (msg = message EMSedge.EMchkconvex (&msg_loc, NULL,
               mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex, &is_neutral,
               &angmeas), targetid = edge_rnd_info[i].edge_id );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    edge_rnd_info[i].edge_config = is_convex ? 
                                    EMSedge_convex : EMSedge_concave;
    }

  /*
   * STEP 2:
   * Get the vertex information, including the vertex configuration which
   * indicates the kind of treatment that needs to be done on it for output.
   */
  
  ex$message( msgnumb=EMS_I_ClassiVerticies);
  
  blksize = num_edges * sizeof (bool2);
  if (num_edges <= MAX_TO_STACKALLOC)
    {
    end_procd = (bool2 *) alloca (blksize);
    EMerr_hndlr (!end_procd, *msg, EMS_E_NoStackMemory, ret_end);
    }
  else
    {
    end_procd = (bool2 *) om$malloc (size = blksize);
    EMerr_hndlr (!end_procd, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  for (i=0; i<num_edges ; i++)
    for (j=START; j<=STOP; j++)
      end_procd[i][j] = FALSE;

  for (inx=0; inx<num_edges; inx++)
    {
    /*
     * If both ends of this edge already processed, go to the
     * next edge.
     */

    if (end_procd[inx][START] && end_procd[inx][STOP])
      continue;

    /*
     * If edge is closed, indicate this in the properties field for
     * the edge. No further processing is necessary. This end can be
     * trivially processed. Go to the next edge.
     */

    stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc, &ed_props),
               targetid = edge_rnd_info[inx].edge_id );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

    if (ed_props & EMED_XYZ_CLOSED)
      {
      edge_rnd_info[inx].props |= EMSfillet_ed_is_xyz_closed;
      end_procd[inx][START] = end_procd[inx][STOP] = TRUE;
      continue;
      } 
      
    /*
     * At every end point of this edge get the vertex information, including
     * the vertex configuration. Also set the pointers to the vertex info
     * for every edge that is to be rounded and which is incident on this
     * vertex.
     */

    stat_OM = om$send (msg = message EMSedge.EMxyz_endpt (&msg_loc, NULL,
               &md_env->md_env, NULL, NULL, endpts[START], endpts[STOP],
               NULL), targetid = edge_rnd_info[inx].edge_id );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

    for (endinx=START; endinx<=STOP; endinx++)
      {
      /*
       * If this end already processed, proceed to the next end
       */

      if (end_procd[inx][endinx])
        continue;

      /*
       * Initialize the fields dealing with edges incident on this
       * vertex.
       */

      vtx_edge_ends = vtx_edge_ends_mem;
      vtx_edges = vtx_edges_mem;
      num_vtx_edges = 0;
      stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (&msg_loc,
                 EMSvtxedges_onlydominant | EMSvtxedges_nodegenerate,
                 endinx, MAX_TO_STACKALLOC,
                 &num_vtx_edges, &vtx_edges, &vtx_edge_ends),
                 targetid = edge_rnd_info[inx].edge_id );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
       ret_end);

      vtx_rnd_info = (struct EMSvtx_rnd_info *) om$malloc (size = 
                       sizeof (struct EMSvtx_rnd_info));
      EMerr_hndlr (!vtx_rnd_info, *msg, EMS_E_NoDynamicMemory, ret_end);

      if (num_vtx_edges <= STATIC_MAX_NUM_EDGES_VTX)
        {
        vtx_rnd_info->edge_ids = vtx_rnd_info->edge_ids_mem;
        vtx_rnd_info->edge_infos = vtx_rnd_info->edge_infos_mem;
        vtx_rnd_info->edge_stops = vtx_rnd_info->edge_stops_mem;
        vtx_rnd_info->edge_configs = vtx_rnd_info->edge_configs_mem;
        }
      else
        {
        ptr = om$malloc (size = num_vtx_edges * sizeof (GRobjid));
        EMerr_hndlr (!ptr, *msg, EMS_E_NoDynamicMemory, ret_end);
        vtx_rnd_info->edge_ids = (GRobjid *) ptr;

        ptr = om$malloc (size = num_vtx_edges * sizeof (IGRchar *));
        EMerr_hndlr (!ptr, *msg, EMS_E_NoDynamicMemory, ret_end);
        vtx_rnd_info->edge_infos = (struct EMSedge_rnd_info **) ptr;

        ptr = om$malloc (size = num_vtx_edges * sizeof (IGRboolean));
        EMerr_hndlr (!ptr, *msg, EMS_E_NoDynamicMemory, ret_end);
        vtx_rnd_info->edge_stops = (IGRboolean *) ptr;

        ptr = om$malloc (size = num_vtx_edges * sizeof (enum EMSedge_config));
        EMerr_hndlr (!ptr, *msg, EMS_E_NoDynamicMemory, ret_end);
        vtx_rnd_info->edge_configs = (enum EMSedge_config *) ptr;
        }

      vtx_rnd_info->num_edges = num_vtx_edges;
      OM_BLOCK_MOVE (vtx_edges, vtx_rnd_info->edge_ids, num_vtx_edges *
       sizeof (GRobjid));
      OM_BLOCK_MOVE (vtx_edge_ends, vtx_rnd_info->edge_stops, num_vtx_edges *
       sizeof (IGRboolean));
      OM_BLOCK_MOVE (endpts[endinx], vtx_rnd_info->vtx_pt, sizeof (IGRpoint));
      for (i=0; i<num_vtx_edges ; i++)
        {
        tmpinx = UNDEFINED;
        for (j=0; j<num_edges; j++)
          if (IF_EQ_OBJID (vtx_edges[i], edge_rnd_info[j].edge_id))
            {
            tmpinx = j;
            break;
            }

        if (tmpinx != UNDEFINED)
          {
          vtx_rnd_info->edge_infos[i] = &edge_rnd_info[tmpinx];
          vtx_rnd_info->edge_configs[i] = edge_rnd_info[tmpinx].edge_config;
          }
        else
          {
          vtx_rnd_info->edge_infos[i] = NULL;

          stat_OM = om$send (msg = message EMSedge.EMchkconvex (&msg_loc,
                     EMSchkconvex_global | EMSchkconvex_nextgeomsf,
                     mattyp, mat, EMS_ZEROANGLE_DEG_MAX,
                     &is_convex, &is_neutral, &angmeas),
                     targetid = vtx_edges[i]);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
           ret_end);

          if (msg_loc == EMS_I_NotFound)
            vtx_rnd_info->edge_configs[i] = EMSedge_undefined;
          else
            vtx_rnd_info->edge_configs[i] =
             !is_neutral ? (is_convex ? 
                             EMSedge_convex : 
                             EMSedge_concave) :
                           (fabs (2.0 - angmeas) < EMS_ZEROANGLE_DEG_MAX ?
                             EMSedge_neutral :
                             (is_convex ?
                               EMSedge_neutral_convex : 
                               EMSedge_neutral_concave));
          }
        }

      /*
       * Set the pointers of the edge-info structures of edges that terminate
       * at this vertex
       */

      for (i=0; i<num_edges; i++)
        {
        for (j=num_vtx_edges-1; j>=0; j--)
          if (IF_EQ_OBJID (edge_rnd_info[i].edge_id, vtx_edges[j]))
            {
            if (vtx_edge_ends[j]) 
              {
              edge_rnd_info[i].stop_vtx = vtx_rnd_info;
              end_procd[i][STOP] = TRUE;
              }
            else  
              {
              edge_rnd_info[i].start_vtx = vtx_rnd_info;
              end_procd[i][START] = TRUE;
              }
            }
          }

      if (vtx_edge_ends && vtx_edge_ends != vtx_edge_ends_mem)
        {
        om$dealloc (ptr = vtx_edge_ends);
        vtx_edge_ends = NULL;
        }
      if (vtx_edges && vtx_edges != vtx_edges_mem)
        {
        om$dealloc (ptr = vtx_edges);
        vtx_edges = NULL;
        }

      vtx_rnd_info->fixed = FALSE;

      vtx_rnd_info->vtx_config = EMget_vtx_config (options, 
                                  vtx_rnd_info, OM_Gw_current_OS);
      EMerr_hndlr (vtx_rnd_info->vtx_config == EMSvertex_not_implemented,
       *msg, EMS_E_NotSupported, ret_end);
      }
    }


  /*
   * STEP 3:
   * Create the fillets at the edges to be rounded, attaching them
   * to a general-composite surface as we go along. This composite is to be
   * used later as the second operand in the "Boolean" operation.
   * The property bits indicating degeneracy of the fillet at either
   * ends and the bit indicating whether the V=0, isoline on the fillet
   * corresponds to the start end of the edge or not are set.
   */

  const_list->geometry = NULL;
  stat_OM = om$construct (classid = OPP_EMSgencompsf_class_id,
             p_objid = &fill_patch_id.objid,
             msg = message GRgraphics.GRconstruct (const_list));
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  fill_patch_id.osnum = OM_Gw_current_OS;

  filopts = EMS_FIL_SINGLE_FILLET | EMS_FIL_BOUND_SURF | 
            EMS_FIL_SURF_ORIENTED | EMS_FIL_CHECK_CURV_PROB;
  if (options & EMS_RND_CHAMFER)
    rho_val = 0.0;
  else
    filopts |= EMS_FIL_DEFAULT_RHO;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);  

  for (i=0; i<num_edges; i++)
    {
    ex$message (msgnumb = EMS_I_CreatingFilletNumber, type="%d", var=`i+1`);

    stat_OM = om$send (msg = message EMSedge.EMinternalpt (&msg_loc, 2,
               NULL, (IGRdouble *) midpts, NULL, NULL),
               targetid = edge_rnd_info[i].edge_id );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    BSsfptseval (edge_rnd_info[i].surf,(IGRint) 2, (IGRdouble *)midpts, 
		(IGRdouble *)midpts_xyz, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, msg_loc, ret_end);

    filopts &= ~(EMS_FIL_NATURAL_NORMAL1 | EMS_FIL_NATURAL_NORMAL2);
    if (edge_rnd_info[i].edge_config == EMSedge_convex)
      {
      filopts |= edge_rnd_info[i].surf->pos_orient == TRUE ?
                  EMS_FIL_NATURAL_NORMAL1 : NULL;
      filopts |= edge_rnd_info[i].com_surf->pos_orient == TRUE ?
                  EMS_FIL_NATURAL_NORMAL2 : NULL;
      }
    else
      {
      filopts |= edge_rnd_info[i].surf->pos_orient == TRUE ?
                   NULL : EMS_FIL_NATURAL_NORMAL1;
      filopts |= edge_rnd_info[i].com_surf->pos_orient == TRUE ?
                   NULL : EMS_FIL_NATURAL_NORMAL2;
      }

    objptr = &edge_rnd_info[i].fill_id;
    srfptr = srfptr_mem;
    propsptr = &fill_props;
    tmpid.objid = edge_rnd_info[i].surf_id;
    tmpid.osnum = OM_Gw_current_OS;
    other_tmpid.objid = edge_rnd_info[i].com_surf_id;
    other_tmpid.osnum = OM_Gw_current_OS;
    radius = edge_rnd_info[i].radius;

    if (edge_rnd_info[i].props & EMSfillet_is_variable_radius)
      {
      if (edge_rnd_info[i].props & EMSfillet_ed_is_xyz_closed)
        {
        *msg = EMS_E_InvalidArg;
        goto ret_end;
        }
      om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, mdenv_info,
       NULL, edge_rnd_info[i].surf, 0, MAXINT, FALSE, NULL, &intcv),
       targetid = edge_rnd_info[i].edge_id);
      if (EMSerror (msg_loc))
        p_intcv = NULL;
      else
        p_intcv = &intcv;

      other_radius = edge_rnd_info[i].other_radius;
      for (j=START; j<=STOP; j++)
        {
        if (j == START)
          vtx_rnd_info = edge_rnd_info[i].start_vtx;
        else
          vtx_rnd_info = edge_rnd_info[i].stop_vtx;

        if (vtx_rnd_info->vtx_config == EMSvertex_tangent_trim &&
            vtx_rnd_info->num_edges == 3)
          {
          endpt[j] = endpts[j];
          modify_endpt_onto_neutral_edge (&edge_rnd_info[i], j, mdenv_info, os,
           endpt[j]);
          extdist[j] = 0.0;
          }
        else
          {
          endpt[j] = vtx_rnd_info->vtx_pt;
          extdist[j] = j == START ? radius : other_radius;
          }
        }

      stat_OM = EMcreate_fillet_surf1_to_surf2_var_rad( &msg_loc, filopts,
                 const_list, &tmpid, edge_rnd_info[i].surf, &other_tmpid,
                 edge_rnd_info[i].com_surf, radius, other_radius, 0.0,
                 endpt[START], endpt[STOP], FALSE,
                 extdist[START], extdist[STOP],
                 NULL, p_intcv,
                 NULL, NULL, NULL, NULL, NULL, NULL,
                 0.0, 0.0, &ctrline_cv, &ctrline_type, midpts_xyz,           
                 options & EMS_RND_CHAMFER ? TRUE : FALSE, rho_val,
                 NULL, &objptr, &srfptr, &propsptr);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      if (intcv.poles)
        om$dealloc (ptr = intcv.poles);
      if (intcv.knots)
        om$dealloc (ptr = intcv.knots);
      if (intcv.weights)
        om$dealloc (ptr = intcv.weights);
      intcv.poles = intcv.knots = intcv.weights = NULL;
      }
    else
      {
      stat_OM = EMcreate_fillet_surf1_to_surf2_const_rad (&msg_loc, filopts,
                 const_list, 
                 &tmpid, edge_rnd_info[i].surf,
                 &other_tmpid, edge_rnd_info[i].com_surf,
                 radius, 2 * radius,
                 FALSE,
                 NULL, NULL, NULL, NULL, NULL, NULL,
                 midpts_xyz, 
                 options & EMS_RND_CHAMFER, 
                 rho_val, 
                 NULL, &objptr, &srfptr, &fsf_type, &propsptr);
     EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
     }
 
    edge_rnd_info[i].fill_surf = srfptr[FIRST];
    edge_rnd_info[i].props |= fill_props;

    fsrf = edge_rnd_info[i].fill_surf;

#if WBC_USE_NEW_MATH
      EFinit_geom_surface(&msg_loc, fsrf, edge_rnd_info[i].fill_id,
                          const_list->env_info->md_id.osnum, &geom_surface);
      EMerr_hndlr (!(msg_loc & 1), *msg, EMS_E_BSerror, ret_end);

      count = 1;
#endif

    if (edge_rnd_info[i].props & EMSfillet_ed_is_xyz_closed)
    {
      if (!fsrf->v_phy_closed)
      {
        ex$message (msgnumb = EMS_S_FilletCrvCspProblem);
        sleep (3);
        *msg = EMS_E_SurfaceError;
        if (fsf_type)
          om$dealloc (ptr = fsf_type);
        goto ret_end;
      }
    }

    for (endinx=START; endinx<=STOP; endinx++)
    {
      if (fsrf->v_phy_closed)
        pt = midpts_xyz[endinx];
      else if (endinx == START)
        pt = edge_rnd_info[i].start_vtx->vtx_pt;
      else
        pt = edge_rnd_info[i].stop_vtx->vtx_pt;

#if WBC_USE_NEW_MATH
      BSprptarrsf(&geom_surface, bastol, 2, 2, &count, pt, sf_uv, dumpt,
                  &onsrf, NULL, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      u[endinx] = sf_uv[0];
      v[endinx] = sf_uv[1];
#else
      {
        IGRdouble dist; /* Remove this, when removing WBC_...
                         * Inserted here to stop compiler warning.
                         */

        BSmdistptsf (&msg_loc, fsrf, pt, &u[endinx], &v[endinx], dumpt, &dist);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      }
#endif

    }

#if WBC_USE_NEW_MATH
      if (geom_surface.sfgen_cv)
      {
          BSfreecv(&msg_loc, geom_surface.sfgen_cv);
          geom_surface.sfgen_cv = NULL;
      }
#endif

     if (v[START] < v[STOP])
       edge_rnd_info[i].props |= EMSfillet_v0_closeto_start_end;
 
     BSsfkttol2 (fsrf->u_order, fsrf->v_order, fsrf->u_knots, fsrf->v_knots,
      fsrf->u_num_poles, fsrf->v_num_poles, fsrf->poles, fsrf->weights,
      &edge_rnd_info[i].fill_surf_tol, &msg_loc);
     EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 
     stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                &fill_patch_id, ( IGRlong * ) &i),
                targetid = edge_rnd_info[i].fill_id);
     EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

     if( !( edge_rnd_info[i].props & EMSfillet_is_variable_radius ) )
     {
      stat_OM = EMmodify_fillet (&msg_loc, NULL, md_env, &edge_rnd_info[i]);
      /* continue on error */
     }

    fsrf = edge_rnd_info[i].fill_surf;
    u[FIRST] = 0.0;
    u[SECOND] = 1.0;
    for (j=FIRST; j<=SECOND; j++)
      {
      BSalloccv (fsrf->v_order, fsrf->v_num_poles, fsrf->rational, 0,
       &alloc_crv1, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      tst_plan = TRUE;
      isodir = CONST_U;
      BSconstprcv (&msg_loc, fsrf, &isodir, &u[j], &tst_plan, alloc_crv1);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      edge_rnd_info[i].fill_isocvs[j] = alloc_crv1;
      alloc_crv1 = NULL;

      xyzdata.datatype = EMSdata_curve3d;
      xyzdata.data.curve = edge_rnd_info[i].fill_isocvs[j];
      if (j == FIRST)
        {
        srf = edge_rnd_info[i].surf;
        uvtol = edge_rnd_info[i].surf_tol;
        edge_id = edge_rnd_info[i].edge_id;
        }
      else
        {
        srf = edge_rnd_info[i].com_surf;
        uvtol = edge_rnd_info[i].com_surf_tol;
        count = 0;
        stat_OM = om$get_channel_objects (objid = edge_rnd_info[i].edge_id,
                                          p_chanselect = &chan_to_common,
                                          count = ( IGRuint * ) &count,
                                          size = 1,
                                          list = comm_list);
        if( !count ) continue;
        edge_id = (GRobjid) comm_list[0].S_objid;
        }
        tst_plan = EMS_O_Unknown;
        onsrf = 0;

        stat_OM = om$send (msg = message EMSedge.EMinternalpt (&msg_loc, 1,
                   NULL, (IGRdouble *) edge_mid_pt, NULL, NULL),
                   targetid = edge_id );
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg,EMS_E_Fail,ret_end);

        /* Get the xyz mid-pt of the edge. */
        BSsfeval (srf, edge_mid_pt[0], edge_mid_pt[1], 0, srf_pt, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        EMmapcvxyz_to_uv_mod (&msg_loc, 
              EMS_RMED_ALNG_NATBDRY | EMS_TRIM_AGAINST_NATBDRY, srf, &xyzdata,
              chttol, uvtol, &tst_plan, &edge_rnd_info[i].fill_isocvs_onsfs[j],
              &onsrf, srf_pt);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    }
    {
    IGRboolean int_f = FALSE;
    for (i=0; i<num_edges-1;i++)
      {
      if (edge_rnd_info[i].props & EMSfillet_ed_is_xyz_closed)
        {
        for (j=i+1; j<num_edges;j++)
          {
          int_f = check_fillet_fillet_interaction (&edge_rnd_info[i],
                                                   &edge_rnd_info[j]);
          EMerr_hndlr (int_f, *msg, EMS_E_NotSupported, ret_end);
          }    
        }
      }
    }
  /*
   * STEP 4:
   * Process every vertex. Depending on the type of the vertex configuration,
   * different kinds of processing is carried out. In this process, new
   * blend/patch surfaces may be generated. "Intersections" are generated
   * on the fillets which will serve to trim them back. Corresponding 
   * "intersections" are maintained on the model and the blend/patch surfaces.
   *
   * Exceptions:
   * If edge to be rounded is closed, the fillet also should be closed. 
   * In this case, the processing is special. The V-ends of the fillet 
   * (seam edges) are added specially to the intersection list.
   * 
   * If the fillet degenerates down to a point at the vertex, then
   * this is a special siutation. This vertex will not have any more
   * processing to go through. Only, the degenerate end of the fillet needs
   * to be properly put into fillet intersection list.
   *
   * Note:
   * After some more processing, the fillets may be joined in with the model
   * and the blends/patches at these intersections to produce a topologically
   * closed system. Some of the intersections on the blends/patches may
   * correspond to the natural edges of the surface.
   */

  for (i=0, entity_num=1; i<num_edges; i++)
    {
    p_edge_rnd_info = &edge_rnd_info[i];
    fsrf = p_edge_rnd_info->fill_surf;
    fill_props = p_edge_rnd_info->props;

    /*
     * Take care of the first exception. That is, the edge is closed
     * and the fillet has V-seam. In this case, both the ends of this
     * edge have been processed in one go, here.
     */

    if (fill_props & EMSfillet_ed_is_xyz_closed)
      {
      ex$message (msgnumb = EMS_I_ProcessingVertexNumber,
       type="%d", var=`entity_num`);
      entity_num++;

      array_size = num_surf_edges = 0;
      stat_OM = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc, MAXINT,
                 EMS_OPT_NATURAL, md_env, &fillet_surf_nat_edges,
                 &array_size, &num_surf_edges ),
                 targetid = p_edge_rnd_info->fill_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
       ret_end);

      tmpid.objid = p_edge_rnd_info->fill_id;
      tmpid.osnum = OM_Gw_current_OS;

      xyzdata.datatype   = EMSdata_null;
      xyzdata.data.curve = NULL;

      V0_edge_object = (struct GRid *) om$malloc
                        (size = sizeof (struct GRid));
      EMerr_hndlr (!V0_edge_object, *msg, EMS_E_NoDynamicMemory,
       ret_end);
      *V0_edge_object = fillet_surf_nat_edges[V0];
      uv_data[0].datatype = EMSdata_object;
      uv_data[0].data.object = V0_edge_object;

      V1_edge_object = (struct GRid *) om$malloc
                        (size = sizeof (struct GRid));
      EMerr_hndlr (!V1_edge_object, *msg, EMS_E_NoDynamicMemory,
       ret_end);
      *V1_edge_object = fillet_surf_nat_edges[V1];
      uv_data[1].datatype = EMSdata_object;
      uv_data[1].data.object = V1_edge_object;
  
      V0_more_info = EMsfintedpar_malloc (&msg_loc, 2);
      V1_more_info = EMsfintedpar_malloc (&msg_loc, 2);
      EMerr_hndlr (!V0_more_info || !V1_more_info, *msg, EMS_E_NoDynamicMemory,
       ret_end );

      EMmakeintlist (&msg_loc, &fillet_inters, &fillet_inters, 
       &tmpid, &tmpid, NULL,NULL,
       EMSinters_loopcreated,
       EMSinters_loopcreated,
       &xyzdata,
       &uv_data[0], &uv_data[1],
       FALSE, FALSE,
       (IGRchar*) V0_more_info, (IGRchar*) V1_more_info,
       EMSintobj_marked | EMSintobj_tangent, 
       EMSintobj_marked | EMSintobj_tangent, 
       NULL, NULL, 
       TRUE,FALSE);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      V0_edge_object = NULL;
      V1_edge_object = NULL;
      V0_more_info = NULL;
      V1_more_info = NULL;

      continue;
      }

    /*
     * Process each end of the edge separately.
     */

    for (endinx=START; endinx<=STOP; endinx++)
      {
      vtx_rnd_info = endinx == START ?
                      p_edge_rnd_info->start_vtx : p_edge_rnd_info->stop_vtx;

      if (vtx_rnd_info->fixed)
        continue;

      if ((endinx == START ? TRUE : FALSE) ^
          (fill_props & EMSfillet_v0_closeto_start_end ? TRUE : FALSE))
        processing_v0 = FALSE;
      else
        processing_v0 = TRUE;

      /*
       * Take care of the second exception to the general vertex processing,
       * that of having the fillet degenerate to a point at this vertex.
       */

      ex$message (msgnumb = EMS_I_ProcessingVertexNumber,
       type="%d", var=`entity_num`);
      entity_num++;

      if (((processing_v0 && fill_props & EMSfillet_v0_is_degenerate) ||
           (!processing_v0 && fill_props & EMSfillet_v1_is_degenerate)) &&
          is_degen_end_at_vertex (fsrf, processing_v0, vtx_rnd_info->vtx_pt))
        {
        BSalloccv (2, 2, FALSE, 0, &alloc_crv1, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        BSptcvgen (vtx_rnd_info->vtx_pt, 2, FALSE, alloc_crv1, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        xyzdata.datatype = EMSdata_curve3d;
        xyzdata.data.curve = alloc_crv1;
        alloc_crv1 = NULL;

        idptr = &ids[NATEDS];
        count = 0;
        stat_OM = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc,
                   MAXINT, EMS_OPT_NATURAL, md_env, &idptr, &four, &count),
                   targetid = p_edge_rnd_info->fill_id);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM) || count != 4, *msg,
         EMS_E_Fail, ret_end);
        for (j=U0; j<=V0; j++)
          nateds[j] = idptr[j].objid;

        uv_data[FIRST].datatype = EMSdata_object;
        idptr = (struct GRid *) om$malloc (size = sizeof (struct GRid));
        EMerr_hndlr (!idptr, *msg, EMS_E_NoDynamicMemory, ret_end);
        idptr->objid = nateds[processing_v0 ? V0 : V1];
        idptr->osnum = OM_Gw_current_OS;
        uv_data[FIRST].data.object = idptr;

        bdry_parms[FIRST] = EMsfintedpar_malloc (&msg_loc, 2);
        EMerr_hndlr (!bdry_parms[FIRST], *msg, EMS_E_NoDynamicMemory, ret_end);

        props = EMSintobj_marked | EMSintobj_xyzdegenerate;
        tmpid.objid = p_edge_rnd_info->fill_id;
        tmpid.osnum = OM_Gw_current_OS;
        EMmakeintlist (&msg_loc, &fillet_inters, NULL,
         &tmpid, NULL, NULL, NULL, NULL, NULL,
         &xyzdata, &uv_data[FIRST], NULL,
         FALSE, FALSE,
         bdry_parms[FIRST], NULL,
         props, NULL, NULL, NULL, TRUE, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        bdry_parms[FIRST] = NULL;

        continue;
        }

      switch (vtx_rnd_info->vtx_config)
        {
        case EMSvertex_spherical_blend :
          stat_OM = EMspherical_blend (&msg_loc, options,
                     const_list, vtx_rnd_info, &fill_patch_id,
                     &fillet_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;

        case EMSvertex_3edge_rolling_ball:
          if (options & EMS_RND_CHAMFER)
            stat_OM = EMspherical_blend (&msg_loc, options,
                       const_list, vtx_rnd_info, &fill_patch_id,
                       &fillet_inters);
          else 
            stat_OM = EM3edge_rolling_ball (&msg_loc, options,
                       const_list, vtx_rnd_info, &fill_patch_id,
                       &fillet_inters, &model_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;
          
        case EMSvertex_general_blend:
          stat_OM = EMget_n_sided_blend (&msg_loc, options,
                     const_list, vtx_rnd_info, &fill_patch_id,
                     &fillet_inters, &model_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;

        case EMSvertex_3edge_single_trim:
          stat_OM = EM3edge_single_trim( &msg_loc, options, const_list,
                     vtx_rnd_info, &fillet_inters, &model_inters );
          if (EMSerror (stat_OM & msg_loc))
            {
            /* Failure could be due to bounded model surface resulting
             * in an inaccurate intersection between fillet and model.
             * In such cases, it is feasible to attempt to generate a
             * single patch.
             */

            stat_OM = EMsingle_patch (&msg_loc, options, const_list,
                       vtx_rnd_info, &fill_patch_id,
                       &fillet_inters, &model_inters);
            EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
             ret_end);
            }
          break;

        case EMSvertex_single_patch:
          stat_OM = EMsingle_patch (&msg_loc, options,
                     const_list, vtx_rnd_info, &fill_patch_id,
                     &fillet_inters, &model_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;

        case EMSvertex_general_trim :
          stat_OM = EMgeneral_trim (&msg_loc, options,
                     const_list, vtx_rnd_info, &fill_patch_id,
                     &fillet_inters, &model_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;

        case EMSvertex_2edge_cx_1edge_cv:
          stat_OM = EM2edge_cx_1edge_cv (&msg_loc, options,
                     const_list, vtx_rnd_info, &fill_patch_id,
                     &fillet_inters, &model_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;

        case EMSvertex_tangent_trim:
          stat_OM = EMtangent_trim (&msg_loc, options,
                     const_list, vtx_rnd_info, &fill_patch_id,
                     &fillet_inters, &model_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;
      
        case EMSvertex_open:
          stat_OM = EMopen_surf_round (&msg_loc, options, const_list,
                     vtx_rnd_info, &fillet_inters);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
           ret_end);
          break;
      
        default:
          *msg  = EMS_E_NotSupported;
          goto ret_end; 
        }
      vtx_rnd_info->fixed = TRUE; 
      }
    }

  /*
   * STEP 5:
   * At this point we have the intersection list consisting of pieces at the
   * "ends" of the fillets. To topologically close, intersections must be
   * generated using the iso boundary curves of the fillets on the surface and
   * common edge surface. In fact, only a portion of these iso-curves will
   * be relevant for this fillet. The intersection on the fillet is generated
   * as a part of an iso-curve and the corresponding "intersection" on the
   * model is generated via mapping. Add these pieces to the inters list,
   * orienting them properly. The fillet-iso-curve is easily oriented as we
   * know that these edges go to form a P-loop. The orientation of the mapped
   * curve on the model will be opposite that of the fillet-iso-curve if the
   * orientation of the fillet-surface and the model-surface are the same
   * (just as in a winged-edge data-structure). All the iso-curve intersections
   * generated on the fillet are marked specially.
   * 
   * The intersections on the fillets are re-arranged such that the very
   * first intersection in the linked list against a given surface is
   * a marked one. Such an intersection is special since we know for
   * sure that it will form an edge in the final result. Unlike some other
   * intersections that may have been create on the fillet which may eventually
   * get thrown out. Making such an intersection the very first one ensures
   * that the subsequently called trace algorithm will pick this intersection
   * up to form the first group.
   */

  u[FIRST] = 0.0;
  u[SECOND] = 1.0;
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  ids[FILLET].osnum = ids[MODEL].osnum = OM_Gw_current_OS;
  for (i=0, entity_num = 1; i<num_edges; i++)
    {
    ex$message( msgnumb=EMS_I_TrimmingFillets, type="%d", var=`entity_num` );
    entity_num++;

    p_edge_rnd_info = &edge_rnd_info[i];
    fsrf = p_edge_rnd_info->fill_surf;
    ids[FILLET].objid = p_edge_rnd_info->fill_id;

    idptr = &ids[NATEDS];
    count = 0;
    stat_OM = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc, MAXINT,
               EMS_OPT_NATURAL, md_env, &idptr, &four, &count),
               targetid = p_edge_rnd_info->fill_id);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM) || count != 4, *msg, EMS_E_Fail,
     ret_end);
    for (j=U0; j<=V0; j++)
      nateds[j] = idptr[j].objid;

    _process_tply = _process_tply_interaction;

      BSalloccv (fsrf->v_order, fsrf->v_num_poles, fsrf->rational, 0,
       &alloc_crv1, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
      no_interaction = TRUE;

      for (j=FIRST, k=U0; j<=SECOND; j++, k=U1)
      {
        /*
         * Obtain the relevant portion of the iso-curve 
         */
  
        fwd = bwd = NULL;
        uvchttol = p_edge_rnd_info->fill_surf_tol * chttol / bastol;
        get_part_nat_edge_split_info (&msg_loc, md_env, uvchttol,
                 chttol, fillet_inters, p_edge_rnd_info->fill_id,
  	       j, nateds[k], &bwd, &fwd, &v[FIRST], &v[SECOND]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
        EMerr_hndlr((k == U0 && v[FIRST] > v[SECOND]) ||
                 (k == U1 && v[FIRST] < v[SECOND]), *msg, EMS_E_Fail, ret_end);

        /*
         * It is possible for a fillet to maintain its natural edges, without
         * any modifications (ex: in the case of rounding an edge that is closed
         * in xyz space).  The loop on such fillets need any modification, thus
         * these fillets do NOT get traced in STEP 6.  In the following, ensure
         * that such fillet's already existing U0/U1 objects are extracted as
         * the intobj.
         */
            /*
             * Get a reference to the fillet inters that is currently
             * being processed.
             */
                for( tmp_inters = fillet_inters; tmp_inters;
  					tmp_inters = tmp_inters->next )
  
                   if( IF_EQ_OBJID( tmp_inters->this_obj.objid,
  					p_edge_rnd_info->fill_id ) )
  		   break;
            
            if( tmp_inters->props & EMSinters_loopcreated )
            {
               idptr = ( struct GRid * ) om$malloc ( size =
  					sizeof( struct GRid ) );
               EMerr_hndlr( !idptr, *msg, EMS_E_NoDynamicMemory, ret_end );
               idptr->osnum = OM_Gw_current_OS;
               idptr->objid = nateds[ k ];
               uv_data[FILLET].datatype = EMSdata_object;
               uv_data[FILLET].data.object = idptr;
            }
            else
            {
               uv_data[FILLET].datatype = EMSdata_poly2d;
               py = (struct IGRpolyline *) om$malloc (size = 
                     sizeof (struct IGRpolyline));
               pts = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
               EMerr_hndlr (!py || !pts, *msg, EMS_E_NoDynamicMemory, ret_end);
               py->num_points = 2;
               py->points = pts;
               pts[0] = pts[2] = u[j];
               pts[1] = v[FIRST]; pts[3] = v[SECOND];
               uv_data[FILLET].data.poly = py;
            }
  
        /*
         * Obtain the corresponding xyz-data on the model
         */
  
        tst_plan = TRUE;
        isodir = CONST_U;
        BSconstprcv (&msg_loc, fsrf, &isodir, &u[j], &tst_plan, alloc_crv1);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
        BSalloccv (fsrf->v_order, fsrf->v_num_poles + 2 * fsrf->v_order - 1,
         fsrf->rational, 0, &alloc_crv2, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
        BSpartofcv (&msg_loc, alloc_crv1,
         k == U1 ? v[SECOND] : v[FIRST],
         (v[FIRST] + v[SECOND]) / 2.0,
         k == U1 ? v[FIRST] : v[SECOND],
         alloc_crv2);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        if (k == U1)
          BSrev_cv (&msg_loc, alloc_crv2);
  
        xyzdata.datatype = EMSdata_curve3d;
        xyzdata.data.curve = alloc_crv2;
        alloc_crv2 = NULL;
  
        /*
         * Obtain the corresponding uv-data on the model
         */

        if (j == FIRST)
          {
          srf = p_edge_rnd_info->surf;
          uvtol = p_edge_rnd_info->surf_tol;
          ids[MODEL].objid = p_edge_rnd_info->surf_id;
          }
        else
          {
          srf = p_edge_rnd_info->com_surf;
          uvtol = p_edge_rnd_info->com_surf_tol;
          ids[MODEL].objid = p_edge_rnd_info->com_surf_id;
          }
        tst_plan = EMS_O_Unknown;
        EMmapcvxyz_to_uv (&msg_loc, EMS_TRIM_AGAINST_NATBDRY, srf, &xyzdata,
         chttol, uvtol, &tst_plan, &uv_data[MODEL], &onsrf);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
        /*
         * Obtain the bdry-parameters for the fillet and the model
         * intersections (the info on where they intersect the
         * model topology; in the case of the fillet this information
         * can be NULL).
         */
  
        partolbasis.is_valid = TRUE;
        partolbasis.tol = uvtol * chttol / bastol;
        count = 0;
        stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                   &uv_data[MODEL], &partolbasis, EMS_INTER_BDRYISAREA, &count,
                   &py_bdry, &bdry_parms[MODEL]), 
                   p_chanselect = &chan_to_loopset, senderid = ids[MODEL].objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
        if(count !=1 || !chkatend (&xyzdata, py_bdry, srf))
        {
          if(_process_tply)
          {
            /*
             * A possible interaction has been hit. This might be while
             * processing the first or the second iso. If first, then fine.
             * Otherwise, we have to erase all memories of having processed
             * the edge. ie delete the intersections that have been created
             * this far and try out the interaction processing.
             *
             * Interaction processing will generate its own intersections
             * on the fillet and model, for both the isos, and return it in
             * fillet_inters & model_inters respectively.
             */
            if(p_fillet_inters)
            {
              EMinters_data_free (&msg_loc, p_fillet_inters, MAXINT, NULL,
                                  EMsfintedpar_free);
              EMerr_hndlr (!(1 & msg_loc), *msg, EMS_E_Fail, ret_end);

              EMinters_free (p_fillet_inters, MAXINT);
              p_fillet_inters = NULL;
            }

            if(p_model_inters)
            {
              EMinters_data_free (&msg_loc, p_model_inters, MAXINT, NULL,
                                  EMsfintedpar_free);
              EMerr_hndlr (!(1 & msg_loc), *msg, EMS_E_Fail, ret_end);

              EMinters_free (p_model_inters, MAXINT);
              p_model_inters = NULL;
            }

            stat_OM = EMget_rnd_topology_int_data (&msg_loc,
                                                   options,
                                                   const_list,
                                                   p_edge_rnd_info,
                                                   &fill_patch_id,
                                                   &fillet_inters,
                                                   &model_inters);
            EMerr_hndlr (!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

            /*
             * Successfully completed interaction procesing. Now, continue
             * processing the other edges.
             */
            no_interaction = FALSE;
            break;
          }
          else
          {
            EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end); 
          }
        }

        /* If either or both ends of the fillets are degenerate, then it is
         * possible that the incident information is incorrect, due to EMS
         * representation of certain topology. (this was an observation made
         * during the rounding of an intersection edge between two identical
         * diameter cylinders with their axis at right angles, and the axis
         * intersecting).  Check and adjust the incident information.
         */
            stat_OM = check_and_adjust_bdry_parms( &msg_loc, md_env,
                        &uv_data[ MODEL ],
                        j == FIRST ? TRUE : FALSE, p_edge_rnd_info,
                        bdry_parms[ MODEL ] );
            EMerr_hndlr( !( 1 & stat_OM & msg_loc ), *msg, EMS_E_Fail,
                         ret_end );
  
        bdry_parms[FILLET] = EMsfintedpar_malloc (&msg_loc, 2);
        EMerr_hndlr (!bdry_parms[FILLET], *msg, EMS_E_NoDynamicMemory, ret_end);
  
        /*
         * Add to the intersection lists.
         */

        p_intobj = EMmakeintlist (&msg_loc, &p_fillet_inters, &p_model_inters,
                    &ids[FILLET], &ids[MODEL], NULL, NULL, NULL, NULL,
                    &xyzdata, &uv_data[FILLET], &uv_data[MODEL],
                    FALSE, !(srf->pos_orient ^ fsrf->pos_orient),
                    bdry_parms[FILLET], bdry_parms[MODEL],
                    EMSintobj_marked | EMSintobj_isocurve |
                    EMSintobj_exact_atstart | EMSintobj_exact_atstop |
                    (options & EMS_RND_CHAMFER ? NULL : EMSintobj_tangent),
                    options & EMS_RND_CHAMFER ? NULL : EMSintobj_tangent,
                    NULL, NULL, TRUE, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        bdry_parms[FILLET] = NULL;
        bdry_parms[MODEL] = NULL;
  
        /*
         * If the connectivity to some other intersection is known
         * put that information in.
         */
  
        if (fwd)
          {
          p_intobj->fwd = fwd;
          p_intobj->props |= EMSintobj_fwd_connectuv;
          p_intobj->fwd->bwd = p_intobj;
          p_intobj->fwd->props |= EMSintobj_bwd_connectuv;
          }
        if (bwd)
          {
          p_intobj->bwd = bwd;
          p_intobj->props |= EMSintobj_bwd_connectuv;
          p_intobj->bwd->fwd = p_intobj;
          p_intobj->bwd->props |= EMSintobj_fwd_connectuv;
          }
  
        if(py_bdry)
          {
          EMpypoint_free( py_bdry, 0 );
          py_bdry = NULL;
          }
      }

      if(no_interaction)
      {
        /*
         * The intobjs are generated on temporary nodes. Merge them
         * into the fillet and model intersecion lists.
         */
        EMmergeinters ( &msg_loc, &fillet_inters, p_fillet_inters);
        EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
        p_fillet_inters = NULL;

        EMmergeinters ( &msg_loc, &model_inters, p_model_inters);
        EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
        p_model_inters = NULL;
      }
  
      if (alloc_crv1)
        {
        BSfreecv (&msg_loc, alloc_crv1);
        alloc_crv1 = NULL;
        }
    }

  /*
   * STEP 6:
   * The intersection list of the fillet surfaces is traced first on a per
   * surface basis. On any fillet surface there should be one and only one
   * group which will have one closed sub_group. If there are any open groups,
   * all the elements of this group are deleted. All the non-object uv-space
   * data is then converted to OM-object (EMSedge) data. The closed group on
   * each fillet surface is imposed as the boundary for fillet surface.
   *
   * The intersection list for the model is traced next which must yield only
   * closed groups. Calling the Boolean function with this model-inters list
   * completes the rounding operation.
   */

  ex$message( msgnumb=EMS_I_ImpBndOnFillets );
  
  stat_OM = EMimpose_boundaries_on_fillet_blends (&msg_loc, options, md_env,
                                     num_edges, edge_rnd_info, fillet_inters);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, msg_loc, ret_end);

  /*
   * Using the intersection list on the model, impose boundaries
   * on it. Make sure that the uv-data in the intersection list
   * are all EMSedges.
   */

  ex$message( msgnumb=EMS_I_ImpBndOnModel );

  for (p_inters=model_inters; p_inters; p_inters=p_inters->next)
    {
    p_intobj = p_inters->cvs;
    while (p_intobj)
      {
      EMconvert_to_edge (&msg_loc, p_intobj, os);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      if (p_intobj->other_intobj_node)
        {
        EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, os);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      p_intobj = p_intobj->next;
      }
    }

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  loc_opts =   EMS_SFINT_MUSTORIENT | EMS_SFINT_SKIPSFINT | 
	       EMS_SFINT_SKIPFIXING | EMS_SFINT_CHTTRACETOL |
	       EMS_SFINT_PUSHBADCOINC;
  stat_OM = EMintersect_surfaces (&msg_loc, NULL, mdenv_info, 
             0, NULL, NULL, loc_opts, NULL, NULL, NULL, const_list, NULL,
             &model_inters, NULL, &sftrace, NULL, NULL, NULL,
             NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  tmpid.objid = my_id;
  tmpid.osnum = OM_Gw_current_OS;
  fill_patch = fill_patch_id.objid;
  loc_opts =  EMSsfbool_opt_OpenIntPossible | EMSsfbool_opt_SingleTopology |
	      EMSsfbool_opt_display | EMSsfbool_opt_HandleStop |
	      EMSsfbool_opt_ConnectToComEdge;
  stat_OM = EMboolean_surfaces_w_intersection (&msg_loc, &tmpid,
             EMSbool_intersect, md_env, model_id->objid, 1, &fill_patch,
             model_inters, NULL, &sftrace, NULL, NULL, NULL, loc_opts,
             display_count, display_ids, NULL);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
     sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
     sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  dpmode = GRbd; 
  om$send (msg = message GRgraphics.GRdisplay (&msg_loc, mattyp, mat,
   &dpmode, &md_env->md_id), targetid = fill_patch);

ret_end:
  if( V0_edge_object )
    om$dealloc( ptr = V0_edge_object );
  if( V1_edge_object )
    om$dealloc( ptr = V1_edge_object );
  if( fillet_surf_nat_edges )
    om$dealloc( ptr = fillet_surf_nat_edges );

  EMsfintedpar_free( V0_more_info, MAXINT );
  EMsfintedpar_free( V1_more_info, MAXINT );

  EMinters_data_free (&msg_loc, fillet_inters, MAXINT, NULL,
   EMsfintedpar_free);
  EMinters_free (fillet_inters, MAXINT);

  EMinters_data_free (&msg_loc, model_inters, MAXINT, NULL,
   EMsfintedpar_free);
  EMinters_free (model_inters, MAXINT);

  if(p_fillet_inters)
  {
    EMinters_data_free (&msg_loc, p_fillet_inters, MAXINT, NULL,
                        EMsfintedpar_free);
    EMinters_free (p_fillet_inters, MAXINT);
  }

  if(p_model_inters)
  {
    EMinters_data_free (&msg_loc, p_model_inters, MAXINT, NULL,
                        EMsfintedpar_free);
    EMinters_free (p_model_inters, MAXINT);
  }

  /*
   * Free the internals of each edge round information packet.
   * Then, if required, free the array itself.
   */
      EMSedge_rnd_info_free (&msg_loc, num_edges, edge_rnd_info);
      if( num_edges > MAX_TO_STACKALLOC && edge_rnd_info )
         om$dealloc( ptr = edge_rnd_info );

  if (end_procd && num_edges > MAX_TO_STACKALLOC)
    om$dealloc (ptr = end_procd);

  if (vtx_edge_ends && vtx_edge_ends != vtx_edge_ends_mem)
    om$dealloc (ptr = vtx_edge_ends);
  if (vtx_edges && vtx_edges != vtx_edges_mem)
    om$dealloc (ptr = vtx_edges);

  if (alloc_crv1)
    BSfreecv (&msg_loc, alloc_crv1);
  if (alloc_crv2)
    BSfreecv (&msg_loc, alloc_crv2);

  EMsfintedpar_free (bdry_parms[FIRST], MAXINT);
  EMsfintedpar_free (bdry_parms[SECOND], MAXINT);

  EMpypoint_free( py_bdry, 0 );

  if (intcv.poles)
    om$dealloc (ptr = intcv.poles);
  if (intcv.knots)
    om$dealloc (ptr = intcv.knots);
  if (intcv.weights)
    om$dealloc (ptr = intcv.weights);

  if (!_keep_fillets_patches && EMSerror (*msg & stat_OM) && 
      fill_patch_id.objid != NULL_OBJID)
    om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
     targetid =  fill_patch_id.objid);

  if (_use_timers)
    stop_timer (T_EMROUND, FALSE, "");

  EMWRAPUP (*msg, stat_OM, "EMSsfrndbool.EMround");
  return (stat_OM);
}

#argsused

static void get_part_nat_edge_split_info (msg, md_env, par_tol, xyz_tol, 
                                          inters, sfobj,
                                          nat_edge_loc, nat_edge,
                                          bwd, fwd, bwd_v, fwd_v)
IGRlong  *msg;
struct GRmd_env *md_env;
IGRdouble par_tol, xyz_tol;
struct EMSinters *inters;
GRobjid sfobj;
IGRshort nat_edge_loc;
GRobjid nat_edge;
struct EMSintobj **bwd, **fwd;
IGRdouble *bwd_v, *fwd_v;
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
  struct EMSsfintedpar *EMsfintedpar_malloc();

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
      p_sfintedpar = EMsfintedpar_malloc (&msg_loc, 2);
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
               else
                  if ( is_equal == FALSE || dotp < discr_dotp[ bndinx ] )
                  {
                     bndpts[bndinx][V] = endv;
                     continuity_ptr[sign == POSITIVE ? BWD : FWD] = p_intobj;
                     discr_dotp[ bndinx] = dotp;
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


#argsused

static void check_fillet_or_surf (msg, num_edges, ed_rnd_info, srfobj,
                                  info_inx, is_fillet)
IGRlong *msg;
IGRint num_edges;
struct EMSedge_rnd_info *ed_rnd_info;
GRobjid srfobj;
IGRint *info_inx;
IGRboolean *is_fillet;
{
  IGRint inx;

  *msg = EMS_S_Success;

  for (inx=0; inx<num_edges; inx++)
    {
    if (ed_rnd_info[inx].surf_id == srfobj ||
        ed_rnd_info[inx].com_surf_id == srfobj)
      {
      *is_fillet = FALSE;
      *info_inx = inx;
      *msg = EMS_I_Found;
      break;
      }
    else if (ed_rnd_info[inx].fill_id == srfobj)
      {
      *is_fillet = TRUE;
      *info_inx = inx;
      *msg = EMS_I_Found;
      break;
      }
    }
  return;
}




#argsused

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
      EMerr_hndlr (EMSerror (stat_OM) || !edge_returned, stat_func, FALSE,
       ret_end);

      if (nxtedge == edge)
        stat_func = TRUE;
      }
    }

ret_end:
  return (stat_func);
}


/*
 * DESCRIPTION:
      If a fillets V0 and/or V1 is degenerate, then EMSloopset.EMlsparttrim()
      generated edge incident information, for the counter-part of fillet's
      U0 and U1 on the model, may be incorrect, Under these conditions, force
      the incident information to contain the round edge.

 * OPTIONS:
      none

 * INPUT:
      md_env
      cv_on_sf		The counter-part of fillet's U0 or U1, on the
                        appropriate model surface.  The incident information
                        is generated for this curve.
      processing_U0	TRUE if U0 of fillet is being processed, else FALSE.
      rnd_ed_info	The information packet on the edge being rounded.
      bdry_parms	Typically, EMSloopset.EMlsparttrim() generated
                        boundary information.  This and its next must not be
                        NULL.
 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      bdry_parms	Possibly, modified boundary information.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 04/16/93 : Original.
 */

#argsused

IGRlong check_and_adjust_bdry_parms( EMmsg, md_env, cv_on_sf,
                   processing_U0, rnd_ed_info, bdry_parms )

IGRlong			*EMmsg;
struct GRmd_env 	*md_env;
struct EMSdataselect	*cv_on_sf;
IGRboolean		processing_U0;
struct EMSedge_rnd_info	*rnd_ed_info;
struct EMSsfintedpar	*bdry_parms;
{
   OMuint		count;
   IGRlong		OM_stat, msg;
   GRobjid		incident_ed;
   GRspacenum		osnum;
   OM_S_CHANSELECT      to_common_ed;
   OM_S_OBJECT_LINKAGE  comm_ed_list[1];
   PT_IN_UV		end_pts[2];

   struct EMSproj_info	 new_bdry_info;
   struct EMSpartolbasis par_tol_basis;
   struct EMSsfintedpar	 *tmp_bdry_parm, *p_tail=NULL;


   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   osnum = md_env->md_id.osnum;
   par_tol_basis.mattyp   = &md_env->md_env.matrix_type;
   par_tol_basis.mat      = md_env->md_env.matrix;
   par_tol_basis.in_world = FALSE;
   par_tol_basis.is_valid = TRUE;
   EMmake_chanselect( EMSedge_to_common_edge, &to_common_ed );


   /* Obtain the end points of the uv curve */
      OM_stat = EMgetendpts_uv( &msg, cv_on_sf, FALSE, ( IGRint ) 1,
                                end_pts[ START ], end_pts[ STOP ] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

   /* If processing U0, then the incident edge is the round edge, else the
    * the incident edge is the common edge of the round edge.
    */
       incident_ed = rnd_ed_info->edge_id;
       par_tol_basis.tol = rnd_ed_info->surf_tol;
       if( processing_U0 == FALSE )
       {
          count = 0;
          om$get_channel_objects( objid = rnd_ed_info->edge_id,
                                  p_chanselect = &to_common_ed,
                                  count = &count,
                                  size = 1,
                                  osnum = osnum,
                                  list = comm_ed_list );
          EMerr_hndlr( count != 1, *EMmsg, EMS_E_EdgeError, wrapup );

          incident_ed = (GRobjid) comm_ed_list[ FIRST ].S_objid;
          par_tol_basis.tol = rnd_ed_info->com_surf_tol;
       }

   /* At each end of the round edge, determine whether the fillet at
    * that end is degenerate.  If so, update the appropriate boundary
    * information packet.
    */
       p_tail = bdry_parms;
       while(p_tail && p_tail->next) p_tail = p_tail->next;

       if( rnd_ed_info->props & EMSfillet_v0_is_degenerate )
       {
          OM_stat = om$send ( msg = message EMSedge.EMptproject
               	         ( &msg,
                           end_pts[ processing_U0 == TRUE ? START : STOP ],
                           1, &new_bdry_info, NULL, &par_tol_basis ),

                              senderid = NULL_OBJID,
                              targetid = incident_ed,
                              targetos = osnum);

          EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError,
                       wrapup );

          tmp_bdry_parm = processing_U0 == TRUE ? bdry_parms
                                                : p_tail;

          if((tmp_bdry_parm->point[1] - 0.0) < par_tol_basis.tol)
          {
            tmp_bdry_parm->intloc   = new_bdry_info.location;
            tmp_bdry_parm->edgeid   = incident_ed;
            tmp_bdry_parm->edgepar  = new_bdry_info.param;
            tmp_bdry_parm->point[0] = new_bdry_info.proj_pt[0];
            tmp_bdry_parm->point[1] = new_bdry_info.proj_pt[1];
            tmp_bdry_parm->info = NULL;
          }
       }

       if( rnd_ed_info->props & EMSfillet_v1_is_degenerate )
       {
          OM_stat = om$send ( msg = message EMSedge.EMptproject
               	         ( &msg,
                           end_pts[ processing_U0 == TRUE ? STOP : START ],
                           1, &new_bdry_info, NULL, &par_tol_basis ),

                              senderid = NULL_OBJID,
                              targetid = incident_ed,
                              targetos = osnum );

          EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError,
                       wrapup );

          tmp_bdry_parm = processing_U0 == TRUE ? p_tail
                                                : bdry_parms;
          if((1.0 - tmp_bdry_parm->point[1]) < par_tol_basis.tol)
          {
            tmp_bdry_parm->intloc   = new_bdry_info.location;
            tmp_bdry_parm->edgeid   = incident_ed;
            tmp_bdry_parm->edgepar  = new_bdry_info.param;
            tmp_bdry_parm->point[0] = new_bdry_info.proj_pt[0];
            tmp_bdry_parm->point[1] = new_bdry_info.proj_pt[1];
            tmp_bdry_parm->info = NULL;
          }
       }

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "check_and_adjust_bdry_parms" );
   return( OM_stat );
}


static IGRboolean is_degen_end_at_vertex (fsrf, v0_end, vtxpt)
struct IGRbsp_surface *fsrf;
IGRboolean v0_end;
IGRpoint vtxpt;
{
  IGRboolean stat_func;
  IGRlong msg_loc;
  IGRdouble chttol;
  IGRpoint pt;

  stat_func = TRUE;
  BSsfeval (fsrf, 0.5, v0_end ? 0.0 : 1.0, 0, pt, &msg_loc);
  if (msg_loc == BSSUCC)
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);  
    stat_func = EMis_geomequal_3dpt (pt, vtxpt, chttol);
    }
  return (stat_func);
}


static IGRboolean chkatend (xyzdata, py, srf)
struct EMSdataselect *xyzdata;
struct EMSpypoint *py;
struct IGRbsp_surface *srf;
{
  IGRboolean atbdry=TRUE, found;
  IGRshort j;
  IGRlong msg_loc;
  IGRdouble chttol;
  IGRpoint sfpt, endpts[2];
  struct EMSpypoint *p_pypt=NULL;
  extern IGRdouble BSdistptpt();

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);  

  EMgetendpts_xyz (&msg_loc, NULL, NULL, xyzdata, FALSE, 1, 
                   endpts[START], endpts[STOP]);
  EMerr_hndlr (EMSerror (msg_loc), atbdry, FALSE, ret_end);

  p_pypt = py;
  found = FALSE;

  for(j=START; j<=STOP; j++)
  {
    /*if (!(p_pypt->props & (EMS_PYPT_ATSTART | EMS_PYPT_ATSTOP)))*/
    {
      BSsfeval (srf, p_pypt->point[U], p_pypt->point[V], 0, sfpt, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, atbdry, FALSE, ret_end);

      if(BSdistptpt(&msg_loc, sfpt, endpts[j]) >= chttol)
      {
        found = TRUE;
        break;
      }
    }

    /*
     * Get the last one in the list.
     */
    while(p_pypt->next)
      p_pypt = p_pypt->next;
  }

  EMerr_hndlr (found, atbdry, FALSE, ret_end);

ret_end:
  return (atbdry);
}



static void modify_endpt_onto_neutral_edge (edge_rnd_info, is_stop, 
                                            mdenv_info, os, endpt)
struct EMSedge_rnd_info *edge_rnd_info;
IGRboolean is_stop;
struct GRmdenv_info *mdenv_info;
GRspacenum os;
IGRdouble *endpt;
{
  IGRboolean n1, n2, isucc;
  IGRint i, neutral_inx;
  IGRlong msg_loc, stat_func;
  IGRdouble radius, dumpar1, dumpar2, dumpar3, dumpar4, dumpar5;
  IGRpoint guess_pt, loc_endpt, dumpt1, dumpt2;
  GRobjid sfid1, sfid2;
  struct EMSvtx_rnd_info *vtx_rnd_info;
  struct EMSedge_rnd_info **edge_infos, *other_edge_rnd_info;
  struct IGRbsp_curve xyzcv;
  struct IGRbsp_surface *sf1, *sf2;
  struct BSgeom_bsp_surf gmsf1, gmsf2;

  stat_func = TRUE;

  xyzcv.poles = NULL;
  xyzcv.knots = NULL;
  xyzcv.weights = NULL;

  if (is_stop)
    {
    vtx_rnd_info = edge_rnd_info->stop_vtx;
    radius = edge_rnd_info->other_radius;
    }
  else
    {
    vtx_rnd_info = edge_rnd_info->start_vtx;
    radius = edge_rnd_info->radius;
    }

  OM_BLOCK_MOVE (vtx_rnd_info->vtx_pt, endpt, sizeof (IGRpoint));

  sfid1 = edge_rnd_info->surf_id;
  sf1 = edge_rnd_info->surf;
  sfid2 = edge_rnd_info->com_surf_id;
  sf2 = edge_rnd_info->com_surf;

  edge_infos = vtx_rnd_info->edge_infos;
  for (i=0; i<3; i++)
    if (!edge_infos[i])
      {
      neutral_inx = i;
      continue;
      }
    else if (edge_infos[i]->edge_id != edge_rnd_info->edge_id)
      other_edge_rnd_info = edge_infos[i];

  if (other_edge_rnd_info->surf_id == sfid2 ||
      other_edge_rnd_info->com_surf_id == sfid2)
    {
    EMswapmem (&sfid1, &sfid2, sizeof (GRobjid));
    EMswapmem (&sf1, &sf2, sizeof (struct IGRbsp_surface *));
    }

  msg_loc = NULL;
  om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, mdenv_info, NULL,
   NULL, 0, MAXINT, FALSE, NULL, &xyzcv),
   targetid = vtx_rnd_info->edge_ids[neutral_inx], targetos = os,
   senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), stat_func, FALSE, ret_end);

  msg_loc = NULL;
  om$send (msg = message EMSedge.EMptalong (&msg_loc, NULL, mdenv_info,
   vtx_rnd_info->vtx_pt, radius, 
   vtx_rnd_info->edge_stops[neutral_inx] ? FALSE : TRUE, NULL, guess_pt),
   targetid = vtx_rnd_info->edge_ids[neutral_inx], targetos = os,
   senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), stat_func, FALSE, ret_end);
   
  EFinit_geom_surface (&msg_loc, sf1, sfid1, os, &gmsf1);
  EFinit_geom_surface (&msg_loc, sf2, sfid2, os, &gmsf2);
  if (edge_rnd_info->edge_config == EMSedge_convex)
    {
    n1 = sf1->pos_orient;
    n2 = sf2->pos_orient;
    }
  else
    {
    n1 = !sf1->pos_orient;
    n2 = !sf2->pos_orient;
    }
  
  BScostsrdit (&gmsf1, &gmsf2, n1, n2, &xyzcv, radius, guess_pt, 
   dumpt1, dumpt2, loc_endpt, &dumpar1, &dumpar2, &dumpar3, &dumpar4, &dumpar5,
   &isucc, &msg_loc);
  EMerr_hndlr (!isucc || msg_loc != BSSUCC, stat_func, FALSE, ret_end);
  OM_BLOCK_MOVE (loc_endpt, endpt, sizeof (IGRpoint));

ret_end:
  if (xyzcv.poles)
    om$dealloc (ptr = xyzcv.poles);
  if (xyzcv.knots)
    om$dealloc (ptr = xyzcv.knots);
  if (xyzcv.weights)
    om$dealloc (ptr = xyzcv.weights);

  EMWRAPUP (stat_func, stat_func, "onto_neutral_edge");
  return;
}

static IGRboolean check_fillet_fillet_interaction (rnd_info_1, rnd_info_2)
struct EMSedge_rnd_info *rnd_info_1, *rnd_info_2;
{
  IGRboolean this_surf, intf = FALSE;
  IGRint uinx1, uinx2, numpts = 0;
  IGRlong msg_loc;
  IGRdouble loc_sf_tol;
  struct EMSpypoint *intpts1, *intpts2;
  GRobjid loc_sf_obj;

  intpts1 = intpts2 = NULL;

  /*
   * Obtain information from the EMSedge_rnd_info structure
   * that is directly available into local variables.
   */

  if (IF_EQ_OBJID (rnd_info_1->surf_id, rnd_info_2->surf_id) ||
       IF_EQ_OBJID (rnd_info_1->surf_id, rnd_info_2->com_surf_id))
    {
    loc_sf_obj = rnd_info_1->surf_id;
    loc_sf_tol = rnd_info_1->surf_tol;
    this_surf = TRUE;
    }
  else if (IF_EQ_OBJID (rnd_info_1->com_surf_id, rnd_info_2->surf_id) ||
           IF_EQ_OBJID (rnd_info_1->com_surf_id, rnd_info_2->com_surf_id))
    {
    loc_sf_obj = rnd_info_1->com_surf_id;
    loc_sf_tol = rnd_info_1->com_surf_tol;
    this_surf = FALSE;
    }
  else
    {
    intf = FALSE;
    goto wrapup;
    }
  if ((rnd_info_1->start_vtx == rnd_info_2->start_vtx) ||
      (rnd_info_1->start_vtx == rnd_info_2->stop_vtx)  ||
      (rnd_info_1->stop_vtx == rnd_info_2->stop_vtx)   ||
      (rnd_info_1->stop_vtx == rnd_info_2->start_vtx))
    {
    intf = FALSE;
    goto wrapup;
    }

  uinx1 = this_surf ? FIRST : SECOND;
  uinx2 = IF_EQ_OBJID (loc_sf_obj, rnd_info_2->surf_id) ? FIRST : SECOND;

  /*
   * Obtain the intersection points between the two iso-curves by
   * intersecting the mapped iso-curves.
   */

  EFget_intersection_points (&msg_loc, loc_sf_tol, NULL, NULL,
   &rnd_info_1->fill_isocvs_onsfs[uinx1], FALSE,
   &rnd_info_2->fill_isocvs_onsfs[uinx2], FALSE,
   &numpts, &intpts1, &intpts2);
  if (EMSerror(msg_loc))
    intf = FALSE;
  else if (numpts >= 2)
    intf = TRUE;

wrapup:
  if (intpts1)
    EMpypoint_free (intpts1, MAXINT);
  if (intpts2)
    EMpypoint_free (intpts2, MAXINT);

  return (intf);
}

/*
  DESCRIPTION
  Takes in intersection curves on the fillets and processes each surface
  in the fillet composite by turn. Performs a trace on a per surface basis,
  converts intersections to edges, creates loops and imposes them on the
  surface. This code was initially within the EMround method. Modifications
  for handling topology interaction now allows multiple loops on a fillet
  surface.

  Aditya 03 Sep 96     : Creation (?).
*/

IGRlong EMimpose_boundaries_on_fillet_blends (msg, options, md_env, num_edges,
                                              edge_rnd_info, fillet_inters)
IGRlong  *msg;
IGRushort  options;
IGRint num_edges;
struct GRmd_env  *md_env;
struct EMSedge_rnd_info  *edge_rnd_info;
struct EMSinters  *fillet_inters;
{
  IGRboolean is_fillet, true = TRUE, grp_closed=FALSE, open_grp=FALSE;
  IGRshort   *mattyp=NULL;
  IGRlong    stat, msg_loc;
  IGRint     i, j, k, this_fillet_info_inx, count;
  IGRdouble  *mat=NULL, uvtol, chttol, bastol, uvchttol, **sfpartols=NULL;
  GRspacenum os;
  GRobjid    this_fillet;
  GRobjid    **loops_and_sfs=NULL, **end_edges=NULL;
  OM_S_OBJECT_LINKAGE comm_list[1];
  OM_S_CHANSELECT chan_to_loopset, chan_to_loops;
  struct EMSpartolbasis partolbasis;
  struct EMSsftracedata sftrace;
  struct EMSintobj *p_intobj=NULL, *tmp_intobj=NULL;
  struct EMSinters *p_inters=NULL, *save_p_inters=NULL;
  struct EMSnest_info nest_info;
  struct EMSsfintedpar ***intedpars=NULL;
  extern void EMrnd_set_bwd_fwd_continuity_ptrs();

  stat = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  msg_loc = EMS_S_Success;

  os = md_env->md_id.osnum;
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  partolbasis.in_world = TRUE;
  partolbasis.mattyp = mattyp;
  partolbasis.mat = mat;

  BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, chttol);
  BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bastol);

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);

  for (p_inters=fillet_inters; p_inters; p_inters=p_inters->next)
  {
   /*
    * Process fillets and blends/patches. The goal in this iteration is
    * to redefine the boundary (loopset) on these surfaces. Some of
    * them have already gotten their boundaries correctly defined.
    * These are left untouched.
    */

    if (p_inters->props & EMSinters_loopcreated)
      continue;

    /*
     * Trace just this fillet surface and make sure that
     * it fulfils the correctness criteria.
     */

    save_p_inters = p_inters->next;
    p_inters->next = NULL;

    if(_process_tply)
    {
      struct IGRbsp_surface *p_sf=NULL;

      /*
       * Surface data in p_sf s stored on the stack and goes out of scope 
       * at the end of the 'if' statement.
       */
      PW_GetSfBspsfStack(p_inters->this_obj.objid,
                         p_inters->this_obj.osnum,
                         *mattyp, mat, p_sf);

      uvchttol = pwGetParTolSf ( p_sf, chttol);

      EMrnd_set_bwd_fwd_continuity_ptrs (&msg_loc, p_inters, uvchttol);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
    }

    stat = EMintersect_surfaces (&msg_loc, NULL, &md_env->md_env, 0, NULL, NULL,
               EMS_SFINT_SKIPSFINT | EMS_SFINT_SKIPFIXING |
               EMS_SFINT_CHTTRACETOL, NULL, NULL, NULL, NULL,
               NULL, &p_inters, NULL,
               &sftrace, NULL, NULL, NULL, NULL);
    p_inters->next = save_p_inters;    
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
    EMerr_hndlr (!sftrace.num_grps, *msg, EMS_E_Fail, wrapup);

    grp_closed = FALSE;
    open_grp=FALSE;
    for (i=0; i<sftrace.num_grps; i++)
    {
      if(sftrace.grp_closed[i])
      {
        for (j=0; j<sftrace.num_subgrps_grp[i]; j++)
        {
          grp_closed = TRUE;
          EMerr_hndlr (sftrace.num_subgrps_grp[i]!=1 ||
                       !sftrace.subgrp_closed[i][j], *msg, EMS_E_Fail, wrapup);

          for (k=0; k<sftrace.num_elems_subgrp[i][j]; k++)
          {
            EMerr_hndlr (sftrace.elem_rev[i][j][k], *msg,
                         EMS_E_IntersectOrient, wrapup);
          }
        }
      }
      else
      {
        open_grp = TRUE;
        /*
         * If a group is not closed, we don't need it in rounding at this
         * stage. Mark all the intobjs in that group as deletable and
         * delete them through a call to EMdelintobj_selective.
         */
        for (j=0; j<sftrace.num_subgrps_grp[i]; j++)
        {
          p_intobj = sftrace.elems[i][j];
          for (k=0; k<sftrace.num_elems_subgrp[i][j]; k++)
          {
            p_intobj->props |= EMSintobj_deletable;
            if(p_intobj->other_intobj_node)
              p_intobj->other_intobj_node->props |= EMSintobj_deletable;

            p_intobj = p_intobj->next;
          }
        }
      }
    }
    /*
     * Error out if there is no closed group on this surface.
     */
    EMerr_hndlr( !grp_closed, *msg, EMS_E_Fail, wrapup);

    if(open_grp)
    {
      EMdelintobj_selective(&msg_loc, NULL, p_inters, 
                            EMSintobj_deletable, NULL);
      EMerr_hndlr (!(1&msg_loc), *msg, EMS_E_Fail, wrapup);
    }

    if (sftrace.num_grps==1)
    {
      p_intobj = tmp_intobj = sftrace.elems[FIRST][FIRST];
      while (p_intobj->next)
      {
        p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
        p_intobj->props |= EMSintobj_fwd_connectuv;
        p_intobj->fwd = p_intobj->next;
   
        p_intobj->fwd->props &= ~EMSintobj_bwd_noconnectuv;
        p_intobj->fwd->props |= EMSintobj_bwd_connectuv;
        p_intobj->fwd->bwd = p_intobj;
  
        EMconvert_to_edge (&msg_loc, p_intobj, os);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
        if (p_intobj->other_intobj_node)
        {
          EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, os);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
        }
        p_intobj = p_intobj->next;
      }
      p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
      p_intobj->props |= EMSintobj_fwd_connectuv;
      p_intobj->fwd = tmp_intobj;
  
      tmp_intobj->props &= ~EMSintobj_bwd_noconnectuv;
      tmp_intobj->props |= EMSintobj_bwd_connectuv;
      tmp_intobj->bwd = p_intobj;
    
      EMconvert_to_edge (&msg_loc, p_intobj, os);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
      if (p_intobj->other_intobj_node)
      {
        EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, os);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
      }
    }
    else
    {
      p_intobj = p_inters->cvs;
      while (p_intobj)
      {
        EMconvert_to_edge (&msg_loc, p_intobj, os);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
        if (p_intobj->other_intobj_node)
        {
          EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, os);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
        }
        p_intobj = p_intobj->next;
      }
    }

    EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
       sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
       sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);
  
    /*
     * This is the final state of the linked list of EMSintobj on this
     * fillet surface. Trace again and this time we should get a closed,
     * single(!! No longer ) group. This group is converted to a loop and 
     * imposed as the new boundary on the fillet surface.
     */

    this_fillet = p_inters->this_obj.objid;
    check_fillet_or_surf (&msg_loc, num_edges, edge_rnd_info,
     this_fillet, &this_fillet_info_inx, &is_fillet);
    if (msg_loc != EMS_I_Found || !is_fillet)
    {
      om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc, mattyp, mat,
                                      &true, TRUE, &uvtol), 
                                      senderid = NULL_OBJID,
                                      targetid = this_fillet,
                                      targetos = os);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
    }
    else
      uvtol = edge_rnd_info[this_fillet_info_inx].fill_surf_tol;

    uvchttol = uvtol * (chttol / bastol);
    save_p_inters = p_inters->next;
    p_inters->next = NULL;

    EMsfinttrace (&msg_loc, mattyp, mat, p_inters, &uvchttol, &chttol,
     &sftrace.num_grps, &sftrace.num_subgrps_grp, &sftrace.num_elems_subgrp,
     &sftrace.elems, &sftrace.subgrp_rev, &sftrace.elem_rev,
     &sftrace.grp_closed, &sftrace.subgrp_closed);
    p_inters->next = save_p_inters;    
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

    EMsfintloops (&msg_loc, mattyp, mat, OM_Gw_current_OS, &uvchttol,
     sftrace.num_grps, sftrace.num_subgrps_grp, sftrace.num_elems_subgrp,
     sftrace.elems, sftrace.subgrp_rev, sftrace.elem_rev,
     sftrace.grp_closed, sftrace.subgrp_closed, 
     TRUE, FALSE, &loops_and_sfs, &end_edges, &intedpars, &sfpartols);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

    count = 0;
    om$get_channel_objects (objid = this_fillet,
     p_chanselect = &chan_to_loopset, count = ( IGRuint * ) &count, size = 1,
     list = comm_list);
    EMerr_hndlr (count != 1, *msg, EMS_E_Fail, wrapup);
    
    stat = om$send (msg = message EMSloop.EMtreemod (&msg_loc, NULL,
               DELETE, NULL), p_chanselect = &chan_to_loops,
               senderid = comm_list[FIRST].S_objid);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

    for (i=0; i<sftrace.num_grps; i++)
    {
      for (j=0; j<sftrace.num_subgrps_grp[i]; j++)
      {
        stat = om$send( msg = message EMSloop.EMset_props
				    (&msg_loc, EMLP_NEW, EMS_O_OFF ),
                           senderid = NULL_OBJID,
		           targetid = loops_and_sfs[i][j],
                           targetos = os);
        EMerr_hndlr (!(1 & stat & msg_loc), *msg, EMS_E_Fail, wrapup);

        partolbasis.is_valid = TRUE;
        partolbasis.tol = uvchttol;
        nest_info.loopid = loops_and_sfs[i][j];
        nest_info.parent = comm_list[FIRST].S_objid;
        nest_info.parent_props = NULL;
        nest_info.lp_props = EMLP_PLOOP | EMLP_EXTERNAL | EMLP_ACTIVE;

        stat = om$send (msg = message EMSloop.EMset_props (&msg_loc,
               nest_info.lp_props, EMS_O_ON), 
               senderid = NULL_OBJID,
               targetid = nest_info.loopid,
               targetos = os);
        EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_Fail, wrapup);

        stat = om$send (msg = message EMSloopset.EMtreemod (&msg_loc,
                                      &nest_info, ADD_CHILD, &partolbasis),
                              senderid = NULL_OBJID,
                              targetid = comm_list[0].S_objid,
                              targetos = os);
        EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_Fail, wrapup);

      }
    }
    EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
      sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
      sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);
    EMsfintloops_free (loops_and_sfs, end_edges, intedpars, sfpartols);
  }

wrapup:
  EMWRAPUP (*msg, stat, "EMimpose_boundaries_on_fillet_blends");
  return (stat);
}


/*
  DESCRIPTION

   This function takes in an inters list, and a surface id,
   and sets the fwd-bwd, connectivity pointers for all the 
   intobj's on this surface. 

  ARGUMENTS

   fillet_inters       - Input/Output: The "intersections" between the
                          the fillets and the patches generated herein
                          are recorded in this list.
  HISTORY

  KNAP : 17 Apr, 95.   : Creation
  Aditya 03 Sep 96     : Rewrite.
*/

void EMrnd_set_bwd_fwd_continuity_ptrs 
(
  IGRlong *msg,
  struct EMSinters *fillet_inters,
  IGRdouble uvchttol
)
{
  IGRlong msg_loc;
  IGRint  i;
  IGRdouble endpts[2][2], tst_pts[2][2];

  struct EMSintobj *p_intobj, *intobj;
  extern IGRboolean EMis_geomequal_2dpt();

  *msg = EMS_S_Success;

  intobj = fillet_inters->cvs;
  while (intobj)
  {
    if(!(intobj->props & EMSintobj_marked) ||
        (intobj->props &  EMSintobj_bwd_connectuv &&
         intobj->props &  EMSintobj_fwd_connectuv))
    {
      /*
       * Process only marked intobjs. Also don't process if both
       * fwd and bwd pointers have been set (optimization).
       */
      intobj = intobj->next;
      continue;
    }

    EMgetendpts_uv (&msg_loc, &intobj->this_uvintobj, intobj->reversed,
                    1, endpts[START], endpts[STOP]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
  
    p_intobj = fillet_inters->cvs;
    while (p_intobj)
    {
      if (p_intobj->props &  EMSintobj_bwd_connectuv &&
          p_intobj->props &  EMSintobj_fwd_connectuv)
      {
        p_intobj = p_intobj->next;
        continue;
      }

      if (p_intobj != intobj)
      {
        EMgetendpts_uv (&msg_loc, &p_intobj->this_uvintobj, 
                        p_intobj->reversed, 1, tst_pts[START], tst_pts[STOP]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

        for (i=START; i<=STOP; i++)
        {
          if (EMis_geomequal_2dpt(endpts[i], tst_pts[!i], uvchttol))
          {
            if (i==START && !(intobj->props & EMSintobj_bwd_connectuv))
            {
              intobj->bwd = p_intobj;
              intobj->props |= EMSintobj_bwd_connectuv;
              intobj->props &= ~EMSintobj_bwd_noconnectuv;

              p_intobj->fwd = intobj;
              p_intobj->props |= EMSintobj_fwd_connectuv;
              p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
            }
            else if(!(intobj->props & EMSintobj_fwd_connectuv))
            {
              intobj->fwd = p_intobj;
              intobj->props |= EMSintobj_fwd_connectuv;
              intobj->props &= ~EMSintobj_fwd_noconnectuv;

              p_intobj->bwd = intobj;
              p_intobj->props |= EMSintobj_bwd_connectuv;
              p_intobj->props &= ~EMSintobj_bwd_noconnectuv;
            }
          }
        }
      }
      p_intobj = p_intobj->next;
    }
    intobj = intobj->next;
  }

wrapup:
  return;
}

end implementation EMSsfrndbool;
