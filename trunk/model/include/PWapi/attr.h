#ifndef _attr_proto_h 
#define _attr_proto_h

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

extern PWresult pwGetSymbology _PW_((
  PWobjid                 objid, 
  PWosnum                 os,
  struct GRsymbology     *p_symb
));

#if defined(__cplusplus) 
} 
#endif 

#endif 

