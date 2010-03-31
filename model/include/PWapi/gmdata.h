#ifndef _gmdata_proto_h 
#define _gmdata_proto_h

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

extern void pwSetTopoposCvpt _PW_(( 
  struct PWcvpt         *p_cvpt,
  enum   PWtopopostype  topopos
));

extern enum PWtopopostype pwGetTopoposCvpt _PW_((
  struct PWcvpt  *p_cvpt
));

extern void pwFreeCvdataGeom _PW_((
  struct PWcvdata *cvdata
));

extern void pwCnvtPyToCv _PW_((
  struct PWpoly       *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
));

extern void pwCnvtPy2dToCv _PW_((
  struct PWpoly2d     *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
