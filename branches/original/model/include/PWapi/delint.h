#ifndef _delint_proto_h 
#define _delint_proto_h

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

extern PWresult   pwDeleteInt _PW_((
   struct EMSinters **pp_inters
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
