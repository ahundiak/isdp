#ifndef _spangm_proto_h 
#define _spangm_proto_h

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

extern PWresult pwGetSpanCvdata _PW_((
  struct PWcvdata *p_cvdata,
  int             spaninx,
  struct PWcvdata *p_span
));

extern PWboolean pwGetNonDegenSpanPy _PW_((
  struct PWpoly *p_py,
  int           spaninx,
  double        lentol,
  PWpoint       outpts[2]
));

extern PWboolean pwGetNonDegenSpanPy2d _PW_((
  struct PWpoly2d *p_py,
  int             spaninx,
  double          lentol,
  PWpoint2d       outpts[2]
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
