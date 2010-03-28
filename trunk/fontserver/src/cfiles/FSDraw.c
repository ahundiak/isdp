/* $RCSfile: fsdraw.c $$Revision: 1.4 $$Date: 1992/10/25 09:56:07 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSSize.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSConvert.h"
#include "../hfiles/FSDraw.h"

static int	_FSProcessChar();
static int	_FSProcessText();

void _FSDrawBitmap();
void _FSDrawRLE8();
void _FSDrawRLE16();
void _FSDrawOutline();
void _FSDrawOutline3D();

static void (*FSBmapDrawFunc)() = _FSDrawBitmap;
static void (*FSRLE8DrawFunc)() = _FSDrawRLE8;
static void (*FSRLE16DrawFunc)() = _FSDrawRLE16;
static void (*FSOutlDrawFunc)() = _FSDrawOutline;
static void (*FSOutl3DDrawFunc)() = _FSDrawOutline3D;


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSSetBmapDrawFunc (drawFunc)					*/
/*									*/
/*	  void (*drawFunc)();		- char. bitmap draw function	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the character bitmap draw function for the	*/
/*	  Font Server.  All calls to FSDraw...() will ultimately result	*/
/*	  in a call to this function for bitmap fonts.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSSetBmapDrawFunc (drawFunc)
void	(*drawFunc)();
{
    FSBmapDrawFunc = drawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetBmapDrawFunc (drawFunc)					*/
/*									*/
/*	  void (**drawFunc)();		- char. bitmap draw function	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the current character bitmap draw	*/
/*	  function.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetBmapDrawFunc (drawFunc)
void	(**drawFunc)();
{
    *drawFunc = FSBmapDrawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSSetRLE8DrawFunc (drawFunc)					*/
/*									*/
/*	  void (*drawFunc)();	- char 8-bit RLE draw function		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the character 8-bit RLE draw function for	*/
/*	  the Font Server.  All calls to FSDraw...() will ultimately	*/
/*	  result in a call to this function for 8-bit encoded		*/
/*	  characters in bitmap fonts.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSSetRLE8DrawFunc (drawFunc)
void	(*drawFunc)();
{
    FSRLE8DrawFunc = drawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetRLE8DrawFunc (drawFunc)					*/
/*									*/
/*	  void (**drawFunc)();	- char 8-bit RLE draw function		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the current character 8-bit RLE draw	*/
/*	  function.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetRLE8DrawFunc (drawFunc)
void	(**drawFunc)();
{
    *drawFunc = FSRLE8DrawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSSetRLE16DrawFunc (drawFunc)					*/
/*									*/
/*	  void (*drawFunc)();	- char 16-bit RLE draw function		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the character 16-bit RLE draw function for	*/
/*	  the Font Server.  All calls to FSDraw...() will ultimately	*/
/*	  result in a call to this function for 16-bit encoded		*/
/*	  characters in bitmap fonts.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSSetRLE16DrawFunc (drawFunc)
void	(*drawFunc)();
{
    FSRLE16DrawFunc = drawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetRLE16DrawFunc (drawFunc)					*/
/*									*/
/*	  void (**drawFunc)();	- char 16-bit RLE draw function		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the current character 16-bit RLE draw	*/
/*	  function.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetRLE16DrawFunc (drawFunc)
void	(**drawFunc)();
{
    *drawFunc = FSRLE16DrawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSSetOutlDrawFunc (drawFunc)					*/
/*									*/
/*	  void (*drawFunc)();		- char. outline draw function	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the character outline draw function for the	*/
/*	  Font Server.  All calls to FSDraw...() will ultimately result	*/
/*	  in a call to this function for outline fonts.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSSetOutlDrawFunc (drawFunc)
void	(*drawFunc)();
{
    FSOutlDrawFunc = drawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetOutlDrawFunc (drawFunc)					*/
/*									*/
/*	  void (**drawFunc)();		- character draw function	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the current character outline draw	*/
/*	  function.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetOutlDrawFunc (drawFunc)
void	(**drawFunc)();
{
    *drawFunc = FSOutlDrawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSSetOutl3DDrawFunc (drawFunc)				*/
/*									*/
/*	  void (*drawFunc)();		- 3D char. outline draw function*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the 3D character outline draw function for	*/
/*	  the Font Server.  All calls to FSDraw...() will ultimately	*/
/*	  result in a call to this function for outline fonts.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSSetOutl3DDrawFunc (drawFunc)
void	(*drawFunc)();
{
    FSOutl3DDrawFunc = drawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetOutl3DDrawFunc (drawFunc)				*/
/*									*/
/*	  void (**drawFunc)();		- 3D character draw function	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the current 3D character outline draw	*/
/*	  function.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetOutl3DDrawFunc (drawFunc)
void	(**drawFunc)();
{
    *drawFunc = FSOutl3DDrawFunc;

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSDrawChar (window, font, character, x, y, nx, ny)		*/
/*									*/
/*	  int		window;		- window number			*/
/*	  FontNode	**font;		- font identifier		*/
/*	  CharId	character;	- character identifier		*/
/*	  Real64	x, y;		- character start position	*/
/*	  Real64	*nx, *ny;	- position after char is drawn  */
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified character in the given	*/
/*	  the window at position (x, y).  The character is drawn using 	*/
/*	  the font specified by the given font identifier.  The new 	*/
/*	  text position after drawing the character is returned in nx 	*/
/*	  and ny.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSDrawChar (window, font, character, x, y, nx, ny)
int		window;
FontNode	**font;
CharId		character;
Real64		x, y;
Real64		*nx, *ny;
{
    return (_FSProcessChar (window, font, character, x, y, nx, ny, TRUE));
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetCharVect (font, character, x, y, nx, ny)			*/
/*									*/
/*	  FontNode	**font;		- font identifier		*/
/*	  CharId	character;	- character identifier		*/
/*	  Real64	x, y;		- character start position	*/
/*	  Real64	*nx, *ny;	- next position if the		*/
/*					  character is drawn		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the next location of the draw		*/
/*	  position that will occur if the specified character is drawn	*/
/*	  in the given font.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetCharVect (font, character, x, y, nx, ny)
FontNode	**font;
CharId		character;
Real64		x, y;
Real64		*nx, *ny;
{
    return (_FSProcessChar (0, font, character, x, y, nx, ny, FALSE));
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSDrawText (window, font, text, size, x, y, nx, ny)		*/
/*									*/
/*	  int		window;		- window number			*/
/*	  FontNode	**font;		- font identifier		*/
/*	  char		*text;		- text				*/
/*	  int		size;		- number of characters in text  */
/*	  Real64	x, y;		- text start position		*/
/*	  Real64	*nx, *ny;	- position after text is drawn  */
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified number of characters from	*/
/*	  text in the given window at position (x, y).  The text is	*/
/*	  drawn using the font specified by the given font identifier.  */
/*	  The new text position after drawing the text is returned	*/
/*	  in nx and ny.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSDrawText (window, font, text, size, x, y, nx, ny)
int		window;
FontNode	**font;
char		*text;
int		size;
Real64		x, y;
Real64		*nx, *ny;
{
    return (_FSProcessText (window, font, text, size, x, y, nx, ny, TRUE));
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetTextVect (font, text, size, x, y, nx, ny)		*/
/*									*/
/*	  FontNode	**font;		- font identifier		*/
/*	  char		*text;		- text				*/
/*	  int		size;		- number of characters in text  */
/*	  Real64	x, y;		- text start position		*/
/*	  Real64	*nx, *ny;	- next position if the text	*/
/*					  is drawn			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the next location of the draw		*/
/*	  position if the specified number of characters from text are  */
/*	  drawn using the font specified by the given font identifier.  */
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetTextVect (font, text, size, x, y, nx, ny)
FontNode	**font;
char		*text;
int		size;
Real64		x, y;
Real64		*nx, *ny;
{
    return (_FSProcessText (0, font, text, size, x, y, nx, ny, FALSE));
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSDrawString (window, font, string, x, y, nx, ny)		*/
/*									*/
/*	  int		window;		- window number			*/
/*	  FontNode	**font;		- font identifier		*/
/*	  char		*string;	- string			*/
/*	  Real64	x, y;		- string start position		*/
/*	  Real64	*nx, *ny;	- position after string is	*/
/*					  drawn				*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified string in the given window	*/
/*	  at position (x, y).  The string is drawn using the font	*/
/*	  specified by the given font identifier.  The new text		*/
/*	  position after drawing the text is returned in nx and ny.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSDrawString (window, font, string, x, y, nx, ny)
int		window;
FontNode	**font;
char		*string;
Real64		x, y;
Real64		*nx, *ny;
{
    return (_FSProcessText (window, font, string, -1, x, y, nx, ny, TRUE));
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetStringVect (font, string, x, y, nx, ny)			*/
/*									*/
/*	  FontNode	**font;		- font identifier		*/
/*	  char		*string;	- string			*/
/*	  Real64	x, y;		- string start position		*/
/*	  Real64	*nx, *ny;	- next position if the string	*/
/*					  is drawn			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the delta x and delta y of the draw	*/
/*	  position if the specified string is drawn using the font	*/
/*	  specified by the given font identifier.  			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetStringVect (font, string, x, y, nx, ny)
FontNode	**font;
char		*string;
Real64		x, y;
Real64		*nx, *ny;
{
    return (_FSProcessText (0, font, string, -1, x, y, nx, ny, FALSE));
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSProcessChar (window, font, character, x, y, nx, ny,	*/
/*			  drawFlag)					*/
/*									*/
/*	  int		window;		- window number			*/
/*	  FontNode	**font;		- font identifier		*/
/*	  CharId	character;	- character identifier		*/
/*	  Real64	x, y;		- character start position	*/
/*	  Real64	*nx, *ny;	- position after char is drawn  */
/*	  int		drawFlag;	- draw it iff TRUE		*/
/*									*/
/*	DESCRIPTION							*/
/*	  If drawFlag is TRUE, this routine calls the appropriate	*/
/*	  drawing routine (bitmap or outline) to draw the specified	*/
/*	  character using the specified font in the given the window at */
/*	  position (x, y), and returns the new draw position in		*/
/*	  (nx, ny).  If drawFlag is FALSE, the new draw position is	*/
/*	  returned but the character is not drawn.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

static int _FSProcessChar (window, font, character, x, y, nx, ny, drawFlag)
int		window;
FontNode	**font;
CharId		character;
Real64		x, y;
Real64		*nx, *ny;
int		drawFlag;
{
    int			shared;
    Real64		kernTrack, xPos, yPos, setWidth=0.0;
    FontInfo		*info;
    FontModes		*modes;
    FontCharNode	**thisChar;

    /** Do a little validity checking **/
    if (!_FSBmapFont (font) && !_FSOutlFont (font))
	return (FS_INVALID_FONT);

    /** Lock the shared memory semaphore if necessary **/
    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockInfo (font);
    _FSFontLockModes (font);

    /** Get pointers to some of the font sections **/
    info = _FSBmapInfo (font);
    modes = _FSBmapModes (font);

    xPos = x;
    yPos = y;

    /** Get the kern track **/
    if ((modes->kernTrack > 0) && (modes->kernTrack < 4))
	kernTrack = info->track[modes->kernTrack - 1];
    else
	kernTrack = 0.0;

    thisChar = _FSFontCharNode (font, &character, TRUE);

    /** Is the character displayable? **/
    if (thisChar != NULL)
    {
	_FSFontGetChar (font, thisChar, character);

	if (_FSBmapFont (font))		/* bitmap font? */
	{
	    BmapCharInfo	*charInfo;
	    BmapBitmap		*bitmap;

	    _FSBmapLockCharInfo (thisChar);
	    _FSBmapLockCharBitmap ((BmapCharNode **)thisChar);
	    charInfo = _FSBmapCharInfo (thisChar);
	    bitmap = _FSBmapCharBitmap (thisChar);

	    /** Draw it if necessary **/
	    if (drawFlag)
	    {
		void	(*drawFunc) () = NULL;

		switch (charInfo->flags & FS_USED_FLAG_BITS)
		{
		    case FS_REAL_BITMAP:
			drawFunc = FSBmapDrawFunc;
			break;

		    case FS_RUNLENGTH_8:
			drawFunc = FSRLE8DrawFunc;
			break;

		    case FS_RUNLENGTH_16:
			drawFunc = FSRLE16DrawFunc;
			break;
		}
		_FSDrawBmapChar (window, charInfo, bitmap, x, y, drawFunc);
	    }

	    setWidth = charInfo->setWid;

	    _FSBmapUnlockCharInfo (thisChar);
	    _FSBmapUnlockCharBitmap ((BmapCharNode **)thisChar);
	}
	else if (_FSOutlFont (font))		/* outline font? */
	{
	    OutlCharInfo	*charInfo;
	    OutlPolySize	*pSize;
	    OutlVertex		*vert;

	    _FSOutlLockCharInfo (thisChar);
	    _FSOutlLockCharPSize ((OutlCharNode **)thisChar);
	    _FSOutlLockCharVert ((OutlCharNode **)thisChar);
	    charInfo = _FSOutlCharInfo (thisChar);
	    pSize = _FSOutlCharPSize (thisChar);
	    vert = _FSOutlCharVert (thisChar);

	    /** Draw it if necessary **/
	    if (drawFlag)
	    {
		void	(*drawFunc) () = NULL;

		drawFunc = (info->flags & FS_3D) ? FSOutl3DDrawFunc :
			   FSOutlDrawFunc;
		_FSDrawOutlChar (window, charInfo, pSize, vert, x, y,
				 drawFunc);
	    }

	    setWidth = charInfo->setWid;

	    _FSOutlUnlockCharInfo (thisChar);
	    _FSOutlUnlockCharPSize ((OutlCharNode **)thisChar);
	    _FSOutlUnlockCharVert ((OutlCharNode **)thisChar);
	}
    
	/** Calculate the new position **/
	xPos += (setWidth + modes->extraWidth + kernTrack) * info->rotationCos;
	yPos -= (setWidth + modes->extraWidth + kernTrack) * info->rotationSin;
    }

    /** Return the next positions if necessary **/
    if (nx != NULL)  *nx = xPos;
    if (ny != NULL)  *ny = yPos;	

    _FSFontUnlockInfo (font);
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSProcessText (window, font, text, size, x, y, nx, ny,	*/
/*			  drawFlag)					*/
/*									*/
/*	  int		window;		- window number			*/
/*	  FontNode	**font;		- font identifier		*/
/*	  char		*text;		- text				*/
/*	  int		size;		- number of characters in text  */
/*					  (size < 0 if null-terminated)	*/
/*	  Real64	x, y;		- text start position		*/
/*	  Real64	*nx, *ny;	- position after text is drawn  */
/*	  int		drawFlag;	- draw the chars iff TRUE	*/
/*									*/
/*	DESCRIPTION							*/
/*	  If drawFlag is TRUE, this routine calls the appropriate	*/
/*	  drawing function (bitmap or outline) to draw the specified	*/
/*	  number of characters from text using the specified font at	*/
/*	  position (x, y) in the given window, and returns the new	*/
/*	  draw position in (nx, ny).  If drawFlag is FALSE, the new	*/
/*	  draw position is returned but the text is not drawn.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

static int _FSProcessText (window, font, text, size, x, y, nx, ny, drawFlag)
int		window;
FontNode	**font;
char		*text;
int		size;
Real64		x, y;
Real64		*nx, *ny;
int		drawFlag;
{
    int			shared;
    register Char16	*textPtr, *textEnd, *text16;
    register Char8	*text8;
    Char16		character;
    Char16		*newText;
    Real64		xPos, yPos, kernAmount, kernTrack;
    FontInfo		*info;
    FontModes		*modes;

    /** Do a little validity checking **/
    if (!_FSBmapFont (font) && !_FSOutlFont (font))
	return (FS_INVALID_FONT);

    /** Lock the shared memory semaphore if necessary **/
    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockInfo (font);
    _FSFontLockModes (font);
    _FSFontLockKernPairs (font);

    /** Get pointers to some of the font sections **/
    info = _FSBmapInfo (font);
    modes = _FSBmapModes (font);

    xPos = x;
    yPos = y;

    /** Get the kern track **/
    if ((modes->kernTrack > 0) && (modes->kernTrack < 4))
	kernTrack = info->track[modes->kernTrack - 1];
    else
	kernTrack = 0.0;

    /** Calculate the size of the string if necessary **/
    text8 = (Char8 *) text;
    text16 = (Char16 *) text;
    if (size < 0)
	if (info->fontFlags & FS_SIXTEEN_BIT_FONT)
	    for (size = 0; *text16 != (Char16) 0; size++, text16++);
	else
	    for (size = 0; *text8 != '\0'; size++, text8++);

    /** Allocate space for converting the string **/
    newText = (Char16 *) _FSAlloc (size * sizeof (Char16));
    textEnd = &newText[size];

    /** Convert to 16-bit characters **/
    text8 = (Char8 *) text;
    text16 = (Char16 *) text;
    if (info->fontFlags & FS_SIXTEEN_BIT_FONT)
    {
	for (textPtr = newText; textPtr < textEnd; textPtr++, text16++)
	    *textPtr = (Char16) *text16;
    }
    else
    {
	for (textPtr = newText; textPtr < textEnd; textPtr++, text8++)
	    *textPtr = (Char16) *text8;
    }

    if (modes->ligature)
    {
	/** ligatures unsupported for now **/
    }

    if (_FSBmapFont (font))	/* bitmap font? */
    {
	BmapCharNode	**thisChar;
	BmapCharInfo	*charInfo;
	BmapBitmap	*bitmap;

	for (textPtr = newText; textPtr < textEnd;)
	{
	    character = *textPtr++;
	    thisChar = _FSBmapCharNode (font, &character, TRUE);
	    if (thisChar == NULL)
		continue;

	    _FSBmapGetChar (font, thisChar, character);

	    _FSBmapLockCharInfo (thisChar);
	    _FSBmapLockCharBitmap (thisChar);
	    charInfo = _FSBmapCharInfo (thisChar);
	    bitmap = _FSBmapCharBitmap (thisChar);

	    if (drawFlag) 
	    {
		void	(*drawFunc) ()=NULL;

		switch (charInfo->flags & FS_USED_FLAG_BITS)
		{
		    case FS_REAL_BITMAP:
			drawFunc = FSBmapDrawFunc;
			break;

		    case FS_RUNLENGTH_8:
			drawFunc = FSRLE8DrawFunc;
			break;

		    case FS_RUNLENGTH_16:
			drawFunc = FSRLE16DrawFunc;
			break;
		}
		_FSDrawBmapChar (window, charInfo, bitmap, xPos, yPos,
				 drawFunc);
	    }

	    if ((modes->kernPair) && (textPtr < textEnd))
		kernAmount = _FSBmapKernValue (font, character, *textPtr);
	    else
		kernAmount = 0.0;

	    /** Calculate the next position **/
	    xPos += (charInfo->setWid + kernTrack + kernAmount +
		     modes->extraWidth) * info->rotationCos;
	    yPos -= (charInfo->setWid + kernTrack + kernAmount +
		     modes->extraWidth) * info->rotationSin;

	    _FSBmapUnlockCharInfo (thisChar);
	    _FSBmapUnlockCharBitmap (thisChar);
	}
    }
    else	/* outline font */
    {
	OutlCharNode	**thisChar;
	OutlCharInfo	*charInfo;
	OutlPolySize	*pSize;
	OutlVertex	*vert;

	for (textPtr = newText; textPtr < textEnd;)
	{
	    character = *textPtr++;
	    thisChar = _FSOutlCharNode (font, &character, TRUE);
	    if (thisChar == NULL)
		continue;

	    _FSOutlGetChar (font, thisChar, character);

	    _FSOutlLockCharInfo (thisChar);
	    _FSOutlLockCharPSize (thisChar);
	    _FSOutlLockCharVert (thisChar);
	    charInfo = _FSOutlCharInfo (thisChar);
	    pSize = _FSOutlCharPSize (thisChar);
	    vert = _FSOutlCharVert (thisChar);

	    if (drawFlag)
	    {
		void	(*drawFunc) ()=NULL;

		drawFunc = (info->flags & FS_3D) ? FSOutl3DDrawFunc :
			   FSOutlDrawFunc;
		_FSDrawOutlChar (window, charInfo, pSize, vert, xPos, yPos,
				 drawFunc);
	    }

	    if ((modes->kernPair) && (textPtr < textEnd))
		kernAmount = _FSOutlKernValue (font, character, *textPtr);
	    else
		kernAmount = 0.0;

	    /** Calculate the next position **/
	    xPos += (charInfo->setWid + kernTrack + kernAmount +
		     modes->extraWidth) * info->rotationCos;
	    yPos -= (charInfo->setWid + kernTrack + kernAmount +
		     modes->extraWidth) * info->rotationSin;

	    _FSOutlUnlockCharInfo (thisChar);
	    _FSOutlUnlockCharPSize (thisChar);
	    _FSOutlUnlockCharVert (thisChar);
	}
    }
    _FSDealloc ((char *)newText);

    /** Return the next positions if necessary **/
    if (nx)  *nx = xPos;
    if (ny)  *ny = yPos;
    
    _FSFontUnlockInfo (font);
    _FSFontUnlockModes (font);
    _FSFontUnlockKernPairs (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawBmapChar (window, charInfo, bitmap, bx, by, drawFunc)	*/
/*									*/
/*	  int		window;		- window number			*/
/*	  BmapCharInfo  *charInfo;	- character info		*/
/*	  BmapBitmap	*bitmap;	- bitmap for this character	*/
/*	  Real64	bx, by;		- character baseline origin	*/
/*	  void		(*drawFunc)();	- draw function			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified character with the given	*/
/*	  draw function.  The draw function normally calls		*/
/*	  _FSDrawBitmap() (below).					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Zero.								*/
/*									*/
/************************************************************************/

int _FSDrawBmapChar (int window, BmapCharInfo *charInfo, BmapBitmap *bitmap, Real64 bx, Real64 by, void (*drawFunc)())
{
    double	bx2, by2;
    int		x, y;

    /** Calculate the coordinates for the draw function **/
    bx2 = bx + charInfo->hOff;
    by2 = by - charInfo->vOff - charInfo->rHgt;
    x = ROUND (bx2);
    y = ROUND (by2);

    /** Draw the character **/
    (*drawFunc) (window, x, y, charInfo->rWid, charInfo->rHgt, bitmap,
		 bx, by, charInfo);

    return (0);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawBitmap (window, x, y, width, height, bitmap, bx, by,	*/
/*			 charInfo)					*/
/*									*/
/*	  int		window		- window number			*/
/*	  int		x, y;		- coordinates to draw at	*/
/*	  int		width, height;	- width, height of char		*/
/*	  BmapBitmap	*bitmap;	- the bitmap			*/
/*	  double	bx, by;		- baseline coordinates		*/
/*					  (usually not needed)		*/
/*	  BmapCharInfo	*charInfo;	- charInfo (ditto)		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified bitmap at the given		*/
/*	  location.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

/*ARGSUSED*/
void _FSDrawBitmap (window, x, y, width, height, bitmap, bx, by, charInfo)
int		window;
int		x, y;
int		width, height;
BmapBitmap	*bitmap;
double		bx, by;
BmapCharInfo	*charInfo;
{
    if ((width > 0) && (height > 0))
	drawbitmap (window, 0xFFFF, x, y, x + width - 1, y + height - 1,
		    bitmap);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawRLE8 (window, x, y, width, height, RLE8, bx, by,	*/
/*			charInfo)					*/
/*									*/
/*	  int		window		- window number			*/
/*	  int		x, y;		- coordinates to draw at	*/
/*	  int		width, height;	- width, height of char		*/
/*	  uInt8		*RLE8;		- 8-bit RLE data		*/
/*	  double	bx, by;		- baseline coordinates		*/
/*					  (usually not needed)		*/
/*	  BmapCharInfo	*charInfo;	- charInfo (ditto)		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified 8-bit RLE-encoded bitmap at	*/
/*	  the given location.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _FSDrawRLE8 (window, x, y, width, height, RLE8, bx, by, charInfo)
int		window;
int		x, y;
int		width, height;
uInt8		*RLE8;
double		bx, by;
BmapCharInfo	*charInfo;
{
    int		bmapSize;
    BmapBitmap	*bitmap;

    bmapSize = BMAP_BMAP_SIZE (((width + 7) >> 3) * height);

    if (bmapSize > 0)
    {
	bitmap = (BmapBitmap *) _FSAlloc (bmapSize);
	_FSConvertRLE8 (RLE8, bitmap, width, height);

	(*FSBmapDrawFunc) (window, x, y, width, height, bitmap, bx, by,
				charInfo);
	_FSDealloc ((char *)bitmap);
    }
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawRLE16 (window, x, y, width, height, RLE16, bx, by,	*/
/*			charInfo)					*/
/*									*/
/*	  int		window		- window number			*/
/*	  int		x, y;		- coordinates to draw at	*/
/*	  int		width, height;	- width, height of char		*/
/*	  uInt16	*RLE16;		- 16-bit RLE data		*/
/*	  double	bx, by;		- baseline coordinates		*/
/*					  (usually not needed)		*/
/*	  BmapCharInfo	*charInfo;	- charInfo (ditto)		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified 16-bit RLE-encoded bitmap at	*/
/*	  the given location.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _FSDrawRLE16 (window, x, y, width, height, RLE16, bx, by, charInfo)
int		window;
int		x, y;
int		width, height;
uInt16		*RLE16;
double		bx, by;
BmapCharInfo	*charInfo;
{
    int		bmapSize;
    BmapBitmap	*bitmap;

    bmapSize = BMAP_BMAP_SIZE (((width + 7) >> 3) * height);

    if (bmapSize > 0)
    {
	bitmap = (BmapBitmap *) _FSAlloc (bmapSize);
	_FSConvertRLE16 ((Int16 *)RLE16, bitmap, width, height);

	(*FSBmapDrawFunc) (window, x, y, width, height, bitmap, bx, by,
				charInfo);
	_FSDealloc ((char *)bitmap);
    }
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawOutlChar (window, charInfo, pSize, vert, x, y,		*/
/*			   drawFunc)					*/
/*									*/
/*	  int		window;		- window number			*/
/*	  OutlCharInfo	*charInfo;	- character 			*/
/*	  OutlPolySize	*pSize;		- ptr to polygon sizes		*/
/*	  OutlVertex	*vert;		- ptr to vertices		*/
/*	  Real64	x, y;		- character start position	*/
/*	  void		(*drawFunc)();	- draw function (not NULL!)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified outline character with the	*/
/*	  given draw function.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  Zero.								*/
/*									*/
/************************************************************************/

int _FSDrawOutlChar (int window, OutlCharInfo *charInfo, OutlPolySize *pSize, OutlVertex *vert, Real64 x, Real64 y, void (*drawFunc)())
{
    /** Draw the character **/
    (*drawFunc) (window, x, y, vert, pSize, charInfo->nPSize, charInfo);

    return (0);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawOutline (window, x, y, vert, pSize, nPolys, charInfo)	*/
/*									*/
/*	  int		window		- window number			*/
/*	  int		x, y;		- draw coordinates		*/
/*	  OutlVertex	*vert;		- the vertices			*/
/*	  OutlPolySize	*pSize;		- polygon sizes			*/
/*	  int		nPolys;		- number of polygons		*/
/*	  OutlCharInfo	*charInfo;	- charInfo (usually not needed)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified outlines at the given	*/
/*	  location.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

/*ARGSUSED*/
void _FSDrawOutline (window, x, y, vert, pSize, nPolys, charInfo)
int		window;
Real64		x, y;
OutlVertex	*vert;
OutlPolySize	*pSize;
int		nPolys;
OutlCharInfo	*charInfo;
{
    int	j, k, count;

    for (j = 0; j < nPolys; j++)
    {
	move (window, (int) (x + vert->x), (int) (y - vert->y));
	vert++;
	count = *pSize++;
	for (k = 1; k < count; k++, vert++)
	    draw (window, (int) (x + vert->x), (int) (y - vert->y));
    }
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDrawOutline3D (window, x, y, vert, pSize, nPolys,		*/
/*				charInfo)				*/
/*									*/
/*	  int		window		- window number			*/
/*	  int		x, y;		- draw coordinates		*/
/*	  Outl3DVertex	*vert;		- the 3D vertices		*/
/*	  OutlPolySize	*pSize;		- polygon sizes			*/
/*	  int		nPolys;		- number of polygons		*/
/*	  OutlCharInfo	*charInfo;	- charInfo (usually not needed)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine draws the specified 3D outlines at the given	*/
/*	  location.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

/*ARGSUSED*/
void _FSDrawOutline3D (window, x, y, vert, pSize, nPolys, charInfo)
int		window;
Real64		x, y;
Outl3DVertex	*vert;
OutlPolySize	*pSize;
int		nPolys;
OutlCharInfo	*charInfo;
{
    int	j, k, count;

    for (j = 0; j < nPolys; j++)
    {
	move (window, (int) (x + vert->x), (int) (y - vert->y));
	vert++;
	count = *pSize++;
	for (k = 1; k < count; k++, vert++)
	    draw (window, (int) (x + vert->x), (int) (y - vert->y));
    }
}
