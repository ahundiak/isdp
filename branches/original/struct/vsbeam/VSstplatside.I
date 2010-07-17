/*
	I/STRUCT
*/
class implementation VSstfBeam ;

/*----------------------------------------------------------------------------*/
method VSputPlateSide( long *msg ; int side ) {

	long	sts ;

	switch( side ) {
		case VS_K_stOnBotOfPlate :
		case VS_K_stOnTopOfPlate :
			me->flags.onWhichSideOfPlate = side ;
			*msg = MSSUCC ; sts = OM_S_SUCCESS ;
			break ;
		default			 :
			*msg = MSINARG ; sts = OM_E_INVARG ;
			break ;
	}
	return sts ;

} /* method VSputPlateSide */
/*----------------------------------------------------------------------------*/
method VSgetPlateSide( long *msg ; int *p_side ) {

	*p_side = me->flags.onWhichSideOfPlate ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetPlateSide */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

