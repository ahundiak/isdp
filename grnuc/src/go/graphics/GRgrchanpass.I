class implementation GRgraphics;

/*
History

        AIC 05 Feb 92   Creation (taken from old Rootmsg code)
*/

#include "OMerrordef.h"

method GRchannel_pass(
        GR_S_PATH_LIST  path[];         /* i - Path to traverse         */
        int             num_levels;     /* i - Num levs in path         */
        OM_p_MESSAGE    msg)            /* i - Message to send          */
{
  int     lv,sts;

  /*
   * AIC: This structure is no longer used.
  struct  req
  {
    int     type;
  }*request;
   */

  /*
   * AIC: I don't understand the need to my_id_KLUGE
   *
  OM_S_OBJID  my_id_KLUGE;

  my_id_KLUGE=my_id;
   */

  if ( (num_levels ==1) && (path[0].user_arg == (char *) 0) )
  {
    sts = om$send(mode = path[0].mode,
                msg = msg,
                p_chanselect = path[0].chansel,
                from = path[0].from_ndx,
                to = path[0].to_ndx);
  }
  else if( num_levels == 0 )
  {
    sts = om$send(mode = path[0].mode,
                msg = msg,
                targetid = my_id);
/*              targetid = my_id_KLUGE); AIC */
  }
  else
  {
    lv = (num_levels == 1) ? 0:1;
    sts = om$send(mode = path[0].mode,
                  msg = message GRgraphics.GRchannel_pass(&path[lv],
                        (num_levels-1),msg),
                  p_chanselect = path[0].chansel,
                  from = path[0].from_ndx,
                  to = path[0].to_ndx);
  }

  /*
   * Handle special processing
   *
   * The OM_E_INVCHAN error occurs when chanpassing across a channel such
   * as QYroot.  This is really like an UNKNOWN_CHANNEL and should not stop
   * sends.  Therefore we return OM_S_SUCCESS if we detect this error.
   *
   * AIC: This section of code is redundant.
   *
  if(! (request = (struct req *) path[0].user_arg) ) 
    return( (sts==OM_E_INVCHAN) ? OM_S_SUCCESS: sts );
   */

  return( (sts==OM_E_INVCHAN) ? OM_S_SUCCESS: sts );
}

end implementation GRgraphics;

