/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

# include "EMS.h"
# include "OMmacros.h"
 
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMSGD_UPTODATE   */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

# ifndef EMSommacros_include
# include "EMSommacros.h"
# endif

extern IGRchar EMScrossHatchPlaneBuffer[CROSS_HATCH_PLANE_BUFFER_SIZE];

/*
History

    msm     03 Oct 92   ANSI-C conversion.
    AIC     17 Apr 89   Remove unnecessary import of EMgetRuleLineTable.
                        Always calculate rule lines.
    AIC     28 Apr 88   Change EMFRT_UPTODATE to EMGD_UPTODATE.
    RC      12 Apr 87   Modified for cross-hatching in both
                        directions
    AIC            87   Genesis
*/

method EMupdate(IGRlong *EMmsg;
                IGRshort *mx_type; IGRmatrix mx;
                struct IGResqbs **rlt;
                struct IGResbs *bs_attr;
                struct IGRbsp_surface *plane;
                IGRchar *buffer; IGRint buffer_size;
                struct EMSpartolbasis *partol)
{
  struct EMSxh_info         xh_info;
  IGRlong                   sts;
  struct IGRbsp_surface     *xh_plane;

  /*
   * Initialize
   */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(! (me^^EMShelper.props & EMGD_UPTODATE))
  {
    /*
     * Update myself
     */
      IGRboolean EFget_xh_rulelines(), EFget_xh_sf_geom();
      IGRint  total_bytes;

      /*
       * Get the unclipped cross hatch rule line table
       */
      EMSbs_size(plane->u_order, plane->v_order, plane->u_num_poles,
                 plane->v_num_poles, plane->rational, 0, (IGRlong *)NULL,
                 total_bytes)

      ems$get_memory(rc = EMmsg, num_elements = total_bytes,
                     buffer = EMScrossHatchPlaneBuffer,
                     buffer_size = CROSS_HATCH_PLANE_BUFFER_SIZE,
                     ptr = (IGRchar **)&xh_plane);
      if(! (1 & *EMmsg)) goto wrapup;
      EMSmsgReport(*EMmsg, "Get cross hatch plane memory",
                   *EMmsg IS EMS_I_DynamicMemoryAllocated);

      EMSbs_partition(plane->u_order, plane->v_order, plane->u_num_poles,
                      plane->v_num_poles, plane->rational, 0,
                      (IGRlong *)NULL, xh_plane)

      EFget_xh_sf_geom(EMmsg, me->angle, NULL, NULL, plane, xh_plane);

      xh_info.angle = me->angle;
      OM_BLOCK_MOVE (me->origin, xh_info.origin, sizeof(IGRpoint));
      xh_info.num_u_sgrps = me->num_u_sgrps;
      xh_info.num_v_sgrps = me->num_v_sgrps;
      xh_info.u_sgrp_info = me->num_u_sgrps ? me->sgrp_info : NULL;
      xh_info.v_sgrp_info = me->num_v_sgrps ? 
                              &me->sgrp_info[me->num_u_sgrps] : NULL;

      if((*rlt) && (((IGRchar*)*rlt ISNT buffer) || (buffer IS NULL)))
      {
        om$dealloc(ptr = *rlt);
        *rlt = NULL;
      }

      EFget_xh_rulelines(EMmsg, xh_plane, &xh_info, rlt, buffer, 
                         buffer_size );
      if(! (1 & *EMmsg)) goto wrapup;

    /*
     * Clip me according to the rule line table
     */
    sts = om$send(msg = message EMSgradata.EMclip(EMmsg, *rlt, partol,
                  mx_type, mx, plane), targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }

wrapup:
  EMSmsgReport(sts, "EMSchatch.EMupdate", FALSE);
  if EMSmsgReport(*EMmsg, "EMSchatch.EMupdate", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSchatch;
