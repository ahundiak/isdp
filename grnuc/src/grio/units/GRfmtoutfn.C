/* #######################    APOGEE COMPILED   ######################## */
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

  int GRIOformat_readout(rc,
			 readout_spec,
			 num_alias,
			 alias_list,
			 value_list,
			 field_size,
			 fraction_mode,
			 return_string )

int                        *rc;
struct GRIOreadout_spec    *readout_spec;
short                      *num_alias;
GRIOalias_name             *alias_list[];
IGRdouble                  *value_list;
short                      *field_size;
short                      *fraction_mode;
char                       *return_string;
{
  return UOM_grio_format_readout( rc, readout_spec, num_alias, alias_list,
                                  value_list, field_size, fraction_mode,
                                  return_string );
}
