#ifndef _intrelsupp_proto_h 
#define _intrelsupp_proto_h

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

extern PWresult       pwComputeIntRels _PW_((
  struct EMSintobj   *p_intcv, 
  double             xyztol
));

extern PWresult    pwGetIntPropsAtPt  _PW_((
  struct EMSintobj         *p_intcv, 
  PWpoint                  sampleptxyz,
  double                   xyztol,
  PWboolean                option, 
  PWvector                 T, 
  PWvector                 *vecs,
  struct IntInfo           *p_intinfo 
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
