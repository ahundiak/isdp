class implementation NMedge;

#include "OMmacros.h"
#include "EMSopt.h"

#define StaticBuf 10

from EMSboundary import EMintcopy;
from EMSsurface import EMintcopy;

method NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRboolean		copy_exists = FALSE, *reverse = NULL;
 struct GRid		*myedges = NULL, *copyedges = NULL, 
			copyedbuf[StaticBuf], refedge, refsf, copy_refsf;
 IGRint			i, numedges = 0;
 GRobjid		my_creator = NULL_OBJID, copy_creator = NULL_OBJID;

 *EMmsg = EMS_S_Success;
 *newobjid = NULL_OBJID;

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

 sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, 
       &numedges, &myedges, &refedge, &refsf, &reverse, NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!numedges) goto wrapup;

 EMerr_hndlr(!IF_EQ_OBJID(refedge.objid, myedges[0].objid), *EMmsg, 
	     EMS_E_Fail, wrapup);
	
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
    copyedges = (struct GRid *) om$malloc(size = numedges * 
	        sizeof(struct GRid));
   else
    copyedges = copyedbuf;
   EMerr_hndlr(!copyedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   for(i=0; i<numedges; i++)   
    {
     copyedges[i].osnum = myedges[i].osnum;
     copy_exists = FALSE;
     EMcpsearch(EMmsg, myedges[i].objid, &copyedges[i].objid, copy_info, 1, 
     &copy_exists);
     if(!copy_exists)
      {
       sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
	     obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	     copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
	     &copyedges[i].objid, copy_info), targetid = myedges[i].objid);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
    }

   copy_refsf.osnum = refsf.osnum;
   copy_exists = FALSE;
   EMcpsearch(EMmsg, refsf.objid, &copy_refsf.objid, copy_info, 1, 
   &copy_exists);
   if(!copy_exists)
    {
     sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
           new_mdenv, &copy_refsf.objid, copy_info, bdry_options, sf_options), 
           targetid = refsf.objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   sts = om$send(msg = message NMedge.NMconnect_edges(EMmsg, numedges, 
         copyedges, &copy_refsf, reverse, new_mdenv, NULL, NULL), 
         targetid = *newobjid);
   if(!(1&*EMmsg&sts)) goto wrapup;

  } /* if(numedges) */

wrapup:
if(myedges) om$dealloc(ptr = myedges);
if(reverse) om$dealloc(ptr = reverse);
if(copyedges && (copyedges != copyedbuf)) om$dealloc(ptr = copyedges);

EMWRAPUP(*EMmsg, sts, "NMedge.NMintcopy");
return(sts);
}

end implementation NMedge;
