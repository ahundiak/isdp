#ifndef malloc_D_INCLUDED
#define malloc_D_INCLUDED 1

#define  PBLOCK  0
#define  CBLOCK  1

/* routines */

#if defined(__cplusplus)
extern "C" {
#endif
#if (defined(__STDC__) || defined(__cplusplus)) && !defined(_BLOCKPVT_H)
int    setblk     (void *blk);
int    resetblk   (void);
int  (*settrap ())(int (*fn)());
void  *malloc     (unsigned int size);
void   free       (void *ptr);
void  *realloc    (void *ptr, unsigned int size);
void  *calloc     (unsigned int nelem, unsigned int elsize);
#else  /* K&R "C" */
int    setblk     ();
int    resetblk   ();
int  (*settrap ())();
void  *malloc     ();
void   free       ();
void  *realloc    ();
void  *calloc     ();
#endif
#if defined(__cplusplus)
}
#endif


/*======== MALLOC (3X) compatability ===== MALLOC (3X) compatability ========*/

#define M_MXFAST	1	/* set size of blocks to be fast */
#define M_NLBLKS	2	/* set number of block in a holding block */
#define M_GRAIN		3	/* set number of sizes mapped to one, for
				   small blocks */
#define M_KEEP		4	/* retain contents of block after a free until
				   another allocation */

struct mallinfo  {
	int arena;	/* total space in arena            */
	int ordblks;	/* number of ordinary blocks       */
	int smblks;	/* number of small blocks          */
	int hblks;	/* number of holding blocks        */
	int hblkhd;	/* space in holding block headers  */
	int usmblks;	/* space in small blocks in use    */
	int fsmblks;	/* space in free small blocks      */
	int uordblks;	/* space in ordinary blocks in use */
	int fordblks;	/* space in free ordinary blocks   */
	int keepcost;	/* cost of enabling keep option    */
};	

struct mallinfo mallinfo ();
int             mallopt  ();

/*======== MALLOC (3X) compatability ===== MALLOC (3X) compatability ========*/

#endif
