/* ###################   APOGEE COMPILED   ################## */
class implementation EMSelpcone;

/*
 HISTORY:

Creation:  ??	During the neolithic period.

08/18/92:  NP 	The "mx_type" argument is declared as "IGRint *" while the
		GRgetabsg macro needs a "IGRshort *", which was causing mismatch
		problems during ANSI compilation. Correctly typecast.

*/

# include "EMS.h"
# include "msdef.h"
# include "igrtypedef.h"    /* GRgetabsg            */
# include "OMminimum.h"     /* GRgetabsg            */
# include "gocmacros.h"     /* GRgetabsg            */
# include "EMSfrtdef.h"     /* RLT_BUFFER_SIZE      */
# include "EMSommacros.h"   /* ems$get_rule_lines   */
# include "EMSopt.h"        /* EMS_OPT_CONIC        */

method EMgetRuleLineTable(IGRlong               *EMmsg;
                          IGRboolean            nat_edges;
                          IGRint                *u_stripes,
                                                *v_stripes;
                          struct IGRbsp_surface *in_surf;
                          IGRint                *mx_type;
                          IGRmatrix             mx;
                          IGRchar               *in_buffer;
                          IGRint                buffer_size;
                          struct IGResqbs       **rlt)
/*
Abstract

    This method returns the rule line table for an elliptical cone.

Arguments

    u_stripes, v_stripes - input
        The number of additional rule lines to add between each default
        rule line.

    in_surf - input
        The geometry of the surface in world coordinates. This may be
        NULL.

    mx, mx_type - input
        The matrix and type from local to world coordinates. If the
        surface geometry is provided, these arguments may be NULL.

    in_buffer - input
        Memory provided by the caller for the rule line table.

    buffer_size - input
        The size in bytes of in_buffer.

    rlt - output
        The address of the rule line table.

Notes

    If the rule line table requires more memory than is provided by the
    input buffer, this function will allocate a block of memory and
    partition that block for the rule line table. Otherwise it will
    partition the input buffer.

    The rule line table generated for an elliptical cone is valid
    for cylinders, cones, and elliptical cylinders.

History

    AIC     20 May 88       Use EMS_OPT_CONIC option to generate
                            the default rule lines along the
                            ellipse.
    AIC     23 Mar 88       Creation Date
*/
{
  IGRlong               sts;
  IGRint                uv[2];
  struct IGRbsp_surface *surf;
  struct IGResbs        attr;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * Get my geometry
   */
  if(in_surf) surf = in_surf;
  else
  {
    IGRchar *buffer;

    GRgetabsg(EMmsg, (IGRshort *)mx_type, mx, &buffer, unused);
    if(! (1 & *EMmsg)) goto wrapup;
    surf = (struct IGRbsp_surface *) buffer;
  }

  /*
   * Get the number of rule lines between each cusp
   */
  sts = om$send(msg = message EMSsubbs.GRgetattr(EMmsg,(IGRchar *) &attr),
                targetid = my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;
  if(u_stripes) attr.u_rules = *u_stripes;
  if(v_stripes) attr.v_rules = *v_stripes;

  /*
   * Use the conic default rule lines along the ellipse and the
   * paramaters 0 and 1 along the sweep.
   */
  if(surf->u_order IS 2) { uv[0] = 2; uv[1] = EMS_OPT_CONIC; }
  else { uv[0] = EMS_OPT_CONIC; uv[1] = 2; }
  ems$get_rule_lines(rc = EMmsg,
                     u_by_v =       uv,
                     bs_attr =      &attr,
                     nat_edges =    nat_edges,
                     in_buffer =    in_buffer,
                     buffer_size =  buffer_size,
                     rlt =          rlt);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSelpcone.EMgetRuleLineTable")
  return (sts);
}

end implementation EMSelpcone;
