/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/mem.C
 *
 * Description:
 *      This is another copy of the vrrt/mem.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: mem.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/11/06  23:34:40  pinnacle
 * Replaced: vrrt_STEP/mem.C for:  by apazhani for route
 *
 * Revision 1.1  1998/11/06  19:28:50  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *      11/06/98        Alwin     Type casted the allocation(CLIX is quite 
 *				  strict in this )
 *
 *************************************************************************/

#include "common.h"

charp membcpy(s1,s2,n) 
charp s1, s2; int n; 
{ 
    charp sret = s1;

    if (s1 < s2)         while (n-- > 0) *s1++ = *s2++;
    else 
    { s1+=n, s2+=n; 
      while (n-- > 0) *--s1 = *--s2; 
    } 

    return sret; 
}

charp memcopy(s2,n) charp s2; int n; 
{
    charp s1 = (char*)diag_malloc(DIAG_FATAL,n); 
    memcpy(s1,s2,n); return s1; 
}

charp membcopy(s2,n) charp s2; int n; 
{
    charp s1 = (char*)diag_malloc(DIAG_FATAL,n); 
    membcpy(s1,s2,n); return s1; 
}
