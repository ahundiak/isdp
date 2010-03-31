#ifndef _channel_proto_h 
#define _channel_proto_h

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

extern int omNumObjsOnChannel _PW_((
  PWobjid obj,
  PWosnum os,
  OM_S_CHANSELECT *p_channel
));

extern int omGetObjsOnChannel _PW_((
  PWobjid obj,
  PWosnum os,
  OM_S_CHANSELECT *p_channel,
  PWobjid *p_outobjs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
