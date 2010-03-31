#ifndef _changedata_proto_h 
#define _changedata_proto_h

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

extern PWresult  pwChangeEMSCvdata _PW_((
  struct EMSdataselect *p_datasel,
  struct PWcvdata      *p_cvdata,
  short                mattyp,
  PWmatrix             p_mat,
  PWboolean            *p_allocated
));

extern void pwFreeCvdata _PW_((
  struct PWcvdata *cvdata
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
