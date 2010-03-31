#ifndef _dbglevel_proto_h 
#define _dbglevel_proto_h

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

extern int pwGetDebugLevel _PW_((
));

extern void pwSetDebugLevel _PW_((
  int level
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
