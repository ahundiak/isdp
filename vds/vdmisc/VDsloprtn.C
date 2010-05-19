/* $Id: VDsloprtn.C,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmisc / VDsloprtn.C
 *
 * Description:
 *	Functions to implement numeric operations in parser 
 *	Used by 
 *		Visual interprter (vddraw/drw) 
 *		attribute expression interpreter (vdtbl/parser)
 *
 *	   verbose
 *		0		silent
 *		> 0  		print operations and warnings
 *		< 0 		print only warnings 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsloprtn.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  1999/07/08  21:36:10  pinnacle
 * (No comment)
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
 * Revision 1.8  1995/11/30  23:03:34  pinnacle
 * Replaced: vdmisc/VDsloprtn.C for:  by tlbriggs for vds.240
 *
 * Revision 1.7  1995/11/22  23:49:34  pinnacle
 * Replaced: ./vdmisc/VDsloprtn.C for:  by azuurhou for vds.240
 *
 * Revision 1.6  1995/08/30  20:02:56  pinnacle
 * Replaced: vdmisc/VDsloprtn.C for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1995/08/21  18:57:56  pinnacle
 * Replaced: vdmisc/VDsloprtn.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/07/28  19:44:30  pinnacle
 * Replaced: vdmisc/VDsloprtn.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/07/27  23:18:22  pinnacle
 * Replaced: vdmisc/VDsloprtn.C for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	07/21/95   tlb	   Add default msg status to functions
 *
 *	07/23/95   tlb	   Add support for VD_null, VD_bool
 *			   AND, OR now defined on strings
 *			   NOT on strings - value converted first
 *			   Add verbose flags to all routines
 *			   Added check for incomplete conversion of string 
 *				to numeric
 *	07/28/95   tlb	   Change verbose/warning constants
 *	08/19/95   tlb	   VD_relOP: string operations were broken
 *	08/29/95   tlb     Add VD_getValPtr, null case for relOP
 *	11/30/95   tlb     Fix null case of '!=' operator
 *	07/06/99   Ming    TR179802268
 *
 *************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include "msdef.h"
#include "v_slc.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_lngopproto.h"


/*************************************************************************
 *  Local value conversion functions
 *	For use in this file only
 *	Do not report conversions!!!
 *
 ***********************************************************************/
static void
VD_cvrtString (	int		verbose,
	  	char 		*str, 
	 	double 		*d )
{
	char		*s;

	*d = strtod( str, &s); 
	if (verbose ) {
	    	if (s == str)
  			VD_drwParserWarn (verbose, 
			"Cannot convert string: '%s'\n", str);
		else if (*s != '\0')
  			VD_drwParserWarn (verbose, 
			"Incomplete string conversion : '%s'\n", str);
		}
}
/*----------------------------------------------------------------------------*/
static long
VD_getNumericValue (	int	    	   verbose,	/* verbose flag */
			const VD_execRes  *in, 		/* input value */
			double            *d		/* numeric valus */
			)
{
	VD_execRes	r ;
	long		msg = MSSUCC;

	*d = 0;
	switch( in->type ) {
		case VD_bool	: 	*d = in->_ival		; break ;
		case VD_int	: 	*d = in->_ival		; break ;
	      	case VD_double	: 	*d = in->_dval		; break ;
	      	case VD_string	: 	
			VD_cvrtString (verbose, (char *)in->_sval, d); 
			break;
	      	case VD_object	:
	        	VD_getObjVal( &msg, &in->_oval, &r ) ;
			if( !( msg & 1 ) ) goto wrapup ;
			switch( r.type ) {
		  		case VD_double:	
					*d = r._dval; 
					break ;
		  		case VD_string: 
					VD_cvrtString (verbose, r._sval, d); 
					break ;
		  		default	: 	
					msg = MSINARG	; break;
				}
			break ;

	      	case VD_array:
	      		if (!VD_cvrtVal(&msg, verbose, VD_double, 
						     VD_getAryElm( in, 0 ), &r))
				goto wrapup ;
			*d = r._dval; 
			break;

	      	default	: 		
			msg = MSINARG	; break ;
	      	}
wrapup:
	return msg;
}

/*----------------------------------------------------------------------------*/
static long
VD_getStringValue ( 	int			verbose,
			const VD_execRes  	*in, 	/* input value */
			char 			*s	/* string value */
			)
{
	VD_execRes	r ;
	long		msg = MSSUCC;

	*s = '\0';
	switch( in->type ) {
	      	case VD_bool	: 	sprintf( s, "%d", in->_ival)   ; break;
	      	case VD_int	: 	sprintf( s, "%d", in->_ival)   ; break;
	      	case VD_double	: 	sprintf( s, "%g", in->_dval)   ; break;
	      	case VD_string	: 	strcpy ( s, in->_sval)	       ; break;
	      	case VD_object	:
	        		VD_getObjVal( &msg, &in->_oval, &r ) ;
	        		if( !( msg & 1 ) ) goto wrapup ;
				switch( r.type ) {
		  			case VD_double: 
						sprintf(s,"%g",r._dval);break;
		  			case VD_string: 
						strcpy( s, r._sval ); 	break ;
		  			default	: 
						msg = MSINARG; 		break ;
					}
				break ;

	      	case VD_array 	:
	      			if (!VD_cvrtVal( &msg, verbose, VD_string, 
						     VD_getAryElm( in, 0 ), &r))
						goto wrapup ;
				strcpy (s, r._sval); 
				break;

	        default		: 	msg = MSINARG; break ;
		}
wrapup:
	return msg;
}
/*************************************************************************
 *  External functions
 *	Report conversions!!!
 *
/*----------------------------------------------------------------------------*/
int VD_relOP( long			*msg ,
		int			verbose,
		int			opType ,
		const VD_execRes	*operand1 ,
		const VD_execRes	*operand2 ,
		VD_execRes		*res )
{

	int		rel	= FALSE ;
	char		*s1,
			*s2 ;
	VD_execRes	O1, O2;

	/* Defaults*/
	*msg 		= MSSUCC ;
	res->type	= VD_int ;
	res->_ival	= rel ;

	switch( operand1->type ) {
	  	case VD_object :
			VD_getObjVal( msg, &operand1->_oval, &O1 ) ;
			if( !(*msg & 1) ) goto wrapup ;
			operand1 = &O1 ;
			break ;
	  	case VD_array	:
	        	/* Array: use first element */
	        	return VD_relOP( msg, verbose, opType, 
						VD_getAryElm(operand1, 0), 
								operand2, res);
	   	}


	/* Null operations */
	if (operand1->type == VD_null || operand2->type == VD_null) {
		switch( opType ) {
		   case VD_eq : 
		   case VD_le : 
		   case VD_ge : rel = operand1->type == VD_null && 
						operand2->type == VD_null;
			    	break;

		   case VD_ne : rel = operand1->type != VD_null || 
						operand2->type != VD_null;
			    	break;

		   case VD_lt : 
		   case VD_gt : 
		   case VD_and: 
		   case VD_or : 
				res->type = VD_null;
				goto wrapup;

		   default    : *msg = MSINARG ; goto wrapup ;
		   }
		}
	/* String operation */
	else if (operand1->type == VD_string && operand2->type == VD_string) {
		s1	= (char *)operand1->_sval ;
		s2	= (char *)operand2->_sval ;
		switch( opType ) {
		   case VD_le : rel = strcmp( s1, s2 ) <= 0 ; break ;
		   case VD_lt : rel = strcmp( s1, s2 ) <  0 ; break ;
		   case VD_ge : rel = strcmp( s1, s2 ) >= 0 ; break ;
		   case VD_gt : rel = strcmp( s1, s2 ) >  0 ; break ;
		   case VD_eq : 
			    /* Modified by Ming for TR179802268 */
 			    if( strchr(s1, '*') )
			      rel = ASmatchRE( s1, s2 );
			    else if( strchr(s2, '*') )
			      rel = ASmatchRE( s2, s1 );
			    else
			      rel = strcmp( s1, s2 ) == 0;
			    break;
		   case VD_ne : rel = strcmp( s1, s2 ) != 0 ; break ;
		   case VD_and: 
			    VD_cvrtVal(msg, verbose, VD_double, operand1, &O1);
			    VD_cvrtVal(msg, verbose, VD_double, operand2, &O2);
			    rel = O1._dval && O2._dval ; 
			    break ;
		   case VD_or : 
			    VD_cvrtVal(msg, verbose, VD_double, operand1, &O1);
			    VD_cvrtVal(msg, verbose, VD_double, operand2, &O2);
			    rel = O1._dval || O2._dval ; 
			    break ;
		   default    : *msg = MSINARG ; goto wrapup ;
		   }
		}
	/* Numeric comparison */
	else {
		/* Force all numeric to double */
		if (!VD_cvrtVal( msg, verbose, VD_double, operand1, &O1)) 
			goto wrapup;
		if (!VD_cvrtVal( msg, verbose, VD_double, operand2, &O2)) 
			goto wrapup;

	        switch( opType ) {
		  case VD_le : rel = O1._dval <= O2._dval ; break ;
		  case VD_lt : rel = O1._dval <  O2._dval ; break ;
		  case VD_ge : rel = O1._dval >= O2._dval ; break ;
		  case VD_gt : rel = O1._dval >  O2._dval ; break ;
		  case VD_eq : rel = O1._dval == O2._dval ; break ;
		  case VD_ne : rel = O1._dval != O2._dval ; break ;
		  case VD_and: rel = O1._dval && O2._dval ; break ;
		  case VD_or : rel = O1._dval || O2._dval ; break ;
		  default    : *msg = MSINARG ; goto wrapup ;
	          }
		}
	res->_ival	= rel ;

wrapup :
	if (verbose > 0  )
		VD_drwVerbOp (opType, operand1, operand2, res);
		
	return *msg & 1 ;

} /* VD_relOP */
/*----------------------------------------------------------------------------*/
int VD_unrOP( 	long			*msg ,
		int			verbose,
		int			opType ,
		const VD_execRes	*operand ,
		VD_execRes		*res ) 
{
	int		neg ;
	VD_execRes	O ;

	*msg = MSSUCC ;

	/* Result is null if operand is null */
	if (operand->type == VD_null ){
		res->type = VD_null;
		goto wrapup;
		}

	switch( operand->type ) {
	  case VD_object :
		VD_getObjVal( msg, &operand->_oval, &O ) ;
		if( !(*msg & 1) ) {
			res->type  = VD_int ; res->_ival = 0 ;
			goto wrapup ;
		}
		operand = &O ;
	  case VD_array :
		return VD_unrOP( msg, verbose, opType, 
					VD_getAryElm( operand, 0 ), res ) ;
	}

	switch( opType ) {

	  case VD_not	:
		switch( operand->type ) {
			case VD_bool	: 
				neg = ! operand->_ival     	; break ;
			case VD_int	: 
				neg = ! operand->_ival     	; break ;
			case VD_double	: 
				neg = ! operand->_dval     	; break ;
			case VD_string	: 
			 	VD_cvrtVal(msg, verbose, VD_double, 
								operand, res);
				neg = ! res->_dval 		; break ;
			default		: 
				neg = FALSE ; *msg = MSINARG	; break ;
			}
		res->type  = VD_int ; 
		res->_ival = neg ;
		break ;

	  case VD_minus	:
		switch( operand->type ) {
			case VD_bool	:
				res->type  = VD_bool ;
				res->_ival = - operand->_ival   ; break ;
			case VD_int	:
				res->type  = VD_int ;
				res->_ival = - operand->_ival   ; break ;
			case VD_double	:
				res->type  = VD_double ;
				res->_dval = - operand->_dval   ; break ;
			case VD_string	:
				VD_cvrtVal( msg, verbose, VD_double, 
								operand, res ) ;
				res->_dval = - operand->_dval   ; break ;
			default		:
				res->type  = VD_double ;
				res->_dval = 0 ;
				*msg = MSINARG			; break ;
			}
		break ;

	  default	: *msg = MSINARG ; goto wrapup ;
	}

wrapup :
	if (verbose > 0 )
		VD_drwVerbOp (opType, operand, NULL, res);
		
	return *msg & 1 ;

} /* VD_unrOP */
/*----------------------------------------------------------------------------*/
const VD_execRes 
*VD_getAryElm(	const VD_execRes *ary,
		int		index ) 
{
	static VD_execRes intZero ;

	/*
	 * Return a pointer to the element at the given index and a pointer to
	 * int zero if the index is invalid.
	 */
	if( VD_array == ary->type ) {
	  	if( 0 <= index && index < ary->_aval.size ) 
	    		return ary->_aval.element + index ;
	  	else {
	    		intZero.type = VD_int ; intZero._ival = 0 ;
	    		return &intZero ;
	  		}
		} 
	else {
	  /* Not a VD_array: return input as array element...*/
	  return ary ;
	}

} /* VD_getAryElm */
/*---------------------------------------------------------------------------*/
int 
VD_getValPtr ( 	const VD_execRes	*arg ,
		void 			**ptr,
		int			*size)
{
	int	flag = TRUE;

	switch( arg->type ) {
		case VD_bool	: 
			*ptr =  (void *) &(arg->_ival); 
			*size = sizeof(int); 
			break;
		case VD_int	: 
			*ptr =  (void *) &(arg->_ival);
			*size = sizeof(int); 
			break;
		case VD_double	: 
			*ptr =  (void *) &(arg->_dval);
			*size = sizeof(double); 
			break;
		case VD_string	: 
			*ptr =  (void *) &(arg->_sval); 
			*size = sizeof(VD_tktxt); 
			break;

		case VD_null	: 
		default		: 
			*ptr = NULL; 
			*size = 0;
			flag = FALSE;
			break;
		}
	return flag;
}
/*---------------------------------------------------------------------------*/
int VD_cvrtVal( long			*msg ,
		int			verbose,
		int			typeWanted ,
		const VD_execRes	*in ,
		VD_execRes		*out )
{

	double		d = 0. ;

	*msg = MSSUCC;

	/* null values cannot be converted */
	if (in->type == VD_null) {
		out->type = VD_null;
		*msg = MSFAIL;
		goto wrapup;
		}

	/*
	 * Perform type conversion between `in' and `out'.
	 * NOTE: we convert array to int/double/string by taking the first
	 * element of the array. We do not convert array to int/double/string.
	 */
	out->type = typeWanted ;

	switch( typeWanted ) {

	  	case VD_bool:
				*msg = VD_getNumericValue (verbose, in, &d);
	    			out->_ival = ((int) d) != FALSE  ;
				break;
	  	case VD_int:
				*msg = VD_getNumericValue (verbose, in, &d);
	    			out->_ival = (int) d ;
				break;
	  	case VD_double:
				*msg = VD_getNumericValue (verbose, in, 
	    							&(out->_dval));
				break;

	  	case VD_string:
				*msg = VD_getStringValue (verbose, in, 
							&(out->_sval[0]));
				break;

	  	case VD_array:
	    			if( in->type == VD_array ) 
	      				*out = *in ;
	    			else 
	      				*msg = MSINARG ;
	    			break ;

	  	case VD_null: 	
				*msg = MSINARG ; break ;

	  	default	: 	
				*msg = MSINARG ; break ;
		}

wrapup :
	/* if verbose - print conversion info  */
	if( (*msg & 1) && verbose > 0  && in->type != out->type ) 
		VD_drwVerbConv (in, out);
		
	return *msg & 1 ;

} /* VD_cvrtVal */
/*----------------------------------------------------------------------------*/
/* Perform binary operation */
int VD_binOP( 	long			*msg ,
		int			verbose,
		int			opType ,
		const VD_execRes	*operand1 ,
		const VD_execRes	*operand2 ,
		VD_execRes		*res )
{
	VD_execRes	O1,
			O2 ;
	double		d = 0. ;

	/* Defaults */
	*msg 		= MSSUCC;
	res->type	= VD_double ;
	res->_dval	= d ;


	/* Result is null if either operand is null */
	if (operand1->type == VD_null || operand2->type == VD_null){
		res->type = VD_null;
		goto wrapup;
		}
		
	/* Convert to double */
	if (!VD_cvrtVal( msg, verbose, VD_double, operand1, &O1)) goto wrapup;
	if (!VD_cvrtVal( msg, verbose, VD_double, operand2, &O2)) goto wrapup;

	switch( opType ) {
		case VD_plus	: d = O1._dval + O2._dval ; break ;
		case VD_minus	: d = O1._dval - O2._dval ; break ;
		case VD_mult	: d = O1._dval * O2._dval ; break ;
		case VD_div	: if( O2._dval ) {
					d = O1._dval / O2._dval ;
				  } else {
				  	d = DBL_MAX ;
				  	if( O1._dval < 0 ) d = -d ;
					if (verbose )
  					    VD_drwParserWarn (verbose,
						   "Division by zero\n");
				  }
				  break ;
		case VD_pow	: if( O1._dval == 0. ) {
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
				  if (d == DBL_MAX && verbose )
  					VD_drwParserWarn (verbose, 
						 "Illegal exponent\n");
				   break ;
		}
	res->_dval	= d ;

wrapup :
	if (verbose > 0 )
		VD_drwVerbOp (opType, operand1, operand2, res);
		
	return *msg & 1 ;

} /* VD_binOP */
