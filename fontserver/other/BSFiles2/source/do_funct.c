




/*****************************************************************************
*                                                                            *
*               Copyright 1987, Bitstream Inc., Cambridge, MA                *
*                            Patent No. 4,785,391                            *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/************************ D O _ F U N C T I O N S . C ************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)   1-May-85  jsc   module created as a result of moving constraint
                      function operators from rules.c into a separate file.
                      Added the operator definitions:
                          do_bzon()
                          do_bzon1()
                          do_lzon()
                          do_lzon1()
                          do_cfflb()
                          do_cffrb()
                          do_cfslb()
                          do_cfsrb()
                          do_xht_adj()

 2)   6-Oct-86  jsc   Updated cfflb(), cffrb(), cfslb() and cfsrb() to
                      operate correctly when sum of left and right side-
                      bearings are zero pixels.

 3)  17-Mar-88  jsc   Removed 
                          do_xht_adj()
                          do_print()
                          do_add()
                          do_sub()
                          do_mul()
                          do_div()
                          do_fixr()
                          do_fix()
                      functions (not used -- implemented in line in rules.c)

  4) 21-Jul-88  reh   Moved some of do_funct.c to fixed point

  5)  5-Aug-88  reh   Implemented sliding point (see rules.c)

 *****************************************************************************
 **************** Constraint function operators ******************************

   The constraint function operators in the module are called by get_pixels.
   All pop their parameters from the stack and push their result back onto
   the stack.

 ****************************************************************************/


#include    "stdef.h"                                      
#include    <math.h>

#define TWO_TO_THE_31 2.147483648E+09




static real   pix_acc, dpt5;
static fix15  pix_shift;
static fix31  pix_round;
static fix31  pix_add_25;
static fix31  pix_add_75;

FUNCTION setup_funct(acc, shift, rounder, add_75, add_25, dec_point_5)
real    acc;                                          
real    dec_point_5;
fix15   shift;
fix31   rounder;
fix31   add_75;
fix31   add_25;
    {
    pix_acc = acc;
    pix_shift = shift;
    pix_round = rounder;
    pix_add_25 = add_25;
    pix_add_75 = add_75;
    dpt5 = dec_point_5;                                              
    }

FUNCTION do_cf(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A CF function takes three arguments from the execution stack and returns a whole
 *  number of pixels.  The three arguments (in the order pushed onto the stack) are
 *  threshold, fpixels_self and fpixels_other.  If fpixels_self differs from
 *  fpixels_other by less than the threshold, the average value of fpixels_self and
 *  fpixels_other is rounded to the nearest whole number of pixels and returned as
 *  the result.  Otherwise, a combination of rounding up or down for fpixels_self
 *  and fpixels_other is chosen whose ratio most closely approximates the ratio
 *  of the unrounded values. 
 */

{
real fpixels_other;
real fpixels_self;
real threshold;
real ratio, pixels;
real self_down, self_up, other_down, other_up;
real error, min_error;

fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));
if (fabs(fpixels_self - fpixels_other) < threshold)
    {
    pixels = fpixels_self + fpixels_other;
    if (pixels < TWO_TO_THE_31)
        {
        pixels = (real) ((((((fix31) pixels) + 1) >> 1) + pix_round) >> pix_shift);
        }
    else 
        {
        pixels = floor(((pixels * 0.5) / pix_acc) + dpt5);
        }
    }
else
    {
    ratio = fpixels_self / fpixels_other;
    if (fpixels_self < TWO_TO_THE_31)
        self_down = (real) (((fix31) fpixels_self) >> pix_shift);
    else
        self_down = floor(fpixels_self / pix_acc);
    self_up = self_down + 1;
    if (fpixels_other < TWO_TO_THE_31)
        other_down = (real) (((fix31) fpixels_other) >> pix_shift);
    else
        other_down = floor(fpixels_other / pix_acc);
    /* make sure we haven't screwed up */
    if (other_down == 0)
        other_down = floor(fpixels_other / pix_acc);

    other_up = other_down + 1;
    pixels = self_up;
    min_error = fabs(self_up / other_down - ratio);
    error = fabs(self_up / other_up - ratio);
    if (error < min_error)
        {
        min_error = error;
        }
    error = fabs(self_down / other_down - ratio);
    if (error < min_error)
        {
        pixels = self_down;
        min_error = error;
        }
    error = fabs(self_down / other_up - ratio);
    if (error < min_error)
        {
        pixels = self_down;
        }
    } 
*((*pstack_pointer)++) = (real) ((fix31) pixels << pix_shift);
}

FUNCTION do_rrfs(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  An RRFS function takes three arguments from the execution stack and returns a
 *  whole number of pixels.  The three arguments (in the order pushed onto the
 *  stack) are pixels_other_footspace, pixels_my_height, pixels_other_height.  The
 *  value of pixels_other_footspace is reduced by half the difference between pixels
 *  my_height and pixels_other_height. The result is rounded up to the next whole
 *  number and pushed onto the stack. 
 */

{
real pixels_other_height;
real pixels_my_height;
real pixels_other_footspace;
real extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_footspace = *(--(*pstack_pointer));
extra = (pixels_my_height - pixels_other_height);
if ((pixels_other_footspace < TWO_TO_THE_31) && (extra < TWO_TO_THE_31)) 
    pixels_other_footspace = (real) (((((fix31) pixels_other_footspace) - ((((fix31) extra) + 1) >> 1) + pix_add_75) 
                                     >> pix_shift) << pix_shift);
else
    pixels_other_footspace = floor(((pixels_other_footspace - (extra * 0.5)) / pix_acc) + 0.75) * pix_acc;
*((*pstack_pointer)++) = pixels_other_footspace;
}

FUNCTION do_rrfs1(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  An RRFS1 function takes three arguments from the execution stack and returns a
 *  whole number of pixels.  The three arguments (in the order pushed onto the
 *  stack) are pixels_other_footspace, pixels_my_height, pixels_other_height.  The
 *  value of pixels_other_footspace is reduced by half the difference between pixels
 *  my_height and pixels_other_height. The result is rounded down to the next whole
 *  number and pushed onto the stack. 
 */

{
real pixels_other_height;
real pixels_my_height;
real pixels_other_footspace;
real extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_footspace = *(--(*pstack_pointer));
extra = (pixels_my_height - pixels_other_height);
if ((pixels_other_footspace < TWO_TO_THE_31) && (extra < TWO_TO_THE_31)) 
    pixels_other_footspace = (real) (((((fix31) pixels_other_footspace) - ((((fix31) extra) + 1) >> 1) + pix_add_25) 
                                     >> pix_shift) << pix_shift);
else
    pixels_other_footspace = floor(((pixels_other_footspace - (extra * 0.5)) / pix_acc) + 0.25) * pix_acc;
*((*pstack_pointer)++) = pixels_other_footspace;
}

FUNCTION do_rrhs(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  An RRHS function takes three arguments from the execution stack and returns a
 *  whole number of pixels.  The three arguments (in the order pushed onto the
 *  stack) are pixels_other_headspace, pixels_my_height, pixels_other_height.  The
 *  value of pixels_other_head_space is reduced by half the difference between pixels
 *  my_height and pixels_other_height. The result is rounded down to the next whole
 *  number and pushed onto the stack. 
 */

{
real pixels_other_height;
real pixels_my_height;
real pixels_other_headspace;
real extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_headspace = *(--(*pstack_pointer));
extra = (pixels_my_height - pixels_other_height);
pixels_other_headspace = floor(((pixels_other_headspace - (extra * 0.5)) / pix_acc) + 0.25);
*((*pstack_pointer)++) = pixels_other_headspace * pix_acc;
}

FUNCTION do_rrhs1(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  An RRHS1 function takes three arguments from the execution stack and returns a
 *  whole number of pixels.  The three arguments (in the order pushed onto the
 *  stack) are pixels_other_headspace, pixels_my_height, pixels_other_height.  The
 *  value of pixels_other_head_space is reduced by half the difference between pixels
 *  my_height and pixels_other_height. The result is rounded up to the next whole
 *  number and pushed onto the stack. 
 */

{
real pixels_other_height;
real pixels_my_height;
real pixels_other_headspace;
real extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_headspace = *(--(*pstack_pointer));
extra = (pixels_my_height - pixels_other_height);
pixels_other_headspace = floor(((pixels_other_headspace - (extra * 0.5)) / pix_acc) + 0.75);
*((*pstack_pointer)++) = pixels_other_headspace * pix_acc;
}

FUNCTION do_bzon(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A BZON function takes two arguments from the execution stack and returns a
 *  whole number of pixels.  The two arguments (in the order pushed onto the
 *  stack) are fpixels_self and fpixels_other.
 *  If the rounded sum of fpixels_self and fpixels_other is less than or equal
 *  to a threshold of 10, the rounded sum is divided by two rounding up the
 *  result if necessary to the next whole number. 
 *  Otherwise, the fpixels_self is rounded to the nearest whole number.     
 */

{
real threshold;
real fpixels_self;
real fpixels_other;
real total, pixels;

threshold = 10.0;
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = fpixels_self + fpixels_other;
if (total < TWO_TO_THE_31)
    total = (real) ((((fix31) total) + pix_round) >> pix_shift);              
else
    total = floor((total / pix_acc) + dpt5);
if (total > threshold)
    {
    if (fpixels_self < TWO_TO_THE_31)
        {
        pixels = (real) ((((fix31) fpixels_self) + pix_round) >> pix_shift);
        }
    else 
        {
        pixels = floor((fpixels_self / pix_acc) + dpt5);
        }
    }
else 
    {    
    pixels = (real) (((((fix31) total) << (pix_shift - 1)) + pix_add_75) >> pix_shift);
    }
*((*pstack_pointer)++) = (real) ((fix31) pixels << pix_shift);
}

FUNCTION do_bzon1(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A BZON1 function takes three arguments from the execution stack and returns
 *  a whole number of pixels.  The three arguments (in the order pushed onto the
 *  stack) are fpixels_self, fpixels_other and threshold.
 *  If the rounded sum of fpixels_self and fpixels_other is less than or equal
 *  to the threshold, the rounded sum is divided by two rounding up the result
 *  if necessary to the next whole number. 
 *  Otherwise, the fpixels_self is rounded to the nearest whole number.     
 */

{
real threshold;
real fpixels_self;
real fpixels_other;
real total, pixels;

threshold = *(--(*pstack_pointer));
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = floor(((fpixels_self + fpixels_other) / pix_acc) + dpt5);
if (total > (threshold / pix_acc))
    {
    pixels = floor((fpixels_self / pix_acc) + dpt5);
    }
else 
    {    
    pixels = floor((total * 0.5) + 0.75);
    }
*((*pstack_pointer)++) = pixels * pix_acc;
}

FUNCTION do_lzon(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A LZON function takes two arguments from the execution stack and returns a
 *  whole number of pixels.  The two arguments (in the order pushed onto the
 *  stack) are fpixels_self and fpixels_other.
 *  If the rounded sum of fpixels_self and fpixels_other is less than or equal
 *  to a threshold of 10, the rounded sum is divided by two rounding down the
 *  result if necessary to the next whole number. 
 *  Otherwise, the fpixels_self is rounded to the nearest whole number.     
 */

{
real threshold;
real fpixels_self;
real fpixels_other;
real total, pixels;

threshold = 10.0;
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = fpixels_self + fpixels_other;
if (total < TWO_TO_THE_31)
    total = (real) ((((fix31) total) + pix_round) >> pix_shift);
else
    total = floor((total / pix_acc) + dpt5);
if (total > threshold)
    {
    if (fpixels_self < TWO_TO_THE_31)
        {
        pixels = (real) ((((fix31) fpixels_self) + pix_round) >> pix_shift);
        }
    else 
        {
        pixels = floor((fpixels_self / pix_acc) + dpt5);
        }
    }
else 
    {    
    pixels = (real) (((((fix31) total) << (pix_shift - 1)) + pix_add_25) >> pix_shift);
    }
*((*pstack_pointer)++) = (real) ((fix31) pixels << pix_shift);
}

FUNCTION do_lzon1(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A LZON1 function takes three arguments from the execution stack and returns
 *  a whole number of pixels.  The three arguments (in the order pushed onto the
 *  stack) are fpixels_self, fpixels_other and threshold.
 *  If the rounded sum of fpixels_self and fpixels_other is less than or equal
 *  to the threshold, the rounded sum is divided by two rounding down the result
 *  if necessary to the next whole number. 
 *  Otherwise, the fpixels_self is rounded to the nearest whole number.     
 */

{
real threshold;
real fpixels_self;
real fpixels_other;
real total, pixels;

threshold = *(--(*pstack_pointer));
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = fpixels_self + fpixels_other;
total = floor((total / pix_acc) + dpt5);
if (total > (threshold / pix_acc))
    {
    pixels = floor((fpixels_self / pix_acc) + dpt5);
    }
else 
    {    
    pixels = floor((total * 0.5) + 0.25);
    }
*((*pstack_pointer)++) = pixels * pix_acc;
}

FUNCTION do_cfflb(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A CFFLB function takes five arguments from the execution stack and returns a
 *  whole number of pixels.  The five arguments (in the order pushed onto the
 *  stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
 *  fpixels_second_rb.
 *  If the sum of the left and right side bearings of the first character is
 *  less than the specified threshold, CFFLB carries out a special pixel
 *  budgeting process for the left and right side bearings of the first and
 *  second characters. The process ensures that the sum of the left and right
 *  side bearings of the first character has the same parity as the sum of the
 *  left and right side bearings of the second character. If these sums are both
 *  odd, pixels are allocated to the left and right side bearings of each
 *  character in a manner that tends to allocate the extra pixel to the left side
 *  bearings.
 *  CFFLB returns the number of pixels allocated to the left side bearing of the
 *  first character.                                                         
 */

{
real threshold;
real fpixels_first_lb;
real fpixels_first_rb;
real fpixels_second_lb;
real fpixels_second_rb;
real sum, first_sum, second_sum;
real pixels_sum, pixels_first_sum;
real pixels_first_lb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)        
    {
    pixels_first_lb = floor((fpixels_first_lb / pix_acc) + dpt5);
    }
else
    {
    sum = first_sum + second_sum;   
    if (sum < TWO_TO_THE_31)
        {
        pixels_sum = (real) ((((((fix31) sum + 1) >> 1) + pix_round) >> pix_shift) << 1);
        }
    else
        {
        pixels_sum = floor(((sum / pix_acc) * 0.5) + dpt5) * 2.0; /* Round to nearest even number of pixels */
        }
    if (pixels_sum < 0.5)
        {
        pixels_first_lb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + dpt5);
        pixels_first_lb = fpixels_first_lb * pixels_first_sum / first_sum;
        if (((fix15)pixels_first_sum) & 0x1)           /* pixels_first_sum odd? */
            {
            pixels_first_lb = floor(pixels_first_lb + 1.0);
            }
        else 
            {
            pixels_first_lb = floor(pixels_first_lb + dpt5);
            }
        }
    }
*((*pstack_pointer)++) = pixels_first_lb * pix_acc;
}

FUNCTION do_cffrb(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A CFFRB function takes five arguments from the execution stack and returns a
 *  whole number of pixels.  The five arguments (in the order pushed onto the
 *  stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
 *  fpixels_second_rb.
 *  If the sum of the left and right side bearings of the first character is
 *  less than the specified threshold, CFFRB carries out a special pixel
 *  budgeting process for the left and right side bearings of the first and
 *  second characters. The process ensures that the sum of the left and right
 *  side bearings of the first character has the same parity as the sum of the
 *  left and right side bearings of the second character. If these sums are both
 *  odd, pixels are allocated to the left and right side bearings of each
 *  character in a manner that tends to allocate the extra pixel to the left side
 *  bearings.
 *  CFFRB returns the number of pixels allocated to the right side bearing of the
 *  first character.                                                         
 */

{
real threshold;
real fpixels_first_lb;
real fpixels_first_rb;
real fpixels_second_lb;
real fpixels_second_rb;
real sum, first_sum, second_sum;
real pixels_sum, pixels_first_sum;
real pixels_first_lb, pixels_first_rb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)        
    {
    pixels_first_rb = floor((fpixels_first_rb / pix_acc) + dpt5);
    }
else
    {
    sum = first_sum + second_sum;   
    if (sum < TWO_TO_THE_31)
        {
        pixels_sum = (real) ((((((fix31) sum + 1) >> 1) + pix_round) >> pix_shift) << 1);
        }
    else
        {
        pixels_sum = floor(((sum / pix_acc) * 0.5) + dpt5) * 2.0; /* Round to nearest even number of pixels */
        }
    if (pixels_sum < 0.5)
        {
        pixels_first_rb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + dpt5);
        pixels_first_lb = fpixels_first_lb * pixels_first_sum / first_sum;
        if (((fix15)pixels_first_sum) & 0x1)           /* pixels_first_sum odd? */
            pixels_first_lb = floor(pixels_first_lb + 1.0);
        else 
            pixels_first_lb = floor(pixels_first_lb + dpt5);
        pixels_first_rb = pixels_first_sum - pixels_first_lb;
        }
    }
*((*pstack_pointer)++) = pixels_first_rb * pix_acc;
}

FUNCTION do_cfslb(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A CFSLB function takes five arguments from the execution stack and returns a
 *  whole number of pixels.  The five arguments (in the order pushed onto the
 *  stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
 *  fpixels_second_rb.
 *  If the sum of the left and right side bearings of the first character is
 *  less than the specified threshold, CFSLB carries out a special pixel
 *  budgeting process for the left and right side bearings of the first and
 *  second characters. The process ensures that the sum of the left and right
 *  side bearings of the first character has the same parity as the sum of the
 *  left and right side bearings of the second character. If these sums are both
 *  odd, pixels are allocated to the left and right side bearings of each
 *  character in a manner that tends to allocate the extra pixel to the left side
 *  bearings.
 *  CFSLB returns the number of pixels allocated to the left side bearing of the
 *  second character.                                                        
 */

{
real threshold;
real fpixels_first_lb;
real fpixels_first_rb;
real fpixels_second_lb;
real fpixels_second_rb;
real sum, first_sum, second_sum;
real pixels_sum, pixels_first_sum, pixels_second_sum;
real pixels_second_lb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb; 
if (first_sum > threshold)        
    {
    pixels_second_lb = floor((fpixels_second_lb / pix_acc) + dpt5);
    }
else
    {
    sum = first_sum + second_sum;   
    if (sum < TWO_TO_THE_31)
        {
        pixels_sum = (real) ((((((fix31) sum + 1) >> 1) + pix_round) >> pix_shift) << 1);
        }
    else
        {
        pixels_sum = floor(((sum / pix_acc) * 0.5) + dpt5) * 2.0; /* Round to nearest even number of pixels */
        }
    if (pixels_sum < 0.5)
        {
        pixels_second_lb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + dpt5);
        pixels_second_sum = pixels_sum - pixels_first_sum;
        pixels_second_lb = fpixels_second_lb * pixels_second_sum / second_sum;
        if (((fix15)pixels_second_sum) & 0x1)           /* pixels_first_sum odd? */
            {
            pixels_second_lb = floor(pixels_second_lb + 1.0);
            }
        else 
            {
            pixels_second_lb = floor(pixels_second_lb + dpt5);
            }
        }
    }
*((*pstack_pointer)++) = pixels_second_lb * pix_acc;
}

FUNCTION do_cfsrb(pstack_pointer)
real **pstack_pointer;      /* Execution stack pointer (input and output) */

/*  A CFSRB function takes five arguments from the execution stack and returns a
 *  whole number of pixels.  The five arguments (in the order pushed onto the
 *  stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
 *  fpixels_second_rb.
 *  If the sum of the left and right side bearings of the first character is
 *  less than the specified threshold, CFSRB carries out a special pixel
 *  budgeting process for the left and right side bearings of the first and
 *  second characters. The process ensures that the sum of the left and right
 *  side bearings of the first character has the same parity as the sum of the
 *  left and right side bearings of the second character. If these sums are both
 *  odd, pixels are allocated to the left and right side bearings of each
 *  character in a manner that tends to allocate the extra pixel to the left side
 *  bearings.
 *  CFSRB returns the number of pixels allocated to the right side bearing of the
 *  second character.                                                       
 */

{
real threshold;
real fpixels_first_lb;
real fpixels_first_rb;
real fpixels_second_lb;
real fpixels_second_rb;
real sum, first_sum, second_sum;
real pixels_sum, pixels_first_sum, pixels_second_sum;
real pixels_second_lb, pixels_second_rb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)
    {
    pixels_second_rb = floor((fpixels_second_rb / pix_acc) + dpt5);
    }
else
    {
    sum = first_sum + second_sum;   
    if (sum < TWO_TO_THE_31)
        {
        pixels_sum = (real) ((((((fix31) sum + 1) >> 1) + pix_round) >> pix_shift) << 1);
        }
    else
        {
        pixels_sum = floor(((sum / pix_acc) * 0.5) + dpt5) * 2.0; /* Round to nearest even number of pixels */
        }
    if (pixels_sum < 0.5)
        {
        pixels_second_rb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + dpt5);
        pixels_second_sum = pixels_sum - pixels_first_sum;
        pixels_second_lb = fpixels_second_lb * pixels_second_sum / second_sum;
        if (((fix15)pixels_second_sum) & 0x1)           /* pixels_first_sum odd? */
            {
            pixels_second_lb = floor(pixels_second_lb + 1.0);
            }
        else 
            {
            pixels_second_lb = floor(pixels_second_lb + dpt5);
            }
        pixels_second_rb = pixels_second_sum - pixels_second_lb;
        }
    }
*((*pstack_pointer)++) = pixels_second_rb * pix_acc;
}


