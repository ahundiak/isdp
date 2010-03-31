#ifndef _msgsend_h 
#define _msgsend_h

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

extern PWresult omMakeMessage _PW_((
  char *classname,
  char *messgname,
  void *messgargs,
  int argssize,
  struct PWommsg *messg
));

extern PWresult omSend _PW_((
  struct PWommsg *messg,
  PWobjid targetid,
  PWosnum targetos,
  PWobjid senderid,
  PWboolean invoke_parent_implementation
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
