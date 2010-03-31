#ifndef _edtype_proto_h 
#define _edtype_proto_h

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

extern int pwGetEdTypeFromBsType _PW_(( 
  int bstype
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
