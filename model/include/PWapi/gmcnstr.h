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



extern PWresult pwCoincidentConstraint _PW_((
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *coincident
));

extern PWresult pwCollinearConstraint  _PW_(( 
  int num_elems,
  PWobjid *element_ids,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *collinear
));



extern PWresult pwEqualityConstraint  _PW_(( 
  int num_elems,
  PWobjid *element_ids,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *equal
));

extern PWresult pwGroundConstraint  _PW_(( 
  PWobjid element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr, 
  PWobjid *ground
));


extern PWresult pwHorizVertConstraint  _PW_(( 
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWboolean is_horiz,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *horizvert
));


extern PWresult pwNormalConstraint  _PW_((  
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *normal
));


extern PWresult pwParallelConstraint  _PW_((  
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *parallel
));


extern PWresult pwPtonelmtConstraint  _PW_(( 
  PWobjid *element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *ptonelmt
));


extern PWresult pwTangencyConstraint  _PW_(( 
  PWobjid element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *tangent
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
