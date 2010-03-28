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

extern  int     _FSReadBmapHeader (FILE *file, BmapHeader *hdr);
extern  int     _FSReadFontInfo (FILE *file, FontInfo *info, int version);
extern  int     _FSReadFontKernPair (FILE *file, FontKernPair *kernPair, int version);
extern  int     _FSReadBmapCharInfo (FILE *file, BmapCharInfo *info, int version);
extern  int     _FSReadOutlHeader (FILE *file, OutlHeader *hdr);
extern  int     _FSReadOutlCharInfo (FILE *file, OutlCharInfo *info, int version);
extern  int     _FSReadOutlPolySize (FILE *file, OutlPolySize *pSize, int count, int version);
extern  int     _FSReadOutl3DVertex (FILE *file, Outl3DVertex *vert, int count, int version);
extern  int     _FSReadOutlVertex (FILE *file, OutlVertex *vert, int count, int version);
extern  int     _FSWriteOutlHeader (FILE *file, OutlHeader *hdr);
extern  int     _FSWriteOutlCharInfo (FILE *file, OutlCharInfo *info);
extern  int     _FSWriteOutlPolySize (FILE *file, OutlPolySize *pSize, int count);
extern  int     _FSWriteOutl3DVertex (FILE *file, Outl3DVertex *vert, int count);
extern  int     _FSWriteOutlVertex (FILE *file, OutlVertex *vert, int count);
extern  int     _FSWriteBmapHeader (FILE *file, BmapHeader *hdr);
extern  int     _FSWriteFontInfo (FILE *file, FontInfo *info);
extern  int     _FSWriteFontKernPair (FILE *file, FontKernPair *kernPair);
extern  int     _FSWriteBmapCharInfo (FILE *file, BmapCharInfo *info);
extern  int     _FSWriteBmapBitmap (FILE *file, BmapBitmap *bitmap, int size);

#endif
