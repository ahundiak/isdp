/* ###################   APOGEE COMPILED   ################## */
class implementation ECmerge;

/*
DESCRIPTION
        This command object will construct a curve/surface by merging
        the located curves/surfaces together. The original curves/surfaces
        must
        have their endpoints/edges within system tolerance. There
        are two command strings for this command, they are:
           1) Merge curves
           2) Make merged curve
           3) Merge surfaces
           4) Make merged surface
        The 1st and 3rd commands will delete the parent elements if the 
        merge was successful. The other command does not delete
        the parent elements.
        The command object allows for an unlimited number of curves/surfs
        to be merged at the same time. However, if a curve/surf is found
        to be invalid (not within tolerance) then all of the curves/surfs
        must be reentered. 

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE the the command is deleted by
        the command server.

BUGS
        Note the comments in the code where external routines
        do not behave as are expected.

HISTORY
        DLB  9/08/86             Creation date.
        DLB 10/18/86             4.0 conversion.
        rlw 05/18/87             changed the way the construct takes place
        DLB 01/11/88             mod for EMS 1.1 release.
        PP  10/21/91             Make merged curve associative
	Carlos 04/09/92  	 Fix for TR92n3859. -Execute- was not 
				 returning success to the command server 
				 when the merge can not be done.
        Vadiraj 06/03/92         Modified for message subsystem compliance.
        Jack    23-Feb-93        Changed EMmerge_surfaces message send to 
                                 EFmerge_surfaces function call.  Re: analytic
                                 surface creation.
        scw  08/14/94            clarified sleep method

*/


#include "EMS.h"
#include <stdio.h>
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "bserr.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "dp.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "griodef.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" /* gr$get_active_display */
#include "exmacros.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "EC_P.h"
#include "EC_M.h"
#include "EC_I.h"
#include "EC_S.h"
#include "EMSascmacros.h"

# define MERGECV  0  /* Merge curves.*/
# define MAKE_MCV 1  /* Merge curves (delete parent curves).*/
# define MERGESF  2  /* Merge surfaces.*/
# define MAKE_MSF 3  /* Merge surfaces (delete parent curves).*/

from GRgraphics import GRdisplay, GRdelete;
from GRsubbc import EMmerge_curves;

extern IGRlong EFmerge_surfaces();

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhhd;
 IGRlong msg = EMS_S_Success;
 IGRint        sts = OM_S_SUCCESS, i;

 for (i = 0; i < me->num_located; i++)
 { 
   sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                       &me->located_obj[i].module_info.md_env.matrix_type, 
                       me->located_obj[i].module_info.md_env.matrix, 
                       &Display_Mode, 
                       &me->located_obj[i].module_info.md_id),
                 targetid = me->located_obj[i].located_obj.objid,
                 targetos = me->located_obj[i].located_obj.osnum);
   ERROR(sts, msg, "merge draw hi", wrapup);
 }

 if (me->mytype == MAKE_MCV)
 {
  extern IGRboolean EMshould_be_associative();
  /* For EMS, should always be associative!  Other applications like
   * MDS can override this functionality at runtime be overriding the
   * EMshould_be_associative() function.
   */
  if ( EMshould_be_associative() )
     gr$get_associative_flag( buffer = &me->is_associative); 
  else
     me->is_associative = FALSE;

  if (me->is_associative)
    GRdisplay_associative_button(TRUE);
 }

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint sts = OM_S_SUCCESS, msg = EMS_S_Success;

 if (me->num_located)
 {
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "merge erase hi", wrapup);
 }

 if (me->is_associative)
   GRdisplay_associative_button(FALSE);

 ex$message(msgnumb=EM_M_ClearMessageField);
 ex$message(msgnumb=EMS_S_ClearStatusField);
 ex$message(msgnumb=EMS_P_ClearPromptField);

 wrapup:
  return(sts);
}

extern OMuword OPP_GRbcsubbc_class_id, OPP_EMSgenbs_class_id,
               OPP_GRcurve_class_id, OPP_EMSsubbs_class_id;

method execute(int *response; char *response_data; int pos)
{
 IGRlong               qsize, msg;
 IGRint                sts=OM_S_SUCCESS, index;
 IGRint                token, locate_mask, accept_mask;
 IGRint                display_flag, size = sizeof(struct GRevent), i;
 struct GRid           construct_id;
 enum   GRdpmode       display_mode;
 struct GRvg_construct construct_list;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 IGRboolean            make_error = FALSE, found_same;
 OMuword               rclass, eliclass;
 IGRchar               loc_prompt[54], acc_prompt[54], reloc_prompt[54];


#define NUM_TOKENS 4
static int Tokens[NUM_TOKENS] =
{
  EX_BACK_UP, DATA, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
};

enum actions
{
  NIL, ERR, init, rem_obj, add_obj, merge, rem_all
};

#define NUM_STATES 2
enum states
{
  start, got_it
};

 /* */ static /* */ enum states NextState[NUM_STATES][NUM_TOKENS] =
 {
  /*  token:    BACK_UP  DATA    MOVEON    UNK
  old state: */             
  /* start   */{start,   start,  got_it,  start  },
  /* got_it  */{got_it,  start,  got_it,  got_it }     
 };


 /* */ static /* */ enum actions NextAction[NUM_STATES][NUM_TOKENS] =
 {
  /*  token:    BACK_UP   DATA      MOVEON    UNK
  old state: */
  /* start   */{rem_obj,  add_obj,  merge,    NIL },
  /* got_it  */{ERR,      rem_all,  ERR,      ERR }     
 };

 locate_mask = GRm_DATA | GRm_BACK_UP;

 switch (ME.super_cmd->mytype)
 {
   case MERGECV:
     ex$message(msgnumb=EM_M_MrCr); 
     break;

   case MAKE_MCV:
     ex$message(msgnumb=EM_M_PMrCr);
     break;
 
   case MERGESF:
     ex$message(msgnumb=EM_M_MrgSrfs); 
     break;

   case MAKE_MSF:
     ex$message(msgnumb=EM_M_MkMrgdSrf); 
     break;

   default:
     ERROR(OM_E_ABORT, EMS_E_Fail, "merge bad mytype", wrapup)
 }


 qsize = sizeof(me->locate_event.event) + sizeof (IGRint);


 do
 {
  switch (ME.COconst->action)
  {
   
   case NIL:
   case ERR:
   {
    break;
   }

   case init:
   {
    me->num_located = 0; 
    break;
   }

   case add_obj:
   {
    found_same = FALSE;

    for (i = 0; i < me->num_located; i++)
    {
      if (me->located_obj[i].located_obj.objid ==
          me->locate_event.located_object[0].located_obj.objid &&
          me->located_obj[i].located_obj.osnum == 
          me->locate_event.located_object[0].located_obj.osnum)
      {
        found_same = TRUE;
        break;
      }
    }

    if (found_same)
    { 
      if (ME.super_cmd->mytype == MERGECV ||
          ME.super_cmd->mytype == MAKE_MCV)
        ex$message(msgnumb=EMS_S_CrvHasBeenLoced)
      else
        ex$message(msgnumb=EMS_S_SrfHasBeenLoced);
      ems_sleep(2);
      break;
    }

    if (om$dimension_of(varray = me->located_obj) <= me->num_located)
    {
      sts = om$vla_set_dimension(varray = me->located_obj,
                                 size = me->num_located + 2);
      ERROR(sts, EMS_S_Success, "merge expand vla", wrapup);
    } 

    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->located_obj[me->num_located], 
                  sizeof(struct GRlc_info));

    /*Place accept event on the software stack for the next locate.*/
    sts = ex$putque(msg = &msg, 
                    response = response, 
                    byte = &qsize,
                    buffer = (char *) &me->locate_event.event);
    ERROR(sts, msg, "mergecv putque", wrapup)

    me->num_located++;

    break;
   }


   case rem_obj:
   {
     /* If no located objects break.*/
     if (! me->num_located) break;

     /* Dehilite the last object located.*/
     if (me->num_located == 1)
     {
       sts = dp$erase_hilite(msg = &msg);
       ERROR(sts, msg, "merge erase hi", wrapup);
     }
     else if (me->num_located > 1)
     {
       display_mode = GRhe;
       index = me->num_located-1;
       
       sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                     &me->located_obj[index].module_info.md_env.matrix_type,
                     me->located_obj[index].module_info.md_env.matrix,
                     &display_mode, 
                     &me->located_obj[index].module_info.md_id),
                    targetid = me->located_obj[index].located_obj.objid,
                    targetos = me->located_obj[index].located_obj.osnum);
       ERROR(sts, msg, "merge GRhe display", wrapup)
     }

     me->num_located--;
     break;
   }

          
   case rem_all:
   {
     /* If the command was merge rather than make merged then I delete
      * the parent objs. 
      */
     if ( (ME.super_cmd->mytype == MERGECV ||
           ME.super_cmd->mytype == MERGESF) && 
          (!make_error) )
     {
       for(i = 0; i < me->num_located; i++)
       {
         sts = om$send(msg = message GRgraphics.GRdelete(&msg,
                             &me->located_obj[i].module_info), 
                       targetid = me->located_obj[i].located_obj.objid,
                       targetos = me->located_obj[i].located_obj.osnum);
         ERROR(sts, msg, "merge delete", wrapup)
       }
     }
     me->num_located = 0;
     break;
   }

        
   case merge:
   {
     /* Dehilite the hilited objs.*/
     sts = dp$erase_hilite(msg = &msg);
     ERROR(sts, msg, "merge erase hi", wrapup);

     /*If a make error occured then don't delete parents.*/
     make_error = FALSE;

     construct_list.msg = &msg;
     construct_list.env_info = &me->located_obj[0].module_info;
     construct_list.newflag = FALSE;
     construct_list.geometry = NULL;
     construct_list.class_attr = NULL;
     construct_list.level = ME.COconst->ActiveLevel;
     construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     construct_list.display = &ME.COconst->ActiveDisplay;
     construct_list.name = NULL;
     
     /*Constructed object will be in space of first object located.*/
     construct_id.osnum = me->located_obj[0].located_obj.osnum;

     ex$message(msgnumb=EMS_I_00003);
     ex$message(msgnumb=EMS_P_ClearPromptField);  
 
     if (ME.super_cmd->mytype == MERGECV ||
         ME.super_cmd->mytype == MAKE_MCV)
     {
      if (!me->is_associative)
      {
       sts = om$construct(classid = OPP_GRbcsubbc_class_id,
                          p_objid = &construct_id.objid,
                          osnum = construct_id.osnum,
                          msg = message GRsubbc.EMmerge_curves(
                                me->num_located, me->located_obj, 
                                &construct_list, &msg));
      }
      else
      {
/****************************************************************************
        sts = EFplace_merged_curve(&msg,NULL,me->num_located,
                                   me->located_obj,
                                   &construct_list, &construct_id.objid);
****************************************************************************/
        sts = ems$place_merged_curve(msg = &msg,
                                     num_curves = me->num_located,
                                   curve_info = me->located_obj,
                                   construction_list = &construct_list,
                           resultant_obj = &construct_id.objid);
      }
     }
     else
     { 
 
       sts = EFmerge_surfaces( me->num_located, 
                               me->located_obj, 
                              &construct_list, 
                              &construct_id,
                              &msg);
 
      }

     ex$message(msgnumb=EMS_S_ClearStatusField);

     if (COERROR(msg) || COERROR(sts))
     {
       if (ME.super_cmd->mytype == MERGECV ||
           ME.super_cmd->mytype == MAKE_MCV)
         ex$message(msgnumb=EMS_I_CrvNotConstd)
       else
         ex$message(msgnumb=EMS_I_SrfNotConstd);
       make_error = TRUE;
     }
     else
     {
       /*Display merged obj.*/
       display_mode = GRbd;
       sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                        &me->located_obj[0].module_info.md_env.matrix_type, 
                        me->located_obj[0].module_info.md_env.matrix,
                        &display_mode, 
                        &me->located_obj[0].module_info.md_id),
                     targetid = construct_id.objid,
                     targetos = construct_id.osnum);
       ERROR(sts, msg, "merge display const id", wrapup)
     }
     break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "bad action", wrapup)
   }
  }

        
  switch(ME.super_cmd->state)
  {

   case start:
   {
     display_flag = 70;
     accept_mask = GRm_DATA;

     switch (ME.super_cmd->mytype)
     {
      case MERGECV:
      case MAKE_MCV:             
      {
        if (me->num_located < 1)
        {
          locate_mask = GRm_DATA | GRm_BACK_UP;
          /*strcpy(loc_prompt, ECsP_Identify_curve);*/
            ex$message(buff = loc_prompt, msgnumb = EMS_P_00030);  
        }
        else
        {
          locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
          /*strcpy(loc_prompt, ECsP_Identify_curve_move);*/
            ex$message(buff = loc_prompt, msgnumb = EMS_P_IdCvEnough);
        }
        /*strcpy(acc_prompt, ECsP_Accept_loc_next_cv_reject_elt);*/
  ex$message(buff = acc_prompt, msgnumb = EMS_P_Accept_loc_next_cv_reject_elt);
       /*strcpy(reloc_prompt, ECsP_Curve_not_found);*/
         ex$message(buff = reloc_prompt, msgnumb = EMS_I_00010);
        strcpy(attr.classes, "GRcurve");

        rclass = OPP_GRcurve_class_id;
        eliclass = OPP_GRcurve_class_id;

        break;
      }

      case MERGESF:
      case MAKE_MSF:
      {
        if (me->num_located < 2)
        {
          locate_mask = GRm_DATA | GRm_BACK_UP;
          /*strcpy(loc_prompt, ECsP_Identify_surface);*/
           ex$message(buff = loc_prompt, msgnumb = EMS_P_00031);  
        }
        else
        {
          locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
          /*strcpy(loc_prompt, ECsP_Identify_surf_move);*/
            ex$message(buff = loc_prompt, msgnumb = EMS_P_Identify_surf_move);
        }
        /*strcpy(acc_prompt, ECsP_Accept_loc_next_sf_reject_elt);*/
ex$message(buff = acc_prompt, msgnumb = EMS_P_Accept_loc_next_sf_reject_elt);
        /*strcpy(reloc_prompt, ECsP_Surf_not_found);*/
          ex$message(buff = reloc_prompt, msgnumb = EMS_I_00011);
        strcpy(attr.classes, "EMSsubbs");

        rclass = OPP_EMSsubbs_class_id;
        eliclass = OPP_EMSsubbs_class_id;

        break;
      }
     }

     switch (ME.super_cmd->mytype)
     {
      case MERGECV:
       attr.owner_action = 0x06;   /*Loc RO & FC*/
       break;
    
      case MAKE_MCV:
       attr.owner_action = 0x07;   /*Loc RO & RC & FC*/
       break;
 
      case MERGESF:
       attr.owner_action = 0x04;   /*Loc FC*/
       break;

      case MAKE_MSF:
       attr.owner_action = 0x05;   /*Loc FC & RC*/
       break;
     }

     attr.properties = LC_LC_ONLY | 
                       LC_DP_ONLY |
                       LC_RW;

     rtree_classes.w_count = 1;
     elig_classes.w_count = 1;
     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

     rtree_classes.p_classes = &rclass;
     elig_classes.p_classes = &eliclass;

     lc$locate(rc = &msg, 
               event1 = &me->locate_event, 
               event2 = &me->locate_event,
               mask1 = locate_mask, 
               mask2 = accept_mask, 
               eventsize= &size, 
               display_flag = display_flag,
               response = response, 
               response_data = response_data, 
               unhilight_mode = (enum GRdpmode) GRhhd,
               locate_prompt = loc_prompt, 
               acc_prompt = acc_prompt,
               relocate_prompt = reloc_prompt, 
               attributes = &attr, 
               stack = &me->locate_stack, 
               rtree_classes = &rtree_classes, 
               eligible_classes = &elig_classes);
 
     token = GRloc_token(&msg, Tokens, &me->locate_event);    
     break;
   }

   case got_it:
   {
     token = 1;  /*Simulate DATA event.*/
     break;
   }
        
   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "merge bad state", wrapup)
   }

  } /*switch(state) */
  
  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 sts = 1; /* It should always return success, fix for TR92n3859. */
 return sts;

 wrapup:
  *response = TERMINATE;
  return (OM_E_ABORT);

}
end implementation ECmerge;
