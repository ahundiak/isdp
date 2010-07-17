/* $Id: VRCOProduc3i.I,v 1.2 2001/02/20 01:12:19 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRCOProduc3i.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCOProduc3i.I,v $
 *	Revision 1.2  2001/02/20 01:12:19  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  2000/02/21  20:51:50  pinnacle
# Replaced: vrco/VRCOProduc3i.I for:  by lawaddel for route
#
# Revision 1.3  1999/04/19  18:05:20  pinnacle
# Replaced: vrco/VRCOProduc3i.I for: CR179900491 by apazhani for route
#
# Revision 1.2  1998/09/24  06:18:58  pinnacle
# Replaced: vrco/VRCOProduc3i.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/08  14:26:00  pinnacle
# Replaced: vrco/VRCOProduc3i.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  21:27:24  pinnacle
# Replaced: vrco/VRCOProduc3i.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/96    tlb	    Add prototypes
 *	12/08/97    Alwin   Commented the check for Correction components.
 *      24/9/98     Reddy   Uncommented the check for HVAC correction components
 *      04/19/99    Alwin   Modified VRGetObject() to get the number of Cpts
 *			    in the located component. And to prevent the user
 *			    locating the Raceway correction components.
 *      02/14/00    law     Corrected replace component to get shape code from
 *                          db for compcode instead of from object. HVAC comp
 *                          transitions may have wrong shape codes.
 *************************************************************************/
class implementation VRCOProduct;

%safe
#include <math.h>
%endsafe
#include <stdio.h>
#include <stdlib.h>
#include "igewindow.h"
#include "igrdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "griomacros.h"
#include "godef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "VRcsdef.h"
#include "VRPid.h"
#include "acrepdef.h"
#include "ACattrib.h"
#include "vrco_pto.h"
#include "vrtools_pto.h"
#include "bsroto.h"
#include "ACrg_collect.h"
#include "VRutildef.h"

#include "vrdbgmacros.h"

#define AS_DEBUG	

from	NDnode		import	NDdisplay;
from	GRvg		import	GRputsymb,
				GRgetsymb;
from	VRGeneric	import	VRGetParams,
				VRGetPlanesOnCpt,
				VRChgParams,
				VRGetSysType,
				VRGetNumberOfCpts,
				VRGetStatus,
				VRGetInstance,
				VRSetInstance,
				VRGetSupports,
				VRGetOrigCoor;
from	VRProduct	import	VRGetSearch;
from	ACncpx		import	ACget_NV_rep;

/*************************************************************************/
method	VRGetObject ( IGRlong	*ret )
{
  IGRlong		status, msg;
  IGRshort		Type, nStatus;
  struct	GRid	SupIds[VR_MAX_CPTS];
  struct  VRGenInfo	Instance;

  SetProc( Md VRGetObject ); Begin 

  *ret = MSSUCC;

  me->ReplaceCommand     = TRUE;

  me->CompId	 = me->event1.located_object[0].located_obj;
  me->ModuleEnv	 = me->event1.located_object[0].module_info;

  /*| -- Get supplementary informations -- */
  VRGetSpecialInformations ( &msg, &me->nInitialCompTopo, &Type,
			     &me->CompId, &me->ModuleEnv);

  /*"InitialCompTopo %d, InitialCompType %d\n", me->nInitialCompTopo, Type */

  VRGetLocatedPocketMenuName ( me->Product, Type, me->nInitialCompTopo,
			       me->szActivePocketMenuName);
  /*"Pocket Menu Name = %s \n",me->szActivePocketMenuName*/


  status = 
  om$send( msg      = message NDnode.NDdisplay( 0, GRhe, &me->ModuleEnv ), 
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum,
	   senderid = my_id );
  as$status();

  /*"LocatedObjec = %d %d\n",me->CompId.objid, me->CompId.osnum*/
  /*"LocatedMdEnv = %d %d\n",me->ModuleEnv.md_id.objid, me->ModuleEnv.md_id.osnum*/ 

  /* Check whether we can replace on that component */
  if (me->ModuleEnv.md_id.osnum != me->ModuleInfo.md_id.osnum)
  {
    	*ret = VRNOT_OK;
    	ex$message( field   = ERROR_FIELD,
		    msgnumb = VR_E_RepNotAllowedOnThatComp);
	End
    	return OM_S_SUCCESS;
  }

  /*| -- retrieve Component type -- */
  status = 
  om$send( msg	     = message VRGeneric.VRGetSysType( &msg, &me->nSysType),
	   targetid  = me->CompId.objid,
	   targetos  = me->CompId.osnum,
	   senderid  = my_id );
  as$status();
  /*"Component type = %d\n",me->nSysType */

  /*| -- retrieve Component status -- */
  status =
  om$send( msg	    = message VRGeneric.VRGetStatus( &msg, &nStatus),
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum,
	   senderid = my_id );
  as$status();

  /*| GetSymb */
  status = om$send( msg      = message GRvg.GRgetsymb (&msg, &me->Symb),
		    targetid = me->CompId.objid,
		    targetos = me->CompId.osnum );
  as$status( );

/* Now this is being enabled...Now we're allowing the user to change the
   attributes(option code only) of the Correction Component also, but not
   the component itself.  Only the "option_code" of a correction component
   can be changed using this facility ... Alwin for CR179421374 */

/****************************************************************************/

/* Only for piping corrections are allowed to for modifications. That too
they can modify only piping_option_code. Any other product should rejected
at this stage itself */
if( me->Product != VR_PIPING )
   if (nStatus & VR_CORRECTION)
   {
     	*ret = VRNOT_OK;
     	ex$message( field   = ERROR_FIELD,
                    msgnumb = VR_E_RepNotAllowedOnThatComp);
	__DBGpr_com( " Component is not allowed for replacement " );
	End
     	return OM_S_SUCCESS;
   }

/****************************************************************************/
/* Above Portion is commented by  Alwin for CR179421374 */
/* Uncommented by Reddy for the sake of HVAC (TR179801407 and TR179801408)
   without affecting the fix for CR179421374 */

  __DBGpr_com( " Calling the VRGetInstance ... " );
  status = 
  om$send( msg      = message VRGeneric.VRGetInstance( &msg, &Instance ),
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum );
  as$status();

  strcpy( me->CmpAABBCCcode, Instance.szAABBCC );
  strcpy( me->CmpNumber, Instance.szNumber );
  strcpy( me->CmpNotes, Instance.szNotes );
  me->CmpOption = Instance.nOption;

  /* AAAAA added this for Raceway Enhacenment */
  status = om$send ( msg = message VRGeneric.VRGetNumberOfCpts( &msg,
                                        &me->CmpNbCpts, &me->ModuleEnv ),
            targetid = me->CompId.objid,
            targetos = me->CompId.osnum);
  as$status ();
  /* AAAAA added this for Raceway Enhacenment */

  /*| -- Retrieve Segments of Component -- */
  status = 
  om$send ( msg      = message VRGeneric.VRGetSupports( &msg,VR_MAX_CPTS,
							SupIds, 
							&me->NbSupports),
	    targetid = me->CompId.objid,
	    targetos = me->CompId.osnum);
  as$status ();

  me->SegId.objid = SupIds[0].objid;
  me->SegId.osnum = me->ModuleEnv.md_id.osnum;

  /*| -- Get Navsea representation -- */
  status = 
  om$send( msg      = message ACncpx.ACget_NV_rep( &me->cRep ),
           targetid = me->CompId.objid,
           targetos = me->CompId.osnum );
  as$status();

  /*| retrieve attribut of the located component */
  status = 
  om$send( msg	     = message VRGeneric.VRGetParams( &msg, 
						      &me->SavSysParamId,
						      &me->SavUserParamId, 
						      &me->SavMissParamId ),
	   targetid  = me->CompId.objid,
	   targetos  = me->CompId.osnum );
  as$status( msg = "Error in VRGetParams" );
  /* tr179900985 */
  /* For HVAC and RWAY, the transition objects may have the wrong shape-code */

  if(me->Product == VR_HVAC) /* just correcting HVAC for now */
  {
     IGRint locshape_code;
     IGRshort bIsTransition;
     struct        ACrg_coll       Attr;
     IGRint retmsg;
     IGRint locproduct;
     locproduct = VR_HVAC;
     /*printf("Trying to update shapecode\n"); ***/

     status = VRGetShapeFrmCompCode (  Instance.szAABBCC,
                                          &bIsTransition,
                                          &locshape_code,
                                          locproduct );
     if(bIsTransition)
     {
        Attr.desc.value.att_exp = (double) locshape_code;
        strcpy(Attr.name, VR_N_SHAPE_IN);
        Attr.desc.type = AC_ATTRIB_DOUBLE;
        __DBGpr_com("modified collection here");
        status = VRModifyCollection( &retmsg,
                  VR_UPDATE_COLL, VR_RG_COLL,
                  NULL, &Attr,1,&me->SavSysParamId);
     }

  }

  VRGetParamBoxClone( &msg, &me->SavSysParamId, &me->SysParamId);
  VRGetParamBoxClone( &msg, &me->SavUserParamId, &me->UsrParamId);

  if( me->SavMissParamId.objid != NULL_OBJID )
	VRGetParamBoxClone ( &msg, &me->SavMissParamId, &me->MissParamId);
  else me->MissParamId.objid = NULL_OBJID;

  VRBlankMessage ();

End
return	OM_S_SUCCESS;
} /* end method VRGetObject */

/* ==================================================================== */

method dynamics (IGRint dynamics; IGRint *sts)
{
  IGRint		i;
  IGRdouble		Origin[3],XAxis[3], YAxis[3];

  *sts = MSSUCC;

  for( i=0; i<3; i++ )
  {
	XAxis[i]  = me->CmpMatrix[i*4];
	YAxis[i]  = me->CmpMatrix[(i*4)+1];
	Origin[i] = me->CmpMatrix[(i*4)+3];
  }  

  if (dynamics == DYNTEE)
  	VRorient ( me->Product, Origin, XAxis, YAxis, 
		   &me->ActiveDisplay, &me->ModuleEnv);

  return OM_S_SUCCESS;

} /* end method dynamics */

/* ====================================================================	*/

method VRComputeOrientationTee  (IGRlong *ret)
{  
  IGRlong		status, msg;
  IGRint		i;
  IGRdouble		dXAxis[3], dYAxis[3];
  IGRdouble		origin[3];
  BSrc			bsretcode;
  IGRdouble		view_scale, vect_size;
  IGRlong 		which_error, bytes_returned;
  struct win_var_list	var_list[2];

  *ret = MSSUCC;

  status = dp$erase_hilite ( msg   = &msg,
			     osnum = me->ModuleEnv.md_id.osnum);

  /*| -- Initialise the two axis of the tee -- */  
  for( i=0; i<3; i++ )
  {
	dXAxis[i] = me->CmpMatrix[(i*4)];
	dYAxis[i] = me->CmpMatrix[(i*4)+1];
	origin[i] = 0;
  }
 
  /*| -- Switch Axis of these components -- */
  if( me->mytype == VR_HVACOFFSET_INSERTION   || me->mytype == VR_RWAYOFFSET_INSERTION  ||
      me->mytype == VR_HVACSPLIT_INSERTION    || me->mytype == VR_RWAYSPLIT_INSERTION   ||
      me->mytype == VR_HVACREDUCER_INSERTION  || me->mytype == VR_RWAYREDUCER_INSERTION ||
      me->mytype == VR_HVACTRANSITION_INSERTION )
  {
	IGRboolean BooleanVar;

	BooleanVar = TRUE;   	
	BSroto( &bsretcode, origin, dXAxis, &BooleanVar, &me->Angle, dYAxis, dYAxis);
  } 		

  var_list[0].var            = VVOL_VIEWPORT_SCALE;
  var_list[0].var_ptr        = ( char *) &view_scale;  
  var_list[0].num_bytes      = sizeof( IGRdouble );
  var_list[0].bytes_returned = &bytes_returned;
  var_list[1].var 	     = END_PARAM;

  status = dp$inq_set_gragad(	msg          	= &msg,
				osnum 	 	= me->event1.event.button.osnum,
				gragad_objid 	= me->event1.event.button.objid,
				which_error  	= &which_error,
				var_list     	= var_list );
  as$status();

  vect_size = 40 / view_scale;

  for( i=0; i<3; i++ )
  {
  	dXAxis[i] = dXAxis[i] * vect_size + me->dSplitPoint[i];
  	dYAxis[i] = dYAxis[i] * vect_size + me->dSplitPoint[i];
  }

  VRDisplayHvacOrientTee( me->dSplitPoint, dXAxis, dYAxis, &me->ActiveDisplay,
			   &me->ModuleEnv);

return OM_S_SUCCESS;

}
/* ====================================================================	*/
method VRRetrieveOldComponent (IGRlong *ret)
{
  IGRlong		msg, status;
  IGRchar		NewSearch[50], OldSearch[50];
  IGRint		NbParamList=0;
  struct VRGenInfo	Instance;
  struct GRid		NullId, NewSysParamId, NewUsrParamId, NewMissParamId;
  struct GRid		OldSysParamId, OldUsrParamId, OldMissParamId;
  struct VRSelectAttr   ParamList;

  *ret = MSSUCC;

  NullId.objid = NULL_OBJID;
  NullId.osnum = me->ModuleEnv.md_id.osnum;
  OldSearch[0] = NewSearch[0] = '\0';

  status =
  om$send( msg = message VRGeneric.VRGetNumberOfCpts( &msg, &me->CmpNbCpts,
						      &me->ModuleEnv ),
	   senderid = NULL_OBJID,
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum);
  as$status();

  /*| ----- UnDisplay component Evaluated ----- */
  VRUndisplayComponent ( &me->CmpId, &me->ModuleEnv );
  VRUndisplayComponent ( &me->CompId, &me->ModuleEnv );

  /*| --- Check if it is the same component with different params --- */
  status = 
  om$send( msg      = message VRProduct.VRGetSearch( &msg, &NullId, 0, 
						     &NbParamList, &ParamList,
						     OldSearch, &me->ModuleEnv ),
	   senderid = NULL_OBJID,
	   targetid = me->CompId.objid, 
	   targetos = me->CompId.osnum );
  as$status();
  /*"OldSearch = <%s> \n",OldSearch*/

  /*| --- Check if it is the same component with different params --- */
  status = 
  om$send( msg      = message VRProduct.VRGetSearch( &msg, &NullId, 0, 
						     &NbParamList, &ParamList,
						     NewSearch, &me->ModuleEnv ),
	   senderid = NULL_OBJID,
	   targetid = me->CmpId.objid, 
	   targetos = me->CmpId.osnum );
  as$status();
  /*"NewSearch = <%s> \n",NewSearch*/

  if( !strcmp( OldSearch, NewSearch ))
  {
  	/* -- Orient with specified amgle -- */
  	VR$OrientComp( 	p_retmsg = &msg,
		 	p_CmpId  = &me->CompId,
		 	Justif   = me->CptNum,
		 	Matrix   = me->CmpMatrix,
		 	p_MdEnv  = &me->ModuleEnv
	             );  

	status =
        om$send( msg = message VRGeneric.VRGetParams(&msg, &OldSysParamId, 
							   &OldUsrParamId, 
							   &OldMissParamId),
		 senderid = NULL_OBJID,
                 targetid = me->CompId.objid,
		 targetos = me->CompId.osnum);
        as$status();

	status =
        om$send( msg = message VRGeneric.VRGetParams(&msg, &NewSysParamId, 
							   &NewUsrParamId, 
							   &NewMissParamId),
		 senderid = NULL_OBJID,
                 targetid = me->CmpId.objid,
		 targetos = me->CmpId.osnum);
        as$status();

	/*| --- Change params to give the new one to the located component --- */
	status =
        om$send( msg = message VRGeneric.VRChgParams(&msg, &NewSysParamId, 
							   &NewUsrParamId, 
							   &NewMissParamId),
		 senderid = NULL_OBJID,
                 targetid = me->CompId.objid,
		 targetos = me->CompId.osnum);
        as$status();
  
	status =
	om$send( msg = message VRGeneric.VRChgParams(&msg, &OldSysParamId, 
							   &OldUsrParamId, 
							   &OldMissParamId),
		 senderid = NULL_OBJID,
                 targetid = me->CmpId.objid,
		 targetos = me->CmpId.osnum);
        as$status();

  	VRGetParamBoxClone( &msg, &OldSysParamId, &me->SysParamId);
  	VRGetParamBoxClone( &msg, &OldUsrParamId, &me->UsrParamId);
	if( NewMissParamId.objid != NULL_OBJID )
  		VRGetParamBoxClone( &msg, &OldMissParamId, &me->MissParamId);
	
	/* --- Compute in rigth order  --- */
	status = VRUpdateGeometry ( &msg, NULL, &me->CmpId, &me->ModuleEnv);

	status =
	om$send( msg = message VRGeneric.VRGetInstance( &msg, &Instance ),
		 senderid = NULL_OBJID,
                 targetid = me->CompId.objid,
		 targetos = me->CompId.osnum);
        as$status();
	
	strcpy( Instance.szAABBCC, me->CmpAABBCCcode );
	strcpy( Instance.szNumber, me->CmpNumber );
	strcpy( Instance.szNotes, me->CmpNotes );
	Instance.cNoMtoFlg = me->CmpNoMtoFlag;
	Instance.nOption   = me->CmpOption;

	status =
        om$send( msg = message VRGeneric.VRSetInstance( &msg, &Instance ),
		 senderid = NULL_OBJID,
                 targetid = me->CompId.objid,
		 targetos = me->CompId.osnum);
        as$status();

	NullId.objid     = me->CompId.objid;
	me->CompId.objid = me->CmpId.objid;
 	me->CmpId.objid  = NullId.objid;

	*ret = VRALL_OK;
  }
  else
  {
  	/*| ----- Disconnect comp Evaluated and reconnect old one ----- */
  	status = VRReConnect( 	&msg, &me->CmpId, &me->CompId, NULL, 
				me->CmpNbCpts, 0, NULL, &me->ModuleEnv 
		      	    );
  }

  /*| ----- Display New component ----- */
  status = 
  om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleEnv ),
	   targetid = me->CompId.objid, 
	   targetos = me->CompId.osnum );
  as$status();

  /*| ----- Display Form with first component parameters ----- */
  status =
  om$send( msg           = message VRCOProduct.VRFillForm( &msg, &me->CompId,
                                        		   &me->SavSysParamId, 
							   &me->ModuleEnv ),
           targetid = my_id);
  as$status( );
  
  nd$exec_batch();

  status = 
  om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleEnv ), 
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum,
	   senderid = my_id );
  as$status();

  me->CompId.objid = NULL_OBJID;

  return OM_S_SUCCESS;
} /* end method VRRetrieveOldComponent */

end implementation VRCOProduct;
