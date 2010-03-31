#ifndef _revgm_proto_h 
#define _revgm_proto_h

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

extern void pwRevCvdata _PW_((
  struct PWcvdata *p_cvdata
));

extern void pwRevPy2d _PW_((
  int num_pts,
  PWpoint2d *p_pts
));

extern void pwRevPy _PW_((
  int num_pts,
  PWpoint *p_pts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
