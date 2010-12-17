/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   cmdclass.h  $
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
|   cmdclass.h -- Command class values  				|
|									|
+----------------------------------------------------------------------*/
#if !defined (__cmdclassH__)
#define __cmdclassH__

#define INHERIT	     0
#define	PLACEMENT    1
#define	VIEWING	     2
#define	FENCE	     3
#define	PARAMETERS   4
#define	LOCKS	     5
#define	USERCOMMAND  6
#define	MANIPULATION 7
#define	SHOW	     8
#define	PLOT	     9
#define	NEWFILE	    10
#define	MEASURE	    11
#define	INPUT	    12
#define	CELLLIB	    13
#define	FILEDESIGN  14
#define	COMPRESS    15
#define	REFERENCE   16
#define	DATABASE    17
#define	DIMENSION   18
#define	LOCATE	    19
#define	TUTCLASS    20
#define	WORKINGSET  21
#define	ELEMENTLIST 22
#define	UNDO	    23
#define	SUBPROCESS  24
#define	VIEWPARAM   25
#define VIEWIMMED   26
#define WINDOWMAN   27
#define DIALOGMAN   28

#if defined (resource)
/* Options */
#define HID    	         (  1  )      /* Hidden */
#define DEF    	         (  1 << 1 )  /* Default */
#define REQ	         (  1 << 2 )  /* Required */
#define TRY	         (  1 << 3 )  /* Tryparse */

#define IMM    	         (  1 << 4 )
#define NOI    	    	 (  2 << 4 )

#define CMDSTR(a)        (  a <<  6 )  /* Command string number */
#define NONE    	          0
#endif	/* resource */

#endif	/* __cmdclassH__ */
