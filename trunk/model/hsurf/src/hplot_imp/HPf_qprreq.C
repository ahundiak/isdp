
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "madef.h"
#include "godef.h"
#include "plotmsg.h"
#include "FI.h"

#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "hsdef.h"
#include "HSplot_def.h"
#include "HSplot.h"
#include "hsmsg.h"

#include "wl.h"
#include "HSpr_hplot.h"

#define DEBUG	0

/*---HPqprreq----------------------------------------------------------*/

/*
NAME
	HPqprreq
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Format a qpr request for the shaded plot and submit it by
	using popen
	
PARAMETERS
	info	:(IN) : shaded plotting global information
	results	:(OUT): string containing the submit status
	
GLOBALS USED
	-name-
	
FUNCTIONS CALLED
	HPcreate_textfile_with_raster_attachment
	HPfind_seedfile
	HPverify
	co$cvt_exp_to_wrk
	ex$get_cur_mode
	ex$message
	getc
	pclose
	popen
	sprintf
	strcat
	strcpy
	strlen

HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPqprreq( struct HSplot_info *info,
				     IGRchar *result )
#else
	IGRint	HPqprreq( info, result )

	struct HSplot_info	*info;
	IGRchar	*result;
#endif

	{
	IGRint		sts;
	IGRchar		cmd[512], buf[128], buf2[128];
	IGRshort	stuff[3];
	FILE		*pp = NULL, *popen();
	char		c, *s;
	int		i, status;
	char		seedfile[132];
	char		textfile[132];
	extern char	*getenv();
	char		*expr;
					

	sts = PI_S_SUCCESS;

	if( !strlen( info->plotfile ) )
		{
		sts = PI_F_FAIL;
		ex$message( msgnumb = HS_P_EntFlNme, buff = result );
		}
	else
		{
		strcpy( cmd, "qpr 2>&1 " );

		if( strlen( info->queue ) )
			{
			sprintf( buf, " -q %s ", info->queue );
			strcat( cmd, buf );
			}

		if( strlen( info->date ) )
			{
			sprintf( buf, " -a \"%s\" ", info->date );
			strcat( cmd, buf );
			}

		if( info->dpb_flags & HS_PLOT_MAIL_AT_BEGIN )
			{
			strcat( cmd, " -mb " );
			}

		if( info->dpb_flags & HS_PLOT_MAIL_AT_END )
			{
			strcat( cmd, " -me " );
			}

		if( info->con_flags & HP_CONTROL_SUBMIT_PLOTFILE )
			sprintf( buf, " -t HSplot " );
		else
			sprintf( buf, " -t igds " );
			
		strcat( cmd, buf );


		{
		OM_S_OBJID		mod_id;
		OMuword			mod_osnum;
		IGRlong			msg;
		IGRdouble		dxsize, dysize;
		IGRdouble		xsize, ysize;
	
		ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum );

		dxsize = 1.0 / info->size_x;
		dysize = 1.0 / info->size_y;
	
		status = co$cvt_exp_to_wrk(
					msg		= &msg,
					osnum		= mod_osnum,
					unit_type	= "UOM_DISTANCE",
					units		= dxsize,
					alias		= "in",
					result		= &xsize );
				
		status = co$cvt_exp_to_wrk(
					msg		= &msg,
					osnum		= mod_osnum,
					unit_type	= "UOM_DISTANCE",
					units		= dysize,
					alias		= "in",
					result		= &ysize );
				
		xsize = 1.0 / xsize;
		ysize = 1.0 / ysize;
	

		if( strlen( info->plotfile ) > 6 )
			{
			s = &info->plotfile[strlen(info->plotfile)-5];
		
			expr = getenv( "HSplot_DONT_PLOT" );
			if( expr != NULL && expr[0] == '1' )
				sprintf( buf, " -o \" -e %.3fx%.3f -z ", xsize, ysize );
			else
				sprintf( buf, " -o \" -e %.3fx%.3f ", xsize, ysize );
			}
		else
			{
			sprintf( buf, " -o \" -e %.3fx%.3f ", xsize, ysize );
			}
			
		if( info->con_flags & HP_CONTROL_SUBMIT_PLOTFILE )
			{
			if( info->copies > 1 )
				sprintf( buf, "%s -c %d ", buf, info->copies );
			
/*
			if( info->dpb_flags & HS_PLOT_BLACK_AND_WHITE )
				strcat( buf, " -b " );

			if( !(info->dpb_flags & HS_PLOT_WHITE_BACKGROUND) )
				strcat( buf, " -w " );
*/
				
			sprintf( buf2, " -l %1f ", info->line_width_const );
			strcat( buf, buf2 );
			
			sprintf( buf2, " -m %1d ", info->max_line_width );
			strcat( buf, buf2 );
			
			sprintf( buf2, " -k %1d ", info->raster_type );
			strcat( buf, buf2 );
			}
		
		strcat( buf, " \" " );

		strcat( cmd, buf );
		}

		if( info->con_flags & HP_CONTROL_SUBMIT_PLOTFILE )
			{
			status = HPverify( info->plotfile, 0 );
			if( status & 2 )
				{
				ex$message( msgnumb=HS_E_InvPltFl, buff=result );
				return( PI_F_FAIL );
				}
			else
				{
				if( status & 4 )
					{
					ex$message( msgnumb=HS_E_PltFlNtExst, buff=result );
					return( PI_F_FAIL );
					}
				else
					{
					if( info->con_flags & HP_CONTROL_SUBMIT_TEXTFILE )
						{
						status = HPverify( info->textfile, 8 );
						
						if( status & 2 )
							{
							sprintf( result, "Invalid textfile\n" );
							return( PI_F_FAIL );
							}
							
						if( status & 4 )
							{
							sprintf( result, "textfile does not exist\n" );
							return( PI_F_FAIL );
							}
							
						sprintf( buf, " -e TEXTFILE=%s ", 
							info->textfile );
							
						strcat( cmd, buf );
						}
						
					strcat( cmd, info->plotfile );
					}
				}
			}
		else
			{
			status = HPverify( info->rasterfile, 1 );
			if( status & 2 )
				{
				ex$message( msgnumb=HS_E_InvRaFl, buff=result );
				return( PI_F_FAIL );
				}

			if( status & 4 )
				{
				ex$message( msgnumb=HS_E_RaFlNtExst, buff=result );
				return( PI_F_FAIL );
				}

			sprintf( textfile, "/usr/tmp/HSplot.meta" );

			if( info->con_flags & HP_CONTROL_SUBMIT_TEXTFILE )
				{
				status = HPverify( info->textfile, 8 );
						
				if( status & 2 )
					{
					sprintf( result, "Invalid textfile\n" );
					return( PI_F_FAIL );
					}
							
				if( status & 4 )
					{
					sprintf( result, "textfile does not exist\n" );
					return( PI_F_FAIL );
					}
							
				HPcreate_textfile_with_raster_attachment( 
					info->textfile, 
					info->rasterfile, 
					textfile );
				}
			else
				{
				sprintf( seedfile, "/usr3/ingr/model/config/HSplot.seed" );

				status = HPfind_seedfile( seedfile );

				if( !status )
					{
					return( PI_F_FAIL );
					}

				HPcreate_textfile_with_raster_attachment( 
					seedfile, 
					info->rasterfile, 
					textfile );
				}

			sprintf( buf, " -e RASTERFILE=%s %s", info->rasterfile, textfile );
			strcat( cmd, buf );
			}

#		if DEBUG
		fprintf( stderr, "%s\n", cmd );
#		endif

		pp = popen( cmd, "r" );

		if( pp == NULL )
			{
			sts = PI_F_FAIL;
			
			ex$message( msgnumb = HS_E_CantExe,
				       type = "%s",
					var = `"qpr"`,
				       buff = result );
						
			}
		else
			{
			cmd[0] = NULL;

			/*
			 *  get feedback from request
			 */

			i = 0;
			c = getc( pp );
			while( c != 10 && c > 0 )
				{
				buf[i++] = c;
				if( i > 127 ) i = 127;
				c = getc( pp );
				}
				
			buf[i] = 0;
			
			sts = PI_S_SUCCESS;
			strncpy( result, buf, 128 );

			pclose( pp );
			}
		}

finish:

	return( sts );
	}
