/*
******************************************************************************
** $Id: mytypes.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: mytypes.h
**
** This header defines basic type extensions used throughout the Software
** Evaluation Systems.  It also defines a prototyping macro which simplifies
** the declaration of function prototypes accross platforms.
******************************************************************************
*/

#if !defined(_MYTYPES_H_)
#define _MYTYPES_H_

#if defined(_SYSV_) || defined(HP_UX) || defined(_SUNOS_) 
#  include <sys/types.h>
#  if defined(_SUNOS_) || defined(HP_UX)
typedef unsigned char unchar;
typedef unsigned long ulong;
#  endif
#elif !defined(sgi)
typedef unsigned char  unchar;
typedef unsigned short ushort;
typedef unsigned int   uint;
typedef unsigned long  ulong;
#endif

/*
** The following macro is used to prune the prototype argument list based on
** the capabilities of the specific platform's compiler.
*/
#if !defined(_SUNOS_)
#    define OF(a) a
#else
#    define OF(a) ()
#endif

#endif /* _MYTYPES_H_ */
