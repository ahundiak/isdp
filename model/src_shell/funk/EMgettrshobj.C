/* ###################   APOGEE COMPILED   ################## */
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsdef.h"

/*
   DESCRIPTION

     The following function provides a means of quickly obtaining shell
     object-ids for different classes in a transient object-space.
     Any number of objects of a given class may be requested at given
     time. Objects once constructed are repeatedly returned in subsequent
     calls. 

   NOTES

     None of the objects returned by this function should ever be
     deleted. A more general function is EMgetshobj, which interfaces
     with the EMSshobjmgr - the shell object manager.

     The transient object space is assumed to remain in undisturbed existence
     throughout a design session, including all saves, file attachments
     and file closes that may take place within that session.

   EXAMPLES

     To be used as a tool to improve efficiency when the geometry of some
     data that is to be worked upon needs to be inside an object.

   RETURN VALUE

     The return code is 
       - EMS_S_Success, if all went well and the output argument 
          the requested information. 
     On error, the return code is 
       - EMS_E_OMerror, if an OM error occurred.
       - EMS_E_NoDynamicMemory, if malloc or realloc failed.

   HISTORY

     SS  :  04/04/88  :  Creation
     DLB :  10/19/91  :  Bug fix added to objects_memory function.  See
			 inline commens.
*/

/*
 * The number of objects that are stored per class,
 * in statically allocated memory. And the number of classes that are
 * stored in statically allocated memory. Also, the number by which
 * the arrays of objects stored and the array of classes stored must
 * increment, when the time to reallocate or (malloc the first time)
 * comes.
 */


#define NUM_STATIC_OBJECTS  5
#define NUM_STATIC_CLASSES  20
#define INCRSIZE_CLASSES    2

/*
 * The structure that holds the information about the shell-objects
 * of each class.
 */

struct EMStrans_shell_store
  {
  GRclassid classid;
  IGRint numobj;
  GRobjid statobj[NUM_STATIC_OBJECTS];
  GRobjid *memobj;
  };

/*
 * The locally known, static array of the class structures along with
 * control information that indicates how many classes are known.
 * This last piece of information in conjunction with NUM_STATIC_CLASSES,
 * indicates whether the class array is static or malloced. 
 */

static IGRint num_shell_classes = 0;
static struct EMStrans_shell_store stat_shell_store[NUM_STATIC_CLASSES];
static struct EMStrans_shell_store *mem_shell_store = NULL;
static IGRboolean classes_memory(), objects_memory();

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

IGRlong EMgettrshobj (msg, classid, numobj, transobj)
IGRlong *msg;
GRclassid classid;
IGRint numobj;
struct GRid *transobj;
{
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRlong EMgettrshobj_byinx();

  for (i=0; i<numobj; i++)
    {
    stat_OM = EMgettrshobj_byinx (&msg_loc, classid, i, &transobj[i]);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  return (stat_OM);
}


/*
 * This function can be called independently if needed. It is intended
 * as a helper function to the one above. This function treats transient
 * shell objects of a particular class as present in an array. Given the
 * index into the array, the appropriate object is returned. If the
 * array is smaller than the index specified, more transient objects are
 * generated to fill up the array so as to match the size.
 */

IGRlong EMgettrshobj_byinx (msg, classid, objinx, transobj)
IGRlong *msg;
GRclassid classid;
IGRint objinx;
struct GRid *transobj;
{
  IGRboolean stat_func, classfound;
  IGRint classinx, numknownobj, i;
  IGRlong stat_OM;
  GRobjid *objbuff;
/*  GRclassid flagclass;--- NOT USED */
  struct EMStrans_shell_store *classbuff;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * The static data is either correct or has been initialized to
   * start-up. Proceed to obtain the object-id requested.
   */

  if (num_shell_classes <= NUM_STATIC_CLASSES)
    classbuff = stat_shell_store;
  else
    classbuff = mem_shell_store;

  /*
   * Check to see if the class requested is already
   * known.
   */

  classfound = FALSE;
  for (classinx=0; classinx<num_shell_classes; classinx++)
    {
    if (classbuff[classinx].classid == classid)
      {
      classfound = TRUE;
      break;
      }
    }

  if (!classfound)
    {
    /*
     * There is no such class known yet.
     * Data containing the class information must be
     * updated, after making room for one more class.
     */

    stat_func = classes_memory (classinx, &classbuff);
    EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, ret_end);

    classbuff[classinx].classid = classid;
    num_shell_classes++;
    }

  /*
   * Obtain the object-id buffer for this particular class (increasing it's 
   * size if needed). This buffer contains the object-ids of this
   * class that have thus far been created.
   */
   
  stat_func = objects_memory (objinx+1, classinx, classbuff, &objbuff);
  EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, ret_end);

  numknownobj = classbuff[classinx].numobj;
  if (objinx+1 > numknownobj)
    {
    /*
     * The array of known objects must be brought up to a sufficient size
     * to allow for indexing as specified. The remaining objects are
     * created and the control data updated.
     */

    for (i=numknownobj; i<objinx+1; i++)
      {
      stat_OM = om$construct (classid = classid, osnum = OM_Gw_TransOSnum_0,
                 p_objid = &objbuff[i]);
      EMomerr_exit (stat_OM, ret_end);

      classbuff[classinx].numobj++;
      }
    }

  /*
   * The object id is returned by indexing into the 
   * objects-array.
   */

  transobj->objid = objbuff[objinx];
  transobj->osnum = OM_Gw_TransOSnum_0;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgettrshobj_byinx");
  return (stat_OM);
}


/*
 * Locally used functions in the above
 * main function. Not for public use.
 */

static IGRboolean classes_memory (classinx, classbuff)
IGRint classinx;
struct EMStrans_shell_store **classbuff;
{
  IGRboolean stat_func;
  IGRint i;

  stat_func = TRUE;

  if (num_shell_classes+1 > NUM_STATIC_CLASSES &&
      !((num_shell_classes-NUM_STATIC_CLASSES) % INCRSIZE_CLASSES))
    {
    if (!mem_shell_store)
      {
      mem_shell_store = (struct EMStrans_shell_store *) om$malloc
        (size = (NUM_STATIC_CLASSES + INCRSIZE_CLASSES) *
        sizeof (struct EMStrans_shell_store));
      OM_BLOCK_MOVE (stat_shell_store, mem_shell_store, NUM_STATIC_CLASSES *
       sizeof (struct EMStrans_shell_store));
      *classbuff = mem_shell_store;
      }
    else
      {
      mem_shell_store = (struct EMStrans_shell_store *) om$realloc
        (size = (num_shell_classes + INCRSIZE_CLASSES) *
        sizeof (struct EMStrans_shell_store), ptr = (IGRchar *) mem_shell_store);
      }
    EMerr_hndlr (!mem_shell_store, stat_func, FALSE, ret_end);

    for (i=classinx; i<num_shell_classes+INCRSIZE_CLASSES; i++)
      (*classbuff)[i].numobj = 0;
    }

ret_end:
  return (stat_func);
}


static IGRboolean objects_memory (num_needed, classinx, classbuff, objbuff)
IGRint num_needed, classinx;
struct EMStrans_shell_store *classbuff;
GRobjid **objbuff;
{
  IGRboolean stat_func;
  IGRint  numobj;
  GRobjid *buffmem;

  stat_func = TRUE;

  numobj = classbuff[classinx].numobj;
  if (num_needed > NUM_STATIC_OBJECTS)
    {
    if (num_needed > numobj)
      {
      buffmem = (GRobjid *) om$malloc (size = num_needed * sizeof (GRobjid));
      EMerr_hndlr (!buffmem, stat_func, FALSE, ret_end);

      if (numobj)
      {
        if (numobj > NUM_STATIC_OBJECTS)
        {
          OM_BLOCK_MOVE(classbuff[classinx].memobj, buffmem,
  	                numobj * sizeof (GRobjid));
        }
        else  /*Added else (move statobj) - DLB 10/19/91*/
        {
          OM_BLOCK_MOVE(classbuff[classinx].statobj, buffmem,
  	                numobj * sizeof (GRobjid));
        } 
      }

      if (numobj > NUM_STATIC_OBJECTS)
        om$dealloc (ptr = classbuff[classinx].memobj);
      classbuff[classinx].memobj = buffmem;
      }
    *objbuff = classbuff[classinx].memobj;
    }
  else
    *objbuff = classbuff[classinx].statobj;

ret_end:
  return (stat_func);
}
