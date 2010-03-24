#ifndef UMCcomp_include
#define UMCcomp_include


#define	UMC_FILELEN	128

#define	UMC_BUFLEN	512

#define	UMC_IDXALLOC	250
#define	UMC_TEXTALLOC	8192
#define	UMC_EXTALLOC	2048
#define	UMC_KEY2ALLOC	256

#define	UMC_NOFILE	0
#define	UMC_CFILE	1
#define	UMC_FORFILE	2

#define UMC_BASE_MIN    1
#define UMC_BASE_MAX    2047

#define UMC_COMP_MIN    2

#define	UMC_COUNT_MAX	4095

typedef struct
{
	UMSFileHdr	hdr;
	int		idxAlloc;
	long		*fileIdx;
	unsigned	textAlloc;
	char		*textBuf;
	unsigned	extAlloc;
	char		*extBuf;
	unsigned	key2Alloc;
	char		*key2Buf;
	int		key2Count;
} UMCFileData;


#endif
