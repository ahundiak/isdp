#ifndef _intcvcv_proto_h 
#define _intcvcv_proto_h

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

extern PWresult pwCvCvInt _PW_((
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWrange                b_range,
  PWboolean              b_reverse,
  PWboolean              b_process_start, 

  struct IGRbsp_curve    *p_icv,
  struct PWadjseg        *p_iadjseg,
  PWrange                i_range,
  PWboolean              i_reverse,
  PWboolean              i_process_start,

  PWvector               dirvec,
  double                 lentol,

  int                    *p_num_inters,
  struct PWcvintpt_list  **p_cvintpt_list
));

extern PWresult pwGetCvFwBwTangents _PW_((
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse, 
  double               partol,
  PWvector             tangents[2]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
