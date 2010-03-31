#ifndef _skin_proto_h 
#define _skin_proto_h

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

extern PWresult pwCreatSolidBySkinning _PW_((
 int num_trace_curves,
 PWobjid *trace_curves,
 PWboolean *trace_curve_orientation,
 PWosnum os,
 int num_cross_sections,
 PWobjid *cross_sections,
 PWboolean *cross_sections_orientation,
 PWboolean is_obsolute_orientation,
 PWobjid *skinned_solid
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
