#ifndef _sftrim_proto_h 
#define _sftrim_proto_h

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

extern PWresult pwTrimAgainstSurface _PW_((
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_uvcv,
  struct PWcvdata        *p_xyzcv,
  PWrange2d              uvcvrng,
  double                 xyztol,
  struct PWcvregion_list **p_cvregs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
