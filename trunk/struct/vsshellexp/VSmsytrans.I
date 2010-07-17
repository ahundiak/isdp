/*
	I/STRUCT
*/
class implementation VSmergeShExp ;

#include <stdio.h>
#include <math.h>
#include "vsmiscmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */

/*----------------------------------------------------------------------------*/
method VSget_y_translation( long		*msg ;
			    struct GRmd_env	*myEnv ;
			    double		*yTrans )
{
	*yTrans = me->yTranslation *
		  sqrt( myEnv->_MATRIX[0] * myEnv->_MATRIX[0] +
			myEnv->_MATRIX[4] * myEnv->_MATRIX[4] +
			myEnv->_MATRIX[8] * myEnv->_MATRIX[8] ) ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* VSget_y_translation */
/*----------------------------------------------------------------------------*/

end implementation VSmergeShExp ;
