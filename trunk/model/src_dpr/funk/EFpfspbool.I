/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

 #include "emssfintdef.h"
 #include "EMSdef.h" /*for EMparms struct */

 extern OMuword  OPP_EMSslboolean_class_id, OPP_EMSsfboolean_class_id;
 /* pathway flags */
 extern IGRboolean _pathway_trim, _pathway_orient;

/*
 ABSTRACT
          This following function peforms a boolean operation such that
	      only user defined portions are kept. This is used in 
	      trimming/extending/diff/union/intersection operations.
	      The associated function(s) are in file EFspboolsup.I (for both
              EFperform_special_boolean_mod AND EFperform_special_boolean,
              (the OLD function and the REWRITTEN function respectively).

 HISTORY
        NP    09/09/93     Allow "num_bad_pts" and "bad_pts_info" to be NULL.
                           Changed argument type from EMSsortpt_info to struct
                           EMparms for parameters "bad_pts_info" and 
                           "sort_pts_info". Changed parameters to function
                           EFspbool_modify_trace_groups, which has also been
                           modified.
        NP    07/27/93     Added NULLs for two new paramters to the function
                           "EFspbool_modify_trace_groups".
        NP    05/07/93     If boolean failed during first pass and succeeded 
                           during double check, the return code was still from 
                           the failure in the first pass.
        NP    11/30/92     Deleted the old special boolean function
                           "EFperform_special_boolean_mod". Will save it in
                           file EFpfspold.I in "$MODEL/src_save" directory for
                           a while, till it is finally deleted.The support 
                           functions for this code in file "EFspboolsup.I" have
                           already been deleted (see comments in that file). 
                           The support file "EFsortint.I" is also being deleted
                           and stored in "src_save" as "EFsortold.I".
 	NP    07/24/92	   This function replaces the older function
                           "EFperform_special_boolean_mod". This function 
                           is a major re-write of the older function. It 
                           replaces most of the code in the older function with
                           a call to "EFspbool_modify_trace_groups", which 
                           essentially removes unwanted trace groups, as 
                           decided by the sort points. Then the boolean goes on
                           as usual.
                           (The "EFperform_special_boolean_mod" and its 
                            supporting functions still exist in the source code 
                            and will continue to be for some time till they are
                            eventually deleted)

 OLD_HISTORY (for the old version of this function before the re-write)

       	RC    07/22/89     Creation Date
        SS    08/12/89     Changed the function EMbool_validate to
                           EMsfint_topology_validate.
	Tapadia 09/05/91   Added an argument in the function, hence changed 
			   the name to EFperform_special_boolean_mod. If the
			   argument arg_bool_GRid.objid is NULL_OBJID an 
			   object of class EMSsfboolean or EMSslboolean is
			   constructed, else the passed objid is used in 
			   boolean operation. 
	SM    19-Feb-92    Initialized all pointers to NULL in the
	                   declaration itself.
*/


void EFperform_special_boolean(EFmsg, 
                               md_env, 
                               op1_elem,
                               num_op2_elems, 
                               op2_elems, 
                               all_elements_solid, 
                               const_list, 
                               bool_type, 
                               num_sort_pts, 
                               sort_pts_info, /* no need to fill in "normal" 
                                               * field of struct.
                                               */
                               options, 
                               num_bad_pts,   /* may be NULL */
                               bad_pts_info,  /* may be NULL 
                                               * if non-NULL, no need to fill 
                                               * in "normal" field of struct.
                                               */
                               arg_bool_GRid)
 IGRlong                 *EFmsg;
 struct GRmd_env         *md_env;
 GRobjid                 op1_elem;
 IGRint                  num_op2_elems;
 GRobjid                 *op2_elems;
 IGRboolean              all_elements_solid;
 struct GRvg_construct   *const_list;
 enum   EMSbooltype      bool_type;
 IGRint                  num_sort_pts;
 IGRushort               options;
 IGRint                  *num_bad_pts;
 struct EMparms          *sort_pts_info, **bad_pts_info;
 struct GRid 		 arg_bool_GRid;
{

 extern IGRlong        	EMintersect_surfaces(), 
                       	EMboolean_surfaces_w_intersection(),
                       	EFspbool_modify_trace_groups();
 extern void           	EMsfinttrace_free(), EMsfintedpar_free(),
                       	EMinters_data_free(), EMinters_free();

 IGRlong               	rc, OM_stat;
 IGRint                	i, opix, num_inters;
 IGRboolean            	double_chk, openint_valid, handle_stop;
 IGRchar               	status_str[54];
 IGRushort             	inters_opts, outworld_opts, outparam_opts,
                       	trim_opts, bool_options;


 GRspacenum            	cur_os;
 struct GRid           	*op2_elems_GRid = NULL, 
                       	op2_elems_GRidmem[OP2_BUF_SIZE],
                       	op1_elem_GRid, bool_GRid;

 struct EMSinters      	*inters[2];
 struct EMSsftracedata  *trace_info = NULL, trace_data[2];
 struct EMSdataselect  	*op2_elems_dataselect = NULL, 
                       	op2_elems_datmem[OP2_BUF_SIZE];

 IGRboolean save_pathway_trim, save_pathway_orient;

 /* ****************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 op2_elems_dataselect = NULL;
 op2_elems_GRid = NULL; 
 cur_os = md_env->md_id.osnum;
 bool_GRid.objid = NULL_OBJID;
 bool_GRid.osnum = cur_os;

 double_chk    = options & EMSsfbool_opt_doublecheck;
 openint_valid = options & EMSsfbool_opt_OpenIntPossible; /* NEEDED ??*/
 handle_stop   = options & EMSsfbool_opt_HandleStop; /* NEEDED??*/

 /*
  * Get the oriented intersections for the boolean operation
  */

 if (num_op2_elems > OP2_BUF_SIZE)
 {
  op2_elems_dataselect = (struct EMSdataselect *) om$malloc (size = 
            num_op2_elems * sizeof(struct EMSdataselect));
  EMerr_hndlr (!op2_elems_dataselect,*EFmsg,EMS_E_NoDynamicMemory,wrapup);
 
  op2_elems_GRid = (struct GRid *) om$malloc (size = num_op2_elems *
                                               sizeof(struct GRid));
  EMerr_hndlr (!op2_elems_GRid, *EFmsg, EMS_E_NoDynamicMemory, wrapup);
 
 } /* if (num_op2_elems > OP2_BUF_SIZE) */
 else
 {
   op2_elems_dataselect = op2_elems_datmem;
   op2_elems_GRid = op2_elems_GRidmem;
 }

 op1_elem_GRid.objid = op1_elem;
 op1_elem_GRid.osnum = cur_os;

 for (i = 0; i < num_op2_elems; i++)
 {
  op2_elems_dataselect[i].datatype = EMSdata_object;
  op2_elems_dataselect[i].data.object = &op2_elems_GRid[i];
  op2_elems_GRid[i].objid = op2_elems[i];
  op2_elems_GRid[i].osnum = cur_os;

 } /* for (i = 0; i < num_op2_elems; i++) */

/*
 ex$message (msgnumb = EMS_I_Processing, buff = status_str);
 */

 strcpy (status_str, "Processing");

 inters_opts = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
               EMS_SFINT_PUSHBADCOINC |
               (bool_type == EMSbool_difference ?
                             EMS_SFINT_REVERSESECONDINT : NULL) |
               (double_chk? EMS_SFINT_DOUBLECHECK : EMS_SFINT_MUSTNOAMBIGUOUS)|
               (openint_valid ? NULL : EMS_SFINT_MUSTCLOSE) |
               (handle_stop ? EMS_SFINT_HANDLESTOP : NULL);

 outworld_opts = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;

 outparam_opts = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                 EMSINT_ORIENT_OUTPUT |
                 (bool_type == EMSbool_intersect ? EMSINT_ORIENT_RIGHT :
                  NULL);

 trim_opts = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA | 
             EMSINT_TRIM_COPLANAR |
             (double_chk ? EMSINT_TRIM_MOREPRECISE 
                      /* | EMSINT_TRIM_PROCOVERLAP (is always set internally)*/ 
                           : NULL);

 num_inters = 0;

 for (opix = 0; opix < 2; opix++)
 {
  inters[opix] = NULL;

  trace_info = &(trace_data[opix]);
  trace_info->num_grps = 0;
  trace_info->num_subgrps_grp = NULL;
  trace_info->num_elems_subgrp = NULL;
  trace_info->elems = NULL;
  trace_info->subgrp_rev = NULL;
  trace_info->elem_rev = NULL;
  trace_info->grp_closed = NULL;
  trace_info->subgrp_closed = NULL;
 
 } /* for (i = 0; i < 2; i++) */

 save_pathway_trim = _pathway_trim;
 save_pathway_orient = _pathway_orient;
 _pathway_trim = 0;
 _pathway_orient = 0;


 OM_stat = EMintersect_surfaces (&rc, &op1_elem_GRid, &md_env->md_env, 
             num_op2_elems, op2_elems_dataselect, &md_env->md_env, 
             inters_opts, outworld_opts, outparam_opts,
             trim_opts, const_list, &num_inters, 
             &(inters[EMSoprnd_A]), &(inters[EMSoprnd_B]), 
             &(trace_data[EMSoprnd_A]),
             &(trace_data[EMSoprnd_B]), NULL, NULL, 
             status_str);

 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;

 EMerr_hndlr (!num_inters, *EFmsg, EMS_E_NoIntersection, wrapup);
 EMerr_hndlr (!(1&OM_stat&rc), *EFmsg, EMS_E_Fail, wrapup);

 /* Modify the intersection lists to keep only those parts of the surfaces 
  * that have been identified with points. In case some of the points are 
  * invalid, these are returned to us by the function, and are later displayed
  * by the command object, but the boolean goes on. If ALL points are invalid,
  * however, the operation is not possible and we return with an error code.
  * NOTE:
  * The case of ALL points being invalid can be handled as a regular boolean 
  * too, without erroring out. CHECK WHAT TO DO HERE...For now, erroring out..
  */

 OM_stat = EFspbool_modify_trace_groups (&rc, 
			const_list,
                        md_env,
                        &(inters[EMSoprnd_A]),
                        &(inters[EMSoprnd_B]),
                        &(trace_data[EMSoprnd_A]),
                        &(trace_data[EMSoprnd_B]),
                        NULL, /*no options right now*/
                        sort_pts_info,
                        &num_sort_pts,
                        bad_pts_info,
                        num_bad_pts,
                        NULL,
                        NULL); 

 /* Trap "EMS_E_AllIntersectionsDeleted" error */
 EMerr_hndlr (rc==EMS_E_AllIntersectionsDeleted, *EFmsg, rc, wrapup);

 /* all other failure cases */
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
 EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
  			

 /* INSERT CODE HERE:
  * This space is for code to delete those object ids from the array
  * "op2_elems", that DO NOT HAVE any intersections anymore, due to selective
  * deletion of intersections above. Accordingly decrement "num_op2_elems".
  * (If ALL intersections between operands had been deleted, however, this
  *  would already have errored out with the "EMS_E_AllIntersectionsDeleted"
  *  error above). The idea of doing this is that, those operands B, which may
  * or may not be  disjoint from A, but have all their intersections with 
  * operand A deleted will NOT be put in the SSI table of the dpr state (i.e. 
  * those will NOT be a part of the boolean).
  *
  * NOTE: It might be a better idea to store the deleted objects from the
  * "op2_elems" array, since we need to restore the array to its original form
  * if the "EMboolean_surfaces_w_intersection" fails and we need to go into a 
  * double check.
  */

 /* Construct a new object if not already passed */

 if(arg_bool_GRid.objid == NULL_OBJID) 
 {
 	OM_stat = om$construct (classid = all_elements_solid ?
              OPP_EMSslboolean_class_id : OPP_EMSsfboolean_class_id,
              osnum = cur_os, p_objid = &bool_GRid.objid);
 	EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
 }
 else 
	bool_GRid.objid = arg_bool_GRid.objid;


 /*
  * Resume Boolean operation
  */
  
 bool_options = EMSsfbool_opt_display ;

 OM_stat = EMboolean_surfaces_w_intersection (&rc, &bool_GRid, bool_type,
             const_list->env_info, op1_elem, num_op2_elems, op2_elems,
             inters[EMSoprnd_A], inters[EMSoprnd_B],
             &(trace_data[EMSoprnd_A]), &(trace_data[EMSoprnd_B]),
             NULL, NULL, bool_options, NULL, NULL, status_str);

 EMerr_hndlr (!(1&OM_stat&rc), *EFmsg, EMS_E_Fail, wrapup);
 

wrapup:
 
 /*
  *   Free trace info.
  */

 for (opix = 0; opix < 2; opix++)
 {
  trace_info = &(trace_data[opix]);
  EMsfinttrace_free (&rc, trace_info->num_grps, 
      trace_info->num_subgrps_grp, trace_info->num_elems_subgrp, 
      trace_info->elems, trace_info->subgrp_rev, trace_info->elem_rev,
      trace_info->grp_closed, trace_info->subgrp_closed);

 } /* for (opix = 0; opix < 2; opix++) */


 /*
  * Free inters link list
  */

 for (opix = 0; opix < 2; opix++)
 {
  EMinters_data_free(&rc, inters[opix], MAXINT, NULL, EMsfintedpar_free);
  EMinters_free(inters[opix], MAXINT);
 }

 if (num_op2_elems > OP2_BUF_SIZE)
 {
  if (op2_elems_dataselect) om$dealloc (ptr = op2_elems_dataselect);
  if (op2_elems_GRid) om$dealloc (ptr = op2_elems_GRid);

 } /* if (num_op2_elems > OP2_BUF_SIZE) */
 
 /*
  * If the error is non_fatal and the double_check option has not
  * been used and if arguments are not invalid, & if the selections points are
  * not ALL invalid (suggested by EMS_E_AllIntersectionsDeleted), redo the 
  * processing using double_checking algorithm.
  */

 if (  EMSerror (*EFmsg) && 
       EMS_SeverityLevel (*EFmsg) != FATL && 
       (*EFmsg) != EMS_E_InvalidArg && 
       (*EFmsg) != EMS_E_AllIntersectionsDeleted && 
       !double_chk
    )
  {
   /* Free memory for "*bad_pts_info", if any has been allocated before going 
    * into double check. This is because the function 
    * "EFspbool_modify_trace_groups" allocates memory for "bad points" if 
    * there are any, and we want to start with a clean slate. Ultimately, this 
    * memory is freed by the calling function.
    */
   if (bad_pts_info)
   {  if (*bad_pts_info)
      { om$dealloc (ptr = *bad_pts_info);
        *bad_pts_info = NULL;
      }
      if (num_bad_pts)
        *num_bad_pts = 0;
   }
   EFperform_special_boolean(EFmsg, md_env, op1_elem,
            	num_op2_elems, op2_elems, all_elements_solid, const_list, 
            	bool_type, num_sort_pts, sort_pts_info, 
          	options | EMSsfbool_opt_doublecheck, num_bad_pts, 
		bad_pts_info, arg_bool_GRid);
  }
 else
  {
   EMWRAPUP (*EFmsg, OM_stat, "EFperform_special_boolean");
  }

 return; 

} /* void EFperform_special_boolean() */


end implementation EMSsfboolean;
