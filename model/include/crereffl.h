#ifndef _crereffl_proto_h 
#define _crereffl_proto_h

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

extern PWresult pwCreateReferenceFile _PW_((
   char *filename ,
   PWobjid ref_plnid ,
   PWpoint origin ,
   PWobjid *rfheader ,
   PWosnum *osn
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
