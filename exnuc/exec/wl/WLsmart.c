#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include "wl.h"
#include "wl_internal.h"

static WLuint32 prev_bg;
static WLuint8 bg_buffer_c[100];
static WLuint16 bg_buffer_s[100];
static WLuint32 bg_buffer_i[100];
static int first_time = WLI_TRUE;
#if defined (X11)
static int screen_width, screen_height;
#endif

 
/*--- WLis_region_empty--------------------------------------------*/
 
int WLis_region_empty( WLuint32 lwin_no,
                       int x,
                       int y,
                       int pixels,
                       int *region)
 
/*
NAME
   WLis_region_empty

KEYWORD
   WL
 
DESCRIPTION
   This function to check if there are any pixel active ( different from
   the background ) in a square centered on the hot spot of the mouse 

 
SYNOPSIS
   int WLis_region_empty( WLuint32 lwin_no, 	 
                          int x,
                          int y,
                          int pixels,
                          int *region)

PARAMETERS
   pixels (IN)  - Number of pixels
   region   (OUT) - the flag indicating whether the region is empty.

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/05/93 Henry Bequet
      Initial definition
 
   06/07/93 Ravi Parthasarathy
      Initial design

   06/07/93 Ravi Parthasarathy
      Development 
*/
{
   int sts;
   int width, height;
   int x_origin, y_origin;
   int xmax_image, ymax_image;
   WLuint32 red, green, blue;
   WLuint32 context_no;
   WLuint32 test_pixel;
   int bits_per_pixel;
   int i=0,j=0;
   struct WLIwin* win_struct;
   struct WLIcontext* context_struct;
   int hilite_depth;
   WLuint16 lscreen_no;
   WLuint8 group_index;
   WLuint8 offset;

#if defined (X11)
   unsigned long mask;
   unsigned long pixel_value;
   XImage* image ;
   int bytes_per_line;
   int depth, bitmap_pad ;
   int index;
   char *data ;
   int screen;
   int win_x, win_y;
  
#elif defined ( ENV5 )
   int mask;
   double buff[100];
   void *buffer;
   int malloc_flag, size_needed;
   struct vlt_info v_info;
   int old_enabledata;
#endif
#if defined( OPENGL )
   unsigned char *gl_pixels, gl_static_pixels[400];
   int ii;
   int use_static_buffer, update_static_buffer;
   GLenum gl_type;
   GLint gl_index_shift, gl_pack_alignment;
   *region = FALSE;
   return( WL_SUCCESS );
#endif

    if( lwin_no == WL_UNDEFINED_WINDOW )
    {
       *region = WLI_TRUE;
       WL_REPORT_ERROR( WL_SYSTEM_ERROR );
       return( WL_SYSTEM_ERROR );
    }


   x_origin = x - pixels;
   y_origin = y - pixels;
   height = width = 2*pixels;

   xmax_image = x_origin + width ;
   ymax_image = y_origin + height ;
   if ( x_origin < 0 )
   {
      x_origin = 0;
   }

   if ( y_origin < 0 )
   {
      y_origin = 0;
   }

   context_no = WL_DEFAULT_CONTEXT;
   WLIwin_set_bounds( lwin_no );

   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, 
                                        &win_struct, &context_struct );
   if(sts != WL_SUCCESS )
   {
      *region = WLI_TRUE;
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }


   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset) != WL_SUCCESS)
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      *region = WLI_TRUE;
      return( WL_BAD_WINDOW_NUMBER );
   }

   if ( xmax_image > win_struct->area_bounds.width )
   {
      width = win_struct->area_bounds.width - x_origin;
      xmax_image = win_struct->area_bounds.width;
   }

   if ( ymax_image > win_struct->area_bounds.height )
   {
      height = win_struct->area_bounds.height - y_origin;
      ymax_image = win_struct->area_bounds.height;
   }

#if defined( X11 )
   if( first_time )
   {
      sts = WLget_hardware_screen_number( win_struct->hwin_no, &screen );
      if(sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   /* These macros are returning higher values than the actual "buffer size */
  /*  Hence, subtracting  15 and 25 pixels based on tests */

      screen_width = DisplayWidth( win_struct->native_info.EXdisplay, screen )
                     - 15;
      screen_height= DisplayHeight( win_struct->native_info.EXdisplay, screen )
                      -25;
   }
   win_x = win_struct->bounds.x;
   win_y = win_struct->bounds.y;

   if ( ( win_x + x_origin + width  ) > screen_width ) 
   {
      if( ( win_x + x_origin ) > screen_width )
      {
         width = ( win_x + x_origin ) - screen_width ;
      }
      else
      {
         width = screen_width - ( win_x + x_origin );
      }
   }
   if ( ( win_y + y_origin + height ) > screen_height ) 
   {
      if( ( win_y + y_origin ) > screen_height )
      {
         height = ( win_y + y_origin ) - screen_height ;
      }
      else
      {
         height = screen_height - ( win_y + y_origin );
      }
   }
   if( ( width < 0 ) || ( height < 0 ) )
   {
      *region = WLI_FALSE;
      return( WL_SUCCESS);
   }

#endif

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );

      glReadBuffer( GL_FRONT );
      glGetIntegerv( GL_PACK_ALIGNMENT, &gl_pack_alignment );
      
      y_origin = win_struct->area_bounds.height - (y_origin + height + 1);
      
      *region = WLI_TRUE;
      
      use_static_buffer = ((width * height) <= 100);
      if ( context_struct->base_cmap_type == WL_CMAP_INDEXED )
      {
         bits_per_pixel = ((context_struct->base_depth + 7) / 8) * 8;
         if ( !(context_struct->flags & WL_SEPARATE_HILITE) )
         {
            /* shift out the hilite plane when the pixels are read */
            gl_index_shift = bits_per_pixel - context_struct->base_depth;
         }
         else
         {
            gl_index_shift = 0;
         }

         glPixelTransferi( GL_INDEX_SHIFT, gl_index_shift );
         
         test_pixel = win_struct->background_color_index << gl_index_shift;
         switch ( bits_per_pixel )
         {
            case 8:
               if ( ! use_static_buffer )
               {
                  gl_pixels = malloc( width * height );
                  if ( ! gl_pixels )
                  {
                     WL_REPORT_ERROR( WL_ERROR );
                     return( WL_ERROR );
                  }
               }
               gl_type = GL_UNSIGNED_BYTE;
               glPixelStorei( GL_PACK_ALIGNMENT, 1 );
               break;
            case 16:
               if ( ! use_static_buffer )
               {
                  gl_pixels = malloc( width * height * 2 );
                  if ( ! gl_pixels )
                  {
                     WL_REPORT_ERROR( WL_ERROR );
                     return( WL_ERROR );
                  }
               }
               gl_type = GL_UNSIGNED_SHORT;
               glPixelStorei( GL_PACK_ALIGNMENT, 2 );
               break;
            case 32:
               if ( ! use_static_buffer )
               {
                  gl_pixels = malloc( width * height * 4 );
                  if ( ! gl_pixels )
                  {
                     WL_REPORT_ERROR( WL_ERROR );
                     return( WL_ERROR );
                  }
               }
               gl_type = GL_UNSIGNED_INT;
               glPixelStorei( GL_PACK_ALIGNMENT, 4 );
               break;
         }

         update_static_buffer = (first_time) || (test_pixel != prev_bg);
         first_time = WLI_FALSE;
         
         if ( update_static_buffer )
         {
            for ( ii = 0; ii < 100; ii++ )
            {
               bg_buffer_c[ii] = test_pixel;
               bg_buffer_s[ii] = test_pixel;
               bg_buffer_i[ii] = test_pixel;
            }
         }

         if ( use_static_buffer )
         {
            *region = WLI_TRUE;
            glReadPixels( x_origin, y_origin, width, height, GL_COLOR_INDEX,
                          gl_type, gl_static_pixels );
            switch ( bits_per_pixel )
            {
               case 8 :
                  if ( memcmp( bg_buffer_c, gl_static_pixels, width * height ) )
                  {
                     *region = WLI_FALSE;
                  }
                  break;
               case 16 :
                  if ( memcmp( bg_buffer_s, gl_static_pixels, 2 * width * height ) )
                  {
                     *region = WLI_FALSE;
                  }
                  break;
               case 32 :
                  if ( memcmp( bg_buffer_i, gl_static_pixels, 4 * width * height ) )
                  {
                     *region = WLI_FALSE;
                  }
                  break;
            }
         }
         else
         {
            glReadPixels( x_origin, y_origin, width, height, GL_COLOR_INDEX,
                          gl_type, gl_pixels );

            switch( bits_per_pixel )
            {
               case 8 :
                  for ( ii = 0; ii < (width * height); ii++ )
                  {
                     if ( ((unsigned char *)gl_pixels)[ii] != test_pixel )
                     {
                        *region = WLI_FALSE;
                        break;
                     }
                  }
                  break;
               case 16 :
                  for ( ii = 0; ii < (width * height); ii++ )
                  {
                     if ( ((unsigned short *)gl_pixels)[ii] != test_pixel )
                     {
                        *region = WLI_FALSE;
                        break;
                     }
                  }
                  break;
               case 32 :
                  for ( ii = 0; ii < (width * height); ii++ )
                  {
                     if ( ((unsigned int *)gl_pixels)[ii] != test_pixel )
                     {
                        *region = WLI_FALSE;
                        break;
                     }
                  }
                  break;
            }

            WLI_FREE( gl_pixels );
         }
      }
      else
      {
         /* true color */
         red   = win_struct->background_red >> 8 ;
         blue  = win_struct->background_blue >> 8; 
         green = win_struct->background_green >> 8;

         glPixelStorei( GL_PACK_ALIGNMENT, 1 );
         if ( use_static_buffer )
         {
            glReadPixels( x_origin, y_origin, width, height, GL_RGB, GL_UNSIGNED_BYTE, gl_static_pixels );
            for ( ii = 0; ii < (width * height); ii++ )
            {
               if ( (gl_static_pixels[ii*3] != red) ||
                    (gl_static_pixels[ii*3+1] != green) ||
                    (gl_static_pixels[ii*3+2] != blue) )
               {
                  *region = WLI_FALSE;
                  break;
               }
            }
         }
         else
         {
            gl_pixels = malloc( width * height * 3 );
            if ( ! gl_pixels )
            {
               WL_REPORT_ERROR( WL_ERROR );
               return( WL_ERROR );
            }
            glReadPixels( x_origin, y_origin, width, height, GL_RGB, GL_UNSIGNED_BYTE, gl_pixels );
            for ( ii = 0; ii < (width * height); ii++ )
            {
               if ( (gl_pixels[ii*3] != red) ||
                    (gl_pixels[ii*3+1] != green) ||
                    (gl_pixels[ii*3+2] != blue) )
               {
                  *region = WLI_FALSE;
                  break;
               }
            }
            WLI_FREE( gl_pixels );
         }
      }

      glPixelStorei( GL_PACK_ALIGNMENT, gl_pack_alignment );
      return( WL_SUCCESS );
   }
#endif

   if( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      red   = win_struct->background_red >> 8 ;
      blue  = win_struct->background_blue << 8; 
      green = win_struct->background_green;
      test_pixel = red | green | blue;
   }
   else
   {
     test_pixel = win_struct->background_color_index ;
   }

  if ( (first_time) || (test_pixel != prev_bg) )
  {
     for( i=0;i<100;i++)
     {
        bg_buffer_c[i] = test_pixel ;
        bg_buffer_s[i] = test_pixel ;
        bg_buffer_i[i] = test_pixel ;
     }
     prev_bg = test_pixel;
     first_time = WLI_FALSE;
  }

  if( context_struct->hilite_used &&
     !( context_struct->flags & WL_SEPARATE_HILITE ) )
  {
     hilite_depth = 1;
  }
  else
  {
     hilite_depth = 0;
  }

   mask = ( 1 << context_struct->base_depth ) - 1 ;
   
#if defined( X11 )
   depth =  context_struct->base_depth + hilite_depth;
   bytes_per_line =  0;
   bitmap_pad = 8;

   image = XGetImage( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                      x_origin, y_origin, width, height, mask, ZPixmap ); 
   
   if(image == NULL)
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   bytes_per_line = image->bytes_per_line;
   data = image->data;

   for(i=0; i<height; i++)
   {
      index = bytes_per_line * i;

         if( !( memcmp( &((char *)data)[index], (char *)bg_buffer_c, width )))
         {
            continue;
         }
         else
         {
            *region = WLI_FALSE ;
            return( WL_SUCCESS );
         }
   } 

/*   this is slow compared to the above chunk */
/*
   for( i=0; i< width ; i++)
   {
      for( j=0; j< width ; j++)
      {      
         pixel_value = XGetPixel( image, i, j) ;
         if ( pixel_value != test_pixel )
         {
            *region = WLI_FALSE;
            return( WL_SUCCESS );
         }
      }
   }
*/
   if( image != NULL )
   {
      if( image->data != NULL )
      {
         free( image->data );
      }
      image->data = NULL ;
      XDestroyImage( image );
   }

#elif defined ( ENV5 )
   if( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      sts = Inq_vlt_info( win_struct->native_info.screen_no, TRUE_COLOR_DATA, 
                          &v_info );
      if( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   }
   else 
   if( context_struct->base_cmap_type == WL_CMAP_INDEXED )
   {
      sts = Inq_vlt_info( win_struct->native_info.screen_no, INDEXED_COLOR_DATA,
                          &v_info );
      if( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   }
   
   size_needed = v_info.vlti_num_bytes_per_pixel * width * height ;


   if( size_needed < ( 100 * sizeof( double )) )
   {
      buffer = buff;
      malloc_flag = WLI_FALSE;
   }
   else
   {
      buffer = malloc( size_needed );
      malloc_flag = WLI_TRUE;
   }

   
   Inq_enabledata( win_struct->hwin_no, IMAGE_DATA, &old_enabledata );
   enabledata( win_struct->hwin_no, IMAGE_DATA, mask );
   switch( v_info.vlti_num_bytes_per_pixel )
   {
      case 1:
   
      sts = getpixelblock( win_struct->hwin_no, mask, x_origin, 
                           y_origin, x_origin + width - 1 ,
                           y_origin+ height -1,
                           (char *)buffer );
      if( sts )
      {
         if( malloc_flag )
         {
            free( buffer );
         }
         enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      if(!(malloc_flag ))
      {
         if(!(memcmp( (char *)buffer,(char *)bg_buffer_c, width*height )))
         {
              *region = WLI_TRUE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
         }
         else
         {
              *region = WLI_FALSE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
         }
      }
      else
      {
         for ( j = 0; j < width*height; j++ )
         {
           if ( ( mask & ((char * )buffer)[j] ) != test_pixel )
           {
              free( buffer );
              *region = WLI_FALSE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
           }
         }
      }

      break;
      case 2:
      sts = getpixelblock16( win_struct->hwin_no, mask, x_origin,
                           y_origin, x_origin + width - 1 ,
                           y_origin+ height -1,
                           (short *)buffer );
      if( sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
         return( WL_SYSTEM_ERROR );
      }
      if(!(malloc_flag ))
      {
         if(!(memcmp( (short *)buffer,(short *)bg_buffer_s, width*height )))
         {
              *region = WLI_TRUE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
         }
         else
         {
              *region = WLI_FALSE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
         }
      }
      else
      {
         for ( j = 0; j < width*height; j++ )
         {
            if( ( mask & ((short *)buffer)[j] ) != test_pixel )
            {
               free( buffer );
               *region = WLI_FALSE;
               enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
               return( WL_SUCCESS );
            }
         }
      }

      break;
      case 4:
         /* Because getpixelblock() doesn't work in TRUE COLOR */
      sts = getblockdata( win_struct->hwin_no,x_origin, y_origin,
                          x_origin + width - 1 , y_origin + height -1,
                          IMAGE_DATA, (long *)buffer );
      if( sts )
      {
              WL_REPORT_ERROR( WL_SYSTEM_ERROR );
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SYSTEM_ERROR );
      }
      if(!(malloc_flag ))
      {
         if(!(memcmp( (long *)buffer,(long *)bg_buffer_i, width*height )))
         {
              *region = WLI_TRUE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
         }
         else
         {
              *region = WLI_FALSE;
              enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
              return( WL_SUCCESS );
         }
      }
      else
      {
         for ( j = 0; j < width*height; j++ )
         { 
            if( ((long *)buffer)[j] != test_pixel )
            {
               free( buffer );
               *region = WLI_FALSE;
               enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
               return( WL_SUCCESS );
            }
         }
      } 
      break;
   }
     
 if( malloc_flag )
 {
    free( buffer );
 }


enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
 
#endif

   *region = WLI_TRUE;
   return( WL_SUCCESS );

}
