class implementation NMvertex_use;

#include "OMmacros.h"
#include "godef.h"

method debug()
{
 IGRlong 		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 OM_S_CHANSELECT	to_vtx;
 IGRint			i, numeds = 0;
 OMuint			count;
 OM_S_OBJECT_LINKAGE	junk;
 GRobjid		sfid = NULL_OBJID, *eds = NULL, creator = NULL_OBJID;

 fprintf(stderr, "NM Vertex Use Object:\n\tObjectid %d\n", my_id);
 fprintf(stderr, "\tVertex Use Properties: 0x%x\n", ME.NMvertex_use->props);

 sts = om$send(msg = message NMcreated.NMget_put_creator_id(&EMmsg, 
       &creator, FALSE), targetid = my_id);

 fprintf(stderr, "\tCreator : %d\n", creator);

 NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtx, 
       count = &count);
 if(!(1&sts)) goto wrapup;

 if(count)
  {
   sts = om$get_channel_objects(object = me, p_chanselect = &to_vtx, 
         list = &junk, size = 1,  count = &count);
   if(!(1&sts)) goto wrapup;
   fprintf(stderr, "\tConnected to vertex %d.%d\n", junk.osnum, junk.S_objid);
  }
 else
  fprintf(stderr, "\t**** Not Connected to any vertex ****\n");

 fprintf(stderr, "\tUV point: %lf  %lf\n", ME.NMvertex_use->point[0], 
         ME.NMvertex_use->point[1]);

 sts = om$send(msg = message NMvertex_use.NMget_incedence_info(&EMmsg, 
       NULL_OBJID, &numeds, &eds, NULL, NULL, NULL, NULL, NULL), 
       targetid = my_id);

 if( ((i = om$dimension_of(varray = ME.NMvertex_use->edloc)) != numeds))
  {
   fprintf(stderr, "\t **** Edge count out of sync -\n");
   fprintf(stderr, "\t\t Instance Data count: %d\n", i);
   fprintf(stderr, "\t\t Channel count: %d\n", count);
  }
 else
  {
   sts = om$send(msg = message NMvertex_use.NMgetsurface_info(&EMmsg, &sfid, 
	 NULL), targetid = my_id);
	
   fprintf(stderr, "\tConnected to %d edges on surf %d\n", 
	   numeds, sfid);
   if(eds)
    for(i=0; i<numeds; i++)
     fprintf(stderr, "\t\t%d\n", eds[i]);
   else fprintf(stderr, "\tCould not get edge ids\n");
  }

 fprintf(stderr, "\tEdloc instance data array - \n");
 for(i=0; i<numeds; i++)
  fprintf(stderr, "\t\t%d) %d\n", i, ME.NMvertex_use->edloc[i]);

wrapup:
if(eds) om$dealloc(ptr = eds);
return(sts);
}

end implementation NMvertex_use;
