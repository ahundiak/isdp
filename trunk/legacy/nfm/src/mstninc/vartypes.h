/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   vartypes.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   vartypes.h -- Variable Type Constant Definitions			|
|									|
+----------------------------------------------------------------------*/
#ifndef __vartypesH__
#define __vartypesH__

/*----------------------------------------------------------------------+
|									|
|   Variable Type Constants						|
|									|
+----------------------------------------------------------------------*/
#define FMT_STRING	    1
#define FMT_SHORT	    2	    /* signed, 2 bytes */
#define FMT_LONG	    3	    /* signed, 4 bytes */
#define FMT_DPFP	    4	    /* double precision floating point */
#define FMT_BYTE	    5
#define FMT_VIEWINFO	    6	
#define FMT_TRANSFORM	    7
#define FMT_QWORD	    8
#define FMT_RAD5	    9	    /* radix 50 */
#define FMT_UWORD	    10	    /* unsigned, 2 bytes */
#define FMT_UINT	    11	    /* unsigned, 4 bytes */
#define	FMT_REG		    12
#define FMT_SCAN	    13
#define FMT_VAXF	    14
#define FMT_SWPINT	    15
#define FMT_UCDPFV	    0	    /* VAX double with words swapped */

#endif
