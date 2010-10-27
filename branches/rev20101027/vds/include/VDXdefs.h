/* $Id: VDXdefs.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXdefs.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXdefs.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  14:08:00  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *			
 ***************************************************************************/

#define VDX_BATCH	0 
#define VDX_INTERACTIVE	1 

/*************** BW. 3/16/94 define keys for UMS *************************/
#define LOAD_INTO_MEMORY (UMS_INDEX | UMS_MESSAGE)

/*************** BW.  3/17/94 product number for Extract for Review ********/

#define VDX_product_num "SW**063"

#define EMS_GETB_COMPATIBLEXYZ          0x001
#define EMS_GETB_COMPATIBLEUV           0x002


/****  Macros  ****/

#define MEM_FREE( arg ) if( arg ) free( arg ); arg = 0;

#define GUswapint1(s,d)                         \
        {                                       \
            t = *((IGRshort *)s);               \
            *s = *(((IGRshort *) s) + 1);       \
            *(((IGRshort *) s) + 1) = t;        \
            *d = *s;                            \
        }

