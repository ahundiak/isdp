/* $RCSfile: fschrmp.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:04 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _CHARMAP
#define _CHARMAP	0


#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSUtil.h"


#define CHARMAP_MAGIC	0x50414D43	/* "CMAP" */
#define	CM_CACHE_SIZE	4		/* size of char map cache */
#define MAX_CHARMAP	64		/* to support char map ids */

#define CM_PATH		  "/opt/ingr/resrc/fontserver/charmap"
#define	CM_PATH_VAR	"FS_CMPATH"
#define	CM_EXT		  ".cm"


/** Character mapping file header **/
typedef struct
{
    Int32	magic;		/* magic number				*/
    CharMapId	charMapId;	/* character mapping id			*/
    Int32	numChar;	/* total # of chars in char mapping	*/
    Char16	missingChar;	/* missing character id			*/
    Int32	flags;		/* #defined in FS.h			*/
    char	pad[14];	/* pad out to 32 packed bytes total	*/
}   CharMapHeader;


/** Character mapping cache entry **/
typedef struct
{
    uInt16	numChar;	/* total # of characters in char map	*/
    Char16	missingChar;	/* missing character id			*/
    Int32	flags;		/* #defined in FS.h and below		*/
    uInt32	tag;		/* unique tag number (dev# & inode#)	*/
    uInt32	timeStamp;	/* time stamp				*/
    CharMapSpec	*charId;	/* array of CharMapSpec sorted by bsNbr	*/
    CharMapSpec	*bsNbr;		/* array of CharMapSpec sorted by charId*/
}   CharMapStruct;

#define	FS_CM_USED	0x80000000	/* char map cache slot used	*/
#define	FS_CM_LOCKED	0x40000000	/* char map cache slot locked	*/

extern CharMapStruct _FSCharMapCache[];


/** Char map id/file xref table entry (to support char map ids) **/
typedef struct
{
    int			refCount;	/* reference count (0 = unused)	*/
    char		*fileName;	/* name of char map file	*/
    uInt32		tag;		/* unique tag number		*/
    CharMapStruct	*cachePtr;	/* index into char map cache	*/
}   CharMapEntry;

extern CharMapEntry	_FSCharMapTable[];

extern char	_FSCMPathVar[];
extern char	_FSCMDefPath[];
extern char	_FSCMExtension[];


/** Routines **/
extern	Char16	_FSCharMapBsNbr ();
extern	CharId	_FSCharMapCharId ();
extern  int     _FSCacheCharMapFile (FileRef *cmRef, CharMapStruct **cachePtr);
extern  int     _FSCacheCharMap (CharMapSpec *charMapSpec, int numChar,
        CharId missingChar, Int32 flags, uInt32 tag, CharMapStruct **cachePtr);
extern  int     _FSAddCharMapId (CharMapId *charMapId, int useId,
        char *fileName, CharMapStruct *cachePtr);
extern  Int     FSReadCharMapFile (char *fileName, CharMapId *charMapId);
extern  int     _FSReadCharMapHeader (FILE *file, CharMapHeader *header);
extern  int     _FSReadCharMapChars (FILE *file, CharMapSpec *charMap,
        int numChar);
extern  int     _FSWriteCharMapChars (FILE *file, CharMapSpec *charMap,
        int numChar);
extern  int     _FSWriteCharMapHeader (FILE *file, CharMapHeader *header);
extern  int     _FSInitCharMap (void);
extern  int     _FSDisposeCharMap (void);
extern  int     _FSGetCharMapRef (char *charMap, FileRef *cmRef);
extern  int     _FSGetCharMap (FileRef *cmRef, CharMapStruct **cachePtr);


#endif
