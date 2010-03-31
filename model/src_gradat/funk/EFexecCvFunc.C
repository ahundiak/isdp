#include "EMS.h"

/*
History
	AIC	??/??/??	Creation.
	SM	02-Jun-88	Pass curve type as the last argument to the
				callers function. Currently for lack of any
				information about the curve type for
				rule lines NULL is passed. This means the
				curve type is unknown or should be
				ignored.
	SM	13-Sep-89	Added arguments u_curve_type and
				v_curve_type. A NULL indicates unknown curve
				type in a particular direction. Changed
				function name to EFexecuteCurveFunc().
	SM	14-Feb-90	Except in case of EMS_E_NoDynamicMemory, 
				ignore problem causing rule line and process
				the next one.
	Sudha	25-Jun-93	Modified for BSprototype ansification
*/

# include "OMprimitives.h"      /* om$...           */
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
# include "emssfcvs.h"
#include "bscnstprpol.h"

# define BUFFER_SIZE    300


void EFexecuteCurveFunc(EMmsg, rlt, surface, f, arglist, nat_rules_ok, 
			    u_curve_type, v_curve_type)

IGRlong                 *EMmsg;
struct IGResqbs         *rlt;
struct IGRbsp_surface   *surface;
IGRint                  (*f)();
IGRchar                 *arglist;
IGRboolean		nat_rules_ok;
IGRuchar	*u_curve_type, *v_curve_type;
{
  BSrc                  rc;
  IGRboolean            terminate = FALSE;
  IGRint                i, k;
  IGRint                sizeof_double;
  IGRint                iso_buffer_size;
  IGRint                num_rules;
  IGRint                *num_clip_pairs;
  IGRdouble             **clip_points;
  IGRdouble             *knots;
  IGRdouble             *rule_values;
  IGRdouble             *iso_buffer;
  IGRdouble             static_iso_buffer[BUFFER_SIZE];
  struct IGRbsp_curve   iso_curve;
  IGRdouble		u_low, u_hig, v_low, v_hig;
  struct EMSinvoker_info my_info;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  u_low = u_hig = v_low = v_hig = 0.0;
  iso_buffer = static_iso_buffer;
  iso_buffer_size = BUFFER_SIZE;
  sizeof_double = sizeof(IGRdouble);
  my_info.flags = EMSexecCvF_RuleLine;
  my_info.obj.objid = NULL_OBJID;

  /*
   * Determine the parametric values of the edges of the surface
   * These are needed only if the natural rules lines are to be ignored.
   */

  if(!nat_rules_ok)
   {
     u_low = surface->u_knots[surface->u_order - 1];
     u_hig = surface->u_knots[surface->u_num_poles];
     v_low = surface->v_knots[surface->v_order - 1];
     v_hig = surface->v_knots[surface->v_num_poles];
   }

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

  for(k = U; ((k <= V) && (! terminate)); k ++)
  {
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
    else iso_curve.weights = NULL;

    /*
     * Get the knots for the iso curve
     */
    OM_BLOCK_MOVE(knots, iso_curve.knots,
                  iso_curve.num_knots * sizeof_double);

    for(i = 0; ((i < num_rules) && (! terminate)); i ++)
    {
      IGRshort  BScnstprpol_option;

      /* If the input flag indicates that the rules lines overlapping
       * the natural bounds of the surface are to be ignored, then
       * make the relevant check.
       */

       if(!nat_rules_ok)
        {
	  if(k == U)
	   {
	     if( (rule_values[i] == v_low) || (rule_values[i] == v_hig) )
	       continue;
	   }
	  else
	   {
	     if( (rule_values[i] == u_low) || (rule_values[i] == u_hig) )
	       continue;
	   }
        }
      /*
       * Get the poles for the isoparametric curve
       */
      BScnstprpol_option = k + 1;
      BScnstprpol(surface, BScnstprpol_option, rule_values[i],
                  iso_curve.poles, iso_curve.weights, &rc);
      if(rc ISNT BSSUCC) { *EMmsg = EMS_S_Success; continue; }

      /*
       * Get the boundaries for the isoparametric curve
       */
      iso_curve.num_boundaries = num_clip_pairs[i];
      if(iso_curve.num_boundaries)
        iso_curve.bdrys = &clip_points[i][0];
      else
	iso_curve.bdrys = NULL;

      my_info.cvtype = (k == U) ? u_curve_type : v_curve_type;
      *EMmsg = (*f)(&iso_curve, arglist, &my_info);
      if(*EMmsg IS EMS_I_Stop) terminate = TRUE;
      *EMmsg = EMS_S_Success;

    } /* end for each iso curve */

    if(terminate) break;

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
    if(! surface->rational) iso_curve.weights = NULL;
    iso_curve.num_boundaries = 0;
    iso_curve.bdrys = NULL;

  } /* end for U, then V */

wrapup:
  if(iso_buffer && (iso_buffer ISNT static_iso_buffer))
    om$dealloc(ptr = iso_buffer);
  if EMSmsgReport(*EMmsg, "EFexecuteCurveFunc", FALSE) *EMmsg = EMS_S_Success;
}
