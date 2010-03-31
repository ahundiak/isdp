#ifndef _edintpts_proto_h 
#define _edintpts_proto_h

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

extern PWresult   pwEdInternalPts _PW_((
  PWobjid edobj,
  PWosnum os,
  int num,
  PWpoint2d *pts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
