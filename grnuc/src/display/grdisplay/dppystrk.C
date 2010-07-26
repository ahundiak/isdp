/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	DPplstrk
 
     Abstract:
		This module takes pointer to IGDS polyine geometry,  
		pointer to element specific attribute, pointer to display 
		attribute pointer to vvol_viewport_scale and pointer to
                hardware window number as input, stroke, clip and then 
                output the element.

-----
%SC%


     VALUE = DPplstrk(message, line_str, ele_attr, dis_attr, scale, 
			win_no,type,clip)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	line_str   IGRpointset	 pointer to:point set geometry
        ele_attr   IGResps		    element specific attr.
	dis_attr   IGRdisplay		    display attribute
        scale      IGRdouble                vvol_viewport_scale
        win_no     IGRint                   hardware window no.   

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong 	 completion code
				    - DPSUCC if successful
				    - DPFAIL (severe) if failure occurred

     VALUE (IGRboolean) = TRUE	    - if successful
		          FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:
			MAptsxform()
			DPclip()
			DPoutvec()
			calloc()
			free()
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
	
	ht  01/02/86  : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
	
   note: the pointset geometry contains points of 3-D only. (x, y, z)

----*/
/*EH*/

#include "grimport.h"
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "msdef.h"
#include "dpdef.h"

#ifdef GRAPHICS_ATP
#include "DIdef.h"
#endif

#include "wl.h"
#include "dl.h"

/* prototype files */
#include "DPviewdyn.h"
#include "dppystrk.h"

extern IGRboolean DPdlist_feedback_in_progress;

IGRboolean  DPpystrk(
IGRint *message,	        /* output completion code       */
struct  IGRpolyline *line_str,	/* input  polyline              */
struct  IGResps     *ele_attr,  /* element specific attr        */
struct  IGRdisplay  *dis_attr,
IGRint  gpipe_id,                /* hardware window number       */
IGRint	flags,
IGRint  disp_flags,
IGRint  blend,
int draw_opt )

{
        int num_points_int;
	WLuint32 color_ref;

	*message = MSSUCC;

	WLpack_index_colorref( dis_attr->color, &color_ref, FALSE );

        /* don't do filled polygons in view dynamics */
	if ( (disp_flags & DPPOLY_FILL) &&
             ( (DPdlist_feedback_in_progress) ||
               (!(flags & DPVIEW_DYNAMICS)) ) )
	{
#ifdef GRAPHICS_ATP
           if(TSisGraphicsATP())
  	   {
             int	ii, jj;
	     FILE *wfp;
             extern char TSGraphicsATPFile [DI_PATH_MAX];

	     if(wfp = fopen(TSGraphicsATPFile, "a"))
	     {
	       fprintf(wfp, "Arguments to GPPolyFill3D\n\n");
	       fprintf(wfp, "GPIPE ID:\t%d\n", gpipe_id);
	       fprintf(wfp, "%d points:\n", line_str->num_points);
	       for(ii = jj = 0; ii < line_str->num_points; ii ++)
	       {
	         fprintf(wfp, "%.16LE %.16LE %.16LE\n", line_str->points[jj++],
		   line_str->points[jj++],line_str->points[jj++]);
	       }
	       fprintf(wfp, "\nEnd of arguments to GPPolyFill3D\n\n");
	       fclose (wfp);
	     }
	     else fprintf(stderr, "Error opening output file.\n");
	   }
#endif
           draw_opt |= DL_OPT_FILL;
           num_points_int = line_str->num_points;
	   DLdraw_3D_polygons( gpipe_id, line_str->points, &num_points_int, 1,
                               color_ref, dis_attr->style, blend, dis_attr->weight,
                               draw_opt );
	}
	else
	{
#ifdef GRAPHICS_ATP
              if(TSisGraphicsATP())
  	      {
	        int	ii, jj;
	        FILE *wfp;
                extern char TSGraphicsATPFile [DI_PATH_MAX];

	        if(wfp = fopen(TSGraphicsATPFile, "a"))
	        {
	          fprintf(wfp, "Arguments to GPLinestr3D\n\n");
	          fprintf(wfp, "GPIPE ID:\t%d\n", gpipe_id);
	          fprintf(wfp, "%d points\n", line_str->num_points);
	          for(ii = jj = 0; ii < line_str->num_points; ii ++)
	          {
	            fprintf(wfp, "%.16LE %.16LE %.16LE\n", line_str->points[jj ++],
		      line_str->points[jj ++], line_str->points[jj ++]);
	          }
	          fprintf(wfp, "End of arguments to GPLinestr3D\n\n");
	          fclose(wfp);
	        }
	        else fprintf(stderr, "Error opening output file.\n");
	      }
#endif 
              DLdraw_3D_line_string( gpipe_id, line_str->points, line_str->num_points,
                                     color_ref, dis_attr->style, blend, dis_attr->weight,
                                     draw_opt );
	}

	if ( flags & DPVIEW_DYNAMICS )
	{
	   DLpass_to_feedback( gpipe_id, (WLint16) 0, (WLint16) 0, 0 );

           if ( ! DPdlist_feedback_in_progress )
           {
	      DPpack_buffer(IGRPY,dis_attr);
           }

	   DLreset_feedback( gpipe_id );
	}
	
        return( TRUE );

}  /* DPpystrk */

