/*
	I/STRUCT
*/
class specification VSplbeamCmd (1:0) of VSfmbeamCmd ;

#include "growner.h"

instance VSplbeamCmd {
	struct GRobj_env	BeamSect ;

	IGRboolean		detailCard ;
} ;

override wakeup ;

override delete ;

message init_cmd( int *sts ) ;

message store_surface( int *sts ) ;

message store_axis( int *sts ) ;

message process_fence( int *sts ) ;

message chain_locate( int *sts ) ;

override enable_form ;

override load_attributes ;

message construct_beam( long *msg ) ;

override get_modifiable_gadgets ;

override form_notification ;

message inter_display( long *msg ) ;

message hilight_elem( long *msg ) ;

message unhilight_elem( long *msg ) ;

message load_attributes_from_beam( long *msg ) ;

message place_plane( int *sts ) ;

end specification VSplbeamCmd ;

