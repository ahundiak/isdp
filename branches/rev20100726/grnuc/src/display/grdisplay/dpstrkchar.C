/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPstrkchar

          Abstract:    This routine will actually stroke the character.


----
%SC%

     VALUE = DPstrkchar(msg,vec_resolution,strk_ptr,buffer,fun_facts,
			fnt_to_screen,abc_width,num_pnts)


----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------

      *vec_resolution	IGRshort		vector resolution of the
						strokes

      *strk_ptr		IGRchar			pointer to the strokes

      *fun_facts	struct f_facts		pointer to the fun fact 
						information

      *fnt_to_screen	IGRdouble		matrix that takes strokes
						from the font coordinate
						system to the screen
						coordinate system

      *abc_width	IGRlong			the abc width of the character.
						used if an old style font



----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------	-----------------      --------------------------
      *msg		IGRlong			return status
						 MSSUCC - successfully completed
						 MSFAIL - unsuccessfully completed

      *buffer		IGRdouble		contains the screen
						values of the strokes

      *num_pnts		IGRlong			contains the number of points
						in the buffer


      VALUE() =    TRUE if successful
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  

	MAptsxform()

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



---*/
/*EH*/

#include <math.h>
#include <values.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "font.h"
#include "dpfont.h"
#include "dppriv.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "msdef.h"

/* prototype files */
#include "dpstrkchar.h"


#define  MAXDOUBLE  1.79769313486231470e+308


	int DPstrkchar(msg,vec_resolution,strk_ptr,buffer,fun_facts,
		       fnt_to_screen,abc_width,num_pnts)

	
	  IGRlong	*msg;
	  IGRshort	*vec_resolution;
	  IGRchar	*strk_ptr;
	  IGRdouble	*buffer;
	  struct f_facts *fun_facts;
	  IGRdouble	*fnt_to_screen;
	  IGRlong	*abc_width;
	  IGRlong	*num_pnts;

	{


	  IGRlong    value = TRUE;
	  IGRshort   num_vec_ele;
	  IGRdouble  *out_buf_ptr;
	  IGRdouble  *start_buf;
	  IGRint     j;
	  IGRint     k;
	  IGRlong    num_vec_in_buf;
	  IGRshort   num_vec;
	  IGRlong    disconnect;	
	  IGRshort   short_x_vec;
	  IGRshort   short_y_vec;
	  IGRlong    x_vec;
	  IGRlong    y_vec;

	  IGRboolean first_char = TRUE;


	  *msg = MSSUCC;

  /*  skip options flag							*/

	  strk_ptr += 2;
	  OM_BLOCK_MOVE( strk_ptr,
                         &num_vec_ele,
                         sizeof(IGRshort));

	   strk_ptr += 2;


   /* set up pointer to output buffer   				*/

	   out_buf_ptr = buffer;
	   start_buf = buffer;

  /*  stroke for each vector element					*/
		 for ( j = 0; j < num_vec_ele; j++)
		 {
  /* if this is first character, dont check for disconnect		*/

		    if (!first_char)
		    {

  /*  don't put in disconnect if disconnect is last vecter in the buffer*/

		       if (*(out_buf_ptr - 3) != MAXDOUBLE)
		       {

  /*  calculate the number of vectors to be converted to screen 	*/
  /*  coordinates.							*/

			  num_vec_in_buf = ((IGRchar *) out_buf_ptr - 
					    (IGRchar *) start_buf)/(3*sizeof(IGRdouble));

  /*  are the any new vectors in the buffer				*/

			  if (num_vec_in_buf)
			  {

  /*  transform points to screen coordinates				*/

			     if (!(value = MAptsxform(msg,&num_vec_in_buf,
				   fnt_to_screen,start_buf,start_buf)))
			     {
				goto wrapup;
			     }
			  }

  /*  set start buf right after the disconnect				*/

			  start_buf = out_buf_ptr + 3;

  /*  insert a disconnect						*/

			  *out_buf_ptr++ = MAXDOUBLE;
			  out_buf_ptr += 2;

		       } /* end of then part of if (*(out_buf_ptr-3)!=MAXDOUBLE)  */


		    }  /* end of then of if (!first_char)  */
		    else
		    {
		       first_char = FALSE;
		    }


  /*  see if the vectors are of type line string		 	*/

		    if (((*strk_ptr) != LINE_STRING) &&
			((*strk_ptr) != VECTOR_LIST_ARC) &&
			((*strk_ptr) != FILLED_CHAR))
		    {
		    /* process fill character  */
		    }
		    else
		    {
		       strk_ptr += 2;
		       OM_BLOCK_MOVE( strk_ptr,
                                      &num_vec,
                                      sizeof(IGRshort));
/*		       num_vec = *(IGRshort *) strk_ptr;*/

		       strk_ptr += 2;

  /*  loop through for each vector					*/
	
		       for (k= 0; k < num_vec; k++)
		       {

  /*  check for disconnect						*/

			  if (*vec_resolution == BYTE_VEC_RES)
			  {
			      disconnect = -(BYTE_DISCONNECT);
			      x_vec = *strk_ptr++;
			      y_vec = *strk_ptr++;
			   }
			   else
			   {
			      if (*vec_resolution == WORD_VEC_RES)
			      {
				 disconnect = -(WORD_DISCONNECT);
		       		 OM_BLOCK_MOVE( strk_ptr,
                                                       &short_x_vec,
                                                       sizeof(IGRshort));
				 x_vec = short_x_vec;
				 strk_ptr += 2;
		       		 OM_BLOCK_MOVE( strk_ptr,
                                                       &short_y_vec,
                                                       sizeof(IGRshort));
				 y_vec = short_y_vec;
				 strk_ptr += 2;
			      }
			      else
			      {
				 disconnect = LONG_DISCONNECT;
		       		 OM_BLOCK_MOVE( strk_ptr,
                                                       &x_vec,
                                                       sizeof(IGRlong));

				 strk_ptr += 4;
		       		 OM_BLOCK_MOVE( strk_ptr,
                                                       &y_vec,
                                                       sizeof(IGRlong));


				 strk_ptr += 4;
			      }
			   }

			  if (x_vec == disconnect)
			  {

  /*  make sure disconnect is not last vector in the buffer		*/

			     if (*(out_buf_ptr - 3) != MAXDOUBLE)
			     {

  /*  see how many vectors have to be transformed to screen coordinates	*/

				num_vec_in_buf = ((IGRchar *) out_buf_ptr - 
						  (IGRchar *) start_buf)/(3*sizeof(IGRdouble));
				if (num_vec_in_buf)
				{
				   if (!(value=MAptsxform(msg,&num_vec_in_buf,
					fnt_to_screen,start_buf,start_buf)))
				   {
				      goto wrapup;
				   }
				}

  /* set start position immediately following the disconnect		*/

				start_buf = out_buf_ptr + 3;

  /*  insert a disconnect						*/

				*out_buf_ptr++ = MAXDOUBLE;
			 	out_buf_ptr += 2;

			     } /* end of then of if (*(out_buf_ptr.. != .. */


			  } /* end of then of ( x_vec == disconnect) */

		          else
		          {
			     *out_buf_ptr++ = (IGRdouble ) x_vec;

			     *out_buf_ptr++ = (IGRdouble ) y_vec;


  /*  if old style font, adjust stroke accordingly			*/

			     if ((OLD_STYLE_FONT) && (*abc_width > 222))
			     {
				*(out_buf_ptr - 2) = *(out_buf_ptr - 2) *
				 ((IGRdouble ) *abc_width / 222);

				*(out_buf_ptr - 1) = *(out_buf_ptr - 1) *
				 ((IGRdouble) *abc_width / 222);
			     }

			     *out_buf_ptr++ = 0;

			  } /* end of else of (*(IGRchar ... == BYTE ..) */

		       }  /* end of for (j= 0; ....  */

		    } /* end of else of (*(IGRchar ...!= LINE_STRING  */

		 } /*  end of for (i=0; ...   */


  /*  see how many vectors have to be transformed to screen coordinates	*/

		num_vec_in_buf = ((IGRchar *) out_buf_ptr - 
				  (IGRchar *) start_buf)/(3*sizeof(IGRdouble));
		if (num_vec_in_buf)
		{
		   if (!(value = MAptsxform(msg,&num_vec_in_buf,
			fnt_to_screen,start_buf,start_buf)))
		   {
		      goto wrapup;
		   }
		}

		 *num_pnts = ((IGRchar *) out_buf_ptr -
			     (IGRchar *) buffer)/(3*sizeof(IGRdouble));

wrapup:

	    return(value);

	   } /* end of DPstrkchar     */
