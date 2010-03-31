#include "EMS.h"
# include "OMprimitives.h"      /* om$()alloc       */
# include "OMmacros.h"          /* OM_BLOCK_MOVE    */
# include "OMminimum.h"         /* GRlc...          */
# include "OMlimits.h"          /* GRlc...          */
# include "igetypedef.h"        /* GRlc...          */
# include "igrtypedef.h"        /* IGR...           */
# include "igr.h"               /* IGR...           */
# include "gr.h"                /* GRlc...          */
# include "igrdp.h"             /* IGResqbs         */
# include "dp.h"                /* GRlc...          */
# include "madef.h"             /* GRlc...          */
# include "godef.h"             /* GRlc...          */
# include "go.h"                /* GRlc...          */
# include "ex.h"                /* GRlc...          */
# include "griodef.h"           /* GRlc...          */
# include "grio.h"              /* GRlc...          */
# include "lcdef.h"             /* GRlc...          */
# include "lc.h"                /* GRlc...          */
# include "msdef.h"             /* MSSUCC           */
# include "EMSmsgdef.h"         /* EMS error codes  */
# include "EMSlogic.h"          /* EMSmsgReport     */
# include "EMStypedef.h"        /* EMSmsgReport     */
# include "EMScmacros.h"        /* EMSmsgReport     */
# include "EMSlcdef.h"          /* relation codes   */
# include "bstypes.h"           /* BSrc             */
# include "bserr.h"             /* BS...            */
# include "grgsdef.h"           /* GO_...           */
#include "bscnstprpol.h"
#include "bsactivsplt.h"

# define BUFFER_SIZE    300

void EFlocateRLT(EMmsg, rlt, surface, loc_parms, cvl, prism_rel,
                 inside, outside, overlap, was_located)

IGRlong                 *EMmsg;
struct IGResqbs         *rlt;
struct IGRbsp_surface   *surface;
struct GRlc_info        *loc_parms;
struct GRlc_cvl         *cvl;
IGRlong                 *prism_rel;
IGRboolean              *inside;
IGRboolean              *outside;
IGRboolean              *overlap;
IGRboolean              *was_located;
/*
Abstract

    This function performs locate on a rule line table.

Arguments

    rlt - input
        The rule line table.

    surface - input
        The surface geometry in world coordinates.

    loc_parms - input/output
        The locate paramaters.

    cvl - input
        More locate paramaters.

    prism_rel - input
        The desired prism relation in the event of a prism locate.

    inside - ouput
        True for prism locate when the rule line table is at least
        partially inside the prism.

    outside - output
        True for prism locate when the rule line table is at least
        partially outside the prism.

    overlap - output
        True for prism locate when the rule line table overlaps
        the prism.

    was_located - output
        True if the rule line table satisfies the locate criteria.

Algorithm

    Perform the locate of each rule line until the locate criteria is
    satisfied or the rule lines have all been processed.

Return Status

    EMS_S_Success           - A fatal error did not occur.
    EMS_E_NoDynamicMemeory  - There was not enough dynamic memeory.

History

    Sudha   25-Jun-93   Modified for BSprototype ansification
    AIC     06-Apr-88   Fixed for prism locate when there are no clip
                        points.
    AIC     23-Mar-88   Optimized.
    AIC     ??-???-87   Creation Date.
*/
{
  IGRboolean            test_planar = FALSE;
  BSrc                  rc;
  IGRint                i=0, j, k;
  IGRint                sizeof_double;
  IGRint                iso_buffer_size;
  IGRint                part_buffer_size;
  IGRint                num_rules;
  IGRint                *num_clip_pairs;
  IGRdouble             **clip_points;
  IGRdouble             *knots;
  IGRdouble             *rule_values;
  IGRdouble             *iso_buffer;
  IGRdouble             *part_buffer;
  IGRdouble             intersection_param=0;/* fix for umr */
  IGRdouble             static_iso_buffer[BUFFER_SIZE];
  IGRdouble             static_part_buffer[BUFFER_SIZE];
  struct IGRbsp_curve   iso_curve;
  struct IGRbsp_curve   part_curve;

  void EFisoCurveLocate();
  void EFinterpretRelation();

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  iso_buffer = static_iso_buffer;
  part_buffer = static_part_buffer;
  iso_buffer_size = part_buffer_size = BUFFER_SIZE;
  sizeof_double = sizeof(IGRdouble);

  if(*was_located) goto wrapup;

  /*
   * Set up to do U (using v-definition of the surface)
   */
  num_rules = rlt->u_rules;
  rule_values = rlt->u_rule_values;
  num_clip_pairs = rlt->u_num_bound;
  clip_points = rlt->u_bdrys;

  knots = surface->v_knots;
  iso_curve.order = surface->v_order;
  iso_curve.periodic = surface->v_periodic;
  iso_curve.non_uniform = surface->v_non_uniform;
  iso_curve.num_poles = surface->v_num_poles;
  iso_curve.num_knots = surface->v_num_knots;
  iso_curve.rational = surface->rational;
  if(! surface->rational) iso_curve.weights = NULL;
  iso_curve.planar = surface->planar;
  iso_curve.phy_closed = surface->v_phy_closed;
  iso_curve.num_boundaries = 0;
  iso_curve.bdrys = NULL;

  for(k = U; ((k <= V) && (! *was_located)); k ++)
  {
    IGRboolean  boundaries;
    IGRint      num_doubles, pole_dimension;

    /*
     * Set up memory for the iso curve
     */
    if(iso_curve.rational) pole_dimension = 4;
    else pole_dimension = 3;
    num_doubles = iso_curve.num_poles * pole_dimension;
    num_doubles += iso_curve.num_knots;

    if(num_doubles > iso_buffer_size)
    {
      iso_buffer = (IGRdouble *)
        om$malloc(size = num_doubles * sizeof_double);
      if(! iso_buffer) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
      iso_buffer_size = num_doubles;
    }

    iso_curve.poles = iso_buffer;
    iso_curve.knots = iso_curve.poles + (iso_curve.num_poles * 3);
    if(iso_curve.rational)
      iso_curve.weights = iso_curve.knots + iso_curve.num_knots;

    /*
     * Get the knots for the iso curve
     */
    OM_BLOCK_MOVE(knots, iso_curve.knots,
                  iso_curve.num_knots * sizeof_double);

    /*
     * Determine whether the partial curve will be used
     */
    boundaries = FALSE;
    for(i = 0; i < num_rules; i ++)
    {
      if(num_clip_pairs[i])
      {
        boundaries = TRUE;
        break;
      }
    }

    if(boundaries)
    {
      /*
       * Set up the memory for the partial curve
       */
      if(num_doubles > part_buffer_size)
      {
        part_buffer = (IGRdouble *)
          om$malloc(size = num_doubles * sizeof_double);
        if(! part_buffer) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
        part_buffer_size = num_doubles;
      }

      part_curve.poles = part_buffer;
      part_curve.knots = part_curve.poles + (iso_curve.num_poles * 3);
      if(iso_curve.rational)
        part_curve.weights = part_curve.knots + iso_curve.num_knots;
    }

    for(i = 0; ((i < num_rules) && (! *was_located)); i ++)
    {
      IGRboolean    test_iso_curve;
      IGRshort      BScnstprpol_option;
      IGRshort      relation;

      /*
       * Get the poles for the isoparametric curve
       */
      BScnstprpol_option = k + 1;
      BScnstprpol(surface, BScnstprpol_option, rule_values[i],
                  iso_curve.poles, iso_curve.weights, &rc);
      if(rc ISNT BSSUCC) continue;

      if(! num_clip_pairs[i]) test_iso_curve = TRUE;
      else
        test_iso_curve = cvl->attributes.type IS GR_bl_loc ? TRUE : FALSE;

      if(test_iso_curve)
      {
        /*
         * Use the iso curve
         */
        EFisoCurveLocate(EMmsg, &iso_curve, cvl, loc_parms, TRUE,
                         &intersection_param, &relation);
        if(! (1 & *EMmsg)) continue;

        EFinterpretRelation(EMmsg,relation, cvl->attributes.type,
                            num_clip_pairs[i], num_clip_pairs[i] ? 
			    clip_points[i] : NULL,
                            intersection_param, prism_rel, inside,
                            outside, overlap, was_located);
        if(! (1 & *EMmsg)) continue;
      }

      if((! test_iso_curve) ||
         ((cvl->attributes.type IS GR_bl_loc) &&
          (relation IS HIT) && (*was_located ISNT HIT)))
      {
        IGRint      num_internal_curves;
        IGRdouble   *cv_params;

        /*
         * Use the partial curve(s)
         */
        if(clip_points[i][0] ISNT 0.0)
        {
          IGRdouble zero = 0.0;

          /*
           * Do the section beginning at 0.0
           */
          (void)BSactivsplt(&rc, &iso_curve, &zero, clip_points[i],
                            &part_curve, &test_planar);
          if(rc ISNT BSSUCC) continue;

          EFisoCurveLocate(EMmsg, &part_curve, cvl, loc_parms, TRUE,
                           &intersection_param, &relation);
          if(! (1 & *EMmsg)) continue;

          EFinterpretRelation(EMmsg, relation, cvl->attributes.type, 0,
                              NULL, intersection_param, prism_rel, inside,
                              outside, overlap, was_located);
          if(! (1 & *EMmsg)) continue;
        }

        if((clip_points[i][num_clip_pairs[i] * 2 - 1] ISNT 1.0) &&
           (! *was_located))
        {
          IGRdouble one = 1.0;

          /*
           * Do the section ending at 1.0
           */
          (void)BSactivsplt(&rc, &iso_curve,
                            &clip_points[i][num_clip_pairs[i] * 2 - 1],
                            &one, &part_curve, &test_planar);
          if(rc ISNT BSSUCC) continue;

          EFisoCurveLocate(EMmsg, &part_curve, cvl, loc_parms, TRUE,
                           &intersection_param, &relation);
          if(! (1 & *EMmsg)) continue;

          EFinterpretRelation(EMmsg, relation, cvl->attributes.type, 0,
                              NULL, intersection_param, prism_rel, inside,
                              outside, overlap, was_located);
          if(! (1 & *EMmsg)) continue;
        }

        cv_params = &clip_points[i][1];
        num_internal_curves = num_clip_pairs[i] - 1;
        for(j = 0;
            ((j < num_internal_curves) && (! *was_located));
            cv_params += 2, j ++)
        {
          /*
           * Do the internal the sections.
           */
          (void)BSactivsplt(&rc, &iso_curve, cv_params, &cv_params[1],
                            &part_curve, &test_planar);
          if(rc ISNT BSSUCC) continue;

          EFisoCurveLocate(EMmsg, &part_curve, cvl, loc_parms, TRUE,
                           &intersection_param, &relation);
          if(! (1 & *EMmsg)) continue;

          EFinterpretRelation(EMmsg, relation, cvl->attributes.type, 0,
                              NULL, intersection_param, prism_rel, inside,
                              outside, overlap, was_located);
          if(! (1 & *EMmsg)) continue;

        } /* end for each partial curve */

      } /* end if no clips, else */

    } /* end for each iso curve */

    /*
     * Set up to do V (using v-definition of the surface)
     */
    num_rules = rlt->v_rules;
    rule_values = rlt->v_rule_values;
    num_clip_pairs = rlt->v_num_bound;
    clip_points = rlt->v_bdrys;

    knots = surface->u_knots;
    iso_curve.order = surface->u_order;
    iso_curve.periodic = surface->u_periodic;
    iso_curve.non_uniform = surface->u_non_uniform;
    iso_curve.num_poles = surface->u_num_poles;
    iso_curve.num_knots = surface->u_num_knots;
    iso_curve.phy_closed = surface->u_phy_closed;

  } /* end for U, then V */

  if(*was_located && loc_parms)
  {
    if(k IS U)
    {
      loc_parms->geom_parms.u = rule_values[i];
      loc_parms->geom_parms.v = intersection_param;
    }
    else
    {
      loc_parms->geom_parms.u = intersection_param;
      loc_parms->geom_parms.v = rule_values[i];
    }
  }

wrapup:
  if(iso_buffer && (iso_buffer ISNT static_iso_buffer))
    om$dealloc(ptr = iso_buffer);
  if(part_buffer && (part_buffer ISNT static_part_buffer))
    om$dealloc(ptr = part_buffer);
  if EMSmsgReport(*EMmsg, "EFlocateRLT", FALSE) *EMmsg = EMS_S_Success;
}

void EFinterpretRelation(EMmsg, relation, operation_type, num_clip_pairs,
                         clip_points, intersection_param, prism_rel,
                         inside, outside, overlap, was_located)

IGRlong                 *EMmsg;
IGRshort                relation;
enum GRlocate_types     operation_type;
IGRint                  num_clip_pairs;
IGRdouble               *clip_points;
IGRdouble               intersection_param;
IGRlong                 *prism_rel;
IGRboolean              *inside;
IGRboolean              *outside;
IGRboolean              *overlap;
IGRboolean              *was_located;

{
  switch(operation_type)
  {
    case GR_bl_loc:
      if(relation IS HIT)
      {
        if(num_clip_pairs)
        {
          IGRint  i, j;

          if((intersection_param < clip_points[0]) ||
             (intersection_param > clip_points[num_clip_pairs * 2 - 1]))
            *was_located = TRUE;
          else
          {
            for(i = j = 1; i < num_clip_pairs; i ++)
            {
              if(intersection_param < clip_points[j ++]) break;
              else
              {
                if(intersection_param < clip_points[j ++])
                {
                  *was_located = TRUE;
                  break;
                }
              }
            }
          }
        }
        else *was_located = TRUE;
      }
      break;

    case GR_cv_loc:

    case GR_rp_loc:
      {
        /*
         * Interpret the relation
         */
        switch(relation)
        {
          case INSIDE:
            *inside = TRUE;
            if(*outside) *overlap = *was_located = TRUE;
            else if((*prism_rel IS (GO_INSIDE | GO_OVERLAP)) OR
                    (*prism_rel IS GO_OUTSIDE))
              *was_located = TRUE;
            break;

          case OUTSIDE:
            *outside = TRUE;
            if(*inside) *overlap = *was_located = TRUE;
            else if((*prism_rel IS (GO_OUTSIDE | GO_OVERLAP)) OR
                    (*prism_rel IS GO_INSIDE))
              *was_located = TRUE;
            break;

          case OVERLAP:
            *inside = *outside = *overlap = *was_located = TRUE;
            break;

          default:
            *EMmsg = EMS_E_InvalidCase;
            goto wrapup;
        } /* switch */

      }
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
  }

wrapup:
  if EMSmsgReport(*EMmsg, "EFinterpretRelation", FALSE)
    *EMmsg = EMS_S_Success;
}
