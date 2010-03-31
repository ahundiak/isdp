#ifndef _globals_proto_h 
#define _globals_proto_h

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

extern struct GRmd_env *pwModuleEnv _PW_((
  PWosnum os,
  struct GRmd_env *md_env
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
