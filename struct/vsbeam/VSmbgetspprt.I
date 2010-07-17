/*
	I/STRUCT
*/
class implementation VSmodBeam ;

/*----------------------------------------------------------------------------*/
method VSgetSupportSf(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env 	*sf ) {

	long	notUsed ;	/* Self-explanatory	*/

	return om$send(	msg	= message VSfeature.VSforwardToSource(
					&notUsed, OM_e_wrt_object, OPPmargs ),	
			targetid= my_id ) ;

} /* method VSgetSupportSf */
/*----------------------------------------------------------------------------*/
method VSgetSupportAxis(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env 	*axis ) {

	long	notUsed ;	/* Self-explanatory	*/

	return om$send(	msg	= message VSfeature.VSforwardToSource(
					&notUsed, OM_e_wrt_object, OPPmargs ),	
			targetid= my_id ) ;

} /* method VSgetSupportAxis */
/*----------------------------------------------------------------------------*/

end implementation VSmodBeam ;

