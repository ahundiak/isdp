/* ###################   APOGEE COMPILED   ################## */
/*
Description
    The following functions are used by the EMget(put)CompIndex messages.
    These use a pseudo channel in order to determine the proper owner index
    of surfaces removed.  This is important when performing random access
    tree editing.

History
    DLB 05/15/89 Creation.
*/

#define DEBUG 0

#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "OMmacros.h"


void EFinitchan(EMmsg, chan, id)
IGRint              *EMmsg;
struct EMchanstruct *chan;
GRobjid             id;
{
  IGRlong         OM_stat;      
  OMuint          ii, count;
  OM_S_CHANSELECT to_comps;
  OMuword         dumosnum;


  EMmake_chanselect(GRcmpowner_to_components, &to_comps);
 
  chan->id = id;
  chan->chancnt = 0;
  chan->chan = NULL;

  OM_stat = om$get_channel_count(objid = id,
                                 p_chanselect = &to_comps,
                                 count = &count);
  if (!(1 & OM_stat)) goto wrapup;
                                           

  for(ii=0; ii<count; ii++)
  {
    EFrealloc_if_needed(EMmsg, &chan->chan, chan->chancnt, 
                        CHAN_BUFF_INCR, sizeof(GRobjid));
    if (!(1 & *EMmsg)) goto wrapup;
    
    OM_stat = om$get_objid_at_index(objid = id,
                                    p_chanselect = &to_comps,
                                    index = ii,
                                    objidaddr = &chan->chan[chan->chancnt],
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;

    chan->chancnt++;
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFinitchan")
    return;
}

void EFconnectchan(EMmsg, chan, id, inx)
IGRlong             *EMmsg;
struct EMchanstruct *chan;
GRobjid             id;
IGRint              inx;
{
# if DEBUG
  IGRint ii;
  for(ii=0; ii<chan->chancnt; ii++)
  {
    if (chan->chan[ii] == id)
    {
      fprintf(stderr,"EFconnectchan-Duplicate found %d, index %d\n", id, ii);
      fprintf(stderr,"Id not added\n");
      goto wrapup;
    }
  }
# endif

  EFrealloc_if_needed(EMmsg, &chan->chan, chan->chancnt, 
                      CHAN_BUFF_INCR, sizeof(GRobjid));
  if (!(1 & *EMmsg)) goto wrapup;

  if (chan->chancnt > inx)
  {
    /*Insert between existing connections.*/
    OM_BLOCK_MOVE(&chan->chan[inx], &chan->chan[inx+1], 
                  (chan->chancnt - inx) * sizeof(GRobjid));
  }

  chan->chan[inx] = id;
  chan->chancnt++;

  wrapup:
    EMSmsgReport(*EMmsg, "EFconnectchan", 0);
    return;
}

void EFdisconnectchan(EMmsg, chan, inx)
IGRlong             *EMmsg;
struct EMchanstruct *chan;
IGRint              inx;
{
  if (chan->chancnt > inx+1)
  {
    /*Collapse index and move down existing connections.*/
    OM_BLOCK_MOVE(&chan->chan[inx+1], &chan->chan[inx], 
                  (chan->chancnt - (inx + 1)) * sizeof(GRobjid));
  }

  chan->chancnt--;

  EMSmsgReport(*EMmsg, "EFdisconnectchan", 0);
  return;
}
