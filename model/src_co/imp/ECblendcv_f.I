 

class implementation ECblendcv;

#include <stdio.h>
#include "GRtypedef.h"
#include "FI.h"
#include "exmacros.h"

#include "ecblc_for.h"

                          /*   1   ( V )  */
                          /*   4   ( X )  */
#define HDbd_CRV1_POS_BTN     11        
#define HDbd_CRV2_POS_BTN     12     
                          /*  13  text??? !!! */
#define HDbd_MOD1_BTN         14
#define HDbd_MOD4_BTN         15
                          /*  16  box cv_2  */
                          /*  17  text???   */
                          /*  18  box cv_1  */
#define HDbd_UNDOLM_BTN       19
#define HDbd_CRV1_SENS_GRP    20
#define HDbd_MODE_GRP         21
                          /*  22  text (BLEND CURVE) */
#define HDbd_MINRAD_FLD       23
                          /*  24  text */
#define HDbd_CRV1_ENDP_BTN    25
                          /*  26  text (Modify mode) */
#define HDbd_CRV2_ENDP_BTN    27
#define HDbd_CRV1_LENG_FLD    28
#define HDbd_CRV1_POINT_BTN   29 
#define HDbd_CRV2_LENG_FLD    30
#define HDbd_CRV2_POINT_BTN   31
                          /*  32  */
                          /*  33  text (Curve 1)  */
                          /*  34  text (Curve 2)  */
#define HDbd_CRV1_SENS_FLD    35
#define HDbd_CRV2_SENS_TXT    36
#define HDbd_CRV2_SENS_FLD    37
#define HDbd_CRV2_SENS_TXT    38
#define HDbd_UNDO_BTN         39
#define HDbd_DIAGNOS_BTN      40     /*  curvator diagnostics  */
                          /*  41  */
                          /*  42  box radius */
                          /*  43  text cv1 (INTERNAL)  */
                          /*  44  group ????*/
                          /*  45  text cv2 (INTERNAL)  */
                          /*  46  box cv1 internal  */ 
                          /*  47  box modify mode   */
#define HDbd_CRV1_LENG_TXT    48
                          /*  49  box cv2 internal  */       
                          /*  50  text radius  */
#define HDbd_MINRAD_GRP       51
#define HDbd_CRV2_LENG_TXT    52
#define HDbd_TOGGLE_POLY      53  
#define HDbd_CRV1_CONT_TGL    54
                          /*  55  cv1 group exi/screen */
#define HDbd_CRV1_LOW_BTN     56
#define HDbd_CRV1_MED_BTN     57
#define HDbd_CRV1_HIG_BTN     58
#define HDbd_SYMMETRIC        59
#define HDbd_CRV2_CONT_TGL    60
#define HDbd_CRV2_LOW_BTN     61
#define HDbd_CRV2_MED_BTN     62
#define HDbd_CRV2_HIG_BTN     63
                          /*  64  cv2 group exi/screen */


#define VAL_LOW   0.25
#define VAL_MED   1.0
#define VAL_HIG   4.0

#define SENSI_LOW   1
#define SENSI_MED   2
#define SENSI_HIG   3



%safe
/* static variable and default values */

static Form HDbd_status_form = NULL;

static struct HDbd_form_params blend_par;

static IGRint     chk_mode_button;
static IGRboolean crv1_pos_change,
                  crv2_pos_change;
static IGRshort   crv1_sensi_range,
                  crv2_sensi_range;
static IGRint     old_crv1_cont,
                  old_crv2_cont;
/*...static IGRdouble  HDbd_minrad;  */
%endsafe







void HDbd_cp_f_data(IGRint task, struct HDbd_form_params *HDbd_f_par)

/*
NAME
        HDbd_cp_f_data

DESCRIPTION
        This function will preset or read the the form data.
SYNOPSIS
        HDbd_cp_f_data(IGRint, struct HDbd_form_params)

PARAMETERS
   task   (IN) - if 0:  the values in the array are used to preset the form
                    1:  the form values are copied to the array.
  *HDbd_f_par (IN/OUT)  array for form values


NOTES
HISTORY
	11/15/93    HOB
*/



{
  if (task == 0)        
  {
    /*  preset form values  */
    blend_par.HDbd_crv1point  = HDbd_f_par->HDbd_crv1point;
    blend_par.HDbd_crv2point  = HDbd_f_par->HDbd_crv2point;
    blend_par.HDbd_crv1exip   = HDbd_f_par->HDbd_crv1exip;
    blend_par.HDbd_crv2exip   = HDbd_f_par->HDbd_crv2exip;
    blend_par.HDbd_crv1_cont  = HDbd_f_par->HDbd_crv1_cont;
    blend_par.HDbd_crv2_cont  = HDbd_f_par->HDbd_crv2_cont;
    blend_par.HDbd_undolm     = HDbd_f_par->HDbd_undolm;
    blend_par.HDbd_undo       = HDbd_f_par->HDbd_undo;
    blend_par.HDbd_mode       = HDbd_f_par->HDbd_mode;
    blend_par.HDbd_crv1sens   = HDbd_f_par->HDbd_crv1sens;
    blend_par.HDbd_crv2sens   = HDbd_f_par->HDbd_crv2sens;
    blend_par.HDbd_abs_ratio1 = HDbd_f_par->HDbd_abs_ratio1;
    blend_par.HDbd_abs_ratio2 = HDbd_f_par->HDbd_abs_ratio2;
    blend_par.HDbd_minrad     = HDbd_f_par->HDbd_minrad;
    blend_par.HDbd_diagnos    = HDbd_f_par->HDbd_diagnos;
    blend_par.HDbd_toggle_pol = HDbd_f_par->HDbd_toggle_pol;
    blend_par.HDbd_symmetric  = HDbd_f_par->HDbd_symmetric;
    blend_par.HDbd_accept     = FALSE;

    old_crv1_cont = HDbd_f_par->HDbd_crv1_cont;
    old_crv2_cont = HDbd_f_par->HDbd_crv2_cont;

    /*  save preset mode  */
    chk_mode_button = blend_par.HDbd_mode;

    /*  preset new position selection flag  */
    crv1_pos_change = (blend_par.HDbd_crv1exip == 4);  
    crv2_pos_change = (blend_par.HDbd_crv2exip == 4);  
 
    /*  set sensitivity values  */
    if (blend_par.HDbd_crv1sens == VAL_MED)   crv1_sensi_range = SENSI_MED;
    else
      if (blend_par.HDbd_crv1sens < VAL_MED)  crv1_sensi_range = SENSI_LOW;
      else                                    crv1_sensi_range = SENSI_HIG;

    if (blend_par.HDbd_crv2sens == VAL_MED)   crv2_sensi_range = SENSI_MED;
    else
      if (blend_par.HDbd_crv2sens < VAL_MED)  crv2_sensi_range = SENSI_LOW;
      else                                    crv2_sensi_range = SENSI_HIG;
  }

  else

  {
    /*  fill form function with actual form values  */ 
    HDbd_f_par->HDbd_crv1point  = blend_par.HDbd_crv1point;
    HDbd_f_par->HDbd_crv2point  = blend_par.HDbd_crv2point; 
    HDbd_f_par->HDbd_crv1exip   = blend_par.HDbd_crv1exip; 
    HDbd_f_par->HDbd_crv2exip   = blend_par.HDbd_crv2exip; 
    HDbd_f_par->HDbd_crv1_cont  = blend_par.HDbd_crv1_cont; 
    HDbd_f_par->HDbd_crv2_cont  = blend_par.HDbd_crv2_cont; 
    HDbd_f_par->HDbd_undolm     = blend_par.HDbd_undolm; 
    HDbd_f_par->HDbd_undo       = blend_par.HDbd_undo; 
    HDbd_f_par->HDbd_mode       = blend_par.HDbd_mode; 
    HDbd_f_par->HDbd_crv1sens   = blend_par.HDbd_crv1sens; 
    HDbd_f_par->HDbd_crv2sens   = blend_par.HDbd_crv2sens;
    HDbd_f_par->HDbd_abs_ratio1 = blend_par.HDbd_abs_ratio1;
    HDbd_f_par->HDbd_abs_ratio2 = blend_par.HDbd_abs_ratio2; 
    HDbd_f_par->HDbd_minrad     = blend_par.HDbd_minrad;
    HDbd_f_par->HDbd_diagnos    = blend_par.HDbd_diagnos;
    HDbd_f_par->HDbd_toggle_pol = blend_par.HDbd_toggle_pol;
    HDbd_f_par->HDbd_symmetric  = blend_par.HDbd_symmetric;
    HDbd_f_par->HDbd_accept     = blend_par.HDbd_accept;

    /*  modify int blend flag  */ 
    if (HDbd_f_par->HDbd_crv1exip  == 2  && crv1_pos_change) 
                                            HDbd_f_par->HDbd_crv1exip  = 3;
    if (HDbd_f_par->HDbd_crv2exip  == 2  && crv2_pos_change) 
                                            HDbd_f_par->HDbd_crv2exip  = 3;
  } 
}




void HDbd_erase_status_form(void)

/*
NAME
        void HDbd_erase_status_form(void)

DESCRIPTION
        This function will erase the Curve Blending form if it is
        created.

NOTES
HISTORY
        10/20/93    Ralf Burkhart
*/
{

    if (HDbd_status_form)

    {
        FIf_erase(HDbd_status_form);
    }
}


 void HDbd_delete_status_form(void)  

/*
NAME
        HDbd_delete_status_form

DESCRIPTION
        This function will delete the Curve Blending form if it is
        created.

NOTES
HISTORY
        10/20/93    Ralf Burkhart
*/
{

    if (HDbd_status_form)

    {
        FIf_delete(HDbd_status_form);
        HDbd_status_form = NULL;
    }
}





void HDbd_notif( int     f_label,
                 int     g_label,
                 double  value,
                 Form    fp)

/*
NAME
        HDbd_notif

DESCRIPTION
        Notification routine of Curve Blending status form.

NOTES
HISTORY
        10/20/93    Ralf Burkhart
*/

{
  IGRdouble     chk_tmp;
  IGRint        state;

  IGRlong       loc_msg;
  IGRint        response;


  /*    -----------------    */

  switch (g_label)
  {
    case FI_CANCEL:

      HDbd_delete_status_form();

      response = EX_FORM_FINISHED;
      ex$putque (msg      = &loc_msg,
                 response = &response);
      break;


    case FI_ACCEPT:

      /* get value and states */
      FIg_get_value(fp, HDbd_CRV1_SENS_FLD, &blend_par.HDbd_crv1sens);
      FIg_get_value(fp, HDbd_CRV1_LENG_FLD, &blend_par.HDbd_abs_ratio1);
      FIg_get_value(fp, HDbd_CRV1_CONT_TGL, &chk_tmp);
      blend_par.HDbd_crv1_cont = (int)chk_tmp;
      FIg_get_value(fp, HDbd_CRV1_ENDP_BTN, &chk_tmp);
      if ((int) chk_tmp) 
      {
        blend_par.HDbd_crv1exip = 0;
      }
      else
      {
        FIg_get_value(fp, HDbd_CRV1_POS_BTN, &chk_tmp);
        if ((int) chk_tmp)  blend_par.HDbd_crv1exip = 1;
        else                blend_par.HDbd_crv1exip = 2;
      }

      FIg_get_value(fp, HDbd_CRV2_SENS_FLD, &blend_par.HDbd_crv2sens);
      FIg_get_value(fp, HDbd_CRV2_LENG_FLD, &blend_par.HDbd_abs_ratio2);
      FIg_get_value(fp, HDbd_CRV2_CONT_TGL, &chk_tmp);
      blend_par.HDbd_crv2_cont = (int)chk_tmp;

      FIg_get_value(fp, HDbd_CRV2_ENDP_BTN, &chk_tmp);
      if (chk_tmp)  blend_par.HDbd_crv2exip = 0;
      else
      {
        FIg_get_value(fp, HDbd_CRV2_POS_BTN, &chk_tmp);
        if (chk_tmp)  blend_par.HDbd_crv2exip = 1;
        else          blend_par.HDbd_crv2exip = 2;
      }


      FIg_get_value(fp, HDbd_MINRAD_FLD, &blend_par.HDbd_minrad);
      FIg_get_value(fp, HDbd_UNDOLM_BTN, &chk_tmp);
      blend_par.HDbd_undolm = (int)chk_tmp;
      FIg_get_value(fp, HDbd_UNDO_BTN, &chk_tmp);
      blend_par.HDbd_undo = (int)chk_tmp;
      FIg_get_value(fp, HDbd_DIAGNOS_BTN, &chk_tmp);
      blend_par.HDbd_diagnos = (int)chk_tmp;
      FIg_get_value(fp, HDbd_TOGGLE_POLY, &chk_tmp);
      blend_par.HDbd_toggle_pol = (int)chk_tmp;
      FIg_get_value(fp, HDbd_SYMMETRIC, &chk_tmp);
      blend_par.HDbd_symmetric = (int)chk_tmp;
      blend_par.HDbd_mode = chk_mode_button;

      blend_par.HDbd_accept = TRUE;

      HDbd_delete_status_form();

      response = EX_FORM_FINISHED;
      ex$putque (msg      = &loc_msg,
                 response = &response);
      break;



    case HDbd_CRV1_LENG_FLD:      /*  curve tangent length  */
      FIg_get_value(fp, HDbd_CRV1_CONT_TGL, &chk_tmp);
      if (old_crv1_cont != chk_tmp)
                      FIg_set_value(HDbd_status_form, HDbd_CRV1_LENG_FLD, 1.0);
      if (blend_par.HDbd_symmetric)
      {
        FIg_get_value(fp, HDbd_CRV1_LENG_FLD, &chk_tmp);
        FIg_set_value(HDbd_status_form, HDbd_CRV2_LENG_FLD, chk_tmp);
      }
      break;

    case HDbd_MOD1_BTN:     /* Member of group HDbd_MODE_GRP  */
      FIg_get_state(fp, HDbd_MOD1_BTN, &state);
      if (state)
      {
         /* STATE ON */
         FIg_display(fp, HDbd_CRV1_SENS_GRP);
         FIg_erase(fp, HDbd_MINRAD_GRP);
         chk_mode_button = 1;
      }
      break;

    case HDbd_MOD4_BTN:     /* Member of group HDbd_MODE_GRP  */
      FIg_get_state(fp, HDbd_MOD4_BTN, &state);
      if (state)
      {
         /* STATE ON */
         FIg_display(fp, HDbd_MINRAD_GRP);
         chk_mode_button = 4;
      }
      break;


    case HDbd_CRV1_ENDP_BTN:
    case HDbd_CRV1_POINT_BTN:
    case HDbd_CRV1_POS_BTN: 
      crv1_pos_change = TRUE;
      break;
 

    case HDbd_CRV1_SENS_FLD:
      FIg_get_value(fp, HDbd_CRV1_SENS_FLD, &blend_par.HDbd_crv1sens);
      /*  set sensitivity values  */
      if (blend_par.HDbd_crv1sens == VAL_MED)   crv1_sensi_range = SENSI_MED;
      else
        if (blend_par.HDbd_crv1sens < VAL_MED)  crv1_sensi_range = SENSI_LOW;
        else                                    crv1_sensi_range = SENSI_HIG;
      FIg_set_state(fp, HDbd_CRV1_LOW_BTN, FALSE);
      FIg_set_state(fp, HDbd_CRV1_MED_BTN, FALSE);
      FIg_set_state(fp, HDbd_CRV1_HIG_BTN, FALSE);
      if (crv1_sensi_range == SENSI_LOW)  FIg_set_state(fp,HDbd_CRV1_LOW_BTN, TRUE); 
      if (crv1_sensi_range == SENSI_MED)  FIg_set_state(fp,HDbd_CRV1_MED_BTN, TRUE); 
      if (crv1_sensi_range == SENSI_HIG)  FIg_set_state(fp,HDbd_CRV1_HIG_BTN, TRUE); 
      break;

    case HDbd_CRV1_LOW_BTN:
      FIg_get_state(fp, HDbd_CRV1_LOW_BTN, &state);
      if (state)
      {
        blend_par.HDbd_crv1sens = VAL_LOW;
        FIg_set_value(fp, HDbd_CRV1_SENS_FLD, blend_par.HDbd_crv1sens);
        FIg_display(fp, HDbd_CRV1_SENS_FLD); 
      }
      break;

    case HDbd_CRV1_MED_BTN:
      FIg_get_state(fp, HDbd_CRV1_MED_BTN, &state);
      if (state)
      {
        blend_par.HDbd_crv1sens = VAL_MED;
        FIg_set_value(fp, HDbd_CRV1_SENS_FLD, blend_par.HDbd_crv1sens);
        FIg_display(fp, HDbd_CRV1_SENS_FLD); 
      }
      break;

    case HDbd_CRV1_HIG_BTN:
      FIg_get_state(fp, HDbd_CRV1_HIG_BTN, &state);
      if (state)
      {
        blend_par.HDbd_crv1sens = VAL_HIG;
        FIg_set_value(fp, HDbd_CRV1_SENS_FLD, blend_par.HDbd_crv1sens);
        FIg_display(fp, HDbd_CRV1_SENS_FLD); 
      }
      break;

    case HDbd_CRV1_CONT_TGL:      /*  tangency / curvature  */
      FIg_get_value(fp, HDbd_CRV1_CONT_TGL, &chk_tmp);
      if (old_crv1_cont != chk_tmp)
                      FIg_set_value(HDbd_status_form, HDbd_CRV1_LENG_FLD, 1.0);
      break;



    case HDbd_CRV2_LENG_FLD:      /*  curve tangent length  */
      FIg_get_value(fp, HDbd_CRV2_CONT_TGL, &chk_tmp);
      if (old_crv2_cont != chk_tmp)
                  FIg_set_value(HDbd_status_form, HDbd_CRV2_LENG_FLD, 1.0);
      if (blend_par.HDbd_symmetric)
      {
        FIg_get_value(fp, HDbd_CRV2_LENG_FLD, &chk_tmp);
        FIg_set_value(HDbd_status_form, HDbd_CRV1_LENG_FLD, chk_tmp);
      }
      break;

    case HDbd_CRV2_ENDP_BTN:
    case HDbd_CRV2_POINT_BTN:
    case HDbd_CRV2_POS_BTN:
      crv2_pos_change = TRUE;
      break;


    case HDbd_CRV2_SENS_FLD:
      FIg_get_value(fp, HDbd_CRV2_SENS_FLD, &blend_par.HDbd_crv2sens);
      /*  set sensitivity values  */
      if (blend_par.HDbd_crv2sens == VAL_MED)   crv2_sensi_range = SENSI_MED;
      else
        if (blend_par.HDbd_crv2sens < VAL_MED)  crv2_sensi_range = SENSI_LOW;
        else                                    crv2_sensi_range = SENSI_HIG;
      FIg_set_state(fp, HDbd_CRV2_LOW_BTN, FALSE);
      FIg_set_state(fp, HDbd_CRV2_MED_BTN, FALSE);
      FIg_set_state(fp, HDbd_CRV2_HIG_BTN, FALSE);
      if (crv2_sensi_range == SENSI_LOW)  FIg_set_state(fp,HDbd_CRV2_LOW_BTN, TRUE); 
      if (crv2_sensi_range == SENSI_MED)  FIg_set_state(fp,HDbd_CRV2_MED_BTN, TRUE); 
      if (crv2_sensi_range == SENSI_HIG)  FIg_set_state(fp,HDbd_CRV2_HIG_BTN, TRUE); 
      break;

    case HDbd_CRV2_LOW_BTN:
      FIg_get_state(fp, HDbd_CRV2_LOW_BTN, &state);
      if (state)
      {
        blend_par.HDbd_crv2sens = VAL_LOW;
        FIg_set_value(fp, HDbd_CRV2_SENS_FLD, blend_par.HDbd_crv2sens);
        FIg_display(fp, HDbd_CRV2_SENS_FLD); 
      }
      break;

    case HDbd_CRV2_MED_BTN:
      FIg_get_state(fp, HDbd_CRV2_MED_BTN, &state);
      if (state)
      {
        blend_par.HDbd_crv2sens = VAL_MED;
        FIg_set_value(fp, HDbd_CRV2_SENS_FLD, blend_par.HDbd_crv2sens);
        FIg_display(fp, HDbd_CRV2_SENS_FLD); 
      }
      break;

    case HDbd_CRV2_HIG_BTN:
      FIg_get_state(fp, HDbd_CRV2_HIG_BTN, &state);
      if (state)
      {
        blend_par.HDbd_crv2sens = VAL_HIG;
        FIg_set_value(fp, HDbd_CRV2_SENS_FLD, blend_par.HDbd_crv2sens);
        FIg_display(fp, HDbd_CRV2_SENS_FLD); 
      }
      break;

    case HDbd_CRV2_CONT_TGL:      /*  tangency / curvature  */
      FIg_get_value(fp, HDbd_CRV2_CONT_TGL, &chk_tmp);
      if (old_crv2_cont != chk_tmp)
                      FIg_set_value(HDbd_status_form, HDbd_CRV2_LENG_FLD, 1.0);
      break;

    case HDbd_SYMMETRIC:
      FIg_get_value(fp, HDbd_SYMMETRIC, &chk_tmp);
      blend_par.HDbd_symmetric = (int)chk_tmp;
      if (blend_par.HDbd_symmetric)
      {
        FIg_get_value(fp, HDbd_CRV1_LENG_FLD, &chk_tmp);
        FIg_set_value(HDbd_status_form, HDbd_CRV2_LENG_FLD, chk_tmp);
      }
      break;

  }      /* END switch ( g_label ) */

}        /* END notification_routine() */





int HDbd_display_status_form ( IGRboolean create )

/*
NAME
        HDbd_display_status_form

DESCRIPTION
        This function will create the Curve Blending status form if it doesn't exit.
	Then display the form.
SYNOPSIS
        HDbd_display_status_form(void)

PARAMETERS
   create (IN) - if TRUE, create and display form; if FALSE, only
                 display if form already exists
RETURN VALUES
        TRUE -- Successful, 
        FALSE -- Failed in creating the form.
NOTES
HISTORY
	10/20/93    Ralf Burkhart (borrowed from DPvd_display_status_form of T.Wang)
*/

{
    IGRint status;
    int display_status;

    /* Create if not exist */
    if (HDbd_status_form == NULL)
    {
        if (!create)  return(TRUE);
	/* Create the form */
        status = FIf_new(100, "EMBlendCurve", HDbd_notif, &HDbd_status_form);
	if (status != FI_SUCCESS)  return(FALSE);
    }


    /* Assign initial values */

    FIg_set_value(HDbd_status_form, HDbd_MINRAD_FLD, blend_par.HDbd_minrad);

    FIg_set_state(HDbd_status_form, HDbd_CRV1_CONT_TGL, blend_par.HDbd_crv1_cont);
    FIg_set_value(HDbd_status_form, HDbd_CRV1_LENG_FLD, blend_par.HDbd_abs_ratio1);

    FIg_set_value(HDbd_status_form, HDbd_CRV1_SENS_FLD, blend_par.HDbd_crv1sens);
    FIg_set_state(HDbd_status_form, HDbd_CRV1_LOW_BTN, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_CRV1_MED_BTN, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_CRV1_HIG_BTN, FALSE);
    if (crv1_sensi_range == SENSI_LOW)  FIg_set_state(HDbd_status_form,HDbd_CRV1_LOW_BTN, TRUE); 
    if (crv1_sensi_range == SENSI_MED)  FIg_set_state(HDbd_status_form,HDbd_CRV1_MED_BTN, TRUE); 
    if (crv1_sensi_range == SENSI_HIG)  FIg_set_state(HDbd_status_form,HDbd_CRV1_HIG_BTN, TRUE);
    FIg_set_state(HDbd_status_form, HDbd_CRV1_ENDP_BTN, !blend_par.HDbd_crv1exip);
    FIg_set_state(HDbd_status_form, HDbd_CRV1_POS_BTN,   blend_par.HDbd_crv1exip==1);
    FIg_set_state(HDbd_status_form, HDbd_CRV1_POINT_BTN, blend_par.HDbd_crv1exip>1);
    

    FIg_set_state(HDbd_status_form, HDbd_CRV2_CONT_TGL, blend_par.HDbd_crv2_cont);
    FIg_set_value(HDbd_status_form, HDbd_CRV2_LENG_FLD, blend_par.HDbd_abs_ratio2);

    FIg_set_value(HDbd_status_form, HDbd_CRV2_SENS_FLD, blend_par.HDbd_crv2sens);
    FIg_set_state(HDbd_status_form, HDbd_CRV2_LOW_BTN, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_CRV2_MED_BTN, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_CRV2_HIG_BTN, FALSE);
    if (crv2_sensi_range == SENSI_LOW)  FIg_set_state(HDbd_status_form,HDbd_CRV2_LOW_BTN, TRUE); 
    if (crv2_sensi_range == SENSI_MED)  FIg_set_state(HDbd_status_form,HDbd_CRV2_MED_BTN, TRUE); 
    if (crv2_sensi_range == SENSI_HIG)  FIg_set_state(HDbd_status_form,HDbd_CRV2_HIG_BTN, TRUE);

    FIg_set_state(HDbd_status_form, HDbd_CRV2_ENDP_BTN, !blend_par.HDbd_crv2exip);
    FIg_set_state(HDbd_status_form, HDbd_CRV2_POS_BTN,   blend_par.HDbd_crv2exip==1);
    FIg_set_state(HDbd_status_form, HDbd_CRV2_POINT_BTN, blend_par.HDbd_crv2exip>1);
    

    /*  set last used mode button  */
    FIg_set_state(HDbd_status_form, HDbd_MOD1_BTN, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_MOD4_BTN, FALSE);
    if (blend_par.HDbd_mode==1)  FIg_set_state(HDbd_status_form, HDbd_MOD1_BTN, TRUE);
    if (blend_par.HDbd_mode==4)  FIg_set_state(HDbd_status_form, HDbd_MOD4_BTN, TRUE);

    /*  dont display undo buttons yet  */
    FIg_erase(HDbd_status_form, HDbd_UNDOLM_BTN);
    FIg_erase(HDbd_status_form, HDbd_UNDO_BTN);

    /*  check if FORM is already displayed  */
    FIf_is_displayed(HDbd_status_form, &display_status);
    if (!display_status)
    {
      /* DISPLAY/ERASE GADGETS, dependend on some variables */
      /*  default display of minimum radius mode 4 only  */
      if (blend_par.HDbd_mode != 4)  FIg_erase(HDbd_status_form, HDbd_MINRAD_GRP);

      FIg_set_state(HDbd_status_form, HDbd_DIAGNOS_BTN, blend_par.HDbd_diagnos);
      FIg_set_state(HDbd_status_form, HDbd_TOGGLE_POLY, blend_par.HDbd_toggle_pol);
      FIg_set_state(HDbd_status_form, HDbd_SYMMETRIC, blend_par.HDbd_symmetric);

      FIf_display(HDbd_status_form);
    }

    return(TRUE);
}
   
end implementation ECblendcv;
