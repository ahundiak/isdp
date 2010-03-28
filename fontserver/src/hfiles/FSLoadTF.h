/* $RCSfile: fsloadtf.h $$Revision: 1.2 $$Date: 1990/12/13 13:24:18 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef	_LOADTF
#define	_LOADTF	0

#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSTFCache.h"

extern  Int     _FSCFTLoadInfo(FILE *fontStr, TFBlockHeader *infoHdr, TFInfo *info);
extern  Int     _FSTFCheck (FILE *fontStr);
extern  Int     _FSLoadOutlDataHdr (FILE *fontStr, TFInfo *info, TFBlockHeader *outlDataHdr);
extern  Int     _FSOutlDataSize (TFBlockHeader *outlDataHdr);
extern  Int     _FSCFTLoadOutlData(FILE *fontStr, TFInfo *info, TFBlockHeader *outlDataHdr, TFOutlines **outlData);
extern  Int     _FSLoadCharDirHdr (FILE *fontStr, TFInfo *info, TFBlockHeader *charDirHdr);
extern  Int     _FSLoadKernTrkHdr (FILE *fontStr, TFInfo *info, TFBlockHeader *kernTrackHdr);
extern  Int     _FSCFTLoadKernTrks(FILE *fontStr, TFInfo *info, TFBlockHeader *kernTrackHdr, TFKernTrack **kernTrack);
extern  Int     _FSCFTLoadCharDirs(FILE *fontStr, TFInfo *info, TFBlockHeader *charDirHdr, TFCharInfo **charDir);
extern  Int     _FSCFTLoadKernPrs(FILE *fontStr, TFInfo *info, TFBlockHeader *kernPairHdr, TFKernPair **kernPair);
extern  Int     _FSLoadXOutlData(FILE *fontStr, TFInfo *info, TFBlockHeader *outlinesHdr, TFOutlines *outlines);
extern  Int     _FSLoadXCharDirs(FILE *fontStr, TFInfo *info, TFBlockHeader *dirHdr, TFCharInfo *charDir);
extern  Int     _FSLoadXKernTrks(FILE *fontStr, TFInfo *info, TFBlockHeader *trackHdr, TFKernTrack *kernTrack);
extern  Int     _FSLoadXKernPrs(FILE *fontStr, TFInfo *info, TFBlockHeader *pairHdr, TFKernPair *kernPair);
extern  Int     _FSLoadXInfo(FILE *fontStr, TFBlockHeader *infoHdr, TFInfo *info);
extern  Int     _FSLoadKernPrHdr (FILE *fontStr, TFInfo *info, TFBlockHeader *kernPairHdr);
extern  Int     _FSReadChk (FILE *str, char *buffer, Int32 count);
extern  Int     _FSCFTUnload (TFStruct *cmfont);
extern  Int     _FSLoadOutlData(FILE *fontStr, TFStruct *cmfont);
extern  Int     _FSLoadCharDirs(FILE *fontStr, TFStruct *cmfont);
extern  Int     _FSLoadKernTrks(FILE *fontStr, TFStruct *cmfont);
extern  Int     _FSLoadKernPrs(FILE *fontStr, TFStruct *cmfont);
extern  Int     _FSMemoryAlloc(TFStruct *cmfont);
extern  Int     _FSBlockHSLoad(FILE *fontStr, TFStruct *cmfont);
extern  Int     _FSLoadInfo(FILE *fontStr, TFStruct *cmfont);
extern  Int     _FSCFTLoad(FILE *fontStr, TFStruct *cmfont);

#endif
