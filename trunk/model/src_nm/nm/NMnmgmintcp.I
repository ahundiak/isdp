class implementation NMnonmanigm;

#include "OMmacros.h"
#include "EMSopt.h"
#include "EMcp.h"

#define StaticBuf 10

from EMSsurface import EMintcopy, EMfix_creator_id;
from NMinters import NMintcopy;
from NMvertex import NMintcopy;
from NMedge import NMintcopy;
from NMvertex_use import NMintcopy;
from EMSboundary import EMintcopy, EMfix_creator_id;

extern OMuword OPP_NMnonmanigm_class_id, OPP_EMSsurface_class_id, 
	       OPP_NMinters_class_id;
	
method NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRboolean		copy_exists = FALSE;
 IGRint			num_parents = 0, i, num_base = 0, j, numedgesin, 
			num_copy_parents = 0, num_copy_base = 0;
 struct EMSobject_info  *parents = NULL, parentsbuf[StaticBuf], 
			*copy_parents = NULL, copyparentsbuf[StaticBuf];
 struct GRid		*my_base = NULL, *copy_base = NULL, 
			copybasebuf[StaticBuf], copysf;
 IGRboolean		*my_trans = NULL, *copy_trans = NULL, 
			copytransbuf[StaticBuf];
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 struct GRvg_construct  construct;
 struct IGRdisplay	disp;
 struct GRmd_env	env;
 struct NMgmSSI		my_ssi, copy_ssi;
 struct NMentities	*mynm = NULL, *copynm = NULL;
 IGRboolean 		copymcp = FALSE;
 struct GRmd_env 	mdenvs[2];


 *EMmsg = EMS_S_Success;
 *newobjid = NULL_OBJID;
 NMinit_ssi(&my_ssi);
 NMinit_ssi(&copy_ssi);
 sf_options |= EMS_COPY_ASSOCIATIVE;

 /* If Already copied, exit.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 0, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;
 if(copy_exists) goto wrapup;

 sts = om$construct_and_copy(object = me, osnum = new_mdenv->md_id.osnum, 
       p_objid = newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Add myself to the list.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 3, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;

 parents = parentsbuf;
 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       StaticBuf, &num_parents), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!num_parents) goto wrapup;

 sts = om$send(msg = message NMassoctrans.NMget_trans_info(EMmsg, &my_trans, 
       &my_base, &num_base), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(num_parents > StaticBuf)
  copy_parents = (struct EMSobject_info *) om$malloc(size = num_parents *
		 sizeof(struct EMSobject_info));
 else
  copy_parents = copyparentsbuf;
 EMerr_hndlr(!copy_parents, *EMmsg, EMS_E_NoDynamicMemory, wrapup);


 /* Copy all the parents and base states if necessary.
 */
 for(i=0; i<num_parents; i++)
  {
   copy_parents[num_copy_parents] = parents[i];
   copy_parents[num_copy_parents].grid.objid = NULL_OBJID;

   if(EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
      OPP_NMnonmanigm_class_id, TRUE))
     sts = om$send(msg = message NMnonmanigm.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, &copy_parents[num_copy_parents++].grid.objid, copy_info,
	   nm_opt, bdry_options, sf_options), 
	   targetid = parents[i].grid.objid);
	
   else if(EFisAncestryValid(EMmsg, parents[i].grid.objid, 
           parents[i].grid.osnum, OPP_NMinters_class_id, TRUE))
     sts = om$send(msg = message NMinters.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, &copy_parents[num_copy_parents++].grid.objid, copy_info,
	   nm_opt, bdry_options, sf_options), 
	   targetid = parents[i].grid.objid);
	
   else if(EFisAncestryValid(EMmsg, parents[i].grid.objid, 
           parents[i].grid.osnum, OPP_EMSsurface_class_id, TRUE))
    {
     copy_exists = FALSE;
     EMcpsearch (EMmsg, parents[i].grid.objid, 
	         &copy_parents[num_copy_parents].grid.objid, 
		 copy_info, 0, &copy_exists);
     if(!(1&*EMmsg)) goto wrapup;
     if(!copy_exists)
      {
       sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
	     new_mdenv, &copy_parents[num_copy_parents].grid.objid, 
	     copy_info, bdry_options, sf_options), 
	     targetid = parents[i].grid.objid);
       if(!(1&*EMmsg)) goto wrapup;
       sts = om$send(msg = message EMSsurface.EMfix_creator_id(EMmsg, 
             copy_info, NULL_OBJID, NULL), 
	     targetid = copy_parents[num_copy_parents].grid.objid, 
	     targetos = new_mdenv->md_id.osnum);
      }
     num_copy_parents++;
    }
/************************
   else
    {
     *EMmsg = EMS_E_InvalidCase;
     goto wrapup;
    }
***********************/
   if(!(1&*EMmsg&sts)) goto wrapup;
  }


 if(num_base > StaticBuf)
  {
   copy_base = (struct GRid *) om$malloc(size = num_base *
		 sizeof(struct GRid));
   copy_trans = (IGRboolean *) om$malloc(size = num_base *
		 sizeof(IGRboolean));
  }
 else
  {
   copy_base = copybasebuf;
   copy_trans = copytransbuf;
  }
 EMerr_hndlr(!copy_base || !copy_trans, *EMmsg, EMS_E_NoDynamicMemory, wrapup);


 for(i=0; i<num_base; i++)
  {
   copy_base[num_copy_base].objid = NULL_OBJID;
   copy_base[num_copy_base].osnum = new_mdenv->md_id.osnum;
   copy_trans[num_copy_base] = my_trans[i];

   if(EFisAncestryValid(EMmsg, my_base[i].objid, my_base[i].osnum, 
      OPP_NMnonmanigm_class_id, TRUE))
     sts = om$send(msg = message NMnonmanigm.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, &copy_base[num_copy_base++].objid, copy_info, nm_opt, 
	   bdry_options, sf_options), targetid = my_base[i].objid);

   else if(EFisAncestryValid(EMmsg, my_base[i].objid, 
           my_base[i].osnum, OPP_NMinters_class_id, TRUE))
     sts = om$send(msg = message NMinters.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, &copy_base[num_copy_base++].objid, copy_info, nm_opt, 
	   bdry_options, sf_options), targetid = my_base[i].objid);
	
   else if(EFisAncestryValid(EMmsg, my_base[i].objid, 
           my_base[i].osnum, OPP_EMSsurface_class_id, TRUE))
     sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
	   new_mdenv, &copy_base[num_copy_base++].objid, copy_info, 
	   bdry_options, sf_options), targetid = my_base[i].objid);
/*******************
   else
    {
     *EMmsg = EMS_E_InvalidCase;
     goto wrapup;
    }
*******************/
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 construct.display = &disp;
 construct.class_attr = NULL;
 construct.msg = EMmsg;
 construct.env_info = &env;
 env = *new_mdenv;

 sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;

 sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
       initas_opt, NMinitas_NoDuplicateParents, num_copy_parents, 
       copy_parents, num_copy_base, copy_trans, copy_base, NULL, NULL, NULL, 
       &construct), targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;


 /* Now copy all the SSI stuff.
 */
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

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &my_ssi, NULL), 
	targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<my_ssi.num_vtx; i++)
  {
   sts = NMsetUpSSI(EMmsg, NULL, &copy_ssi, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$send(msg = message NMvertex.NMintcopy(EMmsg, obj_env, new_mdenv, 
         &copy_ssi.vtx[copy_ssi.num_vtx++], copy_info, nm_opt, bdry_options, 
         sf_options), targetid = my_ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
   copy_ssi.vtxbufsize--;
  }


 for(i=0; i<my_ssi.num_nmedges; i++)
  {
   sts = NMsetUpSSI(EMmsg, NULL, &copy_ssi, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$send(msg = message NMedge.NMintcopy(EMmsg, obj_env, new_mdenv, 
         &copy_ssi.nmedges[copy_ssi.num_nmedges++], copy_info, nm_opt, 
	 bdry_options, sf_options), targetid = my_ssi.nmedges[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
   copy_ssi.nmedgesbufsize--;
  }

 for(i=0; i<my_ssi.num_sfs; i++)
  {
   mynm = &my_ssi.nmentities[i];
   copysf.osnum = new_mdenv->md_id.osnum;
   sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
         new_mdenv, &copysf.objid, copy_info,
         bdry_options, sf_options), targetid = mynm->sfid.objid);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);
   if(!(1&*EMmsg&sts)) goto wrapup;

   for(j=0; j<mynm->num_flps; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->flps[copynm->num_flps], copy_info), 
	   targetid = mynm->flps[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     sts = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg, 
	   copy_info, *newobjid, NULL), 
	   targetid = copynm->flps[copynm->num_flps++]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->flpsbufsize--;
    }

   for(j=0; j<mynm->num_vtxuses; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message NMvertex_use.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, 
           &copynm->vtxuses[copynm->num_vtxuses++], copy_info, nm_opt, 
	   bdry_options, sf_options), targetid = mynm->vtxuses[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->vtxusebufsize--;
    }

   for(j=0; j<mynm->num_edges; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->edges[copynm->num_edges], copy_info), 
	   targetid = mynm->edges[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg, 
	   copy_info, *newobjid, NULL), 
	   targetid = copynm->edges[copynm->num_edges++]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->edgesbufsize--;
    }

   numedgesin = 0;
   for(j=0; j<mynm->numedgesout; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->edgesout[copynm->numedgesout], copy_info), 
	   targetid = mynm->edgesout[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;

     copynm->numedgesin[copynm->numedgesout] = mynm->numedgesin[j];
     copynm->numedgesout++;
     copynm->edgesoutbufsize--;
     numedgesin += mynm->numedgesin[j];
    }

   for(j=0; j<numedgesin; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->edgesin[j], copy_info), 
	   targetid = mynm->edgesin[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     sts = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg, 
	   copy_info, *newobjid, NULL), 
	   targetid = copynm->edgesin[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->edgesinbufsize--;
    }


   for(j=0; j<mynm->numedgesrev; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->edgesrev[copynm->numedgesrev++], copy_info), 
	   targetid = mynm->edgesrev[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->edgesrevbufsize--;
    }


   for(j=0; j<mynm->numedcon; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->edcon[copynm->numedcon], copy_info), 
	   targetid = mynm->edcon[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message NMedge.NMintcopy(EMmsg, obj_env, new_mdenv, 
           &copynm->nmedgescon[copynm->numedcon++], copy_info, nm_opt, 
	   bdry_options, sf_options), targetid = mynm->nmedgescon[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->edconbufsize--;
    }


   for(j=0; j<mynm->numeddiscon; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->eddiscon[copynm->numeddiscon], copy_info), 
	   targetid = mynm->eddiscon[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message NMedge.NMintcopy(EMmsg, obj_env, new_mdenv, 
           &copynm->nmedgesdiscon[copynm->numeddiscon++], copy_info, nm_opt, 
	   bdry_options, sf_options), targetid = mynm->nmedgesdiscon[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     copynm->eddisconbufsize--;
    }

   for(j=0; j<mynm->numvtxusechg; j++)
    {
     sts = NMsetUpSSI(EMmsg, &copysf, &copy_ssi, &copynm);	
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message NMvertex_use.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, 
           &copynm->vtxusechg[copynm->numvtxusechg], copy_info, nm_opt, 
	   bdry_options, sf_options), targetid = mynm->vtxusechg[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;

     if(IF_NULL_OBJID(mynm->origedges[j]))
      copynm->origedges[copynm->numvtxusechg] = NULL_OBJID;
     else
      {
       sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
             obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	     copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
             &copynm->origedges[copynm->numvtxusechg], copy_info), 
	     targetid = mynm->origedges[j]);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
           obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	   copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC, 
           &copynm->repledges[copynm->numvtxusechg], copy_info), 
	   targetid = mynm->repledges[j]);
     if(!(1&*EMmsg&sts)) goto wrapup;

     copynm->numvtxusechg++;
     copynm->vtxusechgbufsize--;
    }

  } /* for(i=0; i<my_ssi.num_sfs; i++) */


 sts = om$send(msg = message NMnonmanigm.NMput_SSI(EMmsg, &copy_ssi), 
       targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;




wrapup:
if(parents && (parents != parentsbuf)) om$dealloc(ptr = parents);
if(copy_parents && (copy_parents != copyparentsbuf)) 
  om$dealloc(ptr = copy_parents);
if(my_trans) om$dealloc(ptr = my_trans);
if(copy_trans && (copy_trans != copytransbuf)) om$dealloc(ptr = my_trans);
if(my_base) om$dealloc(ptr = my_base);
if(copy_base && (copy_base != copybasebuf)) om$dealloc(ptr = copy_base);
NMfree_ssi(&my_ssi);
NMfree_ssi(&copy_ssi);

EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NMintcopy");
return(sts);
}
end implementation NMnonmanigm;
