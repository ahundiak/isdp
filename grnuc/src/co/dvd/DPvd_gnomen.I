class implementation DPvd;

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <FI.h>

#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "dl.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igecolordef.h"

#include "grmsg.h"

#include "EMdtmacros.h"
#include "EMSdatumdef.h"

#include "dpgraphics.h"

#include "DPvd.h"

extern IGRdouble MAsqrt();
#define DPvd_GN_DEFAULT_SIZE 20
#define MODE_FLAG   0x30

%safe

#include "maptsxfor.h"  /* prototype files */

static WLuint32 gn_lwin_no=WL_UNDEFINED_WINDOW;	   /* window to display GN */
static int gn_size;		                   /* size of the larger rect */
static IGRdouble gn_loc_wld[3];                    /* location in wld */
static IGRdouble gn_loc_vwport[3];                 /* location in vwport */
static struct WLrect  gn_rect1, gn_rect2;          /* large and small rect */
static struct WLpoint gn_x[2];                     /* short x line */
static struct WLpoint gn_y[2];                     /* short y line */
static struct WLpoint gn_xp[3],gn_yp[3];           /* x,y arrow */
static struct WLpoint gn_cmode_x[5],gn_cmode_y[5]; /* cont mode nod */
static struct WLrect  gn_smode_x,gn_smode_y;       /* step mode nod */
static struct WLpoint gn_free_line[3];             /* rotation axis line,
                                                      arrow */
static struct WLpoint gn_elem_line[2],gn_elem_arrow[3]; /* element tangent */
static struct WLbounds gn_win_area_bounds;

static int gn_mode=0x0000;   /* DPvd_DRAG,DPvd_STEP,DPvd_CONT */
static int gn_align;         /* values see gnomen areas defines */

static int gn_line_style;
static int gn_line_weight;

%endsafe

extern IGRboolean dynamics_in_progress;

void DPvd_set_GN_size(int size)
/*
NAME
        DPvd_set_GN_size

DESCRIPTION
        Set the size of GN, which is the number of pixels of the width (length)
	of the larger square of the GN. If not set, a default value will be
	used to draw the GN.

SYNOPSIS
        void DPvd_set_GN_size(int size)

PARAMETERS
        size (IN) - number of pixels of one side the larger square.

GLOBALS USED
RETURN VALUES
NOTES
HISTORY
	06/20/93    T. Wang
*/
{
    gn_size = size;
}



int DPvd_get_GN_size(void)
/*
NAME
        DPvd_set_GN_size

DESCRIPTION
        Get the size of GN, which is the number of pixels of the width (length)
	of the larger square of the GN. 

SYNOPSIS
        int DPvd_get_GN_size(void)

PARAMETERS
GLOBALS USED
RETURN VALUES
NOTES
        See also DPvd_set_GN_size()
HISTORY
	06/20/93    T. Wang
*/
{
    if(gn_size == 0)
      return(DPvd_GN_DEFAULT_SIZE);
    else
      return(gn_size);
}




void DPvd_draw_GN(struct DPvd_draw_GN_t *draw_info, 
                  int clear_first,
                  int use_hilite)
/*
NAME
        DPvd_draw_GN
DESCRIPTION
        Draw Gnomen and rubber band.

SYNOPSIS
        void DPvd_draw_GN(struct DPvd_draw_GN_t *draw_info,int clear_first)
PARAMETERS

	draw_info - pass in information as how to draw the rubber band,
	            step mode scale number, etc. NULL means no such info.

	clear_first - TRUE: clear hilite plane first.
	              FALSE: don't clear hilite plane first.

GLOBALS USED
RETURN VALUES
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    long msg;
    struct WLpoint gn_loc; /* GN location in vwport */

#if defined (XGL)
    Xgl_object  xgl_context_3D, hl_xgl_context;
    Xgl_hlhsr_mode	xgl_hlhsr_mode;
#endif

% safe
/* These vars remembers the info of current gnomen rubber lines, so that 
   they can be erased next time */ 

   static int             rubber_line_drawn = 0;
   static int             old_gn_align = 0;
   static struct WLpoint  rubber_band[2] = {0, 0, 0, 0};
   static char            step_string[25];
   static struct WLpoint  old_gn_loc = { 0, 0 };
   static int             old_gn_mode=0x1000;   /* DPvd_DRAG,DPvd_STEP,
                                                   DPvd_CONT */
%endsafe


    gn_loc.x = gn_loc_vwport[0] + 0.5;
    gn_loc.y = gn_loc_vwport[1] + 0.5;

    if( use_hilite)
    {
        WLenter_dynamics(gn_lwin_no);
    }

    WLhide_cursor (gn_lwin_no, 0);

    /* enter 2D drawing context so less matrix setting is done */
    WLenter_2D( gn_lwin_no, use_hilite );

#if defined (OPENGL)
   glDisable( GL_DEPTH_TEST );
#endif

#if defined( XGL )
    if( !use_hilite )
       {
       WLxgl_get_window_contexts( gn_lwin_no,
                                  &xgl_context_3D,
                                  &hl_xgl_context);

       xgl_object_get( xgl_context_3D,
                       XGL_3D_CTX_HLHSR_MODE, &xgl_hlhsr_mode );

       if( xgl_hlhsr_mode == XGL_HLHSR_Z_BUFFER )
          xgl_object_set( xgl_context_3D, 
                          XGL_3D_CTX_HLHSR_MODE,
                          XGL_HLHSR_NONE,
                          0 );
       }
#endif

    /*
     * Erase old gnomen
     */

    if (clear_first)
    {
	if (gn_mode != old_gn_mode ||
	    gn_mode != DPvd_STEP ||
	    gn_align || old_gn_align ||
	    draw_info == NULL /* align axix selection, etc */ ||
	    ((gn_loc.x != old_gn_loc.x) || (gn_loc.y != old_gn_loc.y)) )
	{
            if( use_hilite )
            {
	        /* 
	         * Erase whole hilite plane 
	         */
	        WLclear_hilite (gn_lwin_no);
            }

	    rubber_line_drawn = 0;
	}
	else
	{
	    /*
	     * Erase old gnomen rubber lines
	     */

	    if (rubber_line_drawn)
	    {
		int mx, my, len;
		
		/* WLset_drawing_mode (gn_lwin_no, WL_HILITE_ERASE); */
		WLset_dynamics_drawing_mode(gn_lwin_no,WL_DYN_ERASE_MODE);

		if (draw_info->draw_flags & DPvd_GN_RUBBER)
		  WLdraw_2D_line_string (gn_lwin_no, 2, rubber_band);
		
		len = strlen (step_string);
		
		mx = rubber_band[1].x + 10;
		my = rubber_band[1].y;
		
		/* keep text string inside window */
		if (mx > gn_win_area_bounds.width - 100)
		  mx = gn_win_area_bounds.width - 100;
		else if (mx < 0)
		  mx = 0;
		if (my > gn_win_area_bounds.height - 50)
		  my = gn_win_area_bounds.height - 50;
		else if (my < 50)
		  my = 50;
		
		if (len > 0)
		  WLdraw_text (gn_lwin_no, mx, my, step_string, len);
		
		/* draw free rotate axis */
		if(draw_info->draw_flags & DPvd_GN_CENTER)
		{
		    int x1,y1;
		    double rub_len,f;
		    IGRlong msg;
		    
		    /* draw a line perpendicular to the rubber line */
		    x1 = -(rubber_band[1].y - rubber_band[0].y);
		    y1 = (rubber_band[1].x - rubber_band[0].x);
		    
		    if(x1 != 0 || y1 != 0)
		    {
			rub_len = x1*x1+y1*y1;
			rub_len = MAsqrt(&msg,&rub_len);
			f = (IGRdouble)(gn_xp[2].x - gn_loc.x) / rub_len;
			
			gn_free_line[0].x = x1 * f + gn_loc.x;
			gn_free_line[0].y = y1 * f + gn_loc.y;
			gn_free_line[1].x = -x1 * f + gn_loc.x;
			gn_free_line[1].y = -y1 * f + gn_loc.y;
			
			WLset_active_symbology(gn_lwin_no,
                                               0,
                                               gn_line_style,
                                               0xFFFF,
                                               (gn_line_weight+1),
					       WL_SYMB_CHANGE_WEIGHT);
			
			WLdraw_2D_line_string(gn_lwin_no,2,gn_free_line);
		    }
		}

		rubber_line_drawn = 0; /* because erased */
		
		/* WLset_drawing_mode (gn_lwin_no, WL_HILITE_DRAW); */
	    }
	}
    }

    /*
     * Remember old location
     */

    if (draw_info && gn_mode == DPvd_STEP)
    {
	rubber_band[0].x = draw_info->rubber_band[0].x;
	rubber_band[0].y = draw_info->rubber_band[0].y;
	rubber_band[1].x = draw_info->rubber_band[1].x;
	rubber_band[1].y = draw_info->rubber_band[1].y;
    
	strcpy (step_string, draw_info->step_string);

	rubber_line_drawn = 1; /* will be drawn */
    }

    old_gn_mode = gn_mode;
    old_gn_loc.x = gn_loc.x;
    old_gn_loc.y = gn_loc.y;
    old_gn_align = gn_align;

    /*
     * Draw new Gnomen
     */

    /* WLenter_dynamics(gn_lwin_no); */
/*
    if( use_hilite)
    {
        WLenter_dynamics(gn_lwin_no);
    }
*/

    if(use_hilite)
    {
        WLset_dynamics_drawing_mode(gn_lwin_no,WL_DYN_DRAW_MODE);
    }
    else
    {
       WLset_drawing_mode( gn_lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP );
    }

    /* 
     * Draw the located element in hilite plane if needed.
     * Set dynamics_in_progress = TRUE temporarily, so that cursor will not be 
     * hiden in dp$display() and the BUTTON-UP event can be detected.
     */

    if(draw_info != NULL &&
       (draw_info->draw_flags & DPvd_GN_ELEMENT))
    {
	IGRboolean old_dynamics_in_progress;
	
	old_dynamics_in_progress = dynamics_in_progress;
	dynamics_in_progress = TRUE;

	dp$display(msg = &msg,
		   osnum = draw_info->gg_id->osnum,
		   objid = draw_info->gg_id->objid,
		   oids = draw_info->elem_id,
		   mode = GRhd);

	dynamics_in_progress = old_dynamics_in_progress;
    }

   /*
    * Draw Gnomen
    */

    /* Set standard line weight, color and style for GN */
    WLset_active_symbology(gn_lwin_no,
                           IGE_LOGICAL_HILITE,
                           gn_line_style,
                           0xFFFF,
                           gn_line_weight,
			   WL_SYMB_CHANGE_COLOR | 
                           WL_SYMB_CHANGE_STYLE |
                           WL_SYMB_CHANGE_WEIGHT);


    WLhide_cursor(gn_lwin_no, 0); /* need this, since dp$display() */ 

    /* draw Z axis and center */
    if(gn_align==DPvd_GN_ZAXIS || 
       (draw_info!=NULL && (draw_info->draw_flags&DPvd_GN_ZAXIS)))
    {
	WLdraw_rectangle(gn_lwin_no, &gn_rect1, TRUE);

        if(use_hilite)
        {
	    WLset_dynamics_drawing_mode(gn_lwin_no,WL_DYN_ERASE_MODE);
        }
        else
        {
            WLset_drawing_mode( gn_lwin_no, WL_BASE_ERASE | WL_HILITE_NOOP );
        }

	WLdraw_rectangle(gn_lwin_no, &gn_rect2, TRUE);

        /* reset drawing mode */
        if(use_hilite)
        {
            WLset_dynamics_drawing_mode(gn_lwin_no,WL_DYN_DRAW_MODE);
        }
        else
        {
            WLset_drawing_mode( gn_lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP );
        }
    }
    else if(draw_info!=NULL && (draw_info->draw_flags&DPvd_GN_CENTER))
    {
	/* Free rotate */
	WLdraw_rectangle(gn_lwin_no, &gn_rect1, FALSE);
	WLdraw_rectangle(gn_lwin_no, &gn_rect2, TRUE);
    }
    else
    {
	WLdraw_rectangle(gn_lwin_no, &gn_rect1, FALSE);
	WLdraw_rectangle(gn_lwin_no, &gn_rect2, FALSE);
    }
    
    
    /* draw X axis */
    WLdraw_2D_line_string(gn_lwin_no,2,gn_x);
    if(gn_align==DPvd_GN_XAXIS || 
       (draw_info!=NULL && (draw_info->draw_flags&DPvd_GN_XAXIS)))
    {
	WLdraw_polygon(gn_lwin_no, 3, gn_xp, TRUE);
    }
    else
    {
	WLdraw_polygon(gn_lwin_no, 3, gn_xp, FALSE);
    }

    /* draw Y axis */
    WLdraw_2D_line_string(gn_lwin_no,2,gn_y);
    if(gn_align==DPvd_GN_YAXIS || 
       (draw_info!=NULL && (draw_info->draw_flags&DPvd_GN_YAXIS)))
    {
	WLdraw_polygon(gn_lwin_no, 3, gn_yp, TRUE);
    }
    else
    {
	WLdraw_polygon(gn_lwin_no, 3, gn_yp, FALSE);
    }

    /* draw continuous, step mode node */
    if(gn_mode == DPvd_CONT)
    {
	WLdraw_polygon(gn_lwin_no, 3, &gn_cmode_x[0], TRUE);
	WLdraw_polygon(gn_lwin_no, 3, &gn_cmode_x[2], TRUE);
	WLdraw_polygon(gn_lwin_no, 3, &gn_cmode_y[0], TRUE);
	WLdraw_polygon(gn_lwin_no, 3, &gn_cmode_y[2], TRUE);
    }
    else if(gn_mode == DPvd_STEP)
    {
	WLdraw_rectangle(gn_lwin_no,&gn_smode_x,TRUE);
	WLdraw_rectangle(gn_lwin_no,&gn_smode_y,TRUE);
    }
    

    /* draw rubber band and other lines */
    if(draw_info != NULL)
    {
	/* draw rubber band */
	if(draw_info->draw_flags & DPvd_GN_RUBBER)
	  WLdraw_2D_line_string(gn_lwin_no,2,draw_info->rubber_band);

	/* draw step value */ 
	if(gn_mode == DPvd_STEP)
	{
	    int mx,my, len;
	    
	    /* set font ...... */

	    len = strlen(draw_info->step_string);

	    mx = draw_info->rubber_band[1].x + 10;
	    my = draw_info->rubber_band[1].y ;

	    /* keep text string inside window */
	    if(mx > gn_win_area_bounds.width-100) mx = gn_win_area_bounds.width-100;
	    else if(mx < 0) mx = 0;
	    if(my > gn_win_area_bounds.height-50) my = gn_win_area_bounds.height-50;
	    else if(my < 50) my = 50;
	    
	    if(len > 0) WLdraw_text(gn_lwin_no,mx,my,draw_info->step_string,len);
	}

	/* draw free rotate axis */
	if(draw_info->draw_flags & DPvd_GN_CENTER)
	{
	    int x1,y1;
	    double rub_len,f;
	    IGRlong msg;

	    WLdraw_rectangle(gn_lwin_no, &gn_rect2, TRUE);
	    
	    /* draw a line perpendicular to the rubber line */
	    x1 = -(draw_info->rubber_band[1].y - draw_info->rubber_band[0].y);
	    y1 = (draw_info->rubber_band[1].x - draw_info->rubber_band[0].x);
	    if(x1 != 0 || y1 != 0)
	    {
		rub_len = x1*x1+y1*y1;
		rub_len = MAsqrt(&msg,&rub_len);
		f = (IGRdouble)(gn_xp[2].x - gn_loc.x) / rub_len;

		gn_free_line[0].x = x1 * f + gn_loc.x;
		gn_free_line[0].y = y1 * f + gn_loc.y;
		gn_free_line[1].x = -x1 * f + gn_loc.x;
		gn_free_line[1].y = -y1 * f + gn_loc.y;

		WLset_active_symbology(gn_lwin_no,
                                       0,
                                       gn_line_style,
                                       0xFFFF,
                                       (gn_line_weight+1),
				       WL_SYMB_CHANGE_WEIGHT);

		WLdraw_2D_line_string(gn_lwin_no,2,gn_free_line);
	    }
	}

	/* draw element tangent line */
	else if(draw_info->draw_flags & DPvd_GN_ELEMENT)
	{
	    if(draw_info->first_elem_line)
	    {
		double len,f;
		len = (IGRdouble)(gn_xp[2].x - gn_loc.x);

		/* make the len long enough to see */
		if(fabs(draw_info->elem_tangent[0])>fabs(draw_info->elem_tangent[1]))
		  f = fabs(draw_info->elem_tangent[0]);
		else 
		  f = fabs(draw_info->elem_tangent[1]);
		if(f > 0.01) len = len/f;

		/* set values */
		gn_elem_line[0].x = len * draw_info->elem_tangent[0];
		gn_elem_line[0].y = -(len * draw_info->elem_tangent[1]);
		gn_elem_line[1].x = -gn_elem_line[0].x;
		gn_elem_line[1].y = -gn_elem_line[0].y;
		
		gn_elem_arrow[0].x = gn_elem_line[0].x * 0.3;
		gn_elem_arrow[0].y = gn_elem_line[0].y * 0.3;
		gn_elem_arrow[1].x = -gn_elem_arrow[0].y * 0.5;
		gn_elem_arrow[1].y = gn_elem_arrow[0].x * 0.5;
		gn_elem_arrow[2].x = -gn_elem_arrow[1].x;
		gn_elem_arrow[2].y = -gn_elem_arrow[1].y;
		
		gn_elem_line[0].x += gn_loc.x;
		gn_elem_line[0].y += gn_loc.y;
		gn_elem_line[1].x += gn_loc.x;
		gn_elem_line[1].y += gn_loc.y;

		gn_elem_arrow[0].x += gn_elem_line[0].x;
		gn_elem_arrow[0].y += gn_elem_line[0].y;
		gn_elem_arrow[1].x += gn_elem_line[0].x;
		gn_elem_arrow[1].y += gn_elem_line[0].y;
		gn_elem_arrow[2].x += gn_elem_line[0].x;
		gn_elem_arrow[2].y += gn_elem_line[0].y;

		draw_info->first_elem_line = FALSE;
	    }

	    if(gn_align != 0)
	    {
		WLset_active_symbology(gn_lwin_no,
                                       0,
                                       gn_line_style,
                                       0xFFFF,
				       (gn_line_weight+1),
                                       WL_SYMB_CHANGE_COLOR |
                                       WL_SYMB_CHANGE_STYLE |
                                       WL_SYMB_CHANGE_WEIGHT);

		WLdraw_2D_line_string(gn_lwin_no,2,gn_elem_line);

		WLdraw_polygon(gn_lwin_no, 3, gn_elem_arrow, TRUE);
	    }
	}
    }

    WLexit_2D( gn_lwin_no, use_hilite );

#if defined( XGL )
    if( !use_hilite )
       if( xgl_hlhsr_mode == XGL_HLHSR_Z_BUFFER )
          xgl_object_set( xgl_context_3D,
                          XGL_3D_CTX_HLHSR_MODE,
                          XGL_HLHSR_Z_BUFFER,
                          0);
#endif

    if(use_hilite)
    {
        WLexit_dynamics(gn_lwin_no);
    }

    WLset_drawing_mode( gn_lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP );
    WLshow_cursor(gn_lwin_no);
}


/*
void DPvd_draw_GN_center(WLuint32 lwin_no)

NAME
         DPvd_draw_GN_center
DESCRIPTION
         Draw GN at a window's center
SYNOPSIS
         void DPvd_draw_GN_center(WLuint32 lwin_no)
PARAMETERS
         lwin_no - WL window number
GLOBALS USED
RETURN VALUES
NOTES
HISTORY
        06/20/93    T. Wang

{
    struct WLbounds bounds,area_bounds;
    
    WLget_window_bounds(lwin_no,&bounds,&area_bounds);
    
    DPvd_set_GN_location(lwin_no,(IGRdouble)(area_bounds.width)/2.0,
			 (IGRdouble)(area_bounds.height)/2.0, gn_z_screen);
    
    DPvd_draw_GN(NULL,1);
 
}
*/


void DPvd_erase_GN()
/*
NAME
         DPvd_erase_GN
DESCRIPTION
         Erase GN
SYNOPSIS
         DPvd_erase_GN
PARAMETERS
GLOBALS USED
RETURN VALUES
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    WLhide_cursor(gn_lwin_no, 0);
    WLclear_hilite(gn_lwin_no);
    WLshow_cursor(gn_lwin_no);
}



int DPvd_check_toggle_GN_mode(WLuint32 lwin_no,int x,int y)
/*
NAME
        DPvd_check_toggle_GN_mode

DESCRIPTION
        This routine checks if a given pointer is in the GN's mode
	area. If so, GN's mode is changed, return the new mode, and
        redraw GN. If not, just return the current GN mode. 

SYNOPSIS
        int DPvd_check_toggle_GN_mode(WLuint32 lwin_no,int x,int y)

PARAMETERS

        lwin_no - WL window of the data pointer.
        x,y     - location of the data pointer.

GLOBALS USED
RETURN VALUES
        0,1,2 -- operation mode of GN. (DRAG, CONT, STEP)
NOTES
HISTORY
        06/20/93    T. Wang
        09/20/93    H.S.Gandhi
                    Changed the modes to the following values
                    DPvd_STEP --- 0x00
                    DPvd_DRAG --- 0x10
                    DPvd_CONT --- 0x20
                    Also added code to store the current GN mode
                    in the design file through the DPcodpb messages
*/
{
    int mode_changed = FALSE;
    IGRushort   dvd_flags;

    if(lwin_no != gn_lwin_no) return(gn_mode);

    /* Check if (x,y) is within the mode node rect */
    if(x>=gn_smode_x.x && x<=(gn_smode_x.x+gn_smode_x.width) &&
       y>=gn_smode_x.y && y<=(gn_smode_x.y+gn_smode_x.height))
    {
	mode_changed = TRUE;
    }
    else if(x>=gn_smode_y.x && x<=(gn_smode_y.x+gn_smode_y.width) &&
	    y>=gn_smode_y.y && y<=(gn_smode_y.y+gn_smode_y.height))

    {
	mode_changed = TRUE;
    }


    if(mode_changed)
    {

        if ( (gn_mode & MODE_FLAG) == DPvd_STEP)
        {
           gn_mode = DPvd_DRAG;
        }
        else if ( (gn_mode & MODE_FLAG) == DPvd_DRAG)
        {
           gn_mode = DPvd_CONT;
        }
        else
        {
           gn_mode = DPvd_STEP;
        }

        /* get the current dvd flags value */
        DPcodpb_get_dvd_flags( (IGRushort *) &dvd_flags );

        /* add the GN mode value to the dvd flags value */
        dvd_flags = dvd_flags & (~MODE_FLAG) | gn_mode;

        /* set the new dvd flags value into the DPcodpb object */
        DPcodpb_set_dvd_flags( (IGRushort) dvd_flags );

    }
    
    return(gn_mode);
}



int DPvd_set_GN_mode(void)
/*
NAME
        DPvd_set_GN_mode
DESCRIPTION
        This routine reads the GN mode value from the design
        file through the DPcodpb messages and sets it to the
        current GN mode.
SYNOPSIS
        int DPvd_set_GN_mode(void)
PARAMETERS
GLOBALS USED
RETURN VALUES
        Current GN mode
NOTES
HISTORY
        09/20/93    H.S.Gandhi
*/
{
   IGRushort   dvd_flags;

   /* read the gn_mode from the design file through the DPcodpb  */
   /* messages -- HSG */
   DPcodpb_get_dvd_flags( (IGRushort *) &dvd_flags );

   /* Assign it to the current gn_mode value -- HSG */
   gn_mode = dvd_flags & MODE_FLAG;
   return(TRUE);
}


int DPvd_get_GN_mode(void)
/*
NAME
        DPvd_get_GN_mode
DESCRIPTION
        This routine return the current GN mode.
SYNOPSIS
        int DPvd_get_GN_mode(void)
PARAMETERS
GLOBALS USED
RETURN VALUES
        Current GN mode
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    return(gn_mode);
}





int DPvd_check_select_GN_axis(WLuint32 lwin_no,int x,int y)
/*
NAME
         DPvd_check_select_GN_axis

DESCRIPTION
         This routine just check if a point is in the GN's X, Y, Z, or CENTER
	 area. If so, it returns that area number. Otherwise, return 0.

SYNOPSIS
         int DPvd_check_select_GN_axis(WLuint32 lwin_no,int x,int y)

PARAMETERS

        lwin_no - WL window of the data pointer.
        x,y     - location of the data pointer.

GLOBALS USED
RETURN VALUES
        0 -- point is not in any area of the GN.
        Nonzero -- area number of the GN selected.
NOTES
        GN is not redrawn.
HISTORY
        06/20/93    T. Wang
*/
{
    if(lwin_no != gn_lwin_no) return(0);

    if(x>=gn_rect1.x && x<=(gn_rect1.x+gn_rect1.width) &&
       y>=gn_rect1.y && y<=(gn_rect1.y+gn_rect1.height))
    {
	if(x>=gn_rect2.x && x<=(gn_rect2.x+gn_rect2.width) &&
	   y>=gn_rect2.y && y<=(gn_rect2.y+gn_rect2.height))
	{
	    return(DPvd_GN_CENTER);
	}
	else
	  return(DPvd_GN_ZAXIS);
    }
    else if(x>=gn_xp[0].x && x<=gn_xp[2].x &&
	    y>=gn_xp[0].y && y<=gn_xp[1].y )
    {
	return(DPvd_GN_XAXIS);
    }
    else if(x>=gn_yp[0].x && x<=gn_yp[1].x &&
	    y<=gn_yp[0].y && y>=gn_yp[2].y )
    {
	return(DPvd_GN_YAXIS);
    }
    else
      return(0);
}





int DPvd_check_set_GN_align_state(WLuint32 lwin_no, int x, int y)
/*
NAME
         DPvd_check_set_GN_align_state

DESCRIPTION
         This routine check if a pointer is on the X,Y,Z area of GN.
	 If so, it remembers that that axis is to be aligned, and redraw
	 GN with that axis hilited.
         Axis to be aligned is returned. (0 means no align axis)

SYNOPSIS
         int DPvd_check_set_GN_align_state(WLuint32 lwin_no, int x, int y)

PARAMETERS

        lwin_no - WL window of the data pointer.
        x,y     - location of the data pointer.

GLOBALS USED
RETURN VALUES
        Axis number to be aligned. 0 means no align axis.
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    int selected_axis;
    
    selected_axis = DPvd_check_select_GN_axis(lwin_no,x,y);
    
    if(selected_axis == DPvd_GN_XAXIS ||
       selected_axis == DPvd_GN_YAXIS ||
       selected_axis == DPvd_GN_ZAXIS)
    {
	if(gn_align == selected_axis) gn_align = 0; /* off */
	else gn_align = selected_axis;
    }

    return(gn_align);
}





int DPvd_get_GN_align_state(void)
/*
NAME
        DPvd_get_GN_align_state
DESCRIPTION
        Return the current align axis selected.
SYNOPSIS
        int DPvd_get_GN_align_state(void)
PARAMETERS
GLOBALS USED
RETURN VALUES
        0 or an axis number.
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    return(gn_align);
}




int DPvd_set_GN_align_state(int align_axis)
/*
NAME
        DPvd_set_GN_align_state
DESCRIPTION
        Set or clear GN's align axis. 
SYNOPSIS
        int DPvd_set_GN_align_state(int align_axis)

PARAMETERS
        align_axis -- axis area number.

GLOBALS USED
RETURN VALUES
        old align axis area number.
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    int old_state;
    old_state = gn_align;
    gn_align = align_axis;
    return(old_state);
}



int DPvd_set_GN_location(WLuint32 lwin, IGRdouble *loc_vwport, IGRdouble *loc_wld)
/*
NAME
         DPvd_set_GN_location
DESCRIPTION
         Set new GN location and calculate the GN display variables.
SYNOPSIS
         int DPvd_set_GN_location(WLuint32 lwin, IGRdouble *loc_vwport, IGRdouble *loc_wld)

PARAMETERS
GLOBALS USED
RETURN VALUES
        TRUE - Success
        FALSE - Failed
NOTES
HISTORY
        09/10/93    T. Wang
*/
{
    int k,n;
    struct WLbounds bounds;
    struct WLpoint gn_loc; /* GN location in vwport */

    if(lwin == WL_UNDEFINED_WINDOW) return(1);

    gn_lwin_no = lwin;

    gn_loc_vwport[0] = loc_vwport[0];
    gn_loc_vwport[1] = loc_vwport[1];
    gn_loc_vwport[2] = loc_vwport[2];
    
    gn_loc_wld[0] = loc_wld[0];
    gn_loc_wld[1] = loc_wld[1];
    gn_loc_wld[2] = loc_wld[2];

    gn_loc.x = gn_loc_vwport[0] + 0.5;
    gn_loc.y = gn_loc_vwport[1] + 0.5;

    /* calculate display variables */

    if(gn_size == 0) /* first time */
    {
	gn_size = DPvd_GN_DEFAULT_SIZE; /* default size */
	gn_line_style = 0;
	gn_line_weight = 0;
    }
 
	
    WLget_window_bounds(gn_lwin_no,&bounds,&gn_win_area_bounds);
    
    /* large rect */
    gn_rect1.width = gn_size;    
    gn_rect1.height = gn_size;
    k = gn_size / 2;
    gn_rect1.x = gn_loc.x - k;
    gn_rect1.y = gn_loc.y - k;
    
    /* small rect */
    k = gn_size / 2;
    gn_rect2.width = k;
    gn_rect2.height = k;
    k = k >> 1;
    gn_rect2.x = gn_loc.x - k;
    gn_rect2.y = gn_loc.y - k;
    
    /* short x line */
    gn_x[0].x = gn_loc.x + (gn_rect1.width / 2);
    gn_x[0].y = gn_loc.y;
    gn_x[1].x = gn_x[0].x + gn_size;
    gn_x[1].y = gn_loc.y;
    
    /* x arrow */
    k = (int)(gn_rect1.width * 0.3);
    gn_xp[0].x = gn_x[1].x;
    gn_xp[0].y = gn_x[1].y - k;
    gn_xp[1].x = gn_x[1].x;
    gn_xp[1].y = gn_x[1].y + k;
    gn_xp[2].x = gn_x[1].x + 5*k;
    gn_xp[2].y = gn_x[1].y;
    
    
    /* continous mode x node */
    k = (gn_x[1].x - gn_x[0].x) / 4;  /* node size parameter */
    n = (gn_x[1].x + gn_x[0].x) / 2;  /* middle point */
    gn_cmode_x[0].x = n - k;
    gn_cmode_x[0].y = gn_x[0].y - k;
    gn_cmode_x[1].x = n + k;
    gn_cmode_x[1].y = gn_x[0].y - k;
    gn_cmode_x[2].x = n;
    gn_cmode_x[2].y = gn_x[0].y;
    gn_cmode_x[3].x = n - k;
    gn_cmode_x[3].y = gn_x[0].y + k;
    gn_cmode_x[4].x = n + k;
    gn_cmode_x[4].y = gn_x[0].y + k;
    
    
    /* step mode x node */
    gn_smode_x.x = n - k;
    gn_smode_x.y = gn_x[0].y - k;
    gn_smode_x.width = k+k;
    gn_smode_x.height = k+k;
    
    /* short y line */
    gn_y[0].x = gn_loc.x;
    gn_y[0].y = gn_loc.y - (gn_rect1.height / 2);
    gn_y[1].x = gn_loc.x;
    gn_y[1].y = gn_y[0].y - gn_size;
    
    /* y arrow */
    k = (int)(gn_rect1.width * 0.3);
    gn_yp[0].x = gn_y[1].x - k;
    gn_yp[0].y = gn_y[1].y;
    gn_yp[1].x = gn_y[1].x + k;
    gn_yp[1].y = gn_y[1].y;
    gn_yp[2].x = gn_y[1].x;
    gn_yp[2].y = gn_y[1].y - 5*k;
    
    /* continous mode y node */
    k = (gn_y[0].y - gn_y[1].y) / 4;
    n = (gn_y[0].y + gn_y[1].y) / 2;
    gn_cmode_y[0].x = gn_y[0].x - k;
    gn_cmode_y[0].y = n + k;
    gn_cmode_y[1].x = gn_y[0].x - k;
    gn_cmode_y[1].y = n - k;
    gn_cmode_y[2].x = gn_y[0].x;
    gn_cmode_y[2].y = n;
    gn_cmode_y[3].x = gn_y[0].x + k;
    gn_cmode_y[3].y = n + k;
    gn_cmode_y[4].x = gn_y[0].x + k;
    gn_cmode_y[4].y = n - k;
    
    /* step mode y node */
    gn_smode_y.x = gn_y[0].x - k;
    gn_smode_y.y = n - k;
    gn_smode_y.width = k+k;
    gn_smode_y.height = k+k;

    return(TRUE);
}

int DPvd_get_GN_location(WLuint32 *lwin, IGRdouble *loc_vwport, IGRdouble *loc_wld) 
/*
NAME
         DPvd_get_GN_location
DESCRIPTION
         Return the location of the GN.
SYNOPSIS
         int DPvd_get_GN_location(WLuint32 *lwin, IGRdouble *loc_vwport, IGRdouble *loc_wld)

PARAMETERS
GLOBALS USED
RETURN VALUES
        TRUE - location returned.
        FALSE - GN has not be defined before.
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    IGRint i;
    
    if(gn_lwin_no == WL_UNDEFINED_WINDOW) return(FALSE);

    *lwin = gn_lwin_no;

    for(i=0;i<3;i++)
    {
	loc_vwport[i] = gn_loc_vwport[i];
	loc_wld[i] = gn_loc_wld[i];
    }

    return(TRUE);
}


end implementation DPvd;
