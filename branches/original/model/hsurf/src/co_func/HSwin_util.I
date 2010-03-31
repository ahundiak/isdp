
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

class implementation Root;

#include <stdio.h>
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "igecolor.h"

#include "HSsara.h"
#include "hsanimate.h"
#include "hskyoptypes.h"
#include "HSrle.h"

#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "hsmachine.h"
#include "HStl_window.h"

#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"

/* Prototype files */
#include "HSpr_co_func.h"

from IGEgadget           import activate, clear;

#ifdef X11
#define MESSAGE_STRIP_HEIGHT        56;
#endif



/*--- HSinit_full_screen_window ---------------------------------------------*/

void HSinit_full_screen_window( WLuint32  *context_no,
                                WLuint32  *win_no,
                                int       *x_dits,
                                int       *y_dits,
                                int       ignore_edgeII )
             
/*
DESCRIPTION
   This function creates the full screen window used for displaying images.
   It returns the window number, the x and y size of the window in dits, and
   the context_no of the newly created window.

HISTORY
   S.P. Rogers  09/07/89  Creation Date
   S.P. Rogers  03/13/90  Changed to support TRUE COLOR
   R. Druzynski 07/12/91  Changed to support 8 or 24 bit display on edgeII
   S.P. Rogers  03/26/92  Changed to use new DPx functions to add window
                          to EX_win array
   R. Druzynski 05/24/93  Converted to use WL calls for portability
   R. Druzynski 03/23/94  Added platform specific runtime switches to place
                          window properly on screen.
*/

{
   WLuint16               lscreen_no;
   struct WLbounds        bounds;
   struct WLcontext_info  info;
   int                    screen_type;
   int                    width;
   int                    height;
   int                    sts;
   WLcolorref             color_ref;
   struct WLnative_info   native_info;
   int                    (*cmap_to_index)();
   int                    (*cmap_to_rgb)();
   int                    (*cmap_init)();
   OM_S_OBJID             color_objid;


   /* construct a hardware window that covers the entire screen */
   sts = WLget_active_screen( &lscreen_no, &screen_type );
   if( sts != WL_SUCCESS)
   {
#ifdef DEBUG
      fprintf(stderr, "Error getting active screen; Error %d\n", sts);
#endif
   }

   sts = WLget_screen_size( lscreen_no, &width, &height );
   if( sts != WL_SUCCESS)
   {
#ifdef DEBUG
      fprintf(stderr, "Error getting screen size; Error %d\n", sts);
#endif
   }
   
   *x_dits = width;
   *y_dits = height - MESSAGE_STRIP_HEIGHT;

   bounds.x      = 0;

#if defined( SUNOS )
   bounds.y      = 90;
   *y_dits       = height - 90;
#elif defined( MIPS )
   bounds.y      = 150;
   *y_dits	 = height - 150;
#elif defined( X11 )
   bounds.y      = 120;
   *y_dits       = height - 150;
   *x_dits       = width - 7;
#elif defined( ENV5 )
   bounds.y      = 56;
#endif

   bounds.width  = *x_dits;
   bounds.height = *y_dits;

   /* get the default context of the screen */
   CMget_active_context( lscreen_no, context_no );

   /* get context_info to see if on a true color machine */
   CMget_context_info( *context_no,
                       &color_objid, 
                       &cmap_to_index,
                       &cmap_to_rgb,
                       &cmap_init,
                       &info );

   /*---------------------------------------------------------------------
    *
    *  for XGL I want to create a window with the same depth as the other
    *  graphics windows.  Therefore, I'm not creating an 8 bit context
    *  (Mike 1/11/96)
    */

#  if ! defined (XGL)
   if( info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* On a true color machine.  If ignore_edgeII parameter is true, */
      /* we need to create a new 8 bit context for the window.         */

      if( ignore_edgeII )
      {
         info.base_depth     = 8;
         info.base_cmap_type = WL_CMAP_INDEXED;

         /* Create a new context with a TRUE share flag */
         sts = CMcreate_context( color_objid,
                                 lscreen_no,
                                 &info,                                 
                                 TRUE,
                                 context_no );
      }
   }
#  endif
   
   sts = WLcreate_window( lscreen_no, "Render", &bounds, 0, *context_no, 
                          win_no);

   if( sts != WL_SUCCESS )
   {
#ifdef DEBUG
      fprintf(stderr, "Error creating window\n");
#endif
      win_no = NULL;
   }
   else
   {
      WLinstall_cmap( *win_no, *context_no );

      WLdisplay_window( *win_no );

      WLflush( *win_no );

      /* set the background color of the window to the Ems background color */
      WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
      WLset_background( *win_no, color_ref );
      WLclear_window( *win_no );

      /* need to record new window for journaling */
      WLget_native_info( *win_no, *context_no, &native_info);
      JNL_record_new_window( native_info.base_win );

      WLIwin_set_event_mask( *win_no, WL_BUTTON | WL_KEY );
   }
} /* HSinit_full_screen_window() */


/*--- HSdelete_full_screen_window --------------------------------------------*/

void HSdelete_full_screen_window( WLuint32  win_no )

/*
DESCRIPTION
   This function deletes the full screen window.

HISTORY
   S.P. Rogers  09/07/89  Creation Date
   S.P. Rogers  03/13/90  Changed to support TRUE COLOR
   R. Druzynski 07/12/91  Changed to support 8 or 24 bit mode on edgeII
   S.P. Rogers  03/26/92  Changed to use new DPx functions to delete window
                          from EX_win array
   R. Druzynski 05/24/93  Converted to use WL calls for portability

*/

{
   int sts;

   sts = WLdelete_window( win_no );
   if( sts != WL_SUCCESS )
   {
#ifdef DEBUG
      fprintf(stderr, " Error deleting window\n");
#endif
   }
} /* HSdelete_full_screen_window() */

/*---HSconvert_to_indexed_context--------------------------------------------*/

int HSconvert_to_indexed_context( WLuint32    lwin_no,
                                  OM_S_OBJID  gragad_id,
                                  OMuword     gragad_os )

/*

*/

{
   struct WLcontext_info  context_info;
   struct WLcontext_info  *context_array;
   WLuint32               base_context_no;
   WLuint32               context_no;
   WLuint32               saved_context_no;
   WLuint16               screen_no;
   int                    num_contexts;
   int                    i;
   int                    sts;
   int                    high_index = 0;
   OMuint                 count;
   IGRint                 pipe_no;
   struct var_list        var_list1[2];
   IGRlong                msg;
   IGRlong                which_error;
   IGRlong                ret_bytes;
   OM_S_CHANSELECT        chansel;
   OM_S_OBJECT_LINKAGE    list;
   int                    (*cmap_to_index)();
   int                    (*cmap_to_rgb)();
   int                    (*cmap_init)();
   OM_S_OBJID             color_objid;
 

   /* get the window object from the gragad_id */
   sts = om$make_chanselect(channame     = "IGEgadget.to_parent",
                            p_chanselect = &chansel);

   sts = om$get_channel_objects( objid        = gragad_id,
                                 osnum        = gragad_os,
                                 p_chanselect = &chansel,
                                 list         = &list,
                                 size         = 1,
                                 count        = &count);
   
   /* get the current context information of the window */
   WLget_window_base_context( lwin_no, &base_context_no ); 

   CMget_context_info( base_context_no,
                       &color_objid, 
                       &cmap_to_index,
                       &cmap_to_rgb,
                       &cmap_init,
                       &context_info );


   /* determine if the windows active context is already indexed */
   if( context_info.base_cmap_type == WL_CMAP_INDEXED )
   {
      /* if already an indexed window, exit */
      return( 0 );
   }

   /* Get all the available indexed contexts available for the window's      */
   /* screen that support the windows hilight mode, and chose the one with   */
   /* the best (greatest) base depth.                                        */

   sts = WLget_window_screen( lwin_no, &screen_no );
   if ( sts != WL_SUCCESS )
   {
      return( 1 );
   }

   sts = WLget_screen_contexts( screen_no,
                                WL_CMAP_INDEXED,
                                context_info.hilite_used,
                                &num_contexts,
                                &context_array );

   if ( sts != WL_SUCCESS )
   {
      return( 1 );
   }

   for( i = 0; i < num_contexts; i++)
   {
      if ((context_array[i].base_depth > context_array[high_index].base_depth) &&
          (context_array[i].base_depth <= 8) )
      {
         high_index = i;
      }
   }

   /* Create a new context with a TRUE share flag */
   sts = CMcreate_context( color_objid,
                           screen_no,
                           &context_array[high_index],
                           TRUE,
                           &context_no );
   if ( sts )
   {
      /* If the context was not created, set the saved_context_num variable to*/
      /* the default context number.                                          */
      saved_context_no= WL_DEFAULT_CONTEXT;
   }
   else
   {
      /* Save the old context, and make the new context the active context   */
      CMget_active_context( screen_no, &saved_context_no );
      CMset_active_context( screen_no, context_no );

      /* Erase the window from the screen and then activate it again to      */
      /* install the new context into the window                             */
      sts = om$send( mode = OM_e_wrt_object,
                     msg  = message IGEgadget.clear( &msg ),
                     senderid = gragad_id,
                     targetid = list.S_objid,
                     targetos = gragad_os );

      DPactivate_update( FALSE );
      sts = om$send( mode = OM_e_wrt_object,
                     msg  = message IGEgadget.activate( &msg, 0 ),
                     senderid = gragad_id,
                     targetid = list.S_objid,
                     targetos = gragad_os );
      DPactivate_update( TRUE );

      /* set the active context back to the saved context for the rest of the */
      /* windows                                                              */
      CMset_active_context( screen_no, saved_context_no );


      /* Set the window to be the active window (in case it is currently not  */
      /* the active window) and save the old context number for later         */
      /* recalling.                                                           */

      var_list1[0].var            = GPIPE_ID;
      var_list1[0].var_ptr        = (char *)&pipe_no;
      var_list1[0].num_bytes      = sizeof(IGRint);
      var_list1[0].bytes_returned = &ret_bytes;
      var_list1[1].var            = END_PARAM;

      dp$inq_set_gragad( msg          = &msg,
                         inq0_set1    = 0,
                         osnum        = gragad_os,
                         gragad_objid = gragad_id,
                         which_error  = &which_error,
                         var_list     = var_list1);

      HSactivate_window( pipe_no);

/*      WLinstall_cmap( lwin_no, context_no); */
   }

   active_window->saved_win_context = saved_context_no;   

   return(0);
}

/*---HSrestore_window_context------------------------------------------------*/

int HSrestore_window_context( WLuint32    lwin_no,
                              OM_S_OBJID  gragad_id,
                              OMuword     gragad_os )
                              
{
   WLuint16               screen_no;
   WLuint32               old_context_no;
   IGRlong                msg;
   IGRlong                which_error;
   IGRlong                sts;
   struct var_list        var_list1[2];
   IGRint                 pipe_no;   
   OM_S_CHANSELECT        chansel;
   OM_S_OBJECT_LINKAGE    list;
   OMuint                 count;
   IGRlong                ret_bytes;

   /* get the window object from the gragad_id */
   sts = om$make_chanselect(channame     = "IGEgadget.to_parent",
                            p_chanselect = &chansel);

   sts = om$get_channel_objects( objid        = gragad_id,
                                 osnum        = gragad_os,
                                 p_chanselect = &chansel,
                                 list         = &list,
                                 size         = 1,
                                 count        = &count);

   /* Get the saved context from the tilers active window structure */
   var_list1[0].var            = GPIPE_ID;
   var_list1[0].var_ptr        = (char *)&pipe_no;
   var_list1[0].num_bytes      = sizeof(IGRint);
   var_list1[0].bytes_returned = &ret_bytes;
   var_list1[1].var            = END_PARAM;

   dp$inq_set_gragad( msg          = &msg,
                      inq0_set1    = 0,
                      osnum        = gragad_os,
                      gragad_objid = gragad_id,
                      which_error  = &which_error,
                      var_list     = var_list1);

   HSactivate_window( pipe_no);

   if ( active_window->saved_win_context == WL_DEFAULT_CONTEXT)
   {
      /* If the saved context is non-existant, return. */
      return(0);
   }

   /* save the current context number for later reinstallation, and load the */
   /* saved context                                                          */

   sts = WLget_window_screen( lwin_no, &screen_no );
   CMget_active_context( screen_no, &old_context_no );
   CMset_active_context( screen_no, active_window->saved_win_context );
   

   /* Erase the window from the screen and then activate it again to install */
   /* the saved context into the window                                      */

   sts = om$send( mode = OM_e_wrt_object,
                  msg  = message IGEgadget.clear( &msg ),
                  senderid = gragad_id,
                  targetid = list.S_objid,
                  targetos = gragad_os );

   DPactivate_update( FALSE );
   sts = om$send( mode = OM_e_wrt_object,
                  msg  = message IGEgadget.activate( &msg, 0 ),
                  senderid = gragad_id,
                  targetid = list.S_objid,
                  targetos = gragad_os );
   DPactivate_update( TRUE );


   /* Re-load the old context of the screen */

   CMset_active_context( screen_no, old_context_no );

   return(0);
}

/*----NCget_rgb_from_logical_color-------------------------------------------*/

void NCget_rgb_from_logical_color(  IGRuint logical_color,
                                    IGRuint *red,
                                    IGRuint *green,
                                    IGRuint *blue )

/* ABSTRACT:  This function is for NC.  This is used to update the NCshading
 *            variable active red, green, and blue whenever the color changes.
 *            This has room for optimization like not using parameters and just 
 *            setting the NCshading values
 */

{
/*   IGRuint   psuedo_color; */

   IGRuint    packed_color;
   IGRushort  r_temp;   /* temporary variables to store the correct var type */
   IGRushort  g_temp;
   IGRushort  b_temp;

   ige$get_rgb_value( log_color = logical_color, 
                      rgb_value = &packed_color );

   CLunpack_colors( packed_color,
                    &r_temp,
                    &g_temp,
                    &b_temp );

   *red = (IGRuint)r_temp;
   *green = (IGRuint)g_temp;
   *blue = (IGRuint)b_temp;

/*
   psuedo_color=HSget_rgb_value( logical_color );
 
   *red = (psuedo_color >> 22) & 0xff;
   *green = (psuedo_color >> 12) & 0xff;
   *blue = (psuedo_color >> 2) & 0xff;
*/
}

end implementation Root;
