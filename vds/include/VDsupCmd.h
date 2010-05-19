
#define VDSUP_FORM_ETC_L_CURVES 16
#define VDSUP_FORM_ETC_C_CURVES 15
#define VDSUP_FORM_ETC_M_CURVES 25

#define VDSUP_FORM_ETC_B_HILITE_SEL  21
#define VDSUP_FORM_ETC_B_HILITE_ALL  20
#define VDSUP_FORM_ETC_B_UNHILITE    18
#define VDSUP_FORM_ETC_B_DROP_CURVES 22

#define VDSUP_FORM_ETC_B_TRIM1        13
#define VDSUP_FORM_ETC_B_TRIM2        14
#define VDSUP_FORM_ETC_B_ETC				  23
#define VDSUP_FORM_ETC_B_PARENT   		27

#define VDSUP_FORM_ETC_T_ETC   26

#define VDSUP_FORM_ETC_G_TRIM1 17
#define VDSUP_FORM_ETC_G_TRIM2 19
#define VDSUP_FORM_ETC_G_ETC   24

#define VDSUP_FORM_ETC_G_DISTANCE 11


typedef struct {
  Form       form;
  IGRint     gadget;

  TGRid      etcID;
  TGRid      disID;

  TGRobj_env trim1OE,trim2OE;

  IGRint     crvCNT;
  TGRobj_env crvOEs[64];

  TGRmd_env  env;
  IGRint     selInProgress;
} TVDsupEtc;
