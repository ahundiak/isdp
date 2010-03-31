/* ###################   APOGEE COMPILED   ################## */
class implementation GRvg;

/*
  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h" /* For BSTOLBASIS */
#include "EMSerrordef.h"
#include "emsdattyp.h" /* For EMSdata_curve3d */
#include "emserr.h" /* For EMerr_hndlr */
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "bsgeom_cvsf.h"
#include "bsprptarrsf.h"
#include "bsnorvec.h"
#include "bsmdstptscv.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"

#define BUFF_SIZE 20

EFproject_pts_onto_element (EMmsg, grid, env, npts, pts,
                            proj_pts,dists,params,vectors,ref_pt)
IGRlong *EMmsg;
struct GRid *grid;
struct GRmd_env *env;
IGRint npts;
IGRdouble *pts;
IGRdouble *proj_pts;
IGRdouble *dists;
IGRdouble *params;
IGRdouble *vectors;
IGRdouble *ref_pt;
{
 IGRlong sts;
 IGRint type;
 IGRchar *geom = NULL;
 IGRdouble params_buff[2*BUFF_SIZE],*params_ptr = NULL;
 IGRpoint  proj_pts_buff[BUFF_SIZE];
 IGRdouble dists_buff[BUFF_SIZE],*proj_pts_ptr = NULL,
                *dists_ptr = NULL;
 IGRint dim;
 IGRboolean all_on_elem = FALSE;
 BSrc  rc;
 IGRboolean direction_determined = FALSE;
 IGRboolean natural_normal = TRUE;
 IGRvector norm,normr;
 IGRdouble basis_tol;
 IGRdouble twice_chrdht_tol;
 IGRint i,j;
 struct IGRbsp_curve *curve = NULL;
 struct IGRbsp_surface *surf = NULL;
 struct BSgeom_bsp_surf geom_surface;
 extern int EMgetvggeom();
 extern void EFinit_geom_surface();

 *EMmsg = EMS_S_Success;
 sts = 1;
 geom_surface.sfgen_cv = NULL;

 BSEXTRACTPAR(&rc,BSTOLBASIS,basis_tol);
 BSEXTRACTPAR(&rc,BSTOLCHRDHT,twice_chrdht_tol);
 twice_chrdht_tol *= 2;

 EMgetvggeom(EMmsg,&env->md_env.matrix_type, env->md_env.matrix,grid,&geom,
             &type);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 EMerr_hndlr(((type != EMSdata_curve3d) && (type != EMSdata_surface)),
             *EMmsg, EMS_E_InvalidArg, wrapup);

 if (proj_pts)
  proj_pts_ptr = proj_pts;

 if (dists)
  dists_ptr = dists;

 if (params)
  params_ptr = params;

 if (npts > BUFF_SIZE)
 {
  if (!proj_pts_ptr)
  proj_pts_ptr = (IGRdouble *) om$malloc (size = sizeof(IGRdouble) * 3 * npts);
  EMerr_hndlr(!proj_pts_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

  if (!dists_ptr)
  dists_ptr = (IGRdouble *) om$malloc (size = sizeof(IGRdouble) * npts);
  EMerr_hndlr(!dists_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

  dim = ((type == EMSdata_curve3d) ? 1 : 2);

  if (!params_ptr)
  params_ptr = (IGRdouble *) om$malloc (size = sizeof(IGRdouble) * dim * npts);
  EMerr_hndlr(!params_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
 }
 else
 {
  if (!proj_pts_ptr)
   proj_pts_ptr = (IGRdouble *)proj_pts_buff;

  if (!dists_ptr)
   dists_ptr = dists_buff;

  if (!params_ptr)
   params_ptr = params_buff;
 }

 if (type == EMSdata_curve3d)
 {
  curve = (struct IGRbsp_curve *) geom;
  BSmdstptscv(npts,(IGRpoint *)pts,curve,params_ptr,(IGRpoint *)proj_pts_ptr,
              dists_ptr,&all_on_elem,&rc);
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
 }
 else
 {
  surf = (struct IGRbsp_surface *) geom;

  EFinit_geom_surface(&rc, surf, grid->objid, grid->osnum, &geom_surface);
  EMerr_hndlr(BSERROR(!(rc & 1)), *EMmsg, EMS_E_Fail, wrapup);

  BSprptarrsf(&geom_surface, twice_chrdht_tol, 2, 0, &npts, pts, params_ptr,
              proj_pts_ptr, &all_on_elem, NULL, &rc);
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

  if (dists)
  {
   for (i = 0; i < npts; i++)
   {
    dists[i] = BSdistptpt(&rc, &pts[i * 3], &proj_pts_ptr[i * 3]);
    EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
   }
  }
 }

/*
 * If vectors need to be output then should the distance of the point to
 * the element be less than basis tolerance then
 * If it is a curve
 *   the vector is initialised to 0,0,0
 * if it is a surface
 *   then depending on whether the reference point is lying along the
 *   natural normal of the surface an appropriate vector is determined.
 */

 if (vectors)
 {
  for (i=0;i<npts;i++)
  {
   if (type == EMSdata_curve3d)
   {
    for (j=0;j<3;j++)
      vectors[3*i+j] = pts[3*i+j] - proj_pts_ptr[3*i+j];
      BSnorvec(&rc,&vectors[3*i]);

    if (rc)
    {
     for (j=0;j<3;j++)
       vectors[3*i+j] = 0.0;
    }
   }
   else 
   {
      if (!direction_determined)
      {
       IGRdouble ref_parms[2],ref_proj_pts[3],ref_dist;
       IGRdouble dotp;
       IGRint    num_pts = 1;

        EFinit_geom_surface(&rc, surf, grid->objid, grid->osnum, &geom_surface);
        EMerr_hndlr(BSERROR(!(rc & 1)), *EMmsg, EMS_E_Fail, wrapup);

        BSprptarrsf(&geom_surface, twice_chrdht_tol, 2, 0, &num_pts, ref_pt,
                    ref_parms, ref_proj_pts, &all_on_elem, NULL, &rc);
        EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

        ref_dist = BSdistptpt(&rc, ref_pt, ref_proj_pts);
        EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

        if (ref_dist > basis_tol)
        {
         EMavgsfnorm(&rc,surf,ref_parms[0],ref_parms[1],ref_proj_pts,norm);
         EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

         for (j=0;j<3;j++)
           normr[j] = ref_pt[j] - ref_proj_pts[j];
         BSnorvec(&rc,normr);

         dotp = normr[0]*norm[0] + normr[1]*norm[1] + normr[2]*norm[2];
         if (dotp > 0)
          natural_normal = TRUE;
         else
          natural_normal = FALSE;
        }
        else
          natural_normal = TRUE;

        direction_determined = TRUE;
      }

      EMavgsfnorm(&rc,surf,params_ptr[2*i],params_ptr[2*i+1],
                  &proj_pts_ptr[3*i],norm);
      EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

      if (!natural_normal)
      {
       for (j=0;j<3;j++)
        norm[j] = -norm[j];
      }

      OM_BLOCK_MOVE(norm,&vectors[3*i],sizeof(IGRpoint));
   }
  }
 }

 
wrapup:
 if (!proj_pts && proj_pts_ptr && (proj_pts_ptr != (IGRdouble *)proj_pts_buff))
  om$dealloc(ptr = proj_pts_ptr);

 if (!dists && dists_ptr && (dists_ptr != dists_buff))
  om$dealloc(ptr = dists_ptr);

 if (!params && params_ptr && (params_ptr != params_buff))
  om$dealloc(ptr = params_ptr);

 if (geom) om$dealloc(ptr = geom);

 if (geom_surface.sfgen_cv)
    BSfreecv(&rc, geom_surface.sfgen_cv);

 return(sts);
}

end implementation GRvg;

