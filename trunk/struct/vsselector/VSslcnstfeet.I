/*
	I/STRUCT
*/
class implementation VSselector ;

#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes for function prototypes.
 */
#include "vsslcproto.h"

extern void		VSsetGRids() ;
extern IGRboolean	ASbroadcast_in_progress ;
extern int		VDcomment;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	char			*program ;	/* Program text		*/
	VSexecIN		inParms ;	/* Input to exec.	*/
	VSexecOUT		outParms ;	/* Output from exec.	*/
	VSparseErr		err ;		/* Parsing error	*/
	VS_NODE			*progStart ;	/* Start node of program*/
	IGRboolean		saveBroadcast ;
	struct GRsymbology	mySymb ;

	progStart		= NULL ;
	program 		= NULL ;
	/*
	 * Modify broadcast flag so possible GRcopy messages won't trigger
	 * a graph copy.
	 */
	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	VSsetGRids( myEnv->_MD_OS, VS_K_MAX_OUTPUT, listOfOutputs ) ;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;

	/*
	 * Note: if selector has no graphic output, "GRvg.GRgetsymb" will fail,
	 * put dummy symbology.
	 */
	if( !( sts & *msg & 1 ) ) {
		mySymb.level			= 0 ;
		mySymb.display_attr.color	= 1 ;
		mySymb.display_attr.weight	= 0 ;
		mySymb.display_attr.style	= 0 ;
	}
	vs$fill_cnst_list(	Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	inParms.cst	= &cst ;
	inParms.INPUT	= listOfInputs ;
	inParms.count	= countOfInputs ;

	outParms.OUTPUT	= listOfOutputs ;
	outParms.size	= VS_K_MAX_OUTPUT ;
	outParms.count	= 0 ;

	/*
	 * Get selection program to run.
	 */
	sts = om$send(	msg	= message GRvg.GRgetattr(
						msg, (char *) &program ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * Compile and execute program.
	 */
	if( vs$compile(	error		= &err,
			program		= program,
			executable	= &progStart,
			aliases		= inParms.aliases )  ) {

		vs$execProgram(	msg		= msg,
				input		= &inParms,
				executable	= progStart,
				output		= &outParms ) ;

		if( !(*msg&1)){
			/* Debug out program */
			printf("\t[%d,%d]VSseletor program failed \n",OM_Gw_current_OS,my_id);
		    	if( VDcomment ){
				VSdumpProg( progStart );
			}
		}
			
		__CheckRC( 1, *msg, "vs$execProgram", wrapup ) ;

	} /* else error */

	*countOfOutputs = outParms.count ;

	/*
	 * Do not allow an output-less selector: if object has no name it will
	 * be hard to reach it.
	 */
	if( !*countOfOutputs ) {
		*msg = EMS_E_NoSolution ;
	} else {
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
		/*
		 * Update object tag, don't check return code: will be
		 * OM_W_NOTTAGGED if object has no tag connection.
		 */
		om$change_tag_version() ;
	}

	wrapup :
		ASbroadcast_in_progress = saveBroadcast ;

		if( progStart ) VSfreeProg( progStart ) ;
		_FREE( program ) ;

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids	= outParms.OUTPUT,
					count	= outParms.count,
					theEnv	= cst.env_info ) ;

			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
	    		}
		}

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSselector ;
