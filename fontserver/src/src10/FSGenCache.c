/* $RCSfile: fsgncch.c $$Revision: 1.8 $$Date: 1992/10/25 10:48:09 $ Copyright (c) 1990 Intergraph Corp. */

/* This module provides generic storage facilities that, at this time,	*/
/* are used only to store fonts.  It provides storage in the private	*/
/* memory of a program and provides storage and caching in shared	*/
/* memory (since shared memory is a fixed size).			*/
/*									*/
/* All blocks are referenced by handles (double-indirection).  Blocks	*/
/* may therefore be relocated or purged if necessary (only in shared	*/
/* memory).								*/
/*									*/
/* Allocation and deallocation is performed in the current GCContext	*/
/* (which is either private memory or shared memory) by the current	*/
/* GCFunctions (private or shared memory functions).			*/

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <stdio.h>
#include <memory.h>
#include <malloc.h>
#include <unistd.h>
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSUtil.h"


#ifndef	NDEBUG
#ifndef GC_DEBUG
#define	GC_DEBUG	/* turn on debug for GC routines */
#endif
#endif


#define	SEM_KEY		0x4D535346	/* "FSSM"			*/
#define	SHM_KEY		0x48535346	/* "FSSH"			*/

#define	SHM_ADDR	((void *)0xF1000000)	/* shm address (must be fixed)	*/
#define	SHM_SIZE	0x400000	/* shm size (4M)		*/
#define	SHM_HEAP_OFFSET	0x400		/* offset to heap (size=4M-1K)	*/

#define	NUM_MPTRS 	1024		/* allocate this many mast ptrs	*/


typedef struct
{
    char	*address;	/* this field MUST come first to	*/
				/* allow double indirection		*/
    uInt16	flags;		/* flags (below)			*/
#ifdef	GC_DEBUG
    uInt32	size;
#endif
} MastPtr;	/* master pointer structure (handles point to these) */

/** values for flags field (above) **/
#define GC_LOCK_MASK	0x000F
#define GC_LOCK_INCR	0x0001
#define GC_USED		0x0010
#define GC_PURGEABLE	0x0020
#define	GC_END		0x8000


typedef struct	/* generic cache context structure */
{
    MastPtr	dir;		/* head of linked list of master ptrs	*/
    MastPtr	*start;		/* starting location for searches	*/
    int		numMastPtrs;	/* total number of mast ptrs allocated	*/
    int		usedMastPtrs;	/* total number of master ptrs used	*/
} GCContext;

typedef struct	/* generic cache function pointer structure */
{
    char	*(*malloc_)();	/* malloc function			*/
    char	*(*realloc_)();	/* realloc function			*/
    void	(*free_)();	/* free function			*/
    void	(*setHdl)();	/* set handle function			*/
    MastPtr	*(*newMPtrs)();	/* func that allocates master ptrs	*/
    void	(*compact)();	/* compaction function			*/
    int		(*purge)();	/* purge func (returns TRUE if purged)	*/
} GCFunctions;


typedef union _GCStore	/* shared memory store structure */
{
    struct
    {
	union _GCStore	*next;		/* next block in the arena	*/
	long		mPtr;		/* handle (ptr to mast ptr)	*/
					/*  NULL means no mast ptr	*/
    } d;
    double	align;		/* for alignment			*/
} GCStore;

#define	GC_BLOCK_USED	0x00000001	/* block is used		*/

#define	ShTestUsed(p)		((p)->d.mPtr & GC_BLOCK_USED)
#define	ShSetUsed(p)		((p)->d.mPtr |= GC_BLOCK_USED)
#define	ShClearUsed(p)		((p)->d.mPtr &= ~GC_BLOCK_USED)
#define	ShGetHandle(p)		(MastPtr *) ((p)->d.mPtr & ~GC_BLOCK_USED)
#define	ShSetHandle(p,h)	((p)->d.mPtr = ((long) h) | ((p)->d.mPtr & \
					GC_BLOCK_USED))


typedef struct	/* shared memory header structure */
{
    int		version;	/* version of shared memory		*/
    GCContext	context;	/* shared memory context		*/
    char	*heapStart;	/* pointer to start of heap		*/
    char	*heapEnd;	/* pointer to end of heap		*/
    GCStore	*startPtr;	/* starting point for searches		*/
    int		usedMemory;	/* sum of sizes of all used blocks	*/
    long	extra[16];	/* reserved for application use		*/
    long	reserved[16];	/* reserved for GC use			*/
} GCShMemHeader;


MastPtr	*_GCNewMastPtrs ();

char	*_GCShMalloc ();
char	*_GCShRealloc ();
void	_GCShFree ();
void	_GCShSetHandle ();
MastPtr	*_GCShNewMastPtrs ();
void	_GCShCompact ();



/** Data for normal memory context *************************************/
static GCContext _GCMemCon =	{
				    {	NULL, GC_END,
#ifdef	GC_DEBUG
					0	/* the 'size' field */
#endif
				    },
				    &_GCMemCon.dir, 0, 0
				};

/** Data for normal memory functions ***********************************/
static GCFunctions _GCMemFunc =	{
				    _FSMalloc, _FSRealloc, _FSFree, NULL,
				    _GCNewMastPtrs, NULL, NULL
				};


/** Data for shared memory header & context ****************************/
static GCShMemHeader _GCShMemHdr =
				{
				    0,	/* version # */
				    {
					{	NULL, GC_END,
#ifdef	GC_DEBUG
						0	/* the 'size' field */
#endif
					},
					NULL, 0, 0
				    },
				    NULL, NULL, NULL, 0, 0
				};

/** Data for shared memory functions ***********************************/
static GCFunctions _GCShMemFunc =
				{
				    _GCShMalloc, _GCShRealloc, _GCShFree,
				    _GCShSetHandle, _GCShNewMastPtrs,
				    _GCShCompact, NULL
				};


static GCContext	*GCShMemCon;		/* shared memory	*/
static GCFunctions	*GCShMemFunc =
				&_GCShMemFunc;	/* shared memory funcs	*/

static int		GCShmId;		/* shared memory id	*/
static char		*GCShmAddr;		/* shared memory addr.	*/
static int		GCShmSize;		/* size of shared mem.	*/
static GCShMemHeader	*GCShMemHdr;		/* shared memory header	*/

static int		GCSemId;		/* semaphore id		*/
static int		GCSemNest;		/* semaphore nest value	*/

static int		ShInit = FALSE;		/* TRUE: sh mem inited	*/


static GCContext	*GCMemCon = &_GCMemCon;	/* regular memory	*/
static GCFunctions	*GCMemFunc =
				&_GCMemFunc;	/* regular memory funcs	*/

static GCContext	*GCCon = &_GCMemCon;	/* current context	*/
static GCFunctions	*GCFunc = &_GCMemFunc;	/* current functions	*/



/************************/
/* "Public" GC routines */
/************************/

int _GCIpcRm(void)
{

	struct shmid_ds buf;

    shmdt (GCShmAddr);
	shmctl(GCShmId, IPC_RMID, &buf);
    ShInit = FALSE;
	semctl (GCSemId, 0, IPC_RMID, 1);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  Int _GCShEnter (ownerFlag)					*/
/*									*/
/*	  int	ownerFlag;	- T: I am shared memory owner		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes the shared memory.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

Int _GCShEnter (int ownerFlag)
{
    struct shmid_ds	shmStat;


    /** Get the shared memory **/
    if (ownerFlag)
	GCShmId = shmget (SHM_KEY, SHM_SIZE, IPC_CREAT | 0666);
    else
	GCShmId = shmget (SHM_KEY, 0, 0444);

    if (GCShmId == -1)
	return (FS_CANT_ALLOC);

    /** Attach the shared memory **/
    GCShmAddr = (char *) shmat (GCShmId, SHM_ADDR, 0);
    if (GCShmAddr == (char *) -1)
	return (FS_CANT_ALLOC);
    GCShMemHdr = (GCShMemHeader *) GCShmAddr;
    GCShMemCon = &GCShMemHdr->context;

    /** Get the shared memory semaphore **/
    if (ownerFlag)
	GCSemId = semget (SEM_KEY, 1, IPC_CREAT | 0666);
    else
	GCSemId = semget (SEM_KEY, 1, 0666);

    if (GCSemId == -1)
	return (FS_CANT_ALLOC);

    shmctl (GCShmId, IPC_STAT, &shmStat);
    GCShmSize = shmStat.shm_segsz;

    /** If I am the creator of the shm, initialize it **/
    if (shmStat.shm_cpid == getpid ())
    {
	GCStore	*startPtr, *endPtr;

	/** Initialize the header **/
	memcpy (GCShMemHdr, &_GCShMemHdr, sizeof (GCShMemHeader));
	GCShMemHdr->context.start = &GCShMemHdr->context.dir;
	GCShMemHdr->heapStart = GCShmAddr + SHM_HEAP_OFFSET;
	GCShMemHdr->heapEnd = GCShmAddr + SHM_SIZE;
	GCShMemHdr->usedMemory = sizeof (GCStore);

	/** Initialize the heap **/
	startPtr = (GCStore *) GCShMemHdr->heapStart;
	endPtr = ((GCStore *) GCShMemHdr->heapEnd) - 1;
	startPtr->d.next = endPtr;
	ShClearUsed (startPtr);
	endPtr->d.next = startPtr;
	ShSetUsed (endPtr);
	GCShMemHdr->startPtr = startPtr;

	/** Initialize the semaphore **/
	GCSemNest = 0;
	semctl (GCSemId, 0, SETVAL, 1);
    }

    ShInit = TRUE;

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCShExit ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine deallocates all shared memory used by the	*/
/*	  Generic Cache (GC) routines for this process.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCShExit (void)
{
    shmdt (GCShmAddr);
    ShInit = FALSE;
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCEnter ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes the Generic Cache (GC) structures.	*/
/*	  It must be called before any of the other GC routines.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

Int _GCEnter ()
{
    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCExit ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine deallocates all memory used by the Generic Cache	*/
/*	  (GC) structures.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCExit ()
{
    MastPtr *dp, *dp2, *nextDp;

    GCMemCon->numMastPtrs = GCMemCon->usedMastPtrs = 0;
    GCMemCon->start = &GCMemCon->dir;
    GCMemCon->dir.flags = GC_END;

    dp = (MastPtr *) GCMemCon->dir.address;
    if (dp == NULL)
	return;

    do
    {
	for (dp2 = dp; !(dp2->flags & GC_END); dp2++)
	{
	    if (dp2->flags & GC_USED)
		if (dp2->address != NULL)
		    (*GCMemFunc->free_) (dp2->address);
	}

	nextDp = (MastPtr *) dp[NUM_MPTRS].address;
	(*GCMemFunc->free_) (dp);
	dp = nextDp;
    } while (dp != (MastPtr *) GCMemCon->dir.address);
    GCMemCon->dir.address = NULL;
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCLockSem (shared)					*/
/*									*/
/*	  int	shared;		- if TRUE, lock the semaphore		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine locks the shared memory semaphore iff shared is	*/
/*	  TRUE.								*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCLockSem (shared)
int	shared;
{
#ifdef SHFONT

    static struct sembuf	lock = { 0, -1, SEM_UNDO };

    if (shared)
    {
	if (GCSemNest == 0)
	    semop (GCSemId, &lock, 1);
	GCSemNest++;
    }

#endif
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCUnlockSem (shared)					*/
/*									*/
/*	  int	shared;		- if TRUE, unlock the semaphore		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine unlocks the shared memory semaphore iff shared	*/
/*	  is TRUE.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCUnlockSem (shared)
int	shared;
{
#ifdef SHFONT

    static struct sembuf	unlock = { 0, 1, SEM_UNDO };

    if (shared)
    {
	GCSemNest--;
	if (GCSemNest == 0)
	    semop (GCSemId, &unlock, 1);
    }

#endif
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCSetMemory (shared)					*/
/*									*/
/*	  int		shared;		- TRUE: use shared memory	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the GC context to either shared or private	*/
/*	  memory.  All memory functions will be performed in this	*/
/*	  context.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCSetMemory (shared)
int	shared;
{
    GCCon = shared ? GCShMemCon : GCMemCon;
    GCFunc = shared ? GCShMemFunc : GCMemFunc;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _GCSharedMemory ()					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns TRUE iff the current GC context is for	*/
/*	  shared memory.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _GCSharedMemory ()
{
    return (GCCon == GCShMemCon);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _GCSharedAddr (addr)					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns TRUE iff the specified address is in	*/
/*	  shared memory.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _GCSharedAddr (addr)
char	*addr;
{
    if (ShInit)
	return ((addr >= GCShmAddr) && (addr < GCShmAddr + GCShmSize));
    else
	return (FALSE);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _GCShInited ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns TRUE iff shared memory has been		*/
/*	  initialized.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _GCShInited ()
{
    return (ShInit);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCSetSharedValue (index, value)				*/
/*									*/
/*	  int	index;		- which value to set (0 <= index < 16)	*/
/*	  long	value;		- the new value				*/
/*									*/
/*	DESCRIPTION							*/
/*	  There are 16 application-defined values in shared memory.	*/
/*	  This routine sets the specified shared memory value.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCSetSharedValue (index, value)
int	index;
long	value;
{
    if (ShInit)
	GCShMemHdr->extra[index] = value;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  long _GCGetSharedValue (index)				*/
/*									*/
/*	  int	index;		- which value to get (0 <= index < 16)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  There are 16 application-defined values in shared memory.	*/
/*	  This routine returns the specified shared memory value.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

long _GCGetSharedValue (index)
int	index;
{
    if (ShInit)
	return (GCShMemHdr->extra[index]);
    else
	return (0);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCSetPurgeFunc (func)					*/
/*									*/
/*	  void	(*func)();	- purge function			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sets the purge function of the current memory	*/
/*	  context.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCSetPurgeFunc (func)
int	(*func)();
{
    GCFunc->purge = func;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static char *_GCAllocMem (size)				*/
/*									*/
/*	  int	size;		- amount of memory needed (in bytes)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates a block in the cache and returns a	*/
/*	  pointer to the block.  It is used by _GCAlloc and _GCRealloc.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  NULL is returned if one of the following occurs:		*/
/*		- the memory could not be allocated			*/
/*									*/
/************************************************************************/

static char *_GCAllocMem (size)
int	size;
{
    int		purged;
    char	*ptr;

    ptr = (char *) (*GCFunc->malloc_) (size);
    if (ptr == NULL)
    {
	if (GCFunc->compact != NULL)
	{
	    (*GCFunc->compact) ();	/* compact */
	    ptr = (char *) (*GCFunc->malloc_) (size);
	    if (ptr == NULL)
	    {
		if (GCFunc->purge != NULL)
		{
		    do
		    {
			purged = (*GCFunc->purge) (size);	/* purge */
			ptr = (char *) (*GCFunc->malloc_) (size);
			if (ptr == NULL)
			{
			    (*GCFunc->compact) ();	/* compact */
			    ptr = (char *) (*GCFunc->malloc_) (size);
			}
		    } while ((ptr == NULL) && purged);
		}
	    }
	}
    }
    return (ptr);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static char *_GCReallocMem (ptr, size)			*/
/*									*/
/*	  char	*ptr;		- pointer to reallocate			*/
/*	  int	size;		- amount of memory needed (in bytes)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reallocates a block in the cache and returns a	*/
/*	  pointer to the block.  It is used by _GCRealloc.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  NULL is returned if one of the following occurs:		*/
/*		- the memory could not be allocated			*/
/*									*/
/************************************************************************/

static char *_GCReallocMem (ptr, size)
char	*ptr;
int	size;
{
    int		purged;
    char	*newPtr;

    newPtr = (char *) (*GCFunc->realloc_) (ptr, size);
    if (newPtr == NULL)
    {
	if (GCFunc->compact != NULL)
	{
	    (*GCFunc->compact) ();	/* compact */
	    newPtr = (char *) (*GCFunc->realloc_) (ptr, size);
	    if (newPtr == NULL)
	    {
		if (GCFunc->purge != NULL)
		{
		    do
		    {
			purged = (*GCFunc->purge) (size);	/* purge */
			newPtr = (char *) (*GCFunc->realloc_) (ptr, size);
			if (newPtr == NULL)
			{
			    (*GCFunc->compact) ();	/* compact */
			    newPtr = (char *) (*GCFunc->realloc_) (ptr, size);
			}
		    } while ((newPtr == NULL) && purged);
		}
	    }
	}
    }
    return (newPtr);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_GCAlloc (size)						*/
/*									*/
/*	  int	size;		- amount of memory needed (in bytes)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates a block in the cache and returns a	*/
/*	  handle to the block.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  The handle of the cache block, which can be used for double	*/
/*	  indirection, since the first field in a master pointer	*/
/*	  structure is the pointer to the memory allocated.  NULL is	*/
/*	  returned if one of the following occurs:			*/
/*		- the memory could not be allocated			*/
/*									*/
/************************************************************************/

char *_GCAlloc (size)
int	size;
{
    MastPtr *dp, *dpEnd, *newTable, *start;

    start = GCCon->start;
    if (GCCon->usedMastPtrs == GCCon->numMastPtrs)	/* need more ptrs? */
    {
	/** Find the end of the current master pointer table **/
	for (; !(start->flags & GC_END); start++);

	/** Get a new block of master pointers **/
	newTable = (*GCFunc->newMPtrs) (NUM_MPTRS);
	if (newTable == NULL)
	    return (NULL);
	GCCon->numMastPtrs += NUM_MPTRS;

	/** Initialize the new master pointers **/
	dpEnd = &newTable[NUM_MPTRS];
	for (dp = newTable; dp < dpEnd; dp++)
	    dp->flags = 0;
	dp->flags = GC_END;

	if (start->address == NULL)
	    dp->address = (char *) newTable;
	else
	    dp->address = start->address;
	start->address = (char *) newTable;

	start = (MastPtr *) start->address;
	GCCon->start = start;
    }

    /** Look for an empty master pointer **/
    for (;; start = (MastPtr *) start->address)
    {
	for (; !(start->flags & GC_END); start++)
	{
	    if (!(start->flags & GC_USED)) 
	    {
		if (size >= 0)
		{
		    size = ALIGN (size);
		    start->address = (char *) _GCAllocMem (size);
		    if (start->address == NULL)
			return (NULL);

		    if (GCFunc->setHdl != NULL)
			(*GCFunc->setHdl) (start->address, start);
		}
		else
		    start->address = NULL;

		GCCon->usedMastPtrs++;
		start->flags = GC_USED;
#ifdef	GC_DEBUG
		start->size = size;
#endif

		start++;	/* starting place for search next time */
		GCCon->start = start;

		/* return pointer to master pointer (i.e., handle to data) */
		return ((char *) (start - 1));
	    }
	}
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCRelease (handle)					*/
/*									*/
/*	  MastPtr	*handle;	- handle to be released		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine releases the memory allocated for the specified	*/
/*	  handle and makes it available for reuse.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCRelease (handle)
MastPtr	*handle;
{
    _FSAssert (handle != NULL);
    _FSAssert (handle->flags & GC_USED);

    if (handle->address != NULL)
	(*GCFunc->free_) (handle->address);

    handle->flags = 0;
    GCCon->usedMastPtrs--;

    GCCon->start = handle;	/* starting place for next search */
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_GCRealloc (handle, size)				*/
/*									*/
/*	  MastPtr	*handle;	- handle to reallocate		*/
/*	  int		size;		- new size of handle		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reallocates the data belonging to the given	*/
/*	  handle to the new size.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  The handle.  NULL is returned if one of the following		*/
/*	  occurs:							*/
/*		- the handle was not previously allocated		*/
/*		- the memory could not be allocated			*/
/*									*/
/************************************************************************/

char *_GCRealloc (handle, size)
MastPtr	*handle;
int	size;
{
    char *newPtr;

    _FSAssert (handle != NULL);
    _FSAssert (handle->flags & GC_USED);

    if (size >= 0)
    {
	size = ALIGN (size);
	if (handle->address == NULL)
	{
	    if ((newPtr = (char *) _GCAllocMem (size)) == NULL)
		return (NULL);
	}
	else
	{
	    if ((newPtr = (char *) _GCReallocMem
					(handle->address, size)) == NULL)
		return (NULL);
	}

	if (GCFunc->setHdl != NULL)
	    (*GCFunc->setHdl) (newPtr, handle);
    }
    else
    {
	if (handle->address != NULL)
	    (*GCFunc->free_) (handle->address);
	newPtr = NULL;
    }

#ifdef	GC_DEBUG
    handle->size = size;
#endif

    handle->address = newPtr;
    return ((char *) handle);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCLock (handle)						*/
/*									*/
/*	  MastPtr	*handle;	- handle to lock		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine locks the specified handle (i.e., makes it	*/
/*	  temporarily non-relocatable and unpurgeable).			*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCLock (handle)
MastPtr	*handle;
{
    int lockCount;

    _FSAssert (handle != NULL);

    /** Increment the lock count **/
    lockCount = (handle->flags & GC_LOCK_MASK) + GC_LOCK_INCR;
    _FSAssert ((lockCount & GC_LOCK_MASK) != 0);
    handle->flags = (handle->flags & ~GC_LOCK_MASK) | lockCount;
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCUnlock (handle)					*/
/*									*/
/*	  MastPtr	*handle;	- handle to unlock		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine unlocks the specified handle.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCUnlock (handle)
MastPtr	*handle;
{
    int lockCount;

    _FSAssert (handle != NULL);

    /** Decrement the lock count **/
    lockCount = (handle->flags & GC_LOCK_MASK);
    _FSAssert (lockCount > 0);
    lockCount -= GC_LOCK_INCR;
    handle->flags = (handle->flags & ~GC_LOCK_MASK) | lockCount;
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _GCLocked (handle)					*/
/*									*/
/*	  MastPtr	*handle;	- handle			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns TRUE iff the handle is locked.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  TRUE	- the handle is locked (it cannot be purged or moved)	*/
/*	  FALSE	- the handle is unlocked				*/
/*									*/
/************************************************************************/

int _GCLocked (handle)
MastPtr	*handle;
{
    _FSAssert (handle != NULL);
    return (handle->flags & GC_LOCK_MASK);
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCSetPurge (handle, purge)				*/
/*									*/
/*	  MastPtr	*handle;	- handle to make (un)purgeable	*/
/*	  int		purge;		- purge flag			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine makes the specified handle purgeable (i.e.,	*/
/*	  allows it to be deleted from memory) or unpurgeable.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCSetPurge (handle, purge)
MastPtr	*handle;
int	purge;
{
    _FSAssert (handle != NULL);

    if (purge)
	handle->flags |= GC_PURGEABLE;
    else
	handle->flags &= ~GC_PURGEABLE;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _GCGetPurge (handle)					*/
/*									*/
/*	  MastPtr	*handle;	- the handle			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the purge state of the specified handle.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  TRUE or FALSE.						*/
/*									*/
/************************************************************************/

int _GCGetPurge (handle)
MastPtr	*handle;
{
    _FSAssert (handle != NULL);
    return (handle->flags & GC_PURGEABLE);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCPurge (handle)					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine purges the specified handle.  If the handle is	*/
/*	  not purgeable, it is not purged.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCPurge (handle)
MastPtr	*handle;
{
    _FSAssert (handle != NULL);

    if (_GCGetPurge (handle) && !_GCLocked (handle))
	_GCRealloc (handle, -1);
}



/***************************/
/* Regular memory routines */
/***************************/


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  MastPtr *_GCNewMastPtrs ()					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates the standard number of new master	*/
/*	  pointers in regular memory (unshared).			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Pointer to new master pointers.				*/
/*									*/
/************************************************************************/

MastPtr *_GCNewMastPtrs ()
{
    return ((MastPtr *) (*GCMemFunc->malloc_)
				((NUM_MPTRS + 1) * sizeof (MastPtr)));
}




/**************************/
/* Shared memory routines */
/**************************/


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCShSetHandle (ptr, handle)				*/
/*									*/
/*	  GCStore	*ptr;		- ptr to the block		*/
/*	  MastPtr	*handle;	- the handle			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allows a block to remember its handle.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCShSetHandle (ptr, handle)
GCStore	*ptr;
MastPtr	*handle;
{
#ifdef SHFONT

    ShSetHandle (ptr - 1, handle);

#endif
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  MastPtr *_GCShNewMastPtrs ()					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates the standard number of new master	*/
/*	  pointers in shared memory.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Pointer to new master pointers.				*/
/*									*/
/************************************************************************/

MastPtr *_GCShNewMastPtrs ()
{
#ifdef SHFONT

    MastPtr	*mastPtrs;

    /** Allocate them as low as possible in shared memory **/
    GCShMemHdr->startPtr = (GCStore *) GCShMemHdr->heapStart;
    mastPtrs = (MastPtr *) _GCShMalloc ((NUM_MPTRS + 1) * sizeof (MastPtr));
    if (mastPtrs != NULL)
	_GCLock (mastPtrs);	/* master pointers must be locked!! */
    return (mastPtrs);

#endif
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static char *_GCShMallocCopy (size, ptr, oldSize)		*/
/*									*/
/*	  int	size;		- how many bytes to allocate		*/
/*	  char	*ptr;		- copy from here (NULL = don't copy)	*/
/*	  int	oldSize;	- how much to copy			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates the specified amount of memory from	*/
/*	  shared memory.  If ptr != NULL, oldSize bytes are copied from	*/
/*	  ptr to the new location.  The old and new pointers may	*/
/*	  overlap.  This allows reallocation of a block to function	*/
/*	  properly.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Pointer to new memory.					*/
/*									*/
/************************************************************************/

static char *_GCShMallocCopy (size, ptr, oldSize)
int	size;
char	*ptr;
int	oldSize;
{
#ifdef SHFONT

    int		blockSize, freeMem;
    GCStore	*p, *q, *r, *start;

    size = ALIGN (size);

    /** See if it can possibly fit **/
    freeMem = GCShMemHdr->heapEnd - GCShMemHdr->heapStart -
	      GCShMemHdr->usedMemory;
    if (size + sizeof (GCStore) > freeMem)
	return (NULL);

    p = start = GCShMemHdr->startPtr;
    do
    {
	if (!ShTestUsed (p))
	{
	    /** Combine all subsequent unused blocks into one unused block **/
	    for (q = p->d.next; !ShTestUsed (q); q = q->d.next);
	    p->d.next = q;
	    if ((p < start) && (start < q))
		start = q;	/* might have eaten the starting block */

	    /** Is this block big enough? **/
	    blockSize = (char *) q - (char *) p - sizeof (GCStore);
	    if (blockSize >= size)
		goto Found;
	}
	p = p->d.next;
    } while (p != start);
    return (NULL);

Found:
    /** Copy the data if necessary **/
    if ((ptr != NULL) && (ptr != ((char *) p + 1)))
	_FSMemCopy ((char *) (p + 1), ptr, oldSize);

    GCShMemHdr->usedMemory += size + sizeof (GCStore);

    /** Break it into 2 pieces if size is smaller than the free block **/
    if (size < blockSize)
    {
	r = (GCStore *) ((char *) p + size) + 1;
	_FSAssert (r >= (GCStore *) GCShMemHdr->heapStart);
	_FSAssert (r < (GCStore *) GCShMemHdr->heapEnd);

	ShClearUsed (r);
	r->d.next = p->d.next;
	p->d.next = r;
	GCShMemHdr->startPtr = r;	/* start here next time */

	/** If sufficiently fragmented, start next search at beginning **/
	if (((char *) GCShMemHdr->startPtr - GCShMemHdr->heapStart) >
	    (GCShMemHdr->usedMemory << 2))
	    GCShMemHdr->startPtr = (GCStore *) GCShMemHdr->heapStart;
    }
    p->d.mPtr = NULL;
    ShSetUsed (p);
    return ((char *) (p + 1));

#endif
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_GCShMalloc (size)				*/
/*									*/
/*	  int	size;		- how many bytes to allocate		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates the specified amount of memory from	*/
/*	  shared memory.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  Pointer to new memory.					*/
/*									*/
/************************************************************************/

char *_GCShMalloc (size)
int	size;
{
#ifdef SHFONT

    return (_GCShMallocCopy (size, (char *)NULL, 0));

#endif
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCShFree (ptr)						*/
/*									*/
/*	  char	*ptr;	- pointer to block				*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine frees the specified block from shared memory.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCShFree (ptr)
char	*ptr;
{
#ifdef SHFONT

    GCStore	*p;

    p = ((GCStore *) ptr) - 1;
    _FSAssert (p >= (GCStore *) GCShMemHdr->heapStart);
    _FSAssert (p < (GCStore *) GCShMemHdr->heapEnd);

    ShClearUsed (p);
    GCShMemHdr->startPtr = p;

    GCShMemHdr->usedMemory -= (char *) p->d.next - (char *) p;

#endif
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_GCShRealloc (ptr, size)				*/
/*									*/
/*	  char	*ptr;		- block to reallocate			*/
/*	  int	size;		- how many bytes to allocate		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reallocates the specified block in shared	*/
/*	  memory.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Pointer to new memory.					*/
/*									*/
/************************************************************************/

char *_GCShRealloc (ptr, size)
char	*ptr;
int	size;
{
#ifdef SHFONT

    int		oldSize;
    char	*newPtr;
    GCStore	*p;

    p = ((GCStore *) ptr) - 1;
    oldSize = (char *) p->d.next - (char *) p - sizeof (GCStore);
    _GCShFree (ptr);
    newPtr = _GCShMallocCopy (size, ptr, MIN (size, oldSize));
    return (newPtr);

#endif
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCShCompact ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine compacts the shared memory as much as possible.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCShCompact ()
{
#ifdef SHFONT

    int		size, bSize;
    MastPtr	*h;
    GCStore	*p, *q, *r, *end, *ptr, *last;

    end = ((GCStore *) GCShMemHdr->heapEnd) - 1;
    p = (GCStore *) GCShMemHdr->heapStart;
    do
    {
	if (!ShTestUsed (p))
	{
	    /** Combine all subsequent unused blocks into one unused block **/
	    for (q = p->d.next; !ShTestUsed (q); q = q->d.next);
	    p->d.next = q;

	    /** p points to unused block that is to be filled in.	**/
	    /** q points to next block, which is used.			**/

	    if (q != end)	/* don't move the end block */
	    {
		/** Find master pointer that belongs to next block **/
		h = ShGetHandle (q);

		/** Move this block only if it is unlocked **/
		if ((h != NULL) && !_GCLocked (h))
		{
		    size = (char *) q->d.next - (char *) q;
		    _FSMemCopy ((char *) p, (char *) q, size);
		    r = (GCStore *) ((char *) p + size);
		    r->d.next = p->d.next;
		    p->d.next = r;
		    ShSetUsed (p);
		    ShClearUsed (r);
		    h->address = (char *) (p + 1);
		}
		else	/* must work around this locked block */
		{
		    /** Fit as many blocks as possible into the unused	**/
		    /** space below the locked block			**/

		    size = (char *) q - (char *) p - sizeof (GCStore);
		    for (r = q->d.next; r != end; r = r->d.next)
		    {
			if (ShTestUsed (r))
			{
			    h = ShGetHandle (r);
			    if ((h != NULL) && !_GCLocked (h) &&
				((bSize = (char *) r->d.next - (char *) r -
				  sizeof (GCStore)) <= size))
			    {
				/** Relocate the block to where p points **/
				GCShMemHdr->startPtr = p;
				ptr = (GCStore *) _GCShMallocCopy (bSize,
						 (char *)(r+1), bSize);
				_FSAssert (ptr == p + 1);
				h->address = (char *) ptr;
				ShSetHandle (p, h);
				_GCShFree ((char *)(r + 1));
				p = p->d.next;

				size -= bSize;
				if (size == 0)	/* totally filled it up? */
				    break;
				size -= sizeof (GCStore);
			    }
			}
		    }
		}
	    }
	}
	last = p;
	p = p->d.next;
    } while (p != end);

    /** Reset the search start location to end of compacted blocks **/
    GCShMemHdr->startPtr = last;

#endif
}


/******************/
/* Debug routines */
/******************/


#ifdef	GC_DEBUG


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCRelocateAll ()					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine attempts to relocate all relocatable blocks.	*/
/*	  It is used for debugging.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCRelocateAll ()
{
    MastPtr	*dp;

    dp = (MastPtr *) GCCon->dir.address;
    if (dp == NULL)
	return;

    do
    {
	for (; !(dp->flags & GC_END); dp++)
	{
	    if ((dp->flags & GC_USED) && (dp->address != NULL) &&
		!_GCLocked (dp))
	    {
		char	*newPtr;

		newPtr = (char *) (*GCFunc->malloc_) (dp->size);
		memcpy (newPtr, dp->address, dp->size);
		if (GCFunc->setHdl != NULL)
		    (*GCFunc->setHdl) (newPtr, dp);

		(*GCFunc->free_) (dp->address);
		dp->address = newPtr;
	    }
	}
	dp = (MastPtr *) dp->address;
    } while (dp != (MastPtr *) GCCon->dir.address);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCCheck ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine checks the sanity of all master pointers.	*/
/*	  It is used for debugging.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCCheck ()
{
    int		count;
    MastPtr	*dp, *dp2;

    dp = (MastPtr *) GCCon->dir.address;
    if (dp == NULL)
	return;

    do
    {
	for (dp2 = dp, count = 0; !(dp2->flags & GC_END); dp2++, count++)
	{
	    if (dp2->address != NULL)
	    {
		if (dp2->size > 100000)
		    printf ("Possibly bad size at %d: %d\n", dp2 - dp, dp2->size);
	    }

	    if (dp2->flags & 0x7FC0)
	    {
		printf ("Bad flags at %d: %x\n", dp2 - dp, dp2->flags);
		exit (-1);
	    }
	}

	if (count != NUM_MPTRS)
	{
	    printf ("Bad GC_END encountered: %d\n", count);
	    exit (-1);
	}
	dp = (MastPtr *) dp[NUM_MPTRS].address;
    } while (dp != (MastPtr *) GCCon->dir.address);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCShCheck ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine checks the sanity of all master pointers in	*/
/*	  shared memory.  It is assumed that the GC context is set to	*/
/*	  shared memory.						*/
/*	  It is used for debugging.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCShCheck ()
{
    GCStore	*p, *end;
    MastPtr	*h;

    /** Check the master pointers **/
    _GCCheck ();

    /** Check the shared memory heap **/
    end = ((GCStore *) GCShMemHdr->heapEnd) - 1;
    for (p = (GCStore *) GCShMemHdr->heapStart; p != end; p = p->d.next)
    {
	if ((p->d.next < (GCStore *) GCShMemHdr->heapStart) ||
	    (p->d.next >= (GCStore *) GCShMemHdr->heapEnd))
	{
	    printf ("Bad block address in heap at 0x%x\n", p);
	    exit (-1);
	}

	if (ShTestUsed (p))
	{
	    h = ShGetHandle (p);
	    if (((h < (MastPtr *) GCShMemHdr->heapStart) ||
		 (h >= (MastPtr *) GCShMemHdr->heapEnd)) && (h != NULL))
	    {
		printf ("Bad handle in heap at 0x%x\n", p);
		exit (-1);
	    }
	}
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  void _GCShPrint ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine prints a list of all the blocks in the shared	*/
/*	  memory heap.							*/
/*	  It is used for debugging.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _GCShPrint ()
{
    GCStore	*p, *start;

    printf ("addr\t\t   size\t\tflags\thandle\n");
    printf ("----\t\t----------\t-----\t------\n");

    p = start = (GCStore *) GCShMemHdr->heapStart;
    do
    {
	MastPtr	*handle;

	printf ("0x%08x\t%10u\t", p,
		(char *) p->d.next - (char *) p - sizeof (GCStore));

	if (ShTestUsed (p))
	{
	    printf ("U");	/* used block */

	    handle = ShGetHandle (p);
	    if (handle != NULL)
	    {
		if (_GCLocked (handle))
		    printf ("L");	/* locked block */
		else
		    printf (" ");

		printf ("\t0x%08x", handle);
	    }
	    else
	    {
		printf (" P");	/* no handle to this block */
	    }
	}

	printf ("\n");

	p = p->d.next;
    } while (p != start);
}


#endif
