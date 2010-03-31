#ifndef _featquery_proto_h 
#define _featquery_proto_h

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

extern PWboolean pwIsBooleanObj _PW_((
  PWobjid obj,
  PWosnum os,
  enum PWbooltype *booltype
));

extern enum PWfeattype pwFeatureType _PW_((
  PWobjid featnode,
  PWosnum os
));

extern PWresult pwGetFeatureSfs _PW_((
  PWobjid featnode,
  PWosnum os,
  int *num_featsfs,
  PWobjid **featsfs
));

extern PWboolean pwIsFeatureState _PW_((
  PWobjid feature_id,
  PWosnum os,
  enum PWfeattype *feat_type
));

extern PWboolean pwIsFeatureActive _PW_((
  PWobjid feature_id,
  PWosnum os
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
