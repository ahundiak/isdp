/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
#include <stdio.h>

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

void EMreport_error(error_code, str)
IGRlong error_code;
IGRchar *str;
{
  fprintf(stderr,"\nerror code: %d %s\n", error_code, str);
}
