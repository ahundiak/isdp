/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   cexprrsc.h  $
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
|   cexpr.r -- resource definitions for C expressions   		|
|									|
|									|
+----------------------------------------------------------------------*/
#ifndef __cexprrscH__
#define __cexprrscH__

/* .h File Dependencies */
#ifndef __rscdefsH__
#include    <rscdefs.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/

#if defined (resource)
#define	VARIABLE_SIZE
#else
#define VARIABLE_SIZE	1
#endif

/* Bit masks for the typeInfo field in the cexprMember structure */
#define CTYPE_PACKED	    0x80000000  /* Resource definition not used */
#define CTYPE_RESOURCE_ID   0x7FFFFFFF  /* Resource ID of type def */
#define CTYPE_CODE	    0xFF	/* Type code if not resource ID */
#define CTYPE_WIDTH_MASK    0xFF00	/* Field width for bit fields */
#define CTYPE_WIDTH_SHIFT   8
#define CTYPE_SHIFT_MASK    0xFF0000	/* Shift count for bit fields */
#define CTYPE_SHIFT_SHIFT   16
#define CTYPE_POINTER	    0x40000000  /* Pointer to base type */
#define CTYPE_COUNT_MASK    0x0FFFFF00  /* If pointer, repeat count.
					   Non-zero => array */
#define CTYPE_COUNT_SHIFT   8

/* Bit masks for the nameSum field in the cexprMember structure */
#define MEMBER_NAMESUM_DUP  	0x80000000  /* If set, nameSum is not unique
					       almong struct members */
#define MEMBER_NAMESUM_VALUE	0x7FFFFFFF  /* Actual value of nameSum */


/*----------------------------------------------------------------------+
|									|
|   Typedefs								|
|									|
+----------------------------------------------------------------------*/

typedef struct cexprType
    {
    short	    tcode;	    /*  STRUCT, UNION, etc. */
    unsigned long   size;	    /*  Total type size	    */
    unsigned long   detail;	    /*  0, resource ID of madeof, or 
					CEXPR_TYPE_ definitions */
    unsigned long   name;	    /*  Name if STRUCT or UNION  */
    unsigned long   tnumber;	    /*  Count of fields if array.  Field
					width if bit field. */
    } CexprType;

#if defined (resource)
resourceclass CexprType  RTYPE_CTYPE;
#endif

/*  Used for structures and unions  */
typedef struct cexprStructName
    {
    unsigned long   typeID;
    unsigned long   nameID;
    unsigned long   nameSum;
    } CexprStructName;

/*  Count of named unions and structures. */
typedef struct cexprNamedStructures
    {
#if !defined (resource)
    int		    structCount;
#endif
    CexprStructName structs [VARIABLE_SIZE];
    } CexprNamedStructures;

#if defined (resource)
resourceclass CexprNamedStructures RTYPE_CSTRUCT_NAME;
#endif

/*  Used for structure members  */
typedef struct cexprMember
    {
    unsigned long   typeInfo;	    /* See the CTYPE_... bits masks */
    unsigned long   offset;
    unsigned long   nameID;
    unsigned long   nameSum;	    /* Most significant bit off => unique */
    } CexprMember;

typedef struct cexprMemberList
    {
#if !defined (resource)
    int		    numberMembers;
#endif
    CexprMember	    members [VARIABLE_SIZE];
    } CexprMemberList;

#if defined (resource)
resourceclass CexprMemberList RTYPE_CMEMBER;
#endif

typedef struct cexprName
    {
#if !defined (resource)
    int		    size;
#endif
    char	    name [VARIABLE_SIZE];
    } CexprName;

#if defined (resource)
resourceclass CexprName RTYPE_CNAME;
#endif

#endif
