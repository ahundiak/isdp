/*
	I/STRUCT
*/
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatadef.h"
#include "vsdata.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Include for function prototypes.
 */
#include "vsshdatproto.h"

/*
 * ADZ: The UINTMAX results in compilation conflicts on INTEL_SOLARIS.
 *      The fact the value is used as checkvalue we replace it by a local
 *	constant, equal to the CLIX UINT_MAX.
 */
#define	VS_UINT_MAX	4294967295

/*----------------------------------------------------------------------------*/
void VSdumpSharedData( count, list ) int count ; VSdataDesc list[] ; {

	int		i ;
	VSdataDesc 	*l ;

	for( i = 0, l = list ; i < count ; i++, l++ ) {

		printf( "Item %2d: index %2d ", i, l->index ) ;

		switch( l->type ) {
		case VSdouble	: printf( "double <%g>\n", l->value.d ) ; break;
		case VSint	: printf( "int    <%d>\n", l->value.i ) ; break;
		case VSstring	: printf( "string <%s>\n", l->value.s ) ; break;
		case -1		: printf( "not set\n" ) ; break ;
		default		: printf( "unknown\n" ) ; break ;
		}
	}

} /* VSdumpSharedData */
/*----------------------------------------------------------------------------*/
static unsigned VSitemSize( type, ptr ) VSdataType type ; char *ptr ; {

	unsigned size ;

	switch( type ) {
		case VSdouble	: size = sizeof( double )	; break ;
		case VSint	: size = sizeof( int    )	; break ;
		case VSstring	: size = 1 + strlen( ptr )	; break ;
		default		: size = 0 ;
	}
	return size ;

} /* VSitemSize */
/*----------------------------------------------------------------------------*/
static unsigned VSitemAlign( type, oldaddr )

VSdataType	type ;
unsigned	oldaddr ; {

	unsigned newaddr ;

#define ALIGN( x, t ) \
	( (x) % sizeof( t ) ? ( (x) / sizeof( t ) + 1 ) * sizeof( t ) : (x) )

	switch( type ) {
		case VSdouble	: newaddr = ALIGN( oldaddr, double ) ; break ;
		case VSint	: newaddr = ALIGN( oldaddr, int    ) ; break ;
		case VSstring	: newaddr = oldaddr		     ; break ;
		default		: newaddr = VS_UINT_MAX              ; break ;
	}
	return newaddr ;

#undef ALIGN

} /* VSitemAlign */
/*----------------------------------------------------------------------------*/
long VSpackData( msg, count, data, packed, p_loc, size )

long		*msg ;
int		count ;
VSdataDesc	data[] ;
char		**packed ;
VSdataLoc	**p_loc ;
unsigned	*size ; {

	long			sts ;
	register VSdataDesc	*d,
				*stop ;
	register VSdataLoc	*loc ;

	*packed = NULL ; loc = NULL ; *size = 0 ;

	if( !count ) vs$inv_arg() ;

	stop = data + count ;

	if( !( loc = _MALLOC( count, VSdataLoc ) ) ) vs$mem_fail() ;

	for( d = data ; d < stop ; d++ ) {
		if( d->index == VS_K_NULL_INDEX ) continue ;
		if( ( *size = VSitemAlign( d->type, *size ) )
						== (unsigned) VS_UINT_MAX ) {
			/*
			 * Bad size ...
			 */
			vs$inv_arg() ;
		}


		loc[d->index].type = d->type ;
		loc[d->index].addr = *size ;
		*size += VSitemSize( d->type, d->value.s ) ;

	}
	/*
	 * At the end of the loop `*size' contains the size of the
	 * memory to handle the data.
	 */
	if( *size ) {
		VSdataPtr v ;

		if( !( *packed = _MALLOC( *size, char ) ) ) vs$mem_fail() ;
		memset( *packed, 0, (int) *size ) ;

		for( d = data ; d < stop ; d++ ) {
			if( d->index == VS_K_NULL_INDEX ) continue ;

			v.s = *packed + loc[d->index].addr ;
			switch( d->type ) {
				case VSdouble	: *v.d = d->value.d ; break ;
				case VSint	: *v.i = d->value.i ; break ;
				case VSstring	: strcpy( v.s, d->value.s ) ;
			}
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( loc ) ;
		}
		if( p_loc ) 	*p_loc = loc ;
		else		_FREE( loc ) ;

		return sts ;

} /* VSpackData */
/*----------------------------------------------------------------------------*/
void VSfreeData( count, data )

int		count ;
VSdataDesc	data[] ; {

	int i ;

	for( i = 0 ; i < count ; i++ ) {
		if( data[i].type == VSstring ) {
			_FREE( data[i].value.s ) ;
			data[i].value.s = NULL ;
		}
	}

} /* VSfreeData */
/*----------------------------------------------------------------------------*/

