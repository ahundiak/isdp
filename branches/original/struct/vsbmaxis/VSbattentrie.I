/*
	I/STRUCT
*/
class implementation VSbeamAxis ;

/*----------------------------------------------------------------------------*/
method VDget_trans_table_entries( long		*msg ;
				  struct GRid	*main_root ;
				  char		*cmd_name ) {

	main_root->objid = NULL_OBJID ; 	/* First root -> plate. */
	strcpy( cmd_name, "stiffener" ) ;	/* Like a stiffener.	*/

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* VDget_trans_table_entries */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
