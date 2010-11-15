/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							ARC370ascdc.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					2/91
**	ABSTRACT:
**	Conversion routine for ibm370 packed decimal to ascii string
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include  <stdio.h>
#include "arch.h"
#include "sys_.h"
#include "ARCgeneric_.h"
#include "RIScommon.h"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define ARC370ascdc_c
#include "ARC370ascdc_.h"
#include "COMfunc_.h"



/******************************************************************************/

/*
** Convert a 370 packed decimal to an ascii string.
**
** Input:	byte array 
**			# of bytes is  (precision+1)/2 rounded up
**			consists of "precision" digit nibbles and a sign nibble;
**			sign is 0xD or 0xB for negative, 0xC for positive
**
**			Note: if there is a spare nibble, it is the leading nibble
**
** We must avoid overflowing the output buffer, which might not be big enough.
** In the case of overflow, the resulting ascii string is truncated.
**
** The different types of output strings are:
**
**	decimal(x,y) where x>y, y=0 e.g. decimal(2,0)
**
**		Note: always dot, leading zero in only one case
**		12.
**		10.
**		 1.
**		 0.
**
**	decimal(x,y) where x>y, y>0 e.g. decimal(4,2)
**
**		Note: always dot, leading zero in only one case, use trailing zeroes
**		12.23
**		10.01
**		 1.20
**		 0.00
**
**	decimal(x,y) where x=y, e.g. decimal(2,2)
**
**		Note: preceding dot, fill out field with trailing zeroes, no leading 0
**		.12
**		.10		
**		.00		
**
*/

extern void ARC_370_to_asc_decimal(
	arc_s * arc,
	unsigned char *source,			/* source and destination buffer */
	int	bufsize,				/* size of destination buffer in bytes */
	unsigned short format)		/* precision/scale */
{
	/*
	** Buffer used to build up a string; no ascii string needs more 
	** than ARC_MAX_PRECISION + sign + dot + null.
	*/
	char	buffer[ARC_MAX_PRECISION+3];	
	char	*bufp;	/* points to a position in buffer */
	unsigned char *input;
	unsigned char  tmp,nibble1,nibble2;
	int nibbles,radix,print_zeroes;
	unsigned char precision = (unsigned char)(format >> 8);
	unsigned char scale = (unsigned char) (format & 0xff);

ARC_DBG(("\nARC_370_to_asc_decimal(arc:0x%x,buf:%08x,bufsize:%d,prec/scale:%04x\n",
	arc,source,bufsize,format));

	ARC_DBG(("input:%02x%02x%02x%02x%02x%02x%02x%02x\n",
		source[0], source[1], source[2], source[3],
		source[4], source[5], source[6], source[7]));

	bufp = buffer;

		/* 
		** We will not use a sign for positive; just a - for negative numbers.
		** Last nibble 0xf means negative; last nibble 0xd is positive.
		*/

	tmp = source[((precision+2)/2)-1] & 0xf;

	if ((tmp == 0xB) || (tmp == 0xD))	/* negative */
		*bufp++ = '-';

		/*
		** determine where the radix goes;
		** precision minus scale is the number of nibbles to process
		**  before putting in the radix
		*/

	radix = precision - scale;

		/* 
		** Putting digits into the string is easy.  The only tricky
		** parts are watching when to put the decimal point in (may be first),
		** watching not to treat the sign as a digit, and determining when
		** to put in a leading zero.
		*/

	input = (unsigned char *)source;
	nibbles = 0;		/* nibbles put in */
	print_zeroes = 0;	/* don't print zeroes until non-zero or radix */

		/* check to see if we start with a "." */

	if (radix == 0)
	{
		*bufp++ = '.';
		if (precision%2)
			print_zeroes = 1;
	}

	while (1)
	{
		tmp  = *input++;		/* get two nibbles */

		nibble1 = (tmp>>4) & 0xf;
		nibble2 = tmp & 0xf;

		if ((nibble1) || print_zeroes || nibbles || (precision%2))
		{
			if (nibble1 || print_zeroes)
			{
				*bufp++ = (char)(nibble1 + 0x30);
				print_zeroes = 1;
			}
			++nibbles;

			if (nibbles == radix)
			{
				if (radix && (bufp == buffer))
					*bufp++ = '0';
				*bufp++ = '.';
				print_zeroes = 1;
			}
		}

		if (nibbles > radix)
			print_zeroes = 1;

		if (nibbles == precision)
			break;

		if (nibble2 || print_zeroes)
		{
			*bufp++ = (char)(nibble2 + 0x30);
			print_zeroes = 1;
		}

		++nibbles;

		if (nibbles == radix)
		{
			if (radix && (bufp == buffer))
				*bufp++ = '0';
			*bufp++ = '.';
			print_zeroes = 1;
		}
		if (nibbles == precision)
			break;
	}
	
	*bufp = '\0';

	ARC_DBG(("string: <%s>\n", buffer));

	ARC_cpy(bufsize, buffer, (char*)source);

	ARC_DBG(("result: <%s>\n", source));
}

/******************************************************************************/

#ifdef TEST

	struct {
		unsigned values[2];
		char *expected;
		unsigned short format;
	} data[] = {
		{{0x6C452301,0x00000000},".123456",0x0606},
		{{0x34120000,0x000C0056},"123.456000",0x0c06},
		{{0x6d452301,0x00000000},"-.123456",0x0606},
		{{0x34120000,0x000D0056},"-123.456000",0x0c06},
		{{0x6d452301,0x00000000},"-123.456",0x0603},
		{{0x6c452001,0x00000000},"120.456",0x0603},
		{{0x6c052301,0x00000000},"123.056",0x0603},
		{{0x6c052001,0x00000000},"120.056",0x0603},
		{{0x6c452301,0x00000000},"123.456",0x0603},
		{{0x6c452301,0x00000000},"12345.6",0x0601},
		{{0x6c452301,0x00000000},"1.23456",0x0605},
		{{0x6c452301,0x00000000},"123456.",0x0600},
		{{0x6c402301,0x00000000},"123406.",0x0600},
		{{0x6c052301,0x00000000},"123056.",0x0600},
		{{0x6d452301,0x00000000},"-123456.",0x0600},
		{{0x6c452301,0x00000000},"123456.",0x0600},
		{{0x6c452301,0x00000000},".123456",0x0606},
		{{0x6C452301,0x00000000},"0.123456",0x0706},
		{{0x61452301,0x006D4523},"-123456.123456",0x0c06},
		{{0x78563412,0x6D452391},"-123456789.123456",0x0f06},
		{{0x78563412,0x6C452391},"123456789.123456",0x0f06},
		{{0,0},0, 0x0000}
	};
		
main()
{
	int i;
	char array[40];
	for (i=0; data[i].expected; ++i)
	{
		ARC_cpy(8, data[i].values, array);
		ARC_370_to_asc_decimal(array, sizeof(array), data[i].format);
		printf("--------------GOT-----------  %s\n",array);
		printf("--------------EXPECTED------  %s\n",data[i].expected);
	}
}

#endif /* TEST */
