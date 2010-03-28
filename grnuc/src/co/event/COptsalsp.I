/* 
IGRlong CO_ni_generate_pts_along_element_by_spacing( msg, Events )

Arguments
        event[0] spacing between points
        event[1] is the from point on element
        event[2] is the to point on element
        event[3] is the directional point ( if element closed )

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    srh 08/24/89 : created for NAVSEA prototype.
    dhm 07/14/92 : ansi conversion.
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


#define  PointSpacing       Events[0]->event.value
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

from GRvg    import GRgetsize, 
                    GRgetgeom,
                    GRgeomprops;


/*
 * -------------------------------------------------
 *   CO_ni_generate_pts_along_element_by_spacing();
 * -------------------------------------------------
 */

IGRlong CO_ni_generate_pts_along_element_by_spacing( msg, Events )

    IGRlong              *msg;
    struct GRevent       *Events[];
{
    IGRlong
        status,         /* return code       */
        size,
        num_points,
        rc = 0;

    IGRboolean 
        alloc_flag = 0;

    IGRpoint
        from_pt,
        to_pt,
        dir_pt;


    struct IGRbsp_curve    
       *p_curve = NULL;

    struct GRparms  
        to_parms,
        dir_parms,
        from_parms;

    struct GRprops    
        properties;

    IGRdouble
       *out_pts  = NULL;

    IGRshort        
	start,
	limit,
	inc_dec,
        cur_pt;

    extern void        BSeqdptscv();

    /*
     *  Allocate enough space for the element's geometry
     */
    status = om$send( msg = message GRvg.GRgetsize( 
                                msg,
                               &ModuleEnvironment.md_env.matrix_type,
                                ModuleEnvironment.md_env.matrix,
                               &size ),
                      senderid = NULL_OBJID,
                      targetid = ObjectsGrid.objid,
                      targetos = ObjectsGrid.osnum );
    _m_check2q( status, *msg );

    p_curve = ( struct IGRbsp_curve * ) om$malloc( size = size );

    status = om$send( msg = message GRvg.GRgetgeom(
                                msg,
                               &ModuleEnvironment.md_env.matrix_type,
                                ModuleEnvironment.md_env.matrix,
                                (IGRchar *) p_curve ),
                      senderid = NULL_OBJID,
                      targetid = ObjectsGrid.objid,
                      targetos = ObjectsGrid.osnum );
    _m_check2q( status, *msg );


    /*
     *  Get properties ( is it open or closed? )
     */
    status = om$send( msg = message GRvg.GRgeomprops(
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
       dir_parms.u = ( from_parms.u + to_parms.u) / 2.0;
       dir_pt[0] = to_pt[0];
       dir_pt[1] = to_pt[1];
       dir_pt[2] = to_pt[2];
    }

    /*
     * get equally spaced points
     */
    BSeqdptscv(  p_curve,
                 from_parms.u,
                 dir_parms.u,
                 to_parms.u,
                 PointSpacing,
                 0,              /* force BS routine to malloc for us */
                 NULL,           /* no local allocation */
                &alloc_flag,
                &num_points,
                &out_pts,
                &rc );

    if ( rc || ! alloc_flag )
    {
      *msg = MSFAIL;
      goto quit;
    }

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

    if ( out_pts ) free (out_pts);
    if ( p_curve ) om$dealloc( ptr = p_curve );

    return ( status );
}

end implementation Root;

