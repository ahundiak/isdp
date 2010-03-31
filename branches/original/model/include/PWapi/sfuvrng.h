#ifndef _sfuvrng_include
#define _sfuvrng_include

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

extern void pwGetSfUvRng 
(
  PWobjid sf,
  PWosnum os,
  PWrange2d uvrng
);

#if defined(__cplusplus) 
} 
#endif

#endif
