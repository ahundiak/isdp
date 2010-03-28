/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COsizeplot

Description
        This function determines whether a plot at a given size will
        fit within the limits defined by the plotter selected.  All
        input is taken from the monstrous data structure passed in.

History
        mrm     03/17/89    creation
	madhu   02/01/91    adjusts local plotting size variables
*/

#ifndef STANDALONE
#include "coimport.h"
#endif
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "dimfiundef.h"
#include "FI.h"
#include "pi.h"
#include "pidef.h"

int COsizeplot (pd)
PIplotdata *pd;
{
    int sts = PI_S_SUCCESS;
    double *scale, *plot_x, *plot_y;

    /* validate the size and scale args */

    if(pd->pltype)	{
	scale = &pd->lscale;
	plot_x = &pd->lplot_x;
	plot_y = &pd->lplot_y;
    }
    else	{
	scale = &pd->scale;
	plot_x = &pd->plot_x;
	plot_y = &pd->plot_y;
    }
  
    if (*scale == 0.0)
        *scale = 1.0;
    if (*plot_x == 0.0)
        *plot_x = 1.0;
    if (*plot_y == 0.0)
        *plot_y = 1.0;

    
    /* adjust the appropriate value */

    if ((pd->last_value == PI_X_SIZE) && (*plot_x > 0.0))
    {
     	   	*scale = *plot_x / pd->file_x;
        	*plot_y = *scale * pd->file_y;
    }
    else if ((pd->last_value == PI_Y_SIZE) && (*plot_y > 0.0))
    {
        	*scale = *plot_y / pd->file_y;
        	*plot_x = *scale * pd->file_x;
    }
    else
    {
        *plot_x = *scale * pd->file_x;
        *plot_y = *scale * pd->file_y;
    }

    /* compare plotter limits to plot size.. in case of network plotting */

    if ((pd->plot_x > pd->plotter_max[0]) && (!pd->pltype))
    {
        sts = PI_W_RESCALE;
        pd->scale = pd->plotter_max[0] / pd->file_x;
        pd->plot_x = pd->plotter_max[0];
        pd->plot_y = pd->scale * pd->file_y;
    }

    if ((pd->plot_y > pd->plotter_max[1]) && (!pd->pltype))
    {
        sts = PI_W_RESCALE;
        pd->scale = pd->plotter_max[1] / pd->file_y;
        pd->plot_x = pd->scale * pd->file_x;
        pd->plot_y = pd->plotter_max[1];
    }

    return (sts);
}
