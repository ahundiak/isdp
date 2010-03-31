#ifndef _cvcompcv_proto_h 
#define _cvcompcv_proto_h

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

extern int pwNumCvsOfCompCv  _PW_((
  PWobjid  cvobj,
  PWosnum  os
));

extern int pwCvsOfCompCv  _PW_((
  PWobjid  cvobj,
  PWosnum  os,
  PWobjid  *p_cvs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
