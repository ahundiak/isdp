class implementation EMSsubbs;

/* HISTORY:
   Creation: ???   Long ago.
   08/26/92: NP    Modified for ANSI compliance. Pointer to "GRmd_env" was being
		   passed to EMSedge.EMxyz_endpt instead of ptr to "GRmdenv_info".
   12/08/92: janaka Message sub-systen complience.
   12/29/92: WBC   Added the function EFgmsfoffset and replaced the calls to
                   BSsfoffset and BSsfoffsetd with a call to EFgmsfoffset.
   01/05/93: WBC   Replaced the call to BSsur_sur with a call to BSsfsfint.
   01/06/93: WBC   Replaced some of the calls to BSmdistptsf with calls to
                   BSprptarrsf.
   07/07/93: Sudha Modified for BSprototypes ansification

 */

#include "EMS.h"
#include <stdio.h>
#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "emsedgedef.h"
#include "OMmacros.h"
#include "OMstackalloc.h"
#include "gocmacros.h" /* GRgetabsg */
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsmalloc.h"
#include "bsgeom_cvsf.h"
#include "bssfxttpt.h"
#include "bssfsfint.h"
#include "bssfkttol2.h"
#include "bssfeval.h"
#include "bssfarrevt.h"
#include "bssfarrevn.h"
#include "bssf_thrcvs.h"
#include "bsscnvtmekt.h"
#include "bsptonnsdsf.h"
#include "bsptnorpch.h"
#include "bspseudoarc.h"
#include "bsprptonsf.h"
#include "bsprptarrsf.h"
#include "bspartofsf.h"
#include "bsnorvec.h"
#include "bsmovecrs.h"
#include "bsmkvec.h"
#include "bsmkcvscp.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bslnkptarrs.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bsdbgfree.h"
#include "bscvoton.h"
#include "bsconstprcv.h"
#include "bschangepar.h"
#include "bscdoffsrf.h"
#include "bsallocsf.h"
#include "bsalloccv.h"

/* Macro to free the geometric curves created by a calling BSsfsfint */

#define free_geom_bsp_curve(rc, num_curves, curve_array)                  \
        {                                                                 \
            if (curve_array)                                              \
            {                                                             \
                int index;                                                \
                for (index = 0; index < num_curves; index++)              \
                {                                                         \
                    if (curve_array[index].array1)                        \
                        BSdealloc((char *) curve_array[index].array1);    \
                    if (curve_array[index].bspcv)                         \
                        BSfreecv(rc, curve_array[index].bspcv);           \
                }                                                         \
                BSdealloc((char *) curve_array);                          \
                curve_array = NULL;                                       \
            }                                                             \
        }

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSpcylindr_class_id;

from EMSedge import     EMconnect_edges,
                        EMptatpr,
                        EMptproject,
                        EMget_sf_edges,
                        EMget_bcxyz_geom,
                        EMendpts,
                        EMxyz_endpt,
                        EMget_props_type,
                        EMget_props;
from EMSboundary import EMget_objid;

method EMfillet_surface(IGRlong                  *EMmsg;
                        struct GRmd_env          *my_env;
                        IGRint                   *edge_number;
                        GRobjid                  *round_id;
                        IGRpoint                 dirpt;
                        struct GRvg_construct    *construct_list;
                        IGRushort        operation_type;
                        struct EMedge_round_info *my_info;
                        IGRint                   *num_def_info;
                        struct EMdef_con_info    *def_info;
                        IGRint                   *num_pair_info;
                        struct EMedge_con_info   *pair_info;
                        IGRint                   num_round_edges;
                        GRobjid                  *rnd_edge_ids;
                        GRobjid                  *fillet_id)
{

extern IGRdouble    sqrt();         /* calculate square root           */
extern void         EFinit_geom_surface();

%safe
void         EFgmsfoffset();
%endsafe

IGRlong                 stat_OM, stat_OM1, msg, msg1;
IGRlong                 num_bytes;
IGRshort                tempord, option, cvscode;
IGRuchar        	curve_type;
IGRushort       	rnd_edge_prop, edge_prop, next_edge_prop;
IGRboolean              On_surf, status, closed_curve;
IGRboolean              special_proc, special_fillet;
IGRboolean              tst_planar;
IGRint                  cind, split_ind=1;
IGRint                  tnumgrps,
                        numgrps,
                        *tnumpts,
                        *numpts,
                        *tnumints;
BSpair                  **tpar1, **tpar2,
                        **par1,**par2;
IGRpoint                **tpts,**pts;
IGRpoint                beg_pt, end_pt;
IGRpoint                bpnt[2], epnt[2];      
IGRpoint                poles[2], evpts[3];
IGRpoint                s1_pnt, s2_pnt;
IGRpoint                xyzbeg, xyzend, f_point;
IGRpoint                base_point;
IGRpoint                *cv1_pts, *cv2_pts;
IGRint                  i, j, inxa, inxb;
IGRint                  low_inx, mid_inx, high_inx;
IGRint                  tnum, sub;
IGRint                  num_loops, num_ed;
IGRint                  total_num_cvs, num_pts;
IGRvector               norm1, norm2;
IGRvector               vector0, vector1, av_normal;
IGRdouble               chrdht_tol, knot_tol;
IGRdouble               pt_in_area[2], knots[4],
                        end_param[8],
                        param[2], my_parms[2];
IGRdouble               *p0=NULL, *p1=NULL;
IGRdouble               low_dist, mid_dist, dist_tol, dist_sqtol;
IGRdouble               min_dist, rho, temp_tol, dist;
IGRdouble               uvbegpt[2], uvendpt[2],
                        cuvbegpt[2], cuvendpt[2];
IGRdouble               d1, d2, v0_or_v1, mid_parm[2];
static IGRdouble        identity_matrix[3][3] = {1.0, 0.0, 0.0,
                                                 0.0, 1.0, 0.0,
                                                 0.0, 0.0, 1.0};
extern IGRdouble 	fabs();
GRobjid                 other_edge;
GRobjid                 f_edges[4], ngb_edges[4];
GRobjid                 *loop_id;
struct GRid             edges[2], next_edges[2];
struct IGRbsp_surface   *s1, *s2;
struct IGRbsp_surface   *fsurf, *part_surf, *ext_surf;
struct IGRbsp_curve     **arc1=NULL,
                        **arc2=NULL;
struct IGRbsp_curve     *first_arc,
                        *last_arc,
                        *iso_curve,
                        edge_geom;
struct EMSproj_info     proj_info;
struct EMSpartolbasis   s1_partol, s2_partol;
struct EMSedgebound     bound[2], mid_param;
struct BSgeom_bsp_surf *geom_offsf1 = NULL,
                       *geom_offsf2 = NULL,
                        geom_surface;
struct BSgeom_bsp_curve  *xyz_cvs = NULL,
                         *uv1_cvs = NULL,
                         *uv2_cvs = NULL;
OM_S_CHANSELECT         to_common_edge;

/*----------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

tnumpts = NULL;
tpts = NULL;
tpar1 = tpar2 = NULL;
numpts = NULL;
pts = NULL;
par1 = par2 = NULL;
fsurf = NULL;
part_surf = NULL;
first_arc = NULL;
last_arc = NULL;
min_dist = MAXFLOAT;
special_fillet = FALSE;
tnumints = NULL;
total_num_cvs = 0;

my_info->fillet_modified = FALSE;

if (operation_type == EMS_CHAMFER_OPR)
    rho = 0;
else
    (void)BSEXTRACTPAR(&msg, BSRHO_VALUE, rho);

(void)BSEXTRACTPAR(&msg, BSTOLCHRDHT, chrdht_tol);
(void)BSEXTRACTPAR(&msg, BSTOLSQLENVEC, dist_sqtol);

dist_tol = sqrt(dist_sqtol);

stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
if (! (1 & stat_OM)) goto wrapup;

if (operation_type == EMS_CHAMFER_OPR)
{
     ex$message( msgnumb = EMS_S_GenChamfer,
                 type = "%d",
                 var = `*edge_number+1` );
}
else
{
     ex$message( msgnumb = EMS_S_GenFilletSrf,
                 type = "%d",
                 var = `*edge_number+1` );
}

stat_OM = om$send(msg = message EMSedge.EMget_props_type (&msg,
                        &rnd_edge_prop, &curve_type),
                  targetid = my_info->edge_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

stat_OM = om$send(msg = message EMSsubbs.GRgetsize(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        &num_bytes),
                  targetid = my_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

s1 = (struct IGRbsp_surface *) om$malloc(size = (OMuint) num_bytes);
EMerr_hndlr(!s1, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

/* Get the surface-1 geometry */

stat_OM = om$send(msg = message EMSsubbs.GRgetgeom(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        (IGRchar *) s1),
                  targetid = my_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

stat_OM = om$send(msg = message EMSsubbs.GRgetsize(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        &num_bytes),
                  targetid = my_info->comm_surface_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

s2 = (struct IGRbsp_surface *) om$malloc(size = (OMuint) num_bytes);
EMerr_hndlr(!s2, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

/* Get the surface-2 geometry */

stat_OM = om$send(msg = message EMSsubbs.GRgetgeom(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        (IGRchar *) s2),
                  targetid = my_info->comm_surface_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 
/* get the partol for both the surfaces */

BSsfkttol2(s1->u_order, s1->v_order, s1->u_knots, s1->v_knots,
           s1->u_num_poles, s1->v_num_poles, s1->poles, s1->weights,
           &s1_partol.tol, &msg);
EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

s1_partol.is_valid = TRUE;
s1_partol.in_world = TRUE;
s1_partol.mattyp = &my_env->md_env.matrix_type;
s1_partol.mat = my_env->md_env.matrix;

BSsfkttol2(s2->u_order, s2->v_order, s2->u_knots, s2->v_knots,
           s2->u_num_poles, s2->v_num_poles, s2->poles, s2->weights,
           &s2_partol.tol, &msg);
EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

s2_partol.is_valid = TRUE;
s2_partol.in_world = TRUE;
s2_partol.mattyp = &my_env->md_env.matrix_type;
s2_partol.mat = my_env->md_env.matrix;

my_info->surface = s1;

if (curve_type == EMlinesegment)
 {
  if ((! s1->planar) || (! s2->planar))
      curve_type = EMfreeform_curve;
 }

retry:
switch (curve_type)
 {
  case EMcircle:
  case EMcircular_arc:
  case EMlinesegment:

     special_fillet = TRUE;
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                             uvendpt, NULL, NULL, NULL),
                       targetid = my_info->edge_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, cuvbegpt,
                             cuvendpt, NULL, NULL, NULL),
                       senderid = my_info->edge_id,
                       p_chanselect = &to_common_edge);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if (rnd_edge_prop & EMED_REVERSE_CONNECT)
      {
       cuvbegpt[0] = cuvendpt[0]; cuvbegpt[1] = cuvendpt[1]; 
      }

     BSsfarrevn (&msg, s1, 1, &uvbegpt[0], 1, &uvbegpt[1], xyzbeg, norm1);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSsfarrevn (&msg, s2, 1,&cuvbegpt[0], 1,&cuvbegpt[1], beg_pt, norm2);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if (! s1->pos_orient)
      {
       for(i=0; i<3; i++)
           norm1[i] = -norm1[i]; 
      }
     if (! s2->pos_orient)
      {
       for(i=0; i<3; i++)
           norm2[i] = -norm2[i]; 
      }

     for (i=0; i<3; i++)
          av_normal[i] = (norm1[i] + norm2[i]) / 2;
     status = BSnorvec(&msg, av_normal);
      
     d1 = BSdotp(&msg, av_normal, norm2);

     if (my_info->edge_type == EMS_CONVEX_EDGE)
      {
       for (i=0; i<3; i++)
            base_point[i] = av_normal[i] + xyzbeg[i];
      }
     else
     if (my_info->edge_type == EMS_CONCAVE_EDGE)
      {
       for (i=0; i<3; i++)
            base_point[i] = xyzbeg[i] - av_normal[i];
      }

     d2 = BSdistptpt(&msg, base_point, xyzbeg);

     for (i=0; i<3; i++)
          f_point[i] = ((base_point[i]*my_info->radius)/d1 +
                         xyzbeg[i]*(d2-my_info->radius/d1))/d2;

     BSptnorpch(f_point, s1, uvbegpt, &sub, &dist, &end_param[0],
                &end_param[1], bpnt[0], &msg);
     EMerr_hndlr (! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

     num_pts = 1;
     
     if ((! sub) || (sub > 1))
      {
       EFinit_geom_surface(&msg, s1, my_id, OM_Gw_current_OS,
                           &geom_surface);
       EMerr_hndlr(!(msg & 1),*EMmsg,EMS_E_BSerror,wrapup);

       BSprptarrsf(&geom_surface, dist_tol, 2, 2, &num_pts, f_point,
                   end_param, bpnt[0], &On_surf, NULL, &msg);
       EMerr_hndlr(msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }

     BSptnorpch(f_point, s2, cuvbegpt, &sub, &dist, &end_param[2],
                &end_param[3], epnt[0], &msg);
     EMerr_hndlr (! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);
     
     if ((! sub) || (sub > 1))
      {
       EFinit_geom_surface(&msg, s2, my_info->comm_surface_id,
                           OM_Gw_current_OS, &geom_surface);
       EMerr_hndlr(!(msg & 1),*EMmsg,EMS_E_BSerror,wrapup);

       BSprptarrsf(&geom_surface, dist_tol, 2, 2, &num_pts, f_point,
                   &end_param[2], epnt[0], &On_surf, NULL, &msg);
       EMerr_hndlr(msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }
     
     /* if surfaces have degenerate boundaries at the end of edge, the
        resulting arc will be erroneous, so get the conventional fillet */

     if (curve_type == EMlinesegment)
      {
       if ((BSdistptpt(&msg, xyzbeg, bpnt[0]) <= dist_tol) ||
           (BSdistptpt(&msg, xyzbeg, epnt[0]) <= dist_tol))
        {
         curve_type = EMfreeform_curve;     
         goto retry;
        }
      }

     BSmkvec (&msg, norm1, bpnt[0], f_point);
     status = BSnorvec(&msg, norm1);
     BSmkvec (&msg, norm2, epnt[0], f_point);
     status = BSnorvec(&msg, norm2);

     if (my_info->edge_type == EMS_CONCAVE_EDGE)
      {
       for(i=0; i<3; i++)
           vector0[i] = -norm1[i]; 
      }
     else
      {
       for(i=0; i<3; i++)
           vector0[i] = norm1[i]; 
      }

     first_arc = NULL; last_arc = NULL;

     if (rho != 0)
      {
       BSalloccv(3, 9, 1, 0, &first_arc, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     else
      {
       BSalloccv(2, 2, 0, 0, &first_arc, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }

     BSpseudoarc (bpnt[0], f_point, epnt[0], rho, norm1, norm2, first_arc,
                  &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     iso_curve = NULL;

     if (curve_type == EMlinesegment)
      {
       BSsfeval(s1, uvendpt[0], uvendpt[1], 0, (IGRpoint *)xyzend, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       edge_geom.poles = poles[0];
       edge_geom.knots = knots;

       edge_geom.order          = 2;
       edge_geom.periodic       = FALSE;
       edge_geom.non_uniform    = FALSE;
       edge_geom.num_poles      = 2;
       edge_geom.num_knots      = 4;
       edge_geom.rational       = FALSE;
       edge_geom.weights        = NULL;
       edge_geom.num_boundaries = 0;
       edge_geom.bdrys          = NULL;
       edge_geom.phy_closed     = FALSE;
       edge_geom.planar         = TRUE;

       edge_geom.knots[0] = 0.0;
       edge_geom.knots[1] = 0.0;
       edge_geom.knots[2] = 1.0;
       edge_geom.knots[3] = 1.0;

       dist= BSdistptpt(&msg, xyzbeg, xyzend);

       for (i=0; i<3; i++)
            edge_geom.poles[i] = (xyzbeg[i] * (my_info->radius + dist) -
                                  my_info->radius * xyzend[i]) / dist;
       for (i=0; i<3; i++)
            edge_geom.poles[3+i] = (xyzend[i] * (my_info->radius + dist) -
                                    my_info->radius * xyzbeg[i]) / dist;

       BSmkvec (&msg, vector1, &edge_geom.poles[0], xyzbeg);
       dist = 1.0;

       BSalloccv (first_arc->order, first_arc->num_poles,
                  first_arc->rational, NULL, &iso_curve, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       BScvoton (&msg,vector1,identity_matrix,&dist,first_arc,iso_curve);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       my_info->fillet_modified = TRUE;
      }
     else
      {
       edge_geom.weights = NULL;
       edge_geom.poles = NULL;
       edge_geom.knots = NULL;
       edge_geom.bdrys = NULL;

       stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                               &my_env->md_env, NULL, s1, 0,
                               OM_K_MAXINT, FALSE, NULL, &edge_geom),
                         targetid = my_info->edge_id);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
      }

     BSmovecrs((curve_type == EMlinesegment) ? iso_curve : first_arc,
                NULL,
                &edge_geom,
                NULL,
                FALSE,
                TRUE,
                NULL, NULL, NULL, NULL, NULL,
                &fsurf,
                &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     /* Assumption is being made here that the arcs are constant-v in
        fillet surface. This is good for the skinning surface that
        exists today. if this changes then BSexch_u_v should be used to
        swap parametrization. I am doing this for efficiency reasons */


     if (curve_type == EMlinesegment)
      {
       BSmkvec (&msg, vector1, xyzend, &edge_geom.poles[0]);
       dist = 1.0;

       BSalloccv (iso_curve->order, iso_curve->num_poles,
                  iso_curve->rational, NULL, &last_arc, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       BScvoton (&msg,vector1,identity_matrix,&dist,iso_curve,last_arc);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      }
     else
     if (curve_type == EMcircular_arc)
      {
       BSalloccv (fsurf->u_order, fsurf->u_num_poles, fsurf->rational,
                  NULL, &last_arc, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       option = 0;
       v0_or_v1 = 1.0;

       tst_planar = TRUE;
       BSconstprcv (&msg, fsurf, &option, &v0_or_v1,&tst_planar,last_arc);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      }
     else
      {
       last_arc = first_arc;
      }

     if (iso_curve) BSfreecv (&msg, iso_curve);
     iso_curve = NULL;

     if (last_arc->rational)
      {
       for (j=0; j<3; j++)
        {
         bpnt[1][j] = last_arc->poles[j] / last_arc->weights[0];
         epnt[1][j] = last_arc->poles[3 * (last_arc->num_poles-1) + j] /
                      last_arc->weights[last_arc->num_poles - 1];  
        }
      }
     else
      {
       for (j=0; j<3; j++)
        {
         bpnt[1][j] = last_arc->poles[j];
         epnt[1][j] = last_arc->poles[3 * (last_arc->num_poles-1) + j];
        }
      }

     if (curve_type == EMlinesegment)
      {
       for (i=0; i<3; i++)
        {
         s1_pnt[i] = bpnt[0][i] + (bpnt[1][i] - bpnt[0][i])/2;     
         s2_pnt[i] = epnt[0][i] + (epnt[1][i] - epnt[0][i])/2;     
        }
      }
     else
      {
       iso_curve = NULL;
       BSalloccv (fsurf->u_order, fsurf->u_num_poles, fsurf->rational,
                  NULL, &iso_curve, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       option = 0;
       v0_or_v1 = 0.5;
       tst_planar = FALSE;
       BSconstprcv (&msg, fsurf, &option,&v0_or_v1,&tst_planar,iso_curve);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       if (iso_curve->rational)
        {
         for (j=0; j<3; j++)
          {
           s1_pnt[j] = iso_curve->poles[j] / iso_curve->weights[0];
           s2_pnt[j] = iso_curve->poles[3*(iso_curve->num_poles-1)+j] /
                          iso_curve->weights[iso_curve->num_poles - 1];  
          }
        }
       else
        {
         for (j=0; j<3; j++)
          {
           s1_pnt[j] = iso_curve->poles[j];
           s2_pnt[j] = iso_curve->poles[3*(iso_curve->num_poles-1)+j];
          }
        }
      }

     if (curve_type == EMcircular_arc)
      {
       /* 01/06/93: WBC: Decided not to replace the call to BSsfxttpt with a
        * call to BSxgmsfdst since the direction and distance points derived
        * below would be difficult to accurately convert to extend distance and
        * direction needed by BSxgmsfdst
        */

       for (j=0; j<2; j++)
        {
         i = 1;
         param[0] = 0.5;
         param[1] = (j) ? 1.0 : 0.0;
         dist = my_info->radius;
         BSsfarrevt(fsurf, i, &param[0], i, &param[1], dist, (IGRdouble *)evpts, &msg);
         EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         if (! j)
          {
           for (i=0; i<3; i++)
                evpts[2][i] = 2 * evpts[0][i] - evpts[2][i];
          }

         for (i=0; i<3; i++)
              base_point[i] = (evpts[2][i] + 10 * evpts[0][i]) / 11.0;

         sub = 2;
         ext_surf = NULL;
         BSsfxttpt(sub, fsurf, base_point, evpts[2], &ext_surf, &msg);

         if (msg != BSSUCC)
          {
           msg = BSSUCC;
           ext_surf = fsurf;
          }
         else
          {
           if (fsurf) BSfreesf (&msg, fsurf);
           fsurf = ext_surf;
          }
        }

       my_info->fillet_modified = TRUE;
      }

     status = BSprptonsf (&msg, fsurf, bpnt[0], &param[0], &param[1],
                          &On_surf);
     EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);

     end_param[0] = 0.0; end_param[1] = 0.0;
     end_param[2] = 0.0; end_param[3] = 0.0;
     end_param[4] = 0.0; end_param[5] = 1.0;
     end_param[6] = 0.0; end_param[7] = 1.0;

     if (iso_curve) BSfreecv (&msg, iso_curve);

    break;

  default:

     for (i=0; i<4; i++)
          ngb_edges[i] = NULL_OBJID;

     /* Offset both surfaces */

     EFgmsfoffset(EMmsg, s1, my_id, OM_Gw_current_OS, my_info->radius, dirpt,
                  my_info->edge_type, &geom_offsf1);
     EMerr_hndlr (!(*EMmsg & 1), *EMmsg, EMS_E_RndGrExit, wrapup);

     EFgmsfoffset(EMmsg, s2, my_info->comm_surface_id, OM_Gw_current_OS, 
                  my_info->radius, dirpt, my_info->edge_type, &geom_offsf2);
     EMerr_hndlr (!(*EMmsg & 1), *EMmsg, EMS_E_RndGrExit, wrapup);

     /* Intersect the offset surfaces */

     BSsfsfint(geom_offsf1, geom_offsf2, &tnumgrps, &tnumints, &tnumpts,
               &tpts, &tpar1, &tpar2, &cvscode, &xyz_cvs, &uv1_cvs, &uv2_cvs,
               &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     for (total_num_cvs = 0, i = 0; i < tnumgrps; i++)
        total_num_cvs += tnumints[i];

     if (tnumgrps == 0)
      {
       *EMmsg = EMS_E_RndGrExit;
       goto wrapup;
      }

     /* If more than one intersection group, link together across */
     /* parameter boundaries                                      */

     if (tnumgrps > 1)
      {
       temp_tol = chrdht_tol / 2;
       (void)BSchangepar(&msg, BSTOLSQLENVEC, temp_tol );

       BSlnkptarrs (1, 1, tnumgrps, tnumpts, tpts, tpar1, tpar2, &numgrps,
                    &numpts, &pts, &par1, &par2, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       (void)BSchangepar (&msg, BSTOLSQLENVEC, dist_sqtol );
      }
     else
      {
       numgrps = tnumgrps;
       numpts = tnumpts;
       pts = tpts;
       par1 = tpar1;
       par2 = tpar2;
      }

    /* If there are several intersection groups, determine which group is
       closest to dirpt */

    cind = 0;
    if (numgrps > 1)
     {
      low_dist = BSdistptpts (&msg, dirpt, pts[0][0] );
      for (i=0; i<numgrps; i++)
       {
        sub = numpts[i] / 20;
        if (sub < 1)
         {
          sub = 1;
         }
        if (i == 0)
         {
          for (j=sub; j<numpts[i]; j+=sub)
           {
            dist = BSdistptpts (&msg, dirpt, pts[i][j]);
            if (dist < low_dist)
             {
              low_dist = dist;
             }
           }         
         }
        else
         {
          for (j=0; j<numpts[i]; j+=sub)
           {
            dist = BSdistptpts (&msg, dirpt, pts[i][j] );
            if (dist < low_dist)
             {
              low_dist = dist;
              cind = i;
             }
           }         
         }
       }
     }

    /* Find corresponding parameter values of the */ 
    /* intersection points on both surfaces       */

    arc1 = (struct IGRbsp_curve **)OM_stack_alloc((unsigned)(numpts[cind]*
                                          sizeof(struct IGRbsp_curve *)));
    EMerr_hndlr (! arc1, *EMmsg, EMS_E_NoStackMemory, wrapup);

    for (i=0; i<numpts[cind]; ++i)
         arc1[i] = NULL;

    stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                            uvendpt, bound, &bound[1], NULL),
                      targetid = my_info->edge_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    if (bound[0].span_inx == bound[1].span_inx)
     mid_param.span_inx = bound[0].span_inx;
    else
     mid_param.span_inx = (IGRint)(bound[0].span_inx+bound[1].span_inx)/2;

    mid_param.param = (bound[0].param + bound[1].param) / 2;

    stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1, &mid_param,
                            NULL, my_parms),
                      targetid = my_info->edge_id);      
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    for (i=0; i<numpts[cind]; i++)
     {
      (void) BSsfarrevn (&msg, s1, 1, &par1[cind][i][0], 1,
                         &par1[cind][i][1], beg_pt, norm1);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      (void) BSsfarrevn (&msg, s2, 1, &par2[cind][i][0], 1,
                         &par2[cind][i][1], end_pt, norm2);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (i==0)
       {
        end_param[0] = par1[cind][i][0];
        end_param[1] = par1[cind][i][1];
        end_param[2] = par2[cind][i][0];
        end_param[3] = par2[cind][i][1];
        OM_BLOCK_MOVE(beg_pt, bpnt[0], sizeof (IGRpoint));
        OM_BLOCK_MOVE(end_pt, epnt[0], sizeof (IGRpoint));
        if (! s1->pos_orient)
         {
          for(j=0; j<3; j++)
           vector0[j] = -norm1[j]; 
         }
        else
         {
          for(j=0; j<3; j++)
           vector0[j] = norm1[j]; 
         }
       }

      dist = EM2ddistptpts (my_parms, par1[cind][i]);
      if (dist < min_dist)
       {
        OM_BLOCK_MOVE(beg_pt, s1_pnt, sizeof (IGRpoint));
        OM_BLOCK_MOVE(end_pt, s2_pnt, sizeof (IGRpoint));
        min_dist = dist;
       }
      if (rho != 0)
       {
        BSalloccv(3, 9, 1, 0, &arc1[i], &msg);
        EMerr_hndlr (msg != BSSUCC,*EMmsg, EMS_E_NoDynamicMemory, wrapup);
       }
      else
       {
        BSalloccv(2, 2, 0, 0, &arc1[i], &msg);
        EMerr_hndlr (msg != BSSUCC,*EMmsg, EMS_E_NoDynamicMemory, wrapup);
       }

      BSpseudoarc (beg_pt, pts[cind][i], end_pt, rho, norm1, norm2,
                   arc1[i], &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }

    end_param[4] = par1[cind][(numpts[cind]-1)][0];
    end_param[5] = par1[cind][(numpts[cind]-1)][1];
    end_param[6] = par2[cind][(numpts[cind]-1)][0];
    end_param[7] = par2[cind][(numpts[cind]-1)][1];

    OM_BLOCK_MOVE(beg_pt, bpnt[1], sizeof (IGRpoint));
    OM_BLOCK_MOVE(end_pt, epnt[1], sizeof (IGRpoint));

    if (numpts[cind] == 2)
     {
      for (i=0; i<3; i++)
       {
        s1_pnt[i] = bpnt[0][i] + (bpnt[1][i] - bpnt[0][i])/2;     
        s2_pnt[i] = epnt[0][i] + (epnt[1][i] - epnt[0][i])/2;     
       }
     }

    /* Make all circular arcs compatible */

    if (rho != 0)
     {
      arc2 = (struct IGRbsp_curve **) om$malloc(size = numpts[cind] *
                                         sizeof(struct IGRbsp_curve *));
      EMerr_hndlr (!arc2, *EMmsg, EMS_E_NoStackMemory, wrapup);
    
      BSmkcvscp (numpts[cind], arc1, arc2, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }

    /* Using the information contained in the compatible arcs, construct*/
    /* the fillet surface                                               */

    tnum = numpts[cind] + 3;

    if (numpts[cind] > 3)
        tempord = 4;
    else
        tempord = numpts[cind];

    if (rho != 0)
     {
      BSallocsf (arc2[0]->order, tempord, arc2[0]->num_poles, tnum, 1, 0, 
                 &fsurf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     }
    else
     {
      BSallocsf (arc1[0]->order, tempord, arc1[0]->num_poles, tnum, 1, 0, 
                 &fsurf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     }

    fsurf->v_order = tempord;
    fsurf->planar = FALSE;
    fsurf->u_phy_closed = FALSE;

    dist = BSdistptpts (&msg, pts[cind][0], pts[cind][numpts[cind] - 1]);

    fsurf->v_periodic = (dist < dist_sqtol) ? TRUE : FALSE;

    if (rho != 0)
     {
      BSsf_thrcvs (numpts[cind], arc2, NULL, 0, 0, 0, fsurf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      first_arc = arc2[0];
      last_arc = arc2[numpts[cind]-1];
     }
    else
     {
      BSsf_thrcvs (numpts[cind], arc1, NULL, 0, 0, 0, fsurf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      first_arc = arc1[0];
      last_arc = arc1[numpts[cind]-1];
     }

    fsurf->v_phy_closed = (dist < dist_sqtol) ? TRUE : FALSE;

    if (fsurf->v_periodic)
     {
      BSscnvtmekt(FALSE, FALSE, TRUE, TRUE, fsurf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }

    special_proc = FALSE;

    if ((s1->u_phy_closed || s1->v_phy_closed || s2->u_phy_closed ||
         s2->v_phy_closed) && (! (rnd_edge_prop & EMED_XYZ_CLOSED)))
     {
      stat_OM = om$send(msg = message EMSedge.EMxyz_endpt(&msg, NULL,
                              &(my_env->md_env),uvbegpt,uvendpt,xyzbeg, xyzend, &s1),
                        targetid = my_info->edge_id);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                              EMS_WHL_EDGE, edges, &num_ed),
                        targetid = my_info->edge_id);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      ngb_edges[0] = edges[0].objid;
      ngb_edges[1] = edges[1].objid;

      for (i=0; i<2; i++)
       {
        stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                                &edge_prop),
                          targetid = edges[i].objid);
        EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);
        if (edge_prop & EMED_SEAM)
         {
          iso_curve = NULL;

          edge_geom.weights = NULL;
          edge_geom.poles = NULL;
          edge_geom.knots = NULL;
          edge_geom.bdrys = NULL;

          stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                                  &my_env->md_env, NULL, s1, 0,
                                  OM_K_MAXINT, FALSE, NULL, &edge_geom),
                            targetid = edges[i].objid);
          EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

          BSalloccv (fsurf->v_order, fsurf->v_num_poles, fsurf->rational,
                     NULL, &iso_curve, &msg);
          EMerr_hndlr (msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

          option = 1;
          v0_or_v1 = 0.0; tst_planar = TRUE;
          BSconstprcv(&msg,fsurf,&option,&v0_or_v1,&tst_planar,iso_curve);
          EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

          BSmdistcvcv(iso_curve,
                      &edge_geom,
                      (IGRint *)&num_bytes,
                      &p0, &p1,
                      &cv1_pts,
                      &cv2_pts,
                      &dist,
                      &msg);
          EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

          inxa = 0;
          if (num_bytes > 1)
           {
            low_dist = MAXFLOAT;
            for (j=0; j<num_bytes; j++)
             {
              dist =  BSdistptpt (&msg, cv1_pts[j],(!i)?xyzbeg:xyzend);
              if (dist < low_dist)
               {
                low_dist = dist;
                inxa = j;
               }     
             }   
           }

          if (! i)
           OM_BLOCK_MOVE(&cv1_pts[inxa][0], xyzbeg, sizeof (IGRpoint));
          else
           OM_BLOCK_MOVE(&cv1_pts[inxa][0], xyzend, sizeof (IGRpoint));

          special_proc = TRUE;
          break;
         }
       }

      if (! special_proc)
       {
        if (rnd_edge_prop & EMED_REVERSE_CONNECT)
         {
          OM_BLOCK_MOVE(xyzbeg, base_point, sizeof (IGRpoint));
          OM_BLOCK_MOVE(xyzend, xyzbeg, sizeof (IGRpoint));
          OM_BLOCK_MOVE(base_point, xyzend, sizeof (IGRpoint));
         }

        stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                                EMS_WHL_EDGE, edges, &num_ed),
                          senderid = my_info->edge_id,
                          p_chanselect = &to_common_edge);
        EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);

        ngb_edges[2] = edges[0].objid;
        ngb_edges[3] = edges[1].objid;

        for (i=0; i<2; i++)
         {
          stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                                  &edge_prop),
                            targetid = edges[i].objid);
          EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

          if (edge_prop & EMED_SEAM)
           {
            iso_curve = NULL;

            edge_geom.weights = NULL;
            edge_geom.poles = NULL;
            edge_geom.knots = NULL;
            edge_geom.bdrys = NULL;

            stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                                    &my_env->md_env, NULL, s2, 0,
                                    OM_K_MAXINT, FALSE, NULL, &edge_geom),
                              targetid = edges[i].objid);
            EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_EdgeError, wrapup);

            BSalloccv(fsurf->v_order, fsurf->v_num_poles, fsurf->rational,
                      NULL, &iso_curve, &msg);
            EMerr_hndlr(msg !=BSSUCC,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

            option = 1;
            v0_or_v1 = 1.0; tst_planar = TRUE;
            BSconstprcv (&msg, fsurf, &option, &v0_or_v1, &tst_planar,
                         iso_curve);
            EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

            BSmdistcvcv(iso_curve,
                        &edge_geom,
                        (IGRint *)&num_bytes,
                        &p0, &p1,
                        &cv1_pts,
                        &cv2_pts,
                        &dist,
                        &msg);
            EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

            inxa = 0;
            if (num_bytes > 1)
             {
              low_dist = MAXFLOAT;
              for (j=0; j<num_bytes; j++)
               {
                dist =  BSdistptpt(&msg,cv1_pts[j],(!i)?xyzbeg:xyzend);
                if (dist < low_dist)
                 {
                  low_dist = dist;
                  inxa = j;
                 }     
               }   
             }

            if (! i)
             OM_BLOCK_MOVE(&cv1_pts[inxa][0], xyzbeg, sizeof (IGRpoint));
            else
             OM_BLOCK_MOVE(&cv1_pts[inxa][0], xyzend, sizeof (IGRpoint));

            special_proc = TRUE;
            break;
           }
         }
       }
     }

    if (((!(rnd_edge_prop & EMED_XYZ_CLOSED)) && (fsurf->v_phy_closed)) ||
        (special_proc))
     {
      BSsfeval(s1, my_parms[0], my_parms[1], 0, (IGRpoint *)f_point, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      min_dist = MAXFLOAT;
      low_dist = MAXFLOAT;
      mid_dist = MAXFLOAT;

      for (i=0; i<numpts[cind]; i++)
       {
        dist = BSdistptpts (&msg, xyzbeg, pts[cind][i]);
        if (dist < min_dist)
         {
          min_dist = dist;
          inxa = i;
         }

        dist = BSdistptpts (&msg, xyzend, pts[cind][i]);
        if (dist < low_dist)
         {
          low_dist = dist;
          inxb = i;
         }

        dist = BSdistptpts (&msg, f_point, pts[cind][i]);
        if (dist < mid_dist)
         {
          mid_dist = dist;
          mid_inx = i;
         }
       }

      if ((mid_inx < inxa) && (mid_inx < inxb))
       {
        if (inxb == numpts[cind]-1) inxb = 0;
        else if (inxa == numpts[cind]-1) inxa = 0;
       }
      else
      if ((mid_inx > inxa) && (mid_inx > inxb))
       {
        if (inxa == 0) inxa = numpts[cind]-1;
        else if (inxb == 0) inxb = numpts[cind]-1;
       }

      if (inxa < inxb) { low_inx = inxa; high_inx = inxb; }
      else { low_inx = inxb; high_inx = inxa; }

      status = BSmdistptsf (&msg, 
                            fsurf,
                            pts[cind][low_inx],
                            &param[0],
                            &param[1],
                            base_point,
                            &dist);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      status = BSmdistptsf (&msg, 
                            fsurf,
                            pts[cind][high_inx],
                            &pt_in_area[0],
                            &pt_in_area[1],
                            base_point,
                            &dist);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

      param[0] = 0.0;
      pt_in_area[0] = 0.0;

      numpts[cind] = high_inx-low_inx+1;

      status = BSprptonsf(&msg, fsurf, f_point, &mid_parm[0],&mid_parm[1],
                          &On_surf);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

      if (! On_surf)
       {
        status = BSmdistptsf (&msg, 
                              fsurf,
                              f_point,
                              &mid_parm[0],
                              &mid_parm[1],
                              base_point,
                              &dist);
        EMerr_hndlr(!status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
       }

      BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

      mid_parm[0] = 0.0;

      if (((mid_parm[1] > param[1]) && (mid_parm[1] > pt_in_area[1])) ||
          ((mid_parm[1] < param[1]) && (mid_parm[1] < pt_in_area[1])))
       {
        if ((param[1] >= 1-knot_tol) || (param[1] <= knot_tol))
         {
          if (param[1] >= 1-knot_tol)
           {
            if (mid_parm[1] < pt_in_area[1]) param[1] = 0.0;
           }
          if (param[1] <= knot_tol)
           {
            if (mid_parm[1] > pt_in_area[1]) param[1] = 1.0;
           }
         }
        else if((pt_in_area[1] >= 1-knot_tol) ||
                (pt_in_area[1] <= knot_tol))
         {
          if (pt_in_area[1] >= 1-knot_tol)
           {
            if (mid_parm[1] < param[1]) pt_in_area[1] = 0.0;
           }
          if (pt_in_area[1] <= knot_tol)
           {
            if (mid_parm[1] > param[1]) pt_in_area[1] = 1.0;
           }
         }
       }

      BSallocsf(2*(fsurf->u_order),2*(fsurf->v_order),
                2*(fsurf->u_num_poles),2*(fsurf->v_num_poles),
                2*(fsurf->rational),2*(fsurf->num_boundaries),
                &part_surf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      fsurf->num_boundaries = 0;
      part_surf->rational = fsurf->rational;
      part_surf->num_boundaries = fsurf->num_boundaries;

      BSpartofsf (fsurf, param, mid_parm, pt_in_area, split_ind,
                  part_surf, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      BSnrsfkntvc(part_surf);

      part_surf->pos_orient = fsurf->pos_orient;

      if (fsurf) BSfreesf (&msg, fsurf);
      fsurf = part_surf;
  
      end_param[0] = par1[cind][low_inx][0];
      end_param[1] = par1[cind][low_inx][1];
      end_param[2] = par2[cind][low_inx][0];
      end_param[3] = par2[cind][low_inx][1];

      end_param[4] = par1[cind][high_inx][0];
      end_param[5] = par1[cind][high_inx][1];
      end_param[6] = par2[cind][high_inx][0];
      end_param[7] = par2[cind][high_inx][1];

      BSalloccv (fsurf->u_order, fsurf->u_num_poles, fsurf->rational,
                 NULL, &first_arc, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      option = 0;
      mid_parm[0] = 0.0; tst_planar = TRUE;
      BSconstprcv(&msg, fsurf, &option, &mid_parm[0], &tst_planar,
                  first_arc);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      BSalloccv (fsurf->u_order, fsurf->u_num_poles, fsurf->rational,
                 NULL, &last_arc, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      option = 0;
      mid_parm[0] = 1.0;  tst_planar = TRUE;
      BSconstprcv(&msg, fsurf, &option, &mid_parm[0], &tst_planar,
                  last_arc);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (first_arc->rational)
       {
        for (j=0; j<3; j++)
         {
          bpnt[0][j] = first_arc->poles[j] / first_arc->weights[0];
          epnt[0][j] = first_arc->poles[3 * (first_arc->num_poles-1) + j]/
                       first_arc->weights[first_arc->num_poles - 1];  
         }
       }
      else
       {
        for (j=0; j<3; j++)
         {
          bpnt[0][j] = first_arc->poles[j];
          epnt[0][j] = first_arc->poles[3 * (first_arc->num_poles-1) + j];
         }
       }

      if (last_arc->rational)
       {
        for (j=0; j<3; j++)
         {
          bpnt[1][j] = last_arc->poles[j] / last_arc->weights[0];
          epnt[1][j] = last_arc->poles[3 * (last_arc->num_poles-1) + j] /
                       last_arc->weights[last_arc->num_poles - 1];  
         }
       }
      else
       {
        for (j=0; j<3; j++)
         {
          bpnt[1][j] = last_arc->poles[j];
          epnt[1][j] = last_arc->poles[3 * (last_arc->num_poles-1) + j];
         }
       }

      for (i=0; i<numpts[cind]; i++)
       {
        par1[cind][i][0] = par1[cind][low_inx+i][0];
        par1[cind][i][1] = par1[cind][low_inx+i][1];
        par2[cind][i][0] = par2[cind][low_inx+i][0];
        par2[cind][i][1] = par2[cind][low_inx+i][1];
       }

      d1 = EM2ddistptpt(uvbegpt, par1[cind][1]);
      d2 = EM2ddistptpt(uvendpt, par1[cind][1]);

      if ((d1<d2) && (ngb_edges[0] != NULL_OBJID))
           next_edges[0].objid = ngb_edges[0];
      else
      if ((d2<d1) && (ngb_edges[1] != NULL_OBJID))
           next_edges[0].objid = ngb_edges[1];
      else
       {
        stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                               (d1<d2)? EMS_EDGE_BEG_PT : EMS_EDGE_END_PT,
                               &next_edges[0], &num_ed),
                          targetid = my_info->edge_id);
        EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
       }

      stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                              &next_edge_prop),
                        targetid = next_edges[0].objid);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      if (next_edge_prop & EMED_SEAM)
       {
        par1[cind][0][0] = par1[cind][1][0];
        par1[cind][0][1] = par1[cind][1][1];
 
        stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                                &par1[cind][0][0], 1, &proj_info, NULL,
                                &s1_partol),
                          targetid = next_edges[0].objid);
        EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);

        par1[cind][0][0] = proj_info.proj_pt[0];
        par1[cind][0][1] = proj_info.proj_pt[1];
       }

      if ((d1<d2) && (ngb_edges[1] != NULL_OBJID))
           next_edges[1].objid = ngb_edges[1];
      else
      if ((d2<d1) && (ngb_edges[0] != NULL_OBJID))
           next_edges[1].objid = ngb_edges[0];
      else
       {
        stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                               (d1<d2)? EMS_EDGE_END_PT : EMS_EDGE_BEG_PT,
                               &next_edges[1], &num_ed),
                          targetid = my_info->edge_id);
        EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
       }

      stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                              &next_edge_prop),
                        targetid = next_edges[1].objid);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      if (next_edge_prop & EMED_SEAM)
       {
        par1[cind][numpts[cind]-1][0] = par1[cind][numpts[cind]-2][0];
        par1[cind][numpts[cind]-1][1] = par1[cind][numpts[cind]-2][1];

        stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                                &par1[cind][numpts[cind]-1][0], 1,
                                &proj_info, NULL, &s1_partol),
                          targetid = next_edges[1].objid);
        EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);

        par1[cind][numpts[cind]-1][0] = proj_info.proj_pt[0];
        par1[cind][numpts[cind]-1][1] = proj_info.proj_pt[1];
       }

      stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                              uvendpt, NULL, NULL, NULL),
                        senderid = my_info->edge_id,
                        p_chanselect = &to_common_edge);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      d1 = EM2ddistptpt(uvbegpt, par2[cind][1]);
      d2 = EM2ddistptpt(uvendpt, par2[cind][1]);

      if ((d1<d2) && (ngb_edges[2] != NULL_OBJID))
           next_edges[0].objid = ngb_edges[2];
      else
      if ((d2<d1) && (ngb_edges[3] != NULL_OBJID))
           next_edges[0].objid = ngb_edges[3];
      else
       {
        stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                               (d1<d2)? EMS_EDGE_BEG_PT : EMS_EDGE_END_PT,
                               &next_edges[0], &num_ed),
                          senderid = my_info->edge_id,
                          p_chanselect = &to_common_edge);
        EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
       }

      stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                              &next_edge_prop),
                        targetid = next_edges[0].objid);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      if (next_edge_prop & EMED_SEAM)
       {
        par2[cind][0][0] = par2[cind][1][0];
        par2[cind][0][1] = par2[cind][1][1];

        stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                                &par2[cind][0][0], 1, &proj_info, NULL,
                                &s2_partol),
                          targetid = next_edges[0].objid);
        EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);

        par2[cind][0][0] = proj_info.proj_pt[0];
        par2[cind][0][1] = proj_info.proj_pt[1];
       }

      if ((d1<d2) && (ngb_edges[3] != NULL_OBJID))
           next_edges[1].objid = ngb_edges[3];
      else
      if ((d2<d1) && (ngb_edges[2] != NULL_OBJID))
           next_edges[1].objid = ngb_edges[2];
      else
       {
        stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                               (d1<d2)? EMS_EDGE_END_PT : EMS_EDGE_BEG_PT,
                               &next_edges[1], &num_ed),
                          senderid = my_info->edge_id,
                          p_chanselect = &to_common_edge);
        EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
       }

      stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                              &next_edge_prop),
                        targetid = next_edges[1].objid);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      if (next_edge_prop & EMED_SEAM)
       {
        par2[cind][numpts[cind]-1][0] = par2[cind][numpts[cind]-2][0];
        par2[cind][numpts[cind]-1][1] = par2[cind][numpts[cind]-2][1];

        stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                                &par2[cind][numpts[cind]-1][0], 1,
                                &proj_info, NULL, &s2_partol),
                          targetid = next_edges[1].objid);
        EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);
 
        par2[cind][numpts[cind]-1][0] = proj_info.proj_pt[0];
        par2[cind][numpts[cind]-1][1] = proj_info.proj_pt[1];
       }

      BSsfarrevn (&msg, s1, 1, &par1[cind][0][0], 1, &par1[cind][0][1],
                  beg_pt, norm1);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (! s1->pos_orient)
       {
        for(j=0; j<3; j++)
            vector0[j] = -norm1[j]; 
       }
      else
       {
        for(j=0; j<3; j++)
            vector0[j] = norm1[j]; 
       }
     }

    status = BSprptonsf (&msg, fsurf, bpnt[0], &param[0], &param[1],
                         &On_surf);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    break;
 } /* switch */

 /* Align the normal of fillet surface */

 BSsfarrevn(&msg, fsurf, 1, &param[0], 1, &param[1], f_point, vector1);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (BSdotp(&msg, vector0, vector1) > 0)
     fsurf->pos_orient = TRUE;
 else
     fsurf->pos_orient = FALSE;
 
 my_info->fillet_surface = fsurf;
 
 construct_list->geometry = (IGRchar *) fsurf;

 if ((curve_type == EMlinesegment) && (operation_type != EMS_CHAMFER_OPR))
  {
   stat_OM = om$construct(classid = OPP_EMSpcylindr_class_id,
                          p_objid = fillet_id,
                          msg = message GRgraphics.GRconstruct(
                          construct_list));
  }
 else
  {
   stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                          p_objid = fillet_id,
                          msg = message GRgraphics.GRconstruct(
                          construct_list));
  } 
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 /* construct the natural boundary for the surface fillet surface */

 stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                          &my_env->md_env, f_edges),
                    targetid = *fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 closed_curve = FALSE;

 if ((EM2ddistptpt(&end_param[0], &end_param[4]) <= s1_partol.tol) &&
     (BSdistptpt(&msg, bpnt[0], bpnt[1]) <= dist_tol))
      closed_curve = TRUE; /* closed in uv & model space */

 EFget_point_in_area (&msg, closed_curve, s1, s1_pnt, s2_pnt, pt_in_area);
 EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
 
 num_loops = 0;
 loop_id = NULL;

 stat_OM = om$send (msg = message EMSsubbs.EMmake_edge_loop (&msg,
                          my_env, my_info, fsurf, s1, par1, cind,
                          &numpts[cind], 0, EMS_EDGE_BND, round_id,
                          my_info->edge_id, &s1_partol, FALSE,
                          special_fillet, pt_in_area, &edges[0],
                          &num_loops, &loop_id),
                    targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 
 stat_OM = om$send (msg = message EMSedge.EMconnect_edges (&msg,
                          NULL, TRUE,
                          f_edges[0],
                          my_id,
                          *fillet_id,
                          &my_env->md_env),
                    targetid = edges[0].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 closed_curve = FALSE;

 if ((EM2ddistptpt(&end_param[2], &end_param[6]) <= s2_partol.tol) &&
     (BSdistptpt(&msg, epnt[0], epnt[1]) <= dist_tol))
      closed_curve = TRUE;

 EFget_point_in_area (&msg, closed_curve, s2, s2_pnt, s1_pnt, pt_in_area);
 EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
 
 stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                         &other_edge),
                   senderid = my_info->edge_id,
                   p_chanselect = &to_common_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 num_loops = 0;
 loop_id = NULL;

 stat_OM = om$send (msg = message EMSsubbs.EMmake_edge_loop (&msg,
                          my_env, my_info, fsurf, s2, par2, cind,
                          &numpts[cind], 1, EMS_EDGE_BND, round_id,
                          other_edge, &s2_partol, FALSE,
                          special_fillet, pt_in_area, &edges[1],
                          &num_loops, &loop_id),
                    targetid = my_info->comm_surface_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 stat_OM = om$send (msg = message EMSedge.EMconnect_edges (&msg,
                          NULL, TRUE,
                          f_edges[2],
                          my_info->comm_surface_id,
                          *fillet_id,
                          &my_env->md_env),
                    targetid = edges[1].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 UI_status(" ");

/* What happens at the fillet ends ? 0. Trim with adjacent surfaces(s) */
/*                                   1. Patch off the gaps             */

if (! (rnd_edge_prop & EMED_XYZ_CLOSED))
 {
  if ((curve_type == EMlinesegment) || (curve_type == EMcircular_arc))
   {
    stat_OM = om$send (msg = message EMSedge.EMendpts (&msg,&end_param[0],
                             &end_param[4], NULL, NULL, NULL),
                       targetid = edges[0].objid);
    EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    stat_OM = om$send (msg = message EMSedge.EMendpts (&msg,&end_param[2],
                             &end_param[6], NULL, NULL, NULL),
                       targetid = edges[1].objid);
    EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  stat_OM = om$send (msg = message EMSsubbs.EMend_patches (&msg,
                           my_env, round_id, construct_list, &s1_partol,
                           &s2_partol, s2, *fillet_id, bpnt, end_param,
                           f_edges, first_arc, last_arc, my_info,
                           num_def_info, def_info, num_pair_info,
                           pair_info, num_round_edges, rnd_edge_ids,
                           edges),
                     targetid = my_id);  
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMfillet_surface");

 if (! (1 & stat_OM & *EMmsg))
  {
   if (1 & (stat_OM1 = om$is_objid_valid(objid = my_info->fillet_id)))
    {
     stat_OM1 = om$send(msg = message GRgraphics.GRdelete(&msg1, my_env),
                       targetid = my_info->fillet_id);
    }
  }

 if ((arc2) && (rho != 0))
  {
    for (i=0;i < numpts[cind];i++)
     {
      if (arc2[i]) BSfreecv (&msg, arc2[i] );
     }
    om$dealloc (ptr = (char *)arc2);
  }

 if (arc1)
  {
    for (i=0;i < numpts[cind];i++)
     {
      if (arc1[i]) BSfreecv (&msg, arc1[i] );
     }
    OM_stack_dealloc ((char *)arc1);
  }

 if ((numpts) && (tnumgrps > 1))
    om$dealloc(ptr = (char *)numpts);

 if ((pts) && (tnumgrps > 1))
  {
    for (i=0;i < numgrps;i++)
     {
        if (pts[i])
           om$dealloc (ptr = (char *)pts[i]);
     }
    om$dealloc (ptr = (char *)pts);
  }
 if ((par1) && (tnumgrps > 1))
  {
    for (i=0;i < numgrps;i++)
     {
        if (par1[i])
           om$dealloc (ptr = (char *)par1[i]);
     }
    om$dealloc (ptr = (char *)par1);
  }
 if ((par2) && (tnumgrps > 1))
  {
    for (i=0;i < numgrps;i++)
     {
        if (par2[i])
           om$dealloc (ptr = (char *)par2[i]);
     }
    om$dealloc (ptr = (char *)par2);
  }
 if (tnumpts)
    om$dealloc (ptr = (char *)tnumpts);
 if (tpts)
  {
    for (i=0;i < tnumgrps;i++)
     {
        if (tpts[i])
           om$dealloc (ptr = (char *)tpts[i]);
     }
    om$dealloc (ptr = (char *)tpts);
  }
 if (tpar1)
  {
    for (i=0;i < tnumgrps;i++)
     {
        if (tpar1[i])
           om$dealloc (ptr = (char *)tpar1[i]);
     }
    om$dealloc (ptr = (char *)tpar1);
  }
 if (tpar2)
  {
    for (i=0;i < tnumgrps;i++)
     {
        if (tpar2[i])
           om$dealloc (ptr = (char *)tpar2[i]);
     }
    om$dealloc (ptr = (char *)tpar2);
  }

  if (geom_offsf1)
  {
      if (geom_offsf1->bspsf)
          BSfreesf(&msg, geom_offsf1->bspsf);

      if (geom_offsf1->sfgen_cv)
          BSfreecv(&msg, geom_offsf1->sfgen_cv);

      BSdealloc((char *) geom_offsf1);
  }

  if (geom_offsf2)
  {
      if (geom_offsf2->bspsf)
          BSfreesf(&msg, geom_offsf2->bspsf);

      if (geom_offsf2->sfgen_cv)
          BSfreecv(&msg, geom_offsf2->sfgen_cv);

      BSdealloc((char *) geom_offsf2);
  }

 free_geom_bsp_curve(&msg, total_num_cvs, xyz_cvs);
 free_geom_bsp_curve(&msg, total_num_cvs, uv1_cvs);
 free_geom_bsp_curve(&msg, total_num_cvs, uv2_cvs);
 if (tnumints)
   BSdealloc((char *) tnumints);

 if (s2) om$dealloc (ptr = s2);
 if (special_fillet && first_arc)
  {
   BSfreecv (&msg, first_arc);
   first_arc = NULL;
  }
 if ((special_fillet && last_arc) && (curve_type != EMcircle))
  {
   BSfreecv (&msg, last_arc);
   last_arc = NULL;
  }

 return (stat_OM);
}

/*
    HISTORY

    12/28/92 : WBC : Creation

    ABSTRACT

        This function will create an offset surface from a bspline surface
    and return both the bspline and geometric definition of the offset surface.
    It is assumed that the surface being created is to be used for rounding.
*/

void EFgmsfoffset(msg, bsp_surface, surface_id, surface_os, distance, side_pt,
                  edge_type, geom_offset_surf)

IGRlong                 *msg;               /* Output:  return code */
struct IGRbsp_surface   *bsp_surface;       /* Input:  surface from which to
                                                       create the offset
                                                       surface */
GRobjid                  surface_id;        /* Input:  object id of the
                                                       bsp_surface */
GRspacenum               surface_os;        /* Input:  object osnum of the
                                                       bsp_surface */
IGRdouble                distance;          /* Input:  distance to create the
                                                       offset surface from the
                                                       original surface */
IGRpoint                 side_pt;           /* Input:  point to indicate on
                                                       which side of the
                                                       original surface the
                                                       offset surface is to be
                                                       created */
IGRushort                edge_type;         /* Input:  the type of the edge to
                                                       be rounded */
struct BSgeom_bsp_surf **geom_offset_surf;  /* Output:  the offset surface;
                                                        the memory for this
                                                        surface will be
                                                        allocated within this
                                                        function; the caller
                                                        is responsible for
                                                        deallocting the memory
                                                        using BSdealloc */
{
    extern void EFinit_geom_surface();

    struct BSgeom_bsp_surf   geom_surface,
                           **offset_surf_array;
    BSrc                     rc;
    IGRint                   num_surfs,
                             index;
    IGRboolean               natural_normal;

    *msg = EMS_S_Success;

    /* initialize the required members of the geometric surface structure */

    EFinit_geom_surface(msg, bsp_surface, surface_id, surface_os,
                        &geom_surface);

    if (1 & *msg)
    {
        /* determine if the offset surface is to be created on the original
         * surface's natural normal side or the opposite side
         */

        BSptonnsdsf(bsp_surface, side_pt, &natural_normal, &rc);

        if (rc != BSSUCC)
        {
            if (((bsp_surface->pos_orient) &&
                 (edge_type == EMS_CONVEX_EDGE)) ||
                ((! bsp_surface->pos_orient) &&
                 (edge_type == EMS_CONCAVE_EDGE)))
                natural_normal = TRUE;
            else
                natural_normal = FALSE;
        }

        /* call the function to create the offset geometric surface */

        num_surfs = 0;

        BScdoffsrf(&geom_surface, distance, natural_normal, TRUE, &num_surfs,
                   &offset_surf_array, &rc);

        if (rc == BSSUCC)
        {
            *geom_offset_surf = offset_surf_array[0];

            /* remove any unused offset surfaces */

            for (index = 1; index < num_surfs; index++)
            {
                if (offset_surf_array[index])
                {
                    if (offset_surf_array[index]->bspsf)
                        BSfreesf(&rc, offset_surf_array[index]->bspsf);

                    if (offset_surf_array[index]->sfgen_cv)
                        BSfreecv(&rc, offset_surf_array[index]->sfgen_cv);

                    BSdealloc((char *) offset_surf_array[index]);
                }
            }

            if (offset_surf_array)
                BSdealloc((char *) offset_surf_array);
        }
        else
            *msg = EMS_E_Fail;
    }
}

end implementation EMSsubbs;
