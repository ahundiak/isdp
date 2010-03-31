
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

/*
Name
        HPsizescale

Description
        This function handles the input of a new size or scale to the
        Submit Plot form.

History
        mrm     03/17/89    creation
*/

#include <stdlib.h>
#include "wl.h"
#include "DIdef.h"

#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "msmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "plotmsg.h"
#include "exsysdep.h"
#include "FI.h"
#include "madef.h"
#include "godef.h"
#include "HSplot.h"
#include "HSplot_def.h"
#include "HSplot_label.h"
#include "hsmsg.h"
#include "exmacros.h"

#include "HSpr_hplot.h"

/*-------------------------
 *  for function
 *     HSconv_double
 */
 
#include "hsanimate.h"
#include "HSrle.h"
#include "HSpr_rle_uti.h"

/*------------------------*/


#define PI_X_SIZE           0
#define PI_Y_SIZE           1
#define PI_SCALE            2

static int	last_value;
static double	file_x, file_y;

/*
static int	HPsizeplot();
static int	HPget_viewport_size();
*/

/*
 *  Prototype declaration for static functions
 */

#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HPf_sizeplot.C */
static int HPsizeplot __((	 struct HSplot_info *info));

static int HPget_viewport_size __((	    IGRchar *plotfile, 
					    IGRchar *rasterfile, 
					  IGRdouble *xsize, 
					  IGRdouble *ysize));

#if defined(__cplusplus)
}
#endif


#undef __


/*---HPsizescale-------------------------------------------------------*/

/*
NAME
	HPsizescale
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Causes the plot size/scale to get updated when a new queue
	is selected
	
PARMETERS
	into		:(IN) : shaded plotting global information
	gadget_label	:(IN) : gadget selected
	form		:(IN) : form id
	
GLOBALS USED
	-none-
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	int HPsizescale( struct HSplot_info *info,
					int gadget_label,
				       Form form )
#else
	int HPsizescale( info, gadget_label, form )

	struct HSplot_info	*info;
	int			gadget_label;
	Form			form;
#endif

	{
	int	row, sel, sts;
	double	*z;
	char	unit_type[32], buf[64];

	FIfld_get_text( form, gadget_label, 0, 0, 64, buf, &sel, &row );
	
	file_x = info->plotter_max[0];
	file_y = info->plotter_max[1];

	HPget_viewport_size( info->plotfile, info->rasterfile, &file_x, &file_y );

	/*
	 *  Use the grnuc expression handler to interpret the input
	 */

	if( gadget_label == SP_SCALE )
		{
		strcpy( unit_type, GRIO_SCALAR );
		last_value = PI_SCALE;
		z = &info->scale;
		}
	else 
		{
		if( gadget_label == SP_X )
			{
			strcpy( unit_type, GRIO_DISTANCE );
			last_value = PI_X_SIZE;
			z = &info->size_x;
			}
		else
			{
			strcpy( unit_type, GRIO_DISTANCE );
			last_value = PI_Y_SIZE;
			z = &info->size_y;
			}
		}

	co$expreval( msg = &sts,
	      expression = buf,
	       unit_type = unit_type,
		  result = z );

	if( !(sts & 1 ) && *z == 0.0 )
		{
		*z = 1000000; /* force rescaling */
		ex$message( msgnumb = PI_E_InvInp, buff = buf );
		FIfld_set_text( form, SP_INFO, 0, 0, buf, 0 );
		FIg_display( form, SP_INFO );
		}
	
	sts = HPsizeplot( info );

	if( !(sts & 1 ) )
		{
		ex$message( msgnumb = PI_I_PlotScaled, buff = buf );
		FIfld_set_text( form, SP_INFO, 0, 0, buf, 0 );
		FIg_display( form, SP_INFO );
		}

	/* display the plot size and scale */

	HPshow_size( info );

	return( PI_S_SUCCESS );
	}
	
/*---HPsizeplot-------------------------------------------------------*/

/*
NAME
	HPsizeplot

DESCRIPTION
	This function determines whether a plot at a given size will
	fit within the limits defined by the plotter selected.  All
	input is taken from the monstrous data structure passed in.

PARAMETERS
	info	:(IN) : shaded plotting global information
	
GLOBALS USED
	-none-
	
HISTORY
	03/17/89	mrm
		creation
*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HPsizeplot( struct HSplot_info *info )
#else
	static int HPsizeplot( info )

	struct HSplot_info	*info;
#endif

	{
	int sts = PI_S_SUCCESS;

	/* validate the size and scale args */

	if( info->scale == 0.0 ) info->scale = 1.0;
	if( info->size_x == 0.0 ) info->size_x = 1.0;
	if( info->size_y == 0.0 ) info->size_y = 1.0;

	/* adjust the appropriate value */

	if( (last_value == PI_X_SIZE ) && ( info->size_x > 0.0 ) )
		{
		info->scale = info->size_x / file_x;
		info->size_y = info->scale * file_y;
		}
	else if( (last_value == PI_Y_SIZE ) && ( info->size_y > 0.0 ) )
		{
		info->scale = info->size_y / file_y;
		info->size_x = info->scale * file_x;
		}
	else
		{
		info->size_x = info->scale * file_x;
		info->size_y = info->scale * file_y;
		}

	/* compare plotter limits to plot size */

	if( info->size_x > info->plotter_max[0] )
		{
		sts = PI_W_RESCALE;
		info->scale = info->plotter_max[0] / file_x;
		info->size_x = info->plotter_max[0];
		info->size_y = info->scale * file_y;
		}

	if( info->size_y > info->plotter_max[1] )
		{
		sts = PI_W_RESCALE;
		info->scale = info->plotter_max[1] / file_y;
		info->size_x = info->scale * file_x;
		info->size_y = info->plotter_max[1];
		}

	return( sts );
	}

struct	rasterfile_header_info
	{
	short		level_type;	
	short		wds_to_follow;	
	short		data_type_code;
	short		app_type_code;
	double		view_origin[3];
	double		view_extent[3];
	double		transformation[16];
	long		num_cols;
	long		num_rows;
	short		device_resolution;
	};

/*---HPget_viewport_size-----------------------------------------*/

/*
NAME
	HPget_viewport_size
	
DESCRIPTION
	Get the viewport size from either the plotfile or rasterfile
	
PARAMETERS
	plotfile	:(IN) : name of the shaded plotfile
	rasterfile	:(IN) : name of the rasterfile
	xsize, ysize	:(OUT): viewport size
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HPget_viewport_size( IGRchar *plotfile,
					IGRchar *rasterfile,
				      IGRdouble *xsize,
				      IGRdouble *ysize )
#else
	static int	HPget_viewport_size( plotfile, rasterfile, xsize, ysize )

	IGRchar		*plotfile;
	IGRchar		*rasterfile;
	IGRdouble	*xsize;
	IGRdouble	*ysize;
#endif

	{
	IGRint				fp;
	IGRchar				buffer[512];
	struct rasterfile_header_info	rasterfile_header;
	IGRdouble			xres, yres, res;
	
	fp = open( plotfile, 0 );
	if( fp < 0 )
		{
		fp = open( rasterfile, 0 );
		if( fp < 0 )
			{
			return 0 ;
			}
		else
			{
			read( fp, &rasterfile_header, sizeof( struct rasterfile_header_info ) );
			close( fp );
			
			xres = ((IGRdouble)rasterfile_header.num_rows) / *xsize;
			yres = ((IGRdouble)rasterfile_header.num_cols) / *ysize;
			
			res = xres > yres ? xres : yres;
			
			*xsize = ((IGRdouble)rasterfile_header.num_rows) / res;
			*ysize = ((IGRdouble)rasterfile_header.num_cols) / res;
			
			return 1;
			}
		}
	else
		{	
		read( fp, buffer, 512 );
	
		*xsize = *(double *)(buffer + 256);
		*ysize = *(double *)(buffer + 264);

#		ifdef BIG_ENDIAN
			HSconv_double( xsize, 1 );
			HSconv_double( ysize, 1 );
#		endif
		
		close( fp );

		return 1;
		}
	}
				

extern int FIfld_set_text(  );
extern int FIg_display(  );

/*---HPshow_size--------------------------------------------------------------------*/

/*
NAME
	HPshow_size

DESCRIPTION
	This function displays the size and scale stored in the pd
	data structure on the Submit Plot form.
	
PARAMETERS
	info	:(IN) : shaded plotting global information
	
HISTORY
	??/??/??	M. Mathis, M. Lanier
		Created
		
	02/12/93	M. Lanier
		Change HPconvert_to_outunits, to COspcvttoout.
		
*/

#if defined(__STDC__) || defined(__cplusplus)
	int HPshow_size( struct HSplot_info *info )
#else
	int HPshow_size( info )

	struct HSplot_info	*info;
#endif

	{
	char buf1[32], buf2[32];

	/* display the plot size and scale */

	COspcvttoout( info->size_x, info->size_y, 32, buf1, buf2 );
	
	FIfld_set_text( info->displayed_form, SP_X, 0, 0, buf1, 0 );
	FIg_display( info->displayed_form, SP_X );
	FIfld_set_text( info->displayed_form, SP_Y, 0, 0, buf2, 0 );
	FIg_display( info->displayed_form, SP_Y );
	
	sprintf( buf1, "%f", info->scale );
	FIfld_set_text( info->displayed_form, SP_SCALE, 0, 0, buf1, 0 );
	FIg_display( info->displayed_form, SP_SCALE );
	
	return( PI_S_SUCCESS );
	}
