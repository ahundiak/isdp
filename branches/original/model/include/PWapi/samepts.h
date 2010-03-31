#ifndef _samepts_proto_h 
#define _samepts_proto_h

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

extern PWboolean pwIsSamePt2d  _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2,
  double tol
));

extern PWboolean pwIsSamePt  _PW_((
  PWpoint pt1,
  PWpoint pt2,
  double tol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
