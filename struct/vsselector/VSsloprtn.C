/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include "msdef.h"
#include "vsslc.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vslngopproto.h"
/*----------------------------------------------------------------------------*/
int VSrelOP( msg, opType, operand1, operand2, res ) 

long		*msg ;
int		opType ;
const VSexecRes	*operand1 ;
const VSexecRes	*operand2 ;
VSexecRes	*res ; {

	int		rel	= FALSE ;
	int		i1,
			i2 ;
	char		*s1,
			*s2 ;
	double		d1,
			d2 ;
	VSexecRes	O1,
			O2 ;

	switch( operand1->type ) {
	  case VS_object :
		VSgetObjVal( msg, &operand1->_oval, &O1 ) ;
		if( !(*msg & 1) ) goto wrapup ;
		operand1 = &O1 ;
		break ;
	  case VS_array	:
	        /* Array: use first element */
	        return VSrelOP( msg, opType, VSgetAryElm( operand1, 0 ),
	        		operand2, res ) ;
	}

	switch( operand2->type ) {
	  case VS_object :
		VSgetObjVal( msg, &operand2->_oval, &O2 ) ;
		if( !(*msg & 1) ) goto wrapup ;
		operand2 = &O2 ;
		break ;
	  case VS_array	:
	        /* Array: use first element */
	        return VSrelOP( msg, opType, operand1,
	          		  VSgetAryElm( operand2, 0 ), res ) ;
	}

	i1	= operand1->_ival ;
	i2	= operand2->_ival ;
	d1	= operand1->_dval ;
	d2	= operand2->_dval ;
	s1	= operand1->_sval ;
	s2	= operand2->_sval ;

	switch( operand1->type ) {
	  case VS_int	:

	    switch( operand2->type ) {
	      case VS_int :

	        switch( opType ) {
		  case VS_le : rel = i1 <= i2 ; break ;
		  case VS_lt : rel = i1 <  i2 ; break ;
		  case VS_ge : rel = i1 >= i2 ; break ;
		  case VS_gt : rel = i1 >  i2 ; break ;
		  case VS_eq : rel = i1 == i2 ; break ;
		  case VS_ne : rel = i1 != i2 ; break ;
		  case VS_and: rel = i1 && i2 ; break ;
		  case VS_or : rel = i1 || i2 ; break ;
		  default    : *msg = MSINARG ; goto wrapup ;
	        }
	        break ;
	      case VS_double :

	        switch( opType ) {
		  case VS_le : rel = i1 <= d2 ; break ;
		  case VS_lt : rel = i1 <  d2 ; break ;
		  case VS_ge : rel = i1 >= d2 ; break ;
		  case VS_gt : rel = i1 >  d2 ; break ;
		  case VS_eq : rel = i1 == d2 ; break ;
		  case VS_ne : rel = i1 != d2 ; break ;
		  case VS_and: rel = i1 && d2 ; break ;
		  case VS_or : rel = i1 || d2 ; break ;
		  default    : *msg = MSINARG ; goto wrapup ;
	        }
	        break ;
	      default	:

	        *msg = MSINARG ; goto wrapup ;
	     }
	     break ;

	   case VS_double :

	     switch( operand2->type ) {
	       case VS_int :

	         switch( opType ) {
		   case VS_le : rel = d1 <= i2 ; break ;
		   case VS_lt : rel = d1 <  i2 ; break ;
		   case VS_ge : rel = d1 >= i2 ; break ;
		   case VS_gt : rel = d1 >  i2 ; break ;
		   case VS_eq : rel = d1 == i2 ; break ;
		   case VS_ne : rel = d1 != i2 ; break ;
		   case VS_and: rel = d1 && i2 ; break ;
		   case VS_or : rel = d1 || i2 ; break ;
		   default    : *msg = MSINARG ; goto wrapup ;
		 }
		 break ;
	       case VS_double :

	         switch( opType ) {
		   case VS_le : rel = d1 <= d2 ; break ;
		   case VS_lt : rel = d1 <  d2 ; break ;
		   case VS_ge : rel = d1 >= d2 ; break ;
		   case VS_gt : rel = d1 >  d2 ; break ;
		   case VS_eq : rel = d1 == d2 ; break ;
		   case VS_ne : rel = d1 != d2 ; break ;
		   case VS_and: rel = d1 && d2 ; break ;
		   case VS_or : rel = d1 || d2 ; break ;
		   default    : *msg = MSINARG ; goto wrapup ;
		 }
		 break ;
		 default	:

		   *msg = MSINARG ; goto wrapup ;
		 }
		 break ;
	   case VS_string :

	     switch( operand2->type ) {
	       default		:
	       case VS_int	:
	       case VS_double	:

		 *msg = MSINARG ; goto wrapup ;

	       case VS_string	:

	         switch( opType ) {
		   case VS_le : rel = strcmp( s1, s2 ) <= 0 ; break ;
		   case VS_lt : rel = strcmp( s1, s2 ) <  0 ; break ;
		   case VS_ge : rel = strcmp( s1, s2 ) >= 0 ; break ;
		   case VS_gt : rel = strcmp( s1, s2 ) >  0 ; break ;
		   case VS_eq : rel = strcmp( s1, s2 ) == 0 ; break ;
		   case VS_ne : rel = strcmp( s1, s2 ) != 0 ; break ;
		   default    : *msg = MSINARG ; goto wrapup ;
		 }
		 break ;
	       }
	       break ;

	   default	: *msg = MSINARG ; goto wrapup ;

	}
	*msg = MSSUCC ;

	wrapup :
		res->type	= VS_int ;
		res->_ival	= rel ;

		return *msg & 1 ;

} /* VSrelOP */
/*----------------------------------------------------------------------------*/
int VSunrOP( msg, opType, operand, res ) 

long		*msg ;
int		opType ;
const VSexecRes	*operand ;
VSexecRes	*res ; {

	int		neg ;
	VSexecRes	O ;

	switch( operand->type ) {
	  case VS_object :
		VSgetObjVal( msg, &operand->_oval, &O ) ;
		if( !(*msg & 1) ) {
			res->type  = VS_int ; res->_ival = 0 ;
			goto wrapup ;
		}
		operand = &O ;
	  case VS_array :
		return VSunrOP( msg, opType, VSgetAryElm( operand, 0 ), res ) ;
	}

	*msg = MSSUCC ;
	switch( opType ) {

	  case VS_not	:
		switch( operand->type ) {
			case VS_int	: neg = ! operand->_ival     ; break ;
			case VS_double	: neg = ! operand->_dval     ; break ;
			case VS_string	: neg = *operand->_sval != 0 ; break ;
			default		: neg = FALSE ;*msg = MSINARG; break ;
		}
		res->type = VS_int ; res->_ival	= neg ;
		break ;

	  case VS_minus	:
		switch( operand->type ) {
			case VS_int	:
				res->type  = VS_int ;
				res->_ival = - operand->_ival   ; break ;
			case VS_double	:
				res->type  = VS_double ;
				res->_dval = - operand->_dval   ; break ;
			case VS_string	:
				VScvrtVal( msg, VS_double, operand, res ) ;
				res->_dval = - operand->_dval   ; break ;
			default		:
				res->type  = VS_double ;
				res->_dval = 0 ;
				*msg = MSINARG			; break ;
		}
		
		break ;

	  default	: *msg = MSINARG ; goto wrapup ;
	}

	wrapup :

		return *msg & 1 ;

} /* VSunrOP */
/*----------------------------------------------------------------------------*/
const VSexecRes *VSgetAryElm(	const VSexecRes *ary,
				int		index ) {

	static VSexecRes intZero ;

	/*
	 * Return a pointer to the element at the given index and a pointer to
	 * int zero if the index is invalid.
	 */
	if( VS_array == ary->type ) {
	  if( 0 <= index && index < ary->_aval.size ) {
	    return ary->_aval.element + index ;
	  } else {
	    intZero.type = VS_int ; intZero._ival = 0 ;
	    return &intZero ;
	  }
	} else {
	  /* Not a VS_array: return input as array element...*/
	  return ary ;
	}

} /* VSgetAryElm */
/*----------------------------------------------------------------------------*/
int VScvrtVal( msg, typeWanted, in, out )

long		*msg ;
int		typeWanted ;
const VSexecRes	*in ;
VSexecRes	*out ; {

	int		vtype = in->type ;
	VSexecRes	r ;
	double		d = 0. ;
	char		*s = out->_sval ;

	/*
	 * Perform type conversion between `in' and `out'.
	 * NOTE: we convert array to int/double/string by taking the first
	 * element of the array. We do not convert array to int/double/string.
	 */
	out->type = typeWanted ;

	switch( typeWanted ) {

	  case VS_int	:
	  case VS_double:
	    switch( vtype ) {
	      default		: *msg = MSINARG	; break ;
	      case VS_int	: d = in->_ival		; break ;
	      case VS_double	: d = in->_dval		; break ;
	      case VS_string	: d = atof( in->_sval )	; break ;
	      case VS_object	:
	        VSgetObjVal( msg, &in->_oval, &r ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		switch( r.type ) {
		  case VS_double: d = r._dval		; break ;
		  case VS_string: d = atof( r._sval )	; break ;
		  default	: *msg = MSINARG	; break ;
		}
		break ;
	      case VS_array	:
	      	return VScvrtVal( msg, VS_double, VSgetAryElm( in, 0 ), out ) ;
	    }
	    if( typeWanted == VS_int )	out->_ival = (int) d ;
	    else			out->_dval = d ;
	    break ;

	  case VS_string:
	    switch( vtype ) {
	      case VS_int	: sprintf( s, "%d", in->_ival)	; break ;
	      case VS_double	: sprintf( s, "%g", in->_dval)	; break ;
	      case VS_string	: strcpy( s, in->_sval )	; break ;
	      case VS_object	:
	        VSgetObjVal( msg, &in->_oval, &r ) ;
	        if( !( *msg & 1 ) ) goto wrapup ;
		switch( r.type ) {
		  case VS_double: sprintf( s, "%g", r._dval )	; break ;
		  case VS_string: strcpy( s, r._sval )		; break ;
		  default	: *msg = MSINARG		; break ;
		}
		break ;
	      case VS_array	:
	      	return VScvrtVal( msg, VS_string, VSgetAryElm( in, 0 ), out ) ;

	        default		: *msg = MSINARG		; break ;
	    }
	    break ;

	  case VS_array		:
	    if( VS_array == vtype ) {
	      *out = *in ; break ;
	    } else {
	      *msg = MSINARG ;
	    }
	    break ;

	    default		: *msg = MSINARG ; break ;
	}

	wrapup :
		return *msg & 1 ;

} /* VScvrtVal */
/*----------------------------------------------------------------------------*/
int VSbinOP( msg, opType, operand1, operand2, res ) 

long		*msg ;
int		opType ;
const VSexecRes	*operand1 ;
const VSexecRes	*operand2 ;
VSexecRes	*res ; {

	VSexecRes	O1,
			O2 ;
	double		d = 0. ;

	VScvrtVal( msg, VS_double, operand1, &O1 ) ;
	if( !( *msg & 1 ) ) goto wrapup ;
	VScvrtVal( msg, VS_double, operand2, &O2 ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	switch( opType ) {
		case VS_plus	: d = O1._dval + O2._dval ; break ;
		case VS_minus	: d = O1._dval - O2._dval ; break ;
		case VS_mult	: d = O1._dval * O2._dval ; break ;
		case VS_div	: if( O2._dval ) {
					d = O1._dval / O2._dval ;
				  } else {
				  	d = DBL_MAX ;
				  	if( O1._dval < 0 ) d = -d ;
				  }
				  break ;
		case VS_pow	: if( O1._dval == 0. ) {
					if( O2._dval > 0 ) {
						d = 0. ;
					} else {
						d = DBL_MAX ;
					}
				  } else if( O1._dval < 0. ) {
				  	if( (int) O2._dval == O2._dval ) {
				  		d = pow( O1._dval, O2._dval ) ;
				  	} else {
				  		d = DBL_MAX ;
				  	}
				  } else /* O1._dval > 0 */ {
				  	d = pow( O1._dval, O2._dval ) ;
				  }
				  break ;
	}
	wrapup :
		res->type	= VS_double ;
		res->_dval	= d ;

		return *msg & 1 ;

} /* VSbinOP */
/*----------------------------------------------------------------------------*/

