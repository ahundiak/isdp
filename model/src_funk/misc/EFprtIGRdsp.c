/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
# include <stdio.h>

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"    /* needed for igrdp.h */
# endif

# ifndef igr_include
# include "igr.h"           /* needed for igrdp.h */
# endif

# ifndef igrdp_include
# include "igrdp.h"         /* struct IGRdisplay */
# endif


/* print IGRdisplay */

/*
void EFprtIGRdsp (fp, display_attr)
FILE *fp;
IGRint display_attr;
{
    fprintf (fp, "color 0x%x\n",
        ((unsigned char *)&display_attr)[0]);
    fprintf (fp, "weight 0x%x\n",
        ((unsigned char *)&display_attr)[1]);
    fprintf (fp, "font number 0x%x\n",
        ((unsigned char *)&display_attr)[2]);
    fprintf (fp, "line style 0x%x\n",
        ((unsigned char *)&display_attr)[3]);

    return;
}
*/

void EFprtIGRdsp (fp, display)
FILE *fp;
struct IGRdisplay display;
{
/*
    fprintf (fp, "rgb_value 0x%x\n", display.rgb_value);
*/
    fprintf (fp, "color 0x%x\n", display.color);
    fprintf (fp, "weight 0x%x\n", display.weight);
    fprintf (fp, "style 0x%x\n", display.style);

    return;
}
