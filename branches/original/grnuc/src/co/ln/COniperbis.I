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
IGRlong CO_ni_perbis

Arguments
        event[1] is the from point
        event[2] is the to point


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

from GRcurve    import GRperbis;
from IGEgragad  import DPinrot;


/*----------------------------------------
 *  CO_ni_perbis
 *----------------------------------------
 */
IGRlong CO_ni_perbis(
                        msg,
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

    IGRlong                      status;         /* return code       */
    IGRmatrix                    rot_matrix;
    IGRvector                    nor_vect;
    IGRpoint                     ToPoint; /* point to which to perbis object */
    IGRpoint                     FromPoint; 
    struct GRparms               Parms;

    GRls_declare( line_seg, PoleKnotBuffer );

    GRls_init( line_seg, PoleKnotBuffer );

    status = co$project_event( msg     =  msg,
                               event   =  Events[0],
                               module  =  ModuleInfo[0],
                               cob_id  =  CobID,
                               grid    =  ObjectsGrid[0],
		               parms   = &Parms,
			       point   =  FromPoint );
    _m_check2q(status, *msg);
 
     /*
      *  extract the destination point from the destination event
      */
      ToPoint[0] = Events[1]->event.button.x;
      ToPoint[1] = Events[1]->event.button.y;
      ToPoint[2] = Events[1]->event.button.z;

      /*
       * get normal vector from event 1.
       */
       status = om$send(msg = message IGEgragad.DPinrot(msg,
                                                        rot_matrix),
                        senderid = CobID,
                        targetid = Events[0]->event.button.objid,
                        targetos = Events[0]->event.button.osnum);
       _m_check2q(status, *msg);

       nor_vect[0] = rot_matrix[8];
       nor_vect[1] = rot_matrix[9];
       nor_vect[2] = rot_matrix[10];

      /*
       *  send to the object
       */
       status = om$send(msg = message GRcurve.GRperbis(msg,
                                   &ModuleInfo[0]->md_env.matrix_type,
                                   ModuleInfo[0]->md_env.matrix,
                                  &Parms,
                                   nor_vect,
                                   ToPoint,
                                  &line_seg),
                        senderid = CobID,
                        targetid = ObjectsGrid[0]->objid,
                        targetos = ObjectsGrid[0]->osnum);
    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&line_seg);
    _m_checkq(status);

   /*
    * construct and display object
    */             
    if ( ClassName != NULL )
      {
           status = co$construct_object(
                           msg          = msg,
                           mode         =  ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     = &line_seg,
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
                           geometry     = &line_seg,
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
 
    }

end implementation Root;
