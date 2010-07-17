/*
	I/STRUCT
*/ 
class implementation VSvarPlate ;

#include "EMSmsgdef.h"
#ifndef EMSopt_include
#	include "EMSopt.h"
#endif
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsexpvalue.h"
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long		sts ;		/* OM return code	*/
	double		wantedThickness,/* Needed thickness	*/
			rdbThickness ;	/* Thickness from RDB	*/
	char		rdbThkName[100];/* Name of RDB thickness*/
	VSpartAttr	myAttr ;	/* My part attributes	*/
	VSplateAttr	myInfo ;	/* Some attributes	*/

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	/*
	 * Fetch value of parent #1 (expression).
	 */
	sts = VSexpValue( listOfInputs[1].objid, listOfInputs[1].osnum,
			  &wantedThickness ) ;
	__CheckRC( sts, 1, "VSexpValue", wrapup ) ;
	
	/*
	 * Ask Relational Data Base for available thickness.
	 * This method fails if the station is not connected to the RDB server:
	 * then keep old value (i.e. jump to "evaluate:" ).
	 */
	sts = om$send(	msg	= message VSvarPlate.VSselectThicknessFromRDB(
						msg,
						wantedThickness,
						&rdbThickness,
						rdbThkName ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSvarPlate.VSselectThicknessFromRDB", evaluate );

	/*
	 * Put attributes.
	 * NOTE: this objects updates its attributes during compute. How does
	 * that influence the system if this object is inside a macro
	 * definition ? : it is of no consequence because the update takes
	 * place a each recompute and the new recompute does not depend upon
	 * the preceeding values of the attributes.
	 */
	myAttr.Iwant	= VS_m_Thickness | VS_m_PartNum ;
	myAttr.specific	= (void *) &myInfo ;

	myInfo.thickness	= rdbThickness ;
	strcpy( myAttr.info.partNum, rdbThkName ) ;
	sts = om$send(	msg	= message GRvg.GRputattr(
							msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

	/*
	 * Now evaluate yourself. Use first parent only !
	 */
	evaluate :

	sts = om$send(	msg	= message VSsrcPlate.ACconstruct_feet(
								msg,
								purpose,
								1,
								listOfInputs,
								myEnv,
								countOfOutputs,
								listOfOutputs ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	wrapup :
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSvarPlate ;
