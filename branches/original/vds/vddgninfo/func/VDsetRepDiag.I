/* $Id: VDsetRepDiag.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddgninfo/func/VDsetRepDiag.I
 *
 * Description:
 *      those functions are used to set representation to diagram(P&ID) mode 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsetRepDiag.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/01/28  20:32:38  pinnacle
# Replaced: vddgninfo/func/VDsetRepDiag.I for:  by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	06/01/97	yzhu		create
 ***************************************************************************/

class implementation Root;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMparameters.h"
#include "OMmacros.h"

#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vddgndef.h"
#include "v_dbgmacros.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "acrepmacros.h"
#include "AS_debug.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vderrmacros.h"

#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "VDSglobals.h"

%safe
static int  PreRepres = 0 ; 
%endsafe

/*---------------------------------------------------------------------- */
from  ACrg_collect	import  ACget_attribute_at_index;
from  NDmacro		import  ACgive_structure;

long VDsetRepToDiag( msg  )
long                    *msg;                   /* Return message       */
{
long                    status;
struct VDSsymb 		vds_symb;
struct GRid    		symb_id;
int                     diagCtl;     

       SetProc(VDsetRepToDiag); Begin


       diagCtl = -1;
       *msg = OM_S_SUCCESS;
       status = OM_S_SUCCESS ;

       __DBGpr_int( " PreRepres", PreRepres); 

       /* get previous active rep */
       status = vd$symbology(      msg         = msg,
                                symb_id     = &symb_id,
                                symb        = &vds_symb );
       __DBGpr_int( " before representation", vds_symb.representation); 

       /* check if diagCtl = 1 */
       status = VDgetDiagCtlPar( msg, &diagCtl  ); 
       if ( !(status&*msg&1) || diagCtl == -1) {
          
          *msg = MSFAIL;
          goto wrapup;
       }
       if ( diagCtl == 1) {
        __DBGpr_com( " set Active Representation to pid "); 
        PreRepres = vds_symb.representation;
        vds_symb.representation = 6;
        status = vd$symbology(    msg         = msg,
                                operation   = STORE,
                                symb_id     = &symb_id,
                                symb        = &vds_symb );
         if ( !(status&*msg&1) ) {
          *msg = MSFAIL;
         }
       }
       else if ( vds_symb.representation == 6) {  /* yzhu 1/28/98 */
        __DBGpr_com( " set Active Representation to PreRepres "); 
         vds_symb.representation = PreRepres; 

         status = vd$symbology(    msg         = msg,
                                operation   = STORE,
                                symb_id     = &symb_id,
                                symb        = &vds_symb );
         if ( !(status&*msg&1) ) {
          *msg = MSFAIL;
         }

       }
       /* get modified active rep */
       status = vd$symbology(   msg         = msg,
                                symb_id     = &symb_id,
                                symb        = &vds_symb );
       __DBGpr_int( " after representation", vds_symb.representation); 

wrapup:
   End
   return status;
} 


end implementation Root;

