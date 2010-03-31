/* 
Name
  ECtrmcrvelei.I

Description
  ***to be filled in***

History
  sjv     11/18/87        date of creation
  sjv     02/13/88        modified for cleanup at delete & to mark
                          points given by user
  sjv     02/17/88        modified to continue with more input in case
                          of disjoint result
  dhm     03/23/89        Fixed display located channel problem by
                          initializing event1's module_info.
  dhm     08/27/93        added code to make trim curves work with
                          profiles.
  dhm     11/17/93        the resultant curve was not displaying once the
                          command was put to sleep and then woke up.
  dhm     12/07/93        fixed to turn the associativity toggle blue on
                          wakeup and  turn off on sleep.
  scw     08/14/94        clarified sleep method
*/

class implementation ECtrmcrvele;

#define MSTRM_DUP_CRV           101    /* duplicate curve located */
#define MSTRM_1_CRV             103    /* 1 curve located */

/* EMtrmcrvele warning return status codes */

#define MSTRM_NONINT_CRV        201    /* non-intersecting curves */
#define MSTRM_DISJNT_CRV        203    /* unconnected (disjoint) curves */
#define MSTRM_AMBIG_CRV         205    /* curve segment ambiguous */
#define MSTRM_INVMULT_CRV       207    /* invalid mult input, curve disjoint */

/* includes */

#include "comisc.h"
#include "EMS.h"
#include "ECcmd_def.h"
#include "EMSlogic.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "emserr.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "EMSutlmacros.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "SKdef.h"
#include "SKmacros.h"

extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_SKgeometry_class_id;

/* message imports */

from GRvg import        GRgeomprops;

from GRgraphics import  GRcopy,
                        GRdelete,
                        GRdisplay,
                        GRptproject;

from SKgeometry import SKgetmgr;
from SKmgr import GRremove_components;


/*
Name

Abstract

Keywords

History
  08/31/93 : dhm : added header

*/
method init_event1_md_env ( long * sts )
{
  *sts = MSSUCC;

  OM_BLOCK_MOVE(&me->ModuleInfo, &me->event1.located_object[0].module_info,
                sizeof(struct GRmd_env));

  return OM_S_SUCCESS;
}


/*
Name

Abstract

Keywords

History
  08/31/93 : dhm : added header

*/
method super_cmd.sleep ( int pos )
{
  int		  status = OM_S_SUCCESS;

 IGRlong                msg;
 IGRshort               crv_num;
 IGRint                 num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean             draw_background = FALSE; /* for ECdisplayPointSetByBuffer */
 IGRboolean             associative_flag;
 struct GRid            md_id;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();

 /* TR 119313973 - dhm  12/7/93
  * If associative, then turn the associative toggle off.
  */

  gr$get_associative_flag( buffer = &associative_flag );
  if ( associative_flag )
      GRdisplay_associative_button(FALSE);

 /* dehighlight located curves */

 if ( me -> num_crvs)
 {
     /* unmark locate points */

     for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
     {
         p_crv_info = &me -> crv_info[ crv_num ];

         /* unmark located point on curve */

         status = ECdisplayPointSetByBuffer(&msg, me^^CEO_LOCATE.ActiveDisplay,
                                            me^^CEO_LOCATE.ModuleInfo, my_id,
                                            num_pnts, p_crv_info->loc_pt,
                                            draw_background);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.sleep : ECdisplayPointSetByBuffer" );

     }

     md_id = me^^ECconst.construct_list.env_info -> md_id;
     status = dp$erase_hilite(msg = &msg,
                              objid = md_id.objid,
                              osnum = md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.sleep : dp$erase_hilite" );
 }

 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_S_ClearStatusField);

 status = om$send(mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.sleep( 0 ),
                  targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmcrvele.sleep : CEO_LOCATE.sleep" );

quit:
  return OM_S_SUCCESS;
}

/*
Name

Abstract

Keywords

History
  08/31/93 : dhm : added header

*/
method wakeup ( int pos )
{
  int		  status = OM_S_SUCCESS;

 IGRlong                msg;
 IGRshort               crv_num;
 IGRint                 num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean             draw_background = TRUE; /* for ECdisplayPointSetByBuffer */
 IGRboolean             associative_flag;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();
 extern IGRboolean EMshould_be_associative();

 /*
  * TR 119313973 - dhm 12/7/93.
  * For EMS, it should always be associative!  Other applications like
  * MDS can override this functionality at runtime by overriding the
  * EMshould_be_associative() function.
  */

 if ( EMshould_be_associative() )
 {
     gr$get_associative_flag( buffer = &associative_flag );
     if ( associative_flag )
         GRdisplay_associative_button(TRUE);
 }

 if ( me->compcrv_id ISNT NULL_OBJID)
 {
     /* 
      * Highlight the resultant composite curve if there is one. dhm  11/17/93
      */

     p_md_env = me^^ECconst.construct_list.env_info;
     mdenv_info = p_md_env -> md_env;

     me->DisplayMode = GRhd;

     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay(&msg,
                                 &mdenv_info.matrix_type,
                                 mdenv_info.matrix,
                                 &me->DisplayMode,
                                 &p_md_env->md_id),
                      targetid = me->compcrv_id,
                      targetos = p_md_env->md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.wakeup : GRgraphics.GRdisplay : 1");

 }
 else if ( me->num_crvs )
 {
     p_md_env = me^^ECconst.construct_list.env_info;
     mdenv_info = p_md_env -> md_env;

     for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
     {
         p_crv_info = &me -> crv_info[ crv_num ];

         /* mark located point on curve */

         status = ECdisplayPointSetByBuffer(&msg, me^^CEO_LOCATE.ActiveDisplay,
                                            me^^CEO_LOCATE.ModuleInfo, my_id,
                                            num_pnts, p_crv_info->loc_pt,
                                            draw_background);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.wakeup : ECdisplayPointSetByBuffer" );

         if (p_crv_info -> crv_stat IS CRV_DISCARD) /* skip discarded curves */
             continue;

         /*
          * Now determine exactly what needs to be hilited upon wakeup.
          * dhm  11/17/93.
          */

         if (p_crv_info -> crv_stat IS CRV_DISJNT)
         {
             /* highlight non-intersecting / disjoint curve */

             me->DisplayMode = GRhd;
             status = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay( &msg,
                                     &mdenv_info.matrix_type,
                                     mdenv_info.matrix,
                                     &me^^CEO_LOCATE.DisplayMode,
                                     &p_md_env -> md_id),
                              targetid = p_crv_info -> crv_id,
                              targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.wakeup : GRgraphics.GRdisplay : 2");
         }
         else if ( me->is_crv_ambig OR me->is_crv_disjnt )
         {
             /* highlight partial curves */

             me->DisplayMode = GRhd;
             status = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay(&msg,
                                    &mdenv_info.matrix_type,
                                    mdenv_info.matrix,
                                    &me->DisplayMode,
                                    &p_md_env->md_id),
                              targetid = p_crv_info->pcrv_id,
                              targetos = p_md_env->md_id.osnum);
             EMomerr_hndlr( status, quit, "ECtrmcrvele.wakeup : GRgraphics.GRdisplay : 3");
         }
         else
         {
             if (p_crv_info -> dup_crvix ISNT crv_num)
                 continue; /* curve copy, already highlighted */

             /* half-highlight identified curves */
         
             me^^CEO_LOCATE.DisplayMode = GRhhd;
             status = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay( &msg,
                                       &mdenv_info.matrix_type,
                                       mdenv_info.matrix,
                                       &me^^CEO_LOCATE.DisplayMode,
                                       &p_md_env -> md_id),
                              targetid = p_crv_info -> crv_id,
                              targetos = p_md_env -> md_id.osnum);
             EMomerr_hndlr( status, quit, "ECtrmcrvele.wakeup : GRgraphics.GRdisplay : 4");
         }

     }  /* end for loop */

 } /* end else if */
 
 status = om$send(mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.wakeup( 0 ),
                  targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmcrvele.wakeup : CEO_LOCATE.wakeup" );

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract

Keywords

History
  08/31/93 : dhm : added header

*/
method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

 IGRshort       crv_info_vla_initial = 10; /* initial size for VLA crv_info */

 me -> num_crvs = 0;
 me -> num_dup_crvs = 0;
 me -> is_crv_ambig = FALSE;
 me -> is_crv_disjnt = FALSE;
 me -> compcrv_id = NULL_OBJID;

 status = om$vla_set_dimension( varray = me -> crv_info,
                                 size = crv_info_vla_initial );
 EMomerr_hndlr( status, quit, "ECtrmcrvele.init : om$vla_set_dimension" );

 status = om$send( mode = OM_e_wrt_message,
                   msg = message ECconst.init( type, str_ptr ),
                   targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmcrvele.init : ECconst.init" );

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  do cleanup, delete curve copies, if any;
  delete parts of curve, if any; and composite curve, if necessary.

Keywords

History
  08/31/93 : dhm : added header

*/
method my_delete ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRshort       crv_num;
 IGRint         num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean     draw_background = FALSE; /* for ECdisplayPointSetByBuffer */

 struct GRmd_env        *p_md_env;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();
 long   sts1 = MSSUCC;

 *sts = MSSUCC;

 if ( me->num_crvs )
 {
     /* unmark the points */

     for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
     {
         p_crv_info = &me -> crv_info[ crv_num ];

         /* unmark located point on curve */

         status = ECdisplayPointSetByBuffer(&sts1,
                                            me^^CEO_LOCATE.ActiveDisplay,
                                            me^^CEO_LOCATE.ModuleInfo, my_id,
                                            num_pnts, p_crv_info->loc_pt,
                                            draw_background);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.my_delete : ECdisplayPointSetByBuffer" );

     }

     p_md_env = me^^ECconst.construct_list.env_info;

     if (me->num_dup_crvs)
     {         
         /* delete curve copies */

         for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
         {
             p_crv_info = &me -> crv_info[ crv_num ];
                        
             if ( crv_num IS p_crv_info -> dup_crvix )
                 continue; /* skip if not copy */

             /* delete curve, if copy */
                    
             status = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdelete(
                                         &sts1, /* *msg */
                                         p_md_env /* *md_env */),
                              targetid = p_crv_info -> crv_id,
                              targetos = p_md_env -> md_id.osnum);
             EMomerr_hndlr( status, quit, "ECtrmcrvele.my_delete : GRgraphics.GRdelete : 1");

         }  /* end for loop */
     }  /* end if */

     if (me -> is_crv_ambig OR me -> is_crv_disjnt)
     {
         /* delete parts of curve */

         for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
         {
             p_crv_info = &me -> crv_info[ crv_num ];

             if (p_crv_info -> pcrv_id IS NULL_OBJID)
                 continue; /* skip if no part of curve */

             /* delete part of curve */
             status = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdelete(
                                         &sts1, /* *msg */
                                         p_md_env /* *md_env */),
                              targetid = p_crv_info -> pcrv_id,
                              targetos = p_md_env -> md_id.osnum);
             EMomerr_hndlr( status, quit, "ECtrmcrvele.my_delete : GRgraphics.GRdelete : 2");
         }  /* end for loop */
     }  /* end if */

     if (me -> compcrv_id ISNT NULL_OBJID)
     {
         /* delete composite curve */
         status = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                     p_md_env /* *md_env */),
                          targetid = me -> compcrv_id,
                          targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.my_delete : GRgraphics.GRdelete : 3");
         me->compcrv_id = NULL_OBJID;
     }

 }  /* if me -> num_crvs */

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  patch to initialize field in event from get_event
  for reuse by locate filter.

Keywords

History
  08/31/93 : dhm : added header

*/
method patch_get_event ( long * sts )
{
 *sts = MSSUCC;

 me^^CEO_LOCATE.event1.num_id = 0;

 return OM_S_SUCCESS;
}


/*
Name

Abstract
  push accept event on queue with the accept response
Keywords

History
  08/31/93 : dhm : added header

*/
method push_accept_event ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 *sts = MSSUCC;

 *me^^CEO.response = me -> accept_response;
 status = om$send(mode = OM_e_wrt_message,
                  msg = message ECcmd.EMpush_button_on_stack(
                             &me->accept_event),
                  targetid = my_id );
 EMomerr_hndlr( status, quit, "ECtrmcrvele.push_accept_event : ECcmd.EMpush_button_on_stack" );

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  initialisations to restart command;
  erases mark at located points and deletes curve copies, if any.

Keywords

History
  08/31/93 : dhm : added header

*/
method restart_cmd ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRshort               crv_num;
 IGRint         num_pnts = 1; /* for ECdisplayPointSetByBuffer */
 IGRboolean     draw_background = FALSE; /* for ECdisplayPointSetByBuffer */

 struct GRmd_env        *p_md_env;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 if ( me -> num_crvs)
 {
     p_md_env = me^^ECconst.construct_list.env_info;

     for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
     {
         p_crv_info = &me -> crv_info[ crv_num ];

         /* unmark located point on curve */
         status = ECdisplayPointSetByBuffer(&sts1, 
                                            me^^CEO_LOCATE.ActiveDisplay,
                                            me^^CEO_LOCATE.ModuleInfo, my_id,
                                            num_pnts, p_crv_info -> loc_pt,
                                            draw_background);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.restart_cmd : ECdisplayPointSetByBuffer" );

         /* delete curve copies */

         if ( crv_num IS p_crv_info -> dup_crvix )
             continue; /* skip if not copy */

         /* delete curve, if copy */

         status = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete( &sts1,
                                                            p_md_env),
                          targetid = p_crv_info -> crv_id,
                          targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.restart_cmd : GRgraphics.GRdelete");
     }

     status = dp$erase_hilite(msg = &sts1,
                              objid = p_md_env -> md_id.objid,
                              osnum = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.restart_cmd : dp$erase_hilite" );
 }  /* end if */

 me -> num_crvs = 0;
 me -> num_dup_crvs = 0;
 me -> is_crv_ambig = FALSE;
 me -> is_crv_disjnt = FALSE;
 me -> compcrv_id = NULL_OBJID;

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  save located information - located curve id & the locate point
  projected onto the located curve;
  initialize construct_list;
  check for duplicate curve & if so, make copy of curve & save info;
  mark located point on curve.

Keywords

History
  08/31/93 : dhm : added header

*/
method save_loc_info ( long * sts )
{
  int		  status = OM_S_SUCCESS;


 IGRshort       crv_info_vla_incr = 5; /* increment value for VLA crv_info[] */
 IGRint         num_pnts = 1, /* for ECdisplayPointSetByBuffer */
                crv_num,
                new_crv_num, /* index to the VLA crv_info[] */
                crv_info_vla_size, /* present size of the VLA crv_info[] */
                dup_crv_num = 0; /* duplicate curve number */
 IGRboolean     draw_background = TRUE, /* for ECdisplayPointSetByBuffer */
                is_crv_dup;
 GRobjid                copy_crv_id; /* id of copy curve */
 struct GRlc_info       *p_loc_crv_lc_info; /* located curve info */
 struct GRmdenv_info    *p_mdenv_info; /* pointer to mdenv_info of located curve */
 struct GRid            located_obj; /* located curve GRid */
 struct GRid            owner_id;
 struct GRprops geomprops; /* geometric properties of the curve */
 struct EMScrv_info_sd  *p_crv_info;
 OM_S_CHANSELECT   to_owner;
 OMuword           owner_classid;

 int    ECdisplayPointSetByBuffer();
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 ex$message(msgnumb = EMS_S_ClearStatusField);

 if (me -> num_crvs IS 0)
 {
     /* first curve, prepare construction list for curves */
     /* store point for use by init_construct */
     status = om$send(mode = OM_e_wrt_message,
                      msg = message ECconst.EMstorepoint( &sts1, /* *msg */
                                 reg_input, /* type_store */
                                 NULL, /* check */
                                 NULL, /* obj_id */
                                 NULL), /* *prj_parms */
                      targetid = my_id);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : ECconst.EMstorepoint" );

     status = om$send(mode = OM_e_wrt_message,
                      msg = message ECconst.init_construct( &sts1 ),
                      targetid = my_id );
     EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : ECconst.init_construct" );

 }  /* end if */

 new_crv_num = me -> num_crvs;    /* set index for VLA crv_info */

 p_loc_crv_lc_info = &me^^CEO_LOCATE.event1.located_object[ 0 ];

 /* If the located object is owned by a GRcompcurve, then make the GRcompcurve
  * the located object.   Doree 8/26/93
  */

 ems$make_chanselect(chan_label = GRconnector_to_owners,
                     chan_selector = &to_owner);

 status = om$get_objid_at_index(osnum = p_loc_crv_lc_info->located_obj.osnum,
                                objid = p_loc_crv_lc_info->located_obj.objid,
                                p_chanselect = &to_owner,
                                index = 0,
                                objidaddr = &owner_id.objid,
                                osnumaddr = &owner_id.osnum);
 if (status == OM_S_SUCCESS)
 {
     status = om$get_classid(osnum = owner_id.osnum,
                             objid = owner_id.objid,
                             p_classid = &owner_classid);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : om$get_classid");

     status = om$is_ancestry_valid(subclassid = owner_classid,
                                   superclassid = OPP_GRcompcurve_class_id);
     if (status == OM_S_SUCCESS)
     {
         located_obj.objid = owner_id.objid;
         located_obj.osnum = owner_id.osnum;
     }
     else
     {
         located_obj = p_loc_crv_lc_info -> located_obj;
     }
 }
 else
 {
     located_obj = p_loc_crv_lc_info -> located_obj;
 }

 /* check if curve already identified */

 is_crv_dup = FALSE;
 if ( me -> num_crvs )
 {
     for ( crv_num = 0; (crv_num < me -> num_crvs); ++crv_num )
     {
         if (located_obj.objid IS me -> crv_info[ crv_num ].crv_id)
         {
             /* duplicate id found */
             ++me -> num_dup_crvs;
             is_crv_dup = TRUE;
             dup_crv_num = me -> crv_info[ crv_num ].dup_crvix;
             break;
         }
     }
 }

 /* check VLA size & increase size, if necessary */

 crv_info_vla_size = om$dimension_of (varray = me -> crv_info);
 ++me -> num_crvs;
 
 if ( me -> num_crvs > crv_info_vla_size)
 {
     /* increment the array size */

     status = om$vla_set_dimension(varray = me -> crv_info,
                             size = (crv_info_vla_size + crv_info_vla_incr) );
     EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : om$vla_set_dimension" );
 }

 if (is_crv_dup)
 {
     /* make copy of curve & use copy for processing */
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRcopy( &sts1,
                                 &p_loc_crv_lc_info -> module_info,
                                 &p_loc_crv_lc_info -> module_info,
                                 &copy_crv_id),
                      targetid = located_obj.objid,
                      targetos = located_obj.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : GRgraphics.GRcopy");

     located_obj.objid = copy_crv_id;
 }

 p_crv_info = &me -> crv_info[ new_crv_num ];

 /* save located curve id */

 p_crv_info -> crv_id = located_obj.objid;
 p_crv_info -> pcrv_id = NULL_OBJID;

 /* project located point (in event2) onto located curve (in event1) */

 p_mdenv_info = &p_loc_crv_lc_info -> module_info.md_env;

 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRptproject( &sts1, /* *msg */
                             &p_mdenv_info -> matrix_type, /* *matrix_type */
                             p_mdenv_info -> matrix, /* matrix */
                             &me^^CEO_LOCATE.event2.event.button.x, /* point */
                             p_crv_info -> loc_pt, /* proj_pt */
                             &p_crv_info -> loc_pt_prj_parms/* *proj_parms */),
                  targetid = located_obj.objid,
                  targetos = located_obj.osnum);
 EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : GRgraphics.GRptproject" );

 /* mark located point on curve */

 status = ECdisplayPointSetByBuffer(&sts1, me^^CEO_LOCATE.ActiveDisplay,
                                    me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts,
                                    p_crv_info -> loc_pt, draw_background);
 EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : ECdisplayPointSetByBuffer" );

 /* display object in highlight */

 me^^CEO_LOCATE.DisplayMode = GRhhd;
 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                             &p_mdenv_info -> matrix_type, /* *type */
                             p_mdenv_info -> matrix, /* matrix */
                             &me^^CEO_LOCATE.DisplayMode, /* *mode */
                             &p_loc_crv_lc_info -> module_info.md_id),
                  targetid = located_obj.objid,
                  targetos = located_obj.osnum);
 EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : GRgraphics.GRdisplay");

 if (is_crv_dup)
 {
     p_crv_info -> dup_crvix = me -> crv_info[ dup_crv_num ].dup_crvix;
     p_crv_info -> phy_closed = me -> crv_info[ dup_crv_num ].phy_closed;

     /* save event1 (accept point) in accept_event */

     me -> accept_event = me^^CEO_LOCATE.event1;

     /* save response type */

     me -> accept_response = *me^^CEO.response;
     sts1 = MSTRM_DUP_CRV;
     *sts = sts1;
     goto quit;
 }

 /* new curve, get geometric properties */

 p_crv_info -> dup_crvix = new_crv_num;

 /* get geometric properties of the curve, to find open/closed curve */

 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgeomprops( &sts1, /* *msg */
                         &p_mdenv_info -> matrix_type, /* *mat_type */
                         p_mdenv_info -> matrix, /* matrix */
                         &geomprops), /* *properties */
                  targetid = located_obj.objid,
                  targetos = located_obj.osnum);
 EMomerr_hndlr( status, quit, "ECtrmcrvele.save_loc_info : GRvg.GRgeomprops");

 me -> crv_info[ new_crv_num ].phy_closed = geomprops.phy_closed;

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  reject the last located information,
  erase mark at locate point & delete curve, if copy.

Keywords

History
  08/31/93 : dhm : added header

*/
method reject_loc_info ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRint         num_pnts = 1, /* for ECdisplayPointSetByBuffer */
                crvix;
 IGRboolean     draw_background = FALSE; /* for ECdisplayPointSetByBuffer */
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 struct EMScrv_info_sd  *p_crv_info;

 int    ECdisplayPointSetByBuffer();
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 --me -> num_crvs;
 crvix = me -> num_crvs;
 p_crv_info = &me -> crv_info[ crvix ];
 p_md_env = me^^ECconst.construct_list.env_info;

 /* unmark located point on curve */

 status = ECdisplayPointSetByBuffer(&sts1, me^^CEO_LOCATE.ActiveDisplay,
             me^^CEO_LOCATE.ModuleInfo, my_id, num_pnts, p_crv_info -> loc_pt,
             draw_background);
 EMomerr_hndlr( status, quit, "ECtrmcrvele.reject_loc_info : ECdisplayPointSetByBuffer" );

 if (p_crv_info -> dup_crvix ISNT crvix)
 {
     --me -> num_dup_crvs;

     /* delete the curve copy */
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdelete( &sts1,
                                                        p_md_env),
                      targetid = p_crv_info -> crv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.reject_loc_info : GRgraphics.GRdelete");

     goto quit; /* do not dehighlight if copy */
 }

 mdenv_info = p_md_env -> md_env;

 /* dehighlight the last located object */

 me^^CEO_LOCATE.DisplayMode = GRhe;
 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                                &mdenv_info.matrix_type, /* *type */
                                mdenv_info.matrix, /* matrix */
                                &me^^CEO_LOCATE.DisplayMode, /* *mode */
                                &p_md_env -> md_id /* *display_info */
                                ),
                  targetid = p_crv_info -> crv_id,
                  targetos = p_md_env -> md_id.osnum);
 EMomerr_hndlr( status, quit, "ECtrmcrvele.reject_loc_info : GRgraphics.GRdisplay");

 if (me -> num_crvs IS 1)
     sts1 = MSTRM_1_CRV;

 *sts = sts1;

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract

Keywords

History
  08/27/93 : dhm : added support for profiles.
  08/31/93 : dhm : added header.

*/
method process ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 /* end of user interaction, now process the information */

 IGRlong                sts1 = MSSUCC;
 IGRlong                EMtrmcrvele();
 IGRshort               crv_num, prf_inx = 0;
 struct EMScrv_info_sd  *p_crv_info;
 GRobjid                new_crv_id;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 IGRboolean             is_crv_nonint,
                        is_crv_invmult;
 OMuword                object_classid;
 IGRpoint               proj_pt;

 struct save_profile_info
 {
     GRobjid    prf_id;
     IGRshort   prf_to_crv_info_inx;
 };

 struct save_profile_info    *prf_info = NULL;

 *sts = MSSUCC;

 prf_info = (struct save_profile_info *)
     om$malloc(size = (me->num_crvs * sizeof(struct save_profile_info)) );

 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_I_00003);

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 /* If one of the objects was a profile, then drop associativity before
  * sending to EMtrmcrele().  Do this by copying out the basic geometry of the
  * profile (GRcompcurve, GR3dlineseg, etc) and then project the locate point
  * onto this new copied curve.   Doree  8/27/93
  */

 for (crv_num = 0; crv_num < me->num_crvs; crv_num++)
 {
   p_crv_info = &me->crv_info[crv_num];
   status = om$get_classid(objid = p_crv_info->crv_id,
                           p_classid = &object_classid,
                           osnum = p_md_env->md_id.osnum);
   EMomerr_hndlr( status, fini, "ECtrmcrvele.process : om$get_classid" );

   status = om$is_ancestry_valid(subclassid = object_classid,
                                 superclassid = OPP_SKgeometry_class_id);
   if (status == OM_S_SUCCESS)
   {
       prf_info[prf_inx].prf_id = p_crv_info->crv_id;
       prf_info[prf_inx].prf_to_crv_info_inx = crv_num;
       prf_inx++;

       status = om$send(msg = message GRgraphics.GRcopy(&sts1, p_md_env,
                              p_md_env, &new_crv_id),
                        targetid = p_crv_info->crv_id,
                        targetos = p_md_env->md_id.osnum);
       EMomerr_hndlr( status, fini, "ECtrmcrvele.process : NDnode.NDmove_to_root" );

       p_crv_info->crv_id = new_crv_id;

       status = om$send(msg = message GRgraphics.GRptproject(&sts1,
                              &mdenv_info.matrix_type, mdenv_info.matrix,
                              p_crv_info->loc_pt, proj_pt,
                              &p_crv_info->loc_pt_prj_parms),
                        targetid = p_crv_info->crv_id,
                        targetos = p_md_env->md_id.osnum);
       EMomerr_hndlr( status, fini, "ECtrmcrvele.process : GRgraphics.GRptproject");

       p_crv_info->loc_pt[0] = proj_pt[0];
       p_crv_info->loc_pt[1] = proj_pt[1];
       p_crv_info->loc_pt[2] = proj_pt[2];
   }

 }  /* end for loop */

 status = EMtrmcrvele(&sts1,                         /* *msg */
                      me -> crv_info,                /* **crv_info */
                      &me^^ECconst.construct_list,   /* *p_const_list */
                      me -> num_crvs,                /* num_crvs */
                      me -> num_dup_crvs,            /* num_dup_crvs */
                      &me -> compcrv_id);            /* *p_compcrv_id */

 EMomerr_hndlr( status, fini, "ECtrmcrvele.process : EMtrmcrvele" );

 is_crv_nonint = (sts1 IS MSTRM_NONINT_CRV);
 is_crv_invmult = (sts1 IS MSTRM_INVMULT_CRV);
 me -> is_crv_disjnt = (sts1 IS MSTRM_DISJNT_CRV);
 me -> is_crv_ambig = (sts1 IS MSTRM_AMBIG_CRV);

 /* If there were any profiles, then delete the copy of the profile and put
  * the original profile's id back into the me->crv_info array.  Doree  8/27/93
  */

 if (prf_inx)
 {
     for (crv_num = 0; crv_num < prf_inx; crv_num++)
     {
         p_crv_info = &me->crv_info[prf_info[crv_num].prf_to_crv_info_inx];

         status = om$send(msg = message GRgraphics.GRdelete(&sts1, p_md_env),
                          targetid = p_crv_info->crv_id,
                          targetos = p_md_env->md_id.osnum);
         EMomerr_hndlr(status, fini, "ECtrmcrvele.process : GRgraphics.GRdelete");

         p_crv_info->crv_id = prf_info[crv_num].prf_id;
     }
 }

 /* dehilight all curves */
 status = dp$erase_hilite( msg = &sts1,
                           objid = p_md_env -> md_id.objid,
                           osnum = p_md_env -> md_id.osnum);
 EMomerr_hndlr( status, fini, "ECtrmcrvele.process : dp$erase_hilite" );

 me^^CEO_LOCATE.DisplayMode = GRhd;

 if ( NOT(is_crv_nonint OR me -> is_crv_ambig OR me -> is_crv_disjnt
          OR is_crv_invmult) )
 {
     /* highlight the composite curve */
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay( &sts1, 
                                        &mdenv_info.matrix_type, 
                                        mdenv_info.matrix,
                                        &me^^CEO_LOCATE.DisplayMode,
                                        &p_md_env -> md_id),
                      targetid = me -> compcrv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, fini, "ECtrmcrvele.process : GRgraphics.GRdisplay : 1");

     goto fini; /* no more processing */
 }

 /* non-intersecting curves or disjoint and/or ambiguous result;
    highlight disjoint curves and/or curve segments */

 for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
 {
     p_crv_info = &me -> crv_info[ crv_num ];

     if (p_crv_info -> crv_stat IS CRV_DISCARD)
         continue;/* skip discarded curves */
     
     if (p_crv_info -> crv_stat IS CRV_DISJNT)
     {
         /* highlight non-intersecting / disjoint curve */
         status = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                                     &mdenv_info.matrix_type,       /* *type */
                                     mdenv_info.matrix,            /* matrix */
                                     &me^^CEO_LOCATE.DisplayMode,   /* *mode */
                                     &p_md_env -> md_id),   /* *display_info */
                          targetid = p_crv_info -> crv_id,
                          targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, fini, "ECtrmcrvele.process : GRgraphics.GRdisplay : 2");
     }
     else   /* (me -> is_crv_ambig OR me -> is_crv_disjnt) */
     {
         if (is_crv_invmult)
             continue; /* no segments for invalid multiple input */

         /* highlight curve segments */
         status = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                                     &mdenv_info.matrix_type,       /* *type */
                                     mdenv_info.matrix,            /* matrix */
                                     &me^^CEO_LOCATE.DisplayMode,   /* *mode */
                                     &p_md_env -> md_id),   /* *display_info */
                          targetid = p_crv_info -> pcrv_id,
                          targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, fini, "ECtrmcrvele.process : GRgraphics.GRdisplay : 3");
     }
 }

 if (is_crv_nonint)
     sts1 = MSTRM_NONINT_CRV;
 else if (is_crv_invmult)
     sts1 = MSTRM_INVMULT_CRV;
 else if (me -> is_crv_ambig)
     sts1 = MSTRM_AMBIG_CRV;
 else /* (me -> is_crv_disjnt) */
     sts1 = MSTRM_DISJNT_CRV;

 *sts = sts1;

fini:
  if (prf_info)  om$dealloc(ptr = prf_info);
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  result confirmed by user, erase & delete original curves;
  draw resultant composite curve.

Keywords

History
  08/30/93 : dhm : added support for profiles. 
  08/31/93 : dhm : added header.

*/
method confirm_result ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRshort               crv_num;
 IGRint                 num_objects = 1;
 struct EMScrv_info_sd  *p_crv_info;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 OMuword                object_classid;
 GRobjid                sk_mgr;
 struct GRobj_env       objects[1];
 struct GRid            GR_id;
 IGRboolean             assoc_flag;
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 me^^CEO_LOCATE.DisplayMode = GRbe;

 for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
 {
     p_crv_info = &me -> crv_info[ crv_num ];
     if (( p_crv_info -> crv_stat IS CRV_DISJNT ) OR
         (crv_num ISNT p_crv_info -> dup_crvix))
         /* skip disjoint elements and curve copies */
         continue;

     /* erase curve elements */
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay( &sts1,
                                 &mdenv_info.matrix_type,
                                 mdenv_info.matrix, 
                                 &me^^CEO_LOCATE.DisplayMode,
                                 &p_md_env -> md_id), 
                      targetid = p_crv_info -> crv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.confirm_result : GRgraphics.GRdisplay : 1");

     /* If it's a profile, then get its SKmgr and do a GRremove_components.
      * Doree  8/30/93
      */

     status = om$get_classid(objid = p_crv_info->crv_id,
                             p_classid = &object_classid,
                             osnum = p_md_env->md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.confirm_result : om$get_classid" );

     status = om$is_ancestry_valid(subclassid = object_classid,
                                   superclassid = OPP_SKgeometry_class_id);
     if (status == OM_S_SUCCESS)
     {
         /*
          * Disconnect the geometry from its manager.
          */

         status = om$send (msg = message SKgeometry.SKgetmgr(&sts1, &sk_mgr),
                           targetid = p_crv_info->crv_id,
                           targetos = p_md_env->md_id.osnum);
         EMomerr_hndlr(status, quit, "ECtrmcrvele.confirm_result : SKgetmgr");

         objects[0].obj_id.objid = p_crv_info->crv_id;
         objects[0].obj_id.osnum = p_md_env->md_id.osnum;
         status = om$send (msg = message SKmgr.GRremove_components
                                      (&sts1, p_md_env, &num_objects, objects),
                           targetid = sk_mgr,
                           targetos = p_md_env->md_id.osnum);
         EMomerr_hndlr(status, quit, "ECtrmcrvele.confirm_result : GRremove_components");

     }
     else
     {
         /* delete curve elements */
         status = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                     p_md_env /* *md_env */),
                          targetid = p_crv_info -> crv_id,
                          targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.confirm_result : GRgraphics.GRdelete");
     }

 }  /* end for loop */

 if (me->compcrv_id != NULL_OBJID)
 {
     /* If the associative flag is on, then convert the composite curve to a 
      * profile.    Doree  8/26/93
      */

     gr$get_associative_flag(buffer = &assoc_flag);

     if (assoc_flag)
     {
         GR_id.objid = me->compcrv_id;
         GR_id.osnum = p_md_env->md_id.osnum;
         status = sk$convert_to_profile(msg = &sts1,
                                        options = SK_CONVERT_VERBOSE,
                                        geometry = GR_id,
                                        module = p_md_env,
                                        profile = &me->compcrv_id,
                                        automask = SK_AUTO_GEOMETRIC);
         EMomerr_hndlr(status, quit, "ECtrmcrvele.confirm_result : convert_to_profile");
     }

     /* draw resultant composite curve */
     me^^CEO_LOCATE.DisplayMode = GRbd;

     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay(&sts1,
                                 &mdenv_info.matrix_type,
                                 mdenv_info.matrix,
                                 &me^^CEO_LOCATE.DisplayMode, 
                                 &p_md_env -> md_id),
                      targetid = me -> compcrv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.confirm_result : GRgraphics.GRdisplay : 2");

 }

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  delete the composite curve.

Keywords

History
  08/31/93 : dhm : added header

*/
method cancel_result ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 struct GRmd_env        *p_md_env;
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 p_md_env = me^^ECconst.construct_list.env_info;

 if (me->compcrv_id != NULL_OBJID)
 {
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                 p_md_env /* *md_env */),
                      targetid = me -> compcrv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.cancel_result : GRgraphics.GRdelete" );
     me->compcrv_id = NULL_OBJID;
 }

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract
  dehighlight & delete parts of curve.

Keywords

History
  08/31/93 : dhm : added header

*/
method cancel_part_result ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRshort               crv_num;
 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 p_md_env = me^^ECconst.construct_list.env_info;
 mdenv_info = p_md_env -> md_env;

 me^^CEO_LOCATE.DisplayMode = GRhe;
 for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
 {
     if ((me -> crv_info[ crv_num ].crv_stat IS CRV_DISCARD) OR
         (me -> crv_info[ crv_num ].crv_stat IS CRV_DISJNT))
         continue; /* skip discarded/disjoint curves */

     /* dehighlight segments */
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay( &sts1, /* *msg */
                                 &mdenv_info.matrix_type, /* *type */
                                 mdenv_info.matrix, /* matrix */
                                 &me^^CEO_LOCATE.DisplayMode, /* *mode */
                                 &p_md_env -> md_id), /* *display_info */
                      targetid = me -> crv_info[ crv_num ].pcrv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.cancel_part_result : GRgraphics.GRdisplay");

     /* delete segments */
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdelete( &sts1, /* *msg */
                                 p_md_env), /* *md_env */
                      targetid = me -> crv_info[ crv_num ].pcrv_id,
                      targetos = p_md_env -> md_id.osnum);
     EMomerr_hndlr( status, quit, "ECtrmcrvele.cancel_part_result : GRgraphics.GRdelete");
     me -> crv_info[ crv_num ].pcrv_id = NULL_OBJID;
 }

 me -> is_crv_ambig = FALSE;
 me -> is_crv_disjnt = FALSE;

quit:
  return OM_S_SUCCESS;
}


/*
Name

Abstract

Keywords

History
  08/31/93 : dhm : added header

*/
method hilight_curves ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRshort               crv_num;

 struct GRmd_env        *p_md_env;
 struct GRmdenv_info    mdenv_info;
 long sts1 = MSSUCC;

 *sts = MSSUCC;

 if ( me -> num_crvs )
 {
     p_md_env = me^^ECconst.construct_list.env_info;
     mdenv_info = p_md_env -> md_env;
     me^^CEO_LOCATE.DisplayMode = GRhhd;

     for ( crv_num = 0; ( crv_num < me -> num_crvs); ++crv_num )
     {
         if (me -> crv_info[ crv_num ].dup_crvix ISNT crv_num)
             continue; /* skip curve copies */

         /* highlight identified curves */
         status = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay(
                                     &sts1, /* *msg */
                                     &mdenv_info.matrix_type, /* *type */
                                     mdenv_info.matrix, /* matrix */
                                     &me^^CEO_LOCATE.DisplayMode, /* *mode */
                                     &p_md_env -> md_id), /* *display_info */
                          targetid = me -> crv_info[ crv_num ].crv_id,
                          targetos = p_md_env -> md_id.osnum);
         EMomerr_hndlr( status, quit, "ECtrmcrvele.hilight_curves : GRgraphics.GRdisplay");

     } /* end for loop */

 } /* end if (me->num_crvs) */

quit:
  return OM_S_SUCCESS;
}

end implementation ECtrmcrvele;
