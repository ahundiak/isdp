/*
	I/STRUCT
*/
class implementation VSbeam ;

/*----------------------------------------------------------------------------*/
method VDget_prefix_name( long		*msg ;
			  char		*directory ;
			  int		*real_name ;
			  char		*prefix ) {

	long	sts ;

	sts = om$send( msg	= message VSbeam.VSisNameHolder(
							      VS_K_READ_OMmsg ),
		       targetid = my_id ) ;

	if( sts == OM_I_STOP_SENDING ) {
		/*
		 * I can store the name.
		 */
		strcpy( prefix, "B" ) ;
		*real_name = FALSE ;

		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;
	} else {
		/*
		 * I cannot store the name.
		 */
		sts  = OM_E_ABORT ;
		*msg = MSFAIL ;
	}

	return sts ;

} /* VDget_prefix_name */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
