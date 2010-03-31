class implementation EMSrevol;

# include "msdef.h"
# include "EMSbnddef.h"
# include "EMSprop.h"
# include "emsmacros.h"
# include "EMSopt.h"
# include "emsedgedef.h"
# include "EMSssprops.h"
 
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
*/

{
  IGRlong       sts;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  sts = om$send(mode = OM_e_wrt_message,
                msg = message EMSsubbs.EMget_natedge_info(
                    EMmsg, md_env, curve_type, edge_props),
                targetid = my_id);
  if(! (1 & sts)) goto wrapup;

  if((me^^EMSsubbs.ss_props & EMSformat) == EMSrevolvedFormat)
  {
    IGRboolean    is_360;

    sts = om$send(msg = message EMSrevol.EMgetRevolvedFormat(EMmsg, FALSE,
                    NULL, NULL, NULL, NULL, &is_360, NULL, NULL, NULL),
                  targetid = my_id);
    if(! (1 & sts)) goto wrapup;

    if(is_360)
    {
      curve_type[0] = curve_type[2] = EMcircle;
      if(edge_props)
      {
        edge_props[1] |= EMED_TANGENT;
        edge_props[3] |= EMED_TANGENT;
      }
    }
    else curve_type[0] = curve_type[2] = EMcircular_arc;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSrevol.EMget_natedge_info")
  return sts;
}

end implementation EMSrevol;
