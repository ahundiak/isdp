#ifndef _PlaceCnstrAPI_include
#define _PlaceCnstrAPI_include

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

extern PWresult pwFixangConstraint  _PW_((
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *fixang
));



extern PWresult pwHorizDimConstraint  _PW_((  
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWboolean is_horiz,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *horizdim
));




extern PWresult pwRadialConstraint  _PW_(( 
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *radial
));

extern PWresult pwSingleParlConstraint  _PW_(( 
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *singleparl
));

extern PWresult pwRelangConstraint  _PW_(( 
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *relang
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
