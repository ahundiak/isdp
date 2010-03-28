#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIreport_errors;

/*--- DLIupdate_pipe_symbology ---------------------------------*/

int DLIupdate_pipe_symbology(
   struct DLpipeline *pipe,
   int draw_opt,
   WLcolorref color,
   int lstyle,
   int lweight,
   WLuint16 blend )

/*
NAME
	DLIupdate_pipe_symbology

DESCRIPTION
	This function updates the symbology parameters for
	a given drawing pipeline.

SYNOPSIS
	int DLIupdate_pipe_symbology(
	   struct DLpipeline *pipe,
	   int draw_opt,
	   WLcolorref color,
	   int lstyle,
	   int lweight,
	   WLuint16 blend )

PARAMETERS
	pipe (IN) - the drawing pipeline
	draw_opt (IN) - the drawing options
	color (IN) - the new color
	lstyle (IN) - the new style
	lweight (IN) - the new weight
	blend (IN) - the new blend

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
         DL_ERROR
            A WL call failed

HISTORY
	11/25/92   S.P. Rogers
	   Creation Date
*/

{
   int wl_mode;

   pipe->draw_opt = draw_opt;

   pipe->color = color;
   pipe->lstyle = lstyle;
   pipe->blend = blend;
   pipe->lweight = lweight;

   if ( pipe->fb_size > 0 )
   {
      /* feedback pipeline => don't make windowing system calls */
      return( DL_SUCCESS );
   }

   switch ( draw_opt & DL_OPT_BASE_MODE )
   {
      case DL_OPT_BASE_DRAW :
         wl_mode = WL_BASE_DRAW;
         break;
      case DL_OPT_BASE_ERASE :
         wl_mode = WL_BASE_ERASE;
         break;
      default :
         wl_mode = WL_BASE_NOOP;
         break;
   }

   switch ( draw_opt & DL_OPT_HILITE_MODE )
   {
      case DL_OPT_HILITE_DRAW :
         wl_mode |= WL_HILITE_DRAW;
         break;
      case DL_OPT_HILITE_ERASE :
         wl_mode |= WL_HILITE_ERASE;
         break;
      default :
         wl_mode |= WL_HILITE_NOOP;
         break;
   }

   WLset_drawing_mode( pipe->lwin_no, wl_mode );

   WLset_active_symbology( pipe->lwin_no, pipe->color,
                                 pipe->lstyle, pipe->blend,
                                 pipe->lweight,
                                 WL_SYMB_CHANGE_WEIGHT |
                                 WL_SYMB_CHANGE_STYLE |
                                 WL_SYMB_CHANGE_COLOR );

   return( DL_SUCCESS );

}  /* DLIupdate_pipe_symbology */

/*--- DLIpoint2D --------------------------------------------------*/

int DLIpoint2D(
   struct DLpipeline *pipe,
   int x,
   int y )

/*
NAME
	DLIpoint2D

DESCRIPTION
	This function draws a 2D point by calling WL

SYNOPSIS
	int DLIpoint2D(
	   struct DLpipeline *pipe,
	   int x,
	   int y )

PARAMETERS
	pipe (IN) - the pipeline structure to use
	x (IN) - the x coordinate of the point
	y (IN) - the y coordinate of the point

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	12/02/92    S.P. Rogers
	   Documented
*/

{

   struct WLpoint point;

   point.x = x;
   point.y = y;
   WLdraw_2D_point_string( pipe->lwin_no, 1, &point );

   return( DL_SUCCESS );

}  /* DLIpoint2D */

