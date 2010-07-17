/*
	I/STRUCT
*/
class implementation expression ;

#include <stdio.h>
#include <string.h>
/*----------------------------------------------------------------------------*/
long VStxtExpValue( exp_id, exp_os, p_value )

OM_S_OBJID	exp_id ;
OMuword		exp_os ;
char		*p_value ; {

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

	strcpy( p_value, rs.var.text_st.text_string );

	return sts ;

} /* VStxtExpValue */
/*----------------------------------------------------------------------------*/

end implementation expression ;
