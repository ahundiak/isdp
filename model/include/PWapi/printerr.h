#ifndef _printerr_proto_h 
#define _printerr_proto_h

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

extern int pwGetSubsysString _PW_((
  unsigned int holder,
  char *str
));

extern int pwGetErrCodeString _PW_((
  unsigned int holder,
  char *str
));

extern int pwGetErrCodeTypeString _PW_((
  unsigned int holder,
  char *str
));

extern int pwGetErrorString  _PW_((
  PWresult code,
  char *errstr
));

extern int pwPrintCode  _PW_((
  FILE *fp,
  PWresult code
));

extern void pwPrintError  _PW_((
  PWresult code,
  char *str
));

extern void pwPrintErrorId  _PW_((
  PWresult code,
  char *str, 
  PWobjid id
));

extern void pwPrintErrorIdVal  _PW_((
  PWresult code,
  char *str,
  PWobjid id, 
  double val
));

extern void pwPrintErrorIdId  _PW_((
  PWresult code,
  char *str,
  PWobjid id1,
  PWobjid id2
));

extern void pwPrintFileLine _PW_((
  char *filename,
  int linenum
));

extern void pwDebugLine _PW_((
  int debug_level,
  char *format,
  ...
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
