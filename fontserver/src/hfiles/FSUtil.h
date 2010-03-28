/* $RCSfile: fsutil.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:18 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _UTIL
#define _UTIL	0


/** File reference structure **/
typedef struct
{
    char	fileName[512];		/* file name	*/
    uInt32	tag;			/* file tag	*/
} FileRef;


/** Routines **/
extern	uInt32	_FSGetFileTag ();
extern	char	*_FSGetFileFullPath ();
extern	char	*_FSFindFile ();
extern	char	*_FSGetBaseName ();
extern  int     _FSMemCopy (char *to, char *from, int count);


#endif
