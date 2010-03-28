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
#include "comiscmac.h"



/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import GRcopy, GRdelete;
from GRcurve import GRptextend;


%safe
extern    IGRint    DYextmodify();
extern    IGRlong   DYrbextend();
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


IGRint  LCdyn_rbextend(LCobj, LCevent, Add_Info)
struct GRid *LCobj;
struct GRevent *LCevent;
struct GRmd_env *Add_Info;
{
  IGRlong status = OM_S_SUCCESS;

  status = DYrbextend(0,	/* unused */
		      &LCevent,
		      Add_Info,
		      NULL_OBJID,
		      OM_Gw_current_OS,
		      NULL,
		      LCobj);

  return status;
}


IGRlong  DYrbextend( 
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


    /*
     *  get the data set env stuff from the DPB
     */
    NumberOfBytes = sizeof( DYinfo.NewContext );
    gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &DYinfo.NewContext,
                nret = &BytesReceived );
    _m_checkp( msg, "DYrbextend - gr$get_module_env." );
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

    _m_debug_str( "DYrbextend - Going to call DPdynamics." );

    dp$dynamics( 
            dyn_fun = DYextmodify,
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

        _m_check2p( status, msg, "DYrbextend - error deleting clone." );
    }

quit:
    return( status );
}


/*----------------------------------------
 *    routine actually called by DPdynamics
 *----------------------------------------
 */
IGRint  DYextmodify(
                DYinfo,
                Point,
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
    struct  EX_button               *Point;
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
    IGRpoint                        FromPoint, ToPoint;
    struct GRparms                  DummyParms;

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

        _m_check2p( status, msg, "DYextmodify - error deleting clone." );
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

    _m_check2p( status, msg, "DYextmodify - failed GRcopy" );
    _m_check2q( status, msg );

    /*
     *  record the clone's birth certificate
     */
    DYinfo->CloneExists = TRUE;

    /*
     *  set up from point and to point
     */
    status = co$project_event( msg = &msg,
                               event = DYinfo->events[0],
                               module = &DYinfo->NewContext,
                               cob_id = DYinfo->MyId,
                               grid = &DYinfo->ClonesGrid,
                               parms = &DummyParms,
			       point = FromPoint );

    ToPoint[0] = Point->x;
    ToPoint[1] = Point->y;
    ToPoint[2] = Point->z;

    /*
     *  call the modification method
     */
    status = om$send( msg = message GRcurve.GRptextend( &msg,
                                                        &DYinfo->NewContext,
                                                        FromPoint,
                                                        ToPoint,
                                                        FromPoint ),
		      senderid = DYinfo->MyId,
                      targetid = DYinfo->ClonesGrid.objid,
		      targetos = DYinfo->ClonesGrid.osnum );

    *num_buffers = 0;
    *objects = &DYinfo->ClonesGrid;

quit:
    *num_objects = status & 1;
    return(  status );
}

end implementation Root;

