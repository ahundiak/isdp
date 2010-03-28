/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPchg_fst_fnt

          Abstract:   This routine will change the fast font numbers
		      of a particular font table


----
%SC%

     VALUE = DPdel_fnt_tbl(msg,fnt_os_tbl,fnt_os,fst_char_fnt,fst_sym_fnt,
			   fst_lin_fnt,fst_ptrn_fnt)

----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *fnt_os_tbl       struct DPfnt_os_tbl     pointer to the font object
					        space table

      *fnt_os	        GRspacenum	        the object space number of
					        the table to be deleted

      fst_char_fnt	IGRshort		the virtual font number of
						the fast character font

      fst_frac_fnt	IGRshort		the virtual font number of
						the fast fraction font

      fst_16bit_fnt	IGRshort		the virtual font number of
						the fast 16-bit font


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

       AET   02/02/86   : Creation date
       AET   12/11/87   : change argument list to only fast char font and 
			  change fst_char_fnt to be received by value 
       AET   03/17/88	: added fast fraction font
       AET   06/20/88	: added fast 16-bit font

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	This routine will change the the fast fonts for a particular
	font table. If you do want do change a fast font then the pointer
	to that fast font has to be NULL.

---*/
/*EH*/

#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpfont.h"
#include "dp.h"
#include "dpstruct.h"

/* prototype files */
#include "dpchgfstfnt.h"


   DPchg_fst_fnt(IGRlong	     *msg,
		 struct DPfnt_os_tbl *fnt_os_tbl,
		 GRspacenum	     fnt_os,
		 IGRshort	     fst_char_fnt,
		 IGRshort	     fst_frac_fnt,
		 IGRshort	     fst_16bit_fnt )
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

    /*  change the fast font number if needed  */

		 cur_ptr->fnt_os_tbl[i].fst_char_fnt = fst_char_fnt;
		 cur_ptr->fnt_os_tbl[i].fst_frac_fnt = fst_frac_fnt;
		 cur_ptr->fnt_os_tbl[i].fst_16bit_fnt = fst_16bit_fnt;


	      }  /* end then of if (...os_num == font_os_no)   */
	      else
	      {
		i++;
	      }  /* end else of (..os_num == font_os_no)   */

	   }  /* end of while (i < 33 && not_found  */

  /*  was an empty slot found  */

	   if (not_found)
	   {

   /*  if no empty slot was found, but there is another object space   */
   /*  table, change the current pointer to the new object space table */

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

	return (ret_cde);
       
     } /* end DPchg_fst_fnt  */

 

