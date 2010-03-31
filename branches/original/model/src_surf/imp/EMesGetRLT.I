/* ###################   APOGEE COMPILED   ################## */
class implementation EMSelpsoid;

/*
HISTORY:

Creation:	When dinosaurs roamed the earth...

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

static IGRdouble EMSrltBuffer[DBL_RLT_BUFFER_SIZE];

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

    This method returns the rule line table for an ellipsoid.

Arguments

    nat_edges - input
        Include natural edges ?

    u_stripes, v_stripes - input
        The number of additional rule lines to add between each
        default rule line.

    in_surf - input
        The geometry of the surface in world coordinates. This
        may be NULL.

    mx, mx_type - input
        The matrix and type from local to world coordinates. If
        the surface geometry is provided, these arguments may be
        NULL.

    in_buffer - input
        Memory provided by the caller for the rule line table.

    buffer_size - input
        The size in bytes of in_buffer.

    rlt - output
        The address of the rule line table.

Notes

    If the rule line table requires more memory than is provided
    by the input buffer, this function will allocate a block of
    memory and partition that block for the rule line table.
    Otherwise it will partition the input buffer.

Bugs

    This method assumes the ellipsoid is strored as a
    half-ellipse rotated 360 degrees.

History

    AIC     17 Apr 89       Support MSC.
    AIC     20 May 88
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
   * Get a standard surface of revolution rule line table with no
   * internal default rule lines in U. (Rule lines are generated
   * at u=0 and u=1 because the rule line table function always
   * does this.)
   */
  uv[0] = 3;
  uv[1] = EMS_OPT_CONIC;
  ems$get_rule_lines(rc =           EMmsg,
                     u_by_v =       uv,
                     bs_attr =      &attr,
                     nat_edges =    nat_edges,
                     in_buffer =    in_buffer,
                     buffer_size =  buffer_size,
                     rlt =          rlt);

  /*
   * The u = 0 and u = 1 rule lines are along degenerate edges,
   * so discard them.
   */
  if(nat_edges)
  {
    (*rlt)->u_rules -= 2;
    (*rlt)->u_rule_values ++;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSelpsoid.EMgetRuleLineTable")
  return (sts);
}

end implementation EMSelpsoid;
