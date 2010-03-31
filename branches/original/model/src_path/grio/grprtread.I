class implementation GRgraphics;

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/grprtread.h" 
#include "PWapi/rdminim.h"
#include "PWapi/objcons.h"
#include "PWapi/objquery.h"
#include "PWapi/clsid.h"

/*
  DESCRIPTION
  
  The following function is the API to print a given GRgraphics object in
  ASCII formatted data into a given file. The geometry, when printed, will
  always be in it's native co-ordinates. That is, the printout is a true
  dump of what is stored inside the object. This file can be read back into
  the same object, if the object is found inside the EMS datafile.

  The caller may wish to output the abbreviated format for a given class.
  This may not output all the geometry for instance. Chosing this option
  is accomplished by setting 'full_format' to FALSE. If this data is to be
  read back in, be sure to set the same 'full_format' flag on the read.

  In the case of a compound object, it is possible that more than one object
  is printed out (eg: Boolean tree). There are two ways of handling the 
  printing of such objects --
  1) Each component may be printed out as independent objects which if read
     in one after the other will yield the compound object back again. 
  2) It is also possible that the compound object chooses to dump the contents
     of it's components as one blob of information. In such a case, one would
     say that only one object was written out. 
  It is the prerogative of the object class to decide to adopt (1) or (2) as
  it's formatted representation.

  The only kind of compound object handled is the one with a pure tree-like
  structure (ie, no general graph-type connections are handled).


  NOTES 

  This kind of flexibility of allowing compound objects to print their 
  components either as independent objects or as one cohesive blob provides
  for the ability to code only certain classes within something like a DPR
  tree. 

  Only the 'handled' classes will print out their internals for editing
  purposes. So, the entire DPR tree need not be written in order for only some
  components to be handled. Some of the DPR classes may not chose to recurse
  deeper. Their print can be trivial (one small blob). Others like the Boolean
  class can chose to recurse deeper (individual objects as it recurses down).

  The ids of all the objects being printed (including the component objects
  if this is a compound object as in a composite surface, solid, etc) are
  listed within the file, alongside the respective object's class's
  name. 

  The FILE for printing can also be stdout or stderr.


  HISTORY

  SS   :  02/28/95   :   Creation
*/

PWresult pwPrintObject
(
  PWobjid grobj,
  PWosnum os,
  FILE *file,
  PWboolean full_format
)
{
  PWresult result=PW_K_Success;

  result = om$send (msg = message GRgraphics.GRprint (file, 0, TRUE, 
            full_format), targetid = grobj, targetos = os, 
            senderid = PW_K_NullObjid);
  OnErrorCode (result, wrapup);

wrapup:
  return (result);
}



/*
  DESCRIPTION

  The following function reads in all the objects from a given file. This
  is the top-level API for reading in the ASCII, formatted file. A flag
  is passed in, indicating whether the format is the short or the full one.
  The routine returns the number of objects read in successfully in the 
  output argument -- 'num_objects'. If the other output argument -- 'objects' 
  is non-NULL, then this function will return the objids of all the
  successfully read objects in an array allocated herein.


  NOTES

  Read the description on the helper function -- ReadObject below for some
  more details on the nature of the formatted file vis-a-vis object creation
  and initialization.


  HISTORY

  SS  :  03/21/96  :  Creation
*/

#define BUFF_INCR 20

PWresult pwReadAllObjects
(
  FILE *file,
  PWosnum os,
  PWboolean full_format,
  int *num_objects,
  PWobjid **objects
)
{
  int numobjs;
  PWboolean eof=FALSE;
  PWresult result=PW_K_Success;
  PWobjid readobj, *objsmem;

  *num_objects = 0;
  if (objects)
    *objects = NULL;

  InitNewObjTable();

  do 
  {
    result = ReadObject (file, os, full_format, TRUE, TRUE, &readobj);
    OnErrorCode (result, wrapup);

    if (GetCode (result) == PW_K_Interrupt)
      goto wrapup;

    if (GetCode (result) == PW_K_EndOfData)
      eof = TRUE;
    else
    {
      if (objects)
      {
        objsmem = *objects;
        numobjs = *num_objects;

        if (! (numobjs % BUFF_INCR))
        {
          if (! numobjs)
            objsmem = (PWobjid *) malloc (BUFF_INCR * 
                       sizeof (PWobjid));
          else
            objsmem = (PWobjid *) realloc (objsmem, (numobjs + BUFF_INCR) *
                       sizeof (PWobjid));
          OnErrorState (!objsmem, result, SetError (PW_K_Pathway, 
           PW_K_DynamicMemory), wrapup);
        }

        objsmem[numobjs-1] = readobj;
        *objects = objsmem;
      }
      (*num_objects)++;
    }
  }
  while (!eof);

wrapup:
  DeleteNewObjTable();
  PW_Wrapup (result, "pwReadAllObject");
  return (result);
}



/*
  DESCRIPTION
  
  The following function is used to read in a single object from the given
  file location. The working FILE pointer of the ASCII, formatted data is
  passed in as input. This is not the recommended API to be used when reading
  an entire file. This is more an internal API. Some initialization outside 
  this function is assumed to have been done, which makes this a dangerous
  function to call in a standalone mode.

  The file is searched from it's current location for a line that has the
  following format:
   + classname [objid,osnum]
  where,
  the '+' is a reserved character and must be present. White spaces are ignored
  but are the valid delimiters between the 3 items. The 'classname' is the 
  name of the object's class. 'objid' and 'osnum' are as the names suggest.
  The 'objid' is looked for in the EMS file and verified if it belongs to
  'classname'. If this is not TRUE, then a search of the "new-object table" is
  performed to see if a new object has already been created in it's place.
  If this is also not TRUE (and a new object is allowed to be created), then
  a new object of 'classname' is constructed, added to the "new-object table"
  and this object is returned as the output.

  Unless told otherwise, this function assumes that there is data for the
  object to follow in the file and invokes the object's GRread method to
  read the data.

  If 'full_format' is set to FALSE, then the function knows that there is only
  limited data within the file. Only that part of the object is then 
  initialized with the given data.


  NOTES

  It is possible that the object being read in is a compound object consisting
  of several component objects which are also written out not as independent
  objects but as true components of this class (eg: the reference plane as a
  component of a DPR-feature class). This function will initialize the object
  to be output by reading in all the components and making the necessary 
  connections.


  HISTORY

  SS   :  02/28/95   :   Creation
*/

PWresult ReadObject
(
  FILE *file,
  PWosnum os,
  PWboolean full_format,
  PWboolean create_object_if_needed,
  PWboolean object_data_follows,
  PWobjid *objid
)
{
  char classname[PW_K_MaxStringLen];
  PWresult result=PW_K_Success;
  PWobjid readobj, newobj;
  struct PWid grid;

  *objid = PW_K_NullObjid;

  /*
   * Read the object-id from the file. If EOF, then exit with
   * an informational message.
   */

  OnErrorState (!pwReadId (file, &grid.objid, &grid.osnum, classname), result,
   SetInfo (PW_K_Pathway, PW_K_EndOfData), wrapup);

  /*
   * Process the object-id
   */

  if (omIsObjidValid (grid.objid, grid.osnum) &&
      (omClassidFromObjid (grid.objid, grid.osnum) ==
       omClassidFromName (classname, grid.osnum)))
  {
    /*
     * The object id found in the file is the target to be read into.
     */

    readobj = grid.objid;
  }
  else if (GetCode (GetNewObjFromTable (grid.objid, &newobj)) == PW_K_Found)
  {
    /*
     * The new-object table was looked up and a new object corresponding to
     * the one indicated in the file was found to be already created. Use
     * this as the object to read into.
     */

    readobj = newobj;
  }
  else if (create_object_if_needed)
  {
    /*
     * A new object has to be created of the class that has been read in
     * from the file. This is used as the object to be read into. Also,
     * add this new object to the new-object table.
     */

    newobj = omCreateObjFromClassid (os, omClassidFromName (classname, os));
    OnErrorState (newobj == PW_K_NullObjid, result, SetError (PW_K_OM,
     PW_K_Error), wrapup);

    result = AddNewObjToTable (grid.objid, newobj);
    OnErrorCode (result, wrapup);

    readobj = newobj;
  }
  else
  {
    /*
     * No object has been found and neither can one be created. Return
     * an information code.
     */

    OnErrorState (TRUE, result, SetInfo (PW_K_Pathway, PW_K_NotFound),
     wrapup);
  }

  /*
   * Invoke the class specific read code if the input flag says that
   * there is such that data that follows.
   */

  if (object_data_follows)
  {
    result = om$send (msg = message GRgraphics.GRread (file, TRUE,
              full_format), targetid = readobj, targetos = os, 
              senderid = PW_K_NullObjid);
    OnErrorCode (result, wrapup);
  }

  /*
   * Return the object-id read as the output
   */

  *objid = readobj;

wrapup:
  return (result);
}



/*------------------- FUNCTIONS MANAGING NEW-OBJECT-TABLE ------------
  
  The following functions are not intended as general APIs, but are utility
  functions needed to implement the GRread functionality. They help maintain
  a table consisting of rows of old objects and their new counterparts, 
  created in the process of the read operation.

  --------------------------------------------------------------------*/

%safe
static int _num_newobjs=0;
static PWobjid (*_newobjs)[2]=NULL;
%endsafe

void InitNewObjTable
(
)
{
  if (_newobjs)
    free (_newobjs);
  _newobjs = NULL;
  _num_newobjs = NULL;

  return;
}

void DeleteNewObjTable
(
)
{
  if (_newobjs)
    free (_newobjs);
  _newobjs = NULL;
  _num_newobjs = NULL;

  return;
}

PWresult AddNewObjToTable
(
  PWobjid oldobjid,
  PWobjid newobjid
)
{
  char *mem=NULL;
  PWresult result=PW_K_Success;

  if (! (_num_newobjs % BUFF_INCR))
  {
    mem = (char *) _num_newobjs;
    if (! _num_newobjs)
      mem = (char *) malloc (2 * BUFF_INCR * sizeof (PWobjid));
    else
      mem = (char *) realloc (mem, 2 * (_num_newobjs + BUFF_INCR) * 
             sizeof (PWobjid));
    OnErrorState (!mem, result, SetError (PW_K_Pathway, PW_K_DynamicMemory),
     wrapup);

    _newobjs = (PWobjid (*)[]) mem;
  }

  _newobjs[_num_newobjs][0] = oldobjid;
  _newobjs[_num_newobjs][1] = newobjid;
  _num_newobjs++;

wrapup:
  PW_Wrapup (result, "AddNewObjToTable");
  return (result);  
}


PWresult GetNewObjFromTable
(
  PWobjid oldobjid,
  PWobjid *newobjid
)
{
  PWboolean found=FALSE;
  int i;
  PWresult result;
 
  result = SetInfo (PW_K_Pathway, PW_K_Found);

  for (i=0; i<_num_newobjs; i++)
  {
    if (_newobjs[i][0] == oldobjid)
    {
      *newobjid = _newobjs[i][1];
      found = TRUE;
      break;
    }
  }
  if (!found)
    result = SetInfo (PW_K_Pathway, PW_K_NotFound);

  return (result);  
}

end implementation GRgraphics;
