/*
	I/STRUCT
*/
class implementation VSbeam ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "grerr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbOutputs	1

	long		sts ;	/* OM return code	*/
	/*
	 * Graphic output's name.
	 */
	static char	*oNames[nbOutputs] = {	VS_K_bmGrCmpName },
	/*
	 * Virtual outputs' names.
	 */
		*vNames[] = {
			VS_K_prPrtFamAttr,	/* PDM/PDU family name	*/
			VS_K_prPrtNumAttr,	/* PDM/PDU part number	*/
			VS_K_prMbrNamAttr,	/* Object's name	*/
			VS_K_prMbrClsAttr,	/* Class of object	*/
			VS_K_prMbrTypAttr,	/* Type of object	*/
			VS_K_prMbrGeoAttr,	/* Geometry		*/
			VS_K_prMatTypAttr,	/* Material		*/
			VS_K_prMatGrdAttr,	/* Grade of material	*/
			VS_K_prUsrNotAttr,	/* User comments	*/
			VS_K_prMTOSrcAttr,	/* Source number	*/
			VS_K_prMTOStkAttr,	/* Stock number		*/
			VS_K_prChgNumAttr,	/* Change request number*/
			VS_K_prFpThckAttr,	/* Fireproof'g thickness*/
			VS_K_prApprvlAttr,	/* Approval status	*/
			VS_K_prConstrAttr,	/* Construction status	*/
			VS_K_bmHeightAttr,	/* Height of profile	*/
			VS_K_bmWidthAttr,	/* Width of profile	*/
			VS_K_bmFlgThkAttr,	/* Flange thickness	*/
			VS_K_bmWebThkAttr,	/* Web thickness	*/
			VS_K_bmFltRadAttr,	/* Fillet radius	*/
			VS_K_prUsrAttr		/* Usr attr. collection	*/
	} ;
	/*
	 * Virtual outputs' types.
	 */
	static int	vTypes[] = {
			text_type,	/* PDM/PDU family name	*/
			text_type,	/* PDM/PDU part number	*/
			text_type,	/* Object's name	*/
			double_type,	/* Class of object	*/
			double_type,	/* Type of object	*/
			double_type,	/* Geometry		*/
			text_type,	/* Material		*/
			text_type,	/* Grade of material	*/
			text_type,	/* User comments	*/
			text_type,	/* Source number	*/
			text_type,	/* Stock number		*/
			double_type,	/* Change request number*/
			double_type,	/* Fireproof'g thickness*/
			text_type,	/* Approval status	*/
			text_type,	/* Construction status	*/
			double_type,	/* Height of profile	*/
			double_type,	/* Width of profile	*/
			double_type,	/* Flange thickness	*/
			double_type,	/* Web thickness	*/
			double_type,	/* Fillet radius	*/
			gen_rg_collect	/* Usr attr. collection	*/
	} ;


	/*
	 * The definitions of inputs are sub-class dependent and are not defined
	 * here.
	 */
	myDef->input.count = 0 ;

	/*
	 * Outputs.
	 */
	myDef->output.count		= nbOutputs ;
	myDef->output.names		= oNames ;
	myDef->output.type.classids	= NULL ;

	/*
	 * Virtual outputs.
	 */
	myDef->virtual.count		= sizeof vNames / sizeof *vNames ;
	myDef->virtual.names		= vNames ;
	myDef->virtual.type.types	= vTypes ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

