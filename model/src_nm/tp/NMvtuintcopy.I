class implementation NMvertex_use;

#include "OMmacros.h"
#include "EMSopt.h"

#define StaticBuf 10

from NMvertex import NMintcopy, NMconnect_vertex_uses;
from EMSboundary import EMintcopy;

method NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRboolean		copy_exists = FALSE;
 struct GRid		myvtx, copyvtx;
 GRobjid		*myedges = NULL, *copyedges = NULL, 
			copyedbuf[StaticBuf];
 IGRint			i, numedges;
 enum EMScvinttype	*loconedge = NULL;
 IGRdouble		uvpt[2], xyzpt[3];
 struct GRid		myGRid, copyGRid;
 GRobjid		my_creator = NULL_OBJID, copy_creator = NULL_OBJID;

 *EMmsg = EMS_S_Success;
 *newobjid = NULL_OBJID;
 myvtx.objid = copyvtx.objid = NULL_OBJID;

 /* If Already copied, exit.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 0, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;
 if(copy_exists) goto wrapup;

 sts = om$construct_and_copy(object = me, osnum = new_mdenv->md_id.osnum, 
       p_objid = newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Following message to adjust instance data on the copy, untill some
    edges are actually connected to it.
 */
 sts = om$send(msg = message NDnode.NDdisconnect(NULL, NULL), 
       targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Add myself to the list.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 3, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;

 /* Set up the creator id of the copy.
 */
 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &my_creator, FALSE), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!IF_NULL_OBJID(my_creator))
  {
   EMcpsearch (EMmsg, my_creator, &copy_creator, copy_info, 0, &copy_exists);
   if(!(1&*EMmsg)) goto wrapup;
   EMerr_hndlr(!copy_exists, *EMmsg, EMS_E_InvalidCase, wrapup);
  }
 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &copy_creator, TRUE), targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 myGRid.osnum = copyGRid.osnum = OM_Gw_current_OS; /* This ain't right */
 myGRid.objid = my_id;
 copyGRid.objid = *newobjid;

 /* 
  The vtxuse's copy needs to be connected to the appropriate edges and
  the appropriate vertex.
 */
 sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
       NULL_OBJID, &numedges, &myedges, &loconedge, &myvtx, uvpt, xyzpt, 
       NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Vertex processing.
 */
 if(!IF_NULL_OBJID(myvtx.objid))
  {
   copyvtx.osnum = myvtx.osnum;		/* This ain't right */
   copy_exists = FALSE;
   EMcpsearch(EMmsg, myvtx.objid, &copyvtx.objid, copy_info, 1, &copy_exists);

   if(!copy_exists)
    {
     sts = om$send(msg = message NMvertex.NMintcopy(EMmsg, obj_env, new_mdenv, 
           &copyvtx.objid, copy_info, nm_opt, bdry_options, sf_options), 
           targetid = myvtx.objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, 1, 
         &copyGRid, xyzpt, NULL, NMconnect_NoChecks), 
         targetid = copyvtx.objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }


 /* Edge processing.
 */
 if(numedges)
  {
   IGRboolean copymcp;
   struct GRmd_env mdenvs[2];

   if (obj_env->md_id.osnum == new_mdenv->md_id.osnum)
    {
     /*
      * The object space in which the copy is to be placed is the
      * same as this object's object-space. Therefore, it is possible
      * to copy any model-space geometry associated with the loopset.
      * (This is currently a restriction that must be satisfied).
      * The old and the new module environments are put into an
      * array as elements 0 and 1, respectively.
     */

     OM_BLOCK_MOVE (obj_env, &mdenvs[0], sizeof (struct GRmd_env));
     OM_BLOCK_MOVE (new_mdenv, &mdenvs[1], sizeof (struct GRmd_env));
     copymcp = TRUE;
    }
   else
    copymcp = FALSE;

   if(numedges > StaticBuf)
    copyedges = (GRobjid *) om$malloc(size = numedges * sizeof(GRobjid));
   else
    copyedges = copyedbuf;
   EMerr_hndlr(!copyedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   for(i=0; i<numedges; i++)   
    {
     copy_exists = FALSE;
     EMcpsearch(EMmsg, myedges[i], &copyedges[i], copy_info, 1, &copy_exists);
     if(!copy_exists)
      {
       sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
	     obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	     copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
	     &copyedges[i], copy_info), targetid = myedges[i]);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
    }

   sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, numedges, 
         copyedges, loconedge, uvpt, NMconnect_NoChecks, NULL), 
         targetid = *newobjid);
   if(!(1&*EMmsg&sts)) goto wrapup;

  } /* if(numedges) */

wrapup:
if(myedges) om$dealloc(ptr = myedges);
if(loconedge) om$dealloc(ptr = loconedge);
if(copyedges && (copyedges != copyedbuf)) om$dealloc(ptr = copyedges);

EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMintcopy");
return(sts);
}

end implementation NMvertex_use;
