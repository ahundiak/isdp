




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/******************************* A L L O C . C *******************************

   Routines to allocate and deallocate memory 

 ****************************************************************************/




#include "../hfiles/stdef.h"
#include "../hfiles/alloc.h"
#include <malloc.h>


static ufix8 *alloc_buf=NULL;               /* pointer to storage area */
static ufix8 *allocp;                       /* next free position */
static ufix32 m = ALLOCSIZE;                /* amnt of free space (alloc.h) */

#ifdef MSDOS
static ufix8 *alloc_buf2=NULL;              /* pointer to storage area #2 */
static ufix8 *allocp2;                      /* next free position #2 */
static ufix32 m2 = ALLOCSIZE2;              /* amnt of free space (alloc.h) */
#endif /* MSDOS */


FUNCTION  void  initalloc()
/* routine to initialize dynamic memory
 *
 * NOTE: this routine should only be called once at the start of the 
 * the program. it gets the maximum amount of memory that it will need
 * from the sustem (malloc).
 */

    DECLARE
    void    alloc_reset();
#ifdef apollo
    void    aplo_memory_init();
#endif

    BEGIN
#ifdef apollo
    aplo_memory_init();
    if ((alloc_buf = (ufix8 *)malloc ((fix31) ALLOCSIZE)) == 0)
        {
        report_error ("initalloc: unable to malloc alloc_$buf");
        exit(1);
        }
#endif /* apollo */
#ifdef MSDOS
    if ( ((alloc_buf = (ufix8 *)halloc ((fix31) ALLOCSIZE, 1)) == 0)
      || ((alloc_buf2 = (ufix8 *)halloc ((fix31) ALLOCSIZE2, 1)) == 0) )
        {
        report_error("Insufficient memory available to run the Bitmap Font Generator");
        exit(1);
        }
#endif /* MSDOS */
#ifdef IPRO
    ipro_memory_init();
    if ((alloc_buf = (ufix8 *)malloc ((fix31) ALLOCSIZE)) == 0)
        {
        report_error ("initalloc: unable to malloc alloc_buf");
        exit(1);
        }
#endif /* interpro */

    alloc_reset();
    END




FUNCTION void alloc_reset() /* resets storage area */
/*
 *  resets global variables used by the memory allocation
 *  functions in this module. initalloc() should be called
 *  once before this routine is called.
 */
    DECLARE
    BEGIN
    allocp = (ufix8 *)alloc_buf;   /* beginning of storage area */
    m = ALLOCSIZE;                 /* amnt of free space */
#ifdef MSDOS
    allocp2 = (ufix8 *)alloc_buf2; /* beginning of storage area #2 */
    m2 = ALLOCSIZE2;               /* amnt of free space */
#endif /* MSDOS */
    END




FUNCTION  ufix32  alloccount()  /* returns total available free space */
    DECLARE
    BEGIN
    return(m);
    END




FUNCTION  void freealloc ()

    DECLARE
    BEGIN

#ifdef apollo
    if (alloc_buf) free (alloc_buf);
#endif /* apollo */
#ifdef MSDOS
    if (alloc_buf) hfree (alloc_buf);
    if (alloc_buf2) hfree (alloc_buf2);
#endif /* MSDOS */
#ifdef IPRO
    if (alloc_buf) free (alloc_buf);
#endif /* interpro */

    END


FUNCTION  ufix8  *alloc(n)      /* return pointer to n bytes */
  ufix32 n;

    DECLARE
    BEGIN
    n = (n + 3) & 0xfffffffc;   /* assign on 32-bit bdries */
    if (n <= m)                 /* if enough mem left */
        {
        allocp += n;            /* pt to next block*/
        m -= n;
        return(allocp - n);     /* return ptr to block */
        }
    else                        /* not enough memory */
        return(NULL);
    END





FUNCTION  bool  dealloc(p)      /* free memory from p */
  ufix8    *p;                  /* pointer to block of mem to be freed */

    DECLARE
    ufix32  n;

    BEGIN
    n = (ufix32)p;
    n = (n + 3) & 0xfffffffc;   /* deassign on 32-bit bdries */
    p = (ufix8 *)n;
    if ((p < alloc_buf)  ||  (p > allocp))     /* Kosher ptr? */
        return(FALSE);
    m += (ufix32)(allocp - p);
    allocp = p;                 /* recover space */
    return(TRUE);
    END



/* these next three memory allocation routines manage a second
 * second memory block. Two smaller memory blocks are preferable
 * to one large block for MSDOS. the cfont_ac module is the only
 * module that uses these routines.
 */


#ifdef MSDOS
FUNCTION  ufix32  alloccount2()  /* returns total available free space */
    DECLARE
    BEGIN
    return(m2);
    END
#endif /* MSDOS */


#ifdef MSDOS
FUNCTION  ufix8  *alloc2(n)      /* return pointer to n bytes */
  ufix32 n;

    DECLARE
    BEGIN
    n = (n + 3) & 0xfffffffc;   /* assign on 32-bit bdries */
    if (n <= m2)                 /* if enough mem left */
        {
        allocp2 += n;            /* pt to next block*/
        m2 -= n;
        return(allocp2 - n);     /* return ptr to block */
        }
    else                        /* not enough memory */
        return(NULL);
    END
#endif /* MSDOS */



#ifdef MSDOS
FUNCTION  bool  dealloc2(p)      /* free memory from p */
  ufix8    *p;                  /* pointer to block of mem to be freed */

    DECLARE
    ufix32  n;

    BEGIN
    n = (ufix32)p;
    n = (n + 3) & 0xfffffffc;   /* deassign on 32-bit bdries */
    p = (ufix8 *)n;
    if ((p < alloc_buf2)  ||  (p > allocp2))     /* Kosher ptr? */
        return(FALSE);
    m2 += (ufix32)(allocp2 - p);
    allocp2 = p;                 /* recover space */
    return(TRUE);
    END
#endif /* MSDOS */




/*
 *  BFG bitmap allocation routines: The memory required by a bitmap will vary
 *  very significantly, and could be very large. Because of this, it is
 *  a good idea to make it possible to allocate memory outside of standard
 *  BFG memory allocation. This allows ALLOCSIZE to be made significantly
 *  smaller.
 */

#ifdef MSDOS
bit8     temp_bfg_bmap[MAX_BMAP_BYTES];
#endif /* MSDOS */

FUNCTION  ufix8  *alloc_bitmap(n)      /* return pointer to n bytes */
  ufix32 n;

    DECLARE

    ufix8  *alloc();      /* return pointer to n bytes */

    BEGIN

#ifdef apollo
     return(alloc(n));
#endif /* apollo */
#ifdef MSDOS
     if (n > MAX_BMAP_BYTES)
         return (NULL);
     else
         return ((bit8 *)temp_bfg_bmap);
#endif /* MSDOS */
#ifdef IPRO
     return(alloc(n));
#endif /* interpro */

    END





FUNCTION  bool  dealloc_bitmap(p)      /* free memory from p */
  ufix8    *p;                  /* pointer to block of mem to be freed */

    DECLARE
    ufix32  n;

    BEGIN
#ifdef apollo
    /* It is assumed that all BFG memory that has been allocated for generating
     * one character is freed with on call to dealloc() elsewhere.
     */
    return (TRUE);
#endif /* apollo */
#ifdef MSDOS
    /* ms_dos does not dynamically allocate memory for the bitmap
     */
    return (TRUE);
#endif /* MSDOS */
#ifdef IPRO
    /* It is assumed that all BFG memory that has been allocated for generating
     * one character is freed with on call to dealloc() elsewhere.
     */
    return (TRUE);
#endif /* interpro */
    END
