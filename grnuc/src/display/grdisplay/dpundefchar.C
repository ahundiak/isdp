/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPset_undef_char

          Abstract:   This routine will set the undefined character
		      that is used when a character has no stroke
		      definition.


----
%SC%

     VALUE = DPset_undef_char(msg,fun_facts,undef_char_ptr)

----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------

      *fun_facts	struct	f_facts		pointer to fun fact 
						information

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------	-----------------      --------------------------
      *msg		IGRlong		         return status
				  	       MSSUCC - successfully completed
				  	       MSFAIL - unsuccessfully completed

      *undef_char_ptr	IGRchar			contains the strokes for
						the undefined character

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

	   This routine will construct the strokes for the undefined
	character.


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
#include "dpundefchar.h"


    int DPset_undef_char(msg,fun_facts,undef_char_ptr)

	IGRlong		*msg;
	struct f_facts	*fun_facts;
	IGRchar		*undef_char_ptr;

     {

	IGRlong	half_tile;
	IGRshort vec_resolution;

	*msg = MSSUCC;
	half_tile = fun_facts->tile_height >> 1;
	vec_resolution = fun_facts->vector_word_size;

	*(IGRshort *) undef_char_ptr = 0;
	undef_char_ptr += 2;

	*(IGRshort *) undef_char_ptr = 1;
	undef_char_ptr += 2;

	*(IGRshort *) undef_char_ptr = 1;
	undef_char_ptr += 2;

	*(IGRshort *) undef_char_ptr = 8;
	undef_char_ptr += 2;

	if (vec_resolution == BYTE_VEC_RES)
	{
	   *undef_char_ptr++ = (IGRchar ) fun_facts->x_origin +
			     half_tile;
	   *undef_char_ptr++ = (IGRchar ) fun_facts->y_origin;

	   *undef_char_ptr++ = (IGRchar ) fun_facts->x_origin +
			     half_tile;
	   *undef_char_ptr++ = (IGRchar ) fun_facts->y_origin +
			     fun_facts->tile_height;

	   *undef_char_ptr++ = BYTE_DISCONNECT;
	   *undef_char_ptr++ = BYTE_DISCONNECT;

	   *undef_char_ptr++ = (IGRchar ) fun_facts->x_origin;
	   *undef_char_ptr++ = (IGRchar ) fun_facts->y_origin;

	   *undef_char_ptr++ = (IGRchar ) fun_facts->x_origin +
			     fun_facts->tile_height;
	   *undef_char_ptr++ = (IGRchar ) fun_facts->y_origin +
			     fun_facts->tile_height;

	   *undef_char_ptr++ = BYTE_DISCONNECT;
	   *undef_char_ptr++ = BYTE_DISCONNECT;

	   *undef_char_ptr++ = (IGRchar ) fun_facts->x_origin +
			     fun_facts->tile_height;
	   *undef_char_ptr++ = (IGRchar ) fun_facts->y_origin;

	   *undef_char_ptr++ = (IGRchar ) fun_facts->x_origin;
	   *undef_char_ptr++ = (IGRchar ) fun_facts->y_origin +
			     fun_facts->tile_height;
	}
	else
	{
	   if (vec_resolution == WORD_VEC_RES)
	   {
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->x_origin +
			     half_tile;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->y_origin;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->x_origin +
			     half_tile;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->y_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = WORD_DISCONNECT;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = WORD_DISCONNECT;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->x_origin;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->y_origin;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->x_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->y_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = WORD_DISCONNECT;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = WORD_DISCONNECT;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->x_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->y_origin;
	      undef_char_ptr += 2;

	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->x_origin;
	      undef_char_ptr += 2;
	      *(IGRshort *) undef_char_ptr = (IGRshort ) fun_facts->y_origin +
			     fun_facts->tile_height;
	   }
	   else
	   {
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->x_origin +
			     half_tile;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->y_origin;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->x_origin +
			     half_tile;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->y_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = LONG_DISCONNECT;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = LONG_DISCONNECT;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->x_origin;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->y_origin;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->x_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->y_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = LONG_DISCONNECT;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = LONG_DISCONNECT;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->x_origin +
			     fun_facts->tile_height;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->y_origin;
	      undef_char_ptr += 4;

	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->x_origin;
	      undef_char_ptr += 4;
	      *(IGRlong *) undef_char_ptr = (IGRlong ) fun_facts->y_origin +
			     fun_facts->tile_height;

	   }	
	} 

	return(TRUE);

     }
