/* $RCSfile: fsmodes.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:56 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSGenCache.h"


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSSetKernMode (font, mode)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Int32		mode;		- enabled or disabled		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Enables or disables the use of the kerning pair table		*/
/*	  for the font.  If mode is ON, the spacing between certain	*/
/*	  characters is adjusted when they are drawn to make the	*/
/*	  spacing appear 'right'.  The kerning mode is initially	*/
/*	  enabled.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSSetKernMode (font, mode)
FontNode	**font;
Int32		mode;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    modes->kernPair = mode;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSGetKernMode (font, mode)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Int32		*mode;		- enabled or disabled		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the value of kernMode.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSGetKernMode (font, mode)
FontNode	**font;
Int32		*mode;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    *mode = modes->kernPair;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSSetKernTrack (font, track)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Int32		track;		- kerning track value		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This sets the kerning track that is used for inter-		*/
/*	  character spacing.  Different kerning tracks can give		*/
/*	  the font a 'scrunched' or expanded look.  There are		*/
/*	  four kerning tracks, numbered 1 through 4.  If track		*/
/*	  zero is selected, no kerning track is used.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSSetKernTrack (font, track)
FontNode	**font;
Int32		track;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    modes->kernTrack = track;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSGetKernTrack (font, track)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Int32		*track;		- which kerning track to use.	*/
/*					  if it's zero, no kerning	*/
/*					  track is used.		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This returns the kerning track number in track.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSGetKernTrack (font, track)
FontNode	**font;
Int32		*track;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    *track = modes->kernTrack;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSSetLigMode (font, mode)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Int32		mode;		- enabled or disabled		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Enables or disables the use of the ligature table for the	*/
/*	  font.  If enabled (ON), the ligature is substituted for	*/
/*	  the sequence of letters that make it (the 'ffi' ligature	*/
/*	  for the sequence of letters f, f, then i,  for example).	*/
/*	  The ligature mode is initially disabled.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSSetLigMode (font, mode)
FontNode	**font;
Int32		mode;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    modes->kernPair = mode;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSGetLigMode (font, mode)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Int32		*mode;		- enabled or disabled		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This returns the value of the ligature mode in mode.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSGetLigMode (font, mode)
FontNode	**font;
Int32		*mode;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    *mode = modes->ligature;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSSetExtraWidth (font, width)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Real32	width;		- extra width value		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This function sets the floating point extra width value for	*/
/*	  a font.  This value is added to the width of every character	*/
/*	  drawn.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSSetExtraWidth (font, width)
FontNode	**font;
Real32		width;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    modes->extraWidth = width;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int	FSGetExtraWidth (font, width)				*/
/*									*/
/*	  FontNode	**font;		- the font identifier		*/
/*	  Real32	*width;		- extra width value		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the extra width value.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always FS_NO_ERROR.						*/
/*									*/
/************************************************************************/

int FSGetExtraWidth (font, width)
FontNode	**font;
Real32		*width;
{
    int		shared;
    FontModes	*modes;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockModes (font);
    modes = _FSFontModes (font);
    *width = modes->extraWidth;
    _FSFontUnlockModes (font);

    _GCUnlockSem (shared);

    return (FS_NO_ERROR);
}
