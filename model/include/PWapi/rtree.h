#ifndef _rtree_proto_h 
#define _rtree_proto_h

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

extern PWresult pwAddObjToRtree _PW_((
  PWobjid objid,
  PWosnum os,
  PWrange range
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
