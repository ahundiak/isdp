/* $RCSfile: fsbmpcch.h $$Revision: 1.2 $$Date: 1990/12/13 13:23:38 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _MAKEBMAP
#define _MAKEBMAP	0


#include "FSTypes.h"
#include "FSBmap.h"
#include "FSFontCach.h"


/* These #defines are for generic font structures that are used for	*/
/* bitmap fonts (see FSFontCach.h).					*/

#define	BmapNode	FontNode
#define	BmapPairNode	FontPairNode
#define	BmapModes	FontModes
#define	BmapRegen	FontRegen
#define	BmapCharDir	FontCharDir


/* These #defines are for generic font access functions that are used	*/
/* for bitmap fonts (see FSFontCach.c).					*/

#define	_FSBmapHeader		(BmapHeader *) _FSFontHeader
#define	_FSBmapInfo		(BmapInfo *) _FSFontInfo
#define	_FSBmapKernPairs	(BmapKernPair *) _FSFontKernPairs
#define	_FSBmapFirstChar	(BmapCharNode **) _FSFontFirstChar
#define	_FSBmapNextChar		(BmapCharNode **) _FSFontNextChar
#define	_FSBmapCharDirEntry	(BmapCharNode ***) _FSFontCharDirEntry
#define	_FSBmapCharNode		(BmapCharNode **) _FSFontCharNode
#define	_FSBmapModes		(BmapModes *) _FSFontModes
#define	_FSBmapRegen		(BmapRegen *) _FSFontRegen
#define	_FSBmapCharDir		(BmapCharDir *) _FSFontCharDir
#define	_FSBmapCharDirTable	(BmapCharNode ***) _FSFontCharDirTable
#define	_FSBmapInsertKernRec	(BmapPairNode **) _FSFontInsertKernRec


/* These #defines are for generic font access routines that are used	*/
/* for bitmap fonts (see FSFontCach.c).					*/

#define	_FSBmapLockFont			_FSFontLockFont
#define	_FSBmapUnlockFont		_FSFontUnlockFont
#define	_FSBmapLockHeader		_FSFontLockHeader
#define	_FSBmapUnlockHeader		_FSFontUnlockHeader
#define	_FSBmapLockInfo			_FSFontLockInfo
#define	_FSBmapUnlockInfo		_FSFontUnlockInfo
#define	_FSBmapAutosetInfo		_FSFontAutosetInfo
#define	_FSBmapLockKernPairs		_FSFontLockKernPairs
#define	_FSBmapUnlockKernPairs		_FSFontUnlockKernPairs
#define	_FSBmapAppendCharDir		_FSFontAppendCharDir
#define	_FSBmapGetChar(x,y,z)		_FSFontGetChar (x, (FontCharNode **) y, z)
#define	_FSBmapLockCharInfo(x)		_FSFontLockCharInfo ((FontCharNode **) x)
#define	_FSBmapUnlockCharInfo(x)	_FSFontUnlockCharInfo ((FontCharNode **) x)
#define	_FSBmapLockModes		_FSFontLockModes
#define	_FSBmapUnlockModes		_FSFontUnlockModes
#define	_FSBmapLockCharDir		_FSFontLockCharDir
#define	_FSBmapUnlockCharDir		_FSFontUnlockCharDir
#define	_FSBmapLockCharDirTable		_FSFontLockCharDirTable
#define	_FSBmapUnlockCharDirTable	_FSFontUnlockCharDirTable
#define	_FSBmapNewKernPairs		_FSFontNewKernPairs
#define	_FSBmapKernValue		_FSFontKernValue


/* These functions provide access to bitmap fonts (see FSBmapCach.c).	*/

extern	BmapCharInfo	*_FSBmapCharInfo ();
extern	BmapBitmap	*_FSBmapCharBitmap ();
extern	BmapCharNode	**_FSBmapNewDirRec ();
extern	BmapCharNode	**_FSBmapInsertDirRec ();
extern	BmapBitmap	**_FSBmapNewMap ();
extern	BmapNode	**_FSBmapCreateBmap ();
extern  Int             _FSBmapLockCharBitmap (BmapCharNode **charNode);
extern  Int             _FSBmapUnlockCharBitmap (BmapCharNode **charNode);
extern  Int             _FSBmapFont (BmapNode **bmapNode);
extern  Int             _FSBmapUpdateHeader (BmapNode **bmapNode);
extern  Int             _FSBmapFree (BmapNode **bmapNode);
extern  Int             _FSBmapAutosetHeader (BmapNode **bmapNode);
extern  Int             _FSBmapPurgeChar (BmapCharNode **charNode);
extern  Int             _FSBmapPurgeableChar (BmapCharNode **charNode);
extern  Int             _FSBmapDeleteChar (BmapNode *bmapNode, CharId character);
extern  Int             _FSBmapHierarchicalUpdate (BmapNode **bmapNode);

#endif
