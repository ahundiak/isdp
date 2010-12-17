/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Header:   I:/include/strlist.h_v   
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
|   strlist.h -- String List definitions used by			|
|		  MicroStation/MDL					|
|									|
+----------------------------------------------------------------------*/
#ifndef __filelistH__
#define __filelistH__


/*----------------------------------------------------------------------+
|									|
|   File system separators						|
|									|
+----------------------------------------------------------------------*/
#if defined (msdos)
#define Separator '\\'
#endif

#if defined (unix)
#define Separator '/'
#endif    

/*----------------------------------------------------------------------+
|									|
|   File User Message Constants						|
|									|
+----------------------------------------------------------------------*/
#define FILELISTTYPE_UPDATE	    1
#define FILELISTTYPE_SETFILENAME    2
#define FILELISTTYPE_SETFILTER	    3

#define FILELISTDATA_DRIVES	    1
#define FILELISTDATA_DIRECTORIES    2
#define FILELISTDATA_FILES	    3

/*----------------------------------------------------------------------+
|									|
|   File List Attributes Constants					|
|									|
+----------------------------------------------------------------------*/
#define FILELISTATTR_SORT		0x00000001
#define FILELISTATTR_UNIQUE		0x00000002
#define FILELISTATTR_CASESENSITIVE	0x00000004
#define FILELISTATTR_MULTIPLE		0x00000008
#define FILELISTATTR_CANSELECTEXISTING  0x00000010
#define FILELISTATTR_CANSELECTNEW	0x00000020
    
#define FILELISTATTR_DRIVES		0x00000040
#define FILELISTATTR_DIRECTORIES	0x00000080
#define FILELISTATTR_FILES		0x00000100

/*
*   If you are doing a create and the file to be created already exists,
*   specifying the following attribute will put up an alert asking you
*   to confirm that choice. Choosing OK will overwrite the existing file,
*   Cancel will allow you to choose another file to create.
*   Ignored for FILELISTATTR_MULTIPLE.
*/
#define FILELISTATTR_ALERTONCREATEEXIST	0x00001000
    
#define FILELISTATTR_OPEN	    FILELISTATTR_CANSELECTEXISTING
#define FILELISTATTR_CREATE	    (FILELISTATTR_CANSELECTNEW | \
				     FILELISTATTR_ALERTONCREATEEXIST)
#define FILELISTATTR_OPENCREATE	    (FILELISTATTR_CANSELECTEXISTING | \
				     FILELISTATTR_CANSELECTNEW | \
				     FILELISTATTR_ALERTONCREATEEXIST)

#define FILELISTATTR_DEFAULT	    (FILELISTATTR_SORT | \
				     FILELISTATTR_UNIQUE | \
				     FILELISTATTR_MULTIPLE | \
				     FILELISTATTR_OPEN | \
				     FILELISTATTR_FILES)


typedef struct filelistinfo
    {
    int	    lastAction;
    char    lastDirectory[MAXFILELENGTH];
    char    lastFilter[MAXEXTENSIONLENGTH];
    } FileListInfo;
    

#endif