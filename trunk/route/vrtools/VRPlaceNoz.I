class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include <stdio.h>
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRstructs.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "parametric.h"

#include "AS_status.h"
#define AS_DEBUG

from NDnode	import	NDplace;
from GRgraphics	import	GRdelete;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
IGRint VRPlaceNozz( msg, ComponentId, CompStr, RefId, p_CnstList, md_env )
			       
IGRlong 		*msg ;         /* O : Return code, MSSUCC or MSFAIL.            */
struct GRid		*ComponentId ; /* I : Component to Place.                       */
struct VRGenInfo	*CompStr;      /* I : Temporary                                 */
struct GRid		*RefId;	       /* I : Referencial to be attached to Id  	*/ 
struct GRvg_construct   *p_CnstList;   /* I : construction list                         */
struct GRmd_env 	*md_env;

/*.VRPlaceNozz */
{
	IGRint		status;
	struct GRas	assoc_list;

	/*"md_env 	= %d %d\n", md_env->md_id.objid, md_env->md_id.osnum */
	/*"RefId 	= %d %d \n",RefId->objid,RefId->osnum */

	/*| update assoc construction list */
	assoc_list.as_attr        = ( IGRchar * ) CompStr;
	assoc_list.num_parents    = 1;
	assoc_list.go_objid.objid = NULL_OBJID;
	assoc_list.parents        = RefId;


	/* KLUDGE WAIT FOR RIGHT ID TO BE SPECIFIED */
	CompStr->GraphicsId.objid = NULL_OBJID;

	/* -- Place the Nozzle -- */

        /*"ComponentId     = %d %d\n", ComponentId->objid, ComponentId->osnum */

	status = 
	om$send( msg	   = message NDnode.NDplace( &assoc_list, md_env, 
						    ( IGRchar * ) p_CnstList),
			  senderid = NULL_OBJID,
			  targetid = ComponentId->objid,
			  targetos = ComponentId->osnum ) ;
	as$status ();

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

}/* end VRplace */

/*********************************************************************

	VRGetEquiShort : Function to get the equivallent short
			 value of a string given by the database
			 ( for the Nozzle placement ).

********************************************************************/

IGRint VRGetEquiShort( StringTab, ShortTab, SizeTab, String, Short )
			       
IGRchar		*StringTab;
IGRshort 	*ShortTab;
IGRint		SizeTab;
IGRchar		String[9];
IGRshort	*Short;

/*.VRGetEquiShort */
{
  IGRint	i;
  
  *Short = 0;
  for( i=0; i<SizeTab; i++ )
  {
	if( StringTab[i*9] )
	{
		if( !strcmp( &StringTab[i*9], String ))
			*Short = ShortTab[i];
	}
  }
  /*"Equi Short = %d\n",*Short*/

  return OM_S_SUCCESS;
}
end implementation Root;
