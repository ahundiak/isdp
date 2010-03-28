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
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRvg import GRgetsize;
from GRvg import GRgetgeom;
from GRvg import GRdetplane;

struct orthoinfo
{ 
    IGRpoint            *point1_ptr;
    IGRpoint            *point2_ptr;
    struct IGRplane      plane;
    struct DPele_header  ele_buf[2];
    IGRlong              num_poles;
};


/*
 * -------------------------------------------
 *    routine actually called by DPdynamics
 * -------------------------------------------
 */
IGRint  DYorthline(
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
        
    struct  orthoinfo               *DYinfo;
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
    IGRboolean                      b_status;
    IGRlong                         msg;        
    IGRpoint                        ortho_point;
extern    IGRboolean    MAptplproj();
extern    IGRboolean    GRorthoseg();

    status = MSSUCC; 

    DYinfo->ele_buf[1].geometry.polyline->points[3] = Cursor->x;
    DYinfo->ele_buf[1].geometry.polyline->points[4] = Cursor->y;
    DYinfo->ele_buf[1].geometry.polyline->points[5] = Cursor->z;

    if(DYinfo->num_poles > 2)
     {
       b_status = MAptplproj( &msg, 
                              &DYinfo->ele_buf[1].geometry.polyline->points[3],
                              &DYinfo->plane, 
                              &DYinfo->ele_buf[1].geometry.polyline->points[3]);
     }

    b_status = GRorthoseg( &msg, 
                            DYinfo->point1_ptr, 
                            DYinfo->point2_ptr, 
                           &DYinfo->ele_buf[1].geometry.polyline->points[3],
                           &ortho_point[0]);

    DYinfo->ele_buf[1].geometry.polyline->points[0] = ortho_point[0];
    DYinfo->ele_buf[1].geometry.polyline->points[1] = ortho_point[1];
    DYinfo->ele_buf[1].geometry.polyline->points[2] = ortho_point[2];

    DYinfo->ele_buf[0].geometry.polyline->points[3] = ortho_point[0];
    DYinfo->ele_buf[0].geometry.polyline->points[4] = ortho_point[1];
    DYinfo->ele_buf[0].geometry.polyline->points[5] = ortho_point[2];

quit:
    *buffers = DYinfo->ele_buf;
    *num_buffers = 2;
    return(  status );
}                                     


IGRlong  DYrborthline( 
                function_index,
                events,
                Context,
                MyId,
                my_os,
                MyChannelStruct,
                ObjectGrid )
    IGRlong                     function_index;
    struct GRevent             *events[];
    struct GRmd_env            *Context;   
    GRobjid                     MyId;
    GRspacenum                  my_os;
    OM_S_CHANSELECT            *MyChannelStruct;
    struct GRid                *ObjectGrid;


{
    IGRlong                      status;
    IGRboolean                   b_status;
    IGRlong                      msg;
    IGRuint                      NumberObjectsFound;
    OM_S_OBJECT_LINKAGE          ChannelLinkage[1];
    struct GRid                  element;
    struct IGRbsp_curve         *bspline_ptr;   
    IGRlong                      size;
    IGRpoint                     point;
    IGRvector                    normal;
    IGRdouble                    dist;
    IGRlong                      num_points;
    struct  orthoinfo            DYinfo;
    struct  IGRpolyline          pyline1;
    struct  IGRpolyline          pyline2;
    struct  IGRdisplay           display1;
    struct  IGRdisplay           display2;
    IGRdouble                    pt_buffer[12]; 

    pyline1.num_points = 2;
    pyline1.points = &pt_buffer[0];

    pyline2.num_points = 2;
    pyline2.points = &pt_buffer[6];

    DYinfo.plane.point = &point[0];
    DYinfo.plane.normal = &normal[0];

    size = sizeof( display1 );
    gr$get_active_display( msg = &msg,
                           sizbuf = &size,
                           buffer = &display1,
                           nret = &size );

    display2 = display1;
    display2.style = 3;

    if ( MyChannelStruct != NULL )  /* extract object from channel */
     {
       status = om$get_channel_objects(objid = MyId,
                                       p_chanselect = MyChannelStruct,
                                       list = ChannelLinkage,
                                       size = 1,
                                       count = &NumberObjectsFound );
       element.objid = ChannelLinkage[0].S_objid;
       element.osnum = ChannelLinkage[0].osnum;
     }
    else                            /* grid passed */
     {
        element = *ObjectGrid;
     }

    status = om$send(msg = message GRvg.GRgetsize(&msg,         
                            &Context->md_env.matrix_type,
                             Context->md_env.matrix,
                            &size),
                     senderid = MyId,
                     targetid = element.objid,
                     targetos = element.osnum );
 
    bspline_ptr = (struct IGRbsp_curve *)om$malloc(size = size);

    status = om$send(msg = message GRvg.GRgetgeom(&msg,         
                            &Context->md_env.matrix_type,
                             Context->md_env.matrix,
                             (IGRchar *)bspline_ptr),
                     senderid = MyId,
                     targetid = element.objid,
                     targetos = element.osnum );

    _m_check2q(status,msg);
    
    dist = 0.0;
    num_points = bspline_ptr->num_poles;
                                  /* point to last point in list */
    DYinfo.point1_ptr = (IGRpoint *)&bspline_ptr->poles[(bspline_ptr->num_poles*3)-3];
    DYinfo.point2_ptr = (IGRpoint *)&bspline_ptr->poles[(bspline_ptr->num_poles*3)-3];

    pt_buffer[0] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-3];
    pt_buffer[1] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-2];
    pt_buffer[2] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-1];

    while(dist <= 0.0  && num_points > 1 )
     {
       b_status = MA2ptdis(  &msg, 
                             DYinfo.point2_ptr,
                             --DYinfo.point1_ptr,
                            &dist);
       num_points--;
     }

    DYinfo.num_poles = bspline_ptr->num_poles;
    if(DYinfo.num_poles > 2)
     {
      status = om$send(msg = message GRvg.GRdetplane(&msg,         
                            &Context->md_env.matrix_type,
                             Context->md_env.matrix,
                            &DYinfo.plane),
                       senderid = MyId,
                       targetid = element.objid,
                       targetos = element.osnum );
      }

     dp$build_dis_buffer( buffer      = &DYinfo.ele_buf[0],
                          type        =  IGRPY,      
                          display_att = &display1,
                          geometry    = (struct IGRpolyline *) &pyline1  );

      dp$build_dis_buffer( buffer      = &DYinfo.ele_buf[1],
                           type        =  IGRPY,      
                           display_att = &display2,
  	                   geometry    = (struct IGRpolyline *) &pyline2  );


      dp$dynamics( dyn_fun = DYorthline,
                   information = &DYinfo );

 quit:
       om$dealloc(ptr = bspline_ptr);
       return(status);

}           
end implementation Root;





























