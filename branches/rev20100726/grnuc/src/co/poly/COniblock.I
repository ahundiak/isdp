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
IGRlong CO_ni_place_block(

Abstract
    This function constructs a bspline representation of a block, then
     constructs and optionally displays a block object.
    If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        Event[0] - 1st diagonal
        Event[1] - 2st diagonal

    IGRlong      number_events
        the number of events in the array.
        should be 2


    The rest of the arguments are exactly as specified in co$construct_object.
    Except that object, and objid are not allowed.


Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.

History
    bmr 03/06/87 : adapted to the new include file design
    srh 05/23/89 :  removed GRIS_ properties from construct list 
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

from IGEgragad import DPinrot;

/*
 *  the router to construct the rotated block returns boolean
 */
extern    IGRboolean    MA2ptrcconstr();

/*----------------------------------------
 *  CO_ni_place_block
 *----------------------------------------
 */
IGRlong CO_ni_place_block(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                BlockGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index)
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *BlockGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

{

    IGRlong             status;         /* return code                  */
    IGRboolean          b_status;       /* return status                */
    IGRmatrix           rot_matrix;    /* rotation mtx from view  */
    IGRvector           dir_vect;      /* direct vector for block */
    IGRdouble           point1[3];      /* first point */
    IGRdouble           point2[3];      /* second point */
    struct IGRbsp_curve block;
    IGRdouble           pole_buff[15];  /* stub poles for bspline  */
    IGRdouble           knot_buff[15];  /* stub knots for bspline  */

    block.poles = pole_buff;         
    block.knots = knot_buff;

    /*
     *  SET up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = MSSUCC;


    /*
     *  initialize the poles, weights, knots pointers in the rotated block 
     *  using the macro defined by eddie jennings
     */
    status = om$send(
                msg = message IGEgragad.DPinrot(
                    msg,
                    rot_matrix ),
                senderid = NULL_OBJID,
                targetid = Events[0]->event.button.objid,
                targetos = Events[0]->event.button.osnum );
    _m_checkp( *msg, "CO_ni_place_block - failed in IGEgrad.DPinrot." );
    _m_checkq( *msg );

    dir_vect[0] = rot_matrix[4];
    dir_vect[1] = rot_matrix[5];
    dir_vect[2] = rot_matrix[6];

    point1[0] = Events[0]->event.button.x;
    point1[1] = Events[0]->event.button.y;
    point1[2] = Events[0]->event.button.z;

   

    point2[0] = Events[1]->event.button.x;
    point2[1] = Events[1]->event.button.y;
    point2[2] = Events[1]->event.button.z;

    b_status = MA2ptrcconstr(msg,
                             point1,
                             point2,
                             dir_vect,
                            &block); 
    _m_check_boolp( b_status,"CO_ni_place_block - failed in MA2ptrcconstr.");
    _m_check_boolq( b_status );
    _m_checkq( *msg );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&block);
    _m_checkq(status);

    /*	
     *  set up the object space of the new object
     */
    BlockGrid->osnum = ModuleInfo->md_id.osnum;
    
    
    /*
     *  classname is specified
     */
    if ( classname != NULL )
      {
	status = co$construct_object(
				     msg = msg,
				     mode = DisplayMode,
				     module = ModuleInfo,
				     newflag = newflag,
				     properties = 0,
				     geometry = &block,
				     symbology = ActiveDisplay,
				     level = ActiveLevel,
				     attr = attr,
				     name = name,
				     grid = BlockGrid,
				     display_obj = DisplayGrid,
				     neighbor = neighbor,
				     cob_id = cob_id,
				     cob_os = cob_os,
				     p_co_chansel = p_co_chanselect,
				     co_index = co_index,
				     classname = classname );
	
      }
    else /* classid is specified */
      {
	status = co$construct_object(msg = msg,
				     mode = DisplayMode,
				     module = ModuleInfo,
				     newflag = newflag,
				     properties = 0,
				     geometry = &block,
				     symbology = ActiveDisplay,
				     level = ActiveLevel,
				     attr = attr,
				     name = name,
				     grid = BlockGrid,
				     display_obj = DisplayGrid,
				     neighbor = neighbor,
				     cob_id = cob_id,
				     cob_os = cob_os,
				     p_co_chansel = p_co_chanselect,
				     co_index = co_index,
				     classid = classid );
      }
    
    _m_check2p( 
	       status,
	       *msg,
	       "CO_ni_place_block - failed in co$construct object." );
    
  quit:
    return ( status );
  }

end implementation Root;
