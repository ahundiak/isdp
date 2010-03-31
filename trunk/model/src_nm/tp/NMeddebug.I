class implementation NMedge;

#include "emsmacros.h"

method debug()
{
 IGRlong		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 IGRint			numed = 0, i;
 struct GRid		*ed = NULL, refed, refsf;
 IGRboolean		*rev = NULL;
 GRobjid		creator = NULL_OBJID;

 sts = om$send(msg = message NMedge.NMget_edge_info(&EMmsg, &numed, &ed, 
	&refed, &refsf, &rev, NULL), targetid = my_id);
 if(!(1&EMmsg&sts)) goto wrapup;

 fprintf(stderr, "NM Edge Object:\n\tObjectid %d\n", my_id);
 fprintf(stderr, "\tProps : 0x%x\n", ME.NMedge->props);
 sts = om$send(msg = message NMcreated.NMget_put_creator_id(&EMmsg, 
       &creator, FALSE), targetid = my_id);

 fprintf(stderr, "\tCreator : %d\n", creator);
 if(numed)
  {
   fprintf(stderr, "\tConnected to %d edges\n", numed);
   fprintf(stderr, "\tEdgeid\tReverse Flag\n");
   for(i=0; i<numed; i++)
    {
     fprintf(stderr, "\t%d.%d\t%d", ed[i].osnum, ed[i].objid, rev[i]);
     if(IF_EQ_GRID(ed[i], refed))
      fprintf(stderr, "  (Ref Ed on Ref Sf=%d)\n",refsf.objid);
     else fprintf(stderr, "\n");
    }
  }
 else fprintf(stderr, "** Not connected to any edge\n");

wrapup:

if(ed) om$dealloc(ptr = ed);
if(rev) om$dealloc(ptr = rev);

EMWRAPUP(EMmsg, sts, "NMedge.debug");
return(sts);
}

end implementation NMedge;
