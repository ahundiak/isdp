#ifndef _errlogfile_proto_h 
#define _errlogfile_proto_h

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

extern FILE *pwGetErrLogFile _PW_((
));

extern PWboolean pwSetErrLogFile  _PW_((
  char *filename,
  PWboolean append
));

extern void pwResetErrLogFile  _PW_((
));

extern PWboolean pwGetErrLogFilename  _PW_((
  char *filename
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
