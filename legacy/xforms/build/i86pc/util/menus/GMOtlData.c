#include <malloc.h>
#include <stdio.h>
#include "GMoutline.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

/******************************************************************************

Doc:	GMGetOtlData

Abstract:
	The GMGetOtlData function reads and parses the non-header lines
	from the outline and generates a circular, doubly linked list of
	palettes.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_W_TRUNCATE	-	Truncated palette file/symbol file/font name(s)
	GM_W_PARSE	-	Parsing warning(s)
	GM_E_PARSE	-	Parsing error(s)
	GM_F_OUTLINE	-	No valid buttons described
	GM_F_ALLOC	-	Error allocating memory

******************************************************************************/
/* struct GMOtlPalette **otlPalList;  ** o - Pointer to circular, doubly */
/*                                           linked list of palettes  */
/* struct GMHdrData    *hdrData;      ** i - Outline header data      */
/* struct GMParseFp    *fp;           ** i - File info for parsing    */

int	GMGetOtlData (struct GMOtlPalette **otlPalList,
                      struct GMHdrData    *hdrData,
                      struct GMParseFp    *fp)
{
extern	struct	GMOtlPalette	*GMAddOtlPal();
extern	struct	GMOtlButton	*GMAddOtlBtn();

struct	GMLineData	*curLine, *prevLine;
struct	GMOtlPalette	palHdr, *curPal;
struct	GMOtlButton	dummyBtn, *prevBtn;
int			curLevel, prevLevel, btnCount;
int			sts, retsts;

	sts = GMInitLineData( &prevLine );
	if ( sts == GM_F_ALLOC )
	{
		fprintf( fp->err,
			 "Line %d  Error allocating memory\n",
			 fp->line );
		return( sts );
	}
	dummyBtn.data = prevLine;
	dummyBtn.palette = ( struct GMOtlPalette * )0;
	dummyBtn.nextBtn = dummyBtn.prevBtn = &dummyBtn;
	prevBtn = &dummyBtn;

	prevLevel = 0;
	palHdr.data = ( struct GMLineData * )0;
	palHdr.level = prevLevel;
	palHdr.buttons = &dummyBtn;
	palHdr.nextPal = palHdr.prevPal = &palHdr;
	curPal = &palHdr;

	btnCount = 0;

	retsts = GM_S_SUCCESS;

	while ( ( sts = GMGetLineData( &curLevel, &curLine, hdrData, fp ) ) != GM_I_EOF )
	{
		if ( sts == GM_F_ALLOC )
			goto alloc_fail;
		else if ( sts > retsts )
			retsts = sts;

		if ( GM_ERROR( sts ) )
			continue;
		else if ( curLevel == 0 )
			continue;
		else if ( curLevel == prevLevel )
			;
		else if ( curLevel < prevLevel )
		{
			curPal = palHdr.prevPal;
			while ( curPal->level != curLevel )
				curPal = curPal->prevPal;
		}
		else if ( curLevel == prevLevel + 1 )
		{
			curPal = GMAddOtlPal( &palHdr, prevLine, curLevel, hdrData );
			if ( ! curPal )
				goto alloc_fail;
			prevBtn->palette = curPal;
		}
		else
		{
			fprintf( fp->err,
				 "Line %d  Button level %d cannot immediately follow level %d\n",
				 fp->line, curLevel, prevLevel );
			GMFreeLineData( curLine, hdrData );
			retsts = GM_E_PARSE;
			continue;
		}

		prevBtn = GMAddOtlBtn( curPal, curLine, hdrData );
		if ( ! prevBtn )
			goto alloc_fail;
		curPal->data->numBtn++;
		btnCount++;

		prevLevel = curLevel;
		prevLine = curLine;
	}

	if ( btnCount == 0 )
	{
		fprintf( fp->err,
			 "No valid button descriptions\n" );
		GMFreeOtlData( TRUE, &palHdr, hdrData );
		return( GM_F_OUTLINE );
	}

	if ( GM_ERROR( retsts ) )
	{
		GMFreeOtlData( TRUE, &palHdr, hdrData );
		return( retsts );
	}

	curPal = palHdr.nextPal;
	do
	{
		sts = GMFinishOtlPal( curPal );
		curPal = curPal->nextPal;
	} while ( curPal != &palHdr );

	*otlPalList = palHdr.nextPal;
	( *otlPalList )->prevPal = palHdr.prevPal;
	( *otlPalList )->prevPal->nextPal = *otlPalList;

	return( retsts );

alloc_fail:
	fprintf( fp->err,
		 "Line %d  Error allocating memory\n",
		 fp->line );
	GMFreeOtlData( TRUE, &palHdr, hdrData );
	return( GM_F_ALLOC );
}

/******************************************************************************

Doc:	GMAddOtlPal

Abstract:
	The GMAddOtlPal function adds a palette to the outline palette
	list and assigns defaults from outline header data to undefined
	palette information in the line data.

Return Values:
	Pointer to the new palette
	0  (Error allocating memory)

******************************************************************************/
/* struct GMOtlPalette  *palHdr;  ** i/o - Circular doubly linked */
/*                                         list of palettes       */
/* struct GMLineData *lineData;	  ** i/o - Line data              */
/* int	             level;       ** i - Palette's level          */
/* struct GMHdrData  *hdrData;    ** i - Outline header data      */

struct	GMOtlPalette	*GMAddOtlPal (struct GMOtlPalette  *palHdr,
                                      struct GMLineData *lineData,
                                      int               level,
                                      struct GMHdrData  *hdrData)
{
struct	GMOtlPalette	*newPal;

	newPal = ( struct GMOtlPalette * )malloc( sizeof( struct GMOtlPalette ) );
	if ( ! newPal )
		return( newPal );

	newPal->data = lineData;
	newPal->level = level;
	newPal->buttons = ( struct GMOtlButton * )0;
	newPal->nextPal = palHdr;
	newPal->prevPal = palHdr->prevPal;

	palHdr->prevPal->nextPal = newPal;
	palHdr->prevPal = newPal;

	lineData->numBtn = 0;
	if ( level == 1 )
	{
		lineData->numColumn = hdrData->level[0].numColumn;
		lineData->numRow = hdrData->level[0].numRow;
		lineData->btnHeight = hdrData->level[0].btnHeight;
		lineData->btnWidth = hdrData->level[0].btnWidth;

		lineData->remember = 0;
	}
	else		/* Only for panel menu palettes	*/
	{
		level--;

		if ( lineData->numColumn > 0 )
			lineData->btnWidth = PANEL_PAL_WIDTH / lineData->numColumn;
		else if ( lineData->btnWidth > 0 &&
			  lineData->btnWidth <= PANEL_PAL_WIDTH )
			lineData->numColumn = PANEL_PAL_WIDTH / lineData->btnWidth;
		else
		{
			lineData->numColumn = hdrData->level[level].numColumn;
			lineData->btnWidth = hdrData->level[level].btnWidth;
		}

		if ( lineData->btnHeight <= 0 )
			lineData->btnHeight = hdrData->level[level].btnHeight;

		lineData->numRow = 0;

		if ( lineData->remember == UNDEFINED_DATA )
			lineData->remember = hdrData->remember;
	}

	return( newPal );
}

/******************************************************************************

Doc:	GMFinishOtlPal

Abstract:
	The GMFinishOtlPal function sets the remaining palettea attributes
	in the line data for the given palette.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* struct GMOtlPalette *otlPal;   ** i/o - Outline palette  */

int	GMFinishOtlPal (struct GMOtlPalette *otlPal)

{
	if ( otlPal->data->numColumn > 0 )
	{
		otlPal->data->numRow = otlPal->data->numBtn / otlPal->data->numColumn;
		if ( otlPal->data->numBtn % otlPal->data->numColumn )
			otlPal->data->numRow++;
	}
	else					/* Bar menu only	*/
		otlPal->data->numColumn = otlPal->data->numBtn;

	return( GM_S_SUCCESS );
}

/******************************************************************************

Doc:	GMAddOtlBtn

Abstract:
	The GMAddOtlBtn function adds a button to the current outline
	palette and assigns defaults from outline header data to undefined
	button information in the line data.

Return Values:
	Pointer to the new button
	0  (Error allocating memory)

******************************************************************************/
/* struct GMOtlPalette *curPal;   ** i/o - Current outline palette */
/* struct GMLineData   *lineData; ** i/o - Line data               */
/* struct GMHdrData    *hdrData;  ** i - Outline header data       */

struct	GMOtlButton	*GMAddOtlBtn (struct GMOtlPalette *curPal,
                                      struct GMLineData   *lineData,
                                      struct GMHdrData    *hdrData)
{
struct	GMOtlButton	*newBtn;
int			i;

	newBtn = ( struct GMOtlButton * )malloc( sizeof( struct GMOtlButton ) );
	if ( ! newBtn )
		return( newBtn );

	newBtn->data = lineData;
	newBtn->palette = ( struct GMOtlPalette * )0;
	if ( curPal->buttons )
	{
		newBtn->nextBtn = curPal->buttons;
		newBtn->prevBtn = curPal->buttons->prevBtn;

		curPal->buttons->prevBtn->nextBtn = newBtn;
		curPal->buttons->prevBtn = newBtn;
	}
	else
	{	
		newBtn->prevBtn = newBtn;
		newBtn->nextBtn = newBtn;

		curPal->buttons = newBtn;
	}

	if ( lineData->textStyle == UNDEFINED_DATA )
		lineData->textStyle = hdrData->textStyle;
	if ( lineData->textJust == UNDEFINED_DATA )
		lineData->textJust = hdrData->textJust;

	for ( i = 0; i < NUM_COLORS; i++ )
	{
		if ( lineData->color[i] == UNDEFINED_DATA )
			lineData->color[i] = hdrData->color[i];
	}

	return( newBtn );
}

/******************************************************************************

Doc:	GMFreeOtlData

Abstract:
	The GMFreeOtlData function frees the space allocated for the
	outline data structures.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* int	               dummyFlag;     ** i - First palette a dummy?  */
/* struct GMOtlPalette *otlPalList;   ** i - Circular doubly linked  */
/*                                       list of outline palettes    */
/* struct GMHdrData    *hdrData;      ** i - Outline header data     */

int	GMFreeOtlData (int                 dummyFlag,
                       struct GMOtlPalette *otlPalList,
                       struct GMHdrData    *hdrData)
{
struct	GMOtlPalette	*curPal, *nextPal;
struct	GMOtlButton	*curBtn, *nextBtn;

	if ( dummyFlag )
	{
		if ( otlPalList->nextPal == otlPalList )
		{
			GMFreeLineData( otlPalList->buttons->data, hdrData );
			return( GM_S_SUCCESS );
		}

		curPal = otlPalList->nextPal;
	}
	else
		curPal = otlPalList;

        /* GMFreeLineData( curPal->data );  dmb:09/02/92:Fixed for ANSI */
	GMFreeLineData( curPal->data, hdrData );
	do
	{
		nextPal = curPal->nextPal;
		if ( curPal->buttons )
		{
			curBtn = curPal->buttons;
			do
			{
				nextBtn = curBtn->nextBtn;
				GMFreeLineData( curBtn->data, hdrData );
				free( curBtn );
				curBtn = nextBtn;
			} while ( curBtn != curPal->buttons );
		}
		free( curPal );
		curPal = nextPal;
	} while ( curPal != otlPalList );

	return( GM_S_SUCCESS );
}
