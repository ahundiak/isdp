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

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "griodef.h"
#include "msdef.h"
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




/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import GRcopy, GRdelete;


%safe
extern    IGRint    DY2ptmodify();
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




IGRlong  DYrb2ptmodify( 
                FunctionIndex,
                events,
                LocateContext,
                MyId,
                my_os,
                MyChannelStruct,
                ObjectsGrid )

    IGRlong                     FunctionIndex;
    struct GRevent             *events[];
    struct GRmd_env            *LocateContext;   
    GRobjid                     MyId;
    GRspacenum                  my_os;
    OM_S_CHANSELECT            *MyChannelStruct;
    struct GRid                *ObjectsGrid;

{
    IGRlong
                status = 1,
                msg,
                NumberOfBytes,
                BytesReceived;

    struct ModifyElementInfo
                DYinfo;


    *events[1] = *events[0];


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

    if (ObjectsGrid) /*DLB - 10/06/91 - Check for NULL ptr*/
      DYinfo.ObjectsGrid       = *ObjectsGrid;
    else
    {
      DYinfo.ObjectsGrid.objid = NULL_OBJID;
      DYinfo.ObjectsGrid.osnum = 0;
    }

    DYinfo.ClonesGrid.osnum  = DYinfo.NewContext.md_id.osnum;
    DYinfo.CloneExists       = FALSE;
    DYinfo.events            = events;
    DYinfo.MyId              = MyId;
    DYinfo.my_os             = my_os;
    DYinfo.FunctionIndex     = FunctionIndex;
    DYinfo.LocateContext     = *LocateContext;

    _m_debug_str( "DYrb2ptmodify - Going to call DPdynamics." );

    dp$dynamics( 
            dyn_fun = DY2ptmodify,
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
                targetid = DYinfo.ClonesGrid.objid,
                targetos = DYinfo.ClonesGrid.osnum );         

        _m_check2p( status, msg, "DYrb2ptmodify - error deleting clone." );
    }

quit:
    return( status );
}           




/*----------------------------------------
 *    routine actually called by DPdynamics
 *----------------------------------------
 */
IGRint  DY2ptmodify(
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
                    targetid = DYinfo->ClonesGrid.objid,
                    targetos = DYinfo->ClonesGrid.osnum );

        DYinfo->CloneExists = FALSE;

        _m_check2p( status, msg, "DY2ptmodify - error deleting clone." );
        _m_check2q( status, msg );
    }


    /*
     *  clone the mutha
     */
    if ( DYinfo->MyChannelStruct == NULL )
    {
        status = om$send(
                    msg = message GRgraphics.GRcopy( 
                        &msg,
                        &DYinfo->LocateContext,
                        &DYinfo->NewContext,
                        &DYinfo->ClonesGrid.objid ),
                    senderid = DYinfo->MyId,
                    targetid = DYinfo->ObjectsGrid.objid,
                    targetos = DYinfo->ObjectsGrid.osnum );
    }
    else
    {
        status = om$send(
                    msg = message GRgraphics.GRcopy( 
                        &msg,
                        &DYinfo->LocateContext,
                        &DYinfo->NewContext,
                        &DYinfo->ClonesGrid.objid ),
                    senderid = DYinfo->MyId,
                    p_chanselect = DYinfo->MyChannelStruct );
    }
    _m_check2p( status, msg, "DY2ptmodify - failed GRcopy" );
    _m_check2q( status, msg );


    /*
     *  record the clone's birth certificate
     */
    DYinfo->CloneExists = TRUE;



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
                grid = &DYinfo->ClonesGrid );


    *num_buffers = 0;
    *objects = &DYinfo->ClonesGrid;

quit:
    *num_objects = status & 1;
    return(  status );
}                                     

end implementation Root;

