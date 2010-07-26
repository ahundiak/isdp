class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern IGRboolean MAcpxform ();

method GRupdrefrng ( long *msg; short *mx_type; IGRmatrix matrix)
{
  char               *ptr;
  long               OMmsg;
  struct IGRcv_prism transformed_cp, *cv_prism;
  double             points2 [90], knots [36];

  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* get the curve prism representation of the reffile object */
  GRgetabsg ( msg, mx_type, matrix, &ptr, i );
  if (1 & *msg)
  {
    cv_prism = (struct IGRcv_prism *) ptr;

    transformed_cp.curve.poles = points2;
    transformed_cp.curve.knots = knots;
    transformed_cp.curve.weights = NULL;

    if (MAcpxform ( msg, cv_prism, me->master_to_ref_matrix, &transformed_cp ))
      MAcpextents ( msg, &transformed_cp, me->range, &me->range[3] );
    else
      OMmsg = OM_E_ABORT;
  }
  else
    OMmsg = OM_E_ABORT;

  GR_NOTIFY_LISTENERS ( msg, &OMmsg, GR_ATTR_MODIFIED );

  return OMmsg;
}

end implementation GRreffile;
