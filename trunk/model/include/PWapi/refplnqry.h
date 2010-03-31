#ifndef _refplnqry_proto_h 
#define _refplnqry_proto_h

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

extern PWresult pwGetDatpldata _PW_((
  PWobjid datplane,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  PWvector xvec,
  PWvector yvec,
  PWvector zvec,
  PWpoint  origpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
