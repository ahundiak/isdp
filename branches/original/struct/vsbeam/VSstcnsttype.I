/*
	I/STRUCT
*/
class implementation VSstfBeam ;

/*----------------------------------------------------------------------------*/
method VSputConstructionType( long *msg ; int ctype ) {

	long	sts ;

	switch( ctype ) {
		case VS_K_stNormalToSide :
		case VS_K_stUseSurfOfPrj :
			me->flags.constructType = ctype ;
			*msg = MSSUCC ; sts = OM_S_SUCCESS ;
			break ;
		default			 :
			*msg = MSINARG ; sts = OM_E_INVARG ;
			break ;
	}
	return sts ;

} /* method VSputConstructionType */
/*----------------------------------------------------------------------------*/
method VSgetConstructionType( long *msg ; int *p_ctype ) {

	*p_ctype = me->flags.constructType ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetConstructionType */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

