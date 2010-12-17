/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   basedefs.h  $
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
|   basedefs.h -- Basic preprocessor definitions for MicroStation/MDL  	|
|									|
+----------------------------------------------------------------------*/
#if !defined (__basedefsH__)
#define __basedefsH__

#if defined (NULL)
#	undef	NULL
#endif
#if defined (TRUE)
#	undef	TRUE
#endif
#if defined (FALSE)
#	undef	FALSE
#endif

#define	    TRUE	1
#define	    FALSE	0
#define	    ON		1
#define	    OFF		0
#define	    SUCCESS	0x0000
#define	    ERROR	0x8000
#define	    byte	unsigned char
#define	    NULL	((void *) 0)
#define	    Void	int
#define	    boolean	int
#define	    Longint	long
#define	    Wordint	short
#define	    Public
#define	    MdlPublic
#define	    SemiPrivate

/* Removed from resource.h on 8/23/90 - WJD */
#define QUOTE 0x27
#define TAB   0x09
#define LF    0x0A
#define CR    0x0D
#define CNTRL_Z 0x1a
#define BACKSLASH 0x5c
#define BS	0x08
#define FF	0x0c

#if !defined (rm286)
#   define far
#endif	    

#if defined (noPrivate)
#define	    Private
#else
#define	    Private	static
#endif

/*----------------------------------------------------------------------+
|									|
|   Platform specific capabilities					|
|									|
+----------------------------------------------------------------------*/
#if defined (ip32)
#define DATA_ALIGNMENT_FORCED
#endif

#endif	/* __basedefsH__ */
