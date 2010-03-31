#ifndef _clsid_proto_h 
#define _clsid_proto_h

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

extern PWclassid omClassidFromObjid _PW_((
  PWobjid objid,
  PWosnum osnum
));

extern char *omClassNameFromClassid _PW_((
  PWclassid classid,
  PWosnum osnum,
  char *classname
));

extern PWclassid omClassidFromName _PW_((
  char *classname,
  PWosnum osnum
));

extern PWboolean omIsAncestryValid  _PW_((
  PWclassid subclassid,
  PWclassid superclassid
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
