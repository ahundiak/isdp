/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgenbs;

/*
HISTORY:

Long Ago:  ??  Creation.
08/27/92:  NP  Modified for ANSI compliance.
07/06/93   Sudha Modified for BSprototypes ansification

*/

#include "EMS.h"
#include "bsfreesf.h"
#include "bsfndspnarr.h"
#include "bsfitratsf.h"

#define MAX_BUFF 20

p_fit_rational_surface(EMmsg,g_surf_env,g_surf_GRid, unum, vnum,
                       u_vals, v_vals, weights,node_pts,
                       f_GRid,f_surf_env)

IGRlong *EMmsg;
struct GRmd_env *g_surf_env;
struct GRid *g_surf_GRid;
IGRint unum;
IGRint vnum;
IGRdouble *u_vals;
IGRdouble *v_vals;
IGRdouble *weights;
IGRdouble *node_pts;
struct GRid *f_GRid;
struct GRmd_env *f_surf_env;
{
 IGRlong status,rc,i,j,numpts;
 struct IGRbsp_surface *new_surf = NULL;
 struct IGRbsp_surface *g_surf = NULL,*f_surf = NULL;
 IGRint *u_spn_ptr = NULL, *v_spn_ptr = NULL;
 IGRint u_spn_buff[MAX_BUFF], v_spn_buff[MAX_BUFF];
 IGRint unum_buff[MAX_BUFF],*unum_ptr = NULL;
 IGRshort dirfit = TRUE;
 IGRchar *geom = NULL;
 enum EMSdatatype type;

/* Dummy variables for direct fit */

 IGRpoint maxpt;
 IGRdouble avgerr, maxerr,tol;
 IGRint maxind[2];

/* ****************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 EMgetvggeom(EMmsg, &g_surf_env->md_env.matrix_type, g_surf_env->md_env.matrix,
            g_surf_GRid, &geom, &type);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);
        
 EMerr_hndlr((type != EMSdata_surface), *EMmsg, EMS_E_InvalidArg, wrapup);

 g_surf = (struct IGRbsp_surface *) geom;

 geom = NULL;

 EMgetvggeom(EMmsg, &f_surf_env->md_env.matrix_type, f_surf_env->md_env.matrix,
            f_GRid, &geom, &type);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);
        
 EMerr_hndlr((type != EMSdata_surface), *EMmsg, EMS_E_InvalidArg, wrapup);

 f_surf = (struct IGRbsp_surface *) geom;

 if (unum > MAX_BUFF)
 {
  u_spn_ptr = (IGRint *) om$malloc (size = sizeof (IGRint) * unum);
  EMerr_hndlr(!u_spn_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
  u_spn_ptr = u_spn_buff;

 if (vnum > MAX_BUFF)
 {
  v_spn_ptr = (IGRint *) om$malloc (size = sizeof (IGRint) * vnum);
  EMerr_hndlr(!v_spn_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  unum_ptr = (IGRint *)om$malloc (size = sizeof(IGRint) * vnum);
  EMerr_hndlr(!unum_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
 {
  v_spn_ptr = v_spn_buff;
  unum_ptr = unum_buff;
 }

 for (i=0;i<vnum;i++)
  unum_ptr[i] = unum;


 BSfndspnarr(g_surf->u_order, g_surf->u_num_poles, unum, u_vals,g_surf->u_knots,
             u_spn_ptr, &rc);
 EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

 BSfndspnarr(g_surf->v_order, g_surf->v_num_poles, vnum ,v_vals,g_surf->v_knots,
             v_spn_ptr, &rc);
 EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

 numpts = unum * vnum;

/*
 * Weight the nodes back if weights are being passed in.
 */

 if (weights)
 {
  for (i=0;i<numpts;i++)
  {
   for (j=0;j<3;j++)
    f_surf->poles[3*i+j] = f_surf->poles[3*i+j] * weights[i];
  }
 }

 BSfitratsf(vnum, /* Vnum */
            unum_ptr, /* Unum */
            f_surf->poles, /* Node pts */
            weights, /* weights */
            u_vals, /* u pars */
            v_vals, /* v pars */
            u_spn_ptr, /* U span indices */
            v_spn_ptr, /* V span indices */
            g_surf->u_order, /* U order */
            g_surf->v_order, /* V order */
            g_surf->u_num_knots, /* U num knots */
            g_surf->v_num_knots, /* V num knots */
            g_surf->u_knots,     /* U knots */
            g_surf->v_knots,     /* V knots */
            g_surf->u_periodic,  /* U periodic */
            g_surf->v_periodic,  /* V periodic */
            1,                   /* U code */
            1,                   /* V code */
            0, /* uendl */
            0, /* uendr */
            0, /* vendl */
            0, /* vendr */
            NULL, /* utanpoll */
            NULL, /* utanpolr */
            NULL, /* vtanpoll */
            NULL, /* vtanpolr */
            NULL, /* ucrvpol */
            NULL, /* ucrvpolr */
            NULL, /* vcrvpolr */
            NULL, /* vcrvpolr */
            NULL, /*  uewtl */
            NULL, /* uewtr */
            NULL, /* vewtl */
            NULL, /* vewtr */
            NULL, /* unewtl */
            NULL, /* unewtr */
            NULL, /* vnewtl */
            NULL, /* vnewtr */
            dirfit, /* Direct fit */
            tol,  /* Tolerance not used */
            &new_surf, /* new surface */
            &avgerr, /* Not used for direct fit */
            &maxerr, /* Not used for direct fit */
            maxind,  /* Not used for direct fit */
            maxpt,   /* Not used for direct fit */
            &rc);
 EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

 {
  OMuword        g_classid;

  status  = om$get_classid(p_classid = &g_classid,
                         objid = g_surf_GRid->objid,
                         osnum = g_surf_GRid->osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  if (g_classid == OPP_EMSgenbs_class_id)
  {
    struct      GRpost_info info;

    info.construct_flag = FALSE;

    status = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRpostabsg(
                   EMmsg,
                   g_surf_env,
                   &info,
                   (IGRchar *) new_surf,
                   &g_surf_GRid->objid),
                  senderid = NULL_OBJID,
                  targetid = g_surf_GRid->objid,
                  targetos = g_surf_GRid->osnum);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
   else
   {
    IGRshort    chan_flag, del_flag;
    IGRshort properties;

    chan_flag = TRUE;
    del_flag = TRUE;
    status = om$send (msg = message GRgraphics.GRgetprops(EMmsg,&properties),
             senderid = NULL_OBJID,
             targetid = g_surf_GRid->objid,
             targetos = g_surf_GRid->osnum);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    status = EMchgclass (
            EMmsg, 
            g_surf_env,
            *g_surf_GRid, "EMSgenbs", 
            &properties, 
            new_surf,
            &chan_flag, 
            &del_flag, 
            &g_surf_GRid->objid);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
 }

wrapup:

 if (f_surf) om$dealloc(ptr = f_surf);
 if (u_spn_ptr && (u_spn_ptr != u_spn_buff))
  om$dealloc(ptr = u_spn_ptr);
 if (v_spn_ptr && (v_spn_ptr != v_spn_buff))
  om$dealloc(ptr = v_spn_ptr);
 if (unum_ptr && (unum_ptr != unum_buff))
  om$dealloc(ptr = unum_ptr);

 if (new_surf) 
 {
  status = BSfreesf (&rc,new_surf); 
 }

 if (g_surf) om$dealloc(ptr = g_surf);
 GRabsg_del_by_objid(&g_surf_GRid->objid,&g_surf_GRid->osnum);

 return;
}
end implementation EMSgenbs;

