/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <string.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "vsbtchctsdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

extern OMuword	OPP_expression_class_id ;
/*----------------------------------------------------------------------------*/
static int VS__getOperatorToOperandsMap( string, oprndIndices, oprtrNum )

char	*string,
	oprndIndices[VS_K_MAX_OPNDS] ;
int	*oprtrNum ; {

	/*
	 * Decipers the mapping string, which must have the form
	 *
	 *	"~~operator<n>~<i0>~<i1>~<i2>~...<ip>"
	 *
	 * Where	<n>	is the operator number
	 *		<ik>	is the index of the oprand cut by operator <n>
	 * The string means that the (nested) foot of the macro, which is
	 * the operator, will cut the templates of the macro at indices <ik>.
	 * There may be at most VS_K_MAX_OPTRS operators hence <n> must range
	 * between 0 and VS_K_MAX_OPTRS-1 ; ther may be at most VS_K_MAX_OPNDS,
	 * hence k ( of <ik> ) must range between 0 and VS_K_MAX_OPNDS-1.
	 *
	 * If string is reduced to
	 *	"~~operator<n>" (no map)
	 * then all operands (templates) will be cut with operator <n>.
	 *
	 * We also accept "~~operator", meaning "~~operator0".
	 *
	 * Note : "~~operator"  is #defined to be `VS_K_optrKyWord'
	 *        separator '~' is #defined to be `VS_K_MAX_SEP'
	 */
	char	*p,
		*ptr ;
	int	i,
		ioperator,	/* Index of operator,  read from string	*/
		ioperand,	/* Index of 1 operand, read from string	*/
		mapall ;	/* Operator cut all operands(TRUE/FALSE)*/

	/*
	 * We know that strings begins with "~~operator", so go past those
	 * characters, what remains thus is
	 *		"<n>~<i0>~<i1>~<i2>~...<ip>"
	 * Or		"<n>"			(no map)
	 * Or		""			(case "~~operator")
	 */

	p = string + strlen( VS_K_optrKyWord ) ;

	for( i = 0 ; i < VS_K_MAX_OPNDS ; i++ )
		oprndIndices[i] = VS_K_END_OF_MAP ;

	mapall = TRUE ;
	/*
	 * Read operator index.
	 */
	ioperator = strtol( p, &ptr, 10 ) ;

	if( ptr == p ) {
		/*
		 * Nothing read.
		 */
		if( !*p ) {
			/*
			 * Because string was empty : OK.
			 * ( Case "~~operator", meaning "~~operator0".
			 */
			ioperator = 0 ;
		} else {
			/*
			 * Because non-numeric : bad.
			 * (Eg. "~~operatorQ")
			 */
			return FALSE ;
		}

	} else if( VS_K_MAP_SEP == *ptr ) {
			/*
			 * Next char after number is ~ : we have a mapping.
			 */
			mapall = FALSE ;
	} else if( ptr == p + strlen( p ) ) {
		/*
		 * All of `p' was read, all operands mapped to operator.
		 * ( Eg. "~~operator3" ).
		 */
		/* NO OP */
	} else {
		/*
		 * Got garbage : bad, eg. "~~operator3x", where "x" is garbage.
		 */
		return FALSE ;
	}

	*oprtrNum = ioperator ;

	/*
	 * Check for overflow.
	 */
	if( ioperator >= VS_K_MAX_OPTRS ) {
		return FALSE ;
	}
	if( mapall ) {
		oprndIndices[0] = VS_K_MAP_ALL ;
		return TRUE ;
	}
	i = 0 ;
	do {
		if( *ptr != VS_K_MAP_SEP ) {
			/* Missing separator */
			return FALSE ;
		}

		p = ptr + 1 ;
		ioperand = strtol( p, &ptr, 10 ) ;

		/*
		 * Skip this one if overflow.
		 */
		if( ioperand < VS_K_MAX_OPNDS ) {
			oprndIndices[i++] = ioperand ;
		}
		if( !*ptr ) {
			break ;
		}
	} while( TRUE ) ;

	return TRUE ;

} /* VS__getOperatorToOperandsMap */
/*----------------------------------------------------------------------------*/
long VSgetOperatorToOperandsMap( msg, optObj, map, cnt )

long		*msg ;
struct GRid	*optObj ;
VSoprtrOprndMap	map[VS_K_MAX_OPTRS] ;
int		*cnt ; {

	long			sts ;
	int			DIrc,
				i,
				j,
				ioptr,
				count	= 0 ;
	char			**lines	= NULL,
				regExp[20],
				oprndIndices[VS_K_MAX_OPNDS] ;
	DIgrid			*grids	= NULL ;
	OM_S_CLASSLIST		clist ;
	struct ret_struct	rs ;

	*cnt = 0 ;

	/*
	 * Dump content of directory associated with macro definition, we are
	 * only interested in expressions.
	 */
	clist.w_count	= 1 ;
	clist.w_flags	= OM_CLST_subclass ;
	clist.p_classes = &OPP_expression_class_id ;

	sts = om$send(	msg	= message IGRdir.dump(	&DIrc,
							"*",
							&clist,
							&lines,
							&grids,
							&count,
							0 ),
			senderid= NULL_OBJID,
			targetid= optObj->objid,
                	targetos= optObj->osnum ) ;
	__CheckRC( DIrc, sts, "IGRdir.dump", wrapup ) ;

	/*
	 * Init map : operators -> operands
	 */
	for( i = 0 ; i < VS_K_MAX_OPTRS ; i++ ) {
		map[i].oprndIndices[0] = VS_K_END_OF_MAP ;
	}
	/*
	 * Keep expressions whose names begin with "~~operator".
	 */
	sprintf( regExp, "%s*", VS_K_optrKyWord ) ;

	for( i = j = 0 ; i < count ; i++ ) {
		if( !VSmatchRE( regExp, lines[i] ) ) continue ;

               	__DBGpr_str( "LINE", lines[i] ) ;

		/*
		 * Parse line, extracting which operands correspond to one
		 * operator (all this can be deduced from the expression's
		 * name).
		 */
		if( !VS__getOperatorToOperandsMap(	lines[i],
							oprndIndices,
							&ioptr ) ) continue ;

		memcpy( map[ioptr].oprndIndices,
			oprndIndices,
			VS_K_MAX_OPNDS * sizeof( char ) ) ;

		/*
		 * Now get the pathname of the operator: it is the value of
		 * the expression.
		 */
		sts = om$send(	msg	= message NDnode.NDgive_structure(
							msg, &rs, NULL ),
				senderid= NULL_OBJID,
				targetid= grids[i].objid,
				targetos= grids[i].osnum ) ;

               	if( ( sts & 1 & *msg ) && rs.type == text_type ) {
               		strcpy(	map[ioptr].oprtrName,
               			rs.var.text_st.text_string ) ;
               		__DBGpr_str( "Value of ~~operator",
               			     map[ioptr].oprtrName ) ;
               	} else {
               		map[ioptr].oprndIndices[0] = VS_K_END_OF_MAP ;
               		__DBGpr_com( "End of map" ) ;
               	}
               	j++ ;
	}

	*cnt = j ;

	if( count && lines != NULL ) VSfreeList( count, lines ) ;
	if( count && grids != NULL ) free( (char *) grids ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSgetOperatorToOperandsMap */
/*----------------------------------------------------------------------------*/
int VSgetOperatorsForOperand( oprndIndex, cnt, map,
			      oprtrNms, nmCount )

int		oprndIndex,	/* Index of operand in "~~operand<index>" */
		cnt,		/* Size of map				  */
		*nmCount ;
VSoprtrOprndMap	map[VS_K_MAX_OPTRS] ;
char		*oprtrNms[VS_K_MAX_OPTRS] ; {

	/*
	 * Given a map : operators -> operands deduced from expressions in
	 * the directory associated with a macro definition:
	 *
	 * ~~operand0~1~2	= "foot1:footA"
	 * ~~operand1~1		= "foot2"
	 * ~~operand2~3		= "foot3:footB:footX",
	 *
	 * a macro occurrence owning (possibly nested) feet (operators)
	 *
	 *	"foot1:footA", "foot2", "foot3:footB:footX"
	 *
	 * and a template of the macro occurrence `operand', checks if `operand'
	 * has its index in the map : operators -> operands, ie. if the index
	 * of `operand' is in some of the lists associated with the operators.
	 * If so adds the foot name of the operator to the name list `oprtrNms'.
	 */

	int		i,
			j,
			k,
			pos ;

	k = 0 ;
	/*
	 * Loop on operators.
	 */
	for( i = 0 ; i < cnt ; i++ ) {
		/*
		 * Loop on indices of operands.
		 */
		for( j = 0 ; j < VS_K_MAX_OPTRS ; j++ ) {
	
			pos = map[i].oprndIndices[j] ;

			/*
			 * End of map operator #i -> operands.
			 */
			if( VS_K_END_OF_MAP == pos ) break ;

			if( VS_K_MAP_ALL == pos ) {
				/*
				 * Operators mapped to all operands, add foot
				 * name.
				 */
				oprtrNms[k++] = map[i].oprtrName ;
				continue ;
			}
			if( pos == oprndIndex ) {
				/* Match! */
				oprtrNms[k++] = map[i].oprtrName ;
			}

			/*
			 * Beware of overflow !
			 */
			if( k >= VS_K_MAX_OPTRS ) break ;

		} /* End loop on operands (templates) */

	} /* End loop on operators ( feet) */

	*nmCount = k ;

	return 1 ;

} /* VSgetOperatorsForOperand */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

