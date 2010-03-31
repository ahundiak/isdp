
/* ********

Description

   Definition for blend curve form data exchange 
   

History :  created 09/14/94  - HOB                            **** */


struct HDbd_form_params
{ 
    IGRint      HDbd_crv1point;
    IGRint      HDbd_crv2point;
    IGRint      HDbd_crv1exip;
    IGRint      HDbd_crv2exip;
    IGRint      HDbd_crv1_cont;
    IGRint      HDbd_crv2_cont;
    IGRdouble   HDbd_crv1sens;
    IGRdouble   HDbd_crv2sens;
    IGRdouble   HDbd_abs_ratio1;
    IGRdouble   HDbd_abs_ratio2;

    IGRint      HDbd_undolm;
    IGRint      HDbd_undo;
    IGRint      HDbd_mode;
    IGRdouble   HDbd_minrad;
    IGRint      HDbd_diagnos;
    IGRint      HDbd_toggle_pol;
    IGRint      HDbd_symmetric;
    IGRboolean  HDbd_accept;
};





#define                  MAX_BLEND_ORDER    7
#define                  MAX_BLEND_POLES    7
#define                  MAX_BLEND_KNOTS    14

