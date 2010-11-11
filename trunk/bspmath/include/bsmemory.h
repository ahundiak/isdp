/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

HISTORY
02-JUL-1987 J. Brooke King Added safeguard for definition of "vms."
27-OCT-1986 J. Brooke King Creation
*/

# ifndef bsmemory_include
# define bsmemory_include

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

#   ifndef igrtypedef_include
#       include "igrtypedef.h"
#   endif

#   if vms || __vms || __vms__
	extern IGRchar *BSmemcpy();
#       define BSMEMCPY(numBytes, source, destination) \
            (BSmemcpy ((numBytes), (source), (destination)))

/*        IGRchar *BSmemcpy();	*/
#   else
        /* assuming System V */
/*
#       include <string.h>
#       define BSMEMCPY(numBytes, source, destination) \
            (memcpy ((destination), (source), (numBytes)))
*/
#       include "bsblkmv.h"
#       define BSMEMCPY(numBytes, source, destination) \
            (BSblkmv ((numBytes), (source), (destination)))
#   endif /* vms */

# endif /* bsmemory_include */
