/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   rscdefs.h  $
|   $Revision: 1.1 $ $Date: 1995/10/17 23:24:04 $
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
|  RSCDEFS.H - Resource Manager Structure Definitions and Constants	|
|									|
+----------------------------------------------------------------------*/
#ifndef __rscdefsH__
#define __rscdefsH__

#ifndef __basetypeH__
#include    <basetype.h>
#endif

#ifndef __mdlioH__
#include    <mdlio.h>
#endif

#ifndef __mdlerrsH__
#include    <mdlerrs.h>
#endif

/*----------------------------------------------------------------------+
|									|
| Defines								|
|									|
+----------------------------------------------------------------------*/
/* mdlResource_query Id's. "Given a pointer to a resource, return ..." */
#define RSC_QRY_SIZE 	    	 1  /* "... size of the resource." */
#define RSC_QRY_TYPE 	    	 2  /* "... type of the resource." */
#define RSC_QRY_ID    	    	 3  /* "... id of the resource." */
#define RSC_QRY_FILEHANDLE    	 4  /* "... fh where resource was loaded." */
#define RSC_QRY_FILENAME    	 5  /* "... file where resource was loaded." */
#define RSC_QRY_ALIAS	    	 7  /* "... alias name of the resource." */

/* mdlResource_queryClass Ids. "Given rsc fhandle and rsc class, return ..." */
#define RSC_QRY_COUNT	    	 6  /* "... number of rsrcs of this class. */
/*      RSC_QRY_ID (defined above)  /* "... nth configured rscId of class. */
#define RSC_QRY_AVAIL_ID    	13  /* "... next available id of the class. */
#define RSC_QRY_NEG_ID    	14  /* undocumented */

/* mdlResource_queryFile Id's. "Given resource file name, return..." */
#define RSC_QRY_NUMTYPES    	 8  /* "... number of classes in file." */
#define RSC_QRY_VERSION	    	 9  /* "... application version of file." */
#define RSC_QRY_SYSVERSION      10  /* undocumented */
#define RSC_QRY_IDENT	    	11  /* "... resource file identity string." */
#define RSC_QRY_MDLAPPLLIST     12  /* undocumented */
#define RSC_QRY_CLASS	    	15  /* "... nth configured class of file. */

/* File open modes */
#define RSC_READONLY	     	 0
#define RSC_READWRITE	     	 1

/*----------------------------------------------------------------------+
|  Internal Microstation Resource Type Identifiers   			|
|      	  (Hex constants used for     					|
|      	   benefit of MSC compiler)   					|
+----------------------------------------------------------------------*/
#define RTYPE_MESSAGES    0x73747223	    /* 'str#' */
#define RTYPE_STRINGLIST  0x7374724c	    /* 'strL' */
#define RTYPE_COMMAND     0x436d6473	    /* 'Cmds' */
#define RTYPE_CMDNAME     0x436d644e	    /* 'CmdN' */
#define RTYPE_ERRMSGS     0x45727273	    /* 'Errs' */
#define RTYPE_XLATE	  0x586c6174	    /* 'Xlat' */
#define RTYPE_UCMVAR	  0x55636d56	    /* 'UcmV' */
#define RTYPE_CHARXLT     0x43586c74	    /* 'CXlt' */
#define RTYPE_USERPREFS	  0x55707266	    /* 'Uprf' */

/* USCONFIG and USINSTAL Types */
#define RTYPE_CNFGDATA    0x436e6644	    /* 'CnfD' */
#define RTYPE_CNFGMENU    0x436e664d	    /* 'CnfM' */

/* Database Server Types. */
#define RTYPE_DBCOMMAND   0x44424364	    /* 'DBCd' */

/* MDL Types. */
#define RTYPE_MDLDBGCMD   0x4d646c44	    /* 'MdlD' */
#define RTYPE_MDLIMAGE    0x4d646c49	    /* 'MdlI' */

/* C Expression Evaluation */
#define RTYPE_CMEMBER		'CEme'
#define RTYPE_CNAME		'CEna'
#define	RTYPE_CSTRUCT_NAME	'CEst'
#define RTYPE_CTYPE		'CEty'

/* General items. */
#define RTYPE_INTEGER		'Intg'

/*----------------------------------------------------------------------+
|									|
|   Published Internal Microstation Resource Identifiers    		|
|									|
+----------------------------------------------------------------------*/
/* Character Translation Tables */
#define	RSCID_NATIVE_TO_INTERNAL	    -1
/* String Lists */
#define RSCID_MESSAGES			    -1
#define RSCID_MESSAGES2			    -2
#define RSCID_CMDNAMES			    -3
#define RSCID_USCONFIG			    -4
#define RSCID_DBMSGS			    -5
#define	RSCID_UNIXENV			    -6	/* Unix env var names */
#define	RSCID_ENVEXCL			    -7  /* Env Var exlusion list */
/* Error Lists */
#define RSCID_ERRMSGS			    -1
#define RSCID_DBERRS			    -2

/*----------------------------------------------------------------------+
|									|
| Typedefs								|
|									|
+----------------------------------------------------------------------*/
typedef	unsigned long	RscFileHandle;	/* Resource File handle (index). */

/*----------------------------------------------------------------------+
|									|
|    StringList Resource Definition					|
|									|
+----------------------------------------------------------------------*/
#if defined (resource)
typedef struct __stringlist__
    {
    ULong	numInfoFields;
    struct strings
    	{
	ULong	infoFields[];
    	char    string[];
    	} Strings [];
    }  StringList;

resourceclass	StringList    RTYPE_STRINGLIST;
#else
struct __stringlist__
    {
    ULong   expectedNumInfoFields;
    ULong   numRecs;
    /* First string record. */
    struct strings
    	{
	ULong   actualNumInfoFields;
    	ULong   firstInfoField;
/*
    	.
    	.
	.
	ULong   lastInfoField;
	ULong	msgSize;
    	char    msg[1];
*/
    	} Strings;
    };
#endif

/*----------------------------------------------------------------------+
|									|
|    MessageList Resource Definition					|
|									|
+----------------------------------------------------------------------*/
#if defined (resource)
typedef struct __messagelist__
    {
    ULong	1;	/* Number of expected infoFields per string. */
    struct messages
    	{
    	ULong   infoFields[];
    	char    msg[];
    	} Messages [];
    }  MessageList;

resourceclass	MessageList    RTYPE_MESSAGES ascending 2 1;
#else
typedef struct __messagelist__
    {
    ULong   expectedNumInfoFields;
    ULong   numRecs;
    /* First string record. */
    struct messages
    	{
	ULong	numInfoFields;
    	ULong   msgId;
	ULong	msgSize;
    	char    msg[1];
    	} Messages;
    } MessageList;
#endif

/*----------------------------------------------------------------------+
|									|
|  Microstation Command Table Resource Description		    	|
|									|
+----------------------------------------------------------------------*/
#if defined (resource)
/* Note: Do not change the name of the following structure as it is
    	 recognized by the resource compiler. */
typedef	struct __cmdentry__
    {
    unsigned long  num;
    unsigned long  subtable:8;
    unsigned long  classname:6;
    unsigned long  options:18;
    char    	   name [];
    } Table [];
resourceclass Table 'CmdT';
#else
typedef	struct __cmdentry__
    {
    unsigned long  numCommands;
    unsigned long  num;
#if !defined (TURBOC)    
    struct
	{
    	unsigned long subtable:8;
    	unsigned long classname:6;
    	unsigned long hidden:1;
    	unsigned long defalt:1;
    	unsigned long required:1;
    	unsigned long tryparse:1;
    	unsigned long immediate:2;
    	unsigned long cmdstring:10;
    	unsigned long notused:2;
	} options;
#else	
    struct
	{
    	unsigned short subtable:8;
    	unsigned short classname:6;
    	unsigned short hidden:1;
    	unsigned short defalt:1;
    	unsigned short required:1;
    	unsigned short tryparse:1;
    	unsigned short immediate:2;
    	unsigned short cmdstring:10;
    	unsigned short notused:2;
	} options;
#endif	
    unsigned long  nameSize;
    char    	   name [1];
    } Table ;
#endif

/*----------------------------------------------------------------------+
|									|
|   Resource Manager Structures Used For Obtaining Resource File Info	|
|									|
+----------------------------------------------------------------------*/

#if !defined (resource)
typedef struct rscdirectaccess
    {
    RscFileHandle   rfHandle;
    FILE	    *fileP;
    unsigned long   filePos;
    unsigned long   rscSize;
    } RscDirectAccess;

typedef struct mdlappllist
    {
    int	    argc;
    char  **argv;
    } MdlApplList;
#endif

#endif /* __rscdefsH__ */


