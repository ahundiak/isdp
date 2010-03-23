/* $RCSfile: fstlcch.h $$Revision: 1.2 $$Date: 1990/12/13 13:24:20 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _MAKEOUTL
#define _MAKEOUTL	0


#include "FSTypes.h"
#include "FSOutl.h"
#include "FSFontCach.h"


/* These #defines are for generic font structures that are used for	*/
/* outline fonts (see FSFontCach.h).					*/

#define	OutlNode	FontNode
#define	OutlPairNode	FontPairNode
#define	OutlModes	FontModes
#define	OutlRegen	FontRegen
#define	OutlCharDir	FontCharDir


/* These functions provide access to outline fonts (see FSOutlCach.c).	*/

extern	OutlCharInfo	*_FSOutlCharInfo ();
extern	OutlPolySize	*_FSOutlCharPSize ();
extern	OutlVertex	*_FSOutlCharVert ();
extern	OutlCharNode	**_FSOutlFirstChar ();
extern	OutlCharNode	**_FSOutlNextChar ();
extern	OutlCharNode	**_FSOutlNewDirRec ();
extern	OutlCharNode	**_FSOutlInsertDirRec ();
extern	OutlPolySize	**_FSOutlNewPSize ();
extern	OutlVertex	**_FSOutlNewVert ();
extern	Outl3DVertex	**_FSOutlNew3DVert ();
extern	OutlNode	**_FSOutlCreateOutl ();


/* These #defines are for generic font access functions that are used	*/
/* for outline fonts (see FSFontCach.c).				*/

#define	_FSOutlHeader		(OutlHeader *) _FSFontHeader
#define	_FSOutlInfo		(OutlInfo *) _FSFontInfo
#define	_FSOutlKernPairs	(OutlKernPair *) _FSFontKernPairs
#define	_FSOutlFirstChar	(OutlCharNode **) _FSFontFirstChar
#define	_FSOutlNextChar		(OutlCharNode **) _FSFontNextChar
#define	_FSOutlCharDirEntry	(OutlCharNode ***) _FSFontCharDirEntry
#define	_FSOutlCharNode		(OutlCharNode **) _FSFontCharNode
#define	_FSOutlModes		(OutlModes *) _FSFontModes
#define	_FSOutlRegen		(OutlRegen *) _FSFontRegen
#define	_FSOutlCharDir		(OutlCharDir *) _FSFontCharDir
#define	_FSOutlCharDirTable	(OutlCharNode ***) _FSFontCharDirTable


/* These #defines are for generic font access routines that are used	*/
/* for outline fonts (see FSFontCach.c).				*/

#define	_FSOutlLockFont			_FSFontLockFont
#define	_FSOutlUnlockFont		_FSFontUnlockFont
#define	_FSOutlLockHeader		_FSFontLockHeader
#define	_FSOutlUnlockHeader		_FSFontUnlockHeader
#define	_FSOutlLockInfo			_FSFontLockInfo
#define	_FSOutlUnlockInfo		_FSFontUnlockInfo
#define	_FSOutlAutosetInfo		_FSFontAutosetInfo
#define	_FSOutlLockKernPairs		_FSFontLockKernPairs
#define	_FSOutlUnlockKernPairs		_FSFontUnlockKernPairs
#define	_FSOutlAppendCharDir		_FSFontAppendCharDir
#define	_FSOutlGetChar			_FSFontGetChar
#define	_FSOutlLockCharInfo		_FSFontLockCharInfo
#define	_FSOutlUnlockCharInfo		_FSFontUnlockCharInfo
#define	_FSOutlLockModes		_FSFontLockModes
#define	_FSOutlUnlockModes		_FSFontUnlockModes
#define	_FSOutlLockCharDir		_FSFontLockCharDir
#define	_FSOutlUnlockCharDir		_FSFontUnlockCharDir
#define	_FSOutlLockCharDirTable		_FSFontLockCharDirTable
#define	_FSOutlUnlockCharDirTable	_FSFontUnlockCharDirTable
#define	_FSOutlNewKernPairs		_FSFontNewKernPairs
#define	_FSOutlKernValue		_FSFontKernValue


#endif
