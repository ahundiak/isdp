#ifndef _posptgm_proto_h 
#define _posptgm_proto_h

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

extern enum PWtopopostype pwGetPosPtSg2d _PW_((
  double par,
  PWpoint2d pt1, 
  PWpoint2d pt2,
  double tol
));

extern enum PWtopopostype pwGetPosPtSg _PW_((
  double par,
  PWpoint pt1, 
  PWpoint pt2,
  double tol
));

extern enum PWtopopostype pwGetPosPtPy2d _PW_((
  struct PWcvparam *par,
  int numpts, 
  PWpoint2d *pts,
  double tol
));

extern enum PWtopopostype pwGetPosPtPy _PW_((
  struct PWcvparam *par,
  int numpts, 
  PWpoint *pts,
  double tol
));

extern PWboolean pwIsParAtCvEnd _PW_((
  struct PWcvparam *par,
  PWboolean at_stop_end,
  struct PWcvdata *cvdata,
  PWboolean cv_reverse,
  double lentol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
