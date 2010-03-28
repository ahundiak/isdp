/*
Name
        IPtype5.h

Description
        This file is "borrowed" from InterPlot.

History
        mrm     02/17/92    added to GRNUC
*/

# ifndef iptypes_include
# define iptypes_include 1
/******************************************************************************

    FILE 

	IPtypes.h

    DESCRIPTION

	This file contains miscellaneous type definitions.  The use
	of the data types defined in this file instead of the types
	built-in to the C language will make the code easier to port
	to other environments (such as PC-DOS or OS-2).

    INCLUDE FILE DEPENDENCIES

	None

    CHANGE HISTORY

	03-15-88 (RKS)	Initial creation.

******************************************************************************/

typedef char		IPint8;		/* signed integer data types	*/
typedef	short		IPint16;
typedef	long		IPint32;

typedef unsigned char	IPuint8;	/* unsigned integer data types	*/
typedef unsigned short	IPuint16;
typedef unsigned long	IPuint32;

typedef float		IPreal32;	/* floating point data types	*/
typedef double		IPreal64;

#endif /* iptypes_include */
