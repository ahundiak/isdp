/*
  OVERVIEW
  Function prototypes and structures that are required for the use of
  Profile Query  APIs.

  NOTES

  HISTORY
  Satya   06/11/96   Creation
*/

#ifndef _ProfQueryAPI_include
#define _ProfQueryAPI_include

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


extern PWobjid pwGetRefPlane  _PW_((
  PWobjid profile_id,
  PWosnum os
));

extern PWresult  pwGetProfileComponents  _PW_(( 
  PWobjid profile_id,
  PWosnum os,
  PWobjid *components
));

extern int pwNumProfileComponents  _PW_(( 
  PWobjid profile_id,
  PWosnum os
));

extern PWresult  pwGetCvComponents   _PW_((
  PWobjid comp_curve,
  PWosnum os,
  PWobjid *components
));

extern int pwNumCvComponents  _PW_(( 
  PWobjid comp_curve,
  PWosnum os
));


extern PWresult pwProfileXformMat  _PW_(( 
  PWobjid profile_id,
  PWosnum os,
  short inp_mattyp,
  PWmatrix inp_mat,
  short  *xyz_xy_mattyp,
  PWmatrix xyz_xy_mat,
  short  *xy_xyz_mattyp,
  PWmatrix xy_xyz_mat
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
