#ifndef _objcons_proto_h 
#define _objcons_proto_h

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

extern PWobjid omCreateObjFromClassid _PW_((
  PWosnum os,
  PWclassid clsid
));

extern PWobjid omCreateObjFromObjid _PW_((
  PWosnum os,
  PWobjid objid
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
