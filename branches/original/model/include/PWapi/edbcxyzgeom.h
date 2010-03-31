#ifndef _edbcxyzgeom_proto_h 
#define _edbcxyzgeom_proto_h

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

extern PWresult pwGetEdbcXyzGeom _PW_((
   PWobjid		ed,
   PWosnum		os,
   struct PWsfdata      *p_sfdata,
   struct IGRbsp_curve  **p_bspcv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
