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

/* godef.h replacement */

# ifndef madef_include
# include "madef.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

/* end of godef.h replacement */

/* print GRvg properties */

void EFprtGRvgPp (fp, properties)
FILE *fp;
IGRshort properties;
{
    fprintf (fp, "%sGR_RIGID_RELATIONSHIP\n",
        (GR_RIGID_RELATIONSHIP & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_PLANAR\n",
        (GRIS_PLANAR & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_READ_ONLY\n",
        (GRIS_READ_ONLY & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_NEW\n",
        (GRIS_NEW & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_MODIFIED\n",
        (GRIS_MODIFIED & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_LOCATABLE\n",
        (GRIS_LOCATABLE & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_DISPLAYABLE\n",
        (GRIS_DISPLAYABLE & properties) ? "" : "not ");
    fprintf (fp, "%sGRFILLED_DISPLAY\n",
        (GRFILLED_DISPLAY & properties) ? "" : "not ");
    fprintf (fp, "%sGRNOT_IN_RTREE\n",
        (GRNOT_IN_RTREE & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_VIEW_INDEP\n",
        (GRIS_VIEW_INDEP & properties) ? "" : "not ");
    fprintf (fp, "%sGRIS_SCALE_INDEP\n",
        (GRIS_SCALE_INDEP & properties) ? "" : "not ");


    return;
}
