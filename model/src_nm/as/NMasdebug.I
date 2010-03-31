class implementation NMassoctrans;

#include "OMmacros.h"

method debug()
{
 IGRlong	sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 IGRint		num = 0, i;
 struct GRid	*basest = NULL;
 IGRboolean	*trans = NULL;

 sts = om$send(msg = message NMassoctrans.NMget_trans_info(&EMmsg, &trans, 
       &basest, &num), targetid = my_id);
 if(!(1&EMmsg&sts)) goto wrapup;

 fprintf(stderr, "\n\tTransmigration Information -\n");
 fprintf(stderr, "\tBase State     Trans Flag\n");
 for(i=0; i<num; i++)
  fprintf(stderr, "\t%d.%d            %d\n", basest[i].osnum, basest[i].objid,
   trans[i]);

wrapup:
if(basest) om$dealloc(ptr = basest);
if(trans) om$dealloc(ptr = trans);
return(sts);
}

end implementation NMassoctrans;
