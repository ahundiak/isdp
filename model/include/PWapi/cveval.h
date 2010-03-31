#ifndef _cveval_proto_h 
#define _cveval_proto_h

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

extern PWresult pwGetCvPlane _PW_((
  PWobjid cvid,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  struct PWplane *plane
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
