class  ECtrmdrvr    /* Command Object class */
command_string  EM_M_TrimCurEle,0,EMDlCrTIn
super_class     ECconst
spec_path       "$MODEL/src_co/spec" /* path to .S (specification) files */
start_state     id_drvr
product_name    "$MODEL"              /* (V 1.1) */

specification
/*
   Abstract
        This command object gathers the data and calls the methods
        needed to trim multiple curve elements against a single driver
        curve element

   Notes
        The user needs to have more than one ( i.e., at least two)
        curve elements in order to run this command

   History
        sjv     01/29/88        date of creation
        sjv     02/14/88        modified for cleanup at delete & to mark
                                points given by user
        sjv     02/18/88        modified to ignore non-intersecting curves &
                                continue with more input
        dhm     05/10/88        modified to extend to intersection if no intersection
                                was returned from EMcrvcrvint.
        rlw     01/05/89        Fixed command key.
        dhm     03/23/89        Fixed display located channel problem by
                                initializing event1's module_info.
        Carlos  03/26/92        Changed product from $EMS to $MODEL.
        Carlos  05/01/92        Made changes to use the message system
                                at least for the command name.
*/

#include "EMSstruct.h"

instance
{
 GRobjid   drvr_crv_id;  /* driver curve element id */
 IGRint    num_crvs,     /* number of curves */
           accept_response;     /* save for reuse on duplicate input */
 struct GRevent   accept_event; /* save for reuse on duplicate input */
 variable struct EMScrv_info_sd crv_info[];     /* VLA of curve ids. */
}


implementation
 /*
   Abstract
        ***to be filled in***

   Algorithm
        ***to be filled in***

   History
    sjv 01/29/88    date of creation
    sjv 02/14/88    modified for cleanup at delete & to mark
                    points given by user
    sjv 02/18/88    modified to ignore non-intersecting curves &
                    continue with more input
    dhm 05/04/88    modified to extend to intersection if no intersection
                    was found
    dhm 11/16/88    changed to put the active symbology for all curves
                    that were extended.
    dhm 2/16/89     changed to use the original curves symbology.
    dhm 03/23/89    Fixed display located channel problem by
                    initializing event1's module_info.
    dhm 11/17/93    fixed hiliting of resultant curve(s) upon wakeup, clear 
                    stack in states other than locate state not working, and 
                    reject_loc_info giving OM-E-NOSUCHOBJ.
*/

#define MSTRM_DUP_CRV           101     /* duplicate curve located */
#define MSTRM_ZERO_CRV          103     /* only driver curve located */

/*
 * EMtrmdrvr warning return status codes
 */
#define MSTRM_NONINT_CRV 201 /* curve non-intersecting with driver */
#define MSTRM_DISJNT_CRV 203 /* curve unconnected (disjoint) with driver */

#include "EMS.h"
#include "ECcmd_def.h"
#include "EMSlogic.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "emserr.h"
#include "grmsg.h"
#include "EMSmsgdef.h" /* very important! must go before ECcmd.h and ECmsg.h */
#include "ECcmd.h"
#include "ECmsg.h"

from GRvg import        GRgeomprops, GRputsymb;
from GRgraphics import  GRdelete, GRdisplay, GRptproject, GRcopy;
from GRcurve import GRendpts;
from GRowner import GRget_components;

extern OMuword  OPP_GRcompcurve_class_id;

state_table

#define MSTRM_DUP_CRV    101 /* duplicate curve located */
#define MSTRM_ZERO_CRV   103 /* only driver curve located */
#define MSTRM_NONINT_CRV 201 /* curve non-intersecting with driver */
#define MSTRM_DISJNT_CRV 203 /* curve unconnected (disjoint) with driver */

#include        "griodef.h"
#include        "lcdef.h"
#include        "msdef.h"
#include        "grmsg.h"
#include        "ECcmd.h"
#include        "ECmsg.h"

state id_drvr
  execute   init_event1_md_env
  highlight_located      0      /* dehighlight objects on located channel */
  disconnect_located 1  /* disconnect all objects from located channel */
  message_key           EM_M_TrimCurEle
  status_key            EMS_I_ClearStatusField
  prompt_key            EMS_P_IdDrCvEl
  accept_key            EMS_P_AcPtSgNxCvRj
  relocate_key          EMS_P_CvNotFoundRetry
  locate_class          "GRcurve"
  locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR | LC_ERASE_LOC_ELEMENT"
                        /* do not project accept point onto the located element */
  locate_properties     "LC_LC_ONLY | LC_DP_ONLY"
  locate_owner "LC_FLEX_COMP | LC_RIGID_OWNER" 
  locate_mask           GRm_DATA
  accept_mask           GRm_DATA
  filter            locate_noauto /* locate but don't dehighlight object */
  on EX_DATA   do save_loc_info
               do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
               state id_curve

state id_curve
  status_key            EMS_I_ClearStatusField
  prompt_key            EMS_P_IdCvPtSg
  accept_key            EMS_P_AcPtSgNxCvRj
  relocate_key          EMS_P_CvNotFoundRetry
  locate_class          "GRcurve"
  locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR | LC_ERASE_LOC_ELEMENT"
                        /* do not project accept point onto the located element */
  locate_properties     "LC_LC_ONLY | LC_DP_ONLY"
  locate_owner          "LC_FLEX_COMP | LC_RIGID_OWNER"
  locate_mask           "GRm_DATA | GRm_BACK_UP | GRm_RESTART"
  accept_mask           "GRm_DATA | GRm_RESTART"
  filter            locate_noauto /* locate but don't dehighlight object */
  on EX_DATA   do save_loc_info
                 on MSTRM_DUP_CRV state duplicate_curve
               do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
               state id_next_curve
  on EX_BACK_UP   do reject_loc_info
                  state id_drvr
  on EX_RESTART   do restart_cmd
                  state id_drvr

state id_next_curve
  status_key            EMS_I_ClearStatusField
  prompt_key            EMS_P_IdNxCvPtSgMvOn
  accept_key            EMS_P_AcPtSgNxCvRj
  relocate_key          EMS_P_CvNotFoundRetry
  locate_class          "GRcurve"
  locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR | LC_ERASE_LOC_ELEMENT"
  locate_properties     "LC_LC_ONLY | LC_DP_ONLY"
  locate_owner          "LC_FLEX_COMP | LC_RIGID_OWNER"
  locate_mask           "GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART"
  accept_mask           "GRm_DATA | GRm_RESTART"
  filter                locate_noauto   /* locate but do not dehighlight object */
  on EX_RJT_MOVEON   do process
                       on MSFAIL state proc_error
                       on MSTRM_NONINT_CRV state nonint_curve
                       on MSTRM_DISJNT_CRV state disjnt_curve
                     state ask_user
  on EX_DATA   do save_loc_info
                 on MSTRM_DUP_CRV state duplicate_curve
               do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
               state .
  on EX_BACK_UP   do reject_loc_info
                    on MSTRM_ZERO_CRV state id_curve
                  state .
  on EX_RESTART   do restart_cmd
                  state id_drvr

state ask_user
  status_key            EMS_I_ResCvsAfTrim
  prompt_key            EMS_P_AcDtBkCn
  filter                get_event
  on EX_BACK_UP   do cancel_result
                  do restart_cmd
                  state id_drvr /* restart command */
  on EX_DATA   do patch_get_event
               do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
               do confirm_result
               do restart_cmd
               state id_drvr /* restart command */
  on EX_RJT_MOVEON      state .

state proc_error
  status_key         EMS_E_ErrProc
  prompt_key         EMS_P_MvOnToRs
  filter             get_event
  on EX_RJT_MOVEON   do restart_cmd
                     state id_drvr /* restart command */
  on EX_BACK_UP      state .
  on EX_DATA         state .

state duplicate_curve
  status_key            EMS_P_CvPrevId
  prompt_key            EMS_P_MvOnToIgInCn
  filter                get_event
  on EX_RJT_MOVEON   do push_accept_event
                     state previous_state
  on EX_BACK_UP      state .
  on EX_DATA         state .

state nonint_curve
  status_key            EMS_E_ErrNonIsectCvsId
  prompt_key            EMS_P_MvOnToCn
  filter                get_event
  on EX_RJT_MOVEON   do restart_cmd
                     state id_drvr /* restart command */
  on EX_BACK_UP      state .
  on EX_DATA         state .

state disjnt_curve
  status_key            EMS_E_WrnNtAllCvsTrim
  prompt_key            EMS_P_EnDtPrRsMvOnCn
  filter                get_event
  on EX_RJT_MOVEON   do cancel_result
                     do restart_cmd
                     state id_drvr /* restart command */
  on EX_DATA   do patch_get_event
               do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
               do confirm_result
               do restart_cmd
               state id_drvr /* restart command */
  on EX_BACK_UP      state .

  at delete   do my_delete



action init_event1_md_env
{
  OM_BLOCK_MOVE(&me->ModuleInfo, &me->event1.located_object[0].module_info,
                sizeof(struct GRmd_env));

}


action sleep
{
 IGRlong                msg;
 IGRshort               crv_num;
 IGRint                 num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean             draw_background = FALSE; /* for ECdisplayPointSetByBuffer */
 struct GRid            md_id;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();

 /* dehighlight located curves,if any */
 if ( me -> drvr_crv_id ISNT NULL_OBJID) {
        /* unmark locate points */
        for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num ) {
                p_crv_info = &me -> crv_info[ crv_num ];
                /* unmark located point on curve */
                status = ECdisplayPointSetByBuffer(&msg, me^^CEO_LOCATE.ActiveDisplay,
                       me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts, p_crv_info -> loc_pt, draw_background);
                EMomerr_hndlr( status, quit, "ECtrmdrvr.sleep : ECdisplayPointSetByBuffer" );
        };

        md_id = me^^ECconst.construct_list.env_info -> md_id;
        status = dp$erase_hilite( msg = &msg,
                                  objid = md_id.objid,
                                  osnum = md_id.osnum);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.sleep : dp$erase_hilite" );
 };

 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_S_ClearStatusField);

 status = om$send( mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.sleep( 0 ),
                   targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmdrvr.sleep : CEO_LOCATE.sleep" );
}/* sleep */


action wakeup
{
 IGRlong                msg;
 IGRshort               crv_num;
 IGRint                 num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean             draw_background = TRUE, /* for ECdisplayPointSetByBuffer */
                        hilite_driver_curve = TRUE;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();

 if (me -> drvr_crv_id IS NULL_OBJID)
 {
     hilite_driver_curve = FALSE;
     goto parent_wakeup;
 }
 else if (me -> num_crvs IS 0)
     goto parent_wakeup;

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
 {
        p_crv_info = &me -> crv_info[ crv_num ];

        /* mark located point on curve */

        status = ECdisplayPointSetByBuffer(&msg, me^^CEO_LOCATE.ActiveDisplay,
                        me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts, p_crv_info -> loc_pt, draw_background);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.wakeup : ECdisplayPointSetByBuffer" );

        /*
         * Check to see if you have the resultant curve(s) yet.
         * dhm  11/17/93  -  TR 119313306
         */

        if ( p_crv_info -> pcrv_id != NULL_OBJID )
        {
            /* Don't need to hilite the driver curve if  you already have
             * the resultant curve(s).
             */
            hilite_driver_curve = FALSE;

            me^^CEO_LOCATE.DisplayMode = GRhd;
            status = om$send( mode = OM_e_wrt_object,
                             msg = message GRgraphics.GRdisplay( &msg,
                                   &mdenv_info.matrix_type,
                                   mdenv_info.matrix,
                                   &me^^CEO_LOCATE.DisplayMode,
                                   &p_md_env -> md_id),
                             targetid = p_crv_info -> pcrv_id,
                             targetos = p_md_env -> md_id.osnum);
            EMomerr_hndlr( status, quit, "ECtrmdrvr.wakeup : GRgraphics.GRdisplay : 1");
        }
        else
        {
            /* highlight identified curves */

            me^^CEO_LOCATE.DisplayMode = GRhhd;
            status = om$send( mode = OM_e_wrt_object,
                             msg = message GRgraphics.GRdisplay( &msg,
                                   &mdenv_info.matrix_type,
                                   mdenv_info.matrix,
                                   &me^^CEO_LOCATE.DisplayMode,
                                   &p_md_env -> md_id),
                             targetid = p_crv_info -> crv_id,
                             targetos = p_md_env -> md_id.osnum);
            EMomerr_hndlr( status, quit, "ECtrmdrvr.wakeup : GRgraphics.GRdisplay : 2");
        }

 }  /* end for loop */


parent_wakeup :

 if ( hilite_driver_curve )
 {
     p_md_env = me^^ECconst.construct_list.env_info;
     mdenv_info = p_md_env -> md_env;
     me^^CEO_LOCATE.DisplayMode = GRhd;

     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay( &msg, /* *msg */
                            &mdenv_info.matrix_type, /* *type */
                            mdenv_info.matrix, /* matrix */
                            &me^^CEO_LOCATE.DisplayMode, /* *mode */
                            &p_md_env -> md_id),
                      targetid = me -> drvr_crv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmdrvr.wakeup : GRgraphics.GRdisplay : 3");
 }

 status = om$send( mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.wakeup( 0 ),
                   targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmdrvr.wakeup : CEO_LOCATE.wakeup" );

}/* wakeup */


action init
{
 IGRshort       crv_info_vla_initial = 10; /* init size for VLA crv_info[] */

 me -> num_crvs = 0;
 me -> drvr_crv_id = NULL_OBJID;

 status = om$vla_set_dimension( varray = me -> crv_info,
                                 size = crv_info_vla_initial );
 EMomerr_hndlr( status, quit, "ECtrmdrvr.init : om$vla_set_dimension" );

 status = om$send( mode = OM_e_wrt_message,
                   msg = message ECconst.init( type, str_ptr ),
                   targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmdrvr.init : ECconst.init" );

}/* init */


action my_delete
{
 /* do cleanup, delete parts of curve, if any
    unmark locate points on curves */
 IGRshort               crv_num;
 IGRint         num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean     draw_background = FALSE; /* for ECdisplayPointSetByBuffer */

 struct GRmd_env        *p_md_env;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();
 long sts1 = MSSUCC;

 if ( me -> num_crvs) {
        p_md_env = me^^ECconst.construct_list.env_info;
        for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num ) {
                p_crv_info = &me -> crv_info[ crv_num ];

                /* unmark located point on curve */
                status = ECdisplayPointSetByBuffer(&sts1, me^^CEO_LOCATE.ActiveDisplay,
                       me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts, p_crv_info -> loc_pt, draw_background);
                EMomerr_hndlr( status, quit, "ECtrmdrvr.my_delete : ECdisplayPointSetByBuffer" );

                if (p_crv_info -> crv_stat IS CRV_DISJNT)
                        continue; /* no part of curve for non-intersecting curves */
                /* delete part of curve */
                status = om$send( mode = OM_e_wrt_object,
                                  msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                                p_md_env /* *md_env */),
                                  targetid = p_crv_info -> pcrv_id,
                                  targetos = p_md_env -> md_id.osnum);
                EMomerr_hndlr( status, quit, "ECtrmdrvr.my_delete : GRgraphics.GRdelete");
        };
 };

}/* my_delete */


action patch_get_event
{
 /* patch to initialize event from get_event */
 me^^CEO_LOCATE.event1.num_id = 0;
}


action push_accept_event
{
 /* push accept event on queue with the accept response */

 *me^^CEO.response = me -> accept_response;
 status = om$send( mode = OM_e_wrt_message,
                   msg = message ECcmd.EMpush_button_on_stack(&me -> accept_event),
                   targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmdrvr.push_accept_event : ECcmd.EMpush_button_on_stack" );

}/* push_accept_event */


action restart_cmd
{
 /* initialisations to restart command */
 IGRshort               crv_num;
 IGRint         num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean     draw_background = FALSE; /* for ECdisplayPointSetByBuffer */

 struct GRmd_env        *p_md_env;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();
 long sts1 = MSSUCC;

 if ( me -> drvr_crv_id ISNT NULL_OBJID) {
        if ( me -> num_crvs)
                /* unmark points */
                for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num ) {
                        p_crv_info = &me -> crv_info[ crv_num ];
                        /* unmark located point on curve */
                        status = ECdisplayPointSetByBuffer(&sts1, me^^CEO_LOCATE.ActiveDisplay,
                               me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts, p_crv_info -> loc_pt, draw_background);
                        EMomerr_hndlr( status, quit, "ECtrmdrvr.restart_cmd : ECdisplayPointSetByBuffer" );
                };

        /* dehighlight located curves */
        p_md_env = me^^ECconst.construct_list.env_info;
        status = dp$erase_hilite( msg = &sts1,
                                  objid = p_md_env -> md_id.objid,
                                  osnum = p_md_env -> md_id.osnum);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.restart_cmd : dp$erase_hilite" );
 };
 me -> num_crvs = 0;
 me -> drvr_crv_id = NULL_OBJID;
}/* restart_cmd */


action save_loc_info
{
 /* save located information, located curve id & the locate point
    projected onto the located curve */

 IGRshort       crv_info_vla_incr = 5; /* increment value for VLA crv_info[] */
 IGRint         num_pnts = 1, /* for ECdisplayPointSetByBuffer */
                crv_num,
                new_crv_num, /* index to the VLA crv_info[] */
                crv_info_vla_size; /* present size of the VLA crv_info[] */
 IGRboolean     draw_background = TRUE, /* for ECdisplayPointSetByBuffer */
                is_crv_dup;
 struct EMScrv_info_sd  *p_crv_info;
 struct GRlc_info       *p_loc_crv_lc_info; /* located curve info */
 struct GRmdenv_info    *p_mdenv_info; /* pointer to mdenv_info of located curve */
 struct GRid            located_obj; /* located curve GRid */
 struct GRprops geomprops; /* geometric properties of the curve */

 int    ECdisplayPointSetByBuffer();
 long sts1 = MSSUCC;

 ex$message(msgnumb = EMS_S_ClearStatusField);
 is_crv_dup = FALSE;

 p_loc_crv_lc_info = &me^^CEO_LOCATE.event1.located_object[ 0 ];
 located_obj = p_loc_crv_lc_info -> located_obj;
 p_mdenv_info = &p_loc_crv_lc_info -> module_info.md_env;

 if (me -> drvr_crv_id IS NULL_OBJID) {
        me -> drvr_crv_id = located_obj.objid;
        /* first curve, prepare construction list for curves */
        /* store point for use by init_construct */
        status = om$send( mode = OM_e_wrt_message,
                          msg = message ECconst.EMstorepoint( &sts1, /* *msg */
                                        reg_input, /* type_store */
                                        NULL, /* check */
                                        NULL, /* obj_id */
                                        NULL), /* *prj_parms */
                          targetid = my_id);
        EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : ECconst.EMstorepoint" );

        /* prepare construction list for curves */
        status = om$send( mode = OM_e_wrt_message,
                          msg = message ECconst.init_construct( &sts1 ),
                          targetid = my_id );
        EMomerr_hndlr( status, quit, "ECtrmdrvr.save_loc_info : ECconst.init_construct" );
        /* display driver element in highlight */
        me^^CEO_LOCATE.DisplayMode = GRhd;
        goto disp_curve;
 } else
        /* check if same as driver element */
        if (located_obj.objid IS me -> drvr_crv_id) {
                is_crv_dup = TRUE;
                me^^CEO_LOCATE.DisplayMode = GRhd;
                goto disp_curve;
        };

 new_crv_num = me -> num_crvs; /* set index for VLA crv_info */

 /* set display mode for located curve = half-highlight */
 me^^CEO_LOCATE.DisplayMode = GRhhd;

 /* check if curve already identified */
 if ( me -> num_crvs ) {
        for ( crv_num = 0; (crv_num < me -> num_crvs); ++crv_num )
                if (located_obj.objid IS me -> crv_info[ crv_num ].crv_id) {
                        /* duplicate id found */
                        is_crv_dup = TRUE;
                        goto disp_curve;
                };
 };

 /* check VLA size & increase size, if necessary */
 crv_info_vla_size = om$dimension_of (varray = me -> crv_info);
 ++me -> num_crvs;
 
 if ( me -> num_crvs > crv_info_vla_size) {
   /* increment the array size */
   status = om$vla_set_dimension( varray = me -> crv_info,
                                  size = (crv_info_vla_size + crv_info_vla_incr) );
   EMomerr_hndlr( status, quit, "ECtrmdrvr.save_loc_info : om$vla_set_dimension" );
 };

 p_crv_info = &me -> crv_info[ new_crv_num ];
 /* save located curve id */
 p_crv_info -> crv_id = located_obj.objid;
 p_crv_info -> pcrv_id = NULL_OBJID;

 /* project located point (in event2) onto located curve (in event1) */

 status = om$send( mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRptproject( &sts1, /* *msg */
                                &p_mdenv_info -> matrix_type, /* *matrix_type */
                                p_mdenv_info -> matrix, /* matrix */
                                &me^^CEO_LOCATE.event2.event.button.x, /* point */
                                p_crv_info -> loc_pt, /* proj_pt */
                                &me -> crv_info[ new_crv_num ].loc_pt_prj_parms
                                /* *proj_parms */),
                   targetid = located_obj.objid,
                   targetos = located_obj.osnum);
 EMomerr_hndlr( status, quit, "ECtrmdrvr.save_loc_info : GRgraphics.GRptproject" );

 /* mark located point on curve */
 status = ECdisplayPointSetByBuffer(&sts1, me^^CEO_LOCATE.ActiveDisplay,
        me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts, p_crv_info -> loc_pt, draw_background);
 EMomerr_hndlr( status, quit, "ECtrmdrvr.save_loc_info : ECdisplayPointSetByBuffer" );

 /* get geometric properties of the curve, to find open/closed curve */
 status = om$send( mode = OM_e_wrt_object,
                   msg = message GRvg.GRgeomprops( &sts1, /* *msg */
                         &p_mdenv_info -> matrix_type, /* *mat_type */
                         p_mdenv_info -> matrix, /* matrix */
                         &geomprops), /* *properties */
                   targetid = located_obj.objid,
                   targetos = located_obj.osnum);
 EMomerr_hndlr( status, quit, "ECtrmdrvr.save_loc_info : GRvg.GRgeomprops");
 me -> crv_info[ new_crv_num ].phy_closed = geomprops.phy_closed;

disp_curve :

 status = om$send( mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                         &p_mdenv_info -> matrix_type, /* *type */
                         p_mdenv_info -> matrix, /* matrix */
                         &me^^CEO_LOCATE.DisplayMode, /* *mode */
                         &p_loc_crv_lc_info -> module_info.md_id /* *display_info */
                                ),
                   targetid = located_obj.objid,
                   targetos = located_obj.osnum);
 EMomerr_hndlr( status, quit, "ECtrmdrvr.save_loc_info : GRgraphics.GRdisplay");

 if (is_crv_dup) {
        /* save event1 (accept point) in accept_event */
        me -> accept_event = me^^CEO_LOCATE.event1;
        /* save response type */
        me -> accept_response = *me^^CEO.response;
        sts1 = MSTRM_DUP_CRV;
 };

}/* save_loc_info */


action reject_loc_info
{
 /* reject the last located information */

 IGRint         num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean     draw_background = FALSE; /* for ECdisplayPointSetByBuffer */
 GRobjid        loc_crv_id = NULL_OBJID;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 long sts1 = MSSUCC;

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 if (me -> num_crvs IS 0)
 {
     /* reject driver element */

     loc_crv_id = me -> drvr_crv_id;
     me -> drvr_crv_id = NULL_OBJID;
 }
 else
 {
     --me -> num_crvs;

     /* unmark located point on curve */

     status = ECdisplayPointSetByBuffer(&sts1, me^^CEO_LOCATE.ActiveDisplay,
                 me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts,
                 me -> crv_info[ me -> num_crvs ].loc_pt, draw_background);
     EMomerr_hndlr( status, quit, "ECtrmdrvr.reject_loc_info : LOCAL_DISPLAY" );

     loc_crv_id = me -> crv_info[ me -> num_crvs ].crv_id;
 }

 /* dehighlight the last located object */

 if ( loc_crv_id )
 {
     me^^CEO_LOCATE.DisplayMode = GRhe;
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                                &mdenv_info.matrix_type, /* *type */
                                mdenv_info.matrix, /* matrix */
                                &me^^CEO_LOCATE.DisplayMode, /* *mode */
                                &p_md_env -> md_id /* *display_info */
                                ),
                      targetid = loc_crv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmdrvr.reject_loc_info : GRgraphics.GRdisplay");
 }

 if (me -> num_crvs IS 0)
        *sts = MSTRM_ZERO_CRV;    /* only driver curve located */

}/* reject_loc_info */


action process
{
 /* end of user interaction, now process the information */

 IGRlong        EMtrmdrvr();
 IGRint     ret_count;
 IGRshort               crv_num;
 IGRboolean             is_crv_nonint, is_crv_disjnt;
 struct EMScrv_info_sd  *p_crv_info;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 IGRlong     EMextend_to_int(), msg;
 IGRpoint    end_pnt1, end_pnt2, spnt, epnt, ext_pnt;
 struct GRparms     p1, p2;
 struct GRid        obj1, obj2;
 GRobjid            crv_id;
 IGRint             index;
 extern IGRdouble          BSdistptpts();
 long sts1 = MSSUCC;


 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_I_00003);

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 /*
  * This needs to be set in the function when the symbology of the
  * original curve is gotten just before doing the EMpartofcv.
  * dhm  2/16/89.
  */

 me->construct_list.display = NULL;
 me->construct_list.level = NULL;

 status = EMtrmdrvr(
                        &sts1,                    /* *msg */
                        me -> drvr_crv_id,      /* drvr_crv_id */
                        me -> crv_info,         /* **crv_info */
                        &me^^ECconst.construct_list,    /* *p_const_list */
                        me -> num_crvs          /* num_crvs */
                        );
 EMomerr_hndlr( status, quit, "ECtrmdrvr.process : EMtrmdrvr" );

 is_crv_nonint = (sts1 IS MSTRM_NONINT_CRV);
 is_crv_disjnt = FALSE;

 /* dehighlight all curves */
 status = dp$erase_hilite( msg = &sts1,
                           objid = p_md_env -> md_id.objid,
                           osnum = p_md_env -> md_id.osnum);
 EMomerr_hndlr( status, quit, "ECtrmdrvr.process : dp$erase_hilite" );

 /*
  * highlight trimmed curve segments.
  */

 me^^CEO_LOCATE.DisplayMode = GRhd;

 obj2.objid = me->drvr_crv_id;
 obj2.osnum = p_md_env->md_id.osnum;
 obj1.osnum = p_md_env->md_id.osnum;

 for (crv_num = 0;  crv_num < me->num_crvs; ++crv_num)
 {
    p_crv_info = &me->crv_info[crv_num];

    /*
     * If no intersection was found, then try to extend to intersection.
     * dhm  5/10/88.
     */

    if (p_crv_info->crv_stat IS CRV_DISJNT)
    {
          if (p_crv_info->phy_closed)
          {
            is_crv_disjnt = TRUE;
            continue;
          }

          status = om$send(msg = message GRgraphics.GRcopy(&sts1,
                                 p_md_env, p_md_env, &crv_id),
                           targetid = p_crv_info->crv_id,
                           targetos = obj1.osnum);
          EMomerr_hndlr(status, quit, "ECtrmdrvr : GRcopy\n");
          EMerr_hndlr(EMis_error(sts1), sts1, MSFAIL, quit);

          status = om$send(msg = message GRcurve.GRendpts(&sts1,
                                &mdenv_info.matrix_type, mdenv_info.matrix,
                                spnt, epnt),
                                   targetid = crv_id,
                           targetos = obj1.osnum);
          EMomerr_hndlr(status, quit, "ECtrmdrvr : GRendpts\n");
          EMerr_hndlr(EMis_error(sts1), sts1, MSFAIL, quit);

          if ( BSdistptpts(&sts1, spnt, p_crv_info->loc_pt) <
               BSdistptpts(&sts1, epnt, p_crv_info->loc_pt) )
          {
            index = 0;
            p1.u = 0.0;
            end_pnt1[0] = spnt[0];
            end_pnt1[1] = spnt[1];
            end_pnt1[2] = spnt[2];
          }
          else
          {
            index = p_crv_info->chan_count - 1;
            p1.u = 1.0;
            end_pnt1[0] = epnt[0];
            end_pnt1[1] = epnt[1];
            end_pnt1[2] = epnt[2];
          }

          if (p_crv_info->chan_count > 0) /* if composite curve */
          {
            status = om$send(msg = message GRowner.GRget_components(&sts1,
                                   p_md_env, &obj1, 1, &ret_count, index,
                                   index),
                             targetid = crv_id,
                             targetos = obj1.osnum);
            EMomerr_hndlr(status, quit, "ECtrmdrvr : GRget_components\n");
            EMerr_hndlr(EMis_error(sts1), sts1, MSFAIL, quit);
          }
          else
            obj1.objid = crv_id;

          status = om$send(msg = message GRgraphics.GRptproject(&sts1,
                                &mdenv_info.matrix_type, mdenv_info.matrix,
                                end_pnt1, end_pnt2, &p2),
                           targetid = obj2.objid,
                           targetos = obj2.osnum);
          EMomerr_hndlr(status, quit, "ECtrmdrvr : GRptproject\n");
          EMerr_hndlr(EMis_error(sts1), sts1, MSFAIL, quit);

	  p1.polygon_inx = 0;

          status = EMextend_to_int(&msg, p_md_env, &obj1, &obj2, &p1, &p2,
                                   0.01, FALSE, FALSE, end_pnt1, end_pnt2,
                                   ext_pnt);
          EMomerr_hndlr(status, quit, "ECtrmdrvr : EMextend_to_int\n");
          if ( (msg == EMS_E_NoIntersection) || !(msg&1) )
          {
            is_crv_disjnt = TRUE;
            p_crv_info->crv_stat = CRV_DISJNT;

            status = om$send(msg = message GRgraphics.GRdelete(&sts1,
                                   p_md_env),
                        targetid = crv_id,
                        targetos = obj1.osnum);
            EMomerr_hndlr(status, quit, "ECtrmdrvr : GRdelete\n");
            EMerr_hndlr(EMis_error(sts1), sts1, MSFAIL, quit);

            continue;
          }
          else
          {
            is_crv_nonint = FALSE;
            p_crv_info->crv_stat = CRV_OK;
            p_crv_info->pcrv_id = crv_id;
          }

    }  /* end if p_crv_info->crv_stat == CRV_DISJNT */


        status = om$send( mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                                &mdenv_info.matrix_type, /* *type */
                                mdenv_info.matrix, /* matrix */
                                &me^^CEO_LOCATE.DisplayMode, /* *mode */
                                &p_md_env -> md_id /* *display_info */
                                ),
                          targetid = p_crv_info -> pcrv_id,
                          targetos = p_md_env -> md_id.osnum);
        EMomerr_hndlr(status, quit, "ECtrmdrvr : GRgraphics.GRdisplay");

 }  /* end for crv_num < me->num_crvs */

 if (is_crv_nonint)
        *sts = MSTRM_NONINT_CRV;
 else if (is_crv_disjnt)
        *sts = MSTRM_DISJNT_CRV;
 else
        *sts = sts1;

} /* process */
 

action confirm_result
{
 /* result confirmed by user, erase & delete original curves;
    draw trimmed curve elements */
 IGRshort               crv_num;
 struct EMScrv_info_sd  *p_crv_info;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 enum GRdpmode          pcrv_dpmode = GRbd; /* display mode for trimmed curve elements */
 long sts1 = MSSUCC;

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 me^^CEO_LOCATE.DisplayMode = GRbe;
 for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num ) {
        p_crv_info = &me -> crv_info[ crv_num ];
        if (p_crv_info -> crv_stat IS CRV_DISJNT)
                continue; /* skip non-intersecting curves */

        /* erase located curve elements */
        status = om$send( mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                        &mdenv_info.matrix_type, /* *type */
                        mdenv_info.matrix, /* matrix */
                        &me^^CEO_LOCATE.DisplayMode, /* *mode */
                        &p_md_env -> md_id /* *display_info */
                                ),
                   targetid = p_crv_info -> crv_id,
                   targetos = p_md_env -> md_id.osnum);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.confirm_result : GRgraphics.GRdisplay : 1");

        /* delete elements */
        status = om$send( mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                        p_md_env /* *md_env */),
                          targetid = p_crv_info -> crv_id,
                          targetos = p_md_env -> md_id.osnum);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.confirm_result : GRgraphics.GRdelete");

        /* draw trimmed elements */
        status = om$send( mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                        &mdenv_info.matrix_type, /* *type */
                        mdenv_info.matrix, /* matrix */
                        &pcrv_dpmode, /* *mode */
                        &p_md_env -> md_id /* *display_info */
                                ),
                   targetid = p_crv_info -> pcrv_id,
                   targetos = p_md_env -> md_id.osnum);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.confirm_result : GRgraphics.GRdisplay : 2");
 };

}/* confirm_result */


action cancel_result
{
 /* delete the trimmed curve elements */
 IGRshort               crv_num;
 struct EMScrv_info_sd  *p_crv_info;
 struct GRmd_env        *p_md_env;
 long sts1 = MSSUCC;

 p_md_env = me^^ECconst.construct_list.env_info;

 for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num ) {
        p_crv_info = &me -> crv_info[ crv_num ];
        if (p_crv_info -> crv_stat IS CRV_DISJNT)
                continue; /* skip non-intersecting curves */
        /* delete trimmed curve elements */
        status = om$send( mode = OM_e_wrt_object,
                           msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                        p_md_env /* *md_env */),
                           targetid =p_crv_info -> pcrv_id,
                           targetos = p_md_env -> md_id.osnum);
        EMomerr_hndlr( status, quit, "ECtrmdrvr.cancel_result : GRgraphics.GRdelete" );
 };

}/* cancel_result */
