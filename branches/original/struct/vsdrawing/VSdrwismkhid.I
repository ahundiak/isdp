/* $Id $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwismkhid.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	10/14/00	Rama Rao	File Creation
 * -------------------------------------------------------------------*/

class implementation VSplate ;

#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "OMmacros.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsvedef.h"
#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbeam.h"
#include "vsdbgmacros.h"

extern GRclassid OPP_VSstfBeam_class_id;

/*----------------------------------------------------------------------------*/
int VSdrwIsMarkHidden( msg, inp, xData, hidden )

long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*hidden ; {

	IGRlong			sts;
	struct GRobj_env	plateOE, stiffOE;

	__DBGpr_obj( "Mark to draw", *(inp->elmId) ) ;
	__DBGpr_mat( "Mark mx", inp->elmEnv->_MATRIX ) ;

	*hidden = FALSE ;

	vdobj$GetTemplate( objID      = inp->elmId,
			   nth        = 1,
			   templateOE = &plateOE );
	__DBGpr_obj( "Parent Plate Object", plateOE.obj_id );

        vdobj$GetTemplate( objID      = inp->elmId,
                           nth        = 2,
                           templateOE = &stiffOE );
        __DBGpr_obj( "Parent Stiffener Object", stiffOE.obj_id );

	if( !vs$is_ancestry_valid( object  = &stiffOE.obj_id,
				   classid = OPP_VSstfBeam_class_id ) )
        {
            sts = VSdrwIsBeamHiddenByPlate( msg,
                                            &stiffOE.obj_id,
                                            inp->elmEnv,
                                            &plateOE.obj_id,
                                            inp->elmEnv,
                                            inp->drwInfo.viewVector,
                                            hidden ) ;
            __CheckRC( sts, *msg, "VSdrwIsBeamHiddenByPlate", wrapup ) ;
        }
	else
	{
	   IGRlong          rc;
           IGRpoint         spt, ept;
           IGRvector        vec;
           IGRmatrix        SecMat;
	   VSpartAttr       part ;     /* My part attributes  */
           VSbeamAttr       myAttr ;   /* My beam attributes  */

	   stiffOE.mod_env = *(inp->elmEnv );

	   part.Iwant = VS_m_Symmetry ;
           part.specific   = (void *) &myAttr ;
	   sts = om$send( msg      = message GRvg.GRgetattr( msg, &part ),
			  senderid = stiffOE._objid,
                          targetid = stiffOE._objid,
			  targetos = stiffOE._osnum   ) ;
           __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

           sts = VSevalBeamCS( msg, &stiffOE, 0, VS_e_BOT_LEFT , SecMat );
	   __CheckRC( sts, *msg, "VSevalBeamCS", wrapup ) ;

           spt[0] = SecMat[3]; spt[1] = SecMat[7]; spt[2] = SecMat[11];
           __DBGpr_vec( "Start Point", spt );

           sts = VSevalBeamCS( msg, &stiffOE, 0, VS_e_UPP_LEFT , SecMat );
	   __CheckRC( sts, *msg, "VSevalBeamCS", wrapup ) ;

           ept[0] = SecMat[3]; ept[1] = SecMat[7]; ept[2] = SecMat[11];
           __DBGpr_vec( "End Point", ept );

	   __DBGpr_int( "Symmetry", myAttr.sym );

	   if( ( myAttr.sym == VS_e_No_Symm ) || ( myAttr.sym == VS_e_Y_Symm ) )
                 BSmkvec( &rc, vec, spt, ept ) ;
	   else  
		BSmkvec( &rc, vec, ept, spt );

           BSnorvec( &rc, vec );

           __DBGpr_vec( "Vector", vec );
           __DBGpr_vec( "View Vector", inp->drwInfo.viewVector );

           if( BSdotp( &rc, (double *) inp->drwInfo.viewVector, vec ) < 0. )
           {
               __DBGpr_com( "Marking is HIDDEN" ) ;
               *hidden = TRUE ;
           } else {
               __DBGpr_com( "Marking is NOT HIDDEN" ) ;
               *hidden = FALSE ;
           }
        }
	__DBGpr_int( "Is Marking hidden ?", *hidden ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSdrwIsMarkHidden */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
