#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "exmacros.h"


#include "wl.h"
#include "wl_internal.h"
#include "cm.h"


#if defined( X11 )
extern Display *EXdisplay;
#endif
static WLuint32 CMexnuc_forms_context[WL_MAX_SCREENS];
static WLuint32 saved_lwin_no, saved_context_no;
static int number_of_forms_in_wl = 0;
static int initial_number_of_forms_in_wl = 0;
/*---  CMadd_form_to_wl--------------------------------------------*/

int CMadd_form_to_wl(
   WLhwin_no hwin_no,
   int share,
   OM_S_OBJID color_objid,
   OMuword osnum,
   int save_restore,
   WLuint16 *lscreen_no,
   WLuint32 *context_no,
   WLuint32 *lwin_no )

/*
NAME
	CMadd_form_to_wl
 
KEYWORD
	
 
DESCRIPTION
	This function adds a form to the WL system so that WL windows can be 
	used to manipulate the form window. It creates a context and
	adds the window to the wl system.

SYNOPSIS
	int CMadd_form_to_wl(
		WLhwin_no hwin_no,
		int share,
		OM_S_OBJID color_objid,
		int save_restore,
		WLuint16 *lscreen_no,
		WLuint32 *context_no,
		WLuint32 *lwin_no )
 
PARAMETERS
	hwin_no (IN) - The hardware window number of the form
	share (IN) - Indicates whether to share the context
	color_objid (IN) - Color object object id, NULL_OBJID to use IGEcolor2
	osnum (IN) - The object space number of the color object
	save_restore (IN) - Indicates whether the form is save restore or not
	lscreen_no (OUT) - The logical screen number
	context_no (OUT) - context number
	lwin_no (OUT) - The logical window number

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	01/20/93 Shridar Subramanian
		Initial definition

	01/20/93 Shridar Subramanian
		Initial design
*/

{
   int context_defined = 0;
   OM_S_OBJID  mod_id;
   OMuword super_osnum;  
   int sts, i, num_contexts, found, hilite_depth;
   int form_depth, form_cmap_type;
   char class[100];

   struct WLnative_info native_info;
   struct WLcontext_info context_info;
   struct CMctx_mgr *ctx_arr;


#if defined( ENV5 )
   struct scr_info info[MAX_SCREENS];
#elif defined( X11 )
   XWindowAttributes win_attr;
   GC gc;
#endif
   found = form_depth = form_cmap_type = 0;

   if ( color_objid == NULL_OBJID )
   {
      ex$get_modid( mod_osnum = osnum, mod_id = &mod_id );
      sts = ex$get_super ( mod_id = mod_id, mod_osnum = osnum,
                           super_name = "IGECOLOR2", create = 0,  
                           super_class=class, super_id = &color_objid, 
                           super_osnum=&super_osnum );     
      if( sts != OM_S_SUCCESS )
      {
         color_objid = NULL_OBJID;
      }
   }
  

#if defined( ENV5 )

   native_info.base_win = hwin_no;
   native_info.cursor = 0;

   /* Its better to inq_displayed_vs b'cos inq_win_vs may return vs_no 0 */
   /* in the case of save restore forms, which is an invalid screen num  */
   /* in Env5                                                            */

   sts = Inq_displayed_vs( &native_info.vs_no );
   if ( sts )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }

   sts = Inq_screen_info( info );
   if ( sts )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }

   if ( ( !save_restore ) && 
        ( info[native_info.vs_no].vsi_flags & VSI_TRC_ABILITY ) )
   {
      sts = Inq_activevltno( hwin_no, &native_info.vlt_no );
      if ( sts )
      {
         CM_REPORT_ERROR( CM_SYSTEM_ERROR );
         return( CM_SYSTEM_ERROR );
      }
   }
   else
   {
      native_info.vlt_no = -1;
   }
   if ( save_restore )
   {
      context_info.base_cmap_type =  WL_CMAP_INDEXED;
      context_info.base_depth = info[native_info.vs_no].vsi_SR_max_planes;
      context_info.hilite_used = 0;
      context_info.flags = WL_SAVE_RESTORE_CONTEXT | 
                           WL_COLORMAP_SAVE_RESTORE;
      if (  info[native_info.vs_no].vsi_flags & VSI_SR_VLT_ABILITY )
      {
         context_defined = 1;
         found = 1;
      }
      else
      {
         context_defined = 0;
         form_depth = info[native_info.vs_no].vsi_SR_max_planes;
         form_cmap_type =  WL_CMAP_INDEXED;
         found = 0;
      }
   }
   else
   {
      /* See what contexts can be shared   */

      context_defined = 0;

      /* If Edge I                         */

      if ( ( info[native_info.vs_no].vsi_num_planes == 9 ) &&
           ( info[native_info.vs_no].vsi_VLT_size == 256 ) )
      {
         form_depth = 8;
      }
      else
      {
         form_depth = info[native_info.vs_no].vsi_num_planes;
      }
      form_cmap_type = WL_CMAP_INDEXED;

   }

   sts = WLget_logical_screen_from_screen( native_info.vs_no, lscreen_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
  
#elif defined( X11 )
   native_info.display = EXdisplay;
   native_info.base_win = hwin_no;
   native_info.hl_win = -1;
#if defined( OPENGL )
   native_info.glx_context = NULL;
#endif
#if defined( XGL )
   native_info.xgl_context_3D = NULL;
   native_info.hl_xgl_context_3D = NULL; 
   native_info.win_ras = NULL;
   native_info.hl_win_ras = NULL;
   native_info.mem_ras = NULL;
   native_info.hl_mem_ras = NULL;
   native_info.xgl_base_cmap = NULL;
   native_info.xgl_hilite_cmap = NULL;
   native_info.flags &= (~WL_USING_XGL );
#endif

   sts = XGetWindowAttributes( EXdisplay, hwin_no, &win_attr );   
   if ( sts == 0 )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }
   gc =  XCreateGC( EXdisplay, hwin_no, 0, NULL );
   native_info.gc = gc;
   native_info.colormap = win_attr.colormap;
   native_info.visual = win_attr.visual;
   native_info.cursor = NULL;
   native_info.screen = XScreenNumberOfScreen( win_attr.screen );

   form_depth = win_attr.depth;
   context_defined = 0;
   
   form_cmap_type = WL_CMAP_INDEXED;

   sts = WLget_logical_screen_from_screen( native_info.screen, lscreen_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
 
#elif defined( WIN32 )

/* !!!!!! Need to implement NT       !!!!!!!!!!! */

#else
#error " A windowing system must be defined"
#endif

   if ( !context_defined )
   {
      CMget_contexts ( &ctx_arr, &num_contexts );
      found = 0;
      for( i = 0; i < num_contexts; i++ )
      {
         sts = WLget_context_info( ctx_arr[i].context_no, &context_info );
         if ( sts != WL_SUCCESS )
         {
            WL_REPORT_ERROR( sts );
            return( sts );
         }
         hilite_depth = (context_info.hilite_used) ? 1 : 0;

         /* Special treatement for Edge 1, because of the separate */
         /* highlight slot issue ( if hilight_depth == 1, one will */
         /* be comparing with a depth of 9, which is incorrect     */
 
#if defined( ENV5 )
         if ( ( info[native_info.vs_no].vsi_num_planes == 9 ) &&
              ( info[native_info.vs_no].vsi_VLT_size == 256 ) )
         {
            if ( context_info.base_depth == 8 )
            {
               hilite_depth = 0;
            }
         }
#endif
         
         if ( ( ( context_info.base_depth + hilite_depth ) == form_depth ) &&
              ( context_info.base_cmap_type == form_cmap_type ) &&
              ( !( context_info.flags & WL_SAVE_RESTORE_CONTEXT ) ) )
         {
            found = 1;
            break;
         }
      }
   } 

   if ( !found )
   {
      context_info.base_depth = form_depth;
      context_info.base_cmap_type = form_cmap_type;
      context_info.hilite_used = 0;
   }
   /*
      Though the Env5 documentation says that Load_SR_vlt should be used only
      if the SR_VLT_ABILITY flag is set, we have to use Load_SR_vlt if the
      window is save restore. ( Loadvlt in SR does not work on 2400 ).
      If a SR vlt is not present try to use context information that 
      is common with some other EMS window 
   */
   if ( save_restore )
   {
      context_info.flags = WL_SAVE_RESTORE_CONTEXT | 
                           WL_COLORMAP_SAVE_RESTORE;
      sts = WLset_active_SR_window( hwin_no );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      } 
   }
   else
   {
      context_info.flags = 0;
      sts = WLset_active_SR_window( -1 );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      } 
   }


   sts = CMcreate_context_native_info( color_objid, *lscreen_no, &context_info,
                                       &native_info, share, context_no );
   if ( sts != CM_SUCCESS )
   {
      CM_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( X11 )
   native_info.flags = 0;
#endif
   sts = WLadd_hardware_window( hwin_no, *context_no, &native_info, lwin_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   } 
   if ( number_of_forms_in_wl <= initial_number_of_forms_in_wl )
   {
      WLget_installed_cmap( &saved_lwin_no, &saved_context_no );
   }
   number_of_forms_in_wl++; 
   WLinstall_cmap( *lwin_no,  *context_no ); 

   return( CM_SUCCESS );
} /* CMadd_form_to_wl */
    
     
/*---  CMremove_form_from_wl--------------------------------------------*/

int CMremove_form_from_wl(
   WLuint16 lscreen_no,
   WLuint32 lwin_no,
   WLuint32 context_no )

/*
NAME
	CMremove_form_from_wl
 
KEYWORD
	
 
DESCRIPTION
	This function removes a form to the WL system. 

SYNOPSIS
	int CMremove_form_from_wl(
		WLuint16 lscreen_no,
		WLuint32 lwin_no,
		WLuint32 context_no )

PARAMETERS
	lscreen_no (IN) - The logical screen number
	lwin_no (IN) - The logical window number
	context_no (IN) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	01/20/93 Shridar Subramanian
		Initial definition

	01/20/93 Shridar Subramanian
		Initial design
*/

{

   int sts;

   sts = WLdelete_window( lwin_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLset_active_SR_window( -1 );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   } 

   sts = CMdelete_context( lscreen_no, context_no );
   if ( sts != CM_SUCCESS )
   {
      CM_REPORT_ERROR( sts );
      return( sts );
   }

   if ( number_of_forms_in_wl <= (initial_number_of_forms_in_wl + 1) )
   {
      WLinstall_cmap( saved_lwin_no,  saved_context_no ); 
   }
   number_of_forms_in_wl--; 
   return( CM_SUCCESS );

} /* CMremove_form_from_wl */
    
/*---  CMset_exnuc_forms_context--------------------------------------------*/

int CMset_exnuc_forms_context(
   WLuint16 lscreen_no,
   WLuint32 context_no )

/*
NAME
	CMset_exnuc_forms_context
 
KEYWORD
	
 
DESCRIPTION
	This function sets the forms context created by exnuc for that screens

SYNOPSIS
	int CMset_exnuc_forms_context(
		WLuint16 lscreen_no,
		WLuint32 context_no )

PARAMETERS
	lscreen_no (IN) - The logical screen number
	context_no (IN) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	07/01/93 Shridar Subramanian
		Initial definition, design, implementation

*/

{

   if ( lscreen_no >= WL_MAX_SCREENS )
   {
      CM_REPORT_ERROR( CM_BAD_PARAMETER );
      return( CM_BAD_PARAMETER );
   }

   CMexnuc_forms_context[lscreen_no] = context_no;
   
   return( CM_SUCCESS );

} /* CMset_exnuc_forms_context */
    
/*---  CMget_exnuc_forms_context--------------------------------------------*/

int CMget_exnuc_forms_context(
   WLuint16 lscreen_no,
   WLuint32 *context_no )

/*
NAME
	CMget_exnuc_forms_context
 
KEYWORD
	
 
DESCRIPTION
	This function gets the forms context created by exnuc for that screens

SYNOPSIS
	int CMget_exnuc_forms_context(
		WLuint16 lscreen_no,
		WLuint32 *context_no )

PARAMETERS
	lscreen_no (IN) - The logical screen number
	context_no (OUT) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	07/01/93 Shridar Subramanian
		Initial definition, design, implementation

*/

{

   if ( lscreen_no >= WL_MAX_SCREENS )
   {
      CM_REPORT_ERROR( CM_BAD_PARAMETER );
      return( CM_BAD_PARAMETER );
   }

   *context_no = CMexnuc_forms_context[lscreen_no];
   
   return( CM_SUCCESS );

} /* CMget_exnuc_forms_context */
    
/*---  CMset_initial_num_forms--------------------------------------------*/

int CMset_initial_num_forms(
   int num_initial_forms )

/*
NAME
	CMset_initial_num_forms
 
KEYWORD
	
 
DESCRIPTION
	This function sets the variable initial_num_forms

SYNOPSIS
        int CMset_initial_num_forms(
                int num_initial_forms )
 
PARAMETERS
        num_initial_forms (IN) - The initial value

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	02/02/94 Shridar Subramanian
		Initial definition, design
*/

{
   initial_number_of_forms_in_wl = num_initial_forms;

   return( CM_SUCCESS );

} /* CMset_initial_num_forms */

/*---  CMget_initial_num_forms--------------------------------------------*/

int CMget_initial_num_forms(
   int *num_initial_forms )

/*
NAME
	CMget_initial_num_forms
 
KEYWORD
	
 
DESCRIPTION
	This function gets the variable initial_num_forms

SYNOPSIS
        int CMget_initial_num_forms(
                int *num_initial_forms )
 
PARAMETERS
        num_initial_forms (OUT) - The initial value

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	02/02/94 Shridar Subramanian
		Initial definition, design
*/

{
    *num_initial_forms = initial_number_of_forms_in_wl;

   return( CM_SUCCESS );

} /* CMget_initial_num_forms */
