/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation EMSsubbs;

/*
  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#define INCREMENT 10

#include "EMS.h" /* For shared libraries */
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "EMSconstruct.h" /* For EMS_S_INSOLID */
#include "EMSerrordef.h" /* For EMSerror definitions */
#include "maptpspro.h"
#include "bsunwght_p.h"

from EMSsolid import EMpoint_locate;

IGRlong EFreturn_pole_indices(EMmsg,surf_env,surf_GRid,no_poles, poles,
                            indices)
IGRlong *EMmsg;
struct GRmd_env *surf_env;
struct GRid *surf_GRid;
IGRint no_poles;
IGRdouble *poles;
IGRint *indices;
{
 IGRlong status;
 IGRint i;
 IGRpoint pole;
 struct IGRbsp_surface *surf = NULL;
 enum EMSdatatype type;
 IGRchar *geom = NULL;
 IGRlong stat_func;
 IGRdouble *unwpoles = NULL;
 struct IGRpointset pt_set;      /* point set,control pts of surf*/

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 EMgetvggeom(EMmsg, &surf_env->md_env.matrix_type, surf_env->md_env.matrix,
             surf_GRid, &geom, &type);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);
        
 EMerr_hndlr((type != EMSdata_surface), *EMmsg, EMS_E_InvalidArg, wrapup);
 
 surf = (struct IGRbsp_surface *) geom;

 pt_set.num_points = surf->u_num_poles * surf->v_num_poles;
 pt_set.points = surf->poles;

 unwpoles = NULL;
 if (surf->rational)
  {
    unwpoles = (IGRdouble *) om$malloc(size = pt_set.num_points * sizeof
                             (IGRdouble) * 3);
    if (! unwpoles)
     {
       *EMmsg = EMS_E_Fail;
       goto wrapup;
      }
    status = BSunwght_p (EMmsg, surf->poles, surf->weights,
                     &pt_set.num_points, unwpoles);
    pt_set.points = unwpoles;
   }

 for (i=0;i<no_poles;i++)
  {
    stat_func = MAptpsproj(EMmsg,&poles[3*i],&pt_set,pole,(IGRlong *)&indices[i]);
    EMerr_hndlr (! stat_func || EMis_error (*EMmsg), *EMmsg, 
        EMS_E_MAerror,wrapup);
/*
 * The index is subtracted by -1 to give the actual index into the pole array
 * beginning at 0.
 */
    indices[i] -= 1;
  }

wrapup:
 if (surf) om$dealloc (ptr = surf);
 if (unwpoles) om$dealloc(ptr = unwpoles);
 return (status);
}
end implementation EMSsubbs;

