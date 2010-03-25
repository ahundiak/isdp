/*
The following are some C routines for manipulating infinite-precision,
integer numbers.  The routines have been fairly well tested, but no
guarantees are offered as to efficiency.  The following operations
are supported:

infpAlloc (ip, n)	- allocate memory for an ip-number of the given size
infpInit (ip, n)	- allocate memory for and initilize a ip-number
infpInitStr (ip, str)	- allocate memory for and initilize a ip-number
			from a string
infpSet (ip, n)		- change the value of an ip-number to the given int
infpSetStr (ip, str)	- change the value of an ip-number to the given str
infpAdd (ip0, ip1)	- add ip0 and ip1 storing the result in ip0
infpSub (ip0, ip1)	- substract ip0 and ip1 storing the result in ip0
infpMult (ip0, ip1)	- multiply ip0 and ip1 storing the result in ip0
infpDiv (ip0, ip1)	- divide ip0 and ip1 storing the result in ip0
infpCmp (ip0, ip1)	- compare ip0 and ip1 returning:
				-1 :  ip0 < ip1
				 0 :  ip0 = ip1
				 1 :  ip0 > ip1

The format used to store the numbers is:
    char *number	- a string with the digits of the number in it with
			no leading zeros
    int size		- the number of digits in the above string
    int maxSize		- the amount of memory allocate for the string
			(maxSize >= size)

*/

#include <stdlib.h>
#include <stdio.h>
#include "infp.h"

#define infpResize(n, size)	\
{				\
    if(n->maxSize < size) {	\
	int newSize;		\
	newSize = MAX(size, n->maxSize*2);	\
	n->number = (char *) realloc(n->number, newSize);	\
	n->maxSize = newSize;	\
    }				\
}

static char *S0_ptr;
static int S0_size=0;
#define SCRATCH0(ptr, size) {	\
    if(size >= S0_size) {	\
	if(S0_size != 0)	\
	    free(S0_ptr);	\
	S0_size = size * 2;	\
	S0_ptr = (char *) malloc(S0_size); \
    }				\
    ptr = S0_ptr;		\
}

static char *S1_ptr;
static int S1_size=0;
#define SCRATCH1(ptr, size) {	\
    if(size >= S1_size) {	\
	if(S1_size != 0)	\
	    free(S1_ptr);	\
	S1_size = size * 2;	\
	S1_ptr = (char *) malloc(S1_size); \
    }				\
    ptr = S1_ptr;		\
}

void
infpCopy();
void
infpAlloc();
void
infpInit();
void
infpInitStr();
void
infpFixZero();
void
infpStripZero();
/*
void
infpResize();
*/
void
infpFree();
void
infpSet();
void
infpSetStr();
void
infpAdd();
void
infpSub();
int
infpDiv();
int
infpCmp();
void
infpAddFunc();
void
infpSubFunc();
void
infpMultFunc();
int
infpDivFunc();

/* Allocate memory for an ip-number of the given size.
 */
void
infpAlloc(n, size)
    infp *n;
    int size;
{
    n->size = size;
    n->maxSize = size;
    n->number = (char *) malloc(n->maxSize);
    n->negative = 0;
}


/* Allocate memory for and initialize an ip-number.  The number is
 * initialized to the value in the integer "number."
 */
void
infpInit(n, number)
    infp *n;
    int number;
{
    infpAlloc(n, 32);
    infpSet(n, number);
}


/* Copy the ip-number in ip1 to ip0; ip1 is unaffected.
 */
void
infpCopy(n0, n1)
    infp *n0, *n1;
{
    n1->size = n0->size;
    infpResize(n1, n1->size);
    memcpy(n1->number, n0->number, n0->size);
    n1->negative = n0->negative;
    infpStripZero(n1);
}


/* Allocate memory for and initialize an ip-number.  The number is
 * initialized to the value in the string "str."
 */
void
infpInitStr(n, str)
    infp *n;
    char *str;
{
    infpAlloc(n, strlen(str));
    infpSetStr(n, str);
}


/* infpFixZero changes -0 to 0.
 */

void
infpFixZero(n)
    infp *n;
{
    if((n->negative) && (n->size == 1) && (n->number[0] == (char) 0))
	n->negative = 0;
}

/* Removes leading zeros from the given ip-number.  This routine should
 * only be necessary for internal use.  The possibility of leading zeros
 * makes writing the operators much more difficult as no assumptions can
 * be made about the size of a number by its length.
 */

void
infpStripZero(n)
    infp *n;
{
    int i;
    char *c, *b;

    b = n->number;
    for(i=0, c=b; i<n->size; ++i,++c)
	if(*c > 0)
	    break;

    if(i > 0) {
	int newSize;

	newSize = n->size - i;
	if(newSize > 0) {
	    for(;i<n->size; ++i, ++b, ++c)
		*b = *c;

	    n->size = newSize;
	} else {
	    n->size = 1;
	    *(n->number) = 0;
	}
    }
}


/* Make sure that the given ip-number is big enough for "size" digits.
 */
/*
void
infpResize(n, size)
    infp *n;
    int size;
{
    if(n->maxSize < size) {
	int newSize;

	newSize = MAX(size, n->maxSize*2);
	n->number = (char *) realloc(n->number, newSize);
	n->maxSize = newSize;
    }
}
*/

/* Free the memory used by an ip-number.
 */

void
infpFree(n)
    infp *n;
{
    free(n->number);
}


/* Set the value of an ip-number to the value in the integer "i."
 */

void
infpSet(n, i)
    infp *n;
    int i;
{
    int size, b, e;
    char nBuf[256];

    if(i < 0) {
	n->negative = 1;
	i = -i;
    } else
	n->negative = 0;

    size = 0;
    while( i > 0) {
	nBuf[size] = (char)(i % 10);
	i /= 10;
	++size;
    }

    infpResize(n, size);
    if(size == 0) {
	n->size = 1;
	n->number[0] = (char) 0;
    } else {
	n->size = size;
	for(b=0,e=size-1; b<size; ++b, --e)
	    n->number[e] = nBuf[b];
    }
}


/* Set the value of an ip-number to the value in the string "str."
 */

void
infpSetStr(n, str)
    infp *n;
    char *str;
{
    int size;
    char *nPtr;

    if(*str == '-') {
	n->negative = 1;
	++str;
    } else
	n->negative = 0;

    size = strlen(str);
    infpResize(n, size);
    if(size == 0) {
	n->size = 1;
	n->number[0] = (char) 0;
    } else {
	n->size = size;
	for(nPtr=n->number; *str; ++nPtr, ++str)
	    *nPtr = *str - '0';
    }
    infpStripZero(n);
}


/* infpAdd takes two (possibly negative) numbers, and calls the
 * appropriate function to actually perform the work.
 */

void
infpAdd(result, n0, n1)
    infp *result, *n0, *n1;
{
    infp arg0, arg1;

    infpSet(result, 0);

	/* If the signs are the same, just add as usual */
    if(n0->negative == n1->negative) {
	if(n0->negative) {
	    arg0 = *n0;
	    arg1 = *n1;
	    arg0.negative = 0;
	    arg1.negative = 0;
	    infpAddFunc(result, &arg0, &arg1);
	    result->negative = 1;
	} else
	    infpAddFunc(result, n0, n1);
    } else {
		/* The signs are opposite, subtract instead */
	arg0 = *n0;
	arg1 = *n1;
	if(arg0.negative) {
	    arg0.negative = 0;
	    infpSub(result, &arg1, &arg0);
	} else {
	    arg1.negative = 0;
	    infpSub(result, &arg0, &arg1);
	}
    }
    infpFixZero(result);
}


/* infpSub takes two (possibly negative) numbers, and calls the
 * appropriate function to actually perform the work.
 */

void
infpSub(result, n0, n1)
    infp *result, *n0, *n1;
{
    infp arg0, arg1;

    infpSet(result, 0);

    if(n1->negative) {
		/* Second argument is negative: x - (-y) */
	arg0 = *n0;
	arg1 = *n1;
	if(n0->negative) {
	    arg0.negative = 0;
	    arg1.negative = 0;
	    infpSub(result, &arg1, &arg0);
	} else {
	    arg1.negative = 0;
	    infpAddFunc(result, &arg0, &arg1);
	}
    } else if(n0->negative) {
		/* Only first argument is negative */
	arg0 = *n0;
	arg1 = *n1;
	arg0.negative = 0;
	infpAddFunc(result, &arg0, &arg1);
	result->negative = 1;
    } else {
		/* Both arguments are positive */
	if(infpCmp(n0, n1) < 0) {
		/* This means the result will be negative.
		 * Reverse the order, subtract, and change the sign
		 * of the result.
		 */
	    arg0 = *n0;
	    arg1 = *n1;
	    infpSubFunc(result, &arg1, &arg0);
	    result->negative = 1;
	} else
	    infpSubFunc(result, n0, n1);
    }
    infpFixZero(result);
}


/* infpDiv takes two (possibly negative) numbers, calls the infpDivFunc
 * to do the work, and then fixes the sign of the result.
 */

int
infpDiv(result, n0, n1)
    infp *result, *n0, *n1;
{
    infp arg0, arg1;
    int ret;

    arg0 = *n0;
    arg1 = *n1;

    arg0.negative = 0;
    arg1.negative = 0;

    ret = infpDivFunc(result, &arg0, &arg1);

    if(n0->negative == n1->negative)
	result->negative = 0;
    else
	result->negative = 1;
    infpFixZero(result);

    return(ret);
}


/* infpMult takes two (possibly negative) numbers, calls the infpMultFunc
 * to do the work, and then fixes the sign of the result.
 */

void
infpMult(result, n0, n1)
    infp *result, *n0, *n1;
{
    infp arg0, arg1;

    arg0 = *n0;
    arg1 = *n1;

    arg0.negative = 0;
    arg1.negative = 0;

    infpMultFunc(result, &arg0, &arg1);

    if(n0->negative == n1->negative)
	result->negative = 0;
    else
	result->negative = 1;

    infpFixZero(result);
}


/* Add the ip-numbers in n0 and n1 and store the result
 */

void
infpAddFunc(result, n0, n1)
    infp *result, *n0, *n1;
{
    char *b0, *b1, *num0, *num1, *r;
    infp *op0, *op1;
    int sum, carry;

    if(n0->size > n1->size) {
	op0 = n0;
	op1 = n1;
    } else {
	op1 = n0;
	op0 = n1;
    }

    result->size = op0->size + 1;
    infpResize(result, result->size);

    b0 = op0->number;
    b1 = op1->number;
    num0 = b0 + op0->size-1;
    num1 = b1 + op1->size-1;
    r = result->number + result->size - 1;

    carry = 0;
    while(num0 >= b0) {
	if(num1 < b1)
	    sum = *num0 + carry;
	else {
	    sum = *num0 + *num1 + carry;
	    --num1;
	}
	--num0;

	if(sum > 9) {
	    carry = 1;
	    *r = sum - 10;
	} else {
	    carry = 0;
	    *r = sum;
	}
	--r;
    }
    if(carry)
	*r = 1;
    else
	*r = 0;

    infpStripZero(result);
}


/* Subtract the ip-number n1 from n0 and store the result; n0 and n1 are
 * unaffected.
 */

void
infpSubFunc(result, n0, n1)
    infp *result, *n0, *n1;
{
    char *b0, *b1, *num0, *num1, *r;
    int dif, carry;

    if(n0->size < n1->size) {
	infpSet(result, 0);
	return;
    }

    result->size = n0->size;
    infpResize(result, result->size);

    b0 = n0->number;
    b1 = n1->number;
    num0 = b0 + n0->size-1;
    num1 = b1 + n1->size-1;
    r = result->number + result->size - 1;

    carry = 0;
    while(num1 >= b1) {
	dif = *num0 - *num1 - carry;

	if(dif < 0) {
	    *r = dif + 10;
	    carry = 1;
	} else {
	    *r = dif;
	    carry = 0;
	}

	--r;
	--num0;
	--num1;
    }
    while(num0 >= b0) {
	dif = *num0 - carry;

	if(dif < 0) {
	    *r = dif + 10;
	    carry = 1;
	} else {
	    *r = dif;
	    carry = 0;
	}

	--r;
	--num0;
    }
    if(carry) {
	infpSet(result, 0);
	return;
    }

    infpStripZero(result);
}


/* Multiply the ip-numbers in n0 and n1 and store the result; n0 and n1 are
 * unaffected.
 */
void
infpMultFunc(result, n0, n1)
    infp *result, *n0, *n1;
{
    char *b0, *b1, *num0, *num1;
    int sum, carry;
    char *accum, *accumPtr, *tmp, *tmpPtr;
    int accumSize;

    accumSize = n0->size + n1->size;
/*    accum = (char *) malloc(accumSize);*/
    SCRATCH0(accum, accumSize);
    accumPtr = accum;
    memset(accum, 0, accumSize);
/*    tmp = (char *) malloc(accumSize);*/
    SCRATCH1(tmp, accumSize);
    b0 = n0->number;
    b1 = n1->number;
    num1 = b1 + n1->size-1;

    carry = 0;
    while(num1 >= b1) {
	num0 = b0 + n0->size-1;
	carry = 0;
	tmpPtr = tmp;
	
	while(num0 >= b0) {
	    sum = (*num0) * (*num1) + carry;
	    *tmpPtr++ = sum % 10;
	    carry = sum / 10;
	    --num0;
	}
	*tmpPtr++ = carry;

	{
	    char *t, *a;

	    carry = 0;
	    for(t=tmp, a=accumPtr; t!=tmpPtr; ++t, ++a) {
		sum = *a + *t + carry;

		if(sum > 9) {
		    carry = 1;
		    *a = sum - 10;
		} else {
		    carry = 0;
		    *a = sum;
		}
	    }
	    if(carry)
		*a = 1;

	    ++accumPtr;
	}

	--num1;
    }

    {
	char *resultNumber;

	result->size = accumSize;
	infpResize(result, result->size);
	resultNumber = result->number + accumSize - 1;
	accumPtr = accum;
	while(accumSize--)
	    *resultNumber-- = *accumPtr++;
    }

/*    free(accum);*/
/*    free(tmp);*/
    infpStripZero(result);
}


/* Divide the ip-number n0 by n1 and store the result; n0 and n1 are
 * unaffected.
 */

int
infpDivFunc(result, n0, n1)
    infp *result, *n0, *n1;
{
    char *number0, *number1;
    char *num0, *num1;
    char *divisor, *divPtr, *resultPtr;
    int dif, carry, count, shift, size, digit, divSize;

	/* Integer math determines that dividing a smaller number by
	 * a larger one will always return 0.
	 */
    if(n0->size < n1->size) {
	infpSet(result, 0);
	return(1);
    }

	/* Test for divide by 0 */
    if((n1->size == 1) && (n1->number[0] == 0)) {
	infpSet(result, 0);
	return(1);
    }

	/* Set up the result variable.  The size calculated is not only
	 * the worst case, the dividing algorithm depends on it being
	 * this size.
	 */
    result->size = n0->size - n1->size + 1;
    infpResize(result, result->size);
    resultPtr = result->number;

	/* Shift is the number of decimal places to shift the divisor
	 * (the smaller number) to match the dividend for the first
	 * round of subtraction.
	 */
    shift = n0->size - n1->size;

	/* This size is the size of the two scratch numbers used.  Each is
	 * the size of the dividend (larger number) plus one more digit.
	 * This extra digit allows the subtraction algorithm to work
	 * without making a special case for the first round of subtraction
	 * where we could potentially store one more digit than we had room
	 * for.  During that particular subtraction, this digit will be
	 * zero, but I don't want to check for it.  Plus, all the rest
	 * of the times we do want to store the zero to remove unused
	 * digits from the result.
	 */
    size = n0->size + 1;
    SCRATCH0(number0, size);
    *number0 = (char) 0;
    memcpy(number0+1, n0->number, n0->size);
    SCRATCH1(number1, size);
    memcpy(number1, number0, size);
    divisor = n1->number;
    divSize = n1->size;
/*
 *	The algorithm:
 *	  - Put the dividend into two scratch numbers, number0 and number1;
 *	  - Subtract the shifted divisor from number0 into number1
 *	  - If the subtraction didn't work, stop and the count of subtractions
 *	    so far is the result digit.
 *	  - If the subtraction worked, increment the count, switch the pointers
 *	    on number0 and number1, and do the subtract again.
 */

    for(digit=0; digit<=shift; ++digit) {
	count = 0;

	for(;;) {
	    carry = 0;
	    divPtr = divisor + divSize - 1;
	    num0 = number0 + divSize + digit;
	    num1 = number1 + divSize + digit;

	    while(divPtr >= divisor) {
		dif = *num0 - *divPtr - carry;

		if(dif < 0) {
		    *num1 = dif + 10;
		    carry = 1;
		} else {
		    *num1 = dif;
		    carry = 0;
		}

		--divPtr;
		--num0;
		--num1;
	    }

		/* Do one more digit to take care of left-over carry. */
	    dif = *num0 - carry;

	    if(dif < 0)
		break;
	    else {
		char *tmp;

		*num1 = dif;
		tmp = number0;
		number0 = number1;
		number1 = tmp;
		++count;
	    }
	}

	*resultPtr++ = count;
    }
	/* Strip any leading zeros from the result. */

    infpStripZero(result);

	/* If the final subtraction left all zeros, return 0 meaning
	 * there was no remainder.  Otherwise, return 1.
	 */
    num0 = number0 + size;
    for(digit=0; digit<divSize; ++digit ) {
	--num0;
	if(*num0)
	    return(1);
    }

    return(0);
}


/* Compare the ip-numbers in n0 and n1 and return:
 *	-1 if  ip0 < ip1
 *	 0 if  ip0 = ip1
 * 	 1 if  ip0 > ip1
 */

int
infpCmp(n0, n1)
    infp *n0, *n1;
{
    char *c0, *c1;
    int count;

    if(n0->negative != n1->negative) {
	if(n0->negative)
	    return(-1);
	else
	    return(1);
    } else {
	if(n0->negative) {
	    infp *t;
	    t = n0;
	    n0 = n1;
	    n1 = t;
	}
    }

    if(n0->size > n1->size)
	return(1);

    if(n0->size < n1->size)
	return(-1);

    c0 =n0->number;
    c1 = n1->number;
    for(count=n0->size; count; --count) {
	if(*c0 > *c1)
	    return(1);

	if(*c0 < *c1)
	    return(-1);

	++c0;
	++c1;
    }

    return(0);
}


/* Print the contents of the ip-number "n" to the specified stream.
 */

infpPrint(strm, n)

char *strm;
infp *n;

{
    int 	i;
    char 	*c;
    char	onech[2];

    strm[0] = '\0';

    if(n->negative)
	strcat(strm, "-");

    for(i=0, c=n->number; i<n->size; ++i, ++c)
    {
	sprintf(onech, "%c", (int)(*c + '0'));
	strcat(strm, onech);
    } /* for */
}

infpOut(n)
    infp *n;
{
	int	i;
	char	*c;

	for(i=0, c=n->number; i<n->size; ++i, ++c)
		fprintf(stdout, "%c", (int)(*c + '0'));
	printf("\n");
} /* infpOut */


infp oper(op, op0, op1)

char	op;
infp	op0;
infp	op1;

{
	infp result;

	infpInit(&result, 0);

	switch(op) 
	{
	    case '+':
		infpAdd(&result, &op0, &op1);
		break;
	    case '-':
		infpSub(&result, &op0, &op1);
		break;
	    case '*':
		infpMult(&result, &op0, &op1);
		break;
	    case '/':
		infpDiv(&result, &op0, &op1);
		break;
	} /* switch */
/*
	infpOut(&op0);
	printf(" %c ", op);
	infpOut(&op1);
	printf(" = ");
	infpOut(&result);
	printf("\n");
*/
	return(result);
} /* oper */

