#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <malloc.h>
/* #include <tools.h> */
#include "FI.h"
#include "MI.h"
#include "GMoutline.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

/******************************************************************************

Doc:	GMGetHdrData

Abstract:
	The GMGetHdrData function reads and parses the first line of
	the outline and returns the data.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated symbol file/font name(s)
	GM_W_PARSE	-	Parsing warning
	GM_F_PARSE	-	Fatal parsing error
	GM_F_OUTLINE	-	Empty outline file
	GM_F_ALLOC	-	Error allocating memory

******************************************************************************/
/* struct    GMHdrData	*hdrData;	** o - Outine header data	*/
/* struct    GMParseFp	*fp;		** i - File info for parsing	*/


int	GMGetHdrData( struct    GMHdrData  *hdrData,
                      struct    GMParseFp  *fp)
{
int	inc, sts, retsts;
char	*linePtr, line[PARSE_BUF_LEN], token[PARSE_BUF_LEN];

	sts = GMInitHdrData( hdrData );

	if ( GMGetLine( fp, line, PARSE_BUF_LEN ) == EOF )
	{
		fprintf( fp->err,
			 "Empty outline file\n" );
		return( GM_F_OUTLINE );
	}

	linePtr = line;
	inc = GMParseToken( token, linePtr );
	hdrData->menuType = GMParseMenuType( token );
	if ( hdrData->menuType == UNDEFINED_DATA )
	{
		fprintf( fp->err,
			 "Line %d  Invalid menu type : %s\n",
			 fp->line, token );
		return( GM_F_PARSE );
	}

	linePtr += inc;
	inc = GMParseToken( token, linePtr );
	if ( ! GMParseVersion( token ) )
	{
		fprintf( fp->err,
			 "Line %d  Invalid outline format : %s\n",
			 fp->line, token );
		return( GM_F_PARSE );
	}

	retsts = GM_S_SUCCESS;

	linePtr += inc;
	while ( ( inc = GMParseToken( token, linePtr ) ) > 0 )
	{
		sts = GMParseMenuOption( hdrData, token, fp );
		if ( sts == GM_F_ALLOC )
		{
			fprintf( fp->err,
				 "Line %d  Error allocating memory\n",
				 fp->line );
			return( sts );
		}
		else if ( sts == GM_W_PARSE )
		{
			fprintf( fp->err,
				 "Line %d  Warning--Invalid menu option : %s\n",
				 fp->line, token );
			retsts = sts;
		}
		else if ( sts > retsts )
			retsts = sts;

		linePtr += inc;
	}

	sts = GMFinishHdrData( hdrData );

	return( retsts );
}

/******************************************************************************

Doc:	GMInitHdrData

Abstract:
	The GMInitHdrData function initializes the outline header data
	with "undefined" values.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* struct    GMHdrData	*hdrData;	** o - Outline header data	*/


int	GMInitHdrData (struct GMHdrData *hdrData)
{
int	i;

	hdrData->menuType = UNDEFINED_DATA;

	hdrData->xOrg = UNDEFINED_DATA;
	hdrData->yOrg = UNDEFINED_DATA;

	for ( i = 0; i < MAX_LEVELS; i++ )
	{
		hdrData->level[i].numColumn = UNDEFINED_DATA;
		hdrData->level[i].numRow = UNDEFINED_DATA;
		hdrData->level[i].btnHeight = UNDEFINED_DATA;
		hdrData->level[i].btnWidth = UNDEFINED_DATA;
	}

	hdrData->remember = UNDEFINED_DATA;

	hdrData->symFile = ( char * )0;

	hdrData->fontName = ( char * )0;
	hdrData->bodySize = 0.0;
	hdrData->textStyle = UNDEFINED_DATA;
	hdrData->textJust = UNDEFINED_DATA;

	for ( i = 0; i < NUM_COLORS; i++ )
		hdrData->color[i] = UNDEFINED_DATA;

	return( GM_S_SUCCESS );
}

/******************************************************************************

Doc:	GMParseMenuType

Abstract:
	The GMParseMenuType function parses the menu type token.

Return Values:
	Menu type  (Listed in MI.h)
	UNDEFINED_DATA  (Undefined menu type)

******************************************************************************/
/* char	*token;			** i - Menu type token			*/


int	GMParseMenuType (char * token)
{
int		menuType;
static	char	*typeNames[]={ "BAR", "PANEL", "POCKET" };

	for ( menuType = 0; menuType < MAX_MENU_TYPES; menuType++ )
	{
		if ( strcmp( token, typeNames[menuType] ) == 0 )
			return( menuType );
	}

	return( UNDEFINED_DATA );
}

/******************************************************************************

Doc:	GMParseVersion

Abstract:
	The GMParseVersion function parses the outline version token.

Return Values:
	TRUE	-	Valid outline version
	FALSE	-	Invalid outline version

******************************************************************************/
/* char	*token;		** i - Outline version token		*/

int	GMParseVersion (char *token)
{
	if ( strcmp( token, "1.3" ) == 0 )
		return( TRUE );
	else if ( strcmp( token, "1.2" ) == 0 )
		return( TRUE );
	else
		return( FALSE );
}

/******************************************************************************

Doc:	GMParseMenuOption

Abstract:
	The GMParseMenuOption function parses a menu option token and
	writes the result in the outline header data.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated symbol file/font name(s)
	GM_W_PARSE	-	Invalid menu option
	GM_F_ALLOC	-	Error allocating memory

******************************************************************************/
/* struct    GMHdrData	*hdrData;	** i/o - Outline header data	*/
/* char	                *token;		** i - Menu option token	*/
/* struct    GMParseFp	*fp;		** i - File info for parsing	*/

int	GMParseMenuOption (struct    GMHdrData  *hdrData,
                           char                 *token,
                           struct    GMParseFp  *fp)
{
union	GMTokenData	data;
int			sts, option, len;

	option = GMParseKeyword( &data, token );
	sts = GM_S_SUCCESS;
	switch ( option )
	{
	case KEY_X:
		if ( data.ival < 0 )
			sts = GM_W_PARSE;
		else
			hdrData->xOrg = data.ival;
		break;
	case KEY_Y:
		if ( data.ival < 0 )
			sts = GM_W_PARSE;
		else
			hdrData->yOrg = data.ival;
		break;
	case KEY_NUM:		case KEY_NUM2:
	case KEY_NUM3:		case KEY_NUM4:
		if ( data.ival <= 0 )
			sts = GM_W_PARSE;
		else
			hdrData->level[option - KEY_NUM].numColumn = data.ival;
		break;
	case KEY_HT:		case KEY_HT2:
	case KEY_HT3:		case KEY_HT4:
		if ( data.ival <= 0 )
			sts = GM_W_PARSE;
		else
			hdrData->level[option - KEY_HT].btnHeight = data.ival;
		break;
	case KEY_WD:		case KEY_WD2:
	case KEY_WD3:		case KEY_WD4:
		if ( data.ival <= 0 )
			sts = GM_W_PARSE;
		else
			hdrData->level[option - KEY_WD].btnWidth = data.ival;
		break;
	case KEY_REM:
		if ( data.ival == UNDEFINED_DATA )
			sts = GM_W_PARSE;
		else
			hdrData->remember = data.ival;
		break;
	case KEY_SYM:
		len = strlen( data.aval );
		if ( len == 0 )
			sts = GM_W_PARSE;
		else
		{
			hdrData->symFile = malloc( len + 1 );
			if ( hdrData->symFile )
			{
				strcpy( hdrData->symFile, data.aval );
				if ( len > 14 )
				{
					hdrData->symFile[14] = NULLCHAR;
					fprintf( fp->err,
						 "Line %d  Warning--Truncated symbol file to %s\n",
						 fp->line, hdrData->symFile );
					sts = GM_W_TRUNCATE;
				}
			}
			else
				sts = GM_F_ALLOC;
		}
		break;
	case KEY_FONT:
		len = strlen( data.aval );
		if ( len == 0 )
			sts = GM_W_PARSE;
		else
		{
			hdrData->fontName = malloc( len + 1 );
			if ( hdrData->fontName )
			{
				strcpy( hdrData->fontName, data.aval );
				if ( len > 14 )
				{
					hdrData->fontName[14] = NULLCHAR;
					fprintf( fp->err,
						 "Line %d  Warning--Truncated font name to %s\n",
						 fp->line, hdrData->fontName );
					sts = GM_W_TRUNCATE;
				}
			}
			else
				sts = GM_F_ALLOC;
		}
		break;
	case KEY_SIZE:
		if ( data.ival <= 0 )
			sts = GM_W_PARSE;
		else
			hdrData->bodySize = ( float )data.ival;
		break;
	case KEY_STYLE:
		if ( data.ival == UNDEFINED_DATA )
			sts = GM_W_PARSE;
		else
			hdrData->textStyle = data.ival;
		break;
	case KEY_JUST:
		if ( data.ival == UNDEFINED_DATA )
			sts = GM_W_PARSE;
		else
			hdrData->textJust = data.ival;
		break;
	case KEY_OFF:		case KEY_ON:
	case KEY_OFF2:		case KEY_ON2:
		if ( data.ival == UNDEFINED_DATA )
			sts = GM_W_PARSE;
		else
			hdrData->color[option - KEY_OFF] = data.ival;
		break;
	default:
		sts = GM_W_PARSE;
		break;
	}

	return( sts );
}

/******************************************************************************

Doc:	GMFinishHdrData

Abstract:
	The GMFinishHdrData function finishes out the header data by
	loading system defaults for any undefined values.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* struct    GMHdrData	*hdrData;  ** i/o - Outline header data	*/

int	GMFinishHdrData (struct    GMHdrData  *hdrData)
{
static	int	panNumColumn[MAX_LEVELS]={
					PANEL_NUM_COLUMN1,
					PANEL_NUM_COLUMN2,
					PANEL_NUM_COLUMN3,
					PANEL_NUM_COLUMN4
					 },
		panBtnWidth[MAX_LEVELS]={
					PANEL_BTN_WIDTH1,
					PANEL_BTN_WIDTH2,
					PANEL_BTN_WIDTH3,
					PANEL_BTN_WIDTH4
					},
		panBtnHeight[MAX_LEVELS]={
					PANEL_BTN_HEIGHT1,
					PANEL_BTN_HEIGHT2,
					PANEL_BTN_HEIGHT3,
					PANEL_BTN_HEIGHT4
					 };
int	lev;

	switch ( hdrData->menuType )
	{
	case PANEL_MENU:
		if ( hdrData->xOrg < 0 )
			hdrData->xOrg = PANEL_XORG;
		if ( hdrData->yOrg < 0 )
			hdrData->yOrg = PANEL_YORG;

		for ( lev = 0; lev < MAX_LEVELS; lev++ )
		{
			if ( hdrData->level[lev].numColumn > 0 )
				hdrData->level[lev].btnWidth =
					PANEL_PAL_WIDTH / hdrData->level[lev].numColumn;
			else if ( hdrData->level[lev].btnWidth > 0 &&
				  hdrData->level[lev].btnWidth <= PANEL_PAL_WIDTH )
				hdrData->level[lev].numColumn =
					PANEL_PAL_WIDTH / hdrData->level[lev].btnWidth;
			else
			{
				hdrData->level[lev].numColumn = panNumColumn[lev];
				hdrData->level[lev].btnWidth = panBtnWidth[lev];
			}

			if ( hdrData->level[lev].btnHeight <= 0 )
				hdrData->level[lev].btnHeight = panBtnHeight[lev];

			hdrData->level[lev].numRow = 0;
		}
		break;
	case BAR_MENU:
		if ( hdrData->xOrg < 0 )
			hdrData->xOrg = BAR_XORG;
		if ( hdrData->yOrg < 0 )
			hdrData->yOrg = BAR_YORG;

		if ( hdrData->level[0].numColumn <= 0 )
		{
			hdrData->level[0].numColumn = 0;
			hdrData->level[0].numRow = 1;
		}
		else
			hdrData->level[0].numRow = 0;

		if ( hdrData->level[0].btnWidth <= 0 )
			hdrData->level[0].btnWidth = BAR_BTN_WIDTH;
		if ( hdrData->level[0].btnHeight <= 0 )
			hdrData->level[0].btnHeight = BAR_BTN_HEIGHT;
		break;
	case POCKET_MENU:
		if ( hdrData->xOrg < 0 )
			hdrData->xOrg = POCKET_XORG;
		if ( hdrData->yOrg < 0 )
			hdrData->yOrg = POCKET_YORG;

		if ( hdrData->level[0].numColumn <= 0 )
			hdrData->level[0].numColumn = POCKET_NUM_COLUMN;
		hdrData->level[0].numRow = 0;

		if ( hdrData->level[0].btnWidth <= 0 )
			hdrData->level[0].btnWidth = POCKET_BTN_WIDTH;
		if ( hdrData->level[0].btnHeight <= 0 )
			hdrData->level[0].btnHeight = POCKET_BTN_HEIGHT;
		break;
	}

	if ( hdrData->remember == UNDEFINED_DATA )
		hdrData->remember = 1;

	if ( hdrData->textStyle == UNDEFINED_DATA )
		hdrData->textStyle = FI_NORMAL_TEXT;
	if ( hdrData->textJust == UNDEFINED_DATA )
		hdrData->textJust = FI_CENTER_JUSTIFIED;

	if ( hdrData->color[OFF_COLOR1] == UNDEFINED_DATA )
		hdrData->color[OFF_COLOR1] = FI_BLACK;
	if ( hdrData->color[ON_COLOR1] == UNDEFINED_DATA )
		hdrData->color[ON_COLOR1] = FI_YELLOW;
	if ( hdrData->color[OFF_COLOR2] == UNDEFINED_DATA )
		hdrData->color[OFF_COLOR2] = FI_BLACK;
	if ( hdrData->color[ON_COLOR2] == UNDEFINED_DATA )
		hdrData->color[ON_COLOR2] = FI_YELLOW;

	return( GM_S_SUCCESS );
}

/******************************************************************************

Doc:	GMFreeHdrData

Abstract:
	The GMFreeHdrData function frees the space allocated in the
	outline header data.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* struct    GMHdrData	*hdrData;  ** i - Outline header data	*/

int	GMFreeHdrData (struct    GMHdrData  *hdrData)

{
	if ( hdrData->symFile )
		free( hdrData->symFile );
	if ( hdrData->fontName )
		free( hdrData->fontName );

	return( GM_S_SUCCESS );
}
