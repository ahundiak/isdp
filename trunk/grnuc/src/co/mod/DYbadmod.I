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

class implementation Root;

/*
 *  this dynamics routine is a bad version of the DY2ptmodify
 *  dynamics routine.  what makes it bad is that it assumes
 *  that the object coming in is on a channel.  This routine
 *  is necessary to handle methods that change classes and object
 *  id's.  The channel is necessary to hold onto the clone.
 */

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "grdpbdef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dpstruct.h"
#include "coniarray.h"
#include "dp.h"

#include "igrmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"




/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import GRcopy, GRdelete;


%safe
extern    IGRint    DYbadmodify();
%endsafe



struct ModifyElementInfo 
{ 
    IGRlong               FunctionIndex;
    struct GRmd_env       LocateContext;
    struct GRmd_env       NewContext;
    struct GRevent      **events;
    struct GRid           ObjectsGrid;
    struct GRid           ClonesGrid;
    IGRboolean            CloneExists;
    OM_S_CHANSELECT      *MyChannelStruct;
    GRobjid               MyId;
    GRspacenum            my_os;
};




IGRlong DYrbbadmodify( 
                FunctionIndex,
                Events,
                LocateContext,
                MyId,
                my_os,
                MyChannelStruct,
                ObjectsGrid )

    IGRlong                     FunctionIndex;
    struct GRevent             *Events[];
    struct GRmd_env            *LocateContext;   
    GRobjid                     MyId;
    GRspacenum                  my_os;
    OM_S_CHANSELECT            *MyChannelStruct;
    struct GRid                *ObjectsGrid;

{
/* BV - BEGINNING OF VARIABLE LIST, USED FOR SEARCHING */

    IGRlong                    status;
    IGRlong                    msg;
    struct GRid                LocalObjectsGrid;
    struct ModifyElementInfo   DYinfo;
    OM_S_CHANSELECT            OtherChannelStruct;
    IGRlong                    NumberOfObjectssFound;
    OM_S_OBJECT_LINKAGE        ChannelLinkage[1];
    IGRlong                    NumberOfBytes;
    IGRlong                    BytesReceived;

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */
                                /* linkage to objects on channel */

    _m_debug_str( "DYrbbadmodify." );

    *Events[1] = *Events[0];


    status = om$make_chanselect(
                            channame = "GRconnector.to_owners",
                            p_chanselect = &OtherChannelStruct );
    _m_checkp( status, "DYrbbadmodify - failed make_chanselect" );
    _m_checkq( status );


    /*
     *  get the object id of the real object on the channel.
     */
    LocalObjectsGrid.objid = NULL_OBJID;
    status = lc$get_channel_objects(
                        objid = MyId,
                        p_chanselect = MyChannelStruct,
                        list = ChannelLinkage,
                        size = 1,
                        count = &NumberOfObjectssFound );
    _m_checkp( status, "DYrbbadmodify - failed in get_chan_obj" );
    _m_checkq( status );

    LocalObjectsGrid.objid = ChannelLinkage[0].S_objid;
    LocalObjectsGrid.osnum = ChannelLinkage[0].osnum;
    _m_print_grid( "DYrbbadmodify - object to modify", &LocalObjectsGrid );


    /*
     *  get the object off of the channel
     */
    status = lc$wild_disconnect( objid = MyId,
				 p_chanselect = MyChannelStruct );
    _m_checkp( status, "DYrbbadmodify - failed wild disconnect" );
    _m_checkq( status );


    /*
     *  get the data set env stuff from the DPB
     */
    NumberOfBytes = sizeof( DYinfo.NewContext );
    gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &DYinfo.NewContext,
                nret = &BytesReceived );
    _m_checkp( msg, "DYrb2ptmodify - gr$get_module_env." );
    _m_checkq( msg );
    DYinfo.NewContext.md_id.objid = NULL_OBJID;



    /*
     *  set up the dynamic info data
     */
    DYinfo.MyChannelStruct   = MyChannelStruct;
    DYinfo.ObjectsGrid       = LocalObjectsGrid;
    DYinfo.ClonesGrid.osnum  = DYinfo.NewContext.md_id.osnum;
    DYinfo.CloneExists       = FALSE;
    DYinfo.events            = Events;
    DYinfo.MyId              = MyId;
    DYinfo.my_os             = my_os;
    DYinfo.FunctionIndex     = FunctionIndex;
    DYinfo.LocateContext     = *LocateContext;

    _m_debug_str( "DYrbbadmodify - Going to call DPdynamics." );

    dp$dynamics( 
            dyn_fun = DYbadmodify,
            information = &DYinfo );


    if ( DYinfo.CloneExists )
    {
        /*
         *  delete the stupid sob
         */
        status = om$send(
                msg = message GRgraphics.GRdelete( 
                    &msg,
                    &DYinfo.NewContext ),
                senderid = MyId,
                p_chanselect = MyChannelStruct );

        _m_check2p( status, msg, "DYrbbadmodify - error deleting clone." );
    }


quit:
    /*
     *  reconnect the original object onto the channel
     */
    if ( LocalObjectsGrid.objid != NULL_OBJID )
    {
	status = lc$connect( objid = MyId,
	                     p_chanselect = MyChannelStruct,
			     go_objid = LocalObjectsGrid.objid,
			     go_osnum = LocalObjectsGrid.osnum  );

        _m_checkp( status, "DYrbbadmodify - failed Root.connect" );

    }

    return( OM_S_SUCCESS );
}           




/*----------------------------------------
 *    routine actually called by DPdynamics
 *----------------------------------------
 */
IGRint  DYbadmodify(
                DYinfo,
                Cursor,
                ViewMatrix,
                objects,
                num_objects,
                buffers,
                num_buffers,
                in_dum1,
                in_dum2,
                in_dum3,
                out_dum1,
                out_dum2,
                out_dum3 )
        
    struct  ModifyElementInfo       *DYinfo;
    struct  EX_button               *Cursor;
    IGRdouble                       *ViewMatrix;
    struct  GRid                    **objects;
    IGRint                          *num_objects;
    struct DPele_header             **buffers;
    IGRint                          *num_buffers;
    IGRchar                         *in_dum1, *in_dum2, *in_dum3;
    IGRchar                         **out_dum1, **out_dum2, **out_dum3;

{
    IGRlong                         status;
    IGRlong                         msg;        
    OM_S_CHANSELECT            OtherChannelStruct;
    IGRlong                         NumberOfObjectssFound;
    OM_S_OBJECT_LINKAGE             ChannelLinkage[1];
                            /* linkage to objects on channel */

    status = om$make_chanselect(
                            channame = "GRconnector.to_owners",
                            p_chanselect = &OtherChannelStruct );
    _m_checkp( status, "DYbadmodify - failed make_chanselect" );
    _m_checkq( status );


    /*
     *  if the clone exists delete it
     */
    if ( DYinfo->CloneExists )
    {
        /*
         *  delete the stupid sob
         */
        status = om$send(
                    msg = message GRgraphics.GRdelete( 
                        &msg,
                        &DYinfo->NewContext ),
                    senderid = DYinfo->MyId,
                    p_chanselect = DYinfo->MyChannelStruct );

        DYinfo->CloneExists = FALSE;

        _m_check2p( status, msg, "DYbadmodify - error deleting clone." );
    }


    /*
     *  clone the mutha
     */
    status = om$send(
                    msg = message GRgraphics.GRcopy( 
                        &msg,
                        &DYinfo->LocateContext,
                        &DYinfo->NewContext,
                        &DYinfo->ClonesGrid.objid ),
                    senderid = DYinfo->MyId,
                    targetid = DYinfo->ObjectsGrid.objid,
                    targetos = DYinfo->ObjectsGrid.osnum );
    _m_check2p( status, msg, "DYbadmodify - failed GRcopy" );
    _m_check2q( status, msg );


    /*
     *  record the clone's birth certificate
     */
    DYinfo->CloneExists = TRUE;


    /*
     *  put the clone on a channel
     */
    status = lc$connect( objid = DYinfo->MyId,
	                 p_chanselect = DYinfo->MyChannelStruct,
			 go_objid = DYinfo->ClonesGrid.objid,
			 go_osnum = DYinfo->ClonesGrid.osnum  );
                        
    _m_checkp( status, "DYbadmodify - failed to connect clone to channel" );
    _m_checkq( status );


    /*
     *  set up the to event
     */
    DYinfo->events[1]->event.button = *Cursor;


    /*
     *  call the mod function of the function index
     */
    status = co$ni_modify_func(
                func_index = DYinfo->FunctionIndex,
                msg = &msg,
                events = DYinfo->events,
                module = &DYinfo->NewContext,
                cob_id = DYinfo->MyId,
                p_chanselect = DYinfo->MyChannelStruct );


    /*
     *  get the clone's id from the channel
     */
    status = lc$get_channel_objects(
                        objid = DYinfo->MyId,
                        p_chanselect = DYinfo->MyChannelStruct,
                        list = ChannelLinkage,
                        size = 1,
                        count = &NumberOfObjectssFound );

    _m_checkp( status, "DYbadmodify failed in get_chan_obj" );
    _m_checkq( status );

    DYinfo->ClonesGrid.objid = ChannelLinkage[0].S_objid;
    DYinfo->ClonesGrid.osnum = ChannelLinkage[0].osnum;



    *num_buffers = 0;
    *objects = &DYinfo->ClonesGrid;

quit:

    _m_checkp( status, "DYbadmodify - failed modify func." );
    *num_objects = status & 1;
    return(  status );
}                                     

end implementation Root;

