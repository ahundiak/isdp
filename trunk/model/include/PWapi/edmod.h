#ifndef _edmod_proto_h 
#define _edmod_proto_h

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

extern void pwEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern pwMakeCommEdgeConn _PW_((
 PWosnum    osnum,
 PWboolean  orient1,
 PWboolean  orient2,
 PWobjid    edobj1,
 PWobjid    edobj2
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
