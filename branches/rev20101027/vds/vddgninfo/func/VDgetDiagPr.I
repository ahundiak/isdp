/* $Id: VDgetDiagPr.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddgninfo/func/VDgetDiagPr.I
 *
 * Description:
 *      those functions are used to get diagram control parameter 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgetDiagPr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/07/08  16:12:20  pinnacle
# Created: vddgninfo/func/VDgetDiagPr.I by yzhu for vds
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
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vddgndef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "vderrmacros.h"
#include "v_drwproto.h"
#include "v_drw.h"
#include "v_drwmacros.h"

/*---------------------------------------------------------------------- */
from  ACrg_collect	import  ACget_attribute_at_index;
from  NDmacro		import  ACgive_structure;
/*-----------------------------------------------------------------------*/
/*  *diagCtl: =-1, collector not exist; =0, control=OFF; =1 control = on */ 
/*-----------------------------------------------------------------------*/
long VDgetDiagCtlPar( msg, diagCtl  )
long                    *msg;                   /* Return message       */
int                     *diagCtl;               /* (OUT) diagram control*/
{
long                    status;
IGRint                  rc ,
                        dirIndex;
struct  ret_struct      retStr ;
GRname                  name;
struct GRid             collId;
struct GRmd_env         mdEnv ;


       SetProc(VDgetDiagCtlPar); Begin

       dirIndex = -1;
       *diagCtl = -1;
       *msg = OM_S_SUCCESS; 
       status = OM_S_SUCCESS ;

       /*
        * Get the collector.
        */
       collId.objid = NULL_OBJID ;
       status =
       VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
       if( ! (status&*msg&1)){
                *msg = MSFAIL;
       }
       else {
           /* get diagram control parameter */
           strcpy( name, "pidStatus"  );

           status = _VD_SEND_OBJN(       collId,
                NDmacro.ACgive_structure( &rc, &dirIndex, name,
                                                  &retStr, &mdEnv ));
           if(( ! (status&rc&1 )) ||
               ( !strcmp (retStr.var.text_st.text_string, VD_UNDEFINED_STR) ))
           {
                *msg = MSFAIL;
           }
           else   {
                *diagCtl = atoi( retStr.var.text_st.text_string) ;
           }

        }

        __DBGpr_int( "diagCtl", *diagCtl);

     End
     return status;
}


end implementation Root;

