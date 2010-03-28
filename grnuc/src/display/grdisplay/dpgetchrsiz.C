/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPgetchrsiz

          Abstract:    This routine will get the size of the character


----
%SC%

     VALUE = DPgetchrsiz(msg,strokes,fun_facts,strk_ptr,character,char_size)

----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------

      *strokes		struct strk		stroke structure

      *fun_facts	struct f_facts		fun facts structure

      *strk_ptr		IGRchar			pointer to the vectors
						of the character

      *character	IGRshort		current character

----
%EX%

        NAME		DATA TYPE                   DESCRIPTION
      ----------	-----------------      --------------------------
	*msg		IGRlong		         return status
				  	        MSSUCC - successfully completed
				  	        MSFAIL - unsuccessfully completed

      *char_size	IGRlong			size of the character

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

       AET   02/14/86   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

	   This routine will return the size of the character based upon
	the next characters offset.

---*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "font.h"
#include "dpfont.h"
#include "dpdef.h"
#include "dppriv.h"
#include "msdef.h"
#include <math.h>

/* prototype files */
#include "dpgetchrsiz.h"


	IGRint  DPgetchrsiz(msg,strokes,fun_facts,strk_ptr,character,
			    char_size)

	  IGRlong		*msg;
	  struct strk		*strokes;
	  struct f_facts	*fun_facts;
	  IGRchar		*strk_ptr;
	  IGRshort unsigned	*character;
	  IGRlong		*char_size;

	 {


	   IGRlong 	last_char;
	   IGRint	ii;
	   IGRint	value = TRUE;
	   IGRboolean	not_found;
	   IGRlong	num_bytes_in_char;
	   IGRlong	num_bytes_for_dis;

		 *msg = MSSUCC;
		 last_char = strokes->first_chr + strokes->num_chr -1;
		 ii = *character + 1;
		 not_found = TRUE;
		

  /*  look for next defined character					*/

		 while ((ii <= last_char) && (not_found))
		 {
		    if (strokes->stroke_offsets[ii] != -1)
		    {
		       num_bytes_in_char = strokes->stroke_offsets[ii] -
					   strokes->stroke_offsets[*character];

		       not_found = FALSE;
		    }

		    ii++;

		 }

  /*  if last character, use length of strokes to determine length	*/

		 if (not_found)
		 {
		    num_bytes_in_char = strokes->num_bytes_stroke_def -
				strokes->stroke_offsets[*character] + 1;
		 }

  /*  calculate number of bytes needed for disconnect			*/

		 num_bytes_for_dis = *(strk_ptr + 2) * NUM_VEC_IN_INBUF *
				  fun_facts->vector_word_size;
		 
		 *char_size = num_bytes_for_dis + num_bytes_in_char;


wrapup:
	         return(value);

	}
