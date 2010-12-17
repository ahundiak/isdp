/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							ARCasc370dc.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					2/91
**	ABSTRACT:
**		
**	Conversion routine for ascii string to ibm370 packed decimal
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include "COMfunc_.h"
#include "arch.h"
#include "sys_.h"
#include "RIScommon.h"



/*
**	DEFINES
*/
#ifdef TEST
# undef  ARC_ERR
# define ARC_ERR(err) {printf("  *** ERR %d ***\n", err); return;}
# undef ARC_DBG
# define ARC_DBG(x)   printf x  
#endif


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define ARCasc370dc_c
#include "ARCasc370dc_.h"
#include "COMfunc_.h"



/******************************************************************************/

/*
** Convert a null-terminated ascii decimal string to a 370 packed decimal.
**
** Input:  Anything of the form [{+|-}]ddd*.ddd*\0
**
**    Special case:  For a parameter in a where clause that is compared
**		to a decimal, we will know the type as decimal but the
**		size we get will be (15,-1) meaning any value at all.
**		In this case we have to set the precision and scale.
**		There may not be any decimal point.
**
** Output:  precision nibbles + 1 for sign
**
** There will always be just enough space for the output.
**
** If there is an odd number of nibbles ( precision+1 not even),
** there will be a null nibble.  It is the leading nibble.
*/

extern void ARC_asc_to_370_decimal(
	arc_s * arc,
	char *source,		/* source and destination buffer */
	int	bufsize,				/* size of destination buffer in bytes */
	unsigned short *format)		/* precision; scale */
{
	int left_digits;	/* digits to the left of the decimal point */
	int right_digits;	/* digits to the right of the decimal point */
	unsigned char sign = 0xC;		/* assumed positive */
	char *input,*ptr;
	unsigned char *output;
	int blanks;			
	int i;
	int index;
	int nibbles;
	unsigned char precision = (unsigned char)(*format >> 8);
	unsigned char scale = (unsigned char)(*format & 0xff);
	unsigned char tmp;
	/*
	** Output goes back to the original source pointer;
	** this is a copy of the original to work with.
	** At most we can have ARC_MAX_PRECISION digits + sign + . + null.
	*/
	char	copy[ARC_MAX_PRECISION+3];	

ARC_DBG(("\nARC_asc_to_370_decimal(arc:0x%x,buf:%08x,bufsize:%d,prec/scale:%04x\n",
	arc,source,bufsize,*format));

	ARC_DBG(("input:<%s>\n",source));
	input = source;

		/* skip any white space */

	while (*input == ' ')
		++input;

		/* pick up the sign, if any */
	
	if (isdigit(*input) || *input == '.')
		sign = 0xC;	/* positive */
	else if (*input == '-')
	{
		sign = 0xD; /* negative */
		++input;
	}
	else if (*input == '+')
	{
		sign = 0xC;	/* positive */
		++input;
	}

	/*
	** Build up a string of precision digits, with the correct 
	** positioning.
	**
	** It will look like   *bbbddd[.ddd]\0
	**   where the "*" represents a null nibble.
	*/

	index = 0;
	ptr = input;

		/* how many digits we have in the left block */

	for (left_digits=0; isdigit(ptr[left_digits]); ++left_digits)
		;

		/*
		** find out how many right digits there are
		*/

	ptr += left_digits;
	right_digits = 0;
	if (*ptr == '.')
	{
		++ptr;
		for (; isdigit(ptr[right_digits]); ++right_digits)
			;
	}

		/*
		** If this is a special case (precision/scale really unknown),
		** we set the precision and scale based on the number of digits
		** we have found.
		*/

	if (scale == 0xff)
	{
		precision = left_digits + right_digits;
		scale = right_digits;
		*format = (((unsigned short)precision) << 8 ) |  scale;
	}
	
		/*
		** precision - scale - left_digits
		** gives us known leading blanks
		*/

	blanks = precision - scale - left_digits;

	if (!(precision%2))
		copy[index++] = '*';

	for (i=0;  i < blanks; ++i)
		copy[index++] = ' ';

	for (i=0; i < left_digits; ++i,++input)
		copy[index++] = *input;

		/* copy the right section of digits in */

	if (*input == '.')
		++input;

	for (i=0; i < right_digits; ++i,++input)
		copy[index++] = *input;

		/*
		** scale - right_digits
		** gives us known trailing blanks
		*/

	blanks = scale - right_digits;

	for (i=0;  i < blanks; ++i,++input)
		copy[index++] = ' ';

		/* null terminate */

	copy[index] = '\0';

	ARC_DBG(("string:<%s>\n",copy));

	/* 
	**  We now have a null terminated string with the digits positioned
	**  properly.  Pack everything into nibbles.
	*/

	output = (unsigned char *)source;

	input = copy;

		/* loop; two nibbles at a time; only blanks, digits, nulls */

	nibbles = 0;

	while(1)
	{
		if (!*input)	/* at end, throw in the sign */
		{
			*output++ = (sign<<4);
			break;
		}

			/* convert blanks or * to zero, digits to binary */

		if ((*input == ' ') || (*input == '*'))
			tmp = 0;
		else
			tmp = (unsigned char) (*input - 0x30);	

		++input;
		++nibbles;

		tmp = tmp << 4;

		if (*input)
		{
			if (*input == ' ')
				;
			else
				tmp = tmp | (unsigned char)(*input - 0x30);
			++input;
			++nibbles;
		}
		else
			tmp |= sign;	/* throw in the sign at the end */
		
		*output++ = tmp;

	}

	if (ARC_debug)
	{
		ARC_DBG(("result: %02.2x%02.2x%02.2x%02.2x%02.2x%02.2x%02.2x%02.2x\n",
			source[0], source[1], source[2], source[3],
			source[4], source[5], source[6], source[7]));
	}
}

/******************************************************************************/

#ifdef TEST

	int ARC_debug = 1;

	struct {
		char *ptr;
		unsigned short	format;
	} data[] = {
		{"12.34",0x0fff},
		{"+12.34",0x0fff},
		{"-12.34",0x0fff},
		{"12.3",0x0fff},
		{"+12.3",0x0fff},
		{"-12.3",0x0fff},
		{"1.23",0x0fff},
		{"+1.23",0x0fff},
		{"-1.23",0x0fff},
		{"-123",0x0fff},
		{"+123",0x0fff},
		{"123",0x0fff},
		{"1234",0x0fff},
		{".1234",0x0fff},
		{"-.123",0x0fff},
		{"+.123",0x0fff},
		{"78.999",0x0503},
		{"123.456",0x0703},
		{"123.456",0x0704},
		{"-123.456",0x0703},
		{"-123.456",0x0704},
		{"123.456",0x0603},
		{"12345.6",0x0601},
		{"1.23456",0x0605},
		{"123456",0x0600},
		{"-123456",0x0600},
		{"+123456",0x0600},
		{".123456",0x0606},
		{"-.123456",0x0606},
		{"+.123456",0x0606},
		{"123.456",0x0c06},
		{"+123.456", 0x0c06},
		{"-123.456", 0x0c06},
		{(char *)0, 0x0000}
	};
		
main()
{
	int i;
	unsigned short format;
	char array[40];
	for (i=0; data[i].ptr; ++i)
	{
		strcpy(array,data[i].ptr);
		format = data[i].format;
		ARC_asc_to_370_decimal(array, sizeof(array), &format);
		printf("NEW format %04x\n",format);
	}
}

#endif /* TEST */
