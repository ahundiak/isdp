#ifndef _solproj_proto_h 
#define _solproj_proto_h

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

extern PWresult pwCreatSolidOfProj _PW_((
   PWobjid      profile_id,
   PWosnum 	profile_os,
   PWboolean 	project_normal,
   PWvector  	dirvec,
   struct PWvalueinfo  distance,
   PWboolean 	is_symmetric,
   PWobjid     	*solid 
));

extern PWresult pwCreateSolidOfProjBtnPlanes _PW_((
   PWobjid profile_id,
   PWosnum profile_os,
   PWboolean proj_normal,
   PWvector dir_vector, //if proj_normal==TRUE, approx dir_vec accepted,
                        // else dir_vec is absolute.
   PWobjid start_plane,  // if NULL, use prof plane.
   PWobjid end_plane,
   PWobjid *mod_solid
));

extern int pwNumSideSf _PW_((
  PWobjid solid,
  PWosnum os
));

extern  PWobjid pwCapsf _PW_((
  PWobjid solid,
  PWosnum os,
  PWboolean is_start_cap
));

extern PWobjid pwSideSf _PW_((
  PWobjid solid,
  PWosnum os,
  int side_index  
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
