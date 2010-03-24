#if defined( X11 ) || defined( ENV5 )
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

/*---WLIget_fg_and_hl_IX-----------------------------------------*/

int WLIget_fg_and_hl_IX(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color )
/*
NAME
	WLIget_fg_and_hl_IX
 
KEYWORD
	WLI 
 
DESCRIPTION
	This function returns the hilite and foreground colors in indexed mode
        without separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_IX(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct,
           int *fg_color,
           int *hl_color )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
        fg_color (OUT) - The foreground color
        hl_color (OUT) - The hilight color 

RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/

{
   if ( ( win_struct->flags & WLI_WIN_BASE_MASK ) == WLI_WIN_FLAGS_BASE_DRAW )
   {
      *fg_color = win_struct->color_index;
   }
   else
   { 
      *fg_color = win_struct->background_color_index;
   }

   if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
   {
      *hl_color = 1 << context_struct->base_depth;
   }
   else
   {
      *hl_color = 0;
   }

   return( WL_SUCCESS );
      
}/* WLIget_fg_and_hl_IX */

/*---WLIget_fg_and_hl_HL_IX-----------------------------------------*/

int WLIget_fg_and_hl_HL_IX(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color )
/*
NAME
	WLIget_fg_and_hl_HL_IX
 
KEYWORD
	WLI
 
DESCRIPTION
	This function returns the hilite and foreground colors in indexed mode
        with separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_HL_IX(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct,
           int *fg_color,
           int *hl_color )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
        fg_color (OUT) - The foreground color
        hl_color (OUT) - The hilight color 

RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/

{
   if ( ( win_struct->flags & WLI_WIN_BASE_MASK ) == WLI_WIN_FLAGS_BASE_DRAW )
   {
      *fg_color = win_struct->color_index;
   }
   else
   { 
      *fg_color = win_struct->background_color_index;
   }

   if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
   {
      *hl_color = 1; 
   }
   else
   {
      *hl_color = 0;
   }

   return( WL_SUCCESS );
      
}/* WLIget_fg_and_hl_HL_IX */

/*---WLIget_fg_and_hl_HL_TC-----------------------------------------*/

int WLIget_fg_and_hl_HL_TC(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color )
/*
NAME
	WLIget_fg_and_hl_HL_TC
 
KEYWORD
	WLI
 
DESCRIPTION
	This function returns the hilite and foreground colors in true color 
        mode with separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_HL_TC(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct,
           int *fg_color,
           int *hl_color )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
        fg_color (OUT) - The foreground color
        hl_color (OUT) - The hilight color 

RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/

{
   WLuint16 red, green, blue;

   if ( (win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_DRAW )
   {
      red = win_struct->red >> context_struct->right_shifter;
      green = win_struct->green >> context_struct->right_shifter;
      blue = win_struct->blue >> context_struct->right_shifter;
   }
   else
   {
      red = win_struct->background_red >> context_struct->right_shifter;
      green = win_struct->background_green >> context_struct->right_shifter;
      blue = win_struct->background_blue >> context_struct->right_shifter;
   }
   *fg_color = ( blue <<  context_struct->blue_shifter ) | 
               ( green << context_struct->green_shifter ) | 
               ( red << context_struct->red_shifter );;
   
   if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
   {
      *hl_color = 1; 
   }
   else
   {
      *hl_color = 0;
   }

   return( WL_SUCCESS );
      
}/* WLIget_fg_and_hl_HL_TC */

/*---WLIget_fg_and_hl_TC-----------------------------------------*/

int WLIget_fg_and_hl_TC(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color )
/*
NAME
	WLIget_fg_and_hl_TC
 
KEYWORD
	WLI
 
DESCRIPTION
	This function returns the hilite and foreground colors in true color 
        mode without separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_TC(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct,
           int *fg_color,
           int *hl_color )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
        fg_color (OUT) - The foreground color
        hl_color (OUT) - The hilight color 

RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/

{
   WLuint16 red, green, blue;

   if ( (win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_DRAW )
   {
      red = win_struct->red >> context_struct->right_shifter;
      green = win_struct->green >> context_struct->right_shifter;
      blue = win_struct->blue >> context_struct->right_shifter;
   }
   else
   {
      red = win_struct->background_red >> context_struct->right_shifter;
      green = win_struct->background_green >> context_struct->right_shifter;
      blue = win_struct->background_blue >> context_struct->right_shifter;
   }
   *fg_color = ( blue <<  context_struct->blue_shifter ) | 
               ( green << context_struct->green_shifter ) | 
               ( red << context_struct->red_shifter );;
   
   if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
   {
      *hl_color = 1; 
   }
   else
   {
      *hl_color = 0;
   }

   return( WL_SUCCESS );
      
}/* WLIget_fg_and_hl_HL_TC */
#endif
