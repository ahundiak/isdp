#include <sys/types.h>
#include <string.h>
#include <malloc.h>
#include <stdio.h>
#include "MI.h"
#include "GMoutline.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

extern	double	atof();

/**********************************************************************

Doc:	GMGetLineData

Abstract:
	The GMGetLineData function reads and parses the next line from
	the outline and returns the data.

Return Status:

  GM_S_SUCCESS	-  Success
  GM_I_EOF	-  Reached the end-of-file
  GM_W_TRUNCATE	-  Truncated palette file/symbol file/font name(s)
  GM_W_PARSE	-  Parsing warning(s)
  GM_E_PARSE	-  Parsing error(s)
  GM_F_ALLOC	-  Error allocating memory

**********************************************************************/
/*  int			*level;		** o - Line "level"	     */
/*  struct GMLineData	**lineData;	** o - Line data	     */
/*  struct GMHdrData	*hdrData;	** i - Outline header data   */
/*  struct GMParseFp	*fp;		** i - File info for parsing */

int GMGetLineData (int                 *level,
                   struct GMLineData   **lineData,
                   struct GMHdrData    *hdrData,
                   struct GMParseFp    *fp)
{
  static int	inComment={TRUE};
  int		inc, sts, retsts;
  char		*linePtr, line[PARSE_BUF_LEN], token[PARSE_BUF_LEN];


  if ( GMGetLine( fp, line, PARSE_BUF_LEN ) == EOF )
    {
      return ( GM_I_EOF );
    }

  *level = GMParseLevel( line );
  if ( *level == 0 )
    {
      if ( inComment )
	{
	  return( GM_S_SUCCESS );
	}
      else
	{
	  fprintf( fp->err,
	   "Line %d  Warning--Invalid location for comment/line without tabs\n",
	   fp->line );
	  return( GM_W_PARSE );
	}
    }

  inComment = FALSE;

  if ( hdrData->menuType == PANEL_MENU && *level > MAX_LEVELS	||
       hdrData->menuType != PANEL_MENU && *level > 1		 )
    {
	fprintf( fp->err,
		 "Line %d  Invalid button level/tab count : %d\n",
		 fp->line, *level );
	return( GM_E_PARSE );
    }

  sts = GMInitLineData( lineData );
  if ( sts == GM_F_ALLOC )
    {
	return( sts );
    }

  retsts = GM_S_SUCCESS;

  linePtr = line;
  inc = GMParseToken( token, linePtr );
  sts = GMParseLineToken1( *lineData, token, fp );
  if ( sts == GM_F_ALLOC )
    {
	goto alloc_fail;
    }
  else if ( sts > retsts )
    {
	retsts = sts;
    }

  linePtr += inc;
  inc = GMParseToken( token, linePtr );
  sts = GMParseLineToken2( *lineData, hdrData, token, fp );
  if ( sts == GM_F_ALLOC )
    {
	goto alloc_fail;
    }
  else if ( sts > retsts )
    {
	retsts = sts;
    }

  linePtr += inc;
  inc = GMParseToken( token, linePtr );
  sts = GMParseLineToken3( *lineData, hdrData, token, fp );
  if ( sts == GM_F_ALLOC )
    {
	goto alloc_fail;
    }
  else if ( sts > retsts )
    {
	retsts = sts;
    }

  linePtr += inc;
  inc = GMParseToken( token, linePtr );
  sts = GMParseLineToken4( *lineData, hdrData, token, fp );
  if ( sts > retsts )
    {
	retsts = sts;
    }

  linePtr += inc;
  while ( ( inc = GMParseToken( token, linePtr ) ) > 0 )
    {
      sts = GMParseLineOption( *lineData, token );
      if ( sts == GM_F_ALLOC )
	{
	  goto alloc_fail;
	}
      else if ( sts == GM_W_PARSE )
	{
	  fprintf( fp->err, "Line %d  Warning--Invalid option : %s\n",
		 fp->line, token );
	  if ( sts > retsts )
	    {
	      retsts = sts;
	    }
	}
      linePtr += inc;
    }

  if ( GM_ERROR( retsts ) )
    {
	GMFreeLineData( *lineData, hdrData );
    }

  return( retsts );

alloc_fail:

  GMFreeLineData( *lineData, hdrData );
  return( GM_F_ALLOC );
}

/**********************************************************************

Doc:	GMInitLineData

Abstract:
	The GMInitLineData function allocates and then initializes the
	line data with "undefined" defaults.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_F_ALLOC	-	Error allocating memory

**********************************************************************/
/*  struct GMLineData	**lineData;	** o - Line data	*/
  
int GMInitLineData (struct GMLineData   **lineData)
{
  int	ii;

  *lineData = (struct GMLineData *)
			malloc ( sizeof( struct GMLineData ) );

  if ( ! ( *lineData ) )
    {
	return( GM_F_ALLOC );
    }

  ( *lineData )->nameType = UNDEFINED_DATA;
  ( *lineData )->name = ( char * )0;

  ( *lineData )->numBtn = UNDEFINED_DATA;

  ( *lineData )->numColumn = UNDEFINED_DATA;
  ( *lineData )->numRow = UNDEFINED_DATA;
  ( *lineData )->btnHeight = UNDEFINED_DATA;
  ( *lineData )->btnWidth = UNDEFINED_DATA;

  ( *lineData )->remember = UNDEFINED_DATA;

  ( *lineData )->cmdType = UNDEFINED_DATA;
  ( *lineData )->cmdString = ( char * )0;

  ( *lineData )->grafixType = UNDEFINED_DATA;

  ( *lineData )->symFile = ( char * )0;

  for ( ii = 0; ii < NUM_SYMBOLS; ii++ )
    {
	( *lineData )->symbol[ii] = UNDEFINED_DATA;
    }

  ( *lineData )->textString = ( char * )0;
  ( *lineData )->fontName = ( char * )0;
  ( *lineData )->bodySize = 0.0;
  ( *lineData )->textStyle = UNDEFINED_DATA;
  ( *lineData )->textJust = UNDEFINED_DATA;

  for ( ii = 0; ii < NUM_COLORS; ii++ )
    {
	( *lineData )->color[ii] = UNDEFINED_DATA;
    }

  ( *lineData )->helpTopic = ( char * )0;

  return ( GM_S_SUCCESS );
}

/**********************************************************************

Doc:	GMParseLineToken1

Abstract:
	The GMParseLineToken1 function parses the first token from the
	line into the button "name" and name type.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated palette file name
	GM_E_PARSE	-	Parsing error
	GM_F_ALLOC	-	Error allocating memory

**********************************************************************/
/*  struct GMLineData  *lineData;	** i/o - Line data	     */
/*  char               *token;		** i - First token from line */
/*  struct GMParseFp   *fp;		** i - File info for parsing */


int  GMParseLineToken1 (struct GMLineData  *lineData,
                        char               *token,
                        struct GMParseFp   *fp)
{
  int	len;

  if ( token[0] == ASTERISK )
    {
	lineData->nameType = STARRED_STRING;
	token++;
    }
  else if ( token[0] == DQUOTE )
    {
      lineData->nameType = QUOTED_STRING;
      token++;
      len = strlen( token ) - 1;
      if ( token[len] == DQUOTE )
	{
	  token[len] = (char) NULL;
	}
    }
  else
    {
	lineData->nameType = PLAIN_STRING;
    }

  len = strlen( token );
  if ( len == 0 )
    {
      fprintf( fp->err, "Line %d, field 1  Undefined button name\n",
	 fp->line );
      return( GM_E_PARSE );
    }

  lineData->name = malloc( len + 1 );
  if ( lineData->name )
    {
      strcpy( lineData->name, token );
      if ( len > 14 && lineData->nameType == STARRED_STRING )
	{
	  lineData->name[14] = NULLCHAR;
	  fprintf( fp->err,
	    "Line %d, field 1  Warning--Truncated palette file to %s\n",
		fp->line, lineData->name );
	  return( GM_W_TRUNCATE );
	}
    }
  else
    {
	return( GM_F_ALLOC );
    }

  return( GM_S_SUCCESS );
}

/**********************************************************************

Doc:	GMParseLineToken2

Abstract:
	The GMParseLineToken2 function parses the second token from
	the line into a symbol file name or a text string (and thus
	the type of graphics on the button).

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated symbol file name
	GM_W_PARSE	-	Parsing warning
	GM_E_PARSE	-	Parsing error
	GM_F_ALLOC	-	Error allocating memory

**********************************************************************/
/*  struct GMLineData  *lineData;	** i/o - Line data	      */
/*  struct GMHdrData  *hdrData;         ** i - Outline header data    */
/*  char	      *token;		** i - Second token from line */
/*  struct GMParseFp  *fp;		** i - File info for parsing  */

int	GMParseLineToken2 (struct GMLineData  *lineData,
                           struct GMHdrData  *hdrData,
                           char              *token,
                           struct GMParseFp  *fp)
{
  int	len;

  if ( token[0] != DQUOTE )
    {
      lineData->grafixType = SYM_GRAFIX;

      len = strlen( token );
      if ( len != 0 )
	{
	  lineData->symFile = malloc( len + 1 );
	  if ( lineData->symFile )
	    {
	      strcpy( lineData->symFile, token );
	      if ( len > 14 )
		{
		  lineData->symFile[14] = NULLCHAR;
		  fprintf( fp->err,
		     "Line %d, field 2  Warning--Truncated symbol file to %s\n",
		     fp->line, lineData->symFile );
		  return( GM_W_TRUNCATE );
		}
	    }
	  else
	    {
	      return( GM_F_ALLOC );
	    }
	}
      else if ( hdrData->symFile )
	{
			lineData->symFile = hdrData->symFile;
	}
      else
	{
	  fprintf( fp->err, "Line %d, field 2  Undefined symbol file\n",
		 fp->line );
	  return( GM_E_PARSE );			
	}
    }
  else
    {
      lineData->grafixType = TEXT_GRAFIX;

      token++;
      len = strlen( token ) - 1;
      if ( token[len] == DQUOTE )
	{
	  token[len] = (char) NULL;
	}

      GMParseNewLines( token );

      len = strlen( token );
      lineData->textString = malloc( len + 1 );
      if ( lineData->textString )
	{
	  strcpy( lineData->textString, token );
	}
      else
	{
	  return( GM_F_ALLOC );
	}

      if ( len == 0 )
	{
	  fprintf( fp->err,
		 "Line %d, field 2  Warning--Empty text string\n",
		 fp->line );
	  return( GM_W_PARSE );
	}
    }

  return( GM_S_SUCCESS );
}

/**********************************************************************

Doc:	GMParseNewLines

Abstract:
	The GMParseNewLines function replaces the characters `\' and `n'
	with the `\n' character in the text string.

Return Status:
	GM_S_SUCCESS	-	Success

**********************************************************************/
/*  char	*textString;	** i/o - Text string token	*/

int GMParseNewLines (char        *textString)
{
  int	ii, jj, max;
  char	newString[PARSE_BUF_LEN];

  max = strlen( textString ) - 1;
  for ( ii = 0, jj = 0; ii < max; ii++, jj++ )
    {
      if ( textString[ii] == BACKSLASH && textString [ ii + 1 ] == 'n' )
	{
	  newString[jj] = EOL;
	  ii++;
	}
      else
	{
	  newString[jj] = textString[ii];
	}
    }

  if ( ii == max )
    {
      newString[jj++] = textString[max];
    }

  newString[jj] = NULLCHAR;

  strcpy( textString, newString );
  return( GM_S_SUCCESS );
}

/**********************************************************************

Doc:	GMParseLineToken3

Abstract:
	Based on the type of graphics, the GMParseLineToken3 function
	parses the third token from the line into the first symbol
	index or the text font.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated font name
	GM_E_PARSE	-	Parsing error
	GM_F_ALLOC	-	Error allocating memory

**********************************************************************/
/*  struct GMLineData *lineData;	** i/o - Line data	     */
/*  struct GMHdrData  *hdrData;         ** i - Outline header data   */
/*  char	      *token;		** i - Third token from line */
/*  struct GMParseFp  *fp;		** i - File info for parsing */

int GMParseLineToken3 (struct GMLineData *lineData,
                       struct GMHdrData  *hdrData,
                       char              *token,
                       struct GMParseFp  *fp)
{
  int	symIdx, len;

  if ( lineData->grafixType == SYM_GRAFIX )
    {
      if ( strlen( token ) == 0 )
	{
	  fprintf( fp->err,
		 "Line %d, field 3  Undefined symbol index\n",
		 fp->line );
	  return( GM_E_PARSE );
	}

      symIdx = atoi( token );
      if ( symIdx < 0 || symIdx > 255 )
	{
	  fprintf( fp->err,
		 "Line %d, field 3  Invalid symbol index : %d\n",
		 fp->line, symIdx );
	  return( GM_E_PARSE );
	}
      lineData->symbol[0] = symIdx;
    }
  else
    {
      len = strlen( token );
      if ( len != 0 )
	{
	  lineData->fontName = malloc( len + 1 );
	  if ( lineData->fontName )
	    {
	      strcpy( lineData->fontName, token );
	      if ( len > 14 )
		{
		  lineData->fontName[14] = NULLCHAR;
		  fprintf( fp->err,
		     "Line %d, field 3  Warning--Truncated font name to %s\n",
			 fp->line, lineData->fontName );
		  return( GM_W_TRUNCATE );
		}
	    }
	  else
	    {
	      return( GM_F_ALLOC );
	    }
	}
      else if ( hdrData->fontName )
	{
	  lineData->fontName = hdrData->fontName;
	}
      else
	{
	  fprintf ( fp->err, "Line %d, field 3  Undefined text font\n",
		 fp->line );
	  return( GM_E_PARSE );
	}
    }

  return( GM_S_SUCCESS );
}

/**********************************************************************

Doc:	GMParseLineToken4

Abstract:
	Based on the type of graphics, the GMParseLineToken4 function
	parses the fourth token from the line into the second symbol
	index or the text bodysize.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_E_PARSE	-	Parsing error

**********************************************************************/
/*  struct GMLineData  *lineData;	** i/o - Line data	      */
/*  struct GMHdrData  *hdrData;         ** i - Outline header data    */
/*  char	      *token;		** i - Fourth token from line */
/*  struct GMParseFp  *fp;		** i - File info for parsing  */

int GMParseLineToken4 (struct GMLineData  *lineData,
                       struct GMHdrData  *hdrData,
                       char              *token,
                       struct GMParseFp  *fp)
{
  int	symIdx, bodySize;

  if ( lineData->grafixType == SYM_GRAFIX )
    {
		if ( strlen( token ) == 0 )
		{
			fprintf( fp->err,
				 "Line %d, field 4  Undefined symbol index\n",
				 fp->line );
			return( GM_E_PARSE );
		}

		symIdx = atoi( token );
		if ( symIdx < -1 || symIdx == 0 || symIdx > 255 )
		{
			fprintf( fp->err,
				 "Line %d, field 4  Invalid symbol index : %d\n",
				 fp->line, symIdx );
			return( GM_E_PARSE );
		}
		lineData->symbol[1] = ( symIdx == -1 ) ? 0 : symIdx;
    }
  else
    {
      if ( strlen( token ) == 0 )
	{
	  if ( hdrData->bodySize <= 0.0 )
	    {
	      fprintf( fp->err,
		 "Line %d, field 4  Undefined text size\n",
		 fp->line );
	      return( GM_E_PARSE );
	    }

	  lineData->bodySize = hdrData->bodySize;
	}
      else
	{
	  bodySize = atoi( token );
	  if ( bodySize <= 0 )
	    {
	      fprintf( fp->err,
		 "Line %d, field 4  Invalid text size : %d\n",
		 fp->line, bodySize );
	      return( GM_E_PARSE );
	    }

	  lineData->bodySize = ( float )bodySize;
	}
    }

  return( GM_S_SUCCESS );
}

/**********************************************************************

Doc:	GMParseLineOption

Abstract:
	The GMParseLineOption function parses an option token and
	writes the result in the line data structure.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_PARSE	-	Parsing warning
	GM_F_ALLOC	-	Error allocating memory

**********************************************************************/
/*  struct GMLineData	*lineData;	** i/o - Line data	*/
/*  char		*token;		** i - Option token	*/

int GMParseLineOption (struct GMLineData   *lineData,
                       char                *token)

{
  union	GMTokenData	data;
  int			sts, len, option;
  char			*aptr;

  option = GMParseKeyword( &data, token );
  sts = GM_S_SUCCESS;
  switch ( option )
    {
      case KEY_NUM:
	if ( data.ival <= 0 )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->numColumn = data.ival;
	  }
	break;

      case KEY_HT:
	if ( data.ival <= 0 )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->btnHeight = data.ival;
	  }
	break;

      case KEY_WD:
	if ( data.ival <= 0 )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->btnWidth = data.ival;
	  }
	break;

      case KEY_REM:
	if ( data.ival == UNDEFINED_DATA )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->remember = data.ival;
	  }
	break;

      case KEY_CMD:
	if ( data.aval[0] == DQUOTE )
	  {
	    lineData->cmdType = QUOTED_STRING;
	    aptr = &data.aval[1];
	    len = strlen( aptr ) - 1;
	    if ( aptr[len] == DQUOTE );
	      {
		aptr[len] = (char) NULL;
	      }
	  }
	else
	  {
	    lineData->cmdType = PLAIN_STRING;
	    aptr = data.aval;
	  }

	len = strlen( aptr );
	if ( len == 0 )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->cmdString = malloc( len + 1 );
	    if ( lineData->cmdString )
	      {
		strcpy( lineData->cmdString, aptr );
	      }
	    else
	      {
		sts = GM_F_ALLOC;
	      }
	  }
	break;

      case KEY_STYLE:
	if ( data.ival == UNDEFINED_DATA )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->textStyle = data.ival;
	  }
	break;

      case KEY_JUST:
	if ( data.ival == UNDEFINED_DATA )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->textJust = data.ival;
	  }
	break;

      case KEY_OFF:
      case KEY_ON:
      case KEY_OFF2:
      case KEY_ON2:
	if ( data.ival == UNDEFINED_DATA )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->color[option - KEY_OFF] = data.ival;
	  }
	break;

      case KEY_HELP:
	if ( data.aval[0] == DQUOTE )
	  {
	    aptr = &data.aval[1];
	    len = strlen( aptr ) - 1;
	    if ( aptr[len] == DQUOTE )
	      {
		aptr[len] = (char) NULL;
	      }
	  }
	else
	  {
	    aptr = data.aval;
	  }

	len = strlen( aptr );
	if ( len == 0 )
	  {
	    sts = GM_W_PARSE;
	  }
	else
	  {
	    lineData->helpTopic = malloc( len + 1 );
	    if ( lineData->helpTopic )
	      {
		strcpy( lineData->helpTopic, aptr );
	      }
	    else
	      {
		sts = GM_F_ALLOC;
	      }
	  }
	break;

      default:
	sts = GM_W_PARSE;
	break;
    }

  return( sts );
}

/**********************************************************************

Doc:	GMFreeLineData

Abstract:
	The GMFreeLineData function frees the space allocated for a line
	data structure.

Return Status:
	GM_S_SUCCESS	-	Success

**********************************************************************/
/*  struct GMLineData	*lineData;	** i - Line data	   */
/*  struct GMHdrData	*hdrData;	** i - Outline header data */

int GMFreeLineData (struct GMLineData   *lineData,
                    struct GMHdrData    *hdrData)
{
  if ( lineData->name )
    {
      free ( lineData->name );
    }

  if ( lineData->cmdString )
    {
      free ( lineData->cmdString );
    }

  if ( lineData->symFile && lineData->symFile != hdrData->symFile )
    {
      free ( lineData->symFile );
    }

  if ( lineData->textString )
    {
      free ( lineData->textString );
    }

  if ( lineData->fontName && lineData->fontName != hdrData->fontName )
    {
      free ( lineData->fontName );
    }

  if ( lineData->helpTopic )
    {
      free ( lineData->helpTopic );
    }

  free ( lineData );

  return ( GM_S_SUCCESS );
}
