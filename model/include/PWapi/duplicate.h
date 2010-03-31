#ifndef _duplicate_proto_h 
#define _duplicate_proto_h

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

extern void     pwProcessDupInt _PW_(( 
   struct EMSinters **p_inters, 
   double           xyztol
));

extern PWboolean AreIntobjsSame _PW_((
   struct EMSintobj  *p_intcv1,
   struct EMSintobj  *p_intcv2,
   double            tol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
