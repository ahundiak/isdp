/*
	I/STRUCT
*/
class specification VSjnattrCmd (1:0) of CEO ;

instance VSjnattrCmd {
	char	*ActJnAttr_form,
	/*
	 * Pointer so save the pocket-menu, since we disable it while the
	 * save-restore from is up.
	 */
		*pkt_menu ;
} ;

message does_form_exist( int *sts ) ;

message createForm( int *sts ) ;

message initForm( long *msg ) ;

message displayForm( int * sts ) ;

message deleteForm( int * sts ) ;

message disable_enable_pkt_menu( int di0_en1 ) ;

end specification VSjnattrCmd ;
