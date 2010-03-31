/* ###################   APOGEE COMPILED   ################## */

/*
History:

    AIC     Many moons ago      Creation from EFgetRLT.C
    AIC     10/30/92            Modified to prevent fabs error. (TR119221125)
    Sudha   07/06/93 		Modified for BSprototypes ansification

*/

# include <math.h>          /* sqrt() fabs()            */
# include "bserr.h"         /* BSEXTRACTPAR             */
# include "bsparameters.h"  /* BSEXTRACTPAR             */
# include "OMmacros.h"      /* OM_BLOCK_MOVE            */
# include "OMerrordef.h"    /* OM error codes           */
# include "igrtypedef.h"    /* Standard IGE types       */
# include "igr.h"           /* Standarf IGE structures  */
# include "igrdp.h"         /* IGResqbs                 */
# include "EMSmsgdef.h"     /* EMS error codes          */
# include "EMSlogic.h"      /* EMSmsgReport             */
# include "EMStypedef.h"    /* EMSmsgReport             */
# include "EMScmacros.h"    /* EMSmsgReport             */
# include "EMSommacros.h"   /* ems$get_memory           */
# include "OMprimitives.h"  /* om$                      */
# include "emserr.h"        /* EMWRAPUP                 */
# include "gocmacros.h"     /* GRalign                  */
# include "bstypes.h"       /* BSrc                     */
# include "EMSopt.h"        /* EMS_OPT_*                */
#include "bssfkttol2.h"
#include "bsfndsfcsp.h"
#include "bsfindmkts.h"

/*
 * Buffering definitions
 */
# define CUSP_BUFFER_SIZE       100
# define PADDING                8

/*
 * The number of default rule lines for conics
 */
# define NUM_CONIC_RULE_LINES   5

/*
 * The parameters of the default conic rule lines.
 */
# define _0_DEGREES             0.0
# define _90_DEGREES            (1. - sqrt(3.)) / -3.
# define _180_DEGREES           0.5
# define _270_DEGREES           (4. - sqrt(3.)) / 3.
# define _360_DEGREES           1.0

#ifdef __STDC__
void EFgetRuleLineTable2(IGRlong *EMmsg, struct IGRbsp_surface *surf,
                             IGRint *u_by_v, struct IGResbs *in_attr,
                             IGRboolean nat_edges, IGRchar *in_buffer,
                             IGRint buffer_size, struct IGResqbs **rlt)
#else
void EFgetRuleLineTable2(EMmsg, surf, u_by_v, in_attr, nat_edges,
                         in_buffer, buffer_size, rlt)

IGRlong                 *EMmsg;
struct IGRbsp_surface   *surf;
IGRint                  *u_by_v;
struct IGResbs          *in_attr;
IGRboolean              nat_edges;
IGRchar                 *in_buffer;
IGRint                  buffer_size;
struct IGResqbs         **rlt;

#endif

/*
Abstract

    This function generates a rule line table. The rule lines may
    be equally spaced, specially spaced for conics, placed at
    every knot line of multiplicity order - 1, or at true cusps.

Arguments

    surf - input
        The geometry of the surface. The geometry only needs to
        be supplied when one or both of the options (u_by_v[0]
        and u_by_v[1]) are EMS_OPT_ATKNOTS, EMS_OPT_ATCUSPS, or
        EMS_OPT_ATKNOTS_NOCUSPS.

    u_by_v - input
        An array of two integers indicating the number of default
        rule lines in u and v respectivly. Each value may be a
        positive integer or an option. Positive integers indicate
        the number of default rule lines and that they are equally
        spaced in parametric space. The option EMS_OPT_ATKNOTS
        indicates that the default rule lines are at knotlines of
        multiplicity order - 1. The option EMS_OPT_ATCUSPS indicates
        that the default rule lines are at true cusps lines. The option
        EMS_OPT_ATKNOTS_NOTCUSPS indicates that the default rule lines
        are at the knotlines, except the true cusps. The option
        EMS_OPT_CONIC indicates that the default rule lines are at 0,
        90, 180, 270, and 360 degrees along a conic.

    in_attr - input
        The bspline surface attributes. This is used to fill in the
        the rule lines between each default rule line.

    in_buffer - input
        Memory provided by the caller for the rule line table.

    buffer_size - input
        The size in bytes of in_buffer.

    rlt - output
        The address of the rule line table. See Notes.

Notes

    If the rule line table requires more memory than is provided by the
    input buffer, this function will allocate a block of memory and
    partition that block for the rule line table. Otherwise it will
    partition the input buffer.

History

    NP      05 Oct 92       Put an "ifdef __STDC__" for function definition, 
			    because it was conflicting with the prototype in
			    EMSommacros.h. Also, added some typecasts in the
			    ems$get_memory macros.
    AIC     08 Feb 92       Fix for NOTCUSP in u, CONIC in v.
    AIC     11 Jan 92       Support EMS_OPT_ATKNOTS_NOTCUSP option.
    AIC     01 Jul 88       Support EMS_OPT_ATCUSPS option.
    AIC     20 May 88       Support EMS_OPT_CONIC and EMS_OPT_ATKNOTS
                            options.
    AIC     13 Apr 88       Mix uniform and non-uniform modes.
    AIC     23 Mar 88       Creation Date.
*/
{
  BSrc                  rc;
  IGRint                num_u_cusps = 0, num_v_cusps = 0,
                        num_u_uncusps = 0, num_v_uncusps = 0,
                        num_u_rules, num_v_rules,
                        dummy_size,
                        num_bytes,
                        i, j, k,
                        *dummy,
                        dummy_buffer[CUSP_BUFFER_SIZE],
                        u_by_v_buffer[2];
  IGRdouble             incr,
                        knot_tol,
                        *u_cusps = NULL, *v_cusps = NULL,
                        *u_uncusps = NULL, *v_uncusps = NULL,
                        u_buffer[CUSP_BUFFER_SIZE],
                        v_buffer[CUSP_BUFFER_SIZE],
                        u_uncusp_buffer[CUSP_BUFFER_SIZE],
                        v_uncusp_buffer[CUSP_BUFFER_SIZE];
  struct IGResbs        default_attr, *bs_attr;

extern void EFknotVector() ;

  /*
   * Initialize
   */
  if(! in_buffer) buffer_size = 0;
  if(in_attr) bs_attr = in_attr;
  else /* Internal rule lines not specified. */
  {
    /*
     * Use 0 internal rule lines.
     */
    default_attr.u_rules = default_attr.v_rules = 0;
    default_attr.is_surfdis = TRUE;
    default_attr.is_polydis = default_attr.is_slowdis = FALSE;
    bs_attr = &default_attr;
  }
  if(! u_by_v)
  {
    /*
     * Rule line spacing not specified. Default is at knotlines
     * with multiplicity of order - 1.
     */
    u_by_v = u_by_v_buffer;
    u_by_v[0] = u_by_v[1] = EMS_OPT_ATKNOTS;
  }
  u_cusps = u_buffer;
  v_cusps = v_buffer;
  dummy = dummy_buffer;

  /*
   * Determine amount of space required to store the rule lines.
   * (Natural edges will be treated as cusp lines.) If u_by_v[0]
   * or u_by_v[1] is EMS_OPT_ATCUSPS, then BSfndsfcsp will be
   * called, so there must be enough memory for that result in
   * both parametric directions, even if they are not bith used.
   */
  switch(u_by_v[0])
  {
    case EMS_OPT_ATCUSPS:
      /*
       * This defines the minimum size needed for the call to
       * BSfndsfcsp for the v cusps. Fall through to define the
       * actual size required for the u cusps.
       */
      num_v_cusps = surf->v_num_poles - surf->v_order + 3;

    case EMS_OPT_ATKNOTS:
    case EMS_OPT_ATKNOTS_NOTCUSPS:
      num_u_cusps = surf->u_num_poles - surf->u_order + 3;
      break;

    case EMS_OPT_CONIC:
      num_u_cusps = NUM_CONIC_RULE_LINES;
      break;

    default:
      if(u_by_v[0] < 0) { *EMmsg = EMS_E_InvalidArg; goto wrapup; }
      num_u_cusps = u_by_v[0];
      break;
  }

  switch(u_by_v[1])
  {
    IGRint  minimum_u_cusps;

    case EMS_OPT_ATCUSPS:
    case EMS_OPT_ATKNOTS_NOTCUSPS:
      /*
       * If the size defined for the u cusps is not enough for
       * the call to BSfndsfcsp, then adjust it accordingly.
       * Fall through to define the number of v cusps.
       */
      minimum_u_cusps = surf->u_num_poles - surf->v_num_poles + 3;
      if(num_u_cusps < minimum_u_cusps) num_u_cusps = minimum_u_cusps;

    case EMS_OPT_ATKNOTS:
      num_v_cusps = surf->v_num_poles - surf->v_order + 3;
      break;

    case EMS_OPT_CONIC:
      if(num_v_cusps < NUM_CONIC_RULE_LINES)
        num_v_cusps = NUM_CONIC_RULE_LINES;
      break;

    default:
      if(u_by_v[1] < 0) { *EMmsg = EMS_E_InvalidArg; goto wrapup; }
      if(num_v_cusps < u_by_v[1]) num_v_cusps = u_by_v[1];
      break;
  }

  /*
   * Allocate space for the cusp lines (or use the buffers)
   */
  ems$get_memory(rc = EMmsg, element_size = sizeof(*u_cusps),
                 num_elements = num_u_cusps, buffer = (IGRchar *)u_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*u_cusps),
                 ptr = (IGRchar **)&u_cusps);
  if(! (1 & *EMmsg)) goto wrapup;
  ems$get_memory(rc = EMmsg, element_size = sizeof(*v_cusps),
                 num_elements = num_v_cusps, buffer = (IGRchar *)v_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*v_cusps),
                 ptr = (IGRchar **)&v_cusps);
  if(! (1 & *EMmsg)) goto wrapup;
  if(num_u_cusps > num_v_cusps) dummy_size = num_u_cusps;
  else dummy_size = num_v_cusps;
  ems$get_memory(rc = EMmsg, element_size = sizeof(*dummy),
                 num_elements = dummy_size, buffer = (IGRchar *)dummy_buffer,
                 buffer_size = CUSP_BUFFER_SIZE * sizeof(*dummy),
                 ptr = (IGRchar **)&dummy);
  if(! (1 & *EMmsg)) goto wrapup;

  if((u_by_v[0] == EMS_OPT_ATKNOTS_NOTCUSPS) ||
     (u_by_v[1] == EMS_OPT_ATKNOTS_NOTCUSPS))
  {
    ems$get_memory(rc = EMmsg, element_size = sizeof(*u_uncusps),
                   num_elements = num_u_cusps, 
		   buffer = (IGRchar *)u_uncusp_buffer,
                   buffer_size = CUSP_BUFFER_SIZE * sizeof(*u_uncusps),
                   ptr = (IGRchar **)&u_uncusps);
    if(! (1 & *EMmsg)) goto wrapup;
    ems$get_memory(rc = EMmsg, element_size = sizeof(*v_uncusps),
                   num_elements = num_v_cusps, 
		   buffer = (IGRchar *)v_uncusp_buffer,
                   buffer_size = CUSP_BUFFER_SIZE * sizeof(*v_uncusps),
                   ptr = (IGRchar **)&v_uncusps);
    if(! (1 & *EMmsg)) goto wrapup;
  }

  if((u_by_v[0] == EMS_OPT_ATKNOTS) || (u_by_v[1] == EMS_OPT_ATKNOTS) ||
     (u_by_v[0] == EMS_OPT_ATKNOTS_NOTCUSPS) ||
     (u_by_v[1] == EMS_OPT_ATKNOTS_NOTCUSPS))
  {
    BSsfkttol2(surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
               surf->u_num_poles, surf->v_num_poles, surf->poles,
               surf->weights, &knot_tol, &rc);
    if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }
  }

  if((u_by_v[0] == EMS_OPT_ATCUSPS) || (u_by_v[1] == EMS_OPT_ATCUSPS) ||
     (u_by_v[0] == EMS_OPT_ATKNOTS_NOTCUSPS) ||
     (u_by_v[1] == EMS_OPT_ATKNOTS_NOTCUSPS))
  {
    double  *p_u_cusps, *p_v_cusps;
    int     *p_num_u_cusps, *p_num_v_cusps;

    if(u_by_v[0] == EMS_OPT_ATKNOTS_NOTCUSPS)
    {
      p_u_cusps = u_uncusps;
      p_num_u_cusps = &num_u_uncusps;
    }
    else
    {
      p_u_cusps = &u_cusps[1];
      p_num_u_cusps = &num_u_cusps;
    }

    if(u_by_v[1] == EMS_OPT_ATKNOTS_NOTCUSPS)
    {
      p_v_cusps = v_uncusps;
      p_num_v_cusps = &num_v_uncusps;
    }
    else
    {
      p_v_cusps = &v_cusps[1];
      p_num_v_cusps = &num_v_cusps;
    }

    BSfndsfcsp(surf, p_num_u_cusps, p_u_cusps, p_num_v_cusps, p_v_cusps, &rc);
    if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }
  }

  /*
   * Get the default rule line values.
   */
  switch(u_by_v[0])
  {
    case EMS_OPT_ATKNOTS_NOTCUSPS:
    case EMS_OPT_ATKNOTS:
      /*
       * Get the cusp lines. For the ATCUSPS case, the work has
       * been done.
       */
      BSfindmkts(&rc, &surf->u_order, &surf->u_num_poles, surf->u_knots,
                 &knot_tol, &num_u_cusps, &u_cusps[1], dummy);
      if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }

      if(u_by_v[0] == EMS_OPT_ATKNOTS_NOTCUSPS)
      {
        int     i, j;
        double  distol;

        BSEXTRACTPAR(&rc, BSTOLLENVEC, distol);

        for(j = 0, i = 1; (i <= num_u_cusps) && (j < num_u_uncusps); i ++)
        {
          if(fabs(u_cusps[i] - u_uncusps[j]) < distol)
          {
            if(i != num_u_cusps)
            {
              OM_BLOCK_MOVE(&u_cusps[i + 1], &u_cusps[i],
                          (num_u_cusps - i) * sizeof(*u_cusps));
            }
            j ++;
            num_u_cusps --;
            i --;
          }
        }
#if DEBUG
        if(j != num_u_uncusps)
          fprintf(stderr, "j = %d, num_u_uncusps = %d\n", j, num_u_uncusps);
#endif
      }

    case EMS_OPT_ATCUSPS:
      /*
       * Add the natural edges.
       */
      u_cusps[0] = 0.0;
      u_cusps[num_u_cusps + 1] = 1.0;
      num_u_cusps += 2;
      break;

    case EMS_OPT_CONIC:
      /*
       * Get the paramaters of a conic at 0, 90, 180, 270, and 360
       * degrees.
       */
      u_cusps[0] = _0_DEGREES;
      u_cusps[1] = _90_DEGREES;
      u_cusps[2] = _180_DEGREES;
      u_cusps[3] = _270_DEGREES;
      u_cusps[4] = _360_DEGREES;
      break;

    default:
      /*
       * Space the rule lines equally.
       */
      EFknotVector(1, num_u_cusps - 1, u_cusps);
      break;
  }

  switch(u_by_v[1])
  {
    case EMS_OPT_ATKNOTS_NOTCUSPS:
    case EMS_OPT_ATKNOTS:
      /*
       * Get the cusp lines. For the ATCUSPS case, the work has
       * been done.
       */
      BSfindmkts(&rc, &surf->v_order, &surf->v_num_poles, surf->v_knots,
                 &knot_tol, &num_v_cusps, &v_cusps[1], dummy);
      if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }

      if(u_by_v[1] == EMS_OPT_ATKNOTS_NOTCUSPS)
      {
        int     i, j;
        double  distol;

        BSEXTRACTPAR(&rc, BSTOLLENVEC, distol);

        for(j = 0, i = 1; (i <= num_v_cusps) && (j < num_v_uncusps); i ++)
        {
          if(fabs(v_cusps[i] - v_uncusps[j]) < distol)
          {
            if(num_v_cusps != i)
            {
              OM_BLOCK_MOVE(&v_cusps[i + 1], &v_cusps[i],
                          (num_v_cusps - i) * sizeof(*v_cusps));
            }
            j ++;
            num_v_cusps --;
            i --;
          }
        }
#if DEBUG
        if(j != num_v_uncusps)
          fprintf(stderr, "j = %d, num_v_uncusps = %d\n", j, num_v_uncusps);
#endif
      }

    case EMS_OPT_ATCUSPS:
      /*
       * Add the natural edges.
       */
      v_cusps[0] = 0.0;
      v_cusps[num_v_cusps + 1] = 1.0;
      num_v_cusps += 2;
      break;

    case EMS_OPT_CONIC:
      /*
       * Get the paramaters of a conic at 0, 90, 180, 270, and 360
       * degrees.
       */
      num_v_cusps = 5;
      v_cusps[0] = _0_DEGREES;
      v_cusps[1] = _90_DEGREES;
      v_cusps[2] = _180_DEGREES;
      v_cusps[3] = _270_DEGREES;
      v_cusps[4] = _360_DEGREES;
      break;

    default:
      /*
       * Space the rule lines equally.
       */
      EFknotVector(1, num_v_cusps - 1, v_cusps);
      break;
  }

  /*
   * Allocate the rule line table.
   */
  {
    IGRchar *buffer;

    num_u_rules = num_u_cusps + ((num_u_cusps  - 1) * bs_attr->u_rules);
    num_v_rules = num_v_cusps + ((num_v_cusps  - 1) * bs_attr->v_rules);
    num_bytes = ( (num_u_rules + num_v_rules) *
                  (sizeof(IGRdouble) + sizeof(IGRint)) ) +
                sizeof(struct IGResqbs) + PADDING;


    ems$get_memory(rc = EMmsg, num_elements = num_bytes,
                   buffer = in_buffer, buffer_size = buffer_size,
                   ptr = &buffer, clear = TRUE);
    if(! (1 & *EMmsg)) goto wrapup;

    *rlt = (struct IGResqbs *) buffer;
  }

  /*
   * Partition the rule line table.
   */
  (*rlt)->u_rule_values = (IGRdouble *) (GRalign_double(*rlt + 1));
  (*rlt)->v_rule_values = (IGRdouble *) ((*rlt)->u_rule_values + num_u_rules);
  (*rlt)->u_num_bound = (IGRint *) ((*rlt)->v_rule_values + num_v_rules);
  (*rlt)->v_num_bound = (IGRint *) ((*rlt)->u_num_bound + num_u_rules);

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

  /*
   * Insert the internal rule lines as specified in the class
   * attributes.
   */
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

  if(! nat_edges)
  {
    (*rlt)->u_rules -= 2;
    (*rlt)->u_rule_values ++;
    (*rlt)->v_rules -= 2;
    (*rlt)->v_rule_values ++;
  }

wrapup:
  if(u_cusps && (u_cusps != u_buffer)) om$dealloc(ptr = u_cusps);
  if(v_cusps && (v_cusps != v_buffer)) om$dealloc(ptr = v_cusps);
  if(u_uncusps && (u_uncusps != u_uncusp_buffer)) om$dealloc(ptr = u_uncusps);
  if(v_uncusps && (v_uncusps != v_uncusp_buffer)) om$dealloc(ptr = v_uncusps);
  if(dummy && (dummy != dummy_buffer)) om$dealloc(ptr = dummy);
  return;
}
