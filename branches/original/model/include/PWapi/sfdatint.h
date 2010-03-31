#ifndef _sfdatint_h 
#define _sfdatint_h

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

extern PWresult pwSfdataIntersect _PW_ ((
  struct PWsfdata *sf1,
  struct PWsfdata *sf2,
  PWboolean discard_point_intersections,
  PWboolean discard_uvcvs,
  int *num_inters,
  struct PWcvdata **xyzcvs1,
  struct PWcvdata **uvcvs1,
  struct PWcvdata **xyzcvs2,
  struct PWcvdata **uvcvs2
));

extern void pwSfdataIntersectFree _PW_ ((
  int num_inters,
  struct PWcvdata *xyzcvs1,
  struct PWcvdata *uvcvs1,
  struct PWcvdata *xyzcvs2,
  struct PWcvdata *uvcvs2
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
