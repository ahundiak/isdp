#ifndef _edptproj_proto_h 
#define _edptproj_proto_h

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

extern PWresult    pwEdPtProject _PW_((
  struct PWid     *p_edid,
  int             numpts,
  PWpoint2d       *pts,
  double          uvtol,
  struct PWcvpt   *p_cvpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
