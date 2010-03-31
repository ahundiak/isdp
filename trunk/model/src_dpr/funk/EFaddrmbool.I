/* -----------------
 * FOR EMS 4.0
 * Creation : Sanjay
 * -----------------
 */

/*
 *  Description
 *  -----------
 *       This function is very specific to Add/Remove Material functionality.
 *  It does the boolean operation ( union/diff/intersection depending on the 
 *  bool_type ) between the base solid and the secondary solid. In the proce-
 *  ss it deletes the unwanted trace groups and retains only those which are
 *  required. It also takes care of the coincident surface processing in case
 *  of "FROM/TO" option. 
 *
 *  Synopsis 
 *  --------
 *    EFmsg           IGRlong             O   Return Status
 *    options         IGRushort           I   Options if any (For future use)
 *                                            presently it is NULL.
 *    const_list      struct 
 *                      GRvg_construct *  I   Construction list
 *    md_env          struct GRmd_env *   I   Module environment.
 *    feature_type    IGRushort           I   Add/Remove Mtl. Feature.
 *    sec_solid_type  IGRushort           I   Projected/Revolved/Skinned
 *    sec_solid_extent IGRushort          I   To-Next/From-To/Finite ...
 *    bool_type       enum EMSbooltype    I   Type of the boolean operation 
 *                                            need to be done bet. the base and
 *                                            secondary solid.
 *    base_solid_grid struct GRid *       I   ID of the Base Solid
 *    sec_slinfo      struct SecSolidInfo *       
 *                                        I   Secondary Solid Info.
 *    num_coinc_sfs   IGRint              I   Number of Coincident surfaces
 *                                            ( if "From-To" option specified )
 *    coinc_sfs_grid  struct GRid *[2]    I   Coincident surfaces IDs
 *                                            ( if "From-To" option specified )
 *    arg_bool_GRid   struct GRid         I   Final Solid
 *
 *
 *  Return Values
 *  -------------
 *    EMS_S_Success       -  Every thing goes fine.
 *    EMS_E_OMerror       -  Any OM error.
 *    EMS_E_Fail          -  Any serious failure. 
 *    EMS_E_AddRmDisjoint -  Base and secondary solids does not intersect. 
 *
 *  History
 *  -------
 *
 *    Sanjay   :  05/02/94   Creation
 *    Sanjay   :  09/08/95   Don't generate the intersections between the 
 *                           coincident surfaces if pathway is ON. 
 */
class implementation EMSsfboolean;

#include "OMmacros.h"
#include "emssfintdef.h"
#include "EMSdef.h" /*for EMparms struct */
#include "EMSsfintsort.h"
#include "emsfeaopts.h"
#include "addrmopts.h"
#include "addprot.h"

#include "bs.h"
#include "bsdotp.h"

extern OMuword     OPP_EMSslboolean_class_id, OPP_EMSsfboolean_class_id;
extern IGRboolean  _pathway_trim, _pathway_orient;

void EFperform_addrm_boolean( 
IGRlong                 *EFmsg,
IGRushort               options,
struct GRvg_construct   *const_list,
struct GRmd_env         *md_env,
IGRlong                 feature_type,
IGRlong                 sec_solid_type,
IGRlong                 sec_solid_extent,
enum   EMSbooltype      bool_type,
struct GRid             *base_solid_grid,
struct SecSolidInfo     *sec_slinfo, 
IGRint                  num_coinc_sfs,
struct GRid             *coinc_sfs_grid[2],
struct GRid             arg_bool_GRid )
{
 extern IGRlong        	EMintersect_surfaces(), 
                       	EMboolean_surfaces_w_intersection(),
                       	EFspbool_modify_trace_groups();
 extern void           	EMsfinttrace_free(), EMsfintedpar_free(),
                       	EMinters_data_free(), EMinters_free();

 IGRlong               	rc, OM_stat, OUT_rc;
 IGRint                	opix, num_inters, num_op2_elems;
 IGRboolean            	double_chk, openint_valid, handle_stop;
 IGRchar               	status_str[54];
 IGRushort             	inters_opts, outworld_opts, outparam_opts,
                       	trim_opts, bool_options;


 GRobjid                op1_elem_id, op2_elems_id;
 GRspacenum            	cur_os;
 struct GRid           	op1_elem_GRid, bool_GRid;

 struct EMSinters      	*inters[2];
 struct EMSsftracedata  *trace_info = NULL, trace_data[2];
 struct EMSdataselect  	op2_elems_dataselect; 

 struct GRid            *sec_solid_grid;

 IGRboolean             pathway, switch_oprnds=FALSE; 

 /* ****************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 cur_os = md_env->md_id.osnum;
 bool_GRid.objid = NULL_OBJID;
 bool_GRid.osnum = cur_os;
 OUT_rc = 0; 

 double_chk    = (options & AddRm_Bool_DoubleCheck) ? TRUE : FALSE;
 openint_valid = FALSE;
 handle_stop   = FALSE;

 /*
  * Check whether pathway is ON or NOT
  */
 if (_pathway_trim && _pathway_orient)
   pathway = TRUE;
 else
   pathway = FALSE;

 sec_solid_grid = &sec_slinfo->grid;

 /*
  * Get the oriented intersections for the boolean operation
  */
 if (pathway && (options & AddRm_Bool_MaxSplitSecSolid))
 {
   switch_oprnds = TRUE;
 }

 if (switch_oprnds)
 {
   num_op2_elems = 1;
   op1_elem_GRid = *sec_solid_grid;
   op2_elems_dataselect.datatype = EMSdata_object;
   op2_elems_dataselect.data.object = base_solid_grid;
   op1_elem_id = sec_solid_grid->objid;
   op2_elems_id = base_solid_grid->objid;
 }
 else
 {
   num_op2_elems = 1;
   op1_elem_GRid = *base_solid_grid;
   op2_elems_dataselect.datatype = EMSdata_object;
   op2_elems_dataselect.data.object = sec_solid_grid;
   op1_elem_id = base_solid_grid->objid;
   op2_elems_id = sec_solid_grid->objid;
 }

 strcpy (status_str, "Processing");

 if( num_coinc_sfs && coinc_sfs_grid )
 {
     inters_opts = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_NOREFINE |  
               (double_chk? EMS_SFINT_DOUBLECHECK : NULL)|
               (bool_type == EMSbool_difference ?
                             EMS_SFINT_REVERSESECONDINT : NULL) |
               (handle_stop ? EMS_SFINT_HANDLESTOP : NULL ) ;
     trim_opts = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                 (double_chk ? EMSINT_TRIM_MOREPRECISE : NULL);

 }
 else
 {
      inters_opts = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
               EMS_SFINT_PUSHBADCOINC |
               (bool_type == EMSbool_difference ?
                             EMS_SFINT_REVERSESECONDINT : NULL) |
               (double_chk? EMS_SFINT_DOUBLECHECK : EMS_SFINT_MUSTNOAMBIGUOUS)|
               (openint_valid ? NULL : EMS_SFINT_MUSTCLOSE) |
               (handle_stop ? EMS_SFINT_HANDLESTOP : NULL);

      trim_opts = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                  EMSINT_TRIM_COPLANAR | 
                  (double_chk ? EMSINT_TRIM_MOREPRECISE : NULL);

 }

 /*
  * We want maximum splits on the secondary solid, in order to get this we have
  * to set the following trim options.
  */
 if (options & AddRm_Bool_MaxSplitSecSolid)
 {
   trim_opts |= EMSINT_TRIM_RETAIN_ON_PRIMARY |
                EMSINT_TRIM_DELETE_ON_SECONDARY;
 }

 outworld_opts = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;

 outparam_opts = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                 EMSINT_ORIENT_OUTPUT |
                 (bool_type == EMSbool_intersect ? EMSINT_ORIENT_RIGHT :
                  NULL);

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

 OM_stat = EMintersect_surfaces (&rc, &op1_elem_GRid, &md_env->md_env, 
             num_op2_elems, &op2_elems_dataselect, &md_env->md_env, 
             inters_opts, outworld_opts, outparam_opts,
             trim_opts, const_list, &num_inters, 
             &(inters[EMSoprnd_A]), &(inters[EMSoprnd_B]), 
             (num_coinc_sfs && coinc_sfs_grid) ? NULL : 
                                                 &(trace_data[EMSoprnd_A]),
             (num_coinc_sfs && coinc_sfs_grid) ? NULL :
                                                 &(trace_data[EMSoprnd_B]),  
             NULL, NULL, 
             status_str);
#ifdef DEBUG
       if( !num_inters )
           printf("There is no intersection at all\n");
       if( !(1&OM_stat&rc) )
           printf("Intersect surfaces failed\n");
#endif
 add$status( test = (!num_inters || (rc == EMS_E_NoIntersection)), 
     msg = *EFmsg, code = EMS_E_NoIntersection,
     str = "EFperform_addrm_boolean : EMintersect_surfaces : Elements are disjoint",
     action = GOTO_VALUE, value = wrapup );

 add$status( test = !(1&OM_stat&rc), msg = *EFmsg, code = rc,
     str = "EFperform_addrm_boolean : EMintersect_surfaces error",
     action = GOTO_VALUE, value = wrapup );

 /*
  * Modify the inters list for coincident surfaces
  */
 if( num_coinc_sfs && coinc_sfs_grid ) 
 {
     if (!pathway)
     {
       OM_stat = EFmerge_coinc_inters( &rc, md_env, bool_type,
                 switch_oprnds ? &inters[EMSoprnd_B] : &inters[EMSoprnd_A], 
                 switch_oprnds ? &inters[EMSoprnd_A] : &inters[EMSoprnd_B], 
                 num_coinc_sfs, coinc_sfs_grid );
        add$status( test = !(1&OM_stat&rc), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFperform_addrm_boolean : EFmerge_coinc_inters error",
            action = GOTO_VALUE,  value = wrapup );
     }

     /*
      * Then do the tracing
      */
     inters_opts = NULL;
     inters_opts = EMS_SFINT_SKIPSFINT | EMS_SFINT_MUSTCLOSE | 
              (double_chk? EMS_SFINT_DOUBLECHECK : EMS_SFINT_MUSTNOAMBIGUOUS);
     outworld_opts = NULL;
     outparam_opts = NULL; 
     trim_opts = NULL;
 
     OM_stat = EMintersect_surfaces (&rc, NULL, &md_env->md_env,
             num_op2_elems, NULL, &md_env->md_env,
             inters_opts, outworld_opts, outparam_opts,
             trim_opts, NULL, NULL,
             &(inters[EMSoprnd_A]), &(inters[EMSoprnd_B]), 
             &(trace_data[EMSoprnd_A]), &(trace_data[EMSoprnd_B]),
             NULL, NULL, status_str);
#ifdef DEBUG
       if( !(1&OM_stat&rc) )
           printf("Failed in tracing \n");
#endif
     add$status( test = !(1&OM_stat&rc), msg = *EFmsg, code = rc,
         str = "EFperform_addrm_boolean : EMintersect_surfaces error",
         action = GOTO_VALUE,  value = wrapup );

 }

 /*
  * Call the add/remove material support function for keeping the right groups.
  */

 if (!(options & AddRm_Bool_NoSelective)) 
 {
   IGRushort    opts = NULL;

   OM_stat = EFkeep_right_trace_groups( &rc, opts, const_list, md_env, 
             feature_type, sec_solid_type, sec_solid_extent, base_solid_grid, 
             sec_slinfo, 
             switch_oprnds ? &inters[EMSoprnd_B] : &inters[EMSoprnd_A], 
             switch_oprnds ? &inters[EMSoprnd_A] : &inters[EMSoprnd_B], 
             switch_oprnds ? &trace_data[EMSoprnd_B] : &trace_data[EMSoprnd_A], 
             switch_oprnds ? &trace_data[EMSoprnd_A] : &trace_data[EMSoprnd_B]); 
   OUT_rc = rc;
   add$status( test = (rc==EMS_E_AllIntersectionsDeleted), msg = *EFmsg, 
       code = rc,
       str = "EFperform_addrm_boolean : EFkeep_right_trace_groups error",
       action = GOTO_VALUE, value = wrapup );

   /* all other failure cases */
   add$status( test = !(1&rc), msg = *EFmsg, code = rc,
       str = "EFperform_addrm_boolean : EFkeep_right_trace_groups error",
       action = GOTO_VALUE, value = wrapup );

   add$status( test = !(1&OM_stat), msg = *EFmsg, code = EMS_E_OMerror,
       str = "EFperform_addrm_boolean : EFkeep_right_trace_groups error",
       action = GOTO_VALUE, value = wrapup );
 }
     
 /* 
  * Construct a new object if not already passed 
  */
 if(arg_bool_GRid.objid == NULL_OBJID) 
 {
    OM_stat = om$construct (classid = OPP_EMSslboolean_class_id,
                            osnum = cur_os, p_objid = &bool_GRid.objid);
    add$status( test = !(1&OM_stat), msg = *EFmsg, code = EMS_E_OMerror,
        str = "EFperform_addrm_boolean : om$construct error",
        action = GOTO_VALUE, value = wrapup );
 }
 else 
    bool_GRid.objid = arg_bool_GRid.objid;


 /*
  * Resume Boolean operation
  */
 bool_options = EMSsfbool_opt_display ;

 OM_stat = EMboolean_surfaces_w_intersection (&rc, &bool_GRid, bool_type,
             const_list->env_info, 
             (switch_oprnds) ? op2_elems_id : op1_elem_id, num_op2_elems, 
             (switch_oprnds) ? &op1_elem_id : &op2_elems_id, 
             (switch_oprnds) ? inters[EMSoprnd_B] : inters[EMSoprnd_A], 
             (switch_oprnds) ? inters[EMSoprnd_A] : inters[EMSoprnd_B],
    (switch_oprnds) ? &(trace_data[EMSoprnd_B]) : &(trace_data[EMSoprnd_A]), 
    (switch_oprnds) ? &(trace_data[EMSoprnd_A]) : &(trace_data[EMSoprnd_B]), 
             NULL, NULL, bool_options, NULL, NULL, status_str);
 add$status( test = !(1&OM_stat&rc), msg = *EFmsg, code = EMS_E_Fail,
     str = "EFperform_addrm_boolean : EMboolean_surfaces_w_intersection error",
     action = GOTO_VALUE, value = wrapup );


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
       (*EFmsg) != EMS_E_AddRmNoIntToNextSurf &&
       (*EFmsg) != EMS_E_AddRmInfinite &&
       (*EFmsg) != EMS_E_NoIntersection &&
       !double_chk
    )
  {
   /* Free memory for "*bad_pts_info", if any has been allocated before going 
    * into double check. This is because the function 
    * "EFspbool_modify_trace_groups" allocates memory for "bad points" if 
    * there are any, and we want to start with a clean slate. Ultimately, this 
    * memory is freed by the calling function.
    */
   EFperform_addrm_boolean(
             EFmsg, options | AddRm_Bool_DoubleCheck, const_list,
             md_env,  feature_type, sec_solid_type, sec_solid_extent,
             bool_type, base_solid_grid, sec_slinfo, num_coinc_sfs, 
             coinc_sfs_grid, arg_bool_GRid );
  }
 else
  {
   EMWRAPUP (*EFmsg, OM_stat, "EFperform_addrm_boolean");
  }

 if (!(1&*EFmsg&OM_stat))
 {
   if (*EFmsg == EMS_E_NoIntersection)
     *EFmsg = EMS_E_AddRmDisjoint;
   else if(*EFmsg != EMS_E_AddRmNoIntToNextSurf && 
           *EFmsg != EMS_E_AddRmInfinite)
     *EFmsg = EMS_E_Fail;
 }
 else if( (OUT_rc == EMS_I_AddRmNoIntToNextSurf) ||
          (OUT_rc == EMS_I_AddRmInfinite)  )
   *EFmsg = OUT_rc;

 return; 

} /* void EFperform_addrm_boolean() */

end implementation EMSsfboolean;
