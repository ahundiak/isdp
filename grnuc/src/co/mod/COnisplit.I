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

    IGRlong CO_ni_split_element(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               

Abstract
    This function splits an element at the given point
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the split point
                this point will be projected onto the element
                through GRlnproject

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    display_obj
        id of object to display located object

    p_chanselect
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to split

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    trc 03/06/87 : adapted to new include file design

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"
                                                                               
#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "exdef.h"
#include "msdef.h"

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
 *  imports
 *----------------------------------------
 */
from GRcurve    import GRsplit;
from GRgraphics import GRdisplay;


IGRlong CO_ni_split_element(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               
{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong             status;         /* return code                      */
    IGRpoint            ProjectedPoint; /* split point projcecte on element */
    struct GRparms      ProjectedParms; /* parms of projected split point   */
    GRobjid             LeftNewObjid;   /* one of two possible new objids   */
    GRobjid             RightNewObjid;  /* one of two possible new objids   */
    IGRshort            NumberNewObjects;   /* number new objects           */

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */

    _m_debug_str( "CO_ni_split_element." );


    LeftNewObjid = NULL_OBJID;
    RightNewObjid = NULL_OBJID;


    /*
     *  project the data point in the first event
     *  onto the element
     */
    status = co$project_event(
                        msg = msg,
                        event = Events[0],
                        module = ModuleInfo,
                        point = ProjectedPoint,
                        parms = &ProjectedParms,
                        p_chanselect = MyChannelStruct,
                        grid = ObjectsGrid );
    _m_check2p( status, *msg, "COnisplit - failed co$project_event." );
    _m_check2q( status, *msg );



    _m_debug(
            printf( "CO_ni_split_element - the projected split pt is:\n" );
            printf( "           x %4.2f\n", ProjectedPoint[0] );
            printf( "           y %4.2f\n", ProjectedPoint[1] );
            printf( "           z %4.2f\n", ProjectedPoint[2] );
    );


    /*
     *  send the split message to the graphics object.
     */
    status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix, 
                    mesg = message GRcurve.GRsplit( 
                        msg,
                        ModuleInfo,
                        ProjectedPoint,
                        &ProjectedParms,
                        &LeftNewObjid,
                        &RightNewObjid,
                        &NumberNewObjects ),
                    grid = ObjectsGrid,
                    p_chanselect = MyChannelStruct );

    if ( *msg == MSINARG )
    {
        /*
         *  the projected point was an end point
         */
        UI_status( "An object cannot be split at its endpoints" );
    }
    _m_check2p(
                status,
                *msg,
                "CO_ni_split_element - failed co$erase_send_draw/split" );

    /*
     *  erase the left new objid
     */
    if ( LeftNewObjid != NULL_OBJID )
    {
        status = om$send(
                    msg = message GRgraphics.GRdisplay( 
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &DisplayMode,
                        DisplayGrid ),
                    targetid = LeftNewObjid,
                    targetos = ModuleInfo->md_id.osnum );
    }


    /*
     *  erase the right new objid
     */
    if ( RightNewObjid != NULL_OBJID )
    {
        status = om$send(
                    msg = message GRgraphics.GRdisplay( 
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &DisplayMode,
                        DisplayGrid ),
                    targetid = RightNewObjid,
                    targetos = ModuleInfo->md_id.osnum );
    }

quit:
    return ( status );
}               /* end COni_split_element */
                                                                               
end implementation Root;
