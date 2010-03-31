/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION
        This command object will return the radius
        of curvature of a curve or surface given a curve
        or surface, a beginning point, an ending point,
        the number of lines desired, the maximum
        length of the lines, and whether or not to save the 
	output.

ALGORITHM
	This routine begins by asking the user to identify
 	an element. There are 2 different courses of action 
	for a curve and a surface. For a surface and curve,
 	the user is asked for a beginning and ending point
	and the maximum length of lines. But, for a surface,
 	the number of lines in the u direction and the number of lines
	in the v direction is asked for. A isoparametric curve is display
        to show the user which one is the u and which one is the v
        direction. For a curve, the user is
	just asked for the number of lines without specifying
	a direction. To implement this, some actions depend
	on the element type. Also, if a moveon is given for the
	second point, the number of lines is set to 1 (for surfaces
	and curves) and a moveon flag is past to the graphics 
	method to indicate that the second point and the direction
	point (for surfaces only) need not be checked.

BUGS
	See the comments in the program for places where a
	called function doesn't behave as expected.

HISTORY

    dfh 8/13/86: creation date
 
    dfh 8/25/86: changed program to use table driven method and 
                 savesets.
  
    dfh 8/29/86: changed program to include surfaces.

    dfh 10/08/86: added methods, another state, and display stuff.

    dfh 10/21/86: converted to OM 4.0

    rlw 01/27/87: Modified due to changes in curve method

    dhm 04/30/87: Modified due to changes in curve method

    dhm 08/20/87: changed program to call EFshort_cvt to get the units.

    dhm 01/05/88: converted to 1.1.0

    dhm 08/26/88: added code to output a graph when measuring a curve.

    rlw   11/28/88:  modified due to changes in the iso curve extract method

    dhm 12/20/88: added code to output a color display graph when
                  measuring a surface.

    dhm 2/24/89:  changed to work for reference file objects and to use the
                  active module environment for displays and constructs.

    dhm 2/28/89:  added #ifndef's for the I/DRAW product.

    rlw 03/14/89  The plot process was being forked from the current
                  directory and needed to be forked from the product
                  directory.

    rlw 03/14/89  Made the above fix more robust

    dhm 03/24/89  Check for MSINARG after EMcurvature_rlt_color_display.

    SS  08/29/89  Modified the plot to use the new format for the
                  data-file.

    rlw 09/21/89  Repaired Siki's change.

    pp  09/29/89  Modified the code to output curvature too for curves,
                  and surfaces. The actual property outputted would be
                  based on the option the user selects through the
                  status display form. The default option
                  is to output radius of curvature. Also took care of
                  properly truncating the values based on the maximum value
                  for the property which the user entered.
                  Also constructing graphic groups if property
                  values are to be output to database.
                  Changed arguments to EFshort_cvt to prevent potential
                  memory overrides.

    pp  10/09/89  Modified the callto EFshort_cvtn to incorporate scaling
                  on the active coordinate system.
    
 Inasu  05/03/90  Added fix for TR 90n0873 on peroidic curves.
Rustagi 07/06/92  Modified for message sub-system compliance.
Rustagi 17/03/93  Fix for TR 119302583.
Sudha   07/05/93  Modified for BSprototypes ansification
scw     08/14/94  clarified sleep method

Doree the method and the command object should consider the case where
the curve is closed.  In this case additional input must be requested from
the operator.  Come talk to me if this doesn't make sense.

*/

class implementation ECrdofcrv;


# include "codef.h" /* MAX_PROMPT_SIZE */
# include <stdio.h>
# include "msdef.h"     /* MS message codes */
# include "maerr.h"
# include "igrtypedef.h"
# include "igrdp.h"
# include "dpstruct.h"
# include "OMlimits.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "exdef.h"
# include "exmacros.h"  /* for ex$fork */
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "emsdef.h"
# include "emserr.h"
# include "bsparameters.h"
# include "bserr.h"
# include "ECdfh.h"
# include  "EC_M.h"
# include "EC_I.h" 
#include "bsdistncta.h"

from GRgraphics import GRlnproject, GRdisplay, GRdelete;
from GRcurve    import EMcvradcrv;
from GRvg       import GRgeomprops;
#ifndef IDRAW
  from EMSsubbs   import EMsfradcrv;
#endif


#define TRUE 1
#define FALSE 0
#define NUM_TOKENS 6
#define NUM_STATES 12

extern OMuword  OPP_GRbspline_class_id;
#ifndef IDRAW
  extern OMuword OPP_EMSsubbs_class_id;
#endif


method init(IGRint type; IGRchar *string)
{
  IGRlong	status;


  status = OM_S_SUCCESS;
  me->action = 0;
  me->form_displayed = FALSE;
  me->form_initiated = FALSE;
  me->curvature_type = RAD_OF_CRV;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message ECelement.init(type, string),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, "ECrdofcrv.init");

ret_end:
  return(status);
}

method wakeup(int pos)
{
 IGRlong sts;
 IGRlong EMmsg;
 IGRint  ret;

 sts = OM_S_SUCCESS;
 EMmsg = 1;

 sts = om$send(mode = OM_e_wrt_message,
                  msg = message ECelement.wakeup(pos),
                  targetid = my_id);
 if (!(1&sts)) return (OM_E_ABORT);

 if (me->form_displayed)
 {
    ret = FIf_display(me->form1);
    if(ret)
      return (OM_E_ABORT);
 }

 return (sts);
}

method super_cmd.sleep(int pos)
{
 IGRlong sts;
 IGRint  ret;

 sts = OM_S_SUCCESS;

 GRstatus_display_button(0);
 if (me->form_displayed)
 {
   ret = FIf_erase (me->form1);
   if (ret)
     return (OM_E_ABORT);
 }
 return(sts);
}

method execute(int *response; char *response_data; int pos)
{
 extern     IGRint  GRget_token();
 IGRint		GRloc_token();
 IGRint		size, token = 0, i, j, ptinx;
 IGRlong	sts, msg, tokmsg, EFshort_cvtn();
 IGRboolean uistat;
 IGRboolean	continue_flag, go_to_nextstate, no_value;
 IGRint		locate_mask, accept_mask, display_flag;
 IGRuint option;
 IGRchar	buffer[MAX_PROMPT_SIZE], loc_prompt[MAX_PROMPT_SIZE], ans='Z',
                acc_prompt[MAX_PROMPT_SIZE], reloc_prompt[MAX_PROMPT_SIZE],
                buff1[MAX_PROMPT_SIZE], buff2[MAX_PROMPT_SIZE];
 IGRchar    header[80];
 struct		GRevent event;
 struct		GRlc_locate attr;
 enum		GRdpmode Displaymode;
 IGRpoint	proj_pt, ln_pt;
 struct		GRparms proj_parms;
 IGRdouble	t, *upars, *vpars, *crvtr_val, *rad_val, *rad_pol;
 IGRdouble	udist, vdist;
 struct		IGRline boreline;
 IGRpoint	pt1, pt2;
 GRobjid 	*rad_obj, group_obj;
 struct		GRvg_construct construct_list;
 struct		GRparms temp_parm;
 OM_S_CLASSLIST		rtree_classes, elig_classes;
 OMuword			rclass, eliclass;
 struct EX_button   button;
 IGRlong    EMcurvature_rlt_color_display();
 struct GRmdenv_info    *obj_env;

 static int tokens[NUM_TOKENS] = 
 {
  EX_BACK_UP, DATA, VALUE, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
 };

 enum states
 {
  keyin_ln, id_ele, input_pt1, input_pt2, keyin_clines, keyin_slines1,
  keyin_slines2, color_output, input_leg_pnt, type_output, sv_output,
  process
 };

 enum actions
 {
  initialize,NIL, ERR, dehilite, sto_ln, sto_pt1, sto_pt2,
  moveon_act, sto_clines, sto_slines1, sto_slines2, sto_color, sto_button,
  sto_type, sto_ans, rmv_pt, rmv_num, compute_rad
 };

 static enum states next_state[NUM_STATES][NUM_TOKENS] =
 {
/* token:         RESET         DATA          VALUE         STRING        MOVEON         UNK  
   old state:  */

/* keyin_ln    */{keyin_ln,     keyin_ln,     id_ele,       keyin_ln,     keyin_ln,     keyin_ln},

/* id_ele      */{keyin_ln,     input_pt2,    id_ele,       id_ele,       id_ele,       id_ele},

/* input_pt1   */{id_ele,       input_pt2,    input_pt1,    input_pt1,    input_pt1,    input_pt1},

/* input_pt2   */{input_pt1,    NULL,         input_pt2,    input_pt2,    sv_output,    input_pt2},

/*keyin_clines */{input_pt2,    keyin_clines, type_output,  keyin_clines, keyin_clines,  keyin_clines},

/*keyin_slines1*/{input_pt2,    keyin_slines1,keyin_slines2,keyin_slines1,keyin_slines1,keyin_slines1},

/*keyin_slines2*/{keyin_slines1,keyin_slines2,color_output, keyin_slines2,keyin_slines2, keyin_slines2},

/* color_output*/{keyin_slines2,color_output, color_output, color_output, color_output, color_output},

/*input_leg_pnt*/{color_output, process,      input_leg_pnt,input_leg_pnt,input_leg_pnt, input_leg_pnt},

/* type_output */{keyin_clines, type_output,  sv_output,    sv_output,    type_output, type_output},

/* sv_output   */{NULL,         sv_output,    process,      process,      process,     sv_output},

/* process     */{id_ele,       process,      process,      process,      process,      process}
 };


 static enum actions next_action[NUM_STATES][NUM_TOKENS] = 
 {
/* token:        RESET        DATA        VALUE       STRING        MOVEON       UNK
   old state:*/
/* keyin_ln    */{NIL,        ERR,        sto_ln,      ERR,         ERR,         NIL},
/* id_ele      */{NIL,        sto_pt1,    ERR,         ERR,         ERR,         NIL},
/* input_pt1   */{dehilite,   sto_pt1,    ERR,         ERR,         ERR,         NIL},
/* input_pt2   */{rmv_pt,     sto_pt2,    ERR,         ERR,         moveon_act,  NIL},
/*keyin_clines */{rmv_pt,     ERR,        sto_clines,  ERR,         ERR,         NIL},
/*keyin_slines1*/{rmv_pt,     ERR,        sto_slines1, ERR,         ERR,         NIL},
/*keyin_slines2*/{rmv_num,    ERR,        sto_slines2, ERR,         ERR,         NIL},
/*color_output */{rmv_num,    ERR,        sto_color,   sto_color,  sto_color,    NIL},
/*input_leg_pnt*/{NIL,        sto_button, ERR,         ERR,         ERR,   
      NIL},
/* type_output */{NIL,        ERR,        sto_type,    sto_type,    ERR,         NIL},
/* sv_output   */{NIL,        ERR,        sto_ans,     sto_ans,     sto_ans,     NIL},
/* process     */{initialize, compute_rad,compute_rad, compute_rad, compute_rad, NIL}
 };

 /*
 static char *prompts[NUM_STATES] =
 {
   "Keyin cutoff value for property",
   ECsP_Accept_reject_stpt,
   ECsP_Input_str_pt,
   ECsP_Input_end_pt,
   ECsP_Keyin_num_lines,
   ECsP_Keyin_rad_ulines,
   ECsP_Keyin_rad_vlines,
   ECsP_Color_display,
   ECsP_Input_legend_pnt,
   ECsP_many_or_single_elt,
   ECsP_WishToSvOutput,
   ECsP_processing
 };
 */


 static char ums_prompts[NUM_STATES][256];

static IGRint mask[NUM_STATES] =
 {
/* keyin_ln      */ GRm_DIST | GRm_BACK_UP,
/* id_ele        */ NULL,
/* input_pt1     */ GRm_DATA | GRm_BACK_UP,
/* input_pt2     */ GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP,
/* keyin_clines  */ GRm_SCALAR | GRm_BACK_UP,
/* keyin_slines1 */ GRm_SCALAR | GRm_BACK_UP,
/* keyin_slines2 */ GRm_SCALAR | GRm_BACK_UP,
/* color_output  */ GRm_STRING | GRm_BACK_UP | GRm_SCALAR | GRm_RJT_MOVEON,
/* input_leg_pnt */ GRm_DATA | GRm_BACK_UP,
/* type_output   */ GRm_STRING | GRm_BACK_UP | GRm_SCALAR,
/* sv_output     */ GRm_STRING | GRm_BACK_UP | GRm_SCALAR | GRm_RJT_MOVEON,
/* process       */ NULL
 };

 no_value = FALSE;
 sts = OM_S_SUCCESS;

 ex$message( buff = ums_prompts[0],  msgnumb = EMS_P_KyInCtOffVlPr      );
 ex$message( buff = ums_prompts[1],  msgnumb = EMS_P_Accept_reject_stpt );
 ex$message( buff = ums_prompts[2],  msgnumb = EMS_P_Input_str_pt       );
 ex$message( buff = ums_prompts[3],  msgnumb = EMS_P_Input_end_pt       );
 ex$message( buff = ums_prompts[4],  msgnumb = EMS_P_Keyin_num_lines    );
 ex$message( buff = ums_prompts[5],  msgnumb = EMS_P_Keyin_rad_ulines   );
 ex$message( buff = ums_prompts[6],  msgnumb = EMS_P_Keyin_rad_vlines   );
 ex$message( buff = ums_prompts[7],  msgnumb = EMS_P_Color_display      );
 ex$message( buff = ums_prompts[8],  msgnumb = EMS_P_Input_legend_pnt   );
 ex$message( buff = ums_prompts[9],  msgnumb = EMS_P_many_or_single_elt );
 ex$message( buff = ums_prompts[10], msgnumb = EMS_P_WishToSvOutput     );
 ex$message( buff = ums_prompts[11], msgnumb = EMS_I_Processing         );


 do
 {
/* Set the object's md_env.   dhm  2/23/89  */

   obj_env = &me->elem.module_info.md_env;

/* Set the message field and initialize the forms*/

  if (ME.super_cmd->mytype == CURVE)
    ex$message(msgnumb=EM_M_MeasRadofCurve)
#ifndef IDRAW
  else 
    ex$message(msgnumb=EM_M_MeasRadofSur);
#endif

/* if located object was hilited then hilite it on a return entry */

  if (me->elem_hilit)
  {
     Displaymode = GRhd;
     sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                         &obj_env->matrix_type, obj_env->matrix,
                         &Displaymode, &me->md_env.md_id),
                   targetid = me->elem.located_obj.objid,
                   targetos = me->elem.located_obj.osnum);
    EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRdisplay");
    EMerr_hndlr(EMis_error(msg), *response, TERMINATE, ret_end);
  }

/* Initialization */

  size = sizeof(event);
  continue_flag = TRUE;
  go_to_nextstate = TRUE;
  uistat = FALSE;  

/* Case structure for action table */

  switch(me->action)
  {

   case initialize:
   {
      me->num_pts = 0;
      me->num_lines = 0;
      break;
   }


   case dehilite:
   {
      Displaymode = GRbdhe;
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &obj_env->matrix_type, obj_env->matrix,
                          &Displaymode, &me->md_env.md_id),
                    senderid = my_id,
                    targetid = me->elem.located_obj.objid,
                    targetos = me->elem.located_obj.osnum);
      EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRdisplay");
      EMerr_hndlr(EMis_error(msg), *response, TERMINATE, ret_end);

      me->elem_hilit = FALSE;
      break;

   }


   case sto_ln:
   {
      me->max_radius = event.event.value;

      if (no_value)
       {
         ex$message(msgnumb=EMS_I_00006);
         ME.super_cmd->state = keyin_ln; /* Reset to get length again */
         no_value = FALSE;
         break;
       }
      else if (me->max_radius <= 0)
       {
         ex$message(msgnumb=EMS_S_CutValPropgt0);
         ME.super_cmd->state = keyin_ln; /* Reset to get length again */
         break;
       }

      ex$message(msgnumb=EMS_S_CutofValue, buff = buffer);

      sts = EFshort_cvtn(buffer, me->max_radius, 
                ((me->mytype == CURVE) ? 4 : 0),MAX_PROMPT_SIZE);

      if ((me->curvature_type != RAD_OF_CRV) &&
          (strlen(buffer) < (MAX_PROMPT_SIZE - 5)))
       strcat(buffer,"**-1");
     
        ex$message(field=ERROR_FIELD, justification=CENTER_JUS, in_buff = buffer);

      break;
   }


   case sto_pt1:
   case sto_pt2:
   {
      boreline.point1 = pt1;
      boreline.point2 = pt2;
      sts = EFboreline(&msg, my_id, &event, &boreline);
      EMerr_hndlr(!sts || EMis_error(msg), *response, TERMINATE, ret_end);

      proj_parms.u = 5.0;  /* for tolerance for surfaces */       
      sts = om$send(msg = message GRgraphics.GRlnproject(&msg,
                          &obj_env->matrix_type, obj_env->matrix,
                          &boreline, ln_pt, proj_pt, &t, &proj_parms),
                    senderid = my_id,
                    targetid = me->elem.located_obj.objid,
                    targetos = me->elem.located_obj.osnum);
      EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRlnproject");
      EMerr_hndlr(EMis_error(msg), *response, TERMINATE, ret_end);

      event.event.button.x = proj_pt[0];
      event.event.button.y = proj_pt[1];
      event.event.button.z = proj_pt[2];

      sts = DPdrawcross(&msg, &event.event.button);
      EMerr_hndlr(!sts || EMis_error(msg), *response, TERMINATE, ret_end);

      me->prj_point[me->num_pts][0] = proj_pt[0];
      me->prj_point[me->num_pts][1] = proj_pt[1];
      me->prj_point[me->num_pts][2] = proj_pt[2];
      me->num_pts++; /* index for the prj_point array */

      if (me->action == sto_pt1)
          me->start_pt = proj_parms;
      else if (me->action == sto_pt2)
       {
  
         sts = BSdistncta(2, me->prj_point, &msg);
         
         /* Fix for TR 90n0873 for  periodic curves  */

         if (!sts) 
         {
          struct GRprops prop_info;
          
          sts = om$send(msg = message GRvg.GRgeomprops(&msg,
                          &obj_env->matrix_type, obj_env->matrix,
                          &prop_info),
                    senderid = my_id,
                    targetid = me->elem.located_obj.objid,
                    targetos = me->elem.located_obj.osnum);
          EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRgeomprops");
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, ret_end);
          
          sts = FALSE;
             if((prop_info.phy_closed) && 
                        (proj_parms.u == 0.0 || proj_parms.u == 1.0))
             {
               me->mid_pt = proj_parms;
               me->mid_pt.u = 0.5;
               sts = TRUE;
             }
          }/* Fix over */ 

         if (!sts)
          {
            ex$message(msgnumb=EMS_S_PntNtUniq);
            ME.super_cmd->state = input_pt2;  /* get end point again */
            --me->num_pts;  /* subtract one from index */
            break;
          }
         else
          {
            me->end_pt = proj_parms;

            if (ME.super_cmd->mytype == CURVE)
                ME.super_cmd->state = keyin_clines; /* next state */
            else if (ME.super_cmd->mytype == SURFACE)
               ME.super_cmd->state = keyin_slines1; /* next state */
 
         } /* end else */
       }  /* end else if */

      break;
   }  


   case moveon_act:
   {
      me->type = 'M';   /* only ouput a linestring from the point to
                           the center of curvature */

     /*
      * set number of lines equal to one
      */

      if (ME.super_cmd->mytype == CURVE)
         me->clines = 1;
      else if (ME.super_cmd->mytype == SURFACE)
       {
         me->slines[0] = 1;
         me->slines[1] = 1;
       }
      
      break;
   }


   case sto_clines:
   case sto_slines1:
   case sto_slines2:
   {
      if (no_value)
       {
         ex$message(msgnumb=EMS_I_00006);
         no_value = FALSE;
        
        if (me->action == sto_clines)
            ME.super_cmd->state = keyin_clines;
         else if (me->action == sto_slines1)
            ME.super_cmd->state = keyin_slines1;
         else
            ME.super_cmd->state = keyin_slines2;

         break;
       }
      else if (event.event.value < 1)
       {
         ex$message(msgnumb=EMS_S_MinofOneLine);

         if (me->action == sto_clines)
            ME.super_cmd->state = keyin_clines;
         else if (me->action == sto_slines1)
            ME.super_cmd->state = keyin_slines1;
         else
            ME.super_cmd->state = keyin_slines2;

         break;
       }

      if (ME.super_cmd->mytype == CURVE)   /* if curve */
        me->clines = event.event.value;
      else if (ME.super_cmd->mytype == SURFACE)   /* if surface */
       {
        me->slines[me->num_lines] = event.event.value;
        me->num_lines++; /* index for the slines array */
       }

      break;
   }  


   case sto_color:
   {
      me->type = 'Z';     /* set to Z (zero) */

      if (no_value)
      {
        no_value = FALSE;
        me->type = 'C';
        me->state = input_leg_pnt;
      }
      else if (toupper(event.event.keyin[0]) == 'Y')
      {
        me->type = 'C';
        me->state = input_leg_pnt;
      }
      else if (toupper(event.event.keyin[0]) == 'N')
        me->state = sv_output;
      else
      {
        ex$message(msgnumb= EMS_S_InvInp);
        me->state = color_output;  /* go ask question again */
      }

      break;
   }


   case sto_button:
   {
      button = event.event.button;
      break;
   }


   case sto_type:
   {
      me->type = 'Z';     /* set to Z (zero) */

      if (no_value)
       {
         ex$message(msgnumb=EMS_I_00006);
         no_value = FALSE;
         me->state = type_output;
       }
      else if (toupper(event.event.keyin[0]) == 'M')
         me->type = 'M';
      else if (toupper(event.event.keyin[0]) == 'S')
         me->type = 'S';
      else if (toupper(event.event.keyin[0]) == 'G')
      {
         me->type = 'G';
         me->state = process;
      }
      else
       {
         ex$message(msgnumb=EMS_S_InvInp);
         me->state = type_output;  /* go ask question again */
       }

      break;
   }


   case sto_ans:
   {
      ans = 'Z';     /* set to Z (zero) */

      if (no_value)
      {
         ans = 'Y';  /* default is to create objects(save output) */
         no_value = FALSE;
      }
      else if (toupper(event.event.keyin[0]) == 'N')
         ans = 'N';
      else if (toupper(event.event.keyin[0]) == 'Y')
         ans = 'Y';
      else
       {
         ex$message(msgnumb=EMS_S_InvInp);
         ME.super_cmd->state = sv_output;  /* go ask question again */
       }

      break;
   }


   case compute_rad:
   {
      GRobjid    *crv_ptr, crv_obj;
      IGRdouble  *crv_pol;
      IGRdouble  *pts, range[4];
      IGRdouble  *rads;
      IGRboolean rads_allocated = FALSE;
      IGRint     *num_pts, numpoly, numpts, ptsinx;
      IGRchar    procname[200];
      IGRchar    *cptr[4];
      FILE       *outfile;

      crvtr_val = NULL;
      rad_val = NULL;
      rad_pol = NULL;
      rad_obj = NULL;
      crv_pol = NULL;
      upars = NULL;
      vpars = NULL;
      crv_ptr = NULL;
      pts = NULL;
      num_pts = NULL;
      rads = NULL;

      construct_list.msg = &msg;
      construct_list.env_info = &me->md_env;
      construct_list.newflag = FALSE;
      construct_list.geometry = (IGRchar *) NULL;
      construct_list.class_attr = (IGRchar *) NULL;
      construct_list.level = me->active_level;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.display = &me->active_display;
      construct_list.name = NULL;

      Displaymode = GRbdhe;  /* dehilite element */
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &obj_env->matrix_type, obj_env->matrix,
                          &Displaymode, &me->md_env.md_id),
                    senderid = my_id,
                    targetid = me->elem.located_obj.objid,
                    targetos = me->elem.located_obj.osnum);
      EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRdisplay");
      EMerr_hndlr(EMis_error(msg), *response, TERMINATE, ret_end);

      me->elem_hilit = FALSE;

      if (ME.super_cmd->mytype == CURVE)
       {

         /******** Allocate storage for the arrays *********/

         rad_val = (IGRdouble *) om$malloc(size = me->clines *
                                           sizeof(IGRdouble));
         EMerr_hndlr(!rad_val, *response, TERMINATE, ret_end);

         if ((me->type == 'M') && (ans == 'N'))
          {
             rad_pol = (IGRdouble *) om$malloc(size = me->clines * 
                                       2 * sizeof(IGRpoint));
             EMerr_hndlr(!rad_pol, *response, TERMINATE, ret_end);
          }
         else if ((me->type == 'M') && (ans == 'Y'))
          {
             rad_obj = (GRobjid *) om$malloc(size = me->clines *
                        sizeof (GRobjid));
             EMerr_hndlr(!rad_obj, *response, TERMINATE, ret_end);
          }
         else if ((me->type == 'S') && (ans == 'N'))
          {
             crv_pol = (IGRdouble *) om$malloc(size = me->clines *
									   sizeof(IGRpoint));
             EMerr_hndlr(!crv_pol, *response, TERMINATE, ret_end);
          }
         else if ((me->type == 'S') && (ans == 'Y'))
             crv_ptr = &crv_obj;

        /**************** Call graphics methods ******************/

        if (me->curvature_type == RAD_OF_CRV)
        {
         sts = om$send(msg = message GRcurve.EMcvradcrv(&msg, 
                             &obj_env->matrix_type,
                             obj_env->matrix, &construct_list,
                             me->clines,
                             &me->start_pt, 
                             &me->mid_pt,
                             &me->end_pt,
                             me->max_radius, crvtr_val,
                             rad_val, rad_pol, rad_obj, crv_pol, crv_ptr),
                       senderid = my_id,
                       targetid = me->elem.located_obj.objid,
                       targetos = me->elem.located_obj.osnum);
        }
        else if (me->curvature_type == CURVATURE)
        {
         sts = om$send(msg = message GRcurve.EMcvradcrv(&msg, 
                             &obj_env->matrix_type,
                             obj_env->matrix, &construct_list,
                             me->clines,
                             &me->start_pt, 
                             &me->mid_pt,
                             &me->end_pt,
                             me->max_radius, rad_val,
                             crvtr_val, rad_pol, rad_obj, crv_pol, crv_ptr),
                       senderid = my_id,
                       targetid = me->elem.located_obj.objid,
                       targetos = me->elem.located_obj.osnum);
        }

         if (msg == MSINARG)
          {
            ex$message(msgnumb=EMS_I_LinearElmentNotSupported);
            uistat = TRUE;
            if (rad_val) om$dealloc(ptr = rad_val);
            if (rad_pol) om$dealloc(ptr = rad_pol);
            if (rad_obj) om$dealloc(ptr = rad_obj);
            if (crv_pol) om$dealloc(ptr = crv_pol);
            token = 0; /* RESET to disconnect */
            break;
          }
         else if (EMis_error(sts) || EMis_error(msg))
          {
            om$report_error(sts = sts);
            ex$message(msgnumb=EMS_S_IntErContin);
            uistat = TRUE;
            if (rad_val) om$dealloc(ptr = rad_val);
            if (rad_pol) om$dealloc(ptr = rad_pol);
            if (rad_obj) om$dealloc(ptr = rad_obj);
            if (crv_pol) om$dealloc(ptr = crv_pol);
            token = 0; /* RESET to disconnect */
            break;
          }
         else  /* the method worked, so now display output */
          {
           if (me->curvature_type == RAD_OF_CRV)
            ex$message(msgnumb=EMS_S_RadOfCur, buff = header)
           else
            ex$message(msgnumb=EMS_S_Curvature, buff = header);

            if (me->clines == 1)
            {
               if (rad_val[0] == -1)
               {
                 strcpy(buffer,header);
                 ex$message(msgnumb=EMS_S_InfUndef, buff= buff1);
                 strcat(buffer, buff1);
                 uistat = TRUE;
               }
               else
               {
                 sts = EFshort_cvtn(header,rad_val[0], 4,80);
                 strncpy(buffer, header, MAX_PROMPT_SIZE);
                 if ((me->curvature_type != RAD_OF_CRV) &&
                    (strlen(buffer) < (MAX_PROMPT_SIZE - 5)))
                   strcat(buffer,"**-1");
                 ex$message(field=ERROR_FIELD, justification = CENTER_JUS,
                            in_buff = buffer);
                 uistat = TRUE;
               }
            }  /* end if (me->clines == 1) */

            /*
             * This code breaks the radii values up into
             * 2-d polylines for display on a graph. The
             * 2-d points contains the point number and 
             * the corresponding radii value.  dhm 8/26/88.
             */

            if (me->type == 'G')
            {
              if (me->clines > 1)
              {
                IGRdouble factor;
                IGRchar units[80];

                pts = (IGRdouble *) om$malloc(size = 2 * me->clines *
                                              sizeof(IGRdouble) );
                EMerr_hndlr(!pts, *response, TERMINATE, ret_end);

                num_pts = (IGRint *) om$malloc(size = me->clines * 
                                          sizeof(IGRint) );
                EMerr_hndlr(!num_pts, *response, TERMINATE, ret_end);

                /*
                 * Swap the radii values back if the method swapped them.
                 * dhm   1/18/89.
                 */

                if (me->start_pt.u > me->end_pt.u)
                {
                  rads = (IGRdouble *) om$malloc(size = me->clines * 
                                            sizeof(IGRdouble) );
                  EMerr_hndlr(!rads, *response, TERMINATE, ret_end);

                  for (i = 0, j = (me->clines-1); i < me->clines; i++, j--)
                     rads[i] = rad_val[j];

                  rads_allocated = TRUE;
                }
                else
                  rads = rad_val;

                ptsinx = 0;
                numpoly = 0;
                numpts = 0;
              
               {
                IGRdouble inval;

                header[0] = '\0';
                inval = 1.0;

                sts = EFshort_cvtn(header,inval,4,80);
                if (!(1&sts)) return (OM_E_ABORT);
 
                sscanf(header,"%lf%s",&factor,units);
               }

                for (i = 0; i < me->clines; i++)
                {
                  if (rads[i] != -1)
                  {
                    if (numpts == 0)  numpoly++;
                    pts[ptsinx*2] = i + 1;
                    pts[ptsinx*2+1] = rads[i]*factor;
                    ptsinx++;
                    numpts++;
                    num_pts[numpoly-1] = numpts;
                  }
                  else
                    numpts = 0;

                }  /* end for i < me->clines */

                /* 
                 * All radii were infinite. Element linear.  dhm 1/18/89
                 */

                if (numpts == 0)
                {
                  ex$message(msgnumb=EMS_I_LinearElmentNotSupported);
                  uistat = TRUE;
                  if (rad_val) om$dealloc(ptr = rad_val);
                  if (rad_pol) om$dealloc(ptr = rad_pol);
                  if (rad_obj) om$dealloc(ptr = rad_obj);
                  if (crv_pol) om$dealloc(ptr = crv_pol);
                  if (pts) om$dealloc(ptr = pts);
                  if (num_pts) om$dealloc(ptr = num_pts);
                  if (rads_allocated) om$dealloc(ptr = rads);
                  token = 0; /* RESET to disconnect */
                  break;
                }
                EM2dbx(ptsinx, pts, range);

                outfile = fopen ("/tmp/datfile", "w");
                if (!outfile)
                  {
                  ex$message(msgnumb=EMS_S_CouNtoTmpFile);
                  sleep (2);
                  *response = TERMINATE;
                  goto ret_end;
                  }
                ptinx = 0;
                for (i=0; i<numpoly; i++)
                  {
                  fprintf (outfile, "%d\n", num_pts[i]);
                  for (j=0; j<num_pts[i]; j++)
                    {
                    fprintf (outfile, "%lf %lf\n", pts[ptinx], pts[ptinx+1]);
                    ptinx += 2;
                    }
                  }
 		fprintf (outfile, "%d\n", -1);
                if (me->curvature_type == RAD_OF_CRV)
                {
                 ex$message (msgnumb = EMS_S_RadOfCur, buff = buff1);
                 fprintf (outfile, "%s\n", buff1);
                }
                else
                {
                 ex$message (msgnumb = EMS_S_Curvature, buff = buff1);
                 fprintf (outfile, "%s\n", buff1);
                }
                ex$message (msgnumb = EMS_S_Number_points, buff = buff1);
                fprintf (outfile, "%s\n", buff1);
                if (me->curvature_type == RAD_OF_CRV)
                {
                 ex$message (msgnumb = EMS_S_Radius_value, buff = buff1);
                 strcat(buff1, "-");
                 fprintf (outfile, "%s%s\n", buff1, units);
                }
                else
                {
                 strcat(units,"**-1");
                 ex$message (msgnumb = EMS_S_CurvatureValue,  buff = buff1);
                 strcat(buff1, "-");
                 fprintf (outfile, "%s%s\n", buff1,units);
                }
		fprintf (outfile, "%d %d %d %d\n", -1, -1, -1, -1);
                fclose (outfile);

                if (pts) om$dealloc(ptr = pts);
                if (num_pts) om$dealloc(ptr = num_pts);
                if (rads_allocated) om$dealloc(ptr = rads);

                /* 
                 * Find and execute the plot executable image
                 */
                {
                 extern		int access();
                 IGRlong	path_found, i;
                 IGRlong	file_absent = TRUE, not_done = TRUE;

                 for (i = 0; (i < 20) && not_done; i++)
                  {
                   path_found = ex$get_path(
                     index = i,
                     path = procname,
                     len = sizeof(procname),
                     type = EX_PRODUCT_PATH);
                    if (path_found)
                     {
                      strcat (procname, "bin/graph");
                      file_absent = access(procname, 0);
                      if (! file_absent) not_done = FALSE;
                     }
                    else
                     not_done = FALSE;
                  } /* for (i = 0; (i < 20) && not_done; i++) */
                 if (file_absent)
                  ex$message(msgnumb=EMS_E_GrphExeImNtFnd)
                 else
                  {
                   cptr[0] = procname;
		   cptr[1] = EMS_RADCRV_PLOT;
		   cptr[2] = "/tmp/datfile";
                   cptr[3] = NULL;
                   ex$fork (num_entry = 3, argu = cptr);
                  }
                }
              }  /* end if me->clines > 1 */

            }  /* end if want a graph */

            else if ((ans == 'Y') && (me->type == 'M'))
             {
              if (me->clines > 1)
              {
               EFbuild_graphic_group(me->clines,rad_obj,
               NULL,&construct_list,&group_obj,&msg);

               EMomerr_hndlr(sts, ret_end, "ECrdofcrv: EFbuild_gg");
               EMerr_hndlr(EMis_error(msg), *response, TERMINATE,
                 ret_end);
              }
              else group_obj = rad_obj[0];

               Displaymode = GRbd;
               sts = om$send(msg = message GRgraphics.GRdisplay(
                                      &msg,
                                      &me->md_env.md_env.matrix_type,
                                      me->md_env.md_env.matrix,
                                      &Displaymode, &me->md_env.md_id),
                                senderid = my_id,
                                targetid = group_obj,
                                targetos = me->md_env.md_id.osnum);
                EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRdisplay");
                EMerr_hndlr(EMis_error(msg),*response,TERMINATE,ret_end);
             } /* end if ans=='Y' && me->type == 'M' */

            else if ((ans == 'N') && (me->type == 'M'))
             {
               for (i = 0; i < me->clines; i++)
                {
                   if (rad_val[i] == -1)
                    {
                      sts = ECdisplayPointSetByBuffer(&msg,
                            me->active_display, me->md_env,
                            my_id, 1, &rad_pol[i*6], TRUE);
                      EMerr_hndlr(EMis_error(msg), *response, TERMINATE,
                      ret_end);

                    } /* end if */
                   else
                    {
                      sts = ECdisplayPointSetByBuffer(&msg,
                            me->active_display, me->md_env,
                            my_id, 2, &rad_pol[i*6], TRUE);
                      EMerr_hndlr(EMis_error(msg), *response, TERMINATE,
                      ret_end);

                    } /* end else */
                 } /* end for loop */

             } /* end else if */

            else if ((ans == 'Y') && (me->type == 'S'))
             {
                Displaymode = GRbd;
                sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                    &me->md_env.md_env.matrix_type,
                                    me->md_env.md_env.matrix,
                                    &Displaymode, &me->md_env.md_id),
	                          senderid = my_id,
                      	      targetid = crv_obj,
                              targetos = me->md_env.md_id.osnum);
                EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRdisplay");
                EMerr_hndlr(EMis_error(msg), *response, TERMINATE,ret_end);
             }

            else if ((ans == 'N') && (me->type == 'S'))
             {
                ECdisplayPointSetByBuffer(&msg, me->active_display,
 							   me->md_env, my_id, me->clines,
							   crv_pol, TRUE);
       	        EMerr_hndlr(EMis_error(msg), *response, TERMINATE,ret_end);
             }

          } /* end else method worked */

       }  /* end if CURVE */

/************************  Process a Surface ***********************/

      else if (ME.super_cmd->mytype == SURFACE)
       {
#ifndef IDRAW
         upars = (IGRdouble *) om$malloc(size = me->slines[0] *
                                       sizeof(IGRdouble));
         EMerr_hndlr(!upars, *response, TERMINATE, ret_end);

         vpars = (IGRdouble *) om$malloc(size = me->slines[1] *
                                       sizeof(IGRdouble));
         EMerr_hndlr(!vpars, *response, TERMINATE, ret_end);

/************** Computing the parameter values *************************/

         if (me->slines[0] > 1)
         {
           if (me->start_pt.u > me->end_pt.u)
           { 
             temp_parm = me->end_pt;
             me->end_pt = me->start_pt;
             me->start_pt = temp_parm;
           }

           upars[0] = me->start_pt.u;
           udist = ((me->end_pt.u - me->start_pt.u) /
                                         (me->slines[0] - 1));
           for (i = 1; i <= (me->slines[0] - 1); i++)
               upars[i] = upars[i-1] + udist;

           upars[me->slines[0]-1] = me->end_pt.u;
         }
         else
           upars[0] = me->start_pt.u;

         if (me->slines[1] > 1)
         {
           if (me->start_pt.v > me->end_pt.v)
           {
             temp_parm = me->end_pt;
             me->end_pt = me->start_pt;
             me->start_pt = temp_parm;
           }

           vpars[0] = me->start_pt.v;
           vdist = ((me->end_pt.v - me->start_pt.v) /
                                         (me->slines[1] - 1));
           for (i = 1; i <= (me->slines[1] - 1); i++)
               vpars[i] = vpars[i-1] + vdist;

           vpars[me->slines[1]-1] = me->end_pt.v;
         }
         else
           vpars[0] = me->start_pt.v;

/****************** Allocating storage for methods arrays ****************/

         rad_val = (IGRdouble *) om$malloc(size = me->slines[0] *
                                me->slines[1] * sizeof(IGRdouble));
         EMerr_hndlr(!rad_val, *response, TERMINATE, ret_end);

         if (ans == 'N')
          {
            rad_pol = (IGRdouble *) om$malloc(size = me->slines[0] *
                        me->slines[1] * 2*sizeof(IGRpoint));
            EMerr_hndlr(!rad_pol, *response, TERMINATE, ret_end);
          }
         else if (ans == 'Y')
          {
            rad_obj = (GRobjid *) om$malloc(size = me->slines[0] *
                          me->slines[1] * sizeof(GRobjid));
            EMerr_hndlr(!rad_obj, *response, TERMINATE, ret_end);
          }

/************** Call graphics method ************************************/
         switch (me->curvature_type)
         {
          case RAD_OF_CRV:
           option = 0;
           ex$message(msgnumb=EMS_S_RadOfCur, buff=header);
          break;
          case GAUSSIAN:
           option = 1;
           ex$message(msgnumb=EMS_S_GaussCur, buff=header);
          break;
          case MEAN:
           option = 2;
           ex$message(msgnumb=EMS_S_MeanCur, buff=header);
          break;
          case PRINCIPAL_MAX:
           option = 3;
           ex$message(msgnumb=EMS_S_PncpMaxCrv, buff=header);
          break;
          case PRINCIPAL_MIN:
           option = 4;
           ex$message(msgnumb=EMS_S_PncpMinCrv, buff=header);
          break;
          case ABSOLUTE:
           option = 5;
           ex$message(msgnumb=EMS_S_AbsCurvature, buff=header);
          break;
          default:
          {
            return (OM_E_ABORT);
          }
         }
         sts = om$send(msg = message EMSsubbs.EMsfradcrv(&msg, 
                             &obj_env->matrix_type, obj_env->matrix,
                             &construct_list, option,me->slines[0], upars,
                             me->slines[1], vpars, me->max_radius,
                             rad_val, rad_pol, rad_obj),
                       senderid = my_id,
                       targetid = me->elem.located_obj.objid,
                       targetos = me->elem.located_obj.osnum);

         if (msg == MSINARG)
          {
            ex$message(msgnumb=EMS_I_LinearElmentNotSupported);
            uistat = TRUE;
            if (rad_val) om$dealloc(ptr = rad_val);
            if (rad_obj) om$dealloc(ptr = rad_obj);
            if (rad_pol) om$dealloc(ptr = rad_pol);
            if (upars) om$dealloc(ptr = upars);
            if (vpars) om$dealloc(ptr = vpars);
            token = 0; /* RESET to dehilite */
            break;
          }
         else if (EMis_error(sts) || EMis_error(msg))
          {
            om$report_error(sts = sts);
            ex$message(msgnumb=EMS_S_IntErContin);
            uistat = TRUE;
            if (rad_val) om$dealloc(ptr = rad_val);
            if (rad_obj) om$dealloc(ptr = rad_obj);
            if (rad_pol) om$dealloc(ptr = rad_pol);
            if (upars) om$dealloc(ptr = upars);
            if (vpars) om$dealloc(ptr = vpars);
            token = 0; /* RESET to dehilite */
            break;
          }
         else  /* the method worked, so display the output */
          {
            if ( (me->slines[0] == 1) && (me->slines[1] == 1) )
            {
               if (rad_val[0] == -1)
               {
                 strcpy(buffer,header);
                 ex$message(msgnumb=EMS_S_IsUndefine, buff=buff2);
                 strcat (buffer,buff2);
                 ex$message(field=ERROR_FIELD, justification=CENTER_JUS,
                            in_buff=buffer);
                 uistat = TRUE;
               }
               else
               {
                 sts = EFshort_cvtn(header, rad_val[0], 0,80);
                 strncpy(buffer, header, MAX_PROMPT_SIZE);
                 if ((me->curvature_type != RAD_OF_CRV) &&
                     (strlen(buffer) < (MAX_PROMPT_SIZE - 5)))
                      strcat(buffer,"**-1");
                 ex$message(field=ERROR_FIELD, justification=CENTER_JUS,
                            in_buff=buffer);
                 uistat = TRUE;
               }
            }  /* end if (me->slines[0] == 1) && (me->slines[1] == 1) */

            if (me->type == 'C')
            {
              sts = EMcurvature_rlt_color_display(&msg,
                    &obj_env->matrix_type, obj_env->matrix,
                    me->elem.located_obj, rad_val, me->slines[0], upars,
                    me->slines[1], vpars, &button);
              EMomerr_hndlr(sts, ret_end, "ECrdofcrv: rlt color display");
              if (msg == MSINARG)
              {
                 strcpy(buffer,header);
                 ex$message(msgnumb=EMS_S_IsUndefine, buff=buff2);
                 strcat (buffer, buff2);
                 ex$message(field=ERROR_FIELD, justification=CENTER_JUS,
                            in_buff = buffer);
                 uistat = TRUE;
              }
              else if ( EMis_error(msg) )
              {
                 *response = TERMINATE;
                 goto ret_end;
              }
            }
            else if (ans == 'Y')
             {
              if (me->slines[0]*me->slines[1] > 1)
              {
               EFbuild_graphic_group(me->slines[0] * me->slines[1],rad_obj,
               NULL,&construct_list,&group_obj,&msg);

               EMomerr_hndlr(sts, ret_end, "ECrdofcrv: EFbuildgg");
               EMerr_hndlr(EMis_error(msg), *response, TERMINATE,
                 ret_end);
               }
               else group_obj = rad_obj[0];
               
               Displaymode = GRbd;
               sts = om$send(mode = OM_e_wrt_object,
                                msg = message GRgraphics.GRdisplay(&msg,
                                      &me->md_env.md_env.matrix_type,
                                      me->md_env.md_env.matrix,
                                      &Displaymode, &me->md_env.md_id),
                                senderid = my_id,
                                targetid = group_obj,
                                targetos = me->md_env.md_id.osnum);
                   EMomerr_hndlr(sts, ret_end, "ECrdofcrv: GRdisplay");
                   EMerr_hndlr(EMis_error(msg), *response, TERMINATE,
                   ret_end);

             } /* end if */
            else if (ans == 'N')
             {
               for (i = 0; i < (me->slines[0] *
                                me->slines[1]); i++)
                {
                   if (rad_val[i] == -1)
                    {
                      sts = ECdisplayPointSetByBuffer(&msg,
                            me->active_display, me->md_env,
                            my_id, 1, &rad_pol[i*6], TRUE);
                      EMerr_hndlr(EMis_error(msg), *response, TERMINATE,
                      ret_end);

                    } /* end if */
                   else
                    {
                      sts = ECdisplayPointSetByBuffer(&msg,
                            me->active_display, me->md_env,
                            my_id, 2, &rad_pol[i*6], TRUE);
                      EMerr_hndlr(EMis_error(msg), *response, TERMINATE, 
                      ret_end);

                    }
                 } /* end for loop */
             } /* end else if */
          } /* end else */
#endif
       }  /* end if SURFACE */

   /*
    *  Deallocate memory for the locally
    *  allocated variables
    */
      
      if (rad_val) om$dealloc(ptr = rad_val);
      if (rad_pol) om$dealloc(ptr = rad_pol);
      if (rad_obj) om$dealloc(ptr = rad_obj);
      if (crv_pol) om$dealloc(ptr = crv_pol);
      if (upars)   om$dealloc(ptr = upars);
      if (vpars)   om$dealloc(ptr = vpars);

      token = 0;   /* RESET to dehilite and get another element */
      break;
   }


   case NIL:
   {
      break;
   }


   case ERR:
   {
      ex$message(msgnumb=EMS_S_InvInp);
      break;
   }


   case rmv_pt:
   {
      --me->num_pts;
      break;
   }


   case rmv_num:
   {
      --me->num_lines;
      break;
   }

   default:
   {
      *response = TERMINATE;
      return(OM_E_ABORT);
   }
  }       /* end action switch */


/************ Case structure for state table *****************/


  switch(ME.super_cmd->state)
  {

   case keyin_ln:
   {

      GRstatus_display_button(1);
      ex$message(msgnumb = EMS_I_InvkStatusFrm); /* Invoke status form
                                                    to review options */
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS, 
                in_buff = ums_prompts[ME.super_cmd->state]);
      token = GRget_token(&tokmsg, tokens, &mask[ME.super_cmd->state],
              &event, &size, response, response_data);

      if (tokmsg == GRw_no_value)
       {
         no_value = TRUE;
         break;
       }
      else if (EMis_error(tokmsg))
       {
         *response = TERMINATE;
         return(OM_E_ABORT);
       }
      break;
   }


   case id_ele:
   {
      display_flag = ELEM_HILIGHT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      strcpy(acc_prompt, ums_prompts[ME.super_cmd->state]);

      attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
        LC_REF_OBJECTS |      /* locate reference objects */
        LC_NO_REF_HEADER;     /* no reference file header */

      if (ME.super_cmd->mytype == CURVE)
       {
         ex$message(msgnumb = EMS_P_00030, buff = loc_prompt);
         ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
         rclass = OPP_GRbspline_class_id;
         eliclass = OPP_GRbspline_class_id;
       }
      else if (ME.super_cmd->mytype == SURFACE)
       {
#ifndef IDRAW
         ex$message(msgnumb = EMS_P_00031, buff = loc_prompt);
         ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt);
         rclass = OPP_EMSsubbs_class_id;
         eliclass = OPP_EMSsubbs_class_id;
#endif
       }
 
      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      lc$locate(rc = &msg, 
                event1 = &event, 
                event2 = &event,
                mask1 = locate_mask, 
                mask2 = accept_mask, 
                eventsize= &size, 
                display_flag = display_flag,
                response = response, 
                response_data = response_data, 
                locate_prompt = loc_prompt, 
                acc_prompt = acc_prompt,
                relocate_prompt = reloc_prompt, 
                attributes = &attr,
                stack = &ME.ECelement->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      token = GRloc_token(&msg, tokens, &event);

      if (!EMis_error(msg))
      {
         me->elem = event.located_object[0];

/*  use what's returned in ECelement.init   dhm  2/23/89       */
/*         me->md_env = event.located_object[0].module_info;   */

         me->elem_hilit = TRUE;
      }
      else
      {
         if (event.response != EX_BACK_UP)
         {
            me->action = initialize;
            sts = OM_S_SUCCESS;
            goto ret_end;
         }
      }

      break;
   }


   case input_pt1:
   case input_pt2:
   case input_leg_pnt:
   {
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = ums_prompts[ME.super_cmd->state]);
      token = GRget_token(&tokmsg, tokens, &mask[ME.super_cmd->state],
              &event, &size, response, response_data);
      EMerr_hndlr(EMis_error(tokmsg), *response, TERMINATE, ret_end);

      break;
   }


   case keyin_clines:
   case keyin_slines1:
   case keyin_slines2:
   {
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = ums_prompts[ME.super_cmd->state]);
      if (ME.super_cmd->state != keyin_clines)
       {
#ifndef IDRAW
        extern		IGRlong EFdisplay_iso_curve_of_a_surface();
        IGRboolean	extract_u_curve;

        if (ME.super_cmd->state == keyin_slines1)
         extract_u_curve = FALSE;
        else
         extract_u_curve = TRUE;

        EFdisplay_iso_curve_of_a_surface(
          &me->elem,
          &me->active_display,
          &me->md_env,
          extract_u_curve,
          &me->start_pt.u,
          FALSE,		/* Dont' care */
          TRUE,			/* Draw, wait for input, then erase */
          my_id,
          NULL,			/* Delete curve after display */
          &msg);
         EMerr_hndlr(EMis_error(msg), *response, TERMINATE, ret_end);
#endif
       }

      token = GRget_token(&tokmsg, tokens, &mask[ME.super_cmd->state],
              &event, &size, response, response_data);

      if (tokmsg == GRw_no_value)
       {
         no_value = TRUE;
         break;
       }
      else if (EMis_error(tokmsg))
       {
         *response = TERMINATE;
         return(OM_E_ABORT);
       }

      break;
   }  


   case color_output:
   case type_output:
   {
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = ums_prompts[ME.super_cmd->state]);
      token = GRget_token(&tokmsg, tokens, &mask[ME.super_cmd->state],
              &event, &size, response, response_data);

      if ( (tokmsg == GRw_no_value) || ((me->state == color_output) &&
                                        (token == 4)) )
       {
         no_value = TRUE;
         break;
       }
      else if (EMis_error(tokmsg))
       {
         *response = TERMINATE;
         return(OM_E_ABORT);
       }

     break;
   }


   case sv_output:
   {
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                in_buff = ums_prompts[ME.super_cmd->state]);
      token = GRget_token(&tokmsg, tokens, &mask[ME.super_cmd->state],
              &event, &size, response, response_data);

      /* if no value or a moveon, take the default */

      if ( (tokmsg == GRw_no_value) || (token == 4) )
       {
         no_value = TRUE;
         break;
       }
      else if (EMis_error(tokmsg))
       {
         *response = TERMINATE;
         return(OM_E_ABORT);
       }

/* For a RESET you have three different places you could go next
   depending on your type and moveon action */

      if (token == 0)  /* 0 for RESET */
       {
         if (me->action == moveon_act)
          {
            me->action = NIL;
            ME.super_cmd->state = input_pt2;
            go_to_nextstate = FALSE;
          }
         else if (ME.super_cmd->mytype == CURVE)
          {
            me->action = NIL;
            ME.super_cmd->state = type_output;
            go_to_nextstate = FALSE;
          }
         else if (ME.super_cmd->mytype == SURFACE)
          {
            me->action = NIL;
            ME.super_cmd->state = color_output;
            go_to_nextstate = FALSE;
          }
       }

      break;
   }  

      
   case process:
   {
      ex$message(msgnumb=EMS_P_ClearPromptField);    
      if (me->action != compute_rad)
         ex$message(msgnumb=EMS_I_00003)
      else if (!uistat)
      ex$message(msgnumb=EMS_S_ClearStatusField);
      break;
   }


   default:
   {
      *response = TERMINATE;
      return(OM_E_ABORT);
   }
  }    /* end state table */

/********************* Change your state and action **********************/

  if (go_to_nextstate)
   {
     me->action = next_action[ME.super_cmd->state][token];
     ME.super_cmd->state = next_state[ME.super_cmd->state][token];
     continue_flag = (tokens[token] != GR_UNKNOWN_TYPE);
   }
  else
     continue_flag = TRUE;
 
 }    /* end do loop */
 while(continue_flag);

 ret_end:
	return(sts);
}

method delete(int defer_flag)
{
 IGRlong sts;

 sts = OM_S_SUCCESS;

  sts = om$send(mode = OM_e_wrt_ancestor,
                msg = message Root.delete(1),
                targetid = my_id);
  if (!(1&sts)) return (OM_E_ABORT);
 return (sts);
}

end implementation ECrdofcrv;
