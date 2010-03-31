#ifndef _fchlsf_proto_h 
#define _fchlsf_proto_h

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

extern PWresult pwAddFaceToSf _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWobjid faceobj
));

extern PWresult pwAddHoleToSf _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWobjid holeobj
));

extern PWresult pwRemoveFaceOfSf _PW_((
  PWobjid faceobj,
  PWosnum os
));

extern PWresult pwRemoveHoleOfSf _PW_((
  PWobjid hole,
  PWosnum os
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
