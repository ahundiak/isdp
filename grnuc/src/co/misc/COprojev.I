/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/* 
Name

IGRlong COproject_event(
                msg,
                Event,
                ModuleInfo,
                ProjectdPoint,
                ProjectedParms,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Event;
    struct GRmd_env      *ModuleInfo;
    IGRpoint              ProjectedPoint;
    struct GRparms       *ProjectedParms;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               

Abstract
    This function projects the data point in the event onto the element,
    and returns the point and the parms.
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the from point
        event[1] is the to point

    module
        context of located object

    ProjectedPoint
        the projected point on the element

    ProjectedParms
        geometric parameters of the point on the element

    my_id
        object id of calling object, or at least some object

    MyChannelStruct
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to modify

Status returns
    om return codes

History
    trc 06/04/87 : created file

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"


#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "msdef.h"
#include "madef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"

#include "igrmacros.h"
#include "comiscmac.h"


/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import GRlnproject;





/*----------------------------------------
 *  COproject_event
 *----------------------------------------
 */
IGRlong COproject_event(
                msg,
                Event,
                ModuleInfo,
                ProjectedPoint,
                ProjectedParms,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Event;
    struct GRmd_env      *ModuleInfo;
    IGRpoint              ProjectedPoint;
    struct GRparms       *ProjectedParms;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong             status;         /* return code                  */
    IGRdouble           BorePoints[6];  /* points to store boreline         */
    struct IGRline      BoreLine;       /* boreline for apparent project    */
    IGRpoint            DummyPoint1;
    IGRpoint            DummyPoint2;
    IGRdouble           DummyDouble1;
    struct GRparms      DummyParms;
    IGRdouble          *PointPtr;
    struct GRparms     *ParmsPtr;
    IGRboolean          b_status;

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    /*
     *  initialize variables
     */
    status = OM_S_SUCCESS;
    b_status = TRUE;


    if ( ProjectedPoint == NULL )
    {
        PointPtr = DummyPoint2;
    }
    else
    {
        PointPtr = ProjectedPoint;
    }

    if ( ProjectedParms == NULL )
    {
        ParmsPtr = &DummyParms;
    }
    else
    {
        ParmsPtr = ProjectedParms;
    }



    /*
     *  set boreline for apparent project
     */
    BoreLine.point1 = &( BorePoints[0] );
    BoreLine.point2 = &( BorePoints[3] );


    /*
     *  use brad's CObrln to find the boreline
     *  so as to do a boreline project
     *  to set up the FROM point boreline
     */
    b_status = CObrln( 
                    msg,
                    &my_id,
                    Event,
                    &BoreLine );
                                                                 

    /*
     *  send to the graphic object to project
     *  the accept point onto the graphic object
     *  
     *  GOAL : find the ProjectedParms for the input point
     */
    if ( MyChannelStruct != NULL )
    {
        /*
         *  send by channel
         */
        status = om$send(
                    msg = message GRgraphics.GRlnproject(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &BoreLine,
                        DummyPoint1,
                        PointPtr,
                        &DummyDouble1,
                        ParmsPtr ),
                     p_chanselect = MyChannelStruct );
    }
    else
    {
        /*
         *  send by object
         */
        status = om$send(
                    msg = message GRgraphics.GRlnproject(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &BoreLine,
                        DummyPoint1,
                        PointPtr,
                        &DummyDouble1,
                        ParmsPtr ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }

    return( status );
}

end implementation Root;
