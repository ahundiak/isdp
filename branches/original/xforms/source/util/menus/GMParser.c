#include <sys/types.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include "GMoutline.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

extern	double	atof();

/******************************************************************************

Doc:	GMGetLine

Abstract:
	The GMGetLine function gets the next line from the outline file
	and writes it into the given buffer.

Notes:
	1. A line is terminated by `\n' unless preceeded by `\'.
	2. Comments are indicated by `#' and are not returned.

Return Values:
	Number of characters written in the buffer
	EOF (-1)

******************************************************************************/
/* struct GMParseFp *fp;     ** i - File info for parsing  */
/* char             *buf;    ** o - Data buffer            */
/* int              bufLen;  ** i - Buffer length          */

int	GMGetLine (struct GMParseFp *fp,
                   char             *buf,
                   int              bufLen)
{
int	c, cPrev;
int	count, count2, maxCount;

	count = 0;
	maxCount = bufLen - 1;
	c = EOF;

	while ( 1 )
	{
		cPrev = c;
		c = getc( fp->in );

		if ( c == EOF )
		{
			buf[count] = NULLCHAR;
			return( EOF );
		}
		else if ( c == EOL )
		{
			fp->line++;

			if ( cPrev != BACKSLASH )
				buf[count] = NULLCHAR;
			else
			{
				if ( count && buf[count - 1] == BACKSLASH )
					count--;
				count2 = GMGetLine( fp, &buf[count], bufLen - count );
				if ( count2 != EOF )
					count += count2;
			}
			return( count );
		}
		else if ( count < maxCount )
		{
			if ( c != COMMENT )
				buf[count++] = c;
			else
			{
				GMGetLine( fp, &buf[count], 1 );
				return( count );
			}
		}
	}
}

/******************************************************************************

Doc:	GMParseToken

Abstract:
	The GMParseToken function parses the next token from the line
	buffer and writes it into the given token buffer.

Notes:
	1. Tokens are delimited by `,'.
	2. Preceeding and trailing white space is stripped off.
	3. When a `,' is part of the token, it must be protected by
	   quotes ("").

Return Values:
	Number of characters parsed to create the token

******************************************************************************/
/* char	*token;  ** o - Next token in the line		*/
/* char	*line;   ** i - Data buffer for line		*/

int	GMParseToken (char *token,
                      char *line)
{
int	count, len;

	for ( count = 0; isspace( line[count] ); count++ )
		;

	len = 0;

	while ( line[count] != DELIMETER && line[count] != NULLCHAR )
	{
		token[len++] = line[count++];

		if ( line[count - 1] == DQUOTE )
		{
			while ( line[count] != DQUOTE && line[count] != NULLCHAR )
				token[len++] = line[count++];

			token[len++] = DQUOTE;
			if ( line[count] != NULLCHAR )
				count++;
		}
	}

	for ( --len; len > 0 && isspace( token[len] ); len-- )
		;
	token[++len] = NULLCHAR;


	if ( line[count] == DELIMETER )
		count++;

	return( count );
}

/******************************************************************************

Doc:	GMParseKeyword

Abstract:
	The GMParseKeyword function parses the given keyword token
	into a keyword type and associated data.

Notes:
	The keyword token format is `TYPE=data'.

Return Values:
	Defined keyword types (Listed in GMoutline.h)
	UNDEF_KEYWORD  (Undefined keyword)

******************************************************************************/
/* union GMTokenData *data;   ** o - Keyword token data */
/* char              *token;  ** i - Keyword token      */

int	GMParseKeyword (union GMTokenData *data,
                        char              *token)
{
int	num, keyLen, dataStrt;
char	keyword[PARSE_BUF_LEN];

static	char	*keywordList[]={
		"X",		"Y",
		"NUM",		"NUM2",		"NUM3",		"NUM4",
		"HT",		"HT2",		"HT3",		"HT4",
		"WD",		"WD2",		"WD3",		"WD4",
		"REM",
		"CMD",
		"OFF",		"ON",		"OFF2",		"ON2",
		"HELP",
		"SYM",
		"FONT",		"SIZE",		"STYLE",	"JUST" };

static	int	tokenType[]={
		INT_TOKEN,	INT_TOKEN,
		INT_TOKEN,	INT_TOKEN,	INT_TOKEN,	INT_TOKEN,
		INT_TOKEN,	INT_TOKEN,	INT_TOKEN,	INT_TOKEN,
		INT_TOKEN,	INT_TOKEN,	INT_TOKEN,	INT_TOKEN,
		YESNO_TOKEN,
		CHAR_TOKEN,
		COLOR_TOKEN,	COLOR_TOKEN,	COLOR_TOKEN,	COLOR_TOKEN,
		CHAR_TOKEN,
		CHAR_TOKEN,
		CHAR_TOKEN,	INT_TOKEN,	STYLE_TOKEN,	JUST_TOKEN };

	keyLen = strcspn( token, " =" );
	dataStrt = keyLen + strspn( &token[keyLen], " =" );

	for ( num = 0; num < keyLen; num++ )
		keyword[num] = toupper( token[num] );
	keyword[num] = NULLCHAR;

	for ( num = 0; num < MAX_KEYWORDS; num++ )
	{
		if ( strcmp( keyword, keywordList[num] ) == 0 )
		{
			switch ( tokenType[num] )
			{
			case INT_TOKEN:
				data->ival = atoi( &token[dataStrt] );
				break;
			case DBL_TOKEN:
				data->dval = atof( &token[dataStrt] );
				break;
			case CHAR_TOKEN:
				strcpy( data->aval, &token[dataStrt] );
				break;
			case YESNO_TOKEN:
				data->ival = GMParseYesNo( &token[dataStrt] );
				break;
			case COLOR_TOKEN:
				data->ival = GMParseColor( &token[dataStrt] );
				break;
			case STYLE_TOKEN:
				data->ival = GMParseStyle( &token[dataStrt] );
				break;
			case JUST_TOKEN:
				data->ival = GMParseJust( &token[dataStrt] );
				break;
			}
			return( num );
		}
	}

	return( UNDEF_KEYWORD );
}

/******************************************************************************

Doc:	GMParseYesNo

Abstract:
	The GMParseYesNo function parses a yes/no token.

Return Values:
	TRUE		-	"yes" token
	FALSE		-	"no" token
	UNDEFINED_DATA	-	Neither token

******************************************************************************/
/* char	*token;    ** i - Yes/no token to interpret  */

int	GMParseYesNo (char *token)
{
int	i, len;
char	yesno[PARSE_BUF_LEN];

	len = strlen( token );
	for ( i = 0; i < len; i++ )
		yesno[i] = tolower( token[i] );
	yesno[i] = NULLCHAR;

	if ( strcmp( yesno, "yes" ) == 0 )
		return( TRUE );
	else if ( strcmp( yesno, "no" ) == 0 )
		return( FALSE );
	else
		return( UNDEFINED_DATA );
}

/******************************************************************************

Doc:	GMParseColor

Abstract:
	The GMParseColor function parses a color name token.

Return Values:
	Color index matching color name  (Listed in FI.h)
	UNDEFINED_DATA  (Undefined color name)

******************************************************************************/
/* char	*token;     ** i - Color name to interpret  */

int	GMParseColor (char *token)
{
int	i, len, colorIdx;
char	color[PARSE_BUF_LEN];

static	char	*colorList[]={
		"off white",	"med grey",	"black",	"yellow",
		"lt grey",	"dk grey",	"white",	"red",
		"green",	"blue",		"lt yellow",	"dk red",
		"dk green",	"dk blue" };

	len = strlen( token );
	for ( i = 0; i < len; i++ )
		color[i] = tolower( token[i] );
	color[i] = NULLCHAR;

	for ( colorIdx = 0; colorIdx < 14; colorIdx++ )
	{
		if ( strcmp( color, colorList[colorIdx] ) == 0 )
			return( colorIdx );
	}

	return( UNDEFINED_DATA );
}

/******************************************************************************

Doc:	GMParseStyle

Abstract:
	The GMParseStyle function parses a text style name token.

Return Values:
	Text style type matching style name  (Listed in FI.h)
	UNDEFINED_DATA  (Undefined style name)

******************************************************************************/
/* char	*token;    ** i - Text style name to interpret  */

int	GMParseStyle (char *token)
{
int	i, len, styleIdx;
char	style[PARSE_BUF_LEN];

static	char	*styleList[]={
		"normal",	"embossed",	"incised",	"shadowed"
		};

	len = strlen( token );
	for ( i = 0; i < len; i++ )
		style[i] = tolower( token[i] );
	style[i] = NULLCHAR;

	for ( styleIdx = 0; styleIdx < 4; styleIdx++ )
	{
		if ( strcmp( style, styleList[styleIdx] ) == 0 )
			return( styleIdx );
	}

	return( UNDEFINED_DATA );
}

/******************************************************************************

Doc:	GMParseJust

Abstract:
	The GMParseJust function parses a justification name token.

Return Values:
	Justification type matching justification name  (Listed in FI.h)
	UNDEFINED_DATA  (Undefined justification name)

******************************************************************************/
/* char *token;   ** i - Justfication name to interpret  */

int	GMParseJust (char *token)
{
int	i, len, justIdx;
char	just[PARSE_BUF_LEN];

static	char	*justList[]={
		"left",		"right",	"center"
		};

	len = strlen( token );
	for ( i = 0; i < len; i++ )
		just[i] = tolower( token[i] );
	just[i] = NULLCHAR;

	for ( justIdx = 0; justIdx < 3; justIdx++ )
	{
		if ( strcmp( just, justList[justIdx] ) == 0 )
			return( justIdx );
	}

	return( UNDEFINED_DATA );
}

/******************************************************************************

Doc:	GMParseLevel

Abstract:
	The GMParseLevel function counts the number of tabs preceeding
	the first non-white space character to determine the line "level".

Return Values:
	"level" of the line

******************************************************************************/
/* char	*line;   ** i - Data buffer for line  */

int	GMParseLevel (char *line)

{
int	i, level;

	for ( i = 0, level = 0; isspace( line[i] ); i++ )
	{
		if ( line[i] == TAB )
			level++;
	}

	return( level );
}
