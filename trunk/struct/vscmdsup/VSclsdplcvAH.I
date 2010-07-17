/*
	I/STRUCT
*/
class implementation GRvg ;

#include <stdio.h>
#include "nddef.h"
#include "msdef.h"
#include "msmacros.h"
#include "growner.h"
#include "vsdef.h"
#include "vscmd.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "LCptlocact.h"
#include "vsacthrproto.h"
#include "vsgrenvproto.h"

extern OMuword	OPP_GRcurve_class_id ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSisAClosedPlanarCurve_PFAH( curve, PFargs )

struct GRobj_env	*curve ;
VSfenceArgs		*PFargs ; {

	int	rc ;

	if( vs$is_ancestry_valid(	object	= &curve->_grid,
					classid = OPP_GRcurve_class_id ) ) {
		
		long			sts,
					msg ;
		struct GRprops		props ;

		sts = om$send(	msg	= message GRvg.GRgeomprops(
							&msg,
							&curve->_matrix_type,
							curve->_matrix,
							&props ),
				senderid = curve->_objid,
				targetid = curve->_objid,
				targetos = curve->_osnum ) ;

		rc = ( sts & 1 & msg )
		     && props.phy_closed
		     && props.planar ? TRUE : FALSE ;
	} else rc = TRUE ;

	return rc ;

} /* VSisAClosedPlanarCurve_PFAH */
/*----------------------------------------------------------------------------*/
int VSisAClosedPlanarCurve_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	int			sts, rc , size;
        int                     i, locCount;
	struct GRobj_env	curve, *VSlocObjs ;
        IGRlong                 retSts;

	if( *action == start_transition || *action == end_transition ) {
		rc = LCptlocact( (char *) LCargs->stack, entry, args, action ) ;
		return rc ;
	}

	curve._grid	= entry->located_obj ;
	curve.mod_env	= entry->module_info ;

	rc = VSisAClosedPlanarCurve_PFAH( &curve, (VSfenceArgs *) NULL ) ;

	if( !rc && LCargs->rejectSts != MS_NO_MSG ) {
		ex$message( msgnumb	  = LCargs->rejectSts,
			    field	  = ERROR_FIELD,
			    justification = CENTER_JUS ) ;
		VS_Wait_timer( 40 ) ;
	}

	if( vs$is_ancestry_valid(	object	= &curve._grid,
					classid = OPP_GRcurve_class_id ) ) {

          VDgetLocatedObjs( &VSlocObjs, &locCount); 

          if((VSlocObjs!=NULL) && (locCount > 0))
          {
            __DBGpr_int("locateCount ",locCount);
            for(i=0; i<locCount; i++) 
              __DBGpr_obj(" VSlocObjs ", VSlocObjs[i].obj_id);
            for(i=0; i<locCount; i++)
            {
              sts = retSts = 0;
              sts =  VScheckCurveonFeature(curve.obj_id, VSlocObjs[i].obj_id, &retSts);
              if(sts&retSts&1)
              {
                rc = 0; //RELOCATE
                __DBGpr_com("CURVE already PROCESSED");
                UI_status("CURVE already PROCESSED");
                break;
              }
            }
          }
        }
	rc = rc ? LCptlocact( (char *) LCargs->stack, entry, args, action )
		: LC_RELOCATE ;

	return rc ;

} /* VSisAClosedPlanarCurve_LCAH */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

