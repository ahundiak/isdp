/* #######################    APOGEE COMPILED   ######################## */

#include <math.h>
#include "grimport.h"
#include "msdef.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

int GRIO_float_to_sci(float_in,
		      readout_spec,
		      ascii_result)
IGRdouble float_in;
struct GRIOreadout_spec *readout_spec;
char *ascii_result;
{
  return UOM_grio_float_to_sci( float_in, readout_spec, ascii_result );
}
