class implementation NMassoctrans;

#define StaticBuf 50

/*
 Changed the StaticBuf value from 10 to 50 to avoid a crash problem
                                  - TR#169307474. - Vadi - 09/11/93.
*/

#include "emsmacros.h"
#include "nddef.h"
#include "OMmacros.h"

extern struct ext_list NDdelete;
extern OMuword OPP_GRcurve_class_id;

method NMtransmigrate(IGRlong *EMmsg; IGRint (**actid_f)();
		      IGRchar **actid_f_args; IGRushort options)
{
 IGRlong 		sts = OM_S_SUCCESS;
 struct GRid		*junk = NULL, *parents = NULL, parentsbuf[StaticBuf], 
			*base_st = NULL, base_stbuf[StaticBuf], my_GRid;
 struct EMSobject_info 	*new_parents = NULL, newparentsbuf[StaticBuf];
 IGRint			count = 0, i, num_base_states = 0, j; 
 IGRboolean		modified = FALSE, orphan = FALSE, onchan;
 unsigned int 	*root_type = NULL, root_typebuf[StaticBuf];
 union EMSparent_info 	*roots = NULL, rootsbuf[StaticBuf];
 IGRint			(**locf)() = NULL;
 IGRchar		**locargs = NULL;

 *EMmsg = EMS_S_Success;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if(!actid_f)
  {
   sts = om$send(msg = message NMassoctrans.NMget_actid_funcs
         (EMmsg, &locf, &locargs), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   actid_f = locf;
   actid_f_args = locargs;
  }

 /* Determine if my parent connections have been modified:

  1) Are all the base_states (whether I transmigrate or not) still valid?
     If not I should delete myself.
  2) Is the number of parents connected to me still the same as the original 
     number specified?
  3) If I transmigrate on a parent, is its active state currently my parent?
 */

 num_base_states = om$dimension_of(varray = ME.NMassoctrans->base_state);
 if(num_base_states > StaticBuf)
  base_st = (struct GRid *) om$malloc(size = num_base_states *
	    sizeof(struct GRid));
 else base_st = base_stbuf;
 EMerr_hndlr(!base_st, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 for(i=0; i<num_base_states; i++)
  {
   sts = NMtag(EMmsg, &base_st[i], &ME.NMassoctrans->base_state[i], FALSE);
   if(IF_NULL_OBJID(base_st[i].objid))
    {
     sts = OM_S_SUCCESS;
     orphan = TRUE;
     goto wrapup;
    }
   else 
    {
     if(NDin_buffer(base_st[i], &NDdelete) != -1)
      {
       /* My base state itself is in the delete batch. Cannot transmigrate.
       */
       sts = OM_S_SUCCESS;
       orphan = TRUE;
       goto wrapup;
      }
    }
  }

 /* Obtain all my parents currently on the channel.
 */
 sts = om$send(mode = OM_e_wrt_message, 
       msg = message NDnodein.NDget_objects(ND_ROOT | ND_IN_BUF, NULL, 
             NULL, &junk, 0, MAXINT, &count), targetid = my_id);
 if(!(1&sts)) goto wrapup;

 /* Capture the data before next call to NDget_objects.
 */
 if(count > StaticBuf)
  {
   parents = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   new_parents = (struct EMSobject_info *) om$malloc(size = count * 
                  sizeof(struct EMSobject_info));
   root_type = (unsigned int *) om$malloc(size = count * 
               sizeof(unsigned int));
   roots = (union EMSparent_info *) om$malloc(size = count *
		sizeof(union EMSparent_info));
  }
 else
  {
   parents = (struct GRid *) parentsbuf;
   new_parents = (struct EMSobject_info *) newparentsbuf;
   root_type = (unsigned int *) root_typebuf;
   roots = (union EMSparent_info *) rootsbuf;
  }

 EMerr_hndlr(!parents || !new_parents || !root_type || !roots, *EMmsg, 
             EMS_E_NoDynamicMemory, wrapup);
 OM_BLOCK_MOVE(junk, parents, count * sizeof(struct GRid));

 for(i=0; i<count; i++) root_type[i] = EMSgrid;
 sts = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL, count, 
       (IGRchar *) parents, root_type, roots), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Number of parents on the channel is different. Therefore things have
    definetely changed.
 */
 if(count != num_base_states) modified = TRUE;

 for(i=0; i<num_base_states; i++)
  {
    /* KLUDGE - if base state is wireframe then the transmigrate flag
		should be false. If it is not then set it to false now.
		This fixes a problem of incorrect initialization done in
		existing files. - ronnie turrentine			*/

    if(EFisAncestryValid(EMmsg, base_st[i].objid, base_st[i].osnum, 
        OPP_GRcurve_class_id, FALSE) && ME.NMassoctrans->transmigrate[i] )
    {
     ME.NMassoctrans->transmigrate[i] = FALSE; 
    }
     
    if(ME.NMassoctrans->transmigrate[i])
    {
     IGRint	(*fptr)();
     IGRchar	*f_args = NULL;

     if(options & NMtrans_SameActidFunc)
      fptr = *actid_f;
     else fptr = actid_f[i];

     if(actid_f_args)
      {
       if(options & NMtrans_SameActidFuncArgs)
        f_args = *actid_f_args;
       else f_args = actid_f_args[i];
      }

     sts = (*fptr)(EMmsg, f_args, &base_st[i], &new_parents[i].grid);

     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else new_parents[i].grid = base_st[i];

   new_parents[i].env = roots[0].grobj.env;
   if(!modified)
    {
     onchan = FALSE;
     for(j=0; j<count; j++)
      if(IF_EQ_GRID(new_parents[i].grid, roots[j].grobj.grid))
       {
	onchan = TRUE;
	break;
       }
      if(!onchan) modified = TRUE;
    }

  } /* for(i=0; i<num_base_states; i++) */

 /* Re-establish parent-child relationship if modified.
 */
 if(modified)
  {
   struct GRvg_construct	construct;
   struct IGRdisplay		disp;
   struct GRmd_env		env;

   construct.display = &disp;
   construct.class_attr = NULL;
   construct.msg = EMmsg;
   construct.env_info = &env;
   EMidmatrix(EMmsg, &env.md_env.matrix_type, env.md_env.matrix);
   env.md_id.osnum = OM_Gw_current_OS;
   env.md_id.objid = NULL_OBJID;

   sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct),
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   construct.newflag = FALSE;

   sts = om$send(msg = message NDnode.NDdisconnect(count, parents), 
         targetid = my_id);
   if(!(1&sts)) goto wrapup;
   
   sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
         EMS_no_const_assoc, NMinitas_NoDuplicateParents, num_base_states, 
         new_parents, 0, NULL, NULL, NULL, NULL, NULL, &construct), 
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   *EMmsg = EMS_I_Modified;
  }

wrapup:

if(locf) 
 sts = om$send(msg = message NMassoctrans.NMfree_actid_funcs
       (EMmsg, &locf, &locargs), targetid = my_id);

if(parents && (parents != parentsbuf)) om$dealloc(ptr = parents);
if(new_parents && (new_parents != newparentsbuf))
  om$dealloc(ptr = new_parents);
if(root_type && (root_type != root_typebuf)) om$dealloc(ptr = root_type);
if(roots && (roots != rootsbuf)) om$dealloc(ptr = roots);
if(orphan && (1&*EMmsg&sts)) *EMmsg = EMS_I_Useless;
EMWRAPUP(*EMmsg, sts, "NMassoctrans.NMtransmigrate");
return(sts);
}

end implementation NMassoctrans;
