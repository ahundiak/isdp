/* 
IGRlong CO_ni_generate_equal_spaced_pts( msg, Events )

Arguments
        event[0] is the number of points to generate
        event[1] is the from point
        event[2] is the to point
        event[3] is the directional point

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    srh 08/01/89 : created for NAVSEA prototype.
    srh 09/18/89 : spruced up for 1.3.0 GRNUC delivery; reversed order of 
		   points on the SEQ to be more consistant with the way
		   the inputs are given.
    dhm 07/14/92 : ANSI conversion.

Caveats

    Events generated will really screw up Automated Test Procedures.  This 
    is because we don't use a special subtype for these DATA events.  This 
    may be needed in the future.  What we are trying to avoid is putting
    GRevent structs on the queue ( they are HUGE! ).

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
#include "exmacros.h"
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


#define  NumberOfPoints     Events[0]->event.value
#define  ModuleEnvironment  Events[1]->located_object[0].module_info
#define  ObjectsGrid        Events[1]->located_object[0].located_obj
#define  FromPoint          Events[1]->event.button
#define  ViewObjid          Events[1]->event.button.objid
#define  ViewOsnum          Events[1]->event.button.osnum
#define  ToPoint            Events[2]->event.button
#define  DirPoint           Events[3]->event.button
#define  _X                 (0)
#define  _Y                 (1)
#define  _Z                 (2)

from GRcurve    import GRptseqspace; 
from GRvg       import GRgeomprops;


/*
 * -----------------------------------
 *   CO_ni_generate_equal_spaced_pts
 * -----------------------------------
 */

IGRlong CO_ni_generate_equal_spaced_pts( msg, Events )

    IGRlong              *msg;
    struct GRevent       *Events[];
{
    IGRlong
	status,         /* return code       */
        num_points;

    IGRpoint
        to_pt,
        dir_pt,
        from_pt;

    struct GRparms
        to_parms,
        dir_parms,
        from_parms;

    struct GRprops
        properties;

    IGRdouble
       *out_pts = NULL;

    IGRshort                  
	cur_pt,
	limit,
	start,
        inc_dec;

    extern IGRboolean            MA2pttobc();

    GRls_declare( bspline, PoleKnotBuffer );

    /******************************* EV *******************************/


    GRls_init( bspline, PoleKnotBuffer );
    num_points = (IGRlong)NumberOfPoints;

    /*
     * malloc memory for points
     */
    out_pts = (IGRdouble *) om$malloc( size = ( sizeof(IGRdouble) * 
		  ( 3 * num_points ) ) );

    status = om$send(msg = message GRvg.GRgeomprops(
			     msg,
                            &ModuleEnvironment.md_env.matrix_type,
                             ModuleEnvironment.md_env.matrix,
                            &properties),
                     senderid = NULL_OBJID,
                     targetid = ObjectsGrid.objid,
                     targetos = ObjectsGrid.osnum );
    _m_check2q( status, *msg );

    status = co$project_event( msg     =  msg,
                               event   =  Events[1],
                               module  = &ModuleEnvironment,
                               cob_id  =  NULL_OBJID,
                               grid    = &ObjectsGrid,
                               parms   = &from_parms,
                               point   =  from_pt );
    _m_check2q( status, *msg );
  
    status = co$project_event( msg     =  msg,
                               event   =  Events[2],
                               module  = &ModuleEnvironment,
                               cob_id  =  NULL_OBJID,
                               grid    = &ObjectsGrid,
                               parms   = &to_parms,
                               point   =  to_pt );
     _m_check2q( status, *msg );
  
     if(properties.phy_closed)       /* closed object      */
      {
       status = co$project_event( msg     =  msg,
                                  event   =  Events[3],
                                  module  = &ModuleEnvironment,
                                  cob_id  =  NULL_OBJID,
                                  grid    = &ObjectsGrid,
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
                                     &ModuleEnvironment.md_env.matrix_type,
                                      ModuleEnvironment.md_env.matrix,
                                      from_pt,
                                      dir_pt,
                                      to_pt,
                                     &from_parms,
                                     &dir_parms,
                                     &to_parms,
                                     &num_points,
                                      out_pts),
                       senderid = NULL_OBJID,
                       targetid = ObjectsGrid.objid,
                       targetos = ObjectsGrid.osnum );
      _m_check2q( status, *msg );


    /*  
     *  Set up for loop parameters to handle the correct sequencing of
     *  point generation.  This is necessary because the math routines
     *  used allways return the points in assending order along the
     *  curve, regardless of u_parm values.
     */
    start   = (from_parms.u > to_parms.u ) ? (0)           :  (num_points-1);
    inc_dec = (from_parms.u > to_parms.u ) ? (1)           :  (-1)          ;
    limit   = (from_parms.u > to_parms.u ) ? (num_points)  :  (-1)          ;

    /*
     *  Build and generate the EX_button structures to go on the SEQ
     */
    for ( cur_pt  = start; 
	  cur_pt != limit;
	  cur_pt += inc_dec )
    {
       struct EX_button
	  SEQ_event;

       IGRlong
	  Size     = sizeof( struct EX_button );

       IGRint 
          Response = EX_DATA;

          status = co$build_button(
                           msg    =  msg,
                           x      =  out_pts[(cur_pt*3)+_X],
                           y      =  out_pts[(cur_pt*3)+_Y],
                           z      =  out_pts[(cur_pt*3)+_Z],
                           osnum  =  ViewOsnum,
                           objid  =  ViewObjid,
                           button = &SEQ_event );
          _m_check2q( status, *msg );

	  /* Flag event as software generated */

          status = ex$putque ( msg      =  msg,
                               response = &Response,
                               byte     = &Size,
                               buffer   = (IGRchar *) &SEQ_event );
          _m_checkq( status );

    }     /*  end for loop */
quit:
    if ( out_pts ) om$dealloc(ptr = out_pts);
    return ( status );
}

end implementation Root;

