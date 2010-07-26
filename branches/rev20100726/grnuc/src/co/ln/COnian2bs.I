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
   CO_ni_ang2bis()

 Abstract

 Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is point on element 1
        event[1] is point on element 1
        event[2] is endpoint of line

    struct GRmd_env   *module
        context of located object

    GRobjid           CobID
        object id of calling object, or at least some object

    GRspacenum        CobOS
        object space number of calling object, or at least some object

    struct GRid       *display_obj
        id of object to display located object

 Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

 History
    BMR 7/1/87   :  created 
    SCW 2/3/89   :  changed to apparent project
    srh 05/23/89 :  removed GRIS_ properties from construct list 

 */

/*  EH - end of header */
class implementation Root;

#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "codebug.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "codef.h"
#include "igrmacros.h"

extern   IGRboolean          GR2objangbis ();

IGRlong  CO_ni_ang2bis( msg,
                        Events,
                        ConstructInfo,
                        NewFlag,
                        ActiveDisplay,
                        ActiveLevel,
                        Attributes,
                        Name,
                        LineSegmentGrid,
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
    struct GRid          *LineSegmentGrid;
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
    IGRlong             status;    
    IGRboolean          b_status;  /* boolean return code               */
    IGRshort            extend_flag;
    IGRpoint            EndPoint_of_line;
    IGRdouble           distance;

    GRls_declare( LineSegment, PoleKnotBuffer );

    GRls_init( LineSegment, PoleKnotBuffer );

    distance = 0.0;
    extend_flag = 1;

   *msg = MSSUCC;
    status = OM_S_SUCCESS;

    EndPoint_of_line[0] = Events[2]->event.button.x;
    EndPoint_of_line[1] = Events[2]->event.button.y;
    EndPoint_of_line[2] = Events[2]->event.button.z;

    b_status = GR2objangbis ( msg,
                              ObjectsGrid[0],
                             &ModuleInfo[0]->md_env,
                             &Events[0]->located_object[0].geom_parms,
                              Events[0]->located_object[0].proj_pnt,
                              ObjectsGrid[1],
                             &ModuleInfo[1]->md_env,
                             &Events[1]->located_object[0].geom_parms,
                              Events[1]->located_object[0].proj_pnt,
                             &extend_flag,
                             &distance,
                              EndPoint_of_line,
                             &LineSegment);
    _m_check_boolq( b_status );
    _m_checkq( *msg );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&LineSegment);
    _m_checkq(status);

    if ( ClassName != NULL )
      {
           status = co$construct_object(
                           msg          = msg,
                           mode         =  ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     = &LineSegment,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  LineSegmentGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  p_co_chanselect,
                           co_index     =  co_index,
                           classname    =  ClassName );
       }
     else /* classid is specified */
       {
           status = co$construct_object(
                           msg          =  msg,
                           mode         =  ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     = &LineSegment,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  LineSegmentGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  p_co_chanselect,
                           co_index     =  co_index,
                           classid      =  ClassID );
       }
quit:
   return( status );

} /*  end  of CO_ni_ang2bis  */

end implementation Root;
