class implementation NMinters;

#include "EMSopt.h"

#define StaticBuf 10


from EMSsurface import EMintcopy;
from EMSboundary import EMfix_creator_id, EMintcopy;

method NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 IGRboolean		copy_exists = FALSE;
 OM_S_CHANSELECT	to_other_int;
 struct EMSinters	*inters[2], *copy_inters[2], *this_inters = NULL;
 struct EMSobject_info	my_op[2], copy_op[2];
 IGRint			num_inters = 0, i, num_base = 0, numed = 0;
 struct GRid		*origsf = NULL, origsfbuf[StaticBuf], 
			*copysf = NULL, copysfbuf[StaticBuf], 
			*origed = NULL, origedbuf[StaticBuf], 
			*copyed = NULL, copyedbuf[StaticBuf];
 struct GRvg_construct  construct;
 struct IGRdisplay	disp;
 struct GRmd_env	env;
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 IGRboolean		copy_trans[2], *my_trans = NULL, copymcp = FALSE;
 struct GRid		copy_base[2], *my_base = NULL;
 struct EMSintobj	*this_intobj;
 struct EMSdataselect	*this_data;
 struct EMSsfintedpar	*this_edpar;
 struct GRmd_env 	mdenvs[2];

 *EMmsg = EMS_S_Success;
 for(i=0; i<2; i++)
  {
   inters[i] = NULL;
   copy_inters[i] = NULL;
  }

 NMmake_chanselect(NMinters_to_other_int, &to_other_int);
 *newobjid = NULL_OBJID;

 /* If Already copied, exit.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 0, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;

 if(copy_exists) goto wrapup;

 construct.display = &disp;
 construct.class_attr = NULL;
 construct.msg = EMmsg;
 construct.env_info = &env;
 env = *new_mdenv;

 sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;

 /* Copy myself. 
    Copy the intersection data. 
    Deposit the copied intersection data in the copied intersection object.
 */

 sts = om$construct_and_copy(object = me, osnum = new_mdenv->md_id.osnum, 
       p_objid = newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 3, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;

 sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
       &inters[1], my_op, NULL, NULL, NULL, NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

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

 /* For every surface on which the intersection exists, search for its
    copyid. If the copy is not found, copy that surface and add it to the
    list. The edges on which the intersection data is incedent are also
    copied.
 */
 for(i=0; i<2; i++)
  {
   if(origsf && (origsf != origsfbuf)) om$dealloc(ptr = origsf);
   if(origed && (origed != origedbuf)) om$dealloc(ptr = origed);
   if(copysf && (copysf != copysfbuf)) om$dealloc(ptr = copysf);
   if(copyed && (copyed != copyedbuf)) om$dealloc(ptr = copyed);
   origsf = NULL;
   copysf = NULL;
   origed = NULL;
   copyed = NULL;

   this_inters = inters[i];
   num_inters = 0;
   numed = 0;
   while(this_inters)  
    {
     num_inters++;
     this_intobj = this_inters->cvs;
     while(this_intobj)
      {
       this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
       while(this_edpar)
        {
	 if(!IF_NULL_OBJID(this_edpar->edgeid)) numed++;
	 this_edpar = this_edpar->next;
        }
       this_intobj = this_intobj->next;
      }
     this_inters = this_inters->next;
    }

   if(num_inters > StaticBuf)
    {
     origsf = (struct GRid *) om$malloc(size = num_inters * 
	      sizeof(struct GRid));
     copysf = (struct GRid *) om$malloc(size = num_inters * 
	      sizeof(struct GRid));
    }
   else
    {
     origsf = origsfbuf;
     copysf = copysfbuf;
    }
   EMerr_hndlr(!origsf||!copysf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   if(numed > StaticBuf)
    {
     origed = (struct GRid *) om$malloc(size = numed * sizeof(struct GRid));
     copyed = (struct GRid *) om$malloc(size = numed * sizeof(struct GRid));
    }
   else
    {
     origed = origedbuf;
     copyed = copyedbuf;
    }
   EMerr_hndlr(!origed||!copyed, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   this_inters = inters[i];
   num_inters = 0;
   numed = 0;
   while(this_inters)  
    {
     origsf[num_inters] = this_inters->this_obj;
     copysf[num_inters].objid = NULL_OBJID;
     copysf[num_inters].osnum = new_mdenv->md_id.osnum;

     /* Search for this surface's copy. If not found copy it.
     */
     copy_exists = FALSE;
     EMcpsearch(EMmsg, this_inters->this_obj.objid, &copysf[num_inters].objid, 
     copy_info, 1, &copy_exists);
     if(!(1&*EMmsg)) goto wrapup;

     if(!copy_exists)
      {
       sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
	     new_mdenv, &copysf[num_inters].objid, copy_info, bdry_options, 
	     sf_options), 
	     targetid = this_inters->this_obj.objid);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     num_inters++;

     this_intobj = this_inters->cvs;
     while(this_intobj)
      {
       this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
       while(this_edpar)
        {
	 if(!IF_NULL_OBJID(this_edpar->edgeid))
	  {
           origed[numed].objid = this_edpar->edgeid;
           origed[numed].osnum = this_inters->this_obj.osnum;
           copyed[numed].objid = NULL_OBJID;
           copyed[numed].osnum = new_mdenv->md_id.osnum;
           copy_exists = FALSE;
           EMcpsearch(EMmsg, this_edpar->edgeid, &copyed[numed].objid, 
           copy_info, 1, &copy_exists);
           if(!(1&*EMmsg)) goto wrapup;
           if(!copy_exists)
            {
             sts = om$send(msg = message EMSboundary.EMintcopy(EMmsg, mdenvs, 
	     obj_env->md_id.osnum, new_mdenv->md_id.osnum, 
	     copymcp ? bdry_options : bdry_options | EMS_COPY_NOMSC,
	     &copyed[numed].objid, copy_info), 
	     targetid = this_edpar->edgeid);
             if(!(1&*EMmsg&sts)) goto wrapup;
            }
           numed++;
	  }
	
	 this_edpar = this_edpar->next;
        }
       this_intobj = this_intobj->next;
      }
     this_inters = this_inters->next;
    }



   /* Copy the intersection data.
   */
   sts = EMdupinters(EMmsg, &inters[i], &copy_inters[i], TRUE, FALSE, NULL, 
	 NULL, FALSE, obj_env, &construct, origsf, copysf, num_inters, origed, 
	 copyed, numed);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* Set my copy as the creator id on all the copied edges.
   */
   this_inters = copy_inters[i];
   while(this_inters)  
    {
     this_intobj = this_inters->cvs;
     while(this_intobj)
      {
       this_data = &this_intobj->this_uvintobj;
       if(this_data->datatype == EMSdata_object)
        {
	 sts = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg, 
	       copy_info, *newobjid, NULL), 
	       targetid = this_data->data.object->objid);
	 if(!(1&*EMmsg&sts)) goto wrapup;
        }
       this_intobj = this_intobj->next;
      }
     this_inters = this_inters->next;
    }

  } /* for(i=0; i<2; i++) */

 /* Deposit the copied intersection data into my copy.
 */
 sts = om$send(msg = message NMinters.NMput_inters(EMmsg, copy_inters[0], 
	 copy_inters[1], NULL, NULL, NULL, NMputint_StoreOther), 
	 targetid = *newobjid);
	
 if(!(1&*EMmsg&sts)) goto wrapup;


 sts = om$send(msg = message NMassoctrans.NMget_trans_info(EMmsg, &my_trans, 
       &my_base, &num_base), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(num_base != 2, *EMmsg, EMS_E_InvalidCase, wrapup);

 /* Connect my copy to the copies of my operands.
 */
 for(i=0; i<2; i++)
  {
   copy_op[i] = my_op[i];
   copy_op[i].grid.objid = NULL_OBJID;
   copy_exists = FALSE;
   EMcpsearch(EMmsg, my_op[i].grid.objid, &copy_op[i].grid.objid, 
   copy_info, 1, &copy_exists);
   if(!(1&*EMmsg)) goto wrapup;
   if(!copy_exists)
    {
     sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
           new_mdenv, &copy_op[i].grid.objid, copy_info, bdry_options, 
           sf_options), targetid = my_op[i].grid.objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   copy_trans[i] = my_trans[i];
   copy_base[i].osnum = my_base[i].osnum;

   EMcpsearch(EMmsg, my_base[i].objid, &copy_base[i].objid, 
   copy_info, 1, &copy_exists);
   if(!(1&*EMmsg)) goto wrapup;
   if(!copy_exists)
    {
     sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_env, 
           new_mdenv, &copy_base[i].objid, copy_info, bdry_options, 
           sf_options), targetid = my_base[i].objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

  } /* for(i=0; i<2; i++) */

 sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
       initas_opt, NMinitas_NoDuplicateParents, 2, copy_op, 2, 
       copy_trans, copy_base, NULL, NULL, NULL, &construct), 
       targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
if(origsf && (origsf != origsfbuf)) om$dealloc(ptr = origsf);
if(copysf && (copysf != copysfbuf)) om$dealloc(ptr = copysf);
if(origed && (origed != origedbuf)) om$dealloc(ptr = origed);
if(copyed && (copyed != copyedbuf)) om$dealloc(ptr = copyed);
if(my_trans) om$dealloc(ptr = my_trans);
if(my_base) om$dealloc(ptr = my_base);
for(i=0; i<2; i++)
 {
  if(inters[i])
   {
    (void) NMset_object_data_to_null(inters[i], TRUE, TRUE);
    EMinters_data_free(&rc, inters[i], MAXINT, NULL, NULL);
    EMinters_free(inters[i], MAXINT);
   }
  if(copy_inters[i])
   {
    (void) NMset_object_data_to_null(copy_inters[i], TRUE, TRUE);
    EMinters_data_free(&rc, copy_inters[i], MAXINT, NULL, NULL);
    EMinters_free(copy_inters[i], MAXINT);
   }
 }

EMWRAPUP(*EMmsg, sts, "NMinters.NMintcopy");
return(sts);
}

end implementation NMinters;
