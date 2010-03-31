#ifndef _solrev_proto_h 
#define _solrev_proto_h

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

extern PWresult pwCreateSolidOfRev _PW_((
   PWobjid profile_id,
   PWosnum profile_os,
   PWpoint axis_point,
   PWvector axis_vector,
   struct PWvalueinfo *start_angle, /* if NULL start at prof plane */
   struct PWvalueinfo *sweep_angle, /* if NULL, revolve 360.       */
   PWobjid *rev_solid
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
