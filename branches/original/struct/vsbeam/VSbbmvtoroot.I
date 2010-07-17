/*
	I/STRUCT
*/
class implementation VSbooBeam ;

/*----------------------------------------------------------------------------*/
method NDmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ; ) {

	return om$send(	msg	= message VSfeature.VSmove_to_root(
							msg, src, myEnv ),
			targetid= my_id ) ;

} /* method NDmove_to_root */
/*----------------------------------------------------------------------------*/
method NDparent_deleted(	long		*msg ;
				int		deletedCount ;
				struct GRid	deletedList[] ; 
				struct GRid	*newObj ;
				struct GRmd_env *myEnv ) {

	return om$send(	msg	= message VSfeature.VSparentsDeleted(
								msg,
								deletedCount,
								deletedList, 
								newObj,
								myEnv ),
			targetid= my_id ) ;
				
} /* method NDparent_deleted */
/*----------------------------------------------------------------------------*/

end implementation VSbooBeam ;

