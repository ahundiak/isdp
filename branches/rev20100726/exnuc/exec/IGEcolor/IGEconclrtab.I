/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/

class implementation IGEcolor2;

#include <stdio.h>
#include <math.h>
#include "exmacros.h"
#include "igewindef.h"
%safe
#include "wl.h"
#include "cm.h"
%endsafe
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "igewinmacros.h"
#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>

extern Display *EXdisplay;
extern int      EXscreen;
extern Colormap EXcolormap[];
#endif

#define MAXIMUM(x,y) ((x>y)?x:y)
#define MINIMUM(x,y) ((x<y)?x:y)
#define ONE 65535
#define D_ONE 65535.0
#define TOLERANCE 0.01
%safe

static int  (*DPload_vlt_ptr)();
extern int Loadvlt();
extern OMuword OM_Gw_current_OS;
%endsafe

from IGEcolsup import color_table_changed;
from APPcolor2 import  get_color_table;


/* maximum distance in cube is 256^2+256^2+256^2 */
#define MAXDISTSQ 196608
#define MAXDISTSQ_D 196608.0

method configure_table(WLuint32 context_no)
{
/*
NAME
   IGEcolor2.configure_table
DESCRIPTION
   this method will configure the color table
PARAMETERS
   context_no (in) - the context to configure
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   int num_of_contexts, i;
   struct CMctx_mgr *ctx_arr_ptr=(struct CMctx_mgr *) NULL;
   IGRint sts = 1;
   IGRint   count;
   OM_S_CHANSELECT   chandef;
   IGRshort cube_dimension;
   IGRshort special_size;
   IGRushort *special_colors=(IGRushort *)NULL;
   IGRdouble gamma[3];
   struct IGEcontext_info IGEcontext_info;
   struct IGEcolor2_data *IGEcolor2_data_ptr;
   IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;
   
   sts = om$make_chanselect(channame = "IGEcolor2.to_APPcolor2", p_chanselect = &chandef);
   sts = om$get_channel_count(objid = my_id, p_chanselect = &chandef, count = (OMuint *)&count);

   if (count)
   {
      /* get parameters from object */
      sts = om$send(msg = message APPcolor2.get_color_table(
         &cube_dimension,
         &special_size, &special_colors,
         &me->tolerance_pct[0],
         gamma),
            senderid = my_id, 
            p_chanselect = &chandef,
            from = (count - 1),
            to = (count - 1));
      if (me->gamma[0] != 1.0 || me->gamma[1] != 1.0 || me->gamma[2] != 1.0)
      {
         /* only if gamma compensate is on do you shove in the gamma values */
         me->gamma[0] = gamma[0];
         me->gamma[1] = gamma[1];
         me->gamma[2] = gamma[2];
      }
   }
   else
   {
      cube_dimension = 0x7FFF;
      special_size=0;
   }

   /* loads the logical colors of object into local data structures */
   IGEload_logical_array(me->bg_log_hl_colors,0,me->num_bg_log_hl_colors);
   
   /* configure the color table */
   if (context_no == WL_DEFAULT_CONTEXT)
   {
      /* configure all of the contexts with my id */
      CMget_contexts( &ctx_arr_ptr, &num_of_contexts );
   
      for ( i=0; i<num_of_contexts; i++ )
      {
         if ( ctx_arr_ptr[i].color_objid == my_id )
         {
            IGEload_context(ctx_arr_ptr[i].context_no, &IGEcontext_info);
            IGEcontext_info.num_ramp_colors = IGEcolor2_data_ptr->num_ramp_colors;
            IGEcontext_info.user_cube_size = IGEcolor2_data_ptr->user_cube_size;
            IGEsave_context(ctx_arr_ptr[i].context_no, &IGEcontext_info);
            /* Change every context mapping */
            sts = IGEconfigure_table( ctx_arr_ptr[i].context_no, cube_dimension, special_size, special_colors, 
               me->tolerance_pct[0], me->gamma);
            if (!(sts & 1))
            {
#ifdef DEBUG_CL
               printf("IGEcolor2.configure_color_table: configure error context %d\n", ctx_arr_ptr[i].context_no);
#endif
               goto wrapup;
            }
         }
#ifdef DEBUG_CL      
         else
         {
            printf("IGEcolor2.configure_color_table: context color objid %d my_id %d\n",
               ctx_arr_ptr[i].color_objid,my_id);
         }
#endif
      }
   
      if (ctx_arr_ptr)
      {
         free(ctx_arr_ptr);
      }
   }
   else
   {
      /* only one context to configure */   
      IGEload_context(context_no, &IGEcontext_info);
      IGEcontext_info.num_ramp_colors = IGEcolor2_data_ptr->num_ramp_colors;
      IGEcontext_info.user_cube_size = IGEcolor2_data_ptr->user_cube_size;
      IGEsave_context(context_no, &IGEcontext_info);
      IGEconfigure_table( context_no, cube_dimension, special_size, special_colors, 
         me->tolerance_pct[0], me->gamma);
   }
   
   /* notify other objects of a color table change if they are there */
   chandef.type = OM_e_addr;
   chandef.u_sel.addr = &ME.IGEcolor2->notify;
   sts = om$get_channel_count(objid = my_id, p_chanselect = &chandef, count = (OMuint *)&count);

   if (!(sts & 1))
   {
#ifdef DEBUG_CL
      om$report_error(sts = sts);
#endif
      goto wrapup;
   }

   if (count)
   {
      sts = om$send (msg = message IGEcolsup.color_table_changed(my_id, OM_Gw_current_OS),
                     senderid = my_id,
                     p_chanselect = &chandef);
      if (!(1 & sts))
      {
#ifdef DEBUG_CL
         om$report_error(sts = sts);
#endif
         goto wrapup;
      }
   }
   	
wrapup:
   return(sts);
}

IGRint ( *DPset_load_vlt_ptr( int (*func)()) )()
{
/*
NAME
   IGEcolor2.DPset_load_vlt_ptr
DESCRIPTION
   this sets the hook function
PARAMETERS
   func (in) - the function to be called
RETURN VALUES
   the old function
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
    IGRint (*temp_func)();

    temp_func = DPload_vlt_ptr;
    DPload_vlt_ptr = func;

    return(temp_func);
}

method set_data_for_IGEcolor2(IGRshort num_colors;
         IGRint *colors;
         IGRshort num_names;
         struct IGEcol_names *names;
         IGRint num_ramp_colors)
{
/*
NAME
   IGEcolor2.set_data_for_IGEcolor2
DESCRIPTION
   this method sets the data from the IGEcolor object
PARAMETERS
   
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRlong msg;
   IGRint calibration_flag;
   struct IGEcolor2_data *IGEcolor2_data_ptr;
   IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;
   
   GRsetinqcolcal( &msg, 0, &calibration_flag);
   if ( calibration_flag )
   {
      /* gamma compensation was on */
      me->gamma[0] = me->gamma[1] = me->gamma[2] = 2.2;
   }
   else 
   {
      /* gamma compensation was off */
      me->gamma[0] = me->gamma[1] = me->gamma[2] = 1.0;
   }

   ige$change_color_names(num_names = num_names, names = names);

   ige$change_color_table(num_colors = num_colors - 1, colors = colors, 
      flags = PACKED_COLORS | IGE_CHANGE_BACKGROUND);
   
   /* set the highlight color to last in the color array */
   ige$change_reserved_colors(	hilite_color = &colors[num_colors-1], flags = PACKED_COLORS);
   IGEcolor2_data_ptr->num_ramp_colors = num_ramp_colors;
   return(TRUE);
}

method add_context(WLuint32 context_no)
{
/*
NAME
   IGEcolor2.add_context   
DESCRIPTION
   this adds a context to the internal data structures
PARAMETERS
   context_no (in) - the context to add
RETURN VALUES
   0 = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint    num_win_mgr,num_ingr_res, sts;
   struct WLcmap_entry *WLwin_mgr=(struct WLcmap_entry *)NULL;
   struct WLcmap_entry *WLingr_res=(struct WLcmap_entry *)NULL;

   WLget_wm_colors(context_no,&num_win_mgr,&WLwin_mgr,&num_ingr_res,&WLingr_res);  
   sts = IGEadd_context(context_no,num_win_mgr,num_ingr_res,me->num_bg_log_hl_colors);

   if (WLwin_mgr)
   {
      free(WLwin_mgr);
   }
   if (WLingr_res)
   {
      free(WLingr_res);
   }

   return(sts);
}

method delete_context(WLuint32 context_no)
{
/*
NAME
   IGEcolor2.delete_context
DESCRIPTION
   this deletes the internal data structures for a context
PARAMETERS
   context_no (in) - the context to delete
RETURN VALUES
   0 = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   return(IGEdelete_context(context_no));
}

method get_color_functions(
   struct WLcontext_info *context_info;
   int (**cmap_color_to_index)
      ( WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, WLuint32 *);
   int (**cmap_color_to_rgb)
      ( WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, WLuint32,  WLuint32 *, WLuint32 *, WLuint32 *);
   int (**cmap_init)
      ( WLuint32 ) )
{
/*
NAME
   IGEcolor2.get_color_functions
DESCRIPTION
   this method is provided to be overwritten when someone wants to give different
   functions to WL.  returning NULL for a function will not change it.
PARAMETERS
   context_info (in ) - information to help decide which functions to return
   cmap_color_to_inex (out) - function pointer for WL
   cmap_color_to_rgb (out) - function pointer for WL
   cmap_init (out) - function pointer for WL
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   *cmap_color_to_index=(int (*)())NULL;
   *cmap_color_to_rgb=(int (*)())NULL;
   *cmap_init=(int (*)())NULL;
   return(TRUE);
}

method remap_logical_color_table( int start_color; int num_changed_colors )
{
/*
NAME
   IGEcolor2.remap_logical_color_table
DESCRIPTION
   This will remap the logical colors specivied for all of the contexts.
   Create color table will call this when it changes colors to keep them
   all consistent. 
PARAMETERS
   start_color (in) - the logical color to start remapping
   num_changed_colors (in) - the number of colors to remap
RETURN VALUES
   0 = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   int sts=0;
   int num_of_contexts, i;
   struct CMctx_mgr *ctx_arr_ptr=(struct CMctx_mgr *) NULL;
   struct IGEcontext_info IGEcontext_info;

   CMget_contexts( &ctx_arr_ptr, &num_of_contexts );

   for ( i=0; i<num_of_contexts; i++ )
   {
      if ( ctx_arr_ptr[i].color_objid==my_id)
      {
         /* Change every context mapping */
         IGEload_context(ctx_arr_ptr[i].context_no, &IGEcontext_info);
         if ( ((start_color + num_changed_colors - 1) < 1) ||
              (start_color > IGEcontext_info.num_ramp_colors) ||
              !(IGEcontext_info.using_ramp) )
         {
            sts = IGEremap_logical_table( ctx_arr_ptr[i].context_no,
               me->tolerance_pct[0], me->gamma, 
               me->bg_log_hl_colors, me->num_bg_log_hl_colors, 
               start_color, num_changed_colors);
         }
         else
         {
            ige$configure_color_table( context_no = ctx_arr_ptr[i].context_no );
         }
      }
#ifdef DEBUG_CL      
      else
      {
         printf("IGEcolor2.remap_logical_color_table: context color objid %d my_id %d\n",
            ctx_arr_ptr[i].color_objid,my_id);
      }
#endif
   }
   goto wrapup;

wrapup:
   if (ctx_arr_ptr)
   {
      free(ctx_arr_ptr);
   }

   return(sts);
}

end implementation IGEcolor2;


