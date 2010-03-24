#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

extern int WLIdefault_vlt_no[WL_MAX_SCREENS];

#define XGL_OPAQUE_INDEX	0
#define XGL_TRANSPARENT_INDEX	0

#define WLI_MAX_ALLOC_ENTRIES  512

/* This macro determines the size of the cmap based on the the cmap type and */
/* the context depth.                                                        */
/* Parameters                                                                */
/*       struct WLIcontext ctx_ptr;                                          */
/*       int               offset;                                           */
/*       int               base_cmap_size;                                   */

#define WLI_GET_BASE_CMAP_SIZE( ctx_ptr, offset, base_cmap_size )           \
                                                                            \
     {                                                                      \
         if ( ctx_ptr[offset].base_cmap_type == WL_CMAP_TRUE_COLOR )        \
         {                                                                  \
            base_cmap_size = ( 1 << ( ctx_ptr[offset].base_depth / 3 ) );   \
         }                                                                  \
	 else                                                               \
	 {                                                                  \
            base_cmap_size = ( 1 << ( ctx_ptr[offset].base_depth ) );       \
         }                                                                  \
     }                                     
 
/*--- WLIcontext_add_entry--------------------------------------------*/

int WLIcontext_add_entry(
   WLuint16 lscreen_no,
   struct WLnative_info *native_info,
   int     (*cmap_color_to_index)(),
   int     (*cmap_color_to_rgb)(),
   int     (*cmap_init)(),
   struct WLcontext_info *context_info,
   WLuint32 *context_no,
   int created_flag)  
/*
NAME
	WLIcontext_add_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function adds context entry and initializes the values
 
PARAMETERS
	lscreen_no (IN) - logical screen number
	context_info (IN) - The context information
	context_no (OUT) - context  number
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_ERROR
                Failed to add an entry in the context_str array
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
        12/02/93 Joel Underwood
                added transparent index initialization.  It is the 
                index of highlight visual that is transparent.
*/
{
   int found, i, k;
   int size_of_cmap, size_of_rgb;
   WLuint8 group_index;
   WLuint8 offset;
   struct WLIcontext_group *pcontext_arr;
   struct WLIcontext *temp_ptr;
   int hilite_depth;
#if defined( X11 )
   XVisualInfo *vinfo, vinfo_template;
   int nitems;
   int shift_count;
#endif


   /* Search for an empty entry to add a context */
   
   temp_ptr = NULL; 
   group_index = 0;
   offset = 0;
   pcontext_arr = WLIscreens_arr[lscreen_no].pcontext;
   found = WLI_FALSE;
   for ( i=0; i < WLI_MAX_CONTEXT_GROUPS && !found; i++)
   {
      if ( pcontext_arr[i].num_entries_used < WLI_MAX_CONTEXTS_PER_GROUP &&
           pcontext_arr[i].pcontext_group != NULL )
      {
         temp_ptr = pcontext_arr[i].pcontext_group;
         group_index = i;
         found = WLI_TRUE;
      }
   }

   /* If an empty entry is not found, allocate an entry               */

   if ( !found )
   {
       for ( i=0; i < WLI_MAX_CONTEXT_GROUPS && !found; i++)
       {       
         if ( !pcontext_arr[i].pcontext_group )
         {               
            pcontext_arr[i].pcontext_group = ( struct WLIcontext * ) 
                                           malloc( WLI_MAX_CONTEXTS_PER_GROUP * 
                                           sizeof( struct WLIcontext ) );
           
            /* Initialize the values in the allocated entries        */

            pcontext_arr[i].num_entries_used = 0;
            for (k = 0; k < WLI_MAX_CONTEXTS_PER_GROUP; k++)
            {
                pcontext_arr[i].pcontext_group[k].used = WLI_FALSE;
            }
            temp_ptr = pcontext_arr[i].pcontext_group;
            group_index = i;     
            found = WLI_TRUE;   
         }       
       }
   }
  
   /* If cannot allocate an entry, return error                      */

   if ( !found )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   found = WLI_FALSE;
   for ( i=0; i < WLI_MAX_CONTEXTS_PER_GROUP && !found; i++ )
   {
      if ( temp_ptr[i].used == WLI_FALSE )
      {
         offset = i;
         found = WLI_TRUE;
      }
   }

   if ( !found )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   pcontext_arr[group_index].num_entries_used++;
 
   *context_no = WLIcontext_pack( lscreen_no, group_index, offset );

   temp_ptr[offset].used = WLI_TRUE;
   temp_ptr[offset].lscreen_no = lscreen_no;

   temp_ptr[offset].base_cmap_type = context_info->base_cmap_type;
   temp_ptr[offset].base_depth = context_info->base_depth;
   temp_ptr[offset].hilite_depth = 0;
   temp_ptr[offset].hilite_used = context_info->hilite_used;
   temp_ptr[offset].flags = context_info->flags;
   if ( context_info->hilite_used )
   {
      hilite_depth = 1;
   }
   else
   {
      hilite_depth = 0;
   }
   if ( context_info->base_cmap_type == WL_CMAP_INDEXED )
   {
      size_of_cmap = 1 << ( context_info->base_depth + hilite_depth);
   }
   else
   {
      size_of_rgb =  context_info->base_depth / 3; 
      size_of_cmap = 1 << (size_of_rgb  + hilite_depth); 
   }
   temp_ptr[offset].local_colormap = (struct WLcmap_entry *) malloc(
                                               size_of_cmap * 
                                               sizeof( struct WLcmap_entry ) );
 
   temp_ptr[offset].ref_ct = 0;
   temp_ptr[offset].cmap_color_to_index= cmap_color_to_index;
   temp_ptr[offset].cmap_color_to_rgb= cmap_color_to_rgb;
   temp_ptr[offset].cmap_init= cmap_init;
   temp_ptr[offset].created = created_flag;
   temp_ptr[offset].cmap_active = WLI_FALSE;
   

#if defined( X11 )


   temp_ptr[offset].native_info.EXcolormap = native_info->colormap; 
   temp_ptr[offset].native_info.visual = native_info->visual; 
#if defined( XGL )
   temp_ptr[offset].native_info.xgl_base_cmap = native_info->xgl_base_cmap; 
#endif
   if ( context_info->base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      
      vinfo_template.visualid = XVisualIDFromVisual( native_info->visual );
      vinfo = XGetVisualInfo( native_info->display, VisualIDMask, 
                              &vinfo_template, &nitems );
      if ( context_info->base_depth == 12 )
      {
         if ( nitems )
         {
            shift_count = 0;
            while ( !( vinfo[0].red_mask & 1 ) )
            {
               vinfo[0].red_mask = vinfo[0].red_mask >> 1;
               shift_count++;
            }
            temp_ptr[offset].red_shifter = shift_count;

            shift_count = 0;
            while ( !( vinfo[0].green_mask & 1 ) )
            {
               vinfo[0].green_mask = vinfo[0].green_mask >> 1;
               shift_count++;
            }
            temp_ptr[offset].green_shifter = shift_count;

            shift_count = 0;
            while ( !( vinfo[0].blue_mask & 1 ) )
            {
               vinfo[0].blue_mask = vinfo[0].blue_mask >> 1;
               shift_count++;
            }
            temp_ptr[offset].blue_shifter = shift_count;
            
            
         }
         else
         {
            temp_ptr[offset].red_shifter = 0;
            temp_ptr[offset].green_shifter = 4;
            temp_ptr[offset].blue_shifter = 8;
         }
         temp_ptr[offset].right_shifter = 12;
      }
      else
      {
         if ( nitems )
         {
            shift_count = 0;
            while ( !( vinfo[0].red_mask & 1 ) )
            {
               vinfo[0].red_mask = vinfo[0].red_mask >> 1;
               shift_count++;
            }
            temp_ptr[offset].red_shifter = shift_count;

            shift_count = 0;
            while ( !( vinfo[0].green_mask & 1 ) )
            {
               vinfo[0].green_mask = vinfo[0].green_mask >> 1;
               shift_count++;
            }
            temp_ptr[offset].green_shifter = shift_count;

            shift_count = 0;
            while ( !( vinfo[0].blue_mask & 1 ) )
            {
               vinfo[0].blue_mask = vinfo[0].blue_mask >> 1;
               shift_count++;
            }
            temp_ptr[offset].blue_shifter = shift_count;
            
         }
         else
         {
            temp_ptr[offset].red_shifter = 0;
            temp_ptr[offset].green_shifter = 8;
            temp_ptr[offset].blue_shifter = 16;
         }
         temp_ptr[offset].right_shifter = 8;
      }
   }
   else
   {
      temp_ptr[offset].red_shifter = 0;
      temp_ptr[offset].green_shifter = 0;
      temp_ptr[offset].blue_shifter = 0;
      temp_ptr[offset].right_shifter = 0;
   }
 
   temp_ptr[offset].base_mask = (1 << context_info->base_depth) - 1;
   if ( context_info->flags & WL_SEPARATE_HILITE )
   {
      temp_ptr[offset].hl_native_info.hl_colormap = native_info->hl_colormap; 
      temp_ptr[offset].hl_native_info.hl_visual = native_info->hl_visual; 
#if defined( XGL )
      temp_ptr[offset].native_info.xgl_hilite_cmap = native_info->xgl_hilite_cmap; 
#endif
      vinfo_template.visualid = XVisualIDFromVisual( native_info->hl_visual );
      vinfo = XGetVisualInfo( native_info->display, VisualIDMask, 
                              &vinfo_template, &nitems );
      if ( nitems > 0 )
      {
         temp_ptr[offset].hilite_depth = vinfo[0].depth;
      }

      temp_ptr[offset].hilite_mask = (1 << temp_ptr[offset].hilite_depth) - 1;
      temp_ptr[offset].hl_native_info.transparent_index = 
         WLI_UNDEFINED_TRANSPARENT_INDEX;
   }
   else
   {
      if ( context_info->hilite_used )
      {
         temp_ptr[offset].hilite_mask = 1 << context_info->base_depth;
      }
      else
      {
         temp_ptr[offset].hilite_mask = 0;
      }
   }
   
#elif defined( ENV5 )

   temp_ptr[offset].native_info.vlt_no = native_info->vlt_no; 
   if ( temp_ptr[offset].native_info.vlt_no == -1 )
   {
      temp_ptr[offset].cmap_active = WLI_TRUE;
   }
   
   if ( context_info->base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      temp_ptr[offset].base_mask = 0xFFFFFF;
      temp_ptr[offset].red_shifter = 0;
      temp_ptr[offset].green_shifter = 8;
      temp_ptr[offset].blue_shifter = 16;
      temp_ptr[offset].right_shifter = 8;

   }
   else
   {
      temp_ptr[offset].base_mask = (1 << context_info->base_depth) - 1;
      temp_ptr[offset].red_shifter = 0;
      temp_ptr[offset].green_shifter = 0;
      temp_ptr[offset].blue_shifter = 0;
      temp_ptr[offset].right_shifter = 0;

   }

   if ( WLIscreens_arr[lscreen_no].native_info.env5_vsi_flags & VSI_HL )
   {
      temp_ptr[offset].hilite_mask = 0x1;
   }
   else
   {
      if ( context_info->hilite_used )
      {
         temp_ptr[offset].hilite_mask = 1 << context_info->base_depth;
      }
      else
      {
         temp_ptr[offset].hilite_mask = 0;
      }
   }

#elif defined( WIN32 )

   temp_ptr[offset].native_info.palette = native_info->palette; 
   temp_ptr[offset].base_mask = (1 << context_info->base_depth) - 1;
   temp_ptr[offset].hilite_mask = 0;

#else
#error "A Windowing system must be defined"
#endif

   (*cmap_init)( *context_no );

   return( WL_SUCCESS );

} /* WLIcontext_add_entry */

/*--- WLIcontext_retrieve_entry--------------------------------------------*/

int WLIcontext_retrieve_entry(
   WLuint32 context_no,
   struct WLIcontext *context_struct)
/*
NAME
	WLIcontext_retrieve_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function retrieves a context entry
 
PARAMETERS
	context_no (IN) - logical context number
	context_struct (IN) - the WLIcontext structure

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_BAD_CONTEXT
                The context number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIcontext  *temp_ptr;

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset);
   if ( WLIcontext_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }
   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   memcpy( (char * ) context_struct, ( const char * )&temp_ptr[offset], 
           sizeof( struct WLIcontext ) );
   return( WL_SUCCESS );

} /* WLIcontext_retrieve_entry */

/*--- WLIcontext_retrieve_entry_ptr --------------------------------------------*/

int WLIcontext_retrieve_entry_ptr(
   WLuint32 context_no,
   struct WLIcontext **context_struct)
/*
NAME
	WLIcontext_retrieve_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function retrieves a pointer to a context entry
 
PARAMETERS
	context_no (IN) - logical context number
	context_struct (IN) - the pointer to a WLIcontext structure

NOTES
	This function should be used sparingly and with caution
	because it returns a pointer to the internal window
	structure maintained by WL.

GLOBALS USED
        none
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_BAD_CONTEXT
                The context number is invalid
 
	WL_BAD_PARAMETER
		The 'context_struct' pointer is NULL.

HISTORY
        12/22/92 S.P. Rogers
                Initial definition and implementation
*/

{
   WLuint16 lscreen_no;
   WLuint8 group_index;
   WLuint8 offset;
   struct WLIcontext *ctx_group_ptr;

   if ( ! context_struct )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );
   if ( WLIcontext_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   ctx_group_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   *context_struct = &ctx_group_ptr[offset];

   return( WL_SUCCESS );

} /* WLIcontext_retrieve_entry_ptr */

/*--- WLIcontext_delete_entry--------------------------------------------*/

int WLIcontext_delete_entry(
   WLuint32 context_no)
/*
NAME
	WLIcontext_delete_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function deletes a context
 
PARAMETERS
	context_no (IN) - context number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_ERROR
                Failed to delete an entry 
 
        WL_BAD_CONTEXT
                The context number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIcontext  *temp_ptr;
#if defined( X11 )
   int  sts;
   struct WLIscreen   screen_struct;
#endif

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );
   if ( WLIcontext_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   /* We delete the context only if no windows are using it                  */

   if ( temp_ptr[offset].ref_ct > 0 )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   temp_ptr[offset].used = 0;

   if ( temp_ptr[offset].local_colormap )
   {
      WLI_FREE( temp_ptr[offset].local_colormap );
   }
   if ( temp_ptr[offset].created )
   {
#if defined( X11 )
      sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
      XFreeColormap( screen_struct.native_info.EXdisplay, 
                     temp_ptr[offset].native_info.EXcolormap);

      /* If seperate highlight plane is present then free its colormap */

      if ( temp_ptr[offset].flags & WL_SEPARATE_HILITE )
      {
         XFreeColormap( screen_struct.native_info.EXdisplay, 
                        temp_ptr[offset].hl_native_info.hl_colormap);
      }
      
#endif
   }
   return( WL_SUCCESS );
} /*  WLIcontext_delete_entry */

/*--- WLIcontext_inc_ref_ct--------------------------------------------*/

int WLIcontext_inc_ref_ct(
   WLuint32 context_no)
/*
NAME
	WLIcontext_inc_ref_ct
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function increments the reference count of a context
 
PARAMETERS
	context_no (IN) - context number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_BAD_CONTEXT
                The context number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIcontext  *temp_ptr;

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset);
   if ( WLIcontext_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }
   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   temp_ptr[offset].ref_ct++;

   return( WL_SUCCESS );
} /* WLIcontext_inc_ref_ct */

/*--- WLIcontext_dec_ref_ct--------------------------------------------*/

int WLIcontext_dec_ref_ct(
   WLuint32 context_no)
/*
NAME
	WLIcontext_dec_ref_ct
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function decrements the reference count of a context
 
PARAMETERS
	context_no (IN) - context number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_BAD_CONTEXT
                The context number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIcontext  *temp_ptr;

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset);

   if ( WLIcontext_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   temp_ptr[offset].ref_ct--;

   return( WL_SUCCESS );
} /*  WLIcontext_dec_ref_ct */

/*--- WLIcontext_pack--------------------------------------------*/

WLuint32 WLIcontext_pack(
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset)	
/*
NAME
	WLIcontext_pack
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function  creates a context number by packing
 
PARAMETERS
	lscreen_no (IN) - The logical screen number
	group_index (IN) - The group index
	offset (IN) - The offset

GLOBALS USED
        not yet
 
RETURN VALUES
	The packed number
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int   x = 0,y = 0;

   x = lscreen_no << 16;
   y = group_index << 8;	
   return( x | y | offset );

} /* WLIcontext_pack */

/*--- WLIcontext_unpack--------------------------------------------*/

int WLIcontext_unpack(
   WLuint32  lcontext_no,
   WLuint16 *lscreen_no,
   WLuint8  *group_index,
   WLuint8  *offset)	
/*
NAME
	WLIcontext_unpack
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function unpacks  a context number
 
PARAMETERS
	lcontext_no (IN) - The logical window number;
	lscreen_no (OUT) - The logical screen number
	group_index (OUT) - The group index
	offset (OUT) - The offset

GLOBALS USED
        not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   if ( lscreen_no )
   {
      *lscreen_no = ( lcontext_no >> 16 ) & 0xffff;
   }
   if ( group_index )
   {
      *group_index = ( lcontext_no >> 8 ) & 0xff;
   }
   if ( offset )
   {
      *offset = lcontext_no & 0xff;
   }
   return( WL_SUCCESS );

} /*  WLIcontext_unpack */

/*--- WLIcontext_validate--------------------------------------------*/

int WLIcontext_validate(
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset)	
/*
NAME
	WLIcontext_validate
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function validates a context 
 
PARAMETERS
	lscreen_no (IN) - The logical screen number
	group_index (IN) - The group index
	offset (IN) - The offset

GLOBALS USED
        not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_ERROR
		Failure
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int   sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if ( group_index >= WLI_MAX_CONTEXT_GROUPS ||
        offset >= WLI_MAX_CONTEXTS_PER_GROUP )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   if ( !WLIscreens_arr[lscreen_no].pcontext )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   if ( !WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   if ( !WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group[offset].used)
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   return( WL_SUCCESS );

} /*  WLIcontext_validate */

/*--- WLIcontext_fill_pseudo_vlt ---------------------------------------------*/

#if defined ( ENV5 )
int WLIcontext_fill_pseudo_vlt(
   struct vlt_slot *base_color,
   int base_count,
   struct vlt_slot *pseudo_vlt,
   int *pseudo_count )
/*
NAME
	WLIcontext_fill_pseudo_vlt
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function loads the pseudo true color vlt as required by ENV5
 
PARAMETERS
        base_color (IN) -  The colors to be replicated in the pseudo_vlt array
        base_count (IN) - The number of colors in the base_color array
        pseudo_vlt (OUT) - The vlt_slot array to be filled
        pseudo_count (OUT) - The number of pseudo color entries.

GLOBALS USED
        not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_ERROR
		Failure
 
HISTORY
        06/24/93 Shridar Subramanian
                Initial definition and implementation
*/
{
   int i, j;
   
   *pseudo_count = 0;
   for ( i = 0; i < base_count; i++ )
   {
      for ( j = 0; j < 16; j++ )
      {
         pseudo_vlt[*pseudo_count] = base_color[i];
         pseudo_vlt[*pseudo_count].v_slot = *pseudo_count;
         (*pseudo_count)++;
      }
   }

   return( WL_SUCCESS );

} /* WLIcontext_fill_pseudo_vlt */
#endif
    
/*--- WLIcontext_load_cmap_entries--------------------------------------------*/

int WLIcontext_load_cmap_entries(
   WLuint32            context_no,
   int                 num_entries,
   struct WLcmap_entry *cmap_entries )

/*
NAME
   WLIcontext_load_cmap_entries
 
KEYWORD
   WL (INTERNAL)
 
DESCRIPTION
   This function loads the colormap entries
 
PARAMETERS
   context_no (IN) - context number
   num_entries (IN) - number of entries to be loaded
   cmap_entries (IN) - array of color map entries to load

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success

   WL_ERROR
      Failure

   WL_READ_ONLY
      Read only colormap
 
HISTORY
   10/19/92 Shridar Subramanian
      Initial definition

   12/02/93 Joel Underwood
      added transparent index.  It is the 
      index of highlight visual that is transparent.  The
      index is initialized once when alloced, we always
      load in entries besides this one.

*/

   {
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   int        sts, i, j = 0;
   WLuint32   forms_context_no;

   struct WLIcontext   *temp_ptr;
   struct WLIscreen    screen_struct;

#  if defined( ENV5 )
   int        base_count, hilite_count, base_cmap_size; 
   struct rgb_color    hilite_color;
   struct vlt_slot     *base_color, *temp_entries;
   struct vlt_slot     entries_arr[WLI_MAX_ALLOC_ENTRIES];
   struct vlt_slot     pseudo_vlt[256];
   int        pseudo_count, pseudo_cmap = 0;
   int        vlt_type;
#elif defined( X11 )
   XColor              *color_def;
   XColor              *base_color, *hilite_color;
   int                 base_count, hilite_count, base_cmap_size;
   unsigned long       pixels[256], plane_masks[4];
   int                 num_pixels, ii;
#if defined( XGL )
   Xgl_color_list      xgl_color_list;
   Xgl_color_list      hl_xgl_color_list;
   struct WLcmap_entry forms_cmap[32];
#endif
#elif defined( WIN32 )
   PALETTEENTRY        *lppe; 
#else
#error " A windowing system must be defined"
#endif
   
   sts = WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   
   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;
   if ( ( temp_ptr[offset].flags & WL_COLORMAP_READ_ONLY ) &&
       !(temp_ptr[offset].flags & WL_SEPARATE_HILITE ) )
   {
       WL_REPORT_ERROR( WL_READ_ONLY );
       return( WL_READ_ONLY );
   }
   /* Copy the color information into the local colormap               */

   /*------------------------------------------------------------------------
    *
    *   For XGL, I don't care if the colormap is read only, I want to copy
    *   the given colormap into the local colormap anyway.  XGL ignores 
    *   this stuff so it won't matter anyway.  Besides I need this for display
    *   image. (Mike 1/11/96)
    */

#  if ! defined (XGL)
   if( !( temp_ptr[offset].flags & WL_COLORMAP_READ_ONLY ) )
#  endif
   {
      for ( i = 0; i < num_entries; i++)
      {
          /* Colors are ordered by their slot numbers                     */

          temp_ptr[offset].local_colormap[cmap_entries[i].slot].slot = 
                                                         cmap_entries[i].slot;
          temp_ptr[offset].local_colormap[cmap_entries[i].slot].red = 
                                                         cmap_entries[i].red;
          temp_ptr[offset].local_colormap[cmap_entries[i].slot].green = 
                                                         cmap_entries[i].green;
          temp_ptr[offset].local_colormap[cmap_entries[i].slot].blue = 
                                                         cmap_entries[i].blue;
          temp_ptr[offset].local_colormap[cmap_entries[i].slot].flags = 
                                                         cmap_entries[i].flags;
      }
   }

   
#if defined( ENV5 )

   /* The vlt_no will be -1 in cases where the hardware can have only one */
   /* vlt  eg: 2000, EdgeI rop etc                                        */

   hilite_count = 0;
   base_count = 0;
   base_color = NULL;
   if ( temp_ptr[offset].native_info.vlt_no != -1 )
   {
      sts = Inq_vlt_type( temp_ptr[offset].native_info.vlt_no, &vlt_type );
      if ( vlt_type == PSEUDO_TRUE_COLOR_VLT )
      {
         pseudo_cmap = 1;
      }
      if ( temp_ptr[offset].hilite_used )
      {
         if ( screen_struct.native_info.env5_vsi_flags & VSI_HL )
         {
             /* Separate the hilight colors from the base colors */
           
	     WLI_GET_BASE_CMAP_SIZE( temp_ptr, offset, base_cmap_size );

             base_color = ( struct vlt_slot * ) 
                                      malloc( sizeof( struct vlt_slot ) *
                                              num_entries );
             hilite_count = 0;
             base_count = 0;
             for (j = 0; j < num_entries; j++)
             {
                if ( cmap_entries[j].slot > (WLuint16 )( base_cmap_size - 1 ) )
                {
                    if ( ! hilite_count )
                    {
                       hilite_color.red = cmap_entries[j].red;
                       hilite_color.green = cmap_entries[j].green;
                       hilite_color.blue = cmap_entries[j].blue;
                    }
                    hilite_count++;
                }
                else
                {
                    base_color[base_count].v_slot = cmap_entries[j].slot;
                    base_color[base_count].v_red = cmap_entries[j].red;
                    base_color[base_count].v_green = cmap_entries[j].green;
                    base_color[base_count].v_blue = cmap_entries[j].blue;
                    base_count++;
                }
             }

             if ( pseudo_cmap )
             {
                WLIcontext_fill_pseudo_vlt( base_color, base_count, pseudo_vlt,
                                            &pseudo_count );
                if ( base_color )
                {
                   WLfree( base_color );
                }
                base_color = pseudo_vlt;
                base_count = pseudo_count;
             }
             /* Load the base colors and hilite colors              */

             if ( hilite_count )
             {

                 /* Set the hilite color only once                  */

                 sts = LoadHL( screen_struct.native_info.screen_no, 
                               &hilite_color );
                 if ( sts != 0 )
                 {
                     WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                     return( WL_SYSTEM_ERROR );
                 }
                
             }
             if ( base_count )
             {
                 if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                      (WLISRwin_no >= 0) )
                 {
                    sts = Load_SR_vlt( WLISRwin_no, base_color, base_count );
                 }    
                 else if ( temp_ptr[offset].native_info.vlt_no != screen_struct.native_info.vlt_no )
                 {
                    sts = Load_allocated_vlt( screen_struct.native_info.screen_no, 
                                              temp_ptr[offset].native_info.vlt_no, 
                                              base_color, base_count );
                 }
                 else
                 {
                    /* Default indexed vlt of the screen */
                    sts = Loadvlt( screen_struct.native_info.screen_no, 
                                   base_color, base_count );
                 }

                 if ( sts != 0 )
                 {
                      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                      return( WL_SYSTEM_ERROR );
                 }
             }
         }
         else /* if ( hilite plane available ) */
         {
             /* Avoid allocating memory, use arrays if num_entries is small */
             if ( num_entries > WLI_MAX_ALLOC_ENTRIES )
             {
                temp_entries = ( struct vlt_slot * ) 
                                         malloc( sizeof( struct vlt_slot ) *
                                                 num_entries );
             }
             else
             {
                temp_entries = entries_arr;
             }
             for ( i = 0 ; i < num_entries; i++ )
             {
                temp_entries[i].v_slot = cmap_entries[i].slot;
                temp_entries[i].v_red = cmap_entries[i].red;
                temp_entries[i].v_green = cmap_entries[i].green;
                temp_entries[i].v_blue = cmap_entries[i].blue;
             }
             if ( pseudo_cmap )
             {
                WLIcontext_fill_pseudo_vlt( temp_entries, num_entries, 
                                            pseudo_vlt, &pseudo_count );
                if ( temp_entries )
                {
                   WLfree( temp_entries );
                }
                temp_entries = pseudo_vlt;
                num_entries = pseudo_count;
             }


             if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                  (WLISRwin_no >= 0) )
             {
                sts = Load_SR_vlt( WLISRwin_no, temp_entries, num_entries );
             }
             else if ( temp_ptr[offset].native_info.vlt_no != 
                       screen_struct.native_info.vlt_no )
             {
                sts = Load_allocated_vlt( screen_struct.native_info.screen_no, 
                                          temp_ptr[offset].native_info.vlt_no, 
                                          temp_entries, num_entries );
             }
             else
             {
                /* Default indexed vlt */
                sts = Loadvlt( screen_struct.native_info.screen_no, 
                               temp_entries, num_entries );
             }

             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
         }
      }
      else /* if ( hilite used ) */
      {
          /* Allocate only if the space required is > WLI_MAX_ALLOC_ENTRIES */
          if ( num_entries > WLI_MAX_ALLOC_ENTRIES )
          {
             temp_entries = ( struct vlt_slot * ) 
                                      malloc( sizeof( struct vlt_slot ) *
                                              num_entries );
          }
          else
          {
             temp_entries = entries_arr;
          }

          for ( i = 0 ; i < num_entries; i++ )
          {
             temp_entries[i].v_slot = cmap_entries[i].slot;
             temp_entries[i].v_red = cmap_entries[i].red;
             temp_entries[i].v_green = cmap_entries[i].green;
             temp_entries[i].v_blue = cmap_entries[i].blue;
          }
          if ( pseudo_cmap )
          {
             WLIcontext_fill_pseudo_vlt( temp_entries, num_entries, 
                                         pseudo_vlt, &pseudo_count );
             if ( temp_entries )
             {
                WLfree( temp_entries );
             }
             temp_entries = pseudo_vlt;
             num_entries = pseudo_count;
          }

          if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                 (WLISRwin_no >= 0) )
          {
             sts = Load_SR_vlt( WLISRwin_no, temp_entries, num_entries );
          }
          else if ( temp_ptr[offset].native_info.vlt_no != 
                    screen_struct.native_info.vlt_no )
          {
             sts = Load_allocated_vlt( screen_struct.native_info.screen_no,
                                       temp_ptr[offset].native_info.vlt_no,
                                       temp_entries, num_entries );
          }
          else
          {
             /* Default indexed vlt */
             sts = Loadvlt( screen_struct.native_info.screen_no,
                            temp_entries, num_entries );
          }

          if ( sts != 0 )
          {
              WL_REPORT_ERROR( WL_SYSTEM_ERROR );
              return( WL_SYSTEM_ERROR );
          }
      }
   }
   else /* if ( vlt != -1 ) */
   {
      if ( temp_ptr[offset].cmap_active )
      {
         if ( temp_ptr[offset].hilite_used )
         {
            if ( screen_struct.native_info.env5_vsi_flags & VSI_HL )
            {
                /* Separate the hilight colors from the base colors */

	        WLI_GET_BASE_CMAP_SIZE( temp_ptr, offset, base_cmap_size );
                base_color = ( struct vlt_slot * ) 
                                      malloc( sizeof( struct vlt_slot ) *
                                              base_cmap_size );
                hilite_count = 0;
                base_count = 0;
                for (j = 0; j < num_entries; j++)
                {
                   if ( cmap_entries[j].slot > (WLuint16)( base_cmap_size - 1 ) )
                   {
                       if ( ! hilite_count )
                       {
                          hilite_color.red = cmap_entries[j].red;
                          hilite_color.green = cmap_entries[j].green;
                          hilite_color.blue = cmap_entries[j].blue;
                       }
                       hilite_count++;
                   }
                   else
                   {
                       base_color[base_count].v_slot = cmap_entries[j].slot;
                       base_color[base_count].v_red = cmap_entries[j].red;
                       base_color[base_count].v_green = cmap_entries[j].green;
                       base_color[base_count].v_blue = cmap_entries[j].blue;
                       base_count++;
                   }
                }

                /* Load the base colors and hilite colors              */

                if ( hilite_count )
                {
                    sts = LoadHL( screen_struct.native_info.screen_no, 
                                  &hilite_color );
                    if ( sts != 0 )
                    {
                        WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                        return( WL_SYSTEM_ERROR );
                    }
                }
                if ( base_count )
                {
                    if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE )&&
                         (WLISRwin_no >= 0) )
                    {
                       sts = Load_SR_vlt( WLISRwin_no, base_color, base_count );
                    }
                    else
                    {
                       sts = Loadvlt( screen_struct.native_info.screen_no, 
                                      base_color, base_count );
                    }
                    if ( sts != 0 )
                    {
                        WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                        return( WL_SYSTEM_ERROR );
                    }
                }
            }
            else /* if ( hilite plane available ) */
            {
                if ( num_entries > WLI_MAX_ALLOC_ENTRIES )
                {
                   temp_entries = ( struct vlt_slot * ) 
                                            malloc( sizeof( struct vlt_slot ) *
                                                    num_entries );
                }
                else
                {
                   temp_entries = entries_arr;
                }
                for ( i = 0 ; i < num_entries; i++ )
                {
                   temp_entries[i].v_slot = cmap_entries[i].slot;
                   temp_entries[i].v_red = cmap_entries[i].red;
                   temp_entries[i].v_green = cmap_entries[i].green;
                   temp_entries[i].v_blue = cmap_entries[i].blue;
                }
                if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                     (WLISRwin_no >= 0) )
                {
                   sts = Load_SR_vlt( WLISRwin_no, temp_entries, num_entries );
                }
                else
                {
                   sts = Loadvlt( screen_struct.native_info.screen_no, 
                                  temp_entries, num_entries );
                }
                if ( sts != 0 )
                {
                    WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                    return( WL_SYSTEM_ERROR );
                }
            }
         }
         else /* if ( hilite used ) */
         {
             /* Avoid allocating as far as possible                   */

             if ( num_entries > WLI_MAX_ALLOC_ENTRIES )
             {
                 temp_entries = ( struct vlt_slot * ) 
                                          malloc( sizeof( struct vlt_slot ) *
                                                  num_entries );
             }
             else
             {
                 temp_entries = entries_arr;
             }
             for ( i = 0 ; i < num_entries; i++ )
             {
                temp_entries[i].v_slot = cmap_entries[i].slot;
                temp_entries[i].v_red = cmap_entries[i].red;
                temp_entries[i].v_green = cmap_entries[i].green;
                temp_entries[i].v_blue = cmap_entries[i].blue;
             }
             if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                  (WLISRwin_no >= 0) )
             {
                sts = Load_SR_vlt( WLISRwin_no, temp_entries, num_entries );
             }
             else
             {
                sts = Loadvlt( screen_struct.native_info.screen_no,
                               temp_entries, num_entries );
             }
             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
         }
      }
   }

   if ( ( base_color ) && !( pseudo_cmap ) )
   {
      WLI_FREE( base_color );
   }

#  elif defined( X11 )
   {
   base_count = hilite_count = 0;
   base_color = NULL;
   hilite_color = NULL;
   color_def = NULL;

   if ( temp_ptr[offset].flags & WL_SEPARATE_HILITE )
      {
      WLI_GET_BASE_CMAP_SIZE( temp_ptr, offset, base_cmap_size );
      base_color = (XColor *) malloc( sizeof( XColor ) * num_entries );
      hilite_color = (XColor *) malloc( sizeof( XColor ) * num_entries );

      for (j = 0; j < num_entries; j++ )
         {
         if ( cmap_entries[j].slot > (WLuint16)( base_cmap_size - 1 ) )
            {
            if (  hilite_count < ( 1 << temp_ptr[offset].hilite_depth ) )
               {
               hilite_color[hilite_count].pixel = hilite_count;
               hilite_color[hilite_count].red = cmap_entries[j].red;
               hilite_color[hilite_count].green = cmap_entries[j].green;
               hilite_color[hilite_count].blue = cmap_entries[j].blue;
               hilite_color[hilite_count].flags = DoRed | DoGreen | DoBlue;
               }
            hilite_count++;
            }
         else
            {
            base_color[base_count].pixel = cmap_entries[j].slot;
            base_color[base_count].red = cmap_entries[j].red;
            base_color[base_count].green = cmap_entries[j].green;
            base_color[base_count].blue = cmap_entries[j].blue;
            base_color[base_count].flags = DoRed | DoGreen | DoBlue;
            base_count++;
            }
         }

#     if defined (XGL)
         {
      
         /*  For XGL, we're only worried about the first slot in the hilite  */
         /*  colormap.  The rest we want to be the same as the forms colormap */
         /*  this is so that we wont have a flicker when we move the cursor */
         /*  from a graphics window into a forms window and back.... */

         CMget_exnuc_forms_context( lscreen_no, &forms_context_no );
         
         for( i=0; i<31; i++ ) forms_cmap[i].slot = i+1;

         WLIcontext_read_cmap_entries( forms_context_no, 31, forms_cmap );

         for( i=0; i<31; i++ )
            {
            hilite_color[i+1].pixel = forms_cmap[i].slot;
            hilite_color[i+1].red   = forms_cmap[i].red;
            hilite_color[i+1].green = forms_cmap[i].green;
            hilite_color[i+1].blue  = forms_cmap[i].blue;
            hilite_color[i+1].flags = DoRed | DoGreen | DoBlue;
            }
         hilite_color[0].flags = DoRed | DoGreen | DoBlue;
         }
#     endif /* XGL */

      if ( temp_ptr[offset].base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
         if ( !( temp_ptr[offset].flags & WL_COLORMAP_READ_ONLY ) )
            {
            for ( ii = 0; ii < base_count; ii++ )
               {
               base_color[ii].pixel = ii;
               base_color[ii].flags = DoRed;
               }

            XStoreColors( screen_struct.native_info.EXdisplay, 
                          temp_ptr[offset].native_info.EXcolormap, base_color, 
                          base_count );

            for ( ii = 0; ii < base_count; ii++ )
               {
               base_color[ii].pixel = ii << ( temp_ptr[offset].base_depth / 3 );
               base_color[ii].flags = DoGreen;
               }

            XStoreColors( screen_struct.native_info.EXdisplay, 
                          temp_ptr[offset].native_info.EXcolormap, base_color, 
                          base_count );

            for ( ii = 0; ii < base_count; ii++ )
               {
               base_color[ii].pixel = ii << (2 * (temp_ptr[offset].base_depth/3));
               base_color[ii].flags = DoBlue;
               }

            XStoreColors( screen_struct.native_info.EXdisplay, 
                          temp_ptr[offset].native_info.EXcolormap, base_color, 
                          base_count );
            }
         }
      else
         {
         if ( !( temp_ptr[offset].flags & WL_COLORMAP_READ_ONLY ) )
            {
            XStoreColors( screen_struct.native_info.EXdisplay, 
                          temp_ptr[offset].native_info.EXcolormap, base_color, 
                          base_count );
            }
         }

      if ( hilite_count > ( ( 1 << temp_ptr[offset].hilite_depth ) - 1 ) )
         {
         num_pixels = ( 1 << temp_ptr[offset].hilite_depth ) - 1;
         }
      else
         {
         num_pixels = hilite_count;
         }
      
      if ( num_pixels )
         {
         if (temp_ptr[offset].hl_native_info.transparent_index == 
             WLI_UNDEFINED_TRANSPARENT_INDEX)
            {

            /* first time through, allocate color cells and determine */
            /* transparent cell */

#           if defined (XGL)
               {
               if ( temp_ptr[offset].flags & WL_USING_XGL )
                  {
                  pixels[0] = XGL_OPAQUE_INDEX;
                  pixels[1] = XGL_TRANSPARENT_INDEX;
         
                  temp_ptr[offset].hl_native_info.opaque_index = XGL_OPAQUE_INDEX;
                  temp_ptr[offset].hl_native_info.transparent_index = XGL_TRANSPARENT_INDEX;
                                     
                  temp_ptr[offset].hl_native_info.hl_pixel_mapping[0] = pixels[0];
                  temp_ptr[offset].hl_native_info.hl_pixel_mapping[1] = pixels[1];
                  }
               }
#           else /* XGL */
               {
               while (num_pixels )
                  {   
                  if ( XAllocColorCells( screen_struct.native_info.EXdisplay, 
                                         temp_ptr[offset].hl_native_info.hl_colormap,
                                         1, plane_masks, 0, pixels, num_pixels ) ) break;
                  num_pixels--;
                  }
  
               /* i circles through possible indexes for transparent one */
               for ( i = 0; (i < num_pixels) && 
                     (temp_ptr[offset].hl_native_info.transparent_index == 
                      WLI_UNDEFINED_TRANSPARENT_INDEX); i++ )
                  {
                  temp_ptr[offset].hl_native_info.transparent_index = i; 

                  /* j searches to see if i is transparent index */

                  for ( j = 0; j < num_pixels; j++ )
                     {
                     if (i == pixels[j])
                        {
                        temp_ptr[offset].hl_native_info.transparent_index = 
                           WLI_UNDEFINED_TRANSPARENT_INDEX;
                        }
                     }
                  }

               if (!num_pixels || 
                   (temp_ptr[offset].hl_native_info.transparent_index == 
                    WLI_UNDEFINED_TRANSPARENT_INDEX) )
                  {
                  temp_ptr[offset].hl_native_info.transparent_index = 0;
                  }
               }
#           endif /* XGL - else */
            }

#        if defined( XGL )
            {
  
            /*  set the num_pixels to 32, because that is the max that we can load */
            /*  into the hilite colormap */

            num_pixels = 32;
            }
#        else /* XGL */
            {
            for ( i = 0; i < num_pixels; i++ )
               {
               /* skip over the transparent index */
               if ( hilite_color[i].pixel == temp_ptr[offset].hl_native_info.transparent_index )
                  {
if( hilite_color[num_pixels].pixel >= 0 && 
    hilite_color[num_pixels].pixel <= 512 )
                  hilite_color[i].pixel = hilite_color[num_pixels].pixel; 
                  }
               }
            }
#        endif /* XGL - else */

         if ( num_pixels )
            {
            XStoreColors( screen_struct.native_info.EXdisplay, 
                          temp_ptr[offset].hl_native_info.hl_colormap, 
                          hilite_color, num_pixels ); 
            }
         }
      }
   else
      {
      color_def = (XColor *) malloc( sizeof( XColor ) * num_entries );
#     if defined( XGL )
         {
         if ( temp_ptr[offset].flags & WL_USING_XGL )
            {
            xgl_color_list.start_index = cmap_entries[0].slot;
            xgl_color_list.length = num_entries;
            xgl_color_list.colors = 
               (Xgl_color *) malloc( sizeof( Xgl_color ) * num_entries );
            for (i = 0; i < num_entries; i++ )
               {
               xgl_color_list.colors[i].rgb.r = 1.0 * cmap_entries[i].red/WL_MAX_COLOR;
               xgl_color_list.colors[i].rgb.g = 1.0 * cmap_entries[i].green/WL_MAX_COLOR;
               xgl_color_list.colors[i].rgb.b = 1.0 * cmap_entries[i].blue/WL_MAX_COLOR;
               }
            }
         }
#     endif /* XGL */

      for (i = 0; i < num_entries; i++ )
         {
         color_def[i].pixel = cmap_entries[i].slot;
         color_def[i].red = cmap_entries[i].red;
         color_def[i].green = cmap_entries[i].green;
         color_def[i].blue = cmap_entries[i].blue;
         color_def[i].flags = DoRed | DoGreen | DoBlue;
         }

      if ( temp_ptr[offset].base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
         for ( ii = 0; ii < num_entries; ii++ )
            {
            color_def[ii].pixel = ii;
            color_def[ii].flags = DoRed;
            }

         XStoreColors( screen_struct.native_info.EXdisplay,
                       temp_ptr[offset].native_info.EXcolormap, color_def,
                       num_entries );

         for ( ii = 0; ii < num_entries; ii++ )
            {
            color_def[ii].pixel = ii << ( temp_ptr[offset].base_depth / 3 );
            color_def[ii].flags = DoGreen;
            }

         XStoreColors( screen_struct.native_info.EXdisplay,
                       temp_ptr[offset].native_info.EXcolormap, color_def,
                       num_entries );

         for ( ii = 0; ii < num_entries; ii++ )
            {
            color_def[ii].pixel = ii << (2 * (temp_ptr[offset].base_depth/3));
            color_def[ii].flags = DoBlue;
            }

         XStoreColors( screen_struct.native_info.EXdisplay,
                       temp_ptr[offset].native_info.EXcolormap, color_def,
                       num_entries );
         }
      else
         {
         XStoreColors( screen_struct.native_info.EXdisplay, 
                       temp_ptr[offset].native_info.EXcolormap, color_def, 
                       num_entries );

/*
         XStoreColors( screen_struct.native_info.EXdisplay, 
                       temp_ptr[0].hl_native_info.hl_colormap, 
                       color_def, 
                       num_entries>32 ? 32 : num_entries );
*/
         }
      }
 
   if ( color_def )
      {
      WLI_FREE( color_def );
      }

   if ( base_color )
      {
      WLI_FREE( base_color );
      }

   if ( hilite_color )
      {
      WLI_FREE( hilite_color );
      }
   }
#elif defined( WIN32 )
   /* Load the colormap only if a palette was created                      */

   if ( temp_ptr[offset].native_info.palette )
   {
      lppe = NULL;
      lppe = ( PALETTEENTRY * ) malloc( sizeof( PALETTEENTRY ) * num_entries );
      for (i = 0; i < num_entries; i++ )
      {
         /* Red green and Blue contain 16 bit values, so pick up the  */
         /* Significant 8 bits                                        */
         
         lppe[i].peRed =( BYTE )( cmap_entries[i].red >> 8 );
         lppe[i].peGreen =( BYTE ) (cmap_entries[i].green >> 8 );
         lppe[i].peBlue = ( BYTE ) (cmap_entries[i].blue >> 8 );
      }
      SetPaletteEntries( temp_ptr[offset].native_info.palette, 
                         cmap_entries[0].slot, num_entries, lppe );
   }
#else
#error "A windowing system must be defined"
#endif

   return( WL_SUCCESS );

} /*  WLIcontext_load_cmap_entries */

/*--- WLIcontext_read_cmap_entries--------------------------------------------*/

int WLIcontext_read_cmap_entries(
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries )

/*
NAME
	WLIcontext_read_cmap_entries
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function reads the colormap entries
 
PARAMETERS
        context_no(IN) - context number
        num_entries (IN) - number of entries to be loaded
        cmap_entries (OUT) - array of color map entries to load


GLOBALS USED
        not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_ERROR
		Failure
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   int        i, sts;
   struct WLIcontext   *temp_ptr;
   struct WLIscreen    screen_struct;
#if defined( X11 )
   XColor     *color_def;
#elif defined( ENV5 )
   struct vlt_slot *vlt;
#elif defined( WIN32 )
   PALETTEENTRY *lppe;
#endif


   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );
   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   sts = WLIscreen_retrieve_entry( temp_ptr[offset].lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

/*#if ! defined (XGL)*/
   if ( temp_ptr[offset].flags & WL_COLORMAP_READ_ONLY )
   {
#if defined( X11 )
      color_def = (XColor *) malloc( sizeof( XColor ) * num_entries );

      if ( !color_def )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }

      for ( i = 0; i < num_entries; i++ )
      {
         color_def[i].pixel = cmap_entries[i].slot; 
         color_def[i].flags = DoRed | DoGreen | DoBlue;
      }

      XQueryColors( screen_struct.native_info.EXdisplay, 
                    temp_ptr[offset].native_info.EXcolormap, color_def, 
                    num_entries );

      for ( i = 0; i < num_entries; i++ )
      {
         cmap_entries[i].red = color_def[i].red;
         cmap_entries[i].green =  color_def[i].green;
         cmap_entries[i].blue = color_def[i].blue;
      }
      WLI_FREE( color_def );
#elif defined( ENV5 )
      vlt = (struct vlt_slot *) malloc( sizeof( struct vlt_slot ) * 
                                        num_entries );
      if ( !vlt )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }
     
      if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
           ( WLISRwin_no >= 0 ) )
      {
         sts = Read_SR_vlt( WLISRwin_no, vlt, num_entries,
                        cmap_entries[0].slot ); 
      }
      else
      {
         sts = Readvlt( screen_struct.native_info.screen_no, vlt, num_entries,
                        cmap_entries[0].slot ); 
      }

      if ( !sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      for ( i = 0; i < num_entries; i++ )
      {
         cmap_entries[i].red = vlt[i].v_red;
         cmap_entries[i].green =  vlt[i].v_green;
         cmap_entries[i].blue = vlt[i].v_blue;
      }
      WLI_FREE( vlt );
      
#elif defined( WIN32 )
      lppe = (LPPALETTEENTRY )malloc( sizeof( PALETTEENTRY ) * 
                                        num_entries );
      if ( !lppe )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }
     
      sts = GetPaletteEntries( temp_ptr[offset].native_info.palette,
                     cmap_entries[0].slot, num_entries, lppe ); 

      if ( !sts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      for ( i = 0; i < num_entries; i++ )
      {
         cmap_entries[i].red = lppe[i].peRed << 8;
         cmap_entries[i].green =  lppe[i].peGreen << 8;
         cmap_entries[i].blue = lppe[i].peBlue << 8;
      }
      WLI_FREE( lppe );
      
#else
#endif
   }
   else
/*#endif*/ /* !XGL */
   {
      for (i = 0; i < num_entries; i++ )
      {
         cmap_entries[i].red = 
                  temp_ptr[offset].local_colormap[cmap_entries[i].slot].red; 
         cmap_entries[i].green = 
                  temp_ptr[offset].local_colormap[cmap_entries[i].slot].green; 
         cmap_entries[i].blue = 
                  temp_ptr[offset].local_colormap[cmap_entries[i].slot].blue; 
         cmap_entries[i].flags = 
                  temp_ptr[offset].local_colormap[cmap_entries[i].slot].flags; 
      }
   }
      

   return( WL_SUCCESS );
	
} /* WLIcontext_read_cmap_entries */

/*--- WLIcontext_install_cmap--------------------------------------------*/

int WLIcontext_install_cmap(
   WLuint32 lwin_no,
   WLuint32 context_no)
/*
NAME
	WLIcontext_install_cmap
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function installs the colormap
 
PARAMETERS
	lwin_no (IN) - The logical window number
        context_no (IN) - context number


GLOBALS USED
        not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_ERROR
		Failure
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   int        sts;
   struct WLIcontext         *temp_ptr;
   struct WLIwin             win_struct;
#if defined( ENV5 ) || defined( X11 )
   int        i, hilite_depth;
#endif   
#if defined( ENV5 )
   int        base_cmap_size, cmap_size;
   int        j, k;
   struct rgb_color          hl_color;
   struct WLIcontext         *grp_ptr;
   struct WLIcontext_group   *search_ptr; 
   struct vlt_slot           temp_cmap[512];
#endif

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );
   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if ( temp_ptr[offset].flags & WL_SYSTEM_COLORMAP )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
#if defined ( X11 )

 /* The window manager will install the colormap in X. Don't install it   */

#elif defined ( WIN32 )
   if ( temp_ptr[offset].native_info.palette )
   {
      SelectPalette( win_struct.native_info.hdc, 
                     temp_ptr[offset].native_info.palette, TRUE);
      RealizePalette( win_struct.native_info.hdc );
   }
#elif defined ( ENV5 )

   if ( temp_ptr[offset].native_info.vlt_no != -1 )
   {
      sts = activevltno( win_struct.hwin_no, 
                              temp_ptr[offset].native_info.vlt_no );
      if ( sts != 0 )
      {
          WL_REPORT_ERROR( WL_SYSTEM_ERROR );
          return( WL_SYSTEM_ERROR );
      }
      enabledata( win_struct.hwin_no, IMAGE_DATA, 0xffffff );
      enabledata( win_struct.hwin_no, HIGHLIGHT_DATA, 0 );
   }
   else
   {
      /* activate the default indexed VLT for this window */
      if ( WLIdefault_vlt_no[lscreen_no] != -1 )
      {  
         sts = activevltno( win_struct.hwin_no, 
                            WLIdefault_vlt_no[lscreen_no] );
         if ( sts != 0 )
         {
             WL_REPORT_ERROR( WL_SYSTEM_ERROR );
             return( WL_SYSTEM_ERROR );
         }
      }

      if ( temp_ptr[offset].hilite_used )
      {
         if ( win_struct.native_info.env5_vsi_flags & VSI_HL )
         {
             /* Load the hilite colors and the base colors separately   */
             /* if required                                             */

	     WLI_GET_BASE_CMAP_SIZE( temp_ptr, offset, base_cmap_size );
             for ( i = 0; i < base_cmap_size; i++ )
             {
                 temp_cmap[i].v_slot =  temp_ptr[offset].local_colormap[i].slot;
                 temp_cmap[i].v_red =  temp_ptr[offset].local_colormap[i].red;
                 temp_cmap[i].v_green =  temp_ptr[offset].local_colormap[i].green;
                 temp_cmap[i].v_blue =  temp_ptr[offset].local_colormap[i].blue;
             }

             if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                  ( WLISRwin_no >= 0 ) )
             {
                 sts = Load_SR_vlt( WLISRwin_no, temp_cmap, base_cmap_size );
             }
             else
             {
                 sts = Loadvlt( win_struct.native_info.screen_no, 
                                temp_cmap, base_cmap_size );
             }

             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
             hl_color.red = 
                      temp_ptr[offset].local_colormap[base_cmap_size].red; 
             hl_color.green = 
                      temp_ptr[offset].local_colormap[base_cmap_size].green; 
             hl_color.blue = 
                      temp_ptr[offset].local_colormap[base_cmap_size].blue; 
             sts = LoadHL( win_struct.native_info.screen_no, &hl_color );
             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
         
         }
         else /* if (separate hilite plane ) */
         {
             if (  temp_ptr[offset].hilite_used )
             {
                hilite_depth = 1;
             }
             else
             {
                hilite_depth = 0;
             }
	     if ( temp_ptr[offset].base_cmap_type == WL_CMAP_TRUE_COLOR )
	     {
                cmap_size = 1 << ( ( temp_ptr[offset].base_depth / 3 )
			  	       + hilite_depth );
	     }
	     else
	     {
                cmap_size = 1 << ( temp_ptr[offset].base_depth + hilite_depth );
	     }
             for ( i = 0; i < cmap_size; i++ )
             {
                 temp_cmap[i].v_slot =  temp_ptr[offset].local_colormap[i].slot;
                 temp_cmap[i].v_red =  temp_ptr[offset].local_colormap[i].red;
                 temp_cmap[i].v_green =  temp_ptr[offset].local_colormap[i].green;
                 temp_cmap[i].v_blue =  temp_ptr[offset].local_colormap[i].blue;
             }
             if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
                  ( WLISRwin_no >= 0 ) )
             {
                sts = Load_SR_vlt( WLISRwin_no, temp_cmap, cmap_size );
             }
             else
             {
                sts = Loadvlt( win_struct.native_info.screen_no, 
                              temp_cmap, cmap_size );
             }
             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
         }
      }
      else /* if (hilite used ) */
      {
          if (  temp_ptr[offset].hilite_used )
          {
             hilite_depth = 1;
          }
          else
          {
             hilite_depth = 0;
          }
          cmap_size = 1 << (temp_ptr[offset].base_depth +  hilite_depth );
          for ( i = 0; i < cmap_size; i++ )
          {
              temp_cmap[i].v_slot =  temp_ptr[offset].local_colormap[i].slot;
              temp_cmap[i].v_red =  temp_ptr[offset].local_colormap[i].red;
              temp_cmap[i].v_green =  temp_ptr[offset].local_colormap[i].green;
              temp_cmap[i].v_blue =  temp_ptr[offset].local_colormap[i].blue;
          }
          if ( ( temp_ptr[offset].flags & WL_COLORMAP_SAVE_RESTORE ) &&
               ( WLISRwin_no >= 0 ) )
          {
             sts = Load_SR_vlt( WLISRwin_no, temp_cmap, cmap_size );
          } 
          else
          {
             sts = Loadvlt( win_struct.native_info.screen_no, 
                            temp_cmap, cmap_size );
          }
          if ( sts != 0 )
          {
              WL_REPORT_ERROR( WL_SYSTEM_ERROR );
              return( WL_SYSTEM_ERROR );
          }
      }
      
      /* Set the current colormap to be active                      */
      /* Search for any other context with a vlt_no of -1 and an     */
      /* active colormap. Set all such colormaps to inactive        */
      
      search_ptr = WLIscreens_arr[lscreen_no].pcontext;
      for ( k = 0; k < WLI_MAX_CONTEXT_GROUPS; k++ )
      {
         if ( search_ptr[k].num_entries_used > 0 )
         {
            grp_ptr = search_ptr[k].pcontext_group;
            for ( j = 0; j < WLI_MAX_CONTEXTS_PER_GROUP; j++ )
            {
                if ( ( grp_ptr[j].cmap_active == WLI_TRUE ) &&
                     ( grp_ptr[j].native_info.vlt_no == -1 ) )
                {
                    grp_ptr[j].cmap_active = WLI_FALSE;
                }
            }
         }
      }
      temp_ptr[offset].cmap_active = WLI_TRUE;
   }
   
#else
#error "A windowing system must be defined"
#endif

   return( WL_SUCCESS );

} /*  WLIcontext_install_cmap */

/*--- WLIcontext_change_color_funcs-----------------------------------------*/

int WLIcontext_change_color_funcs(
   WLuint32 context_no,
   int     (*cmap_color_to_index)(),
   int     (*cmap_color_to_rgb)(),
   int     (*cmap_init)() )
/*
NAME
	WLIcontext_change_color_funcs
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function changes the colormap function pointers associated with 
	a context
 
PARAMETERS
	context_no (IN) - logical context number
	cmap_color_to_index (IN) - Function pointer
	cmap_color_to_rgb (IN) - Function pointer
	cmap_init (IN) - Function pointer

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_BAD_CONTEXT
                The context number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIcontext  *temp_ptr;

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset);
   if ( WLIcontext_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }
   temp_ptr = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group;

   if ( cmap_color_to_index )
   {
      temp_ptr[offset].cmap_color_to_index = cmap_color_to_index;
   }
   if ( cmap_color_to_rgb )
   {
      temp_ptr[offset].cmap_color_to_rgb = cmap_color_to_rgb;
   }
   if ( cmap_init )
   {
      temp_ptr[offset].cmap_init = cmap_init;
   }
   return( WL_SUCCESS );

} /* WLIcontext_retrieve_entry */

/*---WLIcontext_copy_cmap-----------------------------------------------------
 *
 *  Created for XGL, this copys the colormap from one context to another
 *  I needed to do this for RHL (Mike 01/10/96)
 */

void WLIcontext_copy_cmap( WLuint32 context_no1, WLuint32 context_no2 )
   {
   struct WLcmap_entry	*cmap1, *cmap2;

   WLuint16	lscreen_no;
   WLuint8	group_index, offset;
   int		i, num_entries;

   WLIcontext_unpack( context_no1, &lscreen_no, &group_index, &offset );
   cmap1 = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group[offset].local_colormap;

   num_entries = 256;
/*printf( "need better number for num_entries: %s %d\n", __FILE__, __LINE__ );*/

   WLIcontext_unpack( context_no2, &lscreen_no, &group_index, &offset );
   cmap2 = WLIscreens_arr[lscreen_no].pcontext[group_index].pcontext_group[offset].local_colormap;

   for ( i = 0; i < num_entries; i++)
      {

      /* Colors are ordered by their slot numbers                     */

      cmap2[i].slot  = cmap1[i].slot;
      cmap2[i].red   = cmap1[i].red;
      cmap2[i].green = cmap1[i].green;
      cmap2[i].blue  = cmap1[i].blue;
      cmap2[i].flags = cmap1[i].flags;
      }
   }
