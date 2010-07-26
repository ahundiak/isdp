/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"

/*
 *  This routine converts an ASCII string
 *  to a rad50 string
 */

GUascii_to_rad50 ( num_chars, string, rad_50 )

IGRint		  *num_chars;
IGRchar		  *string;
IGRushort rad_50[];

{
    IGRint	i;
    IGRint	j;
    IGRint	num_words;
    IGRshort	factors[3];


    /*
     *  Calculate the number of words required to
     *  store the rad-50 value of the string.
     */

    num_words = *num_chars / 3;
    if ( *num_chars % 3 )
    {
	num_words++;
    }


    /*
     *  Convert each sequence of three characters to its
     *  rad-50 equivalent (padding with blanks if necessary)
     *  and store.
     */

    for ( i = 0; i < num_words; i++ )
    {

   	for ( j = 0; j < 3; j++ )
	{
	    if ( i*3+j+1 > *num_chars )
	    {
		factors[j] = 0;
  	    }
	    else if ( *string >= 'A'  &&  *string <= 'Z' )
	    {
		factors[j] = *string - 64;
	    }
	    else if ( *string >= 'a'  &&  *string <= 'z' )
	    {
		factors[j] = *string - 96;
	    }
	    else if ( *string >= '0'  &&  *string <= '9' )
	    {
		factors[j] = *string - 18;
	    }
	    else if ( *string == '$' )
	    {
		factors[j] = 27;
     	    }
	    else if ( *string == '.' )
	    {
		factors[j] = 28;
	    }
	    else
	    {
		factors[j] = 0;
	    }

	    string++;

	}
	
	rad_50[i] = factors[0]*1600 + factors[1]*40 + factors[2];

    }
}


/*
 *  This routine converts a rad_50 string 
 *  to a null-terminated ASCII string
 */

GUrad50_to_ascii ( num_words, rad_50, string )

IGRlong		  *num_words;
IGRushort *rad_50;
IGRchar		  *string;	/* size of string array = 3 * num_words + 1 */
{

    IGRlong	i;
    IGRshort	char1,char2,char3;


    /*
     *  Convert each word of the rad-50 array to
     *  three ASCII character values
     */

    for ( i = 0; i < *num_words; ++i )
    {

	char1 = *rad_50 / 1600;

        *rad_50 = *rad_50 - (1600 * char1);

	char2 = *rad_50 / 40;

	*rad_50 = *rad_50 - (40 * char2);

	char3 = *rad_50; 

	++rad_50;


	/*
	 *  check for letter, number, or special symbol
 	 */

	if ( (char1 >= 1) && (char1 <= 26) )
	{
	    char1 += 64;			/* A - Z */
	}
	else if ( char1 == 27 )
	{
	    char1 += 9;				/*   $   */
	}
	else if ( char1 == 28 )
	{
	    char1 += 18;			/*   .   */
	}
	else if ( (char1 >= 30) && (char1 <= 39) )
	{
	    char1 += 18;			/* 0 - 9 */
	}
	else
	{
	    char1 = 32;				/* space */
	}

	*string++ = char1;


	if ( (char2 >= 1) && (char2 <= 26) )
	{
	    char2 += 64;			/* A - Z */
	}
	else if ( char2 == 27 )
	{
	    char2 += 9;				/*   $   */
	}
	else if ( char2 == 28 )
	{
	    char2 += 18;			/*   .   */
	}
	else if ( (char2 >= 30) && (char2 <= 39) )
	{
	    char2 += 18;			/* 0 - 9 */
	}
	else
	{
	    char2 = 32;				/* space */
	}

	*string++ = char2;


	if ( (char3 >= 1) && (char3 <= 26) )
	{
	    char3 += 64;			/* A - Z */
	}
	else if ( char3 == 27 )
	{
	    char3 += 9;				/*   $   */
	}
	else if ( char3 == 28 )
	{
	    char3 += 18;			/*   .   */
	}
	else if ( (char3 >= 30) && (char3 <= 39) )
	{
	    char3 += 18;			/* 0 - 9 */
	}
	else
	{
	    char3 = 32;				/* space */
	}

	*string++ = char3;
    }

    /*
     *  put the null-terminator at the end
     *  of the ASCII string
     */

    --string;

    for ( i = 0; i < *num_words * 3; ++i )
    {
	if ((( *string >= 0x41 ) && ( *string <= 0x5a ))	/* A - Z */
	    || (( *string >= 0x30 ) && ( *string <= 0x39 ))	/* 0 - 9 */
	    || ( *string == 0x24 ) || ( *string == 0x2e ))	/* $ .   */
	{
	    break;
	}
	else
	{
	   --string;
	}
    }
   
    ++string;
    *string = 0x00;
}
