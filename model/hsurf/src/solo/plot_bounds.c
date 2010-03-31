#include "hsurf_import.h"
#include <stdio.h>
#include <tools.h>
#include <sdl.h>

#define FALSE		0
#define TRUE		~FALSE

#define FULL		64224
#define HALF		32112

#define TICK_LENGTH	10

#define FWIN_SIZE	700
#define FWIN_OFFSET	15
#define FWIN_X_ORG	5
#define FWIN_Y_ORG	80

#define RWIN_SIZE	250
#define RWIN_OFFSET	15
#define RWIN_X_ORG	700
#define RWIN_Y_ORG	500

#define SWIN_SIZE	250
#define SWIN_OFFSET	15
#define SWIN_X_ORG	700
#define SWIN_Y_ORG	110


/***********************
 * WINDOW MANIPULATION *
 ***********************/

static int	w_no, sw_no, fw_no, rw_no;
static int	width;
static int	height;
static int	x_offset;
static int	y_offset;
static double	umin, vmin, umax, vmax, uscale, vscale;
static double	rumin, rvmin, rumax, rvmax, ruscale, rvscale;
static double	fumin, fvmin, fumax, fvmax, fuscale, fvscale;
static char	title[100];


/******************
 * INITIALIZATION *
 ******************/
 
static short	first_time=TRUE;
static short	single_step=TRUE;
static short	skip_to_next_facet=FALSE;
static short	skip_to_next_surface=FALSE;
static short	skip_to_next_region=FALSE;


/********************
 * USER INTERACTION *
 ********************/

static int	event_mask;


/**********************
 * COLOR MANIPULATION *
 **********************/

static int		start_slot;
static int		drawing_plane_mask;
static struct vlt_slot	save_vlt[512];
static int		entries, vs_no;



/****************************************************************************************
 * USER INTERACTION  ********************************************************************
 ****************************************************************************************/

/*--- get_input_from_user --------------------------------------------------------------*/

static void get_input_from_user( prompt, set_mode )

	char *prompt;
	short set_mode;
	
	{
	int	cef, area_no, x, y, button, transition, timetag;

/***
fprintf(stderr, "Entering GET_INPUT_FROM_USER...\n");
***/
	Enable_events( BUTTON_EVENT );
	Display_message( 4, CENTER, prompt );
	Wait_for_events( BUTTON_EVENT, &cef );
	Get_button_data( &area_no, &x, &y, &button, &transition, &timetag );
	if (set_mode)
	   if (transition==DOUBLE_CLICK)
	      if (single_step)
	         single_step = FALSE;
	      else
	         single_step = TRUE;
	   else
	      if (single_step)
	         switch (button) {
	            case(0):
	               break;
	            case(1):
	               skip_to_next_facet=TRUE;
	               break;
	            case(2):
	               single_step = FALSE;
	               break;
	            }
	      else
	         switch (button) {
	            case(0):
	               break;
	            case(1):
	               skip_to_next_region=TRUE;
	               break;
	            case(2):
	               skip_to_next_surface=TRUE;
	               break;
	            }
 	Clear_message( 4 );
/***
fprintf(stderr, "...Leaving GET_INPUT_FROM_USER\n");
***/
	}		


/*--- PBpause --------------------------------------------------------------*/

void PBpause()
	{
/***
fprintf(stderr, "Entering PBpause...\n");
***/
	if (single_step)
	   {
	   if (!skip_to_next_facet)
	      get_input_from_user( "Next Step  |  Next Facet  |  Normal Mode", TRUE );
	   }
	else
	   if ( (!skip_to_next_region) && (!skip_to_next_surface) )
	      get_input_from_user( "Next Facet  |  Next Region  |  Next Surface", TRUE );
/***
fprintf(stderr, "...Leaving PBpause.\n");
***/
	}


/*--- PBbadbnd --------------------------------------------------------------*/

void PBbadbnd()
	{
/***
fprintf(stderr, "Entering PBbadbnd...\n");
***/
	get_input_from_user( "BAD BOUNDARY: Hit button to continue ", FALSE );
/***
fprintf(stderr, "...Leaving PBbadbnd.\n");
***/
	}



/****************************************************************************************
 * WINDOW MANIPULATION  *****************************************************************
 ****************************************************************************************/
 
/*--- create_window --------------------------------------------------------------*/

static int	create_window( xmin, ymin, xmax, ymax )

int	xmin, ymin, xmax, ymax;

	{
	int	buffersize;
	int	efn;
	int	vs_no;
	int	no_planes, vlt_size;
	struct scr_info screen_info[MAX_SCREENS];
	
/***
fprintf(stderr, "Entering create_window...\n");
***/
	Inq_displayed_vs( &vs_no );
	Inq_screen_info( screen_info );

	Create_win( vs_no, title, xmin, ymin, xmax, ymax, &w_no );

	Display_win( w_no );
	Erase_win( w_no );

	buffersize = 512;
	allocef( &efn );
	openbuffer( w_no, efn, buffersize );
	enableplane( w_no, drawing_plane_mask );

/***
fprintf(stderr, "...Leaving create_window.\n");
***/
	}  /* create_window */
	

/*--- PBcreate_facet_window --------------------------------------------------------------*/

int	PBcreate_facet_window()

	{
	int     x_size, y_size;

/***
fprintf(stderr, "Entering PBcreate_facet_window...\n");
***/
	x_offset = y_offset = FWIN_OFFSET;
	width = height = FWIN_SIZE;
	
	x_size = FWIN_X_ORG + width + 2 * x_offset;
	y_size = FWIN_Y_ORG + height + 2 * y_offset;
	
	sprintf( title, "Facet (%3.1lf,%3.1lf) - (%3.1lf,%3.1lf)", umin, vmin, umax, vmax );
	create_window ( FWIN_X_ORG, FWIN_Y_ORG, x_size, y_size );
	fw_no = w_no;
/***
fprintf(stderr, "...Leaving PBcreate_facet_window\n");
***/
	}  /* PBcreate_facet_window */
	

/*--- PBcreate_region_window --------------------------------------------------------------*/

int	PBcreate_region_window()

	{
	int     x_size, y_size;

/***
fprintf(stderr, "Entering PBcreate_region_window...\n");
***/
	x_offset = y_offset = RWIN_OFFSET;
	width = height = RWIN_SIZE;
	
	x_size = RWIN_X_ORG + width + 2 * x_offset;
	y_size = RWIN_Y_ORG + height + 2 * y_offset;
	
	sprintf( title, "Region");
	create_window ( RWIN_X_ORG, RWIN_Y_ORG, x_size, y_size );
	rw_no = w_no;
/***
fprintf(stderr, "...Leaving PBcreate_region_window\n");
***/
	}  /* PBcreate_region_window */


/*--- PBcreate_surface_window --------------------------------------------------------------*/

static int	PBcreate_surface_window()

	{
	int     x_size, y_size;

/***
fprintf(stderr, "Entering PBcreate_surface_window...\n");
***/
	x_offset = y_offset = SWIN_OFFSET;
	width = height = SWIN_SIZE;
	
	x_size = SWIN_X_ORG + width + 2 * x_offset;
	y_size = SWIN_Y_ORG + height + 2 * y_offset;
	
	sprintf( title, "Surface" );
	create_window ( SWIN_X_ORG, SWIN_Y_ORG, x_size, y_size );
	sw_no = w_no;
/***
fprintf(stderr, "...Leaving PBcreate_surface_window\n");
***/
	}  /* PBcreate_surface_window */


/*--- PBenable_facet_window --------------------------------------------------------------*/

int	PBenable_facet_window()

	{
/***
fprintf(stderr, "Entering PBenable_facet_window...\n");
***/
	x_offset = y_offset = FWIN_OFFSET;
	width = height = FWIN_SIZE;
	umin = fumin; vmin = fvmin; umax = fumax; vmax = fvmax;
	uscale = fuscale; vscale = fvscale;
	w_no = fw_no;	
/***
fprintf(stderr, "...Leaving PBenable_facet_window\n");
***/
	}


/*--- PBenable_region_window --------------------------------------------------------------*/

int	PBenable_region_window()

	{
/***
fprintf(stderr, "Entering PBenable_region_window...\n");
***/
	x_offset = y_offset = RWIN_OFFSET;
	width = height = RWIN_SIZE;
	umin = rumin; vmin = rvmin; umax = rumax; vmax = rvmax;
	uscale = ruscale; vscale = rvscale;
	w_no = rw_no;	
/***
fprintf(stderr, "...Leaving PBenable_region_window\n");
***/
	}


/*--- PBenable_surface_window --------------------------------------------------------------*/

int	PBenable_surface_window()

	{
/***
fprintf(stderr, "Entering PBenable_surface_window...\n");
***/
	x_offset = y_offset = SWIN_OFFSET;
	width = height = SWIN_SIZE;
	umin = 0.0; vmin = 0.0; umax = 1.0; vmax = 1.0;
	uscale = vscale = 1.0;
	w_no = sw_no;	
/***
fprintf(stderr, "...Leaving PBenable_surface_window\n");
***/
	}


/*--- PBrefresh_window --------------------------------------------------------------*/

void PBrefresh_window()
	{
/***
fprintf(stderr, "Entering PBrefresh_window...\n");
***/
	if ( (single_step) && (w_no==fw_no) )
	   PBpause();
	flushbuffer( w_no );
/***
fprintf(stderr, "...Leaving PBrefresh_window\n");
***/
	}



/****************************************************************************************
 * COLOR MANIPULATION  ******************************************************************
 ****************************************************************************************/
 
/*--- load_colors --------------------------------------------------------------*/

static void load_colors()

	{
	struct vlt_slot vlt[512];
	int             i;
	int             no_planes, vlt_size;
	struct scr_info screen_info[MAX_SCREENS];
	
/***
fprintf(stderr, "Entering load_colors...\n");
***/
	Inq_displayed_vs( &vs_no );
	Inq_screen_info( screen_info );

	entries = screen_info[vs_no].vsi_vlt_size;
	start_slot = screen_info[vs_no].vsi_fixed_vlt_size + 1;

	if ( start_slot == 1 )
	   {
	   drawing_plane_mask = 0x0F;
	   }
	else
	   {
	   drawing_plane_mask = 0x1f;
	   }

	Readvlt( vs_no, save_vlt, entries, 0 );
	Readvlt( vs_no, vlt, entries, 0 );
	
	for ( i = start_slot + 0; i < start_slot + 15; i++ )
	   vlt[i].v_slot = i + 1;

	vlt[start_slot + 00].v_red = 0;     vlt[start_slot + 00].v_green = FULL;  vlt[start_slot + 00].v_blue = 0;
	vlt[start_slot + 01].v_red = FULL;  vlt[start_slot + 01].v_green = 0;     vlt[start_slot + 01].v_blue = 0;
	vlt[start_slot + 02].v_red = 0;     vlt[start_slot + 02].v_green = 0;     vlt[start_slot + 02].v_blue = FULL;
	vlt[start_slot + 03].v_red = FULL;  vlt[start_slot + 03].v_green = FULL;  vlt[start_slot + 03].v_blue = 0;
	vlt[start_slot + 04].v_red = 0;     vlt[start_slot + 04].v_green = FULL;  vlt[start_slot + 04].v_blue = FULL;
	vlt[start_slot + 05].v_red = FULL;  vlt[start_slot + 05].v_green = 0;     vlt[start_slot + 05].v_blue = FULL;
	vlt[start_slot + 06].v_red = FULL;  vlt[start_slot + 06].v_green = FULL;  vlt[start_slot + 06].v_blue = FULL;
	vlt[start_slot + 07].v_red = FULL;  vlt[start_slot + 07].v_green = FULL;  vlt[start_slot + 07].v_blue = HALF;
	vlt[start_slot + 08].v_red = HALF;  vlt[start_slot + 08].v_green = FULL;  vlt[start_slot + 08].v_blue = FULL;
	vlt[start_slot + 09].v_red = FULL;  vlt[start_slot + 09].v_green = HALF;  vlt[start_slot + 09].v_blue = FULL;
	vlt[start_slot + 10].v_red = HALF;  vlt[start_slot + 10].v_green = FULL;  vlt[start_slot + 10].v_blue = HALF;
	vlt[start_slot + 11].v_red = FULL;  vlt[start_slot + 11].v_green = HALF;  vlt[start_slot + 11].v_blue = HALF;
	vlt[start_slot + 12].v_red = HALF;  vlt[start_slot + 12].v_green = HALF;  vlt[start_slot + 12].v_blue = FULL;
	vlt[start_slot + 13].v_red = HALF;  vlt[start_slot + 13].v_green = FULL;  vlt[start_slot + 13].v_blue = 0;
	vlt[start_slot + 14].v_red = 0;     vlt[start_slot + 14].v_green = FULL;  vlt[start_slot + 14].v_blue = HALF;

	Loadvlt( vs_no, (&vlt[start_slot]), 15 );

/***
fprintf(stderr, "...Leaving load_colors\n");
***/
	}  /* load_colors */
	

/*--- PBset_color --------------------------------------------------------------*/

void PBset_color(color)
int color;
{
/***
fprintf(stderr, "Entering PBset_color...\n");
***/
	if (color > 12) color = 1;
	fgcolor( w_no, color + start_slot );
/***
fprintf(stderr, "...Leaving PBset_color\n");
***/
}



/****************************************************************************************
 * WINDOW MAPPING ***********************************************************************
 ****************************************************************************************/

/*--- map_uv_to_screen -----------------------------------------------------------*/

static void map_uv_to_screen( u, v, screen_u, screen_v, )

	double u;
	double v;
	int    *screen_u;
	int    *screen_v;
	
	{
/***
fprintf(stderr, "Entering map_uv_to_screen...\n");
***/
	u = (u - umin) * uscale;
	v = (v - vmin) * vscale;
	
	*screen_u = (u * width) + x_offset;
	*screen_v = (height - (v * height)) + y_offset;

/***
fprintf(stderr, "...Leaving map_uv_to_screen\n");
***/
	}  /* map_uv_to_screen */


/*--- set_outcodes --------------------------------------------------------------*/

static short set_outcodes( u, v )

	double u;
	double v;
	
	{
/***
fprintf(stderr, "Entering set_outcodes...\n");
***/
	return(   ( (vmax - v) < 0.0 )        |
		( ( (v - vmin) < 0.0 ) << 1 ) |
	        ( ( (umax - u) < 0.0 ) << 2 ) |
	        ( ( (u - umin) < 0.0 ) << 3 ) );

/***
fprintf(stderr, "...Leaving set_outcodes\n");
***/
	} /* set_outcodes */
	         


/****************************************************************************************
 * DRAW POINT ***************************************************************************
 ****************************************************************************************/

/*--- PBdraw_point --------------------------------------------------------------*/

void PBdraw_point( u, v )

	double u;
	double v;
	
	{
	short code;
	int   screen_u;
	int   screen_v;
	
/***
fprintf(stderr, "Entering PBdraw_point...\n");
***/
	weight( w_no, 2 );
 	code = set_outcodes( u, v );
	if ( code == 0 )
	   {
	   map_uv_to_screen( u, v, &screen_u, &screen_v );
	   pnt( w_no, screen_u, screen_v );
	   }
	weight( w_no, 0 );
/***
fprintf(stderr, "...Leaving PBdraw_point\n");
***/
	}  /* PBdraw_point */


/*--- PBdraw_big_point --------------------------------------------------------------*/

void PBdraw_big_point( u, v )

	double u;
	double v;
	
	{
	short code;
	int   screen_u;
	int   screen_v;
	
/***
fprintf(stderr, "Entering PBdraw_big_point...\n");
***/
	weight( w_no, 4 );
 	code = set_outcodes( u, v );
	if ( code == 0 )
	   {
	   map_uv_to_screen( u, v, &screen_u, &screen_v );
	   pnt( w_no, screen_u, screen_v );
	   }
	weight( w_no, 0 );
/***
fprintf(stderr, "...Leaving PBdraw_big_point\n");
***/
	}  /* PBdraw_big_point */



/****************************************************************************************
 * DRAW LINE ****************************************************************************
 ****************************************************************************************/

/*--- draw_line --------------------------------------------------------------*/

static void draw_line( u0, v0, u1, v1 )

	double u0;
	double v0;
	double u1;
	double v1;
	
	{
	int screen_u;
	int screen_v;
	
/***
fprintf(stderr, "Entering draw_line...\n");
***/
	map_uv_to_screen( u0, v0, &screen_u, &screen_v );
	move( w_no, screen_u, screen_v );
	
	map_uv_to_screen( u1, v1, &screen_u, &screen_v );
	draw( w_no, screen_u, screen_v );
/***
fprintf(stderr, "...Leaving draw_line\n");
***/
	}  /* draw_line */


/*--- PBclip_and_draw_line -------------------------------------------------------*/

void PBclip_and_draw_line( u0, v0, u1, v1 )

	double u0;
	double v0;
	double u1;
	double v1;
	
	{
	short  accept;
	short  done;
	short  code0;
	short  code1;
	short  temp_b;
	double temp_d;
	
/***
fprintf(stderr, "Entering PBclip_and_draw_line...\n");
***/
	accept = done = FALSE;
	do
	   {
	   code0 = set_outcodes( u0, v0 );
	   code1 = set_outcodes( u1, v1 );

	   if ( code0 & code1 )
	      done = TRUE;       /* trivial rejection */
	   else
	      {
	      accept = ( (code0 == 0) && (code1 == 0) );
	      if ( accept )
	         done = TRUE;    /* trivial acceptance */
	      else
	         {
	         if ( ! code0 )
	            {
	            /* swap to make (u0, v0) outside of window */
	            temp_d = u0; u0 = u1; u1 = temp_d;
	            temp_d = v0; v0 = v1; v1 = temp_d;
	            temp_b = code0; code0 = code1; code1 = temp_b;
	            }
	            
	         if ( code0 & 1 )
	            {
	            /* clip to top */
	            u0 = u0 + (u1 - u0) * (vmax - v0) / (v1 - v0);
	            v0 = vmax;
	            }
	         else if ( code0 & 2 )
	            {
	            /* clip to bottom */
	            u0 = u0 + (u1 - u0) * (vmin - v0) / (v1 - v0);
	            v0 = vmin;
	            }
	         else if ( code0 & 4 )
	            {
	            /* clip to right */
	            v0 = v0 + (v1 - v0) * (umax - u0) / (u1 - u0);
	            u0 = umax;
	            }
	         else if ( code0 & 8 )
	            {
	            /* clip to left */
	            v0 = v0 + (v1 - v0) * (umin - u0) / (u1 - u0);
	            u0 = umin;
	            }
	         }
	      }
	   }
	while ( ! done );
	
	if ( accept )
	   draw_line( u0, v0, u1, v1 );
	   
/***
fprintf(stderr, "...Leaving PBclip_and_draw_line\n");
***/
	}  /* PBclip_and_draw_line */
	            

/*--- PBdraw_bound_line -------------------------------------------------------*/

void PBdraw_bound_line( u0, v0, u1, v1 )

	double u0;
	double v0;
	double u1;
	double v1;
	
	{
/***
fprintf(stderr, "Entering  PBdraw_bound_line...\n");
***/
	PBdraw_point( u0, v0 );
	PBclip_and_draw_line( u0, v0, u1, v1 );
/***
fprintf(stderr, "...Leaving PBdraw_bound_line\n");
***/
	}

	
/*--- PBdraw_uv_border --------------------------------------------------------------*/

static void PBdraw_uv_border()

	{
	int    x,y;
	int    screen_u, screen_v;
	short  code;
	double d;
	

/***
fprintf(stderr, "Entering  PBdraw_uv_border...\n");
***/
	PBset_color(3);

	/* draw uv space border */
	PBclip_and_draw_line( umin, vmin, umax, vmin );
	PBclip_and_draw_line( umax, vmin, umax, vmax );
	PBclip_and_draw_line( umax, vmax, umin, vmax );
	PBclip_and_draw_line( umin, vmax, umin, vmin );

	/* draw grid lines */
	for ( d = 0.0; d <= 1.0; d += 0.1 )
	   {
	   code = set_outcodes( d, vmin );
	   if ( code == 0 )
	      {
	      map_uv_to_screen( d, vmin, &screen_u, &screen_v );
	      move( w_no, screen_u, screen_v );
	      draw( w_no, screen_u, screen_v + TICK_LENGTH );
	      }
	   }
	for ( d = 0.0; d <= 1.0; d += 0.1 )
	   {
	   code = set_outcodes( d, vmax );
	   if ( code == 0 )
	      {
	      map_uv_to_screen( d, vmax, &screen_u, &screen_v );
	      move( w_no, screen_u, screen_v );
	      draw( w_no, screen_u, screen_v - TICK_LENGTH );
	      }
	   }

	for ( d = 0.0; d <= 1.0; d += 0.1 )
	   {
	   code = set_outcodes( umin, d );
	   if ( code == 0 )
	      {
	      map_uv_to_screen( umin, d, &screen_u, &screen_v );
	      move( w_no, screen_u, screen_v );
	      draw( w_no, screen_u - TICK_LENGTH, screen_v );
	      }
	   }

	for ( d = 0.0; d <= 1.0; d += 0.1 )
	   {
	   code = set_outcodes( umax, d );
	   if ( code == 0 )
	      {
	      map_uv_to_screen( umax, d, &screen_u, &screen_v );
	      move( w_no, screen_u, screen_v );
	      draw( w_no, screen_u + TICK_LENGTH, screen_v );
	      }
	   }

	flushbuffer( w_no );
	
/***
fprintf(stderr, "...Leaving draw_uv_border\n");
***/
	}  /* draw_uv_border */



/****************************************************************************************
 * INITIALIZATION ***********************************************************************
 ****************************************************************************************/

/*--- PBinit --------------------------------------------------------------*/

void PBinit()
	{
/***
fprintf(stderr, "Entering PBinit...\n");
***/
	if (first_time)
	   {
	   Set_message_mode( 4 );
	   Inq_enabled_events(&event_mask);
	   Display_message( 2, CENTER, "PLOTTING BOUNDARIES" );
 	   load_colors();
	   PBcreate_facet_window();
	   PBcreate_region_window();
	   PBcreate_surface_window();
	   hidecursor(rw_no);
	   hidecursor(sw_no);
	   umin = vmin = 0.0;
	   umax = vmax = uscale = vscale = 1.0;
	   first_time = FALSE;
	   }
	else
	   {
	   Erase_win(fw_no);
	   Erase_win(rw_no);
	   Erase_win(sw_no);
	   }

	PBdraw_uv_border();

	PBrefresh_window();
/***
fprintf(stderr, "...Leaving PBinit\n");
***/
	}


/*--- PBinit_facet_window --------------------------------------------------------------*/

int	PBinit_facet_window( u0, v0, u1, v1 )

double u0,v0,u1,v1;

	{
	double du, dv;
	
/***
fprintf(stderr, "Entering  PBinit_facet_window...\n");
***/
	du = u1 - u0;
	dv = v1 - v0;
	
	fumin = umin = u0 - (du / 8.0);
	fvmin = vmin = v0 - (dv / 8.0);
	fumax = umax = u1 + (du / 8.0);
	fvmax = vmax = v1 + (dv / 8.0);
	
	fuscale = uscale = 1.0 / ( umax - umin );
	fvscale = vscale = 1.0 / ( vmax - vmin );

	PBenable_facet_window();
	Erase_win(fw_no);
	sprintf( title, "Facet (%4.2lf,%4.2lf) - (%4.2lf,%4.2lf)", u0, v0, u1, v1 );
	Set_win_name( fw_no, title );
	PBdraw_uv_border();
	skip_to_next_facet = FALSE;
/***
fprintf(stderr, "...Leaving PBinit_facet_window\n");
***/
	}


/*--- PBinit_region_window --------------------------------------------------------------*/

int	PBinit_region_window( u0, v0, u1, v1 )

double u0,v0,u1,v1;

	{
	double du, dv;
	
/***
fprintf(stderr, "Entering  PBinit_region_window...\n");
***/
	du = u1 - u0;
	dv = v1 - v0;
	
	rumin = umin = u0 - (du / 8.0);
	rvmin = vmin = v0 - (dv / 8.0);
	rumax = umax = u1 + (du / 8.0);
	rvmax = vmax = v1 + (dv / 8.0);
	
	ruscale = uscale = 1.0 / ( umax - umin );
	rvscale = vscale = 1.0 / ( vmax - vmin );

	PBenable_region_window();
	Erase_win(rw_no);
	sprintf( title, "Region");
	Set_win_name( rw_no, title );
	PBdraw_uv_border();
	skip_to_next_region = FALSE;
/***
fprintf(stderr, "...Leaving PBinit_region_window\n");
***/
	}



/****************************************************************************************
 * CLEANUP ******************************************************************************
 ****************************************************************************************/

/*--- PBexit --------------------------------------------------------------*/

void PBexit()
	{
	IGRint	vs_no;

/***
fprintf(stderr, "Entering  PBexit...\n");
***/
	Inq_displayed_vs( &vs_no );
	PBrefresh_window(fw_no);
	PBrefresh_window(rw_no);
	PBrefresh_window(sw_no);
	if ( (!skip_to_next_facet) && (!skip_to_next_surface) && (!skip_to_next_region) )
	   get_input_from_user( "SURFACE IS COMPLETED: hit button to continue ", FALSE );
	Delete_win( fw_no );
	Delete_win( rw_no );
	Delete_win( sw_no );
	Loadvlt( vs_no, save_vlt, entries );
	Enable_events( event_mask );
	Clear_message( 2 );
	first_time = TRUE;
	skip_to_next_surface = FALSE;
	skip_to_next_region = FALSE;
	skip_to_next_facet = FALSE;
/***
fprintf(stderr, "...Leaving PBexit\n");
***/
	}


