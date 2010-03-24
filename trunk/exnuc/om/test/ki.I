class implementation k;

#include "OMobjectcomm.h"

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ send_chan */
method send_chan (OM_S_CHANNUM chn; int *ans )
{
 int sts;
 OM_S_CHANSELECT chs;

  l_printf ("-- k.send_chan  %d,%d\n",OM_Gw_current_OS, my_id);
  chs.type = OM_e_num;
  chs.u_sel.number = chn;
  
  sts = om$send(msg = message k.answer (ans), p_chanselect=&chs);
  if (sts != OM_S_SUCCESS) {
    printf("k.send_chan: send_channel fail\n");
    om$report_error(sts=sts);
  }
  return(sts);
}
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ answer */
method answer (int *ans)
{
  *ans += 1;
  l_printf ("--- k.ans %d,%d <- %d answers=%d\n",
			OM_Gw_current_OS, my_id, sender_id,*ans);
  return(OM_S_SUCCESS);
}
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ unkmsg */
unkmsg ()
{
  printf (" ---- k.unkmsg !!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
  return(OM_S_SUCCESS);
}

end implementation k;
