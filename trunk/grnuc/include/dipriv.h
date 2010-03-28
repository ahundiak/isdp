#ifndef dipriv_include
#define dipriv_include

/*
 *   Dependencies
 *
 *   This file depends on the following files :
 *	   OMminimum.h
 *	   DItypedef.h
 *	   DIdef.h
 */

struct FormPackInfo
{
    int  count;
    char title   [DI_PATH_MAX],
	 command [DI_PATH_MAX],
	 **list;
};

#endif
