/* $Id: VDitemNum.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	include / VDitemNum.h.h
 *
 * Description:
 *	Functions and macros for item numbers
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemNum.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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
 * Revision 1.4  1995/10/10  20:49:58  pinnacle
 * Replaced: include/VDitemNum.h for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/09/11  15:57:56  pinnacle
 * Replaced: include/VDitemNum.h for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/09/06  21:20:14  pinnacle
 * Replaced: include/*item*.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/20  15:25:12  pinnacle
 * Created: include/VDitemNum.h by tlbriggs for vds.240
 *
 *
 * History:
 *	07/20/95	tlb		Created
 *	09/06/95	tlb		Modify VD_parseItemNum 
 *	09/08/95	tlb		Modify VD_parseItemNum 
 *	10/10/95	tlb		Add is_lineout flag to input structure
 *
 *************************************************************************/

#ifndef VDitemNum_include
#define VDitemNum_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/*----------------------------------------------------------------------- */
/* 
 * size of item number string
 */
#define VD_ITEMNUM_LEN	35



/*----------------------------------------------------------------------- 
 FUNCTION: 	VD_drwGenItemNum

 ABSTRACT
   This function displays the "Generate Item Numbers" subform used by 
   "Create/Modify Table".  It generates item numbers, based on the
   users input.

 ARGUMENTS
 	numRows			I	number of rows in structure
 	rowList->itemNo		I/O 	item number string from BOM
	rowList->is_lineout	I	flag indicating itemNo was modified 
 	rowList->num_objs	I 	number of objects summarized by BOM row
 	rowList->objs		I 	list of objects summarized by BOM row
	rowList->is_modified	O	flag indicating itemNo was modified 

 RETURN VALUES:
	TRUE	item numbers were generated successfully 
	FALSE	item numbers were not be generated 
			user cancelled or internal error

 ------------------------------------------------------------------------*/

typedef struct {
        char            	itemNo[VD_ITEMNUM_LEN];
	short			is_lineout;		/* TRUE/FALSE */
        short             	num_objs;
        struct GRobj_env       *objs;			/* list of objects */
        short           	is_modified;            /* TRUE/FALSE */
   }  VD_itemList_t;


extern int
VD_drwGenItemNum 	__((  	VD_itemList_t	*rowList,
				int 		numRows	 ));

/*----------------------------------------------------------------------- 
 FUNCTION: 	VD_parseItemNum

 ABSTRACT
   Parses item number and generates prefix, sequence number, and suffix.
   Returns status indicating whether itemNo could be parsed

 ARGUMENTS
 	char	*itemNo		I	item number string to parse
	char	*prefix		O	prefix string, 
					  user allocated of size VD_ITEMNUM_LEN
	int	*num		O	sequence number 
	char	*suffix		O	prefix string, 
					  user allocated of size VD_ITEMNUM_LEN

 RETURN VALUES:
	2	item number missing sequence number - only prefix
			(prefix set, num = 0, suffix = "")
	1	item number successfully parsed
	FALSE	empty string as itemNum
			(prefix, num, suffix values are not set)

 ------------------------------------------------------------------------*/

extern int
VD_parseItemNum 	__((char	*itemNo,
		 	    char	*prefix,
		 	    int		*num,
			    char	*suffix));

#endif
