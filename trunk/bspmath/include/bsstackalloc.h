/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

HISTORY
15-NOV-91 D. Breden#if DEBUG,BSSTACK[DE]ALLOC call BSdbgsalloc/BSdbgsfree.
05-SEP-1991 V.W.Ye #if DEBUG, BSSTACK[DE]ALLOC call BSdbgalloc/BSdbgfree.
02-JUL-1987 J. Brooke King Added safeguard for definition of "vms."
28-OCT-1986 J. Brooke King BS'ification.

*/

# ifndef bsstackalloc_include
# define bsstackalloc_include

/* some C preprocessors do not assume a zero value for undefined
    identifiers: */
# ifndef vms
# define vms 0
# endif
# ifndef __vms
# define __vms 0
# endif
# ifndef __vms__
# define __vms__ 0
# endif

#   if vms || __vms || __vms__
        char *malloc();
        int free ();

#       define BSstackalloc(size)   malloc(size)
#       define BSstackdealloc(ptr)  (void)free (ptr)

#   else
        /* assuming clipper System V, sun or other */

#       include <stdlib.h>
#       include "bsdbgsalloc.h"
#       include "bsdbgsfree.h"

/*
#       define BSstackalloc(size)  malloc(size)
#       define BSstackdealloc(ptr) free(ptr)
*/

#       define BSstackalloc(size)  BSdbgsalloc(size)
#       define BSstackdealloc(ptr) BSdbgsfree(ptr)

#   endif /* vms */

# endif /* bsstackalloc_include */
