class implementation NMcrtbnd;

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif
# include "griodef.h"
# include "igrtypedef.h"
# include "igrdp.h"
# include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "ECcmd.h"
#include "ECmsg.h"
#include "NMcmd.h"
#include "NMmsg.h"
/* BYRON #include "local_dsp.h"*/  /* Local display macro */
#include "exmacros.h"   /* Has ex$putque */
#include "dpmacros.h"   /* Has dp$erase_hilite */
#include "msmacros.h"   /* Has message subsystem macros */
#include "maerr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "lcmacros.h"
#include "EMSmsgdef.h"
#include "griomacros.h"    /* co$getevent */
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "emsdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "nmdef.h"
#include "EMSaction.h"
#include "EMSlmdef.h"
#include "go.h"
#include "bssfeval.h"
#include "bsdistptpt.h"

#define TRUE  1
#define FALSE 0

#define INCREMENT     10

/* command states */
#define BEGIN_STATE             0
#define LOCATE_SURFACE          1
#define LOCATE_BOUNDARIES       2
#define INPUT_POINTS		3
#define CREATE_BOUNDARIES       4
#define LOCATE_GLUE_SURFACES	5
#define GLUE_SURFACES		6

/* MYTYPES */
#define EMBED_EDGE		0
#define EMBED_EDGE_GLUE_SF	1

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn NMcrtbnd error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }
#endif

from GRgraphics import GRdisplay, GRdelete, GRptproject;
from GRlinear import GRgetpolyline;
from EMSsurface import EMputLsIfNotThere;
from NMnonmanibnd import NMcreate_boundaries;
from NMnonmanist	import NMperform_stitch;
from GRvg import EMptatpr;
from EMSedge import EMptproject;

extern IGRlong EFbuild_graphic_group();
extern IGRint EMdpb_getinfo();
extern OM_S_OBJID current_creator;

extern OMuword OPP_EMSsubbs_class_id, OPP_NMnonmanibnd_class_id, 
	       OPP_NMnonmanist_class_id, OPP_NMnonmani_class_id;
extern OMuword OPP_GRbspline_class_id, OPP_GRcurve_class_id;


struct dynfunc_args
{
 struct GRid surfid;
 struct GRmd_env surfenv;
 struct DPele_header disbuf;
};


method delete(int defer_flag)
{
 IGRlong sts, i, msg, j;
 enum           GRdpmode DisplayMode;
 struct         GRlc_info *info;

 sts = OM_S_SUCCESS;

 /* Delete the points if they were created.
 */
 info = &ME.NMcrtbnd->cvs[0]; 
 for(j=0; j<me->numsf; j++)
  {
   if(me->points[j])
    {
     DisplayMode = GRbehe;
     for (i=0; i<ME.NMcrtbnd->numcv_persf[j]; i++)
      {
       sts = om$send(msg = message GRgraphics.GRdisplay
                         (&msg,
                          &info->module_info.md_env.matrix_type,
                          info->module_info.md_env.matrix, 
                          &DisplayMode, &me->ModuleInfo.md_id),
           targetid = info->located_obj.objid,
           targetos = info->located_obj.osnum);
       if (!(1 & sts)) return(OM_E_ABORT);
       sts = om$send(msg = message GRgraphics.GRdelete
           (&msg, &info->module_info), 
           targetid = info->located_obj.objid,
           targetos = info->located_obj.osnum);
       if (!(1 & sts)) return(OM_E_ABORT);
       info++;
      }
    }
   else info += ME.NMcrtbnd->numcv_persf[j];
  }
 sts = om$send(mode = OM_e_wrt_ancestor,
               msg = message Root.delete(1),
               targetid = my_id);
 if (!(1&sts)) return (OM_E_ABORT);

 return (sts);
}

method wakeup(int pos)
{
    IGRlong        i, msg, sts, j;
    enum           GRdpmode DisplayMode;
    struct         GRlc_info *info;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message NMcrtbnd.wakeup (pos),
                   targetid = my_id);
    if (!(1 & sts)) return(OM_E_ABORT);

    DisplayMode = GRhd;
    info = &ME.NMcrtbnd->cvs[0];

   for(j=0; j<me->numsf; j++)
    {
     for (i=0; i< ME.NMcrtbnd->numcv_persf[j]; i++)
      {
       if(ME.NMcrtbnd->points[j])
        {
         DisplayMode = GRbd;
         sts = om$send(msg = message GRgraphics.GRdisplay
                           (&msg,
                            &info->module_info.md_env.matrix_type,
                            info->module_info.md_env.matrix, 
                            &DisplayMode, &me->ModuleInfo.md_id),
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);
         if (!(1 & sts)) return(OM_E_ABORT);
        }

        DisplayMode = GRhd;
        sts = om$send(msg = message GRgraphics.GRdisplay
                           (&msg,
                            &info->module_info.md_env.matrix_type,
                            info->module_info.md_env.matrix, 
                            &DisplayMode, &me->ModuleInfo.md_id),
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);
        if (!(1 & sts)) return(OM_E_ABORT);
        info++;
      }
    }

    /* Get the dpb variables */

    sts = EMdpb_getinfo (&msg, &me->dpb_info);
    gr$get_associative_flag( buffer = &me->associative_flag ); 

    if (me->associative_flag)
        GRdisplay_associative_button(TRUE);

    return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
    IGRlong        msg, sts, *response;
    IGRlong        junk;
    IGRlong        i, j;
    enum           GRdpmode DisplayMode;
    struct         GRlc_info *info;


    response = (IGRlong *) &junk;
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "dp$erase_hilite error")

    if (me->associative_flag)
        GRdisplay_associative_button(FALSE);

    info = &ME.NMcrtbnd->cvs[0];
    DisplayMode = GRbehe;
    for(j=0; j<ME.NMcrtbnd->numsf; j++)
     {
      if(me->points[j])
       {
        for (i=0; i<ME.NMcrtbnd->numcv_persf[j]; i++)
         {
          sts = om$send(msg = message GRgraphics.GRdisplay
                           (&msg,
                            &info->module_info.md_env.matrix_type,
                            info->module_info.md_env.matrix, 
                            &DisplayMode, &me->ModuleInfo.md_id),
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);
          if (!(1 & sts)) return(OM_E_ABORT);
          info++;
         }
       }
      else info += ME.NMcrtbnd->numcv_persf[j];
     }
    return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
 enum           GRdpmode DisplayMode;
 IGRchar        locate_prompt[80];
 IGRushort      map_options, nm_options;
 IGRint         size, object_was_located, display_flag, sts;
 IGRlong        msg, putque_size;
 IGRint         locate_mask, accept_mask, i, j;
 struct GRevent event, accept_event;
 struct GRlc_locate attributes;
 GRobjid	nmid = NULL_OBJID;
 struct   GRvg_construct construct_list;
 struct GRlc_info *info = NULL;
 IGRchar    status_str[54];
 static struct dynfunc_args dynargs;
 static struct IGResps esps;
 static struct IGRpointset dynpt;
 static struct IGRdisplay dyndisatt;
 IGRint NMptdynamics();

/*
 * Initialize
 */
 sts = OM_S_SUCCESS;
 size = sizeof(event);

 if(ME.super_cmd->mytype == EMBED_EDGE)
  ex$message(msgnumb = NMC_M_EmbedEdgeOnSurf)
 else if(ME.super_cmd->mytype == EMBED_EDGE_GLUE_SF)
  ex$message(msgnumb = NMC_M_EmbedEdgeGlueSurf)

/*
 * Enter infinite loop
 */
 do
  {
   switch(ME.super_cmd->state)
    {
/*
 * Room for growth
 */
     case BEGIN_STATE:
      ME.super_cmd->state = LOCATE_SURFACE;
/*
 * Get the surface(s)
 */
     case LOCATE_SURFACE:

      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      if (ME.NMcrtbnd->numsf)
       {
        i = ME.NMcrtbnd->numsf + 1;
        ex$message(
         msgnumb = NM_P_IdSfMvOnToCrtBnd, 
         type = "%d",
         var = `i`,
         buff = locate_prompt)
        locate_mask |= GRm_RJT_MOVEON;
       }
      else
       {
        i = 1;
        ex$message(
         msgnumb = EMS_P_00062,	/* identify boundary surface $1 */
         type = "%d",
         var = `i`,
         buff = locate_prompt)
       }

      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ALL_WINDOWS             |       /* Hilite in all windows */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_WRITE_ONLY;                  /* I'm going to change this guy */

       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |                /* We want the surface itself */
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;

       {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler already_located;
       IGRint	   i;

       already_located.next = NULL;
       already_located.option = 0;
       already_located.type = 0; /* Specifying GRlc_info 's */
       already_located.num_objects = 0;
       for(i=0; (i<RLW_STACK_SIZE) && (i<ME.NMcrtbnd->numsf); i++)
        {
         already_located.objects.lc_info[i] = &ME.NMcrtbnd->sf[i];
         (already_located.num_objects)++;
        }

       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_prompt =        locate_prompt, 
         acc_key =              NM_P_AccWCurve,
         relocate_key =         EMS_I_00011,  /* surface not found */
         attributes =           &attributes,
         act_handler = 		EFlocate_action_handler,
         act_args = 		&already_located,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);

       ERROR(sts, object_was_located, "lc$locate error")
       }
      }
      if (!object_was_located)
       {
        if (ME.NMcrtbnd->locate_event.response == EX_BACK_UP)
         {
          if (ME.NMcrtbnd->numsf)
           {
            if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
              info = &ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs - 1];
	    for(i=0; i<ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1];i++)
             {
              DisplayMode = GRhd;
              sts = om$send(
                    msg = message GRgraphics.GRdisplay(
                    &msg,
                    &info->module_info.md_env.matrix_type,
                    info->module_info.md_env.matrix, 
                    &DisplayMode,
                    &me->ModuleInfo.md_id),
                    targetid = info->located_obj.objid,
                    targetos = info->located_obj.osnum);

	      if(ME.NMcrtbnd->points[ME.NMcrtbnd->numsf - 1])
	       {
                DisplayMode = GRbd;
                sts = om$send(
                      msg = message GRgraphics.GRdisplay(
                      &msg,
                      &info->module_info.md_env.matrix_type,
                      info->module_info.md_env.matrix, 
                      &DisplayMode,
                      &me->ModuleInfo.md_id),
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);

                sts = om$send(
                      msg = message GRgraphics.GRdelete(
                      &msg, &info->module_info), 
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);
	       }
	      info--;
	     }
	
            info = &ME.NMcrtbnd->sf[ME.NMcrtbnd->numsf - 1];
            DisplayMode = GRhd;
            sts = om$send(
             msg = message GRgraphics.GRdisplay(
              &msg,
              &info->module_info.md_env.matrix_type,
              info->module_info.md_env.matrix, 
              &DisplayMode,
              &me->ModuleInfo.md_id),
             targetid = info->located_obj.objid,
             targetos = info->located_obj.osnum);

	    if(ME.NMcrtbnd->points[ME.NMcrtbnd->numsf - 1])
	     ME.super_cmd->state = INPUT_POINTS;
	    else
	     ME.super_cmd->state = LOCATE_BOUNDARIES;	
           }
          else ME.super_cmd->state = LOCATE_SURFACE;
	 }
        else if (ME.NMcrtbnd->locate_event.response == EX_RJT_MOVEON)
	 ME.super_cmd->state = CREATE_BOUNDARIES;
         return(OM_S_SUCCESS);
       }
      else
       {
        OMuint  vla_size;

        /*
         * Check if enough space is available to save surface.
         */
        vla_size = om$dimension_of (varray = ME.NMcrtbnd->sf);
        if ((ME.NMcrtbnd->numsf + 2)  > vla_size)
         {
          sts = om$vla_set_dimension (varray = ME.NMcrtbnd->sf,
                                          size = vla_size + INCREMENT);
          sts = om$vla_set_dimension (varray = ME.NMcrtbnd->numcv_persf,
                                          size = vla_size + INCREMENT);
          sts = om$vla_set_dimension (varray = ME.NMcrtbnd->points,
                                          size = vla_size + INCREMENT);
          ERROR (sts, 1, "vla_set_dimension");
         }
        ME.NMcrtbnd->sf[ME.NMcrtbnd->numsf] = 
             accept_event.located_object[0];
        ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf] = 0;
        ME.NMcrtbnd->points[ME.NMcrtbnd->numsf++] = FALSE;
	/*
 	 * Put the accept event on the queue
         */
        putque_size = sizeof(accept_event.event) + sizeof (IGRint) ;
        sts = ex$putque(msg = &msg, response = response,
                        byte = &putque_size, 
                        buffer = (IGRchar *) &accept_event.event);
        ERROR(sts, msg, "ex$putque error")
        ME.super_cmd->state = LOCATE_BOUNDARIES;

        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "dp$erase_hilite error")

       } /* ELSE FOR if (!object_was_located) */

      break;

/*
 * Loop around until all curves have been input
 */
     case LOCATE_BOUNDARIES:

      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      me->points[ME.NMcrtbnd->numsf - 1] = FALSE;
      if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
       {
        i = ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1] + 1;
        ex$message(
         msgnumb = NM_P_IdCurveEnough,
         type = "%d",
         var = `i`,
         buff = locate_prompt)
        locate_mask |= GRm_RJT_MOVEON;
       }
      else
       {
	if(ME.super_cmd->mytype == EMBED_EDGE)
	 {
          ex$message(msgnumb = NM_P_IdCvMvOnForPt, buff = locate_prompt)
          locate_mask |= GRm_RJT_MOVEON;
	 }
        else if(ME.super_cmd->mytype == EMBED_EDGE_GLUE_SF)
          ex$message(msgnumb = NM_P_IdentifyCurve, buff = locate_prompt)
       }
      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ALL_WINDOWS             |       /* Hilite in all windows */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;           /* Don't erase hilite */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* I'm only going to read */

       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |
        LC_RIGID_OWNER |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_GRcurve_class_id;

       {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler already_located;
       IGRint	   i, numlc = 0;
       struct GRlc_info *junkptr = NULL;

       already_located.next = NULL;
       already_located.option = 0;
       already_located.type = 0; /* Specifying GRlc_info 's */
       already_located.num_objects = 0;
       
       numlc = ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1];
       if(numlc)
        junkptr = &ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs - 1];
       for(i=0; (i<RLW_STACK_SIZE) && (i<numlc); i++)
        {
         already_located.objects.lc_info[i] = junkptr;
         (already_located.num_objects)++;
         junkptr--;
        }

       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_prompt =        locate_prompt,
         acc_key =              NM_P_AccWNextCurve,
         relocate_key =         EMS_I_00010, /* curve not found */
         attributes =           &attributes,
         act_handler = 		EFlocate_action_handler,
         act_args = 		&already_located,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
       }

       ERROR(sts, object_was_located, "lc$locate error")
      }
      ex$message(msgnumb = EMS_I_00000)
      if (!object_was_located)
       {
        if (ME.NMcrtbnd->locate_event.response == EX_BACK_UP)
         {
          if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
           {
            info = &ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs - 1];
            DisplayMode = GRhe;
            sts = om$send(
             msg = message GRgraphics.GRdisplay(
              &msg,
              &info->module_info.md_env.matrix_type,
              info->module_info.md_env.matrix, 
              &DisplayMode,
              &me->ModuleInfo.md_id),
             targetid = info->located_obj.objid,
             targetos = info->located_obj.osnum);
            (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])--;
	    ME.NMcrtbnd->totalcvs--;
           }
          else
           {
	    ME.NMcrtbnd->numsf--;
            ME.super_cmd->state = LOCATE_SURFACE;
	   }
         }
        else if (ME.NMcrtbnd->locate_event.response == EX_RJT_MOVEON)
         {
          if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
              ME.super_cmd->state = LOCATE_SURFACE;
	  else ME.super_cmd->state = INPUT_POINTS;
         }
        else
         return(OM_S_SUCCESS);
       }
      else      /* an object was located */
      {
          OMuint  vla_size;

          /*
           * Check if enough space is available to save
           * the located boundary.
           */
          vla_size = om$dimension_of (varray = ME.NMcrtbnd->cvs);
          if ((ME.NMcrtbnd->totalcvs + 2)  > vla_size)
          {
            sts = om$vla_set_dimension (varray = ME.NMcrtbnd->cvs,
                                          size = vla_size + INCREMENT);
            ERROR (sts, 1, "vla_set_dimension");
          }
         (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])++;
          ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs++] = 
              accept_event.located_object[0];
          putque_size = sizeof(accept_event.event) + sizeof (IGRint);
          sts = ex$putque(msg = &msg, response = response,
                          byte = &putque_size, 
                          buffer = (IGRchar *) &accept_event.event);
          ERROR(sts, msg, "ex$putque error");

      }
      break;
/*
 * Create the boundaries on the surface
 */
     case CREATE_BOUNDARIES:

      ex$message(msgnumb = EMS_P_00000)
      ex$message(msgnumb = EMS_I_Processing)
      ex$message(msgnumb = EMS_I_Processing, buff = status_str);

      dp$erase_hilite(msg = &msg);
     for(i=0; i<ME.NMcrtbnd->numsf; i++)
      {
       struct GRid *surf;

       info = &ME.NMcrtbnd->sf[i];
       surf = &info->located_obj;
       current_creator = NULL_OBJID;
       sts = om$send (msg = message EMSsurface.EMputLsIfNotThere
                              (&msg,
                               &info->module_info.md_env,
                               NULL, NULL, NULL, NULL),
                         targetid = surf->objid,
                         targetos = surf->osnum); 
       current_creator = NULL_OBJID;
       ERROR(sts, msg, "EMSsubbs.EMmk_nat_bdry")
      }

      construct_list.msg = &msg;
      construct_list.env_info = &ME.CObuild->ModuleInfo;
      construct_list.newflag = FALSE;
      construct_list.geometry = NULL;
      construct_list.class_attr = NULL;
      construct_list.level = ME.CObuild->ActiveLevel;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.display = &ME.CObuild->ActiveDisplay;
      construct_list.name = NULL;

      current_creator = NULL_OBJID;

      map_options = EMMapBnd_WantBadCurves |
                    EMMapBnd_StrokeIfNeeded | EMMapBnd_NoValidate | 
		    EMMapBnd_NoFixing | EMMapBnd_ClipBdryArea |
		    EMMapBnd_NoRmvColEds;

      nm_options = NULL;
      if(!me->associative_flag) nm_options |=  NMcreatebnd_NoCurveAssoc;

      nmid = NULL_OBJID;
      {
       struct EMSdataselect *cvptr = NULL;
       struct GRid *surfid = NULL;
       IGRint i, numcv = 0;
       struct IGRbsp_curve *ptcv = NULL;

       cvptr = (struct EMSdataselect *) om$malloc(size = ME.NMcrtbnd->totalcvs
	       * sizeof(struct EMSdataselect));
       DisplayMode = GRbe;

       numcv = 0;
       for(i=0; i<ME.NMcrtbnd->numsf; i++)
        {
	 for(j=0; j<ME.NMcrtbnd->numcv_persf[i]; j++)
	  {
	   if(ME.NMcrtbnd->points[i])
	    {
	     cvptr[numcv].datatype = EMSdata_curve3d;
	     info = &ME.NMcrtbnd->cvs[numcv];
	
             sts = EMgetvggeom(&msg, &info->module_info.md_env.matrix_type, 
             info->module_info.md_env.matrix, &info->located_obj, &ptcv,NULL);
             ERROR(sts, msg, "EMgetvggeom error")      
	     cvptr[numcv].data.curve = ptcv;

             sts = om$send(
                    msg = message GRgraphics.GRdisplay(
                    &msg,
                    &info->module_info.md_env.matrix_type,
                    info->module_info.md_env.matrix, 
                    &DisplayMode,
                    &me->ModuleInfo.md_id),
                    targetid = info->located_obj.objid,
                    targetos = info->located_obj.osnum);
             ERROR(sts, msg, "GRdisplay error")
	
             sts = om$send(
                    msg = message GRgraphics.GRdelete(
                    &msg, &info->module_info), 
                    targetid = info->located_obj.objid,
                    targetos = info->located_obj.osnum);
             ERROR(sts, msg, "GRdisplay error")
	    }
	   else
	    {
	     cvptr[numcv].datatype = EMSdata_object;
	     cvptr[numcv].data.object = &ME.NMcrtbnd->cvs[numcv].located_obj;
	    }
	   numcv++;
	  }
        }

       surfid = (struct GRid *) om$malloc(size = ME.NMcrtbnd->numsf *
		sizeof(struct GRid));
       for(i=0; i<ME.NMcrtbnd->numsf; i++)
        surfid[i] = ME.NMcrtbnd->sf[i].located_obj;

        sts = om$construct(osnum = surfid[0].osnum, 
			 classid = OPP_NMnonmanibnd_class_id, 
			 p_objid = &nmid, 
			 msg = message NMnonmanibnd.NMcreate_boundaries(
                               &msg, ME.NMcrtbnd->numsf, surfid, 
			       ME.NMcrtbnd->numcv_persf, cvptr, 
                               &ME.NMcrtbnd->sf[0].module_info,
			       &construct_list, 			       
                               map_options, nm_options, 
			       status_str));
       if(cvptr) om$dealloc(ptr = cvptr);
       if(surfid) om$dealloc(ptr = surfid);
      }
      current_creator = NULL_OBJID;

      if(msg == EMS_I_NoMoreLoops)
       ex$message(msgnumb = NM_E_NoCurveInArea)
      else if (!(1 & sts & msg))
        ex$message(msgnumb = EMS_E_OperationFailed)
      else ex$message(msgnumb = NM_I_Done)

      if(ME.super_cmd->mytype == EMBED_EDGE)
       {
        ME.NMcrtbnd->totalcvs = 0;
        ME.NMcrtbnd->numsf = 0;
        ME.super_cmd->state = BEGIN_STATE;
       }
      else
        ME.super_cmd->state = LOCATE_GLUE_SURFACES;

      break;


     case INPUT_POINTS:

      me->points[ME.NMcrtbnd->numsf - 1] = TRUE;

      /* Build the display buffer for dynamics.
      */
      esps.is_connected = FALSE;
      dynpt.num_points = 0;
      dynpt.points = NULL;
      dyndisatt = ME.CObuild->ActiveDisplay;
      dyndisatt.weight = 3;
      dp$build_dis_buffer (buffer = &dynargs.disbuf, type = IGRPS, 
        display_att = &dyndisatt, ele_spec_att = &esps, 
	geometry = &dynpt);
	
      info = &ME.NMcrtbnd->sf[ME.NMcrtbnd->numsf - 1];

      current_creator = NULL_OBJID;
      sts = om$send (msg = message EMSsurface.EMputLsIfNotThere
                              (&msg,
                               &info->module_info.md_env,
                               NULL, NULL, NULL, NULL),
                         targetid = info->located_obj.objid,
                         targetos = info->located_obj.osnum); 
      current_creator = NULL_OBJID;
      ERROR(sts, msg, "EMSsubbs.EMmk_nat_bdry")

      dynargs.surfid = info->located_obj;
      dynargs.surfenv = info->module_info;

      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA;

      if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
       {
        i = ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1] + 1;
        ex$message(
         msgnumb = NM_P_InputPointMvOn,
         type = "%d",
         var = `i`,
         buff = locate_prompt)
       }
      else
       {
        ex$message(
         msgnumb = NM_P_InputPoint, 
         buff = locate_prompt)
       }


      UI_prompt(locate_prompt);

      /* Call the dynamics function.
      */
      dp$dynamics(dyn_fun = NMptdynamics, information = &dynargs);

      sts = co$getevent(msg = &object_was_located, 
	     event_mask = locate_mask, prompt = locate_prompt, 
	     response = response, response_data = response_data, 
	     event = &accept_event);
	
      ERROR(sts, object_was_located, "lc$locate error")
      ex$message(msgnumb = EMS_I_00000)

      if (accept_event.response == EX_BACK_UP)
       {
        if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
         {
          info = &ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs - 1];
          DisplayMode = GRbehe;
          sts = om$send(
                msg = message GRgraphics.GRdisplay(
                &msg,
                &info->module_info.md_env.matrix_type,
                info->module_info.md_env.matrix, 
                &DisplayMode,
                &me->ModuleInfo.md_id),
                targetid = info->located_obj.objid,
                targetos = info->located_obj.osnum);
          sts = om$send(
                msg = message GRgraphics.GRdelete(
                &msg, &info->module_info), 
                targetid = info->located_obj.objid,
                targetos = info->located_obj.osnum);
          ME.NMcrtbnd->totalcvs--;
          (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])--;
          if(!ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1]) 
	   ME.super_cmd->state = LOCATE_BOUNDARIES;
        }
       else
        ME.super_cmd->state = LOCATE_BOUNDARIES;
      }
     else if (accept_event.response == EX_RJT_MOVEON)
      {
       if (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])
        ME.super_cmd->state = LOCATE_SURFACE;
      }
     else if (accept_event.response == EX_DATA)
      {
        OMuint  vla_size;
        struct GRid ptid;
	IGRpoint pt, oldpt;
        IGRint numcv, i, action = 1;
        IGRlong   rc;
        IGRdouble bastol;
        struct IGRpolyline poly;
        IGRboolean is_unique = TRUE;

        BSEXTRACTPAR(&rc, BSTOLLENVEC, bastol);
        poly.points = oldpt;

        construct_list.msg = &msg;
        construct_list.env_info = &ME.CObuild->ModuleInfo;
        construct_list.newflag = FALSE;
        construct_list.geometry = NULL;
        construct_list.class_attr = NULL;
        construct_list.level = ME.CObuild->ActiveLevel;
        construct_list.properties = GRIS_DISPLAYABLE;
        construct_list.display = &ME.CObuild->ActiveDisplay;
        construct_list.name = NULL;
        if(dynargs.disbuf.geometry.point_set->points)
         OM_BLOCK_MOVE(dynargs.disbuf.geometry.point_set->points, pt, 
			sizeof(IGRpoint));
	else
	 {
          pt[0] = accept_event.event.button.x;
          pt[1] = accept_event.event.button.y;
          pt[2] = accept_event.event.button.z;
	 }

	/* Check the new point against all accumulated points for this surface,
	   for uniqueness.
	*/
        numcv = 0;
        for(i=0; i< (ME.NMcrtbnd->numsf - 1); i++)
         numcv += ME.NMcrtbnd->numcv_persf[i];

        info = &ME.NMcrtbnd->cvs[numcv];
        is_unique = TRUE;
        for(i=0; i<ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1]; i++)
         {
	  poly.num_points = 0;
	  sts = om$send(msg = message GRlinear.GRgetpolyline(&msg, 
                &info->module_info.md_env.matrix_type,
                info->module_info.md_env.matrix, &action, &poly), 
                targetid = info->located_obj.objid,
                targetos = info->located_obj.osnum);
          ERROR(sts, msg, "GRgetpolyline error")
          if(poly.num_points && (BSdistptpt(&rc, oldpt, pt) <= bastol))
           {
	    ex$message(msgnumb = EMS_I_00001); /* Data not unique */
	    is_unique = FALSE;
	    break;
           }
          info++;
         }
       if(!is_unique) break;

       sts = EMoutput_point(&msg, my_id, &construct_list, 1, pt, &ptid);
        ERROR(sts, msg, "EMoutput_point error")

        /*
         * Check if enough space is available to save
         * the located boundary.
         */
        vla_size = om$dimension_of (varray = ME.NMcrtbnd->cvs);
        if ((ME.NMcrtbnd->totalcvs + 2)  > vla_size)
         {
          sts = om$vla_set_dimension (varray = ME.NMcrtbnd->cvs,
                                      size = vla_size + INCREMENT);
          ERROR (sts, 1, "vla_set_dimension");
         }
        (ME.NMcrtbnd->numcv_persf[ME.NMcrtbnd->numsf - 1])++;
        ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs] = ME.NMcrtbnd->sf[0];
        ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs++].located_obj = ptid;

        info = &ME.NMcrtbnd->cvs[ME.NMcrtbnd->totalcvs - 1];
        DisplayMode = GRbd;
        sts = om$send(
               msg = message GRgraphics.GRdisplay(
              &msg,
              &info->module_info.md_env.matrix_type,
              info->module_info.md_env.matrix, 
              &DisplayMode,
              &me->ModuleInfo.md_id),
             targetid = info->located_obj.objid,
             targetos = info->located_obj.osnum);
      }
     else return(OM_S_SUCCESS);

     break;


     case LOCATE_GLUE_SURFACES:

       if(!me->num_gluesf && me->numsf && !me->glue_set_shown)
        {
	 OM_S_CHANSELECT to_parents;
	 OM_S_OBJECT_LINKAGE sfid;
	 extern OMuword OPP_NDnodein_class_id;
         struct GRid thiscv;
	 IGRint j;
	 OMuint count = 0;
	 IGRboolean sfelig = TRUE;
         OMuint vla_size;

	 sts = om$vla_set_dimension(varray = me->glue_sf, size = me->numsf);
	 ERROR(sts, 1, "vla set dimension");

	 /* Add the surfaces on which edges were created to the set of
	    surfaces to be glued.
	 */
         for(i=0; i<ME.NMcrtbnd->numsf; i++)
          me->glue_sf[i] = ME.NMcrtbnd->sf[i].located_obj;

         me->num_gluesf = me->numsf;

         /* Add the surfaces which contributed the curves in edge creation
	    to the set of surfaces to be glued.
	 */
         sts = EMmake_chanselect (NDfather_father, &to_parents);
         ERROR(sts, msg, "make chanselect")		
	 for(i=0; i<me->totalcvs; i++)
	  {
	   thiscv = me->cvs[i].located_obj;
	   if(!EFisAncestryValid(&msg, thiscv.objid, thiscv.osnum, 
				 OPP_NDnodein_class_id))
	    continue;
	   sts = om$get_channel_objects(objid = thiscv.objid, 
		 osnum = thiscv.osnum, p_chanselect = &to_parents, 
		 list = &sfid, size = 1, count = &count);
           ERROR(sts, msg, "get cv parent")
           if(!count) continue;
	   if(!EFisAncestryValid(&msg, sfid.S_objid, sfid.osnum, 
				 OPP_EMSsurface_class_id))
	    continue;

           sfelig = TRUE;
           for(j=0; j<me->num_gluesf; j++)
            {
	     if( (me->glue_sf[j].objid == sfid.S_objid) &&
		 (me->glue_sf[j].osnum == sfid.osnum))
	      {
	       sfelig = FALSE;
	       break;
	      }
            }
           if(!sfelig) continue;

           /*
            * Check if enough space is available to save surface.
           */
           vla_size = om$dimension_of (varray = ME.NMcrtbnd->glue_sf);
           if ((ME.NMcrtbnd->num_gluesf + 2)  > vla_size)
            {
             sts = om$vla_set_dimension (varray = ME.NMcrtbnd->glue_sf,
                                          size = vla_size + INCREMENT);
             ERROR (sts, 1, "vla_set_dimension");
            }
           ME.NMcrtbnd->glue_sf[ME.NMcrtbnd->num_gluesf].objid = sfid.S_objid;
           ME.NMcrtbnd->glue_sf[ME.NMcrtbnd->num_gluesf++].osnum = sfid.osnum;

	  } /* for(i=0; i<me->totalcvs; i++) */
	
         sts = dp$erase_hilite(msg = &msg);
         ERROR(sts, msg, "dp$erase_hilite error")

         /* Hilight the set of surfaces to be glued.
         */
         info = &me->sf[0];
         DisplayMode = GRhd;
         for(i=0; i<me->num_gluesf; i++)
          {
           sts = om$send(
                      msg = message GRgraphics.GRdisplay(
                      &msg,
                      &info->module_info.md_env.matrix_type,
                      info->module_info.md_env.matrix, 
                      &DisplayMode,
                      &me->ModuleInfo.md_id),
                      targetid = me->glue_sf[i].objid,
                      targetos = me->glue_sf[i].osnum);
           ERROR(sts, msg, "GRdisplay error")
          }
         me->glue_set_shown = TRUE;

        } /* if(!me->num_gluesf && me->numsf && !me->glue_set_shown) */

       if(!me->num_gluesf)
        {
         ME.NMcrtbnd->totalcvs = 0;
         ME.NMcrtbnd->numsf = ME.NMcrtbnd->num_gluesf = 0;
         ME.NMcrtbnd->glue_set_shown = FALSE;
         ME.super_cmd->state = BEGIN_STATE;
         break;
        }

       ex$message(msgnumb = NM_I_SfToBeGluedHilited);

       locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       accept_mask = GRm_DATA;
       ex$message(msgnumb = NM_P_IdSfToAddMvOnToGlue, buff = locate_prompt)

      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ALL_WINDOWS             |       /* Hilite in all windows */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        IGN_PLANAR_BIT 		|       /* Ignore planar checks */
        LC_WRITE_ONLY;                  /* I'm going to change this guy */

       attributes.owner_action = 
        LC_ASSOCIATIVE     	|       /* Associative elements */
        LC_EXTERN_CONSTRAINED 	|   /* Externally constrained assoc elements */
        LC_RIGID_OWNER     |       /* Composites */
        LC_FLEX_OWNER      |       /* Graphic groups, etc. */	
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |                /* We want the surface itself */
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 2;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsurface_class_id;
       e_classes[1] = OPP_NMnonmani_class_id;

       {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler already_located;

       already_located.next = NULL;
       already_located.option = 0;
       already_located.type = 1; /* Specifying GRid 's */
       already_located.num_objects = me->num_gluesf;
       already_located.objects.id = ME.NMcrtbnd->glue_sf;

       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_prompt =        locate_prompt, 
         acc_key =              NM_P_AccWithSfToAdd,
         relocate_key =         EMS_I_00011,  /* surface not found */
         attributes =           &attributes,
         act_handler = 		EFlocate_action_handler,
         act_args = 		&already_located,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);

       ERROR(sts, object_was_located, "lc$locate error")
       }
      }

      if (!object_was_located)
       {
        if (ME.NMcrtbnd->locate_event.response == EX_BACK_UP)
         {
           info = &me->sf[0];
	   DisplayMode = GRhe;
           sts = om$send(
                      msg = message GRgraphics.GRdisplay(
                      &msg,
                      &info->module_info.md_env.matrix_type,
                      info->module_info.md_env.matrix, 
                      &DisplayMode,
                      &me->ModuleInfo.md_id),
                      targetid = me->glue_sf[me->num_gluesf - 1].objid,
                      targetos = me->glue_sf[me->num_gluesf - 1].osnum);
           ERROR(sts, msg, "GRdisplay error")
	  ME.NMcrtbnd->num_gluesf--;
	
          if(!me->num_gluesf)
           {
            ME.NMcrtbnd->totalcvs = 0;
            ME.NMcrtbnd->numsf = ME.NMcrtbnd->num_gluesf = 0;
            ME.NMcrtbnd->glue_set_shown = FALSE;
            ME.super_cmd->state = BEGIN_STATE;
            break;
           }
          else
           break;
         }	
        else if (ME.NMcrtbnd->locate_event.response == EX_RJT_MOVEON)
	 ME.super_cmd->state = GLUE_SURFACES;
	else return(OM_S_SUCCESS);
       }
      else
       {
        OMuint  vla_size;

        /*
         * Check if enough space is available to save surface.
         */
        vla_size = om$dimension_of (varray = ME.NMcrtbnd->glue_sf);
        if ((ME.NMcrtbnd->num_gluesf + 2)  > vla_size)
         {
          sts = om$vla_set_dimension (varray = ME.NMcrtbnd->glue_sf,
                                          size = vla_size + INCREMENT);
          ERROR (sts, 1, "vla_set_dimension");
         }
        ME.NMcrtbnd->glue_sf[ME.NMcrtbnd->num_gluesf++] = 
             accept_event.located_object[0].located_obj;
        DisplayMode = GRhd;
        info = &me->sf[0];
        sts = om$send(
                      msg = message GRgraphics.GRdisplay(
                      &msg,
                      &info->module_info.md_env.matrix_type,
                      info->module_info.md_env.matrix, 
                      &DisplayMode,
                      &me->ModuleInfo.md_id),
                      targetid = me->glue_sf[me->num_gluesf - 1].objid,
                      targetos = me->glue_sf[me->num_gluesf - 1].osnum);
        ERROR(sts, msg, "GRdisplay error")

	/*
 	 * Put the accept event on the queue
         */
        putque_size = sizeof(accept_event.event) + sizeof (IGRint) ;
        sts = ex$putque(msg = &msg, response = response,
                        byte = &putque_size, 
                        buffer = (IGRchar *) &accept_event.event);
        ERROR(sts, msg, "ex$putque error")

       } /* ELSE FOR if (!object_was_located) */

     break;


     case GLUE_SURFACES:
      {
       IGRushort makecs_opt = NULL;

       sts = dp$erase_hilite(msg = &msg);
       ERROR(sts, msg, "dp$erase_hilite error")

       construct_list.msg = &msg;
       construct_list.env_info = &ME.CObuild->ModuleInfo;
       construct_list.newflag = FALSE;
       construct_list.geometry = NULL;
       construct_list.class_attr = NULL;
       construct_list.level = ME.CObuild->ActiveLevel;
       construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
       construct_list.display = &ME.CObuild->ActiveDisplay;
       construct_list.name = NULL;

       me->construct_id.osnum = me->glue_sf[0].osnum;
       sts = om$construct(classid = OPP_NMnonmanist_class_id,
                          p_objid = &me->construct_id.objid,
                          osnum = me->construct_id.osnum);
       ERROR(sts, EMS_S_Success, "NMcrtbnd - NMnonmanist construct");

       makecs_opt = NULL;

       ex$message(msgnumb = EMS_P_00000)
       ex$message(msgnumb = EMS_I_Processing, buff = status_str);

       sts = om$send(msg = message NMnonmanist.NMperform_stitch(&msg, 
             me->num_gluesf, me->glue_sf, &me->sf[0].module_info, NULL, 0, 
	     NULL, NULL, makecs_opt, NULL, &construct_list, status_str),
             targetid = me->construct_id.objid,
             targetos = me->construct_id.osnum);

      if( (msg == EMS_E_NoDynamicMemory) || 
          (msg == EMS_E_DynamicMemoryAllocated))
       {
        ex$message(msgnumb = EMS_E_NoMemFewElem);
        msg = EMS_S_Success;
        sts = OM_S_SUCCESS;
        ME.NMcrtbnd->totalcvs = 0;
        ME.NMcrtbnd->numsf = ME.NMcrtbnd->num_gluesf = 0;
        ME.NMcrtbnd->glue_set_shown = FALSE;
        ME.super_cmd->state = BEGIN_STATE;
       }
      else
       {
        ERROR(sts, msg, "NMcrtbnd perform_stitch");
      
        if (msg == EMS_I_Fail)
         {
          OM_S_CHANSELECT       to_comps;  /*DECL*/
	  OMuint count = 0;
	
          ex$message(msgnumb = NM_I_EdgesNotGlued)
	
          sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
          ERROR(sts, EMS_S_Success, "NMcrtbnd mk chan sel");

          sts = om$get_channel_count(objid = me->construct_id.objid,
                                   osnum = me->construct_id.osnum,
                                   p_chanselect = &to_comps,
                                   count = &count);
          ERROR(sts, EMS_S_Success, "NMcrtbnd get chan count");

          if (!count)
           {
            /*Delete composite object.*/
            sts = om$send(msg = message Root.delete(0),
                        targetos = me->construct_id.osnum,
                        targetid = me->construct_id.objid);
            ERROR(sts, msg, "NMcrtbnd stch rt del");
           }
         }
        else  /*It worked.*/
         { 
          if(msg == EMS_I_Interrupt)
           {
            ex$message(msgnumb = EMS_I_ProcessingInterrupt);
            sleep(3);
           }
          ex$message(msgnumb = NM_I_EdgesGlued) 

         }  /* Comp surf made */

        } /* else for no dynamic memory */

       ME.NMcrtbnd->totalcvs = 0;
       ME.NMcrtbnd->numsf = ME.NMcrtbnd->num_gluesf = 0;
       ME.NMcrtbnd->glue_set_shown = FALSE;
       ME.super_cmd->state = BEGIN_STATE;

      }
     break;


/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
}


from GRgraphics import GRlnproject;

#define PROJECT_FIX_MADE_IT_INTO EMS 0

#if PROJECT_FIX_MADE_IT_INTO_EMS
#else

#include "EMSopt.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "EMSprop.h"

from EMSsubbs import EMpartolbasis;
from EMSloopset import EMget_props, EMpt_location;

#endif

#argsused

IGRint NMptdynamics(dynargs, cursor, view_matrix, objects, num_objects, 
		    buffers, num_buffers, in_dummy1, in_dummy2, in_dummy3,
		    out_dummy1, out_dummy2, out_dummy3)
		
struct dynfunc_args	*dynargs;
struct EX_button	*cursor;
IGRdouble		*view_matrix;
struct GRid		**objects;
IGRint			*num_objects;
struct DPele_header	**buffers;
IGRint			*num_buffers;
IGRchar			*in_dummy1;
IGRchar               	*in_dummy2;
IGRchar               	*in_dummy3;
IGRchar              	**out_dummy1;
IGRchar              	**out_dummy2;
IGRchar              	**out_dummy3;
{
 IGRpoint 		curpt, lnpt, borept1, borept2;
 static IGRpoint	sfpt;
 IGRlong 		sts, msg;
 struct IGRline 	bore;
 IGRdouble 		lnpar;
 struct GRparms		sfpar;
 struct IGRpointset	*ptptr;
 
 curpt[0] = cursor->x;
 curpt[1] = cursor->y;
 curpt[2] = cursor->z;

 bore.point1 = borept1;
 bore.point2 = borept2;

 sts = GRbrlnconstr(&msg, curpt, view_matrix, &bore);
 if(!(1&msg&sts)) goto wrapup;

 /* Project the point on to the surface.
  * The GRlnproject for the surface uses EMpt_location for finding a point
  * in area/on edge that is closest to the input point, if the input point
  * happed to fall in a hole. But it should use the option 
  * EMS_PTLOC_CLOSEST_EDGE option when calling EMSloopset.EMpt_location to
  * achieve the correct result. Rather than requesting this fix in EMS at
  * this late point in the game, I am going to do it myself and then worry
  * about putting the fix into EMS later.
 */
#if PROJECT_FIX_MADE_IT_INTO_EMS
 sts = om$send(msg = message GRgraphics.GRlnproject(&msg,
       &dynargs->surfenv.md_env.matrix_type,
       dynargs->surfenv.md_env.matrix,
       &bore, lnpt, sfpt, &lnpar, &sfpar), senderid = NULL_OBJID,
       targetid = dynargs->surfid.objid,
       targetos = dynargs->surfid.osnum);
 if(!(1&msg&sts)) goto wrapup;
#else
  {
   OM_S_CHANSELECT	to_ls, to_sf;
   OM_S_OBJECT_LINKAGE	lsid;
   OMuint		count;
   struct EMSpartolbasis partol;
   IGRboolean 		world = TRUE;
   struct EMSptloc_info loc;
   IGRushort    lsprops = EMLS_NATURAL;
   IGRdouble		uvpt[2];
   struct IGRbsp_surface *sfgeom = NULL;

   sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
   sts = om$get_channel_objects(objid = dynargs->surfid.objid, 
         osnum = dynargs->surfid.osnum, list = &lsid, size = 1, count = &count,
	 p_chanselect = &to_ls);
   if(!(1&sts)) goto wrapup;
   if(count)
    {
     sts = om$send(msg = message Root.wild_disconnect(to_ls), 
           targetid = dynargs->surfid.objid, senderid = NULL_OBJID, 
           targetos = dynargs->surfid.osnum);
     if(!(1&sts)) goto wrapup;
    }

   sts = om$send(msg = message GRgraphics.GRlnproject(&msg,
         &dynargs->surfenv.md_env.matrix_type,
         dynargs->surfenv.md_env.matrix,
         &bore, lnpt, sfpt, &lnpar, &sfpar), senderid = NULL_OBJID,
         targetid = dynargs->surfid.objid,
         targetos = dynargs->surfid.osnum);
   if(count)
    {
     sts = EMmake_chanselect(EMSloopset_to_surface, &to_sf);
     sts = om$send(msg = message Root.connect(to_ls, NULL, lsid.S_objid, 
	   lsid.osnum, to_sf, NULL), senderid = lsid.S_objid, 
           targetid = dynargs->surfid.objid,
           targetos = dynargs->surfid.osnum);
    }
   if(!(1&msg&sts)) goto wrapup;    
   if(!count) goto finish;

   sts = om$send(msg = message EMSloopset.EMget_props(&msg, &lsprops),
	 targetid = lsid.S_objid, targetos = lsid.osnum, 
         senderid = NULL_OBJID);
   if(!(1&msg&sts)) goto wrapup;
   if(lsprops & EMLS_NATURAL) goto finish;

   partol.mattyp = &dynargs->surfenv.md_env.matrix_type;
   partol.mat = dynargs->surfenv.md_env.matrix;
   sts = om$send(msg = message EMSsubbs.EMpartolbasis(&msg, partol.mattyp, 
	 partol.mat, &world, TRUE, &partol.tol), 
         targetid = dynargs->surfid.objid, senderid = NULL_OBJID, 
         targetos = dynargs->surfid.osnum);
   if(!(1&msg&sts)) goto wrapup;
   partol.is_valid = TRUE;
   loc.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_CLOSEST_EDGE;
   uvpt[0] = sfpar.u;
   uvpt[1] = sfpar.v;
   sts = om$send(msg = message EMSloopset.EMpt_location(&msg, uvpt, &loc, 
	 &partol), 
	 targetid = lsid.S_objid, targetos = lsid.osnum, 
         senderid = NULL_OBJID);
   if(!(1&msg&sts)) goto wrapup;

   switch(loc.location)
    {
     case EMS_L_INHOLE:
     case EMS_L_UNKNWN:
      if(!loc.num_located_edges) break;
      OM_BLOCK_MOVE(loc.edge[0].nst_pt.proj_pt, uvpt, 2 * sizeof(IGRdouble));
      sts = EMgetvggeom(&msg, partol.mattyp, partol.mat, &dynargs->surfid, 
	    &sfgeom, NULL);
      if(!(1&msg&sts)) goto wrapup;

      BSsfeval(sfgeom, uvpt[0], uvpt[1], 0, (IGRpoint *)sfpt, &msg);
      if(sfgeom) om$dealloc(ptr = sfgeom);
      sfgeom = NULL;

      if(msg != BSSUCC)
	msg = MSFAIL;
      else msg = MSSUCC;

     break;

     default:
      break;
    }

finish:
;
  }

#endif

 /* Insert the surface point into the display buffer.
 */
 ptptr = dynargs->disbuf.geometry.point_set;
 ptptr->num_points = 1;
 ptptr->points = sfpt;

 *buffers = &dynargs->disbuf;
 *num_buffers = 1;

wrapup:
if( (1&msg) && (!(1&sts))) msg = sts;
return(msg);
}

end implementation NMcrtbnd;
