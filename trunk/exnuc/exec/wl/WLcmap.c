#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined (IRIX)
#include <sys/fcntl.h>
#include <sys/gfx.h>
#endif

#include "wl.h"
#include "wl_internal.h"

static override_num_wm_colors = -1;
static override_num_ingr_colors = -1;
static struct WLIdefault_cmap default_cmap[WL_MAX_SCREENS];
static int default_cmap_initialized = WLI_FALSE;
extern int WLIdefault_vlt_no[WL_MAX_SCREENS];
static WLuint32 cmap_installed_lwin_no = WL_UNDEFINED_WINDOW;
static WLuint32 cmap_installed_context_no = WL_DEFAULT_CONTEXT;

#if defined (IRIX)
int  WLIget_graphics_board( void ); 
#endif



/*---WLinit_default_colormap----------------------------------------------*/
int WLinit_default_colormap(
   WLuint16 lscreen_no ) 
/* 
NAME
   WLinit_default_colormap
 
KEYWORD
   WL 
 
DESCRIPTION
   This function

SYNOPSIS
   int WLinit_default_colormap(
      WLuint16 lscreen_no )

PARAMETERS
	lscreen_no (IN) - The logical screen number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	08/27/93 Shridar Subramanian
		Initial definition Initial design
*/
{
   int i;
   struct WLIscreen screen_struct;
   int sts;
#if defined( ENV5 )
   struct vlt_info vlt_info;
   struct vlt_slot vlt[512];
#elif defined( X11 )
   XColor color[512];
   XVisualInfo *v_info, template;
   int nitems;
#endif

   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if( !default_cmap_initialized )
   {
      for ( i = 0; i < WL_MAX_SCREENS; i++ )
      {
         default_cmap[i].size_of_cmap = 0;
         default_cmap[i].cmap_entry = NULL;
      }
      default_cmap_initialized = WLI_TRUE;
   }
#if defined( ENV5 )
   sts = Inq_vlt_info( screen_struct.native_info.screen_no, INDEXED_COLOR_DATA,
                       &vlt_info );
   if ( sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }
   default_cmap[lscreen_no].cmap_type = WL_CMAP_INDEXED;
   default_cmap[lscreen_no].size_of_cmap = vlt_info.vlti_vlt_size;
   default_cmap[lscreen_no].cmap_entry = ( struct WLcmap_entry *) malloc
                                           ( sizeof ( struct WLcmap_entry ) * 
                                                      vlt_info.vlti_vlt_size );

   sts = Readvlt( screen_struct.native_info.screen_no, 
                  vlt, vlt_info.vlti_vlt_size, 0 );
   if ( sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   for ( i = 0; i < vlt_info.vlti_vlt_size; i++ )
   {
      default_cmap[lscreen_no].cmap_entry[i].slot = i;
      default_cmap[lscreen_no].cmap_entry[i].red = vlt[i].v_red;
      default_cmap[lscreen_no].cmap_entry[i].green = vlt[i].v_green;
      default_cmap[lscreen_no].cmap_entry[i].blue = vlt[i].v_blue;
   }
#elif defined( X11 )
   template.visualid = XVisualIDFromVisual( 
                         DefaultVisual( screen_struct.native_info.EXdisplay, 
                                        screen_struct.native_info.screen_no ) );
   v_info = XGetVisualInfo( screen_struct.native_info.EXdisplay, 
                            VisualIDMask, &template, &nitems );
   if ( nitems == 0 )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   if ( ( v_info[0].class == DirectColor ) || 
        ( v_info[0].class == TrueColor ) )
   {
      default_cmap[lscreen_no].cmap_type = WL_CMAP_TRUE_COLOR;
   }
   else if ( ( v_info[0].class == StaticColor ) || 
             ( v_info[0].class == PseudoColor ) )
   {
      default_cmap[lscreen_no].cmap_type = WL_CMAP_INDEXED;
      default_cmap[lscreen_no].size_of_cmap = v_info[0].colormap_size;
      default_cmap[lscreen_no].cmap_entry = ( struct WLcmap_entry *) malloc
                                            ( sizeof ( struct WLcmap_entry ) * 
                                                      v_info[0].colormap_size );
      for ( i = 0; i < v_info[0].colormap_size; i++ )
      {
         color[i].pixel = i;
         color[i].flags = DoRed | DoGreen | DoBlue;
      }
      XQueryColors( screen_struct.native_info.EXdisplay,
                    DefaultColormap( screen_struct.native_info.EXdisplay,
                                     screen_struct.native_info.screen_no ),
                    color, v_info[0].colormap_size );
      for ( i = 0; i < v_info[0].colormap_size; i++ )
      {
         default_cmap[lscreen_no].cmap_entry[i].slot = color[i].pixel;
         default_cmap[lscreen_no].cmap_entry[i].red = color[i].red;
         default_cmap[lscreen_no].cmap_entry[i].green = color[i].green;
         default_cmap[lscreen_no].cmap_entry[i].blue = color[i].blue;
      }
   }
   else /* Gray scale etc */
   {
      default_cmap[lscreen_no].cmap_type = -1;
   }
   XFree(v_info );
#endif
   return( WL_SUCCESS );

} /* WLinit_default_colormap */
   
/*---WLget_default_colormap_entries-------------------------------------------*/
int WLget_default_colormap_entries(
   WLuint32 context_no,
   int start_slot,
   int num_entries,
   int *num_valid_entries,
   struct WLcmap_entry *default_entries )
/* 
NAME
   WLget_default_colormap_entries
 
KEYWORD
   WL 
 
DESCRIPTION
   This function

SYNOPSIS
   int WLget_default_colormap(
      WLuint32 context_no,
      int start_slot,
      int num_entries,
      int *num_valid_entries,
      struct WLcmap_entry *default_cmap )

PARAMETERS
	context_no (IN) - The context number
        start_slot (IN) - The starting slot number`
        num_entries (IN) - The number of entries
        num_valid_entries (OUT) - The number of valid entires returned
        default_entries (OUT) - The default colormap. 

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
        
        WL_NO_DEFAULT_COLORMAP
                There is no internal default colormap for this screen
        
        WL_BAD_PARAMETER
                The num_valid_entries parameter is NULL

HISTORY
	08/27/93 Shridar Subramanian
		Initial definition Initial design
*/
{
   WLuint16 lscreen_no;
   int i, j; 
   struct WLcmap_entry *cmap_ptr;
   
   
   if ( num_valid_entries == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }
   *num_valid_entries = 0;

   WLIcontext_unpack( context_no, &lscreen_no, ( WLuint8 *) NULL, ( WLuint8 *) NULL );
   if ( default_cmap[lscreen_no].cmap_type != WL_CMAP_INDEXED )
   {
      WL_REPORT_ERROR( WL_NO_DEFAULT_COLORMAP );
      return( WL_NO_DEFAULT_COLORMAP );
   }

   if ( start_slot > default_cmap[lscreen_no].size_of_cmap )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   if ( ( start_slot + num_entries ) > default_cmap[lscreen_no].size_of_cmap ) 
   {
      *num_valid_entries = default_cmap[lscreen_no].size_of_cmap - start_slot;
   }
   else
   {
      *num_valid_entries = num_entries;
   }
   

   cmap_ptr = default_cmap[lscreen_no].cmap_entry;
   for ( i = 0, j = start_slot; i < *num_valid_entries; i++, j++ )
   {
      default_entries[i].slot = cmap_ptr[j].slot;
      default_entries[i].red = cmap_ptr[j].red;
      default_entries[i].green = cmap_ptr[j].green;
      default_entries[i].blue = cmap_ptr[j].blue;
   }

   for ( i = *num_valid_entries; i < num_entries; i++ )
   {
      default_entries[i].slot = i;
      default_entries[i].red = 0;
      default_entries[i].green = 0;
      default_entries[i].blue = 0;
   }
 
   return( WL_SUCCESS );
   
} /* WLget_default_colormap */

/*---WLset_num_wm_colors----------------------------------------------*/
int WLset_num_wm_colors(
   WLint32 num_wm_colors )
/* 
NAME
   WLset_num_wm_colors
 
KEYWORD
   WL 
 
DESCRIPTION
   This function changes the static variable that is an override for the
default number of wm colors.  It will be called at startup because one
of the options is number of wm colors.

SYNOPSIS
   int WLset_num_wm_colors(
      WLint32 num_wm_colors )

PARAMETERS
	num_wm_colors (IN) - the value to override num wm colors

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

RELATED INFORMATION
	Functions:  WLget_wm_colors()

HISTORY
	03/31/93 Joel Underwood
		Initial definition Initial design
*/
{
   override_num_wm_colors = num_wm_colors;
   return( WL_SUCCESS );
}

/*---WLset_num_ingr_colors----------------------------------------------*/
int WLset_num_ingr_colors(
   WLint32 num_ingr_colors )
/* 
NAME
   WLset_num_ingr_colors
 
KEYWORD
   WL 
 
DESCRIPTION
   This function changes the static variable that is an override for the
default number of ingr colors.  It will be called at startup because one
of the options is number of ingr colors.

SYNOPSIS
   int WLset_num_ingr_colors(
      WLint32 num_ingr_colors )

PARAMETERS
	num_ingr_colors (IN) - the value to override num ingr colors

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

RELATED INFORMATION
	Functions:  WLget_wm_colors()

HISTORY
	03/31/93 Joel Underwood
		Initial definition Initial design
*/
{
   override_num_ingr_colors = num_ingr_colors;
   return( WL_SUCCESS );
}


/*---WLchange_window_cmap-----------------------------------------*/

int WLchange_window_cmap(
   WLuint16 lscreen_no,
   WLuint32 lwin_no,
   WLuint32 context_no )

/*
NAME
	WLchange_window_cmap
 
KEYWORD
	WL 
 
DESCRIPTION
	This function changes the colormap associated with a window,by replacing
	the old context with a new one with the same "base_depth" and 
	"hilite_used" parameters.	

SYNOPSIS
	int WLchange_window_cmap(
		WLuint16 lscreen_no,
		WLuint32 lwin_no,
		WLuint32 context_no )

PARAMETERS
	lscreen_no (IN) - The logical screen number.
	lwin_no (IN) - The logical window number
	context_no (IN) - The new context number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
   		The logical screen number is invalid

	WL_BAD_WINDOW_NUMBER
   		The logical window number is invalid

	WL_BAD_CONTEXT
		The context number is invalid or a similar context has not been
		added to the window

RELATED INFORMATION
	Functions:  WLadd_context_to_window(), WLdisplay_window(),WLdelete_window()

HISTORY
	08/28/92 S.P.Rogers, Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   int        sts;
   WLuint16   lscr1, lscr;
   struct WLIwin       win_struct;
   struct WLIcontext   context_struct;
   WLuint32   old_context_no;

   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }

   lscr = lscr1 = 0;
   WLIwin_unpack( lwin_no, &lscr, ( WLuint8 *) NULL, ( WLuint8 *) NULL );

   WLIcontext_unpack( context_no, &lscr, ( WLuint8 *) NULL, ( WLuint8 *) NULL );
   if ( ( lscr != lscr1 ) || ( lscr != lscreen_no ) || ( lscr1 != lscreen_no ) )
   {
       WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
       return( WL_BAD_SCREEN_NUMBER );
   }

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR ( sts );
      return ( sts );
   }
   old_context_no = win_struct.context_no;
   sts = WLIwin_set_context( lwin_no, context_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   sts = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
#if defined( X11 )

   XSetWindowColormap( win_struct.native_info.EXdisplay, win_struct.hwin_no,
                       context_struct.native_info.EXcolormap );

#endif

   /* Decrement the old contex number and increment the new context number */

   sts = WLIcontext_dec_ref_ct( old_context_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   sts = WLIcontext_inc_ref_ct( context_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   return( WL_SUCCESS );
}


/*--- WLload_cmap_entries -------------------------------------------*/
 
int WLload_cmap_entries(
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries )
 
/*
NAME
   WLload_cmap_entries
 
KEYWORD
   WL
 
DESCRIPTION
   This function loads entries in the color map for a context.
   A true colormap has 2^bits_per_primary entries.

SYNOPSIS
   int WLload_cmap_entries(
      WLuint32 context_no,
      int num_entries,
      struct WLcmap_entry *cmap_entries )
 
PARAMETERS
   context (IN) - context number
   num_entries (IN) - number of entries to be loaded
   cmap_entries (IN) - array of color map entries to load

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SLOT_NUMBER
      One of the slot numbers is invalid
 
   WL_BAD_PARAMETER
      "cmap_entries" pointer is NULL or num_entries < 1
 
   WL_BAD_CONTEXT
      The context is invalid
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
   10/22/92 Shridar Subramanian
      Initial design
 
*/
{
   int status;
 
   if ( ( cmap_entries == NULL ) || ( num_entries < 1 ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }
 
   status = WLIslot_validate( cmap_entries, num_entries, context_no );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SLOT_NUMBER );
      return( WL_BAD_SLOT_NUMBER );
   }
 
   status = WLIcontext_load_cmap_entries( context_no, num_entries, cmap_entries ); 
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   return( WL_SUCCESS );
 
} /* WLload_cmap_entries */



/*--- WLread_cmap_entries -------------------------------------------*/
 
int WLread_cmap_entries(
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries )
 
/*
NAME
   WLread_cmap_entries
 
KEYWORD
   WL
 
DESCRIPTION
   This function reads the entries from the color map assoicated with a
   context.  The caller is responsible for filling in the 'slot' field
   for each entry in the 'cmap_entries' array to indicate which slots are
   to be read. A true colormap has 2^bits_per_primary entries

SYNOPSIS
   int WLread_cmap_entries(
      WLuint32 context_no,
      int num_entries,
      struct WLcmap_entry *cmap_entries )
 
PARAMETERS
   context_no (IN) - context number
   num_entries (IN) - number of entries to read
   cmap_entries (OUT) - array of color map entries that were read; the
                        caller is responsible for filling in the 'slot'
                        field.
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SLOT_NUMBER
      One of the slot numbers is invalid
 
   WL_BAD_PARAMETER
      "cmap_entries" pointer is NULL or num_entries < 1
 
   WL_BAD_CONTEXT
      The context is invalid
 
HISTORY
 
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
 
   if ( WLIslot_validate( cmap_entries, num_entries, context_no ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SLOT_NUMBER );
      return( WL_BAD_SLOT_NUMBER );
   }
   if ( ( cmap_entries == NULL ) || ( num_entries < 1 ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }
 
   status = WLIcontext_read_cmap_entries( context_no, num_entries, cmap_entries );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
   return( WL_SUCCESS );
 
}  /* WLread_cmap_entries */


/*--- WLinstall_cmap -----------------------------------------------*/

int WLinstall_cmap(
   WLuint32 lwin_no,
   WLuint32 context_no)

/*
NAME
	WLinstall_cmap
 
KEYWORD
	WL
 
DESCRIPTION
	This function installs the context associated with a logical window
 
SYNOPSIS
	int WLinstall_cmap(
		WLuint32 lwin_no,
		WLuint32 context_no)

PARAMETERS
	lwin_no (IN) - logical window number
	context_no (IN) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_CONTEXT
		The context number is invalid

RELATED INFORMATION

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   int  sts;
   
   sts = WLIcontext_install_cmap( lwin_no, context_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   cmap_installed_lwin_no = lwin_no;
   cmap_installed_context_no = context_no;

   return( WL_SUCCESS );

}

/*--- WLget_installed_cmap --------------------------------------------*/

int WLget_installed_cmap(
   WLuint32 *lwin_no,
   WLuint32 *context_no)

/*
NAME
	WLget_installed_cmap
 
KEYWORD
	WL
 
DESCRIPTION
	This function returns the window and context whose cmap is
        installed
 
SYNOPSIS
	int WLget_installed_cmap(
		WLuint32 *lwin_no,
		WLuint32 *context_no)

PARAMETERS
	lwin_no (OUT) - logical window number
	context_no (OUT) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_CONTEXT
		The context number is invalid

RELATED INFORMATION

HISTORY
	10/28/93 Shridar Subramanian
		Initial definition, design and brain wave
*/
{
   if ((lwin_no == NULL) || (cmap_installed_lwin_no == WL_UNDEFINED_WINDOW))
   {
      return( WL_BAD_WINDOW_NUMBER );
   }
   if ((context_no == NULL) || (cmap_installed_context_no == WL_DEFAULT_CONTEXT))
   {
      return( WL_BAD_CONTEXT );
   }

   *lwin_no = cmap_installed_lwin_no;
   *context_no = cmap_installed_context_no;
   return( WL_SUCCESS );
}

#if defined (IRIX)

#define DEV_GRAPHICS            "/dev/graphics"

int WLIget_graphics_board( void )
/*
NAME
       WLIget_graphics_board

KEYWORD
       WL

DESCRIPTION
       This returns whether the graphics board is the one on Personal IRIS
       or not.  We use this function because it has only 1 color map.

SYNOPSIS
       int WLIget_graphics_board( void )

PARAMETERS
       NONE

RETURN VALUES
       TRUE  Either error and we assume not GR1, or not GR1 board.
       FALSE The graphics board is GR1 (Personal IRIS) and has 1 color map.

HISTORY
        07/30/93 Joel Underwood
                Initial implementation for personal iris.
        11/22/93 Joel Underwood
                modified stand alone Allen Bourgoyne gave us to simplify.
*/
{
   struct gfx_getboardinfo_args    getboardinfo;
   struct gfx_info *info;
   int             gfxfd;
   int             num_boards;
   int             isnt_GR1 = TRUE;

   if ((gfxfd = open(DEV_GRAPHICS, O_RDWR | O_NOCTTY)) < 0) 
   {
      /*fprintf(stderr, "open of %s failed\n", DEV_GRAPHICS);*/
      return(1);
   }

   /* Get number of graphics boards.  If 0, no graphics. */
   if ((num_boards = ioctl(gfxfd, GFX_GETNUM_BOARDS, 0)) < 0) 
   {
      /*fprintf(stderr, "can't get number of graphics boards\n");*/
      return(1);
   }

   if (num_boards == 0) 
   {
      /*fprintf(stderr, "no graphics boards\n");*/
      return(1);
   }

   /* Malloc a buffer to hold graphics board info */
   if ((info = (struct gfx_info *)malloc(sizeof(*info))) == 0) 
   {
      /*fprintf(stderr, "malloc failed\n");*/
      return(1);
   }

   /* Set up structure data, ioctl to get board info */

   getboardinfo.board = 0;             /* graphics board number 0 */
   getboardinfo.buf =  (void *)info;   /* malloc'ed buffer        */
   getboardinfo.len = sizeof(*info);   /* buffer size             */

   if (ioctl(gfxfd, GFX_GETBOARDINFO, &getboardinfo) == -1) 
   {
      /*fprintf(stderr, "graphics getboardinfo failed\n");*/
      return(1);
   }

   if (!strcmp(info->name,"GR1"))
   {
      isnt_GR1 = FALSE;
   }
   else
   {
      isnt_GR1 = TRUE;
   }
   free(info);
   close(gfxfd);
        
   return(isnt_GR1);
}

#endif

/*--- WLget_wm_colors -----------------------------------------------*/

int WLget_wm_colors(
   WLuint32 context_no,
   int *num_entries,
   struct WLcmap_entry **cmap_entries,
   int *ingr_num_entries,
   struct WLcmap_entry **ingr_entries)

/*
NAME
	WLget_wm_colors
 
KEYWORD
	WL
 
DESCRIPTION
	This function returns the number of window manager colors

SYNOPSIS
	int WLget_wm_colors(
		WLuint32 context_no,
		int *num_entries,
		struct WLcmap_entry **cmap_entries,
		int *ingr_num_entries,
		struct WLcmap_entry **ingr_entries)
 
PARAMETERS
	context_no (IN) - The context number
	num_entires (OUT) - The number of window manager colors
	cmap_entries (OUT) - The colormap entries with the slot numbers
	ingr_num_entires (OUT) - The number of intergraph reserved colors
	ingr_entries (OUT) - The slot numbers and colors of intergraph reserved 
                             colors 

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_CONTEXT
		The context number is invalid

	WL_BAD_PARAMETER
		One of the pointers is NULL

RELATED INFORMATION

HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/
{
   int    sts;
   struct WLIcontext context_struct;
   struct WLIscreen screen_struct;
   struct WLcmap_entry *cmap_ptr;
   int  i, last_slot;
#if defined( X11 )
   int  phys_color_table_size;
   int  hilite_depth = 0;
   XColor color_defs[255];
   char *vendor;
   int pid;
   char *file_names[2];
   char graphics_board[255];
   char gfxinfo_output[80];
   int chars_read, cd;
   FILE *gfxinfo_output_file_ptr;
   static int special = -1;
#elif defined( ENV5 )
   int  hilite_depth = 0, j;
   struct vlt_slot vlt[25];
   int used_ingr;
#elif defined( WIN32 )
   PALETTEENTRY lppe[10];
#else
#error "A windowing system must be defined"
#endif
   
   if ( ( ingr_entries == NULL ) || ( cmap_entries == NULL ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   /* set to NULL, so caller can free properly */
   *ingr_entries = *cmap_entries = NULL;

   sts = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }  

   sts = WLIscreen_retrieve_entry( context_struct.lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }  

   if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      *ingr_num_entries = 0;
      *num_entries = 0;
      return( WL_SUCCESS ); 
   }

   /* No reserved colors if the depth < 4 */
   if ( context_struct.base_depth < 4 )
   {
      *ingr_num_entries = 0;
      *num_entries = 0;
      return( WL_SUCCESS );
   }

   if ( context_struct.base_depth < 7 )
   {
      *ingr_num_entries = 5;

      *ingr_entries = ( struct WLcmap_entry * ) malloc( 
                        sizeof( struct WLcmap_entry ) * ( *ingr_num_entries ) );
      
      /* Hardcoded intergraph values                                     */

      (*ingr_entries)[0].slot = 0;
      (*ingr_entries)[0].red = 0;
      (*ingr_entries)[0].green = 0;
      (*ingr_entries)[0].blue = 0;
      
      (*ingr_entries)[1].slot = 1;
      (*ingr_entries)[1].red = 0;
      (*ingr_entries)[1].green = 0xbaba;
      (*ingr_entries)[1].blue = 0;

      (*ingr_entries)[2].slot = 13;
      (*ingr_entries)[2].red = 0xbbbb;
      (*ingr_entries)[2].green = 0xbbbb;
      (*ingr_entries)[2].blue = 0xbbbb;

      (*ingr_entries)[3].slot = 14;
      (*ingr_entries)[3].red = 0x8888;
      (*ingr_entries)[3].green = 0x8888;
      (*ingr_entries)[3].blue = 0x8888;

      (*ingr_entries)[4].slot = 15;
      (*ingr_entries)[4].red = 0xeeee;
      (*ingr_entries)[4].green = 0xeeee;
      (*ingr_entries)[4].blue = 0xdddd;
   }
   else
   {
      *ingr_num_entries = 14;
      *ingr_entries = ( struct WLcmap_entry * ) malloc( 
                        sizeof( struct WLcmap_entry ) * ( *ingr_num_entries ) );
      
      /* Hardcoded intergraph values                                     */

      (*ingr_entries)[0].slot = 1;
      (*ingr_entries)[0].red = 61166;
      (*ingr_entries)[0].green = 61166;
      (*ingr_entries)[0].blue = 56797;

      (*ingr_entries)[1].slot = 2;
      (*ingr_entries)[1].red =  34952;
      (*ingr_entries)[1].green =  34952;
      (*ingr_entries)[1].blue =  34952;

      (*ingr_entries)[2].slot = 3;
      (*ingr_entries)[2].red = 0;
      (*ingr_entries)[2].green = 0;
      (*ingr_entries)[2].blue = 0;

      (*ingr_entries)[3].slot = 4;
      (*ingr_entries)[3].red = 65535;
      (*ingr_entries)[3].green = 65535;
      (*ingr_entries)[3].blue = 0;

      (*ingr_entries)[4].slot = 5;
      (*ingr_entries)[4].red = 48059;
      (*ingr_entries)[4].green = 48059;
      (*ingr_entries)[4].blue = 48059;

      (*ingr_entries)[5].slot = 6;
      (*ingr_entries)[5].red = 21845;
      (*ingr_entries)[5].green = 21845;
      (*ingr_entries)[5].blue = 21845;
      
      (*ingr_entries)[6].slot = 7;
      (*ingr_entries)[6].red = 65535;
      (*ingr_entries)[6].green = 65535;
      (*ingr_entries)[6].blue = 65535;

      (*ingr_entries)[7].slot = 8;
      (*ingr_entries)[7].red = 65535;
      (*ingr_entries)[7].green = 0;
      (*ingr_entries)[7].blue = 0;

      (*ingr_entries)[8].slot = 9;
      (*ingr_entries)[8].red = 0;
      (*ingr_entries)[8].green = 65535;
      (*ingr_entries)[8].blue = 0;

      (*ingr_entries)[9].slot = 10;
      (*ingr_entries)[9].red = 0;
      (*ingr_entries)[9].green = 0;
      (*ingr_entries)[9].blue = 65535;
      
      (*ingr_entries)[10].slot = 11;
      (*ingr_entries)[10].red = 65535;
      (*ingr_entries)[10].green = 65535;
      (*ingr_entries)[10].blue = 48059 ;
      
      (*ingr_entries)[11].slot = 12;
      (*ingr_entries)[11].red = 56797;
      (*ingr_entries)[11].green = 0;
      (*ingr_entries)[11].blue = 0;
      
      (*ingr_entries)[12].slot = 13;
      (*ingr_entries)[12].red = 0;
      (*ingr_entries)[12].green = 48059;
      (*ingr_entries)[12].blue = 0;
      
      (*ingr_entries)[13].slot = 14;
      (*ingr_entries)[13].red = 0;
      (*ingr_entries)[13].green = 0;
      (*ingr_entries)[13].blue = 52428;
   }

   *num_entries = 0;
   if (override_num_wm_colors == 0)
   {
      return( WL_SUCCESS );
   }

#if defined( X11 )

   vendor = ServerVendor( screen_struct.native_info.EXdisplay );

#if defined (IRIX)

   if ( !(strcmp( vendor, "Silicon Graphics" ) ) ) 
   {
      if (special == -1)
      {
         /* only do once */
         special = 0;
         if (WLIget_graphics_board())   
         {
            /* all of the graphics boards that are not GR1 have a seperate 
               hardware colormap so do not need window manager colors in the 
               color map we are loading */
   
            if ( MaxCmapsOfScreen( ScreenOfDisplay( screen_struct.native_info.EXdisplay,
                                       screen_struct.native_info.screen_no ) )
                > 1 )
            {
               *num_entries = 0;
               return( WL_SUCCESS );
            }
         }
         else
         {
            /* The graphics board it GR1 (turbo) and has 1 hw color map */
            /* we want color 0-28 */
            if (override_num_wm_colors == -1)
            {
               special = 29;
            }
            else
            {
               special = override_num_wm_colors;
            }
         }
      }
      else
      {
         if ( special == 0 )
         {
             *num_entries = 0;
            return( WL_SUCCESS );
         }
      }
      
   }
   else
#endif
#if !defined ( SUNOS ) && !defined ( SOLARIS ) && !defined (SUNOS54) && !defined (SUNOS55) 
   {
      /* not on SGI machine test num cmaps.  On Sgi the Cmaps of screen is 
         giving the total number of cmaps instead of the number of hardware 
         color maps. */
      if (MaxCmapsOfScreen( ScreenOfDisplay( screen_struct.native_info.EXdisplay,
                              screen_struct.native_info.screen_no ) )
           /*> 1 )*/
           > 3 )
/*  I set this to 3 because that's what's returned on the ZX... Mike */
      {
         *num_entries = 0;
         return( WL_SUCCESS );
      }
   }
#endif

  if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
  {
     if ( context_struct.base_depth + hilite_depth < 7 )
     {
         if (override_num_wm_colors == -1)
         {
           *num_entries = 5;
         }
         else
         {
           *num_entries = override_num_wm_colors;
         }
        *cmap_entries = ( struct WLcmap_entry * ) malloc( 
                           sizeof( struct WLcmap_entry ) * (*num_entries ) );
        for ( i = 0; i < *num_entries; i++ )
        {
            color_defs[i].pixel = i;
            color_defs[i].flags = DoRed | DoGreen | DoBlue;
        }
         
     }
     else
     {
	if ( special > 0 )
        {
           /* SGI turbo graphics board "GR1" with 1 hw color map */
           *num_entries = special;
        }
        else
        {
           if ( !(strcmp( vendor, "Intergraph Corporation" ) ) ) 
           {
              /* 0-19 and last slot for intergraph (255 for 8 planes and 511 for 9 planes)*/
               if (override_num_wm_colors == -1)
               {
                 *num_entries = 21;
               }
               else
               {
                 *num_entries = override_num_wm_colors;
               }
           }
           else 
           {
              /* Sun and any other platform left */  
               if (override_num_wm_colors == -1)
               {
                 *num_entries = 16;
               }
               else
               {
                 *num_entries = override_num_wm_colors;
               }
#if defined( XGL )
               /* Special for sharing colormaps with overlay planes */
               (*num_entries)++;
#endif
           }
        }
        *cmap_entries = ( struct WLcmap_entry * ) malloc( 
                             sizeof( struct WLcmap_entry ) * ( *num_entries ) );
        for ( i = 0; i < (*num_entries) -1 ; i++ )
        {
            color_defs[i].pixel = i;
            color_defs[i].flags = DoRed | DoGreen | DoBlue;
        }

        if ( !(strcmp( vendor, "Intergraph Corporation" ) ) ) 
        {
           /* Intergraph has screen foreground at last slot that needs to be saved */

           /* the physical table size is base depth + 1 for hilite if used and not seperate */
           phys_color_table_size = context_struct.base_depth + 
              (( (context_struct.hilite_used == TRUE) && (!(context_struct.flags & WL_SEPARATE_HILITE)) ) ? 1 : 0 );

           /* the last slot of the table */
           color_defs[*num_entries - 1].pixel = (1 << phys_color_table_size) - 1;
           color_defs[*num_entries - 1].flags = DoRed | DoGreen | DoBlue;
        }
        else
        {
#if defined( XGL )
           phys_color_table_size = context_struct.base_depth + 
              (( (context_struct.hilite_used == TRUE) && (!(context_struct.flags & WL_SEPARATE_HILITE)) ) ? 1 : 0 );

           color_defs[(*num_entries)-1].pixel=(1 << phys_color_table_size) - 1;
           color_defs[(*num_entries)-1].flags=DoRed | DoGreen | DoBlue;
#else
           /* for other vendors just take the first colors */
           color_defs[(*num_entries) - 1].pixel = (*num_entries) - 1;
           color_defs[(*num_entries) - 1].flags = DoRed | DoGreen | DoBlue;
#endif
        }
     }

     cmap_ptr = default_cmap[context_struct.lscreen_no].cmap_entry;
     if ( cmap_ptr )
     {
        for ( i = 0, cd = 0; i < *num_entries; i++, cd++ )
        {
           if ( (cd >= 2) &&
                (cmap_ptr[cd].slot == cmap_ptr[cd - 1].slot + 1) &&
                (cmap_ptr[cd].slot == cmap_ptr[cd - 2].slot + 2) &&
                (cmap_ptr[cd].red   == cmap_ptr[cd - 1].red) &&
                (cmap_ptr[cd].red   == cmap_ptr[cd - 2].red) &&
                (cmap_ptr[cd].green == cmap_ptr[cd - 1].green) &&
                (cmap_ptr[cd].green == cmap_ptr[cd - 2].green) &&
                (cmap_ptr[cd].blue  == cmap_ptr[cd - 1].blue) &&
                (cmap_ptr[cd].blue  == cmap_ptr[cd - 2].blue) )
           {
              /* NOTE: WHEN COMMAND LINE NUMBER OF WINDOW MANAGER COLORS */
              /* IS IMPLEMENTED, WE PROBABLY DON'T WANT THIS CASE, GIVE*/
              /* THE USER WHAT THEY ASKED FOR.*/
              /* 3 colors exactly the same in sequence, only allow 2 */
              /* because they are probably not being used */
              (*num_entries)--;
              i--;
           }
           else
           {
              (*cmap_entries)[i].slot  = cmap_ptr[cd].slot;
              (*cmap_entries)[i].red   = cmap_ptr[cd].red;
              (*cmap_entries)[i].green = cmap_ptr[cd].green;
              (*cmap_entries)[i].blue  = cmap_ptr[cd].blue;
           }
        }
     }
     else
     {  

        XQueryColors( screen_struct.native_info.EXdisplay, 
                      DefaultColormap( screen_struct.native_info.EXdisplay,
                                       screen_struct.native_info.screen_no ),
                      color_defs, *num_entries );

        for ( i = 0, cd = 0; i < *num_entries; i++, cd++ )
        {
           if ( (cd >= 2) &&
                (color_defs[cd].pixel == color_defs[cd - 1].pixel + 1) &&
                (color_defs[cd].pixel == color_defs[cd - 2].pixel + 2) &&
                (color_defs[cd].red   == color_defs[cd - 1].red) &&
                (color_defs[cd].red   == color_defs[cd - 2].red) &&
                (color_defs[cd].green == color_defs[cd - 1].green) &&
                (color_defs[cd].green == color_defs[cd - 2].green) &&
                (color_defs[cd].blue  == color_defs[cd - 1].blue) &&
                (color_defs[cd].blue  == color_defs[cd - 2].blue) )
           {
              /* NOTE: WHEN COMMAND LINE NUMBER OF WINDOW MANAGER COLORS */
              /* IS IMPLEMENTED, WE PROBABLY DON'T WANT THIS CASE, GIVE*/
              /* THE USER WHAT THEY ASKED FOR.*/
              /* 3 colors exactly the same in sequence, only allow 2 */
              /* because they are probably not being used */
              (*num_entries)--;
              i--;
           }
           else
           {
              (*cmap_entries)[i].slot  = color_defs[cd].pixel;
              (*cmap_entries)[i].red   = color_defs[cd].red;
              (*cmap_entries)[i].green = color_defs[cd].green;
              (*cmap_entries)[i].blue  = color_defs[cd].blue;
           }
        }
     }
   }

#elif defined( ENV5 )
   if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
   {
      if ( context_struct.hilite_used )  
      {
         hilite_depth = 1;
      }
      else
      {
         hilite_depth = 0;
      }
      if ( context_struct.base_depth + hilite_depth < 7 )
      {
         if (override_num_wm_colors == -1)
         {
           *num_entries = 5;
         }
         else
         {
           *num_entries = override_num_wm_colors;
         }
         *cmap_entries = ( struct WLcmap_entry * ) malloc( 
                            sizeof( struct WLcmap_entry ) * (*num_entries ) );
         for ( i = 0; i < *num_entries; i++ )
         {
            (*cmap_entries)[i].slot = (*ingr_entries)[i].slot;
            (*cmap_entries)[i].red = (*ingr_entries)[i].red;
            (*cmap_entries)[i].green = (*ingr_entries)[i].green;
            (*cmap_entries)[i].blue = (*ingr_entries)[i].blue;
         }
         
      }
      else
      {
         /* here is an example of how it will work out 
            vlt[]                    0  1  2  3  4  5  6
            actual phys table[]      0 15 16 17 18 19 255
            cmap_entries[]          14 16 17 18 19 20 15
         */

         /* 0-19 and last slot */
         if (override_num_wm_colors == -1)
         {
            *num_entries = 21;
         }
         else
         {
            *num_entries = override_num_wm_colors;
         }
         *cmap_entries = ( struct WLcmap_entry * ) malloc( 
                            sizeof( struct WLcmap_entry ) * (*num_entries ) );

         if ((used_ingr = *ingr_num_entries) > *num_entries)
         {
            used_ingr = *num_entries;
         }

         for ( i = 0; i < used_ingr; i++ )
         {
            (*cmap_entries)[i].slot = (*ingr_entries)[i].slot;
            (*cmap_entries)[i].red = (*ingr_entries)[i].red;
            (*cmap_entries)[i].green = (*ingr_entries)[i].green;
            (*cmap_entries)[i].blue = (*ingr_entries)[i].blue;
         }

         cmap_ptr = default_cmap[context_struct.lscreen_no].cmap_entry;
         if ( cmap_ptr )
         {
            if (*num_entries > used_ingr)
            {
               (*cmap_entries)[*ingr_num_entries].slot = cmap_ptr[0].slot;
               (*cmap_entries)[*ingr_num_entries].red = cmap_ptr[0].red;
               (*cmap_entries)[*ingr_num_entries].green = cmap_ptr[0].green;
               (*cmap_entries)[*ingr_num_entries].blue = cmap_ptr[0].blue;
            }

            last_slot = default_cmap[context_struct.lscreen_no].size_of_cmap - 1;
            if (*num_entries > used_ingr + 1)
            {
               (*cmap_entries)[*ingr_num_entries + 1].slot = last_slot;
               (*cmap_entries)[*ingr_num_entries + 1].red = cmap_ptr[last_slot].red;
               (*cmap_entries)[*ingr_num_entries + 1].green = cmap_ptr[last_slot].green;
               (*cmap_entries)[*ingr_num_entries + 1].blue = cmap_ptr[last_slot].blue;
            }

            for ( i = *ingr_num_entries + 2, j=*ingr_num_entries + 1; i < *num_entries; i++, j++ )
            {
               (*cmap_entries)[i].slot = j;
               (*cmap_entries)[i].red = cmap_ptr[j].red;
               (*cmap_entries)[i].green = cmap_ptr[j].green;
               (*cmap_entries)[i].blue = cmap_ptr[j].blue;
            }
         }
         else
         {
            if (*num_entries > used_ingr)
            {
               vlt[0].v_slot = 0;
               Readvlt( screen_struct.native_info.screen_no, &vlt[0], 1, vlt[0].v_slot );
               (*cmap_entries)[used_ingr].slot = vlt[0].v_slot;
               (*cmap_entries)[used_ingr].red = vlt[0].v_red;
               (*cmap_entries)[used_ingr].green = vlt[0].v_green;
               (*cmap_entries)[used_ingr].blue = vlt[0].v_blue;
            }

            if (*num_entries > used_ingr + 2)
            {
               for ( i = 1; i <= *num_entries - 2 - used_ingr; i++ )
               {
                  vlt[i].v_slot = *ingr_num_entries + i;
               }
               Readvlt( screen_struct.native_info.screen_no, &vlt[1], *num_entries - 2 - used_ingr, 
                  vlt[1].v_slot );
               for ( i = used_ingr + 2, j=1; i < *num_entries; i++, j++ )
               {
                  (*cmap_entries)[i].slot = vlt[j].v_slot;
                  (*cmap_entries)[i].red = vlt[j].v_red;
                  (*cmap_entries)[i].green = vlt[j].v_green;
                  (*cmap_entries)[i].blue = vlt[j].v_blue;
               }
            }

            if (*num_entries > used_ingr + 1)
            {
               vlt[*num_entries - 1 - used_ingr].v_slot = (1 << (context_struct.base_depth + hilite_depth)) - 1;
               Readvlt( screen_struct.native_info.screen_no, &vlt[*num_entries - 1 - used_ingr], 
                  1, vlt[*num_entries - 1 - used_ingr].v_slot );
               (*cmap_entries)[used_ingr + 1].slot = vlt[*num_entries - 1 - used_ingr].v_slot;
               (*cmap_entries)[used_ingr + 1].red = vlt[*num_entries - 1 - used_ingr].v_red;
               (*cmap_entries)[used_ingr + 1].green = vlt[*num_entries - 1 - used_ingr].v_green;
               (*cmap_entries)[used_ingr + 1].blue = vlt[*num_entries - 1 - used_ingr].v_blue;
            }
         }
      }
   }
#elif defined( WIN32 )
   if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
   {
      if ( context_struct.base_depth <= 4 )
      {
         *num_entries = 16;
         *cmap_entries = ( struct WLcmap_entry * ) malloc( 
                            sizeof( struct WLcmap_entry ) * ( *num_entries ) );
         if ( !cmap_entries )
         {
             WL_REPORT_ERROR( WL_ERROR );
             return( WL_ERROR );
         }
         for ( i = 0; i < 16; i++ )
         {
            (*cmap_entries)[i].slot = i;
         } 
         (*cmap_entries)[8].red = 0x8080;
         (*cmap_entries)[8].green = 0x8080;
         (*cmap_entries)[8].blue = 0x8080;
         
         (*cmap_entries)[9].red = 0xffff;
         (*cmap_entries)[9].green = 0x0000;
         (*cmap_entries)[9].blue = 0x0000;

         (*cmap_entries)[10].red = 0x0000;
         (*cmap_entries)[10].green = 0xffff;
         (*cmap_entries)[10].blue = 0x0000;
        
         (*cmap_entries)[11].red = 0xffff;
         (*cmap_entries)[11].green = 0xffff;
         (*cmap_entries)[11].blue = 0x0000;

         (*cmap_entries)[12].red = 0x0000;
         (*cmap_entries)[12].green = 0x0000;
         (*cmap_entries)[12].blue = 0xffff;
         
         (*cmap_entries)[13].red = 0xffff;
         (*cmap_entries)[13].green = 0x0000;
         (*cmap_entries)[13].blue = 0xffff;

         (*cmap_entries)[14].red = 0x0000;
         (*cmap_entries)[14].green = 0xffff;
         (*cmap_entries)[14].blue = 0xffff;
        
         (*cmap_entries)[15].red = 0xffff;
         (*cmap_entries)[15].green = 0xffff;
         (*cmap_entries)[15].blue = 0xffff;
      }
      else
      {
         *num_entries = 20;
         (*cmap_entries) = ( struct WLcmap_entry * ) malloc( 
                            sizeof( struct WLcmap_entry ) * ( *num_entries ) );
         if ( !(cmap_entries) )
         {
             WL_REPORT_ERROR( WL_ERROR );
             return( WL_ERROR );
         }
         sts = GetPaletteEntries( context_struct.native_info.palette,
                                  8, 4, lppe );
         if ( !sts )
         {
             WL_REPORT_ERROR( WL_SYSTEM_ERROR );
             return( WL_SYSTEM_ERROR );
         }
         for ( i = 0; i < 20; i++ )
         {
            (*cmap_entries)[i].slot = i;
         }
         for ( i = 0; i < 4; i++ )
         {
            (*cmap_entries)[8 + i].red = lppe[i].peRed << 8 ;
            (*cmap_entries)[8 + i].green = lppe[i].peGreen << 8 ;
            (*cmap_entries)[8 + i].blue = lppe[i].peBlue << 8 ;
         }
         (*cmap_entries)[12].red = 0x8080;
         (*cmap_entries)[12].green = 0x8080;
         (*cmap_entries)[12].blue = 0x8080;
         
         (*cmap_entries)[13].red = 0xffff;
         (*cmap_entries)[13].green = 0x0000;
         (*cmap_entries)[13].blue = 0x0000;

         (*cmap_entries)[14].red = 0x0000;
         (*cmap_entries)[14].green = 0xffff;
         (*cmap_entries)[14].blue = 0x0000;
        
         (*cmap_entries)[15].red = 0xffff;
         (*cmap_entries)[15].green = 0xffff;
         (*cmap_entries)[15].blue = 0x0000;

         (*cmap_entries)[16].red = 0x0000;
         (*cmap_entries)[16].green = 0x0000;
         (*cmap_entries)[16].blue = 0xffff;
         
         (*cmap_entries)[17].red = 0xffff;
         (*cmap_entries)[17].green = 0x0000;
         (*cmap_entries)[17].blue = 0xffff;

         (*cmap_entries)[18].red = 0x0000;
         (*cmap_entries)[18].green = 0xffff;
         (*cmap_entries)[18].blue = 0xffff;
        
         (*cmap_entries)[19].red = 0xffff;
         (*cmap_entries)[19].green = 0xffff;
         (*cmap_entries)[19].blue = 0xffff;

      }
      (*cmap_entries)[0].red = 0x0000;
      (*cmap_entries)[0].green = 0x0000;
      (*cmap_entries)[0].blue = 0x0000;

      (*cmap_entries)[1].red = 0x8080;
      (*cmap_entries)[1].green = 0x0000;
      (*cmap_entries)[1].blue = 0x0000;

      (*cmap_entries)[2].red = 0x0000;
      (*cmap_entries)[2].green = 0x8080;
      (*cmap_entries)[2].blue = 0x0000;
        
      (*cmap_entries)[3].red = 0x8080;
      (*cmap_entries)[3].green = 0x8080;
      (*cmap_entries)[3].blue = 0x0000;

      (*cmap_entries)[4].red = 0x0000;
      (*cmap_entries)[4].green = 0x0000;
      (*cmap_entries)[4].blue = 0x8080;
         
      (*cmap_entries)[5].red = 0x8080;
      (*cmap_entries)[5].green = 0x0000;
      (*cmap_entries)[5].blue = 0x8080;

      (*cmap_entries)[6].red = 0x0000;
      (*cmap_entries)[6].green = 0x8080;
      (*cmap_entries)[6].blue = 0x8080;
        
      (*cmap_entries)[7].red = 0xc0c0;
      (*cmap_entries)[7].green = 0xc0c0;
      (*cmap_entries)[7].blue = 0xc0c0;


   }
#else   
#error "A windowing system must be defined"
#endif
   return( WL_SUCCESS );   

}

/*--- WLget_number_of_color_cells -------------------------------------------*/
 
int WLget_number_of_color_cells(
   WLuint32 context_no,
   int *num_of_cells )
/*
NAME
   WLget_number_of_color_cells
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the number of color cells supported for a context.

SYNOPSIS
   int WLget_number_of_color_cells(
      WLuint32 context_no,
      int *num_of_cells )

 
PARAMETERS
   context_no (IN)  - context number
   num_of_cells (OUT) - the number of color cells for the context
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_CONTEXT
      The context is invalid
 
   WL_BAD_PARAMETER
      The "num_of_cells" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status ;
   int hilite_depth;
   struct WLIcontext context_struct;

   if (num_of_cells == NULL)
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );   
      return( WL_BAD_PARAMETER );
   }
   status = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );   
      return( WL_BAD_PARAMETER );
   }
   /* get the default depth of the screen.                           */
   /* use the combination of context_info and screen depth to return */
   /* the number of cells. for eg if                                 */
   if ( context_struct.hilite_used & WL_HILITE_USED )
   {
      hilite_depth = 1;
   }
   else 
   {
      hilite_depth = 0;
   }

   if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      *num_of_cells = 1 << ( context_struct.base_depth/3  );
   }
   else
   {
      *num_of_cells = 1 << ( context_struct.base_depth + hilite_depth );
   }

   return( WL_SUCCESS );
}  /* Wlget_number_of_color_cells */

