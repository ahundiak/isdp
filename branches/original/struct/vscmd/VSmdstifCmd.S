/*
	I/STRUCT
*/
class specification VSmdstifCmd (1:0) of VSmdbeamCmd ;

instance VSmdstifCmd {
	double	maxAdmGap ;
	int	CanPlaceAlPl ;
	double	InternalYOff ;  /* Internal Y offset to have the stiffener    */
				/* outside of plate ( set to height of cross  */
				/* section when symmetry is 'XY' or 'X',      */
				/* otherwise, set to 0. ).                    */
	char		*rotDefForm ;
	long 		recompSurf ;
	IGRboolean	isTwistedStfnr ;
} ;

override init_cmd ;

override delete ;

override get_modifiable_gadgets ;

override form_notification ;

override resetForm ;

message initForm( int *sts ) ;

override load_attributes_from_beam ;

override load_attributes ;

message load_cnst_type( long *msg ) ;

message load_twist_info( long *msg );

message recomp_surface( long *msg );

message sub_form_notification( char *form_ptr ; int gadget_label );

override inter_display ;

override construct_beam ;

end specification VSmdstifCmd ;

