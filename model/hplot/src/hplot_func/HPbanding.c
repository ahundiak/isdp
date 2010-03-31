#include <stdio.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

static struct HPbanding_info *top_list_surf = NULL;
static struct HPbanding_info *top_list_curv = NULL;
static struct HPbanding_info *last_list_surf = NULL;
static struct HPbanding_info *last_list_curv = NULL;
static struct HPbanding_info *current_surf = NULL;
static struct HPbanding_info *current_curv = NULL;
static struct HPbanding_info *current = NULL;

#define  DEBUG_EXTRA  0

/*---HPinit_banding--------------------------------------------------*/

/*
NAME
        HPinit_banding
        
KEYWORD
        HSplot
        banding

DESCRIPTION
        This function initializes the link list used by HSplot
        in re-reading the shaded plotfile.
        
GLOBALS USED
        top_list_surf: static local to this source.  This points
                        to the top of the surface list.
                        
        top_list_curv: static local to this source.  This points
                        to the top of the curve list.  The
                        curve list includes curves and edges.

FUNCTIONS CALLED
        free
        
HISTORY
        ??/??/??  M. Lanier
                Created
*/


void HPinit_banding (void)

   {
   while (top_list_surf != NULL)
      {
      current_surf = top_list_surf->next;
      free (top_list_surf);
      top_list_surf = current_surf;
      }

   while (top_list_curv != NULL)
      {
      current_curv = top_list_curv->next;
      free (top_list_curv);
      top_list_curv = current_curv;
      }
   }


/*---HPreset_banding--------------------------------------------------*/

/*
NAME
        HPreset_banding
        
KEYWORDS
        HSplot
        banding
        
DESCRIPTION
        This function resets the current list pointer to the top
        of both the surface and curve list.
        
GLOBALS USED
        top_list_surf: Static pointer to the top of the surface list
        top_list_curv: Static pointer to the top of the curve list
        current_surf : Static pointer to the current node in the surface list
        current_curv : Static pointer to the current node in the curve list
        
HISTORY
        ??/??/??  M. Lanier
                Created
*/

void HPreset_banding (void)

   {
   current_surf = top_list_surf;
   current_curv = top_list_curv;
   }


/*---HPremember_minmax-------------------------------------------------*/

/*
NAME
        HPremember_minmax
        
KEYWORD
        HSplot
        banding

DESCRIPTION
        Store the x min/max values in the banding node identified
        by p.
        
PARAMETERS
        p    :(IN) : Pointer to a banding node.
        xmin, xmax:(IN) : X min/max range of a just processed object.
                          This is stored in the banding node, p.
                        
FUNCTIONS CALLED
        HPband_dump:  Called if the debugging switch DEBUG_EXTRA is defined
                      displays in ascii format, the contents of the banding
                      node, p
                
HISTORY
        ??/??/??  M. Lanier
                Created
*/

void HPremember_minmax (struct HPbanding_info * p,
                           int xmin,
                           int xmax)

   {
   p->xmin = xmin;
   p->xmax = xmax;

#  if DEBUG_EXTRA
   HPband_dump (p);
#  endif
   }

/*---HPremember_object_surf--------------------------------------------*/

/*
NAME
        HPremember_object_surf
        
KEYWORD
        HSplot
        banding
        
DESCRIPTION
        This functions creates a banding node for a surface object,
        places in the node the information provided in the arguments
        and adds it to the surface list.
        
PARAMETERS
        file_ptr  :(IN) : Contains a pointer into the shaded plotfile
                                pointing at the surface object to remember
        base_color  :(IN) : Active color of the surface object
        translucent  :(IN) : Translucency state of the surface
        rendering_mode  :(IN) : Active rendering mode for the surface
        tiling_tolerance:(IN) : Active tiling tolerance for the surface
        width    :(IN) : Meaningless for surfaces
        style    :(IN) : Meaningless for surfaces
        count    :(IN) : Id assigned to the surface, derrived by
                                counting the surfaces as they are read.
                                This is only used for debugging.
                                
GLOBALS USED
        current    : Static local to this source, used as temporary banding
                          node.
        top_list_surf  : Static local that points to the top of the surface list.
        last_list_surf  : Static local that points to the last banding node
                          added to the surface list.
                        
RETURN VALUES
        current    : Pointer to the banding node just created.  The caller
                          May need to call HPremember_minmax, for which he will
                          heed this pointer.
                        
FUNCTIONS CALLED
        malloc    : Allocate memory for the new banding node
        ftell    : Get an id for the current shaded plotfile file pointer.
        
HISTORY
        12/10/94  M. Lanier
                Added objid, and osnum for 3.2

        ??/??/??  M. Lanier
                Created
*/

struct HPbanding_info *HPremember_object_surf (

FILE   *file_ptr,
int    base_color,
int    translucent,
int    translucency_grid,
int    rendering_mode,
double tiling_tolerance,
int    width,
int    style,
int    count,
int    objid,
short  osnum )

   {
   current = (struct HPbanding_info *) malloc (sizeof (struct HPbanding_info));

   if (top_list_surf == NULL)
      top_list_surf = current;
   else
      last_list_surf->next = current;

   last_list_surf = current;
   current->next = NULL;

   current->object_location = ftell (file_ptr);
   current->base_color = base_color;
   current->translucent = translucent;
   current->translucency_grid = translucency_grid;
   current->rendering_mode = rendering_mode;
   current->tiling_tolerance = tiling_tolerance;
   current->width = width;
   current->style = style;
   current->xmin = 0;
   current->xmax = 0;
   current->count = count;
   current->objid = objid;
   current->osnum = osnum;

   return (current);
   }

/*---HPremember_object_curv--------------------------------------------*/

/*
NAME
        HPremember_object_curv
        
KEYWORD
        HSplot
        banding
        
DESCRIPTION
        This functions creates a banding node for a curve object,
        places in the node the information provided in the arguments
        and adds it to the curve list.
        
PARAMETERS
        file_ptr  :(IN) : Contains a pointer into the shaded plotfile
                                pointing at the curve object to remember
        base_color  :(IN) : Active color of the curve object
        translucent  :(IN) : Meaningless for curves
        rendering_mode  :(IN) : Active rendering mode for the curve
        tiling_tolerance:(IN) : Active tiling tolerance for the curve
        width    :(IN) : Active line width for the curve
        style    :(IN) : Active style for the curve
        count    :(IN) : Id assigned to the curve, derrived by
                                counting the curves as they are read.
                                This is only used for debugging.
                                
GLOBALS USED
        current    : Static local to this source, used as temporary banding
                          node.
        top_list_curv  : Static local that points to the top of the curve list.
        last_list_curv  : Static local that points to the last banding node
                          added to the curve list.
                        
RETURN VALUES
        current    : Pointer to the banding node just created.  The caller
                          May need to call HPremember_minmax, for which he will
                          heed this pointer.
                        
FUNCTIONS CALLED
        malloc    : Allocate memory for the new banding node
        ftell    : Get an id for the current shaded plotfile file pointer.
        
HISTORY
        12/10/94  M. Lanier
                Added objid, and osnum for 3.2

        ??/??/??  M. Lanier
                Created
*/


struct HPbanding_info *HPremember_object_curv (

FILE   *file_ptr,
int    base_color,
int    translucent,
int    translucency_grid,
int    rendering_mode,
double tiling_tolerance,
int    width,
int    style,
int    count,
int    objid,
short  osnum )

   {
   current = (struct HPbanding_info *) malloc (sizeof (struct HPbanding_info));

   if (top_list_curv == NULL)
      top_list_curv = current;
   else
      last_list_curv->next = current;

   last_list_curv = current;
   current->next = NULL;

   current->object_location = ftell (file_ptr);
   current->base_color = base_color;
   current->translucent = translucent;
   current->translucency_grid = translucency_grid;
   current->rendering_mode = rendering_mode;
   current->tiling_tolerance = tiling_tolerance;
   current->width = width;
   current->style = style;
   current->xmin = 0;
   current->xmax = 0;
   current->count = count;
   current->objid = objid;
   current->osnum = osnum;

   return (current);
   }


/*---HPget_next_object_surf-------------------------------------------*/

/*
NAME
        HPget_next_object_surf
        
KEYWORD
        HSplot
        banding
        
DESCRIPTION
        This functions return informaton from the current banding
        node, then moves the banding mode pointer to the next
        node in the list
        
PARAMETERS
        file_ptr  :(OUT): Contains a pointer into the shaded plotfile
                                pointing at the surface object to remember
        base_color  :(OUT): Active color of the surface object
        translucent  :(OUT): Active translucency state for the surface
        rendering_mode  :(OUT): Active rendering mode for the surface
        tiling_tolerance:(OUT): Active tiling tolerance for the surface
        width    :(OUT): Meaningless for surfaces
        style    :(OUT): Meaningless for surfaces
        count    :(OUT): Id assigned to the surface, derrived by
                                counting the surfaces as they are read.
                                This is only used for debugging.
                                
GLOBALS USED
        current_surf  : Pointer to the current banding node in the
                          surface list
                        
RETURN VALUES
        1: There are more surfaces in the list
        0: This is the last surface in the list
                        
FUNCTIONS CALLED
        fseek    : Using the file pointer id, get the file pointer to
                          the shaded plotfile that will allow the caller to
                          read the surface.
        
HISTORY
        ??/??/??  M. Lanier
                Created
*/

int HPget_next_object_surf (

FILE   *file_ptr,
int    *base_color,
int    *translucent,
int    *translucency_grid,
int    *rendering_mode,
double *tiling_tolerance,
int    *width,
int    *style,
int    *xmin,
int    *xmax,
int    *count,
int    *objid,
short  *osnum )

   {
   if (current_surf == NULL)
      return (2);

#  if DEBUG_EXTRA
   HPband_dump (current_surf);
#  endif

   fseek (file_ptr, current_surf->object_location, 0);

   *base_color = current_surf->base_color;
   *translucent = current_surf->translucent;
   *translucency_grid = current_surf->translucency_grid;
   *rendering_mode = current_surf->rendering_mode;
   *tiling_tolerance = current_surf->tiling_tolerance;
   *width = current_surf->width;
   *style = current_surf->style;
   *xmin = current_surf->xmin;
   *xmax = current_surf->xmax;
   *count = current_surf->count;
   *objid = current_surf->objid;
   *osnum = current_surf->osnum;

   current_surf = current_surf->next;

   if (current_surf != NULL)
      return (1);
   else
      return (0);
   }

/*---HPget_next_object_curv-------------------------------------------*/

/*
NAME
        HPget_next_object_curv
        
KEYWORD
        HSplot
        banding
        
DESCRIPTION
        This functions return informaton from the current banding
        node, then moves the banding mode pointer to the next
        node in the list
        
PARAMETERS
        file_ptr  :(OUT): Contains a pointer into the shaded plotfile
                                pointing at the curve object to remember
        base_color  :(OUT): Active color of the curve object
        translucent  :(OUT): Meaningless for curves
        rendering_mode  :(OUT): Active rendering mode for the curve
        tiling_tolerance:(OUT): Active tiling tolerance for the curve
        width    :(OUT): Active line width for the curve
        style    :(OUT): Active style for the curve
        count    :(OUT): Id assigned to the curve, derrived by
                                counting the curves as they are read.
                                This is only used for debugging.
                                
GLOBALS USED
        current_surf  : Pointer to the current banding node in the
                          surface list
                        
RETURN VALUES
        1: There are more surfaces in the list
        0: This is the last surface in the list
                        
FUNCTIONS CALLED
        fseek    : Using the file pointer id, get the file pointer to
                          the shaded plotfile that will allow the caller to
                          read the surface.
        
HISTORY
        ??/??/??  M. Lanier
                Created
*/

int HPget_next_object_curv (

FILE   *file_ptr,
int    *base_color,
int    *translucent,
int    *translucency_grid,
int    *rendering_mode,
double *tiling_tolerance,
int    *width,
int    *style,
int    *xmin,
int    *xmax,
int    *count,
int    *objid,
short  *osnum,
struct HPbanding_info **object)

   {
   if (current_curv == NULL)
      return (2);

#  if DEBUG_EXTRA
   HPband_dump (current_curv);
#  endif

   fseek (file_ptr, current_curv->object_location, 0);

   *base_color = current_curv->base_color;
   *translucent = current_curv->translucent;
   *translucency_grid = current_curv->translucency_grid;
   *rendering_mode = current_curv->rendering_mode;
   *tiling_tolerance = current_curv->tiling_tolerance;
   *width = current_curv->width;
   *style = current_curv->style;
   *xmin = current_curv->xmin;
   *xmax = current_curv->xmax;
   *count = current_curv->count;
   *object = current_curv;
   *objid = current_curv->objid;
   *osnum = current_curv->osnum;

   current_curv = current_curv->next;

   if (current_curv != NULL)
      return (1);
   else
      return (0);
   }

/*---HPband_dump-------------------------------------------------*/

/*
NAME
        HPband_dump
        
KEYWORD
        HSplot
        banding
        debug
        
DESCRIPTION
        Displays in an ascii format, the contents of the banding
        node, p.
        
PARAMETERS
        p: Pointer to a banding node.
        
FUNCTIONS CALLED
        fprintf
        
HISTORY
        ??/??/??  M. Lanier
                Created
*/


/*
        static HPband_dump( struct HPbanding_info *p )

        {
        fprintf( stderr, "\naddress ----------- %x\n", p );
        fprintf( stderr, "count ------------- %d\n", p->count );
        fprintf( stderr, "object_location --- %d\n", p->object_location );
        fprintf( stderr, "base_color -------- %d\n", p->base_color );
        fprintf( stderr, "translucent ------- %d\n", p->translucent );
        fprintf( stderr, "translucency_grid - %d\n", p->translucency_grid );
        fprintf( stderr, "rendering_mode ---- %d\n", p->rendering_mode );
        fprintf( stderr, "tiling_tolerance -- %f\n", p->tiling_tolerance );
        fprintf( stderr, "width ------------- %d\n", p->width );
        fprintf( stderr, "style ------------- %d\n", p->style );
        fprintf( stderr, "xmin, xmax -------- %d %d\n", p->xmin, p->xmax );
        fprintf( stderr, "objid, osnum ------ %d %d\n", p->objid, p->osnum );
        fprintf( stderr, "next -------------- %x\n\n", p->next );
        }

*/
