/* $Id: VD_EFaction.I,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/*************************************************************************
 * I/VDS>
 *
 * File:        vdintf/cmd/VD_EFaction.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VD_EFaction.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  23:23:20  pinnacle
# UnInit Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/04/23  22:54:10  pinnacle
# Created: vdintf/cmd/VD_EFaction.I by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *	04/23/96   HF		Creation date
 *				Overwrite of EFlocate_action_handler() in
 *				order to handle correctly the dynamic
 *				"struct	VDSaction_handler *do_not_locate"
 *	10/30/97   ah		Warning message
 *************************************************************************/

/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function is the I/EMS default action handler.  It should be
 used in place of the default action handler when ever a command
 locates multiple objects and the same object can not be located
 more than once.  The optional argument is used to specify a
 list of objects that are not to be located, presumeably because
 they have already been located by the command.

 History

 09/16/88 : rlw : Creation date
 09/26/88 : rlw : Added option such that one can say only allow elements
                  in the list.  Also added ability to specify a linked
                  list of option lists.
 11/11/88 : pp  : Added option to locate / not locate objects of a given
                  class. I am forced to do this as the locate filter does
                  not support this.
 12/01/88 : rlw : Modified to call the default LCptlocact action handler
                  as opposed to LCaccact.  This is required because
                  model space counterparts have some problem with LCaccact.
 08/08/89 : pp  : Added option to locate / not locate objects whose
                  active ids are of given classids.
 */

class implementation GRvg;

%safe
#include <math.h>
%endsafe

#include "EMS.h"			/* Shared library stuff */
#include "ems_m_inc.h"			/* Includes everything */
#include "VDSaction.h"			/* Action handler stuff */

#ifndef IDRAW
 from EMSsurface import EMgetactiveid;
#endif

VD_EFlocate_action_handler(
 do_not_locate,
 new_entry,
 locate_args,
 action)

struct	VDSaction_handler *do_not_locate;
struct	GRlc_info *new_entry;
struct	LC_action_args *locate_args;
enum	GRlocate_action *action;

{
 IGRboolean	call_action_handler;
 IGRlong	sts;
/*
 * Initialize
 */
 call_action_handler = TRUE;
/*
 * If the action is to add then first check to see
 * if the command object already has the object.  If
 * so then we don't want to go through the accept/reject
 * handler.
 */
 switch (*action)
  {
   case add_all:
   case add_inside:
   case add_outside:
   case add_overlap:
   case add_nopost:
   {
    if ((do_not_locate->option == 0) || (do_not_locate->option == 1))
    {
/*
 * If the option is to locate/not locate objects belonging to the incoming
 * list.
 */
     IGRlong	i;
//   struct	GRlc_info *object;
     struct	GRid check_id, *search_id;

     search_id = &new_entry->located_obj;
     check_id.osnum = do_not_locate->objects.same_space.space_number;
     for (i = 0;
          (i < do_not_locate->num_objects) && call_action_handler;
          i++)
      {
       switch (do_not_locate->type)
        {
         case 0:
          check_id = do_not_locate->objects.lc_info[i]->located_obj;
          break;
         case 1:
          check_id = do_not_locate->objects.id[i];
          break;
         case 2:
          check_id.objid = do_not_locate->objects.same_space.objid[i];
          break; 
        } /* switch (do_not_locate->type) */

       if ((check_id.objid == search_id->objid) &&
           (check_id.osnum == search_id->osnum))
        call_action_handler = FALSE;
      } /* for (i = 0; i < dont_locate->num_objects; i++) */
/*
 * If we are only locating elements in the list then 
 * toggle the status of calling the action handler.
 */
     if ((do_not_locate->option == 1) &&
         do_not_locate->num_objects)
      call_action_handler = (! call_action_handler);
/*
 * If we determined that the element was OK and there is
 * another option list then process this list
 */
    }
    else if ((do_not_locate->option == 2) || (do_not_locate->option == 3)
              || (do_not_locate->option == 4)  
              || (do_not_locate->option == 5))
    {
/*
 * If the option was to locate/not locate objects belonging to a particular
 * class.
 */


     IGRlong	i,loc_msg;
     OMuword search_classid, check_classid;
     struct GRid *search_id;
     struct GRid active_id;
     IGRboolean dont_locate;
 
     search_id = &new_entry->located_obj;

#ifndef IDRAW
     if ((do_not_locate->option == 4) || (do_not_locate->option == 5))
     {
      sts = om$send (msg = message EMSsurface.EMgetactiveid(&loc_msg,&active_id,
                            NULL),
                     senderid = NULL_OBJID,
                     targetid = search_id->objid,
                     targetos = search_id->osnum);
      if (!(1&sts&loc_msg))
      {
       call_action_handler = FALSE;
       sts = OM_S_SUCCESS;
      }

      search_id = &active_id;
     }
#endif

     if ((do_not_locate->option == 2) || (do_not_locate->option == 4))
      dont_locate = TRUE;
     else 
      dont_locate = FALSE;

     for (i=0;i<do_not_locate->num_objects;i++)
     {
       check_classid = do_not_locate->objects.classids[i];

       sts = om$get_classid(objid = search_id->objid,
                            osnum = search_id->osnum,
                            p_classid = &search_classid);
       if (!(1&sts)) return (sts);

       sts = om$is_ancestry_valid (subclassid = search_classid,
                                   superclassid = check_classid);
       if (sts == OM_S_SUCCESS)
       {
        call_action_handler = (dont_locate ?  FALSE : TRUE );
        break;
       }
       else if (sts == OM_I_INVANCESTRY)
       {
        call_action_handler = (dont_locate ?  TRUE : FALSE);
        sts = OM_S_SUCCESS;
        break;
       }
       else
       {
       /*
        * If there is an error in getting the ancestry do not locate
        * the said object.
        */
        call_action_handler = FALSE;
        sts = OM_S_SUCCESS;
        break;
       }
     }
   }

    if (call_action_handler &&
         do_not_locate->next)
     {
       sts = VD_EFlocate_action_handler(
        do_not_locate->next,
        new_entry,
        locate_args,
        action);
       return(sts);
     }
    }
    break;
/*
 * If the action is not to add then let the
 * regular action handler take care of the 
 * situation.
 */
   case start_transition:
   case end_transition:
   case post_object:
   case check_object:
    break;
  } /* switch (*action) */
/*
 * Call the action handler
 */
 if (call_action_handler)
  {
   extern IGRlong LCptlocact();

   sts = LCptlocact(NULL, new_entry, locate_args, action);
  }
 else
  sts = OM_S_SUCCESS;
/*
 * Eof
 */
 return(sts);
}

end implementation GRvg;
