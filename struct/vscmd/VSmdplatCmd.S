/*
	I/STRUCT
*/
class specification VSmdplatCmd (1:0) of VSplplatCmd ;

instance VSmdplatCmd {
	unsigned long		modAttr ;
	char			plateDir[DI_PATH_MAX] ;
	unsigned short		ActPlate;       /* The plate number which     */
						/* attributes are displayed   */
						/* displayed on the form.     */
	int			initialOrientation ;
} ;


from VSfmplatCmd inherit	enable_form,
				wakeup ;

message setFormTitle() ;

override sleep ;

override init_cmd ;

override load_attributes ;

override process_fence ;

override display_support_normal ;

override get_modifiable_gadgets ;

override construct_plate ;

override form_notification ;

override store_support ; 

message resetForm( int *sts ) ;

message ActivateDismissGadget( int *sts ) ;

end specification VSmdplatCmd ;

