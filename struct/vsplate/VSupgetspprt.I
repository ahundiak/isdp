/* $Id: VSupgetspprt.I,v 1.1.1.1 2001/01/04 21:10:53 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsplate/VSupgetspprt.I
 *
 * Description: Get the plates support surface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSupgetspprt.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/02/14  20:08:04  pinnacle
# Replaced: vsplate/VSupgetspprt.I for:  by impd252 for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/29/00  adz     Change process to get direct parent surface. 
 */

class implementation VSsubPlate ;

#include "exmacros.h"
#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern OMuword  OPP_VSsplPlate_class_id ;

/*----------------------------------------------------------------------------*/
method	VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupp ) {

	long			sts,		/* OM return code	*/
				notUsed ;	/* Self-explanatory	*/
	int			u,		/* Index 		*/
				nbParents ,	/* Count of parents	*/
				myIndex ;	/* On Parent Channel	*/
	struct GRid		parent0 ;	/* Parent at index 0	*/

	SetProc( VSgetSupports ); Begin
	__DBGpr_me();

	/*
	 * Find your position in manager parent's ordering, Then get its foot
	 * at the same index.
	 */
	*count = 0 ;

	sts = om$send(msg  = message VSsubFeature.VSgetIndex( msg, &myIndex ),
	    	      targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSsubFeature.VSgetIndex", wrapup1 ) ;

	__DBGpr_int(" INDEX ", myIndex );
	if(!( myIndex == 0 || myIndex == 1 )) goto wrapup1;

	*msg = MSFAIL ;
	sts =  om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								&parent0,
								1,
								NULL,
						/* from = */	VS_K_ConsumedIx,
						/* to   = */	VS_K_ConsumedIx,
								&nbParents ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup1 ) ;
	if( nbParents == 0 ) goto wrapup1 ;

	__DBGpr_obj(" OPERAND ", parent0 );

	/*
	 * Check if parent object is a VSsplPlate object. If so, 
	 * perform new process, otherwise redirect to existing interface.
	 */
    if(! (vs$is_ancestry_valid( object  = &parent0,
                                classid = OPP_VSsplPlate_class_id ))){
		/*
		 * Create the exception process for the split plate.
		 */
		goto wrapup1 ;
	}

	/*
	 * If sub-plate #0, do a give-foot then copy it, if sub-plate #1
	 * consume parent's outputs, then delete unused one.
	 */
	sts = om$send( msg	= message NDmacro.ACreturn_foot(
				msg,
				(myIndex==0) ? VS_K_cpGrCmpSurf0
					     : VS_K_cpGrCmpSurf1,
				& mySupp[0].obj_id,
				& mySupp[0]._matrix_type,
				mySupp[0]._matrix ),
			targetid = parent0.objid,
			targetos = parent0.osnum );
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup1 ) ;

	mySupp[0]._md_os = mySupp[0]._osnum ;
	ex$get_modid(	mod_osnum = mySupp[0].mod_env.md_id.osnum,
			mod_id	  = &mySupp[0].mod_env.md_id.objid ) ;

	__DBGpr_obj(" SUPPORT ", mySupp[0].obj_id );
	(*count)++;

	goto wrapup ;

wrapup1:
	__DBGpr_com(" Old method ");

	/*
	 * We do not want this message to be sent to us first ! Let's
	 * forward it to our parent.
	 */
	*msg = MSFAIL ;
	sts =  om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								&parent0,
								1,
								NULL,
						/* from = */	VS_K_ConsumedIx,
						/* to   = */	VS_K_ConsumedIx,
								&nbParents ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	/*
	 * Go up in search of the VSsrcPlate which may answer this message.
	 */
	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
						&notUsed,
						OM_e_wrt_object,
						OPPmargs ),
			targetid= parent0.objid,
			targetos= parent0.osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;

wrapup :
	End
	return sts ;

} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSsubPlate ;

