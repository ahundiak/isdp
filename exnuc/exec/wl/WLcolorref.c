#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"
 

/*--- WLpack_rgb_colorref-----------------------------------------------*/
 
int WLpack_rgb_colorref(
   WLuint32 red,
   WLuint32 green,
   WLuint32 blue,
   WLcolorref *color_ref,
   WLuint32 physical)
 
/*
NAME
   WLpack_rgb_colorref
 
KEYWORD
   WL
 
DESCRIPTION
   This function packs an RGB color into a color reference

SYNOPSIS
   int WLpack_rgb_colorref(
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLcolorref *color_ref,
      WLuint32 physical)
 
PARAMETERS
   red (IN) - The red component
   green (IN) - The green component
   blue (IN) - The blue component
   color_ref (OUT) - The packed color
   physical (IN) - Whether the RGB is physical or logical

GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_PARAMETER
      The 'color_ref' parameter is NULL.

HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   WLuint32 x;
 
   if ( !color_ref )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   x = WL_COLOR_RGB;
   if ( physical )
   {
      x |= WL_COLOR_PHYSICAL;
   }

   red = red >> 8;
   green = green >> 8;
   blue = blue >> 8;

   x |= (red << 16);
   x |= (green << 8);
   x |= blue;

   *color_ref = x;
 
   return( WL_SUCCESS );
}  /* WLpack_rgb_colorref */

/*--- WLpack_index_colorref-----------------------------------------------*/
 
int WLpack_index_colorref(
   WLuint32 color_index,
   WLcolorref *color_ref,
   WLuint32 physical )
 
/*
NAME
   WLpack_index_colorref
 
KEYWORD
   WL
 
DESCRIPTION
   This function packs a logical color index into a color reference

SYNOPSIS
   int WLpack_index_colorref(
      WLuint32 color_index,
      WLcolorref *color_ref,
      WLuint32 physical )
 
PARAMETERS
   color_index (IN) - The logical or physical color index
   color_ref (OUT) - The packed color
   physical (IN) - Whether the color index is physical or logical

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_PARAMETER
      The 'color_ref' parameter is NULL.
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition

   10/22/92 Shridar Subramanian
      Initial design
*/
{

   if ( ! color_ref )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   *color_ref = color_index;
   if ( physical )
   {
      *color_ref |= WL_COLOR_PHYSICAL;
   }

   return( WL_SUCCESS );

}  /* WLpack_index_colorref */

/*--- WLmap_colorref-----------------------------------------------*/
 
int WLmap_colorref(
   WLuint32 lwin_no,
   WLcolorref color_ref,
   WLuint32 *color_index,
   WLuint32 *red,
   WLuint32 *green,
   WLuint32 *blue,
   WLuint32 *color_flag)
/*
NAME
   WLmap_colorref
 
KEYWORD
   WL
 
DESCRIPTION
   This function unpacks the colorref and returns either the physical index
   or the RGB values

SYNOPSIS
   int WLmap_colorref(
      WLuint32 lwin_no,
      WLcolorref color_ref,
      WLuint32 *color_index,
      WLuint32 *red,
      WLuint32 *green,
      WLuint32 *blue,
      WLuint32 *color_flag)
 
PARAMETERS
   lwin_no (IN) - The logical window number
   color_ref (IN) - The packed color
   color_index (OUT) - The physical color index
   red (OUT) - The red component
   green (OUT) - The green component
   blue (OUT) - The blue component
   color_flag (OUT) - Indicates whether the color index or RGB was filled
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;
   WLuint32 temp_color_index;
   WLuint32 lred;
   WLuint32 lgreen;
   WLuint32 lblue;
   WLuint32 temp_int; 
      
 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   status = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
   status = WLIwin_unpack_colorref( color_ref, &temp_color_index, &lred, &lgreen,
                                    &lblue, color_flag);
   if (status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      if ( (*color_flag & WL_COLOR_PHYSICAL) && !(*color_flag & WL_COLOR_RGB) )
      {
         WL_REPORT_ERROR( WL_BAD_COLOR_REF );
         return( WL_BAD_COLOR_REF );
      }

      if ( *color_flag & WL_COLOR_PHYSICAL )
      {
         *red = lred;
         *green = lgreen;
         *blue = lblue;
      }
      else
      {
         (*context_struct.cmap_color_to_rgb)( win_struct.context_no,
                                              temp_color_index, lred, lgreen,
                                              lblue, *color_flag, red,
                                              green, blue);
      }
   }
   else
   {
      if ( (*color_flag & WL_COLOR_PHYSICAL) && (*color_flag & WL_COLOR_RGB) )
      {
         WL_REPORT_ERROR( WL_BAD_COLOR_REF );
         return( WL_BAD_COLOR_REF );
      }

      if ( *color_flag & WL_COLOR_PHYSICAL )
      {
         *color_index = temp_color_index;
      }
      else
      {
         (*context_struct.cmap_color_to_index)( win_struct.context_no,
                                                temp_color_index, lred, lgreen,
                                                lblue, *color_flag,
                                                &temp_int );
         *color_index = temp_int;
      }
   }

   return( WL_SUCCESS );

}  /* WLmap_colorref */
