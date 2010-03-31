/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

# include "EMS.h"
/*
 History

    08/19/92        NP      Modified for ANSI compliance, by adding correct
                            typecasts for "ems$get_memory" call.
    04/17/89        RC      Modified such that incoming
                            angle is not modified and also use
                            defined PI instead of 22/7.
    12/04/87        RC      Modified arguments and code
                            such that cross hatching in both 
                            directions is possible.

    28 October 87   AIC     Conversion to EMS version 1.1

    09/2/87         RC      Creation Date
*/

# include "msdef.h"
# include "gocmacros.h"     /*  GRgetabsg macro */
# include "bserr.h"
# include "emsmacros.h"
# include "OMerrordef.h"
# include "bserr.h"
# include "emsdef.h"
# include "gomacros.h"
# include "madef.h"
# include "EMScmacros.h"
# include "EMSommacros.h"

# define CROSS_HATCH_PLANE_BUFFER_SIZE 360

extern OMuword  OPP_EMSchatch_class_id;
extern IGRchar  EMScrossHatchPlaneBuffer[CROSS_HATCH_PLANE_BUFFER_SIZE];

from EMSboundary    import EMget_objid;
from EMSgradata     import EMchangeClass, EMinit;
from EMSchatch      import EMputdef;

method EMcross_hatch(IGRlong *EMmsg; struct GRmd_env *my_env;
                     struct EMSxh_info *in_xh_info;
                     IGRdouble vw_mat[4][4])
{
  struct IGRbsp_surface *srf_geom1, *srf_geom2;
  struct EMSxh_info     xh_info;
  OM_S_CHANSELECT       chan;

  IGRdouble             rot_org[3], rot_axis[3], pn_dot_cp = 0, 
                        u, v, angles[3], hv_vec[3], hw_vec[3], 
                        cross_p[3], uw_vec[3];
  extern  IGRdouble     cos(), sin();

  IGRlong               sts, i;

  BSrc                  rc;

  IGRshort              l = 4, m = 4, n = 1;

  GRobjid               newobjid, frt_id;

  IGRboolean            status;
  extern  IGRboolean    BSnorvec(), BSfreesf(), MA2angvc(),
                        BScrossp(), EFget_xh_sf_geom(), 
                        EFget_xh_rulelines();
  IGRchar               *ptr = NULL;
  extern   void         BSsfarrevn(), BSallocsf();

  /* **************************************************************** */

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  xh_info = *in_xh_info;
  ptr = NULL;
  srf_geom1 = NULL;
  srf_geom2 = NULL;
  
  GRgetabsg(EMmsg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
            &ptr, i);
  if(! (1 & *EMmsg)) goto wrapup;

  srf_geom1 = (struct IGRbsp_surface *) ptr;
 
  u = v = 0.5;
  BSsfarrevn (&rc, srf_geom1, 1, &u, 1, &v, rot_org, rot_axis);
  EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /*
   * Get to matrix to rotate the plane along an axis
   * through uv(0.5,0.5) and normal to the surface.
   */

  hv_vec[0] =  cos(xh_info.angle);
  hv_vec[1] =  sin(xh_info.angle);
  hv_vec[1] = -hv_vec[1];     /* hardware wind y_coord is opposite
                                 to viewport y_coord */
  hv_vec[2] = 0;

  for (i = 0; i < 3; i++)
  {
    hw_vec[i] = vw_mat[i][0] * hv_vec[0] +
                vw_mat[i][1] * hv_vec[1] +
                vw_mat[i][2] * hv_vec[2];
  }

  for (i = 0; i < 3; i++)
   uw_vec[i] = srf_geom1->poles[i+3] - srf_geom1->poles[i];

  status = MAang2vc(EMmsg, uw_vec, hw_vec, angles);
  EMerr_hndlr (!(status || (1 & *EMmsg)), *EMmsg, EMS_E_Fail, wrapup);

  xh_info.angle = angles[0];
  if (xh_info.angle > PI) xh_info.angle = 2 * PI - xh_info.angle;

  status = BScrossp (&rc, uw_vec, hw_vec, cross_p);
  status = BSnorvec (&rc, cross_p);
  
  pn_dot_cp += rot_axis[0] * cross_p[0];
  pn_dot_cp += rot_axis[1] * cross_p[1];
  pn_dot_cp += rot_axis[2] * cross_p[2];

  if(pn_dot_cp < 0.) xh_info.angle = -xh_info.angle;
      
  /*
   * check if the number of cross-hatched lines will be > XHatchMaxRules.
   * or not. If so, return
   * XHatchMaxRules is define as 255 in EMScatch.h
   */
  {
    IGRint  size;

    EMSbs_size(srf_geom1->u_order,
               srf_geom1->v_order,
               srf_geom1->u_num_poles,
               srf_geom1->v_num_poles,
               srf_geom1->rational,
               0,
               (IGRchar *)NULL,
               size)

    /* Added correct typecasts for ANSI. Does macro need "element_size"? */
    ems$get_memory(rc = &rc,
                   num_elements = size,
                   buffer = (IGRchar *)EMScrossHatchPlaneBuffer,
                   buffer_size = (IGRint)CROSS_HATCH_PLANE_BUFFER_SIZE,
                   ptr = (IGRchar **)&srf_geom2);

    EMSbs_partition(srf_geom1->u_order,
                    srf_geom1->v_order,
                    srf_geom1->u_num_poles,
                    srf_geom1->v_num_poles,
                    srf_geom1->rational,
                    0,
                    (IGRchar *)NULL,
                    srf_geom2)
  }

  status = EFget_xh_sf_geom(EMmsg,
                            xh_info.angle,
                            NULL,
                            NULL,
                            srf_geom1,
                            srf_geom2);
  EMerr_hndlr(!(status || (1 & *EMmsg)),*EMmsg,EMS_E_Fail,wrapup);

  status = EFget_xh_rulelines(EMmsg, srf_geom2, &xh_info, 
                              NULL, NULL, NULL);
  EMerr_hndlr (!(status || (1 & *EMmsg)),*EMmsg,EMS_E_Fail,wrapup);

  if (xh_info.num_u_rls > XHatchMaxRules || xh_info.num_v_rls > XHatchMaxRules)
  {
    *EMmsg = EMS_I_OutOfBounds;
    return (OM_S_SUCCESS);
  }

  sts = EMmake_chanselect (EMSrequester_to_helpers, &chan);
  if(! (1 & sts)) goto wrapup;

  *EMmsg = EMS_I_NoResponse;
  sts = om$send(msg = message EMSgradata.EMchangeClass(EMmsg,
                OPP_EMSchatch_class_id, message EMSchatch.EMputdef(EMmsg,
                xh_info),
               &newobjid), p_chanselect = &chan);
  if (sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
  if(! (1 & *EMmsg & sts)) goto wrapup;
                  
  if (*EMmsg IS EMS_I_NoResponse)
  {
    GRobjid     loopset_id = NULL_OBJID;
    GRobjid     loop_id = NULL_OBJID;

    sts = om$construct(classid = OPP_EMSchatch_class_id,p_objid = &frt_id,
                       msg = message EMSchatch.EMputdef(EMmsg,
                        xh_info) );
    if(! (1 & *EMmsg & sts)) goto wrapup;

    sts = EMmake_chanselect (EMSsubbs_to_loopset, &chan);
    if(! (1 & sts)) goto wrapup;

    sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
                  &loopset_id), p_chanselect = &chan);
    if(! (1 & *EMmsg & sts)) goto wrapup;

    if(loopset_id ISNT NULL_OBJID)
    {
      sts = EMmake_chanselect (EMSloopset_to_loops, &chan);
      if(! (1 & sts)) goto wrapup;

      sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg,&loop_id),
                    senderid = loopset_id, p_chanselect = &chan);
      if(! (1 & *EMmsg & sts)) goto wrapup;
    }

    sts = om$send(msg = message EMSgradata.EMinit(EMmsg, my_id, loop_id),
                  targetid = frt_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }
  else *EMmsg = EMS_S_Success;

wrapup:
  EMWRAPUP (*EMmsg, sts, "In EMSplane.EMcross_hatch");
  if (ptr) GRabsg_del(ptr);
  if (srf_geom2 && ((IGRchar *)srf_geom2 ISNT EMScrossHatchPlaneBuffer))
    BSfreesf (&rc, srf_geom2);
  return (sts);
}
        
end implementation EMSplane;
