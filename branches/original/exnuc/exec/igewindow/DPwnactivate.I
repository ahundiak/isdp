/*
        CLASS NAME:     IGEwindow
        METHOD NAME:    activate

        Abstract:
                This is the window activate method for the window object.
             it will reset CS_OS_number[hard_w_no] CS_window_id[hard_w_no]
             and use tools' routine to delete window.
*/


class implementation IGEwindow;


#define	DEBUG 1
#ifdef ENV5
#include <sdl.h>
#endif

#include <stdio.h>

#ifdef ENV5
#include <tools.h>
#endif

#include "igetypedef.h"
#include "igewindef.h"
#include "igewinerr.h"
#include "igewinmacros.h"
#include "exmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exlocale.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "wl.h"
#include "exwl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "FI.h"

#include "cm.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
/**#include <X11/cursorfont.h>**/
#endif

%safe
static char c_d[] =
{
	0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0XFE, 0XFF, 0XFF, 0X7F,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
	0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static char c_e[] =
{
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
	0x00, 0xC0, 0x01, 0x00, 0x00, 0xC0, 0x01, 0x00,
};
%endsafe


/********* keep these defs for comments for awhile

#define EX_WIN_MASK (ButtonPressMask | ButtonReleaseMask | \
                     KeyPressMask    |  EnterWindowMask  | \
                     LeaveWindowMask | PointerMotionHintMask | \
		     PointerMotionMask  | \
                     ExposureMask     |  StructureNotifyMask )
**************/

/* IF you changed EX_WIN_MASK be sure to change it in
                 DPwnactivate.I  exwfi.I dp(tx)dynamics.I */


#ifdef X11
extern Display *EXdisplay;
extern char EX_runname[];
#endif

#define ENABLE  1

/*====================================================================*/
/*  This function is used to convert the screen number stored in the  */
/*  IGEwindow instance data to a logical screen number for WL         */
/*====================================================================*/

WLuint16 EXget_logical_screen_number( int screen )

{
   int status;
   int vs_no;
   WLuint16 lscreen_no;
   IGRint   number_screens;

   ige$get_num_screens( num_of_screens = &number_screens);

   if ((number_screens < 2) && (screen == LEFT_SCREEN))
     {
         /*if there is only one screen, ie a front screen, and the instance data says to
         put the window on the back screen, then switch the window to the front screen */

       screen = RIGHT_SCREEN;
     }

   ige$inq_term_info( screen_no = (screen == LEFT_SCREEN) ?
                                      IGE_LEFT_SCREEN : IGE_RIGHT_SCREEN,
                      vs_no = &vs_no );

   status = WLget_logical_screen_from_screen( vs_no, &lscreen_no );
   if ( status != WL_SUCCESS )
   {
      /* !!! what to do about failure !!! */
   }
   
   return( lscreen_no );
}


#argsused
method activate (IGRlong *msg; IGRint win_no)

{
#ifdef X11
   XEvent            xevent;
   XClassHint        class_hint;
   Atom              a;
#endif

#ifdef ENV5
   IGRint            i,
                     done;
   IGRchar           symbol_name[120],
                     language[15];
   FILE	             *fp = NULL;
   int               num_screens;
#endif

   IGRlong           status;
   OMuint            count;
   int               vs_no,
                     screen_no,
                     num_planes,
                     plane_mask,
                     x_extents,
                     y_extents,
                     min_x = 0;
   IGRint            min_y = 0;
   IGRint            max_x = 0;
   IGRint            max_y = 0;
   IGRchar           path_name[DI_PATH_MAX],
                     name[DI_PATH_MAX];


   int                   x, y;
   IGRshort              bgcol, fgcol;
   int                   collapse_state;
   int                   border_width;
   WLuint16              lscreen_no;
   WLuint32              fg_colorref, bg_colorref;
   WLuint32              lwin, ctx_num;
   WLuint32              wl_event_mask;
   struct WLbounds       bounds;
   struct WLnative_info  wl_native_info;
   WLcolorref            bg_color_ref;
   struct WLcontext_info context_info;

   EXwindata            *p_windata;
   OM_S_CHANSELECT       chandef1;

   status = OM_S_SUCCESS;
   *msg   = MSSUCC;

   if (ex$is_batch())
   {
      goto wrapup;
   }

   if  (!(ME.IGEwindow->flags & WIN_IS_ON))
   {
      goto wrapup;
   }

#ifdef ENV5
   DPhandle_event();
#endif

   screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

   ige$inq_term_info( screen_no     = screen_no,
                      vs_no         = &vs_no,
                      num_of_planes = &num_planes,
                      x_extent      = &x_extents,
                      y_extent      = &y_extents,
                      plane_mask    = &plane_mask);

   /*===================================================================*/
   /*  subtract 1 from the extent because the screen values start at 0  */
   /*===================================================================*/

   x_extents--;
   y_extents--;

   /*================================================================*/
   /*  calculate dependent extents from indepentent extents changed  */
   /*================================================================*/

   ME.IGEgadget->min_x_dep = (IGRint) ((ME.IGEgadget->min_x_indep *
                                           x_extents) + 0.5);

   ME.IGEgadget->min_y_dep = (IGRint) ((ME.IGEgadget->min_y_indep *
                                           y_extents) + 0.5);
                                                
   ME.IGEgadget->max_x_dep = (IGRint) ((ME.IGEgadget->max_x_indep *
                                           x_extents) + 0.5);
                                                
   ME.IGEgadget->max_y_dep = (IGRint) ((ME.IGEgadget->max_y_indep *
                                           y_extents) + 0.5);

   if (ME.IGEwindow->win_type != BORDER)
   {
      /*=======================================================*/
      /*  Checking to make sure window is within screen units  */
      /*=======================================================*/

      min_x = ME.IGEgadget->min_x_dep - ME.IGEwindow->left_space;
      min_y = ME.IGEgadget->min_y_dep - ME.IGEwindow->top_space;
      max_x = ME.IGEgadget->max_x_dep + ME.IGEwindow->right_space;
      max_y = ME.IGEgadget->max_y_dep + ME.IGEwindow->bottom_space;
	
      if (min_x < 0)
      {
         max_x += - min_x;
         min_x = 0;
      }

      if (min_y < 0)
      {
         max_y += - min_y;
         min_y = 0;
      }

      if (max_x > x_extents)
      {
         if ((min_x - (max_x - x_extents)) > 0)
         {
            min_x -= (max_x - x_extents);
         }
         else
         {
            min_x = 0;
         }
         max_x = x_extents;
      }

      if (max_y > y_extents)
      {
         if ((min_y - (max_y - y_extents)) > 0)
         {
            min_y -= (max_y - y_extents);
         }
         else
         {
            min_y = 0;
         }
         max_y = y_extents;
      }

      ME.IGEgadget->min_x_dep = min_x + ME.IGEwindow->left_space;
      ME.IGEgadget->min_y_dep = min_y + ME.IGEwindow->top_space;
      ME.IGEgadget->max_x_dep = max_x - ME.IGEwindow->right_space;
      ME.IGEgadget->max_y_dep = max_y - ME.IGEwindow->bottom_space;
   }	

   /*=============================*/
   /*  check the borderless case  */
   /*=============================*/

   if (ME.IGEwindow->win_type == NO_BORDER)
   {
      border_width = 0;
   }
   else
   {
      ME.IGEwindow->draw_border = FALSE;
      border_width = 1;

      /*===================*/
      /*  get window name  */
      /*===================*/

      strcpy(name, " ");
      status = di$untranslate ( objname = path_name,
                                objid   = my_id,
                                osnum   = OM_Gw_current_OS);
      if ((!(status & 1)) && (status != DIR_W_NAME_NOT_FOUND))
      {
#ifdef DEBUG
         di$report_error(sts = status,
                         comment = "untranslate failed in window activate");
#endif
         goto wrapup;
      }

      if (status != DIR_W_NAME_NOT_FOUND)
      {
         status = di$split(pathname=path_name, name=name);
         if (!(status &1))
         {
#ifdef DEBUG
            di$report_error(sts = status,
                            comment = "split failed in window construct");
#endif
            goto wrapup;
         }
      }
   }

   /*=====================*/
   /*  create the window  */
   /*=====================*/

   bounds.x      = ME.IGEgadget->min_x_dep;
   bounds.y      = ME.IGEgadget->min_y_dep;
   bounds.width  = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep + 1;
   bounds.height = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep + 1;

   lscreen_no = EXget_logical_screen_number( ME.IGEwindow->screen_no );

   status = CMget_active_context ( lscreen_no, &ctx_num );
   if (status != WL_SUCCESS) 
   {
      *msg = status = OM_E_ERROR;
      goto wrapup;
   }

   status = WLcreate_window ( lscreen_no, name, &bounds,
                              border_width, ctx_num, &lwin );
   if (status != WL_SUCCESS) 
   {
      *msg = IGENOCREWIN;
      status = OM_E_ERROR;
      goto wrapup;
   }

   WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &bg_color_ref, FALSE );
   status = WLset_background( lwin, bg_color_ref );
   if (status != WL_SUCCESS) 
   {
      *msg = IGENOCREWIN;
      status = OM_E_ERROR;
      goto wrapup;
   }

   status = WLinstall_cmap ( lwin, ctx_num );
   if (status != WL_SUCCESS) 
   {
      *msg = IGENOCREWIN;
      status = OM_E_ERROR;
      goto wrapup;
   }
   status = OM_S_SUCCESS;

/*   THIS IS LEFT TO REMIND ABOUT JOURNALING---------********?????????

	JNL_XCreateWindow( EXdisplay, RootWindow(EXdisplay,screen_no), 
	               ME.IGEgadget->min_x_dep,ME.IGEgadget->min_y_dep,
	               ME.IGEgadget->max_x_dep-ME.IGEgadget->min_x_dep,
	               ME.IGEgadget->max_y_dep-ME.IGEgadget->min_y_dep,
                       borderwidth, DisplayPlanes(EXdisplay,screen_no) ,
		       InputOutput,(Visual *)CopyFromParent, mask, &attr);
*/

   /*=====================*/
   /*  define the cursor  */
   /*=====================*/

   /*===========================*/
   /*  go for menu white        */
   /*===========================*/

   WLget_context_info( ctx_num, & context_info );
   if ( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      WLpack_rgb_colorref( 0, 0, 0, &bg_colorref, TRUE );
      WLpack_rgb_colorref( 0xffff, 0xffff, 0xffff, &fg_colorref, TRUE );
   }
   else
   {
      status = ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                                           FI_DEFINE = FI_WHITE,
                                           phys_slot_num = &fgcol );
      if (!status)
      {
         goto wrapup;
      }
   
      /*===========================*/
      /* get the menu black slot   */ 
      /*===========================*/
   
      status = ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                                           FI_DEFINE = FI_BLACK,
                                           phys_slot_num = &bgcol );
   
      if (!status)
      {
         goto wrapup;
      }
   
   
      WLpack_index_colorref( fgcol, &fg_colorref, TRUE );
      WLpack_index_colorref( bgcol, &bg_colorref, TRUE );
   }

   status = WLdefine_cursor ( lwin, c_d, c_e, 32, 32, fg_colorref,
                              bg_colorref, 15, 15 );
   if (status != WL_SUCCESS)
   {
      *msg = status = OM_E_ERROR;
      goto wrapup;
   }

   /*========================*/
   /*  select window events  */
   /*========================*/

   wl_event_mask = WL_BUTTON | WL_KEY | WL_ENTER_LEAVE_WIN |
                   WL_POINTER_MOTION | WL_EXPOSE | WL_COLORMAP_NOTIFY |
                   WL_SWAP_SCREEN | WL_DELETE | WL_COLLAPSE | WL_TIMER | WL_USER;

   status = WLset_event_mask ( lwin, wl_event_mask );
   if (status != WL_SUCCESS) 
   {
      *msg = status = OM_E_ERROR;
      goto wrapup;
   }

   /*===============================*/
   /*  set the collapse parameters  */
   /*===============================*/

   if (ME.IGEwindow->flags & WIN_IS_COLLAPSED)
      collapse_state = WL_COLLAPSED;
   else
      collapse_state = WL_NOT_COLLAPSED;  

   x = (int)((ME.IGEwindow->collapse_pos[0] * x_extents) + 0.5);
   y = (int)((ME.IGEwindow->collapse_pos[1] * y_extents) + 0.5);

   if (ME.IGEwindow->flags & COLLAPSE_POS_VALID)
   {
      status = WLset_collapse_parms ( lwin, x, y, collapse_state );
      if (status != WL_SUCCESS) 
      {
         *msg = status = OM_E_ERROR;
         goto wrapup;
      }
   }
   status = OM_S_SUCCESS;

   /*========================================================*/
   /*  store the logical window number in the instance data  */
   /*========================================================*/

   ME.IGEgadget->win_no = lwin;

   /*========================================================*/
   /*  now store the osnum and objid in WL user data fields  */
   /*========================================================*/

   p_windata = (EXwindata*)malloc (sizeof (EXwindata));
   if (!p_windata) return (OM_E_NODYNMEM);

   p_windata->id      = EX_GRAPHIC_WINDOW;
   p_windata->win_os  = OM_Gw_current_OS;
   p_windata->win_oid = my_id;

   status = WLset_user_data ( lwin, (void**)&p_windata, NULL );
   if (status != WL_SUCCESS)
   {
      status = *msg = OM_E_ERROR;
      goto wrapup;
   }

   status = WLget_native_info ( lwin, ctx_num, &wl_native_info );
   if (status != WL_SUCCESS)
   {
      *msg = status = OM_E_ERROR;
      goto wrapup;
   }
   status = OM_S_SUCCESS;

   EX_record_new_window (wl_native_info.base_win);

#ifdef X11
   class_hint.res_class= "GraphicWindow";
   strcpy (name,EX_runname);
   strcat (name,"GrWin");
   class_hint.res_name = name;
   XSetClassHint (EXdisplay, wl_native_info.base_win, &class_hint);

   a = XInternAtom (EXdisplay, "WM_DELETE_WINDOW", False);
   XSetWMProtocols (EXdisplay, wl_native_info.base_win, &a ,1);

   /***********???????????????????********/
   if (ME.IGEwindow->flags & WIN_IS_COLLAPSED)
   {
      /*if playbackmode and collapsed there is no expose*/
      XMapWindow (EXdisplay, wl_native_info.base_win);
   }
   else
   {
      JNL_XMapWindow (EXdisplay, wl_native_info.base_win);
      JNL_XWindowEvent (EXdisplay, wl_native_info.base_win, ExposureMask,
                        &xevent);
   }
#endif


#ifdef ENV5


   if (ME.IGEwindow->win_type != SAVE_RESTORE)
   {
      Refresh_on_move (wl_native_info.base_win, ENABLE);

      if (ME.IGEwindow->symbol_number > -1)
      {
         status = TRUE;
         done = FALSE;

         for (i = 0; ((status == TRUE) && (done == FALSE)); i++)
         {
            if (status = ex$get_path( index = i, 
                                      path  = symbol_name, 
                                      len   = sizeof(symbol_name)))
            {
               strcat(symbol_name,"config/icons/");
               ex$language(language = language);
               strcat(symbol_name,language);
               strcat(symbol_name,"/");
               strcat(symbol_name,ME.IGEwindow->symbol_name);

               if (fp = (FILE *) fopen(symbol_name,"r"))
               {
                  done = TRUE;
               }
            }
         }
	     
         if (done)
         {
            fclose(fp);
            Set_win_collapse_symbol (wl_native_info.base_win, symbol_name,
                                     ME.IGEwindow->symbol_number);
         }
      }
   }     
#endif

   status = WLdisplay_window ( lwin );
   if (status != WL_SUCCESS)
   {
      *msg = status = OM_E_ERROR;
      goto wrapup;
   }
   status = OM_S_SUCCESS;

   if (ME.IGEwindow->win_type == NO_BORDER)
   {
      ME.IGEgadget->min_x_dep += ME.IGEwindow->right_space;
      ME.IGEgadget->min_y_dep += ME.IGEwindow->top_space;
      ME.IGEgadget->max_x_dep -= ME.IGEwindow->left_space;
      ME.IGEgadget->max_y_dep -= ME.IGEwindow->bottom_space;
   }

   ME.IGEgadget->min_x_indep = (IGRdouble) ME.IGEgadget->min_x_dep/x_extents;
   ME.IGEgadget->min_y_indep = (IGRdouble) ME.IGEgadget->min_y_dep/y_extents;
   ME.IGEgadget->max_x_indep = (IGRdouble) ME.IGEgadget->max_x_dep/x_extents;
   ME.IGEgadget->max_y_indep = (IGRdouble) ME.IGEgadget->max_y_dep/y_extents;

#ifdef ENV5
   if ((ME.IGEwindow->win_type == NO_BORDER) ||
       (ME.IGEwindow->win_type == SAVE_RESTORE))
   {
      if (ME.IGEwindow->draw_border == TRUE)
      {
         status= om$send (msg = message IGEwindow.draw_border(0xffffffff), 
                          senderid = my_id,
                          targetid = my_id);
         if (!(status & 1))
         {
            om$report_error(sts = status);
            goto wrapup;
         }
      }
      else
      {
         status= om$send (msg = message IGEwindow.draw_border(0), 
                          senderid = my_id,
                          targetid = my_id);
         if (!(status & 1))
         {
            om$report_error(sts = status);
            goto wrapup;
         }
      }
   }
#endif

   WLflush ( lwin );
   ME.IGEwindow->flags |= WIN_IS_ACTIVE;

#ifdef ENV5
   WLget_number_of_screens ( &num_screens, NULL );
   if (num_screens > 1)
   {
      Set_win_vs_swap (wl_native_info.base_win, 1);
   }
#endif

#ifdef X11
   ME.IGEwindow->flags |= WIN_IS_NOTMAPPED;
#endif

   status = ex$add_win_to_exec (win_num = lwin,
                                objid   = my_id, 
                                osnum   = OM_Gw_current_OS);
   if (!(status & 1))
   {
      om$report_error(sts = status);
      goto wrapup;
   }

   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "IGEgadget.to_children";

   status = om$get_channel_count (objid        = my_id, 
                                  p_chanselect = &chandef1, 
                                  count        = &count);
   if (!(status & 1))
   {
      om$report_error(sts = status);
      goto wrapup;
   }
                                
   if (count)                           
   {
      status= om$send (msg = message IGEgadget.activate(msg, lwin), 
                       senderid = my_id, 
                       p_chanselect = &chandef1);
      if (!(status & 1))
      {
         om$report_error(sts = status);
         goto wrapup;
      }
   }            

wrapup:
   return ( status );
}


method deactivate( )
{
   return(1);
}


method reactivate( )
{
   return(1);
}


method change_process_from (IGRlong *msg; IGRint pid; IGRint time_out)
{
   IGRlong status;
#ifdef ENV5
   OMuint  count;
   OM_S_CHANSELECT chandef;
#endif

   status = OM_S_SUCCESS;
   *msg = MSSUCC;

#ifdef ENV5
   if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
   {
      status = Xfer_win_rec(pid,time_out,&ME.IGEgadget->win_no);
      if (status != -1)
      {
         chandef.type = OM_e_name;
         chandef.u_sel.name = "to_children";

         status = ex$add_win_to_exec (win_num = ME.IGEgadget->win_no, 
                                      objid   = my_id, 
                                      osnum   = OM_Gw_current_OS);
         if (!(status & 1))
         {
#ifdef DEBUG
            printf("Error in window change process add_win_to_exec\n");
#endif
            goto wrapup;
         }

         status = om$get_channel_count (objid        = my_id, 
                                        p_chanselect = &chandef, 
                                        count        = &count);
         if (!(status & 1))
         {
#ifdef DEBUG
            om$report_error(sts = status);
#endif
            goto wrapup;
         }

         if (count)				
         {
            status = om$send (mode = OM_e_wrt_object,
                              msg = message IGEgadget.change_process_from(msg,
                                                            pid,time_out),
                              senderid = my_id,
                              p_chanselect = &chandef);
            if ( !(1 & status) )
            {
#ifdef DEBUG
               om$report_error(sts = status);
               printf("Error: send to gragad change_process_from\n");
#endif
            }
         }
      }
      else
      {
         status = OM_I_STOP_SENDING;
         *msg = -1;
      }
   }

wrapup:
#endif
   return (status);
}


method change_process_to (IGRlong *msg; IGRint pid; IGRint time_out)
{
   IGRlong status = OM_S_SUCCESS;
#ifdef ENV5
   OMuint  count;
   OM_S_CHANSELECT chandef;
#endif

   status = OM_S_SUCCESS;
   *msg = MSSUCC;

#ifdef ENV5
   if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
   {
      status = Xfer_win_send(pid,time_out,ME.IGEgadget->win_no);	
      if (status != -1)
      {
         chandef.type = OM_e_name;
         chandef.u_sel.name = "to_children";

         status = om$get_channel_count (objid        = my_id, 
                                        p_chanselect = &chandef, 
                                        count        = &count);
         if (!(status & 1))
         {
#ifdef DEBUG
            om$report_error(sts = status);
#endif
            goto wrapup;
         }

         if (count)				
         {
            status = om$send (mode = OM_e_wrt_object,
                              msg = message IGEgadget.change_process_from(msg,
                                                  pid,time_out),
                              senderid = my_id,
                              p_chanselect = &chandef);
            if ( !(1 & status) )
            {
#ifdef DEBUG
               om$report_error(sts = status);
               printf("Error: send to gragad change_process_from\n");
#endif
            }
         }
      }
      else
      {
         status = OM_I_STOP_SENDING;
         *msg = -1;
      }
   }
wrapup:
#endif
   return (status);
}


method change_cusror_def (IGRlong *msg; IGRint flag;
                          IGRlong *enable_pattern;
                          IGRlong *data_pattern;
                          IGRlong *hot_spot)
{
    IGRshort      fgcol, bgcol;
    WLuint32      fg_colorref, bg_colorref;
    WLuint32      ctx_num;
    IGRint	  status = OM_S_SUCCESS;
    struct WLcontext_info context_info;

    *msg = MSSUCC;

    if (flag == REPLACE_CURSOR_DEF)
    {
        status = om$vla_set_dimension( varray = ME.IGEwindow->cursor_def,
                                      size = 66);

        OM_BLOCK_MOVE((char *)enable_pattern,
                      (char *)ME.IGEwindow->cursor_def,
                      sizeof(IGRlong) * 32);

        OM_BLOCK_MOVE((char *)data_pattern,
                      (char *)&ME.IGEwindow->cursor_def[32],
                      sizeof(IGRlong) * 32);

        OM_BLOCK_MOVE((char *)hot_spot,
                      (char *)&ME.IGEwindow->cursor_def[64],
                      sizeof(IGRlong) * 2);

    }

    status = WLhide_cursor ( ME.IGEgadget->win_no, 1 );
    if (status != WL_SUCCESS)
    {
       status = OM_E_ERROR;
       return (status);
    }

    status = WLget_window_base_context ( ME.IGEgadget->win_no, &ctx_num );
    if (status != WL_SUCCESS) 
    {
       return (OM_E_ERROR);
    }

    status = WLget_context_info ( ctx_num, &context_info );
    if (status != WL_SUCCESS) 
    {
       return (OM_E_ERROR);
    }
    status = OM_S_SUCCESS;

   /*===========================*/
   /*  go for menu white        */
   /*===========================*/

   if ( context_info.base_cmap_type == WL_CMAP_INDEXED )
   {
      status = ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                                           FI_DEFINE = FI_WHITE,
                                           phys_slot_num = &fgcol );

      if (!status)
      {
         return( OM_E_ERROR );
      }
   
      /*===========================*/
      /* get the menu black slot   */ 
      /*===========================*/
   
      status = ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                                           FI_DEFINE = FI_BLACK,
                                           phys_slot_num = &bgcol );
   
      if (!status)
      {
         return( OM_E_ERROR );
      }
   
   
      WLpack_index_colorref( fgcol, &fg_colorref, TRUE );
      WLpack_index_colorref( bgcol, &bg_colorref, TRUE );
    }
    else
    {
      WLpack_rgb_colorref( 0xffff, 0xffff, 0xffff, &fg_colorref, TRUE );
      WLpack_rgb_colorref( 0, 0, 0, &bg_colorref, TRUE );
    }

    status = WLdefine_cursor ( ME.IGEgadget->win_no, (char *)data_pattern,
                               (char *)enable_pattern, 32, 32, fg_colorref,
                               bg_colorref, hot_spot[0], hot_spot[1] );
    if (status != WL_SUCCESS)
    {
       status = OM_E_ERROR;
       return (status);
    }

    status = WLshow_cursor ( ME.IGEgadget->win_no );
    if (status != WL_SUCCESS)
    {
       status = OM_E_ERROR;
    }
    else
       status = OM_S_SUCCESS;

    return(status);
}


method reset_cursor_def (IGRlong *msg)

{
   IGRshort      fgcol, bgcol;
   WLuint32      fg_colorref, bg_colorref;
   WLuint32      ctx_num;
   IGRint        status;
   struct WLcontext_info context_info;

   status = WLhide_cursor ( ME.IGEgadget->win_no, 1 );
   if (status == WL_SUCCESS)
   {
      status = WLget_window_base_context ( ME.IGEgadget->win_no, &ctx_num );
      if (status != WL_SUCCESS) 
      {
         return (OM_E_ERROR);
      }

      status = WLget_context_info ( ctx_num, &context_info );
      if (status != WL_SUCCESS) 
      {
         return (OM_E_ERROR);
      }

      if ( context_info.base_cmap_type == WL_CMAP_INDEXED )
      {

         /*===========================*/
         /*  go for menu white        */
         /*===========================*/

         status = ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                                              FI_DEFINE = FI_WHITE,
                                              phys_slot_num = &fgcol );
   
         if (!status)
         {
            return( OM_E_ERROR );
         }
   
         /*===========================*/
         /* get the menu black slot   */ 
         /*===========================*/
   
         status = ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                                              FI_DEFINE = FI_BLACK,
                                              phys_slot_num = &bgcol );
   
         if (!status)
         {
            return( OM_E_ERROR );
         }
   
   
         WLpack_index_colorref( fgcol, &fg_colorref, TRUE );
         WLpack_index_colorref( bgcol, &bg_colorref, TRUE );
   
      }
      else
      {
         WLpack_rgb_colorref( 0xffff, 0xffff, 0xffff, &fg_colorref, TRUE );
         WLpack_rgb_colorref( 0, 0, 0, &bg_colorref, TRUE );
      }

      if (om$dimension_of(varray = ME.IGEwindow->cursor_def) < 66)
      {
         status = WLdefine_cursor ( ME.IGEgadget->win_no, c_d, c_e, 32, 32,
                                    fg_colorref, bg_colorref, 15, 15 );
      }
      else
      {
         status = WLdefine_cursor ( ME.IGEgadget->win_no,
                                    (char *)&ME.IGEwindow->cursor_def[0],
                                    (char *)&ME.IGEwindow->cursor_def[32],
                                    32, 32, fg_colorref, bg_colorref, 
                                    ME.IGEwindow->cursor_def[64],
                                    ME.IGEwindow->cursor_def[65] );
      }
      if (status == WL_SUCCESS)
         status = WLshow_cursor ( ME.IGEgadget->win_no );
   }

   if (status != WL_SUCCESS)
      *msg = status = OM_E_ERROR;
   else
   {
      *msg = MSSUCC;
      status = OM_S_SUCCESS;
   }
   return(status);
}
	   

method display_name (IGRchar *name)
{
   int status;

   status = WLset_window_name (ME.IGEgadget->win_no, name);
   if (status != WL_SUCCESS) 
   {
      status = OM_E_ERROR;
   }
   else
   {
      status = OM_S_SUCCESS;
   }
   return(status);
}

#argsused
void EX_delete_win(win_no)
int win_no;
{
#ifdef ENV5
   DPhandle_event();
#endif
}

void EX_record_windows()
{
    int                 status;
    long		msg;
    IGRint		i;
    long		which_error;
    GRobjid		mod_id;
    OMuint		win_count;
    struct win_var_list	var_list[3];

#ifdef X11
    XEvent       xevent;
#endif

    IGRint		nret;
    IGRint		win_flags;
    GRspacenum		mod_osnum;
    OM_S_CHANSELECT 	chandef;
    OM_S_OBJECT_LINKAGE	win_list[100];

    WLuint32                lwin;
    int                     num_ctxs;
    WLuint32               *ctx_num_p;
    struct WLcontext_info  *ctx_p;
    struct WLnative_info    wl_native_info;
   
   ex$get_cur_mod ( id    = &mod_id,
                    osnum = &mod_osnum);

   chandef.type = OM_e_name;
   chandef.u_sel.name = "module.windows";

   om$get_channel_objects ( osnum        = mod_osnum,
                            objid        = mod_id,
                            p_chanselect = &chandef,
                            list         = win_list,
                            size         = 100,
                            count        = &win_count);

   var_list[0].var            = HW_WIN_NO;
   var_list[0].var_ptr        = (IGRchar *) &lwin;
   var_list[0].num_bytes      = (IGRlong) sizeof (IGRint);
   var_list[0].bytes_returned = (IGRlong *) &nret;

   var_list[1].var            = WINDOW_FLAGS;
   var_list[1].var_ptr        = (IGRchar *) &win_flags;
   var_list[1].num_bytes      = (IGRlong) sizeof (IGRint);
   var_list[1].bytes_returned = (IGRlong *) &nret;

   var_list[2].var            = END_PARAM;

   for (i = 0; i < win_count; i++)
   {
      ige$inq_set_window ( msg          = &msg,
                           osnum        = win_list[i].osnum,
                           window_objid = win_list[i].S_objid,
                           which_error  = &which_error,
                           var_list     = var_list);

      if (win_flags & WIN_IS_ACTIVE)
      {
         status = WLget_window_contexts ( lwin, &num_ctxs, &ctx_num_p,
                                          &ctx_p );
         if (status != WL_SUCCESS) continue;

         status = WLget_native_info ( lwin, *ctx_num_p, &wl_native_info );

         WLfree ((char*)ctx_num_p);
         WLfree ((char*)ctx_p);

         if (status != WL_SUCCESS) continue;

         EX_record_new_window (wl_native_info.base_win);

#ifdef X11
         if (!(win_flags & WIN_IS_COLLAPSED))
         {
            xevent.type = Expose;
            xevent.xany.window = wl_native_info.base_win;
            JNL_record_next_event (&xevent, 1);
         }
#endif
      }
   }
}


/*====================================================================*/
/*  This function is used to select the proper logical screen id      */
/*  for input to macros like ige$inq_term_info                        */
/*  Values input must be either RIGHT_SCREEN or LEFT_SCREEN           */
/*  Values output will be either IGE_RIGHT_SCREEN or IGE_LEFT_SCREEN  */
/*  See igewindef.h for definitions                                   */
/*====================================================================*/

int EX_multi_screen ( int screen )
{
   int  status;
   int  num_screens;

   if (screen == RIGHT_SCREEN) return (IGE_RIGHT_SCREEN);

   status = WLget_number_of_screens ( &num_screens, NULL );
   if (status != WL_SUCCESS) return (IGE_RIGHT_SCREEN);

   if (num_screens == 1) return (IGE_RIGHT_SCREEN);

   if (screen == LEFT_SCREEN) return (IGE_LEFT_SCREEN);

   return (IGE_RIGHT_SCREEN);   
}


end implementation IGEwindow;
