#ifndef _lped_proto_h 
#define _lped_proto_h

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

extern int pwNumEdsOfLp  _PW_((
  PWobjid loopobj,
  PWosnum os
));

extern int pwEdsOfLp  _PW_((
  PWobjid loopobj,
  PWosnum os,
  PWobjid *p_eds
));

extern PWobjid pwEdAtInxOfLp _PW_((
  PWobjid  loopobj,
  PWosnum  os,
  int      index
));

extern PWobjid pwGetLpOfEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern int pwGetEdInxOnLp  _PW_((
  PWobjid  edobj,
  PWosnum  os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
