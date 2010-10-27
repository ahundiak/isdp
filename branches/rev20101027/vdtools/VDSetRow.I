/* $Id: VDSetRow.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtools / VDSetRow.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSetRow.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/11/24  20:56:28  pinnacle
# Created: vdtools/VDSetRow.I by kddinov for vds
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
*	11-97	kdd		creation
 *
 *************************************************************************/
class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "FI.h"

/*------------------------------------------------------------------------------
*  VDForm_set_active_row ()
*----------------------
# This routine finds first matching row for data from form_ptr:gadget and List[]
* If Multicolumn field, then:
* List[0] is the data in column 0, 
* List[1] is the data in column 1, etc. All data is assumed string. 
*
*----------------------
* Parameters:
*
* I: Form    form_ptr	- pointer to the form.
*
* I: int     gadget	- gadget to search.
*
* I: int     start_row	- begin search from that row.
*
* I: int     start_col	- begin search from that column.
*
* I: char    *List[]	- array of pointers to the conditions in some columns.
*
* I: int     NumList	- number of pointers in List
*
*----------------------
* Return status:
*
* 0 	matching row NOT found.
* n > 0	matching row is found, n points to the first match. 
*	Row n of "gadget" in "form_ptr" is set as the active one.  
*	Row n is on the top of the viewing area. 
------------------------------------------------------------------------------*/
int VDForm_set_active_row (	Form	form_ptr,
				int	gadget,
				int 	start_row,
				int 	start_col,
				char	*List[],
				int	NumList)
{
int		i, j, num_rows=0, num_cols = 0, sel = 0, pos = 0, sts = 0,
		last_col = 0;

char		text[80];


  if ( NumList == 0 ) goto wrapup;


  FIfld_get_num_rows( form_ptr, gadget, &num_rows);
  FImcf_get_num_cols( form_ptr, gadget, &num_cols);

  if ( (last_col = start_col + NumList) >= num_cols ) last_col = num_cols;

  for ( i = start_row; i < num_rows; i++) { 
      for ( j = start_col; j < last_col ; j++ ) {

      	  FIfld_get_text( form_ptr, gadget, i, j, 80,
                                (unsigned char *) text, &sel, &pos);

      	  if ( strcmp( List[j] , text) ) { break;}
      }

      if ( j == last_col) break; /* match is found (row i), exit loop */
  }

  if ( i < num_rows ) { 	/* match is found */

     for ( j = 0; j < num_cols; j++ ) {
  	FIfld_pos_cursor(     form_ptr, gadget, i, j, 0, 0, 0, 0);
  	FIfld_set_select(     form_ptr, gadget, i, j, TRUE);
     }

     FIfld_set_active_row( form_ptr, gadget, i, 0);

     sts = i; 
  }

wrapup:
return (sts);
}

end implementation Root; 
