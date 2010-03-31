#ifndef _angle_proto_h 
#define _angle_proto_h

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

extern PWresult pwAngle2d _PW_((
  PWvector2d  vec_a,
  PWvector2d  vec_b,
  double      *radians 
));

extern PWresult pwAngle _PW_((
  PWvector  vec_a,
  PWvector  vec_b,
  PWvector  ndirvec,
  double    *radians
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
