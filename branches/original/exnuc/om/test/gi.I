/* #define	DBGPRT	1  if want print statements output */
class implementation g;

#include "OMobjectcomm.h"

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ send_chan */
method send_chan ( )
{
 int sts;
 OM_S_CHANSELECT	cs;

  cs.type = OM_e_name;
  cs.u_sel.name="g.one";
#ifdef	DBGPRT
  printf (" ---- g.send_chan  my_id=%d sender_id=%d\n",my_id,sender_id);
  printf ("g.send_chan me=%d &ME.g->one=%d\n",me,(&ME.g->one));
#endif
  sts = om$send(msg = message g.answer (), p_chanselect=&cs);
  if (sts != OM_S_SUCCESS) {
    printf("g.send_chan: send_channel fail\n");
    om$report_error(sts=sts);
  }
  return(sts);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ answer */
method answer ()
{
#ifdef	DBGPRT
  printf (" ---- g.answer  my_id=%d sender_id=%d\n",my_id,sender_id);
#endif
  return(OM_S_SUCCESS);
}
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ unkmsg */
method unknown (OM_S_MESSAGE *msg)
{
#ifdef	DBGPRT
  printf (" ---- g.unkmsg !!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
#endif
  return(OM_S_SUCCESS);
}

end implementation g;
