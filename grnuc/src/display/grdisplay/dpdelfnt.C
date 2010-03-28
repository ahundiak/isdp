/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPdel_fnt

          Abstract:   This routine will delete a font from the particular 
		      font table


----
%SC%

     VALUE = DPdel_fnt(msg,fnt_os_tbl,fnt_os,virt_font_no)

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
       AET   12/11/87	: Changed last two arguments to passed by value
----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	This routine will null out the font pointers in the font table
	for a particular object space

---*/
/*EH*/

#include <FSTypes.h>
#include <FS.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dpfont.h"
#include "msdef.h"
#include "femacros.h"

/* prototype files */
#include "dpdelfnt.h"

DPdel_fnt(	IGRlong		     *msg,
		struct DPfnt_os_tbl  *fnt_os_tbl,
		GRspacenum	     fnt_os,
		IGRshort	     virt_font_no )

     {	

	struct DPfnt_os_tbl  	*cur_ptr;
	IGRboolean		not_found = TRUE;
 	IGRboolean		ret_cde = TRUE;
	IGRint			i,j;
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

    /*  add font to font table  */

	 	 if ((virt_font_no >= 0) && (virt_font_no < 64))
		 {
		    cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].font_id = NULL;
		    cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].body_size = 0.0;

		    bmaptbl_ptr = cur_ptr->fnt_os_tbl[i].bmaptbl;

		    for  (j = 0; j < DPFONT_CACHE_SIZE; j++)
		    {
			if (bmaptbl_ptr->fonts[j].font_id)
			{
			    if (bmaptbl_ptr->fonts[j].virt_font_no == virt_font_no)
		            {
			        fe$rm_font ( msg = msg,
				             font_id = bmaptbl_ptr->fonts[j].font_id);

			        bmaptbl_ptr->fonts[j].font_id = NULL;
			    }
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

   /*  If another object space table does not exist, exit	   */

		 not_found = FALSE;
#ifdef DEBUG
		 printf("\nWARNING: Object space font table not found\n");
#endif
	      } /* end else of if (cur_ptr->next)   */

	   } /* end then of if (not_found)  */

	} /* end of while (not_found)  */

wrapup:
	return (ret_cde);
       
     } /* end DPchg_fst_fnt  */

 

