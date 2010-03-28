/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPadd_fnt

          Abstract:   This routine will add a font to the particular 
		      font table


----
%SC%

     VALUE = DPadd_fnt(msg,fnt_os_tbl,fnt_os,virt_font_no,fond_id,
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

      font_id		IGRint			font_id that identifies 
						the font in font server

      bodysize		IGRdouble		size the font was created

      decent		IGRdouble		units of the bodysize
						that are below the baseline

      flags		IGRint			tells information about the font

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
       AET   12/11/87	: Changed to correpond the the new structure that was
			  created because of font server
----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	This routine will insert the font pointers into the font table
	for a particular object space

---*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpfont.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "msdef.h"

/* prototype files */
#include "dpaddfnt.h"

   DPadd_fnt(msg,fnt_os_tbl,fnt_os,virt_font_no,font_id,
		 body_size,decent,flags)

	IGRlong		     *msg;
	struct DPfnt_os_tbl  *fnt_os_tbl;
	GRspacenum	     fnt_os;
	IGRshort	     virt_font_no;
	IGRint		     font_id;
	IGRdouble	     body_size;
	IGRdouble	     decent;
	IGRint		     flags;


     {	

	struct DPfnt_os_tbl  	*cur_ptr;
	IGRboolean		not_found = TRUE;
 	IGRboolean		ret_cde = TRUE;
	IGRint			i;
	GRspacenum		font_os_no;


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
		    cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].font_id = font_id;
		    cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].body_size = body_size;
		    cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].decent = decent;
		    cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[virt_font_no].flags = flags;
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
       
     } /* end DPadd_fnt  */

 

