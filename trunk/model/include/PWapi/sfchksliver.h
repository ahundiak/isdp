#ifndef _sfchksliver_proto_h 
#define _sfchksliver_proto_h

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

extern int pwGetSliverSfs _PW_((
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  double xyztol,
  int num_samplepts,
  PWobjid **sliver_sfs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
