#ifndef _objconn_proto_h 
#define _objconn_proto_h

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

extern PWresult omConnectObjectAtIndex _PW_((
  PWobjid to_object,
  PWobjid to_os,
  OM_S_CHANSELECT *p_to_channel,
  int to_index,
  PWobjid object,
  PWosnum os,
  OM_S_CHANSELECT *p_channel,
  int index
));

extern PWresult omDisconnectObject _PW_((
  PWobjid to_object,
  PWobjid to_os,
  OM_S_CHANSELECT *p_to_channel,
  PWobjid object,
  PWosnum os,
  OM_S_CHANSELECT *p_channel
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
