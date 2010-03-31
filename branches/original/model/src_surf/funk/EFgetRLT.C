/* ###################   APOGEE COMPILED   ################## */
# include "EMS.h"
#include "OMminimum.h"
# include "OMerrordef.h"    /* OM error codes   */
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"         /* IGResqbs         */
# include "EMSmsgdef.h"     /* EMS error codes  */
# include "EMSlogic.h"      /* EMSmsgReport     */
# include "EMStypedef.h"    /* EMSmsgReport     */
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "EMSommacros.h"   /* ems$get_memory   */
# include "OMprimitives.h"  /* om$              */
# include "emserr.h"        /* EMWRAPUP         */
# include "gocmacros.h"     /* GRalign          */
#include "bserr.h"
#include "bssfkttol2.h"
#include "bsfindmkts.h"

# define CUSP_BUFFER_SIZE 100
# define PADDING            8

void EFgetRuleLineTable(EMmsg, surf, in_attr, in_buffer, buffer_size, rlt)

IGRlong                 *EMmsg;
struct IGRbsp_surface   *surf;
struct IGResbs          *in_attr;
IGRchar                 *in_buffer;
IGRint                  buffer_size;
struct IGResqbs         **rlt;
/*
History

    07/06/93    Sudha   Modified for BSprototypes ansification
    27 Aug 92   NP      Modified for ANSI compliance.
    13 Apr 88   AIC     Touch up memory management.
    ?? ??? 87   AIC     Creation
*/
{
  IGRlong               rc;
  IGRint                *u_indices;
  IGRint                *v_indices;
  IGRint                num_u_cusps, num_v_cusps,
                        num_u_rules, num_v_rules,
                        max_u_cusps, max_v_cusps,
                        indices_buffer[CUSP_BUFFER_SIZE],
                        unused,
                        num_bytes,
                        i, j, k;
  IGRdouble             incr,
                        knot_tol,
                        *u_cusps, *v_cusps,
                        u_buffer[CUSP_BUFFER_SIZE],
                        v_buffer[CUSP_BUFFER_SIZE];
  struct IGResbs        default_attr, *bs_attr;


  /*
   * Initialize
   */
  if(! in_buffer) buffer_size = 0;
  if(in_attr) bs_attr = in_attr;
  else
  {
    default_attr.u_rules = default_attr.v_rules = 0;
    default_attr.is_surfdis = TRUE;
    default_attr.is_polydis = default_attr.is_slowdis = FALSE;
    bs_attr = &default_attr;
  }
  u_cusps = u_buffer;
  v_cusps = v_buffer;
  u_indices = v_indices = indices_buffer;

  /*
   * Allocate space for the cusp lines (or use the buffers)
   * (Natural edges will be treated as cusp lines)
   */
  max_u_cusps = (IGRint) surf->u_num_poles - surf->u_order + 3;
  max_v_cusps = (IGRint) surf->v_num_poles - surf->v_order + 3;
  ems$get_memory(rc = EMmsg, element_size = sizeof(*u_cusps),
                 num_elements = max_u_cusps, buffer = (IGRchar *)u_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*u_cusps),
                 ptr = (IGRchar **) &u_cusps);
  if(! (1 & *EMmsg)) goto wrapup;
  ems$get_memory(rc = EMmsg, element_size = sizeof(*u_indices),
                 num_elements = max_u_cusps, buffer = (IGRchar *)indices_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*u_indices),
                 ptr = (IGRchar **)&u_indices);
  if(! (1 & *EMmsg)) goto wrapup;
  ems$get_memory(rc = EMmsg, element_size = sizeof(*v_cusps),
                 num_elements = max_v_cusps, buffer = (IGRchar *)v_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*v_cusps),
                 ptr = (IGRchar **)&v_cusps);
  if(! (1 & *EMmsg)) goto wrapup;
  ems$get_memory(rc = EMmsg, element_size = sizeof(*v_indices),
                 num_elements = max_v_cusps, buffer = (IGRchar *)indices_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*v_indices),
                 ptr = (IGRchar **)&v_indices);
  if(! (1 & *EMmsg)) goto wrapup;

  /*
   * Get the knot tolerance
   */
  BSsfkttol2(surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
             surf->u_num_poles, surf->v_num_poles, surf->poles,
             surf->weights, &knot_tol, &rc);
  if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }

  /*
   * Get the cusp lines
   */
  BSfindmkts(&rc, &surf->u_order, &surf->u_num_poles, surf->u_knots,
             &knot_tol, &num_u_cusps, &u_cusps[1], u_indices);
  if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }
  BSfindmkts(&rc, &surf->v_order, &surf->v_num_poles, surf->v_knots,
             &knot_tol, &num_v_cusps, &v_cusps[1], v_indices);
  if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }

  /*
   * Treat the natural edges like cusp lines
   */
  u_cusps[0] = 0.0;
  v_cusps[0] = 0.0;
  u_cusps[num_u_cusps + 1] = 1.0;
  v_cusps[num_v_cusps + 1] = 1.0;
  num_u_cusps += 2;
  num_v_cusps += 2;

  /*
   * Allocate and partition the rule line table
   */
  num_u_rules = num_u_cusps + ((num_u_cusps  - 1) * bs_attr->u_rules);
  num_v_rules = num_v_cusps + ((num_v_cusps  - 1) * bs_attr->v_rules);
  num_bytes = ( (num_u_rules + num_v_rules) *
                (sizeof(IGRdouble) + sizeof(IGRint)) ) +
              sizeof(struct IGResqbs) + PADDING;

  {
    IGRchar *buffer;

    ems$get_memory(rc = EMmsg, num_elements = num_bytes,
                   buffer = in_buffer, buffer_size = buffer_size,
                   ptr = &buffer, clear = TRUE);
    if(! (1 & *EMmsg)) goto wrapup;

    *rlt = (struct IGResqbs *) buffer;
  }

  (*rlt)->u_rule_values = (IGRdouble *) GRalign_double(*rlt + 1);
  (*rlt)->v_rule_values = (*rlt)->u_rule_values + num_u_rules;
  (*rlt)->u_num_bound = (IGRint *) ((*rlt)->v_rule_values + num_v_rules);
  (*rlt)->v_num_bound = (*rlt)->u_num_bound + num_u_rules;

  /*
   * Fill in the rule line table
   */
  (*rlt)->is_polydis = bs_attr->is_polydis;
  (*rlt)->is_surfdis = bs_attr->is_surfdis;
  (*rlt)->is_slowdis = bs_attr->is_slowdis;
  (*rlt)->rules_specified = TRUE;
  (*rlt)->u_rules = num_u_rules;
  (*rlt)->v_rules = num_v_rules;
  (*rlt)->u_rule_values[0] = 0.0;
  (*rlt)->v_rule_values[0] = 0.0;

  for(i = k = 1; i < num_u_cusps; i ++, k ++)
  {
    if(bs_attr->u_rules)
    {
      incr = (u_cusps[i] - u_cusps[i - 1]) / (bs_attr->u_rules + 1);
      for(j = 0; j < bs_attr->u_rules; j ++, k ++)
        (*rlt)->u_rule_values[k] = (*rlt)->u_rule_values[k - 1] + incr;
    }
    (*rlt)->u_rule_values[k] = u_cusps[i];
  }

  for(i = k = 1; i < num_v_cusps; i ++, k ++)
  {
    if(bs_attr->v_rules)
    {
      incr = (v_cusps[i] - v_cusps[i - 1]) / (bs_attr->v_rules + 1);
      for(j = 0; j < bs_attr->v_rules; j ++, k ++)
        (*rlt)->v_rule_values[k] = (*rlt)->v_rule_values[k - 1] + incr;
    }
    (*rlt)->v_rule_values[k] = v_cusps[i];
  }

wrapup:
  if(u_cusps && (u_cusps ISNT u_buffer)) om$dealloc(ptr = u_cusps);
  if(v_cusps && (v_cusps ISNT v_buffer)) om$dealloc(ptr = v_cusps);
  if(u_indices && (u_indices ISNT indices_buffer))
    om$dealloc(ptr = u_indices);
  if(v_indices && (v_indices ISNT indices_buffer))
    om$dealloc(ptr = v_indices);
  return;
}
