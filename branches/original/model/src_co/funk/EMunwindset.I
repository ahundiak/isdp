class implementation GRvg;

from GRowner import GRget_number_components, GRget_components,
                    GRget_locate_properties, GRget_context;
from GRgrset import GSinqcount, GSget_object;

extern OMuword	OPP_GRowner_class_id, OPP_GRgrset_class_id,
                OPP_EMScomposite_class_id, OPP_GRsmhdr_class_id;


#include "msdef.h"		/* MSSUCC, MSFAIL */
#include "maerr.h"		/* MANOMEMORY */
#include "grgs.h"		/* GRobj_env */
#include "grownerdef.h"		/* GR_LC_RIGID */
#include "grgsmacros.h"		/* gr$gsget_fence() macro */
#include "OMmacros.h"		/* OM_BLOCK_MOVE() macro */
#include "emsdef.h"		/* GRcmpowner_to_components */
#include "emserr.h"		/* EMSerror macro */

#define A_EMS_GROUP	1
#define A_NORMAL_OBJECT	2
#define A_IGE_GROUP	3

/*

Name
  EMunwind_stupid_sets

Abstract

Synopsis

 INPUT ARGUMENTS

 set_object
  The object which you desire to be dissected.
 break_down_composites
  If TRUE then EMScomposite objects will be broken down into it's
  members.  This option is provided to support commands such as
  change rule line display and toggle polygon.  Ordinarly one
  should not change elements of a rigid composite.
 is_operation_readonly
  Are you just going to do read operations on the objects I return you.
  If so then I will dissect cells and other rigid IGE sets, if not
  then I will return you the rigid set objects.
 my_stupid_id
  Your id.  Used so that I can pretend I am you.

 OUTPUT ARGUMENTS

 number_of_objects
  Total count of objects returned.
 objects
  The objects themselves.
 msg
  Error return code.  The usual (1 & msg) should work fine.

Description

 Given an object, which may be a graphic group or graphics set, this
 routine will return a list of member objects.  It is intended that
 this be used to break down sets into curves, surfaces, and composites.

Return Value

Notes

Index

Keywords
  graphic-set

History
 04/25/88 : rlw : Creation date
 06/15/88 : rlw : Modified the way I get the components from an owner,
                  because EMScomposite class do not support returning
                  the i(th) child, i.e. they recurse and return all
                  components in one shot.
 09/01/88 : rlw : Allen found that I was not freeing all the memory and
                  I have repaired this damage.  Also modified to ensure
                  that owners having one child are properly processed.
 02/22/89 : rlw : Added addition error return code checks because GR*
                  family of methods sometimes return failure msg but OK sts.
 03/24/89 : rlw : Sunit reported that I was not initializing the counts
                  properly.
 04/13/89 : rlw : Modified not to return the fence object.
 06/07/89 : DLB : Changed '==' to '='.
 05/28/90 : SM  : Added code to handle symbols correctly.
 04/16/93 : AIC : Compare structure fields rather than use memcmp.
 04/19/93 : Allen I Clark : Modified header to conform with RELAX standard.
 */
IGRlong EMunwind_stupid_sets(
 set_object,
 break_down_composites,
 is_operation_readonly,
 my_stupid_id,
 number_of_objects,
 objects,
 msg)

struct   	GRlc_info *set_object;
IGRboolean	break_down_composites;
IGRboolean	is_operation_readonly;
OM_S_OBJID	my_stupid_id;
IGRlong  	*number_of_objects;
struct   	GRlc_info **objects;
IGRlong  	*msg;
{
 OMuword 	class_id;
 IGRlong	sts, i, processed;
 struct		GRid set_id;
/*
 * Initailize
 */
 *msg = MSSUCC;
 *objects = NULL;
 *number_of_objects = 0;
 set_id = set_object->located_obj;
/*
 * Determine the classid of the input object
 */
 sts = om$get_classid(
   osnum = set_id.osnum,
   objid = set_id.objid,
   p_classid = &class_id);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Is it a group?
 */
 sts = om$is_ancestry_valid(
   subclassid = class_id, 
   superclassid = OPP_GRowner_class_id);
 if (sts == OM_S_SUCCESS)
  {
/*
 * If the set is a valid EMScomposite then break no further,
 * otherwise it is probably a graphic group or cell and we
 * wish to break it up.
 */
   sts = om$is_ancestry_valid(
     subclassid = class_id, 
     superclassid = OPP_EMScomposite_class_id);
   if (sts == OM_S_SUCCESS)
    {
     if (break_down_composites)
      processed = A_IGE_GROUP;		/* Creative lying */
     else
      processed = A_EMS_GROUP;
    }
   else if (is_operation_readonly)
    {
     sts = om$send(msg = message GRowner.GRget_number_components(msg,
            (IGRint *)number_of_objects), senderid = my_stupid_id,
            targetid = set_id.objid, targetos = set_id.osnum);
     if (*number_of_objects >= 1 || EMSerror (sts)  || EMSerror (*msg))
       processed = A_IGE_GROUP;
     else     
       processed = A_NORMAL_OBJECT;
    }
   else
    {
     IGRint	properties;

     sts = om$send(
       msg = message GRowner.GRget_locate_properties(
        msg,
        &properties),
       senderid = my_stupid_id,
       targetid = set_id.objid,
       targetos = set_id.osnum);
      if ((! (1 & sts))  ||
          (! (1 & *msg)))
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     if (properties & GR_LC_RIGID)
      processed = A_NORMAL_OBJECT;
     else
      processed = A_IGE_GROUP;
    }
/*
 * Break it up if it is a flexible IGE group
 *
 * 06/15/88 : rlw : Took get components out of loop
 */
   if (processed == A_IGE_GROUP)
    {
     IGRint	number_of_objects_returned;
     struct	GRid *temp_ids;

     /* If we have a symbol,  get the context information and process the
        symbol definition header as a rigid owner, with the new context.
        SM 28-May-90.
     */
     sts = om$is_ancestry_valid(
           subclassid = class_id, 
           superclassid = OPP_GRsmhdr_class_id);
     if (sts == OM_S_SUCCESS)
      {
	struct GRmd_env new_env;
        OM_S_CHANSELECT to_comps;
        OM_S_OBJECT_LINKAGE smdfhdr;

       sts = om$send(
         msg = message GRowner.GRget_context(
               msg,
               &set_object->module_info, 	/* old module env */
               &new_env),			/* New context for comps*/
         senderid = my_stupid_id,
         targetid = set_id.objid,
         targetos = set_id.osnum);
        if(!(1 & *msg & sts))
         {
          *msg = MSFAIL;
          goto wrapup;
         }
        *objects = (struct GRlc_info *) malloc(sizeof(struct GRlc_info));
        if (! *objects)
         {
          *msg = MANOMEMORY;
          goto wrapup;
         }
        EMmake_chanselect(GRcmpowner_to_components, &to_comps);
        /* get the symbol definition header object
        */
        sts = om$get_channel_objects(objid = set_id.objid, 
                                     osnum = set_id.osnum, 
                                     p_chanselect = &to_comps, 
                                     list = &smdfhdr, size = 1, 
                                     count = (IGRuint *)number_of_objects);
        if(!(1&sts) || !(*number_of_objects)) 
         {
          *msg = MSFAIL;
          goto wrapup;
         }
        (*objects)[0].located_obj.objid = smdfhdr.S_objid;
        (*objects)[0].located_obj.osnum = smdfhdr.osnum;
        (*objects)[0].module_info = new_env;
	
	/* Let it fall through to the switch statement so that the function
           will get called recursively with the new matrix and set object.
        */
      }
     else
      {
       sts = om$send(
         msg = message GRowner.GRget_number_components(
         msg,
          (IGRint *)number_of_objects),
         senderid = my_stupid_id,
         targetid = set_id.objid,
         targetos = set_id.osnum);
        if ((! (1 & sts))  ||
          (! (1 & *msg)) ||
          (*number_of_objects < 1))
         {
          *msg = MSFAIL;
          goto wrapup;
         }
        *objects = (struct GRlc_info *) malloc(*number_of_objects * 
        sizeof(struct GRlc_info));
        if (! *objects)
         {
          *msg = MANOMEMORY;
          goto wrapup;
         }
        temp_ids = (struct GRid *) malloc(*number_of_objects * 
          sizeof(struct GRid));
        if (! temp_ids)
         {
          *msg = MANOMEMORY;
          goto wrapup;
         }
        number_of_objects_returned = 0;
        sts = om$send(
           msg = message GRowner.GRget_components(
           msg,
           &set_object->module_info,	/* Module info */
           temp_ids,			/* Resulting ids */
           *number_of_objects,		/* Maximum list size w.r.t. id's */
           &number_of_objects_returned,	/* Number got */
           0, *number_of_objects - 1),	/* From, to */
         senderid = my_stupid_id,
         targetid = set_id.objid,
         targetos = set_id.osnum);
         if ((! (1 & sts)) ||
            (! (1 & *msg)))
          {
           *msg = MSFAIL;
           free(temp_ids);
           goto wrapup;
          }
         if (*number_of_objects != number_of_objects_returned)
          {
           *msg = MSFAIL;
           free(temp_ids);
           goto wrapup;
          }
         for (i = 0; i < number_of_objects_returned; i++)
          {
           (*objects)[i].located_obj = temp_ids[i];
           (*objects)[i].module_info = set_object->module_info;
          } /* for (i = 0; i < number_of_objects_returned; i++) */
         free(temp_ids);

      } /* if not a symbol */

    } /* if (processed == A_IGE_GROUP) */
  } /* if (sts == OM_S_SUCCESS) */
/*
 * Is it a fence?
 */ 
 else
  {
   sts = om$is_ancestry_valid(
     subclassid = class_id, 
     superclassid = OPP_GRgrset_class_id);
   if (sts == OM_S_SUCCESS)
    {
     IGRlong	loc_msg;
     IGRint     object_count;
     IGRint     number_of_objects_returned;
     struct	GRid fence_id;
     struct	GRobj_env yet_another_lcinfo;

     processed = A_IGE_GROUP;
     object_count = 0;
     sts = om$send(
       msg = message GRgrset.GSinqcount(
        msg,
        &object_count),
       senderid = my_stupid_id,
       targetid = set_id.objid,
       targetos = set_id.osnum);
      if ((! (1 & sts))  ||
          (! (1 & *msg)) ||
          (object_count < 1))
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     *objects = (struct GRlc_info *) malloc(object_count * 
       sizeof(struct GRlc_info));
      if (! *objects)
       {
        *msg = MANOMEMORY;
        goto wrapup;
       }
     gr$gsget_fence(		/* Get the active fence id, if any */
       msg = &loc_msg,
       fence_id = &fence_id);
      if (! (1 & loc_msg))
       {
        fence_id.objid = NULL_OBJID;
        fence_id.osnum = 0;
       }
     for (i = 0; i < object_count; i++)
      {
       number_of_objects_returned = 0;
       sts = om$send(
         msg = message GRgrset.GSget_object(
          msg,
          &yet_another_lcinfo,
          sizeof(struct GRobj_env),
          &number_of_objects_returned,
          i, i),			/* From i To i */
         senderid = my_stupid_id,
         targetid = set_id.objid,
         targetos = set_id.osnum);
        if ((! (1 & sts))  ||
            (! (1 & *msg)) ||
            (number_of_objects_returned != 1))
         {
          *msg = MSFAIL;
          goto wrapup;
         }
       if (! ((yet_another_lcinfo.obj_id.objid == fence_id.objid) &&
              (yet_another_lcinfo.obj_id.osnum == fence_id.osnum)))
        {
         (*objects)[*number_of_objects].located_obj = 
          yet_another_lcinfo.obj_id;
         (*objects)[*number_of_objects].module_info = 
          yet_another_lcinfo.mod_env;
         *number_of_objects = *number_of_objects + 1;
        }
      } /* for (i = 0; i < object_count; i++) */
     if (*number_of_objects == 0)
      {
       free(*objects);
       *objects = NULL;
      } /* if (*number_of_objects == 0) */
    } /* if (sts == OM_S_SUCCESS) */
/*
 * It must just be a normal object
 */
   else
    processed = A_NORMAL_OBJECT;
  }
/*
 * Process based on the type of object we found
 */
 switch (processed)
  {
   case A_EMS_GROUP:
   case A_NORMAL_OBJECT:
    *objects = (struct GRlc_info *) malloc(sizeof(struct GRlc_info));
     if (! *objects)
      {
       *msg = MANOMEMORY;
       goto wrapup;
      }
    *number_of_objects = 1;
    (*objects)[0] = *set_object;
    break;
/*
 * If we processed a group then we must recurse and
 * process the members of the group in order to ensure that
 * we break this stuff up as small as possible.
 */
   case A_IGE_GROUP:
    {
     IGRlong	number_of_pieces;
     struct	GRlc_info *pieces;

     for (i = 0; i < *number_of_objects; )
      {
       sts = EMunwind_stupid_sets(
         &(*objects)[i],
         break_down_composites,
         is_operation_readonly,
         my_stupid_id,
         &number_of_pieces,
         &pieces,
         msg);
        if (! (1 & *msg))
         {
          if (pieces) free(pieces);
          goto wrapup;
         }
/*
 * If there is only 1 piece and it is the same object
 * we sent in then we should go on to the next object.
 * If there is only 1 piece and it is a different object
 * we replace this object and process the new object.
 * Note that I am assuming that an object cannot own itself.
 */
        if (number_of_pieces == 1)
         {
          if (((*objects)[i].located_obj.objid == pieces[0].located_obj.objid) &&
              ((*objects)[i].located_obj.osnum == pieces[0].located_obj.osnum))
           i++;
          else
           (*objects)[i] = pieces[0];   /*Changed from == to = -DLB*/
         }
/*
 * If the object broke up into smaller pieces then
 * we must insert this data into the list.
 */
        else
         {
          IGRlong	new_total, amount_to_move;

          new_total = *number_of_objects + number_of_pieces - 1;
          *objects = (struct GRlc_info *) realloc(
             *objects,
             sizeof(struct GRlc_info) * new_total);
           if (! *objects)
            {
             free(pieces);
             *msg = MANOMEMORY;
             goto wrapup;
            }
/*
 * Move the old data down to create space for the new
 */
          amount_to_move = *number_of_objects - i - 1;
          if (amount_to_move)		/* Zero if at end of list */
           {
            IGRlong	new_position;

            new_position = i + number_of_pieces;
            OM_BLOCK_MOVE(
             &(*objects)[i + 1],
             &(*objects)[new_position],
             amount_to_move * sizeof(struct GRlc_info));
           }
/*
 * Move the new data into the space created
 */
          OM_BLOCK_MOVE(
           pieces,
           &(*objects)[i],
           number_of_pieces * sizeof(struct GRlc_info));
/*
 * Adjust the total count.
 */
          *number_of_objects = new_total;
         } /* ELSE FOR if (number_of_pieces == 1) */
        if (number_of_pieces) free(pieces);	/* rlw - 09/01/88 */
      } /* for (i = 0; i < *number_of_objects; ) */
    }
    break;
  } /* switch (processed) */
/*
 * eof
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  {
   if (*objects)
    {
     free(*objects);
     *objects = NULL;
    }
   *number_of_objects = 0;
   return(FALSE);
  }
}

end implementation GRvg;
