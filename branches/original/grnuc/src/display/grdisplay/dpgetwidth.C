/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPgetwidth

          Abstract:   This routine will get the width of the character
		   and also set the pointer to the strokes.

----
%SC%

     VALUE = DPgetwidth(msg,strokes,fun_facts,widths,character,first_char,
			abc_width,width,prev_width,ideal_char_width,
			strk_ptr,undef_char_ptr,vec_resolution,txt_x_scale,
			is_char_defined)


----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------

      *strokes		struct strk		pointer to the stroke 
						information

      *fun_facts	struct f_facts		pointer to the fun facts
						structure

      *widths		struct wids		pointer to the widths structure

      *character	IGRshort		current character

      *first_char	IGRboolean		is this the first character
						in the character string

      *prev_width	IGRdouble		previous characters width

      *ideal_char_width	IGRdouble		the ideal character length

      *undef_char_ptr	IGRchar			pointer to the undefined
						character

      *vec_resolution	IGRshort		vector resolution

      *txt_x_scale	IGRdouble		text x scale

      
----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------	-----------------       --------------------------
      *msg		IGRlong		         return status
				  	           MSSUCC - successfully completed
						   MSFAIL - unsuccessfully completed
						
      *abc_width	IGRlong			the abc width of the character

      *width		IGRdouble		the width of the character

      **strk_ptr	IGRchar			pointer to strokes of the 
						character

      *is_char_defined	IGRboolean		is the character defined



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

       AET   03/07/86   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


	   This routine will use find the width of the character depending
	on whether the character is defined, a blank, from an old font ,
	the first character, etc.  It will also set the pointer	to the strokes.


---*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "font.h"
#include "dpfont.h"
#include "dppriv.h"
#include "dpdef.h"
#include "msdef.h"
#include <math.h>

/* prototype files */
#include "dpgetwidth.h"


	IGRint	DPgetwidth(msg,strokes,fun_facts,widths,character,first_char,
			   abc_width,width,prev_width,ideal_char_width,
			   strk_ptr,undef_char_ptr,vec_resolution,txt_x_scale,
			   is_char_defined)


	   IGRlong		*msg;
	   struct  strk		*strokes;
	   struct  f_facts	*fun_facts;
	   struct  wids		*widths;
	   IGRshort unsigned	*character;
	   IGRboolean		*first_char;
	   IGRlong		*abc_width;
	   IGRdouble		*width;
	   IGRdouble		*prev_width;
	   IGRdouble		*ideal_char_width;
	   IGRchar 		**strk_ptr;
	   IGRchar 		*undef_char_ptr;
	   IGRshort		*vec_resolution;
	   IGRdouble		*txt_x_scale;
	   IGRboolean		*is_char_defined;

	  {

	   IGRint	value = TRUE;


	      *msg = MSSUCC;	
  /*  see if character is undefinded					*/

	      if (strokes->stroke_offsets[*character] == UNDEFINED_CHARACTER)
	      {

	         *is_char_defined = FALSE;

		 if ((*character != BLANK) || (*first_char))
		 {
  /* null out abc width so if an old style font, the stroke will not 	*/
  /* change								*/

		    *abc_width = NULL;
		    *width = *ideal_char_width;
		    *prev_width = *width;

  /*  if character is a blank, don't stroke the undefined character	*/

		    if (*character == BLANK)
		    {
		       *strk_ptr = NULL;
		    }
		    else
		    {

  /*  use the undefined character					*/

		       *strk_ptr = undef_char_ptr;


		    }

		 }  /* end of then of  if(character !=BLANK)  */

		 else
		 {

  /* if character is a blank, use the previous width			*/

		    *width = *prev_width;
		    *strk_ptr = NULL;
		 }

	      }  /* end of then part of if (...offsets[char..] == UNDE... */

	      else
	      {

  /*  check for vector resolution   */

		 *is_char_defined = TRUE;

		 if (*vec_resolution == BYTE_VEC_RES)
		 {
		    *abc_width =widths->dim_data.byte_u[(*character -fun_facts->first_char)*
		         fun_facts->num_dim_fields];
		 }
		 else
		 {
		    if (*vec_resolution == WORD_VEC_RES)
		    {
		       *abc_width =widths->dim_data.word_u[(*character -fun_facts->first_char)*
		         fun_facts->num_dim_fields];
		    }
		    else
		    {
		       *abc_width =widths->dim_data.long_u[(*character -fun_facts->first_char)*
		         fun_facts->num_dim_fields];
		    }
		 }

  /* double the abc_width of an old style font				*/

		 if (OLD_STYLE_FONT)
		 {
		    *abc_width <<= 1;
		 }
		 
		 *width = *abc_width * fun_facts->x_scale * *txt_x_scale;
		 *prev_width = *width;

  /*  point to the vectors of the specific character			*/

		 *strk_ptr = (IGRchar *) strokes->strks + 
			     strokes->stroke_offsets[*character];

	      }


wrapup:	

	return(value);

	}   
