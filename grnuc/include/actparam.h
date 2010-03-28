#ifndef _actparam_proto_h 
#define _actparam_proto_h

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

extern IGRboolean pwIsActivationOn _PW_((
));

extern GRspacenum pwGetActiveOs _PW_((
));

extern IGRint pwGetActiveRefHeader _PW_((
   struct GRid *rfhead
));

extern IGRint pwGetActiveModuleEnv _PW_((
   struct GRmd_env *rfenv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
