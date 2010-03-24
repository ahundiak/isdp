#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

#define RED_MASK 0xff
#define GREEN_MASK 0x00ff00
#define BLUE_MASK 0xff0000

static struct WLIraster_detail_data *WLIraster_buffers;
static WLuint16 *WLIfree_buffer_index_stack, WLIfree_buffer_stack_top;
static int WLInum_raster_buffers = 0, WLInext_raster_buffer;
static int WLInum_buffer_chunks = 0;

#if defined (XGL)

/*  memory for an XGL scanline   */

static Xgl_color	*XGLscanline = NULL;
static int		XGLscanline_size;
#endif

static WLuint16 WLIget_logical_raster_buffer( void )

/*
NAME
	WLIget_logical_raster_buffer

KEYWORD
	WL

DESCRIPTION
	This function returns an index to the next available WLIraster_detail_data
	structure from the pool of same. It malloc's upon its first invocation,
	and realloc's thereafter when more structures are needed.

PARAMETERS
	none

GLOBALS USED
	WLIraster_buffers (static)
	WLIfree_buffer_index_stack (static)
	WLIfree_buffer_stack_top (static)
	WLInum_raster_buffers (static)
	WLInext_raster_buffer (static)
	WLInum_buffer_chunks (static)

RETURN VALUES
	The logical raster number (Index in WLIraster_buffers array)

HISTORY
	Created.
		Trevor Mink 1/2/93
*/
{
   WLuint16 lras_no;

   if ( ! WLInum_buffer_chunks )
   {
      WLIraster_buffers = (struct WLIraster_detail_data *)malloc( WLI_BUFFERS_PER_CHUNK *
                                  sizeof( struct WLIraster_detail_data ) );
      WLIfree_buffer_index_stack = (WLuint16 *)malloc( WLI_BUFFERS_PER_CHUNK *
                                           sizeof( WLuint16 ) );
      WLInum_buffer_chunks = 1;
   }

   /* Realloc, if you have run out of structures (array is full) */
   if ( WLInum_raster_buffers == (WLInum_buffer_chunks * WLI_BUFFERS_PER_CHUNK))
   {
      WLInext_raster_buffer = WLInum_buffer_chunks * WLI_BUFFERS_PER_CHUNK;
      WLInum_buffer_chunks++;
      WLIraster_buffers = realloc( WLIraster_buffers, WLInum_buffer_chunks *
                                   WLI_BUFFERS_PER_CHUNK *
                                   sizeof( struct WLIraster_detail_data ) );

      WLIfree_buffer_index_stack = realloc( WLIfree_buffer_index_stack,
                                            WLI_BUFFERS_PER_CHUNK *
                                            sizeof( WLuint16 ) );
   }

   if ( WLInext_raster_buffer == (WLInum_buffer_chunks * WLI_BUFFERS_PER_CHUNK))
   {
      /* Get free raster buffer array index from stack and decrement stack top*/
      lras_no = WLIfree_buffer_index_stack[ WLIfree_buffer_stack_top-- ];
   }
   else
   {
      /* Get free raster buffer from next array element (not at end yet) */
      lras_no = WLInext_raster_buffer++;
   }
   WLInum_raster_buffers += 1;

   return ( lras_no );

} /* WLIget_logical_raster_buffer */

static void WLIgive_back_logical_raster_buffer(
   WLuint16 lras_no )
/*
NAME
	WLIgive_back_logical_raster_buffer

KEYWORD
	WL

DESCRIPTION
	This function frees index 'lras_no' of the WLIraster_buffer array of
	WLIraster_detail_data structures. It is added to the top of the
	(WLIfree_buffer_index_stack) stack as a free element.

PARAMETERS
	none

GLOBALS USED
	WLIraster_buffers (static)
	WLIfree_buffer_index_stack (static)
	WLIfree_buffer_stack_top (static)
	WLInum_raster_buffers (static)
	WLInext_raster_buffer (static)
	WLInum_buffer_chunks (static)

RETURN VALUES
	none

HISTORY
	Created.
		Trevor Mink 1/2/93
*/
{

   if( WLInum_raster_buffers > 0 )
   {
      WLIfree_buffer_index_stack[ ++WLIfree_buffer_stack_top ] = lras_no;
      WLInum_raster_buffers -= 1;
   }

} /* WLIgive_back_logical_raster_buffer */

/*--- WLblock_move--------------------------------------------*/

int WLblock_move(
   WLuint32 lwin_no,
   WLuint32 context_no,
   int src_x,
   int src_y,
   int width,
   int height,
   int dest_x,
   int dest_y)

/*
NAME
	WLblock_move

KEYWORD
	WL

DESCRIPTION
	This function copies a rectangular area of raster data from
	one location to another in the window

SYNOPSIS
	int WLblock_move(
		WLuint32 lwin_no,
		WLuint32 context_no,
		int src_x,
		int src_y,
		int width,
		int height,
		int dest_x,
		int dest_y )

PARAMETERS
	lwin_no (IN) - logical window number
	context_no (IN) - context number
	src_x (IN) - The x coordinate of the source rectangle
	src_y (IN) - The y coordinate of the source rectangle
	width (IN) - The width of the source rectangle
	height (IN) - The height of the source rectangle
	dest_x (IN) - The x coordinate of the destination rectangle
	dest_y (IN) - The y coordinate of the destination rectangle

GLOBALS USED
	none

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_CONTEXT
		The context number is invalid

	WL_BAD_PARAMETER
		One of the coordinates specifying the rectangle is invalid.

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   int sts;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;

#  if defined (XGL)
   Xgl_pt_i2d      position;
   Xgl_bounds_i2d  rectangle;
#  endif

   if ( ( src_x < 0 ) || ( src_y < 0 ) || ( width < 0 ) || ( height < 0 ) ||
      ( dest_x < 0 ) || ( dest_y < 0 ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }

   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( XGL )
   if( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      rectangle.xmin = src_x;
      rectangle.ymin = src_y;
      rectangle.xmax = src_x + width;
      rectangle.ymax = src_y + height;

      position.x = dest_x;
      position.y = dest_y;

      xgl_context_copy_buffer( 
	   win_struct->native_info.xgl_context_3D, 
	   &rectangle, 
	   &position, 
	   win_struct->native_info.win_ras );
      }
   else
#endif
#if defined( X11 )
   /* I'm assuming that the source and destination drawables are the same */
   XCopyArea( win_struct->native_info.EXdisplay, win_struct->hwin_no,
      win_struct->hwin_no, win_struct->native_info.EXgc, src_x, src_y, width,
      height, dest_x, dest_y );
#elif defined( ENV5 )

   /* We don't need context_no for Environ V, Do we for x or NT ??	*/
   blockmove( win_struct->hwin_no, src_x, src_y, ( src_x + width - 1 ),
      ( src_y + height - 1 ), dest_x, dest_y );

#elif defined( WIN32 )
   BitBlt( win_struct->native_info.hdc, dest_x, dest_y, width, height,
           win_struct->native_info.hdc, src_x, src_y, SRCCOPY );
#else
#error "A windowing system must be defined"
#endif

   return (WL_SUCCESS);

} /* WLblock_move */


/*--- WLcreate_raster_data ---------------------------------------------------------*/

int WLcreate_raster_data(
   WLuint32 lwin_no,
   WLuint32 context_no,
   struct WLraster_data *image,
   int x,
   int y,
   int width,
   int height,
   int bits_per_pixel,
   WLuint32 raster_type,
   char *raster_data)

/*
NAME
	WLcreate_raster_data

KEYWORD
	WL

DESCRIPTION
	This function initializes the 'image' structure which is used to get a
	raster image retrieved from a window.
   Points to note ONLY while 
   o  using the WL_FAST_BUFFER raster_type.
      - The image buffer is created and maintained internally, 
        hence raster_data should be NULL.
      - WLget_raster_data must be called before calling WLput_raster_data.

    o  using the WL_SLOW_BUFFER raster_type.
       - If space for raster_data is allocated by the caller, the caller
         should free it. 
   

SYNOPSIS
	int WLcreate_raster_data(
		WLuint32 lwin_no,
		WLuint32 context_no,
		struct WLraster_data *image,
		int x,
		int y,
		int width,
		int height,
		int bits_per_pixel,
		WLuint32 raster_type,
		char *raster_data)

PARAMETERS
	lwin_no (IN) - logical window number
	context_no (IN) - context number
   image (IN) - Pointer to and empty image structure.
	raster_data (IN)- The caller is responsible for allocating
	            and freeing the raster_data in WLraster_data. This is
               NULL for WL_SLOW_BUFFER raster type. The size of the
	            raster_data can be determined from WLget_raster_size(). 

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_CONTEXT
		The context is invalid

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_IMAGE_BUFFER_SIZE
		The buffer size specified by image->width and image->height
	        is invalid

	WL_BAD_DISPLAY_ORIGIN
		The image origin specified by image->x and image->y is invalid

	WL_BAD_PARAMETER
		Bad value in bits_per_pixel field of 'image'

HISTORY
   Created.
     Trevor Mink 12/14/92
   Added raster buffer arrays and changed WLraster_data structure.
     Trevor Mink 1/1/93
   Changed code to support common format for the image->buffer.
     Ravi Parthasarthy 09/10/93
*/
{
   int sts, hilite_depth;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
   struct WLIraster_detail_data *image_detail;
   int mem_size;

   if ( image == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_IMAGE );
      return ( WL_BAD_IMAGE );
   }

   image->lras_no = WLIget_logical_raster_buffer();

   image_detail = & WLIraster_buffers[ image->lras_no ];

   image_detail->fast_buffer = NULL;
   image_detail->flags = WLI_RESERVED_BIT;

   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      goto return_error;
   }

   if ( context_struct->hilite_used && 
        !( context_struct->flags & WL_SEPARATE_HILITE ) )
   {
      hilite_depth = 1;
   }
   else
   {
      hilite_depth = 0;
   }

   if ( bits_per_pixel < 1 )
   {
      sts = WL_BAD_PARAMETER; 
      goto return_error;
   }

   if ( ( x < 0 ) || ( x > WLI_SCREEN_MAX_WIDTH ) ||
      ( y < 0 ) || ( y > WLI_SCREEN_MAX_HEIGHT ) )
   {
      sts = WL_BAD_DISPLAY_ORIGIN;
      goto return_error;
   }

   if ( ( width < 0 ) || ( width > WLI_SCREEN_MAX_WIDTH ) ||
      ( height < 0 ) || ( height > WLI_SCREEN_MAX_HEIGHT ) )
   {
      sts = WL_BAD_DISPLAY_BUFFER_SIZE;
      goto return_error;
   }

   if ( raster_type == WL_SLOW_BUFFER )
   {
      if ( raster_data )
      {
         image->buffer = raster_data;
      }
      else
      {
        /* Rounding up to the next highest byte */
         mem_size = ( ( bits_per_pixel + 7 )/8 ) * width * height ;
         image->buffer = (char *)malloc( mem_size );
         image_detail->flags |= WLI_EXTERNAL_BUFFER_ALLOCATED;
      }
   }
   else if ( raster_type == WL_FAST_BUFFER )
   {
      image_detail->flags |= WLI_FAST_BUFFER;
      image->buffer = NULL;
   }
   else
   {
      sts = WL_BAD_PARAMETER;
      goto return_error;
   }


#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      image_detail->flags |= WLI_OPENGL_IMAGE;
      image_detail->opengl_buffer = NULL;

      if ( image_detail->flags & WLI_FAST_BUFFER )
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         image_detail->opengl_fast_buffer = glGenLists( 1 );
      }
      else
      {
         image_detail->opengl_fast_buffer = 0;
      }
   }
#endif

#if defined( X11 )
      {
         int depth;
         int bytes_per_line, bitmap_pad;
   
         depth =  context_struct->base_depth + hilite_depth;
         bytes_per_line =  0;
         bitmap_pad = 8;


         image_detail->fast_buffer = XCreateImage( win_struct->native_info.
                                     EXdisplay, context_struct->native_info.
                                     visual, depth, ZPixmap, 0, NULL, width,
                                     height, bitmap_pad, bytes_per_line );

         if  ( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR ) 
         {
            if( depth  == 12 )  
            {
               image_detail->red_shift = 4;
               image_detail->green_shift = 12;
               image_detail->blue_shift = 20;
            }
            else
            if( depth  == 24 )
            {
               image_detail->red_shift = 0;
               image_detail->green_shift = 8;
               image_detail->blue_shift = 16;
            }
         }
    }
#elif defined( WIN32 )
   {
      HBITMAP Bitmap;
#if DEBUG
      int planes, pixelbits;

      planes = GetDeviceCaps( win_struct->native_info.hdc, PLANES );
      pixelbits = GetDeviceCaps( win_struct->native_info.hdc, BITSPIXEL );
#endif
      image_detail->fast_buffer = CreateCompatibleDC( win_struct->native_info.hdc );
#if DEBUG
      planes = GetDeviceCaps( image_detail->fast_buffer, PLANES );
      pixelbits = GetDeviceCaps( image_detail->fast_buffer, BITSPIXEL );
#endif
      Bitmap = CreateCompatibleBitmap( win_struct->native_info.hdc,
         width, height );
      SelectObject( image_detail->fast_buffer, Bitmap );
   }
#endif
   image->x = x;
   image->y = y;

   image->width = width;
   image->height = height;

   image_detail->width = width;
   image_detail->height = height;
   image_detail->bits_per_pixel = bits_per_pixel;

   return( WL_SUCCESS );

return_error:
   WLIgive_back_logical_raster_buffer( image->lras_no );
   image->lras_no = WLI_UNDEFINED_LOGICAL_BUFFER;

   WL_REPORT_ERROR( sts );
   return ( sts );

} /* WLcreate_raster_data */


/*--- WLget_raster_data -------------------------------------------*/

int WLget_raster_data(
   WLuint32 lwin_no,
   WLuint32 context_no,
   struct WLraster_data *image)

/*
NAME
	WLget_raster_data

KEYWORD
	WL

DESCRIPTION
	This function retrieves a raster image from a window.
   Points to note ONLY while using the WL_FAST_BUFFER raster_type.
   - WLget_raster_data must be called before calling WLput_raster_data.


SYNOPSIS
	int WLget_raster_data(
		WLuint32 lwin_no,
		WLuint32 context_no,
		struct WLraster_data *image)

PARAMETERS
	lwin_no (IN) - logical window number
	context_no (IN) - context number
	image (IN)- The structure which holds the image data. WLcreate_image
		must first be called in order to initilize this structure.

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_CONTEXT
		The context is invalid

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_IMAGE_BUFFER_SIZE
		The buffer size specified by image->width and image->height
	        is invalid

	WL_BAD_DISPLAY_ORIGIN
		The image origin specified by image->x and image->y is invalid

	WL_BAD_PARAMETER
		Bad value in bits_per_pixel field of 'image'.

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   int sts;
   int bits_per_pixel;
   int bytes_per_pixel;
   WLuint32 width, height;
   unsigned long mask;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
   struct WLIraster_detail_data *image_detail;
#if defined( OPENGL )
   int ii, jj;
   GLint gl_format, gl_type;
   GLvoid *gl_pixels;
#endif
#if defined( XGL )
   Xgl_pt_i2d   position;
   Xgl_color    value;
   Xgl_boolean  obscured;
   int          x, y;
#endif
#if defined (X11)
   int i, j, pixel, count;
   WLuint32  red, green, blue;
#endif

   if ( image == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_IMAGE );
      return ( WL_BAD_IMAGE );
   }

   if ( image->lras_no == WLI_UNDEFINED_LOGICAL_BUFFER )
   {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER );
      return ( WL_BAD_DISPLAY_BUFFER );
   }

   image_detail = & WLIraster_buffers[ image->lras_no ];

   width = image->width;
   height = image->height;
   bits_per_pixel = image_detail->bits_per_pixel;

   if ( ( image->x < 0 ) || ( image->x > WLI_SCREEN_MAX_WIDTH ) ||
      ( image->y < 0 ) || ( image->y > WLI_SCREEN_MAX_HEIGHT ) )
   {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_ORIGIN );
      return( WL_BAD_DISPLAY_ORIGIN );
   }

   if ( ( width > WLI_SCREEN_MAX_WIDTH ) || ( height > WLI_SCREEN_MAX_HEIGHT )) 

   {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER_SIZE );
      return( WL_BAD_DISPLAY_BUFFER_SIZE );
   }

   sts = WLIestablish_lwin_and_context ( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#  if defined (X11)
   
   /*
    *  I had to add this code because we get an error from Xlib when
    *  then requested width/height is larger than the width and height
    *  of the window display range
    */

   if( width > win_struct->area_bounds.width ) 
      width = win_struct->area_bounds.width;

   if( height > win_struct->area_bounds.height )
      height = win_struct->area_bounds.height;
#  endif

   mask = context_struct->base_mask;

#if defined( OPENGL )
   if ( image_detail->flags & WLI_OPENGL_IMAGE )
   {
      /* don't need to setup for 2D because all coords given to */
      /* glReadPixels() are already in window coordinates       */
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
      glReadBuffer( GL_FRONT );

      if ( context_struct->base_cmap_type == WL_CMAP_INDEXED )
      {
         gl_format = GL_COLOR_INDEX;
         switch ( (bits_per_pixel + 7) / 8 )
         {
            case 1 :
               gl_type = GL_UNSIGNED_BYTE;
               bytes_per_pixel = 1;
               break;
            case 2 :
               gl_type = GL_UNSIGNED_SHORT;
               bytes_per_pixel = 2;
               break;
            case 4 :
               gl_type = GL_UNSIGNED_INT;
               bytes_per_pixel = 4;
               break;
         }
      }
      else
      {
         gl_format = GL_RGB;
         gl_type = GL_UNSIGNED_BYTE;
         bytes_per_pixel = 3;
      }

      if ( image_detail->flags & WLI_FAST_BUFFER )
      {
         /* read image from screen and build a display list for it */
         gl_pixels = malloc( bytes_per_pixel * width * height );
         glReadPixels( image->x, win_struct->area_bounds.height - (image->y + image->height + 1),
                       image->width, image->height, gl_format, gl_type, gl_pixels );

         glNewList( image_detail->opengl_fast_buffer, GL_COMPILE );
         glDrawPixels( image->width, image->height, gl_format, gl_type, gl_pixels );
         glEndList();
      
         WLI_FREE( gl_pixels );
      }
      else
      {
         /* read a line at a time so we can reformat */
         gl_pixels = malloc( bytes_per_pixel * width );
         count = 0;
         for ( ii = 0; ii < height; ii++ )
         {
            glReadPixels( image->x, win_struct->area_bounds.height - (image->y + ii + 1),
                          image->width, 1, gl_format, gl_type, gl_pixels );
            if ( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR )
            {
               for ( jj = 0; jj < width; jj++ )
               {
                  (( int *)image->buffer)[count] =
                              ((unsigned char *)gl_pixels)[jj*3] << image_detail->red_shift |
                              ((unsigned char *)gl_pixels)[jj*3+1] << image_detail->green_shift |
                              ((unsigned char *)gl_pixels)[jj*3+2] << image_detail->blue_shift;
                  count++;
               }
            }
            else
            {
               switch ( bytes_per_pixel )
               {
                  case 1:
                     memcpy( &((char *)image->buffer)[count], gl_pixels, bytes_per_pixel * width );
                     break;
                  case 2:
                     memcpy( &((short *)image->buffer)[count], gl_pixels, bytes_per_pixel * width );
                     break;
                  case 4:
                     memcpy( &((int *)image->buffer)[count], gl_pixels, bytes_per_pixel * width );
                     break;
               }
               count += width;
            }
         }
         WLI_FREE( gl_pixels );
      }

      return( WL_SUCCESS );
   }
#endif

#if defined (XGL)
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
   {
      if( image_detail->flags & WLI_FAST_BUFFER )
      {
      }

      else
      {
         position.y = image->y;
         count = 0;
      
         for( y=0; y<height; y++, position.y++ )
         {
            position.x = image->x;
            for( x=0; x<width; x++, position.x++, count++ )
            {
               obscured = xgl_context_get_pixel(
                                 win_struct->native_info.xgl_context_3D,
                                 &position,
                                 &value );
   
               if( context_struct->base_cmap_type == WL_CMAP_INDEXED )
                  image->buffer[count] = value.index;
      
               else
               {
                  ((int *)image->buffer)[count] =
                     ((unsigned char)(value.rgb.r * 255.0)) |
                     ((unsigned char)(value.rgb.g * 255.0) << 8) |
                     ((unsigned char)(value.rgb.b * 255.0) << 16);
               }      
            }
         }
      }
      return ( WL_SUCCESS );
   }

#endif
#if defined( X11 )
  /* XGetImage allocates  space for buffer  */

   if(  image_detail->flags & WLI_INTERNAL_BUFFER_ALLOCATED ) 
   {
      WLI_FREE( image_detail->fast_buffer->data );
      image_detail->flags &= ~(WLI_INTERNAL_BUFFER_ALLOCATED) ;
   }

   image_detail->fast_buffer = XGetImage( win_struct->native_info.EXdisplay,
      win_struct->hwin_no, image->x, image->y, width, height, mask, ZPixmap );

   image_detail->flags |= WLI_INTERNAL_BUFFER_ALLOCATED;
   
   if(!( image_detail->flags & WLI_FAST_BUFFER) )
   {
         count = 0;
         for ( j = 0; j < height; j++ )
         {
            for(i=0;i<width;i++)
            {
               pixel = XGetPixel(image_detail->fast_buffer, i, j );
               if(context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR )
               {
                  red = ( pixel & image_detail->fast_buffer->red_mask ) 
                          >> context_struct->red_shifter ;
                  green = ( pixel & image_detail->fast_buffer->green_mask ) 
                          >> context_struct->green_shifter ;
                  blue = ( pixel & image_detail->fast_buffer->blue_mask ) 
                          >> context_struct->blue_shifter ;
                  (( int *)image->buffer)[count] = 
                                         red << image_detail->red_shift
                                       | green << image_detail->green_shift
                                       | blue << image_detail->blue_shift ;
               }
               else
               {
                  image->buffer[count]= pixel ;
               }
               ++count;
            }
         }
   }
#elif defined( ENV5 )
   bytes_per_pixel = ( bits_per_pixel + 7 )/8 ;
   if( image_detail->flags & WLI_FAST_BUFFER )
   {
      sts = saverasterblock( win_struct->hwin_no, image->x, image->y, 
                       image->x + width - 1, image->y + height - 1, 
                       &image_detail->fast_buffer );
      if( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      image->buffer = NULL;
   }
   else
   {
      if ( ( width == 1 ) || ( height == 1 ) )
      {
         if  ( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR ) 
         {
           /* Because getline() doesn't work in TRUE COLOR */
            sts = getlinedata( win_struct->hwin_no,image->x, image->y,  
                           image->x + width - 1, image->y + height - 1,
                           IMAGE_DATA, (long *)image->buffer );
            if( sts )
            {
               WL_REPORT_ERROR( WL_SYSTEM_ERROR );
               return( WL_SYSTEM_ERROR );
            }
         }
         else
         {
           /* Because getlinedata() doesn't work on an EDGE II in INDEX mode */
            switch( bytes_per_pixel )
            {
               case 1:

               sts = getline( win_struct->hwin_no, mask,image->x,image->y,  
                              image->x + width - 1, image->y + height - 1,
                              (char *)image->buffer );
               if( sts )
               {
                  WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                  return( WL_SYSTEM_ERROR );
               }
               break;

               case 2:

               sts = getline16( win_struct->hwin_no, mask, image->x,
                                image->y, image->x + width - 1, 
                                image->y + height - 1,
                                ( short * )image->buffer );
               if( sts )
               {
                  WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                  return( WL_SYSTEM_ERROR );
               }

               case 4:

               sts = getline32( win_struct->hwin_no, mask, image->x,
                                image->y, image->x + width - 1, 
                                image->y + height - 1,
                                ( long *)image->buffer );
               if( sts )
               {
                  WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                  return( WL_SYSTEM_ERROR );
               }
               break;
            }
         }
      }
      else
      {
         if  ( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR ) 
         {
            /* Because getpixelblock() doesn't work in TRUE COLOR */
            sts = getblockdata( win_struct->hwin_no,image->x,image->y, 
                                image->x + width - 1 , image->y + height -1,
                                IMAGE_DATA,(long *) image->buffer );
            if( sts )
            {
               WL_REPORT_ERROR( WL_SYSTEM_ERROR );
               return( WL_SYSTEM_ERROR );
            }
         }
         else
         {
            switch( bytes_per_pixel )
            {
               case 1:

               sts = getpixelblock( win_struct->hwin_no, mask, image->x,
                                    image->y, image->x + width - 1 , 
                                    image->y + height -1, 
                                    (char *) image->buffer );
               if( sts )
               {
                  WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                  return( WL_SYSTEM_ERROR );
               }
               break;
               case 2:
               sts = getpixelblock16( win_struct->hwin_no, mask, image->x,
                                      image->y, image->x + width - 1 , 
                                      image->y + height -1, 
                                      ( short *) image->buffer );
               if( sts )
               {
                  WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                  return( WL_SYSTEM_ERROR );
               }
               break;
               case 4:
               sts = getpixelblock32( win_struct->hwin_no, mask, image->x,
                                      image->y, image->x + width - 1 , 
                                      image->y + height -1, 
                                      ( long *) image->buffer );
               if( sts )
               {
                  WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                  return( WL_SYSTEM_ERROR );
               }
               break;
            }
         }
         
      }
   }
#elif defined( WIN32 )
   sts = BitBlt( image_detail->fast_buffer, 0, 0, width, height,
      win_struct->native_info.hdc, image->x, image->y, SRCCOPY );
   if ( !sts )
   {
      return( WL_SYSTEM_ERROR );
   }

/*      GetBitmapBits();
*/
#endif

   return ( WL_SUCCESS );

} /* WLget_raster_data */


/*--- WLput_raster_data -------------------------------------------*/

int WLput_raster_data(
      WLuint32 lwin_no,
      WLuint32 context_no,
      struct WLraster_data *image)
/*
NAME
   WLput_raster_data

KEYWORD
   WL

DESCRIPTION
   This function displays a raster image on a window.
   For FAST_BUFFER raster_type, caller must call WLget_raster_data 
   before making a call to this function.

SYNOPSIS
   int WLput_raster_data(
      WLuint32 lwin_no,
      WLuint32 context_no,
      struct WLraster_data *image)

PARAMETERS
   lwin_no (IN) - logical window number
   context_no (IN)  - context number
   image (IN) - raster image

GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_PARAMETER
      The "image" pointer is NULL or type is invalid

   WL_BAD_CONTEXT
      The context is invalid
   
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid

   WL_BAD_DISPLAY_BUFFER_SIZE
      The buffer size specified by image->width and image->height
      is invalid.

   WL_BAD_DISPLAY_ORIGIN
      The image origin specified by image->x and image->y is invalid

   WL_BAD_DISPLAY_BUFFER
      The pointer image->buffer is NULL

HISTORY
   08/28/92 Shridar Subramanian
      Initial definition

   10/22/92 Shridar Subramanian
      Initial design

   3/10/95 Mike Lanier
      Modified for XGL port
*/

   {
   int			sts;
   int			bits_per_pixel;
   int			bytes_per_pixel;
   unsigned long	mask;
   WLuint32		width, height;
   struct WLIwin	*win_struct;
   struct WLIcontext	*context_struct;

   struct WLIraster_detail_data	*image_detail;

#  if defined (OPENGL)
   int			ii, jj, index, jj3, ii3w;
   GLint		gl_unpack_alignment;
   GLint		gl_type;
#  endif

#  if defined (XGL)
   Xgl_boolean		obscured;
   int			x, y;
   struct WLcmap_entry	*ct8;		/*  address of the 8bit colortable  */
					/*  from the forms context  */
   WLuint16		lscreen_no;	/*  active screen number */
   WLuint8		offset;		/*  screen array offset for the */
					/*  forms context */
   WLuint8		group_index;    /*  screen array group index */
   WLuint32		context_no8;    /*  forms context number  */
   WLuint8		*b8;		/*  used when accessing the user */
					/*  array as 8 bit data */
   WLuint32		*b32;		/*  used when accessing the user */
					/*  array as 32 bit data */
#  endif

#  if defined (X11)
   WLuint32		mem_size, i, j, count; 
   int			red,green, blue, pixel;
   struct WLbounds	area_bounds;
#  endif

   if( image == NULL )
      {
      WL_REPORT_ERROR( WL_BAD_IMAGE );
      return( WL_BAD_IMAGE );
      }

   if( image->lras_no == WLI_UNDEFINED_LOGICAL_BUFFER )
      {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER );
      return( WL_BAD_DISPLAY_BUFFER );
      }

   image_detail = &WLIraster_buffers[image->lras_no];

   bits_per_pixel = image_detail->bits_per_pixel;

#  if defined (X11)
   if( (!(image_detail->flags & WLI_OPENGL_IMAGE)) &&
       (image_detail->flags & WLI_FAST_BUFFER) && 
       (image_detail->fast_buffer->data == NULL) )
      {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER );
      return( WL_BAD_DISPLAY_BUFFER );
      }

   WLget_window_bounds( lwin_no, NULL, &area_bounds );
#  endif

   if( (image->buffer == NULL) && !(image_detail->flags & WLI_FAST_BUFFER) )
      {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER );
      return( WL_BAD_DISPLAY_BUFFER );
      }

   if( (image->x < 0) || (image->x > WLI_SCREEN_MAX_WIDTH) ||
       (image->y < 0) || (image->y > WLI_SCREEN_MAX_HEIGHT) )
      {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_ORIGIN );
      return( WL_BAD_DISPLAY_ORIGIN );
      }

   width = image->width;
   height = image->height;

   if( (width > WLI_SCREEN_MAX_WIDTH) || (height > WLI_SCREEN_MAX_HEIGHT) )
      {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER_SIZE );
      return( WL_BAD_DISPLAY_BUFFER_SIZE );
      }

   sts = WLIestablish_lwin_and_context( &lwin_no, 
                                        &context_no, 
                                        &win_struct, 
                                        &context_struct );
   if( sts != WL_SUCCESS )
      {
      WL_REPORT_ERROR( sts );
      return( sts );
      }

   mask = context_struct->base_mask;

#  if defined (OPENGL)
   if( image_detail->flags & WLI_OPENGL_IMAGE )
      {
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );

      /* enable dithering (for better images) and disable ZBuffering */
      /* because this could be a shading window                      */

      glPushAttrib( GL_COLOR_BUFFER_BIT | 
                    GL_DEPTH_BUFFER_BIT |
                    GL_VIEWPORT_BIT );

      glEnable( GL_DITHER );
      glDisable( GL_DEPTH_TEST );

      if( context_struct->base_cmap_type == WL_CMAP_INDEXED )
         {
         glIndexMask( 0xFFFFFFFF );
         }
      else
         {
         glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
         }
      
      WLI_SETUP_OPENGL_FOR_2D( win_struct, 0 );
      glViewport(0, 0,
                 win_struct->area_bounds.width,
                 win_struct->area_bounds.height );

      glPixelZoom( 1.01, 1.01 );

      /* remember that glRasterPos() goes through matrix transformation */

      glRasterPos2i( image->x, image->y + (image->height - 1) );

      if( !( image_detail->flags & WLI_FAST_BUFFER) )
         {

         /* cannot push this state, so we must query and reset it ourselves */

         glGetIntegerv( GL_UNPACK_ALIGNMENT, &gl_unpack_alignment );

         if( context_struct->base_cmap_type == WL_CMAP_INDEXED )
            {
            bytes_per_pixel = (image_detail->bits_per_pixel + 7) / 8;
            if( ((image_detail->width < width) || 
                  (image_detail->height < height) ) ||
                (!(image_detail->flags & WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED)))
               {
               if( image_detail->flags & WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED )
                  {
                  WLI_FREE( image_detail->opengl_buffer );
                  }

               image_detail->opengl_buffer = malloc( bytes_per_pixel * 
                                                     width * height ) ;
               image_detail->height = height;
               image_detail->width = width;
               image_detail->flags |= WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED;
               }
 
            /* invert the raster to account for OpenGL's origin in lower left */

            switch ( bytes_per_pixel )
               {
               case 1:
                  gl_type = GL_UNSIGNED_BYTE;
                  glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
                  index = 0;

                  for( ii=height-1; ii>=0; ii-- )
                     {
                     for( jj=0; jj<width; jj++ )
                        {
                        ((char *)image_detail->opengl_buffer)[ii*width + jj] = 
                           ((char *)image->buffer)[index];
                        index++;
                        }
                     }   
                  break;

               case 2:
                  gl_type = GL_UNSIGNED_SHORT;
                  glPixelStorei( GL_UNPACK_ALIGNMENT, 2 );

                  for( ii=height-1; ii>=0; ii-- )
                     {
                     for( jj=0; jj<width; jj++ )
                        {
                        ((short *)image_detail->opengl_buffer)[ii*width + jj] = 
                           ((short *)image->buffer)[index];
                        index++;
                        }
                     }   
                  break;

               case 4:
                  gl_type = GL_UNSIGNED_INT;
                  glPixelStorei( GL_UNPACK_ALIGNMENT, 4 );

                  for( ii=height-1; ii>=0; ii-- )
                     {
                     for( jj=0; jj<width; jj++ )
                        {
                        ((int *)image_detail->opengl_buffer)[ii*width + jj] = 
                           ((int *)image->buffer)[index];
                        index++;
                        }
                     }   
                  break;
               }
            
            glDrawPixels( width, height, 
                          GL_COLOR_INDEX, 
                          gl_type, 
                          image_detail->opengl_buffer );
            }
         else
            {
            if( ((image_detail->width < width) || 
                 (image_detail->height < height) ) ||
                (!(image_detail->flags & WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED)))
               {
               if( image_detail->flags & WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED )
                  {
                  WLI_FREE( image_detail->opengl_buffer );
                  }

               image_detail->opengl_buffer = malloc( 3 * width * height ) ;
               image_detail->height = height;
               image_detail->width = width;
               image_detail->flags |= WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED;
               }

            /* invert the raster to account for OpenGL's origin in lower left */

            index = 0;
            for( ii=height-1; ii>=0; ii-- )
               {
               ii3w = ii * 3 * width;  /* better to do once than width*3 times */

               for( jj=0; jj<width; jj++ )
                  {
                  jj3 = jj * 3 + ii3w;  /* better to do once than 3 times  */

                  image_detail->opengl_buffer[jj3] = 
                     (((int *)image->buffer)[index]) & 0xFF;

                  image_detail->opengl_buffer[jj3+1] = 
                     ((((int *)image->buffer)[index]) & 0xFF00) >> 8;

                  image_detail->opengl_buffer[jj3+2] = 
                     ((((int *)image->buffer)[index]) & 0xFF0000) >> 16;

                  index++;
                  }
               }   

            glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
            glDrawPixels( width, height, 
                          GL_RGB, 
                          GL_UNSIGNED_BYTE, 
                          image_detail->opengl_buffer );
            }

         glPixelStorei( GL_UNPACK_ALIGNMENT, gl_unpack_alignment );
         glPixelZoom( 1.0, 1.0 );
         }
      else
         {
         glCallList( image_detail->opengl_fast_buffer );
         }

      WLI_RESTORE_OPENGL_TO_3D( 0 );

      glPopAttrib();
      return( WL_SUCCESS );
      }
#  endif

#  if defined( XGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      if( image_detail->flags & WLI_FAST_BUFFER )
         {
         }

      else
         {
         if( context_struct->base_cmap_type != WL_CMAP_INDEXED && 
             bits_per_pixel == 8 )
            {

            /*  If we're in a non-INDEX window and the raster data is */
            /*  8 bits per pixel, get the colortable from the 8bit  */
            /*  context created for forms.  To do this, first I have  */
            /*  to get the screen number from the active context, then  */
            /*  using this, get the context number of the forms context */
            /*  and then, from the forms context, get the indices with  */
            /*  I'll index into the screen array to get the colortable  */
            /*  address.  Mike Lanier */
 
            WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );

            /*-----------------------------------------------------------------
             *
             * I was orignially going to ignore the colormap of the active 
             * window context, and use the one in the forms context, but
             * but it didn't work out for display image. So, I've made
             * sure that the local colormap of the active window context is
             * valid and am now using that (Mike 01/10/96)
             *
             * WLIcontext_unpack( context_no, &lscreen_no, NULL, NULL );
             * CMget_exnuc_forms_context( lscreen_no, &context_no8 );
             * WLIcontext_unpack( context_no8, NULL, &group_index, &offset );
             */

            ct8 = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group[offset].local_colormap;

            } /* if not WL_CMAP_INDEXED && bits_per_pixel == 8  */

  
         /*  If the raster data is 8 bits per pixel, we want to access the  */
         /*  raster data buffer as 8 bit data, else we will access it as  */
         /*  32 bit data  */

         if( bits_per_pixel == 8 )
            b8 = (WLuint8 *)image->buffer;
         else
            b32 = (WLuint32 *)image->buffer;


         /*  allocate memory for the XGL scanline  */

         if( width > XGLscanline_size )
            {
            XGLscanline_size = ((width/100)+1)*100;

            if( XGLscanline == NULL )
               XGLscanline = (Xgl_color *)malloc( XGLscanline_size * 
                                                    sizeof( Xgl_color ) ); 
            else
               XGLscanline = (Xgl_color *)realloc( XGLscanline, 
                                                   XGLscanline_size * 
                                                     sizeof( Xgl_color ) ); 

            } /* if( width > XGLscanline_size ) */
      
         for( y=0; y<height; y++ )
            {

            /*  If the window is INDEXED, simple transfer the data from  */
            /*  the user buffer to the XGLscanline buffer  */

            if( context_struct->base_cmap_type == WL_CMAP_INDEXED )
               {
               for( x=0; x<width; x++, b8++ )
                  XGLscanline[x].index = *b8;
               }
   
            /*  This is something a little unothadox that I add for the  */
            /*  XGL port.  If caller attempts to display 8bit raster data  */
            /*  in a 24bit window, then we user the byte value in the user */
            /*  buffer as an index into the 8bit colormap built for the */
            /*  forms context.  Mike Lanier  */

            else
            if( bits_per_pixel == 8 )
               {
               for( x=0; x<width; x++, b8++ )
                  {
                  XGLscanline[x].rgb.r = (float)(ct8[*b8].red)/65535.0;
                  XGLscanline[x].rgb.g = (float)(ct8[*b8].green)/65535.0;
                  XGLscanline[x].rgb.b = (float)(ct8[*b8].blue)/65535.0;
                  }
               }

            /*  If non of the above, then we're displaying RGB raster in  */
            /*  a true color window.  The data input data is packed in a  */
            /*  32 bit integer.  Unpack it an put it in the XGLscanline  */
            /*  buffer  */

            else
               {
               for( x=0; x<width; x++, b32++ )
                  {
                  XGLscanline[x].rgb.r = (float) (*b32 & 0xff)/255.0;
                  XGLscanline[x].rgb.g = (float)((*b32 & 0xff00) >> 8)/255.0;
                  XGLscanline[x].rgb.b = (float)((*b32 & 0xff0000) >> 16)/255.0;
                  }
               }

            xgl_context_set_pixel_row(
                     win_struct->native_info.xgl_context_3D,
                     image->x,
                     image->y+y,
                     width,
                     XGLscanline );

            } /* for y...*/

         } /* else: image_detail->flags & WLI_FAST_BUFFER */

      return( WL_SUCCESS );

      } /* if( win_struct->flags & WLI_WIN_FLAGS_USING_XGL ) */

#  endif /* if XGL */

#  if defined( X11 )
   if( width > area_bounds.width ) width = area_bounds.width;
   if( height > area_bounds.height ) height = area_bounds.height;

   if( ((image_detail->width < width) || (image_detail->height < height)) && 
       (image_detail->flags & WLI_INTERNAL_BUFFER_ALLOCATED) )
      {
      WLI_FREE( image_detail->fast_buffer->data );

      image_detail->fast_buffer->data =
         malloc( image_detail->fast_buffer->bytes_per_line * height ) ;

      image_detail->height = height;
      image_detail->width = width;
      image_detail->flags |= WLI_INTERNAL_BUFFER_ALLOCATED;
      }

   if( !(image_detail->flags & WLI_INTERNAL_BUFFER_ALLOCATED) )
      {
      image_detail->fast_buffer->data =
         malloc( image_detail->fast_buffer->bytes_per_line * height ) ;

      image_detail->height = height;
      image_detail->width = width;
      image_detail->flags |= WLI_INTERNAL_BUFFER_ALLOCATED;
      }

   if( !(image_detail->flags & WLI_FAST_BUFFER) )
      {
      count=0;
      for( j=0; j<image->height; j++ )
         {
         for( i=0; i < image->width; i++ )
            { 
            if( i < area_bounds.width && j < area_bounds.height )
               { 
               if( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR )
                  {
                  red = ((((int *)image->buffer)[count]) & RED_MASK) 
                           >> image_detail->red_shift; 
                  green = ((((int *)image->buffer)[count]) & GREEN_MASK)
                             >> image_detail->green_shift; 
                  blue = ((((int *)image->buffer)[count]) & BLUE_MASK)
                            >> image_detail->blue_shift; 

                  pixel =  red << context_struct->red_shifter |
                           green << context_struct->green_shifter |
                           blue << context_struct->blue_shifter ;
                  }
               else
                  {
                  pixel = image->buffer[count];
                  }

               XPutPixel( image_detail->fast_buffer, 
                          i, j, 
                          pixel );
               }

            count++ ;
            }
         }
      }
   else
      {
      /* Not doing the line below bcoz WLget_raster_data is called for  */
      /* FAST_BUFFER.  image_detail->fast_buffer->data = image->buffer ; */
      }

   XPutImage( win_struct->native_info.EXdisplay, 
              win_struct->hwin_no, 
              win_struct->native_info.EXgc, 
              image_detail->fast_buffer, 
              0, 0, 
              image->x, image->y, 
              width, height );
 

#  elif defined( ENV5 )
   bytes_per_pixel = ( bits_per_pixel + 7 )/8 ;

   if( image_detail->flags & WLI_FAST_BUFFER )
      {
      sts = restorerasterblock( win_struct->hwin_no, 
                                image->x, image->y, 
                                image_detail->fast_buffer );
      if( sts )
         {
          WL_REPORT_ERROR( WL_SYSTEM_ERROR );
          return( WL_SYSTEM_ERROR );
         }
      }
   else
      {
      if( (width == 1) || (height == 1) )
         {
         if( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR ) 
            {

            /* Because putline() doesn't work in TRUE COLOR */

            sts = putlinedata( win_struct->hwin_no, 
                               image->x, image->y, 
                               image->x + width - 1, 
                               image->y + height - 1, 
                               IMAGE_DATA, 
                               (long *)image->buffer );
            if( sts )
               {
               WL_REPORT_ERROR( WL_SYSTEM_ERROR );
               return( WL_SYSTEM_ERROR );
               }
            }
         else
            {
            switch( bytes_per_pixel )
               {
               case 1:
                  sts = putline( win_struct->hwin_no, 
                                 mask, 
                                 image->x, image->y, 
                                 image->x + width - 1, 
                                 image->y + height - 1, 
                                 (char *)image->buffer );
                  if( sts )
                     {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                     }
                  break;

               case 2:
                  sts = putline16( win_struct->hwin_no, 
                                   mask, 
                                   image->x, image->y, 
                                   image->x + width - 1, 
                                   image->y + height - 1, 
                                   (short *)image->buffer );
                  if( sts )
                     {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                     }
                  break;

               case 4:
                  sts = putline32( win_struct->hwin_no, 
                                   mask, 
                                   image->x, image->y, 
                                   image->x + width - 1, 
                                   image->y + height - 1, 
                                   (long *)image->buffer );
                  if( sts )
                     {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                     }
                  break;
               }    
            }
         }        
      else
         {
         if( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR ) 
            {

            /* Because putblock() doesn't work in TRUE COLOR */

            sts = putblockdata( win_struct->hwin_no,
                                image->x, image->y,
                                image->x + width - 1, 
                                image->y + height - 1,
                                IMAGE_DATA, 
                                (long *)image->buffer );
            if( sts )
               {
               WL_REPORT_ERROR( WL_SYSTEM_ERROR );
               return( WL_SYSTEM_ERROR );
               }
            } 
         else
            {
            switch( bytes_per_pixel )
               {
               case 1:
                  sts = putpixelblock( win_struct->hwin_no, 
                                       mask, 
                                       image->x, image->y, 
                                       image->x + width - 1, 
                                       image->y + height - 1, 
                                       (char *)image->buffer );
                  if( sts )
                     {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                     }
                  break;

               case 2:

                  sts = putpixelblock16( win_struct->hwin_no, 
                                         mask, 
                                         image->x, image->y, 
                                         image->x + width - 1, 
                                         image->y + height - 1, 
                                         (short *)image->buffer );
                  if( sts )
                     {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                     }
                  break;

               case 4:
                  sts = putpixelblock32( win_struct->hwin_no, 
                                         mask, 
                                         image->x, image->y, 
                                         image->x + width - 1, 
                                         image->y + height - 1, 
                                         (long *)image->buffer );
                  if( sts )
                     {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                     }
                  break;
               }
            }
         }
      }

#  elif defined( WIN32 )
   sts = BitBlt( win_struct->native_info.hdc, 
                 image->x, image->y, 
                 width, height, 
                 image_detail->fast_buffer, 
                 0, 0, 
                 SRCCOPY );
   if ( !sts )
      {
      return ( WL_SYSTEM_ERROR );
      }
#  endif
   return ( WL_SUCCESS );

   } /* WLput_raster_data */

/*--- WLfree_raster_data -----------------------------------------------------*/

int WLfree_raster_data(
   struct WLraster_data *image)
/*
NAME
	WLfree_raster_data

KEYWORD
	WL

DESCRIPTION
	This function frees the raster memory associated with 'image'.
	For WL_SLOW_BUFFER, it frees image->buffer memory, otherwise, it
	calls freerasterblock with image->fast_buffer. If user allocates his
   own buffer, this routine will not free it. This function has to be called
   if WLcreate_raster_data is called .

SYNOPSIS
	int WLfree_raster_data(
		struct WLraster_data *image)

NOTE
	

PARAMETERS
	image (IN) - raster image

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_PARAMETER
		The "image" pointer is NULL or type is invalid

	WL_BAD_CONTEXT
		The context is invalid

	WL_BAD_DISPLAY_BUFFER_SIZE
		The buffer size specified by image->width and image->height
		is invalid.

	WL_BAD_DISPLAY_ORIGIN
		The image origin specified by image->x and image->y is invalid

	WL_BAD_DISPLAY_BUFFER
		The pointer image->buffer is NULL

HISTORY
	07/10/93 Initial definition. - Ravi Parthasarathy
   07/10/93 Implementation - Ravi Parthasarathy
*/
{
   struct WLIraster_detail_data *image_detail;

   if ( image == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_IMAGE );
      return ( WL_BAD_IMAGE );
   }

   if ( image->lras_no == WLI_UNDEFINED_LOGICAL_BUFFER )
   {
      WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER );
      return ( WL_BAD_DISPLAY_BUFFER );
   }

   image_detail = & WLIraster_buffers[ image->lras_no ];

   /*----------------------------------------------------------------------
    *  put this in because I have a case from display image where this 
    *  returns NULL... Mike 1/24/96
    */

   if( image_detail == NULL )
      return ( WL_SUCCESS );

   if ( !(image_detail->flags & WLI_FAST_BUFFER ))
   {
      if ( image_detail->flags & WLI_EXTERNAL_BUFFER_ALLOCATED )
      {
          if(image->buffer)
          {
             /*-------------------------------------------------------------
              *  I took this out because buffer was an invalid pointer.  I've
              *  seen cases where display image would use this field and forget
              *  to clear it, and the value would not be something returned by
              *  malloc.  I;ll put this back when I have this problem solved.
              *  Mike 1/24/96
              */

             /*WLI_FREE( image->buffer );*/
             image->buffer = NULL;
          }
          image_detail->flags &= (~(WLI_EXTERNAL_BUFFER_ALLOCATED)) ;
      }
   }

#if defined( OPENGL )
   if ( image_detail->flags & WLI_OPENGL_IMAGE )
   {
      WLI_FREE( image_detail->opengl_buffer );

      if ( image_detail->flags & WLI_FAST_BUFFER )
      {
         glDeleteLists( 1, 1 );
      }
   }
#endif

#if defined( ENV5 )
   if ( image_detail->flags & WLI_FAST_BUFFER )
   {
      if( image_detail->fast_buffer )
      {
         freerasterblock( image_detail->fast_buffer );
         image_detail->fast_buffer = NULL;
      }
      else
      {
         WL_REPORT_ERROR( WL_BAD_DISPLAY_BUFFER );
         return( WL_BAD_DISPLAY_BUFFER );
      }
   }
#elif defined( X11 )
   if( ( image_detail->flags & WLI_INTERNAL_BUFFER_ALLOCATED ) &&
       ( image_detail->fast_buffer->data) )
   {
            WLI_FREE( image_detail->fast_buffer->data );
            image_detail->flags &= (~(WLI_INTERNAL_BUFFER_ALLOCATED)) ;
   }
   if ( image_detail->fast_buffer )
   {
      image_detail->fast_buffer->data = NULL;
      XDestroyImage( image_detail->fast_buffer );
   }
#elif defined( WIN32 )
   {
      HGDIOBJ Bitmap;
      
      Bitmap = SelectObject( image_detail->fast_buffer, NULL );
      DeleteObject( Bitmap );
      DeleteDC( image_detail->fast_buffer );
      image_detail->fast_buffer = NULL;
   }
#endif
   WLIgive_back_logical_raster_buffer( image->lras_no );
   image->lras_no = WLI_UNDEFINED_LOGICAL_BUFFER;

   return ( WL_SUCCESS );

} /* WLfree_raster_data */

/*--- WLget_raster_size -----------------------------------------------------*/

int WLget_raster_size( 
   WLuint32 lwin_no,
    WLuint32 width,
    WLuint32 height,
    int *size)
/*
NAME
	WLget_raster_size

KEYWORD
	WL

DESCRIPTION
	This function  returns the size in bytes required to allocate
   memory for a raster buffer beloging to a given window..

SYNOPSIS
int WLget_raster_size( 
   WLuint32 lwin_no,
   WLuint32 width,
   WLuint32 height,
   int *size)

NOTE


PARAMETERS
   lwin_no(IN)
	width (IN) - width of  image
	height (IN) - height of  image
   size (OUT) - size in bytes.

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_PARAMETER
      The width or height is less than zero.


HISTORY
	07/10/93 Initial definition. -Ravi Parthasarathy
*/
{
   int sts;
   struct WLIwin win_struct;
   struct WLnative_info native_info;
   WLuint32 context_no;
#if defined ( ENV5)
   struct vlt_info v_info;
   int vlt_type;
#else
   struct WLIcontext context_struct ;
#endif


   if (( width < 1 )|| (height < 1) )
   {
      WL_REPORT_ERROR( WL_BAD_IMAGE );
      return ( WL_BAD_IMAGE );
   }

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

#if defined( ENV5 )
   sts = WLget_window_base_context( lwin_no, &context_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   sts = WLget_native_info( lwin_no, context_no,&native_info );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   if( native_info.vlt_no == -1 )
   {
      sts = Inq_vlt_info( native_info.vs_no,
                             INDEXED_COLOR_DATA, &v_info );
      if ( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   }
   else
   {
      sts = Inq_vlt_type( native_info.vlt_no,  &vlt_type );
      if ( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      switch (vlt_type)
      {
         case INDEXED_COLOR_VLT:
            sts = Inq_vlt_info( native_info.vs_no, INDEXED_COLOR_DATA, &v_info );
            break;            
         case PSEUDO_TRUE_COLOR_VLT:
            sts = Inq_vlt_info( native_info.vs_no, PSEUDO_TRUE_COLOR_DATA, &v_info );
            break;            
         case TRUE_COLOR_VLT:
            sts = Inq_vlt_info( native_info.vs_no, TRUE_COLOR_DATA, &v_info );
            break;            
      }
      if ( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }


   }
 
   *size = v_info.vlti_num_bytes_per_pixel * width * height ;

#elif defined( X11 )
   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   if( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      *size = width * height * 4;
   }
   else 
   {
      *size = width * height; 
   }
#endif

return( WL_SUCCESS );

} /* WLget_raster_size */
