/*
	I/STRUCT
*/
class implementation VSfrzBeam ;

/*----------------------------------------------------------------------------*/
method VSgetBeamLength( long *msg ; struct GRmd_env *myEnv ; double *length ) {

	*length = me->length ;
	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetBeamLength */
/*----------------------------------------------------------------------------*/

end implementation VSfrzBeam ;

