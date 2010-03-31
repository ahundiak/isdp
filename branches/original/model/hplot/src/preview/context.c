#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "cmap.h"
#include "error.h"

#define DEBUG 0

#if DEBUG
static void	print_context_info( struct WLcontext_info *c )

   {
   printf( "\nContext Info\n" );
   printf( "   type   : " );
   if( c->base_cmap_type == WL_CMAP_INDEXED ) printf( "INDEXED\n" ); else
   if( c->base_cmap_type == WL_CMAP_TRUE_COLOR ) printf( "TRUE COLOR\n" ); else
                                              printf( "UNKNOWN\n" ); 

   printf( "   depth  : %d\n", c->base_depth ); 

   printf( "   hilite : " );
   if( c->hilite_used ) printf( "USED\n" ); else printf( "NOT USED\n" );

   printf( "   flags  : \n" );
   if( c->flags & WL_COLORMAP_READ_ONLY ) 
      printf( "      COLORMAP READ ONLY\n" );
   if( c->flags & WL_SYSTEM_COLORMAP ) 
      printf( "      SYSTEM COLORMAP\n" );
   if( c->flags & WL_COLORMAP_SAVE_RESTORE ) 
      printf( "      COLORMAP SAVE RESTORE\n" );
   if( c->flags & WL_SAVE_RESTORE_CONTEXT ) 
      printf( "      SAVE RESTORE CONTEXT\n" );
   if( c->flags & WL_SEPARATE_HILITE ) 
      printf( "      SEPARATE HILITE\n" );
   if( c->flags & WL_DOUBLE_BUFFER_ABILITY ) 
      printf( "      DOUBLE BUFFER ABILITY\n" );
   }
#endif

/*---create_context------------------------------------------------*/

int create_context( WLuint16 screen_no,
                    int      base_depth,
                    int      hilite_used,
                    int      separate_hilite,
                    WLuint32 *context_no )

   {
   int		ii;
   int		num_contexts;
   int		sts, screen_type;

   struct WLcontext_info *contexts;

   sts = WLget_screen_contexts(screen_no, 0,0, &num_contexts, &contexts);
   CHECK_WL_ERROR (sts);


   /* find an appropriate context */

   for (ii = 0; ii < num_contexts; ii++)
      {
      if ((contexts[ii].base_depth == base_depth) &&
          (contexts[ii].hilite_used == hilite_used) &&
        (((separate_hilite) && (contexts[ii].flags & WL_SEPARATE_HILITE)) ||
         (!separate_hilite)))
         {
#        if DEBUG
         print_context_info( &contexts[ii] );
#        endif

         break;
         }
      }

   if (ii >= num_contexts)
      {
      fprintf (stderr, "BZZZZZTT!!! Couldn't find an appropriate context\n");
      exit (1);
      }

   sts = WLcreate_context( screen_no, 
                           &contexts[ii],
                           IGEcmap_color_to_index, 
                           IGEcmap_color_to_rgb, 
                           IGEcmap_init,
                           context_no );

   CHECK_WL_ERROR (sts);

   if (contexts) free ((char *) contexts);

   return( sts );
   }
