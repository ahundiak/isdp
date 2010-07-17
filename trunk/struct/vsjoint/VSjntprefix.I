/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "DIdef.h"
#include "DIprims.h"

/*----------------------------------------------------------------------------*/
method VDget_prefix_name( long		*msg ;
			  char		*directory ;
			  int		*real_name ;
			  char		*prefix ) {

	long			sts ;
	struct GRobj_env	feature0,
				feature1 ;

	sts = om$send( msg	= message VSjoint.VSgetJoinedFeatures(msg,
								      &feature0,
								      &feature1,
								      NULL ),
		       targetid = my_id ) ;

	if( sts & 1 & *msg ) {
		char	name[DI_PATH_MAX] ;

		sts = VSmakeJointName( msg,
				       &feature0.obj_id,
				       &feature1.obj_id,
				       directory,
				       name ) ;

		if( sts & 1 & *msg ) {
			sts = di$split( pathname = name,
					name	 = prefix ) ;

			if( sts & 1 ) {
				*real_name = TRUE ;
				sts  = OM_S_SUCCESS ;
				*msg = MSSUCC ;
			} else {
				sts  = OM_E_ABORT ;
				*msg = MSFAIL ;
			}
		} else {
			sts  = OM_E_ABORT ;
			*msg = MSFAIL ;
		}
	} else {
		sts  = OM_E_ABORT ;
		*msg = MSFAIL ;
	}

	return sts ;

} /* VDget_prefix_name */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
