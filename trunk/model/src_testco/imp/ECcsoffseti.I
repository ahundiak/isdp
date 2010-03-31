/*
NAME:
 methods:
  init, wakeup, sleep, execute, dir_dynamics, get_locate_criteria,
  shell_action_handler, element_located 

 functions:
  EFdir_dynamics, EFoffsurf_action_handler, EMloc_open_surf_hndlr1

ABSTRACT:

 This is the command object for creating 'Offset Surfaces' from primitive
 or composite surfaces. 

HISTORY:

 sampath:02/01/93 : Creation.
 sampath:04/19/93 : Changed GRdisplay_status_display_button to
		    GRstatus_display_button.
 Sudha   07/05/93   Modified for BSprototypes ansification
 Sudhakar:25Jul93 : Modified for Auto-dimensioning and UMS compliance.
 Sudhakar:24Aug93 : Modified code for size of direction arrow to be of
                    fixed size (15 * dittol).
 sampath:09/15/93 : Made chages to allow stacking  the command in
		    SPEC_SURFACE_STATE.
 sampath:09/16/93 : fixed backup problem in LOCATE_SOLID_STATE.
 Sudhakar:24Sep93 : Modified to obtain appropriate 'dimensioning' info instead
                      of 'nearest edges'.
 Sudhakar:23Nov93 : Modified the options message not to display 'to one side'
                    as an option which can be changed (Fix for TR# 119313356).
 Sudhakar:27Nov93 : Added code to
                         a) display an 'average dynamic arrow'.
                         b) disallow identifying the composite component of a
                            solid or comp. surface for thinwalling. Either the
                            whole solid/comp.surface or a primitive surface is
                            identified for 'thinwalling'.
 Sanjay  :14Feb94 : Fix for setting of correct direction of offset during 
                    play-back [TR# 119417121].
 Sanjay  :18Jul94 : Fix for using the correct leaf_id of the located event
                    (EMS4 fix).
 scw     :19jul94 : BUILD FIX : Fixed compile error because the last person
                    to check in this file never compiled it before putting it
                    into the source management system. Problem: undefined
                    variable. This is what happens when you cut and paste and
                    don't test.  - IM Integration
 Sanjay  :25jul94 : Removed global variable "IGRpoint dpt" which was added as
                    the last minute kludge for EMS 3.0.
 scw     :08/23/94: Modified AGAIN to reflect changes needed for the Intel 
                    Solaris port.  This is the second such time I have had to
                    make changes that were either made in a previous version 
                    and overwritten or by someone not compiling their changes.
                    This is the exact change I made about six days ago.  You
                    guys be careful about overwriting other peoples changes.
                    You are not the only ones to work on these files.
*/

class implementation ECcsoffset;


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
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "exmacros.h"
#include "msdef.h"
#include "lcmacros.h"
#include "EMSaction.h"
#include "EMSasmacros.h"
#include "emssfintdef.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EC_M.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSfeadef.h"
#include "EMSdpb.h"
#include "ECmsg.h"
#include "dpmacros.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include <stdio.h>

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


#define LOCATE_SOLID_STATE1       0
#define LOCATE_SOLID_STATE2       1
#define COMMON_THICKNESS_STATE    2
#define SPEC_THICKNESS_STATE      3
#define SPEC_SURFACE_STATE        4
#define PROCESS_STATE             5

#define FAIL   0


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
                 OPP_EMSrevcompsf_class_id,
                 OPP_EMSprjcompsf_class_id,
                 OPP_EMSrevol_class_id,
                 OPP_EMSproject_class_id,
                 OPP_EMSsolid_class_id,
                 OPP_GRlinear_class_id,
                 OPP_GRcompcurve_class_id,
                 OPP_EMStorus_class_id,
                 OPP_EMAtorus_class_id,
		 OPP_EMSsfimpbnd_class_id,
                 OPP_EMScompsurf_class_id;

from GRgraphics import GRdisplay;
from GRgraphics import GRgetprops;
from EMSparamgm import EMgetgeom;
from GRcurve    import GRendpts;
from EMSassoc   import EMpack_paraminfo;
from GRvg       import GRgeomprops, GRgetgeom, GRgetsize;
from ECplhole   import hole_dynamics;
from EMSsubbs   import EMgetbsdef, EMget_unit_norm;
from EMSsurface import EMgetactiveid;

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
   struct GRid *surface;
   struct GRid my_inst;
   struct GRmd_env *env;
   struct locate_acthndlr_args actargs;
};

static struct info
{       struct DPele_header header;
        IGRdouble *normal;
        IGRint    num_elems;
        struct GRid *elems;
};


method init(int type; char *str_ptr)
{
   IGRlong     sts;
   short       num_defaults = 1, flag = 0;
   IGRlong     msg = MSSUCC;
   IGRchar     units[52];

   ME.super_cmd->state = 0;
   ME.super_cmd->form_id = NULL_OBJID;
   me->form_displayed = FALSE;
/*
   me->symmetric = TRUE;
*/
   me->onesided_flag = TRUE;
   me->symmetric_flag = TRUE;
   me->common_tk_flag = TRUE;
   me->multiple_tk_flag = TRUE;
   me->inward = TRUE;
   me->multi_tk = FALSE;
   me->num_spec_tks = 0;
   me->spec_surf_id_count = 0;

   sts = om$send(mode = OM_e_wrt_message,
       msg = message ECelements.init(type, str_ptr),
       targetid = my_id);
   ERROR(sts, 1, "init.init error");
/*
   Set the default common surface thickness for the options form
   Get the default units
*/

   sts = co$get_default_units(msg = &msg,
       table_name = GRIO_DISTANCE,
       osnum = 2,
       flag = &flag,
       num_defaults = &num_defaults,
       default_units = units);
/*
   Based on the units assign a default value for diameter & depth
*/
   if(strncmp(units,"mm", 2) == 0)
   {
      me->common_thickness = 2.5;
   }
   else if(strncmp(units,"in", 2) == 0)
   {
      me->common_thickness = 0.100;
   }
ret_end:
   return(sts);
}


method wakeup (IGRint pos)
{
   IGRlong status;
   IGRint  ret;
   IGRboolean associative;

   status = OM_S_SUCCESS;

   status = om$send(mode = OM_e_wrt_message,
       msg = message ECelements.wakeup(pos),
       targetid = my_id);
   if (!(1&status)) return (OM_E_ABORT);

   gr$get_associative_flag(buffer = &associative);
   if(associative)
   {
      ME.ECcsoffset->associative = TRUE;
      GRdisplay_associative_button(TRUE);
   }
   else
      ME.ECcsoffset->associative = FALSE;

   GRstatus_display_button(TRUE);
   if(me->form_displayed == TRUE)
      ret = FIf_display (ME.ECcsoffset->form1);

   return(status);
}

method super_cmd.sleep (IGRint pos)
{
   IGRlong status;

   status = OM_S_SUCCESS;
   if(ME.ECcsoffset->associative)
      GRdisplay_associative_button(FALSE);

   GRstatus_display_button(FALSE);
   status = om$send(mode = OM_e_wrt_message,
       msg = message ECelements.sleep(pos),
       targetid = my_id);
   if (!(1&status)) return (OM_E_ABORT);

   if(me->form_displayed == TRUE)
      FIf_erase (ME.ECcsoffset->form1);

   return(status);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
   IGRboolean stat_func;
   IGRchar *p_actargs;
   IGRint i,tmpcount;
   IGRlong msg_loc, stat_OM, object_was_located, event_mask, eventsize;
   IGRlong display_flag, locate_mask, accept_mask, bufsize;

   IGRuchar buffer;

   GRclassid rclass[2], eliclass[2];
   GRobjid *opensfs;
   struct IGResbs esbs,*surface_specific;
   struct GRmd_env *env;
   struct GRevent event, *locev, *accev,comm_event;

   struct GRlc_locate attributes;
   struct GRvg_construct const_list;
   char inp_buff[GR_MAX_CHAR];
   IGRchar /* side_info[GR_MAX_CHAR], */ type_info[GR_MAX_CHAR];

   struct shell_loc_acthndlr_args offsurf_locate;
   IGRlong sts, nret;
   IGRdouble cht, ct;
   struct EMSvalue_info *spectks=NULL,common_tk1,spek;
   struct EMSobject_info loc_surface;		/* located surface */

   GRobjid    *surface,*new_surface;
   IGRint     num_sfs1,num_new_sfs;
   IGRint     added_sfs;
   GRspacenum surface_osnum;
   IGRboolean is_c_loop, dynamics_on;
   OMuword 	locobj_classid;
   struct GRid new_obj;
   IGRint num_sptks;
   struct  GRid  common_surf;
   struct dimension_info *dim_info = NULL;
   OM_S_CLASSLIST rtree_classes, elig_classes;
   enum EMSuser_responses useract;
   enum GRdpmode dpmode;
   char elem_type[GR_MAX_CHAR], msg_1[GR_MAX_CHAR], msg_2[GR_MAX_CHAR];
   struct open_surf_hndlr_args my_actargs;
   struct GRlc_dynamics dir_dyn;
   struct GRid my_tmp_id;
   IGRint EFdir_dynamics();
   IGRint (*p_acthndlr)();
   IGRint EFshell_action_handler();
   IGRint EFoffsurf_action_handler();
   IGRlong EMloc_open_surf_hndlr();
   IGRlong EMloc_open_surf_hndlr1();
   extern IGRlong EFfind_average_arrow_normal();

   stat_OM = OM_S_SUCCESS;
   opensfs = NULL; 
   dynamics_on = TRUE;
   eventsize = sizeof (struct GRevent);
   env = &ME.ECelements->active_md_env;


      p_actargs = (IGRchar *) &my_actargs;
/*
      Locate handler to locate all types of solids/surfaces
*/
      p_acthndlr = (IGRint (*)())EMloc_open_surf_hndlr1;
      my_actargs.surface = &me->const_obj;
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

        ex$message(msgnumb = EM_M_0045);
        ex$message(msgnumb = EMS_I_InvkStatusFrm);

   do
   {
      switch (ME.super_cmd->state)
      {

      case LOCATE_SOLID_STATE1:
         GRstatus_display_button(TRUE);
         me->onesided_flag = TRUE;
         me->symmetric_flag = TRUE;
         me->common_tk_flag = TRUE;
         me->multiple_tk_flag = TRUE;
	 me->num_spec_tks = 0;
	 me->spec_surf_id_count = 0;
	 ex$message( msgnumb = EMS_P_00031);
      /* ex$message(msgnumb = EMS_I_OneSide, buff = side_info); */
         ex$message(msgnumb = (me->multi_tk ? EMS_I_Multiple : EMS_I_Common), 
                              buff = type_info);
         ex$message(msgnumb = EMS_I_OffDis, type = "%s",
              var = `type_info`, buff = inp_buff);
         ex$message(field = ERROR_FIELD, justification = CENTER_JUS,
                in_buff = inp_buff);

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
		  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
		break;
		case 's' :
		case 'S' :
		  if(me->symmetric_flag)
		  {
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
	 break;
	 case EX_DATA:
           ex$putque (msg = &msg_loc, response = &event.response,
                byte = &eventsize, buffer = (char *) &event.event);
           ME.super_cmd->state = LOCATE_SOLID_STATE2;
	 break;
	 case EX_BACK_UP:
           ME.super_cmd->state = LOCATE_SOLID_STATE1;
	 break;
	 default :
	   goto ret_end;
         }
      break;
      case LOCATE_SOLID_STATE2:

         dp$erase_hilite (msg = &msg_loc);
       /*  ex$message(msgnumb = EMS_I_OneSide, buff = side_info); */
         ex$message(msgnumb = (me->multi_tk ? EMS_I_Multiple : EMS_I_Common),
                              buff = type_info);
         ex$message(msgnumb = EMS_I_OffDis, type = "%s",
              var = `type_info`, buff = inp_buff);
         ex$message(field = ERROR_FIELD, justification = CENTER_JUS,
                in_buff = inp_buff);

         display_flag = ALL_WINDOWS | ELEM_HILIGHT;
         locate_mask = GRm_DATA;
         accept_mask = GRm_DATA;

/*
      Add the additional classes of composite surfaces and
      simple surfaces for selection    - TBD
*/

         elig_classes.w_count = 1;
         eliclass[0] = OPP_EMSsurface_class_id;
         elig_classes.p_classes = eliclass;
         elig_classes.w_flags = OM_CLST_subclass;

         rtree_classes.w_count = 1;
         rclass[0] = OPP_EMSsubbs_class_id;
         rtree_classes.w_flags = OM_CLST_subclass;
         rtree_classes.p_classes = rclass;

         attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
         attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
	     LC_RIGID_COMP| LC_FLEX_OWNER |
             LC_NO_REF_HEADER | LC_REF_OBJECTS |
             LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;

/*  change action handler  p_acthndlr = NULL; */

         p_acthndlr = EFoffsurf_action_handler;
         offsurf_locate.my_inst.objid = my_id;
         offsurf_locate.my_inst.osnum = OM_Gw_current_OS;
         offsurf_locate.next = NULL;

 /*  - Setup the dyn. method data-structure.
       The dir_dynamics methods sets the following instance data:
          me->axis_dir
          me->common_surf
          me->common_surf_pt
 */
         my_tmp_id.objid = my_id;
         my_tmp_id.osnum = OM_Gw_current_OS;
         dir_dyn.GRlc_dyn = EFdir_dynamics;
         dir_dyn.add_info = (IGRchar *)&my_tmp_id;

         lc$locate (rc = &object_was_located,
             event1 = &ME.ECelements->locev,
             event2 = &ME.ECelements->accev,
             mask1 = locate_mask,
             mask2 = accept_mask,
             display_flag = display_flag,
             response = response,
             response_data = response_data,
             locate_key = EMS_P_00031,
             acc_prompt = "",
             relocate_prompt = inp_buff,
             dyn = &dir_dyn,
             attributes = &attributes,
             stack = &ME.ECelements->locate_stack,
             act_handler = p_acthndlr,
             act_args = &offsurf_locate,
             rtree_classes = &rtree_classes,
             eligible_classes = &elig_classes);


         if (!object_was_located)
	 {
	   if (EMSerror (stat_OM))
	      goto ret_end;
            ME.super_cmd->state = LOCATE_SOLID_STATE1;
	      goto ret_end;
	 }
         else
         {
            /*
             * If dynamics is off, Do the following
             */

            bufsize = sizeof( IGRboolean );

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
                extern struct GRevent GRlocate_event;

                /*
                 * Initilize the dyn_point, which is nothing but the projected
                 * point on the located solid. The located event is always av-
                 * ailable in dir_dyn structure. This is the event used in the
                 * dynamics function. -- Sanjay
                 */
                dyn_point[0] = dir_dyn.GRlc_event.located_object[0].proj_pnt[0];
                dyn_point[1] = dir_dyn.GRlc_event.located_object[0].proj_pnt[1];
                dyn_point[2] = dir_dyn.GRlc_event.located_object[0].proj_pnt[2];

                /*
                 * Initialize me->axis_dir
                 */
                stat_OM = EFfind_average_arrow_normal(&msg_loc,
                        &dir_dyn.GRlc_event.located_object[0].module_info,
                        dir_dyn.GRlc_event.located_object[0].located_obj,
                        dir_dyn.GRlc_event.located_object[0].geom_parms.leaf_id,
                        dyn_point, surf_nor);
                EMerr_hndlr (EMSerror (msg_loc & stat_OM), stat_OM, EMS_E_Fail,
                             ret_end);

                OM_BLOCK_MOVE(surf_nor, me->axis_dir, sizeof(IGRvector));

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


                if(BSdotp (&msg_loc, me->axis_dir, normal) > 0.0)
                    me->inward = TRUE;
                else
                    me->inward = FALSE;

                for(ii=0; ii<3; ii++) 
                    me->axis_dir[ii] = normal[ii];
            }
     
/*
            Store the model
*/
            loc_surface.env =
		ME.ECelements->accev.located_object[0].module_info;
            loc_surface.grid = me->const_obj =
                ME.ECelements->accev.located_object[0].located_obj;

	    if(me->onesided_flag)
		me->symmetric_flag=FALSE;
	    else if(me->symmetric_flag)
		me->onesided_flag=FALSE;
/*
   The direction has already been stored in me->axis_dir -
             refer to the method 'dir_dynamics' in this file
*/
            locev = &ME.ECelements->locev;
            accev = &ME.ECelements->accev;
/*
            if (locev->response == EX_OBJID ||
                (locev->subtype != GRst_REGULAR &&
                accev->num_id &&
                locev->located_object[0].located_obj.objid ==
                accev->located_object[0].located_obj.objid))
               putq = FALSE;
            else
               putq = TRUE;

            if (putq)
               ex$putque (msg = &msg_loc, response = response,
                   byte = &eventsize, buffer = (char *) &accev->event);
*/


/*        Send message - 'Evaluating Geometry'  - TBD
          ex$message (msgnumb = EMS_I_EvalGeom);

            Half-Highlight the Model
*/

            loc_surface.grid = me->const_obj;
            dp$erase_hilite (msg = &msg_loc);
            dpmode = GRhhd;
            om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                &env->md_id), targetid = loc_surface.grid.objid,
		targetos = loc_surface.grid.osnum);

           EMtest_any_c_loops(&msg_loc,loc_surface.grid,&is_c_loop,env->md_env);
#ifdef DEBUG
            if(is_c_loop)
                printf("C -- Loop Exists on the surface\n");
#endif
          sts = om$get_classid(objid = me->const_obj.objid,
                         osnum = me->const_obj.osnum,
                         p_classid = &locobj_classid);
          if (!(1&sts)) 
		goto ret_end;

          if(!(om$is_ancestry_valid (subclassid = locobj_classid,
                    superclassid = OPP_EMScompsurf_class_id) == OM_S_SUCCESS))
          {
	    IGRlong sf_size;
	    struct IGRbsp_surface *sf_geom;

            	me->multi_tk = FALSE;
	        me->multiple_tk_flag = FALSE;

      		stat_OM = om$send(msg = message GRvg.GRgetsize(
                     &msg_loc,
                     &(env->md_env.matrix_type),
                     env->md_env.matrix,
                     &sf_size),
                     targetid = me->const_obj.objid,
                     targetos = me->const_obj.osnum);

         	EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             	ret_end);

       		/* allocate memory for surface geometry */

       		sf_geom = (struct IGRbsp_surface *) 
				om$malloc (size = (OMuint)sf_size);

       		/* Get the surface geometry */

      		stat_OM = om$send(msg = message GRvg.GRgetgeom(
                   &msg_loc,
                   &(env->md_env.matrix_type),
                  env->md_env.matrix,
                  (IGRchar *)sf_geom),
                  targetid = me->const_obj.objid,
                  targetos = me->const_obj.osnum);

         	EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             	ret_end);

		if(sf_geom->pos_orient==0)
			me->inward = me->inward ? 0 : 1;
		if(sf_geom) om$dealloc(ptr = sf_geom);

	  }
/*
   Check for Homogeneous edges  - TBD
          UI_message ("Checking for Non-Homogeneous Edges");
*/

/*
   Check for manifold vertices  - TBD
          UI_message ("Checking for Non-Manifold Vertices");
*/
            ME.super_cmd->state = COMMON_THICKNESS_STATE;
         }
         break;

      case COMMON_THICKNESS_STATE:

         msg_loc = MSSUCC;
	 me->num_spec_tks = 0;
	 me->spec_surf_id_count = 0;
	 me->common_tk_flag = TRUE;
         BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);
         ct = ME.ECcsoffset->common_thickness;
         ex$message(msgnumb = EMS_I_00000);
         ex$message(msgnumb = EMS_P_KeyinCoOffDis, type = "%.3f",
			var = `ct`, buff = inp_buff);
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = inp_buff);

         event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING;
         stat_func = ems$getevent (msg = &msg_loc, event_mask = event_mask,
             value_type = GRIO_DISTANCE, event = &event,
             response = (long *)response, response_data = response_data);

	 me->in_thick = event;
         if (msg_loc == GRw_no_value)
         {
            if (ME.ECcsoffset->common_thickness < 0.0)
            {
               ex$message(msgnumb = EMS_I_OffDisMustbePos);
               break;
            }
            if (ME.ECcsoffset->common_thickness <= 10*cht)
            {
               ex$message(msgnumb = EMS_I_OffDisMustbeGr10Cht);
               break;
            }
	    me->in_thick.event.value=ME.ECcsoffset->common_thickness;

            if(!ME.ECcsoffset->multi_tk)
               ME.super_cmd->state = PROCESS_STATE;
            else
	    {
		 me->common_tk_flag = FALSE;
                 ME.super_cmd->state = SPEC_THICKNESS_STATE;
	    }
            break;
         }
         if (msg_loc == MSFAIL)
            goto ret_end;

/*
         Get the current Chord Height Tolerance
*/


         switch (event.response)
         {
	    case EX_STRING:

	    if(event.event.keyin[0]=='\n')
	    {
		me->in_thick.response=EX_VALUE;
		me->in_thick.event.value=ME.ECcsoffset->common_thickness;
		if(!ME.ECcsoffset->multi_tk)
		{
		   ME.super_cmd->state = PROCESS_STATE;
		   comm_event =event;
		}
		else
		{
		   me->common_tk_flag = FALSE;
		   ME.super_cmd->state = SPEC_THICKNESS_STATE;
		}
		break;
	    }
	    else
	    if(strlen(event.event.keyin)==1)
	    {
	    switch(event.event.keyin[0])
	    {
		case 'o' :
		case 'O' :
		  if(me->onesided_flag)
		  {
		  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
		break;
		case 's' :
		case 'S' :
		  if(me->symmetric_flag)
		  {
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
	    {
		goto ret_end;
/*
                junk strings should be checked here -- TBD
                if(!ME.ECcsoffset->multi_tk)
                {
		   comm_event =event;
                   ME.super_cmd->state = PROCESS_STATE;
                }
                else
                {
                   me->common_tk_flag = FALSE;
                   comm_event =event;
                   ME.super_cmd->state = SPEC_THICKNESS_STATE;
                }
*/
	    }
	 break;
         case EX_VALUE:
            if (event.event.value < 0.0)
            {
               ex$message(msgnumb = EMS_I_OffDisMustbePos);
               break;
            }
            if (event.event.value <= 10*cht)
            {
               ex$message(msgnumb = EMS_I_OffDisMustbeGr10Cht);
               break;
            }
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
                ex$message(msgnumb = EMS_I_OffDisMustbeGr10Cht);
		break;
            }
            if(!ME.ECcsoffset->multi_tk)
	       {
               ME.super_cmd->state = PROCESS_STATE;
	       comm_event =event;
	       }
            else
	       {
	       me->common_tk_flag = FALSE;
               ME.super_cmd->state = SPEC_THICKNESS_STATE;
	       }
            break;

         case EX_BACK_UP:
            ME.super_cmd->state = LOCATE_SOLID_STATE1;
            break;
	 default :
	    goto ret_end;
         }
         break;

      case SPEC_THICKNESS_STATE:

         ex$message(msgnumb = EMS_I_00000);
         ex$message(msgnumb = EMS_P_KeyIndOffDisMo, buff = inp_buff);
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = inp_buff);

         event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING;
         stat_func = ems$getevent (msg = &msg_loc, event_mask = event_mask,
             value_type = GRIO_DISTANCE, event = &event,
             response = (long *)response, response_data = response_data);

         if (msg_loc == GRw_no_value)
         {
/*          ex$message(msgnumb = EMS_I_00006); */
            break;
         }
         if (msg_loc != MSSUCC)
            goto ret_end;

/*
         Get the current Chord Height Tolerance.
*/
         BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);


         switch (event.response)
         {
         case EX_VALUE:
            if (event.event.value < 0.0)
            {
               ex$message(msgnumb = EMS_I_OffDisMustbePos);
               break;
            }
            if (event.event.value <= 10*cht)
            {
               ex$message(msgnumb = EMS_I_OffDisMustbeGr10Cht);
               break;
            }
            if(om$dimension_of(varray = me->spec_tk) <= me->num_spec_tks)
            {
               sts = om$vla_set_dimension(varray = me->spec_tk,
                   size = me->num_spec_tks + 1);
               ERROR(sts, 1, "execute(7).vla_set_dimension");
            }

            ME.ECcsoffset->spec_tk[ME.ECcsoffset->num_spec_tks] = event;
            ME.ECcsoffset->num_spec_tks += 1;

            if(om$dimension_of(varray = me->num_sfs_per_tk)
                < me->num_spec_tks)
            {
               sts = om$vla_set_dimension(varray = me->num_sfs_per_tk,
                   size = me->num_spec_tks);
               ERROR(sts, 1, "execute(7).vla_set_dimension");
            }
            me->num_sfs_per_tk[me->num_spec_tks - 1] = 0;
            ME.super_cmd->state = SPEC_SURFACE_STATE;
            break;

         case EX_RJT_MOVEON:

            ME.super_cmd->state = PROCESS_STATE;
            break;

/*
            case of parameter names
*/
          case EX_STRING:

	    if(strlen(event.event.keyin)==1)
	    {
	    switch(event.event.keyin[0])
	    {
		case 'o' :
		case 'O' :
		  if(me->onesided_flag)
		  {
		  }
                  ME.super_cmd->state = LOCATE_SOLID_STATE1;
		break;
		case 's' :
		case 'S' :
		  if(me->symmetric_flag)
		  {
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
/*
		junk strings should be checked here -- TBD

                if(om$dimension_of(varray = me->spec_tk) <= me->num_spec_tks)
                {
                   sts = om$vla_set_dimension(varray = me->spec_tk,
                       size = me->num_spec_tks + 1);
                   ERROR(sts, 1, "execute(7).vla_set_dimension");
                }

                ME.ECcsoffset->spec_tk[ME.ECcsoffset->num_spec_tks] = event;
                ME.ECcsoffset->num_spec_tks += 1;

                if(om$dimension_of(varray = me->num_sfs_per_tk)
                    < me->num_spec_tks)
                {
                   sts = om$vla_set_dimension(varray = me->num_sfs_per_tk,
                       size = me->num_spec_tks);
                   ERROR(sts, 1, "execute(7).vla_set_dimension");
                }
                me->num_sfs_per_tk[me->num_spec_tks - 1] = 0;
                ME.super_cmd->state = SPEC_SURFACE_STATE;
*/
	 }
	 }
	 else
	 {
		goto ret_end;
/*
                junk strings should be checked here -- TBD

                if(om$dimension_of(varray = me->spec_tk) <= me->num_spec_tks)
                {
                   sts = om$vla_set_dimension(varray = me->spec_tk,
                       size = me->num_spec_tks + 1);
                   ERROR(sts, 1, "execute(7).vla_set_dimension");
                }

                ME.ECcsoffset->spec_tk[ME.ECcsoffset->num_spec_tks] = event;
                ME.ECcsoffset->num_spec_tks += 1;

                if(om$dimension_of(varray = me->num_sfs_per_tk)
                    < me->num_spec_tks)
                {
                   sts = om$vla_set_dimension(varray = me->num_sfs_per_tk,
                       size = me->num_spec_tks);
                   ERROR(sts, 1, "execute(7).vla_set_dimension");
                }
                me->num_sfs_per_tk[me->num_spec_tks - 1] = 0;
                ME.super_cmd->state = SPEC_SURFACE_STATE;
*/
         }
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
         tmpcount = ME.ECcsoffset->spec_surf_id_count;
         ME.ECelements->num_elems = 0;
         ex$message(msgnumb = EMS_P_OffSurface, type = "%.3f",
              var = `ct`, buff = elem_type);
         ex$message(msgnumb = EMS_P_MvOnWhenDone, buff = msg_1);
         ex$message(msgnumb = EMS_P_OffSurface, type = "%.3f",
              var = `ct`, buff = msg_2);

	 me->num_events = 0;
	 me->num_elems  = 0;
	 ME.ECelements->display_flag & = ~ONE_WINDOW;
         stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
             &useract, response, response_data, elem_type,
             NULL, msg_1, msg_2, NULL, EC_LOC_NOHALFHILITE ||
                                              EC_LOC_PROJLOCPT),
             targetid = my_id);
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);

	 num_sfs1 = ME.ECelements->num_elems;
	 if(num_sfs1)
         {
	    surface = (GRobjid *) om$malloc(size = num_sfs1*sizeof(GRobjid));
	    for(i=0;i <	num_sfs1;i++)
		surface[i] = ME.ECelements->elems[i].located_obj.objid;

		surface_osnum =	ME.ECelements->elems[0].located_obj.osnum;

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
		}
	 }


	 if(num_sfs1)
	 {
	    ME.ECcsoffset->spec_surf_id_count += num_sfs1;

            if(om$dimension_of(varray = me->spec_surf_ids)
                < me->spec_surf_id_count)
            {
               sts = om$vla_set_dimension(varray = me->spec_surf_ids,
                   size = me->spec_surf_id_count);
               ERROR(sts, 1, "execute(7).vla_set_dimension");
            }

            if(om$dimension_of(varray = me->num_sfs_per_tk)
                < me->num_spec_tks)
            {
               sts = om$vla_set_dimension(varray = me->num_sfs_per_tk,
                   size = me->num_spec_tks);
               ERROR(sts, 1, "execute(7).vla_set_dimension");
            }

            me->num_sfs_per_tk[me->num_spec_tks - 1] += num_sfs1;
#ifdef DEBUG
	    printf("num specfic thickness : %d\n",me->num_spec_tks);
	    printf("num specfic ids : %d\n",me->spec_surf_id_count);
	    printf("num sfs per tk : %d\n",me->num_sfs_per_tk
					[me->num_spec_tks - 1]);
#endif

            for(i=tmpcount; i<ME.ECcsoffset->spec_surf_id_count; i++)
	    {
               ME.ECcsoffset->spec_surf_ids[i] =
		   surface[i-tmpcount];
	    }
            om$dealloc(ptr = surface);
         } /* end of if(..num_sfs1) */

         if(me->num_elems)
         {
           if(om$dimension_of(varray = me->locpts)
                              <= (me->num_spec_tks) + 1)
           {
             sts = om$vla_set_dimension(varray = me->locpts,
                      size = (me->num_spec_tks) + 1);
             ERROR(sts, 1, "execute(7).vla_set_dimension");
           }

           OM_BLOCK_MOVE (
               ME.ECelements->elems[0].proj_pnt,
               me->locpts[me->num_spec_tks - 1],
               sizeof (IGRpoint));
         }
        else
	{
          /* No surfaces have been input for this specific offset distance. 
             So de-record this specific thickness. */
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
		  }
		break;
		case 's' : case 'S' :
		  if(me->symmetric_flag)
		  {
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
        dp$erase_hilite (msg = &msg_loc);
        dpmode = GRhhd;
	for(i=0;i<me->spec_surf_id_count;i++)
        {
            om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                &me->active_md_env.md_env.matrix_type,
		me->active_md_env.md_env.matrix,
		&dpmode, &env->md_id), targetid = me->spec_surf_ids[i],
		targetos = me->const_obj.osnum);
        }

#ifdef DEBUG
         printf("Multiple thickness %lf\nSurface ids = ",ct);
	 for(i=0;i<ME.ECcsoffset->spec_surf_id_count;i++)
                printf("%d ",ME.ECcsoffset->spec_surf_ids[i]);
	 printf("\n");
#endif

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

/*
	 clear the prompt field.
*/
#ifdef DEBUG
	 for(i=0;i<ME.ECcsoffset->num_spec_tks;i++)
            printf("%d ",me->num_sfs_per_tk[i]);
	 printf("\n");
	 for(i=0;i<ME.ECcsoffset->spec_surf_id_count;i++)
                printf("%d ",ME.ECcsoffset->spec_surf_ids[i]);
	 printf("\n");
#endif
         ex$message(msgnumb = EMS_P_00000);
         dp$erase_hilite (msg = &msg_loc);
         ME.ECelements->elems_hilit = FALSE;

         surface_specific = &esbs;
         const_list.class_attr = (IGRchar *) surface_specific;
         surface_specific->is_surfdis = TRUE;		/* Required */
         surface_specific->is_slowdis = FALSE;		/* Doesn't matter */
         surface_specific->type = NULL;	        	/* Doesn't matter */
       
         stat_OM = EMdpb_get( &msg_loc, EMSdpb_props, &buffer);
       
          if (! (1 & stat_OM))
           {
            goto ret_end;
           }
         surface_specific->is_polydis = buffer & EMDPB_POLYGON_DISPLAY_ON;
       
         stat_OM = EMdpb_get( &msg_loc, EMSdpb_u_rules, &buffer);
       
          if (! (1 & stat_OM))
           {
            goto ret_end;
           }
         surface_specific->u_rules = buffer;
       
         stat_OM = EMdpb_get( &msg_loc, EMSdpb_v_rules, &buffer);
       
          if (! (1 & stat_OM))
           {
            goto ret_end;
           }
         surface_specific->v_rules = buffer;

         const_list.msg = &msg_loc;
         const_list.env_info = env;
         const_list.newflag = FALSE;
         const_list.level = ME.ECelements->active_level;
         const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
         const_list.geometry = NULL;
         const_list.display = &ME.ECelements->active_display;
         const_list.name = NULL;
/*
         setup the common thickness information
*/
         switch (me->in_thick.response)
         {
          case EX_VALUE:
            common_tk1.type = EMSdatainfo_event;
            break;
          case EX_STRING:
            common_tk1.type = EMSdatainfo_name;
            break;
          default:
            goto ret_end;
         }
         common_tk1.valevent  = &me->in_thick;
/*
         Setup the special thickness values
*/
         if (ME.ECcsoffset->num_spec_tks)
         {
            spectks = (struct EMSvalue_info *)
                om$malloc (size = ME.ECcsoffset->num_spec_tks
			  * sizeof (struct EMSvalue_info));
            EMerr_hndlr (!spectks, stat_OM, OM_E_ABORT, ret_end);

            for (i=0; i<ME.ECcsoffset->num_spec_tks; i++)
            {
               switch(me->spec_tk[i].response)
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
               spectks[i].valevent = &me->spec_tk[i];
            }
         }


            loc_surface.env =
		ME.ECelements->accev.located_object[0].module_info;
            loc_surface.grid = me->const_obj;

       /* Invoke the function to return a list of 'uv' points corresponding
          to the projected locate points for dimensioning of 'common'
          and 'special' offset distances  */

       common_surf.objid = me->common_surf;
       common_surf.osnum = me->const_obj.osnum;
       num_sptks = me->num_spec_tks;

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
                                   0,
                                   NULL,
                                   dim_info);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);


         stat_OM = EMplace_offset (&msg_loc,
             ME.ECcsoffset->associative
                               ? NULL : EMSasconst_notassociative,
             const_list.env_info, const_list.level,
	     const_list.display,const_list.class_attr,
	     const_list.name, &loc_surface,
             &common_tk1,

             ME.ECcsoffset->num_spec_tks,
             spectks,
             ME.ECcsoffset->num_sfs_per_tk,
             ME.ECcsoffset->spec_surf_ids,
             dim_info,
             ME.ECcsoffset->inward,
	     TRUE,
	     FALSE,
	     &new_obj.objid);

         ex$message(msgnumb = EMS_I_00000);
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
/*
	    Free the memory pointed by 'spectks' and 'dim_info'.
*/
	    if(spectks) 
		om$dealloc(ptr=spectks);
            if(dim_info) om$dealloc(ptr = dim_info);
/*
            Display the constructed object.
*/
	    if(new_obj.objid!=NULL_OBJID) 
	    {
                dpmode = GRbd;
                om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                    &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                    &env->md_id), targetid = new_obj.objid,
		    targetos = const_list.env_info->md_id.osnum);
	    }
	   me->num_spec_tks = 0;
	   me->spec_surf_id_count = 0;


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
   }  while (TRUE);

ret_end:
   if (EMSerror (stat_OM))
   {
     ME.super_cmd->state = LOCATE_SOLID_STATE1;
     me->num_spec_tks = 0;
     me->spec_surf_id_count = 0;
     stat_OM = OM_S_SUCCESS; /* reset to return case 0 */
   }
   return (stat_OM);
}

/*
This function performs the dynamics for drawing the arrow.
*/

IGRint EFdir_dynamics(grid, event, cmd)
struct GRid *grid;
struct GRevent *event;
struct GRid *cmd;
{
   IGRlong sts, msg_loc;
   sts = OM_S_SUCCESS;
   msg_loc = EMS_S_Success;

   ex$message(in_buff = "Accept with direction/Reject",
	      justification = RIGHT_JUS,
	      field = PROMPT_FIELD);
   sts = om$send(msg = message ECcsoffset.dir_dynamics(grid, event,
       cmd),
       senderid = NULL_OBJID,
       targetid = cmd->objid,
       targetos = cmd->osnum);
   if(!(1 & sts))
      goto ret_end;
ret_end:
   return(sts);
}

/*
This method performs the dynamics for displaying the offset direction. 
*/

method dir_dynamics(struct GRid *grid; struct GRevent *event;
struct GRid *cmd)
{
   IGRlong msg_loc, sts;
   IGRlong msg;
   struct GRid win_id;
   IGRdouble dia_dist, dittol;
   IGRpoint dyn_point, to_pt;
   IGRint ret_sts, point_size;
   IGRvector axis_vec, surf_nor;

   extern void EFdraw_vector_on_screen();
   extern IGRlong LCptlocact();
   extern IGRint Hole_EFdyvector();
   extern IGRlong  ECdisplayPointSetByBuffer0();
   extern void EMgetarrowheads();
   extern IGRint ECget_window_dittol();
   extern IGRlong EFfind_average_arrow_normal(); 

   msg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   point_size = sizeof(IGRpoint);
   win_id.objid = me->win_id.objid;
   win_id.osnum = me->win_id.osnum;

/*
     Get the display unit tolerance i.e. minimum distance between
     two distinguishable points in the window. This function
     is defined in the file 'src_testco/funk/EFpattern.I'.
*/
   ret_sts = ECget_window_dittol(&win_id, &dittol);

   dia_dist = dittol * 15.0; /* Set arrow size to 15 times 'dittol'*/

   OM_BLOCK_MOVE(event->located_object[0].proj_pnt, dyn_point, point_size);


   sts = EFfind_average_arrow_normal(&msg_loc,
                        &event->located_object[0].module_info,
                        event->located_object[0].located_obj,
                        event->located_object[0].geom_parms.leaf_id,
                        dyn_point, surf_nor);
   EMerr_hndlr (EMSerror (msg_loc & sts), msg, EMS_E_Fail, ret_end);


/*
   Determine the unit normal at the 'dyn_point' on the surface.
   out_solid = FALSE;
   sts = om$send (msg = message EMSsubbs.EMget_unit_norm
       (&msg_loc, out_solid, NULL,
       &event->located_object[0].module_info.md_env,
       (IGRdouble *)dyn_point,
       &surf_nor[0]),
       targetid = event->located_object[0].geom_parms.leaf_id.objid,
       targetos = event->located_object[0].geom_parms.leaf_id.osnum);

   EMerr_hndlr (EMSerror (msg_loc & sts), msg, EMS_E_Fail, ret_end);
*/

   OM_BLOCK_MOVE(surf_nor, axis_vec, sizeof(IGRvector));

   OM_BLOCK_MOVE(axis_vec, me->axis_dir, sizeof(IGRvector));

   to_pt[0] = dyn_point[0] + me->axis_dir[0] * dia_dist;
   to_pt[1] = dyn_point[1] + me->axis_dir[1] * dia_dist;
   to_pt[2] = dyn_point[2] + me->axis_dir[2] * dia_dist;

/*
      Display a dynamic arrow.
*/

      sts= ECdisplayPointSetByBuffer0(&msg_loc,
          ME.ECelements->active_display,
          event->located_object[0].module_info, cmd->objid, 1,
          event->located_object[0].proj_pnt, GRbd, IGRPS);
      ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");

      Hole_EFdyvector(axis_vec, dyn_point, to_pt,
          &ME.ECelements->active_display,0,NULL);

      sts= ECdisplayPointSetByBuffer0(&msg_loc,
          ME.ECelements->active_display,
          event->located_object[0].module_info, cmd->objid, 1,
          event->located_object[0].proj_pnt, GRbe, IGRPS);
      ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");


      if (BSdotp (&msg_loc, axis_vec, surf_nor) > 0.0)
         me->inward = TRUE;
      else
         me->inward = FALSE;

      OM_BLOCK_MOVE(axis_vec, me->axis_dir, sizeof(IGRvector));

      me->common_surf =
                  event->located_object[0].geom_parms.leaf_id.objid;

      OM_BLOCK_MOVE (
               event->located_object[0].proj_pnt,
               me->common_surf_pt,
               sizeof (IGRpoint));

ret_end:
   return(sts);
}

method get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
OM_S_CLASSLIST *rtree_classes, *elig_classes,
*nelig_classes; IGRushort *geomprops;
IGRshort *operation; IGRushort *options;
IGRint *minnum_to_locate, *maxnum_to_locate)
{
   IGRlong stat_OM;

   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;

   rtree_classes->w_count = 1;
   rtree_classes->w_flags = OM_CLST_subclass;
   rtree_classes->p_classes[0] = OPP_EMSsubbs_class_id;

   elig_classes->w_count = 1;
   elig_classes->w_flags = OM_CLST_subclass;
   elig_classes->p_classes[0] = OPP_EMSsubbs_class_id;

   nelig_classes->w_count = 0;

   *geomprops = NULL;
   *operation = EC_GEOM_READ;
   *options = EC_LOC_APPENDOBJNUM;

   *minnum_to_locate = 0;
   *maxnum_to_locate = MAXINT;

   return (stat_OM);
}

/*
 The following action handler stores the  window-id of the window
 in which the 'data-point' to identify the surface was given.
*/

EFoffsurf_action_handler(offsurf_locate, new_entry, locate_args, action)

struct  shell_loc_acthndlr_args *offsurf_locate;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;

{
   IGRlong sts = OM_S_SUCCESS;
   GRclassid   classid;

   om$get_classid(p_classid = &classid,
		  objid = new_entry->located_obj.objid,
		  osnum = new_entry->located_obj.osnum);
   if(classid ==  OPP_EMSsfimpbnd_class_id)
	goto ret_end;

  /* Donot identify any composite surface owned by another
     composite surface or solid. */

   if(!(om$is_ancestry_valid(superclassid = OPP_EMSsubbs_class_id,
                               subclassid = classid) == OM_S_SUCCESS))
   {   
     OMuint  count;
     OM_S_CHANSELECT chan_to_owners; 
#ifdef DEBUG
  printf(" Surface is not a single surface\n");
#endif

     EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
     count = 0;
     om$get_channel_count (objid = new_entry->located_obj.objid, 
                           osnum = new_entry->located_obj.osnum,
                           p_chanselect = &chan_to_owners, 
                           count = &count);
     if(count > 0)   goto ret_end;
   }

   sts = om$send(msg = message ECcsoffset.shell_action_handler(
       offsurf_locate, new_entry, locate_args, action),
       senderid = NULL_OBJID,
       targetid = offsurf_locate->my_inst.objid,
       targetos = offsurf_locate->my_inst.osnum);

   if(!(1 & sts))
      goto ret_end;

ret_end:
   return(sts);
}

/*
The following method was written to set the window_id structure of
the instance data.
*/

method shell_action_handler(struct shell_loc_acthndlr_args *offsurf_locate;
struct  GRlc_info *new_entry; struct LC_action_args *locate_args;
enum    GRlocate_action *action)
{
   IGRboolean     call_action_handler;
   IGRlong        sts;
   IGRboolean     aflag = 0;

   extern IGRlong LCptlocact();

   sts = OM_S_SUCCESS;

   call_action_handler = TRUE;

   if(aflag = pwIsActivationOn())
   {
     GRspacenum osn;
     osn = pwGetActiveOs();
     if(new_entry->located_obj.osnum !=osn)
       return(sts); 
   }

   switch (*action)
   {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
      case add_nopost:
      {
         me->win_id.objid = locate_args->stack->window.objid;
         me->win_id.osnum = locate_args->stack->window.osnum;
      }
      break;

      default:
      break;
   }

   if (call_action_handler)
   {
      extern IGRlong LCptlocact();
      sts = LCptlocact(NULL, new_entry, locate_args, action);
   }
   else
      sts = OM_S_SUCCESS;

   return(sts);
}

/*
Action-handler to locate any surface of a composite surface
as a specfic thickness surface.
*/

IGRlong EMloc_open_surf_hndlr1 (curr_info, new_locinfo, priv_args, action)
struct open_surf_hndlr_args *curr_info;
struct GRlc_info *new_locinfo;
struct LC_action_args *priv_args;
enum GRlocate_action *action;
{
   IGRboolean     eligible;
   IGRlong        stat_func;
   struct GRid    *search_id;
   struct locate_acthndlr_args *act_args;
   IGRlong       stat_OM, msg_loc;
   IGRlong       msg;
   struct  GRid  start_surf_GRid;
   IGRboolean    already_located=TRUE;

   IGRlong EMlocate_eligchk_hndlr();

   msg = EMS_S_Success;
   stat_func = TRUE;
   eligible = FALSE;

   search_id = &new_locinfo->located_obj;

   stat_OM = om$send(msg = message EMSsurface.EMgetactiveid (&msg_loc,
       &start_surf_GRid, NULL),
       senderid = NULL_OBJID,
       targetid = search_id->objid,
       targetos = search_id->osnum);
   EMerr_hndlr(!(1 & stat_OM & msg_loc), msg, EMS_E_Fail, ret_end);


   if((start_surf_GRid.objid == curr_info->surface->objid) &&
       (start_surf_GRid.osnum == curr_info->surface->osnum))
      eligible = TRUE;

   if(eligible)
   {

      om$send(msg = message ECcsoffset.element_located(
       search_id->objid,&already_located),
       senderid = NULL_OBJID,
       targetid = curr_info->my_inst.objid,
       targetos = curr_info->my_inst.osnum);
/*
      Call the default action-handler defined in ECelements if the surface
      is not already located.
*/
      if(already_located == FALSE) 
      {
          act_args =  &curr_info->actargs;
          stat_func = EMlocate_eligchk_hndlr (act_args, new_locinfo, priv_args,
              action);
      }
   }

ret_end:
   return(stat_func);
}

method element_located(GRobjid id; IGRboolean *located)
{
    int temp;

    *located = FALSE;
    for(temp=0;temp < me->spec_surf_id_count;temp++) 
    {
	if(id == me->spec_surf_ids[temp]) 
	{
	*located = TRUE;
        goto ret_end;
	}
    }
    for(temp=0; temp < me->num_elems; temp++)
    {
	if(id == me->elems[temp].located_obj.objid)
	{
	*located = TRUE;
        goto ret_end;
	}
    }

ret_end:
    return OM_S_SUCCESS;

}
end implementation ECcsoffset;
