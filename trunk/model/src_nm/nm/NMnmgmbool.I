class implementation NMnonmanigm;

#include "OMmacros.h"
#include "nm.h"
#include "grownerdef.h"
#include "emsmacros.h"
#include "EMSasdef.h"
#include "EMSasnuc.h"
#include "ndmacros.h"
#include "EMSopt.h"

#define StaticBuf	10

extern OMuword OPP_EMSsurface_class_id, OPP_NMtrim_class_id, 
               OPP_NMinters_class_id, OPP_NMnonmani_class_id;
extern OMuint OM_Gf_verbose_warning;

from NMinters import NMintersect, NMget_inters, NMprop;
from NMtrim import NMtrim_element;
from EMSsurface import EMputLsIfNotThere;
from GRgrgrp import GRunion;
from NMvertex import NMcheck;
from EMSdpr import EMundo;

method NMperform_boolean(IGRlong *EMmsg;
			  IGRlong error_codes[];
			  struct GRvg_construct *construct;
			  struct GRid vol_op; struct GRmd_env *volenv;
			  IGRint num_nmop;
			  struct GRid *nm_op; struct GRmd_env nmop_env[];
			  enum NMbooltype bool_type; 
			  unsigned short boolopt;
			  IGRchar *status_str; GRobjid *intobj, *auxobj)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct GRid		trim_obj_buf[StaticBuf], *trim_obj = NULL, 
			int_obj_buf[StaticBuf], *int_obj = NULL, my_GRid, 
			actid, volactid;
 struct NMgmSSI		ssi;
 IGRboolean		atleast_one_successful = FALSE, undo_all = FALSE;
 IGRint			i, j;
 IGRboolean		output_inters = FALSE, handle_stop, 
			get_inters = FALSE;
 GRobjid		intobj_loc = NULL_OBJID, auxobj_loc = NULL_OBJID;
 extern 		IGRboolean IGEstop();
 IGRint			NMmerge_graphic_groups();
 IGRchar 		loc_status_str[200], *stsstr = NULL, dot[2];
 struct EMSinters	*nm_inters = NULL, *vol_inters = NULL, 
			*tmpnminters = NULL, *tmpvolinters = NULL;
 struct EMSsftracedata  tracedata[2];
 struct EMSobject_info  int_parents[2], trim_parents[2], *my_parents = NULL, 
			my_parentsbuf[StaticBuf];
 struct GRid		int_base[2], *my_base = NULL, my_basebuf[StaticBuf];
 IGRboolean		int_trans[2], *my_trans = NULL, 
			my_transbuf[StaticBuf], partial_volint = FALSE;
 IGRint			my_numparents = 0;
 IGRdouble		cht, tracetol, *mat;
 IGRshort		mattyp;
 extern OM_S_OBJID	current_creator;
 unsigned short	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 unsigned short 	undo_opt = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
 IGRint 		buff_size = 0, display_count = 0, 
			invoke_count = 0;
 GRobjid 		*display_ids = NULL;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&ssi);

 if(status_str)
  {
   stsstr = loc_status_str;
   strcpy (dot, ".");
  }
 else stsstr = NULL;

 for(i=0; i<2; i++) NMinit_tracedata(&tracedata[i]);

 /* Volume operand must be a surface/composite surface/solid.
 */
 if(!EFisAncestryValid(EMmsg, vol_op.objid, vol_op.osnum, 
                       OPP_EMSsurface_class_id, FALSE))
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }
 else
  {
   sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, 
           &volenv->md_env, NULL, NULL, NULL, NULL), 
           targetid = vol_op.objid, targetos = vol_op.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 /* Non manifold operand for now is restricted to be a surface type.
    Wireframe disallowed for now.
 */
 for(i=0; i<num_nmop; i++)
  {
   if(EFisAncestryValid(EMmsg, nm_op[i].objid, nm_op[i].osnum, 
                       OPP_EMSsurface_class_id, FALSE))
    {
     sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, 
           &volenv->md_env, NULL, NULL, NULL, NULL), 
           targetid = nm_op[i].objid, targetos = nm_op[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
  }

 /* For each volume operand - nm operand pair, create a 
    NMtrim DPR node, create a NMinters information object, establish
    associative connections and do the execution.
 */
 if(num_nmop > StaticBuf)
  {
   if(bool_type != NMbool_split)
    trim_obj =(struct GRid *) om$malloc(size = num_nmop * sizeof(struct GRid));
   int_obj = (struct GRid *) om$malloc(size = num_nmop * sizeof(struct GRid));
   EMerr_hndlr(!trim_obj || !int_obj, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 else
  {
   if(bool_type != NMbool_split)
    trim_obj = trim_obj_buf;
   int_obj = int_obj_buf;
  }

 for(i=0; i<num_nmop; i++)
  {
   if(bool_type != NMbool_split) trim_obj[i].objid = NULL_OBJID;
   int_obj[i].objid = NULL_OBJID;
  }


 boolopt |= EMSsfbool_opt_SingleTopology | EMSsfbool_opt_OpenIntPossible |
           EMSsfbool_opt_IncompleteInt;

 output_inters = boolopt & (EMSsfbool_opt_outinters | EMSsfbool_opt_outaux);
 handle_stop = boolopt & EMSsfbool_opt_HandleStop;

 if(output_inters)
  {
   if(intobj) *intobj = NULL_OBJID;
   if(auxobj) *auxobj = NULL_OBJID;
  }

 mattyp = construct->env_info->md_env.matrix_type;
 mat = construct->env_info->md_env.matrix;

 if(output_inters) get_inters = FALSE;
 else if(bool_type != NMbool_split) get_inters = FALSE;
 else get_inters = TRUE;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 sts = NMget_node(EMmsg, &vol_op, NULL, NULL, NULL, NULL, NULL, &volactid, 
       NULL);
 if(IF_EQ_GRID(my_GRid, volactid)) volactid = vol_op;

 /* If the volume operand is currently not active, a component of it is
    being used as the volume operand.
 */
 if(!(IF_EQ_GRID(vol_op, volactid)))
  partial_volint = TRUE;
 else partial_volint = FALSE;

 for(i=0; i<num_nmop; i++)
  {
   if(handle_stop && IGEstop()) 
    {
     *EMmsg = EMS_I_Interrupt;
     goto next_ele;
    }

   if(stsstr) strcpy(stsstr, status_str);

   intobj_loc = NULL_OBJID;
   auxobj_loc = NULL_OBJID;

   if(bool_type != NMbool_split)
    {
     om$construct(osnum = nm_op[i].osnum, classid = OPP_NMtrim_class_id, 
                  p_objid = &trim_obj[i].objid);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_S_Success, wrapup);
     trim_obj[i].osnum = nm_op[i].osnum;
    }

   om$construct(osnum = construct->env_info->md_id.osnum, 
                classid = OPP_NMinters_class_id, 
                p_objid = &int_obj[i].objid);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_S_Success, wrapup);
   int_obj[i].osnum = nm_op[i].osnum;

   if(partial_volint)
    {
     unsigned char intprops = NMinters_PartialVolInt;
     sts = om$send(msg = message NMinters.NMprop(EMmsg, NMprop_SetOn, 
	   &intprops), targetid = int_obj[i].objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /* Setup associativity information for the NMinters object.
   */
   int_parents[VolOpIdx].grid = vol_op;
   int_parents[VolOpIdx].env = *volenv;
   int_parents[NmOpIdx].grid = nm_op[i];
   int_parents[NmOpIdx].env = nmop_env ? nmop_env[i] : *volenv;
   int_trans[VolOpIdx] = TRUE;
   int_trans[NmOpIdx] = (bool_type == NMbool_split) ? TRUE : FALSE;
   int_base[VolOpIdx] = vol_op;
   int_base[NmOpIdx] = nm_op[i];

   if(bool_type != NMbool_split)
    {
     /* Setup associativity information for the NMtrim object.
     */
     trim_parents[SrcIdx].grid = int_obj[i];
     trim_parents[SrcIdx].env = *(construct->env_info);
     trim_parents[CompIdx].grid = nm_op[i];
     trim_parents[CompIdx].env = nmop_env ? nmop_env[i] : *volenv;
    }

   /* Initialize the intersection object
   */
   sts = om$send(msg = message NMinters.NMintersect(EMmsg, bool_type, boolopt, 
         int_parents, get_inters ? &nm_inters : NULL, 
	 get_inters ? &vol_inters : NULL, get_inters ? &tracedata[0] : NULL, 
         get_inters ? &tracedata[1] : NULL, 
	 output_inters ? NMintersect_NoStoreInters : NULL, construct, 
         output_inters ? &intobj_loc : NULL, 
	 output_inters ? &auxobj_loc : NULL, stsstr), 
         targetid = int_obj[i].objid, targetos = int_obj[i].osnum);
   EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, next_ele);
   if(*EMmsg == EMS_I_Interrupt) goto next_ele;
   if(*EMmsg == EMS_I_NoIntersection) goto next_ele;

   if(output_inters) goto next_ele;

   if(handle_stop && IGEstop()) 
    {
     *EMmsg = EMS_I_Interrupt;
     goto next_ele;
    }

   if(bool_type != NMbool_split)
    {
     /* Execute the trimming operation on the non manifold component.
     */
     sts = om$send(msg = message NMtrim.NMtrim_element(EMmsg, construct->env_info, 
           boolopt, &int_obj[i], &nm_op[i], stsstr, NULL, NULL), 
           targetid = trim_obj[i].objid, targetos = trim_obj[i].osnum);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_IntersectTrim, next_ele);
    }

   /* Make the inters object dependent on the two operands.
   */
   if(partial_volint) int_parents[VolOpIdx].grid = volactid;
   sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
         initas_opt, NMinitas_NoDuplicateParents, 2, int_parents, 2, 
         int_trans, int_base, NULL, NULL, NULL, construct), 
         targetid = int_obj[i].objid, targetos = int_obj[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(bool_type != NMbool_split)
    {
     /* Make the NMtrim object dependent on the NMinters and nm op objects.
     */
     sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg, 
           initas_opt, 2, trim_parents, NULL, NULL, NULL, construct), 
           targetid = trim_obj[i].objid, targetos = trim_obj[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /* Create the non manifold topology (feature loops on the volume component, 
      vertex uses, NMedges etc). If the nm operands are trimmed (as in union
      or intersection), creation of nm topology is defered until after the
      batch has been re-executed. This is because the trimming of those 
      elements could have affected some other operation done previously.
   */
   if(bool_type == NMbool_split)
    {
     if(stsstr)
      {
       strcat(stsstr, dot);
       UI_status(stsstr);
      }

     current_creator = my_id;
     sts = NMcreate_topology(EMmsg, vol_inters, &tracedata[1], construct, 
           NMcreatetp_NonOrientedInput, &ssi);
     if(!(1&*EMmsg&sts))
      {
       undo_all = TRUE;
       goto wrapup;
      }

     /* In case of nm split, create NM topology also on the nm operand.
     */
     if(stsstr)
      {
       strcat(stsstr, dot);
       UI_status(stsstr);
      }
     current_creator = my_id;
     sts = NMcreate_topology(EMmsg, nm_inters, &tracedata[0], construct, 
	   NMcreatetp_NmEdgesConnected | NMcreatetp_NonOrientedInput, &ssi);
     if(!(1&*EMmsg&sts))
      {
       undo_all = TRUE;
       goto wrapup;
      }
    }

   if(nm_inters)
    {
     (void) NMset_object_data_to_null(nm_inters, TRUE, TRUE);
     EMinters_data_free(&rc, nm_inters, MAXINT, NULL, NULL);
     EMinters_free(nm_inters, MAXINT);
     nm_inters = NULL;
    }
   if(vol_inters)
    {
     (void) NMset_object_data_to_null(vol_inters, TRUE, TRUE);
     EMinters_data_free(&rc, vol_inters, MAXINT, NULL, NULL);
     EMinters_free(vol_inters, MAXINT);
     vol_inters = NULL;
    }
   for(j=0; j<2; j++)
    {
     EMsfinttrace_free (&rc, tracedata[j].num_grps,
     tracedata[j].num_subgrps_grp, tracedata[j].num_elems_subgrp, 
     tracedata[j].elems, tracedata[j].subgrp_rev, tracedata[j].elem_rev, 
     tracedata[j].grp_closed, tracedata[j].subgrp_closed);
     NMinit_tracedata(&tracedata[j]);
    }

next_ele:
   if(output_inters)
    {
     if(!IF_NULL_OBJID(intobj_loc))
      {
       if(IF_NULL_OBJID(*intobj)) *intobj = intobj_loc;
       else NMmerge_graphic_groups(*intobj, intobj_loc, construct, intobj);
      }

     if(!IF_NULL_OBJID(auxobj_loc))
      {
       if(IF_NULL_OBJID(*auxobj)) *auxobj = auxobj_loc;
       else NMmerge_graphic_groups(*auxobj, auxobj_loc, construct, auxobj);
      }
    }

   if(!output_inters) error_codes[i] = *EMmsg;
   if(!(1&*EMmsg) || (*EMmsg == EMS_I_NoIntersection) ||
                     (*EMmsg == EMS_I_Interrupt) || output_inters)
    {
     IGRlong rc, junksts;

     /* Cleanup */
     junksts = om$send(msg = message Root.delete(TRUE), 
               targetid = int_obj[i].objid, targetos = int_obj[i].osnum);
     int_obj[i].objid = NULL_OBJID;

     if(bool_type != NMbool_split)
      {
       buff_size = 0;
       display_count = 0;
       invoke_count = 0;
       display_ids = NULL;
       junksts = om$send(msg = message EMSdpr.EMundo(&rc, &undo_opt, 
		 construct->env_info, NULL, NULL, &buff_size, &display_ids, 
		 &display_count, &invoke_count), 
		 targetid = trim_obj[i].objid, targetos = trim_obj[i].osnum);
       trim_obj[i].objid = NULL_OBJID;
      }
  
     if(num_nmop == 1) goto wrapup;	/* Not much left to do */
     if(*EMmsg == EMS_I_Interrupt) goto wrapup;
     *EMmsg = EMS_S_Success;
     sts = OM_S_SUCCESS;
     continue;
    }
   else atleast_one_successful = TRUE;

  } /* for(i=0; i<num_nmop; i++) */

 if(output_inters) goto wrapup;
 EMerr_hndlr(!atleast_one_successful, *EMmsg, EMS_E_Success, wrapup);

 /* If problem after this point, undo everything before exiting.
 */
 undo_all = TRUE;

 /* If the non nm operand was already owned by a nm node, that node
    should reexecute after the nm operand has been trimmed here. Rexecution
    in turn might affect the intersection data.
 */
 if(bool_type != NMbool_split)
  {
   nd$exec_batch();
   for(i=0; i<num_nmop; i++)
    {
     if(IF_NULL_OBJID(int_obj[i].objid)) continue;

     if(nm_inters)
      {
       (void) NMset_object_data_to_null(nm_inters, TRUE, TRUE);
       EMinters_data_free(&rc, nm_inters, MAXINT, NULL, NULL);
       EMinters_free(nm_inters, MAXINT);
       nm_inters = NULL;
      }
     if(vol_inters)
      {
       (void) NMset_object_data_to_null(vol_inters, TRUE, TRUE);
       EMinters_data_free(&rc, vol_inters, MAXINT, NULL, NULL);
       EMinters_free(vol_inters, MAXINT);
       vol_inters = NULL;
      }
     for(j=0; j<2; j++)
      {
       EMsfinttrace_free (&rc, tracedata[j].num_grps,
       tracedata[j].num_subgrps_grp, tracedata[j].num_elems_subgrp, 
       tracedata[j].elems, tracedata[j].subgrp_rev, tracedata[j].elem_rev, 
       tracedata[j].grp_closed, tracedata[j].subgrp_closed);
       NMinit_tracedata(&tracedata[j]);
      }
     sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &nm_inters, 
           &vol_inters, NULL, NULL, NULL, &cht, NULL), 
           targetid = int_obj[i].objid, targetos = int_obj[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!nm_inters || !vol_inters, *EMmsg, EMS_E_Fail, wrapup);

     if(*EMmsg == EMS_I_Modified)
      {
       if(stsstr)
        {
         strcat(stsstr, dot);
         UI_status(stsstr);
        }
       current_creator = my_id;
       sts = NMregenerate_inters(EMmsg, nm_inters, vol_inters, &tmpnminters, 
             &tmpvolinters, cht, construct, &ssi);
       if(!(1&*EMmsg&sts)) goto wrapup;
       EMerr_hndlr(!tmpnminters || !tmpvolinters, *EMmsg, EMS_E_Fail, wrapup);

       (void) NMset_object_data_to_null(nm_inters, TRUE, TRUE);
       EMinters_data_free(&rc, nm_inters, MAXINT, NULL, NULL);
       EMinters_free(nm_inters, MAXINT);
       nm_inters = NULL;

       (void) NMset_object_data_to_null(vol_inters, TRUE, TRUE);
       EMinters_data_free(&rc, vol_inters, MAXINT, NULL, NULL);
       EMinters_free(vol_inters, MAXINT);
       vol_inters = NULL;

       nm_inters = tmpnminters;
       vol_inters = tmpvolinters;
       tmpnminters = NULL;
       tmpvolinters = NULL;
      }

     tracetol = 2*cht;
     for(j=0; j<2; j++)
      {
       EMsfinttrace (EMmsg, &mattyp, mat, j ? vol_inters : nm_inters, 
       NULL, &tracetol, &tracedata[j].num_grps, &tracedata[j].num_subgrps_grp, 
       &tracedata[j].num_elems_subgrp, &tracedata[j].elems, 
       &tracedata[j].subgrp_rev, &tracedata[j].elem_rev, 
       &tracedata[j].grp_closed, &tracedata[j].subgrp_closed);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }

     if(stsstr)
      {
       strcat(stsstr, dot);
       UI_status(stsstr);
      }
     current_creator = my_id;
     sts = NMcreate_topology(EMmsg, vol_inters, &tracedata[1], construct, NULL, 
           &ssi);
     if(!(1&*EMmsg&sts)) goto wrapup;

    } /* for(i=0; i<num_nmop; i++) */

  } /* if(bool_type != NMbool_split) */



 if( (num_nmop * 2 + 1) > StaticBuf)
  {
   my_parents = (struct EMSobject_info *) om$malloc(size = 
               (num_nmop * 2 + 1) * sizeof(struct EMSobject_info));
   my_base = (struct GRid *) om$malloc(size = 
               (num_nmop * 2 + 1) * sizeof(struct GRid));
   my_trans = (IGRboolean *) om$malloc(size = 
               (num_nmop * 2 + 1) * sizeof(IGRboolean));
  }
 else
  {
   my_parents = (struct EMSobject_info *) my_parentsbuf;
   my_base = (struct GRid *) my_basebuf;
   my_trans = (IGRboolean *) my_transbuf;
  }

 EMerr_hndlr(!my_parents || !my_base || !my_trans, *EMmsg, 
 EMS_E_NoDynamicMemory, wrapup);

 my_numparents = 0;

 sts = NMget_node(EMmsg, &vol_op, NULL, NULL, NULL, NULL, NULL, &actid, NULL);
 if(IF_EQ_GRID(my_GRid, actid))
  actid = vol_op;
 my_parents[my_numparents].grid = actid;
 my_parents[my_numparents].env = *volenv;
 my_base[my_numparents] = vol_op;
 my_trans[my_numparents++] = TRUE;

 for(i=0; i<num_nmop; i++)
  {
   if( ((bool_type != NMbool_split) && (IF_NULL_OBJID(trim_obj[i].objid))) ||
       (IF_NULL_OBJID(int_obj[i].objid))) continue;

   sts = NMget_node(EMmsg, bool_type == NMbool_split ? &nm_op[i] : 
         &trim_obj[i], NULL, NULL, NULL, NULL, NULL, &actid, NULL);
   my_parents[my_numparents].grid = actid;
   my_parents[my_numparents].env = nmop_env ? nmop_env[i] : *volenv;
   my_base[my_numparents] = /*nm_op[i]*/actid;
   my_trans[my_numparents++] = TRUE;
  }

 for(i=0; i<num_nmop; i++)
  {
   if( ((bool_type != NMbool_split) && (IF_NULL_OBJID(trim_obj[i].objid))) ||
       (IF_NULL_OBJID(int_obj[i].objid))) continue;

   my_parents[my_numparents].grid = int_obj[i];
   my_parents[my_numparents].env = *(construct->env_info);
   my_base[my_numparents] = int_obj[i];
   my_trans[my_numparents++] = FALSE;
  }

 sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
       initas_opt, NMinitas_NoDuplicateParents, my_numparents, 
       my_parents, my_numparents, my_trans, my_base, NULL, NULL, NULL, construct),
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 ME.NMnonmanigm->bool_type = bool_type;
 ME.NMnonmanigm->num_nmop = num_nmop;
 ME.NMnonmanigm->nmprops = NMgm_Active;

 ME.GRgraphics->properties = construct->properties | GRIS_ASSOCIATIVE |
		             GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 ME.GRflxown->owner_properties = GR_ORPHAN;

 for(i=0; i<ssi.num_vtx; i++)
  {
   sts = om$send(msg = message NMvertex.NMcheck(EMmsg, &ssi, 
	 NMconnect_AddToSSI), 
	 targetid = ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 /* Check for edge coincedency on each affected surfaces.
 */
 current_creator = my_id;
 sts = NMglue_coincedent_edges(EMmsg, &ssi, construct, NULL, stsstr);
 if(!(1&*EMmsg&sts)) goto wrapup;
 
 sts = om$send(msg = message NMnonmanigm.NMput_SSI(EMmsg, &ssi), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<my_numparents; i++)
  {
   unsigned short nmprops = NMgm_Active;

   sts = om$send(msg = message NMnonmanigm.NMprop(EMmsg, NMprop_SetOff, 
	 &nmprops), targetid = my_parents[i].grid.objid, 
	 targetos = my_parents[i].grid.osnum);
   if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 /* Display the affected surfaces on the volume operand.
 */
 {
  unsigned short ssiopt = NMssiact_DrawFlps | NMssiact_DrawVtx;
  sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssiopt, 
        construct->env_info, &ssi), targetid = my_id);
 }


wrapup:

if(!output_inters && (!(1&*EMmsg&sts)) && undo_all)
 {
  IGRlong locsts, locmsg;

  atleast_one_successful = FALSE;
  locsts = om$send(msg = message NMnonmanigm.NMput_SSI(&locmsg, &ssi), 
           targetid = my_id);
  locsts = om$send(msg = message GRowner.GRdrop(&locmsg, construct->env_info), 
           targetid = my_id);

  if(bool_type != NMbool_split)
   for(i=0; i<num_nmop; i++)
    {
     if(IF_NULL_OBJID(trim_obj[i].objid)) continue;
     buff_size = 0;
     display_count = 0;
     invoke_count = 0;
     display_ids = NULL;
     locsts = om$send(msg = message EMSdpr.EMundo(&locmsg, &undo_opt, 
	      construct->env_info, NULL, NULL, &buff_size, &display_ids, 
	      &display_count, &invoke_count), 
	      targetid = trim_obj[i].objid, targetos = trim_obj[i].osnum);
    }

  for(i=0; i<num_nmop; i++)
   {
    if(IF_NULL_OBJID(int_obj[i].objid)) continue;
    locsts = om$send(msg = message Root.delete(TRUE), 
             targetid = int_obj[i].objid, targetos = int_obj[i].osnum);
   }

 }

current_creator = NULL_OBJID;

if(trim_obj && (trim_obj != trim_obj_buf))
  om$dealloc(ptr = trim_obj);
if(int_obj && (int_obj != int_obj_buf))
  om$dealloc(ptr = int_obj);
if(my_parents && (my_parents != my_parentsbuf))
  om$dealloc(ptr = my_parents);
if(my_base && (my_base != my_basebuf))
  om$dealloc(ptr = my_base);
if(my_trans && (my_trans != my_transbuf))
  om$dealloc(ptr = my_trans);


NMfree_ssi(&ssi);

if(nm_inters)
 {
  (void) NMset_object_data_to_null(nm_inters, TRUE, TRUE);
  EMinters_data_free(&rc, nm_inters, MAXINT, NULL, NULL);
  EMinters_free(nm_inters, MAXINT);
  nm_inters = NULL;
 }
if(vol_inters)
 {
  (void) NMset_object_data_to_null(vol_inters, TRUE, TRUE);
  EMinters_data_free(&rc, vol_inters, MAXINT, NULL, NULL);
  EMinters_free(vol_inters, MAXINT);
  vol_inters = NULL;
 }
 for(j=0; j<2; j++)
  EMsfinttrace_free (&rc,tracedata[j].num_grps, tracedata[j].num_subgrps_grp,
   tracedata[j].num_elems_subgrp, tracedata[j].elems, tracedata[j].subgrp_rev, 
   tracedata[j].elem_rev, tracedata[j].grp_closed, tracedata[j].subgrp_closed);

if( !output_inters && (num_nmop > 1) && (*EMmsg != EMS_I_Interrupt))
 if(*EMmsg != EMS_E_Success)
  for(i=0; i<num_nmop; i++)  
   if(atleast_one_successful && !(1&error_codes[i]))
    {
     *EMmsg = EMS_W_Success;
     break;
    }

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NMperform_boolean");
 }
return(sts);
}


end implementation NMnonmanigm;
