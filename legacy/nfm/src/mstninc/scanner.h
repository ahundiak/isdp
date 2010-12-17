/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   scanner.h  $
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
|   scanner.h -- Typedefs and Defines for using the design file		|
|		 "scanner".  The scanner can quickly locate elements	|
|		 based on predefined criteria.				|
|									|
+----------------------------------------------------------------------*/
#ifndef __scannerH__
#define __scannerH__

#if !defined (__basetypeH__)
#   include <basetype.h>
#endif

/* bits used in scantype */
#define	    ELEMDATA	0x0001	/* if true, store data */
#define	    NESTCELL	0x0002	/* if true, cell is treated as one element */
#define	    PICKCELL	0x0004	/* if true, compare cell name */
#define	    PROPCLAS	0x0008	/* if true, compare on properties and class */
#define	    GRPHGRP	0x0010	/* if true, compare on graphics group */
#define	    MULTI	0x0020	/* if true, there are multiple scan ranges */
#define	    SKEW	0x0040	/* if true, do a skew scan */
#define	    BOTH	0x0080	/* if true, get both pointers and data */
#define	    ONEELEM	0x0100	/* if true, get only one element */
#define	    ATTRENT	0x0400	/* if true, compare on attrb linkage entity */
#define	    ATTROCC	0x0800	/* if true, compare on attrb occurence # */
#define	    STOPSECT	0x1000	/* if true, check stop sector */
#define	    LEVELS	0x2000	/* if true, compare on levels */
#define	    ELEMTYPE	0x4000	/* if true, compare on element type */

/* bits used in extendedtype */
#define	    RETURN3D	0x0001	/* if true, return 3D elements from 2D file */
#define	    FILEPOS	0x0002	/* if true, return file pos, not block/byte */
#define	    MEMPTRS	0x0004	/* if true, return mem pointers or elements */
#define	    EXTATTR	0x0008	/* if true, do extended attribute scan */

/* Properties Indicators */    
#define	    ELELOCKED	0x0100	/* set if locked */
#define	    ELENEW	0x0200	/* set if new */
#define	    ELEMOD	0x0400	/* set if modified */
#define	    ELEATTR	0x0800	/* attribute data present */
#define	    ELERELTVE	0x1000	/* set if relative to database */
#define	    ELEPLANR	0x2000	/* set if planar */
#define	    ELESNAP	0x4000	/* set if element is snappable */
#define	    ELEHOLE	0x8000	/* set if element is a hole */

/* Scanner error messages */
#define	    END_OF_DGN	10
#define	    BUFF_FULL	11
#define	    READ_LIMIT	12

typedef struct scanrange
    {
    unsigned long   xlowlim;
    unsigned long   ylowlim;
    unsigned long   zlowlim;
    unsigned long   xhighlim;
    unsigned long   yhighlim;
    unsigned long   zhighlim;
    } Scanrange;	

/* used by caching to associate file positions with element memory address */
typedef struct
    {
    int		    filePos;
    unsigned short  *element;
    } PtrPair;

typedef struct
    {
    short	    numWords;   /* number of words of attr data to consider */
    unsigned short  extAttData[32];
    } ExtendedAttrBuf;

typedef struct extScanlist
    {
    short	    sllen;	/* scan list length */
    unsigned short  scantype;	/* scan type (see bit definitions above) */
    unsigned short  tplval;	/* value for type/plane/level register */
    unsigned short  tplmsk;	/* mask for type/plane/level */
    unsigned long   xlowlim;	/* lower limit (main scan range) */
    unsigned long   ylowlim;		
    unsigned long   zlowlim;
    unsigned long   xhighlim;	/* upper limit */
    unsigned long   yhighlim;
    unsigned long   zhighlim;
    union
	{
	unsigned short	    propval;
	unsigned short	    cell0;
	} pcl;
    union
	{
	unsigned short	    propmsk;
	unsigned short	    cell1;
	} pch;
    unsigned short  grgroup;
    unsigned short  sector;	/* sector at start */
    unsigned short  offset;	/* byte at start */
    short	    ellength;	/* len of elmnt that wont fit (not used) */
    unsigned short  entity;
    unsigned short  clasmsk;
    unsigned short  levmask[8];
    unsigned short  typmask[8];
    long	    occurnce;
    unsigned short  stopsector;	    /* stop on this sector */
    unsigned short  extendedType;   /* extended scan type bits */
    Dpoint3d	    skewVector;	    /* skew direction vector */
    Scanrange	    exrange[8];	    /* extended range blocks */
    ExtendedAttrBuf *extAttrBuf;    /* extended attribute scanning */
    } ExtScanlist, Scanlist;

typedef struct
    {
    ExtScanlist scanlist;
    short	extrawords[100];
    } ScanContext;

#endif	/* __scannerH__ */
