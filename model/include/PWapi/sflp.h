#ifndef _sflp_proto_h 
#define _sflp_proto_h

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

extern int pwNumOuterFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwOuterFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_faceloops
));

extern int pwNumInnersOfLp _PW_((
  PWobjid  loopobj, 
  PWosnum  os
));

extern int pwInnersOfLp _PW_((
  PWobjid  loopobj, 
  PWosnum  os,
  PWobjid  *p_lps
));

extern PWobjid  pwOutterOfLp _PW_((
  PWobjid  loopobj,
  PWosnum  os
));

extern int pwNumLpsOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwLpsOfSf _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_loops
));

extern int pwNumFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_faceloops
));

extern PWobjid pwFaceAtInxOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  unsigned int index
));

extern PWobjid pwOuterFaceAtInxOfSf _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  int      index
));

extern PWobjid pwLpAtInxOfSf _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  int      index
));

extern int pwNumHolesOfFace  _PW_((
  PWobjid  faceloop, 
  PWosnum  os
));

extern int pwHolesOfFace  _PW_((
  PWobjid  faceloop, 
  PWosnum  os,
  PWobjid  *p_holeloops
));

extern int pwNumInnerFacesOfHole  _PW_((
  PWobjid  holeloop, 
  PWosnum  os
));

extern int pwInnerFacesOfHole  _PW_((
  PWobjid  holeloop, 
  PWosnum  os,
  PWobjid  *p_faceloops
));

extern PWobjid pwHoleAtInxOfFace _PW_((
  PWobjid  faceloop,
  PWosnum  os, 
  int      index
));

extern PWobjid pwInnerFaceAtInxOfHole _PW_((
  PWobjid  holeloop,
  PWosnum  os, 
  int      index
));

extern PWobjid pwSfOfLp _PW_((
  PWobjid  loopobj,
  PWosnum  os
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
