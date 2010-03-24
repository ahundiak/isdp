#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

#if defined( XGL )
static Colormap share_indexed_cmap_with_xgl = NULL;
static int      set_by_hilite=1;
static int      xgl_hilite_depth = 0;
#endif

/*
 *  Use this macro to dump info about the visuals returned by functions
 *  like XGetVisualInfo or glXChooseVisual.
 */

#define DEBUG_VISUALS	0

#if DEBUG_VISUALS
#define	DUMP_VISUAL_INFO( vis ) \
{ \
int	value; \
int	status; \
 \
fprintf( stderr, "Visual information\n" ); \
fprintf( stderr, "   VisualID      : %d\n", (vis)->visualid ); \
fprintf( stderr, "   screen        : %d\n", (vis)->screen ); \
fprintf( stderr, "   depth         : %d\n", (vis)->depth ); \
fprintf( stderr, "   class         : %d\n", (vis)->class ); \
fprintf( stderr, "   red_mask      : %d\n", (vis)->red_mask ); \
fprintf( stderr, "   green_mask    : %d\n", (vis)->green_mask ); \
fprintf( stderr, "   blue_mask     : %d\n", (vis)->blue_mask ); \
fprintf( stderr, "   colormap_size : %d\n", (vis)->colormap_size ); \
fprintf( stderr, "   bits_per_rgb  : %d\n", (vis)->bits_per_rgb ); \
fprintf( stderr, "   Config        :\n" ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_USE_GL, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_USE_GL           : %d\n", value ); \
else \
fprintf( stderr, "      GLX_USE_GL           : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_BUFFER_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_BUFFER_SIZE      : %d\n", value ); \
else \
fprintf( stderr, "      GLX_BUFFER_SIZE      : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_LEVEL, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_LEVEL            : %d\n", value ); \
else \
fprintf( stderr, "      GLX_LEVEL            : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_RGBA, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_RGBA             : %d\n", value ); \
else \
fprintf( stderr, "      GLX_RGBA             : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_DOUBLEBUFFER, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_DOUBLEBUFFER     : %d\n", value ); \
else \
fprintf( stderr, "      GLX_DOUBLEBUFFER     : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_STEREO, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_STEREO           : %d\n", value ); \
else \
fprintf( stderr, "      GLX_STEREO           : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_AUX_BUFFERS, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_AUX_BUFFERS      : %d\n", value ); \
else \
fprintf( stderr, "      GLX_AUX_BUFFERS      : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_RED_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_RED_SIZE         : %d\n", value ); \
else \
fprintf( stderr, "      GLX_RED_SIZE         : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_GREEN_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_GREEN_SIZE       : %d\n", value ); \
else \
fprintf( stderr, "      GLX_GREEN_SIZE       : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_BLUE_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_BLUE_SIZE        : %d\n", value ); \
else \
fprintf( stderr, "      GLX_BLUE_SIZE        : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_ALPHA_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_ALPHA_SIZE       : %d\n", value ); \
else  \
fprintf( stderr, "      GLX_ALPHA_SIZE       : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_DEPTH_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_DEPTH_SIZE       : %d\n", value ); \
else \
fprintf( stderr, "      GLX_DEPTH_SIZE       : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_STENCIL_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_STENCIL_SIZE     : %d\n", value ); \
else \
fprintf( stderr, "      GLX_STENCIL_SIZE     : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_ACCUM_RED_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_ACCUM_RED_SIZE   : %d\n", value ); \
else \
fprintf( stderr, "      GLX_ACCUM_RED_SIZE   : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_ACCUM_GREEN_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_ACCUM_GREEN_SIZE : %d\n", value ); \
else \
fprintf( stderr, "      GLX_ACCUM_GREEN_SIZE : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_ACCUM_BLUE_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_ACCUM_BLUE_SIZE  : %d\n", value ); \
else \
fprintf( stderr, "      GLX_ACCUM_BLUE_SIZE  : error return from glXGetConfig: %x\n", status ); \
 \
status = glXGetConfig( screen_struct.native_info.EXdisplay, \
                       (vis), \
                       GLX_ACCUM_ALPHA_SIZE, \
                       &value ); \
 \
if( status == 0 ) \
fprintf( stderr, "      GLX_ACCUM_ALPHA_SIZE : %d\n", value ); \
else \
fprintf( stderr, "      GLX_ACCUM_ALPHA_SIZE : error return from glXGetConfig: %x\n", status ); \
}
#endif /* DEBUG_VISUALS */

/*---WLcreate_context-----------------------------------------------*/

int WLcreate_context(
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
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
      WLuint32 context_no ),
   WLuint32 *context_no)

/*
NAME
	WLcreate_context
 
KEYWORD
	WL 
 
DESCRIPTION
	This function creates a new context using the context information and
	returns the context number.

SYNOPSIS
	int WLcreate_context(
		WLuint16 lscreen_no,
		struct WLcontext_info *context,
		int (*cmap_color_to_index)(),
		int (*cmap_color_to_rgb)(),
		int (*cmap_init)(),
		WLuint32 *context_no)

PARAMETERS
	lscreen_no (IN) - The logical screen number.
	context (IN) - The context information
	cmap_color_to_index (IN) -Function pointer.This function helps translate
                                 the RGB values or logical index to a physical 
                                 index.
	cmap_color_to_rgb (IN) - Function pointer.This function helps translate
                                 the RGB values or logical index to new RGB 
				 values
	cmap_init (IN) - Function pointer. This function initializes the
                              colormap
	context_no (OUT) - The context number. 

NOTES
	The synopsis of the colormap functions is:
	cmap_color_to_index(
		WLuint32 context_no,
		WLuint32 index,
		WLuint32 red,
		WLuint32 green,
		WLuint32 blue,
		WLuint32 flag,
		WLuint32 *phy_index)
        context_no (IN) - The context number
	index (IN) - The logical color index
	red (IN) - The red component
	green (IN) - The green component
	blue (IN) - The blue component
	flag (IN) - indicates whether index or rgb should be used in the 
		    conversion
	phy_index (OUT) - The physical index
	
	cmap_color_to_rgb(
		WLuint32 context_no,
		WLuint32 index,
		WLuint32 red,
		WLuint32 green,
		WLuint32 blue,
		WLuint32 flag,
		WLuint32 *out_red,
		WLuint32 *out_green,
		WLuint32 *out_blue,
        context_no (IN) - The context number
	index (IN) - The logical color index
	red (IN) - The red component
	green (IN) - The green component
	blue (IN) - The blue component
	flag (IN) - indicates whether index or rgb should be used in the 
		    conversion
	out_red (OUT) - The converted red component
	out_green (OUT) - The converted green component
	out_blue (OUT) - The converted blue component

	cmap_init(
		WLuint32 context_no)
        context_no (IN) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
   		The logical screen number is invalid

	WL_BAD_CONTEXT
		The context information is invalid

	WL_BAD_PARAMETER
		One of the pointers is NULL

	WL_SYSTEM_ERROR
		A windowing system error occurred

RELATED INFORMATION
	Functions:  WLadd_context_to_window(), WLdisplay_window(),WLdelete_window()

HISTORY
	08/28/92 S.P.Rogers, Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design

        10/07/96 S.Walters
                Added SUNOS55 options
*/
{
   int    sts;
   struct  WLIscreen     screen_struct;
   struct  WLnative_info native_info;
   int    hilite_depth;
#if defined( X11 )
   Colormap       cmap, hl_cmap;
   int            class;
   int            num_avail;
   XVisualInfo    *vinfo, *avail_visuals, *hl_avail_visuals = NULL, vinfo_template, *hl_vinfo;
#if defined( OPENGL )
   int chosen_index;
   int (*choose_func)( struct WLcontext_info *, XVisualInfo *, int, int *);
   int glx_value;
#endif
#if defined( X11 ) && (defined( SUNOS54 ) || defined( SUNOS55 ))
   XSolarisOvlVisualCriteria pcriteria;
   unsigned long unmet_criteria;
#endif
#elif defined( ENV5 )
   int            vlt_no;
   int            win_no;
   int            flags;
#elif defined( WIN32 )
   LOGPALETTE     pal;
 #endif

#  if DEBUG_VISUALS
   fprintf( stderr, "WLcreate_context*************************\n" );
#  endif

   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }

   if ( context == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   if ( ( context->base_cmap_type != WL_CMAP_INDEXED ) &&   
        ( context->base_cmap_type != WL_CMAP_TRUE_COLOR ) )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   if ( ( cmap_color_to_index == NULL ) || ( cmap_color_to_rgb == NULL ) ||
        ( cmap_init == NULL ) || ( context_no == NULL ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   hilite_depth = (context->hilite_used) ? 1 : 0;

#if defined( X11 )

   if ( context->base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      class = (context->flags & WL_COLORMAP_READ_ONLY) ?
              TrueColor : DirectColor;

      /*** BEGIN KLUDGE */
      context->flags |= WL_COLORMAP_READ_ONLY;
      class = TrueColor;
      /** END KLUDGE **/

   }
   else 
   {
      class = (context->flags & WL_COLORMAP_READ_ONLY) ?
              StaticColor : PseudoColor;
   }

   /* get the available visuals for the display that */
   /* match the screen number, class, and depth      */
   vinfo_template.screen = screen_struct.native_info.screen_no;
   vinfo_template.class = class;
   if ( context->flags & WL_SEPARATE_HILITE )
   {
      vinfo_template.depth = context->base_depth;
   }
   else
   {
      vinfo_template.depth = context->base_depth + hilite_depth;
   }
   avail_visuals = XGetVisualInfo( screen_struct.native_info.EXdisplay,
                                   VisualScreenMask | VisualClassMask | VisualDepthMask,
                                   &vinfo_template, &num_avail );

   if ( ! avail_visuals )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   vinfo = &avail_visuals[0];

#  if DEBUG_VISUALS
   {
   int	iii;
   fprintf( stderr, "Visuals returned by XGetVisualInfo: %d\n", num_avail );
   for( iii=0; iii<num_avail; iii++ )
      {
      DUMP_VISUAL_INFO( (&avail_visuals[iii]) )
      }
   }
#  endif

#if defined( OPENGL )
   if ( screen_struct.flags & WLI_SCREEN_FLAGS_GLX_AVAILABLE )
   {
      WLglx_get_choose_visual_function( &choose_func );
      if ( choose_func )
      {
         /* call application function to choose the OpenGL visual that it wants */
         (*choose_func)( context, avail_visuals, num_avail, &chosen_index );
         if ( (chosen_index >= 0 ) && (chosen_index < num_avail) )
         {
            vinfo = &avail_visuals[chosen_index];
            context->flags |= WL_USING_OPENGL;
         }
      }
   }
if( context->base_depth == 8 )
{
         static int	attrib[] = { GLX_BUFFER_SIZE, 8,
                                     GLX_LEVEL, 0, 
                                     GLX_DEPTH_SIZE, 20,
                                     GLX_STENCIL_SIZE, 4,
                                     None };

         avail_visuals = glXChooseVisual( screen_struct.native_info.EXdisplay,
                                             screen_struct.native_info.screen_no,
                                             attrib );
#     if DEBUG_VISUALS
      fprintf( stderr, "Visual returned by glXChooseVisual\n" );
      DUMP_VISUAL_INFO( (&avail_visuals[0]) )
#     endif

      vinfo = &avail_visuals[0];
}
#endif
#if defined( XGL )
   if ( screen_struct.flags & WLI_SCREEN_FLAGS_XGL_AVAILABLE )
   {
      context->flags |= WL_USING_XGL;
   }
#endif

#  if FALSE
      XSynchronize( screen_struct.native_info.EXdisplay, 1 );
#  endif

   /* Root window is used for getting the screen   */
   /* and not for visual purposes                  */

   if( context->flags & WL_COLORMAP_READ_ONLY )
      {
      cmap = XCreateColormap( screen_struct.native_info.EXdisplay, 
                              RootWindow( screen_struct.native_info.EXdisplay,
                                          screen_struct.native_info.screen_no ),
                              vinfo->visual, AllocNone );
      }
   else
      {
      cmap = XCreateColormap( screen_struct.native_info.EXdisplay, 
                              RootWindow( screen_struct.native_info.EXdisplay,
                                          screen_struct.native_info.screen_no ),
                              vinfo->visual, AllocAll );
      }

#  if defined( XGL )
      {
      if ( context->flags & WL_USING_XGL )
         {
         native_info.xgl_base_cmap = xgl_object_create( screen_struct.native_info.sys_state,
                                                        XGL_CMAP, NULL, 
                                                        XGL_CMAP_NAME,cmap,
                                                        XGL_CMAP_COLOR_TABLE_SIZE,
                                                        vinfo->colormap_size,NULL );
   
         }
      }
#  endif /* XGL */
    
   /* Create a colormap for the hilight plane, if there is a separate one */

   if ( context->flags & WL_SEPARATE_HILITE )
      {

      /*  if X11 and Solaris 5.4 or greater, get the available hilite plane visuals */
      /*  from the special Overlay functions added for XGL */

#     if defined( X11 ) && (defined( SUNOS54 ) || defined( SUNOS55 ))
         {
         hl_avail_visuals = (XVisualInfo *) malloc( sizeof (XVisualInfo ));

         pcriteria.hardCriteriaMask = XSolarisOvlPreferredPartner |
                                      XSolarisOvlUnsharedPixels;
         pcriteria.softCriteriaMask = 0;

         sts = XSolarisOvlSelectPartner( screen_struct.native_info.EXdisplay,
                                         screen_struct.native_info.screen_no,
                                         vinfo->visualid, XSolarisOvlSelectBestOverlay, 1, 
                                         &pcriteria, hl_avail_visuals, &unmet_criteria );

         if ( sts !=XSolarisOvlSuccess && sts != XSolarisOvlQualifiedSuccess )
            {
            printf("Status %x \n", sts );
            WL_REPORT_ERROR( WL_SYSTEM_ERROR );
            return( WL_SYSTEM_ERROR );
            }
         num_avail = 1;
         }
#     else /* X11 and (SUNOS54 or SUNOS55) */
         {
         long	vinfo_mask;
         int	attrib[5];

         /*
          *  According to Tom True at SGI, the following with GLX_LEVEL at 1 
          *  is supposed to fine the transparent visual on any platform.  Running
          *  on the Indy with GLX_LEVEL at 1, I get a visual of depth 8 which
          *  causes EMS to abort.  Running with GLX_LEVEL at 2, I get a visual of
          *  depth 2, which is what I want.  The old way of finding the visual,
          *  which is what I have in place, works fine on the indy. 
          *  Mike Lanier (11/7/96)
          */

#        if defined (OPENGLx)
         attrib[0] = GLX_BUFFER_SIZE;
         attrib[1] = 2;
         attrib[2] = GLX_LEVEL;
         attrib[3] = 2;
         attrib[4] = None;

         hl_avail_visuals = glXChooseVisual( screen_struct.native_info.EXdisplay,
                                             screen_struct.native_info.screen_no,
                                             attrib );

#        else
         vinfo_mask = VisualScreenMask | VisualClassMask | VisualDepthMask;

         vinfo_template.screen = screen_struct.native_info.screen_no;
         vinfo_template.class = PseudoColor;
         vinfo_template.depth = 2;

         hl_avail_visuals = XGetVisualInfo( screen_struct.native_info.EXdisplay,
                                            vinfo_mask,
                                            &vinfo_template, &num_avail );
#        endif /* OPENGL */


#        if defined (OPENGL)

         /*
          *  The SGI/Impact workstation does not support 2 plane visuals.
          *  If the search for a 2 plane visual fails, then search for a 4
          *  plane visual.  Since this change is a result of the SGI/Impact
          *  confine this change to the SGI platform.  (Mike Lanier 4/1/96)
          *  found that the latest 5.3 operating system does not support 4
          *  plane visuals as well.  Therefore, if a search for 4 fails, look
          *  for an 8.
          */

         if ( !hl_avail_visuals )
            {
            vinfo_template.depth = 4;
            hl_avail_visuals = XGetVisualInfo( screen_struct.native_info.EXdisplay,
                                               vinfo_mask,
                                               &vinfo_template, &num_avail );
            }

         if ( !hl_avail_visuals )
            {

            /*
             *  The following will find a transparent visuals on the Impact, but
             *  am having problem with Xlib errors when XQueryColors is called
             */

            attrib[0] = GLX_BUFFER_SIZE;
            attrib[1] = 2;
            attrib[2] = GLX_LEVEL;
            attrib[3] = 1;
            attrib[4] = None;

            hl_avail_visuals = glXChooseVisual( screen_struct.native_info.EXdisplay,
                                                screen_struct.native_info.screen_no,
                                                attrib );

            /*
            vinfo_template.depth = 8;
            hl_avail_visuals = XGetVisualInfo( screen_struct.native_info.EXdisplay,
                                               vinfo_mask,
                                               &vinfo_template, &num_avail );
            */
            }
#        endif /* OPENGL */
         }
#     endif /* X11 and (SUNOS54 or SUNOS55) - else */

      /* If we didn't find any hl visuals, then return with an error */

      if ( !hl_avail_visuals )
         {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
         }

      hl_vinfo = &hl_avail_visuals[0];

      /* Create the colormap object for the hilite plane */
      /* Root window is used for getting the screen*/
      /* and not for visual purposes               */

      hl_cmap = XCreateColormap( screen_struct.native_info.EXdisplay, 
                                 RootWindow( screen_struct.native_info.EXdisplay,
                                             screen_struct.native_info.screen_no ),
                                 hl_vinfo->visual, AllocNone );

      /*  If XGL, create 32 colorcells (that's all you'll need, but you'll need to */
      /*  remember this later) for the hilite colormap object.  Then create an XGL */
      /*  colormap object */

#     if defined( XGL )
         {
         if ( context->flags & WL_USING_XGL )
            {
            unsigned long	plane_mask[4];
            unsigned long	color_mapping[256];

            XAllocColorCells( screen_struct.native_info.EXdisplay,
                              hl_cmap,
                              1,
                              plane_mask,
                              0,
                              color_mapping,
                              32 );

            native_info.xgl_hilite_cmap = xgl_object_create( screen_struct.native_info.sys_state,
                                                             XGL_CMAP, NULL,
                                                             XGL_CMAP_NAME, hl_cmap, 
                                                             XGL_CMAP_COLOR_TABLE_SIZE, 
                                                             32,
                                                             NULL );
            }
         }
#     endif /* XGL */

      native_info.hl_colormap = hl_cmap;
      native_info.hl_visual = hl_vinfo->visual;

#if defined( OPENGL )
      if ( context->flags & WL_USING_OPENGL )
      {
         /* make sure hilite visual supports OPENGL */
         glXGetConfig( screen_struct.native_info.EXdisplay,
                       hl_vinfo, GLX_USE_GL, &glx_value );

         if ( ! glx_value )
         {
            /* hilite visual doesn't support OPENGL, therefore */
            /* we can't use it in the base window either       */
            context->flags &= ~WL_USING_OPENGL;
         }
      }
#endif

   }
   else
   {
      native_info.hl_colormap = -1;
   }
      

   native_info.display = screen_struct.native_info.EXdisplay;
   native_info.colormap = cmap;
   native_info.visual = vinfo->visual;
   native_info.screen = screen_struct.native_info.screen_no;

   XFree( (char *) avail_visuals );
   if ( hl_avail_visuals )
   {
      XFree( (char *) hl_avail_visuals );
   }

#elif defined( ENV5 )
   flags = screen_struct.flags;

   /* Looking for an Edge2                                                 */

   if ( ( screen_struct.native_info.env5_vsi_flags & VSI_TRC_ABILITY )
        && ( !( context->flags & WL_COLORMAP_SAVE_RESTORE ) ) ) 
   {
      if ( context->base_cmap_type == WL_CMAP_INDEXED )
      {
         if ( ! ( screen_struct.flags & WLI_SCREEN_FLAGS_DEFAULT_CMAP_USED ) )
         {
             /* No other way of retrieveing the defaul vlt no in Env5      */

             Create_win( screen_struct.native_info.screen_no, "", 0, 0, 10, 10,
                        &win_no );
             sts = Inq_activevltno( win_no, &vlt_no );
             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
             Delete_win( win_no );
             flags |= WLI_SCREEN_FLAGS_DEFAULT_CMAP_USED;
             sts = WLIscreen_set_flags( lscreen_no, flags );
             sts = WLIscreen_set_vlt( lscreen_no, vlt_no );
             if ( sts != WL_SUCCESS )
             {
                 WL_REPORT_ERROR( sts );
                 return( sts );
             }
                 
         }
         else
         {
             sts = Alloc_vlt( INDEXED_COLOR_VLT, &vlt_no );
             if ( sts != 0 )
             {
                 WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                 return( WL_SYSTEM_ERROR );
             }
         }
      }
      else
      {
         if ( context->base_depth == 24 )
         {
            sts = Alloc_vlt( TRUE_COLOR_VLT, &vlt_no );
            if ( sts != 0 )
            {
                WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                return( WL_SYSTEM_ERROR );
            }
         }
         else
         {
            sts = Alloc_vlt( PSEUDO_TRUE_COLOR_VLT, &vlt_no );
            if ( sts != 0 )
            {
                WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                return( WL_SYSTEM_ERROR );
            }
         }
      }
      native_info.vlt_no = vlt_no;
   }
   else
   {
      native_info.vlt_no = -1;
   }
   native_info.vs_no = screen_struct.native_info.screen_no; 

#elif defined( WIN32 )
   if ( context->flags & WL_SYSTEM_COLORMAP )
   {
      native_info.palette = NULL;
   }
   else
   {
      pal.palNumEntries = 1 << ( context->base_depth + hilite_depth );
      native_info.palette = CreatePalette( &pal );
   }
   
#else
#error "A windowing system should be defined" 
#endif

   return( WLIcontext_add_entry( lscreen_no, &native_info, cmap_color_to_index,
                                 cmap_color_to_rgb, cmap_init, context, 
                                 context_no, 1 ) );
}  /* WLcreate_context */

/*---WLget_context_color_functions-------------------------------------------*/

int WLget_context_color_functions(
   WLuint32 context_no,
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
      WLuint32 context_no ) )

/*
NAME
	WLget_context_color_functions
 
KEYWORD
	WL 
 
DESCRIPTION
	This function retrieves the colormap function pointers associated
	with a context

SYNOPSIS
	int WLget_context_color_functions(
		WLuint32 context_no,
		int (**cmap_color_to_index)(),
		int (**cmap_color_to_rgb)(),
		int (**cmap_init)() )

PARAMETERS
	context_no (IN) - The context number. 
	cmap_color_to_index (OUT)-Function pointer.This function translates
                                 the RGB values or logical index to a physical 
                                 index.  NULL if not desired.
	cmap_color_to_rgb (OUT) - Function pointer.This function translates
                                 the RGB values or logical index to new RGB 
				 values.  NULL if not desired
	cmap_init (OUT) - Function pointer. This function initializes the
                              colormap. NULL if not desired

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_CONTEXT_NUMBER
		The context number is invalid

        WL_BAD_PARAMETER
		One of the pointers is NULL

HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/
{
   int sts;
   struct WLIcontext context_struct;
  
   sts = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( cmap_color_to_index )
   {
      *cmap_color_to_index = context_struct.cmap_color_to_index;
   }

   if ( cmap_color_to_rgb )
   {
      *cmap_color_to_rgb = context_struct.cmap_color_to_rgb;
   }

   if ( cmap_init )
   {
      *cmap_init = context_struct.cmap_init;
   }

   return( WL_SUCCESS );
}  /* WLget_context_color_functions */

/*---WLchange_context_color_functions-------------------------------------------*/

int WLchange_context_color_functions(
   WLuint32 context_no,
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
	WLchange_context_color_functions
 
KEYWORD
	WL 
 
DESCRIPTION
	This function changes the colormap function pointers associated
	with a context

SYNOPSIS
	int WLchange_context_color_functions(
		WLuint32 context_no,
		int (*cmap_color_to_index)(),
		int (*cmap_color_to_rgb)(),
		int (*cmap_init)() )

PARAMETERS
	context_no (IN) - The context number
	cmap_color_to_index (IN)-Function pointer.This function helps translate
                                 the RGB values or logical index to a physical 
                                 index.
	cmap_color_to_rgb (IN) - Function pointer.This function helps translate
                                 the RGB values or logical index to new RGB 
				 values
	cmap_init (IN) - Function pointer. This function initializes the
                              colormap

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_CONTEXT_NUMBER
		The context number is invalid

	WL_BAD_PARAMETER
		One of the pointers is NULL

HISTORY
	11/28/92 Shridar Subramanian
		Initial definition

	11/28/92 Shridar Subramanian
		Initial design
*/
{
   int sts;
  
   sts =  WLIcontext_change_color_funcs( context_no, cmap_color_to_index,
                                         cmap_color_to_rgb, cmap_init );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   return( WL_SUCCESS );
}  /* WLchange_context_color_functions */

/*---WLcreate_context_native_info-------------------------------------*/

int WLcreate_context_native_info(
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
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
      WLuint32 context_no ),
   struct WLnative_info *native_info,
   WLuint32 *context_no)

/*
NAME
	WLcreate_context_native_info
 
KEYWORD
	WL 
 
DESCRIPTION
	This function creates a new context using the context information and
	the native information and returns the context number.

SYNOPSIS
	int WLcreate_context_native_info(
		WLuint16 lscreen_no,
		struct WLcontext_info *context,
		int (*cmap_color_to_index)(),
		int (*cmap_color_to_rgb)(),
		int (*cmap_init)(),
		struct WLnative_info *native_info,
		WLuint32 *context_no)

PARAMETERS
	lscreen_no (IN) - The logical screen number.
	context (IN) - The context information
	cmap_color_to_index (IN) -Function pointer.This function helps translate
                                 the RGB values or logical index to a physical 
                                 index.
	cmap_color_to_rgb (IN) - Function pointer.This function helps translate
                                 the RGB values or logical index to new RGB 
				 values
	cmap_init (IN) - Function pointer. This function initializes the
                              colormap
	native_info (IN) - The native windowing information
	context_no (OUT) - The context number. 

NOTES
	The synopsis of the colormap functions is:
	cmap_color_to_index(
		WLuint32 context_no,
		WLuint32 index,
		WLuint32 red,
		WLuint32 green,
		WLuint32 blue,
		WLuint32 flag,
		WLuint32 *phy_index)
        context_no (IN) - The context number
	index (IN) - The logical color index
	red (IN) - The red component
	green (IN) - The green component
	blue (IN) - The blue component
	flag (IN) - indicates whether index or rgb should be used in the 
		    conversion
	phy_index (OUT) - The physical index
	
	cmap_color_to_rgb(
		WLuint32 context_no,
		WLuint32 index,
		WLuint32 red,
		WLuint32 green,
		WLuint32 blue,
		WLuint32 flag,
		WLuint32 *out_red,
		WLuint32 *out_green,
		WLuint32 *out_blue,
        context_no (IN) - The context number
	index (IN) - The logical color index
	red (IN) - The red component
	green (IN) - The green component
	blue (IN) - The blue component
	flag (IN) - indicates whether index or rgb should be used in the 
		    conversion
	out_red (OUT) - The converted red component
	out_green (OUT) - The converted green component
	out_blue (OUT) - The converted blue component

	cmap_init(
		WLuint32 context_no)
        context_no (IN) - The context number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
   		The logical screen number is invalid

	WL_BAD_CONTEXT
		The context information is invalid

	WL_BAD_PARAMETER
		One of the pointers is NULL

RELATED INFORMATION
	Functions:  WLadd_context_to_window(), WLdisplay_window(),WLdelete_window()

HISTORY
	08/28/92 S.P.Rogers, Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
   if ( ( context->base_cmap_type != WL_CMAP_INDEXED ) && 
        ( context->base_cmap_type != WL_CMAP_TRUE_COLOR ) )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }
   if ( context == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }
 
   /* Remove this when Joel provies the 3 default functions               */

   if ( ( cmap_color_to_index == NULL ) || ( cmap_color_to_rgb == NULL ) ||
        ( cmap_init == NULL ) || ( context_no == NULL ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   return( WLIcontext_add_entry( lscreen_no, native_info, cmap_color_to_index,
                                 cmap_color_to_rgb, cmap_init, context, 
                                 context_no, 0 ) );
} /* WLcreate_context_native_info */

/*---WLdelete_context-----------------------------------------------*/

int WLdelete_context(
   WLuint16 lscreen_no,
   WLuint32 context_no)

/*
NAME
	WLdelete_context
 
KEYWORD
	WL 
 
DESCRIPTION
	This function deletes a context

SYNOPSIS
	int WLdelete_context(
		WLuint16 lscreen_no,
		WLuint32 context_no)

PARAMETERS
	lscreen_no (IN) - The logical screen number.
	context_no (OUT) - The context number. 

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
   		The logical screen number is invalid

	WL_BAD_CONTEXT
		The context information is invalid

RELATED INFORMATION
	Functions:  WLadd_context_to_window(), WLdisplay_window(),WLdelete_window()

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS 	)
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
   return( WLIcontext_delete_entry( context_no ) );
}  /* WLdelete_context */

/*--- WLget_context_depth -------------------------------------------*/

int WLget_context_depth(
   WLuint32 context_no,
   int *depth )

/*
NAME
   WLget_context_depth
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the "actual" depth of a context.  That is, it does
   not remove a plane for hilite if one is being used.

SYNOPSIS
   int WLget_context_depth(
      WLuint32 context_no,
      int *depth )
 
PARAMETERS
   context_no (IN) - context number
   depth (OUT) - depth of the context
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
   WL_BAD_CONTEXT
      The context is invalid
   WL_BAD_PARAMETER
      The 'depth' pointer is NULL.
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
 
 
{
   int status;
   struct WLIcontext context_struct;
 
   if (depth == NULL)
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }
 
   status = WLIcontext_retrieve_entry( context_no,&context_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
   *depth = context_struct.base_depth;
   if ( context_struct.hilite_used )
   {
      (*depth)++;
   }

   return( WL_SUCCESS );

}  /* WLget_context_depth */

/*--- WLget_number_of_contexts_possible -------------------------------------*/
 
/*ARGSUSED*/
int WLget_number_of_contexts_possible(
   WLuint16 lscreen_no,
   WLuint32 context_no,
   int *num_possible )
 
/*
NAME
   WLget_number_of_contexts_possible
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the number of contexts, similar to the one indicated
   by context_no,  that can be simultaneously supported by the hardware.

SYNOPSIS
   int WLget_number_of_contexts_possible(
      WLuint16 lscreen_no,
      WLuint32 context_no,
      int *num_possible )
 
PARAMETERS
   lscreen_no (IN) - screen number
   context_no (IN) - context number
   num_possible (OUT) - number of contexts possible
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SCREEN_NUMBER
      The logical screen number is invalid
 
   WL_BAD_CONTEXT
      The context is invalid
 
   WL_BAD_PARAMETER
      The "num_possible" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIcontext context_struct;
   struct WLIscreen screen_struct;

   if ( ! num_possible )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   status = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
   status = WLIscreen_retrieve_entry( context_struct.lscreen_no, &screen_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

#if defined( WIN32 )
   *num_possible = 1;
#elif defined( X11 )
#if defined( IRIX )
   /* !!! making assumptions about SGI workstations */
   if ( (context_struct.base_depth == 24) ||
        (context_struct.base_depth == 12) )
   {
      *num_possible = 1;
   }
   else
   {
      /* use num cmaps of screen */
      *num_possible = MaxCmapsOfScreen(
                         ScreenOfDisplay( screen_struct.native_info.EXdisplay,
                                          screen_struct.native_info.screen_no ) );
                                                        
   }
#elif defined( SUNOS )
   /* !!! making assumptions about Sun Workstations */
   if ( context_struct.base_depth == 24 )
   {
      *num_possible = 1;
   }
   else if ( context_struct.base_depth == 12 )
   {
      /* assuming Sun GS */
      *num_possible = 2;
   }
   else
   {
      *num_possible = 1;
   }
#else
   /* making assumptions about a generic X workstation */
   *num_possible = 1;
#endif
   
#elif defined( ENV5 )
   {
      if ( screen_struct.native_info.env5_vsi_flags & VSI_TRC_ABILITY )
      {
         /* this is an EdgeII */
         *num_possible = 4;
      }
      else
      {
         /* all other INGR workstations */
         *num_possible = 1;
      }

   } 
#endif
 
  return( WL_SUCCESS );
}  /* WLget_number_of_contexts_possible */

/*--- WLget_context_info -----------------------------------------------*/
 
int WLget_context_info(
   WLuint32 context_no,
   struct WLcontext_info *context_info)
/*
 
NAME
   WLget_context_info
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the information associated with a context

SYNOPSIS
    int WLget_context_info(
       WLuint32 context_no,
       struct WLcontext_info *context_info)
 
PARAMETERS
   context_no (IN) - The context number
   context_info (IN) - The context information
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_PARAMETER
      The pointer "context_info" is NULL
 
   WL_BAD_CONTEXT
      The context number is invalid
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status; 
   struct WLIcontext context_struct;

   if ( context_info == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   } 
   status = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return ( status );
   } 
   context_info->base_cmap_type = context_struct.base_cmap_type;
   context_info->base_depth = context_struct.base_depth;
   context_info->hilite_used = context_struct.hilite_used;
   context_info->flags = context_struct.flags;
   return ( WL_SUCCESS );
 
}  /* WLget_context_info */

        
/*--- WLget_context_interaction -------------------------------------------*/
 
int WLget_context_interaction(
   WLuint16 lscreen_no,
   WLuint32 context_no,
   struct WLcontext_interaction **inter )
 
/*
NAME
   WLget_context_interaction
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the number of different contexts that can co-exist
   with a given context, without their colormaps interfering.

SYNOPSIS
   int WLget_context_interaction(
      WLuint16 lscreen_no,
      WLuint32 context_no,
      struct WLcontext_interaction **inter )
 
PARAMETERS
   lscreen_no (IN) - screen number
   context_no (IN) - context number
   inter (OUT) - array of interactions;  The caller should free this
                 array with WLfree().
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SCREEN_NUMBER
      The logical screen number is invalid
 
   WL_BAD_CONTEXT
      The context is invalid
 
   WL_BAD_PARAMETER
      The "inter" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIscreen screen_struct;
   struct WLIcontext context_struct;
#if defined( X11 )
   XVisualInfo *vinfo, vinfo_temp;
   int nitems, cmaps;
#endif


   if ( !inter )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }
   *inter = NULL;

   status = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   status = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   /* Depending on the type of the machine hard code the interaction for now */
#if defined( ENV5 )
      if ( screen_struct.native_info.env5_vsi_flags & VSI_TRC_ABILITY ) 
      {
         *inter = (struct WLcontext_interaction *)
            malloc(3*sizeof( struct WLcontext_interaction ) );
         if ( ! *inter )
         {
            WL_REPORT_ERROR( WL_ERROR );
            return( WL_ERROR );
         }

         (*inter)[0].context_no = context_no;  
         (*inter)[0].number = 8;  
         (*inter)[0].num_of_coexists = 4;  
         
         (*inter)[1].context_no = context_no;  
         (*inter)[1].number = 24;  
         (*inter)[1].num_of_coexists = 4;  

         (*inter)[2].context_no = context_no;  
         (*inter)[2].number = 12;  
         (*inter)[2].num_of_coexists = 4;  

         if ( context_struct.base_depth == 24 )
         {
            (*inter)[1].num_of_coexists = 3;  
         }
         else if ( context_struct.base_depth == 8 )
         {
            (*inter)[0].num_of_coexists = 3;  
         }
         else if ( context_struct.base_depth == 12 )
         {
            (*inter)[2].num_of_coexists = 3;  
         }
         
      }
      else 
      {
         *inter = (struct WLcontext_interaction *)
            malloc(sizeof(struct WLcontext_interaction) );
         if ( ! *inter )
         {
            WL_REPORT_ERROR( WL_ERROR );
            return( WL_ERROR );
         }
            
         (*inter)[0].context_no = context_no;  
         (*inter)[0].number = context_struct.base_depth;  
         (*inter)[0].num_of_coexists = 0;  
      }
#elif defined ( X11 )

#if defined ( SUNOS ) || defined ( SOLARIS )
   vinfo_temp.depth = 24;
   vinfo_temp.class = TrueColor;
   vinfo = XGetVisualInfo( screen_struct.native_info.EXdisplay, 
                           VisualDepthMask, &vinfo_temp, &nitems );
   if ( nitems > 0 )
   {
      *inter = ( struct WLcontext_interaction *)
         malloc(4*sizeof(struct WLcontext_interaction ) );
      if ( ! *inter )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }

      (*inter)[0].context_no = context_no;  
      (*inter)[0].number = 24;  
      (*inter)[0].num_of_coexists = 1;  
         
      (*inter)[1].context_no = context_no;  
      (*inter)[1].number = 12;  
      (*inter)[1].num_of_coexists = 2;  

      (*inter)[2].context_no = context_no;  
      (*inter)[2].number = 8;  
      (*inter)[2].num_of_coexists = 1;  

      (*inter)[3].context_no = context_no;  
      (*inter)[3].number = 4;  
      (*inter)[3].num_of_coexists = 1;  
      
      if ( context_struct.base_depth == 24 )
      {
         (*inter)[0].num_of_coexists = (*inter)[0].num_of_coexists - 1 ;
      }
      else if ( context_struct.base_depth == 12 )
      {
         (*inter)[1].num_of_coexists = (*inter)[1].num_of_coexists - 1 ;
      }
      else if ( context_struct.base_depth == 8 )
      {
         (*inter)[2].num_of_coexists = (*inter)[2].num_of_coexists - 1;
      }
      else if ( context_struct.base_depth == 4 )
      {
         (*inter)[3].num_of_coexists =  (*inter)[3].num_of_coexists - 1;
      }

   }
   else
   {
      *inter = (struct WLcontext_interaction *)
          malloc(sizeof( struct WLcontext_interaction ) );
      if ( ! *inter )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }
            
      (*inter)[0].context_no = context_no;  
      (*inter)[0].number = context_struct.base_depth;  
      (*inter)[0].num_of_coexists = 0;  
   }

#elif defined ( IRIX )
   vinfo_temp.depth = 24;
   vinfo_temp.class = TrueColor;
   vinfo = XGetVisualInfo( screen_struct.native_info.EXdisplay, 
                           VisualDepthMask, &vinfo_temp, &nitems );
   if ( nitems > 0 )
   {
      *inter = ( struct WLcontext_interaction *)
          malloc( 4*sizeof( struct WLcontext_interaction ) );
      if ( ! *inter )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }

      (*inter)[0].context_no = context_no;  
      (*inter)[0].number = 24;  
      (*inter)[0].num_of_coexists = 1;  
          
      (*inter)[1].context_no = context_no;  
      (*inter)[1].number = 12;  
      (*inter)[1].num_of_coexists = 2;  

      (*inter)[2].context_no = context_no;  
      (*inter)[2].number = 8;  
      (*inter)[2].num_of_coexists = cmaps;  

      (*inter)[3].context_no = context_no;  
      (*inter)[3].number = 4;  
      (*inter)[3].num_of_coexists = 1;  
      
      if ( context_struct.base_depth == 24 )
      {
         (*inter)[0].num_of_coexists = (*inter)[0].num_of_coexists - 1 ;
      }
      else if ( context_struct.base_depth == 12 )
      {
         (*inter)[1].num_of_coexists =  (*inter)[1].num_of_coexists - 1 ;
      }
      else if ( context_struct.base_depth == 8 )
      {
         (*inter)[2].num_of_coexists =  (*inter)[2].num_of_coexists - 1;
      }
      else if ( context_struct.base_depth == 4 )
      {
         (*inter)[3].num_of_coexists =  (*inter)[3].num_of_coexists - 1;
      }

   }
   else
   {
      *inter = (struct WLcontext_interaction *)
         malloc( sizeof( struct WLcontext_interaction ) );
      if ( ! *inter )
      {
         WL_REPORT_ERROR( WL_ERROR );
         return( WL_ERROR );
      }
          
      (*inter)[0].context_no = context_no;  
      (*inter)[0].number = context_struct.base_depth;  
      (*inter)[0].num_of_coexists = 0;  
   }
#endif

#elif defined ( WIN32 )
   /* !!! might need some enhancement */
   *inter = (struct WLcontext_interaction *)
      malloc( sizeof( struct WLcontext_interaction ) );
   if ( ! *inter )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
          
   (*inter)[0].context_no = context_no;  
   (*inter)[0].number = context_struct.base_depth;  
   (*inter)[0].num_of_coexists = 0;  
#endif

   return( WL_SUCCESS );
        
}  /* WLget_context_interaction */

/*--- WLget_native_info_from_context -------------------------------------------*/
 
/*ARGSUSED*/
int WLget_native_info_from_context(
   WLuint16 lscreen_no,
   WLuint32 context_no,
   struct WLnative_info *native_info)
 
 
/*
NAME
   WLget_native_info_from_context
 
KEYWORD
   WL
 
DESCRIPTION
   This function get the native windowing system information using only the
   context number

SYNOPSIS
   int WLget_native_info_from_context(
      WLuint16 lscreen_no,
      WLuint32 context_no,
      struct WLnative_info *native_info)
 
PARAMETERS
   context_no (IN)  - context number
   lscreen_no (IN)  - logical screen number
   native_info (OUT) - The native windowing system information

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_CONTEXT
      The context is invalid
 
   WL_BAD_PARAMETER
      The "native_info" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIscreen screen_struct;
   struct WLIcontext context_struct;
   WLuint16 lscr_no;
   WLuint8  offset, index;
 
   status = WLIcontext_unpack( context_no, &lscr_no, &index, &offset );

   status = WLIscreen_retrieve_entry( lscr_no, &screen_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   status = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
#if defined (X11)
   native_info->display = screen_struct.native_info.EXdisplay;
   native_info->gc = screen_struct.native_info.EXgc;
   native_info->colormap = context_struct.native_info.EXcolormap;
   native_info->hl_colormap = context_struct.hl_native_info.hl_colormap;
   native_info->visual = context_struct.native_info.visual;
   native_info->hl_visual = context_struct.hl_native_info.hl_visual;
   native_info->screen = screen_struct.native_info.screen_no;
   native_info->flags = context_struct.flags;
 
#elif (ENV5)
   native_info->vlt_no = context_struct.native_info.vlt_no;
   native_info->vs_no = screen_struct.native_info.screen_no;
 
#elif (WIN32)
   native_info->hdc = screen_struct.native_info.hdc;
   native_info->palette = context_struct.native_info.palette;
   native_info->class = screen_struct.native_info.app_main_class;
   native_info->hinstance = screen_struct.native_info.hinstance;
 
#endif
 
   return( WL_SUCCESS );

}  /* WLget_native_info_from_context */
