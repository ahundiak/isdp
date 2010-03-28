/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPcreate_fnt_tbl

          Abstract:   This routine will allocate space for a font table
		      and put the pointer to that table in the font object
		      space table.


----
%SC%

     VALUE = DP_create_fnt_tbl(msg,fnt_os_tbl,fnt_os)

----
%EN%

      ON ENTRY:

        NAME            DATA TYPE                   DESCRIPTION
      ----------      --------------         -------------------------
      *fnt_os_tbl     struct DPfnt_os_tbl    pointer to the font object
					     space table

      fnt_os	      GRspacenum	     the object space number to
					     create a table for
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
		
		OM_malloc()

----
%NB%

      NOTES:   None

----
%CH%

       AET   02/01/86   : Creation date
       AET   12/11/87	: change fnt_os argument to by value
----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	This routine will create memory for a font table and then find
	a slot in the font object space table and put the object space 
	number and the address of that space's font table in that slot.

---*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "dpfont.h"
#include "msdef.h"

/* prototype files */
#include "dpcrefntbl.h"


#if defined(__STDC__) || defined(__cplusplus)
   DPcreate_fnt_tbl( IGRlong		  *msg,
		     struct DPfnt_os_tbl  *fnt_os_tbl,
		     GRspacenum		  fnt_os )
#else
   DPcreate_fnt_tbl(msg,fnt_os_tbl,fnt_os)

	IGRlong		     *msg;
	struct DPfnt_os_tbl  *fnt_os_tbl;
	GRspacenum	     fnt_os;
#endif
     {	

	struct DPfnt_os_tbl  	*cur_ptr;
	IGRboolean		not_found = TRUE;
	IGRboolean		ret_cde = TRUE;
	IGRint			i,j;
	GRspacenum		font_os_no;
	struct DPbmap_tbl	*bmaptbl_ptr;

	font_os_no = fnt_os;
	cur_ptr = fnt_os_tbl;

  /*  search table until an empty slot is found  */

	while (not_found)
	{
	   i = 0;

  /*  search current table until an empty slot is found or the */
  /*  entire table has been searched			       */

	   while ((i < 33) && (not_found))
	   {

	/*  empty slot ?  */

	      if (cur_ptr->fnt_os_tbl[i].os_num < 0)
	      {
		 not_found = FALSE;

    /*  fill in object space number  */

		 cur_ptr->fnt_os_tbl[i].os_num = font_os_no;

    /*  allocate space for font table and put the address in        */
    /*  the object space table					    */

		 cur_ptr->fnt_os_tbl[i].fnt_tbl = (struct DPfnt_tbl *)
				  om$malloc(size = sizeof(struct DPfnt_tbl));

		 if (!cur_ptr->fnt_os_tbl[i].fnt_tbl)
		 {
#ifdef DEBUG
		    printf("\nERROR: Out of dynamic memory in DPcreate_fnt\n");
#endif
		    *msg = MSFAIL;
		    ret_cde = FALSE;
		    goto wrapup;
		 }
		 else
		 {
		    for (j=0; j < 64; j++)
		    {
		      
		       cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[j].body_size = 
								  0.0;
		       cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[j].font_id = 
								  NULL;
		       cur_ptr->fnt_os_tbl[i].fnt_tbl->fonts[j].flags = 
								  NULL;
		    }

		    bmaptbl_ptr = (struct DPbmap_tbl *)
				  om$malloc(size = sizeof(struct DPbmap_tbl));

                    if (!bmaptbl_ptr)
                    {
#ifdef DEBUG
                       printf("\nERROR: Out of dynamic memory in DPcreate_fnt\n");
#endif
                       *msg = MSFAIL;
                       ret_cde = FALSE;
                       goto wrapup;
                    }
		    else
		    {
			cur_ptr->fnt_os_tbl[i].bmaptbl  = bmaptbl_ptr;
			bmaptbl_ptr->count = 0;

			for (j = 0; j < DPFONT_CACHE_SIZE; j ++)
			{
			    bmaptbl_ptr->fonts[j].font_id = 0;
			}

		    }

		 }
	      }  /* end then of if (...os_num < 0)   */
	      else
	      {
		i++;
	      }  /* end else of (..os_num < 0)   */

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

   /*  If another object space table does not exist, allocate memory   */
   /*  for it and set the next pointer in previous table	       */

		 cur_ptr->next = (struct DPfnt_os_tbl *) 
			   om$malloc(size = sizeof(struct DPfnt_os_tbl));
		    
		 if (!cur_ptr->next)
		 {
#ifdef DEBUG	
		    printf("\nERROR: Out of dynamic memory in DPcreate_fnt\n");
#endif
		    *msg = MSFAIL;
		    ret_cde = FALSE;
		    goto wrapup;
		 }
		 else
		 {
		    cur_ptr = cur_ptr->next;

	/* initialize object space numbers to -1     */

		    for (i=0; i < 33; i++)
		    {
		       cur_ptr->fnt_os_tbl[i].os_num = -1;
		    }

		    cur_ptr->next = NULL;

		 } /* end then of if (!cur_ptr->next)   */

	      } /* end else of if (cur_ptr->next)   */

	   } /* end then of if (not_found)  */

	} /* end of while (not_found)  */

wrapup:
	return (ret_cde);
       
     } /* end DPcreate_fnt  */

 

