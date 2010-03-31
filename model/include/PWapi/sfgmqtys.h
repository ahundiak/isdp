#ifndef _sfgmqtys_proto_h 
#define _sfgmqtys_proto_h

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

extern PWresult pwGetMinDistAdjPoles _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,

  double *mindist,
  int minpoleinx[2],
  PWboolean *in_u_dir
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
