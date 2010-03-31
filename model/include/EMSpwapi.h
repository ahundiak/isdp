#ifndef _EMpwxchg_proto_h 
#define _EMpwxchg_proto_h

#if defined(__STDC__) || defined(__cplusplus) 
#ifndef _PW_ 
#define _PW_(args) args 
#endif 
#else 
#ifndef _PW_ 
#define _PW_(args) () 
#endif 
#endif 

#if defined(__cplusplus) 
extern "C" 
{ 
#endif

extern void pwCnvtCvregionEMS  _PW_((
  struct PWcvregion_list *p_cvregions,
  struct EMSpypoint *p_pypt,
  struct EMSsfintedpar *p_edpar,
  PWboolean bdry_is_area,
  double uvtol
));

extern void pwCnvtCvintptEMS  _PW_((
  struct PWcvintpt *p_cvintpt,
  struct EMSpypoint *p_pypt,
  struct EMSsfintedpar *p_edpar,
  PWboolean bdry_is_area
));

extern void pwCnvtCvptEMSpypt _PW_((
  struct PWcvpt *p_cvpt,
  struct EMSpypoint *p_pypt
));

extern enum EMScvinttype pwEMSTopopos _PW_((
  enum PWtopopostype topopos
));

extern enum PWtopopostype pwPWCvint _PW_((
  enum EMScvinttype cvint
));

extern void pwCnvtCvptEMSsfed _PW_((
  struct PWcvpt *p_cvpt,
  struct EMSsfintedpar *p_sfed
));

extern void pwCnvtEMSCvdata  _PW_((
  struct EMSdataselect *p_datasel,
  struct PWcvdata *p_cvdata
));

extern void pwMoveCvdataEMS _PW_((
  struct PWcvdata *p_cvdata,
  struct EMSdataselect *p_datasel
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
