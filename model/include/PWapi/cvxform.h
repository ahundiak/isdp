#ifndef _cvxform_proto_h 
#define _cvxform_proto_h

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

extern PWresult pwTransformBspline _PW_((
  PWmatrix trans_mat,
  struct IGRbsp_curve *cvin, 
  struct IGRbsp_curve *cvout
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
