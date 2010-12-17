#include <stdio.h>

#define SUPERIMPOSE    129

struct DEC_data {
                  unsigned char one;
                  unsigned char two;
                  unsigned char DEC; };

static struct DEC_data DEC_table [500] =
{
	{ '!',	'!',	161 },    /* Inverted exclamation mark � */
	{ 'c',	'/',	162 },    /* Cent sign                 � */
	{ '/',	'c',	162 },
	{ 'C',	'/',	162 },
	{ '/',	'C',	162 },
	{ 'c',	'|',	162 },
	{ '|',	'c',	162 },
	{ 'C',	'|',	162 },
	{ '|',	'C',	162 },
	{ 'l',	'-',	163 },    /* Pound sign                � */
	{ '-',	'l',	163 },
	{ 'L',	'-',	163 },
	{ '-',	'L',	163 },
	{ 'l',	'=',	163 },
	{ '=',	'l',	163 },
	{ 'L',	'=',	163 },
	{ '=',	'L',	163 },
	{ 'y',	'-',	165 },    /* Yen sign                  � */
	{ '-',	'y',	165 },
	{ 'Y',	'-',	165 },
	{ '-',	'Y',	165 },
	{ 'y',	'=',	165 },
	{ '=',	'y',	165 },
	{ 'Y',	'=',	165 },
	{ '=',	'Y',	165 },
	{ 's',	'o',	167 },    /* Section sign              � */
	{ 'o',	's',	167 },
	{ 'S',	'O',	167 },
	{ 'O',	'S',	167 },
	{ 's',	'!',	167 },
	{ '!',	's',	167 },
	{ 'S',	'!',	167 },
	{ '!',	'S',	167 },
	{ 's',	'0',	167 },
	{ '0',	's',	167 },
	{ 'S',	'0',	167 },
	{ '0',	'S',	167 },
	{ 'x',	'o',	168 },    /* Currency sign             � */
	{ 'o',	'x',	168 },
	{ 'X',	'O',	168 },
	{ 'O',	'X',	168 },
	{ 'x',	'0',	168 },
	{ '0',	'x',	168 },
	{ 'X',	'0',	168 },
	{ '0',	'X',	168 },
	{ 'c',	'o',	169 },    /* Copyright sign            � */
	{ 'o',	'c',	169 },
	{ 'C',	'O',	169 },
	{ 'O',	'C',	169 },
	{ 'c',	'0',	169 },
	{ '0',	'c',	169 },
	{ 'C',	'0',	169 },
	{ '0',	'C',	169 },
	{ 'a',	'_',	170 },    /* Feminine ordinal indicator � */
	{ '_',	'a',	170 },
	{ 'A',	'_',	170 },
	{ '_',	'A',	170 },
	{ '<',	'<',	171 },    /* Angle quotation mark left  � */
	{ '0',	'^',	176 },    /* Degree sign                � */
	{ '^',	'0',	176 },
	{ ' ',	'*',	176 },
	{ '*',	' ',	176 },
	{ '+',	'-',	177 },    /* Plus/minus sign            � */
	{ '-',	'+',	177 },
	{ '0',	'^',	186 },    /* Superscript 0              � */
	{ '^',	'0',	186 },
	{ '1',	'^',	185 },    /* Superscript 1              � */
	{ '^',	'1',	185 },
	{ '2',	'^',	178 },    /* Superscript 2              � */
	{ '^',	'2',	178 },
	{ '3',	'^',	179 },    /* Superscript 3              � */
	{ '^',	'3',	179 },
	{ '/',	'u',	181 },    /* Micro sign                 � */
	{ '/',	'U',	181 },
	{ 'p',	'!',	182 },    /* Paragraph sign             � */
	{ '!',	'p',	182 },
	{ 'P',	'!',	182 },
	{ '!',	'P',	182 },
	{ '.',	'^',	183 },    /* Middle dot                 � */
	{ '^',	'.',	183 },
	{ '>',	'>',	187 },    /* Angle quotation mark right � */
	{ '1',	'4',	188 },    /* Faction one-quarter        � */
	{ '1',	'2',	189 },    /* Faction one-half           � */
	{ '?',	'?',	191 },    /* Inverted ?                 � */
	{ 'A',	'`',	192 },    /* A grave              � */
	{ '`',	'A',	192 },
	{ 'A',	'\'',	193 },    /* A acute              � */
	{ '\'',	'A',	193 },
	{ 'A',	'^',	194 },    /* A circumflex         � */
	{ '^',	'A',	194 },
	{ 'A',	'~',	195 },    /* A tilde              � */
	{ '~',	'A',	195 },
	{ 'A',	'\"',	196 },    /* A umlaut             � */
	{ '\"',	'A',	196 },
	{ 'A',	'*',	197 },    /* A ring               � */
	{ '*',	'A',	197 },
	{ 'A',	'E',	198 },    /* A E ligature         � */
	{ 'C',	',',	199 },    /* C cedilla            � */
	{ ',',	'C',	199 },
	{ 'E',	'`',	200 },    /* E grave              � */
	{ '`',	'E',	200 },
	{ 'E',	'\'',	201 },    /* E acute              � */
	{ '\'',	'E',	201 },
	{ 'E',	'^',	202 },    /* E circumflex         � */
	{ '^',	'E',	202 },
	{ 'E',	'\"',	203 },    /* E umlaut             � */
	{ '\"',	'E',	203 },
	{ 'I',	'`',	204 },    /* I grave              � */
	{ '`',	'I',	204 },
	{ 'I',	'\'',	205 },    /* I acute              � */
	{ '\'',	'I',	205 },
	{ 'I',	'^',	206 },    /* I circumflex         � */
	{ '^',	'I',	206 },
	{ 'I',	'\"',	207 },    /* I umlaut             � */
	{ '\"',	'I',	207 },
	{ 'N',	'~',	209 },    /* N tilde              � */
	{ '~',	'N',	209 },
	{ 'O',	'`',	210 },    /* O grave              � */
	{ '`',	'O',	210 },
	{ 'O',	'\'',	211 },    /* O acute              � */
	{ '\'',	'O',	211 },
	{ 'O',	'^',	212 },    /* O circumflex         � */
	{ '^',	'O',	212 },
	{ 'O',	'~',	213 },    /* O tilde              � */
	{ '~',	'O',	213 },
	{ 'O',	'\"',	214 },    /* O umlaut             � */
	{ '\"',	'O',	214 },
	{ 'O',	'E',	215 },    /* O E ligature         � */
	{ 'O',	'/',	216 },    /* O slash              0 */
	{ '/',	'O',	216 },
	{ 'U',	'`',	217 },    /* U grave              � */
	{ '`',	'U',	217 },
	{ 'U',	'\'',	218 },    /* U acute              � */
	{ '\'',	'U',	218 },
	{ 'U',	'^',	219 },    /* U circumflex         � */
	{ '^',	'U',	219 },
	{ 'U',	'\"',	220 },    /* U umlaut             � */
	{ '\"',	'U',	220 },
	{ 'Y',	'\"',	221 },    /* Y umlaut             � */
	{ '\"',	'Y',	221 },
	{ 's',	's',	223 },    /* German small sharp s � */
	{ 'a',	'`',	224 },    /* a grave              � */
	{ '`',	'a',	224 },
	{ 'a',	'\'',	225 },    /* a acute              � */
	{ '\'',	'a',	225 },
	{ 'a',	'^',	226 },    /* a circumflex         � */
	{ '^',	'a',	226 },
	{ 'a',	'~',	227 },    /* a tilde              � */
	{ '~',	'a',	227 },
	{ 'a',	'\"',	228 },    /* a umlaut             � */
	{ '\"',	'a',	228 },
	{ 'a',	'*',	229 },    /* a ring               � */
	{ '*',	'a',	229 },
	{ 'a',	'e',	230 },    /* a e ligature         � */
	{ 'c',	',',	231 },    /* c cedilla            � */
	{ ',',	'c',	231 },
	{ 'e',	'`',	232 },    /* e grave              � */
	{ '`',	'e',	232 },
	{ 'e',	'\'',	233 },    /* e acute              � */
	{ '\'',	'e',	233 },
	{ 'e',	'^',	234 },    /* e circumflex         � */
	{ '^',	'e',	234 },
	{ 'e',	'\"',	235 },    /* e umlaut             � */
	{ '\"',	'e',	235 },
	{ 'i',	'`',	236 },    /* i grave              � */
	{ '`',	'i',	236 },
	{ 'i',	'\'',	237 },    /* i acute              � */
	{ '\'',	'i',	237 },
	{ 'i',	'^',	238 },    /* i circumflex         � */
	{ '^',	'i',	238 },
	{ 'i',	'\"',	239 },    /* i umlaut             � */
	{ '\"',	'i',	239 },
	{ 'n',	'~',	241 },    /* n tilde              � */
	{ '~',	'n',	241 },
	{ 'o',	'`',	242 },    /* o grave              � */
	{ '`',	'o',	242 },
	{ 'o',	'\'',	243 },    /* o acute              � */
	{ '\'',	'o',	243 },
	{ 'o',	'^',	244 },    /* o circumflex         � */
	{ '^',	'o',	244 },
	{ 'o',	'~',	245 },    /* o tilde              � */
	{ '~',	'o',	245 },
	{ 'o',	'\"',	246 },    /* o umlaut             � */
	{ '\"',	'o',	246 },
	{ 'o',	'e',	247 },    /* o e ligature         � */
	{ 'o',	'/',	248 },    /* o slash              � */
	{ '/',	'o',	248 },
	{ 'u',	'`',	249 },    /* u grave              � */
	{ '`',	'u',	249 },
	{ 'u',	'\'',	250 },    /* u acute              � */
	{ '\'',	'u',	250 },
	{ 'u',	'^',	251 },    /* u circumflex         � */
	{ '^',	'u',	251 },
	{ 'u',	'\"',	252 },    /* u umlaut             � */
	{ '\"',	'u',	252 },
	{ 'y',	'\"',	253 },    /* y umlaut             � */
	{ '\"',	'y',	253 }
};

/************************************************************************/
/*                                                                      */
/*                     Check_for_DEC()                                  */
/*                                                                      */
/*    This function is used to interpret 3 character DEC Multinational  */
/* sequences and convert them to their 8 bit counterpart.  A single     */
/* character is fed into this routine.  Static variables are used to    */
/* remember previous characters is a sequence.                          */
/*                                                                      */
/*    If more characters are needed to complete the sequence, then a    */
/* value of zero will be returned as the converted character.  If an    */
/* invalid sequence is entered, then any characters used to build the   */
/* sequence will be discarded, and a value of zero will be returned as  */
/* the converted character.                                             */
/*                                                                      */
/*    Characters that do not form part of a DEC sequence will be        */
/* returned unmodified.                                                 */
/*                                                                      */
/************************************************************************/

Check_for_DEC (c, new_c)
unsigned char c;
unsigned char * new_c;
{
static int chars_waiting = 0;	/* Keeps track of whether additional */
				/* characters are need to complete   */
				/* a DEC sequence.                   */

static unsigned char	base_char;  /*  The first character after  */
				    /*  the superimpose character. */

        *new_c = 0;  /* blank character to be returned */

	if ( !chars_waiting && ( c != SUPERIMPOSE ))
	{
		/*  normal flow.  Pass the character back untouched.	*/
printf( "Normal Character %c\n", c );
                *new_c = c;
	}
	else if ( c == SUPERIMPOSE )
	{
printf( "SUPERIMPOSE\n" );
	   chars_waiting = 2;
	}
	else if (( c == '\0' ) && chars_waiting )
	{
		/*  Delete key was pressed during superimpose.		*/
		/*  Blank out what has been done, but don't pass delete	*/
		/*  on to application.					*/
printf( "ERROR\n" );
		chars_waiting = 0;
	}
	else if ( chars_waiting == 2 )
	{
		/*  First character after the superimpose key.  	*/
printf( "1--%c\n", c );
		base_char = c;
		chars_waiting = 1;
	}
	else if ( chars_waiting == 1 )
	{
           int char_found, x;

		/*  Second character after the superimpose key.  	*/
                /*  Use table lookup to verify that this is a good      */
                /*  character sequence and return the DEC character if  */
                /*  it is.                                              */
printf( "2--%c\n", c );
                char_found = 0;
                x = 0;
		chars_waiting = 0;

                while ((DEC_table[x].one != 0) &&
                       (char_found == 0))
                {
                   if ((DEC_table[x].one == base_char) &&
                       (DEC_table[x].two == c))
                   {
                      *new_c = DEC_table[x].DEC;
                      char_found = 1;
printf( "DEC--%c\n", c );
                   }
                   x++;
                }
	}
}
