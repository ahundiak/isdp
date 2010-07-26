/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	DPbcstrk         
 
     Abstract:		
	This module takes pointer to OSA b-spline curve, pointer
	to element specific attribute, pointer to display attribute,
	pointer to vvol_viewport_scale and pointer to hardware
	window number and what type of wld to viewport matrix  as input,
        stroke, clip and then output the element.
-----
%SC%

  VALUE = DPbcstrk(message, bsp_c, ele_attr, dis_attr, scale, win_no,type,
                   clp_flag)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	bsp_c	   IGRbsp_curve  pointer to:bsp curve geomtry
        ele_attr   IGResbc		    element specific attr.
	dis_attr   IGRdisplay		    display attribute
        scale      double                vvol_viewport_scale
        win_no     int                   hardware window no.   
        mtx_type   short                 matrix type
        clp_flag   IGRboolean               to call clip or not 
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      long 	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure occurred

     VALUE (IGRboolean) = TRUE	    - if successful
		          FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:
			MAoptsxform()
			MArptsxform()
			MAbcstroke()
			DPclip()
			DPoutvec()
			DPsetdsp()
			malloc()
			free()
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
	
	ht  12/23/85  : Design date.
	AET 07/30/88  : Add poly fill capability
	AET 08/30/88  :	Added multiple symbology capability

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
	

		

----*/
/*EH*/

#include <stdlib.h>
#include <limits.h>

#include "grimport.h"
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
#include "dpsetdsp.h"
#include "dpbcstrk.h"


extern IGRboolean DPdlist_feedback_in_progress;

#ifdef TIMING_TEST

extern long dpbcstrk_time;

#endif

#define MAX_MULT_SYMB	20

#ifdef GRAPHICS_ATP
int TSisGraphicsATPflag = 1;
char TSGraphicsATPFile [DI_PATH_MAX] = { "output/graphics" };


int TSisGraphicsATP ()
{
  return TSisGraphicsATPflag;
}


int TSsetGraphicsATPflag ( i )
int i;
{
  return TSisGraphicsATPflag = i;
}


int TSSetGraphicsATPFile ( fname )
char *fname	/* The file to write the output to			IN */;
{
  strcpy ( TSGraphicsATPFile, fname );
  
  return 1;
}
#endif

IGRboolean  DPbcstrk(
   IGRint *message,	/* output completion code       */
   struct IGRbsp_curve *bsp_c,		/* input  bsp curve geometry    */
   struct IGResbc *ele_attr, 	/* element specific attr        */
   struct IGRdisplay *dis_attr, 	/* display attribute            */
   int gpipe_id,
   int win_no,
   int flags,
   int unsigned disp_flags,
   struct IGRdisplay **bound_att,
   int num_bound_att,
   int **bound_att_indices,
   int blend,
   int draw_opt )

{
   int    		status;         /* return status */
   int			i;
   int     		symb_malloc = FALSE;
   int     		*bound_indices = NULL;
   struct IGRdisplay	*disp_ptr;
   WLuint32             color_ref;
   struct DLattr_bundle attribute[MAX_MULT_SYMB],*attr_bundle,*beg_attr_bundle = NULL;

#ifdef TIMING_TEST
   long			beg_time,end_time;

   beg_time = clock();
#endif

	*message = MSSUCC;

	WLpack_index_colorref( dis_attr->color, &color_ref, FALSE );

	if ( (ele_attr->is_polydis) && (!DPdlist_feedback_in_progress) )
	{	
           if (bsp_c->rational)
           {
              for(i = 0; i < bsp_c->num_poles; i++)
              {
                 bsp_c->poles[i*3]   /= bsp_c->weights[i];
                 bsp_c->poles[i*3+1] /= bsp_c->weights[i];
                 bsp_c->poles[i*3+2] /= bsp_c->weights[i];
              }
           }

#ifdef GRAPHICS_ATP
	if(TSisGraphicsATP())
	{
          int	ii, jj;
	  FILE *wfp;

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPLinestr3D\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", gpipe_id);
	    fprintf(wfp, "%d points:\n", bsp_c->num_poles);
	    for(ii = 0, jj = 0; ii < bsp_c->num_poles; ii ++)
	    {
	      fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		bsp_c->poles[jj++], bsp_c->poles[jj++], bsp_c->poles[jj++]);
	    }
	    fprintf(wfp, "\nEnd of arguments to GPLinestr3D\n\n");
	    fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif
	   if ( DLdraw_3D_line_string( gpipe_id, bsp_c->poles, bsp_c->num_poles, 
                                       color_ref, 4, (WLuint16) blend, dis_attr->weight,
                                       draw_opt ) != DL_SUCCESS )
	   {
	      status = FALSE;
	      *message = MSFAIL;
	      goto wrapup;
	   }

           if (bsp_c->rational)
           {
              for(i = 0; i < bsp_c->num_poles; i++)
              {
                 bsp_c->poles[i*3]   *= bsp_c->weights[i];
                 bsp_c->poles[i*3+1] *= bsp_c->weights[i];
                 bsp_c->poles[i*3+2] *= bsp_c->weights[i];
              }
           }

	}

	if ( (DPdlist_feedback_in_progress) || 
             (!(flags & DPVIEW_DYNAMICS)) )
	{
	   if ( disp_flags & DPPOLY_FILL )
	   {
	      draw_opt |= DL_OPT_FILL;
	   }
	}

	if ( ele_attr->is_curvedis )
	{
	   if (bound_att)
	   {
	      bound_indices = *bound_att_indices;
	      if (num_bound_att > MAX_MULT_SYMB)
	      {
		 attr_bundle = (struct DLattr_bundle *)
	                          malloc(sizeof(struct DLattr_bundle) * num_bound_att);
		 symb_malloc = TRUE;
	      }
	      else
	      {
		 attr_bundle = attribute;
	      }

	      beg_attr_bundle = attr_bundle;
	      for (i = 0; i < num_bound_att; i++,attr_bundle++)
	      {
	         disp_ptr = bound_att[i];

		 attr_bundle->flags = (disp_ptr->color == DP_INVISIBLE_COLOR) ? 0 : 1;
	         if ( attr_bundle->flags )
	            {
	            WLpack_index_colorref( disp_ptr->color, &attr_bundle->color, FALSE );
                    attr_bundle->lstyle = disp_ptr->style;
	            attr_bundle->weight = disp_ptr->weight;
	            attr_bundle->blend = blend;
	            }
	      }
	   }

#ifdef GRAPHICS_ATP
	if(TSisGraphicsATP())
	{
	  FILE *wfp;

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPBsplineCurve\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", gpipe_id);
	    BSprintbspc(wfp, NULL, bsp_c, FALSE);
	    fprintf(wfp, "clip options:\t%x\n",draw_opt);
	    fprintf(wfp, "%d bound attributes:\n",num_bound_att);
	    if(bound_indices) 
	    {
	      int i;
	      
	      for (i = 0; i < num_bound_att; i++)
  	        fprintf ( wfp, "bound_indices [%d]:\t %d\n", i, bound_indices [i] );
  	    }

	    if(beg_attr_bundle) 
	    {
	      int i;
	      
	      for (i = 0; i < num_bound_att; i++)
	      {
	        if (beg_attr_bundle [i].flags)
    	          fprintf ( wfp, "beg_attr_bundle [%d]:\t ( %d, %d, %d, %d )\n", i,
  	                    beg_attr_bundle [i].flags, beg_attr_bundle [i].color,
  	                    beg_attr_bundle [i].weight, beg_attr_bundle [i].blend );
  	        else
    	          fprintf ( wfp, "beg_attr_bundle [%d]:\t ( %d )\n", i, beg_attr_bundle [i].flags );
  	      }
  	    }

	    fprintf(wfp, "\nEnd of arguments to GPBsplineCurve\n\n");
	    fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
  	}
#endif
	      if ( DLdraw_3D_curve( gpipe_id, bsp_c,
		                    bound_indices, beg_attr_bundle, num_bound_att,
                                    color_ref, dis_attr->style, (WLuint16) blend, dis_attr->weight,
                                    draw_opt ) != DL_SUCCESS )

	         {
	         status = FALSE;
	         *message = MSFAIL;
	         goto wrapup;
	         }
	}

    	status = TRUE;

	if ( flags & DPVIEW_DYNAMICS )
	{
	   DLpass_to_feedback( gpipe_id, (WLint16) 0, (WLint16) 0, 0 );

           if ( ! DPdlist_feedback_in_progress )
           {
	      DPpack_buffer( IGRBC, dis_attr );
           }

	   DLreset_feedback( gpipe_id );
	}
	
wrapup :

	if ( symb_malloc && beg_attr_bundle )
	{
	   free( beg_attr_bundle );
	}

#ifdef TIMING_TEST
   end_time = clock();
   dpbcstrk_time += (end_time - beg_time);
#endif

     return(status);

}  /* DPbcstrk */

