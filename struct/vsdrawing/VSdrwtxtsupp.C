/*
	I/STRUCT
*/
#include <stdlib.h>
#include <string.h>
#include "gotextdef.h"
#include "vsdrw.h"
#include "fontdef.h"
#include "font.h"
#include "VSdrwgrammar.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
#include "GRfldrefpt.h"
/*----------------------------------------------------------------------------*/
int VSgetTxOffType( off, type, kwtype ) int off, *kwtype, *type ; {

	int		rc	= TRUE,
			k	= 0,
			t	= 0 ;

	switch( off ) {
	case (int) VStop	: t = (int) VSabove	; k = ABOVE	; break;
	case (int) VSbottom	: t = (int) VSbelow	; k = BELOW	; break;
	case (int) VSleft	: t = (int) VStoTheLeft	; k = TOTHELEFT ; break;
	case (int) VSright	: t = (int) VStoTheRight; k = TOTHERIGHT; break;
	default			: rc = FALSE ;
	}
	*kwtype	= k ;
	*type	= t ;

	return rc ;

} /* VSgetTxOffType */
/*----------------------------------------------------------------------------*/
int VSgetTxPosType( pos, type, kwtype ) int pos, *kwtype ; VStxPosType *type ; {

	int		rc = TRUE,
			kw = 0 ;
	VStxPosType	t  = VStxLoc ;

	switch( pos ) {
	case (int) VStop	: kw = TOP		; t = VStxLoc ; break ;
	case (int) VSbottom	: kw = BOTTOM		; t = VStxLoc ; break ;
	case (int) VSright	: kw = RIGHT		; t = VStxLoc ; break ;
	case (int) VSleft	: kw = LEFT		; t = VStxLoc ; break ;
	case (int) VS1stEnd	: kw = AT1STEND		; t = VStxLoc ; break ;
	case (int) VS2ndEnd	: kw = AT2NDEND		; t = VStxLoc ; break ;
	case (int) VScenter	: kw = CENTER		; t = VStxLoc ; break ;
	case (int) VSmiddle	: kw = MIDDLE		; t = VStxLoc ; break ;
	case (int) VSinnermost	: kw = INNERMOST	; t = VStxLoc ; break ;
	case (int) VShoriz	: kw = HORIZONTAL	; t = VStxDir ; break ;
	case (int) VSpara	: kw = PARALLEL		; t = VStxDir ; break ;
	case (int) VSortho	: kw = ORTHOGONAL	; t = VStxDir ; break ;
	case (int) VSnotReversed: kw = NOTREVERSED	; t = VStxRev ; break ;
	case (int) VSupsideDown	: kw = UPSIDEDOWN	; t = VStxRev ; break ;
	case (int) VSrightToLeft: kw = RIGHTTOLEFT	; t = VStxRev ; break ;
	default			: rc = FALSE      		      ; break ;
	}

	*kwtype = kw ;
	*type	= t ;

	return rc ;

} /* VSgetTxPosType */
/*----------------------------------------------------------------------------*/
int VScheckJustification( just ) int just ; {

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

} /* VScheckJustification */
/*----------------------------------------------------------------------------*/
int VSdrwJustToTokNum( j ) int j ; {

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

} /* VSdrwJustToTokNum */
/*----------------------------------------------------------------------------*/
void VSdrwTxInit( t ) register VSdrwText *t ; {
	t->buffer = NULL ;
	t->bufsiz = t->curpos = 0 ;
} /* VSdrwTxInit */
/*----------------------------------------------------------------------------*/
void VSdrwTxFree( t ) register VSdrwText *t ; {

	/*
	 * Frees string buffer in text structure.
	 */
	if( t->buffer && t->bufsiz ) free( t->buffer ) ;
	VSdrwTxInit( t ) ;

} /* VSdrwTxFree */
/*----------------------------------------------------------------------------*/
static char *VSallocDrwText( t, n ) register VSdrwText *t ; unsigned n ; {

	/*
	 * (Re)allocates string buffer in text structure.
	 */
	register char	*newptr ;

#define CHUNK	128

	if( t->bufsiz ) {
		n += t->bufsiz + CHUNK ;
		if( newptr = realloc( t->buffer, n * sizeof( char ) ) ) {
			t->buffer = newptr ;
			t->bufsiz = n ;
		}	
	} else {
		if( newptr = malloc( n * sizeof( char ) ) ) {
			t->buffer = newptr ;
			t->bufsiz = n ;
			t->curpos = 0 ;
		}
	}

	return newptr ;

} /* VSallocDrwText */
/*----------------------------------------------------------------------------*/
void VSdrwTxMOVE( t, mvflag, mvval )

VSdrwText		*t ;
char			mvflag ;		/* mvflag = 'h','v','s'	*/
double			mvval ; {

	/*
	 * Puts text commands 'h','v','s' into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 1 + 1 + sizeof( mvval ) ;

	VSdrwTxInit( t ) ;

	if( !VSallocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ;
	*p++ = mvflag ;
	memcpy( p, (char *) &mvval, sizeof( mvval ) ) ;

	t->curpos += nbytes ;

} /* VSdrwTxMOVE */
/*----------------------------------------------------------------------------*/
void VSdrwTxFSTART( t, fieldno )

register VSdrwText	*t ;
int			fieldno ; {

	/*
	 * Puts "start field" command into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 4 ;

	VSdrwTxInit( t ) ;

	if( !VSallocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ; *p++ = 'F' ; *p++ = fieldno ; *p++ = 0 ;

	t->curpos += nbytes ;

} /* VSdrwTxFSTART */
/*----------------------------------------------------------------------------*/
void VSdrwTxFEND( t ) register VSdrwText *t ; {

	/*
	 * Puts "end field" command into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 2 ;

	VSdrwTxInit( t ) ;

	if( !VSallocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ; *p++ = 'E' ;

	t->curpos += nbytes ;

} /* VSdrwTxFEND */
/*----------------------------------------------------------------------------*/
void VSdrwTxMVTOFLD( t, text, fieldno, justification, txSymb, display )

VSdrwText		*t,
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

	VSdrwTxInit( t ) ;

	if( !VSallocDrwText( t, nbytes ) ) return ;

	if( text && text->curpos ) {
		VSgetFontInfo( &msg, txSymb->Active_font, &fontInfo ) ;
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

} /* VSdrwTxMVTOFLD */
/*----------------------------------------------------------------------------*/
void VSdrwTxCHGFONT( t, fontno ) VSdrwText *t ; short fontno ; {

	/*
	 * Puts text commands 'f' (change font) into string buffer.
	 */
	register char		*p ;
	register unsigned	nbytes = 1 + 1 + sizeof( fontno ) ;

	VSdrwTxInit( t ) ;

	if( !VSallocDrwText( t, nbytes ) ) return ;

	p = t->buffer + t->curpos ;

	*p++ = ESC ;
	*p++ = 'f' ;
	memcpy( p, (char *) &fontno, sizeof( fontno ) ) ;

	t->curpos += nbytes ;

} /* VSdrwTxCHGFONT */
/*----------------------------------------------------------------------------*/
void VSdrwTxINITSTRING( t, string )

register VSdrwText	*t ;
const char		*string ; {

	/*
	 * Initializes string buffer with a null-terminated string.
	 */
	register unsigned	nbytes = strlen( string ) ;

	VSdrwTxInit( t ) ;

	__DBGpr_int( "Length of string", nbytes ) ;

	if( VSallocDrwText( t, nbytes ) ) {
		__DBGpr_str( "Init text with", string ) ;
		memcpy( t->buffer + t->curpos, string, nbytes ) ;
		t->curpos += nbytes ;
	}

} /* VSdrwTxINITSTRING */
/*----------------------------------------------------------------------------*/
void VSdrwTxMERGE( toMerge1, toMerge2, merged )

const VSdrwText	*toMerge1 ;
const VSdrwText	*toMerge2 ;
VSdrwText	*merged ; {

	unsigned	nbytes = toMerge1->curpos + toMerge2->curpos ;

	*merged = *toMerge1 ;

	if( VSallocDrwText( merged, nbytes ) ) {
		memcpy( merged->buffer + merged->curpos,
			toMerge2->buffer,
			toMerge2->curpos * sizeof( char ) ) ;
		merged->curpos += toMerge2->curpos ;
	}
	VSdrwTxInit( toMerge1 ) ; VSdrwTxFree( toMerge2 ) ;

} /* VSdrwTxMERGE */
/*----------------------------------------------------------------------------*/
#ifdef vsDEBUG
VSdumpTxtSymb( s ) struct GRdpb_text_symb *s ; {

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
VSdumpTextString( s, size ) char *s ; int size ; {
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

} /* VSdumpTextString */
/*----------------------------------------------------------------------------*/
#endif
