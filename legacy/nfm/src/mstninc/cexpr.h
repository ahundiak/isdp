/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   cexpr.h  $
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
|   cexpr.h -- contains the definitions required by the C Expression
|	       evaluation functions.    				|
|									|
+----------------------------------------------------------------------*/
#ifndef	    __cexprH__
#define	    __cexprH__
#ifndef	    __cexprrscH__
#include    <cexprrsc.h>
#endif    

/* .h File Dependencies */

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/

/*  Symbol type specified in mdlCExpression_symbolPublish */
#define SYMBOL_CLASS_SOURCE	    0x01   /* Used only by the debugger */
#define SYMBOL_CLASS_SCOPE	    0x02   /* Used only by the debugger. */
#define SYMBOL_CLASS_VAR	    0x04   /* Variables */
#define SYMBOL_CLASS_STRUCT         0x08   /* Structures and unions */
#define SYMBOL_CLASS_FUNCTION	    0x20   /* Functions */

/*  Values for visibility flags  */
#define VISIBILITY_DEBUGGER	    1
#define	VISIBILITY_CALCULATOR	    2
#define VISIBILITY_DIALOG_BOX	    4
#define VISIBILITY_LOCAL	    8

/*  Class  */
#define CL_VALUE		    1
#define CL_LVALUE		    2
#define CL_ERROR		    3

#define CEXPR_TYPE_POINTER	    1
#define CEXPR_TYPE_LONG		    2
#define CEXPR_TYPE_ULONG	    3
#define CEXPR_TYPE_DOUBLE	    4

#define TYPECODE_CHAR		    1
#define TYPECODE_SHORT		    2
#define TYPECODE_INT		    3
#define TYPECODE_LONG		    4
#define TYPECODE_FLOAT		    5
#define TYPECODE_DOUBLE		    6
#define TYPECODE_U_CHAR		    7
#define TYPECODE_U_SHORT	    8
#define TYPECODE_U_LONG		    9
#define TYPECODE_POINTER 	    15
#define TYPECODE_STRUCT		    18
#define TYPECODE_UNION		    19

/*----------------------------------------------------------------------+
|									|
|   Typedefs								|
|									|
+----------------------------------------------------------------------*/

typedef struct cType
    {
    unsigned short  tcode;	/* CHAR, LONG, STAR, STRUCT, etc.  */
    int		    size;	/* Size for associated data. */
    unsigned long   madeofResource; /* Resource handle if "madeof" is defined
				    in a resource file.		*/
    union
	{
	struct cType *madeof;	/* Member definition for struct/union.  
				   Type of derefence if pointer.  */
	unsigned long offset;	/*  Shift count for bit fields.  */
	} detail;
    int		    tnumber;	/*  Element count for arrays, field width
				    for bit fields.			*/
    } CType;

typedef struct cExprResult
    {
    byte		class;
    Types_u		value;	    /*  class tells how to access it. */
    struct cType	*ptype;
    } CExprResult;
    
typedef struct cExprValue
    {
    int			type;		/*  DOUBLE, LONG, or POINTER */
    union 
	{
	long		valLong;
	double		valDouble;
	void		*valPointer;
	}		val;
    } CExprValue;

#endif
