/*
	I/STRUCT
*/
class specification VSevmaspCmd (1:0) of VSpartopCmd ;

#include <stdio.h>
#include "growner.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"

message verifyLogin() ;

override status_disp ;

message VSfillMassPropsForm(	long		*msg ;
				VSintegral	*mp ;
				IGRvector	axes[3] ;
				double		moments[3] ) ;

message writeMassProps( long *msg ; FILE *usrFile ) ;

message VSget_modifiable_gadgets( long *msg ; struct VSgadget **list ) ;

message VSenable_form( long *msg );

message VSdisable_form( long *msg );

override operation ;

override wakeup ;
message  VSsleep (int pos) ;

override form_notification ;

end specification VSevmaspCmd ;
