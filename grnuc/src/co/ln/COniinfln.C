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
   IGRlong CO_ni_place_inf_line(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                InfLineGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index )
                                                                            
      IGRlong              *msg;
      struct GRevent       *Events[];
      enum GRdpmode        *DisplayMode;
      IGRboolean            newflag;
      struct GRmd_env      *ModuleInfo;
      struct IGRdisplay    *ActiveDisplay;
      IGRshort              ActiveLevel;
      IGRchar              *attr;
      IGRchar              *name;
      struct GRid          *InfLineGrid;
      struct GRid          *DisplayGrid;
      IGRchar              *classname;
      GRclassid             classid;
      OM_S_NEIGHBOR         neighbor;
      OM_S_OBJID            cob_id;
      GRspacenum            cob_os;
      OM_S_CHANSELECT      *p_co_chanselect;
      IGRint                co_index;

   Abstract:

      This function constructs a bspline representation of an infinite line 
      and then constructs and optionally displays a Infinite line object.  If 
      the display_obj is specified, then the object is displayed.

   Arguments:

      struct GRevent   *Events[]   
	 An array of two data point events used to create tha infinite line 
	 geometry

            Event[0] is the first  definition point of the infinite line 
            Event[1] is the second definition point of the infinite line 

      The rest of the arguments are exactly as specified in co$construct_object
      except that object, objid, and geometry are not allowed.


   Status returns:

      OM_S_SUCCESS            
      OM_E_ABORT
      OM_E_INVARG             
      OM_E_BADCLASSNAMES
      OM_E_INVCLUSTERID
      OM_E_NODYNMEM
      OM_E_NOEXTEND_CLUSTER
      OM_E_NOSUCHCLASS
      OM_E_NOSUCHOS
      OM_I_ADDEDATEND

   Caveats:

      May not specify an object space.  The object space will be the
      same object space as the module's object space.

  History:

      srh ??/??/?? : ( memory fault ) created 
      srh 05/23/89 : removed GRIS_ properties from construct list 

*/
#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "madef.h"
#include "msdef.h"

#include "gr.h"
#include "grerr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"

#include "comiscmac.h"
#include "igrmacros.h"

/*
 *  GRls2pt() converts 2 points into the abstract geometry of a line segment.
 *  MAbccendpts() gets the end points of a linear abstract geometry.  These
 *  two functions are used together to generate the vertices of a polyline.
 *
 */
extern  IGRboolean   GRls2pt();
extern  IGRboolean   MAbcendpts();
extern  IGRboolean   MApytobc();

/*
 *----------------------------------------
 *    CO_ni_place_inf_line
 *----------------------------------------
 */
IGRlong CO_ni_place_inf_line(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                InfLineGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index )
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort              ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *InfLineGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

{
/* BV - BEGINNING OF LOCAL VARIABLE LIST */

           IGRboolean   b_status;       /* return status                     */

           IGRlong      local_msg;      /* return code                       */
           IGRlong      status;         /* return code                       */
           IGRshort      NumberOfEvents = 2; /* for GRls2pt router            */

           IGRdouble    InfLinePoles[12];    /* poles for bspline */
           IGRdouble    InfLineKnots[6];     /* knots for bspline */

    struct IGRbsp_curve InfLine;        /* bspline curve returned     */

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */

    _m_debug_str( "> CO_ni_place_inf_line" );

    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
   *msg = MSSUCC;
    local_msg = MSSUCC;
    status = OM_S_SUCCESS;

    /*
     *   Set up bspline geometry for GRls2pt ( line segment router )
     *   and construct routine for infinite line
     */
    InfLine.poles = InfLinePoles;
    InfLine.knots = InfLineKnots;
    
    _m_debug_str( " Calling GRls2pt()" );
    b_status = GRls2pt( &local_msg,
                         Events,
                        &NumberOfEvents,
                        &InfLine );
    if (! b_status) 
    {
       _m_debug_str( "COniinfline: GRls2pt() FAILED!" );
       status = OM_E_ABORT;
       goto quit;
    }

    /*
     *  extend segment to design space extent
     */
    _m_debug_str( " Calling GRbclnextend()" );
    status = GRbclnextend( &local_msg,
                           &InfLine,
                           &InfLine );
    if ( !b_status )
    {
       _m_debug_str( "COniinfline: GRbclnextend() FAILED!" );
       status = OM_E_ABORT;
       goto quit;
    }

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(&local_msg,&InfLine);
    _m_checkq(status);

    _m_debug_str( "CO_ni_place_inf_line:  calling co$construct" );
    if ( classname != NULL )
    {
       /*
        *  classname is specified
        */
        status = co$construct_object(
                        msg = &local_msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &InfLine,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = InfLineGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classname = classname );
                                                                            
    }
    else
    {
        /*
	 * classid is specified
	 */
	status = co$construct_object(
                        msg = &local_msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &InfLine,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = InfLineGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classid = classid );
    }

    _m_check2p( status,
                local_msg,
                "CO_ni_place_inf_line - failed in co$construct object" );

quit:
    *msg = local_msg;
    _m_debug_str( "< CO_ni_place_inf_line" );
    return ( status );
}
