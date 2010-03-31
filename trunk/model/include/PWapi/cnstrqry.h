/*
  OVERVIEW
  Function prototypes and structures that are required for the use of
  Profile Query  APIs.

  NOTES

  HISTORY
  Satya   06/11/96   Creation
*/

#ifndef _CnstrQueryAPI_include
#define _CnstrQueryAPI_include

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

extern enum PWprfcnstrtype  pwConstraintType   _PW_((
  PWobjid cnstr_id,
  PWosnum os
));

extern double pwDimConstraintVal  _PW_((
  PWobjid dimcnstr_id,
  PWosnum os
));

extern PWboolean pwIsDimConstraint   _PW_((
  PWobjid cnstr_id,
  PWosnum os
));

extern PWboolean pwIsGeomConstraint   _PW_((
  PWobjid cnstr_id,
  PWosnum os
));

extern PWresult  pwGetProfileConstraints _PW_((
  PWobjid profile_id,
  PWosnum os,
  PWobjid *constraints
));

extern PWresult pwGetConstraintGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
));

extern int pwNumProfileConstraints  _PW_(( 
  PWobjid profile_id,
  PWosnum os
));

extern int pwGetDimObject _PW_((
  PWobjid cnstr_id,
  PWosnum os,
  PWobjid *dim_id
));

extern PWresult pwGetConstraintProps _PW_((
  PWobjid cnstr_id,
  PWosnum os,
  unsigned short *vprops
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
