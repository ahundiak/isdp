/*
DESCRIPTION
	rle_view
	
	   - View a type 27 or 29 RLE file or the difference between two rle files
	   
	   Options:
	   
	      -f [file1] -f [file2] -b [flag]: difference two files
					       set flag to "v" for verbose	   
 	      -f [file]               	     : view a single file

HISTORY
	S.P. Rogers  11/24/89  Creation Date
	
	Yvonne Chu   7/1/92    Modified to run non-interactively 
*/	    

#include <stdio.h>
#include <tools.h>
#include <sdl.h>
#include <math.h>

#include "rle_view.h"

short      true_color;
static int x_dits, y_dits;
#ifndef X11
static int indexed_vltno, true_color_vltno;

static char   keyin_buffer[100];
static int    chars_in_buffer;
#endif
static int    verbose = 0;
int    	   batch = 0;

#define	GAMMA 2.2
#define ONE 65535
#define D_ONE 65535.0
#define TRUE 1

/*--------HScolor_compensate-------------------------------------------------*/

/* Given an intensity value in the range [0..65535], return a corresponding*/
/*   compensated or uncompensated value, depending on the "convert_opt"    */
/*   flag.                                                                 */

int HScolor_compensate(intensity, convert_opt)
  int intensity;	/* intensity value - uncompensated or compensated */
  int convert_opt;	/* [0] compensate or [1] uncompensate intensity */
  {
    double temp;	/* intermediate temporary value */

    if (intensity <= 0)
      return (0);
    else if (intensity >= ONE)
      return (ONE);
    else
      {
        if (convert_opt == 1)	/* convert compensated intensity */
          {			/*   to uncompensated intensity  */
            temp = pow (((double)(intensity) / D_ONE), (GAMMA));
            return((int)((temp * D_ONE) + 0.5));
          }
        else	/* convert uncompensated intensity to compensated intensity */
          {
            temp = pow (((double)(intensity) / D_ONE), (1.0 / GAMMA));
            return((int)((temp * D_ONE) + 0.5));
          }
      }
  }	/* HScolor_compensate */


/*--- create_window --------------------------------------------------------------*/

static void create_window( w_no )

	int *w_no;

	{
#ifdef X11
        fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	int             vs_no;
	struct scr_info screen_info[MAX_SCREENS];
	struct vlt_slot vlt[256];
	int comp_int;
	int ii;

	/* construct a hardware window that covers the entire screen 	*/
	Inq_displayed_vs( &vs_no );
	Inq_screen_info( screen_info );

	true_color = screen_info[vs_no].vsi_flags & VSI_TRC_ABILITY;

	x_dits = screen_info[vs_no].vsi_x;
	y_dits = screen_info[vs_no].vsi_y - MESSAGE_STRIP_HEIGHT;

	Create_win_no_border( vs_no, 0, 0, x_dits-1, y_dits-1, w_no );

	Inq_activevltno( *w_no, &indexed_vltno );

	if ( true_color )
	   {
	   Alloc_vlt( TRUE_COLOR_VLT, &true_color_vltno );

	   for ( ii = 0; ii < 256; ii++ )
	      {
	      vlt[ii].v_slot = ii;

	      comp_int = HScolor_compensate( (ii << 8), 0 );
	      vlt[ii].v_red = vlt[ii].v_green = vlt[ii].v_blue = comp_int;
	      }

	   Load_allocated_vlt( vs_no, true_color_vltno, vlt, 256 );
	   }

	Display_win( *w_no );
	flushbuffer( *w_no );
#endif
	}  /* create_window */


/*--- load_diff_vlt --------------------------------------------------------------*/

static void load_diff_vlt( start_slot, num_levels )

	int *start_slot;
	int *num_levels;

	{
#ifdef X11
        fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	struct vlt_slot vlt[256];
	int             i, col, slot, vs_no;
	struct scr_info screen_info[MAX_SCREENS];

	Inq_displayed_vs( &vs_no );
	Inq_screen_info( screen_info );

	*start_slot = slot = (screen_info[vs_no].vsi_num_planes > 5) ? 15 : 0;
	*num_levels = (screen_info[vs_no].vsi_num_planes > 5) ? 240 : 16;

	for ( i = 0, col = 0; i < (*num_levels); i++, slot++, col += (65535/(*num_levels)) )
	   {
	   vlt[i].v_slot = slot;
	   vlt[i].v_red = vlt[i].v_green = vlt[i].v_blue = col;
	   }

	Loadvlt( vs_no, vlt, *num_levels );
#endif
	}  /* load_diff_vlt */


/*--- get_keyin_from_user --------------------------------------------------------------*/

static void get_keyin_from_user( prompt )

	char *prompt;
	
/*
Abstract
	Prompt the user for a keyin in message strip 1
*/

	{
#ifndef X11
	int	cef;
#endif

	if ( batch )
	   {
	   fprintf(stderr, "%s\n", prompt);
	   }
 	else
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Enable_events( KEYIN_EVENT );
	   Process_keyin( 1, LEFT, prompt );
	   Wait_for_events( KEYIN_EVENT, &cef );
	   Get_keyin_data( &chars_in_buffer );
	   keyin_buffer[chars_in_buffer] = '\0';
#endif
	   }
	}		

	   
/*--- calc_and_display_rgb_diff_true_color --------------------------------------------------------------------*/

static void calc_and_display_rgb_diff_true_color( image0, image1, w_no )

	struct image_info *image0, *image1;
	int               w_no;

/*
DESCRIPTION
	This function calculates and displays in gray scale the difference in RGB space
	between two RLE files.
*/

	{
#ifndef BIG_ENDIAN
	char  string[256];
	int   row, col;
	int   dr, dg, db;
	int   max_diff;
	int   *diff_line;
	int   index;

	if ( (image0->num_rows != image1->num_rows) || (image0->num_cols != image1->num_cols) )
	   {
	   get_keyin_from_user( "Images are different sizes => Can't calculate difference - RETURN to exit " );
	   return;
	   }

	if ( batch )
	   {
	   if ( verbose )
	      fprintf( stderr, "Calculating difference between images ...\n" );
	   }
	else
 	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Display_message( 1, LEFT, "Calculating difference between images ... " );
	   hidecursor( w_no );
#endif
	   }

	diff_line = (int *) malloc( image0->num_cols * sizeof( int ) );
	max_diff = 0;
	index = 0;
	for ( row = 0; row < image0->num_rows; row++ )
	   {
	   for ( col = 0; col < image0->num_cols; col++ )
	      {
	      dr = image0->red[index] - image1->red[index];
	      if ( dr < 0 ) dr *= -1.0;
	      dg = image0->green[index] - image1->green[index];
	      if ( dg < 0 ) dg *= -1.0;
	      db = image0->blue[index] - image1->blue[index];
	      if ( db < 0 ) db *= -1.0;

	      diff_line[col] = (db << 16) | (dg << 8) | dr;

	      if ( max_diff < (dr*dr + dg*dg + db*db) )
	         max_diff = (dr*dr + dg*dg + db*db);

	      index++;
	      }
	   if ( !batch )
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      putlinedata( w_no, 0, row, image0->num_cols-1, row, IMAGE_DATA, diff_line );
#endif
	   }
	   
	sprintf( string, "Maximum RGB-space distance: %lf\n", sqrt( (double) max_diff) );
	if ( batch)
	   fprintf( stderr, "%s\n", string );
	else
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Display_message( 1, LEFT, string );
	   showcursor( w_no );
	   flushbuffer( w_no );
#endif
	   }

	strcat( string, " - RETURN to exit" );
	get_keyin_from_user( string );

#endif
	}  /* calc_and_display_rgb_diff_true_color */


/*--- calc_and_display_rgb_diff_indexed --------------------------------------------------------------------*/

static void calc_and_display_rgb_diff_indexed( image0, image1, w_no, low, high, plane_mask )

	struct image_info *image0, *image1;
	int               w_no;
	double            low, high;
	int               plane_mask;

/*
DESCRIPTION
	This function calculates and displays in gray scale the difference in RGB space
	between two RLE files.
*/

	{
#ifndef BIG_ENDIAN
	char   string[256];
	int    row, col;
	int    dr, dg, db;
	int    max_diff;
	int    *diff_buf;
	int    index;
	short  *diff_line;
	double diff_scale;
	int    start_slot;
	int    num_levels;

	if ( (image0->num_rows != image1->num_rows) || (image0->num_cols != image1->num_cols) )
	   {
	   get_keyin_from_user( "Images are different sizes => Can't calculate difference - RETURN to exit " );
	   return;
	   }

	if ( batch )
	   {
	   if ( verbose )
	      fprintf( stderr, "Calculating difference between images ...\n" );
	   }
	else
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Display_message( 1, LEFT, "Calculating difference between images ... " );
#endif

	diff_buf = (int *) malloc( image0->num_rows * image0->num_cols * sizeof( int ) );
	max_diff = 0;
	index = 0;
	for ( row = 0; row < image0->num_rows; row++ )
	   {
	   for ( col = 0; col < image0->num_cols; col++ )
	      {
	      dr = image0->red[index] - image1->red[index];
	      dg = image0->green[index] - image1->green[index];
	      db = image0->blue[index] - image1->blue[index];

	      diff_buf[index] = dr*dr + dg*dg + db*db;
	      if ( max_diff < diff_buf[index] )
	         max_diff = diff_buf[index];

	      index++;
	      }
	   }
	   
	if ( max_diff <= low )
	   {
	   get_keyin_from_user( "No differences - RETURN TO EXIT" );
	   return;
	   }

	/* colormode( w_no, INDEXED_COLOR ); */
#ifdef X11
        fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	load_diff_vlt( &start_slot, &num_levels );
#endif

	if ( high < 0.0 )
	   diff_scale = (num_levels - 1.0) / sqrt((double)max_diff);
	else
	   diff_scale = (num_levels - 1.0) / high;

	sprintf( string, "Maximum RGB-space distance: %lf\n", sqrt( (double) max_diff) );
	if ( batch )
	   fprintf( stderr, "%s\n", string );
	else
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Display_message( 1, LEFT, string );
#endif

	diff_line = (short *) malloc( image0->num_cols * sizeof( short ) );
	index = 0;
	if ( !batch )
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   hidecursor( w_no );
#endif
	for ( row = 0; row < image0->num_rows; row++ )
	   {
	   for ( col = 0; col < image0->num_cols; col++ )
	      {
	      diff_line[col] = (sqrt((double) diff_buf[index]) - low) * diff_scale;
	      if ( diff_line[col] <= 0 )
	         diff_line[col] = 0;
	      else if ( diff_line[col] >= num_levels )
	         diff_line[col] = num_levels - 1;

	      diff_line[col] += start_slot;

	      index++;
	      }
	   if ( !batch )
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      putline16( w_no, plane_mask, 0, row, image0->num_cols-1, row, diff_line );
#endif
	   }

	if ( !batch )
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   showcursor( w_no );
	   flushbuffer( w_no );
#endif
	   }

	strcat( string, " - RETURN to exit" );
	get_keyin_from_user( string );

#endif
	}  /* calc_and_display_rgb_diff_indexed */


/*--- calc_and_display_index_diff --------------------------------------------------------------------*/

static void calc_and_display_index_diff( image0, image1, w_no, low, high, plane_mask )

	struct image_info *image0, *image1;
	int               w_no;
	double            low, high;
	int               plane_mask;

/*
DESCRIPTION
	This function calculates and displays in gray scale the difference in VLT indices
	between two RLE files.
*/

	{
#ifndef BIG_ENDIAN
	char   string[256];
	int    row, col;
	int    max_diff;
	int    *diff_buf;
	int    index;
	short  *diff_line;
	double diff_scale;
	int    start_slot;
	int    num_levels;

	if ( (image0->num_rows != image1->num_rows) || (image0->num_cols != image1->num_cols) )
	   {
	   get_keyin_from_user( "Images are different sizes => Can't calculate difference - RETURN to exit " );
	   return;
	   }

	if ( batch )
	   {
	   if ( verbose )
	      fprintf( stderr, "Calculating difference between images ...\n" );
	   }
	else
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Display_message( 1, LEFT, "Calculating difference between images ... " );
#endif

	diff_buf = (int *) malloc( image0->num_rows * image0->num_cols * sizeof( int ) );
	max_diff = 0;
	index = 0;
	for ( row = 0; row < image0->num_rows; row++ )
	   {
	   for ( col = 0; col < image0->num_cols; col++ )
	      {
	      diff_buf[index] = image0->index_buf[index] - image1->index_buf[index];
	      if ( diff_buf[index] < 0 )
	         diff_buf[index] = -diff_buf[index];

	      if ( max_diff < diff_buf[index] )
	         max_diff = diff_buf[index];

	      index++;
	      }
	   }
	   
	if ( max_diff <= low )
	   {
	   get_keyin_from_user( "No differences - RETURN TO EXIT" );
	   return;
	   }

#ifdef X11
        fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	load_diff_vlt( &start_slot, &num_levels );
#endif

	if ( high < 0.0 )
	   diff_scale = (num_levels - 1.0) / (double)max_diff;
	else
	   diff_scale = (num_levels - 1.0) / high;

	sprintf( string, "Maximum VLT Index difference: %d\n", max_diff );
	if ( !batch )
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Display_message( 1, LEFT, string );
#endif

	diff_line = (short *) malloc( image0->num_cols * sizeof( short ) );
	index = 0;
	if ( !batch )
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   hidecursor( w_no );
#endif
	for ( row = 0; row < image0->num_rows; row++ )
	   {
	   for ( col = 0; col < image0->num_cols; col++ )
	      {
	      diff_line[col] = ((double) diff_buf[index] - low) * diff_scale;
	      if ( diff_line[col] <= 0 )
	         diff_line[col] = 0;
	      else if ( diff_line[col] >= num_levels )
	         diff_line[col] = num_levels - 1;

	      diff_line[col] += start_slot;

	      index++;
	      }
	   if ( !batch )
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      putline16( w_no, plane_mask, 0, row, image0->num_cols-1, row, diff_line );
#endif
	   }

	if ( !batch )
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   showcursor( w_no );
	   flushbuffer( w_no );
#endif
	   }

	strcat( string, " - RETURN to exit" );
	get_keyin_from_user( string );

#endif
	}  /* calc_and_display_index_diff */


/*--- main --------------------------------------------------------------------------*/

main( argc, argv )

	int argc;
	char *argv[];
	
	{
	FILE              *fp;
	char              c, string[256];
	struct image_info image_data[2];
	int               file_count, i;
	int               w_no, plane_mask;
	int               up_left_x, up_left_y;
	double            low,high;
	extern char       *optarg;
#ifndef X11
	int               vs_no;
	struct vlt_info   vlt_info;
#endif

	file_count = 0;
	low = 0;
	high = -1.0;

	while ( (c = getopt( argc, argv,"f:l:h:b:" ) ) != EOF)
	   {
	   switch(c)
	      {
	      case 'f':

	         strcpy( image_data[file_count++].name, optarg );
	         break;

	      case 'l':

	         sscanf( optarg, "%lf", &low );
	         break;

	      case 'h':

	         sscanf( optarg, "%lf", &high );
	         break;

	      case 'b':
		  
		 batch = 1;
		 if (!strcmp(optarg, "v"))
		    verbose = 1;
	         break;

	      }

	   }				

	if ( file_count == 0 )
	   {
	   fprintf( stderr, "USAGE: rle_view -f file1 OR rle_view -f file1 -f file2\n" );
	   return;
	   }

	if ( batch )
	   true_color = 1; 	/* irrelevant, only used for display */
	else
	   {
#ifdef X11
	   fprintf( stderr, "rle_view: Not ported to X yet\n" ); 
#else
	   Enter_tools();

	   Inq_displayed_vs( &vs_no );

	   if ( file_count == 1 )
	      Set_logo( "VIEW" );
	   else
	      Set_logo( "DIFF" );

	   create_window( &w_no  );

	   Set_message_mode( 1 );
	   Set_keyin_buffer( keyin_buffer, sizeof( keyin_buffer ) );
#endif
	   }

	for ( i = 0; i < file_count; i++ )
	   {
	   fp = fopen( image_data[i].name, "r" );
	   if ( fp == NULL )
	         {
	         sprintf( string, "File: %s could not be opened for read access", image_data[i].name );
		 if ( batch )
		    fprintf(stderr, "%s\n", string);
		 else
#ifdef X11
            	    fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	            Error_box( 0, string, 2 );
#endif
	         return;
	         }	    
	   fclose( fp );
	   }
	
	for ( i = 0; i < file_count; i++ )
	   {
	   sprintf( string, "Reading file: %s ... ", image_data[i].name );
	   if ( batch )
	      {
	      if ( verbose )
	         fprintf(stderr, "%s\n", string);
	      }
	   else
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      Display_message( 1, LEFT, string );
#endif
	      
	   read_rle_file( &image_data[i] );
	   
	   if ( !batch )
	      {
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      if ( (image_data[i].rle_type == TYPE_27) && (true_color) )
	         {
	         activevltno( w_no, true_color_vltno );
	         Inq_vlt_info( vs_no, TRUE_COLOR_DATA, &vlt_info );
	         plane_mask = (1 << vlt_info.vlti_num_planes) - 1;
	         enabledata( w_no, IMAGE_DATA, plane_mask );
	         }
	      else
	         {
	         activevltno( w_no, indexed_vltno );
	         Inq_vlt_info( vs_no, INDEXED_COLOR_DATA, &vlt_info );
	         plane_mask = (1 << vlt_info.vlti_num_planes) - 1;
	         enabledata( w_no, IMAGE_DATA, plane_mask );
	         }
#endif
	      }

	   if ( !batch )
	      {
	      up_left_x = (x_dits - image_data[i].num_cols) / 2;
	      up_left_y = (y_dits - image_data[i].num_rows) / 2;
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      hidecursor( w_no );
	      if ( (true_color) && (image_data[i].rle_type == TYPE_27) )
	         {
	         putblockdata( w_no, up_left_x, up_left_y, 
			up_left_x + image_data[i].num_cols - 1, 
			up_left_y + image_data[i].num_rows - 1,
	               	IMAGE_DATA, image_data[i].index_buf );
	         }
	      else
	         {
	         putpixelblock32( w_no, plane_mask, up_left_x, up_left_y,
	              	up_left_x + image_data[i].num_cols - 1, 
			up_left_y + image_data[i].num_rows - 1,
	               	image_data[i].index_buf );
	         }

	      showcursor( w_no );
	      flushbuffer( w_no );
#endif
	      }

	   if ( file_count == 1 )
	      strcpy( string, "RETURN to exit " );
	   else if ( i == 0 )
	      strcpy( string, "RETURN for next file " );
	   else
	      strcpy( string, "RETURN for difference " );

	   if ( !batch || verbose ) 
	      get_keyin_from_user( string );

	   if ( !batch )
	      {
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      Erase_win( w_no );
#endif
	      } 
	   }

	if ( file_count == 1 )
	   return;
 
	if ( (image_data[0].rle_type == TYPE_27) && (image_data[1].rle_type == TYPE_27) )
	   if ( true_color )
	      calc_and_display_rgb_diff_true_color( &image_data[0], &image_data[1], w_no );
	   else
	      calc_and_display_rgb_diff_indexed( &image_data[0], &image_data[1], w_no, low, high, plane_mask );
	else if ( (image_data[0].rle_type == image_data[1].rle_type) &&
	          (image_data[0].rle_type == TYPE_29 ||
	           image_data[0].rle_type == TYPE_10 ||
	           image_data[0].rle_type == TYPE_26) )
	      calc_and_display_index_diff( &image_data[0], &image_data[1], w_no, low, high, plane_mask );
	
	}

