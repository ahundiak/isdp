/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/cutLine/VLwatLinei.I
 *
 * Description:
 *              This file is to get the object defination of a
 *              water line object.
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLwatLinei.I
# Revision 1.1  1995/09/18  16:31:24  pinnacle
# Created: src/cutLine by Rama Rao for loft.
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/20/95        Rama Rao        creation date
 *
 * -------------------------------------------------------------------*/

class implementation VLwatLine;

#include "vds.h"
#include "vlmsg.h"

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjWaterLine;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLwatLine;

