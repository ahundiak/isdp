/* $Id: VDmemUtil.c,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdutil / VDmemUtil.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmemUtil.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1996/05/06  22:04:52  pinnacle
 * Replaced: vdutil/VDmemUtil.c for:  by azuurhou for vds.240
 *
 * Revision 1.3  1996/04/26  02:34:12  pinnacle
 * Replaced: vdutil/VDmemUtil.c for:  by tlbriggs for vds.240
 *
 *
 * History:
 * 	08/23/95   tlb		Modified to use VDS memory checking
 * 	05/06/96   tlb		Check for zero count, zero size in allocation
 *
 *************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VDmem.h"

/*
 Doc : This function mallocs memory for a string list. No. of strings
        in the list and size of each string are the input.

 Return Code:
 1 - memory successfully malloced
 0 - could not allocate memory
*/


long VDmalloc_str_list (
  char ***str_list,	/* I/O - list containing strings */
  int  num_str,		/* I   - no. of strings	in list  */
  int  str_size		/* I   - size of each character string */
  )
{
   int  ii;
   int	sts = TRUE;

   if (!num_str || !str_size) {
	*str_list = NULL;
	return (FALSE);
	}
	
   *str_list = _MALLOC( num_str, char *);
   _CheckAlloc (*str_list, "string list", sts, FALSE, quit);

   for(ii=0; ii<num_str; ii++) {
	(*str_list)[ii] = _MALLOC( str_size, char );
        _CheckAlloc ((*str_list)[ii], "string list element", sts, FALSE, quit);
	(*str_list)[ii][0] = '\0';
        }

quit:
   return (sts);
}

/*
 Doc : This function deallocates memory contained by a string list.
       No. of strings in the list is input.

*/

void VDfree_str_list (
  		char **str_list,	/* list to be freed	  */
  		int  num_str		/* no. of strings in list */
  		)
{ _LOOPFREE (str_list, num_str); }

/************************************************************************/
/*
 Doc : This function mallocs memory for a string list. No. of strings
       in the list and size of each string are the input.
  
       This function modify VDmalloc_str_list using BSmalloc in order
       to use its memory check tool.

 Return Code:
 1 - memory successfully malloced
 0 - could not allocate memory
*/


long VDbsmalloc_str_list (
  char ***str_list,     /* I/O - list containing strings */
  int  num_str,         /* I   - no. of strings in list  */
  int  str_size         /* I   - size of each character string */
  )
{
   int  ii;
   int  sts = TRUE;

   if (!num_str || !str_size) {
	*str_list = NULL;
	return (FALSE);
	}
	
   *str_list = _MALLOC( num_str, char* );
   _CheckAlloc (*str_list, "string list", sts, FALSE, quit);

   for(ii=0; ii<num_str; ii++) {
        (*str_list)[ii] = _MALLOC ( str_size, char );
        _CheckAlloc ((*str_list)[ii], "string list element", sts, FALSE, quit);
        (*str_list)[ii][0] = '\0';
     	}
quit:
   return (sts);
}

/*
 Doc : This function deallocates memory contained by a string list.
       No. of strings in the list is input.

       This function modify VDfree_str_list using BSdealloc inorder to
       using its memory check tool.
*/

void VDbsfree_str_list (
  		char **str_list,      /* list to be freed       */
  		int  num_str          /* no. of strings in list */
   		)
{ _LOOPFREE (str_list, num_str); }
