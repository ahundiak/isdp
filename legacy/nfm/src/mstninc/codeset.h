/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   codeset.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   codeset.h -- Code Set Handler Definitions				|
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
#if !defined (__codesetH__)
#define __codesetH__

#if !defined (__basedefsH__)
#include "basedefs.h"
#endif
#if !defined (__basetypeH__)
#include "basetype.h"
#endif
#if !defined (__msdefsH__)
#include "msdefs.h"
#endif

/*----------------------------------------------------------------------+
|									|
|   Code Set Constants							|
|									|
+----------------------------------------------------------------------*/
#define CODESET_OUTPUTBUFFER_SIZE	    10

/*----------------------------------------------------------------------+
|									|
|   Code Set Handler Messages						|
|									|
+----------------------------------------------------------------------*/
#define CODESET_MESSAGE_KEYSTROKE	    0
#define CODESET_MESSAGE_GETCHARNBYTES	    1

/*----------------------------------------------------------------------+
|									|
|   									|
|									|
+----------------------------------------------------------------------*/
typedef struct codesetmessage
    {
    boolean	    msgUnderstood;	/* <= message understood? */
    int		    messageType;	/* => message type */
    union	    
	{
	struct 
	    {
	    int	    outputBufferLength;	/* <= 0 means nothing done */
	    char    outputBuffer[CODESET_OUTPUTBUFFER_SIZE];	
					/* <= translated keystrokes */
	    int	    keystroke;		/* => keystroke */
	    } keystroke;
	struct
	    {
	    int	     nBytes;		/* <= # of bytes in char */
	    UChar    *charStartP;	/* => ptr to char start */
	    } charNBytes;
	} u;
    } CodeSetMessage;

#endif	/* __codesetH__ */
