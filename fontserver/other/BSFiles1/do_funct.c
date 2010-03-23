




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
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

 *****************************************************************************
 **************** Constraint function operators ******************************

   The constraint function operators in the module are called by get_pixels.
   All pop their parameters from the stack and push their result back onto
   the stack.

 ****************************************************************************/


#include    "../hfiles/stdef.h"
#include    "../hfiles/math.h"


FUNCTION do_co(pstack_pointer)
float **pstack_pointer;
/* A CO function takes three arguments from the execution stack and returns a whole
   number of pixels.  The three arguments (in the order pushed onto the stack)
   are threshold, fpixels_self and pixels_other.  If fpixels_self differs from
   pixels_other by less than threshold, pixels_other is returned; otherwise,
   fpixels is rounded to the nearest number of whole pixels and returned.  */
{
float pixels_other;
float fpixels_self;
float threshold;
float diff;

pixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));
diff = fpixels_self - pixels_other;
if (fabs(diff) < threshold)
    *((*pstack_pointer)++) = pixels_other;
else
    *((*pstack_pointer)++) = floor(fpixels_self + 0.5);
}

FUNCTION do_cf(pstack_pointer)
float **pstack_pointer;
/*  A CF function takes three arguments from the execution stack and returns a whole
    number of pixels.  The three arguments (in the order pushed onto the stack) are
    threshold, fpixels_self and fpixels_other.  If fpixels_self differs from
    fpixels_other by less than the threshold, the average value of fpixels_self and
    fpixels_other is rounded to the nearest whole number of pixels and returned as
    the result.  Otherwise, a combination of rounding up or down for fpixels_self
    and fpixels_other is chosen whose ratio most closely approximates the ratio
    of the unrounded values.  */
{
float fpixels_other;
float fpixels_self;
float threshold;
float ratio, pixels;
float self_down, self_up, other_down, other_up;
float error, min_error;

fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));
if (fabs(fpixels_self - fpixels_other) < threshold)
    pixels = floor((fpixels_self + fpixels_other) * 0.5 + 0.5);
else
    {
    ratio = fpixels_self / fpixels_other;
    self_down = floor(fpixels_self);
    self_up = self_down + 1;
    other_down = floor(fpixels_other);
    other_up = other_down + 1;
    min_error = fabs(self_up / other_down - ratio);
    pixels = self_up;
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
*((*pstack_pointer)++) = pixels;
}

FUNCTION do_rrfs(pstack_pointer)
float **pstack_pointer;
/*  An RRFS function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixels_other_footspace, pixels_my_height, pixels_other_height.  The
    value of pixels_other_footspace is reduced by half the difference between pixels
    my_height and pixels_other_height. The result is rounded up to the next whole
    number and pushed onto the stack.  */
{
float pixels_other_height;
float pixels_my_height;
float pixels_other_footspace;
float extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_footspace = *(--(*pstack_pointer));
extra = pixels_my_height - pixels_other_height;
*((*pstack_pointer)++) = floor(pixels_other_footspace - (extra * 0.5) + 0.75);
}

FUNCTION do_rrfs1(pstack_pointer)
float **pstack_pointer;
/*  An RRFS1 function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixels_other_footspace, pixels_my_height, pixels_other_height.  The
    value of pixels_other_footspace is reduced by half the difference between pixels
    my_height and pixels_other_height. The result is rounded down to the next whole
    number and pushed onto the stack.  */
{
float pixels_other_height;
float pixels_my_height;
float pixels_other_footspace;
float extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_footspace = *(--(*pstack_pointer));
extra = pixels_my_height - pixels_other_height;
*((*pstack_pointer)++) = floor(pixels_other_footspace - (extra * 0.5) + 0.25);
}

FUNCTION do_rrhs(pstack_pointer)
float **pstack_pointer;
/*  An RRHS function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixels_other_headspace, pixels_my_height, pixels_other_height.  The
    value of pixels_other_head_space is reduced by half the difference between pixels
    my_height and pixels_other_height. The result is rounded down to the next whole
    number and pushed onto the stack.  */
{
float pixels_other_height;
float pixels_my_height;
float pixels_other_headspace;
float extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_headspace = *(--(*pstack_pointer));
extra = pixels_my_height - pixels_other_height;
*((*pstack_pointer)++) = floor(pixels_other_headspace - (extra * 0.5) + 0.25);
}

FUNCTION do_rrhs1(pstack_pointer)
float **pstack_pointer;
/*  An RRHS1 function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixels_other_headspace, pixels_my_height, pixels_other_height.  The
    value of pixels_other_head_space is reduced by half the difference between pixels
    my_height and pixels_other_height. The result is rounded up to the next whole
    number and pushed onto the stack.  */
{
float pixels_other_height;
float pixels_my_height;
float pixels_other_headspace;
float extra;

pixels_other_height = *(--(*pstack_pointer));
pixels_my_height = *(--(*pstack_pointer));
pixels_other_headspace = *(--(*pstack_pointer));
extra = pixels_my_height - pixels_other_height;
*((*pstack_pointer)++) = floor(pixels_other_headspace - (extra * 0.5) + 0.75);
}

FUNCTION do_bzon(pstack_pointer)
float **pstack_pointer;
/*  A BZON function takes two arguments from the execution stack and returns a
    whole number of pixels.  The two arguments (in the order pushed onto the
    stack) are fpixels_self and fpixels_other.
    If the rounded sum of fpixels_self and fpixels_other is less than or equal
    to a threshold of 10, the rounded sum is divided by two rounding up the
    result if necessary to the next whole number. 
    Otherwise, the fpixels_self is rounded to the nearest whole number.      */
{
float threshold;
float fpixels_self;
float fpixels_other;
float total, pixels;

threshold = 10.0;
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = floor(fpixels_self + fpixels_other + 0.5);
if (total > threshold)
    pixels = floor(fpixels_self + 0.5);
else
    pixels = floor((total * 0.5) + 0.75);
*((*pstack_pointer)++) = pixels;
}

FUNCTION do_bzon1(pstack_pointer)
float **pstack_pointer;
/*  A BZON1 function takes three arguments from the execution stack and returns
    a whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are fpixels_self, fpixels_other and threshold.
    If the rounded sum of fpixels_self and fpixels_other is less than or equal
    to the threshold, the rounded sum is divided by two rounding up the result
    if necessary to the next whole number. 
    Otherwise, the fpixels_self is rounded to the nearest whole number.      */
{
float threshold;
float fpixels_self;
float fpixels_other;
float total, pixels;

threshold = *(--(*pstack_pointer));
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = floor(fpixels_self + fpixels_other + 0.5);
if (total > threshold)
    pixels = floor(fpixels_self + 0.5);
else
    pixels = floor((total * 0.5) + 0.75);
*((*pstack_pointer)++) = pixels;
}

FUNCTION do_lzon(pstack_pointer)
float **pstack_pointer;
/*  A LZON function takes two arguments from the execution stack and returns a
    whole number of pixels.  The two arguments (in the order pushed onto the
    stack) are fpixels_self and fpixels_other.
    If the rounded sum of fpixels_self and fpixels_other is less than or equal
    to a threshold of 10, the rounded sum is divided by two rounding down the
    result if necessary to the next whole number. 
    Otherwise, the fpixels_self is rounded to the nearest whole number.      */
{
float threshold;
float fpixels_self;
float fpixels_other;
float total, pixels;

threshold = 10.0;
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = floor(fpixels_self + fpixels_other + 0.5);
if (total > threshold)
    pixels = floor(fpixels_self + 0.5);
else
    pixels = floor((total * 0.5) + 0.25);
*((*pstack_pointer)++) = pixels;
}

FUNCTION do_lzon1(pstack_pointer)
float **pstack_pointer;
/*  A LZON1 function takes three arguments from the execution stack and returns
    a whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are fpixels_self, fpixels_other and threshold.
    If the rounded sum of fpixels_self and fpixels_other is less than or equal
    to the threshold, the rounded sum is divided by two rounding down the result
    if necessary to the next whole number. 
    Otherwise, the fpixels_self is rounded to the nearest whole number.      */
{
float threshold;
float fpixels_self;
float fpixels_other;
float total, pixels;

threshold = *(--(*pstack_pointer));
fpixels_other = *(--(*pstack_pointer));
fpixels_self = *(--(*pstack_pointer));
total = floor(fpixels_self + fpixels_other + 0.5);
if (total > threshold)
    pixels = floor(fpixels_self + 0.5);
else
    pixels = floor((total * 0.5) + 0.25);
*((*pstack_pointer)++) = pixels;
}

FUNCTION do_cfflb(pstack_pointer)
float **pstack_pointer;
/*  A CFFLB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
    fpixels_second_rb.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFFLB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFFLB returns the number of pixels allocated to the left side bearing of the
    first character.                                                          */
{
float threshold;
float fpixels_first_lb;
float fpixels_first_rb;
float fpixels_second_lb;
float fpixels_second_rb;
float sum, first_sum, second_sum;
float pixels_sum, pixels_first_sum;
float pixels_first_lb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)
    pixels_first_lb = floor(fpixels_first_lb + 0.5);
else
    {
    sum = first_sum + second_sum;
    pixels_sum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
    if (pixels_sum < 0.5)
        {
        pixels_first_lb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + 0.5);
        if ((fix15)pixels_first_sum & 0x1)           /* pixels_first_sum odd? */
            pixels_first_lb = floor(fpixels_first_lb * pixels_first_sum / first_sum + 1.0);
        else
            pixels_first_lb = floor(fpixels_first_lb * pixels_first_sum / first_sum + 0.5);
        }
    }
*((*pstack_pointer)++) = pixels_first_lb;
}

FUNCTION do_cffrb(pstack_pointer)
float **pstack_pointer;
/*  A CFFRB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
    fpixels_second_rb.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFFRB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFFRB returns the number of pixels allocated to the right side bearing of the
    first character.                                                          */
{
float threshold;
float fpixels_first_lb;
float fpixels_first_rb;
float fpixels_second_lb;
float fpixels_second_rb;
float sum, first_sum, second_sum;
float pixels_sum, pixels_first_sum;
float pixels_first_lb, pixels_first_rb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)
    pixels_first_rb = floor(fpixels_first_rb + 0.5);
else
    {
    sum = first_sum + second_sum;
    pixels_sum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
    if (pixels_sum < 0.5)
        {
        pixels_first_rb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + 0.5);
        if ((fix15)pixels_first_sum & 0x1)           /* pixels_first_sum odd? */
            pixels_first_lb = floor(fpixels_first_lb * pixels_first_sum / first_sum + 1.0);
        else
            pixels_first_lb = floor(fpixels_first_lb * pixels_first_sum / first_sum + 0.5);
        pixels_first_rb = pixels_first_sum - pixels_first_lb;
        }
    }
*((*pstack_pointer)++) = pixels_first_rb;
}

FUNCTION do_cfslb(pstack_pointer)
float **pstack_pointer;
/*  A CFSLB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
    fpixels_second_rb.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFSLB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFSLB returns the number of pixels allocated to the left side bearing of the
    second character.                                                         */
{
float threshold;
float fpixels_first_lb;
float fpixels_first_rb;
float fpixels_second_lb;
float fpixels_second_rb;
float sum, first_sum, second_sum;
float pixels_sum, pixels_first_sum, pixels_second_sum;
float pixels_second_lb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)
    pixels_second_lb = floor(fpixels_second_lb + 0.5);
else
    {
    sum = first_sum + second_sum;
    pixels_sum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
    if (pixels_sum < 0.5)
        {
        pixels_second_lb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + 0.5);
        pixels_second_sum = pixels_sum - pixels_first_sum;
        if ((fix15)pixels_second_sum & 0x1)          /* pixels_second_sum odd? */
            pixels_second_lb = floor(fpixels_second_lb * pixels_second_sum / second_sum + 1.0);
        else
            pixels_second_lb = floor(fpixels_second_lb * pixels_second_sum / second_sum + 0.5);
        }
    }
*((*pstack_pointer)++) = pixels_second_lb;
}

FUNCTION do_cfsrb(pstack_pointer)
float **pstack_pointer;
/*  A CFSRB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixels_first_lb, fpixels_first_rb, fpixels_second_lb,
    fpixels_second_rb.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFSRB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFSRB returns the number of pixels allocated to the right side bearing of the
    second character.                                                        */
{
float threshold;
float fpixels_first_lb;
float fpixels_first_rb;
float fpixels_second_lb;
float fpixels_second_rb;
float sum, first_sum, second_sum;
float pixels_sum, pixels_first_sum, pixels_second_sum;
float pixels_second_lb, pixels_second_rb;

fpixels_second_rb = *(--(*pstack_pointer));
fpixels_second_lb = *(--(*pstack_pointer));
fpixels_first_rb = *(--(*pstack_pointer));
fpixels_first_lb = *(--(*pstack_pointer));
threshold = *(--(*pstack_pointer));

first_sum = fpixels_first_lb + fpixels_first_rb;
second_sum = fpixels_second_lb + fpixels_second_rb;
if (first_sum > threshold)
    pixels_second_rb = floor(fpixels_second_rb + 0.5);
else
    {
    sum = first_sum + second_sum;
    pixels_sum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
    if (pixels_sum < 0.5)
        {
        pixels_second_rb = 0.0;
        }
    else
        {
        pixels_first_sum = floor((first_sum * pixels_sum / sum) + 0.5);
        pixels_second_sum = pixels_sum - pixels_first_sum;
        if ((fix15)pixels_second_sum & 0x1)          /* pixels_second_sum odd? */
            pixels_second_lb = floor(fpixels_second_lb * pixels_second_sum / second_sum + 1.0);
        else
            pixels_second_lb = floor(fpixels_second_lb * pixels_second_sum / second_sum + 0.5);
        pixels_second_rb = pixels_second_sum - pixels_second_lb;
        }
    }
*((*pstack_pointer)++) = pixels_second_rb;
}

FUNCTION do_fix(pstack_pointer)
float **pstack_pointer;
/*  A FIX function takes one argument from the execution stack, rounds it down to
    the next whole number and pushes the result back onto the stack.  */
{
float arg1;

arg1 = *(--(*pstack_pointer));
*((*pstack_pointer)++) = floor(arg1);
}

FUNCTION do_fixr(pstack_pointer)
float **pstack_pointer;
/*  A FIXR function takes one argument from the execution stack, rounds it to the
    nearest whole number and pushes the result back onto the stack.  */
{
float arg1;

arg1 = *(--(*pstack_pointer));
*((*pstack_pointer)++) = floor(arg1 + 0.5);
}

FUNCTION do_add(pstack_pointer)
float **pstack_pointer;
/*  An addition function takes two arguments from the execution stack, adds them
    together and pushes the result back onto the stack.  */
{
float arg1, arg2;

arg2 = *(--(*pstack_pointer));
arg1 = *(--(*pstack_pointer));
*((*pstack_pointer)++) = arg1 + arg2;
}

FUNCTION do_sub(pstack_pointer)
float **pstack_pointer;
/*  A subtraction function takes two arguments from the execution stack, subtracts
    the top of the stack from the next value and pushes the result back onto the
    stack.  */
{
float arg1, arg2;

arg2 = *(--(*pstack_pointer));
arg1 = *(--(*pstack_pointer));
*((*pstack_pointer)++) = arg1 - arg2;
}

FUNCTION do_mul(pstack_pointer)
float **pstack_pointer;
/*  A multiplication function takes two arguments from the execution stack,
    multiplies them together and pushes the result back onto the stack.  */
{
float arg1, arg2;

arg2 = *(--(*pstack_pointer));
arg1 = *(--(*pstack_pointer));
*((*pstack_pointer)++) = arg1 * arg2;
}

FUNCTION do_div(pstack_pointer)
float **pstack_pointer;
/*  A division function takes two arguments from the execution stack, divides
    the top of the stack into the next value and pushes the result back onto the
    stack.  */
{
float arg1, arg2;

arg2 = *(--(*pstack_pointer));
arg1 = *(--(*pstack_pointer));
*((*pstack_pointer)++) = arg1 / arg2;
}

FUNCTION do_print(pstack_pointer)
float **pstack_pointer;
/*  A PRINT function has no effect on the execution stack.  */
{
}

FUNCTION do_xht_adj (xht_adj, pstack_pointer)
float   xht_adj;
float **pstack_pointer;
/*  An xht_adj function takes no arguments from the execution stack,
    and pushes the value onto the stack.                */
{
*((*pstack_pointer)++) = xht_adj;
}
