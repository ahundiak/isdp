/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
# include <stdio.h>

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

/* print GRvg properties */

void EFprtCvAttr (fp, attributes)
FILE *fp;
struct IGResbc *attributes;
{
    (void)fprintf (fp, "polygon display %s\n",
        attributes->is_polydis ? "ON" : "OFF");
    (void)fprintf (fp, "curve display %s\n",
        attributes->is_curvedis ? "ON" : "OFF");

    return;
}
