/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	DPbsstrk         
 
     Abstract:		
	This module takes pointer to OSA b-spline surface, pointer
	to element specific attribute, pointer to display attribute,
	pointer to vvol_viewport_scale and pointer to hardware
	window number as input, stroke, clip and then output the
        element.
-----
%SC%

VALUE = DPbsstrk(message, bsp_s, ele_attr, dis_attr,scale, win_no,mtx_type
                    clp_flag)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	bsp_s	   IGRbsp_surf   pointer to:bsp surface geomtry
        ele_attr   IGResbs		    element specific attr.
	dis_attr   IGRdisplay		    display attribute
        scale      IGRdouble                vvol_viewport_scale
        win_no     IGRlong                  hardware window no.   
        mtx_type   IGRshort                 matrix type of wld to viewport
                                            matrix 
        clp_flag   IGRboolean               clip flag
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong 	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure occurred

     VALUE (IGRboolean) = TRUE	    - if successful
		          FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:
			MArptsxform()
			MAoptsxform()
			MAbsstroke()
			DPpystrk()
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
	
	ht  12/30/85  : Design date.

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
#include "dpbsqstrk.h"


extern IGRboolean DPdlist_feedback_in_progress;

#define  POLE_SIZE	101

IGRboolean  DPbsqstrk(	IGRint  		*message,    /* output completion code       */
			struct IGRbsp_surface	*bsp_s,	     /* input  bsp curve geometry    */
			struct IGResqbs		*ele_attr,   /* element specific attr        */
			struct IGRdisplay	*dis_attr,   /* display attribute            */
			IGRint  		gpipe_id,    /* hardware window number       */
			IGRint		  	win_no,
			IGRint  		flags,
			IGRint			blend,
			IGRint			draw_opt )

{
   
   IGRint     status = TRUE;      /* return status                           */
   IGRlong    msg;
   IGRint     i,j,k;
   IGRlong    num_poles;
   IGRdouble  poles[POLE_SIZE * 3];
   IGRdouble  *col_pole;
   WLuint32   color_ref;

	*message = MSSUCC;

	WLpack_index_colorref( dis_attr->color, &color_ref, FALSE );

	if ( (ele_attr->is_polydis) && (! DPdlist_feedback_in_progress) )
	{	
   	   /*
	   **   may want to set special line style for bsp polygon  
	   */

	   num_poles = bsp_s->u_num_poles * bsp_s->v_num_poles;

	   if(bsp_s->rational)
           {
              for(i = 0; i < num_poles; i++)
              {
                 bsp_s->poles[i*3]   /= bsp_s->weights[i];
                 bsp_s->poles[i*3+1] /= bsp_s->weights[i];
                 bsp_s->poles[i*3+2] /= bsp_s->weights[i];
              }
           }


           /*
	   **  output column control polygon
	   */
	   
           for (i = 0; i < bsp_s->v_num_poles; ++i)
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
	          fprintf(wfp, "%d points:\n", bsp_s->u_num_poles);
	          jj = i * bsp_s->u_num_poles * 3;
	          for(ii = 0; ii < bsp_s->u_num_poles; ii ++)
	          {
	            fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		      bsp_s->poles[jj++], bsp_s->poles[jj++], bsp_s->poles[jj++]);
	          }
	          fprintf(wfp, "\nEnd of arguments to GPLinestr3D\n\n");
	          fclose (wfp);
	        }
	        else fprintf(stderr, "Error opening output file.\n");
	      }
#endif
              if( DLdraw_3D_line_string( gpipe_id,
                       bsp_s->poles + i * bsp_s->u_num_poles * 3, bsp_s->u_num_poles,
	               color_ref, 4, blend, dis_attr->weight,
	               draw_opt ) )
	      {
	         status = FALSE;
	      }	
		    	
           }

	   /*
	   **  output row control polygon
	   */
	   
	   if (bsp_s->v_num_poles > POLE_SIZE)
	   {
	       col_pole = (IGRdouble *) 
                  malloc((unsigned int)(3 * bsp_s->v_num_poles * sizeof(IGRdouble)));
	       if (col_pole == NULL)
	       {
	          status = FALSE;
	          msg = MSFAIL;	
	          goto wrap;
	       }

	   }
	   else
	   {
	      col_pole = poles;
	   }

	
           for (i = 0; i < bsp_s->u_num_poles; ++i)
	   {
               /* copy col of poles into col_pole (continuous space)*/
	       
	      for (j = 0; j < bsp_s->v_num_poles; ++j)
	      {
	          k = 3 * ( j * bsp_s->u_num_poles +  i );
	          *(col_pole + 3 * j)     = bsp_s->poles[k];
	          *(col_pole + 3 * j + 1) = bsp_s->poles[k + 1];
	          *(col_pole + 3 * j + 2) = bsp_s->poles[k + 2];
	      }

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
	          fprintf(wfp, "%d points:\n", bsp_s->v_num_poles);
	          for(ii = 0, jj = 0; ii < bsp_s->v_num_poles; ii ++)
	          {
	             fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		      col_pole[jj++], col_pole[jj++], col_pole[jj++]);
	          }
	          fprintf(wfp, "\nEnd of arguments to GPLinestr3D\n\n");
	          fclose (wfp);
	        }
	        else fprintf(stderr, "Error opening output file.\n");
	      }
#endif
	      if ( DLdraw_3D_line_string( gpipe_id, col_pole, bsp_s->v_num_poles,
	                   color_ref, 4, 0xFFFF, dis_attr->weight,
                           draw_opt) )
	      {
	         status = FALSE;
	      }	
	       
           } /* end of  for (i = 0; ....  */

	   if (bsp_s->v_num_poles > POLE_SIZE)
           {
	      free(col_pole);
	   }

	   if(bsp_s->rational)
           {
              for(i = 0; i < num_poles; i++)
              {
                 bsp_s->poles[i*3]   *= bsp_s->weights[i];
                 bsp_s->poles[i*3+1] *= bsp_s->weights[i];
                 bsp_s->poles[i*3+2] *= bsp_s->weights[i];
              }
           }

        } /* end of if (ele_attr->is_polydis) */


wrap:

        if ( ! status )		/* error occurred		*/
        {
           goto wrapup;		/* return			*/
        }

	if ( ele_attr -> is_surfdis )
	{
#ifdef GRAPHICS_ATP
              if(TSisGraphicsATP())
	      {
	        FILE *wfp;
                extern char TSGraphicsATPFile [DI_PATH_MAX];

	        if(wfp = fopen(TSGraphicsATPFile, "a"))
	        {
	          fprintf(wfp, "Arguments to GPBsplineSurface\n\n");
	          fprintf(wfp, "GPIPE ID:\t%d\n", gpipe_id);
	          BSprintbsps(wfp, NULL, bsp_s, FALSE);
	          TSwriteRLT(wfp, ele_attr);
	          fprintf(wfp, "options:\t%x\n", draw_opt );
	          fprintf(wfp, "\nEnd of arguments to GPBsplineCurve\n\n");
	          fclose (wfp);
	        }
	        else fprintf(stderr, "Error opening output file.\n");
	      }
#endif

	      if (bsp_s->num_boundaries != 0)
	      {
	         draw_opt |= DL_OPT_BOUNDARY;
	      }

	      DLdraw_surface( gpipe_id, bsp_s, 
		          ele_attr->u_rules,ele_attr->v_rules,
		          ele_attr->u_rule_values,ele_attr->v_rule_values,
	   	          ele_attr->u_num_bound,ele_attr->v_num_bound,
		          ele_attr->u_bdrys,ele_attr->v_bdrys,
	                  color_ref, dis_attr->style, blend, dis_attr->weight,
		          draw_opt );
	}

	if ( flags & DPVIEW_DYNAMICS )
	{
	   DLpass_to_feedback( gpipe_id, (WLint16) 0, (WLint16) 0, 0 );

           if ( ! DPdlist_feedback_in_progress )
           {
	      DPpack_buffer(IGRQS,dis_attr);
           }

	   DLreset_feedback( gpipe_id );
	}

wrapup :

     return(status);

}  /* DPbsqstrk */

#ifdef GRAPHICS_ATP

int TSwriteRLT(wfp, r)

FILE *wfp;
struct IGResqbs *r;

{
  fprintf(wfp, "Rule Line Table\n");
  if(r->is_polydis) fprintf(wfp, "Display the polygon\n");
  if(r->is_surfdis) fprintf(wfp, "Display the surface\n");
  if(! r->rules_specified)
    fprintf(wfp, "%d x %d rule lines\n", r->u_rules, r->v_rules);
  else
  {
    int ii, jj;
    double *dd;

    fprintf(wfp, "%d rules in U\n", r->u_rules);
    for(ii = 0; ii < r->u_rules; ii ++)
    {
      fprintf(wfp, "Rule value: %.16LE has %d boundaries\n",
        r->u_rule_values[ii], r->u_num_bound[ii]);
      dd = r->u_bdrys[ii];
      for(jj = 0; jj < (int) r->u_num_bound;)
      {
        fprintf(wfp, "%.16LE %.16LE\n", dd[jj ++], dd[jj ++]);
      }
    }

    fprintf(wfp, "%d rules in V\n", r->v_rules);
    for(ii = 0; ii < r->v_rules; ii ++)
    {
      fprintf(wfp, "Rule value: %.16LE has %d boundaries\n",
        r->v_rule_values[ii], r->v_num_bound[ii]);
      dd = r->v_bdrys[ii];
      for(jj = 0; jj < (int) r->v_num_bound;)
      {
        fprintf(wfp, "%.16LE %.16LE\n", dd[jj ++], dd[jj ++]);
      }
    }
  }
  return 1;
}

#endif
