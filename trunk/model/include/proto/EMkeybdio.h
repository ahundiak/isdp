#ifndef _EMkeybdio_proto_h 
#define _EMkeybdio_proto_h

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

extern double EMgetdouble _PW_((
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  double default_value 
));

extern int EMgetint _PW_((
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  int default_value 
));

extern char EMgetchar _PW_((
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  char default_value 
));

extern char *EMgetstring _PW_((
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  char *default_value,
  char string_memory[GR_MAX_CHAR]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
