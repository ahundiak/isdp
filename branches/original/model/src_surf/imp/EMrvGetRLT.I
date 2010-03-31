/* ###################   APOGEE COMPILED   ################## */
class implementation EMSrevol;

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

    This method returns the rule line table for a general surface of
    revolution.

Arguments

    nat_edges - input
        Include natural edges?

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

Bugs

    This method is only valid if the u paramater iso-curves are
    the revolved curve.

History

    NP      21 Aug 92       The "mx_type" argument is declared as "IGRint *" 
                            while the GRgetabsg macro needs a "IGRshort *", 
                            which was causing mismatch problems during ANSI 
                            compilation. Correctly typecast.
    AIC     11 Jan 92       Support cusps.
    AIC     17 Apr 89       New argument.
    AIC     20 May 88       Use EMS_OPT_CONIC option in v.
    AIC     13 Apr 88       Get the u cusp lines.
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
   * If the geometry is not passed in, then get my geometry.
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
   * If the surface is physically closed in v, process special.
   * Otherwise invoke EMSsubbs.EMgetRuleLineTable.
   */
  if(surf->v_phy_closed)
  {
    /*
     * Get the number of rule lines between each cusp
     */
    sts = om$send(msg = message EMSsubbs.GRgetattr(
                    EMmsg,
                    (IGRchar *) &attr),
                  targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
    if(u_stripes) attr.u_rules = *u_stripes;
    if(v_stripes) attr.v_rules = *v_stripes;

    /*
     * Get the rule line table with standard rule lines at the
     * knotines in u and at 90 degrees in v.
     */
    uv[0] = EMS_OPT_ATKNOTS_NOTCUSPS;
    uv[1] = EMS_OPT_CONIC;
    ems$get_rule_lines(rc =             EMmsg,
                       nat_edges =      nat_edges,
                       surf =           surf,
                       u_by_v =         uv,
                       bs_attr =        &attr,
                       in_buffer =      in_buffer,
                       buffer_size =    buffer_size,
                       rlt =            rlt);
  }
  else /* not closed in V */
  {
    /*
     * Use EMSsubbs.EMgetRuleLineTable
     */
    sts = om$send(msg=message EMSsubbs.EMgetRuleLineTable(
                    EMmsg,
                    nat_edges,
                    u_stripes,
                    v_stripes,
                    surf,
                    mx_type,
                    mx,
                    in_buffer,
                    buffer_size,
                    rlt),
                  mode = OM_e_wrt_message, targetid = my_id);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSrevol.EMgetRuleLineTable")
  return (sts);
}

end implementation EMSrevol;
