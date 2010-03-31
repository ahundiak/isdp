#include "OMminimum.h"
#include "OMerrordef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/clsid.h"

/*
  ABSTRACT

  This function outputs the active classid given the objid and it's
  object space number. If the objid is invalid, PW_K_NullClass is returned.
*/

PWclassid omClassidFromObjid
(
  PWobjid objid,
  PWosnum osnum
)
{
  PWclassid classid=PW_K_NullClass;

  som_get_classid (osnum, (char *) NULL, objid, (OM_p_OBJECTHDR) NULL,
   &classid);

  return (classid);
}



/*
  ABSTRACT

  This function finds the classname given the classid of an object. The
  object space in which this classname is defined is also input.
  The size of the string to hold the classname must be PW_K_MaxStringLen long.
  If successful, the pointer to the input string that contains the classname
  will be returned. On failure, a NULL pointer is returned.
*/

char *omClassNameFromClassid
(
  PWclassid classid,
  PWosnum osnum,
  char *classname
)
{
  PWresult result=PW_K_Success;

  result = som_get_classname (osnum, classid, NULL_OBJID, 
            (OM_p_OBJECTHDR) NULL, classname);
  if (IsError (result))
    return (char *) NULL;
  else
    return classname;
}

/*
  ABSTRACT

  This function returns the active classid given the classname and the
  relevant object space. If the classname is invalid, PW_K_NullClass is
  returned.
*/

PWclassid omClassidFromName
(
  char *classname,
  PWosnum osnum
)
{
  PWclassid classid=PW_K_NullClass;

  som_get_classid (osnum, classname, NULL_OBJID, (OM_p_OBJECTHDR) NULL,
   &classid);

  return (classid);
}


/*
  ABSTRACT

  Tests whether or not a super class is in the ancestry of a subclass. The
  inputs are the classids of the super class and the subclass. If the subclass
  is in the ancestry, this function will return TRUE. If not (or if the
  classids are invalid), this function will return FALSE.
*/

PWboolean omIsAncestryValid 
(
  PWclassid subclassid,
  PWclassid superclassid
)
{
  return (som_is_ancestry_valid (subclassid, superclassid,
          (char *) NULL, (char *) NULL) == OM_S_SUCCESS);
}
