/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method is called to return a shell object of a specified class.
    Such an object might have been freshly created or may be an
    existing one. The watermark stored in this manager object, determines
    when a new object is to be created.

    A pointer to a validator function is accepted that checks if a shell
    object, that was created earlier, can now be reused. This function
    takes in two arguments by address - an address to an IGRlong for the
    return code and the address to the GRid of the shell object
    that is to be validated. If this function pointer is NULL a default
    validator function - EMisshellvalid - gets called.
    
    If the option EMSshell_classvfunc is used then the validator function
    argument is used for a different purpose. The array of the set of objects
    for the specified class are passed in as the first arguement and the
    valid_args is passed in as the second. The method will send this
    same message to the overflow objects and exit after that.

  NOTES

    When it is decided to pick up an existing object and return it
    as the shell, some checks are performed on the object-id. The trivial
    ones are -
      a) whether the object-id is still valid, 
      b) whether the object-id is of the same class as requested.

    The default validator function - EMisshellvalid -  checks to
      a) see if the candidate shell has any objects on the
         GRconnector.to_owners channel. If such a channel does not exist,
         this check is ignored.
      b) see if the candidate shell has any objects on the
         GRnotify.notification channel. If such a channel does not exist,
         this check is ignored.
    
    If any of these checks fail this object ceases to be a candidate for
    being a shell and a different object is searched out (or created).
    Any other reason for change of status of the object-id is the 
    responsibility of the user.

  HISTORY
    
    SS  :  09/29/89  :  Added the option EMSshell_check.
    SS  :  08/17/88  :  Modified argument list to support constructor-function
                        and to specify arguments to constructor and the
                        validator functions.
    SS  :  04/07/88  :  Creation
*/

class implementation EMSshobjmgr;

#include "EMS.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgetshobj (IGRlong *msg; GRclassid classid; 
                   IGRushort options; IGRchar *const_args;
                   IGRboolean (*constfunc)(); IGRchar *valid_args;
                   IGRboolean (*validfunc)(); GRobjid *shellobj)
{
  IGRboolean (*vfunc)(), stat_func;
  IGRboolean classfound, objfound, objvalid, objconst;
  IGRint classinx, size, numclasses, numobjects;
  IGRint outinx, startinx, i, blksize, vident;
  IGRlong msg_loc, stat_OM, shell_msg;
  GRobjid tmpobjid;
  GRclassid shclassid;
  struct GRid shellid;
  OM_S_CHANSELECT chan_to_overflow;
  extern IGRboolean EMisshellvalid();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  numclasses = me->numclasses;
  numobjects = me->numobjects;

  vfunc = validfunc ? validfunc : EMisshellvalid;

  /*
   * Check to see if the class being requested is
   * already in the instance data. If the option is to simply
   * check for the given shellobjs existence, and if the class is
   * not found, return EMS_I_NotFound.
   */

  classfound = FALSE;
  for (classinx=0; classinx<numclasses; classinx++)
    { 
    if (me->classids[classinx] == classid)
      {
      classfound = TRUE;
      break;
      }
    }

  if (options & EMSshell_check || options & EMSshell_classvfunc)
    {
    if (!classfound)
      {
      *msg = EMS_I_NotFound;
      goto ret_end;
      }
    else
      {
      startinx = 0;
      for (i=0; i<classinx; i++)
        startinx += me->numobjclass[i];

      if (options & EMSshell_classvfunc)
        {
        stat_func = (*vfunc)(me->numobjclass[classinx], &me->objects[classinx],
                     valid_args);
        EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

        stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow,
                   &chan_to_overflow);
        EMomerr_exit (stat_OM, ret_end);
  
        stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_overflow);
        }
      else
        {
        objfound = FALSE;
        for (i=startinx; i<startinx + me->numobjclass[classinx]; i++)
          if (IF_EQ_OBJID (*shellobj, me->objects[i]))
            {
            objfound = TRUE;
            break;
            }

        if (objfound)
          {
          *msg = EMS_I_Found;
          stat_OM = OM_I_STOP_SENDING;
          }
        else
          {
          stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow,
                     &chan_to_overflow);
          EMomerr_exit (stat_OM, ret_end);
  
          *msg = EMS_I_NotFound;
          stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_overflow);
          }
        }
      }
    }
  else if (!classfound || me->numobjclass[classinx] < me->watermark ||
           options & EMSshell_create)
    {
    /*
     * There is no such class known yet; or the watermark has not been
     * reached yet; or the option mask indicates explicitly that an
     * object needs to be created. So, create an object of this class
     * and update the instance data. Return this new-object as the result
     * object.
     */

    if (constfunc)
      {
      objconst = (*constfunc) (&msg_loc, const_args, &shellid);
      EMerr_hndlr (EMSerror (msg_loc) || !objconst, *msg, EMS_E_Fail,
       ret_end);
      *shellobj = shellid.objid;
      }
    else
      {
      stat_OM = om$construct (classid = classid, p_objid = shellobj);
      EMomerr_exit (stat_OM, ret_end);
      }

    stat_OM = om$send (msg = message EMSshobjmgr.EMputshobj (&msg_loc,
               *shellobj, vfunc), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    {
    /*
     * The watermark has been reached for this class. A LIFO algorithm is
     * applied to return an existing shell object. The most recently allocated
     * object is at the very start of the block of objects for this class.
     * So, the checks are performed on the last object in the class. If it
     * fails any of them it is deleted from the store, but added into the
     * overflow object associated with this shell-manager. This
     * addition is not performed if any error is associated with the shell-
     * object. And the method is called again recursively.
     */

    startinx = 0;
    for (i=0; i<classinx; i++)
      startinx += me->numobjclass[i];
    outinx = startinx + (me->numobjclass[classinx]-1);

    *shellobj = me->objects[outinx];

    stat_OM = om$get_classid (objid = *shellobj, p_classid = &shclassid);
    if (EMSerror (stat_OM) || shclassid != classid)
      {
      shell_msg = EMS_E_InvalidCase;
      objvalid = FALSE;
      }
    else
      {
      shellid.osnum = OM_Gw_current_OS;
      shellid.objid = *shellobj;
      objvalid = (*vfunc) (&shell_msg, valid_args, &shellid, FALSE, &vident);
      }

    if (!objvalid)
      {
      /*
       * This object-id being invalid as a shell object-id,
       * it is removed from this managers data base. At the same
       * time this entry is stored away in an associated overflow object.
       * This is done so that post-processing on the objects removed
       * is possible at any time. But if any error is associated with
       * this shell object, this object is not put into the overflow.
       * Then, a different shell object is then sought by a recursive call.
       */

      stat_OM = om$send (msg = message EMSshobjmgr.EMremshobj (&msg_loc,
                 *shellobj), targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      if (!EMSerror (shell_msg))
        {
        stat_OM = om$send (msg = message EMSshobjmgr.EMputovflow (&msg_loc,
                   *shellobj, vfunc), targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }

      stat_OM = om$send (msg = OPPmargs, targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (*msg), *msg, *msg, ret_end);
      }
    else
      {
      /*
       * This object is to be returned as the desired shell-
       * object. The LIFO queue is updated by moving this
       * object-id to the start of the class.
       */

      blksize = (me->numobjclass[classinx]-1) * sizeof (GRobjid);
      if (blksize)
        {
        OM_BLOCK_MOVE (&me->objects[startinx], &me->objects[startinx+1],
         blksize);
        me->objects[startinx] = *shellobj;
        }
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSshobjmgr.EMgetshobj");
  return (stat_OM);
}

end implementation EMSshobjmgr;
