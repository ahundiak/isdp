class implementation EMSassoc;
/*
History

20 March 1994 dfl creation.
                recompute function for lsq curve 

*/

#ifndef OM_DEFINE_ERRMSG
#define OM_DEFINE_ERRMSG
#endif

#include "ems_m_inc.h"
#include "bsicmpcvoff.h"
#include "EMSopt.h"
#include "grownmacros.h"
#include "EMSasmacros.h"
#include "EC_I.h"
#include "ecascrcr.h"


%safe
#include "memory.h"
#include "math.h"
%endsafe


#define dflT1 0
#define dflT2 0

from GR3dlinestr import GRgetpolyline, GRputpolyline;

extern void TWlsqweccv0  (IGRlong,     /* num_pts */ 
                          IGRshort,    /* pdim */      
                          IGRdouble *, /* pts */
                          IGRshort,    /* order */
                          IGRlong,     /* num_knots */ 
                          IGRdouble *, /* knots */
                          IGRshort,    /* opt_par */   
                          IGRdouble *, /* par */ 
                          IGRshort,    /* num_fix */ 
                          IGRshort *,  /* pfix */  
                          IGRshort,    /* num_tan */  
                          IGRshort *,  /* ptan */
                          IGRdouble *, /* tan */
                          IGRshort,    /* opt_curv0 */
                          IGRshort,    /* opt_curv1 */
                          IGRdouble *, /* curv */
                          IGRshort,    /* num_wgts */
                          IGRshort *,  /* pwgts */
                          IGRdouble *, /* wgts */
                          IGRshort,    /* opt_end */
                          IGRshort,    /* opt_sm */
                          IGRdouble,   /* smfac */
                          struct IGRbsp_curve *, /* crv */
                          BSrc *);     /* rc */

extern OM_S_OBJID              current_creator;
extern OMuword			OPP_GRbcsubbc_class_id;
extern IGRdouble BSdotp();
extern BSmdstptcv();

IGRlong TWpar_eval(IGRlong *msg,
                  struct IGRbsp_curve *curve,
                  IGRlong  npts,
                  IGRdouble *pts,
                  IGRdouble *par_vec)
{
 BSrc rc;
 IGRint i, j;
 IGRpoint cveval[2];
 IGRdouble f, df;
 IGRvector v, v2;
 for(i=3,j=1;j<npts-1;i += 3,j++) {
    BScveval(curve,par_vec[j], 1, cveval, &rc);
    v[X] =  cveval[0][X] - pts[i + X];
    v[Y] =  cveval[0][Y] - pts[i + Y];
    v[Z] =  cveval[0][Z] - pts[i + Z];
    v2[X] = cveval[1][X];
    v2[Y] = cveval[1][Y];
    v2[Z] = cveval[1][Z];
    f = BSdotp(&rc, v, v2);
    df = BSdotp(&rc, v2, v2);
    par_vec[j] -= f / df;
 }
 *msg = OM_S_SUCCESS;
 return(OM_S_SUCCESS);
}

                      
IGRint EFascrcr(EMmsg,
                   options,
                   old_objid,
                   new_objid,
                   num_parents,
                   parent_info,
                   recomp_info,
                   const_list,
                   mod_new_id)

 	IGRlong 		*EMmsg;
 	IGRuint 		options;
	GRobjid			old_objid;
	GRobjid			new_objid;
	IGRint			num_parents;
	IGRchar			*parent_info;
	IGRchar			*recomp_info;
	struct GRvg_construct	*const_list;
	GRobjid			*mod_new_id;


/*
    comment


**************************************************************************/
{
#if dflT1
 int				XXXXX;
#endif
 IGRboolean                     opt_iter_flag;
 IGRuint			root_type[1];
 IGRuint			root_count;
 IGRshort                       opt_iter, dumq;
 IGRint                         action;
 /*IGRshort                       x;*/
 IGRlong                        x;
 IGRint				i, j;
 IGRlong			sts;
 IGRlong			stat_OM;
 IGRlong			msg_loc;
 BSrc                           rc;

 struct GRid			curve_id;
 struct IGRbsp_curve		*bsp_curve = NULL;
 union EMSparent_info		*roots = NULL;
 
 
 struct v_info                 *asinfo = NULL;
 IGRchar 		       *char_info = NULL;
 IGRchar                       *parvec_pt = NULL;
 IGRdouble                     *polypts = NULL;
 struct IGRpolyline            polyline;
 IGRshort                      *tav_vxp = NULL;
 IGRdouble                     *tav_vec = NULL;
 IGRshort                      *fxp_vxp = NULL;
 IGRshort                      *fac_vxp = NULL;
 IGRdouble                     *fac_val = NULL;
 IGRdouble                     *kno_vec = NULL;
 IGRdouble                     *par_vec = NULL;
 IGRdouble                     *crv_vec = NULL;
 IGRdouble                     *pol_vec = NULL;
 
 

 *EMmsg = OM_S_SUCCESS;
 sts = OM_S_SUCCESS;
 opt_iter_flag = FALSE;
#if dflT1
  printf("start of associative function LSas_crv\n");
#endif

 /* get recompute control information */
 asinfo = (struct v_info *) recomp_info;

 /* extract the parent_info */
 root_type[0] = EMSlcinfo;

 root_count = num_parents;

 roots = (union EMSparent_info *) stackalloc(root_count * sizeof
                                      (union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);


 stat_OM = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,
                                                        NULL,
                                                        root_count,
                                                        parent_info,
                                                        root_type,
                                                        roots),
               senderid = new_objid,
               targetid = new_objid);
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);

 /* allocate memory for parameters  */
 polypts = (IGRdouble *) om$malloc(
                  size = (asinfo->nvx) * 3 * sizeof(IGRdouble));
 if(!polypts)  
     REPORT_ERROR(*EMmsg,OM_E_NODYNMEM,"om$malloc(polypts)",wrapup);

 if (asinfo->nta > 0) {
   tav_vxp = (IGRshort *) om$malloc(
                  size = (asinfo->nta) * sizeof(IGRlong));
   if(!tav_vxp)  
     EMerr_hndlr(!tav_vxp, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
   tav_vec = (IGRdouble *) om$malloc(
                  size = (asinfo->nta) * 3 * sizeof(IGRdouble));
   if(!tav_vec)  
     EMerr_hndlr(!tav_vec, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 if (asinfo->nfp > 0) {
   fxp_vxp = (IGRshort *) om$malloc(
                  size = (asinfo->nfp) * sizeof(IGRlong));
   if(!fxp_vxp)  
     EMerr_hndlr(!fxp_vxp, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 if (asinfo->nfa > 0) {
   fac_vxp = (IGRshort *) om$malloc(
                  size = (asinfo->nfa) * sizeof(IGRlong));
   if(!fac_vxp)  
     EMerr_hndlr(!fac_vxp, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
   fac_val = (IGRdouble *) om$malloc(
                  size = (asinfo->nfa) * 3 * sizeof(IGRdouble));
   if(!fac_val)  
     EMerr_hndlr(!fac_val, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 if (asinfo->nknot > 0) {
   kno_vec = (IGRdouble *) om$malloc(
                  size = (asinfo->nknot) * sizeof(IGRdouble));
   if(!kno_vec)  
     EMerr_hndlr(!kno_vec, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 if (asinfo->npara > 0) {
   par_vec = (IGRdouble *) om$malloc(
                  size = (asinfo->npara) * sizeof(IGRdouble));
   if(!par_vec) 
     EMerr_hndlr(!par_vec, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 crv_vec = (IGRdouble *) om$malloc(
                  size = (6) * sizeof(IGRdouble));
 if(!crv_vec) { 
     EMerr_hndlr(!crv_vec, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 
 pol_vec = (IGRdouble *) om$malloc(
                  size = (asinfo->npole * 3) * sizeof(IGRdouble));
 if(!pol_vec) { 
     EMerr_hndlr(!pol_vec, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 action = 0;
 stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           EMmsg,
                           &roots->lc_info.module_info.md_env.matrix_type,
                           roots->lc_info.module_info.md_env.matrix,
                           &action,
                           &polyline),
                   senderid = new_objid,
                   targetid = roots->lc_info.located_obj.objid,
                   targetos = roots->lc_info.located_obj.osnum);
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);

 /* test if no of poly-points aggree with no of pts in asinfo->nvx (supplied
    by command object */
 if (polyline.num_points != asinfo->nvx) {
   *mod_new_id = NULL_OBJID;
   *EMmsg = 0;
#if dflT1
   printf("the actual linestring and the associative info about the linestring disagree\n");
#endif
   return(OM_E_ABORT);
 }
    
 polyline.points = polypts;
 action = 1; /* get polyline itself */
 stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           EMmsg,
                           &roots->lc_info.module_info.md_env.matrix_type,
                           roots->lc_info.module_info.md_env.matrix,
                           &action,
                           &polyline),
                   senderid = new_objid,
                   targetid = roots->lc_info.located_obj.objid,
                   targetos = roots->lc_info.located_obj.osnum);
   EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);



   char_info = asinfo->char_data; 
   /* get tangents information */ 
   if(asinfo->nta > 0) {
      for(i=0,j=0;i<asinfo->nta;i++) {
        OM_BLOCK_MOVE(char_info,&x,sizeof(IGRlong));
        *(tav_vxp + i) = (short) x;
        char_info = char_info + sizeof(IGRlong);        
        OM_BLOCK_MOVE(char_info,(tav_vec + j++),sizeof(IGRdouble));
        char_info = char_info + (sizeof(IGRdouble));
        OM_BLOCK_MOVE(char_info,(tav_vec + j++),sizeof(IGRdouble));
        char_info = char_info + (sizeof(IGRdouble));
        OM_BLOCK_MOVE(char_info,(tav_vec + j++),sizeof(IGRdouble));
        char_info = char_info + (sizeof(IGRdouble));
      }
   }
   /* get fix point information */
   if(asinfo->nfp > 0) { 
      for(i=0;i<asinfo->nfp;i++) {
        OM_BLOCK_MOVE(char_info,&x,sizeof(IGRlong));
        *(fxp_vxp + i) = (short) x;
        char_info = char_info + sizeof(IGRlong);
      }
   }

   /* get factor information */ 
   if(asinfo->nfa > 0) {
      for(i=0;i<asinfo->nfa;i++) {
        OM_BLOCK_MOVE(char_info,&x,sizeof(IGRlong));
        *(fac_vxp + i) = (short) x;
        char_info = char_info + sizeof(IGRlong);
        OM_BLOCK_MOVE(char_info,(fac_val + i),sizeof(IGRdouble));
        char_info = char_info + sizeof(IGRdouble);
      }
   }

   /* get knot vector information */ 
   for(i=0;i<asinfo->nknot;i++) {
     OM_BLOCK_MOVE(char_info,(kno_vec + i),sizeof(IGRdouble));
     char_info = char_info + sizeof(IGRdouble);
   }
   /* get para vector information */
   if(asinfo->opt_par == 0) { 
     parvec_pt = char_info;
     for(i=0;i<asinfo->npara;i++) {
       OM_BLOCK_MOVE(char_info,(par_vec + i),sizeof(IGRdouble));
       char_info = char_info + sizeof(IGRdouble);
     }
   }
   /* get curvature vector information */ 
   for(i=0;i<6;i++) {
     crv_vec[i] = asinfo->cv_vector[i];
   }
   /* allocate memory for curve */
    /*BSalloccv( asinfo->order,
               asinfo->npole,
               0,
               0,
               &bsp_curve,
               &rc );*/
   bsp_curve = (struct IGRbsp_curve *) 
                   om$malloc(size = (sizeof(struct IGRbsp_curve)));
   if(!bsp_curve) {
     EMerr_hndlr(!bsp_curve, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
   }


   /* recompute smooth factor (temporarily included) */

    /*for (k=0,dl=0; k < 3*(asinfo->nvx-1); k=k+3)
       {
        dx = polypts[k+3]-polypts[k];
        dy = polypts[k+4]-polypts[k+1];
        dz = polypts[k+5]-polypts[k+2];
        dist = sqrt(dx*dx + dy*dy + dz*dz);
        dl = dl+dist;
       }
    dl = dl*dl*dl;  
    sqrtnum_pts = sqrt( (double) asinfo->nvx);
    smfac = asinfo->smfac*sqrtnum_pts/dl;*/       


   bsp_curve->order = asinfo->order;
   bsp_curve->num_poles = asinfo->npole;
   bsp_curve->poles = pol_vec;
   bsp_curve->periodic = FALSE;
   if(!strncmp(asinfo->knot_type,UNIFORM_T,strlen(asinfo->knot_type)))
      bsp_curve->non_uniform = FALSE;
   else
      bsp_curve->non_uniform = TRUE;

   bsp_curve->num_knots = asinfo->nknot;
   bsp_curve->rational = FALSE;
   bsp_curve->weights = NULL;
   bsp_curve->planar = TRUE;
   bsp_curve->phy_closed = FALSE;
   bsp_curve->num_boundaries = 0;
   bsp_curve->knots = kno_vec;
   bsp_curve->bdrys = NULL;

   opt_iter = asinfo->opt_iter;
   do {
     TWlsqweccv0(asinfo->nvx,   asinfo->pdim,  polypts,       asinfo->order,
               asinfo->nknot, kno_vec,       asinfo->opt_par, par_vec, 
               asinfo->nfp,   fxp_vxp,       asinfo->nta,     tav_vxp,
               tav_vec,       asinfo->opt_curv0,    asinfo->opt_curv1,
               crv_vec,       asinfo->nfa,     fac_vxp,      fac_val,
               asinfo->opt_end,              asinfo->opt_sm,  
               asinfo->smfac, bsp_curve,         &rc);
     if(rc) {
       *EMmsg = 0;
       goto wrapup;
     }
     if(opt_iter > 0) {
       opt_iter_flag = TRUE;
       strcpy(asinfo->para_type,FREE_T);
       sts = TWpar_eval(&msg_loc,
                        bsp_curve,
                        asinfo->nvx,
                        polypts,
                        par_vec);
     }
     opt_iter -= 1;
   } while(opt_iter > 0);

   if(opt_iter_flag) {
     for(i=0;i<asinfo->npara;i++) {
       OM_BLOCK_MOVE((par_vec + i),parvec_pt,sizeof(IGRdouble));
       parvec_pt = parvec_pt + sizeof(IGRdouble);
     }
   }

   
    curve_id.osnum = const_list->env_info->md_id.osnum;
    const_list->geometry = (IGRchar *) bsp_curve;

    stat_OM = om$construct (classid = OPP_GRbcsubbc_class_id,
                            msg = message GRvg.GRconstruct(const_list),
                            p_objid = &curve_id.objid,
                            osnum = curve_id.osnum);
    EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);


               

 wrapup:
 *mod_new_id = curve_id.objid;
#if dflT1
    printf("from EFascrcr: id = %d \n", *mod_new_id);
#endif

  if(polypts) om$dealloc(ptr = polypts);
  if(tav_vxp) om$dealloc(ptr = tav_vxp);
  if(tav_vec) om$dealloc(ptr = tav_vec);
  if(fxp_vxp) om$dealloc(ptr = fxp_vxp);
  if(fac_vxp) om$dealloc(ptr = fac_vxp);
  if(fac_val) om$dealloc(ptr = fac_val);
  if(kno_vec) om$dealloc(ptr = kno_vec);
  if(par_vec) om$dealloc(ptr = par_vec);
  if(crv_vec) om$dealloc(ptr = crv_vec);
  if(pol_vec) om$dealloc(ptr = pol_vec);
  if(bsp_curve) om$dealloc(ptr = bsp_curve);
  if (!(1&stat_OM&*EMmsg)) *mod_new_id = NULL_OBJID;
  return (stat_OM);
}

end implementation EMSassoc;
