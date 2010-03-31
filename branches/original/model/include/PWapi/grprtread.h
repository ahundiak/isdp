#ifndef _grprtread_proto_h 
#define _grprtread_proto_h

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

extern PWresult pwPrintObject _PW_((
  PWobjid grobj,
  PWosnum os,
  FILE *file,
  PWboolean full_format
));

extern PWresult pwReadAllObjects _PW_((
  FILE *file,
  PWosnum os,
  PWboolean full_format,
  int *num_objects,
  PWobjid **objects
));

extern PWresult ReadObject _PW_((
  FILE *file,
  PWosnum os,
  PWboolean full_format,
  PWboolean create_object_if_needed,
  PWboolean object_data_follows,
  PWobjid *objid
));

extern void InitNewObjTable _PW_((
));

extern void DeleteNewObjTable _PW_((
));

extern PWresult AddNewObjToTable _PW_((
  PWobjid oldobjid,
  PWobjid newobjid
));

extern PWresult GetNewObjFromTable _PW_((
  PWobjid oldobjid,
  PWobjid *newobjid
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
