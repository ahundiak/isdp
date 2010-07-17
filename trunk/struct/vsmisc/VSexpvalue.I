/*
	I/STRUCT
*/
class implementation expression ;

#Include <stdio.h>
/*----------------------------------------------------------------------------*/
long VSexpValue( exp_id, exp_os, p_value )

OM_S_OBJID	exp_id ;
OMuword		exp_os ;
double		*p_value ; {

	long			sts,
				msg ;
	struct ret_struct	rs ;
	struct GRid		realObj;

	/*
	 * If the expression is a foot of the macro and directly given
	 * as an input( thickness ) to the parametric plate then get the
	 * expression object.
	 */
	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
						&msg,
						"",
						&realObj,
						NULL,
						NULL ),
				targetid = exp_id,
				targetos = exp_os,
				senderid = exp_id );	

	sts = om$send(	msg	= message NDnode.NDgive_structure(
							&msg, &rs, NULL ),
			targetid= realObj.objid,
			targetos= realObj.osnum,
			senderid= realObj.objid  ) ;

	*p_value = rs.var.root_pm_st.value ;
	
	return sts ;

} /* VSexpValue */
/*----------------------------------------------------------------------------*/
long VScreateExp( name, value, osnum, p_objid )

char		*name ;
double		value ;
OMuword		osnum ;
OM_S_OBJID	*p_objid ; {

	long		sts ;
	extern OMuword	OPP_expression_class_id,
			OPP_Gexp_class_id ;

	sts = om$construct(	classid	= name	? OPP_expression_class_id
						: OPP_Gexp_class_id,
				osnum	= osnum,
				p_objid	= p_objid ) ;
	if( sts & 1 ) {
		char		syntax[200] ;
		short		rc ;

		sprintf( syntax, "%20.9lf", value ) ;
		sts = om$send(	msg	= message expression.create(	name,
									syntax,
									&rc ),
				senderid= *p_objid,
				targetid= *p_objid,
				targetos= osnum ) ;
		if( !( sts & 1 & rc ) ) {
			om$send(msg	= message Root.delete( 0 ),
				targetid= *p_objid,
				targetos= osnum,
				senderid= *p_objid ) ;
			sts = OM_W_ABORT ;
		}
	}
	return sts ;

} /* VScreateExp */
/*----------------------------------------------------------------------------*/
long VScreateTextExp( name, value, osnum, p_objid )

char		*name ;
char		*value ;
OMuword		osnum ;
OM_S_OBJID	*p_objid ; {

	long		sts ;
	extern OMuword	OPP_text_exp_class_id,
			OPP_Gtext_exp_class_id ;

	sts = om$construct(	classid	= name	? OPP_text_exp_class_id
						: OPP_Gtext_exp_class_id,
				osnum	= osnum,
				p_objid	= p_objid ) ;
	if( sts & 1 ) {
		short		rc ;

		sts = om$send(	msg	= message expression.create(	name,
									value,
									&rc ),
				senderid= *p_objid,
				targetid= *p_objid,
				targetos= osnum ) ;
		if( !( sts & 1 & rc ) ) {
			om$send(msg	= message Root.delete( 0 ),
				targetid= *p_objid,
				targetos= osnum,
				senderid= *p_objid ) ;
			sts = OM_W_ABORT ;
		}
	}
	return sts ;

} /* VScreateTextExp */
/*----------------------------------------------------------------------------*/

end implementation expression ;
