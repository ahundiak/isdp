#ifndef _partgm_proto_h 
#define _partgm_proto_h

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

extern PWresult pwPartOfPy2d _PW_((
  int num_pts,
  PWpoint2d *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  int *num_outpts,
  PWpoint2d *p_outpts
));

extern PWresult pwPartOfPy  _PW_((
  int num_pts,
  PWpoint *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  int *num_outpts,
  PWpoint *p_outpts
));

extern PWresult pwPartOfCv _PW_((
  struct IGRbsp_curve *p_cv,
  double startpar,
  double stoppar,
  double midpar,

  double lentol,

  struct IGRbsp_curve *p_outcv
));

extern PWresult pwPartOfCvdata _PW_((
  struct PWcvdata *p_cvdata,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  struct PWcvdata *p_outcvdata
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
