#ifndef _inttan_proto_h 
#define _inttan_proto_h

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

extern PWresult    pwGetXyzTanAtIntPt _PW_((
  short                  mattyp,
  PWmatrix               mat,
  struct EMSdataselect   *ingeom,
  PWpoint                inpt,
  double                 xyztol,
  struct PWcvpt          *projpt,
  PWvector               tanvec
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
