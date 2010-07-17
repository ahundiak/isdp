/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "exdef.h"
#include "msdef.h"
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "gr.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bscv_copy.h"
/*----------------------------------------------------------------------------*/
long VScopybc( msg, inCv, outCv )

long			*msg ;
struct IGRbsp_curve	*inCv,
			**outCv ; {

	long	sts ;

	*outCv = NULL ;

	BSalloccv(	inCv->order,
			inCv->num_poles,
			inCv->rational,
			0,
			outCv,
			msg ) ;
	if( BSERROR( *msg ) ) vs$mem_fail() ;

	BScv_copy( msg, inCv, *outCv ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
			
		return sts ;

} /* VScopybc */
/*----------------------------------------------------------------------------*/

