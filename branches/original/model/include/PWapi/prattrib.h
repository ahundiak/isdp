#ifndef _prattrib_proto_h 
#define _prattrib_proto_h

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

extern void pwStringAttrib  _PW_((
  enum PWattribtype attr,
  char *str
));

extern void pwPrintAttrib  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWattrib *attrib
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
