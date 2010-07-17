/*
	I/STRUCT
*/
class implementation VSplate ;

/*----------------------------------------------------------------------------*/
method GRdetplane(	long		*msg ;
			short		*mxType ;
			IGRmatrix	mx ;
			struct IGRplane	*plane ) {

	long		sts ;
	struct GRid	botSurf ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plBotSfPath,
							&botSurf,
							NULL,
							NULL ),
			targetid= my_id ) ;

	if( sts & 1 & *msg ) {
		sts = om$send(	msg	= message GRvg.GRdetplane(
						msg, mxType, mx, plane ),
				targetid= botSurf.objid,
				targetos= botSurf.osnum ) ;
	}

	return sts ;

} /* method GRdetplane */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

