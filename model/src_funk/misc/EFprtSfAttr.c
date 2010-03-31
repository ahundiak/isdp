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

void EFprtSfAttr (fp, attributes)
FILE *fp;
struct IGResbs *attributes;
{
    (void)fprintf (fp, "%ld u rule lines\n",
        attributes->u_rules);
    (void)fprintf (fp, "%ld v rule lines\n",
        attributes->v_rules);

    (void)fprintf (fp, "polygon display %s\n",
        attributes->is_polydis ? "ON" : "OFF");
    (void)fprintf (fp, "surface display %s\n",
        attributes->is_surfdis ? "ON" : "OFF");
    (void)fprintf (fp, "slow display %s\n",
        attributes->is_slowdis ? "ON" : "OFF");

    (void)fprintf (fp, "surface type %d\n", attributes->type);

    return;
}
