/*
Name
        COspsizescale

Description
        This function handles the input of a new size or scale to the
        Submit Plot form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/17/89    creation
	madhu   02/01/91    handles input local plotting size or scale
        mrm     06/19/91    specify GRIO_NO_SCALE to avoid problems with
                            drawing sheet scale when converting lengths
        scw     07/17/92    ansi conversion
	Carlos M. Diaz
                03/01/93    Header and message compliance
        mrm     11/15/93    Full UMS conversion to fix the mess Carlos made of
                            the STANDALONE utility 
*/

#ifndef STANDALONE
#include "coimport.h"
#endif
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "plotmsg.h"
#include "FI.h"
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"

extern int FIfld_get_text();
extern int FIfld_set_text();
extern int FIg_display();


#argsused
int COspsizescale(
  PIplotdata *pd,
  int    form_label,
  int    gadget_label,
  double value,
  Form   form)
{
    int row, sel, sts;
    double *z;
    char buf[64];
#ifndef STANDALONE
    char unit_type[32], buf1[64];
#endif

    FIfld_get_text(form, gadget_label, 0, 0, 64, buf, &sel, &row);

#ifdef STANDALONE

    /*
     *  Parse the input - much more limited scope handled here than in grnuc
     */

    if (gadget_label == SUBMIT_PLOT_SCALE)
    {
        pd->last_value = PI_SCALE;
	z = (pd->pltype) ? &pd->lscale : &pd->scale;
        sscanf(buf, "%lf", z);
    }
    else
    {
        if (gadget_label == SUBMIT_PLOT_X_SIZE)
        {
            pd->last_value = PI_X_SIZE;
	    z = (pd->pltype) ? &pd->lplot_x : &pd->plot_x;
        }
        else
        {
            pd->last_value = PI_Y_SIZE;
	    z = (pd->pltype) ? &pd->lplot_y : &pd->plot_y;
        }
        pd->plot_unit[0] = NULL;
        sscanf(buf, "%lf %8s", z, pd->plot_unit);
        if (pd->plot_unit[0] == NULL)
        {
            sprintf(pd->plot_unit, "in");
        }
	if (pd->pltype)
            sts = COcvtsize(&pd->lplot_x, &pd->lplot_y, pd->plot_unit);
	else
            sts = COcvtsize(&pd->plot_x, &pd->plot_y, pd->plot_unit);

        if (sts == PI_W_UNKUNITS)
        {
            UMSGetByNum(buf, PI_I_UnkUnit, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            FIg_display(form, FI_MSG_FIELD);
        }
    }

#else

    /*
     *  Use the grnuc expression handler to interpret the input
     */

    if (gadget_label == SUBMIT_PLOT_SCALE)
    {
        strcpy(unit_type, GRIO_SCALAR);
        pd->last_value = PI_SCALE;
        z = (pd->pltype) ? &pd->lscale : &pd->scale;
    }
    else if (gadget_label == SUBMIT_PLOT_X_SIZE)
    {
        strcpy(unit_type, GRIO_DISTANCE);
        pd->last_value = PI_X_SIZE;
        z = (pd->pltype) ? &pd->lplot_x : &pd->plot_x;
    }
    else
    {
        strcpy(unit_type, GRIO_DISTANCE);
        pd->last_value = PI_Y_SIZE;
	z = (pd->pltype) ? &pd->lplot_y : &pd->plot_y;
    }

    co$epp(msg = &sts, string = buf, sizebuf = sizeof(buf), buffer = buf1);

    if (sts & 1)
    {
        co$expreval(msg = &sts,
		    scale_flag = GRIO_NO_SCALE,
                    expression = buf1,
                    unit_type = unit_type,
                    result = z);
    }
    if (!(sts & 1))
    {
        *z = 1000000;           /* force rescaling */
        ex$message(msgnumb = PI_E_InvInp, buff = buf);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        FIg_display(form, FI_MSG_FIELD);
    }

#endif

    sts = COsizeplot(pd);

    if (!(sts & 1))
    {
	UMSGetByNum(buf, PI_I_PlotScaled, 0);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        FIg_display(form, FI_MSG_FIELD);
    }

    /* display the plot size and scale */

    COspshosize(pd);

    return(PI_S_SUCCESS);
}
