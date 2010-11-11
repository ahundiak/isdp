/* $Id: VDdrwtxtsupp.C,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwtxtsupp.C
 *
 * Description:
 *		Text support functions
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwtxtsupp.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.3  2000/02/22  16:39:30  pinnacle
 * (No comment)
 *
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
 * Revision 1.2  1995/08/21  18:56:30  pinnacle
 * Replaced: vddraw/drw/VDdrwtxtsupp.C for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	08/19/95   tlb		Change malloc to _MALLOC, free to _FREE
 *
 *************************************************************************/
/*
	I/VDS	Copy.
*/
#include <stdlib.h>
#include <string.h>
#include "gotextdef.h"
#include "v_drw.h"
#include "fontdef.h"
#include "font.h"
#include "VDmem.h"
#include "VDdrwgrammar.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes
 */
#include "GRfldrefpt.h"
/*----------------------------------------------------------------------------*/
int VD_getTxOffType( off, type, kwtype ) int off, *kwtype, *type ; {

	int		rc	= TRUE,
			k	= 0,
			t	= 0 ;

	switch( off ) {
	case (int) VD_top	: t = (int) VD_above	; k = ABOVE	; break;
	case (int) VD_bottom	: t = (int) VD_below	; k = BELOW	; break;
	case (int) VD_left	: t = (int) VD_toTheLeft	; k = TOTHELEFT ; break;
	case (int) VD_right	: t = (int) VD_toTheRight; k = TOTHERIGHT; break;
	default			: rc = FALSE ;
	}
	*kwtype	= k ;
	*type	= t ;

	return rc ;

} /* VD_getTxOffType */
/*----------------------------------------------------------------------------*/
int VD_getTxPosType( pos, type, kwtype ) int pos, *kwtype ; VD_txPosType *type ; {

	int		rc = TRUE,
			kw = 0 ;
	VD_txPosType	t  = VD_txLoc ;

	switch( pos ) {
	case (int) VD_top	: kw = TOP		; t = VD_txLoc ; break ;
	case (int) VD_bottom	: kw = BOTTOM		; t = VD_txLoc ; break ;
	case (int) VD_right	: kw = RIGHT		; t = VD_txLoc ; break ;
	case (int) VD_left	: kw = LEFT		; t = VD_txLoc ; break ;
	case (int) VD_1stEnd	: kw = AT1STEND		; t = VD_txLoc ; break ;
	case (int) VD_2ndEnd	: kw = AT2NDEND		; t = VD_txLoc ; break ;
	case (int) VD_center	: kw = CENTER		; t = VD_txLoc ; break ;
	case (int) VD_middle	: kw = MIDDLE		; t = VD_txLoc ; break ;
	case (int) VD_innermost	: kw = INNERMOST	; t = VD_txLoc ; break ;
	case (int) VD_horiz	: kw = HORIZONTAL	; t = VD_txDir ; break ;
	case (int) VD_para	: kw = PARALLEL		; t = VD_txDir ; break ;
	case (int) VD_ortho	: kw = ORTHOGONAL	; t = VD_txDir ; break ;
	case (int) VD_notReversed: kw = NOTREVERSED	; t = VD_txRev ; break ;
	case (int) VD_upsideDown: kw = UPSIDEDOWN	; t = VD_txRev ; break ;
	case (int) VD_rightToLeft: kw = RIGHTTOLEFT	; t = VD_txRev ; break ;
	default			: rc = FALSE      		      ; break ;
	}

	*kwtype = kw ;
	*type	= t ;

	return rc ;

} /* VD_getTxPosType */
/*----------------------------------------------------------------------------*/
int VD_checkJustification( just ) int just ; {

	int	rc ;

	switch( just ) {
		case LEFT_BOTTOM	:
		case LEFT_BASE		:
		case LEFT_CENTER	:
		case LEFT_CAP		:
		case LEFT_TOP		:
		case CENTER_BOTTOM	:
		case CENTER_BASE	:
		case CENTER_CENTER	:
		case CENTER_CAP		:
		case CENTER_TOP		:
		case RIGHT_BOTTOM	:
		case RIGHT_BASE		:
		case RIGHT_CENTER	:
		case RIGHT_CAP		:
		case RIGHT_TOP		: rc = TRUE ; break ;
		default			: rc = FALSE; break ;
	}

	return rc ;

} /* VD_checkJustification */
/*----------------------------------------------------------------------------*/
int VD_drwJustToTokNum( j ) int j ; {

	int	tok ;

	switch( j ) {
		default			: /* Should not get here */
		case LEFT_BOTTOM	: tok = JLEFT_BOTTOM	; break ;
		case LEFT_BASE		: tok = JLEFT_BASE	; break ;
		case LEFT_CENTER	: tok = JLEFT_CENTER	; break ;
		case LEFT_CAP		: tok = JLEFT_CAP	; break ;
		case LEFT_TOP		: tok = JLEFT_TOP	; break ;
		case CENTER_BOTTOM	: tok = JCENTER_BOTTOM	; break ;
		case CENTER_BASE	: tok = JCENTER_BASE	; break ;
		case CENTER_CENTER	: tok = JCENTER_CENTER	; break ;
		case CENTER_CAP		: tok = JCENTER_CAP	; break ;
		case CENTER_TOP		: tok = JCENTER_TOP	; break ;
		case RIGHT_BOTTOM	: tok = JRIGHT_BOTTOM	; break ;
		case RIGHT_BASE		: tok = JRIGHT_BASE	; break ;
		case RIGHT_CENTER	: tok = JRIGHT_CENTER	; break ;
		case RIGHT_CAP		: tok = JRIGHT_CAP	; break ;
		case RIGHT_TOP		: tok = JRIGHT_TOP	; break ;
		
	}
	return tok ;

} /* VD_drwJustToTokNum */
/*----------------------------------------------------------------------------*/
void VD_drwTxInit( t ) register VD_drwText *t ; {
	t->buffer = NULL ;
	t->bufsiz = t->curpos = 0 ;
} /* VD_drwTxInit */
/*----------------------------------------------------------------------------*/
void VD_drwTxFree( t ) register VD_drwText *t ; {

	/*
	 * Frees string buffer in text structure.
	 */
	if( t->bufsiz ) _FREE( t->buffer ) ;
	VD_drwTxInit( t ) ;

} /* VD_drwTxFree */
/*----------------------------------------------------------------------------*/
static char *VD_allocDrwText( t, n ) register VD_drwText *t ; unsigned n ; {

	/*
	 * (Re)allocates string buffer in text structure.
	 */
	register char	*newptr ;

#define CHUNK	128

	if( t->bufsiz ) {
		n += t->bufsiz + CHUNK ;
		if( newptr = _REALLOC( t->buffer, n, char) ) {
			t->buffer = newptr ;
			t->bufsiz = n ;
		}	
	} else {
		if( n && ( newptr = _MALLOC( n, char) ) ) {
			t->buffer = newptr ;
			t->bufsiz = n ;
			t->curpos = 0 ;
		}
	}

	return newptr ;

} /* VD_allocDrwText */
/*----------------------------------------------------------------------------*/
void VD_drwTxMOVE( t, mvflag, mvval )

VD_drwText		*t ;
IGRchar			mvflag ;		/* mvflag = 'h','v','s'	*/
IGRdouble			mvval ; {

	/*
	 * Puts text commands 'h','v','s' into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 1 + 1 + sizeof( mvval ) ;

	VD_drwTxInit( t ) ;

	if( !VD_allocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ;
	*p++ = mvflag ;
	memcpy( p, (char *) &mvval, sizeof( mvval ) ) ;

	t->curpos += nbytes ;

} /* VD_drwTxMOVE */
/*----------------------------------------------------------------------------*/
void VD_drwTxFSTART( t, fieldno )

register VD_drwText	*t ;
int			fieldno ; {

	/*
	 * Puts "start field" command into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 4 ;

	VD_drwTxInit( t ) ;

	if( !VD_allocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ; *p++ = 'F' ; *p++ = fieldno ; *p++ = 0 ;

	t->curpos += nbytes ;

} /* VD_drwTxFSTART */
/*----------------------------------------------------------------------------*/
void VD_drwTxFEND( t ) register VD_drwText *t ; {

	/*
	 * Puts "end field" command into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 2 ;

	VD_drwTxInit( t ) ;

	if( !VD_allocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ; *p++ = 'E' ;

	t->curpos += nbytes ;

} /* VD_drwTxFEND */
/*----------------------------------------------------------------------------*/
void VD_drwTxMVTOFLD( t, text, fieldno, justification, txSymb, display )

VD_drwText		*t,
			*text ;
short			fieldno ;
char			justification ;
struct GRdpb_text_symb	*txSymb ;
struct IGRdisplay	*display ; {


	/*
	 * Puts "move to field" command into string buffer.
	 */
	long			msg ;
	register char		*p ;
	double			hmove = 0.,
				vmove = 0. ;
	short			length ;
	struct vfont_entry	fontInfo ;
	register unsigned	nbytes = 1 + 1 + 1 + 1 + 2 * sizeof( double ) ;

	VD_drwTxInit( t ) ;

	if( !VD_allocDrwText( t, nbytes ) ) return ;

	if( text && text->curpos ) {
		VD_getFontInfo( &msg, txSymb->Active_font, &fontInfo ) ;
		if( msg & 1 ) {
			unsigned char fno = fieldno ;

			length = text->curpos ;

			/*
			 * Evaluate horizontal and vertical moves needed to
			 * go from where we are to the justification point of
			 * the field.
			 */
			GRfld_ref_pt(	&msg,
					(unsigned char *) text->buffer,
					&length,
					&fno,
					&fontInfo,
					display,
					&txSymb->Active_linespac,
					&txSymb->Active_charspac,
					&txSymb->Active_height,
					&txSymb->Active_width,
					&txSymb->Active_font,
					&justification,
					&hmove,
					&vmove ) ;

        	}
		if( !( msg & 1 ) ) hmove = vmove = 0 ;
	}

	p = t->buffer + t->curpos ;

	*p++ = ESC ;
	*p++ = 'M' ;
	*p++ = fieldno ;
	*p++ = justification ;
	memcpy( p, (char *) &hmove, sizeof( hmove ) ) ;
	p += sizeof( hmove ) ;
	memcpy( p, (char *) &vmove, sizeof( vmove ) ) ;

	t->curpos += nbytes ;

} /* VD_drwTxMVTOFLD */
/*----------------------------------------------------------------------------*/
void VD_drwTxCHGFONT( t, fontno ) VD_drwText *t ; short fontno ; {

	/*
	 * Puts text commands 'f' (change font) into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 1 + 1 + sizeof( fontno ) ;

	VD_drwTxInit( t ) ;

	if( !VD_allocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ;
	*p++ = 'f' ;
	memcpy( p, (char *) &fontno, sizeof( fontno ) ) ;

	t->curpos += nbytes ;

} /* VD_drwTxCHGFONT */
/*----------------------------------------------------------------------------*/
void VD_drwTxINITSTRING( t, string )

register VD_drwText	*t ;
const char		*string ; {

	/*
	 * Initializes string buffer with a null-terminated string.
	 */
	register unsigned	nbytes = strlen( string ) ;

	VD_drwTxInit( t ) ;

	__DBGpr_int( "Length of string", nbytes ) ;

	if( VD_allocDrwText( t, nbytes ) ) {
		__DBGpr_str( "Init text with", string ) ;
		memcpy( t->buffer + t->curpos, string, nbytes ) ;
		t->curpos += nbytes ;
	}

} /* VD_drwTxINITSTRING */
/*----------------------------------------------------------------------------*/
void VD_drwTxMERGE( toMerge1, toMerge2, merged )

const VD_drwText	*toMerge1 ;
const VD_drwText	*toMerge2 ;
VD_drwText	*merged ; {

	unsigned	nbytes = toMerge1->curpos + toMerge2->curpos ;

	*merged = *toMerge1 ;

	if( VD_allocDrwText( merged, nbytes ) ) {
		memcpy( merged->buffer + merged->curpos,
			toMerge2->buffer,
			toMerge2->curpos * sizeof( char ) ) ;
		merged->curpos += toMerge2->curpos ;
	}
	VD_drwTxInit( toMerge1 ) ; VD_drwTxFree( toMerge2 ) ;

} /* VD_drwTxMERGE */
/*----------------------------------------------------------------------------*/
#ifdef vdsDEBUG
VD_dumpTxtSymb( s ) struct GRdpb_text_symb *s ; {

__DBGpr_int( "Font       ", s->Active_font ) ;
__DBGpr_int( "ASCII  font", s->Active_ascii_font ) ;
__DBGpr_int( "Symbol font", s->Active_fraction_font ) ;
__DBGpr_int( "Fract  font", s->Active_symbol_font ) ;
__DBGpr_int( "Justif     ", s->Active_just ) ;
__DBGpr_dbl( "Width      ", s->Active_width ) ;
__DBGpr_dbl( "Height     ", s->Active_height ) ;
__DBGpr_dbl( "Char spac  ", s->Active_charspac ) ;
__DBGpr_dbl( "Line spac  ", s->Active_linespac ) ;
__DBGpr_int( "Flags      ", s->Active_flags ) ;

}
/*----------------------------------------------------------------------------*/
VD_dumpTextString( s, size ) char *s ; int size ; {
	int i, j ; double d ; short f ;

	printf( "String size %d\n", size ) ;
	j = size ;
	for( i = 0 ; i < j ; ) {
		switch( s[i] ) {
			case	ESC	: printf( "ESC " ) ;
			switch( s[i+1] ) {
			case 'f' : printf( "'%c' ", s[i+1] ) ;
			           memcpy( &f, s + i + 2, 2 ) ;
			           printf( "%d ", f ) ;
			           i += 4 ;
			           break ;
			case 'v' : 
			case 'h' :
			case 's' : printf( "'%c' ", s[i+1] ) ;
				   memcpy( &d, s + i + 2, 8 ) ;
				   printf( "%g ", d ) ;
				   i += 10 ;
				   break ;
			case 'F' : printf( "'F' %d %d ", s[i+2], s[i+3] ) ;
				   i += 4 ;
				   break ;
			case 'E' : printf( "'E' " ) ; i += 2 ; break ;
			case 'M' : printf( "'M' %d %d ", s[i+2], s[i+3] ) ;
				   memcpy( &d, s + i + 4, 8 ) ;
				   printf( "%g ", d ) ;
				   memcpy( &d, s + i + 12, 8 ) ;
				   printf( "%g ", d ) ;
				   i += 20 ;
				   break ;
			default	:  printf( "UNKNOWN " ) ; i+= 2 ; break ;
			}
			break ;
			default	: printf( "%c(%x) ", s[i], s[i] ) ; i++ ;
		}
	}
	printf( "\n" ) ;

} /* VD_dumpTextString */
/*----------------------------------------------------------------------------*/
#endif
