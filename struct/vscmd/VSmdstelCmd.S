/*
	I/STRUCT
*/
class specification VSmdstelCmd (1:0) of VSlocateCmd ;

instance VSmdstelCmd {
	struct GRid	GSelement[3] ;		/* Graphic sets of	*/
						/* structural elements :*/
						/* 0 : plates		*/
						/* 1 : beams		*/
						/* 2 : stiffeners	*/

	int		nb_of_elements[3] ;	/* 0 : nb of plates     */
						/* 1 : nb of beams	*/
						/* 2 : nb of stiffeners	*/

	int		element_type ;
	int		flag ;
} ;


override init ;

override sleep ;

override wakeup ;

override delete ;

message store_element( long *msg ) ;

message process_fence( long *msg ) ;

message reset_form( int *sts ) ;

message unhilight_gs( int *sts ) ;

message hilight_gs( int *sts ) ;

message update_form( int *sts ) ;

override form_notification ;

message execute_command( long *msg ) ;

message dissolve_gs( long *msg ) ;

message drop_element( long *msg ) ;

override locate_action_handler ;

end specification VSmdstelCmd ;
