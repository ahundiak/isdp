/*
	I/STRUCT
*/
class implementation VSsharedData ;

/*----------------------------------------------------------------------------*/
method NDcopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*cpyEnv ;
			struct GRid	*copy ) {

	return om$send(	msg	= message NDnode.NDcopy(	msg,
								cp_type,
								myEnv,
								cpyEnv,
								copy ),
			targetid= my_id ) ;

} /* method NDcopy_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;
