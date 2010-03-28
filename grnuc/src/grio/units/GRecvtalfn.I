class implementation Root;

#ifndef NT
#include <sys/time.h>
#endif
#include <time.h>
#include "msdef.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

#include "grimport.h"
#include "igrmacros.h"
#include "csdef.h"
#include "csmacros.h"
#include <stdio.h>

%safe
#include <math.h>
%endsafe

IGRlong GRcvt_exp_to_alias(msg,
                           table_name,
                           osnum,
                           num_def,
                           output_alias,
                           working_units,
                           readout_spec,
                           field_size,
                           inverse_scale_flag,
			   fraction_mode,
                           cvt_string)
     
     IGRlong          *msg;              /* return code from function        */
     IGRchar          *table_name;       /* type of conversion to be done    */
     OMuword           osnum;            /* object space table is in         */
     IGRshort         *num_def;          /* number of defaults specified     */
     GRIOalias_name   *output_alias[];   /* output alias  list               */
     IGRdouble        *working_units;    /* num of working units to cvt from */
     struct GRIOreadout_spec  *readout_spec;
     IGRshort                 *field_size;
     IGRshort                  inverse_scale_flag;
     IGRshort                 *fraction_mode;
     IGRchar                  *cvt_string;   /* list of converted aliases   */
{
  IGRlong sts;

  sts = UOM_cvt_exp_to_alias( msg, table_name, osnum, num_def,
                              output_alias, working_units,
                              readout_spec, field_size,
                              inverse_scale_flag, fraction_mode,
                              cvt_string );
  if ( sts & 1 )
    sts = OM_S_SUCCESS, *msg = MSSUCC;
  else
    sts = OM_E_ABORT, *msg = MSFAIL;

  return sts;
}

end implementation Root;
