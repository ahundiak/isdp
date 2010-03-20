#include <sys/types.h>
#include <string.h>
#include <malloc.h>
#include <stdio.h>
/* #include <tools.h> */
#include "FI.h"
#include "FIdyn.h"
#include "MI.h"
#include "GMmenu.h"
#include "GMoutline.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

extern int panelPalHeight;	/* command line-specified panel height */
extern int panelPalWidth;	/* command line-specified panel width */

/******************************************************************************

Doc:	GMGetMenuData

Abstract:
	The GMGetMenuData function gets the menu data by reading and
	parsing the opened outline file.

Notes:
	GMGetMenuData does not fill in the name of the first palette.
	(It is not defined in the outline.)
	
Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated palette file/symbol file/font name(s)
	GM_W_PARSE	-	Parsing warning(s)
	GM_E_PARSE	-	Parsing error(s)
	GM_F_PARSE	-	Fatal parsing error(s)
	GM_F_OUTLINE	-	Empty outline file
				No valid buttons
	GM_F_ALLOC	-	Error allocating memory

******************************************************************************/
/* int	             *menuType;	    ** o - Menu type  (See MI.h)	*/
/* struct GMPalette  **palList;     ** o - Pointer to linked list of    */
/*                                          menu palettes               */
/* char	             *palPrefix;    ** i - Prefix for palette names	*/
/* FILE	             *otlFp;	    ** i - Opened outline file	*/
/* FILE	             *errFp;	    ** i - Opened "stderr" file	*/

int	GMGetMenuData (int               *menuType,
                       struct GMPalette  **palList,
                       char              *palPrefix,
                       FILE              *otlFp,
                       FILE              *errFp)
{
struct	GMParseFp	fp;
struct	GMHdrData	hdrData;
struct	GMOtlPalette	*otlPalList;
int			sts, savsts;

	fp.in = otlFp;
	fp.line = 0;
	fp.err = errFp;

	sts = GMGetHdrData( &hdrData, &fp );
	if ( GM_ERROR( sts ) )
		goto end_func;

	savsts = GMGetOtlData( &otlPalList, &hdrData, &fp );
	if ( GM_ERROR( savsts ) )
	{
		sts = savsts;
		goto free_hdr;
	}

	sts = GMGenMenuData( palList, palPrefix, &hdrData, otlPalList );
	if ( sts == GM_F_ALLOC )
	{
		fprintf( fp.err,
			 "Error allocating menu data memory\n" );
		goto free_otl;
	}

	if ( savsts > sts )
		sts = savsts;

	*menuType = hdrData.menuType;
free_otl:
	GMFreeOtlData( FALSE, otlPalList, &hdrData );
free_hdr:
	GMFreeHdrData( &hdrData );
end_func:
	return( sts );
}

/******************************************************************************

Doc:	GMGenMenuData

Abstract:
	The GMGenMenuData generates the menu (a linked list of palettes)
	from the outline header data and the circular, doubly linked list
	of outline palettes.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_F_ALLOC	-	Error allocating memory

******************************************************************************/
/* struct GMPalette	**palList;	** o - Pointer to linked list   */
/* 					       of menu palettes		*/
/* char	                *palPrefix;	** i - Prefix for palette names	*/
/* struct GMHdrData	*hdrData;	** i - Outline header data	*/
/* struct GMOtlPalette	*otlPalList;	** i - Circular, doubly linked  */
/*                                            list of outline palettes  */

int	GMGenMenuData (struct GMPalette     **palList,
                       char                 *palPrefix,
                       struct GMHdrData     *hdrData,
                       struct GMOtlPalette  *otlPalList)
{
extern	struct	GMPalette	*GMGenPalette();
extern	struct	GMButton	*GMGenButton();

struct	GMPalette	*curPal, *prevPal;
struct	GMButton	*curBtn, *prevBtn;
struct	GMOtlPalette	*otlPal;
struct	GMOtlButton	*otlBtn;
int			num, palOrg[MAX_LEVELS][2];

	for ( num = 0; num < MAX_LEVELS; num++ )
	{
		palOrg[num][KEY_X] = hdrData->xOrg;
		palOrg[num][KEY_Y] = hdrData->yOrg;
	}

	otlPal = otlPalList;
	prevPal = *palList = ( struct GMPalette * )0;
	do
	{
		curPal = GMGenPalette( otlPal, palPrefix, palOrg );
		if ( ! curPal )
			goto alloc_fail;
		if ( prevPal )
			prevPal->nextPal = curPal;
		else
			*palList = curPal;

		num = 0;
		otlBtn = otlPal->buttons;
		prevBtn = ( struct GMButton * )0;
		do
		{
			curBtn = GMGenButton( otlPal, num, otlBtn, palPrefix );
			if ( ! curBtn )
				goto alloc_fail;
			if ( prevBtn )
				prevBtn->nextBtn = curBtn;
			else
				curPal->buttons = curBtn;

			num++;
			otlBtn = otlBtn->nextBtn;
			prevBtn = curBtn;

		} while ( otlBtn != otlPal->buttons );

		otlPal = otlPal->nextPal;
		prevPal = curPal;

	} while ( otlPal != otlPalList );

	if ( hdrData->menuType == PANEL_MENU )
	{
		/************************************************/
		/* sml:10-14-94:TR 249406896                    */
		/*  check if command line options for panel's   */
		/*  width and height were specified.            */
		/************************************************/

	  if (panelPalWidth > 0)
	  {
		( *palList )->xSize = 2 * BORDER_WIDTH + panelPalWidth;
	  }
	  else
	  {
		( *palList )->xSize = 2 * BORDER_WIDTH + PANEL_PAL_WIDTH;
	  }

	  if (panelPalHeight > 0)
	  {
		( *palList )->ySize = panelPalHeight;
	  }
	  else
	  {
		( *palList )->ySize = PANEL_PAL_HEIGHT;
	  }
	}

	return( GM_S_SUCCESS );

alloc_fail:
	if ( *palList )
		GMFreeMenuPal( *palList );
 	return( GM_F_ALLOC );
}

/******************************************************************************

Doc:	GMGenPalette

Abstract:
	The GMGenPalette function allocates a palette structure and
	sets the values based on the given outline palette structure,
	palette prefix and calculated palette origins.

Notes:
	GMGenPalette uses calloc() instead of malloc(); therefore, any
	value not explicitly set is 0.

Return Values:
	Pointer to the new palette
	0  (Error allocating memory )

******************************************************************************/
/* struct GMOtlPalette *otlPal;         ** i - Outline palette		*/
/* char		       *palPrefix;      ** i - Prefix for palette name	*/
/* int	               palOrg[][2];     ** i - Palette origin coords	*/

struct	GMPalette	*GMGenPalette (struct GMOtlPalette *otlPal,
                                       char                *palPrefix,
                                       int                 palOrg[][2])
{
struct	GMPalette	*newPal;

	newPal = ( struct GMPalette * )calloc( 1, sizeof( struct GMPalette ) );
	if ( ! newPal )
		return( newPal );

	GMGenPalName( newPal->name, otlPal->data->name, palPrefix );

	newPal->xPos = palOrg[ otlPal->level - 1 ][KEY_X];
	newPal->yPos = palOrg[ otlPal->level - 1 ][KEY_Y];
	newPal->xSize = 2 * BORDER_WIDTH +
			otlPal->data->numColumn * otlPal->data->btnWidth;
	newPal->ySize = 2 * BORDER_WIDTH +
			otlPal->data->numRow * otlPal->data->btnHeight;

	newPal->remember = otlPal->data->remember;

	if ( otlPal->level < MAX_LEVELS )
		palOrg[otlPal->level][KEY_Y] = newPal->yPos + newPal->ySize - 2;

	return( newPal );
}

/******************************************************************************

Doc:	GMGenButton

Abstract:
	The GMGenButton function allocates a button structure and sets
	the values based on the given outline palette structure, button
	counter and outline button structure.

Notes:
	GMGenButton uses calloc() instead of malloc(); therefore, any
	value not explicitly set is 0.

Return Values:
	Pointer to the new button
	0  (Error allocating memory)

******************************************************************************/
/* struct GMOtlPalette *otlPal;     ** i - Outline palette          */
/* int                 numBtn;	    ** i - Palette's button counter */
/* struct GMOtlButton  *otlBtn;     ** i - Outline button           */
/* char                *palPrefix;  ** i - Prefix for child palette */

struct	GMButton	*GMGenButton (struct GMOtlPalette *otlPal,
                                      int                 numBtn,
                                      struct GMOtlButton  *otlBtn,
                                      char                *palPrefix)
{
struct	GMButton	*newBtn;
int			len;

	newBtn = ( struct GMButton * )calloc( 1, sizeof( struct GMButton ) );
	if ( ! newBtn )
		return( newBtn );

	newBtn->std.xlo = BORDER_WIDTH +
		( numBtn % otlPal->data->numColumn ) * otlPal->data->btnWidth;
	newBtn->std.ylo = BORDER_WIDTH +
		( numBtn / otlPal->data->numColumn ) * otlPal->data->btnHeight;
	newBtn->std.xhi = newBtn->std.xlo + otlPal->data->btnWidth - 1;
	newBtn->std.yhi = newBtn->std.ylo + otlPal->data->btnHeight - 1;

	newBtn->std.attr_mask = FI_INITIAL_NOTIFY | FI_NO_COMPLETE_NOTIFY;

	if ( otlBtn->data->grafixType == SYM_GRAFIX )
	{
		len = strlen( otlBtn->data->symFile );
		newBtn->std.fontname = malloc( len + 1 );
		if ( newBtn->std.fontname )
			strcpy( newBtn->std.fontname, otlBtn->data->symFile );
		else
			goto alloc_fail;

		newBtn->std.symbol_index = otlBtn->data->symbol[0];
		newBtn->std.off_color = otlBtn->data->color[OFF_COLOR1];
		newBtn->std.on_color = otlBtn->data->color[ON_COLOR1];

		if ( otlBtn->data->symbol[1] )
		{
			newBtn->std.symbol_index2 = otlBtn->data->symbol[1];
			newBtn->std.off_color2 = otlBtn->data->color[OFF_COLOR2];
			newBtn->std.on_color2 = otlBtn->data->color[ON_COLOR2];
		}
	}
	else
	{
		newBtn->std.attr_mask |= FI_TEXT_GADGET;

		len = strlen( otlBtn->data->textString );
		newBtn->std.text = malloc( len + 1 );
		if ( newBtn->std.text )
			strcpy( newBtn->std.text, otlBtn->data->textString );
		else
			goto alloc_fail;

		len = strlen( otlBtn->data->fontName );
		newBtn->std.fontname = malloc( len + 1 );
		if ( newBtn->std.fontname )
			strcpy( newBtn->std.fontname, otlBtn->data->fontName );
		else
			goto alloc_fail;

		newBtn->std.bodysize = otlBtn->data->bodySize;

		newBtn->textStyle = otlBtn->data->textStyle;
		newBtn->textJust = otlBtn->data->textJust;

		if ( newBtn->textStyle == FI_NORMAL_TEXT ||
		     newBtn->textStyle == FI_SHADOWED )
		{
			newBtn->std.off_color = otlBtn->data->color[OFF_COLOR1];
			newBtn->std.on_color = otlBtn->data->color[ON_COLOR1];
		}
		else if ( newBtn->textStyle == FI_EMBOSSED )
		{
			newBtn->std.off_color = FI_BLACK;
			newBtn->std.on_color = FI_WHITE;
		}
		else
		{
			newBtn->std.off_color = FI_WHITE;
			newBtn->std.on_color = FI_BLACK;
		}
	}

	if ( otlBtn->data->helpTopic )
	{
		newBtn->std.attr_mask |= FI_HELP_TOPIC;

		len = strlen( otlBtn->data->helpTopic );
		newBtn->std.help_topic = malloc( len + 1 );
		if ( newBtn->std.help_topic )
			strcpy( newBtn->std.help_topic, otlBtn->data->helpTopic );
		else
			goto alloc_fail;
	}

	if ( otlBtn->palette || otlBtn->data->nameType == STARRED_STRING )
	{
		if ( otlBtn->palette )
			GMGenPalName( newBtn->palName, otlBtn->data->name, palPrefix );
		else
		{
			strncpy( newBtn->palName, otlBtn->data->name, 14 );
			newBtn->palName[14] = NULLCHAR;
		}

		if ( otlBtn->data->cmdString )
		{
			if ( otlBtn->data->cmdType == PLAIN_STRING )
				newBtn->std.attr_mask |= FI_CMD_KEY;
			else
				newBtn->std.attr_mask |= FI_CMD_STRING;

			len = strlen( otlBtn->data->cmdString );
			newBtn->std.command = malloc( len + 1 );
			if ( newBtn->std.command )
				strcpy( newBtn->std.command, otlBtn->data->cmdString );
			else
				goto alloc_fail;
		}
	}
	else
	{
		if ( otlBtn->data->nameType == PLAIN_STRING )
			newBtn->std.attr_mask |= FI_CMD_KEY;
		else
			newBtn->std.attr_mask |= FI_CMD_STRING;

		len = strlen( otlBtn->data->name );
		newBtn->std.command = malloc( len + 1 );
		if ( newBtn->std.command )
			strcpy( newBtn->std.command, otlBtn->data->name );
		else
			goto alloc_fail;
	}

	return( newBtn );

alloc_fail:
	GMFreeMenuBtn( newBtn );
	return( ( struct GMButton * )0 );
}

/******************************************************************************

Doc:	GMGenPalName

Abstract:
	The GMGenPalName function generates the palette name based on the
	name from the outline and an optional prefix.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* char	*palName;		** o - Generated palette name		*/
/* char	*otlPalName;		** i - Palette name from the outine	*/
/* char	*palPrefix;		** i - Optional prefix for palette name	*/

int	GMGenPalName (char *palName,
                      char *otlPalName,
                      char *palPrefix)
{
int	len, i;

	if ( ! otlPalName )
		return( GM_S_SUCCESS );

	len = strlen( palPrefix );

	for ( i = 0; i < len && i < 14; i++ )
	{
		if ( palPrefix[i] == DOT ||
		     palPrefix[i] >= '0' && palPrefix[i] <= '9' ||
		     palPrefix[i] >= 'A' && palPrefix[i] <= 'Z' ||
		     palPrefix[i] == UNDERBAR ||
		     palPrefix[i] >= 'a' && palPrefix[i] <= 'z' )
			palName[i] = palPrefix[i];
		else
			palName[i] = UNDERBAR;
	}

	for ( i = 0; len < 14 && otlPalName[i] != NULLCHAR; i++, len++ )
	{
		if ( otlPalName[i] == DOT ||
		     otlPalName[i] >= '0' && otlPalName[i] <= '9' ||
		     otlPalName[i] >= 'A' && otlPalName[i] <= 'Z' ||
		     otlPalName[i] == UNDERBAR ||
		     otlPalName[i] >= 'a' && otlPalName[i] <= 'z' )
			palName[len] = otlPalName[i];
		else
			palName[len] = UNDERBAR;
	}

	palName[len] = NULLCHAR;

	return( GM_S_SUCCESS );
}
