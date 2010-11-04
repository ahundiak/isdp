/* $RCSfile: fstfcch.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:16 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _TFCACHE
#define _TFCACHE	0


#include "FSTypes.h"
#include "FS.h"
#include "FSTypeface.h"
#include "FSUtil.h"


#define	TF_CACHE_SIZE	4		/* size of typeface cache */

#define TF_PATH		  "/opt/ingr/resrc/fontserver/typeface"
#define	TF_PATH_VAR	"FS_TFPATH"
#define	TF_EXT		  ".tf"


typedef struct
{
    TFBlockHeader	 infoHdr;	     /* font info block header	*/
    TFInfo		     info;		      /* general font information	*/
    TFBlockHeader	 kernPairHdr;	  /* kerning pair data block hdr	*/
    TFKernPair		*kernPair;	    /* ptr to kern pair records	*/
    TFBlockHeader	 ligatureHdr;	  /* ligature data block header	*/
    TFLigature		*ligature;	    /* ptr to ligature records	*/
    TFBlockHeader	 kernTrackHdr;	/* track kerning data block hdr	*/
    TFKernTrack		*kernTrack;	    /* ptr to track kern records	*/
    TFBlockHeader	 charDirHdr;	  /* char directories block hdr	*/
    TFCharInfo		*charDir;	      /* ptr to char directory recs	*/
    TFBlockHeader	 outlinesHdr;	  /* outline data block header	*/
    TFOutlines		*outlines;	    /* ptr to comp outline data	*/
    char		      *memory;	      /* memory allocated for tf	*/
}   TFStruct;	/* typeface (compressed outline) structure */


/** Typeface cache entry **/
typedef struct
{
    TFStruct	typeface;	/* typeface structure			*/
    uInt32	tag;		/* unique tag number (dev# & inode#)	*/
    uInt32	timeStamp;	/* time stamp				*/
    uInt32	flags;		/* flags (below)			*/
}   TFEntry;

#define	FS_TF_USED	0x80000000	/* typeface cache slot used	*/

extern TFEntry	_FSTFCache[];


extern char	_FSTFPathVar[];		/* tf search path env variable	*/
extern char	_FSTFDefPath[];		/* tf default path		*/
extern char	_FSTFExtension[];	/* typeface file extension	*/
extern int      _FSInitTF (void);
extern int      _FSDisposeTF (void);
extern int      _FSGetTFRef (char *typeface, FileRef *tfRef);
extern int      _FSGetTF (FileRef *tfRef, TFStruct **cachePtr);


#endif
