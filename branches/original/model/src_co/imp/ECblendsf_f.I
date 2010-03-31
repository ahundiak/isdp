


class implementation ECblendsf;

#include <stdio.h>
#include "GRtypedef.h"
#include "FI.h"
#include "exmacros.h"

#include "EMSblend_sf.h"
#include "ecbls_for.h"

                          /*   1   ( V )  */ 
                          /*   4   ( X )  */
#define HDbd_SRF2_T_SENS_TEXT 12
#define HDbd_SRF1_T_SENS_TEXT 13
#define HDbd_MOD1_BTN         14
#define HDbd_MOD4_BTN         15
                          /*  16  TANGENT VALUE  (TEXT SF2)  */
                          /*  17  */
                          /*  18  Surface 1 BOX = group  */
#define HDbd_UNDOLM_BTN       19
                          /*  20  */
                          /*  21  (MODIFY MODE GROUP)  */
                          /*  22  Blend Surface (TEXT) */
#define HDbd_MINRAD_FLD       23
#define HDbd_MINRAD_TEXT      24
                          /*  25  */
                          /*  26  Modify Mode (TEXT) */
#define HDbd_SRF1_IB_V_CHK    27
#define HDbd_SRF1_IB_U_CHK    28
#define HDbd_SRF1_CRV_BTN     29
                          /*  30  */
                          /*  31  Surface 2 BOX = group  */
                          /*  32  Surface 2 (TEXT) */
#define HDbd_SRF2_IB_V_CHK    33
                          /*  34  Surface 1 (TEXT) */
                          /*  35  TANGENT DIRECTION    SRF1 (TEXT) */
#define HDbd_SRF1_IB_RUL_CHK  36
#define HDbd_SRF2_IB_U_CHK    37
#define HDbd_SRF2_CRV_BTN     38
#define HDbd_UNDO_BTN         39
#define HDbd_SRF2_TANDIR_GRP  40  /* (TANGENT DIRECTION SRF2 GROUP)  */
                          /*  41  */
#define HDbd_DIAGNOS_BTN      42  
                          /*  43  TANGENT DIRECTION    SRF2 (TEXT) */
#define HDbd_SRF2_IB_RUL_CHK  44
#define HDbd_SRF2_IB_V_S_CHK  45
#define HDbd_SRF2_IB_V_D_CHK  46
                          /*  47  Modify Mode (BOX)   */
#define HDbd_SRF1_IB_V_S_CHK  48
#define HDbd_SRF1_IB_V_D_CHK  49
                          /*  50  (RECT FORM all)  */
#define HDbd_MINRAD_GRP       51   
                          /*  52  (RECT TANGENT DIRECTION  SRF1)  */
#define HDbd_SRF1_T_SCR_CHK   53
#define HDbd_SRF1_T_AUT_CHK   54
#define HDbd_SRF1_T_SENS_FLD  55
#define HDbd_SRF1_T_COP_CHK   56
#define HDbd_SRF1_T_KEY_CHK   57
#define HDbd_SRF1_PART_CHK    58
                          /*  59  TANGENT VALUE   SRF1 (BOX)   */
#define HDbd_SRF1_TANDIR_GRP  60  /* (TANGENT DIRECTION SRF1 GROUP)  */
                          /*  61  (RECT TANGENT DIRECTION  SRF2)  */
#define HDbd_SRF2_T_SCR_CHK   62
#define HDbd_SRF2_T_AUT_CHK   63
#define HDbd_SRF2_T_SENS_FLD  64
#define HDbd_SRF2_T_COP_CHK   65
#define HDbd_SRF2_T_KEY_CHK   66
#define HDbd_SRF2_PART_CHK    67
                          /*  68  TANGENT VA:LUE   SRF2 (BOX)   */
#define HDbd_SRF2_T_KEYIN_FLD 69
#define HDbd_SRF1_T_KEYIN_FLD 70
#define HDbd_SRF_TWIST_CHK    71
                          /*  72  group  */
                          /*  73  group  */
                          /*  74  */
                          /*  75  TANGENCY SRF1 TEXT  */
                          /*  76  rect  */
                          /*  77  TANGENCY SRF2 TEXT  */
#define HDbd_SRF1_APPROX_FLD  78
                          /*  79  SRF1 Approximation Factor (TEXT) */
#define HDbd_SRF2_APPROX_FLD  80  
                          /*  81  SRF2 Approximation Factor (TEXT) */
                          /*  82  SRF1 INTERNAL (TEXT) */
#define HDbd_SRF_ORDER_FLD    83
#define HDbd_SRF_ORDER_TEXT   84
#define HDbd_SRF_POLES_FLD    85
#define HDbd_SRF_POLES_TEXT   86
                          /*  87  ORDER/POLES BOX  */
#define HDbd_SRF1_T_LOW_BUT   88
#define HDbd_SRF1_T_MED_BUT   89
#define HDbd_SRF1_T_HIG_BUT   90
#define HDbd_SRF1_SENS_B_GRP  91  /* (SRF1 SENSITIVITY BUTTON GROUP)  */
#define HDbd_SRF1_SENS_V_GRP  92  /* (SRF1 SENSITIVITY VAL GROUP)     */
#define HDbd_SRF2_T_LOW_BUT   93
#define HDbd_SRF2_T_MED_BUT   94
#define HDbd_SRF2_T_HIG_BUT   95
#define HDbd_SRF2_SENS_V_GRP  96  /* (SRF2 SENSITIVITY VAL GROUP)     */
#define HDbd_SRF2_SENS_B_GRP  97  /* (SRF2 SENSITIVITY BUTTON GROUP)  */
#define HDbd_SRF1_NAT_BTN     98
                          /*  99  SRF2 INTERNAL (TEXT) */
#define HDbd_SRF1_POS_BTN    100
#define HDbd_SRF1_INT_GRP    101  
#define HDbd_SRF2_NAT_BTN    102
                          /* 103  SRF1 INTERNAL BOX  */
#define HDbd_SRF2_POS_BTN    104
#define HDbd_SRF2_INT_GRP    105  
                          /* 106  SRF2 INTERNAL BOX  */
#define HDbd_SRF1_CRCO_TGL   107
#define HDbd_SYMMETRIC       108 
#define HDbd_SRF2_CRCO_TGL   109
#define HDbd_SRF1_IB_PER_CHK 110
#define HDbd_SRF2_IB_PER_CHK 111

                      


#define VAL_LOW   0.25
#define VAL_MED   1.0
#define VAL_HIG   4.0

#define SENSI_LOW   1
#define SENSI_MED   2 
#define SENSI_HIG   3 



/* static variable and default values */

%safe

static Form HDbd_status_form = NULL;
static struct HDbd_form_sf_p blend_par;
static IGRint chk_mode_button;
static IGRboolean srf1_pos_change,
                  srf2_pos_change;
static IGRshort   partial1_modified,
                  partial2_modified;
static IGRshort   srf1_sensi_range,
                  srf2_sensi_range;
static IGRint     old_srf1_curv_c,
                  old_srf2_curv_c;

%endsafe

/*...double HDbd_minrad;...*/





void HDbs_cp_f_data(IGRint task, struct HDbd_form_sf_p *HDbd_f_par)

/*
NAME
        HDbs_cp_f_data

DESCRIPTION
        This function will preset or read the the form data.
SYNOPSIS
        HDbs_cp_f_data(IGRint, struct HDbd_form_sf_p)

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
  
    blend_par  = *HDbd_f_par;      /*  preset form values  */
    blend_par.HDbd_accept = FALSE;

    /*  save preset mode  */
    chk_mode_button = blend_par.HDbd_mode;

    /*  correct sreen pos flag  */
    srf1_pos_change = (blend_par.HDbd_srf1.exicrv == 4);  
    srf2_pos_change = (blend_par.HDbd_srf2.exicrv == 4);  

    partial1_modified =
    partial2_modified = 0;
   
    if (blend_par.HDbd_srf1.t_sensi == VAL_MED)   srf1_sensi_range = SENSI_MED;
    else
      if (blend_par.HDbd_srf1.t_sensi < VAL_MED)  srf1_sensi_range = SENSI_LOW;
      else                                        srf1_sensi_range = SENSI_HIG;
 
    if (blend_par.HDbd_srf2.t_sensi == VAL_MED)   srf2_sensi_range = SENSI_MED;
    else
      if (blend_par.HDbd_srf2.t_sensi < VAL_MED)  srf2_sensi_range = SENSI_LOW;
      else                                        srf2_sensi_range = SENSI_HIG;
  }

  else

  {
    /*  fill form function with actual form values  */ 
    *HDbd_f_par = blend_par;      /* rewrite form values  */

    /*  modify int blend flag  */
    if (HDbd_f_par->HDbd_srf1.exicrv == 2  &&  srf1_pos_change) 
                                     HDbd_f_par->HDbd_srf1.exicrv = 3;
 
    if (HDbd_f_par->HDbd_srf2.exicrv == 2  &&  srf2_pos_change) 
                                     HDbd_f_par->HDbd_srf2.exicrv = 3;
 

    /*  correct partial modified status  */
    if (HDbd_f_par->HDbd_srf1.partial&1)
                    HDbd_f_par->HDbd_srf1.partial = 1 + 2*partial1_modified;
    else            HDbd_f_par->HDbd_srf1.partial = 0;

    if (HDbd_f_par->HDbd_srf2.partial&1)
                    HDbd_f_par->HDbd_srf2.partial = 1 + 2*partial2_modified;
    else            HDbd_f_par->HDbd_srf2.partial = 0;

     old_srf1_curv_c = HDbd_f_par->HDbd_srf1.curv_c;
     old_srf2_curv_c = HDbd_f_par->HDbd_srf2.curv_c; 
  } 
 
}




void HDbs_erase_status_form( void )

/*
NAME
        void HDbs_erase_status_form(void)

DESCRIPTION
        This function will erase the Curve Blending form if it is
        created.

NOTES
HISTORY
        10/20/93    Ralf Burkhart
*/

{
  if ( HDbd_status_form )

  {
    FIf_erase( HDbd_status_form );
  }
}


 void HDbs_delete_status_form( void )  

/*
NAME
        HDbs_delete_status_form

DESCRIPTION
        This function will delete the Curve Blending form if it is
        created.

NOTES
HISTORY
        10/20/93    Ralf Burkhart
*/
{

    if ( HDbd_status_form )

    {
        FIf_delete( HDbd_status_form );
        HDbd_status_form = NULL;
    }
}





void HDbs_notif( int     f_label,
                 int     g_label,
                 double  value,
                 Form    fp)

/*
NAME
        HDbs_notif

DESCRIPTION
        Notification routine of Curve Blending status form.

NOTES
HISTORY
        10/20/93    Ralf Burkhart
*/

{
  IGRdouble      chk_tmp;
  IGRint         min_order, max_order;
  IGRint         state, state_crv, state_nat, state_pos;
  IGRlong        loc_msg;
  IGRint         response;



  /*    -----------------    */

             value   = value;                   /*  avoid warning  */
             f_label = f_label;                 /*  avoid warning  */


  switch ( g_label )
  {

    case FI_CANCEL:
      HDbs_delete_status_form();

      response = EX_FORM_FINISHED;
      ex$putque(msg      = &loc_msg,
                response = &response);
      break;

    case FI_ACCEPT:
      /*  get value and states  */
      /*  surface independent  */
      FIg_get_value ( fp, HDbd_UNDO_BTN, &chk_tmp);
      blend_par.HDbd_undo = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_UNDOLM_BTN, &chk_tmp);
      blend_par.HDbd_undolm = (int)chk_tmp;
      blend_par.HDbd_mode = chk_mode_button;
      FIg_get_value ( fp, HDbd_DIAGNOS_BTN, &chk_tmp);
      blend_par.HDbd_diagnos = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SYMMETRIC, &chk_tmp);
      blend_par.HDbd_symmetric = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF_TWIST_CHK, &chk_tmp);
      blend_par.HDbd_srf_twist = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF_ORDER_FLD, &chk_tmp);
      blend_par.HDbd_order = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF_POLES_FLD, &chk_tmp);
      blend_par.HDbd_poles = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_MINRAD_FLD, &blend_par.HDbd_minrad);

      /*  SRF1  */

      FIg_get_value ( fp, HDbd_SRF1_T_SENS_FLD, &blend_par.HDbd_srf1.t_sensi);
      FIg_get_value ( fp, HDbd_SRF1_NAT_BTN, &chk_tmp);
      if (chk_tmp)  blend_par.HDbd_srf1.exicrv = 0;
      else
      {
        FIg_get_value ( fp, HDbd_SRF1_POS_BTN, &chk_tmp);
        if (chk_tmp)  blend_par.HDbd_srf1.exicrv = 1;
        else
        {
          FIg_get_value ( fp, HDbd_SRF1_CRV_BTN, &chk_tmp);
          if (chk_tmp)  blend_par.HDbd_srf1.exicrv = 2;
        }
      }
      FIg_get_value ( fp, HDbd_SRF1_T_AUT_CHK, &chk_tmp);
      blend_par.HDbd_srf1.t_auto = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_T_SCR_CHK, &chk_tmp);
      blend_par.HDbd_srf1.t_screen = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_T_COP_CHK, &chk_tmp);
      blend_par.HDbd_srf1.t_copy = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_T_KEY_CHK, &chk_tmp);
      blend_par.HDbd_srf1.t_keyin = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_T_KEYIN_FLD, &blend_par.HDbd_srf1.ratio);
      FIg_get_value ( fp, HDbd_SRF1_PART_CHK, &chk_tmp);
      blend_par.HDbd_srf1.partial = (int)chk_tmp;

      FIg_get_value ( fp, HDbd_SRF1_IB_U_CHK, &chk_tmp);
      blend_par.HDbd_srf1.crv_u = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_IB_V_CHK, &chk_tmp);
      blend_par.HDbd_srf1.crv_v = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_IB_RUL_CHK, &chk_tmp);
      blend_par.HDbd_srf1.crv_ruled = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_IB_V_S_CHK, &chk_tmp);
      blend_par.HDbd_srf1.crv_vec_s = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_IB_V_D_CHK, &chk_tmp);
      blend_par.HDbd_srf1.crv_vec_d = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_IB_PER_CHK, &chk_tmp);
      blend_par.HDbd_srf1.crv_perp = (int)chk_tmp;

      FIg_get_value ( fp, HDbd_SRF1_CRCO_TGL, &chk_tmp);
      blend_par.HDbd_srf1.curv_c = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF1_APPROX_FLD, &blend_par.HDbd_srf1.approx);


      /*  SRF2  */
      FIg_get_value ( fp, HDbd_SRF2_T_SENS_FLD, &blend_par.HDbd_srf2.t_sensi);
      FIg_get_value ( fp, HDbd_SRF2_NAT_BTN, &chk_tmp);
      if (chk_tmp)  blend_par.HDbd_srf2.exicrv = 0;
      else
      {
        FIg_get_value ( fp, HDbd_SRF2_POS_BTN, &chk_tmp);
        if (chk_tmp)  blend_par.HDbd_srf2.exicrv = 1;
        else
        {
          FIg_get_value ( fp, HDbd_SRF2_CRV_BTN, &chk_tmp);
          if (chk_tmp)  blend_par.HDbd_srf2.exicrv = 2;
        }
      }
      FIg_get_value ( fp, HDbd_SRF2_T_AUT_CHK, &chk_tmp);
      blend_par.HDbd_srf2.t_auto = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_T_SCR_CHK, &chk_tmp);
      blend_par.HDbd_srf2.t_screen = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_T_COP_CHK, &chk_tmp);
      blend_par.HDbd_srf2.t_copy = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_T_KEY_CHK, &chk_tmp);
      blend_par.HDbd_srf2.t_keyin = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_T_KEYIN_FLD, &blend_par.HDbd_srf2.ratio);
      FIg_get_value ( fp, HDbd_SRF2_PART_CHK, &chk_tmp);
      blend_par.HDbd_srf2.partial = (int)chk_tmp;

      FIg_get_value ( fp, HDbd_SRF2_IB_U_CHK, &chk_tmp);
      blend_par.HDbd_srf2.crv_u = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_IB_V_CHK, &chk_tmp);
      blend_par.HDbd_srf2.crv_v = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_IB_RUL_CHK, &chk_tmp);
      blend_par.HDbd_srf2.crv_ruled = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_IB_V_S_CHK, &chk_tmp);
      blend_par.HDbd_srf2.crv_vec_s = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_IB_V_D_CHK, &chk_tmp);
      blend_par.HDbd_srf2.crv_vec_d = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_IB_PER_CHK, &chk_tmp);
      blend_par.HDbd_srf2.crv_perp = (int)chk_tmp;

      FIg_get_value ( fp, HDbd_SRF2_CRCO_TGL, &chk_tmp);
      blend_par.HDbd_srf2.curv_c = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_APPROX_FLD, &blend_par.HDbd_srf2.approx);

      blend_par.HDbd_accept = TRUE;

      HDbs_delete_status_form();

      response = EX_FORM_FINISHED;
      ex$putque(msg = &loc_msg,
                response = &response);
      break;


    case HDbd_MOD1_BTN:
      FIg_get_state ( fp, HDbd_MOD1_BTN, &state );
      if (state)
      {
         FIg_display (fp, HDbd_SRF1_T_SENS_FLD); 
         FIg_display (fp, HDbd_SRF2_T_SENS_FLD); 
         FIg_erase (fp, HDbd_MINRAD_GRP);
         chk_mode_button = 1;
      }
      break;

    case HDbd_MOD4_BTN:     /* Member of group HDbd_MODE_GRP  */
      FIg_get_state(fp, HDbd_MOD4_BTN, &state);
      if (state)
      {
        FIg_display(fp, HDbd_MINRAD_GRP);
        chk_mode_button = 4;
      }
      break;

 
    case HDbd_SRF1_NAT_BTN:
    case HDbd_SRF1_POS_BTN:
    case HDbd_SRF1_CRV_BTN:
      {
        FIg_get_state (fp,HDbd_SRF1_CRV_BTN, &state);
        state_crv = state;
        FIg_get_state (fp,HDbd_SRF1_NAT_BTN, &state);
        state_nat = state;
        FIg_get_state (fp,HDbd_SRF1_POS_BTN, &state);
        state_pos = state;

        if (state_nat || state_pos)
        { 
          FIg_erase  (fp, HDbd_SRF1_TANDIR_GRP); 
          FIg_display(fp, HDbd_SRF1_PART_CHK);
        }

        if (state_crv)
        {  
          FIg_display(fp, HDbd_SRF1_TANDIR_GRP);
          FIg_erase  (fp, HDbd_SRF1_PART_CHK);
        }
        srf1_pos_change = TRUE;
      }
      break;


    /* ---  SRF1 TANGENT VALUE BLOCK  --- */ 

    case HDbd_SRF1_T_KEYIN_FLD:
      FIg_get_value ( fp, HDbd_SRF1_CRCO_TGL, &chk_tmp);
      if (old_srf1_curv_c != (int) chk_tmp)
                   FIg_set_value(HDbd_status_form, HDbd_SRF1_T_KEYIN_FLD, 1.0);
      break;

    case HDbd_SRF1_T_AUT_CHK: 
      FIg_erase(fp, HDbd_SRF1_SENS_B_GRP);
      FIg_erase(fp, HDbd_SRF1_SENS_V_GRP);
      FIg_display(fp, HDbd_SRF1_T_KEYIN_FLD);
      break;

    case HDbd_SRF1_T_SCR_CHK: 
      FIg_display(fp, HDbd_SRF1_SENS_B_GRP);
      FIg_display(fp, HDbd_SRF1_SENS_V_GRP);
      break;

    case HDbd_SRF1_T_COP_CHK: 
      FIg_erase(fp, HDbd_SRF1_SENS_B_GRP);
      FIg_erase(fp, HDbd_SRF1_SENS_V_GRP);
      FIg_display(fp, HDbd_SRF1_T_KEYIN_FLD);
      break;

    case HDbd_SRF1_T_KEY_CHK: 
      FIg_erase(fp, HDbd_SRF1_SENS_B_GRP);
      FIg_erase(fp, HDbd_SRF1_SENS_V_GRP);
      FIg_display(fp, HDbd_SRF1_T_KEYIN_FLD);
      break;

    case HDbd_SRF1_T_SENS_FLD:
      FIg_get_value ( fp, HDbd_SRF1_T_SENS_FLD, &blend_par.HDbd_srf1.t_sensi);
      if (blend_par.HDbd_srf1.t_sensi == VAL_MED)  srf1_sensi_range = SENSI_MED;
      else
        if (blend_par.HDbd_srf1.t_sensi < VAL_MED) srf1_sensi_range = SENSI_LOW;
        else                                       srf1_sensi_range = SENSI_HIG;
      FIg_set_state(fp, HDbd_SRF1_T_LOW_BUT, FALSE);
      FIg_set_state(fp, HDbd_SRF1_T_MED_BUT, FALSE);
      FIg_set_state(fp, HDbd_SRF1_T_HIG_BUT, FALSE);
      if (srf1_sensi_range == SENSI_LOW)  FIg_set_state(fp, HDbd_SRF1_T_LOW_BUT, TRUE);
      if (srf1_sensi_range == SENSI_MED)  FIg_set_state(fp, HDbd_SRF1_T_MED_BUT, TRUE);
      if (srf1_sensi_range == SENSI_HIG)  FIg_set_state(fp, HDbd_SRF1_T_HIG_BUT, TRUE);
      break;

    case HDbd_SRF1_T_LOW_BUT:
      FIg_get_state (fp,HDbd_SRF1_T_LOW_BUT, &state);
      if (state)
      {
        blend_par.HDbd_srf1.t_sensi = VAL_LOW;
        FIg_set_value(fp, HDbd_SRF1_T_SENS_FLD, blend_par.HDbd_srf1.t_sensi);
        FIg_display(fp, HDbd_SRF1_T_SENS_FLD);
      }
      break;

    case HDbd_SRF1_T_MED_BUT:
      FIg_get_state (fp,HDbd_SRF1_T_MED_BUT, &state);
      if (state)
      {
        blend_par.HDbd_srf1.t_sensi = VAL_MED;
        FIg_set_value(fp, HDbd_SRF1_T_SENS_FLD, blend_par.HDbd_srf1.t_sensi);
        FIg_display(fp, HDbd_SRF1_T_SENS_FLD);
      }
      break;

    case HDbd_SRF1_T_HIG_BUT:
      FIg_get_state (fp,HDbd_SRF1_T_HIG_BUT, &state);
      if (state)
      {
        blend_par.HDbd_srf1.t_sensi = VAL_HIG;
        FIg_set_value(fp, HDbd_SRF1_T_SENS_FLD, blend_par.HDbd_srf1.t_sensi);
        FIg_display(fp, HDbd_SRF1_T_SENS_FLD);
      }
      break;

    case HDbd_SRF1_PART_CHK:
      partial1_modified = 1;
      break;


    case HDbd_SRF2_NAT_BTN:
    case HDbd_SRF2_POS_BTN:
    case HDbd_SRF2_CRV_BTN:
      {
        FIg_get_state (fp,HDbd_SRF2_CRV_BTN, &state);
        state_crv = state;
        FIg_get_state (fp,HDbd_SRF2_NAT_BTN, &state);
        state_nat = state;
        FIg_get_state (fp,HDbd_SRF2_POS_BTN, &state);
        state_pos = state;
        if (state_nat || state_pos)
        { 
          FIg_erase  (fp, HDbd_SRF2_TANDIR_GRP); 
          FIg_display(fp, HDbd_SRF2_PART_CHK);
        }

        if (state_crv)
        {  
          FIg_display(fp, HDbd_SRF2_TANDIR_GRP);
          FIg_erase  (fp, HDbd_SRF2_PART_CHK);
        }
        srf2_pos_change = TRUE;
      }
      break;


    /* ---  SRF2 TANGENT VALUE BLOCK  --- */

    case HDbd_SRF2_T_KEYIN_FLD:
      FIg_get_value ( fp, HDbd_SRF2_CRCO_TGL, &chk_tmp);
      if (old_srf2_curv_c != (int) chk_tmp)
                  FIg_set_value(HDbd_status_form, HDbd_SRF2_T_KEYIN_FLD, 1.0);
      break;

    case HDbd_SRF2_T_AUT_CHK: 
      FIg_erase(fp, HDbd_SRF2_SENS_B_GRP);
      FIg_erase(fp, HDbd_SRF2_SENS_V_GRP);
      FIg_display(fp, HDbd_SRF2_T_KEYIN_FLD);
      break;

    case HDbd_SRF2_T_SCR_CHK: 
      FIg_display(fp, HDbd_SRF2_SENS_B_GRP);
      FIg_display(fp, HDbd_SRF2_SENS_V_GRP);
      break;

    case HDbd_SRF2_T_COP_CHK: 
      FIg_erase(fp, HDbd_SRF2_SENS_B_GRP);
      FIg_erase(fp, HDbd_SRF2_SENS_V_GRP);
      FIg_display(fp, HDbd_SRF2_T_KEYIN_FLD);
      break;

    case HDbd_SRF2_T_KEY_CHK: 
      FIg_erase(fp, HDbd_SRF2_SENS_B_GRP);
      FIg_erase(fp, HDbd_SRF2_SENS_V_GRP);
      FIg_display(fp, HDbd_SRF2_T_KEYIN_FLD);
      break;

    case HDbd_SRF2_T_SENS_FLD:
      FIg_get_value ( fp, HDbd_SRF2_T_SENS_FLD, &blend_par.HDbd_srf2.t_sensi);
      if (blend_par.HDbd_srf2.t_sensi == VAL_MED)  srf2_sensi_range = SENSI_MED;
      else
        if (blend_par.HDbd_srf2.t_sensi < VAL_MED) srf2_sensi_range = SENSI_LOW;
        else                                       srf2_sensi_range = SENSI_HIG;
      FIg_set_state(fp, HDbd_SRF2_T_LOW_BUT, FALSE);
      FIg_set_state(fp, HDbd_SRF2_T_MED_BUT, FALSE);
      FIg_set_state(fp, HDbd_SRF2_T_HIG_BUT, FALSE);
      if (srf2_sensi_range == SENSI_LOW)  FIg_set_state(fp, HDbd_SRF2_T_LOW_BUT, TRUE);
      if (srf2_sensi_range == SENSI_MED)  FIg_set_state(fp, HDbd_SRF2_T_MED_BUT, TRUE);
      if (srf2_sensi_range == SENSI_HIG)  FIg_set_state(fp, HDbd_SRF2_T_HIG_BUT, TRUE);
      break;

    case HDbd_SRF2_T_LOW_BUT:
      FIg_get_state (fp,HDbd_SRF2_T_LOW_BUT, &state);
      if (state)
      {
        blend_par.HDbd_srf2.t_sensi = VAL_LOW;
        FIg_set_value(fp, HDbd_SRF2_T_SENS_FLD, blend_par.HDbd_srf2.t_sensi);
        FIg_display(fp, HDbd_SRF2_T_SENS_FLD);
      }
      break;

    case HDbd_SRF2_T_MED_BUT:
      FIg_get_state (fp,HDbd_SRF2_T_MED_BUT, &state);
      if (state)
      {
        blend_par.HDbd_srf2.t_sensi = VAL_MED;
        FIg_set_value(fp, HDbd_SRF2_T_SENS_FLD, blend_par.HDbd_srf2.t_sensi);
        FIg_display(fp, HDbd_SRF2_T_SENS_FLD);
      }
      break;

    case HDbd_SRF2_T_HIG_BUT:
      FIg_get_state (fp,HDbd_SRF2_T_HIG_BUT, &state);
      if (state)
      {
        blend_par.HDbd_srf2.t_sensi = VAL_HIG;
        FIg_set_value(fp, HDbd_SRF2_T_SENS_FLD, blend_par.HDbd_srf2.t_sensi);
        FIg_display(fp, HDbd_SRF2_T_SENS_FLD);
      }
      break;

    case HDbd_SRF2_PART_CHK:
      partial2_modified = 1;
      break;


    case HDbd_SRF1_CRCO_TGL:
    case HDbd_SRF2_CRCO_TGL:
    case HDbd_SRF_ORDER_FLD:
      FIg_get_value ( fp, HDbd_SRF1_CRCO_TGL, &chk_tmp);
      blend_par.HDbd_srf1.curv_c = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF2_CRCO_TGL, &chk_tmp);
      blend_par.HDbd_srf2.curv_c = (int)chk_tmp;
      FIg_get_value ( fp, HDbd_SRF_ORDER_FLD, &chk_tmp);
      blend_par.HDbd_order = (int)chk_tmp;
      min_order = 3 + (blend_par.HDbd_srf1.curv_c | blend_par.HDbd_srf2.curv_c);
      max_order = 4 + blend_par.HDbd_srf1.curv_c + blend_par.HDbd_srf2.curv_c;
      if (blend_par.HDbd_order < min_order)  blend_par.HDbd_order = min_order;
      if (blend_par.HDbd_order > max_order)  blend_par.HDbd_order = max_order;
      blend_par.HDbd_poles = 4 +  2 * (  blend_par.HDbd_srf1.curv_c 
                                       | blend_par.HDbd_srf2.curv_c );
      FIg_set_value(fp, HDbd_SRF_ORDER_FLD, (IGRdouble)blend_par.HDbd_order);
      FIg_set_value(fp, HDbd_SRF_POLES_FLD, (IGRdouble)blend_par.HDbd_poles);

      if (g_label == HDbd_SRF1_CRCO_TGL)
      {
        FIg_get_value ( fp, HDbd_SRF1_CRCO_TGL, &chk_tmp);
        if (old_srf1_curv_c != (int) chk_tmp)
                  FIg_set_value(HDbd_status_form, HDbd_SRF1_T_KEYIN_FLD, 1.0);
      }

      if (g_label == HDbd_SRF2_CRCO_TGL)
      {
        FIg_get_value ( fp, HDbd_SRF2_CRCO_TGL, &chk_tmp);
        if (old_srf2_curv_c != (int) chk_tmp)
                  FIg_set_value(HDbd_status_form, HDbd_SRF2_T_KEYIN_FLD, 1.0);
      }
      break;


  }   /* END switch ( g_label ) */

}     /* END notification_routine() */





int HDbs_display_status_form ( IGRboolean create )

/*
NAME
        HDbs_display_status_form

DESCRIPTION
        This function will create the Curve Blending status form if it doesn't exit.
	Then display the form.
SYNOPSIS
        HDbs_display_status_form(void)

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
    if ( HDbd_status_form == NULL )
    {
        if ( !create )
        {
            return( TRUE );
        }

	/* Create the form */
        status = FIf_new(100, "EMBlendSurf", HDbs_notif, &HDbd_status_form); 
	if ( status != FI_SUCCESS )
	{
	    return( FALSE );
	}
    }

    /* Assign initial values */

    FIg_set_value( HDbd_status_form, HDbd_MINRAD_FLD, blend_par.HDbd_minrad);
    if (blend_par.HDbd_mode != 4 ) FIg_erase  (HDbd_status_form, HDbd_MINRAD_GRP);

    FIg_set_value(HDbd_status_form, HDbd_SRF_ORDER_FLD, (IGRdouble)blend_par.HDbd_order);
    FIg_set_value(HDbd_status_form, HDbd_SRF_POLES_FLD, (IGRdouble)blend_par.HDbd_poles);

    /*  SRF1  */

    FIg_set_state(HDbd_status_form, HDbd_SRF1_NAT_BTN, !blend_par.HDbd_srf1.exicrv);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_POS_BTN,  blend_par.HDbd_srf1.exicrv==1);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_CRV_BTN,  blend_par.HDbd_srf1.exicrv>1);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_AUT_CHK, blend_par.HDbd_srf1.t_auto);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_SCR_CHK, blend_par.HDbd_srf1.t_screen);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_COP_CHK, blend_par.HDbd_srf1.t_copy);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_KEY_CHK, blend_par.HDbd_srf1.t_keyin);

    if (blend_par.HDbd_srf1.exicrv == 0 || blend_par.HDbd_srf1.exicrv == 1)
    { 
      FIg_erase(HDbd_status_form, HDbd_SRF1_TANDIR_GRP); 
      FIg_set_state(HDbd_status_form, HDbd_SRF1_TANDIR_GRP, FALSE);
      FIg_set_state(HDbd_status_form, HDbd_SRF1_PART_CHK, blend_par.HDbd_srf1.partial);
    }
    else
    {  
      FIg_set_state(HDbd_status_form, HDbd_SRF1_TANDIR_GRP, TRUE);
      FIg_set_state(HDbd_status_form, HDbd_SRF1_PART_CHK, FALSE);
      FIg_erase  (HDbd_status_form, HDbd_SRF1_PART_CHK);
    }

    FIg_set_value(HDbd_status_form, HDbd_SRF1_T_SENS_FLD, blend_par.HDbd_srf1.t_sensi);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_LOW_BUT, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_MED_BUT, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_HIG_BUT, FALSE);
    if (srf1_sensi_range == SENSI_LOW)  FIg_set_state(HDbd_status_form, HDbd_SRF1_T_LOW_BUT, TRUE);
    if (srf1_sensi_range == SENSI_MED)  FIg_set_state(HDbd_status_form, HDbd_SRF1_T_MED_BUT, TRUE);
    if (srf1_sensi_range == SENSI_HIG)  FIg_set_state(HDbd_status_form, HDbd_SRF1_T_HIG_BUT, TRUE);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_T_SCR_CHK, blend_par.HDbd_srf1.t_screen);
    if (blend_par.HDbd_srf1.t_screen)
    {
      FIg_display(HDbd_status_form, HDbd_SRF1_SENS_B_GRP);
      FIg_display(HDbd_status_form, HDbd_SRF1_SENS_V_GRP);
    }
    else
    {
      FIg_erase(HDbd_status_form, HDbd_SRF1_SENS_B_GRP);
      FIg_erase(HDbd_status_form, HDbd_SRF1_SENS_V_GRP);
    }

    FIg_set_value(HDbd_status_form, HDbd_SRF1_T_KEYIN_FLD, blend_par.HDbd_srf1.ratio);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_IB_U_CHK, blend_par.HDbd_srf1.crv_u);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_IB_V_CHK, blend_par.HDbd_srf1.crv_v);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_IB_RUL_CHK, blend_par.HDbd_srf1.crv_ruled);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_IB_V_S_CHK, blend_par.HDbd_srf1.crv_vec_s);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_IB_V_D_CHK, blend_par.HDbd_srf1.crv_vec_d);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_IB_PER_CHK, blend_par.HDbd_srf1.crv_perp);
    FIg_set_state(HDbd_status_form, HDbd_SRF1_CRCO_TGL, blend_par.HDbd_srf1.curv_c);
    FIg_set_value(HDbd_status_form, HDbd_SRF1_APPROX_FLD, blend_par.HDbd_srf1.approx);


    /*  SRF2  */

    FIg_set_state(HDbd_status_form, HDbd_SRF2_NAT_BTN,  !blend_par.HDbd_srf2.exicrv);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_POS_BTN,   blend_par.HDbd_srf2.exicrv==1);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_CRV_BTN,   blend_par.HDbd_srf2.exicrv>1);

    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_AUT_CHK, blend_par.HDbd_srf2.t_auto);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_SCR_CHK, blend_par.HDbd_srf2.t_screen);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_COP_CHK, blend_par.HDbd_srf2.t_copy);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_KEY_CHK, blend_par.HDbd_srf2.t_keyin);

    if (blend_par.HDbd_srf2.exicrv == 0 || blend_par.HDbd_srf2.exicrv == 1)
    { 
      FIg_erase(HDbd_status_form, HDbd_SRF2_TANDIR_GRP);
      FIg_set_state(HDbd_status_form, HDbd_SRF2_TANDIR_GRP, FALSE);
      FIg_set_state(HDbd_status_form, HDbd_SRF2_PART_CHK, blend_par.HDbd_srf2.partial);
    }
    else
    {  
      FIg_set_state(HDbd_status_form, HDbd_SRF2_TANDIR_GRP, TRUE);
      FIg_set_state(HDbd_status_form, HDbd_SRF2_PART_CHK, FALSE);
      FIg_erase(HDbd_status_form , HDbd_SRF2_PART_CHK);
    }

    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_SCR_CHK, blend_par.HDbd_srf2.t_screen);
    FIg_set_value(HDbd_status_form, HDbd_SRF2_T_SENS_FLD, blend_par.HDbd_srf2.t_sensi);
    FIg_set_value(HDbd_status_form, HDbd_SRF2_T_KEYIN_FLD, blend_par.HDbd_srf2.ratio);
    FIg_set_value(HDbd_status_form, HDbd_SRF2_T_SENS_FLD, blend_par.HDbd_srf2.t_sensi);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_LOW_BUT, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_MED_BUT, FALSE);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_HIG_BUT, FALSE);
    if (srf2_sensi_range == SENSI_LOW)  FIg_set_state(HDbd_status_form, HDbd_SRF2_T_LOW_BUT, TRUE);
    if (srf2_sensi_range == SENSI_MED)  FIg_set_state(HDbd_status_form, HDbd_SRF2_T_MED_BUT, TRUE);
    if (srf2_sensi_range == SENSI_HIG)  FIg_set_state(HDbd_status_form, HDbd_SRF2_T_HIG_BUT, TRUE);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_T_SCR_CHK, blend_par.HDbd_srf2.t_screen);

    if (blend_par.HDbd_srf2.t_screen)
    {
      FIg_display(HDbd_status_form, HDbd_SRF2_SENS_B_GRP);
      FIg_display(HDbd_status_form, HDbd_SRF2_SENS_V_GRP);
    }
    else
    {
      FIg_erase(HDbd_status_form, HDbd_SRF2_SENS_B_GRP);
      FIg_erase(HDbd_status_form, HDbd_SRF2_SENS_V_GRP);
    }


    FIg_display(HDbd_status_form, HDbd_SRF2_T_KEYIN_FLD); 
    FIg_set_state(HDbd_status_form, HDbd_SRF2_IB_U_CHK, blend_par.HDbd_srf2.crv_u);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_IB_V_CHK, blend_par.HDbd_srf2.crv_v);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_IB_RUL_CHK, blend_par.HDbd_srf2.crv_ruled);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_IB_V_S_CHK, blend_par.HDbd_srf2.crv_vec_s);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_IB_V_D_CHK, blend_par.HDbd_srf2.crv_vec_d);
    FIg_set_state(HDbd_status_form, HDbd_SRF2_IB_PER_CHK, blend_par.HDbd_srf2.crv_perp);
    FIg_set_state ( HDbd_status_form, HDbd_SRF2_CRCO_TGL, blend_par.HDbd_srf2.curv_c);
    FIg_set_value( HDbd_status_form, HDbd_SRF2_APPROX_FLD, blend_par.HDbd_srf2.approx);


    /*  set last used mode button  */
    FIg_set_state ( HDbd_status_form, HDbd_MOD1_BTN, FALSE);
    FIg_set_state ( HDbd_status_form, HDbd_MOD4_BTN, FALSE);
    if (blend_par.HDbd_mode==1) FIg_set_state ( HDbd_status_form, HDbd_MOD1_BTN, TRUE);
    if (blend_par.HDbd_mode==4) FIg_set_state ( HDbd_status_form, HDbd_MOD4_BTN, TRUE);


    /*  check if FORM is already displayed  */
    FIf_is_displayed( HDbd_status_form, &display_status );
    if ( ! display_status )
    {
      /* DISPLAY/ERASE GADGETS, dependend on some variables */
      FIg_set_state ( HDbd_status_form, HDbd_DIAGNOS_BTN,blend_par.HDbd_diagnos);
      FIg_set_state ( HDbd_status_form, HDbd_SYMMETRIC,blend_par.HDbd_symmetric);
      FIf_display( HDbd_status_form );
    }

    /*  dont display undo buttons yet  */
    FIg_erase(HDbd_status_form, HDbd_UNDO_BTN);
    FIg_erase(HDbd_status_form, HDbd_UNDOLM_BTN);
    /*  dont display MOD4  */
    FIg_erase(HDbd_status_form, HDbd_MOD4_BTN);
    FIg_erase(HDbd_status_form, HDbd_MINRAD_GRP);

    return(TRUE);
}
   
end implementation ECblendsf;

