/*
	I/STRUCT
*/
#include <stdarg.h>
#include <stdio.h>
#include <FEI.h>
#include <FI.h>
#include "msdef.h"
#include "msmacros.h"
#include "vsformdef.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "vsfmcpypaste.h"
#include "vsformproto.h"
#include "vsgrenvproto.h"

static struct {
	char	*form ;
	int	field ;		/* Label of field		*/
	int	row ;		/* Row in text field		*/
	int	col ;		/* Column if multi-column	*/
	int	pos ;		/* Character position in row	*/
	int	color ;
} SELECTION = { NULL, -1, -1, -1, -1, -1 } ;
/*----------------------------------------------------------------------------*/
void VSf_storeCopyPasteInfo( char *pForm, int gadgetLabel ) {

	int	gadgetType ;
	int	rc ;
	int	wno ;
	int	x,
		y ;
	int	wflag ;

	VS_FIf_get_window( pForm, (VSgrEnvWindow *)&wno ) ;
	VS_Mouseposition( (VSgrEnvWindow *)&wno, &x, &y, &wflag ) ;

	rc = FIg_get_type( pForm, gadgetLabel, &gadgetType ) ;

	if(    FI_SUCCESS == rc
            && ( FI_FIELD == gadgetType || FI_MULTI_COL == gadgetType ) ) {
	  int	row, col, offset, sel, pos, nrows ;
	  char  status[VS_K_FI_PASTELEN+10] ;
	  char	text[VS_K_FI_PASTELEN] ;

	  /*
	   * Try to find where the cursor is...
	   */
	  FIfld_find_row_and_column( pForm, gadgetLabel, x, y, &row, &col ) ;

	  /*
	   * 'FIfld_find_row_and_column' seems to fail for 1-row fields.
	   */
	  FIfld_get_num_rows( pForm, gadgetLabel, &nrows ) ;
	  if( 1 ==  nrows ) row = 0 ;

	  FIfld_get_row_offset( pForm, gadgetLabel, &offset ) ;
	  FIfld_get_text(	pForm,
				gadgetLabel,
				row,
				col,
				VS_K_FI_PASTELEN,
				(unsigned char*) text,
				&sel,
				&pos ) ;

	  if( SELECTION.form ) {
	    int nrows, i ;

	    FIfld_get_num_rows( SELECTION.form, SELECTION.field, &nrows ) ;
	    for( i = 0 ; i < nrows ; i++ ) {
	      FIfld_set_line_color( SELECTION.form, SELECTION.field,
	    		            i, SELECTION.col, SELECTION.color ) ;
	    }
	  }

	  FIfld_get_line_color( pForm, gadgetLabel, row, col, &SELECTION.color);
	 
	  FIfld_set_line_color( pForm, gadgetLabel, row, col, FI_YELLOW ) ;

	  VSfld_find_char( pForm, gadgetLabel, col, x, y, &pos ) ;

	  SELECTION.form = pForm ;
	  SELECTION.field= gadgetLabel ;
	  SELECTION.row  = row ;
	  SELECTION.col  = col ;
	  SELECTION.pos  = pos ;
	  sprintf( status, "Select --> '%s'", text ) ;
	  ex$message(	justification	= CENTER_JUS,
			field		= ERROR_FIELD,
			in_buff		= status ) ;
	}

} /* VSf_storeCopyPasteInfo */
/*----------------------------------------------------------------------------*/
void VSf_resetCopyPasteInfo( char *pForm ) { 
	if( pForm == SELECTION.form ) SELECTION.form = NULL ;
}
/*----------------------------------------------------------------------------*/
void VSf_CopyFromForm( char *pForm ) {

	if( pForm == SELECTION.form ) {
	  int   sel, pos ;
	  char  status[VS_K_FI_PASTELEN+10] ;
	  char	text[VS_K_FI_PASTELEN] ;

	  FIfld_get_text(	SELECTION.form,
				SELECTION.field,
				SELECTION.row,
				SELECTION.col,
				VS_K_FI_PASTELEN,
				(unsigned char*) text,
				&sel,
				&pos ) ;

	  sprintf( status, "Copy --> '%s'", text ) ;
	  ex$message(	justification	= CENTER_JUS,
			field		= ERROR_FIELD,
			in_buff		= status ) ;
	  VSfi_put_paste_buffer( text ) ;
	} else {
	  UI_status( "No text selected from this form..." ) ;
	}

} /* VSf_CopyFromForm */
/*----------------------------------------------------------------------------*/
void VSf_PasteToForm( char *pForm ) {

	if( pForm == SELECTION.form ) {
	  int mode ;
	  FIfld_get_mode( pForm, SELECTION.field, SELECTION.col, &mode ) ;
	  /*
	   * Only write to FI_INSERT fields.
	   */
	  if( FI_INSERT == mode ) {
	    char	text[VS_K_FI_PASTELEN] ;
	    char  status[VS_K_FI_PASTELEN+10] ;
	    VSfi_get_paste_buffer( text ) ;
	    VSfld_insert_text(	pForm,
				SELECTION.field,
				SELECTION.row,
				SELECTION.col,
				SELECTION.pos,
				text ) ;
	    sprintf( status, "Paste --> '%s'", text ) ;
	    ex$message(	justification	= CENTER_JUS,
			field		= ERROR_FIELD,
			in_buff		= status ) ;
	  }
	} else {
	  UI_status( "No field selected from this form..." ) ;
	}

} /* VSf_PasteToForm */
/*----------------------------------------------------------------------------*/

