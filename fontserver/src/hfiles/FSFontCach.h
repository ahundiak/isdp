/* $RCSfile: fsfntcch.h $$Revision: 1.3 $$Date: 1991/02/28 13:39:37 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _FONTCACH
#define _FONTCACH	0


#include "../hfiles/FSDef.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSFont.h"


/** Font node structures that are identical for all fonts:		**/
/**	FontNode	FontModes	FontPairNode	FontCharDir	**/
/**									**/
/** Font node structures that are not identical for all fonts, but	**/
/** exist in all fonts in one form or another:				**/
/**	FontCharNode							**/



/** The following typedef of FontCharNode is common for the character	**/
/** node structures in all font types (see BmapCharNode, OutlCharNode).	**/

typedef struct
{
    Int				timeStamp;
}   FontCharNode;


/* Character node structures for bitmap and outline fonts */

typedef struct
{
    FontCharNode		font;
    BmapCharInfo		data;
    BmapBitmap			**bits;
}   BmapCharNode;

typedef struct
{
    FontCharNode		font;
    OutlCharInfo		data;
    OutlPolySize		**pSize;
    OutlVertex			**vert;
}   OutlCharNode;


/* Font modes structure */

typedef struct
{
    Boolean	kernPair;
    Int		kernTrack;
    Boolean	ligature;
    Real64	extraWidth;
}   FontModes;


/* Font character directory structure */

typedef struct
{
    Char16		minChar;	/* minimum character id		*/
    Int16		numChar;	/* number of chars in table	*/
    FontCharNode	****table;	/* handle to table of		*/
}   FontCharDir;			/* FontCharNode handles		*/


/* Font regeneration structure */

typedef struct
{
    FileRef	sourceRef;		/* tf or font file reference	*/
    FileRef	cmRef;			/* char map reference		*/
    Int		howToRegen;		/* how to regen. font (below)	*/
}   FontRegen;

/** values for howToRegen field **/
#define	CALL_NEWFONT	0
#define	CALL_READFONT	1


/* Font node structure (a font id is a handle to this structure) */

typedef struct _FontNode
{
    Int32		type;		/* font type			*/
    FontModes		modes;		/* kern, lig modes		*/
    FontRegen		regen;		/* how to regenerate font	*/
    FontHeader		**header;	/* font header			*/
    FontInfo		**info;		/* general info			*/
    Int32		numKernPair;	/* # of kern pairs in table	*/
    FontKernPair	**kernPair;	/* handle to kern pair table	*/
    Int32		numLigature;	/* # of ligatures in table	*/
    FontLigature	**ligature;	/* handle to ligature table	*/
    Int32		currChar;	/* current character		*/
    Int32		currCharNum;	/* current character count	*/
    Int16		numChar;	/* # of characters in font	*/
    FontCharDir		charDir;	/* character directory		*/
    int			ownerCount;	/* how many processes own me?	*/
    struct _FontNode	**next;		/* next font in list of fonts	*/
}   FontNode;

/** Masks for the flags field **/
#define	FS_SHARED_FONT	1


/* These functions provide access to all fonts (see FSFontCach.c).	*/

extern	FontHeader	*_FSFontHeader ();
extern	FontInfo	*_FSFontInfo ();
extern	FontKernPair	*_FSFontKernPairs ();
extern	Real64		_FSFontKernValue ();
extern	FontCharNode	**_FSFontFirstChar ();
extern	FontCharNode	**_FSFontNextChar ();
extern	FontCharNode	***_FSFontCharDirEntry ();
extern	FontCharNode	**_FSFontCharNode (FontNode **fontNode, CharId *character, Boolean missFlag);
extern	FontModes	*_FSFontModes ();
extern	FontRegen	*_FSFontRegen ();
extern	FontCharDir	*_FSFontCharDir ();
extern	FontCharNode	***_FSFontCharDirTable ();
extern	FontNode	**_FSFontCreate ();
extern  Int             _FSFontLockHeader (FontNode **);
extern  Int             _FSFontUnlockHeader (FontNode **);
extern  Int             _FSFontLockFont (FontNode **);
extern  Int             _FSFontUnlockFont (FontNode **);
extern  Int             _FSFontFree (FontNode **);
extern  Int             _FSFontGetChar (FontNode **, FontCharNode **charNode, CharId);
extern  Int             _FSFontLockCharInfo (FontCharNode **charNode);
extern  Int             _FSFontUnlockCharInfo (FontCharNode **charNode);
extern  Int             _FSFontUnlockCharDirTable (FontNode **fontNode);
extern  Int             _FSFontLockCharDirTable (FontNode **fontNode);
extern  Int             _FSComparePairChar (CharId char11, CharId char12, CharId char21, CharId char22);
extern  Int             _FSFontLockKernPairs (FontNode **fontNode);
extern  Int             _FSFontUnlockKernPairs (FontNode **fontNode);
extern  Int             _FSFontLockInfo (FontNode **fontNode);
extern  Int             _FSFontUnlockInfo (FontNode **fontNode);
extern  Int             _FSFontAppendCharDir (FontNode **fontNode, CharId *characters, int numChars);
extern  Int             _FSFontAutosetInfo (FontInfo *info);
extern  Int             _FSFontNewKernPairs (FontNode **fontNode, FontKernPair **kernPair, Int numPair);


/* These #defines are for locking and unlocking parts of a font that	*/
/* are contained within the font node structure; thus, they simply lock	*/
/* the font node handle.						*/

#define	_FSFontLockModes	_FSFontLockFont
#define	_FSFontLockRegen	_FSFontLockFont
#define	_FSFontLockCharDir	_FSFontLockFont
#define	_FSFontUnlockModes	_FSFontUnlockFont
#define	_FSFontUnlockRegen	_FSFontUnlockFont
#define	_FSFontUnlockCharDir	_FSFontUnlockFont


#endif
