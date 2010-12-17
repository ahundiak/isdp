/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   system.h  $
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
|   system.h								|
|									|
+----------------------------------------------------------------------*/
#if !defined (__systemH__)
#define __systemH__

#if !defined (__basedefsH__)
#   include	<basedefs.h>
#endif
#if !defined (__basetypeH__)
#   include	<basetype.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|	File Filter Masks - Used for specifying file filter attributes  |
|			    for mdlFile_findFirst			|
|									|
|									|
+----------------------------------------------------------------------*/
#define	    FF_NORMAL	    0x0000
#define	    FF_READONLY	    0x0001
#define	    FF_SUBDIR	    0x0002
    
/*----------------------------------------------------------------------+
|									|
|	Share Mode values used as parameters to mdlFile_setDefaultShare.|
|									|
+----------------------------------------------------------------------*/

#define	    MDL_SHARE_COMPATIBILITY		0
#define	    MDL_SHARE_DENY_READ_WRITE		1
#define	    MDL_SHARE_DENY_WRITE		2
#define	    MDL_SHARE_DENY_READ			3
#define	    MDL_SHARE_DENY_NONE			4


/*----------------------------------------------------------------------+
|									|
|   Typedefs								|
|									|
+----------------------------------------------------------------------*/

typedef struct programVersionNumber
    {
    UShort   release:8;
    UShort   major:8;
    UShort   minor:16;
    } ProgramVersionNumber;

typedef struct mdlAppStatistics
    {
    unsigned long	    codeSize;
    unsigned long	    dataSize;
    unsigned long	    stackSize;
    unsigned long	    mallocedMemoryCount;
    unsigned long	    openFiles;
    unsigned long	    openResourceFiles;
    unsigned long	    loadedResources;
    unsigned long	    loadedResourcesMemory;
    ProgramVersionNumber    programVersion;
    } MdlAppStatistics;

    
/*----------------------------------------------------------------------+
|									|
|    FindFileInfo - Returned by mdlFile_findFirst and mdlFile_findNext	|
|									|
+----------------------------------------------------------------------*/
typedef struct findfileinfo
    {
    char    name[64];
    int	    attributes;
    ULong   time;
    ULong   date;
    ULong   size;
    } FindFileInfo;

#endif	/* __systemH__ */
