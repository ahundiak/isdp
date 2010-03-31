#ifndef _gmdatamem_h 
#define _gmdatamem_h

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

extern void pwFreeCvdataGeom _PW_ ((
  struct PWcvdata *cvdata
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
