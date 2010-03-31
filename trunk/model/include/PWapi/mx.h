#ifndef _mx_proto_h 
#define _mx_proto_h

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

extern double * pwIdMx _PW_((
  PWmatrix mat
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
