/*
	I/STRUCT
*/
class implementation VSdprPart ;

#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatadef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"

extern int	 VSeqIPATHs() ;
/*----------------------------------------------------------------------------*/
void VSdumpIPATH( text, ip )

char		*text ;
VSixPath	*ip ; {

	int	i ;

	printf( "\t%s:", text ) ;
	for( i = 0 ; i < ip->sz ; i++ ) {
		printf( " %d", ip->ls[i] ) ;
	}
	printf( "\n" ) ;
	fflush( stdout ) ;

} /* VSdumpIPATH */
/*----------------------------------------------------------------------------*/
void VSdumpIPATHvla( text, size, ipath )

char	*text ;
int	size ;
char	*ipath ; {

	int	i ;

	printf( "\t%s:", text ) ;
	for( i = 0 ; i < size ; i++ ) {
		printf( " %d", ipath[i] ) ;
	}
	printf( "\n" ) ;
	fflush( stdout ) ;

} /* VSdumpIPATHvla */
/*----------------------------------------------------------------------------*/
method VSget_sub_cmp_ix(	long		*msg ;
				VScmpixtype	flag ;
				VSixPath	*rpath ;
				VSixPath	*vpath ) {

	long		sts ;		/* OM return code		*/
	int		i,
			equal,		/* TRUE if two IPATHs are equal	*/
			nbIPATHs,	/* Count of IPATHs in VLAs	*/
			FRvlasz,	/* Size of from-VLA		*/
			TOvlasz ;	/* Size of to_VLA		*/
	char		*FRvla,		/* Points to from-VLA		*/
			*TOvla ;	/* Point to to-VLA		*/
	VSixPath	*FR,		/* Input from-IPATH		*/
			*TO,		/* Output to-IPATH		*/
			aux ;		/* One IPATH in from-VLA	*/
			
	switch( flag ) {
		case VS_e_real_to_virtual	:
			FR	= rpath ;
			FRvla	= me->realIPATHs ;
			FRvlasz	= om$dimension_of( varray = me->realIPATHs ) ;
			TO	= vpath ;
			TOvla	= me->virtIPATHs ;
			TOvlasz	= om$dimension_of( varray = me->virtIPATHs ) ;
			break ;
		case VS_e_virtual_to_real	:
			FR	= vpath ;
			FRvla	= me->virtIPATHs ;
			FRvlasz	= om$dimension_of( varray = me->virtIPATHs ) ;
			TO	= rpath ;
			TOvla	= me->realIPATHs ;
			TOvlasz	= om$dimension_of( varray = me->realIPATHs ) ;
			break ;
		default				:
			*msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ;
	}

	equal = FALSE ;
	/*
	 * Look `FR' in `FRvla' and fill `TO' with corresponding IPATH found
	 * in `TOvla'.
	 */
	for( nbIPATHs = i = 0 ; i < FRvlasz ; ) {
		/*
		 * Extract a path.
		 */
		aux.sz = 0 ;
		while( FRvla[i] != VS_K_NULL_INDEX ) {
			aux.ls[aux.sz++] = FRvla[i++] ;
		}
		/*
		 * Skip next VS_K_NULL_INDEX.
		 */
		i++ ;

		/*
		 * Compare read path with FR.
		 */
		if( equal = VSeqIPATHs( FR, &aux ) ) {
				break ;
		}
		nbIPATHs++ ;		
	}
	if( equal ) {
		int j ;
		/*
		 * Get path number `nbIPATHs' in `TOvla', copy it to `TO'.
		 */
		j = 0 ;
		for( i = 0 ; i < TOvlasz ; ) {

			if( j == nbIPATHs ) {

				TO->sz = 0 ;
				while( TOvla[i] != VS_K_NULL_INDEX ) {

					TO->ls[TO->sz++] = TOvla[i++] ;
				}
				break ;
			} else {
				while( TOvla[i] != VS_K_NULL_INDEX ) {
					i++ ;
				}
				/*
				 * Skip VS_K_NULL_INDEX.
				 */
				i++ ;
				/*
				 * ... and count it.
				 */
				j++ ;
			}
		}
		sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	} else {
		/*
		 * No match found: return output same as input.
		 */
		*TO = *FR ;
		sts = OM_S_SUCCESS ; *msg = EMS_I_NoSolution ;
	}
	if( TO->sz == 1 && TO->ls[0] == VS_K_CMP_LOST ) {

		sts = OM_W_ABORT ; *msg = EMS_W_NoSolution ;
	}

	wrapup :
		return sts ;

} /* method VSget_sub_cmp_ix */
/*----------------------------------------------------------------------------*/

end implementation VSdprPart ;
