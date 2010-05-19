/* I/VDS
 *
 * File:         ~VDS/VDS--/.I
 *
 * Description:
 *      This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset.
 *
 * History:
 *      06/10/94        Chaya V. Rao
 *
 */
/*============================================================================*/

class implementation VDgrset;

#include <stdio.h>

#include "nddef.h"
#include "exmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from      NDnode     import     NDget_objects, ASreturn_go;

/** #define   DEBUG  1 **/

/*============================================================================*//* function VDcheck_if_pretend- This function checks if the objects is a      */
/*                                                              pretend       */
/*============================================================================*/

int VDcheck_if_pretend( buffer, count )

IGRchar		*buffer;/* i/o - buffer of objects */
IGRint          *count; /* number of objects       */
{
long			status;
int                     val,myind, count1,
                        p, objcount;
IGRchar                 cname[100], prtname[100];
struct  GRid            *prtobjs = NULL, actobjs;
IGRshort                matrix_type;
IGRdouble               *matrix = NULL;

        val = 1;
	if (( !buffer ) || ( !count )) {
                 val = 0; 
                 goto wrapup;
        }
        count1 = *count;
        for( myind = 0; myind < count1; myind++ ){

             status =
             om$get_classname( osnum =((OM_S_OBJECT_LINKAGE *)buffer)[myind].osnum,
                               objid =((OM_S_OBJECT_LINKAGE *)buffer)[myind].S_objid,
                               classname =  prtname );

             if ((om$is_ancestry_valid(subclassname  = prtname,
                                       superclassname= "VDpretendin")
                   == OM_S_SUCCESS)){           

                             status =
                             om$send(msg = message NDnode.NDget_objects
                                           ( ND_ROOT | ND_IN_BUF,
                                             NULL,
                                             0,
                                             &prtobjs,
                                             0,
                                             OM_K_MAXINT,
                                             &objcount),
                                    senderid = NULL_OBJID,
                                    targetid =( (OM_S_OBJECT_LINKAGE *)buffer)[myind].S_objid,
                                    targetos =( (OM_S_OBJECT_LINKAGE *)buffer)[myind].osnum);

                            ( (OM_S_OBJECT_LINKAGE *)buffer)[myind].S_objid = 
                                                            prtobjs[0].objid;
                            ( (OM_S_OBJECT_LINKAGE *)buffer)[myind].osnum =
                                                            prtobjs[0].osnum;

                            for( p = 0; p < objcount; p++ ){

                              om$get_classname( osnum = prtobjs[p].osnum,
                                                objid = prtobjs[p].objid,
                                                classname = cname );
                              if (om$is_ancestry_valid(subclassname  = cname,
                                                 superclassname=  "ASsourcein")
                                == OM_S_SUCCESS
                              || om$is_ancestry_valid(subclassname  = cname,
                                                 superclassname=  "ACpretendin")
                                == OM_S_SUCCESS
                              || om$is_ancestry_valid(subclassname  = cname,
                                                 superclassname=  "ACpretend")
                                == OM_S_SUCCESS
                              || om$is_ancestry_valid(subclassname  = cname,
                                                 superclassname=  "ASsource")
                                == OM_S_SUCCESS ){
                                   status =
                                om$send(msg = message NDnode.ASreturn_go(
                                                               &actobjs,
                                                               &matrix_type,
                                                               matrix),
                                     senderid= NULL_OBJID, 
                                     targetid= prtobjs[p].objid,
                                     targetos= prtobjs[p].osnum ) ;

                                ((OM_S_OBJECT_LINKAGE *)buffer)[myind].S_objid = actobjs.objid;
                                ((OM_S_OBJECT_LINKAGE *)buffer)[myind].osnum   = actobjs.osnum;
                             }

                          }
                     }
            }

wrapup:
  return( val );

}

/*============================================================================*/

end implementation VDgrset;
