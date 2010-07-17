/*
	I/STRUCT
*/
class implementation VSfeature ;

/*----------------------------------------------------------------------------*/
method VDget_trans_table_entries( long		*msg ;
				  struct GRid	*main_root ;
				  char		*cmd_name ) {

	long		rc ;

	return om$send( msg	 = message VSfeature.VSforwardToOriginal(
				    &rc,
				    OM_e_wrt_object,
				    message VSfeature.VDget_trans_table_entries(
								    msg,
								    main_root,
								    cmd_name )),
			targetid = my_id ) ;

} /* VDget_trans_table_entries */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
