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
IGRlong CO_ni_place_equal_pts(
                        msg,
                        Events,
                        ConstructInfo,
                        NewFlag,
                        ActiveDisplay,
                        ActiveLevel,
                        Attributes,
                        Name,
                        DummyGrid,
                        ClassName,
                        ClassID,
                        Neighbor,
                        CobID,
                        CobOS,
                        p_co_chanselect,
                        co_index,
                        LocateDisplayMode,
                        ConstructDisplayMode,
                        DisplayGrid,
                        ModuleInfo,
                        ObjectsGrid )
Arguments
        event[0] is the number of points to construct
        event[1] is the from point
        event[2] is the to point
        event[3] is the directional point

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    bmr 03/06/87 : adapted to the new include file design
    srh 05/23/89 : removed GRIS_ properties from construct list 
*/
class implementation Root;

#include "coimport.h"
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
#include "msdef.h"
#include "dp.h"
#include "exdef.h"
#include "igrmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRcurve    import GRptseqspace; 
from GRvg       import GRgeomprops;

/*----------------------------------------
 *  CO_ni_place_equal_pts
 *----------------------------------------
 */
IGRlong CO_ni_place_equal_pts(
                        msg,
                        Events,
                        ConstructInfo,
                        NewFlag,
                        ActiveDisplay,
                        ActiveLevel,
                        Attributes,
                        Name,
                        DummyGrid,
                        ClassName,
                        ClassID,
                        Neighbor,
                        CobID,
                        CobOS,
                        p_co_chanselect,
                        co_index,
                        LocateDisplayMode,
                        ConstructDisplayMode,
                        DisplayGrid,
                        ModuleInfo,
                        ObjectsGrid )

    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ConstructInfo;
    IGRboolean            NewFlag;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *Attributes;
    IGRchar              *Name;
    struct GRid          *DummyGrid;
    IGRchar              *ClassName;
    GRclassid             ClassID;
    OM_S_NEIGHBOR         Neighbor;
    OM_S_OBJID            CobID;
    GRspacenum            CobOS;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;
    enum GRdpmode         LocateDisplayMode;
    enum GRdpmode         ConstructDisplayMode;
    struct GRid          *DisplayGrid;
    struct GRmd_env      *ModuleInfo[];
    struct GRid          *ObjectsGrid[];
{
    IGRlong                      status;         /* return code       */
    IGRboolean                   b_status;
    IGRpoint                     to_pt;
    struct GRparms               to_parms;
    IGRpoint                     dir_pt;
    struct GRparms               dir_parms;
    IGRpoint                     from_pt;
    struct GRparms               from_parms;
    struct GRprops               properties;
    IGRlong			 num_points;
    IGRdouble                   *out_pts;
    IGRpoint                     point;
    IGRshort                     cur_pt;
extern    IGRboolean    MA2pttobc();
    struct IGRdisplay            local_display;
    GRls_declare( bspline, PoleKnotBuffer );

    /* KLUDGE */
    IGRchar                      classname[15];
    strcpy(classname,"GR3dpoint");

    GRls_init( bspline, PoleKnotBuffer );

    num_points = Events[0]->event.value;


    if ( ActiveDisplay == NULL )
    {
        IGRlong NumberOfBytes;
        IGRlong BytesReceived;

        NumberOfBytes = sizeof( local_display );
        gr$get_active_display(
                msg = msg,
                sizbuf = &NumberOfBytes,
                buffer = &local_display,
                nret = &BytesReceived );
        local_display.weight = local_display.weight +3;
        if(local_display.weight > 31 ) local_display.weight = 31;
        ActiveDisplay = &local_display;
    }


    /*
     * malloc memory for points
     */
    out_pts = (IGRdouble *) om$malloc(size = (sizeof(IGRdouble) * (3 *  
                                               num_points) ) );

    status = om$send(msg = message GRvg.GRgeomprops(msg,
                            &ModuleInfo[0]->md_env.matrix_type,
                             ModuleInfo[0]->md_env.matrix,
                            &properties),
                     senderid = CobID,
                     targetid = ObjectsGrid[0]->objid,
                     targetos = ObjectsGrid[0]->osnum );
    _m_check2q( status, *msg );

    status = co$project_event( msg     =  msg,
                               event   =  Events[1],
                               module  =  ModuleInfo[0],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[0],
  	                       parms   = &from_parms,
			       point   =  from_pt );
    _m_check2q( status, *msg );
  
    status = co$project_event( msg     =  msg,
                               event   =  Events[2],
                               module  =  ModuleInfo[0],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[0],
                               parms   = &to_parms,
            		       point   =  to_pt );
     _m_check2q( status, *msg );
  
     if(properties.phy_closed)       /* closed object      */
      {
       status = co$project_event( msg     =  msg,
                                  event   =  Events[3],
                                  module  =  ModuleInfo[0],
                                  cob_id  =  CobID,
                                  grid    =  ObjectsGrid[0],
    	                          parms   = &dir_parms,
 	    		          point   =  dir_pt);
       _m_check2q( status, *msg );
      }
     else                           /*  object open     */
      {
        dir_parms = to_parms;
        dir_pt[0] = to_pt[0];
        dir_pt[1] = to_pt[1];
        dir_pt[2] = to_pt[2];
      }

      /*
       * get equally spaced points
       */
      status = om$send(msg = message GRcurve.GRptseqspace(msg,
                                     &ModuleInfo[0]->md_env.matrix_type,
                                      ModuleInfo[0]->md_env.matrix,
                                      from_pt,
                                      dir_pt,
                                      to_pt,
                                     &from_parms,
                                     &dir_parms,
                                     &to_parms,
                                     &num_points,
                                      out_pts),
                       senderid = CobID,
                       targetid = ObjectsGrid[0]->objid,
                       targetos = ObjectsGrid[0]->osnum );
     _m_check2q( status, *msg );

    for(cur_pt=0;cur_pt < num_points; cur_pt++)
     {
       point[0] = out_pts[(cur_pt*3)+0];
       point[1] = out_pts[(cur_pt*3)+1];
       point[2] = out_pts[(cur_pt*3)+2];

       b_status = MA2pttobc(  msg,
                              point,
                              point,
                             &bspline);

      /*
       * construct and display object
       */             
      if ( classname != NULL )
       {
           status = co$construct_object(
                           msg          = msg,
                           mode         =  ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     =  &bspline,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  DummyGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  NULL,
                           co_index     =  co_index,
                           classname    =  classname );
         }
       else /* classid is specified */
         {
           status = co$construct_object(
                           msg          =  msg,
                           mode         =  ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     = &bspline,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  DummyGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  NULL,
                           co_index     =  co_index,
                           classid      =  ClassID );
          }
      }     /*  end for loop */
quit:
    om$dealloc(ptr = out_pts);
    return ( status );
}

end implementation Root;



