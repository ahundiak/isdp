#include <stdio.h>
#include "wl.h"
#include "preview.h"
#include "context.h"
#include "error.h"
#include "file.h"
#include "options.h"

#if defined (CLIX)
static int	winrang[4] = {  5, 30, 1190, 850 };
#else
static int	winrang[4] = { 10, 10, 1200, 900 };
#endif

#if defined (XGL) || defined (IRIX)
static short	depth = 24;
#else
static short	depth = 8;
#endif

/*---CMget_exnuc_forms_context-------------------------*/
 
void    CMget_exnuc_forms_context( int screen_no, WLuint32 *context_no )
 
   {
   *context_no = preview.context_no;
   }

#if NOT_USED
static void	stub() 
   {
   int	x, y;
   WLcolorref	c;
   struct WLrect	rect;

   WLset_active_symbology( preview.lwin_no,
      (WLcolorref)7, 0, 0, 0,
      WL_SYMB_CHANGE_COLOR );

   rect.x = 0;
   rect.y = 0;
   rect.width = winrang[2];
   rect.height = winrang[3];

   WLdraw_rectangle( preview.lwin_no, &rect, TRUE );


   c = 0;
   for( y=0; y<16; y++ )
   for( x=0; x<16; x++, c++ )
      {
      rect.x = x * 40;
      rect.y = y * 40;
      rect.width = 35;
      rect.height = 35;

      WLset_active_symbology( preview.lwin_no, c, 0, 0, 0, WL_SYMB_CHANGE_COLOR );
      WLdraw_rectangle( preview.lwin_no, &rect, TRUE );
      }
   }
#endif /* NOT_USED */

void	main( int argc, char *argv[] )
   {
   long			sts;
   int			screen_type;
   struct option_node	*option, *op;

#  if defined (WIN32)
      struct WLinit init_struct;
#  endif

   if( !GetOptions( argc, argv, &option ) ) exit(0);

#  if defined( WIN32 )
      memset( &init_struct, 0, sizeof( struct WLinit ) );

      init_struct.app_wnd_proc = NULL;
      init_struct.app_window_name = "Preview Application Window";
      init_struct.app_main_class = "DLT_APP_WINDOW";
      init_struct.win_class = "DLT_WINDOW";
      init_struct.batch_mode = FALSE;
      sts = WLinitialize (&init_struct, &preview.init_ret);
#  else
      sts = WLinitialize (NULL, &preview.init_ret);
#  endif

   CHECK_WL_ERROR (sts);

   sts = WLget_active_screen (&preview.screen_no, &screen_type);
   CHECK_WL_ERROR (sts);
 
   sts = create_context( preview.screen_no, 
                         preview.base_depth=depth,
                         preview.hilite_used=FALSE,
                         preview.separate_hilite=FALSE,
                         &preview.context_no );
   CHECK_WL_ERROR (sts);

   sts = create_window( preview.screen_no,
                        preview.context_no,
                        winrang[0], winrang[1], 
                        preview.width=winrang[2], 
                        preview.height=winrang[3],
                        &preview.lwin_no,
                        &preview.image,
                        &preview.image_buffer );
   CHECK_WL_ERROR (sts);

#  if defined (CLIX)
   /*env5_event_loop( NULL );*/
#  elif defined (X11)
   x11_event_loop( NULL );
#  endif

   op = option;
   while( op != NULL )
      {
      switch( op->type )
         {
         case OPTION_DISP_IMAGE:
            open_file( op->filename );
            if( preview.fp == NULL ) exit(0);

            read_header();

            init_rgb( preview.context_no, 8 );

            allocate_memory();
            translate_image();
            display_image();
            break;
         }

      op = op->next;
      }

#  if defined (CLIX)
   env5_event_loop( display_image );
#  elif defined (X11)
   x11_event_loop( display_image );
#  endif
   }
