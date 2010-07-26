/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COspcvttoout

Description
        This function converts internal distance to user distance (e.g.
        internal plotsize to inches).  The x_out and y_out buffers are
        each assumed to be at least size characters long.

History
        mrm     05/02/89    creation
	madhu	11/27/90    added local plotting size display on form
        mrm     06/19/91    specify GRIO_NO_SCALE to avoid problems with
                            drawing sheet scale when converting lengths
*/

#ifndef STANDALONE
#include "coimport.h"
#endif
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "FI.h"
#include "pidef.h"
#include "pilabel.h"
#include "pi.h"

extern int FIfld_set_text ();
extern int FIg_display ();


int COspcvttoout (x_in, y_in, size, x_out, y_out)
double x_in, y_in;
int size;
char *x_out, *y_out;
{
#ifdef STANDALONE

    int sts = PI_S_SUCCESS;

    sprintf (x_out, "%.4f in", x_in);
    sprintf (y_out, "%.4f in", y_in);

#else

    int  sts, msg;
    short  i, j;
    OMuword osnum;
    double wu[2];          /* working units */
    char *buff_ptrs[2];    /* pointers to output strings */

    /* get the current module space number */

    ex$get_cur_mod (osnum = &osnum);

    /* convert size values to output strings */

    i = 1;
    j = sizeof(IGRchar) * size;
    wu[0] = x_in;
    wu[1] = y_in;
    buff_ptrs[0] = x_out;
    buff_ptrs[1] = y_out;

    sts = co$cvt_imp_to_alias (msg = &msg,
			       inverse_scale_flag = GRIO_NO_SCALE,
                               unit_type = "UOM_DISTANCE",
                               osnum = osnum,
                               working_units = wu,
                               num_alias = &i,
                               num_conversions = 2,
                               field_size = &j,
                               cvt_list = buff_ptrs);

    sts = (sts & msg & 1) ? PI_S_SUCCESS : PI_F_FAIL;

#endif

    return (sts);
}


/*
Name
        COspshosize

Description
        This function displays the size and scale stored in the pd
        data structure on the Submit Plot form.
*/

int COspshosize (pd)
PIplotdata *pd;
{
    char buf1[32], buf2[32];

    /* display the plot size and scale */

    if(pd->pltype)
	    COspcvttoout (pd->lplot_x, pd->lplot_y, 32, buf1, buf2);
    else
	    COspcvttoout (pd->plot_x, pd->plot_y, 32, buf1, buf2);

    FIfld_set_text (pd->submit_form, SUBMIT_PLOT_X_SIZE, 0, 0, buf1, 0);
    FIfld_set_text (pd->submit_form, SUBMIT_PLOT_Y_SIZE, 0, 0, buf2, 0);
    if(pd->pltype)
  	sprintf (buf1, "%.5f", pd->lscale);
    else
        sprintf (buf1, "%.5f", pd->scale);

    FIfld_set_text (pd->submit_form, SUBMIT_PLOT_SCALE, 0, 0, buf1, 0);
    return (PI_S_SUCCESS);
}
