class implementation EMSedge;

#include "bserr.h"
#include "bsparameters.h"
#include "bsarclen.h"


method EMget_edge_length( IGRlong *EMmsg; IGRushort options;
                           struct GRmdenv_info *mdenv_info;
                           IGRdouble *from_param;
                           IGRdouble *to_param;
                           IGRdouble *mid_pt_param;
                           IGRdouble *edge_length )
{
  IGRboolean		status;
  IGRlong		msg, OM_stat;
  struct IGRbsp_curve	edge_xyz_crv;
  IGRdouble		start_param, end_param, direction;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  EMerr_hndlr( !edge_length, *EMmsg, EMS_E_InvalidArg, wrapup );

  edge_xyz_crv.poles = NULL;
  edge_xyz_crv.knots = NULL;
  edge_xyz_crv.weights = NULL;

  OM_stat = om$send( msg = message EMSedge.EMget_bcxyz_geom( &msg,
                             mdenv_info, NULL, NULL, 0, MAXINT, FALSE,
                             NULL, &edge_xyz_crv ),
                     targetid = my_id);
  EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError, wrapup );

  start_param = 0.0;
  end_param = 1.0;
  direction = 0.5;
  if( from_param )	start_param = *from_param;
  if( to_param ) 	end_param = *to_param;
  if( mid_pt_param )
   direction = *mid_pt_param;
  else
    direction = ( start_param + end_param ) / 2.0;

  BSarclen( &msg, &status, &edge_xyz_crv, &start_param, &end_param,
            &direction, edge_length );
  EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

wrapup:

  if( edge_xyz_crv.poles )
    om$dealloc( ptr = edge_xyz_crv.poles );
  if( edge_xyz_crv.knots )
    om$dealloc( ptr = edge_xyz_crv.knots );
  if( edge_xyz_crv.rational == TRUE && edge_xyz_crv.weights )
    om$dealloc( ptr = edge_xyz_crv.weights );

  EMWRAPUP( *EMmsg, OM_stat, "EMSedge.EMget_edge_length" );
  return( OM_stat );
}

end implementation EMSedge;
