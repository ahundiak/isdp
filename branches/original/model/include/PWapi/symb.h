#ifndef _symb_proto_h 
#define _symb_proto_h

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

extern PWresult pwPutSymb _PW_((
  PWobjid objid, 
  PWosnum osnum,  
  struct GRsymbology *Symb
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
