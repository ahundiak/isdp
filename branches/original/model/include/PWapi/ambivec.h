#ifndef _ambivec_proto_h 
#define _ambivec_proto_h

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

extern PWresult      pwGetAmbiguousVecs  _PW_(( 
   int numvecs, 
   double (*vecs)[3], 
   double *dirvec,
   int *sort_indices, 
   int *numambi,
   int *p_ambi_indices 
));

extern double     pwConvertAngleMeasure _PW_(( 
  double ang_meas
));

extern void    pwMergeAmbiguousVecs _PW_(( 
   int numambi,
   int *ambi_indices, 
   int numsort,
   int *sort_indices, 
   int *newlist 
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
