class implementation EMSproject;

# include "math.h"
# include "msdef.h"
# include "EMSbnddef.h"
# include "EMSprop.h"
# include "emsmacros.h"
# include "EMSopt.h"
# include "emsedgedef.h"
# include "EMSssprops.h"
# include "emsdef.h"
# include "bserr.h"
# include "bsparameters.h"
# include "bsdotp.h"
 
method EMget_natedge_info(IGRlong                     *EMmsg; 
                          struct GRmdenv_info         *md_env; 
                          IGRuchar            *curve_type; 
                          IGRushort           *edge_props)

/*
Description
        The method evaluates and returns the curve type
        of its natural edges.

        It also evaluates and returns the following edge properties 
        for its natural edges.

        EMED_DEGENERATE
        EMED_XYZ_CLOSED
        EMED_SEAM
        EMED_TANGENT
        EMED_REVERSE_CONNECT.

Arguments
        EMmsg   -- output

        md-env  -- input
                module environment info of the surface.

        curve_type -- output
                An array of natural edges' curve type.

        edge_props -- output
                An array of natural edges' properties.
        
    
History
        AIC     20 May 91   Creation
        AIC     21 Oct 91   Handle non-projection format
        pp      01 Nov 91   Allen was not checking whether edge_props was
                            NULL or not
        Sanjay  07 Jan 94   Setting the tangent property correctly. Fix for
                            TR# 119315040
*/

{
  long                  sts;
  struct IGRbsp_curve   curve;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  curve.poles = curve.weights = curve.knots = curve.bdrys = NULL;

  sts = om$send(mode = OM_e_wrt_message,
                msg = message EMSsubbs.EMget_natedge_info(
                    EMmsg, md_env, curve_type, edge_props),
                targetid = my_id);
  if(! (1 & sts)) goto wrapup;

  /* 
   * Fix for TR# 119315040 -- Sanjay
   * ------------------------------
   * The following code will mark the tangent edge property correctly in case
   * surfaces of projections created from B-spline curves.
   */

  if((me^^EMSsubbs.ss_props & EMSformat) == EMSprojectedFormat)
  {
    IGRint                taned0, taned1;    
    struct IGRbsp_surface sfdef; 
    IGRboolean            tangent_edge_may_exist = TRUE ;             

    /*
     * Get the surface definition
     */
    sts = om$send( msg = message EMSsubbs.EMgetbsdef( EMmsg, &sfdef ), 
                   targetid = my_id ); 
    EMerr_hndlr( !(1&sts&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup );

    /*
     * Get the probable tangent edges
     */
    if( sfdef.u_phy_closed )
    {
        taned0 = 0;
        taned1 = 2;
    }
    else if( sfdef.v_phy_closed )
    {
        taned0 = 1;
        taned1 = 3;
    }
    else 
    {
        tangent_edge_may_exist = FALSE;
    }
    
    if( tangent_edge_may_exist ) /* If tangent edge may exist */
    {
       BSrc                  rc;
       IGRpoint              tangent0[2], tangent1[2];
       IGRdouble             dotp, angle, par, tol;

       /*
        * Get the curve definition 
        */
       sts = om$send( msg = message EMSproject.EMgetProjection(
                      EMmsg, NULL, NULL, TRUE, NULL, NULL, &curve),
                      targetid = my_id);
       EMerr_hndlr( !(1&sts&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

       /*
        * Allocate the memory
        */
       curve.poles = (IGRdouble *) om$malloc( size =  
                                    curve.num_poles * 3 * sizeof(IGRdouble) );
       EMerr_hndlr( !curve.poles, *EMmsg, EMS_E_DynamicMemoryAllocated, 
                    wrapup );

       curve.knots = (IGRdouble *) om$malloc( size = 
                                    curve.num_knots * sizeof(IGRdouble) );
       EMerr_hndlr( !curve.poles, *EMmsg, EMS_E_DynamicMemoryAllocated, 
                    wrapup );

       if( curve.rational )
       {
           curve.weights = (IGRdouble *) om$malloc( size = 
                                    curve.num_poles * sizeof(IGRdouble) );
  
           EMerr_hndlr( !curve.poles, *EMmsg, EMS_E_DynamicMemoryAllocated, 
                        wrapup);
       }

       if( curve.num_boundaries )
       {
           curve.bdrys = (IGRdouble *) om$malloc( size = 
                                curve.num_boundaries * 2 * sizeof(IGRdouble) ); 
       }

       /*
        * Get the projected curve geometry
        */ 
       sts = om$send( msg = message EMSproject.EMgetProjection(
                      EMmsg, NULL, NULL, FALSE, NULL, NULL, &curve),
                      targetid = my_id);
       EMerr_hndlr( !(1&sts&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

       /*
        * Get the end tangents of the curve i.e. at parameters 0 and 1.0-tol 
        */
       par = 0.0;
       BScveval( &curve, par, 1, tangent0, &rc);
       EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

       BSEXTRACTPAR( &rc, BSTOLLENVEC, tol );  
       EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
       par = 1.0 - tol;
       BScveval( &curve, par, 1, tangent1, &rc);
       EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

       /*
        * Normalize the tangent vectors
        */ 
       BSnorvec( &rc, &tangent0[1][0]);
       EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

       BSnorvec( &rc, &tangent1[1][0]);
       EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

       /* 
        * Get the dot product of the two tangents i.e. cos of angle between the
        * the vectors. if the dotp value happens to be nearly equal to 1.0,that
        * is if the angle between the tangent vectors is 1.0 then edges that 
        * will be formed at these parameter values will be tangent edges. 
        */

       dotp = BSdotp( &rc, tangent0[1], tangent1[1]);
       EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

       angle = acos( fabs(dotp) ) * 180 / PI ;
       if( angle <= EMS_ZEROANGLE_DEG ) /* if the angle is less than tol_ang */
       {
          edge_props[taned0] |= EMED_TANGENT;
          edge_props[taned1] |= EMED_TANGENT;
       } /* end of if ( angle <= EMS_ZEROANGLE_DEG ) */
    }/* end of if( tangent_edge_may_exist ) */
  } /* end of if ( EMSprojected format ) */

wrapup:

  if( curve.poles ) om$dealloc( ptr = curve.poles );
  if( curve.knots ) om$dealloc( ptr = curve.knots );
  if( curve.weights ) om$dealloc( ptr = curve.weights ); 
  if( curve.bdrys ) om$dealloc( ptr = curve.bdrys ); 
  EMWRAPUP(*EMmsg, sts, "In EMSproject.EMget_natedge_info")
  return sts;
}

end implementation EMSproject;
