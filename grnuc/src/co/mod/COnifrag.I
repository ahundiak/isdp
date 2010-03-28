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

IGRlong CO_ni_fragment_element(
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
    This function fragments an element at the given point
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the fragment point
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
        object to fragment

    [7m[1mNOTE[0m
            this parameter is invalid

Status returns

        om return codes            
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

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "exdef.h"
#include "dp.h"

#include "igrmacros.h"
#include "comiscmac.h"




/*----------------------------------------
 *  imports
 *----------------------------------------
 */
from GRvg       import GRfragment;



IGRlong CO_ni_fragment_element(
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

    IGRlong
                status;         /* return code                      */
    
    IGRuint
                NumberObjectsFound;
    
    OM_S_OBJECT_LINKAGE
                ChannelLinkage[1];

    struct GRid
                IsoGrid;


    _m_debug_str( "CO_ni_fragment_element." );

    if ( MyChannelStruct == NULL )
    {
        _m_debug_str( "CO_ni_fragment_element - MyChannelStruct is NULL" );
        return( OM_E_INVARG );
    }


    /*
     *  find out who is the Go that I am connected to
     */
    status = om$get_channel_objects(
                                objid = my_id,
                                p_chanselect = MyChannelStruct,
                                list = ChannelLinkage,
                                size = 1,
                                count = &NumberObjectsFound );

    /*
     *  only possible error is overflow of the list. ( OM_I_LISTOVFLOW )
     *  this is an error since there should be only one 
     *  object on the other side of the channel.
     */
    if ( status != OM_I_LISTOVFLOW )
    {
        *msg = MSSUCC;
        IsoGrid.objid = ChannelLinkage[0].S_objid;
        IsoGrid.osnum = ChannelLinkage[0].osnum;
    }
    _m_checkp( status, "COnifragment - failed get_chan_obj." );
    _m_checkq( status );
    _m_print_grid( "COnifragment - LCcmd_iso grid", &IsoGrid );


    /*
     *  send the fragment message to the graphics object.
     */
    status = om$send(
                    msg = message GRvg.GRfragment(
                        msg,
                        ModuleInfo,
                        &IsoGrid,
                        ModuleInfo ),
                    p_chanselect = MyChannelStruct );

    _m_check2p(
                status,
                *msg,
                "CO_ni_fragment_element - failed GRvg.GRfragment" );

quit:
    return ( status );
}               /* end COni_fragment_element */
                                                                               
end implementation Root;
