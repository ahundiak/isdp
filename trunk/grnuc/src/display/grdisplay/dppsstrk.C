/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	DPpsstrk         
 
     Abstract:
		This module takes pointer to IGDS pointset geometry,  
		pointer to element specific attribute, pointer to display 
		attribute pointer to vvol_viewport_scale and pointer to
                hardware window number as input, stroke, clip and then 
                output the element.

-----
%SC%


 VALUE = DPpsstrk(message, pt_set, ele_attr, dis_attr, scale, win_no,mtx_type)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	pt_set	   IGRpointset	 pointer to:point set geometry
        ele_attr   IGResps		    element specific attr.
	dis_attr   IGRdisplay		    display attribute
        scale      IGRdouble                vvol_viewport_scale
        win_no     IGRint                   hardware window no.   
        mtx_type   IGRshort                 matrix type
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
			MAoptsxform()
			DPclip()
			DPoutvec()
			malloc()
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
#include <limits.h>
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dppriv.h"
#include "dperr.h"
#include "dpdef.h"
#include "msdef.h"

#ifdef GRAPHICS_ATP
#include "DIdef.h"
#endif

#include "wl.h"
#include "dl.h"

/* prototype files */
#include "dppsstrk.h"
#include "DPviewdyn.h"

extern IGRboolean DPdlist_feedback_in_progress;

IGRboolean  DPpsstrk(
		IGRint             *message,   /* output completion code */
		struct IGRpointset  *pt_set,	/* input  point set       */
		struct IGResps      *ele_attr,  /* element specific attr  */
		struct IGRdisplay   *dis_attr,  /* display attributes	  */
		IGRint              gpipe_id,	/* gpipe id		  */
		IGRint              win_no,     /* hardware window number */
		IGRdouble           *mat,       /* wld to view matrix	  */
		IGRshort            mtx_type,   /* matrix type            */
		IGRint              flags,
		IGRdouble           *depths,
		int		    draw_opt )

{

	WLcolorref color_ref;

	*message = MSSUCC;

	WLpack_index_colorref( dis_attr->color, &color_ref, FALSE );

#ifdef GRAPHICS_ATP
        if(TSisGraphicsATP())
	{
	  int	ii, jj;
	  FILE *wfp;
          extern char TSGraphicsATPFile [PATH_MAX];

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPPointstr3D\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", gpipe_id);
	    fprintf(wfp, "%d points\n", pt_set->num_points);
	    for(ii = jj = 0; ii < pt_set->num_points; ii ++)
	    {
	      fprintf(wfp, "%.16LE %.16LE %.16LE\n", pt_set->points[jj ++],
		pt_set->points[jj ++], pt_set->points[jj ++]);
	    }
	    fprintf(wfp, "End of arguments to GPPointstr3D\n\n");
	    fclose(wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif
	if ( DLdraw_3D_point_string( gpipe_id, pt_set->points, pt_set->num_points,
	                             color_ref, dis_attr->weight,
	                             draw_opt ) != DL_SUCCESS )
	{
	   *message = MSFAIL;
	   return( FALSE );
	}

#ifndef IDRAW
	if ( flags & DPVIEW_DYNAMICS )
	{
	   DLpass_to_feedback( gpipe_id, (WLint16) 0, (WLint16) 0, 0 );

           if ( ! DPdlist_feedback_in_progress )
           {
	      DPpack_buffer( IGRPS, dis_attr );
           }

	   DLreset_feedback( gpipe_id );
	}
#endif

        return( FALSE );

}  /* DPpsstrk */
