#ifndef _degengm_proto_h 
#define _degengm_proto_h

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

extern int pwNumDegenSpans2d _PW_((
  int num_pts, 
  PWpoint2d *pts,
  double tol
));

extern int pwNumDegenSpans _PW_((
  int num_pts, 
  PWpoint *pts,
  double tol
));

extern int pwRemoveDegenSpans2d _PW_((
  int num_inpts,
  PWpoint2d *inpts,
  int *num_outpts,
  PWpoint2d *outpts,
  double tol
));

extern int pwRemoveDegenSpans _PW_((
  int num_inpts,
  PWpoint *inpts,
  int *num_outpts,
  PWpoint *outpts,
  double tol
));

extern PWboolean pwIsDegenPy2d  _PW_((
  int numpts,
  PWpoint2d *pts,
  double tol
));

extern PWboolean pwIsDegenPy _PW_((
  int numpts,
  PWpoint *pts,
  double tol
));

extern PWboolean pwIsCvDegen _PW_((
  struct IGRbsp_curve  *p_cv,
  double               tol
));

extern PWboolean pwIsDegenCvdata _PW_((
  struct PWcvdata *p_cvdata,
  double lentol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
