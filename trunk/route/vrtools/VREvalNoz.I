/* $Id: VREvalNoz.I,v 1.1.1.1 2001/01/04 21:13:11 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VREvalNoz.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREvalNoz.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:11  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/12  09:05:02  pinnacle
# Replaced: vrtools/VREvalNoz.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/05  14:02:02  pinnacle
# Replaced: vrtools/VREvalNoz.I for:  by r240_int for route240
#
# Revision 1.5  1996/04/04  18:55:48  pinnacle
# Replaced: vrtools/VREvalNoz.I for:  by ashankar for route240
#
# Revision 1.4  1996/04/04  16:20:58  pinnacle
# Replaced: vrtools/VREvalNoz.I for:  by ashankar for route240
#
# Revision 1.3  1996/04/04  15:43:12  pinnacle
# Replaced: vrtools/VREvalNoz.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/18  00:30:32  pinnacle
# Replaced: vrtools/VREvalNoz.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb		Add prototypes
	04/12/98   Alwin        Change the display properties of the Evaluated
				Nozzle. TR179525895
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

extern GRclassid	OPP_VRPNozz_class_id,
			OPP_VRHNozz_class_id,
			OPP_VRRNozz_class_id;

from VRGeneric	import	VREvaluate;
from GRgraphics	import	GRdelete, GRchgprops;

/* Internal buffer storing the missing parameters of evaluated component */
%safe
static	IGRint			StatMissingSize = 0;
static	struct ACrg_coll 	*StatMissings = NULL;
%endsafe

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint VREvaluateNozz( msg, Product, Instance, SysParamId, UserParamId,
		       MissingParamId, ComponentId, NbCpts,
		       NbMissingExp, Missings, md_env )
			       
IGRlong 		*msg ;           /* O : Return code, MSSUCC or MSFAIL.   */
IGRint			Product;         /* I : Product the component belongs to */
struct VRGenInfo	*Instance ;      /* I : Instance structure.              */
struct GRid		*SysParamId,     /* I : Active parameters.               */
			*UserParamId,    /* I : User parameters.                 */
			*MissingParamId; /* I : Missing Parameters		 */
struct GRid		*ComponentId ;   /* I : Component to evaluate.           */
IGRint			*NbCpts;         /* O : Number of connect points.        */
IGRint			*NbMissingExp;   /* I : Number of missing parameters     */
struct ACrg_coll	**Missings;      /* I/O : Returns the pointer to the static array
						containing the missing parameters
						description */
struct GRmd_env 	*md_env ; 
/*.VREvaluateNozz */
{
	IGRint			status,
				NbMissingTemp = 0 ;
	IGRlong			retmsg;
	IGRchar 		**MissingNames ;
	struct ret_struct	*MissingStr ;
	IGRboolean		bIsNew;
	GRclassid		CompClass; 	/* Component Class Id */

	/*" Objectid %d specified for evaluation\n", ComponentId->objid */

	bIsNew = (ComponentId->objid == NULL_OBJID);

	/* -- If it is a component creation ==> Create the object with a default class -- */

	if ( bIsNew )
	{
		/* -- Initialize nozzle's class -- */
		switch (Product)
		{
		case VR_PIPING :
			CompClass = OPP_VRPNozz_class_id;
			break;
		case VR_HVAC :
			CompClass = OPP_VRHNozz_class_id;
			break;
		case VR_CABLING :
			CompClass = OPP_VRRNozz_class_id;
			break;
		default :
			printf ( "UNKNOWN PRODUCT : %d\n", Product );
			return OM_E_INVARG;

	 	}/* end switch on product */

		/* -- Create component object -- */

    		ComponentId->osnum = md_env->md_id.osnum;
    		status = om$construct( 	classid = CompClass,
      		           		p_objid = &ComponentId->objid,
		           		osnum   = ComponentId->osnum );
    		as$status( action = RET_STATUS );

	}/* end object creation */

	/* -- Evaluate the component with specified parameters -- */

	/*"SysParamId     = %d %d\n",SysParamId->objid, SysParamId->osnum*/
	/*"UserParamId    = %d %d\n",UserParamId->objid, UserParamId->osnum*/
	/*"MissingParamId = %d %d\n",MissingParamId->objid, MissingParamId->osnum*/

	NbMissingTemp = 0;
	status = om$send( msg	   = message VRGeneric.VREvaluate(
								msg,
								Instance,
								SysParamId,
								UserParamId,
								MissingParamId,
								NbCpts,
								NULL,
								&NbMissingTemp,
								&MissingNames,
								&MissingStr,
								NULL,
								md_env ),
			  senderid = NULL_OBJID,
			  targetid = ComponentId->objid,
			  targetos = ComponentId->osnum ) ;

	if ( !(status&1) ) goto wrapup ;

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
				if ( StatMissings != NULL )
				{
					/** Free previous memory **/
					_FREE( StatMissings );
					StatMissings = NULL;
				}

				/*| First allocation */
				StatMissings =
				(struct ACrg_coll *) _MALLOC ( NbMissingTemp, struct ACrg_coll);
			}/* end first allocation */
			else
			{
				/*| Reallocation */
				StatMissings = 
				(struct ACrg_coll * ) _REALLOC ( StatMissings, NbMissingTemp, struct ACrg_coll);
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

        /* Change the display properties of the Evaluated Nozzle. So, that
        the Phantom nozzle won't appear in the screen. Alwin for TR179525895 */
        if( ComponentId->objid != NULL_OBJID )
        {
          IGRshort  action, props;
          IGRlong   retcode;
 
            props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
            action = 0;
            status = om$send ( msg = message GRgraphics.GRchgprops(
                                                    &retcode,
                                                    &action,
                                                    &props ),
                               senderid = NULL_OBJID,
                               targetid = ComponentId->objid,
                               targetos = ComponentId->osnum );
            as$status();
        }

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

wrapup :
	/* -- On Error restore previous steps -- */

	if ( bIsNew &&  ComponentId->objid != NULL_OBJID )
	{
		/*| ERROR -> Delete component which failed */

		status =
		om$send ( msg = message GRgraphics.GRdelete ( &retmsg, md_env ),
			  senderid = NULL_OBJID,
			  targetid = ComponentId->objid,
			  targetos = ComponentId->osnum ) ;
		as$status ();

		ComponentId->objid = NULL_OBJID;

		SysParamId->objid     = NULL_OBJID;
		UserParamId->objid    = NULL_OBJID;
		MissingParamId->objid = NULL_OBJID;

	}/* end delete created component */

	*msg = MSFAIL;
	return OM_E_ABORT;

}/* end VREvaluate */

end implementation Root;

