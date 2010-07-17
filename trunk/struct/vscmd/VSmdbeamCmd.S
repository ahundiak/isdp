/*
	I/STRUCT
*/
class specification VSmdbeamCmd (1:0) of VSplbeamCmd ;

#include "vspart.h"
#include "vsattr.h"
#include "vsglobals.h"
#include "vssectiondef.h"
#include "vsbeam.h"
#include "growner.h"


instance VSmdbeamCmd {
	unsigned long		modAttr ;
	char			beamDir[DI_PATH_MAX] ;
	struct GRobj_env	surfaceOfCS ;	  /* Surface of cross section */
} ;

from VSfmbeamCmd inherit enable_form ;

override init_cmd ;

message setFormTitle() ;

override wakeup ;

override sleep ;

override delete ;

message store_beam( int *sts ) ;

override load_attributes ;

override process_fence ;

override get_modifiable_gadgets ;

override construct_beam ;

override form_notification ;

override inter_display ;

message resetForm( int *sts ) ;

override hilight_elem ;

message ActivateDismissGadget( int *sts ) ;

override draw_section_on_form ;

end specification VSmdbeamCmd ;

