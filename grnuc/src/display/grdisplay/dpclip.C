/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPclip

          Abstract:     This function clips vectors according to the range
                     in the view table.  There are bits in the view table
                     that need to be set if front and back clipping is to
                     be done.  

----
%SC%

     VALUE = DPclip(message,clip,front_clip,back_clip,dit_clip_range,
		    index,in_buf,no_in_vec,out_buf,no_out_vec)

----
%EN%

      ON ENTRY:

        NAME            DATA TYPE                   DESCRIPTION
      ----------      --------------         -------------------------
      clip	      IGRboolean	     TRUE if rectangular clipping
					        is to be done
					     FALSE if rectangular clipping
					        is not to be done

      front_clip      IGRboolean	     TRUE if front clipping is to
					        be done
					     FALSE if front clipping is not
					        to be done

      back_clip	      IGRboolean	     TRUE if back clipping is to
					        be done
					     FALSE if back clipping is not
					        to be done

      dit_clip_range  IGRdouble		     contains to range to be clipped
						against

      index           IGRlong		     Contains an index into the 
   					     input buffer.  The index is 
     					     the number of the vector to
 					     start processing.

      in_buf          IGRdouble              Contains the vectors to be
                                             clipped.  The vectors are of
                                             the format (X,Y,Z,homogenous)
                                             and there are disconnects 
                                             between each disconnected vector
                                             The disconnect is the constant
                                             MAXDOUBLE.  MAXDOUBLE is put in the X
                                             position with the others set
                                             to zero.

      no_in_vec       IGRlong                The number of input vectors, 
                                             including disconnects.

      no_out_vec      IGRlong                The number of output vectors
                                             that will fit in the output
                                             buffer

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
      message         IGRlong                Return code values are:

                                              DPCLPCOM   - successful completion
                                                           clip complete

                                              DPCLPNCOM  - successful completion
                                                           clip not complete

                                              DPCLPINRNG - invalid ranges

                                              DPCLPININ  - invalid number of
                                                           input vectors

                                              DPCLPINOUT - invalid number of 
                                                           output vectors

                                              DPCLPINBUF - invalid data in 
                                                           input buffer

					      DPCLPINDEX - invalid index

                                              If the clip is incomplete, 
                                              DPclip needs to be called again
                                              with the same information.

      index	      IGRlong		      Contains the number of the last
					      vector that was processed in the
 					      input buffer.
 
      out_buf         IGRdouble               Contains the vectors after they
                                              have been clipped.

      no_out_vec      IGRlong                 Contains the number of output
                                              vectors, including disconnects

      VALUE() =    TRUE if clip was successfully completed
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  None

----
%NB%

      NOTES:   None

----
%CH%

       AET   07/17/85   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


      This function is used to clip a design file to a particular range.
   The algorithm used was developed by Cohen and Sutherland and is very
   efficient in determing lines that can be trivially accepted and rejected.
   A bit is set for each boundary a point extends beyond.  For example, bit 
   1 is set if the point is above the window, bit 2 is set if it is below
   the window, etc. The following figure will show this more clearly:


                         |           |
                         
                  1001   |   0001    |  0101

                         |           |
               - - - - - ------------- - - - - -
			 |           |
			 |           |
                  1000   |   0000    |  0100
			 |           |
			 |           |
               - - - - - ------------- - - - - -
                         |           |

                  1010   |   0010    | 0110
                        
                         |           |

   When the AND operation is performed on the bit codes of the two points
   and the result is non-zero, the line can be rejected.  If the result is
   zero, the algorithm will calculate the intersection point for the line
   until the line is either accepted or rejected.  When the OR operation is
   performed on the bit codes of the two points and the result is zero, the 
   line can be accepted.

   This function receives an input buffer which contain vectors and 
   disconnects for those vectors which are not connected.  The function
   process those vectors and puts the clipped vertices in the output 
   buffer, putting in disconnects when neccesary.  The algorithm stops
   when either:
                1.  It processes the entire input buffer or
                2.  The output buffer is full 
                    ( In this case an status is returned to tell
                      the calling function that the input buffer has
                      not been completly processed )
 
   There are also bits that are checked to see if front or back cliping
   is desired. 

---*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"  
#include "dpdef.h"
#include "dperr.h"
#include "msdef.h"
#include <math.h>
#include <values.h>

/* prototype files */
#include dpclip.h"

/*  This is a macro that checks to see where the z-coordinate is in relation to */
/*  the the window and creates the bit code for the point.  It also checks     */
/*  to see if front and back clipping need to be done.                         */

#define   get_code_z(z,code) \
           code.clip=0;  \
           if ( *front_clip && (z < dit_clip_range[Z_LOW])) \
              code.cde.back=1; \
              else if ( *back_clip &&  (z > dit_clip_range[Z_HIGH])) \
                      code.cde.front=1;

/*  This macro checks to see where the x and y coordinate is in relationship */
/*  to the range and creates a bit code for the point.                       */

#define   get_code_xy(x,y,code)  \
       code.clip=0; \
 \
       if (x< dit_clip_range[X_LOW]) \
          code.cde.left=1; \
          else if (x> dit_clip_range[X_HIGH])  \
                  code.cde.right=1; \
 \
       if (y< dit_clip_range[Y_LOW])   \
          code.cde.bottom=1; \
          else if (y> dit_clip_range[Y_HIGH])  \
                  code.cde.top=1;

        

#define  X_LOW      0
#define  Y_LOW      1
#define  Z_LOW      2
#define  X_HIGH     3
#define  Y_HIGH     4
#define  Z_HIGH     5

#define  MAXDOUBLE  1.79769313486231470e+308


IGRint   DPclip(message,clip,front_clip,back_clip,dit_clip_range,
	  index,in_buf,no_in_vec,out_buf,no_out_vec)

      

	IGRlong    *message;			/* pointer to return message			*/
	IGRboolean *clip;			/* is rectanglur clipping desired? 		*/
	IGRboolean *front_clip;			/* is front clipping desired?			*/
	IGRboolean *back_clip;			/* is back clipping desired?			*/
	IGRdouble  dit_clip_range[];		/* range to clip against			*/
	IGRlong	   *index;			/* index into the input buffer			*/
	IGRdouble  *in_buf;			/* pointer to the input buffer			*/
	IGRlong    *no_in_vec;			/* pointer to the number of input vectors	*/
	IGRdouble  *out_buf;			/* pointer to the output buffer			*/
	IGRlong    *no_out_vec;			/* pointer to the number of output vectors	*/



    {

	struct clp
	   {
	unsigned short  left  :  1;
	unsigned short  right :  1;
	unsigned short  top   :  1;
	unsigned short  bottom:  1;
	unsigned short  front :  1;
	unsigned short  back  :  1;
	unsigned short  rfu   :  2;
	   };

	union clipcode
	   {
	     char   clip;
	     struct clp cde;
	   };

	union       clipcode code1;	/*  clip code for point 1						*/
	union       clipcode code2;	/*  clip code for point 2						*/
	union       clipcode *code;	/*  pointer to either the clip code for point 1 or point 2		*/
	IGRint      out_index = 0;	/*  contains the number of output vectors are in the output buffer	*/
	IGRdouble   x1,y1,z1;		/*  contains the first point						*/
	IGRdouble   x2,y2,z2;		/*  contains the second point						*/
	IGRdouble   x,y,z;		/*  temporary hold for either point 1 or point 2			*/
	IGRdouble   tmp_x,tmp_y,tmp_z;	/*  holds second point before it is clipped				*/
	IGRboolean  first_huge = TRUE;	/*  tell if first point is MAXDOUBLE  */
	IGRboolean  is_disconnect = FALSE;/*  tells whether we need a disconnect or not  1= need disconnect	*/
	IGRboolean  was_disconnect = TRUE;/*  tells whether we need to put 1 or 2 points in the output buffer	*/
	IGRboolean  accept;		/*  Trivial accept							*/
	IGRboolean  reject;		/*  Trivial reject							*/
	IGRboolean  value = TRUE;		/*  return code								*/


  /*    Make sure ranges are OK    */

	if (dit_clip_range[X_LOW] > dit_clip_range[X_HIGH] )
	{
	   *message = DPCLPINRNG;
	   value = FALSE;
	   goto wrapup;
	}

	if (dit_clip_range[Y_LOW] > dit_clip_range[Y_HIGH] )
	{
	   *message = DPCLPINRNG;
	   value = FALSE;
	   goto wrapup;
	}

	if (dit_clip_range[Z_LOW] > dit_clip_range[Z_HIGH] )
	{
	   *message = DPCLPINRNG;
	   value = FALSE;
	   goto wrapup;
	}

  /*    Make sure the number of input vectors is valid   */
	
	if (*no_in_vec < 2 )
	{
	   *message  = DPCLPININ;
	   value = FALSE;
	   goto wrapup;
	}	

  /*  Make sure the number of output vectors is valid  */
 
	if (*no_out_vec < 3)
	{
	   *message = DPCLPINOUT;
	   value = FALSE;
	   goto wrapup;
	}


  /*  Make sure there is not a disconnect in the last two points because       */
  /*  when a disconnect is found there has to be at least 2 points following.  */

	if ((in_buf[(*no_in_vec*3 - 3)]==MAXDOUBLE) || (in_buf[(*no_in_vec*3 -6)]==MAXDOUBLE))
	{
	   *message = DPCLPINBUF;
	   value = FALSE;
	   goto wrapup;
	}

  /*  see if index is valid  */

	if ( *index >= (*no_in_vec))
	{
	   *message = DPCLPINDEX;
	   value = FALSE;
	   goto wrapup;
	}


  /*   calculate where in the input buffer that is still left to be processed  */

	in_buf += ((*index)*3);

  /*  if the next point is the input buffer is not a disconnect, make sure the */
  /*  first point is not skipped over.                                         */

	if (*in_buf != MAXDOUBLE)
	{
	    first_huge = FALSE;
	    tmp_x = *in_buf++;
	    tmp_y = *in_buf++;
	    tmp_z = *in_buf++;
	    (*index)++;
	}

   /*   check to see if we need to do front and back clipping (2D or 3D)  */

	if ( !( *front_clip || *back_clip))
	{

	   if ( *clip)
	   {

  /*    continue processing until we are out of input or the output buffer is full  */

	      while ((*index < *no_in_vec) && (out_index +2 < *no_out_vec))
	      {
    
  /*    If a disconnect or first time through, get two new points   */

		 if (*in_buf == MAXDOUBLE)
		 {
		    in_buf += 3;
		    if (!was_disconnect)
		    {
	               is_disconnect = FALSE;
	               *out_buf++ = MAXDOUBLE;
	               *out_buf++ = 0;
	               *out_buf++ = 0;
	               out_index++;
	               was_disconnect = TRUE;
		    }
		    x1 = *in_buf++;
		    y1 = *in_buf++;
		    z1 = *in_buf++;

  /*   Keep original points in case they are clipped  */

		    tmp_x = x2 = *in_buf++;
		    tmp_y = y2 = *in_buf++;
		    tmp_z = z2 = *in_buf++;
		    *index += 3;
		 }

  /*   If not a disconnect, get next point  */

		 else 
		 {
		    x1 = tmp_x;
		    y1 = tmp_y;
		    z1 = tmp_z;
		    tmp_x=x2 = *in_buf++;
		    tmp_y=y2 = *in_buf++;
		    tmp_z=z2 = *in_buf++;
		    (*index)++;
		 }

  /*   Get bit codes to determine where the points are located  */

		 get_code_xy(x1,y1,code1);
		 get_code_xy(x2,y2,code2);
		 accept = reject = FALSE;

  /*  Continue processing until the line is accepted or rejected  */
   
		 do
		 {

        /*  Trivial accept  */

		    if ( !(code1.clip | code2.clip))
		    {
		       accept = TRUE;
		    }
		    else
		    {

           /*  Trivial reject  */

		       if (code1.clip & code2.clip)
		       {
			  reject = TRUE;
		       }
		       else
		       {

              /*  Make sure the correct point is clipped   */

			  if (code1.clip == 0)
			  {
			      code = &code2;
			  }
			  else 
			  {
			     code = &code1;
			  }
                  
                 /*  Clip left?  */
   
			  if (code->cde.left)
			  {
			     x = dit_clip_range[X_LOW];
			     y = y1+(y2-y1)*(x-x1)/(x2-x1);
			  }

                       /*  Clip right?  */

			  else
			  {
			     if (code->cde.right)
			     {
				x = dit_clip_range[X_HIGH];
				y = y1+(y2-y1)*(x-x1)/(x2-x1);
			     }

                             /*  Clip top?  */

			     else
			     {
				if (code->cde.top)
				{
				   y = dit_clip_range[Y_HIGH];
				   x = x1+(x2-x1)*(y-y1)/(y2-y1);
				}

                                     /*  Clip bottom?  */

				else
				{
				   if (code->cde.bottom)
				   {
				      y = dit_clip_range[Y_LOW];
				      x = x1+(x2-x1)*(y-y1)/(y2-y1);
				   }
				}  /* end else of if (top)  */

			     }  /* end else of if (right)  */

			  } /* end else of if (left)  */
          
                 /*  Assign clip point to correct point  */

			  if (code->clip == code1.clip)
			  {
			     x1 = x;
			     y1 = y;
			     get_code_xy(x1,y1,code1);
			  }
			  else
                                   
                   /*  set flag for disconnect  */
			  {
			     x2 = x;
			     y2 = y;
			     get_code_xy(x2,y2,code2);
			     is_disconnect = TRUE;
			  }
		       }  /*  end else of trivial reject */

		    }  /* end of trivial accept  */
  
		 } while (!accept && !reject);
                  
		 if (accept)
		 {

      /*  If last point was a disconnect, put two points in the output buffer  */
                
		    if (was_disconnect)
		    {
		       *out_buf++ = x1;
		       *out_buf++ = y1;
		       *out_buf++ = z1;
		       *out_buf++ = x2;
		       *out_buf++ = y2;
		       *out_buf++ = z2;
		       out_index += 2;
		       was_disconnect = FALSE;
		    }
		    else
                 
      /*  If last point was not a disconnect, put second point in output buffer  */

		    {
		       *out_buf++ = x2;
		       *out_buf++ = y2;
		       *out_buf++ = z2;
		       out_index++;
		    }

		    if (is_disconnect) 

        /*  If we need a disconnect, put disconnect in buffer  */

		    {
		       is_disconnect = FALSE;
		       *out_buf++ = MAXDOUBLE;
		       *out_buf++ = 0;
		       *out_buf++ = 0;
		       out_index++;
		       was_disconnect = TRUE;
		    }
		 } /* end then (accept)  */
		 else
		 {
		    is_disconnect = FALSE;
		 }
	      }  /* end while  */
	   } /*  end clip bit set  */
	   else
	   {
	
  /*  set in_buf to point to the right place  */

	      if (!first_huge)
	      {
	      in_buf -= 3;
	      }
	      while (( *index < *no_in_vec) && (out_index < *no_out_vec))
	      {
		 *out_buf++ = *in_buf++;
		 *out_buf++ = *in_buf++;
		 *out_buf++ = *in_buf++;
		 (*index)++;
		 out_index++;
	      }

	   }  /* end of else of bit test  */  

	} /*  end then (dim==2)  */

	else  /* do 3D clipping  */ 
	{
                            
   /*   Continue processing until we are out of input or the output buffer is full  */

	   while ((*index < *no_in_vec) && (out_index + 2 < *no_out_vec))
	   {
              
         /*  if a disconnect or first time through, get two new points  */
    
	      if (*in_buf == MAXDOUBLE)
	      {
		 in_buf += 3;
		 if (!was_disconnect)
		 {
	            is_disconnect = FALSE;
	            *out_buf++ = MAXDOUBLE;
	            *out_buf++ = 0;
	            *out_buf++ = 0;
	            out_index++;
	            was_disconnect = TRUE;
		 }
		 x1 = *in_buf++;
		 y1 = *in_buf++;
		 z1 = *in_buf++;  
		 tmp_x = x2 = *in_buf++;
		 tmp_y = y2 = *in_buf++;
		 tmp_z = z2 = *in_buf++;
		 *index += 3;
	      }

   /*  If not a disconnect, get next point  */

	      else 
	      {
		 x1 = tmp_x;
		 y1 = tmp_y;
		 z1 = tmp_z;
		 tmp_x = x2 = *in_buf++;
		 tmp_y = y2 = *in_buf++;
		 tmp_z = z2 = *in_buf++;
		 (*index)++;
	      }
   /*  get z-bit codes to see if the points lie within the z-range  */

	      get_code_z(z1,code1);
	      get_code_z(z2,code2);
	      accept = reject = FALSE;

  /*  clip the FRONT and BACK plane  (3D)  */
   
	      do
	      {
    /*    Trivial accept     */

		 if ( !(code1.clip | code2.clip))
		 {
		    accept = TRUE;
		 }

         /*   Trivial reject  */

		 else
		 {
		    if (code1.clip & code2.clip)
		    {
		       reject = TRUE;
		    }
		    else
		    {

                      /*   Make sure the correct point is clipped  */
  
		       if (code1.clip == 0)
		       {
			  code = &code2;
		       }
		       else
		       {
			  code = &code1;
		       }

                           /*   Clip front?  */
                     
		       if (code->cde.front)
		       {
			  z = dit_clip_range[Z_HIGH];
			  x = x1 + (x2-x1)*(z-z1)/(z2-z1);
			  y = y1 + (y2-y1)*(z-z1)/(z2-z1);
		       }
 
                         /*    Clip back?    */

		       else
		       {
			  if (code->cde.back)
			  {

			     z = dit_clip_range[Z_LOW];
			     x = x1 + (x2-x1)*(z-z1)/(z2-z1);
			     y = y1 + (y2-y1)*(z-z1)/(z2-z1);
			  }
		       } /*  end else for clip front  */

          /*  Assign clip point to the correct point  */
                        
		       if (code->clip == code1.clip)
		       {
			  x1 = x;
			  y1 = y;
			  z1 = z;
			  code1.clip = 0;
		       }
		       else
		       {
			  x2 = x;
			  y2 = y;
			  z2 = z;
			  code2.clip = 0;
			  is_disconnect = TRUE;
		       }

		    }  /*   else trivial reject   */

		 }  /* else - trivial accept  */

	      } while (!accept && !reject);

   /*   see if rectangular cliping needs to be done  */

	      if ( *clip && !reject)
	      {
   /*   Get x and y bit codes  */

		 get_code_xy(x1,y1,code1);
		 get_code_xy(x2,y2,code2);
		 accept = reject = FALSE;

    /* Continue processing until the line is either accepted or rejected  */
   
		 do
		 {

         /*   Trivial accept     */

		    if ( !(code1.clip | code2.clip))
		    {
		       accept = TRUE;
		    }

               /*    Trivial reject   */

		    else
		    {


		       if (code1.clip & code2.clip)
		       {
			  reject = TRUE;
		       }
		       else
		       {

                     /*  Make sure the correct point is clipped  */

			  if (code1.clip == 0)
			  {
			     code = &code2;
			  }
			  else
			  {
			     code = &code1;
			  }
                       /*   Clip left?  */

			  if (code->cde.left)
			  {
			     x = dit_clip_range[X_LOW];
			     y = y1+(y2-y1)*(x-x1)/(x2-x1);
			  }

                        /*     Clip right   */

			  else
			  {
			     if (code->cde.right)
			     {
				x = dit_clip_range[X_HIGH];
				y = y1+(y2-y1)*(x-x1)/(x2-x1);
			     }

                              /*    Clip top   */

			     else
			     {
				if (code->cde.top)
				{
				   y = dit_clip_range[Y_HIGH];
				   x = x1+(x2-x1)*(y-y1)/(y2-y1);
				}

                                   /*     Clip bottom  */
				else
				{
				   if (code->cde.bottom)
				   {
				      y = dit_clip_range[Y_LOW];
				      x = x1+(x2-x1)*(y-y1)/(y2-y1);
				   }

				}  /* end else clip bottom  */

			     }  /*  end else clip top  */

			  }  /* end else clip right   */

                   /*   Assign clip point to correct point   */
  
			  if (code->clip == code1.clip)
			  {
			     x1 = x;
			     y1 = y;
			     get_code_xy(x1,y1,code1);
			  }

                    /*    Set flag for disconnect   */
			  else
			  {
			     x2 = x;
			     y2 = y;
			     get_code_xy(x2,y2,code2);
			     is_disconnect = TRUE;
			  }

		       } /* end else - trivial reject  */   

		    }  /* end else - trivial accept  */

		 } while (!accept && !reject);

	      } /* end clip bit test  */ 
                     
	      if (accept)
	      {

          /*   If last point was a disconnect, put two points in the ouput buffer  */

		 if (was_disconnect)
		 {
		    *out_buf++ = x1;
		    *out_buf++ = y1;
		    *out_buf++ = z1;
		    *out_buf++ = x2;
		    *out_buf++ = y2;
		    *out_buf++ = z2;
		    out_index += 2;
		    was_disconnect = FALSE;
		 }

   /*  If last point was not a disconnect, put second point in the output buffer     */

		 else
		 {
		    *out_buf++ = x2;
		    *out_buf++ = y2;
		    *out_buf++ = z2;
		    out_index++;
		 }
 
   /*   If we need a disconnect, put a disconnect in the output buffer   */

		 if (is_disconnect)
		 {
		    is_disconnect = FALSE;
		    *out_buf++ = MAXDOUBLE;
		    *out_buf++ = 0;
		    *out_buf++ = 0;
		    out_index++;
		    was_disconnect = TRUE;
		 }
	      } /* end if-then (accept) */
	      else
	      {
		 is_disconnect = FALSE;
	      }

	   }  /* end while  */

	} /* if-else (dim==2)  (3D clipping) */

	if (*index < *no_in_vec)
	{
	   *message = DPCLPNCOM;
	   if (*in_buf != MAXDOUBLE)
	   {
	      (*index)--;
	   }
	}
	else 
	{
	   *index = 0;
	   *message = DPCLPCOM;
	}

	if (out_index > 0)
	{
	   if ((*(out_buf-3)) == MAXDOUBLE )
	   {
	      out_index--;
	   }
	}
	*no_out_vec = out_index;


wrapup:
	return (value);

  
       
     } /* end DPclip  */

 

