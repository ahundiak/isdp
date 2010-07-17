/*
	I/STRUCT
*/
class implementation VSmodFeature ;

/*----------------------------------------------------------------------------*/
method VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupports ) {

	long	notUsed ;	/* Self-explanatory	*/

	return om$send(	msg	= message VSfeature.VSforwardToSource(
					&notUsed, OM_e_wrt_object, OPPmargs ),	
			targetid= my_id ) ;

} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;

