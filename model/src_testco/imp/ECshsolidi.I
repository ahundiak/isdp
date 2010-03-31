/*
NAME:
 methods:
  init, execute, dir_dynamics, element_located.

 functions:
  EFshell_dir_dynamics, EFshell_action_handler, EMloc_open_surf_hndlr 

ABSTRACT:

 This is the command object for creating 'thin-walled' solids.

HISTORY:

 SS   : ??/??/92    : Creation
 ashok: 07/29/92    : Added  "my_type=1" to locate primitive solids of 
		      projections and revolutions only. To this end added
		      appropriate  action handlers for locating only eligible
	              solids and eligible open surfaces (end caps). Also made
	              the command object message sub-system compliant.
		      Currently "my_type=0" (z place thin-walled solid") is 
		      meant for demos and benchmarks only.
 ashok: 08/14/92    : Overrode wakeup and sleep to highlight/dehighlight
	              assoc button in assoc mode.
 ashok: 10/015/92   : Modified action handler to allow planar surfaces of 
		      composite surface owned by the solid of revolution to be 
		      located as "open" surfaces.
 ashok  12/03/92    : Disabling action handler for locating solids. Done 
                      to start testing 'thin-wall' creation using 
                      composite surface offset.
 Sudhakar: 01/11/93 : Modification for Phoenix Thin Wall Command.
                      Added a function "EFshell_dir_dynamics' and a method
                      "dir_dynamics" to display a dynamic or symmetric arrow.
 Sudhakar: 01/22/93 : Modified  function 'EMloc_open_surf_handlr()' to
                      identify any component surface as open surface.
 Sudhakar: 02/01/93 : Completed form interface 
 Sudhakar: 03/10/93 : Modified to take in expression object names for thickness
                      (common or special) values.
 Sudhakar: 03/12/93 : Integrated with new 'Place Offset Surface' command object.
                      Removed overrides of 'wakeup' and 'sleep'. Subclassing
                      from 'ECcsoffset' class instead of 'ECelements'.
 Sudhakar: 23Apr'93 : Modified to facilitate auto-dimensioning.
 Sudha  07/05/93    : Modified for BSprototypes ansification
 Sudhakar: 26Jul'93 : Fixed some prompts and made UMS compliant.
 Sudhakar: 24Aug'93 : Fixed direction arrow size to (15 * dittol).
 Sampath : 01sep'93 : Added code to group tangent surfaces.
 Sampath : 17sep'93 : Implemented command statcking in all states, invoking
		      status display form in all states. Added code to reject
		      Imposed boundry class during locate. Fixed problem with
		      direction of thin-wall for simple surfaces, locating open
		      surfaces and backup in LOCATE_SOLID_STATE.
 Sudhakar: 24Sep'93 : Modified to obtain appropriate 'dimensioning' info instead
                      of 'nearest edges'.
 Sudhakar: 27Nov'93 : Added code to 
                         a) display an 'average dynamic arrow'. 
                         b) detect 'null solids' due to choice of open surfaces
                            and warn the user (Fix for TR# 119312777).
                         c) disallow identifying the composite component of a
                            solid or comp. surface for thinwalling. Either the
                            whole solid/comp.surface or a primitive surface is
                            identified for 'thinwalling'(fix for TR# 119312776).
                         d) high-light the open surfaces and de-highlight them
                            appropriately.
 Sudhakar: 05Jan'94 : Fix for TR# 119415155. Also reset the open sfs count
                      after each complete operation.
 Sudhakar: 26Jan'94 : Modified to avoid grouping of tangent surfaces for
                      the open surface state if the input solid is an
                      associative solid of projection or revolution. This
                      ensures compatibililty with EMS 2.2 thinwall models.
 Sudhakar: 02Feb'94 : Fixed the problem where if thinwall fails, the backup
                      does an undo on the previous state [TR# 119416611].
 Sanjay  : 14Feb'94 : Fix for setting of correct direction of offset during
                      play-back [TR# 119417121].
 Sanjay  : 18Jul'94 : Fix for using the correct leaf_id of the located event
                      (EMS4 fix).
 Sanjay  : 25Jul'94 : Removed variable "extern IGRpoint dpt" which was added
                      as the last minute kludge for EMS 3.0.  
*/

class implementation ECshsolid;


#include <stdio.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h" /* for co$getevent */
#include "grmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "EMSaction.h"  /* for EMSaction_handler */

#include "EMSasmacros.h"
#include "emssfintdef.h"
/* #include "emssfint.h" */
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EC_M.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSfeadef.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "ECmsg.h"
#include "plotmacros.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#include "actparam.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define START  0
#define STOP   1

#define REV_CRV    0
#define REV_BASE   1
#define REV_DIR    2
#define REV_START  3
#define REV_SWEEP  4

#define LOCATE_SOLID_STATE2	6
#define LOCATE_SOLID_STATE1	0
#define LOCATE_OPENSFS_STATE	1
#define COMMON_THICKNESS_STATE	2
#define SPEC_THICKNESS_STATE	3
#define SPEC_SURFACE_STATE      4 
#define PROCESS_STATE		5

# define FAIL   0

static IGRboolean aflag;
static struct GRmd_env rfenv;
static IGRint rfsts;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#ifdef DEBUG
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
        printf("\nIn ECshsolid: %s\n", error_message); \
        sts = FAIL; \
        goto ret_end;\
    }\
 }
#else
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
        sts = FAIL; \
        goto ret_end;\
    }\
 }
#endif

struct dimension_info
{
  GRobjid    surf;
  IGRpoint   uv_point;
  OMuword    view_index;
};

extern GRclassid OPP_EMSsubbs_class_id,
                 OPP_EMSdpr_class_id,
                 OPP_EMSsfsolid_class_id,
		 OPP_EMSrevcompsf_class_id,
                 OPP_EMSprjcompsf_class_id,
		 OPP_EMSrevol_class_id,
		 OPP_EMSproject_class_id,
                 OPP_EMSsolid_class_id,
                 OPP_GRlinear_class_id, 
 		 OPP_GRcompcurve_class_id,
		 OPP_EMStorus_class_id,
		 OPP_EMAtorus_class_id,
                 OPP_EMScompsurf_class_id,
                 OPP_EMSshslbool_class_id,
                 OPP_EMSsfimpbnd_class_id,
                 OPP_EMSsurface_class_id;

from GRgraphics import GRdisplay, GRdelete;
from GRgraphics import GRgetprops;
from EMSparamgm import EMgetgeom;
from GRcurve import GRendpts;
from EMSassoc import EMpack_paraminfo;
from GRvg import GRgeomprops, GRgetgeom, GRgetsize;
from ECplhole import hole_dynamics;
from EMSsubbs import EMgetbsdef, EMget_unit_norm, EMget_props;
from EMSsurface import EMgetactiveid, EMgetedges;
from EMSdpr import  EMundo;
from GRowner import GRget_number_components;

/*
 * This structure is used as an argument to the action-handler
 * called within the 'do_locate' method.
 */
struct locate_acthndlr_args
  {
  IGRushort options;
  IGRchar *loc_prompt, *acc_prompt, *reloc_prompt;
  IGRint numelems;
  struct GRlc_info *elems;
  OM_S_CLASSLIST nelig_classes;
  };

/*
 * This structure is used as an argument to the action-handler
 * called within this command's execute method.
 */
struct open_surf_hndlr_args
  {
  struct GRid *solid;
  struct GRmd_env *env;
  struct GRid my_inst;
  struct locate_acthndlr_args actargs;
  };

/*
 * This structure is used to call the Hole_EFdymodvec
 */
static struct info
{       struct DPele_header header;
        IGRdouble *normal;
        IGRint    num_elems;
        struct GRid *elems;
};

method init(int type; char *str_ptr)
{
    IGRlong     sts;
/*    IGRlong     msg = MSSUCC; */

    /* initialize */

    /* Set the symmetric / directional offset flag for options form */
    me->symmetric = FALSE;
    me->input_obj.objid = NULL_OBJID;
    me->const_obj.objid = NULL_OBJID;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message ECcsoffset.init(type, str_ptr),
                  targetid = my_id);
   ERROR(sts, 1, "init.init error");

ret_end:
        return(sts);
} /* init */


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func, putq, dynamics_on;
  IGRchar *p_actargs;
  IGRint i, num_elems, tmpcount;
  IGRlong msg_loc, stat_OM, object_was_located, event_mask, eventsize;
  IGRlong display_flag, locate_mask, accept_mask, bufsize, nret;

  IGRlong acc_key;

  GRclassid rclass[2], eliclass[2], locobj_classid;
  GRobjid dprobj, *opensfs;
  struct IGResbc esbc;
  struct GRmd_env *env;
  struct GRevent event, *locev, *accev;
  struct GRlc_locate attributes;
  struct GRvg_construct const_list;

  struct shell_loc_acthndlr_args shell_locate;
  IGRint  num_edges, buff_size;
  IGRlong sts, *msg;
  IGRdouble cht, ct;
  struct GRevent *specs = NULL;
  IGRint num_sptks;
  struct EMSvalue_info common_tk, spek, *spectks=NULL;
  GRobjid *opsfs;
  struct  GRid  common_surf;
  struct dimension_info *dim_info = NULL;
  GRobjid    *surface,*new_surface;
  IGRint     num_sfs1,num_new_sfs;
  IGRint     added_sfs;
  GRspacenum surface_osnum;
  IGRboolean is_disjoint, special_solid=FALSE;

  OM_S_CLASSLIST rtree_classes, elig_classes;
  enum EMSuser_responses useract;
  enum GRdpmode dpmode;
  char elem_type[GR_MAX_CHAR], msg_1[GR_MAX_CHAR], msg_2[GR_MAX_CHAR];
  char inp_buff[GR_MAX_CHAR];
  IGRchar side_info[GR_MAX_CHAR], type_info[GR_MAX_CHAR];
  struct open_surf_hndlr_args my_actargs;
        struct GRlc_dynamics dir_dyn;
        struct GRid my_tmp_id;
        IGRint EFshell_dir_dynamics();
  IGRint (*p_acthndlr)();
  IGRint EFshell_action_handler();
  IGRlong EMloc_open_surf_hndlr();
  IGRint  EFget_num_sfs_of_original_object(); 

 stat_OM = sts = OM_S_SUCCESS;
 msg = (IGRlong *) om$malloc(size = sizeof(IGRlong));
 EMerr_hndlr (!msg, stat_OM, OM_E_ABORT, ret_end); 
 *msg = EMS_S_Success;


  opensfs = NULL;
  eventsize = sizeof (struct GRevent);

  aflag = pwIsActivationOn();
  if(aflag)
  {
     rfsts = pwGetActiveModuleEnv(&rfenv);
     env = &rfenv;
  }
  else
  {
     env = &ME.ECelements->active_md_env;
  }


  if( ME.super_cmd->mytype == 1) /* For EMS 3 release in order to
                                    locate all solids, comp.surfs and surfs */
  {
      ex$message(msgnumb = EM_M_CrThWaSolid);

   /* Set up to locate any component surface of the located solid
      as an eligible "open" surface
   */
      p_actargs = (IGRchar *) &my_actargs;
  
   /* Locate handler to locate all types of solids/surfaces */
      p_acthndlr = (IGRint (*)())EMloc_open_surf_hndlr; 
      my_actargs.solid = &ME.ECcsoffset->input_obj;
      my_actargs.my_inst.objid = my_id;
      my_actargs.my_inst.osnum = OM_Gw_current_OS;
      my_actargs.actargs.options = ME.ECelements->options;
      my_actargs.actargs.loc_prompt = NULL;
      my_actargs.actargs.acc_prompt = NULL;
      my_actargs.actargs.reloc_prompt = NULL;
      my_actargs.actargs.numelems = ME.ECelements->num_elems;
      my_actargs.actargs.elems = ME.ECelements->elems;
      my_actargs.actargs.nelig_classes = ME.ECelements->nelig_classes;
      my_actargs.env = env;
      om$send( msg = message ECelements.set_hndlr_funcs( &msg_loc, 
			     (IGRboolean(*)())p_acthndlr, 
			     p_actargs, NULL, NULL ),
               targetid = my_id);
  }
  else
      ex$message(msgnumb = EM_M_CrThWaSolid); /* For Demos and Benchmarks */

  ex$message(msgnumb = EMS_P_SfToLvOpen, buff = elem_type);
  ex$message(msgnumb = EMS_P_MvOnNone, buff = msg_1);
  ex$message(msgnumb = EMS_P_SfToLvOpen, buff = msg_2);

  do
    {
    switch (ME.super_cmd->state)
      {
      case LOCATE_SOLID_STATE1:
         GRstatus_display_button(TRUE);
         ex$message( msgnumb = EMS_P_IdSfSl);
         if(me->const_obj.objid == NULL_OBJID)
         {
          me->onesided_flag = TRUE;
          me->symmetric_flag = TRUE;
          me->common_tk_flag = TRUE;
          me->multiple_tk_flag = TRUE;
          me->num_spec_tks = 0;
          me->spec_surf_id_count = 0;
          me->num_opensfs = 0;

          dp$erase_hilite (msg = &msg_loc);
          ex$message(msgnumb =(me->symmetric ? EMS_I_Symmetric : EMS_I_OneSide),
                              buff = side_info);
          ex$message(msgnumb = (me->multi_tk ? EMS_I_Multiple : EMS_I_Common),
                              buff = type_info);
          ex$message(msgnumb = EMS_I_OffWallTk, type = "%s%s",
                              var = `side_info, type_info`, buff = inp_buff);
          ex$message(field = ERROR_FIELD, justification = CENTER_JUS,
                              in_buff = inp_buff);
         }
         else
         {
           ex$message(msgnumb = EMS_I_PrCoBkUpToUnStFo)
         }

         event_mask = GRm_DATA |  GRm_BACK_UP | GRm_STRING;
         stat_func = ems$getevent (msg = &msg_loc, event_mask = event_mask,
             event = &event,
             response = (long *)response, response_data = response_data);

         switch (event.response)
         {

         case EX_STRING :

            if(strlen(event.event.keyin)==1)
            {
            switch(event.event.keyin[0])
            {
                case 'o' :
                case 'O' :
                  if(me->onesided_flag)
                  {
		    me->symmetric = FALSE;
                  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
                break;
                case 's' :
                case 'S' :
                  if(me->symmetric_flag)
                  {
		    me->symmetric = TRUE;
                  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
                break;
                case 'c' :
                case 'C' :
                  if(me->common_tk_flag)
                  {
                  me->multi_tk = FALSE;
                  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
                break;
                case 'm' :
                case 'M' :
                  if(me->multiple_tk_flag)
                  {
                  me->multi_tk = TRUE;
                  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
                break;
                default :
                   ex$putque (msg = &msg_loc, response = &event.response,
                        byte = &eventsize, buffer = (char *) &event.event);
                  ME.super_cmd->state = LOCATE_SOLID_STATE2;
                break;
            }
            }
            else
            {
                   ex$putque (msg = &msg_loc, response = &event.response,
                        byte = &eventsize, buffer = (char *) &event.event);
                  ME.super_cmd->state = LOCATE_SOLID_STATE2;
            }
            me->num_opensfs = 0;
            me->input_obj.objid = NULL_OBJID;
            me->const_obj.objid = NULL_OBJID;
         break;
         case EX_DATA:
           ex$putque (msg = &msg_loc, response = &event.response,
                byte = &eventsize, buffer = (char *) &event.event);
           ME.super_cmd->state = LOCATE_SOLID_STATE2;
           me->num_opensfs = 0;
           me->input_obj.objid = NULL_OBJID;
           me->const_obj.objid = NULL_OBJID;
         break;

         case EX_BACK_UP:
           /* Undo or delete the created thinwall solid */
           if(me->is_solid)
           {
	  	IGRint  display_count, involk_count;
 		IGRushort  option;
		GRobjid *display_ids;

		display_count = involk_count = 0;
		display_ids = NULL;
		option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

  		sts = om$send(msg = message EMSdpr.EMundo(&msg_loc,
				&option, env,
				NULL, NULL, NULL, &display_ids,
				&display_count, &involk_count), 
				targetid = me->const_obj.objid,
				targetos = me->const_obj.osnum);
           }
           else
           {
               sts = om$send(msg = message GRgraphics.GRdelete 
                                        (&msg_loc, env),
                             targetid = me->const_obj.objid,
                             targetos = me->const_obj.osnum);
           }
           EMerr_hndlr (EMSerror (sts & msg_loc),
                                          *msg, EMS_E_Fail, ret_end);
           me->const_obj.objid = NULL_OBJID;
           ME.super_cmd->state = LOCATE_SOLID_STATE1;
	   break;

         default :
           goto ret_end;
         }
      break;

      case LOCATE_SOLID_STATE2: 

	me->num_opensfs = 0;
        me->num_spec_tks = 0;
        dp$erase_hilite (msg = &msg_loc);

        /* Invoke status form to review options 
        ex$message(msgnumb = EMS_I_InvkStatusFrm); */

        ex$message(msgnumb =(me->symmetric ? EMS_I_Symmetric : EMS_I_OneSide),
                              buff = side_info);
        ex$message(msgnumb = (me->multi_tk ? EMS_I_Multiple : EMS_I_Common),
                              buff = type_info);
        ex$message(msgnumb = EMS_I_OffWallTk, type = "%s%s",
              var = `side_info, type_info`, buff = inp_buff);
        ex$message(field = ERROR_FIELD, justification = CENTER_JUS,
                in_buff = inp_buff);

        if(me->symmetric)
          acc_key = EMS_P_00038;
        else   
          acc_key = EMS_P_AccDirRej;

        display_flag = ALL_WINDOWS | ELEM_HILIGHT;
        locate_mask = GRm_DATA | GRm_BACK_UP;
        accept_mask = GRm_DATA;



 /*   Setup the classes of solid/composite surfaces and
      simple surfaces as eligible for selection   */
        elig_classes.w_count = 2;
        eliclass[0] = OPP_EMSsolid_class_id;
        eliclass[1] = OPP_EMSsurface_class_id;
        elig_classes.p_classes = eliclass;
        elig_classes.w_flags = OM_CLST_subclass;

        rtree_classes.w_count = 1;
        rclass[0] = OPP_EMSsubbs_class_id;
        rtree_classes.w_flags = OM_CLST_subclass;
        rtree_classes.p_classes = rclass;

	attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
	attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
				  LC_FLEX_OWNER | LC_REF_OBJECTS |
                                   LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;


        p_acthndlr = EFshell_action_handler; /* store the window-id. */

        shell_locate.my_inst.objid = my_id;
        shell_locate.my_inst.osnum = OM_Gw_current_OS;
        shell_locate.next = NULL;


 /*  - Setup the dyn. method data-structure.
       The dir_dynamics methods sets the following instance data:
          me->axis_dir
          me->common_surf
          me->common_surf_pt   
 */
        my_tmp_id.objid = my_id;
        my_tmp_id.osnum = OM_Gw_current_OS;
        dir_dyn.GRlc_dyn = EFshell_dir_dynamics;
        dir_dyn.add_info = (IGRchar *)&my_tmp_id;

        lc$locate (rc = &object_was_located,
		    event1 = &ME.ECelements->locev, 
                    event2 = &ME.ECelements->accev, 
		    mask1 = locate_mask, 
		    mask2 = accept_mask,
		    display_flag = display_flag,
                    response = response, 
		    response_data = response_data, 
		    locate_key = EMS_P_IdSfSl, 
		    acc_key = acc_key,
                    relocate_prompt = inp_buff,
                    dyn = &dir_dyn,
		    attributes = &attributes, 
		    stack = &ME.ECelements->locate_stack, 
                    act_handler = p_acthndlr,
                    act_args = &shell_locate,
		    rtree_classes = &rtree_classes, 
		    eligible_classes = &elig_classes);


        if (!object_was_located)
         {
            ME.super_cmd->state = LOCATE_SOLID_STATE1;
              goto ret_end;
         }
	else
          {
          /* Check the type of object located */
           /* Check for already thin-walled object */
            stat_OM = om$get_classid(objid = 
                                 me->accev.located_object[0].located_obj.objid,
                         osnum = me->accev.located_object[0].located_obj.osnum,
                         p_classid = &locobj_classid);
            if (!(1&stat_OM))
                  goto ret_end;
            if(locobj_classid == OPP_EMSshslbool_class_id)
            {
                  ex$message (msgnumb = EMS_F_ThOpAlPerf);
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
                  goto ret_end;
            }

	  /* Update the instance data */
          /* Store the model  */

            if(me->symmetric)
                me->onesided_flag=FALSE;
            else
                me->symmetric_flag=FALSE;

          ME.ECcsoffset->input_obj.objid = 
               ME.ECelements->accev.located_object[0].located_obj.objid;
          ME.ECcsoffset->input_obj.osnum = 
               ME.ECelements->accev.located_object[0].located_obj.osnum;

          /*
           * If dynamics off, then we need to calculate the offset direction
           * depending up on the accepted event value
           */

          bufsize = sizeof( IGRboolean );
          dynamics_on = TRUE;
          gr$get_dynamics_on( msg = &msg_loc, sizbuf = &bufsize,
                                buffer = &dynamics_on, nret = &nret);

         /* Block to update the instance data based on input data to 
             the locate. */
          {
              IGRint              ii, jj;
              IGRpoint            pnt_buffer[5], normal;
              struct info         info_buffer;
              struct IGRpolyline  polyline;
              IGRpoint            dyn_point;
              IGRvector           surf_nor;

              dyn_point[0] = dir_dyn.GRlc_event.located_object[0].proj_pnt[0];
              dyn_point[1] = dir_dyn.GRlc_event.located_object[0].proj_pnt[1];
              dyn_point[2] = dir_dyn.GRlc_event.located_object[0].proj_pnt[2];
            /* Initialize me->axis_dir */

              stat_OM = EFfind_average_arrow_normal(&msg_loc,
                        &dir_dyn.GRlc_event.located_object[0].module_info,
                        dir_dyn.GRlc_event.located_object[0].located_obj,
                        dir_dyn.GRlc_event.located_object[0].geom_parms.leaf_id,
                        dyn_point, surf_nor);
              EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail,
                             ret_end);

              OM_BLOCK_MOVE(surf_nor, me->axis_dir, sizeof(IGRvector));

#ifdef DEBUG
 printf("The axis_dir is %lg, %lg, %lg\n", me->axis_dir[0], me->axis_dir[1],
        me->axis_dir[2]);
#endif

              for(ii=0; ii<3; ii++)
              {
                  pnt_buffer[0][ii] = dyn_point[ii];
                  pnt_buffer[1][ii] = pnt_buffer[0][ii] + me->axis_dir[ii];
              }
              for(ii=2; ii<5; ii++)
                  for(jj=0; jj<3; jj++)
                      pnt_buffer[ii][jj] = pnt_buffer[1][jj];

              polyline.num_points = 5;
              polyline.points = (IGRdouble *) pnt_buffer;
              info_buffer.num_elems = 0;
              info_buffer.elems = NULL;

              dp$build_dis_buffer( buffer = &info_buffer.header,
                                type = IGRPY, display_att = NULL,
                                geometry = (struct IGRpolyline *) &polyline);

              for(ii=0; ii<3; ii++)
                  normal[ii] = me->axis_dir[ii];

              info_buffer.normal = &normal[0];

              Hole_EFdymodvec( &info_buffer,
                               &ME.ECelements->accev.event.button,
                               NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL );

#ifdef DEBUG
 printf("The normal is %lg, %lg, %lg\n", normal[0], normal[1],
        normal[2]);
#endif

              if( (BSdotp (&msg_loc, me->axis_dir, normal)) > 0.0 )
                  me->inward = TRUE;
              else
                  me->inward = FALSE;
#ifdef DEBUG
 printf("me->inward = %d", me->inward);
#endif

              for(ii=0; ii<3; ii++)
                  me->axis_dir[ii] = normal[ii];
          }

      /* Check class of located object and update instance data */

#ifdef DEBUG
 printf("The located object id = %d, osnum = %d\n", 
               ME.ECcsoffset->input_obj.objid, ME.ECcsoffset->input_obj.osnum);
#endif

        stat_OM = om$get_classid(objid = ME.ECcsoffset->input_obj.objid,
                         osnum = ME.ECcsoffset->input_obj.osnum,
                         p_classid = &locobj_classid);
        if (!(1&stat_OM)) goto ret_end;
          
        if((om$is_ancestry_valid(superclassid = OPP_EMSsubbs_class_id,
                               subclassid = locobj_classid) == OM_S_SUCCESS))
        {
            IGRuchar              sf_props;

            me->is_solid = FALSE;
            me->multi_tk = FALSE;
	    me->multiple_tk_flag = FALSE;

            stat_OM = om$send(msg = message EMSsubbs.EMget_props
                                            (&msg_loc, &sf_props),
                  targetid = me->input_obj.objid,
                  targetos = me->input_obj.osnum);
            EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, 
                  ret_end);

            if(sf_props & EMSIS_NRML_REVERSED)
                        me->inward = me->inward ? 0 : 1;
        }
        else
        {
         /* It is either a solid or a composite surface */
          num_edges = buff_size = 0;
          stat_OM = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                            EMS_OPT_CONNECTABLE, NULL, &buff_size, &num_edges,
                            NULL, NULL, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetos = me->input_obj.osnum,
                      targetid = me->input_obj.objid);
          EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

          if(num_edges > 0)
               me->is_solid = FALSE;
          else
               me->is_solid = TRUE;
#ifdef DEBUG
if (me->is_solid)
    printf("Number of connectable edges = 0; It is a SOLID\n");
else
    printf("Number of connectable edges = %d; It is a COMPOSITE SURFACE\n",
                                                                   num_edges);
printf("#### Common_Surface Id = %d\n", me->common_surf);
#endif
        }

          /* The direction has already been stored in me->axis_dir -
             refer to the method 'dir_dynamics' in this file */
          locev = &ME.ECelements->locev;
          accev = &ME.ECelements->accev;
          if (locev->response == EX_OBJID ||
              (locev->subtype != GRst_REGULAR &&
               accev->num_id &&
               locev->located_object[0].located_obj.objid ==
                accev->located_object[0].located_obj.objid))
            putq = FALSE;
          else
            putq = TRUE;
/*
          if (putq)
            ex$putque (msg = &msg_loc, response = response,
             byte = &eventsize, buffer = (char *) &accev->event);
*/
          /* Send message - 'Evaluating Geometry'   
          ex$message (msgnumb = EMS_I_EvalGeom);  
            Check for Non-homogeneous Edges and
                      Non-manifold vertices   - TBD  */

          /* Half-Highlight the Model  */

          dp$erase_hilite (msg = &msg_loc);
          dpmode = GRhhd;
          om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
           &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
           &env->md_id), targetid = ME.ECcsoffset->input_obj.objid,
           targetos = ME.ECcsoffset->input_obj.osnum);

          if(me->is_solid)
            ME.super_cmd->state = LOCATE_OPENSFS_STATE;
          else
            ME.super_cmd->state = COMMON_THICKNESS_STATE;
          }
        break;

      case LOCATE_OPENSFS_STATE: 

	ex$message(msgnumb = EMS_P_SfToLvOpen, buff = elem_type);
	ex$message(msgnumb = EMS_P_MvOnNone, buff = msg_1);
	ex$message(msgnumb = EMS_P_SfToLvOpen, buff = msg_2);
        ME.ECelements->num_elems  = 0;
        ME.ECelements->num_events = 0;
        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data, elem_type,
                   NULL, msg_1, msg_2, NULL, EC_LOC_NOHALFHILITE ||
                                             EC_LOC_PROJLOCPT),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

       /* Check whether the input object is a pure solid of revolution or
          projection. If so, donot group tangent surfaces. */
        stat_OM = om$get_classid(objid = me->input_obj.objid,
                                 osnum = me->input_obj.osnum,
                                 p_classid = &locobj_classid);
        if (!(1&stat_OM)) goto ret_end;

       /* Special solids are those which have the special offset
          algorithms. These should be tested for associativity. */

        special_solid = FALSE;
        if(locobj_classid == OPP_EMSsfsolid_class_id)
          {
           IGRshort props;
           struct GRid tmpgrid;
           GRclassid   surf_classid;
           OM_S_CHANSELECT chan_to_comps;

           EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

           /*
            * Get the id of the object on channel index zero of
            * the 'sfsolid', and check its class. if it is an
            * associative surface of projection or revolution 
            * it qualifies as a special solid.
            */
           stat_OM =  om$get_objid_at_index (objid = me->input_obj.objid,
                                      osnum = me->input_obj.osnum,
                                      p_chanselect = &chan_to_comps,
                                      index = 0,
                                      objidaddr = &tmpgrid.objid,
                                      osnumaddr = &tmpgrid.osnum);
           EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

           stat_OM = om$get_classid(objid = tmpgrid.objid,
                             osnum = tmpgrid.osnum,
                             p_classid = &surf_classid);
           EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

           if((surf_classid == OPP_EMSrevcompsf_class_id) ||
              (surf_classid == OPP_EMSprjcompsf_class_id))
             {

               stat_OM = om$send(msg = message GRgraphics.GRgetprops
                                 (&msg_loc, &props),
                         targetid = me->input_obj.objid,
                         targetos = me->input_obj.osnum);
               EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
                           ret_end);
#ifdef DEBUG
  printf(" props = %d\n", props);
#endif
              if(props & GRIS_ASSOCIATIVE)
                {
                 special_solid = TRUE;
#ifdef DEBUG
  printf(" Note :  special solid encountered\n");
#endif
                }
             } /* if((surf_class... */
          }
        
       /* Store the open surface information */

        num_sfs1 = ME.ECelements->num_elems;
        if(num_sfs1 > 0) 
	  {
            surface = (GRobjid *) om$malloc(size = num_sfs1*sizeof(GRobjid));
            for(i=0;i < num_sfs1;i++)
                surface[i] = ME.ECelements->elems[i].located_obj.objid;
            if(!special_solid)
            {
                ex$message(msgnumb = EMS_I_GroupTanOpenSfs);
                surface_osnum = ME.ECelements->elems[0].located_obj.osnum;
                for(i=0;i<num_sfs1;i++)
		  {
                        EMget_tgt_surfaces(&msg_loc,surface[i],surface_osnum,
                                &new_surface, &num_new_sfs,
                                &env->md_env.matrix_type,
                                env->md_env.matrix);
                        if(num_new_sfs > 0)
			  {
                                EMattach_surfaces(&surface,num_sfs1,new_surface,
                                        num_new_sfs,&added_sfs);
                                num_sfs1 += added_sfs;
                                om$dealloc(ptr = new_surface);
			  }
		  } /* end of for(i=0; i<num_sfs1....) */
            } /* end of if(!special_solid) */
	  }

        if (num_sfs1)
          {
          ex$message(msgnumb = EMS_I_SelTanOpenSfsHl);
          if(om$dimension_of(varray = me->open_surf_ids) <= 
                                    me->num_opensfs + num_sfs1) 
            {
              stat_OM = om$vla_set_dimension(varray = me->open_surf_ids,
                        size = me->num_opensfs + num_sfs1);
              ERROR(stat_OM, 1, "execute(7).vla_set_dimension");
            }

          for (i=0; i<num_sfs1; i++)
           {
            /* Store all the open surface ids in the instance data */
             ME.ECshsolid->open_surf_ids[me->num_opensfs + i] = surface[i];
           }
          om$dealloc(ptr = surface);
          }

         ME.ECshsolid->num_opensfs += num_sfs1;
         for (i=0; i<me->num_opensfs; i++)
         {
           /* Highlight all the open surfaces */
             dpmode = GRhd;
             stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                      &env->md_id),
                     targetid = me->open_surf_ids[i],
                     targetos = ME.ECcsoffset->input_obj.osnum);
             EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                         ret_end);
         }

         /* Check for Null_Solid due to open sfs */
         if(me->num_opensfs > 0)
         {
           IGRint total_num_sfs;
         /*
          * get  count of number of surfaces of this composite surface/solid
         */

           sts = om$send( msg = message GRowner.GRget_number_components(
                                &msg_loc, &total_num_sfs),
                        senderid = NULL_OBJID,
                        targetid = me->input_obj.objid,
                        targetos = me->input_obj.osnum );
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
           printf("Total numsfs of objid = %d is count = %d \n", 
                      me->input_obj.objid, total_num_sfs);
           printf(" Number of Open sfs = %d\n", me->num_opensfs);
#endif
          /* If number of open surfaces greater than equal to 'total_num_sfs' 
             the resulting Thinwall will be a NULL SOLID */
           if(me->num_opensfs >= total_num_sfs)
           {
              ex$message(msgnumb = EMS_F_NullSolidOpenSfs);
              me->state = LOCATE_SOLID_STATE1;
              break;
           }
         }
         if(*response == CMD_STRING || *response == EX_STRING)
         {
            if(strlen(response_data)==1)
            {
            switch(response_data[0])
            {
                case 'o' : case 'O' :
                  if(me->onesided_flag)
                  {
		    me->symmetric = FALSE;
                  }
                break;
                case 's' : case 'S' :
                  if(me->symmetric_flag)
                  {
		    me->symmetric = TRUE;
                  }
                break;
                case 'c' : case 'C' :
                  if(me->common_tk_flag)
                  {
                  me->multi_tk = FALSE;
                  }
                break;
                case 'm' : case 'M' :
                  if(me->multiple_tk_flag)
                  {
                  me->multi_tk = TRUE;
                  }
                break;
                default :
                goto ret_end;
            }
            }
            else
                goto ret_end;

        }
        if (useract == EMSuser_moveon)
          ME.super_cmd->state = COMMON_THICKNESS_STATE;
        else if (useract == EMSuser_backup)
        {
          me->input_obj.objid = NULL_OBJID;
          ME.super_cmd->state = LOCATE_SOLID_STATE1;
        }
        else if(*response != CMD_STRING && *response != EX_STRING)
          goto ret_end;
        break;

       
      case COMMON_THICKNESS_STATE:
       /* Display the default thickness value from the options form */
	me->num_spec_tks = 0;
	me->spec_surf_id_count = 0;
	me->common_tk_flag = TRUE;
        ct = ME.ECcsoffset->common_thickness;
        ex$message(msgnumb = EMS_P_KeyinCoWallTk, type = "%.3f",
			var = `ct`, buff = inp_buff);
        ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = inp_buff);

        event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING; 

        stat_func = ems$getevent (msg = &msg_loc, event_mask = event_mask,
            value_type = GRIO_DISTANCE, event = &event,
            response = (long *)response, response_data = response_data);
	ex$message(msgnumb = EMS_P_00000);

       /* De-highlight the open surfaces and clear the information field */
        if(me->num_opensfs > 0)
          {
          for(i=0; i<me->num_opensfs; i++)
            {
            /* De-Highlight all the open surfaces */
             dpmode = GRhhd;
             stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                      &env->md_id),
                     targetid = me->open_surf_ids[i],
                     targetos = ME.ECcsoffset->input_obj.osnum);
             EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                         ret_end);
            }
          }
        ex$message(msgnumb = EMS_I_00000);

        if (msg_loc == GRw_no_value)
          {
          /* Assume default value for common-thickness */
           event.response = EX_VALUE;
           event.event.value = me->common_thickness;
           me->in_thick = event;

           if(!ME.ECcsoffset->multi_tk)
              ME.super_cmd->state = PROCESS_STATE;
           else
              {
              me->common_tk_flag = FALSE;
              ME.super_cmd->state = SPEC_THICKNESS_STATE;
	      }

           break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;

    /*  Get the current Chord Height Tolerance  */
        BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);

        switch (event.response)
          {
          case EX_VALUE:
            if (event.event.value < 0.0)
              {             
	      ex$message(msgnumb = EMS_I_WallTkMustbePos);
              break;
              }
            if (event.event.value <= 10*cht)
              {             
	      ex$message(msgnumb = EMS_I_WallTkMustbeGr10Cht);
              break;
              }

            ME.ECcsoffset->in_thick = event;
            ME.ECcsoffset->common_thickness = event.event.value;
            if(!ME.ECcsoffset->multi_tk)
              ME.super_cmd->state = PROCESS_STATE;
            else
              {
              me->common_tk_flag = FALSE;
              ME.super_cmd->state = SPEC_THICKNESS_STATE;
	      }
              
            break;

          case EX_RJT_MOVEON:
            me->in_thick.response=EX_VALUE;
            me->in_thick.event.value=ME.ECcsoffset->common_thickness;

            if (ME.ECcsoffset->common_thickness <= 10*cht)
              {             
	      ex$message(msgnumb = EMS_I_WallTkMustbeGr10Cht);
              break;
              }
            if(!ME.ECcsoffset->multi_tk)
              ME.super_cmd->state = PROCESS_STATE;
            else
              {
              me->common_tk_flag = FALSE;
              ME.super_cmd->state = SPEC_THICKNESS_STATE;
	      }
            break;
             

        /* case of parameter names */
          case EX_STRING:   

	    if(strlen(event.event.keyin)==1)
	    {
	    switch(event.event.keyin[0])
	    {
		case 'o' :
		case 'O' :
		  if(me->onesided_flag)
		  {
		    me->symmetric = FALSE;
		  }
		break;
		case 's' :
		case 'S' :
		  if(me->symmetric_flag)
		  {
		    me->symmetric = TRUE;
		  }
		break;
		case 'c' :
		case 'C' :
		  if(me->common_tk_flag)
		  {
	  	  me->multi_tk = FALSE; 
		  }
		break;
		case 'm' :
		case 'M' :
		  if(me->multiple_tk_flag)
		  {
	  	  me->multi_tk = TRUE; 
		  }
		break;
		default :
		goto ret_end;
	    }
	    }
	    else
		goto ret_end;
/*
            ME.ECcsoffset->in_thick = event;
            if(!ME.ECcsoffset->multi_tk)
              ME.super_cmd->state = PROCESS_STATE;
            else
              {
              me->common_tk_flag = FALSE;
              ME.super_cmd->state = SPEC_THICKNESS_STATE;
	      }
*/
            break;

          case EX_BACK_UP:

            if(me->is_solid)
                ME.super_cmd->state = LOCATE_OPENSFS_STATE;
            else
                ME.super_cmd->state = LOCATE_SOLID_STATE1;
            break;

          default:
            goto ret_end;
          }
        break;

      case SPEC_THICKNESS_STATE:

        ex$message(msgnumb = EMS_P_KeyIndWaTkMo, buff = inp_buff);
        ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = inp_buff);

        event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING;

        stat_func = ems$getevent (msg = &msg_loc, event_mask = event_mask,
            value_type = GRIO_DISTANCE, event = &event,
            response = (long *)response, response_data = response_data);
        ex$message(msgnumb = EMS_P_00000);
        if (msg_loc == GRw_no_value)
          break;
        if (msg_loc != MSSUCC)
          goto ret_end;

   /*  Get the current Chord Height Tolerance  */
        BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);


        switch (event.response)
          {
          case EX_VALUE:
            if (event.event.value < 0.0)
              {
              ex$message(msgnumb = EMS_I_WallTkMustbePos);
              break;
              }
            if (event.event.value <= 10*cht)
              {
              ex$message(msgnumb = EMS_I_WallTkMustbeGr10Cht);
              break;
              }
           /* If num_spec_tks greater than 4, reallocate space for
                 ME.ECcsoffset->spec_tk vla */
            if(om$dimension_of(varray = me->spec_tk) <= me->num_spec_tks)
             {
              stat_OM = om$vla_set_dimension(varray = me->spec_tk,
                        size = me->num_spec_tks + 1);
              ERROR(stat_OM, 1, "execute(7).vla_set_dimension");
             }

            ME.ECcsoffset->spec_tk[ME.ECcsoffset->num_spec_tks] = event;
            ME.ECcsoffset->num_spec_tks += 1;
            if(om$dimension_of(varray = me->num_sfs_per_tk)
                < me->num_spec_tks)
            {
               stat_OM = om$vla_set_dimension(varray = me->num_sfs_per_tk,
                   size = me->num_spec_tks);
               ERROR(stat_OM, 1, "execute(7).vla_set_dimension");
            }

            me->num_sfs_per_tk[me->num_spec_tks - 1] = 0;

            ME.super_cmd->state = SPEC_SURFACE_STATE;
            break;

          case EX_RJT_MOVEON:

            ME.super_cmd->state = PROCESS_STATE;

            break;


        /* case of parameter names */
          case EX_STRING:  

	    if(strlen(event.event.keyin)==1)
	    {
	      switch(event.event.keyin[0])
	      {
		case 'o' :
		case 'O' :
		  if(me->onesided_flag)
		  {
		    me->symmetric = FALSE;
		  }
		break;
		case 's' :
		case 'S' :
		  if(me->symmetric_flag)
		  {
		    me->symmetric = TRUE;
		  }
		break;
		case 'c' :
		case 'C' :
		  if(me->common_tk_flag)
		  {
	  	  me->multi_tk = FALSE; 
		  }
		break;
		case 'm' :
		case 'M' :
		  if(me->multiple_tk_flag)
		  {
	  	  me->multi_tk = TRUE; 
		  }
		break;
		default :
		goto ret_end;
	      }
	    }
	    else
		goto ret_end;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = COMMON_THICKNESS_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case SPEC_SURFACE_STATE:
        switch (me->spec_tk[me->num_spec_tks-1].response)
         {
          case EX_VALUE:
             ct = me->spec_tk[me->num_spec_tks-1].event.value;
             break;
          case EX_STRING:
             spek.type = EMSdatainfo_name;
             spek.valevent = &me->spec_tk[me->num_spec_tks-1];
             stat_OM = EMgetparval_numeric (&msg_loc, &spek, &ct);
             EMerr_hndlr (EMSerror (msg_loc & stat_OM), 
                                    stat_OM, EMS_E_Fail, ret_end);
             break;
          default:
             goto ret_end;
        }
              
        ex$message(msgnumb = EMS_P_TkSurface, type = "%.3f",
              var = `ct`, buff = elem_type);
        ex$message(msgnumb = EMS_P_MvOnWhenDone, buff = msg_1);
        ex$message(msgnumb = EMS_P_TkSurface, type = "%.3f",
              var = `ct`, buff = msg_2);

        tmpcount = ME.ECcsoffset->spec_surf_id_count;
 
        ME.ECelements->num_elems  = 0;
        ME.ECelements->num_events = 0;

        /* The 'EC_LOC_PROJLOCPT' option stores the projected points
           which are later used for placing of dimensions */

        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data, elem_type,
                   NULL, msg_1, msg_2, NULL, EC_LOC_NOHALFHILITE ||
                                             EC_LOC_PROJLOCPT),
                   targetid = my_id);

        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);
        num_sfs1 = ME.ECelements->num_elems;

        /* Process for surfaces tangentially connected to the identified
           surfaces and add them to the list of surfaces associated 
           with the current specific wall thickness.   
         */
        if(num_sfs1)
        {
            surface = (GRobjid *) om$malloc(size = num_sfs1*sizeof(GRobjid));
            for(i=0;i < num_sfs1;i++)
                surface[i] = ME.ECelements->elems[i].located_obj.objid;

                surface_osnum = ME.ECelements->elems[0].located_obj.osnum;

                for(i=0;i<num_sfs1;i++)
                {
                        EMget_tgt_surfaces(&msg_loc,surface[i],surface_osnum,
                                &new_surface, &num_new_sfs,
                                &env->md_env.matrix_type,
                                env->md_env.matrix);
                        if(num_new_sfs > 0)
                        {
                                EMattach_surfaces(&surface,num_sfs1,new_surface,
                                        num_new_sfs,&added_sfs);
                                num_sfs1 += added_sfs;
                                om$dealloc(ptr = new_surface);
                        }
                } /* end of for(i=0; i<num_sfs1....) */
        }

        /* Reset the instance array dimension and store the surface ids. */
        if(num_sfs1)
        {
            ME.ECcsoffset->spec_surf_id_count += num_sfs1;

            if(om$dimension_of(varray = me->spec_surf_ids)
                < me->spec_surf_id_count)
            {
               stat_OM = om$vla_set_dimension(varray = me->spec_surf_ids,
                   size = me->spec_surf_id_count);
               ERROR(stat_OM, 1, "execute(7).vla_set_dimension");
            }

            if(om$dimension_of(varray = me->num_sfs_per_tk)
                < me->num_spec_tks)
            {
               stat_OM = om$vla_set_dimension(varray = me->num_sfs_per_tk,
                   size = me->num_spec_tks);
               ERROR(stat_OM, 1, "execute(7).vla_set_dimension");
            }

            me->num_sfs_per_tk[me->num_spec_tks - 1] += num_sfs1;

            for(i=tmpcount; i<ME.ECcsoffset->spec_surf_id_count; i++)
            {
               ME.ECcsoffset->spec_surf_ids[i] =
                   surface[i-tmpcount];
            }
            om$dealloc(ptr = surface);
        } /* end of if(..num_elems) */

        if(me->num_elems)
        {
          if(om$dimension_of(varray = me->locpts)
                              <= (me->num_spec_tks) + 1)
          {
             stat_OM = om$vla_set_dimension(varray = me->locpts,
                      size = (me->num_spec_tks) + 1);
             ERROR(stat_OM, 1, "execute(7).vla_set_dimension");
          }

          /* Store the point of projection on the first surface
             for auto-dimensioning. */
          OM_BLOCK_MOVE (
               ME.ECelements->elems[0].proj_pnt,
               me->locpts[me->num_spec_tks - 1],
               sizeof (IGRpoint));
        }
        else
        {
          /* No surfaces have been input for this specific offset distance.
             So de-record this specific thickness and go back to the 
             thickness state.  This code also deals with command stacking while
             in this state. */
         if (useract == EMSuser_moveon &&
             me->num_sfs_per_tk[me->num_spec_tks - 1] == 0)
               me->num_spec_tks -= 1;
        }

         if(*response == CMD_STRING || *response == EX_STRING)
         {
            if(strlen(response_data)==1)
            {
            switch(response_data[0])
            {
                case 'o' : case 'O' :
                  if(me->onesided_flag)
                  {
		    me->symmetric = FALSE;
                  }
                break;
                case 's' : case 'S' :
                  if(me->symmetric_flag)
                  {
		    me->symmetric = TRUE;
                  }
                break;
                case 'c' : case 'C' :
                  if(me->common_tk_flag)
                  {
                  me->multi_tk = FALSE;
                  }
                break;
                case 'm' : case 'M' :
                  if(me->multiple_tk_flag)
                  {
                  me->multi_tk = TRUE;
                  }
                break;
                default :
                goto ret_end;
            }
            }
            else
                goto ret_end;

        }

        if (useract == EMSuser_moveon)
          ME.super_cmd->state = SPEC_THICKNESS_STATE;
        else if (useract == EMSuser_backup)
	{
	    me->spec_surf_id_count -= me->num_sfs_per_tk[me->num_spec_tks - 1];
            me->num_spec_tks -= 1;
            ME.super_cmd->state = SPEC_THICKNESS_STATE;
        }
        else if(*response !=CMD_STRING || *response == EX_STRING)
          goto ret_end;
        break;

      case PROCESS_STATE:

        /* Check for disjointness due to open surfaces. */
        if(me->num_opensfs)
        {
	   is_disjoint = 0;
	   EMfind_disjointness(&msg_loc, &me->input_obj,
			    me->open_surf_ids, env,
			    me->num_opensfs, 0, &is_disjoint);
	   if(is_disjoint)
	   {
              ex$message(msgnumb = EMS_F_WrnDsjSolid);
              me->state = LOCATE_SOLID_STATE1;
	      break;
	   }
        }
        dp$erase_hilite (msg = &msg_loc);
        ME.ECelements->elems_hilit = FALSE;

        const_list.msg = &msg_loc;
        const_list.env_info = env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelements->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
        const_list.geometry = NULL;
        const_list.display = &ME.ECelements->active_display;
        esbc.is_polydis = FALSE;
        esbc.is_curvedis = TRUE;
        const_list.class_attr = (IGRchar *) &esbc;
        const_list.name = NULL;
     
        /* Set up the common thickness data */ 
        switch (ME.ECcsoffset->in_thick.response)
        {
         case EX_VALUE:
           common_tk.type = EMSdatainfo_event;
           break;
         case EX_STRING:
           common_tk.type = EMSdatainfo_name;
           break;
         default:
           goto ret_end;
        }
        common_tk.valevent  = &ME.ECcsoffset->in_thick; 

       /* Setup the special thickness values */
        num_sptks = ME.ECcsoffset->num_spec_tks;
     
        if (num_sptks)
          {
          spectks = (struct EMSvalue_info *) 
                om$malloc (size = num_sptks * sizeof (struct EMSvalue_info));
          EMerr_hndlr (!spectks, stat_OM, OM_E_ABORT, ret_end);

          specs = ME.ECcsoffset->spec_tk;
          for (i=0; i<num_sptks; i++)
           {
            switch (specs[i].response)
            {
             case EX_VALUE:
                spectks[i].type = EMSdatainfo_event;
                break;
             case EX_STRING:
                spectks[i].type = EMSdatainfo_name;
                break;
             default:
                goto ret_end;
            } 
            spectks[i].valevent = &specs[i];
           } /* for loop ends */
          }

       /* Setup the open surface information */
        num_elems = ME.ECshsolid->num_opensfs;

        if (num_elems)
          {
          opensfs = (GRobjid *) om$malloc (size = num_elems * sizeof (GRobjid));
          EMerr_hndlr (!opensfs, stat_OM, OM_E_ABORT, ret_end);

          opsfs = ME.ECshsolid->open_surf_ids;
          for (i=0; i<num_elems; i++)
            opensfs[i] = opsfs[i];
          }

       /* Invoke the function to return a list of 'uv' points corresponding
          to the projected locate points for dimensioning of 'common'
          and 'special' thicknesses  */

       common_surf.objid = me->common_surf;
       common_surf.osnum = me->input_obj.osnum; 

       dim_info = (struct dimension_info *) om$malloc (size =
                            (num_sptks + 1) * sizeof(struct dimension_info));
       EMerr_hndlr (!dim_info, stat_OM, OM_E_ABORT, ret_end);

       stat_OM = EFget_dimensioning_information(&msg_loc,
                                   env,                        
                                   common_surf,
                                   me->common_surf_pt,
                                   num_sptks,
                                   me->num_sfs_per_tk,
                                   me->spec_surf_ids,
                                   me->locpts,
                                   num_elems,
                                   opensfs,
                                   dim_info);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);
       stat_OM = EMplace_shell (&msg_loc,
                   !(ME.ECcsoffset->associative) ? EMSasconst_notassociative : 
                                                  NULL, 
                   env, NULL, ME.ECcsoffset->input_obj.objid, 
                   ME.ECshsolid->symmetric,
                   ME.ECcsoffset->inward,
                   ME.ECshsolid->is_solid,   /* Added for shell from cs. */ 
                   &common_tk,
                   ME.ECcsoffset->num_spec_tks,
                   spectks,
                   ME.ECcsoffset->num_sfs_per_tk,
                   ME.ECcsoffset->spec_surf_ids,
                   dim_info,
                   num_elems, opensfs, &dprobj);
	ex$message(msgnumb = EMS_I_00000);
        if(spectks) om$dealloc(ptr = spectks);
        if(opensfs) om$dealloc(ptr = opensfs);
        if(dim_info) om$dealloc(ptr = dim_info);

        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

       /* Store the id of the created object in the instance 
          to enable undo on backup. */
        me->const_obj.objid = dprobj;
        me->const_obj.osnum = me->input_obj.osnum;

       /* Display the created solid, if it is a solid from a surface/
          Composite Surface.
       */
        if(!me->is_solid)
          {
           dpmode = GRbd;
           stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                      &env->md_id), 
                     targetid = dprobj,
                     targetos = ME.ECcsoffset->const_obj.osnum);
           EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                         ret_end);
#ifdef DEBUG
 printf("Displaying thinwall from surface \n");
#endif

          } /* end of if(!me->is_solid)  */

        if (msg_loc == EMS_I_Interrupt)
	  ex$message(msgnumb = EMS_I_Intrupt);
        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_SOLID_STATE1;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  if (EMSerror (stat_OM))
  {  
    ME.super_cmd->state = LOCATE_SOLID_STATE1;
    ME.ECelements->num_elems = 0;
    ME.ECelements->num_events = 0;
    me->num_spec_tks = 0;
    me->spec_surf_id_count = 0;
    me->num_opensfs = 0;
    stat_OM = OM_S_SUCCESS; /* reset to return case 0 */
  }

  return (stat_OM);
}

/* This function performs the dynamics for drawing the arrow  */

IGRint EFshell_dir_dynamics(grid, event, cmd)
struct GRid *grid;
struct GRevent *event;
struct GRid *cmd;
{
        IGRlong sts, msg_loc;
        sts = OM_S_SUCCESS;
        msg_loc = EMS_S_Success;

        sts = om$send(msg = message ECshsolid.dir_dynamics(grid, event,
                                cmd),
                        senderid = NULL_OBJID,
                        targetid = cmd->objid,
                        targetos = cmd->osnum);
        if(!(1 & sts))
                goto ret_end;
ret_end:
        return(sts);
}

/*  This method performs the dynamics for displaying the offset direction */

method dir_dynamics(struct GRid *grid; struct GRevent *event;
        struct GRid *cmd)
{
 IGRlong msg_loc, sts;
 IGRlong *msg;
 struct GRid win_id;
 IGRdouble dia_dist, dittol;
 IGRpoint dyn_point, to_pt;
 IGRint point_size;
 GRrange range;
 IGRvector axis_vec, surf_nor;
 enum GRdpmode dpmode;
 /* IGRlong stat_OM; */
 IGRint i,j, ret_sts;

 extern void EFdraw_vector_on_screen();
 extern IGRlong LCptlocact();
 extern IGRint Hole_EFdyvector();
 extern IGRlong  ECdisplayPointSetByBuffer0();
 extern void EMgetarrowheads();
 extern IGRint ECget_window_dittol();

      /*   Initialize  */ 

   msg = (IGRlong *) alloca (sizeof(IGRlong));
   *msg = EMS_S_Success;
   sts = OM_S_SUCCESS;

        point_size = sizeof(IGRpoint);
        win_id.objid = me->win_id.objid;
        win_id.osnum = me->win_id.osnum;

        if(me->symmetric)
        {
          ex$message(msgnumb = EMS_P_00038);
        }
        else
        {
          ex$message(msgnumb = EMS_P_AccDirRej);
        }

        /* Get the display unit tolerance i.e. minimum distance between
           two distinguishable points in the window. This function
           is defined in the file 'src_testco/funk/EFpattern.I'. 
        */
        ret_sts = ECget_window_dittol(&win_id, &dittol);  

        if(me->symmetric)
            dia_dist = dittol * 30.0;
        else
            dia_dist = dittol * 15.0; /* Set arrow size to 15 times 'dittol'*/

        OM_BLOCK_MOVE(event->located_object[0].proj_pnt, dyn_point, point_size);
    
        sts = EFfind_average_arrow_normal(&msg_loc, 
                        &event->located_object[0].module_info,
                        event->located_object[0].located_obj,
                        event->located_object[0].geom_parms.leaf_id,
                        dyn_point, surf_nor);
        EMerr_hndlr (EMSerror (msg_loc & sts), *msg, EMS_E_Fail, ret_end);

      /* Determine the unit normal at the 'dyn_point' on the surface **
        out_solid = FALSE;
        stat_OM = om$send (msg = message EMSsubbs.EMget_unit_norm
                    (&msg_loc, out_solid, NULL, 
                     &event->located_object[0].module_info.md_env,
                     (IGRdouble *)dyn_point,
                     &surf_nor[0]),
             targetid = event->located_object[0].geom_parms.leaf_id.objid,
             targetos = event->located_object[0].geom_parms.leaf_id.osnum);

        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

       */

#ifdef DEBUG
printf("### Objid of surface on which surf normal drawn = %d\n",
                  event->located_object[0].geom_parms.leaf_id.objid);
#endif

        OM_BLOCK_MOVE(surf_nor, axis_vec, sizeof(IGRvector));
        OM_BLOCK_MOVE(axis_vec, me->axis_dir, sizeof(IGRvector));

        to_pt[0] = dyn_point[0] + me->axis_dir[0] * dia_dist;
        to_pt[1] = dyn_point[1] + me->axis_dir[1] * dia_dist;
        to_pt[2] = dyn_point[2] + me->axis_dir[2] * dia_dist;

        if(me->symmetric)
         {
         /* Display a static symmetric arrow only */

          BSnorvec(&msg_loc, axis_vec);

          for(i = 0; i < 3; i++) 
           {
               range[i]=0.0; 
               range[i+3]=dia_dist; 
           }
          
          dpmode = GRhd;

          for(i=0; i<2; i++)
           {
            if(i == 1)
              for(j=0; j<3;j++)
                axis_vec[j] = -axis_vec[j];
            EFdraw_vector_on_screen(my_id, 
                                  &ME.ECelements->active_display,
                                  &event->located_object[0].module_info,
                                  dpmode,
                                  FALSE,
                                  dyn_point,
                                  axis_vec,
                                  range,
                                  &msg_loc);
            if(!(msg_loc & 1))
              {
                 goto ret_end;
              }
           } /* end of for(i=0...) */

         }
        else
         {
         /* Display a dynamic arrow */

          sts= ECdisplayPointSetByBuffer0(&msg_loc, 
                ME.ECelements->active_display,
                event->located_object[0].module_info, cmd->objid, 1,
                event->located_object[0].proj_pnt, GRbd, IGRPS);
          ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");

          Hole_EFdyvector(axis_vec, dyn_point, to_pt,
                              &ME.ECelements->active_display,
                              0, NULL);

          sts= ECdisplayPointSetByBuffer0(&msg_loc, 
                ME.ECelements->active_display,
                event->located_object[0].module_info, cmd->objid, 1,
                event->located_object[0].proj_pnt, GRbe, IGRPS);
          ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");

        /* Update the Instance Data */

          if (BSdotp (&msg_loc, axis_vec, surf_nor) > 0.0)
             me->inward = TRUE; 
          else
             me->inward = FALSE; 

          OM_BLOCK_MOVE(axis_vec, me->axis_dir, sizeof(IGRvector));

         } /* end of if(me->symmetric) .. */

        me->common_surf =
                  event->located_object[0].geom_parms.leaf_id.objid;
#ifdef DEBUG
  printf (" Dynamics - leaf objid = %d\n", 
                      event->located_object[0].geom_parms.leaf_id.objid);
#endif

        OM_BLOCK_MOVE (
               event->located_object[0].proj_pnt,
               me->common_surf_pt,
               sizeof (IGRpoint));

ret_end:
        return(sts);
}


/*
 The following action handler stores the  window-id of the window
 in which the 'data-point' to identify the solid/surface was given.
*/

EFshell_action_handler(
 shell_locate,
 new_entry,
 locate_args,
 action)

struct  shell_loc_acthndlr_args *shell_locate;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;

{
        IGRlong sts = OM_S_SUCCESS;


        sts = om$send(msg = message ECcsoffset.shell_action_handler(
                        shell_locate, new_entry, locate_args, action),
                senderid = NULL_OBJID,
                targetid = shell_locate->my_inst.objid,
                targetos = shell_locate->my_inst.osnum);

        if(!(1 & sts))
                goto ret_end;

ret_end:
        return(sts);
}

/* Action-handler to locate any surface of a solid as an open surface  */

IGRlong EMloc_open_surf_hndlr (curr_info, new_locinfo, priv_args, action)
struct open_surf_hndlr_args *curr_info;
struct GRlc_info *new_locinfo;
struct LC_action_args *priv_args;
enum GRlocate_action *action;
{
  IGRboolean eligible;
  IGRlong    stat_func;
  struct GRid *search_id;
  struct locate_acthndlr_args *act_args;
  IGRlong stat_OM, msg_loc;
  IGRlong *msg = NULL;
  struct  GRid  start_surf_GRid;
  IGRboolean    already_located=TRUE;
  IGRlong EMlocate_eligchk_hndlr();

  stat_func = TRUE;
  eligible = FALSE;
  stat_OM = OM_S_SUCCESS;

  msg = (IGRlong *) om$malloc (size = sizeof(IGRlong));
  *msg = EMS_S_Success;

  search_id = &new_locinfo->located_obj;

  stat_OM = om$send(msg = message EMSsurface.EMgetactiveid (&msg_loc,
                      &start_surf_GRid, NULL),
                senderid = NULL_OBJID,
                targetid = search_id->objid,
                targetos = search_id->osnum);
  EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
  if((start_surf_GRid.objid == curr_info->solid->objid) &&
     (start_surf_GRid.osnum == curr_info->solid->osnum))
          eligible = TRUE; 

   if(eligible)
   {

      om$send(msg = message ECcsoffset.element_located(
       search_id->objid,&already_located),
       senderid = NULL_OBJID,
       targetid = curr_info->my_inst.objid,
       targetos = curr_info->my_inst.osnum);

      if(already_located == FALSE)
      {
       /* Call the default action-handler defined in ECelements  */
         act_args =  &curr_info->actargs;
         stat_func = EMlocate_eligchk_hndlr (act_args, new_locinfo, priv_args,
                                         action);
      }
  }

ret_end:
  EMWRAPUP(stat_func, *msg, "ECshsolid.EMloc_open_surf_hndlr");
  if(msg) om$dealloc(ptr = msg);
  return(stat_func);
}

/* Method to avoid locating a surface more than once either as
   an 'open' or a 'special thickness' surface. 
 */
method element_located(GRobjid id; IGRboolean *located)
{
    int temp;
    IGRlong  *msg, msg1 = EMS_S_Success, stat_OM = OM_S_SUCCESS;

    msg = &msg1;
    *located = FALSE;
    for(temp=0;temp < me->num_opensfs;temp++)
    {
        if(id == me->open_surf_ids[temp])
        {
        *located = TRUE;
        goto ret_end;
        }
    }
    stat_OM = om$send (msg = message ECcsoffset.element_located(id, located),
                       targetid = my_id,
                       mode = OM_e_wrt_message);
    EMerr_hndlr(!(1 & stat_OM), *msg, EMS_E_Fail, ret_end);
    

ret_end:
    return OM_S_SUCCESS;

}

end implementation ECshsolid;

