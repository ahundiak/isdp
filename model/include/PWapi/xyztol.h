#ifndef _xyztol_proto_h 
#define _xyztol_proto_h

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

extern double pwActiveXYZLenTol _PW_((
));

extern double pwActiveXYZChtTol _PW_((
));

extern void pwSetActiveXYZLenTol _PW_((
  double newtol
));

extern void pwSetActiveXYZChtTol _PW_((
  double newtol
));

extern PWresult pwGetPersistXYZTols _PW_((
  PWosnum os,
  double *lentol,
  double *chttol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
