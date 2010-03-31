#ifndef _inspts_proto_h 
#define _inspts_proto_h

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

extern void pwInsertDouble _PW_((
  int numinspts,
  double *p_inspts,
  int atinx, 
  int numpts,
  double *p_pts
));

extern void pwInsertPts2d  _PW_((
  int numinspts,
  PWpoint2d *p_inspts,
  int atinx,
  int numpts,
  PWpoint2d *p_pts
));

extern void pwInsertPts _PW_((
  int numinspts,
  PWpoint *p_inspts,
  int atinx,
  int numpts,
  PWpoint *p_pts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
