/* $RCSfile: fsloadtf.h $$Revision: 1.2 $$Date: 1990/12/13 13:24:18 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef	_LOADTF
#define	_LOADTF	0


#include "FSTypeface.h"


typedef struct
{
    TFBlockHeader	infoHdr;	/* font info block header	*/
    TFInfo		info;		/* general font information	*/
    TFBlockHeader	kernPairHdr;	/* kerning pair data block hdr	*/
    TFKernPair		*kernPair;	/* ptr to kern pair records	*/
    TFBlockHeader	ligatureHdr;	/* ligature data block header	*/
    TFLigature		*ligature;	/* ptr to ligature records	*/
    TFBlockHeader	kernTrackHdr;	/* kerning track data block hdr	*/
    TFKernTrack		*kernTrack;	/* ptr to kern track records	*/
    TFBlockHeader	charDirHdr;	/* char directories block hdr	*/
    TFCharInfo		*charDir;	/* ptr to char directory recs	*/
    TFBlockHeader	outlinesHdr;	/* outline data block header	*/
    TFOutlines		*outlines;	/* ptr to comp outline data	*/
}   TFStruct;	/* typeface (compressed outline) structure */


#endif
