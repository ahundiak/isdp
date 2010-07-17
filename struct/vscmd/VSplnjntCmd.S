/* $Id: VSplnjntCmd.S,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSplnjntCmd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplnjntCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/01/02  12:17:00  pinnacle
# Replaced: vscmd/VSplnjntCmd.S for:  by svkadamb for struct
#
# Revision 1.1  1997/11/14  12:15:20  pinnacle
# Created: vscmd/VSplnjntCmd.S by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          creation
 ***************************************************************************/

/*
	I/STRUCT
*/
class specification VSplnjntCmd (1:0) of VSpartopCmd ;
#ifndef didef
#       include "DIdef.h"
#endif
#ifndef DItypedef_include
#       include "DItypedef.h"
#endif
#ifndef diglob
#       include "DIglob.h"
#endif
#ifndef DIprims
#       include "DIprims.h"
#endif
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "growner.h"

/*
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"
*/

instance VSplnjntCmd {
	char            *attrForm ;	/* Attribues sun form		*/ 
	char		*plcJnForm ;	/* Joint Placemnt Forms 	*/

	variable struct GRobj_env       firstSet[0] ;
	variable struct GRobj_env       secondSet[0] ;
	variable struct GRobj_env       objList[0] ;

	IGRboolean UAFormErased ;   	/* user attr form erased ?	*/
	IGRboolean attrFormErased ;	/* joint attribute for erased ?	*/
};
override 	init,
		wakeup,
		sleep,
		delete,
		form_notification ;

message VSsetJnts_form_notification( 	int     form_label ;
					int	gadget_label ;
					double	value ;
					char	*form_ptr );

message VSpartJnts_form_notification( 	int     form_label ;
					int	gadget_label ;
					double	value ;
					char	*form_ptr );
message cleanUp( long *sts ) ;

message sub_form_notification( 	int     form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr );

message construct_joint( long	*msg ;
			 int	form_label ;
			 char	*form_ptr ) ;

message store_first_feature( long *sts ) ;

message store_second_feature( long *sts ) ;

message store_geometry( long *sts ) ;

message process_set( 	long *sts ; 
			int whichSet ) ;

message addToSet (	struct GRid	*objToAdd ;
			struct GRmd_env	*envToAdd ;
			int		whichSet   );

message rmLocSet( long *msg ; int whichSet );

message validateFirstSet( long *sts );

message createForm();

message initForm( long *msg ; int form_label ; char *form_ptr );

end specification VSplnjntCmd ;
