/* Includes */

#include "OMminimum.h"          /* OM */
#include "OMerrordef.h"           

#include "PWminimum.h"          /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "PWapi/objcons.h"


/* External Functions */

extern int som_construct_object (char *classname, OMuword classid,
                OM_S_OBJID objid, OM_p_OBJECTHDR p_object, OMuword obj_osnum,
                OMuword osnum, char *osname, OM_p_OBJID p_objid,
                OM_p_MESSAGE msg, OM_S_NEIGHBOR neighbor, OMuint *p_tag);


/*
  ABSTRACT 

  This function construct an object in the given object space given the classid
  of the object.

  NOTES
 
  None
*/

PWobjid omCreateObjFromClassid
(
  PWosnum os,
  PWclassid clsid
)
{
  long OMsts=OM_S_SUCCESS;
  PWobjid obj=PW_K_NullObjid;

  OMsts = som_construct_object ((char *) NULL, clsid, PW_K_NullObjid,
                    NULL, os, os, (char *) NULL, &obj, OM_Gp_NULL_MESSAGE, 
                    OM_GS_NULL_NEIGHBOR, (OMuint *) NULL);
  if (!(1&OMsts))
    return PW_K_NullObjid;
  else
    return obj;
}

/*
  ABSTRACT

  This function construct an object in the given object space whose class is
  same as the given object.

  NOTES

  None
*/

PWobjid omCreateObjFromObjid
(
  PWosnum os,
  PWobjid objid
)
{
  long OMsts=OM_S_SUCCESS;
  PWobjid obj=PW_K_NullObjid;
  
  OMsts = som_construct_object ((char *) NULL, OM_K_NOTUSING_CLASSID,
                    objid, NULL, os, os, (char *) NULL, &obj, 
                    OM_Gp_NULL_MESSAGE, OM_GS_NULL_NEIGHBOR, (OMuint *) NULL);

  if (!(1&OMsts))
    return PW_K_NullObjid;
  else
    return obj;
}

 
