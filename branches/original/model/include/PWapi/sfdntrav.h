#ifndef _sfdntrav_proto_h 
#define _sfdntrav_proto_h

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

extern PWresult pwTraverseCSfCSfs _PW_((
  PWobjid csfobj,
  PWosnum os,
  PWboolean depth_first,
  PWresult (*func)(),
  void *func_args
));

extern PWresult pwTraverseSfSfs _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
));

extern PWresult pwTraverseSfLps _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
));

extern PWresult pwTraverseSfEds _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
