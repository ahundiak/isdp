#ifndef  _BLOCK_H
#define  _BLOCK_H  1

#define  MAL_ABORT         0
#define  MAL_RETRY         1
#define  MAL_DFLT     (int (*)())0


#ifndef _BLOCKPVT_H
typedef char BLOCK;
#endif


/* routines */

#if defined(__cplusplus)
extern "C" {
#endif
#if defined(__STDC__) || defined(__cplusplus)
BLOCK     *defineblk    (void *start, unsigned int size);
BLOCK     *defineblkopt (void *start, unsigned int size,
				unsigned int maxsmall, unsigned int numsmall);
int        growblk      (BLOCK *blk, void *addr, unsigned int size);
unsigned   allocsz      (void *ptr, int incall);
int      (*memtrap ())  (BLOCK *blk, int (*fn)());
char      *blkalloc     (BLOCK *blk, unsigned int nbytes);
int        blkfree      (BLOCK *blk, void *ptr);
char      *blkrealloc   (BLOCK *blk, void *ptr, unsigned int nbytes);
char      *blkcalloc    (BLOCK *blk, unsigned int nbytes);
#else  /* K&R "C" */
BLOCK     *defineblk    ();
BLOCK     *defineblkopt ();
int        growblk      ();
unsigned   allocsz      ();
int      (*memtrap ())  ();
char      *blkalloc     ();
int        blkfree      ();
char      *blkrealloc   ();
char      *blkcalloc    ();
#endif
#if defined(__cplusplus)
}
#endif

#endif
