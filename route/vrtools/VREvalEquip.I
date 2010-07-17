/* $Id: VREvalEquip.I,v 1.1.1.1 2001/01/04 21:13:11 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VREvalEquip.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREvalEquip.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:11  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/04/05  14:02:58  pinnacle
# Replaced: vrtools/VREvalEquip.I for:  by r240_int for route240
#
# Revision 1.4  1996/04/04  18:52:22  pinnacle
# Replaced: vrtools/VREvalEquip.I for:  by ashankar for route240
#
# Revision 1.3  1996/04/04  16:19:24  pinnacle
# Replaced: vrtools/VREvalEquip.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/18  00:30:26  pinnacle
# Replaced: vrtools/VREvalEquip.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *				Change VREvaluateEquip to ANSII style
 *
 *************************************************************************/
class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "igr.h"
#include "msdef.h"
#include <stdio.h>
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "AS_status.h"
#include "vrtools_pto.h"
#include "VDmem.h"
#define AS_DEBUG

extern GRclassid	OPP_VREquipment_class_id;

from VRGeneric  import	VREvaluate;
from GRgraphics	import	GRdelete,
			GRaddwrng;
from ACncpx	import	ACchange_feet;
from GRvg	import	GRputsymb;

/* Internal buffer storing the missing parameters of evaluated component */
%safe
static	IGRint			StatMissingSize = 0;
static	struct ACrg_coll 	*StatMissings = NULL;
%endsafe

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint VREvaluateEquip( 
	IGRlong 	*msg ,	/* O : Return code, MSSUCC or MSFAIL.   */
	IGRchar		*EquiNumber,	/* I : equipment number 	*/
	struct GRsymbology *Symb,	/* I : symbology		*/
	IGRchar		cRep,		/* I : Representation		*/
	struct GRid	*StatParamId,	/* I : Active parameters.      */
	struct GRid	*DynParamId,	/* I : User parameters.        */
	struct GRid	*MissingParamId,/* I : Missing Parameters  */
	struct GRid	*EquipId,	/* I : Component to evaluate. */
	IGRint		*NbMissingExp,	/* I : Number of missing parameters */
	struct ACrg_coll **Missings,	/* I/O : Returns the pointer to 
						the static array containing 
						the missing parameters
						description */
	struct GRmd_env *md_env	 	/* I : module env */
	)
/*.VREvaluateEquip */
{
	IGRint			status,
				NbMissingTemp = 0 ;
	IGRlong			retmsg;
	IGRchar			EqpNo[21];
	IGRchar 		**MissingNames;
	struct	ret_struct	*MissingStr;
	IGRboolean		bIsNew;
	GRclassid		CompClass;
	struct	VRGenInfo	Instance;
	struct	GRid		GraphicId;

	GraphicId.objid = NULL_OBJID;
	GraphicId.osnum = md_env->md_id.osnum;

	strcpy( EqpNo, EquiNumber );

	/*" Objectid %d specified for evaluation\n", EquipId->objid */

	bIsNew = (EquipId->objid == NULL_OBJID);

	/* -- If it is a component creation ==> Create the object with a default class -- */

	if ( bIsNew )	
	{
		CompClass = OPP_VREquipment_class_id;

		/* -- Create component object -- */

    		EquipId->osnum = md_env->md_id.osnum;
    		status = om$construct( 	classid = CompClass,
      		           		p_objid = &EquipId->objid,
		           		osnum   = EquipId->osnum );
    		as$status( action = RET_STATUS );
	}/* end object creation */

	/*| -- Set what is known in Instance -- */
	strcpy( Instance.szAABBCC, "" );
	strcpy( Instance.szNotes, "" );
	Instance.nOption 		 	  = 1;
	Instance.nStatus 		 	  = 0;	
	Instance.cNoMtoFlg 		 	  = '\0';
        Instance.cRep 			 	  = cRep;
	Instance.nNbTopo		 	  = 0;
	Instance.nJustif			  = VR_CENTER_JUST;
	Instance.Attr.Comp.Orientation.nPriIndex  = -1;
	Instance.Attr.Comp.Orientation.dPrimary	  = 0.0;
	Instance.Attr.Comp.Orientation.nSecIndex  = -1;
	Instance.Attr.Comp.Orientation.dSecondary = 0.0;
	Instance.Attr.Comp.Desc.nItemNum 	  = 0;
	Instance.Attr.Equip.EquipNumber	          = EqpNo;

	/* -- Evaluate the component with specified parameters -- */

	/*"StatParamId = %d %d\n",StatParamId->objid, StatParamId->osnum*/
	/*"DynParamId  = %d %d\n",DynParamId->objid, DynParamId->osnum*/
	/*"MissParamId = %d %d\n",MissingParamId->objid, MissingParamId->osnum*/

	NbMissingTemp = 0;
	status = 
	om$send( msg	   = message VRGeneric.VREvaluate(	msg,
								&Instance,
								StatParamId,
								DynParamId,
								MissingParamId,
								NULL,
								NULL,
								&NbMissingTemp,
								&MissingNames,
								&MissingStr,
								&GraphicId,
								md_env ),
			  senderid = NULL_OBJID,
			  targetid = EquipId->objid,
			  targetos = EquipId->osnum ) ;

	if ( !(status&1) ) goto wrapup ;

	/*| -- Give symbology to the component-- */
  	if ( Symb && EquipId->objid != NULL_OBJID )
	{
		/*"color  : %d\n", Symb->display_attr.color*/
		/*"weight : %d\n", Symb->display_attr.weight*/
		/*"style  : %d\n", Symb->display_attr.style*/

  		status = om$send( msg 	   = message GRvg.GRputsymb( &retmsg,
								     Symb ),
			  	  senderid = NULL_OBJID,
	 	 	  	  targetid = EquipId->objid,
	 	 	  	  targetos = EquipId->osnum ) ;
		as$status ( );
	}


	/*| -- Treat missing parameters if pointer is given -- */

	if ( NbMissingTemp != 0 )
	{
		/*" %d MISSING PARAMETERS \n", NbMissingTemp */

	   if ( Missings )
	   {
		if ( NbMissingTemp > StatMissingSize )
		{
			if ( StatMissingSize == 0 )
			{
				if( StatMissings != NULL )
				{
					/** Free previous memory **/
					_FREE( StatMissings );
					StatMissings = NULL;
				}

				/*| First allocation */
				StatMissings =
				(struct ACrg_coll *) _MALLOC ( NbMissingTemp, struct ACrg_coll );
			}/* end first allocation */
			else
			{
				/*| Reallocation */
				StatMissings = 
				(struct ACrg_coll * ) _REALLOC ( StatMissings, NbMissingTemp, struct ACrg_coll );
			} /* end of reallocation */

			if ( !StatMissings ) { StatMissingSize = 0; return OM_E_NODYNMEM;}

			StatMissingSize = NbMissingTemp;

		}/* end allocation missing buffer */

		/*| fill up the Missings array */

		status = VRExtractExpStr( &retmsg,
					  NbMissingTemp,
					  MissingNames,
					  MissingStr,
					  NbMissingExp,
					  StatMissings ) ;
					  
		as$status( action = GOTO_VALUE, value = wrapup ) ;

		if( NbMissingTemp != *NbMissingExp ) 
		{
			/*"NbMissingTemp = %d \n",NbMissingTemp*/
			/*"NbMissingExp  = %d \n",*NbMissingExp*/

			/*|ERROR : Bad number of expression returned*/
			goto  wrapup ;
		}

		*Missings = StatMissings;

		*msg = MSSUCC;
		return OM_S_SUCCESS;

	   }/* end return missings */

	   *msg = MSFAIL;
	   return OM_E_ABORT;

	}/* end missing parameters treatment */

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

wrapup :
	/* -- On Error restore previous steps -- */


	if ( bIsNew &&  EquipId->objid != NULL_OBJID )
	{
		/*| ERROR -> Delete component which failed */

		status =
		om$send ( msg = message GRgraphics.GRdelete ( &retmsg, md_env ),
			  senderid = NULL_OBJID,
			  targetid = EquipId->objid,
			  targetos = EquipId->osnum ) ;
		as$status ();

		EquipId->objid		= NULL_OBJID;

		StatParamId->objid	= NULL_OBJID;
		DynParamId->objid	= NULL_OBJID;
	}/* end delete created component */

	*msg = MSFAIL;
	return OM_E_ABORT;

}/* end VREvaluateEquip */

end implementation Root;

