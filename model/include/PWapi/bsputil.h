#ifndef _bsputil_h 
#define _bsputil_h

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

extern void pwUnweightPoles _PW_ ((
  int num_poles,
  PWpoint *poles,
  double *weights,
  PWpoint *unweighted_poles
));

extern void pwUnweightPoles2d _PW_ ((
  int num_poles,
  PWpoint2d *poles,
  double *weights,
  PWpoint2d *unweighted_poles
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
