/*
	I/STRUCT
*/
#ifdef ENV5
#include <stdarg.h>
#elif defined(X11)
#include "standards.h"
#include "varargs.h"
#include "stdarg.h"
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define FALSE 0
#define TRUE 1
#include <FEI.h>
#include <FI.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsgraphicenv.h"
#include "vs.h"
#include "msdef.h"
#include "msmacros.h"
#include "vsformdef.h"
#include "vscmd.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "vsgrenvproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
int VSf_repaint_gadget( form, gadget )

char	*form ;
int	gadget ; {

	int	rc,
		gx,
		gy,
		gwidth,
		gheight ;

	/*
	 * Repaints the area limited by a gadget, useful when non-FI stuff
	 * has been drawn on the area limited by, say, an FI rectangle.
	 */
	rc = FIg_get_size( form, gadget, &gwidth, &gheight ) ;
	if( rc == FI_SUCCESS ) {
		rc = FIg_get_location( form, gadget, &gx, &gy ) ;
		if( rc == FI_SUCCESS ) {
			rc = FIf_paint_area(	form,
						gx, gy,
						gx + gwidth, gy + gheight ) ;
		}
	}
	return rc ;

} /* VSf_repaint_gadget */
/*----------------------------------------------------------------------------*/
int VSfld_set_list( form, label, size, list )

char	*form ;
int	label,
	size ;
char 	**list ; {

	/*
	 * Sets number of row, then fills them with list.
	 */
	int	rc,
		row ;

	rc = FIfld_set_list_num_rows(	form,
					label,
					0,
					size ) ;

	for( row = 0 ; row < size ; row++ ) {
		rc = VDfld_set_list_text( form, label, row, 0,
					  list[row], FALSE ) ;
	}

	return rc ;

} /* VSfld_set_list */
/*----------------------------------------------------------------------------*/
int VSfld_set_list_with_msgkeys( form, label, size, keylist )

char	*form ;
int	label,
	size ;
long 	*keylist ; {

	/*
	 * Sets number of row, then fills them with list using message keys.
	 */
	int	rc,
		row ;

	rc = FIfld_set_list_num_rows(	form,
					label,
					0,
					size ) ;

	for( row = 0 ; row < size ; row++ ) {
		rc = VDfld_set_list_text( form, label, row, 0,
					  VSmsgkey2string( keylist[row] ),
					  FALSE ) ;
	}

	return rc ;

} /* VSfld_set_list_with_msgkeys */
/*----------------------------------------------------------------------------*/
char *VSmcf_get_text( form, label, row, column ) 

char 	*form ; 
int 	label,
    	row,
    	column ; {

	int	size = 0 ;
	char	*text ;
	
	FIfld_get_text_length( form, label, row, column, &size ) ;

	/*
	 * Malloc's memory then copies ASCII field's row to it.
	 */
	
	if( !size ) {
		text = VSstrdup( "" ) ;
	} else {
		if( text = _MALLOC( size, char ) ) {
			int	sel,
				pos ;

			FIfld_get_text( form, label, row, column, size,
					(unsigned char *) text, &sel, &pos ) ;
		}
	}
	
	return text ;
	
} /* VSmcf_get_text */
/*----------------------------------------------------------------------------*/
char *VSfld_get_text( form, label ) char *form ; int label ; {

	return VSmcf_get_text( form, label, 0, 0 ) ;

} /* VSfld_get_text */
/*----------------------------------------------------------------------------*/
char *VSfld_get_lines( form, label ) char *form ; int label ; {

	/*
	 * Reads all the rows of a form's field and concatenates them in one
	 * string, inserting carriage returns.
	 */
	int	line,
		count,
		size ;
	char	*text ;

	FIfld_get_num_rows( form, label, &count ) ;

	if( !count ) text = VSstrdup( "" ) ;
	else {
		int length = 0 ;

		for( line = 0 ; line < count ; line++ ) {
			FIfld_get_text_length( form, label, line, 0, &size ) ;
			if( !size ) length++ ;
			else length += size ;			
		}

		if( text = _MALLOC( length, char ) ) {
			int sel, pos ;
			
			length = 0 ;

			for( line = 0 ; line < count ; line++ ) {
				FIfld_get_text_length(	form, label,
							line, 0, &size ) ;
				if( !size ) {
					text[length++] = '\n' ;
				} else {
					unsigned char *tx ;

					tx = (unsigned char *) (text + length) ;

					FIfld_get_text( form, label, line, 0,
							size, tx, &sel, &pos ) ;
					length += size ;
					/*
					 * Put carriage return.
					 */
					text[length-1] = '\n' ;
				}
			}
			/*
			 * Terminate string.
			 */
			text[length-1] = '\0' ;
		}
	}
	return text ;

} /* *VSfld_get_lines */
/*----------------------------------------------------------------------------*/
void VSfld_set_lines( form, label, text ) char *form ; int label ; char *text ;{

	char		*last ;
	int		num_row ;

	/*
	 * The reverse of VSfld_get_lines
	 */
	FIfld_get_num_rows( form,
			    label,
			    &num_row ) ;

	FIfld_delete_rows(  form,
			    label,
			    0,
			    num_row ) ;

	num_row = 0 ;
	while( TRUE ) {
		if( last = strchr( text, '\n' ) ) {
			*last = '\0' ;

			FIfld_set_text( form, label, num_row, 0, text, FALSE ) ;
			*last = '\n' ;
			num_row++ ;
			text = last + 1 ;
		} else {
			/*
			 * Last line ;
			 */
			if( *text ) {

				FIfld_set_text( form, label, num_row,
						0, text, FALSE ) ;
			}
			break ;
		}
	}			
		
} /* VSfld_set_lines */
/*----------------------------------------------------------------------------*/
void VSsetGadgetModifiable( list, label, flag )

struct VSgadget	list[] ;
int		label ;
int		flag ; {


	register struct VSgadget	*l ;

	for( l = list ; l->label != -1 ; l++ ) {
		if( l->label == label ) {
			l->touchable = flag ;
			break ;
		}
	}

} /* VSsetGadgetModifiable */
/*----------------------------------------------------------------------------*/
void VSfld_set_row_text( form, label, size, list )

char	*form ;
int	label,
	size ;
char 	**list ; {

	int row ,
	    nb_rows ;

	FIfld_get_num_rows(		form,
					label,
					&nb_rows ) ;

	FIfld_delete_rows(		form,
					label,
					0,
					nb_rows ) ;

	for( row = 0 ; row < size ; row++ ) {
		FIfld_set_text(		form,
					label,
					row,
					0,
					list[row],
					FALSE ) ;
	}

} /* VSfld_set_row_text */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSfld_find_char( form, label, col, x, y, charpos )

char	*form ;
int	label,
	col,
	x,
	y,
	*charpos ; {

	/*
	 * Given a form, a field (label) and a position (x,y), finds to which
	 * character in row of field (x,y) corresponds.
	 * WARNING col for MCFs not taken into account yet!
	 */

	int	rc,
		vis_chars ;

	rc = FIfld_get_num_vis_chars( form, label, col, &vis_chars ) ;
	if( rc == FI_SUCCESS ) {
		int	xs,
			ys,
			xl,
			yl ;
		FIg_get_size( form, label, &xs, &ys ) ;
		FIg_get_location( form, label, &xl, &yl ) ;

		*charpos = ( ( x - xl ) * vis_chars ) / xs ;

	}

	return rc ;

} /* VSfld_find_char */
/*----------------------------------------------------------------------------*/
int VSf_is_cursor_in_fld_row( form, label, x, y, row )

char	*form ;
int	label,
	x,
	y,
	*row ; {

	/*
	 * Finds out if cursor (x,y) is in a row of field "label" of form,
	 * and if so returns the row number.
	 */
	int where ;

	*row = -1 ;
	if( FIf_find_gadget(	form,
				FI_FORM_GROUP,
				x,
				y,
				&where ) == FI_SUCCESS ) {
		if( where == label ) {
			int	col,
				vis,
				roff ;

			 FIfld_find_row_and_column(
					form, label, x, y, row, &col ) ;

			FIfld_get_num_vis_rows( form, label, &vis ) ;
			FIfld_get_row_offset( form, label, &roff ) ;

			if( *row >= vis + roff ) *row = -1 ;
		}
	}
	return *row != -1 ;

} /* VSf_is_cursor_in_fld_row */
/*----------------------------------------------------------------------------*/
int VSg_get_layout( form, label, xpos, ypos, width, height )

char	*form ;
int	label,
	*xpos,
	*ypos,
	*width,
	*height ; {

	int rc ;

	if( ( rc = FIg_get_location(	form,
					label,
					xpos,
					ypos ) ) == FI_SUCCESS ) {
		rc = FIg_get_size( form, label, width, height ) ;
	}
	return rc ;

} /* VSg_get_layout */
/*----------------------------------------------------------------------------*/
int VSg_set_layout( form, label, xpos, ypos, width, height )

char	*form ;
int	label,
	xpos,
	ypos,
	width,
	height ; {

	int rc ;

	if( ( rc = FIg_set_location(	form,
					label,
					xpos,
					ypos ) ) == FI_SUCCESS ) {
		rc = FIg_set_size( form, label, width, height ) ;
	}
	return rc ;

} /* VSg_set_layout */
/*----------------------------------------------------------------------------*/
int VSf_get_layout( form, screen, xpos, ypos, width, height )

char	*form ;
int	*screen,
	*xpos,
	*ypos,
	*width,
	*height ; {

	int rc ;

	if( ( rc = FIf_get_screen( form, screen ) ) == FI_SUCCESS ) {
		if( ( rc = FIf_get_location(	form,
						xpos,
						ypos ) ) == FI_SUCCESS ) {
			rc = FIf_get_size( form, width, height ) ;
		}
	}
	return rc ;

} /* VSf_get_layout */
/*----------------------------------------------------------------------------*/
int VSf_set_layout( form, screen, xpos, ypos, width, height )

char	*form ;
int	screen,
	xpos,
	ypos,
	width,
	height ; {

	int rc ;

	if( ( rc = FIf_set_screen( form, screen ) ) == FI_SUCCESS ) {
		if( ( rc = FIf_set_location(	form,
						xpos,
						ypos ) ) == FI_SUCCESS ) {
			int	wmin,
				hmin ;
			/*
			 * Beware of stupid form sizes ...
			 */
			FIf_get_min_size( form, &wmin, &hmin ) ;
			if( width < wmin || height < hmin ) {

				FIf_get_orig_size( form, &wmin, &hmin ) ;
				width = wmin ; height = hmin ;
			}
			FIf_set_collapse_location( form, xpos, ypos ) ;
			FIf_set_size( form, width, height ) ;
		}
	}
	return rc ;

} /* VSf_set_layout */
/*----------------------------------------------------------------------------*/
int VSg_replace( form, label1, label2 ) char *form ; int label1, label2 ; {

	/*
	 * Erases 1st gadget, displays 2nd.
	 */
	int rc ;

	if( ( rc = FIg_erase( form, label1 ) ) == FI_SUCCESS ) {
		rc = FIg_display( form, label2 ) ;
	}

	return rc ;

} /* VSg_replace */
/*----------------------------------------------------------------------------*/
int VSg_chg_attr( form, label, set, rm )

char	*form ;
int	label,
	set,
	rm ; {

	/*
	 * Changes the attribute mask of a gadget: sets those attributes
	 * specified in "set", removes those specified in "rm".
	 */
	int	rc,
		attr ;

	if( ( rc = FIg_get_attr( form, label, &attr ) ) == FI_SUCCESS ) {
		rc = FIg_set_attr( form, label, ( attr | set ) & ~rm ) ;
	}
	return rc ;

} /* VSg_chg_attr */
/*----------------------------------------------------------------------------*/
/*VARARGS*/
int VSg_chg_attr_of_gadgets( va_alist ) va_dcl {

	/*
	 * Same as above but for a list of gadgets ended by "-1".
	 *
	 * arg 1	: char	*form
	 * arg 2	: attributes to set
	 * arg 3	: attributes to remove
	 * arg 4 ... n-1: int	label
	 * arg n	: -1
	 */
	va_list	ap ;
	int	set,
		rm,
		label,
		rc = FI_INVALID_FORMAT ;
	char	*form ;

	va_start( ap, 0 ) ;

		form	= va_arg( ap, char *	) ;
		set	= va_arg( ap, int	) ;
		rm	= va_arg( ap, int	) ;
		while( ( label = va_arg( ap, int ) ) != -1 ) {
			rc = VSg_chg_attr( form, label, set, rm ) ;
			if( rc != FI_SUCCESS ) break ;
		}

	va_end( ap ) ;

	return rc ;

} /* VSg_chg_attr_of_gadgets */
/*----------------------------------------------------------------------------*/
/*VARARGS*/
int VSg_make_group_of_gadgets( va_alist ) va_dcl {

	/*
	 * arg 1	: char	*form
	 * arg 2	: int	group label
	 * arg 3 ... n-1: int	label
	 * arg n	: -1
	 */
	va_list	ap ;
	int	group,
		label,
		rc = FI_INVALID_FORMAT ;
	char	*form ;

	va_start( ap, 0 ) ;

		form	= va_arg( ap, char *	) ;
		group	= va_arg( ap, int	) ;

		rc = FIg_new( form, FI_GROUP, group ) ;
		if( rc == FI_SUCCESS ) {
			while( ( label = va_arg( ap, int ) ) != -1 ) {
				rc = FIg_add_to_group( form, label, group ) ;
				if( rc != FI_SUCCESS ) break ;
			}
		}

	va_end( ap ) ;

	return rc ;

} /* VSg_make_group_of_gadgets */
/*-OPERATIONS ON LIST OF GADGETS----------------------------------------------*/
/*VARARGS*/
int VSg_op_on_gadgets( va_alist ) va_dcl {

	/*
	 * arg 1	: char	*form
	 * arg 2	: operation function
	 * arg 3 ... n-1: int	label
	 * arg n	: -1
	 */
	va_list	ap ;
	int	label,
		rc = FI_INVALID_FORMAT ;
	char	*form ;
	typedef	int (*IPF)__(( char *fm, int lb )) ;
	IPF	op ;

	va_start( ap, 0 ) ;
	
		form	= va_arg( ap, char *	) ;
		op	= va_arg( ap, IPF	) ;

		while( ( label = va_arg( ap, int ) ) != -1 ) {

			if( ( rc = op( form, label ) ) != FI_SUCCESS ) {
				break ;
			}
		}

	va_end( ap ) ;

	return rc ;

} /* VSg_op_on_gadgets */
/*----------------------------------------------------------------------------*/
int VSf_enable_form( form, labDescr )

register char			*form ;
register struct VSgadget	*labDescr ; {

	int	attr ;

	for( ; labDescr->label != -1 ; labDescr++ ) {
		if( labDescr->touchable ) {
			FIg_get_attr( form, labDescr->label, &attr ) ;

			if( !( attr & FI_NOT_DISPLAYED ) ) {
				FIg_enable( form, labDescr->label ) ;
			}
		} else {
			 FIg_disable( form, labDescr->label ) ;
		}
	}
	return FI_SUCCESS ;

} /* VSf_enable_form */
/*----------------------------------------------------------------------------*/
int VSf_disable_form( form, labDescr )

register char			*form ;
register struct VSgadget	*labDescr ; {

	int	attr ;

	for( ; labDescr->label != -1 ; labDescr++ ) {
		if( labDescr->touchable ) {
			FIg_get_attr( form, labDescr->label, &attr ) ;
			if( !( attr & FI_NOT_DISPLAYED ) ) {
				FIg_disable( form, labDescr->label ) ;
			}
		}
	}
	return FI_SUCCESS ;

} /* VSf_disable_form */
/*----------------------------------------------------------------------------*/
int VSf_display( form ) char *form ; {

	int rc ;

	if( ( rc = FIf_display( form ) ) == FI_NO_SUCH_VS ) {
		FIf_set_screen( form, FI_CURRENT_SCREEN ) ;
		rc = FIf_display( form ) ;
	}
	return rc ;

} /* VSf_display */
/*----------------------------------------------------------------------------*/
void VSmcf_set_list_text( form, label, column, size, list )

char	*form ;
int	label,
	column,
	size ;
char 	**list ; {

	int row ,
	    nb_rows ;

	if( !column ) {
		/*
		 * We want to fill column 0, but before delete previous data
		 * in all rows and columns.
		 */
		FIfld_get_num_rows(		form,
						label,
						&nb_rows ) ;

		FIfld_delete_rows(		form,
						label,
						0,
						nb_rows ) ;
	}

	for( row = 0 ; row < size ; row++ ) {
		FIfld_set_text(		form,
					label,
					row,
					column,
					list[row],
					FALSE ) ;
	}

} /* VSmcf_set_list_text */
/*----------------------------------------------------------------------------*/
char **VSmcf_get_list_text( form, gadget, column )
	
char	*form ;
int	gadget,
	column ; {
		
	char	**list = NULL ;
	int	nb_rows,
		i ;
	
	FIfld_get_num_rows(	form,
				gadget,
				&nb_rows ) ;
	
	if( list = _CALLOC( nb_rows + 1, char * ) ) {
		
		for( i = 0 ; i < nb_rows ; i++ ) {
			list[i] = VSmcf_get_text( form, gadget, i, column ) ;
		}
	}
	return list ;
	
} /* VSmcf_get_list_text */
/*----------------------------------------------------------------------------*/
int VSfld_blank_out_rows( form, label, column )

char		*form ;
int		label,
		column ; {

	int	rc,
		i,
		nrows ;

	rc = FIfld_get_num_rows( form, label, &nrows ) ;
	if( rc != FI_SUCCESS ) return rc ;

	for( i = 0 ; i < nrows ; i++ ) {
		FIfld_set_text( form, label, i, column, "", FALSE ) ;
	}

	return FI_SUCCESS ;

} /* VSfld_blank_out_rows */
/*----------------------------------------------------------------------------*/
int VSfld_del_empty_rows( form, label, column )

char		*form ;
int		label,
		column ; {

	int	rc,
		i,
		j,
		empty,
		nrows ;
	char	**list ;

	rc = FIfld_get_num_rows( form, label, &nrows ) ;
	if( rc != FI_SUCCESS ) return rc ;

	if( !nrows ) return FI_SUCCESS ;

	list = VSmcf_get_list_text( form, label, column ) ;

/*
	FIfld_delete_rows( form, label,	0, nrows ) ;
*/ 
	for( i = 0, j = 0 ; i < nrows ; i++ ) {

		empty = TRUE ;

		if( list[i] && *list[i] ) {
			char	*c = list[i] ;
			while( *c ) {
				if( *c != ' ' ) {
					int	l ;
					empty = FALSE ;
					/*
					 * Remove leading blanks.
					 */
					l = strlen( c ) ;
					OM_BLOCK_MOVE( c, list[i], l+1 ) ;
					/*
					 * Remove trailing blanks.
					 */
					c = strchr( list[i], ' ' ) ;
					if( c ) *c = '\0' ;
					break ;
				} else c++ ;
			}
		}
		if( !empty ) {
			FIfld_set_text(	form, label, j, column, list[i], FALSE);
			j++ ;
		}
	}
	FIfld_set_num_rows( form, label, j ) ;

	VSfreeList( nrows, list ) ;

	return FI_SUCCESS ;

} /* VSfld_del_empty_rows */
/*----------------------------------------------------------------------------*/
void VSscrollField( form, label, pos )

char	*form ;
int	label,
	pos ; {

	FIfld_set_active_char( form, label, 0, pos, 0 ) ;

} /* VSscrollField */
/*----------------------------------------------------------------------------*/
int VSfld_restart( form, gadget ) char *form ; int gadget ; {

	int	rc, fdsp, mask ;

	/* In 2.2 'FIg_reset' crashes ...
	 * So comment it out (until when ?) and replace it with a call to
	 * 'FIfld_set_text' to erase the field.
	 */
/* --- Commented out - see why above.
	rc = FIg_reset( form, gadget ) ;
   --- End */
	rc = FIfld_set_text( form, gadget, 0, 0, "", FALSE ) ;
	if( rc == FI_SUCCESS ) {
		FIf_is_displayed( form, &fdsp ) ;
		FIg_get_attr( form, gadget, &mask ) ;

		if( fdsp && !( mask & FI_NOT_DISPLAYED ) ) {
			FIfld_pos_cursor( form, gadget, 0, 0, 0, 0, 0, 0 ) ;
		}
	}
	return rc ;
	
} /* VSfld_restart */
/*----------------------------------------------------------------------------*/
int VSfld_set_text_and_scroll( form, gadget, row, text )

char	*form ;
int	gadget,
	row ;
char	*text ; {

	int rc ;

	/*
	 * Puts text to field and scrolls down if row is not visible so as to
	 * bring it into view.
	 */

	rc = FIfld_set_text( form, gadget, row, 0, text, FALSE ) ;
	if( rc == FI_SUCCESS ) {

		int	vis_rows,
			offset ;

		FIfld_get_row_offset( form, gadget, &offset ) ;
		FIfld_get_num_vis_rows( form, gadget, &vis_rows ) ;

		/*
		 * Is row in [offset,offset+vis_rows] ?
		 */
		if( !( offset <= row && row < offset + vis_rows ) ) {
			/*
			 * Scroll field.
			 */
			FIfld_set_active_row(	form,
						gadget,
						row,
						offset + vis_rows -1 ) ;
		}
	}
	return rc ;

} /* VSfld_set_text_and_scroll */
/*----------------------------------------------------------------------------*/
int VSfi_prompt( form, prompt ) char *form, *prompt ; {

	return FIfld_set_text( form, FI_PROMPT_FIELD, 0, 0, prompt, FALSE ) ;

} /*  VSfi_prompt */
/*----------------------------------------------------------------------------*/
int VSfi_msg( form, msg ) char *form, *msg ; {

	return FIfld_set_text( form, FI_MSG_FIELD, 0, 0, msg, FALSE ) ;

} /*  VSfi_msg */
/*----------------------------------------------------------------------------*/
int VSfi_msgkey( form, msg ) char *form ; long msg ; {

	return VSfi_msg( form, VSmsgkey2string( msg ) ) ;

} /* VSfi_msgkey */
/*----------------------------------------------------------------------------*/
int VSfi_msgkeySts( form, msgkey ) char *form ; long msgkey ; {

	char	*msg ;

	msg = VSmsgkey2string( msgkey ) ;

	ex$message(	field		= ERROR_FIELD,
			justification	= CENTER_JUS,
			in_buff		= msg ) ;
	return FIfld_set_text( form, FI_MSG_FIELD, 0, 0, msg, FALSE ) ;

} /*  VSfi_msg */
/*----------------------------------------------------------------------------*/
int VSfi_put_paste_buffer( buf ) char *buf ; {

	/*
	 * Use basic graphic interface scrap buffer.
	 */
	VS_Clear_scrap() ;
	VS_Put_scrap( "TEXT", buf, strlen( buf ) ) ;

	return TRUE ;

} /* VSfi_put_paste_buffer */
/*----------------------------------------------------------------------------*/
char *VSfi_get_paste_buffer( buf ) char *buf ; {

	int	size, index ;

	/*
	 * Use basic graphic interface scrap buffer.
	 */
	VS_Get_scrap( "TEXT", NULL, &size, &index ) ;
	if( size ) {
		char	*tmp ;

		tmp = _MALLOC( size + 1, char ) ;
		if( tmp ) {
			int	trunc ;

			VS_Get_scrap( "TEXT", tmp, &size, &index ) ;
			tmp[size] ='\0' ;

			VSstrncpy( buf, tmp, VS_K_FI_PASTELEN, &trunc ) ;

			_FREE( tmp ) ;
		} else {
			*buf = '\0' ;
		}
	} else {
		*buf = '\0' ;
	}

	return buf ;

} /* VSfi_get_paste_buffer */
/*----------------------------------------------------------------------------*/
int VSfld_insert_text( form, gadget, row, col, charpos, text )

char	*form,
	*text ;
int	gadget,
	row,
	col,
	charpos ; {

	int	rc,
		oldlen,
		newlen,
		sel,
		pos ;
	char	*oldbuf = NULL,
		*newbuf = NULL ;

	rc = FIfld_get_mode( form, gadget, col, &sel ) ;
	if( rc == FI_SUCCESS ) {
		if( sel != FI_INSERT ) {
			rc = FI_INVALID_GADGET_TYPE ;
			goto wrapup ;
		}
	} else goto wrapup ;

	if( !text || !*text ) return FI_SUCCESS ;

	FIfld_get_num_rows( form, gadget, &pos ) ;

	if( pos == 0 ) {
		FIfld_set_num_rows( form, gadget, 1 ) ;
		FIfld_set_text( form, gadget, 0, 0, "", FALSE ) ;
	}
	rc = FIfld_get_text_length( form, gadget, row, col, &oldlen ) ;

	/*
	 * NOTE : FIfld_get_text_length counts the space for the terminating
	 * NULL.
	 */
	newlen = oldlen + strlen( text ) ;
	if( !(	   ( oldbuf = _MALLOC( oldlen, char ) )
		&& ( newbuf = _MALLOC( newlen, char ) ) ) ) {
		rc = FI_NO_MEMORY ;
		goto wrapup ;
	}

	FIfld_get_text( form, gadget, row, col, oldlen,
			(unsigned char *) oldbuf, &sel, &pos ); 

	/*
	 * charpos is in [0,oldlen-2]
	 */
	if( charpos <= 0 || oldlen == 1 ) {
		/*
		 * Insert in front.
		 * oldlen == 1 means oldbuf = "".
		 */
		strcpy( newbuf, text ) ;
		strcat( newbuf, oldbuf ) ;
	} else if( charpos <= oldlen - 2 ) {
		/*
		 * Copy charpos characters from oldbuf to newbuf.
		 */
		strncpy( newbuf, oldbuf, charpos ) ;
		/*
		 * Copy text to newbuf at charpos.
		 */
		strcpy( newbuf + charpos, text ) ;
		/*
		 * Cat rest of oldbuf.
		 */
		strcat( newbuf, oldbuf + charpos ) ;
	} else {
		/*
		 * Insert at the end.
		 */
		strcpy( newbuf, oldbuf ) ;
		strcat( newbuf, text   ) ;
	}

	FIfld_set_text( form, gadget, row, col, newbuf, FALSE ) ;

	rc = FI_SUCCESS;
	
	wrapup :
		_FREE( oldbuf ) ;
		_FREE( newbuf ) ;
		return rc ;

} /* VSfld_insert_text */
/*----------------------------------------------------------------------------*/
int VSfld_flip_row_block( form, label, row, col, weight )

char	*form ;
int	label,
	row,
	col,
	weight ; {

	/*
	 * Highlight a row of a field as well as you can.
	 */
	int	rc,
		gtype,		/* Field type		*/
		height,		/* Row height		*/
		xoff,		/* X-offset of column	*/
		xs,		/* Width of column	*/
		xl,		/* X-location of field	*/
		yl,		/* Y-location of field	*/
		xmin,
		ymin,
		xmax,
		ymax ;
	VSgrEnvWindow	wno ;

	rc = FIfld_get_row_height( form, label, &height ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	FIg_get_type( form, label, &gtype ) ;

	if( gtype == FI_MULTI_COL ) {
		int	offset,
			viscol,
			wcol,
			hcol, 
			i ;

		/*
		 * Compute x-offset from left end of MCF, as well as column
		 * width ("xs").
		 */
		FImcf_get_view_data( form, label, &offset, &viscol ) ;

		if( !( offset <= col && col < offset + viscol ) ) {
			/*
			 * Column not visible.
			 */
			rc = FI_SUCCESS ; goto wrapup ;
		}
		xoff = 0 ;
		for( i = offset ; i < col ; i++ ) {
			FImcf_get_col_size( form, label, i, &wcol, &hcol ) ;
			xoff += wcol ;
		}

		FImcf_get_col_size( form, label, col, &wcol, &hcol ) ;
		xs = wcol ;
	} else {
		/*
		 * Simple field.
		 */
		int	ys ;

		xoff = 0 ;
		FIg_get_size( form, label, &xs, &ys ) ;
	}


	FIg_get_location( form, label, &xl, &yl ) ;
	xl += xoff ;

	xmin = xl ;
	ymin = yl + row * height ;
	xmax = xmin + xs ;
	ymax = ymin + height ;

	VS_FIhidecursor( form ) ;
#define D	weight
	VS_FIf_get_window( form, &wno ) ;
	VS_flipblock( &wno, xmin	, ymin	  , xmax    , ymin + D ) ;
	VS_flipblock( &wno, xmax - D	, ymin + D, xmax    , ymax - D ) ; 
	VS_flipblock( &wno, xmin	, ymax - D, xmax    , ymax     ) ;
	VS_flipblock( &wno, xmin	, ymin + D, xmin + D, ymax - D ) ;
#undef D
	VS_FIshowcursor( form ) ;

	wrapup :
		return rc ;

} /* VSfld_flip_row_block */
/*----------------------------------------------------------------------------*/
int VSf_sub_form( form, subFormLabel, subFormFile, subForm )

char	*form,
	*subFormFile,
	**subForm ;
int	subFormLabel ; {

	int		rc,
			xpos,
			ypos,
			xsiz,
			ysiz,
			xs,
			ys ;
	OMuword		cmdOs ;
	OM_S_OBJID	cmdId ;
	int		(*notify)() ;

	*subForm = NULL ;

	rc = FIf_get_notification_routine( form, &notify ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIf_new( subFormLabel, subFormFile, notify, subForm ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	FIf_get_cmd_oid_os( form, (unsigned int *) &cmdId, &cmdOs ) ;
	FIf_set_cmd_oid_os( *subForm, cmdId, cmdOs ) ;
	
	FIf_get_location( form, &xpos, &ypos ) ;
	FIf_get_size( form, &xsiz, &ysiz ) ;
	FIf_get_size( *subForm, &xs, &ys ) ;

	FIf_set_rel_location( *subForm, xpos + xsiz, ypos + ysiz - ys, form ) ;
	FIf_set_collapse_location( *subForm, xpos + xsiz, ypos + ysiz - ys ) ;

	wrapup :
		return rc ;

} /* VSf_sub_form */
/*----------------------------------------------------------------------------*/
int VSfld_insert_newline( form, label, row )

char	*form ;
int	label,
	row ; {

	int	rc,
		numrows ;

	rc = FIfld_get_num_rows( form, label, &numrows ) ;
	if( rc == FI_SUCCESS ) {
		if( row < numrows - 1 ) {
			rc = FIfld_insert_blank_row( form, label, row + 1 ) ;
		} else {
			rc = FIfld_set_num_rows( form, label, row + 2 ) ;
		}
	}
	return rc ;
	
} /* VSfld_insert_newline */
/*----------------------------------------------------------------------------*/
int VSfld_get_cursor( form, label, row, charpos )

char	*form ;
int	label,
	*row,
	*charpos ; {

	int	rc,
		pos ;

	*row = *charpos = 0 ;

	if( ( rc = FIfld_get_active_row(form,
					label,
					row,
					&pos ) ) == FI_SUCCESS ) {

		rc = FIfld_get_active_char( form, label, 0, charpos, &pos ) ;
	}
	return rc ;

} /* VSfld_get_cursor */
/*----------------------------------------------------------------------------*/
int VSfld_set_cursor( form, label, row, charpos )

char	*form ;
int	label,
	row,
	charpos ; {

	int	rc,
		vis,
		offset,
		pos ;

	rc =  FIfld_get_num_vis_rows( form, label, &vis ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;
	rc =  FIfld_get_row_offset( form, label, &offset ) ;

	if( offset <= row && row < offset + vis ) {
		pos = row ;
	} else {
		pos = vis / 2 ;
	}
	
	FIfld_set_active_row( form, label, row, pos ) ;

	FIfld_get_num_vis_chars( form, label, 0, &vis ) ;
	if( charpos < vis ) {
		pos = vis ;
	} else {
		pos = vis / 2 ;
	}

	FIfld_set_active_char( form, label, 0, charpos, pos ) ;

	wrapup :
		return rc ;

} /* VSfld_set_cursor */
/*----------------------------------------------------------------------------*/
int VSfld_delete_word( form, label, row, col, charpos, rowDeleted, delWord )

char	*form ;
int	label,
	row,
	col,
	charpos,
	*rowDeleted ;
char	**delWord ; {

	int	rc,
		mode ;
	char	*text ;

	rc = FIfld_get_mode( form, label, col, &mode ) ;

	if( rc == FI_SUCCESS ) {
		if( mode != FI_INSERT ) {
			rc = FI_INVALID_GADGET_TYPE ; goto wrapup ;
		}
	} else goto wrapup ;
	
	if( !( text = VSmcf_get_text( form, label, row, col ) ) ) {
		rc = FI_NO_MEMORY ; goto wrapup ;
	}
	if( *text ) {
		VSdeleteWordAtIndex( text, charpos, delWord ) ;

		rc = FIfld_set_text( form, label, row, col, text, FALSE ) ;
		*rowDeleted = FALSE ;
	} else {
		/*
		 * Empty row: remove it.
		 */
		rc = FIfld_delete_rows( form, label, row, 1 ) ;
		*rowDeleted = TRUE ;
		if( delWord ) *delWord = NULL ;
	}
	_FREE( text ) ;

	wrapup :
		return rc ;

} /* VSfld_delete_word */
/*----------------------------------------------------------------------------*/
int VSf_locate( form, rangeGadget, p_x, p_y, p_gadget, relocate )

char		*form ;
int		rangeGadget,
		*p_x,
		*p_y,
		*p_gadget,
		relocate ; {

	int		rc,
			attr,
			wstat,
			xmin,
			ymin,
			xmax,
			ymax ;
	VSgrEnvWindow	wno ;

#define PIXDIST 3
	*p_gadget = -1 ;

	if( ( rc = VS_FIf_get_window( form, &wno ) ) != FI_SUCCESS )
		goto wrapup ;

	rc = VS_Mouseposition( &wno, p_x, p_y, &wstat ) ;

	if( !( rc == 0 && wstat ) ) { rc = FI_SUCCESS ; goto wrapup ; }

	if( rangeGadget != -1 ) {
		rc = VSg_get_layout( form, rangeGadget,
					&xmin, &ymin, &xmax, &ymax ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		xmax += xmin ; ymax += ymin ;
	} else {
		xmin = ymin = 0 ;
		FIf_get_size( form, &xmax, &ymax ) ;
	}

	if( !(    xmin <= *p_x && *p_x <= xmax
	       && ymin <= *p_y && *p_y <= ymax ) ) {
		rc = FI_SUCCESS ; goto wrapup ;
	}

	rc = FIf_find_by_point( form, FI_FORM_GROUP, *p_x, *p_y, PIXDIST,
				p_gadget, relocate ? 0 : 1 ) ;

	/*
	 * Make sure we did not got the range gadget.
	 */
	if(    rc == FI_SUCCESS
	    && rangeGadget != -1
	    && rangeGadget == *p_gadget ) {
		rc = FIf_find_by_point( form, FI_FORM_GROUP, *p_x, *p_y,
					PIXDIST, p_gadget, 0 ) ;

		if( rc != FI_SUCCESS ) {
			*p_gadget = -1 ;
			rc = FI_SUCCESS ;
			goto wrapup ;
		}

	}

	/*
	 * Do not return undisplayed gadgets.
	 */
	while( TRUE ) {
		FIg_get_attr( form, *p_gadget, &attr ) ;
		if( !( attr & FI_NOT_DISPLAYED ) ) {
			break ;
		}
		/*
		 * Find next gadget
		 */
		rc = FIf_find_by_point( form, FI_FORM_GROUP, *p_x, *p_y,
					PIXDIST, p_gadget, 0 ) ;
		if( rc != FI_SUCCESS ) {
			*p_gadget = -1 ;
			rc = FI_SUCCESS ;
			goto wrapup ;
		}
	}
	wrapup :
		return rc ;

} /* VSf_locate */
/*----------------------------------------------------------------------------*/
int VSf_rmSaveRestoreProp( form ) char *form ; {

	int	rc ;
	long	fattr ;

	rc = FIf_get_attr( form, &fattr ) ;
	if( rc == FI_SUCCESS && ( fattr & FI_SAVE_RESTORE ) ) {
		fattr &= ~FI_SAVE_RESTORE ;
		FIf_set_attr( form, fattr ) ;
		FIg_erase( form, FI_CVT_TO_PERM_WIN ) ;
	}

	return rc ;

} /* VSf_rmSaveRestoreProp */
/*----------------------------------------------------------------------------*/
void VSscroll_field( form, label, direction )

char	*form ;
int	label ;
int	direction ; /* direction = 0 : push text to the left,
		       direction = 1 : push text to the right */ {

	int		textLength,
			maxVisChar,
			actChar,
			charPos ;

	FIfld_get_text_length( form, label, 0, 0, &textLength ) ;
	FIfld_get_num_vis_chars( form, label, 0, &maxVisChar ) ;
	FIfld_get_active_char( form, label, 0, &actChar, &charPos ) ;

	if( direction ) actChar++ ;
	else		actChar-- ;

	if( ( actChar <= (textLength -1 -maxVisChar) ) && ( actChar >= 0 ) )
		FIfld_set_active_char( form, label, 0, actChar, 0 ) ;

} /* VSscroll_field */
/*----------------------------------------------------------------------------*/

