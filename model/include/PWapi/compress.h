#ifndef _compress_proto_h 
#define _compress_proto_h

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

extern PWresult pwCompressSurfaceEntity _PW_((
  PWobjid sf_entity,
  PWosnum os,
  PWobjid *comp_entity
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
