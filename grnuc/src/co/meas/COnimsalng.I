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

    IGRlong CO_ni_measure_length_along_element(
                msg,
                Events,
                ModuleInfo,
                Length,
                Units,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    IGRdouble            *Length;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               

Abstract
    This function measures the length along an element
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the from point
        event[1] is the to point
        event[2] is the direction point for closed elements

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    Length
        value of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used

    p_chanselect
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to measure

Status returns

    om error codes

History
    trc 03/27/87 : created

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"


#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"




from GRcurve    import GRarclength;
from GRgraphics import GRlnproject;
from GRvg       import GRgeomprops;



/*----------------------------------------
 *  CO_ni_measure_length_along_element
 *----------------------------------------
 */
IGRlong CO_ni_measure_length_along_element(
                msg,
                Events,
                ModuleInfo,
                Length,
                Units,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    IGRdouble            *Length;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               
{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong             status;        /* return code                      */
    IGRpoint            StartPoint;    /* start point on the curve         */
    IGRpoint            MiddlePoint;   /* another point                    */
    IGRpoint            EndPoint;      /* end point on the curve           */
    IGRdouble           BorePoints[6]; /* points to store boreline         */
    struct IGRline      BoreLine;      /* boreline for apparent project    */
    IGRpoint            DummyPoint1;
    IGRdouble           DummyDouble;
    IGRboolean          b_status;
    struct GRprops      Properties;
    struct GRparms      StartParms;
    struct GRparms      MiddleParms;
    struct GRparms      EndParms;

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    IGRmatrix           local_matrix;
    IGRshort            local_matrix_type;
 

    _m_debug_str( "CO_ni_measure_length_along_element." );


  status = COcompute_acs_lcl_matrix(msg,
				    ModuleInfo->md_env.matrix_type,
				    ModuleInfo->md_env.matrix,  
				    &local_matrix_type,
                                    local_matrix);


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
                    Events[0],
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
                        StartPoint,
                        &DummyDouble,
                        &StartParms ),
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
                        StartPoint,
                        &DummyDouble,
                        &StartParms ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, *msg, "COnimsalong - failed first project" );


    /*
     *  use brad's CObrln to find the boreline
     *  so as to do a boreline project
     *  to set up the FROM point boreline
     */
    b_status = CObrln( 
                    msg,
                    &my_id,
                    Events[1],
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
                        EndPoint,
                        &DummyDouble,
                        &EndParms ),
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
                        EndPoint,
                        &DummyDouble,
                        &EndParms ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, *msg, "COnimsalong - failed second project" );


    /*
     *  get the geometric properties of the element
     */
    if ( MyChannelStruct != NULL )
    {
        /*
         *  send by channel
         */
        status = om$send(
                    msg = message GRvg.GRgeomprops(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &Properties ),
                     p_chanselect = MyChannelStruct );
    }
    else
    {
        /*
         *  send by object
         */
        status = om$send(
                    msg = message GRvg.GRgeomprops(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &Properties ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, *msg, "COnimsalong - failed GRgeomprops" );



    /*
     *  if the element is:
     *                     closed, then Point2 = event[2]
     *                     open, then Point2 = Point1
     */
    if ( Properties.phy_closed )
    {
        _m_debug( "COnimsalong - element is closed" );

        /*
         *  build a boreline with the last point, and project it onto
         *  the element
         */


        /*
         *  use brad's CObrln to find the boreline
         *  so as to do a boreline project
         *  to set up the FROM point boreline
         */
        b_status = CObrln( 
                    msg,
                    &my_id,
                    Events[2],
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
                            MiddlePoint,
                            &DummyDouble,
                            &MiddleParms ),
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
                            MiddlePoint,
                            &DummyDouble,
                            &MiddleParms ),
                        targetid = ObjectsGrid->objid,
                        targetos = ObjectsGrid->osnum );
        }
        _m_check2p( status, *msg, "COnimsalong - failed third project" );
    }
    else /* element is open */
    {
        _m_debug_str( "COnimsalong - element is open" );

        MiddlePoint[0] = StartPoint[0];
        MiddlePoint[1] = StartPoint[1];
        MiddlePoint[2] = StartPoint[2];
        MiddleParms = StartParms;
    }



    /*
     *     measure the element
     */
    if ( MyChannelStruct != NULL )
    {
        /*
         *  send by channel
         */
        status = om$send(
                    msg = message GRcurve.GRarclength(
                        msg,
                        &local_matrix_type,
                        local_matrix,
                        StartPoint,
                        MiddlePoint,
                        EndPoint,
                        &StartParms,
                        &MiddleParms,
                        &EndParms,
                        Length ),
                    p_chanselect = MyChannelStruct );
    }
    else
    {
        /*
         *  send by object
         */
        status = om$send(
                    msg = message GRcurve.GRarclength(
                        msg,
                        &local_matrix_type,
                        local_matrix,
                        StartPoint,
                        MiddlePoint,
                        EndPoint,
                        &StartParms,
                        &MiddleParms,
                        &EndParms,
                        Length ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p(
                status,
                *msg,
                "CO_ni_measure_length_along_element - failed GRarclength" );


    /*
     *  we are measuring distance
     */
    strncpy( Units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );

    return( status );
}

end implementation Root;
