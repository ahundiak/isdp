/*
	I/STRUCT
*/ 
class implementation VSxtrBeam ;

/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *myEnv ) {

	return om$send(	msg	= message VSfeature.VSdelete( myEnv ),
			targetid= my_id ) ;
} /* method NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;

