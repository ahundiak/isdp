/* $RCSfile: fsio.h $$Revision: 1.2 $$Date: 1990/12/13 13:24:16 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _FONTIO
#define _FONTIO	0


/* These #defines are for generic font I/O routines that are used	*/
/* for bitmap fonts (see FSIO.c).					*/

#define	_FSReadBmapInfo		_FSReadFontInfo
#define	_FSReadBmapKernPair	_FSReadFontKernPair
#define	_FSReadBmapLigature	_FSReadFontLigature
#define	_FSWriteBmapInfo	_FSWriteFontInfo
#define	_FSWriteBmapKernPair	_FSWriteFontKernPair
#define	_FSWriteBmapLigature	_FSWriteFontLigature


/* These #defines are for generic font I/O routines that are used	*/
/* for outline fonts (see FSIO.c).					*/

#define	_FSReadOutlInfo		_FSReadFontInfo
#define	_FSReadOutlKernPair	_FSReadFontKernPair
#define	_FSReadOutlLigature	_FSReadFontLigature
#define	_FSWriteOutlInfo	_FSWriteFontInfo
#define	_FSWriteOutlKernPair	_FSWriteFontKernPair
#define	_FSWriteOutlLigature	_FSWriteFontLigature


#endif
