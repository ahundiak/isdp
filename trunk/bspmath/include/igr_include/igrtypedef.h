/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef igrtypedef_include
#define igrtypedef_include

#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#ifndef NULL
#define NULL	0
#endif

typedef short	IGRboolean;
typedef short 	IGRshort;
typedef long  	IGRlong;
typedef int   	IGRint;
typedef double  IGRdouble;
typedef char	IGRchar;
typedef unsigned char   IGRuchar;
typedef unsigned short IGRushort;
typedef unsigned int IGRuint;
typedef unsigned long IGRulong;

typedef	 IGRdouble  IGRvector[3];

typedef  IGRdouble  IGRmatrix[16];

typedef  IGRdouble  IGRpoint[3];

#endif /* igrtypedef_include */
