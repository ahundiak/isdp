/*
	I/STRUCT
*/
class implementation VSbooPlate ;

/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *my_env ) {

	return om$send(	msg	= message VSfeature.VSdelete( my_env ),
			targetid= my_id ) ;

} /* method NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSbooPlate ;


