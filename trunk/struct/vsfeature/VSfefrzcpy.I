/*
	I/STRUCT
*/
class implementation VSfeature ;
/*----------------------------------------------------------------------------*/
method VScreateFrozenCopy(	long		*msg ;
				struct GRmd_env	*myEnv,
						*cpyEnv ;
				struct GRid	*copy ) {

	return om$send(	msg	= message ACncpx.NDcopy_to_root(
						msg, 0, myEnv, cpyEnv, copy ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

} /* method VScreateFrozenCopy */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

