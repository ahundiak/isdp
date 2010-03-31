class implementation NMvertex;

#include "OMmacros.h"
#include "godef.h"

from NMvertex_use import NMgetsurface_info;

method debug()
{
 IGRlong 		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 OM_S_CHANSELECT	to_vtx_uses;
 IGRint			i;
 OMuint			count;
 OM_S_OBJECT_LINKAGE	*junk = NULL;
 IGRdouble		*xyzpt;
 GRobjid		creator = NULL_OBJID, sfid;

 xyzpt = ME.GR3dpoint->point;
 fprintf(stderr, "NM Vertex Object:\n\tObjectid %d\n", my_id);
 fprintf(stderr, "\tXYZ Point-\n\t\t%lf %lf %lf\n", 
         xyzpt[0], xyzpt[1], xyzpt[2]);
 fprintf(stderr, "\tGraphics Properties: 0x%x\n", (IGRushort)ME.GRgraphics->properties);
 fprintf(stderr, "\tVertex Properties: 0x%x\n", ME.NMvertex->props);
 
 sts = om$send(msg = message NMcreated.NMget_put_creator_id(&EMmsg, 
       &creator, FALSE), targetid = my_id);

 fprintf(stderr, "\tCreator : %d\n", creator);

 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtx_uses);

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtx_uses, 
       count = &count);
 if(!(1&sts)) goto wrapup;

 fprintf(stderr, "\tConnected to %d vertex uses--\n", count);

 junk = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count * 
                                          sizeof(OM_S_OBJECT_LINKAGE));
 if(!junk) goto wrapup;
 sts = om$get_channel_objects(object = me, p_chanselect = &to_vtx_uses, 
       list = junk, size = count, count = &count);
 if(!(1&sts)) goto wrapup;

 fprintf(stderr, "\tVertex Use\tOn Surf\n");

 for(i=0; i<count; i++)
  {
   sfid = NULL_OBJID;
   sts = om$send(msg = message NMvertex_use.NMgetsurface_info(&EMmsg, 
         &sfid, NULL), targetid = junk[i].S_objid);
   fprintf(stderr, "\t%d.%d\t\t%d.%d\n", junk[i].osnum, junk[i].S_objid, 
	   junk[i].osnum, sfid);
  }

wrapup:
if(junk) om$dealloc(ptr = junk);
return(sts);
}

end implementation NMvertex;
