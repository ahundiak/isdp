/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPget_fnt_adr

          Abstract:   This routine will get the addreses of the strokes,
		      widths, fun facts, and a value that tells if
		      these strokes are the master strokes.  It will
		      do this for a particular font within an object
		      space.

----
%SC%

     VALUE = DPget_fnt_adr(msg,fnt_os_tbl,fnt_os,virt_font_no,font_id,
		       bodysize,decent,flags)

----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *fnt_os_tbl       struct DPfnt_os_tbl     pointer to the font object
					        space table

      fnt_os	        GRspacenum	        the object space number of
					        font table

      virt_font_no	IGRshort		virtual font to be added

      *font_id		IGRint			id font server uses for 
						to identify the font

      *bodysize 	IGRdouble		size the font was created

      *decent		IGRdouble		units below the baseline

      *flags		IGRint			tells about the font

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
	*msg	      IGRlong		         return status
				  	     MSSUCC - successfully completed
				  	     MSFAIL - unsuccessfully completed

      VALUE() =    TRUE if successful
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  

	None		

----
%NB%

      NOTES:   None

----
%CH%

       AET   02/03/86   : Creation date
       AET   12/11/87	: Changed to correspond to new structure that uses
			  font server
----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	This routine will insert the font pointers into the font table
	for a particular object space

---*/
/*EH*/

#include <FS.h>
#include <FSTypes.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "gr.h"
#include "femacros.h"
#include "fontdef.h"
#include "dpfont.h"
#include "dpdef.h"
#include "msdef.h"

/* prototype files */
#include "dpgetfntadr.h"



DPget_fnt_adr(	IGRlong	             *msg,
		IGRint		     in_flags,
		struct DPfnt_os_tbl  *fnt_os_tbl,
		GRspacenum	     fnt_os,
		IGRshort	     virt_font_no,
		IGRdouble	     angle,
		IGRdouble	     aspect_ratio,
		IGRint		     *font_id,
		IGRdouble	     *body_size,
		IGRdouble	     *decent,
		IGRint		     *flags )
     {	

	struct DPfnt_os_tbl  	*cur_ptr;
	IGRdouble		outline_bodysize;
	IGRdouble		outline_decent;
	IGRboolean		not_found = TRUE;
	IGRboolean		bmap_not_found = TRUE;
 	IGRboolean		ret_cde = TRUE;
	IGRint			i,j;
	IGRint			available_bmap_entry;
	IGRint			font_to_replace;
	IGRuint			time_stamp;
	IGRshort		fst_fnt;
	GRspacenum		font_os_no;
	struct DPbmap_tbl 	*bmaptbl_ptr;
	
	font_os_no = fnt_os;
	cur_ptr = fnt_os_tbl;

  /*  search table until the slot for the object space is found  */

	while (not_found)
	{
	   i = 0;

  /*  search current table until the slot to be changed is found or the */
  /*  entire table has been searched			       		*/

	   while ((i < 33) && (not_found))
	   {

	/*  correct slot ?  */

	      if (cur_ptr->fnt_os_tbl[i].os_num == font_os_no)
	      {
		 not_found = FALSE;

    /* Do we want a fast font?		*/

		 if(in_flags & (FAST_16BIT_FONT | FAST_FRAC_FONT | 
				FAST_CHAR_FONT))
		 {
		    if (in_flags & FAST_16BIT_FONT)
		    {
			if (cur_ptr->fnt_os_tbl[i].fst_16bit_fnt < 0)
			{
			   fst_fnt = cur_ptr->fnt_os_tbl[i].fst_char_fnt;
			}
			else
			{
			   fst_fnt = cur_ptr->fnt_os_tbl[i].fst_16bit_fnt;
			}
		    }
		    else
		    {
			if (in_flags & FAST_FRAC_FONT)
			{
			   if (cur_ptr->fnt_os_tbl[i].fst_frac_fnt < 0)
			   {
			      fst_fnt = cur_ptr->fnt_os_tbl[i].fst_char_fnt;
			   }
			   else
			   {
		              fst_fnt = cur_ptr->fnt_os_tbl[i].fst_frac_fnt;
			   }
			}
			else
			{
			   fst_fnt = cur_ptr->fnt_os_tbl[i].fst_char_fnt;
			}
		     }

		     *font_id = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].font_id;
		     *body_size = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].body_size;
		     *decent = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].decent;
		     *flags = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].flags;
			   
		 }
		 else
		 {
    /* is virtual font number valid ?  */

	 	    if ((virt_font_no >= 0) && (virt_font_no < 64))
		    {


		       if ((in_flags & BITMAP_FONT) &&
			   (cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].flags & FILLABLE_FONT))
		       {
			    bmaptbl_ptr = cur_ptr->fnt_os_tbl[i].bmaptbl;
			    outline_bodysize = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].body_size;
			    outline_decent = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].decent;
			    bmap_not_found = TRUE;

			    *body_size *= (outline_bodysize/(outline_bodysize - outline_decent));

                            time_stamp = 0xffffffff;
                            font_to_replace = 0;
                            available_bmap_entry = -1;
                            for (j = 0; (j < DPFONT_CACHE_SIZE) && bmap_not_found; j++)
                            {
                                if (bmaptbl_ptr->fonts[j].font_id)
                                {
                                    
                                    if ((bmaptbl_ptr->fonts[j].virt_font_no == 
                                                                 virt_font_no) &&
                                        (*body_size > (bmaptbl_ptr->fonts[j].body_size -
                                                      BODYSIZE_FP_ERR)) &&
                                        (*body_size < (bmaptbl_ptr->fonts[j].body_size +
                                                      BODYSIZE_FP_ERR)) &&
                                        (angle > (bmaptbl_ptr->fonts[j].angle -
                                                      BODYSIZE_FP_ERR)) &&
                                        (angle < (bmaptbl_ptr->fonts[j].angle +
                                                      BODYSIZE_FP_ERR)) &&
                                        (aspect_ratio > (bmaptbl_ptr->fonts[j].aspect_ratio -
                                                      BODYSIZE_FP_ERR)) &&
                                        (aspect_ratio < (bmaptbl_ptr->fonts[j].aspect_ratio +
                                                      BODYSIZE_FP_ERR)))

                                    {
                                        bmap_not_found = FALSE;
                                        *font_id = bmaptbl_ptr->fonts[j].font_id;

                                        *decent = *body_size * (outline_decent /
                                                               outline_bodysize);
                                        *flags = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].flags;
                                        bmaptbl_ptr->fonts[j].time_stamp = 
                                                                    ++bmaptbl_ptr->count;

                                    }
                                    else
                                    {
                                        if (bmaptbl_ptr->fonts[j].time_stamp < time_stamp)
                                        {
                                            time_stamp = bmaptbl_ptr->fonts[j].time_stamp;
                                            font_to_replace = j;
                                        }
                                        
                                    }
                                }
                                else
                                {
                                    available_bmap_entry = j;
                                    break;
                                }
                                
                            }

                            if (bmap_not_found)
                            {
                                if (available_bmap_entry == -1)
                                {
                                    available_bmap_entry = font_to_replace;
                                    fe$rm_font(     msg = msg,
                                                    font_id = bmaptbl_ptr->fonts[font_to_replace].font_id);
                                }
                        /*
                         * TR#119602054 - The flag bit FS_DEMAND in add_font
                         * has been removed to avoid a crash. Using the default
                         * setting with FS_NO_KERN is being used now - Jeffrey
                         */
                                fe$add_font(msg = msg, 
                                            typeface = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].fontname, 
                                            bodysize = *body_size,
                                            charmap = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].charmap, 
					                        aspect = aspect_ratio,
					                        rotation = angle,
                                            font_id = font_id);

                                bmaptbl_ptr->fonts[available_bmap_entry].font_id = *font_id;
                                bmaptbl_ptr->fonts[available_bmap_entry].virt_font_no = 
                                                                            virt_font_no;
                                bmaptbl_ptr->fonts[available_bmap_entry].body_size = *body_size;
                                bmaptbl_ptr->fonts[available_bmap_entry].angle = angle;
                                bmaptbl_ptr->fonts[available_bmap_entry].aspect_ratio = aspect_ratio;
                                bmaptbl_ptr->fonts[available_bmap_entry].time_stamp = 
                                                                    ++bmaptbl_ptr->count;
                                *decent = *body_size * (outline_decent /
                                                           outline_bodysize);
                                *flags = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].flags;

                                

                            }
		       }
		       else
		       {		   
                           if(cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].body_size != 0.0)
                           {

                              *font_id = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].font_id;
                              *body_size = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].body_size;
                              *decent = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].decent;
                              *flags = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].flags;
                           }
                           else
                           {
                              if (cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].flags & FRAC_FONT)
                              {
                                 fst_fnt = cur_ptr->fnt_os_tbl[i].fst_frac_fnt;
                              }
                              else
                              {
                                 fst_fnt = cur_ptr->fnt_os_tbl[i].fst_char_fnt;
                              }

                              *font_id = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].font_id;
                              *body_size = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].body_size;
                              *decent = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].decent;
                              *flags = cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[fst_fnt].flags;
                           }
			}
		    }
		    else
		    {
#ifdef DEBUG
		       printf("\nERROR: Invalid virtual font number\n");
#endif
		       ret_cde = FALSE;
		       *msg = MSFAIL;
		       goto wrapup;
		    }
		 }
	      }  /* end then of if (...os_num == font_os_no)   */
	      else
	      {
		i++;
	      }  /* end else of (..os_num == font_os_no)   */

	   }  /* end of while (i < 33 && not_found  */

  /*  was the font table found   */

	   if (not_found)
	   {

	/*  if at the end of the table, see if there is another table  */

	      if (cur_ptr->next)
	      {
		 cur_ptr = cur_ptr->next;
	      }
	      else
	      {

   /*  If another object space table does not exist, use fast char font	   */
   /*  of the first object space					   */

		 not_found = FALSE;
		 fst_fnt = cur_ptr->fnt_os_tbl[0].fst_char_fnt;

		 *font_id= cur_ptr->fnt_os_tbl[0].fnt_tbl->fonts[fst_fnt].font_id;
		 *body_size = cur_ptr->fnt_os_tbl[0].fnt_tbl->fonts[fst_fnt].body_size;
		 *decent = cur_ptr->fnt_os_tbl[0].fnt_tbl->fonts[fst_fnt].decent;
		 *flags = cur_ptr->fnt_os_tbl[0].fnt_tbl->fonts[fst_fnt].flags;

	      } /* end else of if (cur_ptr->next)   */

	   } /* end then of if (not_found)  */

	} /* end of while (not_found)  */

wrapup:
	return (ret_cde);
       
     } /* end DPgetfntadr */

 

