/* 
IGRlong CO_ni_place_fillet(
                msg,
Arguments
        event[0] tangent point on element 1
        event[1] tangent point on element 2
        event[2] center point
        event[3] radius
        event[4] end of element 1
        event[5] end of element 2
        event[6] trim flag
                 event.event.value = 0 trim neither curve.
                 event.event.value = 1 manual trim first curve
                 event.event.value = 2 manual trim second curve
                 event.event.value = 3 manual trim both curve
                 event.event.value = 4 auto trim both curve
                 event.event.value = 5 auto trim first curve
                 event.event.value = 6 auto trim second curve

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS
        OM_E_ABORT

History
    bmr 04/13/87 : created
    srh 05/22/89 : removed hard coded properties from co$construct_object
    dhm 10/26/93 : 119311828 - if GRfillet fails return a OM_E_ABORT.
*/

class implementation Root;

#include "coimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "exmacros.h"
#include "msdef.h"
#include "dp.h"
#include "exdef.h"

from  GRvg      import GRgetgeom;
from  GRvg      import GRgetsize;
from GRgraphics import GRlnproject;
from GRgraphics import GRdisplay;


/*----------------------------------------
 *  CO_ni_place_fillet
 *----------------------------------------
 */

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

IGRlong CO_ni_place_fillet(
                        msg,
                        Events,
                        ConstructInfo,
                        NewFlag,
                        ActiveDisplay,
                        ActiveLevel,
                        Attributes,
                        Name,
                        ArcGrid,
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
    struct GRid          *ArcGrid;
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
    IGRboolean                   b_status;
    IGRlong                      status;         /* return code       */
    IGRlong                      loc_msg;
    IGRdouble                    BorePoints[6];  /* points to store boreline*/
    struct IGRline               center_boreline; 
    IGRpoint                     tan_pt1;
    IGRpoint                     tan_pt2;
    IGRpoint                     trim_pt1;
    IGRpoint                     trim_pt2;
    OM_S_OBJID                   my_id;
    struct GRparms               tan_parms1;
    struct GRparms               tan_parms2;
    struct GRparms               end_parms1;
    struct GRparms               end_parms2;
    struct GRevent               center;
    struct GRid                  new1;
    struct GRid                  new2;
    struct GRid                  local_display_mod;
    IGRdouble                    radius_value;
    IGRshort                     trim_flag;
extern    IGRboolean    GRfillet();

    IGRpoint                     center_pt;
    GRconic_declare( circle_arc, circle_arc_poles );

    /* KLUDGE */
    IGRchar                      classname[15];
    enum GRdpmode                DisplayMode = GRbd;
    strcpy(classname,"GR3dcirarc");

    GRconic_init(circle_arc, circle_arc_poles);

    my_id = CobID;

    /*
     *  pull the events out of the array
     */

    center = *Events[2];
    center_pt[0] = center.event.button.x;
    center_pt[1] = center.event.button.y;
    center_pt[2] = center.event.button.z;
    radius_value = Events[3]->event.value;
    trim_flag = (IGRshort)Events[6]->event.value;

    /*
     *  set boreline for apparent project
     */
    center_boreline.point1 = &( BorePoints[0] );
    center_boreline.point2 = &( BorePoints[3] );

                             /* tan pt 1 */
    status = co$project_event( msg     =  msg,
                               event   =  Events[0],
                               module  =  ModuleInfo[0],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[0],
		               parms   = &tan_parms1,
			       point   =  tan_pt1 );
    _m_check2q(status, *msg);

                             /* trim pt 1 */
    status = co$project_event( msg     =  msg,
                               event   =  Events[4],
                               module  =  ModuleInfo[0],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[0],
		               parms   = &end_parms1,
			       point   =  trim_pt1 );
    _m_check2q(status, *msg);

                             /* tan pt 2 */
    status = co$project_event( msg     =  msg,
                               event   =  Events[1],
                               module  =  ModuleInfo[1],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[1],
		               parms   = &tan_parms2,
			       point   =  tan_pt2 );
    _m_check2q(status, *msg);

                             /* trim pt 2 */
    status = co$project_event( msg     =  msg,
                               event   =  Events[5],
                               module  =  ModuleInfo[1],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[1],
		               parms   = &end_parms2,
			       point   =  trim_pt2 );
    _m_check2q(status, *msg);


    b_status = CObrln(msg,
                       &my_id,
                       &center,
                       &center_boreline );
     /*
      * fillet object
      */
     b_status = GRfillet(msg,
                         ObjectsGrid[0],
                         ModuleInfo[0],
                         tan_pt1,
                        &tan_parms1,
                         ObjectsGrid[1],
                         ModuleInfo[1],
                         tan_pt2,
                        &tan_parms2,
                        &radius_value,
                        &center_boreline,
                        &trim_flag,
                         trim_pt1,
                         trim_pt2,
                        &circle_arc,
                        &new1.objid,
                        &new2.objid);

       _m_check_boolq( b_status );
       _m_checkq( *msg );

/*  OBJECTS NOT RETURNED
     ObjectsGrid[0]->objid = mew1.objid;
     ObjectsGrid[1]->objid = mew2.objid;
*/

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
                           geometry     = &circle_arc,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  ArcGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  p_co_chanselect,
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
                           geometry     = &circle_arc,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  ArcGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  p_co_chanselect,
                           co_index     =  co_index,
                           classid      =  ClassID );
       }

quit:
    ex$get_cur_mod(id = &local_display_mod.objid,
                   osnum = &local_display_mod.osnum);

    status = om$send(msg = message GRgraphics.GRdisplay ( &loc_msg,
                           &ModuleInfo[0]->md_env.matrix_type,
                            ModuleInfo[0]->md_env.matrix,
                           &DisplayMode, 
                           &local_display_mod),
                     targetid = ObjectsGrid[0]->objid,
                     targetos = ObjectsGrid[0]->osnum);
    if(ObjectsGrid[0]->objid != ObjectsGrid[1]->objid)
     {
        status = om$send(msg = message GRgraphics.GRdisplay ( &loc_msg,
                              &ModuleInfo[1]->md_env.matrix_type,
                               ModuleInfo[1]->md_env.matrix,
                              &DisplayMode, 
                              &local_display_mod),
                        targetid = ObjectsGrid[1]->objid,
                        targetos = ObjectsGrid[1]->osnum);
     }

    /*
     * TR 119311828 - return a fail if GRfillet fails (b_status = 0).
     * dhm    10/26/93.
     */

    if (!b_status) status = OM_E_ABORT;

    return ( status );
 
    }

end implementation Root;
