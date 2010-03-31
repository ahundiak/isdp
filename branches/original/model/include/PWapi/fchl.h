#ifndef _fchl_proto_h 
#define _fchl_proto_h

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

extern PWresult pwAddHolesToFace _PW_((
  PWosnum os,
  PWobjid face,
  int num_holes,
  PWobjid *p_holes
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
