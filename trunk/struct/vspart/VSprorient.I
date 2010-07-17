/*
	I/STRUCT
*/
class implementation VSpart ;

#include "OMerrordef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
method VSsetOrientation(	long		*msg ;
				struct GRmd_env	*myEnv ;
				int		orientation ) {

	*msg = EMS_I_Fail ;
	return OM_S_SUCCESS ;

} /* method VSsetOrientation */
/*----------------------------------------------------------------------------*/
method VSgetOrientation(	long	*msg ;
			int	*orientation ) {

	*msg = MSSUCC ;
	*orientation = VS_K_NoOrient ;

	return OM_S_SUCCESS ;

} /* method VSgetOrientation */
/*----------------------------------------------------------------------------*/
method VShasOrientation( int OMmsgType ) {

	return OM_W_ABORT ;

} /* method VShasOrientation */
/*----------------------------------------------------------------------------*/
method VSshowOrientation(	long			*msg ;
				struct GRmd_env		*myEnv ;
				int			wantReverse ;
				enum GRdpmode		pen ;
				struct IGRdisplay	*symbology ) {
	*msg = EMS_I_Fail ;
	ex$message(	msgnumb		= VS_gI_NoOrient,
			justification	= CENTER_JUS ) ;
	return OM_S_SUCCESS ;

} /* VSshowOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
