#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIreport_errors;

#define DLI_STATIC_GP_ATTR_SIZE 50

/*--- DLdraw_3D_curve -------------------------------------------*/

int DLdraw_3D_curve(
   int pipe_id,
   struct IGRbsp_curve *curve,
   int *attr_index,
   struct DLattr_bundle *attr_bundle,
   int bundle_size,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_3D_curve

DESCRIPTION
	This function draws a 3D Bspline curve using a drawing pipeline.

SYNOPSIS
	int DLdraw_3D_curve(
	   int pipe_id,
	   struct IGRbsp_curve *curve,
	   int *attr_index,
	   struct DLattr_bundle *attr_bundle,
	   int bundle_size,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	curve (IN) - the Bspline curve to draw
	attr_index (IN) - array of indices for the attribute bundle table
	attr_bundle (IN) - array of attribute bundles
	bundle_size (IN) - number of entries in the attribute bundle table
	color (IN) - the color ref of the curve
	lstyle (IN) - the logical style of the curve
	blend (IN) - the blend parameter for the curve
	weight (IN) - the weight of the curve
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip to the viewport

		DL_OPT_FILL
			Fill the area enclosed by the curve. If the curve is not
			closed by definition, it will be closed with a line
			segment from the last point to the first point.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

	The feedback buffer format for a non-filled 3D bspline curve is:

	    31                                                0
	    ---------------------------------------------------
	    |          flag          |    DL_FB_BSC_LXYZ      |
	    ---------------------------------------------------
	    |  quad words to follow for all DL_FB_LXYZ elems  |
	    ---------------------------------------------------
            |             bspline attribute flag              |
	    ---------------------------------------------------
            |                 attribute data                  |
	    ---------------------------------------------------
            |                   DL_FB_LXYZ 0                  |
	    ---------------------------------------------------
            |                        .                        |
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------
            |             bspline attribute flag              |
	    ---------------------------------------------------
            |                 attribute data                  |
	    ---------------------------------------------------
            |                   DL_FB_LXYZ 1                  |
	    ---------------------------------------------------

	The feedback buffer format for a filled 3D bspline curve is:

	    31                                                0
	    ---------------------------------------------------
	    |          flag          |     DL_FB_BSC_PXYZ     |
	    ---------------------------------------------------
	    |  quad words to follow for all DL_FB_PXYZ elems  |
	    ---------------------------------------------------
            |                   DL_FB_PXYZ 0                  |
	    ---------------------------------------------------
            |                        .                        |
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------
            |                   DL_FB_PXYZ 1                  |
	    ---------------------------------------------------

	The format of a DL_FB_LXYZ record can be found in the NOTES
	section of DLdraw_3D_line_string().  The format of a 
        DL_FB_PXYZ record can be found in the NOTES section of
	DLdraw_3D_polygons().

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_ILLEGAL_BSPLINE_ORDER
		The order of the curve is < 2 or > DL_MAX_ORDER.
	DL_BSPLINE_ERROR
		A math error occurred while processing the Bspline curve.
	DL_BAD_PARAMETER
		One of the pointer parameters is NULL or the 'bundle_size'
		parameter is negative or one of the entries in the attribute
		index array is outside of the attribute bundle array.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_STYLE
		The logical style is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_FEEDBACK_OVERFLOW
		There was not enough room in the feedback buffer.
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory for processing could not be allocated.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;
#if defined( ENV5 )
   int ii;
   int gpipe_opt;
   int curve_color;
   int hl_color;
   WLcolorref bg_color_ref;
   WLuint32 color_index, red, green, blue, color_flag;
   WLuint16 pattern;
   GPattribute *gp_attr, static_gp_attr[DLI_STATIC_GP_ATTR_SIZE];
#endif

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (! curve) ||
        ( (attr_index) && (! attr_bundle) ) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( ( curve->num_poles < curve->order ) ||
        ( curve->order < 2 ) ||
        ( curve->order > DL_MAX_ORDER ) )
   {
      DL_REPORT_ERROR( DL_ILLEGAL_BSPLINE_ORDER );
      return( DL_ILLEGAL_BSPLINE_ORDER );
   }

   if ( !(draw_opt & DL_OPT_USE_LAST_SYMB) )
   {
      DLIupdate_pipe_symbology( pipe, draw_opt, color, lstyle, lweight, blend );
   }

#if defined( OPENGL )
   if ( (pipe->using_opengl) &&
        ( !(draw_opt & DL_OPT_USE_LAST_SYMB) ) )
   {
      /* make sure symbology is activated because we pass */
      /* DL_OPT_USE_LAST_SYMB to the linestring routines  */
      WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
   }
#endif
#if defined( XGL )
   if ( (pipe->using_xgl) &&
        ( !(draw_opt & DL_OPT_USE_LAST_SYMB) ) )
   {
      /* make sure symbology is activated because we pass */
      /* DL_OPT_USE_LAST_SYMB to the linestring routines  */
      WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
   }
#endif
    
#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      if ( !(draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
      }

      if ( (draw_opt & DL_OPT_HILITE_MODE) == DL_OPT_HILITE_DRAW )
      {
         /* drawing in hilite plane => get the hilite color */
         if ( pipe->base_context_info.hilite_used != WL_HILITE_USED )
         {
            DL_REPORT_ERROR( DL_ERROR );
            return( DL_ERROR );
         }

         hl_color = 1 << pipe->base_context_info.base_depth;
      }
      else
      {
         /* erasing or NOOPing the hilite plane */
         hl_color = 0;
      }

      WLget_background( pipe->lwin_no, &bg_color_ref );

      switch( draw_opt & DL_OPT_BASE_MODE )
      {
         case DL_OPT_BASE_DRAW :

            /* drawing in base planes => map the color */
            /* to get a physical value                 */
            WLmap_colorref( pipe->lwin_no, color,
                            &color_index, &red, &green, &blue, &color_flag );
   
            if ( color_flag & WL_COLOR_RGB )
            {
               curve_color = ( (blue >> 8) << 16 ) |
                             ( (green >> 8) << 8 ) |
                               (red >> 8);
            }
            else
            {
               curve_color = color_index | hl_color;
            }
            break;

         case DL_OPT_BASE_ERASE :
            /* base erase = >use the window background color */
            WLmap_colorref( pipe->lwin_no, bg_color_ref,
                            &color_index, &red, &green, &blue, &color_flag );
   
            if ( color_flag & WL_COLOR_RGB )
            {
               curve_color = ( (blue >> 8) << 16 ) |
                             ( (green >> 8) << 8 ) |
                               (red >> 8);
            }
            else
            {
               curve_color = color_index | hl_color;
            }
            break;

         case DL_OPT_BASE_NOOP :
            curve_color = hl_color;
            break;
      }  /* end: switch */

      /* convert attribute bundles to GPIPE format */
      if ( bundle_size > DLI_STATIC_GP_ATTR_SIZE )
      {
         gp_attr = (GPattribute *) malloc( bundle_size * sizeof( GPattribute ) );
      }
      else 
      {
         gp_attr = static_gp_attr;
      }

      for ( ii = 0; ii < bundle_size; ii++ )
      {
         switch( draw_opt & DL_OPT_BASE_MODE )
         {
            case DL_OPT_BASE_DRAW :
               /* drawing in base planes => map the color */
               /* to get a physical value                 */
               WLmap_colorref( pipe->lwin_no, attr_bundle[ii].color,
                               &color_index, &red, &green, &blue, &color_flag );
               if ( color_flag & WL_COLOR_RGB )
               {
                  gp_attr[ii].color = ( (blue >> 8) << 16 ) |
                                      ( (green >> 8) << 8 ) |
                                      ( red >> 8 );
               }
               else
               {
                  gp_attr[ii].color = color_index | hl_color;
               }
               break;

            case DL_OPT_BASE_ERASE :
               /* base erase => use the window background color */
               WLmap_colorref( pipe->lwin_no, bg_color_ref,
                               &color_index, &red, &green, &blue, &color_flag );
   
               if ( color_flag & WL_COLOR_RGB )
               {
                  curve_color = ( (blue >> 8) << 16 ) |
                                ( (green >> 8) << 8 ) |
                                  (red >> 8);
               }
               else
               {
                  curve_color = color_index | hl_color;
               }
               break;

            case DL_OPT_BASE_NOOP :
               /* erasing or NOOPing the base planes */
               gp_attr[ii].color = hl_color;
               break;

         }  /* end: switch */

         WLget_defined_style( attr_bundle[ii].lstyle, &pattern );
         gp_attr[ii].lstyle = pattern;

         gp_attr[ii].wgt = attr_bundle[ii].weight;
         gp_attr[ii].blend = attr_bundle[ii].blend;
         gp_attr[ii].flags = attr_bundle[ii].flags;
      }

      gpipe_opt = (draw_opt & DL_OPT_FILL) ? GP_BSC_SOLID : 0;
      if ( draw_opt & DL_OPT_DONT_CLIP )
      {
         gpipe_opt |= GP_DONT_CLIP;
      }

      sts = GPBsplineCurve( pipe->gpipe_id, curve->order, curve->num_poles, curve->poles,
                            curve->knots, curve->weights,
                            (curve->rational) ? GP_RATIONAL : GP_NONRATIONAL,
                            curve->num_boundaries, curve->bdrys, color,
                            attr_index, gp_attr, bundle_size, gpipe_opt );

       if ( bundle_size > DLI_STATIC_GP_ATTR_SIZE )
       {
          free( (char *) gp_attr );
       }

       return( (sts == 0) ? DL_SUCCESS : DL_ERROR );
   }
   else if ( pipe->using_eg )
   {
      if ( !(draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         /* make sure symbology is activated because we pass */
         /* DL_OPT_USE_LAST_SYMB to the linestring routines  */
         WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
      }
   }
#endif

   /* make sure symbology isn't changed when the */
   /* lines from this curve are processed        */
   draw_opt |= DL_OPT_USE_LAST_SYMB;

   return( DLIbspl_curve( pipe, curve->order, curve->num_poles, curve->poles, curve->knots,
                          curve->weights, curve->rational, curve->num_boundaries, curve->bdrys,
                          attr_index, attr_bundle, draw_opt, curve->periodic ) );

}  /* DLdraw_3D_curve */
