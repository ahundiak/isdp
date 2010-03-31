# include "EMS.h"
# include "OMprimitives.h"      /* om$()alloc       */
# include "OMmacros.h"          /* OM_BLOCK_MOVE    */
# include "OMminimum.h"         /* GRlc...          */
# include "OMlimits.h"          /* GRlc...          */
# include "igetypedef.h"        /* GRlc...          */
# include "igrtypedef.h"        /* IGR...           */
# include "igr.h"               /* IGR...           */
# include "igrdp.h"             /* IGR...           */
# include "gr.h"                /* GRlc...          */
# include "gr.h"                /* GRlc...          */
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
# include "bstypes.h"           /* BSrc             */
# include "bserr.h"             /* BS...            */
#include "bsunwght_p.h"

/*
  HISTORY

       Sudha   25-Jun-93       Modified for BSprototype ansification
*/

# define BUFFER_SIZE 1000
# define PT_SIZE 3

void EFpolygonLocate(EMmsg, surface, lc_info, cvl, prism_rel,
                     inside, outside, overlap, was_located)

IGRlong                 *EMmsg;
struct IGRbsp_surface   *surface;
struct GRlc_info        *lc_info;
struct GRlc_cvl         *cvl;
IGRlong                 *prism_rel;
IGRboolean              *inside,
                        *outside,
                        *was_located;
{
  IGRint                i, buffer_a_size, buffer_b_size, buffer_c_size,
                        pole_increment, weight_increment,
                        doubleSize, pointSize;
  IGRdouble             *poles, *weights;
  IGRdouble             *buffer_a;
  IGRdouble             *buffer_b;
  IGRdouble             *buffer_c;
  IGRdouble             static_buffer_a[BUFFER_SIZE * PT_SIZE];
  IGRdouble             static_buffer_b[BUFFER_SIZE * PT_SIZE];
  IGRdouble             static_buffer_c[BUFFER_SIZE];
  struct IGRpolyline    pline;

  void                  EFpolylineLocate();

  /*
   * Initialize
   */
  buffer_a = static_buffer_a;
  buffer_b = static_buffer_b;
  buffer_c = static_buffer_c;
  buffer_a_size = buffer_b_size = buffer_c_size = BUFFER_SIZE;
  doubleSize = sizeof(IGRdouble);
  pointSize = PT_SIZE * doubleSize;

  /*
   * Get the buffer for the U poles
   */
  if(surface->rational && (surface->u_num_poles > buffer_a_size))
  {
    buffer_a_size = surface->u_num_poles;
    buffer_a = (IGRdouble *) om$malloc
                (size = buffer_a_size * PT_SIZE * doubleSize);
    if(! buffer_a) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
  }

  /*
   * Initialize for the U polylines
   */
  pole_increment = pline.num_points = surface->u_num_poles;
  pole_increment *= 3;
  poles = surface->poles;
  weights = surface->weights;

  /*
   * Do the U polylines
   */
  for(i = 0; (i < surface->v_num_poles) && (! *was_located);
      poles += pole_increment, weights += surface->u_num_poles, i ++)
  {
    /*
     * Get the unweighted poles for the ith U polyline
     */
    if(surface->rational)
    {
      BSrc          rc;

      (void) BSunwght_p(&rc,poles,weights,&surface->u_num_poles,buffer_a);
      if(rc ISNT BSSUCC) { *EMmsg = EMS_E_Fail; goto wrapup; }
      pline.points = buffer_a;
    }
    else pline.points = poles;

    /*
     * Perform the locate on the polyline
     */
    EFpolylineLocate(EMmsg, &pline, lc_info, cvl, prism_rel,
                     inside, outside, overlap, was_located);
    if(! (1 & *EMmsg)) goto wrapup;
  }

  if(! *was_located)
  {
    /*
     * Get the buffers for the V poles and weights
     */
    if(surface->v_num_poles > buffer_a_size)
    {
      buffer_a_size = surface->v_num_poles;
      if(buffer_a ISNT static_buffer_a) om$dealloc(ptr = buffer_a);
      buffer_a = (IGRdouble *) om$malloc
                  (size = buffer_a_size * PT_SIZE * doubleSize);
      if(! buffer_a) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }
    if(surface->v_num_poles > buffer_b_size)
    {
      buffer_b_size = surface->v_num_poles;
      buffer_b = (IGRdouble *) om$malloc
                  (size = buffer_b_size * PT_SIZE * doubleSize);
      if(! buffer_b) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }
    if(surface->v_num_poles > buffer_c_size)
    {
      buffer_c_size = surface->v_num_poles;
      buffer_c = (IGRdouble *) om$malloc
                  (size = buffer_c_size * doubleSize);
      if(! buffer_c) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }

    /*
     * Initialize for the V polylines
     */
    weight_increment = surface->u_num_poles;
    pline.num_points = surface->v_num_poles;
    poles = buffer_b;
    weights = buffer_c;

    /*
     * Do the V polylines
     */
    for(i = 0; (i < surface->u_num_poles) && (! *was_located); i ++)
    {
      IGRint    j;
      IGRdouble *from_pole, *from_weight;
      IGRdouble *to_pole, *to_weight;

      /*
       * Extract the poles and weights for the ith V polyline
       */
      to_pole = poles;
      to_weight = weights;
      from_pole = surface->poles + i * PT_SIZE;
      from_weight = surface->weights + i;
      for(j = 0; j < surface->v_num_poles; j ++)
      {
        OM_BLOCK_MOVE(from_pole, to_pole, pointSize);
        from_pole += pole_increment; to_pole += 3;
        if(surface->rational)
        {
          *to_weight++ = *from_weight;
          from_weight += weight_increment;
        }
      }

      /*
       * Get the unweighted poles for the ith V polyline
       */
      if(surface->rational)
      {
        BSrc    rc;
        IGRint  sts;

        sts=BSunwght_p(&rc,poles,weights,&surface->v_num_poles,buffer_a);
        if(rc ISNT BSSUCC) { *EMmsg = EMS_E_Fail; goto wrapup; }
        pline.points = buffer_a;
      }
      else pline.points = poles;

      /*
       * Perform the locate on the polyline
       */
      EFpolylineLocate(EMmsg, &pline, lc_info, cvl, prism_rel,
                       inside, outside, overlap, was_located);
      if(! (1 & *EMmsg)) goto wrapup;
    }
  }

wrapup:
  if(buffer_a && (buffer_a ISNT static_buffer_a))
    om$dealloc(ptr = buffer_a);
  if(buffer_b &&(buffer_b ISNT static_buffer_b))
    om$dealloc(ptr = buffer_b);
  if(buffer_c && (buffer_c ISNT static_buffer_c))
    om$dealloc(ptr = buffer_c);
  EMSmsgReport(*EMmsg, " in EFpolygonLocate", FALSE);
  return;
}

void EFpolylineLocate(EMmsg, polyline, lc_info, cvl, prism_rel,
                      inside, outside, overlap, was_located)

IGRlong             *EMmsg;
struct IGRpolyline  *polyline;
struct GRlc_info    *lc_info;
struct GRlc_cvl     *cvl;
IGRlong             *prism_rel;
IGRboolean          *inside;
IGRboolean          *outside;
IGRboolean          *overlap;
IGRboolean          *was_located;
{
  IGRdouble             static_knot_buffer[BUFFER_SIZE];
  IGRdouble             knot_increment;
  IGRdouble             *knot_buffer, *knot;
  IGRint                num_knots, num_internal_knots, i;
  struct IGRbsp_curve   curve;

  /*
   * Initialize
   */
  knot_buffer = static_knot_buffer;

  /*
   * Get memeory for knots
   */
  num_knots = polyline->num_points + 2;
  if(num_knots > BUFFER_SIZE)
  {
    knot_buffer = (IGRdouble *) om$malloc
                  (size = num_knots * sizeof(IGRdouble));
    if(! knot_buffer) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
  }

  /*
   * Calculate the knots
   */
  knot = knot_buffer;
  *knot = 0; knot ++; *knot = 0;
  num_internal_knots = polyline->num_points - 1;
  knot_increment = 1.0 / num_internal_knots;
  for(i = 0; i < num_internal_knots; i ++)
  {
    knot[1] = *knot + knot_increment;
    knot ++;
  }
  knot ++; *knot = 1.0;

  /*
   * Set up the curve
   */
  curve.order = 2;
  curve.periodic = FALSE;
  curve.non_uniform = FALSE;
  curve.num_poles = polyline->num_points;
  curve.poles = polyline->points;
  curve.num_knots = num_knots;
  curve.knots = knot_buffer;
  curve.rational = FALSE;
  curve.weights = NULL;
  curve.planar = (polyline->num_points <= 3) ? TRUE : FALSE;
  curve.phy_closed = FALSE;
  curve.num_boundaries = 0;
  curve.bdrys = NULL;

  /*
   * Perform the locate
   */
  {
    IGRdouble   int_parm;
    IGRshort    relation;

    EFisoCurveLocate(EMmsg, &curve, cvl, lc_info, TRUE, &int_parm,
                     &relation);
    if(! (1 & *EMmsg)) goto wrapup;

    EFinterpretRelation(EMmsg, relation, cvl->attributes.type, 0, NULL,
                        int_parm, prism_rel, inside, outside, overlap,
                        was_located);
    if(! (1 & *EMmsg)) goto wrapup;
  }

wrapup:
  if(knot_buffer && (knot_buffer ISNT static_knot_buffer))
    om$dealloc(ptr = knot_buffer);
  EMSmsgReport(*EMmsg, " in EFpolylineLocate", FALSE);
  return;
}
