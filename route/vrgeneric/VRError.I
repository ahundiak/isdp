/*
     CLASS  NAME: VRGeneric
     METHOD NAMES: VRGetErrGraphic

     Abstract: This file contains the methods managing error component.
		
     CHANGE HISTORY:
 *	03/27/01	law	TR4464-need error symbol larger.

***********************************************************************/

class implementation VRGeneric;

#include "godef.h"
#include "gotextdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "cotxmacros.h"

#include "VRDbStruct.h"
#include "VDmem.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"

#define AS_DEBUG	1

#define VR_CPT_DELTA	1 /* One inch between the center and each connect
			     point of the Error component */
#define VR_LOC_DIADEF   4.0   /*  4 inch textsize.......   */

from	VRCnrlSeg	import	VRGetTopo;

/***********************************************************************/

method VRGetErrGraphic ( IGRlong *msg;
			IGRdouble *dMatrix; struct GRid *GraphicId;
			struct GRmd_env *md_env )

{
	IGRdouble		dOrigin[3],dIdMat[16],dDiameter;
	IGRint			status;
	IGRlong			retmsg;
	IGRshort		nProperties,nLength;
	struct GRdpb_text_symb	TxtSymb;
	struct GRid		SymbId;
	struct VDSsymb		VdsSymb;

*msg = MSSUCC;

	/* -- Get diameter for error symbol sizing -- */

	{
		dDiameter = VR_LOC_DIADEF;
		/*" Diameter for text dimensions = %f\n",dDiameter */
                /***** TR4464 *********/
                if(VRenq_proj_units() == VR_METRIC_UNITS)
                               dDiameter *= 25.4;
	}

	/* -- Fill in orientation arguments -- */

	status =
	om$send ( msg = message VRGeneric.VRGetMatrix
			( &retmsg,0, NULL, dIdMat, md_env ),
		targetid = my_id );
	as$status (action = RET_STATUS);

	dOrigin[0] = dIdMat[3];
	dOrigin[1] = dIdMat[7];
	dOrigin[2] = dIdMat[11];

	MAidmx ( (IGRint *) &retmsg, dIdMat );

	/* -- Get VDS error symbology -- */
	SymbId.osnum = OM_Gw_current_OS;

	vd$symbology(	msg	    = &retmsg,
			operation   = RETRIEVE,
			symb_id     = &SymbId,
			symb	    = &VdsSymb );
	/*" Found error color = %d\n",VdsSymb.VDSerror.display_attr.color*/

	/* -- Fill in text Attributes -- */
	TxtSymb.Active_font=0;
	TxtSymb.Active_fraction_font=0;
	TxtSymb.Active_symbol_font=0;
	TxtSymb.Active_ascii_font=0;
	TxtSymb.Active_just=(IGRshort)CENTER_CENTER;
	TxtSymb.Active_width=    dDiameter;
	TxtSymb.Active_height= 1.3*dDiameter;
	TxtSymb.Active_charspac=1.0;
	TxtSymb.Active_linespac=0.0;
	TxtSymb.Active_flags=(IGRshort)VI_FLAG;

	nProperties = (IGRshort) (GRIS_LOCATABLE |
				GRIS_DISPLAYABLE | GRIS_VIEW_INDEP);

	nLength = (IGRshort) strlen(VR_ERROR_SYMBOL);

	co$place_text ( msg		= &retmsg,
			text_string	= VR_ERROR_SYMBOL,
			text_length	= &nLength,
			origin		= dOrigin,
			rot_matrix	= dIdMat,
			ActiveDisplay 	= &VdsSymb.VDSerror.display_attr,
			ActiveLevel 	= VdsSymb.VDSerror.level,
			Properties 	= &nProperties,
			ModuleInfo 	= md_env,
			TextSymb  	= &TxtSymb,
			flags		= 0,		/* no disp, non empty */
			 buffer		= GraphicId);

	if ( retmsg != MSSUCC ) return ( OM_E_ABORT );

return ( OM_S_SUCCESS );

}/* end VRGetErrGraphic */

/***********************************************************************/

method VRGetErrGeom (IGRlong *msg ;IGRshort nCpNum;
		     IGRdouble *dCptCoor; IGRdouble *dConAxis;
		     IGRdouble *dOrientation; struct GRmd_env *md_env)

{

	/* -- Build Error Connect Points Coordinates -- */
	IGRint		status;
	IGRlong		retmsg;
	IGRint		NbCpts,NbSegs;
	IGRdouble	dVect[3];
	IGRshort	nMyIndex;

	struct GRid    *SegIds;

	/*" ---- Error : %s ----\n",me->szAABBCC */

	/*" Connect point : %d \n",nCpNum*/

	/* -- Get Total number of connect points -- */
	status=
	om$send ( msg = message VRGeneric.VRGetNumberOfCpts 
			(&retmsg ,&NbCpts, md_env ),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/*" Total Number Of Connect Points : %d\n",NbCpts*/

  if ( nCpNum < 0 || nCpNum >= NbCpts )
  {
	/*| ERROR -> Bad Cpt Number */
	*msg=MSFAIL;
	return ( OM_E_INVARG );
  }

  *msg = MSSUCC;

	/* -- Get support on connect point -- */
      status =
      om$send ( msg = message VRGeneric.VRGetSupports
                                ( &retmsg, 0, NULL, &NbSegs ),
           targetid = my_id);

      NbSegs++;
      SegIds = _MALLOC (NbSegs, struct GRid);
      if ( !(SegIds) ) return OM_E_NODYNMEM;

	status =
	om$send ( msg = message VRGeneric.VRGetSupports
			(&retmsg,NbSegs,SegIds,&NbSegs),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	status =
	om$send ( msg = message VRCnrlSeg.VRGetTopo
			(&retmsg,dVect,NULL,NULL,NULL,NULL,md_env),
		targetid = SegIds[nCpNum].objid,
		targetos = SegIds[nCpNum].osnum );
	as$status ( action = RET_STATUS );

		
	status =
	om$send ( msg = message VRGeneric.VRGetIndex
			(&retmsg,&SegIds[nCpNum],&nMyIndex ),
		targetid = my_id);
	as$status ( action = RET_STATUS );
	if ( nMyIndex )
	{
		/* Swap vector */
		dVect[0] *= -1;dVect[1] *= -1;dVect[2] *= -1;
	}

	if(dCptCoor)
	{
		IGRdouble	dOrigin[3];
		/*| Return connect point coordinates */

		status =
		om$send ( msg = message VRGeneric.VRGetOrigCoor
				( &retmsg, dOrigin, md_env ),
			targetid = my_id);

		/* -- Connect point = Origin + (Delta*Sup_vect) -- */

		dCptCoor[0] = dOrigin[0] + VR_CPT_DELTA * dVect[0];
		dCptCoor[1] = dOrigin[1] + VR_CPT_DELTA * dVect[1];
		dCptCoor[2] = dOrigin[2] + VR_CPT_DELTA * dVect[2];

		/*" \t %f,%f,%f\n",dCptCoor[0],dCptCoor[1],dCptCoor[2]*/

	}/* end return CptCoor */

	if ( dConAxis )
	{
		/*| Return Connection axis */

		dConAxis[0] = dVect[0];
		dConAxis[1] = dVect[1];
		dConAxis[2] = dVect[2];

		/*" \t %f,%f,%f\n",dConAxis[0],dConAxis[1],dConAxis[2]*/

	}/* end return dConAxis */

	if ( dOrientation )
	{
		/*| Return orientation vector */
		/*|+----------------No ORIENTATION-----------------------+*/

		dOrientation [0] = dOrientation [1] = dOrientation [2] = 0.0;

		/*" \t %f,%f,%f\n",dOrientation[0],dOrientation[1],dOrientation[2]*/

	} /* end return section orientation */

  _FREE (SegIds);

return OM_S_SUCCESS;

}/* end VRGetErrGeom */

/***********************************************************************/

end implementation VRGeneric;
