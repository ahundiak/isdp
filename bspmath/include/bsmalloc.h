/* 

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

HISTORY
19-NOV-91 D. Breden #if DEBUG, BSrealloc call BSdbgralloc.
15-NOV-91 D. Breden #if DEBUG, BSMALLOC/BSFREE call BSdbgalloc/BSdbgfree.
02-JUL-1987 J. Brooke King Added safeguard for definition of "vms."
28-OCT-1986 J. Brooke King Creation.

*/

# ifndef bsmalloc_include
# define bsmalloc_include

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
        char *malloc(), *realloc();
        int free ();

#       define BSmalloc(size)       malloc(size)
#       define BSdealloc(ptr)       (void)free (ptr)
#       define BSrealloc(ptr, size) realloc(ptr, size)

#   else
        /* assuming clipper System V, sun or other */

#       include <stdlib.h>
#       include "bsdbgalloc.h"
#       include "bsdbgralloc.h"
#       include "bsdbgfree.h"

#       define BSmalloc(size)	    BSdbgalloc(size)
#       define BSdealloc(ptr)       BSdbgfree(ptr)
#       define BSrealloc(ptr, size) BSdbgralloc(ptr, size)
/*
#       define BSmalloc(size)       malloc(size)
#       define BSdealloc(ptr)       free(ptr)
#       define BSrealloc(ptr, size) realloc(ptr, size)
*/

#   endif /* vms */

# endif /* bsmalloc_include */
