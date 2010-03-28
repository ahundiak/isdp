/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPdel_fnt_tbl

          Abstract:   This routine will deallocate space of a font table
		      for a specific object space.


----
%SC%

     VALUE = DPdel_fnt_tbl(msg,fnt_os_tbl,fnt_os)

----
%EN%

      ON ENTRY:

        NAME            DATA TYPE                   DESCRIPTION
      ----------      --------------         -------------------------
      *fnt_os_tbl     struct DPfnt_os_tbl    pointer to the font object
					     space table

      fnt_os	      GRspacenum	     the object space number of
					     the table to be deleted
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
		
		OM_dealloc()

----
%NB%

      NOTES:   None

----
%CH%

       AET   02/02/86   : Creation date
       AET   12/11/87	: Change fnt_os argument to be received by value

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	This routine will deallocate memory of a font table and free that
	location in the object space table.

---*/
/*EH*/

#include <FSTypes.h>
#include <FS.h>

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "dpfont.h"
#include "femacros.h"

/* prototype files */
#include "dpdelfntbl.h"


DPdel_fnt_tbl(	IGRlong			*msg,
		struct DPfnt_os_tbl	*fnt_os_tbl,
		GRspacenum		fnt_os )
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

  /*  search current table until the slot to be deleted is found or the */
  /*  entire table has been searched			       		*/

	   while ((i < 33) && (not_found))
	   {

	/*  correct slot ?  */

	      if (cur_ptr->fnt_os_tbl[i].os_num == font_os_no)
	      {
		 not_found = FALSE;

    /*  clear the object space number  */

		 cur_ptr->fnt_os_tbl[i].os_num = -1;

		 bmaptbl_ptr = cur_ptr->fnt_os_tbl[i].bmaptbl;

		 for (j = 0; j < DPFONT_CACHE_SIZE; j++)
		 {
		     if (bmaptbl_ptr->fonts[j].font_id)
		     {
			fe$rm_font( msg = msg,
				    font_id = bmaptbl_ptr->fonts[j].font_id);
		     }
		 }

		 om$dealloc(ptr = cur_ptr->fnt_os_tbl[i].bmaptbl);

    /*  deallocate the memory of the font table space 	        */

		 om$dealloc(ptr = cur_ptr->fnt_os_tbl[i].fnt_tbl);

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
       
     } /* end DPcreate_fnt  */

 

