/*
	I/STRUCT
*/
class implementation VSimgFeature ;

/*----------------------------------------------------------------------------*/
method VSsendToEveryoneUp(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) {

	long			sts ;		/* OM return code	*/
	struct GRid		mdl ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg	= message VSfeature.VSsendToEveryoneUp(
							msg, deliver, Message ),
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	wrapup :
		return sts ;

} /* method VSsendToEveryoneUp */
/*----------------------------------------------------------------------------*/
method VSforwardToSource(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) {

	long			sts ;		/* OM return code	*/
	struct GRid		mdl ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
							msg, deliver, Message ),
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	wrapup :
		return sts ;

} /* method VSforwardToSource */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
