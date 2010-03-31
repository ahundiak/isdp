#ifndef _lptrim_proto_h 
#define _lptrim_proto_h

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

extern PWresult pwTrimAgainstLoop _PW_((
  struct PWid             *p_lpid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWgeomid         *p_sfgmid,
  double                  xyztol,
  struct PWcvregion_list  **p_cvregs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
