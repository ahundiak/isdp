/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mdlio.h  $
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
|   mdlio.h - File I/O definitions and data structures for MDL  	|
|									|
+----------------------------------------------------------------------*/
#if !defined (__mdlioH__)
#define __mdlioH__

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/

/*  Origin specifications for fseek.	*/
#ifndef	    SEEK_SET
#define	    SEEK_SET	(00)
#define	    SEEK_CUR	(01)
#define	    SEEK_END	(02)
#endif

#if !defined (EOF)
#define	    EOF		(-1)
#endif

#if defined (mdl)
#if defined (msdos)
#define _IOFBF	    (1)
#define _IOLBF	    (1)
#define _IONBF	    (0)
#define BUFSIZ	    (512)
#endif
#if defined (ip32)
#define _IOFBF	    (0000)
#define _IOLBF	    (0100)
#define _IONBF	    (0004)
#define BUFSIZ	    (1024)
#endif
#endif

/*----------------------------------------------------------------------+
|									|
|   Typedefs								|
|									|
+----------------------------------------------------------------------*/

#if defined (mdl)
typedef	void FILE;
#endif

#endif	/* __mdlioH__ */
