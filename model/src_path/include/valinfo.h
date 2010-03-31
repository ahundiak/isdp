/*
  OVERVIEW
  Structures and APIs for the PWvalinfo structure. This structure is used
  for passing values/expressions to the feature APIs.

  NOTES
  Any addition/modification to the PWvalinfo structure must be reflected in 
  all the supporting APIs.

  HISTORY
  Aditya   03/19/96  Creation
*/

#ifndef _ValInfo_include
#define _ValInfo_include

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

extern PWresult PutValueInfo _PW_((
  struct PWvalueinfo *invalueinfo,
  struct EMSvalue_info *outvalinfo ));

extern PWresult GetValueInfo _PW_((
  struct EMSvalue_info *invalinfo,
  struct PWvalueinfo *outvalinfo ));

extern PWresult GetExpressionFromParamvlObject _PW_((
  PWobjid objid,
  PWosnum os,
  struct PWvalueinfo *valinfo ));

#if defined(__cplusplus)
}
#endif

#endif
