class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
 
#include "exdef.h"
#include "exmacros.h"

#include "wl.h"
#include "cm.h"

/* for prototypes */
#include "igecolor.h"

/*
  Context manager abstracts 
  1) creation and deletion of context
  2) retrieval and changing of context information
  in EMS. 
*/

%safe
struct CMctx_mgr CMcontexts[CM_MAX_CONTEXTS];
static int CMinitialized = FALSE;
static WLuint32 CMactive_contexts[WL_MAX_SCREENS] = {0};
%endsafe

%safe
static int default_ctx_type = WL_CMAP_TRUE_COLOR;
static int default_ctx_depth = 24;
static int default_db_used = 1;
static default_hilite_used = 1;
%endsafe

from IGEcolor2 import delete_context, get_color_functions;

/*--- CMdelete_context--------------------------------------------*/

int CMdelete_context(
   WLuint16 lscreen_no,
   WLuint32 context_no)

/*
NAME
	CMdelete_context
 
KEYWORD
	CM
 
DESCRIPTION
	This function deletes a context

SYNOPSIS
	int CMdelete_context(
		WLuint16 lscreen_no,
		WLuint32 context_no)
 
PARAMETERS
	context_no (IN) - context number

GLOBALS USED
	CMcontexts (static)
 
RETURN VALUES
	CM_SUCCESS
		Success

	CM_SYSTEM_ERROR
		The lscreen_no and context_no parameters are invalid.
 
HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/

{
   int i;
   int found = FALSE;
   int sts;
   OM_S_OBJID mod_id;
   OMuword mod_osnum;
   
   /* Delete the entry in the CMcontexts array. */
   for ( i = 0; (i < CM_MAX_CONTEXTS) && (!found); i++ )
   {
      if ( CMcontexts[i].context_no == context_no )
      {
         CMcontexts[i].flag &= ( ~CM_SLOT_USED );
         found = TRUE;
         break;
      }
   }

   if ( found )
   {
      if ( CMcontexts[i].color_objid != NULL_OBJID )
      {
         ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum );

         sts = om$send( msg = message IGEcolor2.delete_context( context_no ),
                        targetid = CMcontexts[i].color_objid,
                        targetos = mod_osnum,
                        senderid = NULL );
      }
   }

   sts = WLdelete_context( lscreen_no, context_no ); 
   if ( sts != WL_SUCCESS )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }

 
   return( CM_SUCCESS );
}  /* CMdelete_context */
    
     
/*--- CMcreate_context--------------------------------------------*/

int CMcreate_context(
   OM_S_OBJID color_objid,
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
   int share_context,
   WLuint32 *context_no )

/*
NAME
	CMcreate_context
 
KEYWORD
	CM
 
DESCRIPTION
	This function creates a context

SYNOPSIS
	int CMcreate_context(
		OM_S_OBJID color_objid,
		WLuint16 lscreen_no,
		struct WLcontext_info *context,
		int share_context,
		WLuint32 *context_no )
 
PARAMETERS
	color_objid (IN) - Color object object id.
	lscreen_no (IN) - logical screen number
	context (IN) - The context information
	share_context (IN) - Indiactes whether to share an existing context
	context_no (OUT) - context number

GLOBALS USED
	CMcontexts (static)
 
RETURN VALUES
	CM_SUCCESS
		Success

	CM_SYSTEM_ERROR
		A WL error occurred
 
HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/

{
   int status;
   int found = FALSE;
   int i;
   struct WLcontext_info context_info;
   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ) = NULL;
   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ) = NULL;
   int (*cmap_init)(
      WLuint32 context_no ) = NULL;
   OM_S_OBJID mod_id;
   OMuword mod_osnum;

   if ( ! CMinitialized )
   {
      CMinitialized = TRUE;
      for ( i = 0; i < CM_MAX_CONTEXTS; i++ )
      {
         CMcontexts[i].flag = 0;
         CMcontexts[i].color_objid = NULL_OBJID;
      }
   }       

   if ( ( share_context ) && ( color_objid != NULL_OBJID ) )
   {
      /* look through the array and see if any of the object ids match. if yes,*/
      /* get the context information of that context using WL calls ( It would */
      /* be faster if we store some more context information in the array ) */

      for ( i = 0; (i < CM_MAX_CONTEXTS) && (!found); i++ )
      {
         if ( (CMcontexts[i].flag & CM_SLOT_USED) && 
              (CMcontexts[i].flag & CM_SHARABLE) && 
              (CMcontexts[i].lscreen_no == lscreen_no) &&
              (CMcontexts[i].color_objid == color_objid) )
         {
            /* Compare the accessed context information with the information */
            /* passed into the function.  */

            status = WLget_context_info( CMcontexts[i].context_no, &context_info );
            if ( status != WL_SUCCESS )
            {
               CM_REPORT_ERROR( CM_SYSTEM_ERROR );
               return( CM_SYSTEM_ERROR );
            }

            if ( ( context_info.base_cmap_type == context->base_cmap_type ) &&
                 ( context_info.base_depth == context->base_depth ) &&
                 ( context_info.hilite_used == context->hilite_used ) &&
                 ( context_info.flags == context->flags ) )
            {
               found = TRUE;
               *context_no = CMcontexts[i].context_no;
               return( CM_SUCCESS );
            }
         }
      }
   }
      
   if ( !found )
   {

      if ( color_objid != NULL_OBJID )
      {
         ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum );

         status = om$send( msg = message IGEcolor2.get_color_functions( context,
                                                           &cmap_color_to_index,
                                                           &cmap_color_to_rgb,
                                                           &cmap_init ),
                           targetid = color_objid,
                           targetos = mod_osnum,
                           senderid = NULL );
      }
      
      /* Use the default routines if the color object does not return them */
      if ( !cmap_init )
      {
         cmap_init = IGEcmap_init;
      }
      if ( !cmap_color_to_rgb )
      {
         cmap_color_to_rgb = IGEcmap_color_to_rgb;
      }
      if ( !cmap_color_to_index )
      {
         cmap_color_to_index = IGEcmap_color_to_index; 
      }

      status = WLcreate_context( lscreen_no, context, cmap_color_to_index,
                                 cmap_color_to_rgb, cmap_init,
                                 context_no );
      if ( status != WL_SUCCESS )
      {
         CM_REPORT_ERROR( CM_SYSTEM_ERROR );
         return( CM_SYSTEM_ERROR );
      }

      /* Add an entry in the CMcontexts array */
      for ( i = 0; (i < CM_MAX_CONTEXTS) && (!found); i++ )
      {
         /* look for a slot that is not used and fill it */
         if ( !( CMcontexts[i].flag & CM_SLOT_USED ) )
         {
            CMcontexts[i].lscreen_no = lscreen_no;
            CMcontexts[i].color_objid = color_objid;
            CMcontexts[i].context_no = *context_no;
            CMcontexts[i].flag = CM_SLOT_USED;
            if ( share_context )
            {
               CMcontexts[i].flag |= CM_SHARABLE;
            }
            break;
         }
      }

   }  /* end: if ( ! found ) */
   status = CMinitialize_context( *context_no );

   return( CM_SUCCESS );
 
}  /* CMcreate_context */
    
/*--- CMchange_context_info--------------------------------------------*/

int CMchange_context_info(
   WLuint32 context_no,
   OM_S_OBJID  color_objid,
   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (*cmap_init)(
      WLuint32 context_no ) )

/*
NAME
	CMchange_context_info
 
KEYWORD
	CM
 
DESCRIPTION
	This function changes a context information

SYNOPSIS
	int CMchange_context_info(
		WLuint32 context_no,
		OM_S_OBJID  color_objid,
		int (*cmap_color_to_index)(),
		int (*cmap_color_to_rgb)(),
		int (*cmap_init)() )
 
PARAMETERS
	context_no (IN) - context number
	color_objid (IN) - The object id of the color object
	cmap_color_to_index (IN) - Function pointer
	cmap_color_to_rgb (IN) - Function pointer
	cmap_init (IN) - Function pointer

GLOBALS USED
	CMcontexts (static)
 
RETURN VALUES
	CM_SUCCESS
		Success

	CM_SYSTEM_ERROR
		A WL error occurred
 
HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/

{
   int status;
   int i;
   int found = FALSE;

   status = WLchange_context_color_functions( context_no, cmap_color_to_index,
                                              cmap_color_to_rgb,
                                              cmap_init );
   if ( status != WL_SUCCESS )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }

   /* Change the object id in the CMcontexts array */
   for ( i = 0; (i < CM_MAX_CONTEXTS) && (!found); i++ )
   {
      if ( CMcontexts[i].context_no == context_no )
      {
         CMcontexts[i].color_objid = color_objid;
         found = TRUE;
      }
   }

   return( CM_SUCCESS );
 
}  /* CMchange_context_info */
     
/*--- CMget_context_info--------------------------------------------*/

int CMget_context_info(
   WLuint32 context_no,
   OM_S_OBJID  *color_objid,
   int (**cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (**cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (**cmap_init)(
      WLuint32 context_no ),
   struct WLcontext_info *context_info )

/*
NAME
	CMget_context_info
 
KEYWORD
	CM
 
DESCRIPTION
	This function retrieves context information

SYNOPSIS
	int CMget_context_info(
		WLuint32 context_no,
		OM_S_OBJID  *color_objid,
		int (**cmap_color_to_index)(),
		int (**cmap_color_to_rgb)(),
		int (**cmap_init)(),
		struct WLcontext_info *context_info )
 
PARAMETERS
	context_no (IN) - context number
	color_objid (OUT) - The object id of the color object
	cmap_color_to_index (OUT) - Function pointer
	cmap_color_to_rgb (OUT) - Function pointer
	cmap_init (OUT) - Function pointer
	context_info (OUT) - The context information

GLOBALS USED
	CMcontexts (static)
 
RETURN VALUES
	CM_SUCCESS
		Success

	CM_BAD_PARAMETER
		One of the pointers is NULL

	CM_SYSTEM_ERROR
		A WL error occurred
 
HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/

{
   int status;
   int i;
   int found = FALSE;

   if ( (!color_objid) || (!cmap_color_to_index) ||
        (!cmap_color_to_rgb) || (!cmap_init) )
   {
      CM_REPORT_ERROR( CM_BAD_PARAMETER );
      return( CM_BAD_PARAMETER );
   }

   status = WLget_context_info( context_no, context_info ); 
   if ( status != WL_SUCCESS )
   {
     CM_REPORT_ERROR( CM_SYSTEM_ERROR );
     return( CM_SYSTEM_ERROR ); 
   }

   status = WLget_context_color_functions( context_no, cmap_color_to_index,
                                           cmap_color_to_rgb,
                                           cmap_init );
   if ( status != WL_SUCCESS )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR ); 
   }
   
   /*  get the color object id from the CMcontexts array */
   for ( i = 0; (i < CM_MAX_CONTEXTS) && (!found); i++ )
   {
      if ( CMcontexts[i].context_no == context_no )
      {
         *color_objid = CMcontexts[i].color_objid;
         found = TRUE;
      }
   }

   return( CM_SUCCESS );

}  /* CMget_context_info */
    

/*--- CMget_contexts--------------------------------------------*/

int CMget_contexts(
   struct CMctx_mgr **ctx_arr,
   int  *num_of_contexts )

/*
NAME
	CMget_contexts
 
KEYWORD
	CM
 
DESCRIPTION
	This function lists all the contexts created and the color objects
	associated with the context. This function allocates the space for
	the information. The user is responsible for freeing this memory

SYNOPSIS
	int CMget_contexts(
		struct CMctx_mgr **ctx_arr,
		int  *num_of_contexts )
 
PARAMETERS
	ctx_arr (OUT) - The list of all contexts and object ids
	num_of_contexts (OUT) - The number of contexts

GLOBALS USED
	CMcontexts (static)
 
RETURN VALUES
	CM_SUCCESS
		Success

	CM_BAD_PARAMETER
		One of the pointers is NULL.

	CM_SYSTEM_ERROR
		A WL error occurred
 
HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/

{
   int i;
   int slot_count = 0;
   int index[CM_MAX_CONTEXTS];

   if ( !ctx_arr )
   {
      CM_REPORT_ERROR( CM_BAD_PARAMETER );
      return( CM_BAD_PARAMETER );
   }

   *ctx_arr = NULL;

   if ( !num_of_contexts )
   {
      CM_REPORT_ERROR( CM_BAD_PARAMETER );
      return( CM_BAD_PARAMETER );
   }

   for ( i = 0; i < CM_MAX_CONTEXTS; i++ )
   {
      if ( CMcontexts[i].flag & CM_SLOT_USED )
      {
         index[slot_count] = i;
         ++slot_count;
      }
   }

   *num_of_contexts = slot_count;

   if ( slot_count > 0 )
   {
      *ctx_arr = (struct CMctx_mgr *) malloc( slot_count * 
                                              sizeof( struct CMctx_mgr ) );
      if ( *ctx_arr == NULL )
      {
         CM_REPORT_ERROR( CM_SYSTEM_ERROR )
         return( CM_SYSTEM_ERROR );
      }

      for ( i = 0; i < slot_count; i++ )
      {
         (*ctx_arr)[i] = CMcontexts[index[i]];
      }

   }

   return( CM_SUCCESS );

}  /* CMget_contexts */


/*--- CMset_active_context--------------------------------------------*/

int CMset_active_context(
   WLuint16 lscreen_no,
   WLuint32 context_no )

/*
NAME
	CMset_active_context
 
KEYWORD
	CM
 
DESCRIPTION
	This function sets the active context number for a 
	logical screen.

SYNOPSIS
	int CMset_active_context(
		WLuint16 lscreen_no,
		WLuint32 context_no )
 
PARAMETERS
	lscreen_no (IN) - the logical screen number
	context_no (IN) - The active context number

GLOBALS USED
	CMactive_contexts (static)
 
RETURN VALUES
	CM_SUCCESS
		Success
 
HISTORY
	01/10/93 Shridar Subramanian
		Initial definition

	01/10/93 Shridar Subramanian
		Initial design
*/

{

   CMactive_contexts[lscreen_no] = context_no;
   return( CM_SUCCESS );
}  /* CMset_active_context */


/*--- CMget_active_context--------------------------------------------*/

int CMget_active_context(
   WLuint16 lscreen_no,
   WLuint32 *context_no )

/*
NAME
	CMget_active_context
 
KEYWORD
	CM
 
DESCRIPTION
	This function returns the active context number

SYNOSPSIS
	int CMget_active_context(
		WLuint16 lscreen_no,
		WLuint32 *context_no )
 
PARAMETERS
	lscreen_no (IN) - the logical screen number
	context_no (OUT) - The active_context number

GLOBALS USED
	not yet
 
RETURN VALUES
	CM_SUCCESS
		Success

	CM_BAD_PARAMETER
		The pointer active_context_num is NULL

 
HISTORY
	01/10/93 Shridar Subramanian
		Initial definition

	01/10/93 Shridar Subramanian
		Initial design
*/

{
   if ( !context_no )
   {
      CM_REPORT_ERROR( CM_BAD_PARAMETER );
      return( CM_BAD_PARAMETER );
   }

   *context_no = CMactive_contexts[lscreen_no];
   return( CM_SUCCESS );

}  /* CMget_active_context */

/*--- CMinitialize_context--------------------------------------------*/

int CMinitialize_context(
   WLuint32 context_no )

/*
NAME
	CMinitialize_context
 
KEYWORD
	CM
 
DESCRIPTION
	This function initializes a context with a cmap_init call
	
SYNOPSIS
	int CMchange_context_info(
		WLuint32 context_no )
 
PARAMETERS
	context_no (IN) - context number

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	02/09/93 Joel underwood
		Initial definition

	02/09/93 Joel Underwood
		Initial design
*/

{
   int status;
   int (*cmap_init)(
      WLuint32 context_no );
   
   /* get the correct cmap_init to use */
   status = WLget_context_color_functions( context_no, NULL, NULL, &cmap_init );
   if( status != WL_SUCCESS )
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }

   /* initialize the color map for the given context */
   status = (*cmap_init)( context_no );
   if (status != 0)
   {
      CM_REPORT_ERROR( CM_SYSTEM_ERROR );
      return( CM_SYSTEM_ERROR );
   }
   
   return( CM_SUCCESS );
 
}   /* CMinitialize_context */

/*--- CMcreate_context_native_info-------------------------------------------*/

int CMcreate_context_native_info(
   OM_S_OBJID color_objid,
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
   struct WLnative_info *native_info,
   int share_context,
   WLuint32 *context_no )

/*
NAME
	CMcreate_context_native_info
 
KEYWORD
	CM
 
DESCRIPTION
	This function creates a context using the native info passed in.

SYNOPSIS
	int CMcreate_context_native_info(
		OM_S_OBJID color_objid,
		WLuint16 lscreen_no,
		struct WLcontext_info *context,
		struct WLnative_info *native_info,
		int share_context,
		WLuint32 *context_no )
 
PARAMETERS
	color_objid (IN) - Color object object id.
	lscreen_no (IN) - logical screen number
	context (IN) - The context information
	native_info (IN) - The native information
	share_context (IN) - Indiactes whether to share an existing context
	context_no (OUT) - context number

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/

{
   int status;
   int found = FALSE;
   int i;
   struct WLcontext_info lcontext;
   struct WLnative_info ctx_native_info;
   int (*cmap_color_to_index)();
   int (*cmap_color_to_rgb)();
   int (*cmap_init)();

   extern int IGEcmap_init();
   extern int IGEcmap_color_to_rgb();
   extern int IGEcmap_color_to_index();

   if ( CMinitialized == FALSE )
   {
      CMinitialized = TRUE;
      for ( i = 0; i < CM_MAX_CONTEXTS; i++ )
      {
         CMcontexts[i].flag = 0;
         CMcontexts[i].color_objid = NULL_OBJID;
      }
   }       
   if ( ( share_context ) && ( color_objid != NULL_OBJID ) )
   {
     /* look through the array and see if any of the object ids match. if yes,*/
     /* get the context information of that context using WL calls ( It would */
     /* be faster if we store some more context information in the array ) */

      for( i = 0; ( i < CM_MAX_CONTEXTS) && ( !found ) ; i++ )
      {
         if ( (CMcontexts[i].flag & CM_SLOT_USED) &&
              (CMcontexts[i].flag & CM_SHARABLE) &&
              (CMcontexts[i].lscreen_no == lscreen_no) &&
              (CMcontexts[i].color_objid == color_objid) )
         {
          /* Compare the accessed context information with the information */
          /* passed into the function.  */

            status = WLget_context_info( CMcontexts[i].context_no, &lcontext );
            if( status != WL_SUCCESS )
            {
               CM_REPORT_ERROR( CM_SYSTEM_ERROR );
               return( CM_SYSTEM_ERROR );
            }
            status = WLget_native_info_from_context( lscreen_no, 
                                                     CMcontexts[i].context_no,
                                                     &ctx_native_info );
            if( status != WL_SUCCESS )
            {
               CM_REPORT_ERROR( CM_SYSTEM_ERROR );
               return( CM_SYSTEM_ERROR );
            }
            if( ( lcontext.base_cmap_type == context->base_cmap_type ) &&
                ( lcontext.base_depth == context->base_depth ) &&
                ( lcontext.hilite_used == context->hilite_used ) &&
                ( lcontext.flags == context->flags ) &&
#if defined( X11 )
                ( ctx_native_info.colormap == native_info->colormap ) && 
                ( ctx_native_info.visual == native_info->visual )
#elif defined( ENV5 )
                ( ctx_native_info.vlt_no == native_info->vlt_no ) 
#elif defined( WIN32 )
                ( ctx_native_info.palette == native_info->palette ) 
#endif
                )
            {
               found = TRUE;
               *context_no = CMcontexts[i].context_no;
               return( CM_SUCCESS );
            }
         }
      }
   }
      

   if( !found )
   {
      if ( color_objid != NULL_OBJID )
      {
         /* Use the default routines if the color object does not return them */

         cmap_init = IGEcmap_init;
         cmap_color_to_rgb = IGEcmap_color_to_rgb;
         cmap_color_to_index = IGEcmap_color_to_index; 

         status = om$send( msg = message IGEcolor2.get_color_functions( context,
                                                           &cmap_color_to_index,
                                                           &cmap_color_to_rgb,
                                                           &cmap_init ),
                        targetid = color_objid,
                        senderid = NULL );

   
      }
      else  
      {
         /* Use the default values                                           */

         cmap_init = IGEcmap_init;
         cmap_color_to_rgb = IGEcmap_color_to_rgb;
         cmap_color_to_index = IGEcmap_color_to_index;
      }
     /*  Call WLcreate_context. */
      /* Use the default routines if the color object does not return them */
      if ( !cmap_init )
      {
         cmap_init = IGEcmap_init;
      }
      if ( !cmap_color_to_rgb )
      {
         cmap_color_to_rgb = IGEcmap_color_to_rgb;
      }
      if ( !cmap_color_to_index )
      {
         cmap_color_to_index = IGEcmap_color_to_index; 
      }
      status = WLcreate_context_native_info( lscreen_no, context, 
                                             cmap_color_to_index,
                                             cmap_color_to_rgb, cmap_init,
                                             native_info,
                                             context_no );
      if( status != WL_SUCCESS )
      {
         CM_REPORT_ERROR( CM_SYSTEM_ERROR );
         return( CM_SYSTEM_ERROR );
      }

    /*   Add an entry in the CMcontexts array. */

      for( i=0; ( i<CM_MAX_CONTEXTS) && ( !found ) ; i++ )
      {
        /* look for a slot that is not used and fill it  */
         if( !( CMcontexts[i].flag & CM_SLOT_USED ) )
         {
            CMcontexts[i].color_objid = color_objid;
            CMcontexts[i].context_no = *context_no;
            CMcontexts[i].flag = CM_SLOT_USED;
            break ;
         }
      }
   }
   status = CMinitialize_context( *context_no );

   return( CM_SUCCESS );
 
} /* CMcreate_context_native_info */
    
     
/*--- CMsetup_contexts-------------------------------------------*/

int CMsetup_contexts(
   int db,
   int ctx_type,
   int ctx_depth,
   int hilite )

/*
NAME
	CMsetup_contexts
 
KEYWORD
	CM
 
DESCRIPTION
	This function sets up the contexts for EXNUC based on double buffering,
         context type, depth and whether hilite is used or not.

SYNOPSIS
	int CMsetup_contexts(
           int db,
           int ctx_type,
           int ctx_depth,
           int hilite )
 
PARAMETERS
        db (IN) - Double buffer or not
        ctx_type (IN) - Context type
        ctx_depth (IN) - Context depth
        hilite (IN) - Hilite used or not

GLOBALS USED
	not yet
 
RETURN VALUES
 
HISTORY
	07/17/93 Shridar Subramanian
		Initial definition, design and implementation
*/

{
   int count;
   int required_priority = 0;
   int db_yes, db_no, hl_yes, hl_no, ix, tc;
   int cm_ctx_type;
   int priority[200];
   int distance;
   int selected_index;
   WLuint32 ctx_num;
   WLuint16 *lscreens;
   int      i,j;
   int      status;
   struct WLcontext_info *ctx_info; 
   int      num_screens;
   int      defined = 0;
   int      env_var = 0;
   char     *err_sts;

   lscreens = NULL;
   ctx_info = NULL;
   if ( ( db != WL_UNDEFINED_VALUE ) || ( ctx_type != WL_UNDEFINED_VALUE ) ||
        ( ctx_depth != WL_UNDEFINED_VALUE ) )
   {
      defined = 1;
   }

   /* Check if configuration needs to be reported           */

   err_sts = getenv("CM_REPORT_CONFIG");
   if (err_sts)
   {
      sscanf(err_sts,"%d",&env_var);
   }

   /* set ramp mode; needs to be after enter tools  */
   /* because of default for 3260 machine different */
   IGEset_ramp_mode_getenv();

   if ( db == WL_UNDEFINED_VALUE )
   {
      db = default_db_used;
   }
   if ( ctx_type == WL_UNDEFINED_VALUE )
   {
      ctx_type = default_ctx_type;
   }
   if ( ctx_depth == WL_UNDEFINED_VALUE )
   {
      ctx_depth = default_ctx_depth;
   }
   if ( hilite == WL_UNDEFINED_VALUE )
   {
      hilite = default_hilite_used;
   }
   if ( db )
   {
      db_yes = CM_DB_PRIORITY_1;
      db_no  = CM_DB_PRIORITY_2;
      required_priority |= db_yes;
   }
   else
   {
      db_yes = CM_DB_PRIORITY_2;
      db_no  = CM_DB_PRIORITY_1;
      required_priority |= db_no;
   }

   if ( ctx_type == WL_CMAP_TRUE_COLOR )
   {
      tc = CM_CL_PRIORITY_1;
      ix = CM_CL_PRIORITY_2;
      required_priority |= tc;
      cm_ctx_type = WL_CMAP_TRUE_COLOR;
   }
   else
   {
      tc = CM_CL_PRIORITY_2;
      ix = CM_CL_PRIORITY_1;
      required_priority |= ix;
      cm_ctx_type = WL_CMAP_INDEXED;
   }
      
   if ( hilite )
   {
      hl_yes = CM_HL_PRIORITY_1;
      hl_no  = CM_HL_PRIORITY_2;
      required_priority |= hl_yes;
   }
   else
   {
      hl_yes = CM_HL_PRIORITY_2;
      hl_no  = CM_HL_PRIORITY_1;
      required_priority |= hl_no;
   }
   required_priority += ctx_depth;

   /* Requires read_write context */
   required_priority += 1;

   status = WLget_number_of_screens ( &num_screens, &lscreens );
   if (status != WL_SUCCESS)
   {
      return (OM_E_ERROR);
   }

   for (j=0; j < num_screens; ++j)
   {
  
      /* Get all possible contexts */ 
      status = WLget_screen_contexts ( lscreens[j], 0, 0,
                                       &count, &ctx_info );
      if (status != WL_SUCCESS)
      {
         return ( CM_SYSTEM_ERROR );
      }
      for ( i = 0; i < count ; i++)
      {
         priority[i] = 0;
         if ( ctx_info[i].flags & WL_DOUBLE_BUFFER_ABILITY )
         {
            priority[i] |= db_yes;
         }
         else
         {
            priority[i] |= db_no;
         }
         if ( ctx_info[i].hilite_used )
         {
            priority[i] |= hl_yes;
         }
         else
         {
            priority[i] |= hl_no;
         }

         if ( !( ctx_info[i].flags & WL_COLORMAP_READ_ONLY ) )
         {
            priority[i] += 1;
         }

         priority[i] += ctx_info[i].base_depth;

         if ( ctx_info[i].base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
            if ( ctx_info[i].base_depth < 12 )
            {
               /* Do not allow true color contexts < 12 */
               priority[i] = 0;
            }
            else
            {
               priority[i] |= tc;
            }
         }
         else
         {
            if ( ctx_info[i].base_depth >= 12 )
            {
               priority[i] = 0;
            }
            else
            {
               priority[i] |= ix;
            }
         }
      }   
      distance = INT_MAX;
      selected_index = -1;
      for ( i = 0; i < count; i++)
      {
         if ( ( abs( priority[i] - required_priority) ) < distance )
         {
            selected_index = i;
            distance = abs( priority[i] - required_priority);
         }
      }
      
      if ( ( selected_index == count )  || ( selected_index == -1 ))
      {
         printf("Error could not find an appropriate context \n" );
         return( CM_SYSTEM_ERROR );
      }
      
      if ( env_var || ( ( distance ) && ( defined ) ) ) 
      {
         printf("Using the following configuration for screen %d\n", j);
         if ( ctx_info[selected_index].flags & WL_DOUBLE_BUFFER_ABILITY )
         { 
            printf("Double buffer:	true \n" ); 
         }
         else
         {
            printf("Double buffer:	false \n" ); 
         }
         if ( ctx_info[selected_index].base_cmap_type == WL_CMAP_INDEXED )
         {
            printf("window_type :	indexed \n"); 
         }
         else
         {
            printf("window_type :	truecolor \n"); 
         }
         printf("window_depth:	%d\n",ctx_info[selected_index].base_depth );
      }
      status = CMcreate_context ( NULL_OBJID, lscreens[j], 
                                  &ctx_info[selected_index], 1, &ctx_num );
      if ( status != CM_SUCCESS )
      {
         return ( status );
      }

      /*=========================================================*/
      /*  if this is the active screen - set the active context  */
      /*=========================================================*/

      status = CMset_active_context ( lscreens[j], ctx_num );
      if ( status != CM_SUCCESS )
      {
         return ( status );
      }

      /* Create contexts for forms */
      if ( ctx_info[selected_index].base_cmap_type != WL_CMAP_INDEXED )
      {
         status = WLget_screen_contexts ( lscreens[j], WL_CMAP_INDEXED, 0,
                                          &count, &ctx_info );
         if (status != WL_SUCCESS)
         {
            return ( CM_SYSTEM_ERROR );
         }
         for ( i =0; i < count; i++ )
         {
            if ( ( ctx_info[i].base_depth > 4 ) && 
                 ( !( ctx_info[i].flags & WL_COLORMAP_READ_ONLY ) ) ) 
            {
               break;
            }
         }
         if ( i == count )
         {
            return( CM_SYSTEM_ERROR );
         }
         status = CMcreate_context ( NULL_OBJID, lscreens[j], 
                                     &ctx_info[i], 1, &ctx_num );
         if ( status != CM_SUCCESS )
         {
            return ( status );
         }

      }
      status = CMset_exnuc_forms_context ( lscreens[j], ctx_num );
      if ( status != CM_SUCCESS )
      {
         return ( status );
      }
   }   
   if ( lscreens )
   {
      free( lscreens );
   }
   if ( ctx_info )
   {
      free( ctx_info );
   }

   return( CM_SUCCESS );
 
} /* CMsetup_contexts */
    
end implementation Root;
