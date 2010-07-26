/* #######################    APOGEE COMPILED   ######################## */

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
#include "msdef.h"
#include "OMerrordef.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "madef.h"
#include "coniarray.h"
#include "dp.h"
#include "codef.h"
#include "igrmacros.h"

/*
 *  Options for GRpladdpts indicating closure
 *    option = 0 means closed when first and last points are equal
 *    option = 1 means  open  when first and last points are equal
 */
#define CLOSED  (0)
#define OPEN    (1)

/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import GRcopy, GRdelete;


%safe
extern    IGRint    DYadd_pt_modify();
%endsafe


struct AddPtElementInfo 
{ 
    struct GRmd_env       Context;
    struct GRevent      **events;
    struct GRid           ObjectGrid;
    struct GRid           CloneGrid;
    IGRboolean            CloneExists;
    OM_S_CHANSELECT      *MyChannelStruct;
    GRobjid               MyId;
    GRspacenum            my_os;
};



#argsused
IGRlong  DYrb_add_pt_modify( 
                mytype,
                events,
                Context,
                MyId,
                my_os,
                MyChannelStruct,
                ObjectGrid )

    IGRlong                     mytype;
    struct GRevent             *events[];
    struct GRmd_env            *Context;   
    GRobjid                     MyId;
    GRspacenum                  my_os;
    OM_S_CHANSELECT            *MyChannelStruct;
    struct GRid                *ObjectGrid;

{
    IGRlong                    status;
    IGRlong                    msg;
    struct AddPtElementInfo    DYinfo;


    /*
     *  set up the dynamic info data
     */
    DYinfo.MyChannelStruct   =  MyChannelStruct;
    if ( ObjectGrid )   /*  Sun-port    ...Mohan    */
    DYinfo.ObjectGrid        = *ObjectGrid;
    DYinfo.CloneGrid.osnum   =  Context->md_id.osnum;
    DYinfo.CloneExists       =  FALSE;
    DYinfo.events            =  events;
    DYinfo.MyId              =  MyId;
    DYinfo.my_os             =  my_os;

    DYinfo.Context     = *Context;
    DYinfo.Context.md_id.objid = NULL_OBJID;

    _m_debug_str( "DYrb_add_pt_modify - Going to call DPdynamics." );

    dp$dynamics( 
            dyn_fun = DYadd_pt_modify,
            information = &DYinfo );


    if ( DYinfo.CloneExists )
    {
        /*
         *  delete the incredibly intellegent dod
         */
        status = om$send(
                msg = message GRgraphics.GRdelete( 
                      &msg,
                      &DYinfo.Context ),
                senderid = MyId,
                targetid = DYinfo.CloneGrid.objid,
                targetos = DYinfo.CloneGrid.osnum );         

        _m_check2p( status, msg, "DYrb_add_pt_modify - error deleting clone." );
    }
    return(1);
}           


/*
 * -------------------------------------------
 *    routine actually called by DPdynamics
 * -------------------------------------------
 */
#argsused
IGRint  DYadd_pt_modify(
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
        
    struct  AddPtElementInfo        *DYinfo;
    struct  EX_button               *Cursor;
    IGRdouble                       *ViewMatrix;
    struct  GRid                    **objects;
    IGRint                          *num_objects;
    struct DPele_header             **buffers;
    IGRint                          *num_buffers;
    IGRchar                         *in_dum1, *in_dum2, *in_dum3;
    IGRchar                         **out_dum1, **out_dum2, **out_dum3;

{

    IGRshort                        NumberOfPoints = 1;

    IGRlong                         status;
    IGRlong                         msg;        

    IGRpoint                        next_vertex; 

    GRobjid                         NewObjid;


    /*
     *  if the clone exists delete it
     */

    if ( DYinfo->CloneExists )
    {
        /*
         *  delete the incredible cretin
         */
        status = om$send(
                    msg = message GRgraphics.GRdelete( 
                        &msg,
                        &DYinfo->Context ),
                    senderid = DYinfo->MyId,
                    targetid = DYinfo->CloneGrid.objid,
                    targetos = DYinfo->CloneGrid.osnum );

        DYinfo->CloneExists = FALSE;

        _m_check2p( status, msg, "DYadd_pt_modify - error deleting clone." );
    }

    /*
     *  clone the fatha
     */
    if ( DYinfo->MyChannelStruct == NULL )
    {
        status = om$send(
                    msg = message GRgraphics.GRcopy( 
                        &msg,
                        &DYinfo->Context,
                        &DYinfo->Context,
                        &DYinfo->CloneGrid.objid ),
                    senderid = DYinfo->MyId,
                    targetid = DYinfo->ObjectGrid.objid,
                    targetos = DYinfo->ObjectGrid.osnum );
    }
    else
    {
        status = om$send(
                    msg = message GRgraphics.GRcopy( 
                        &msg,
                        &DYinfo->Context,
                        &DYinfo->Context,
                        &DYinfo->CloneGrid.objid ),
                    senderid = DYinfo->MyId,
                    p_chanselect = DYinfo->MyChannelStruct );
    }
    _m_check2p( status, msg, "DYadd_pt_modify - failed GRcopy" );
    _m_check2q( status, msg );


    /*
     *  record the clone's debut
     */
    DYinfo->CloneExists = TRUE;

    /*
     *  Move cursor coords into point buffer
     */
    next_vertex[0] = Cursor->x;
    next_vertex[1] = Cursor->y;
    next_vertex[2] = Cursor->z;

    /*
     *  call the  add points function to modify the element
     */
    status = GRaddptsutil( &status,
                           &DYinfo->Context,
                           &DYinfo->Context.md_id.osnum,
                           &DYinfo->CloneGrid.objid,
                           &NumberOfPoints,
                            next_vertex,
                           &(ViewMatrix[8]),
                           &NewObjid );

    DYinfo->CloneGrid.objid = NewObjid;

    /*
     *  check return codes from send
     */
    if ( COERROR( status ) || COERROR( msg ) )
    {
       _m_debug_str(" COpolygon - GRpladdpts failed" );
       _m_debug( printf( "   status = 0x%x\n", status ) );
       _m_debug( printf( "   msg    = 0x%x\n", msg ) );
       om$report_error(sts = status);
    }

    _m_debug_str( "DYadd_pt_modify:  have added a vertex\n" );


    *num_buffers = 0;
    *objects = &DYinfo->CloneGrid;

quit:
    *num_objects = status & 1;
    return(  status );
}                                     

end implementation Root;

