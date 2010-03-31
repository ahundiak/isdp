/*
  DESCRIPTION

    This function adds on new elements to an existing or a NULL list.
    The element added is intialized with the input passed in. 

    The "positioned" option requires some elaboration. If this is set to TRUE,
    it is being implied that the list-pointer being input is set to
    the node that simply requires initialization. A NULL-list-pointer with
    this option is therefore an invalid argument.

    If this option is set to FALSE, this function picks out it's EMSinters 
    node, if it exists (that node that has my object-id as "this_obj"). If such
    a node does not exist it allocates a new node which might start of the
    list or be linked to the end (depends on whether the input list ptr is NULL
    or not).

    In any case, new EMintobj's have to be allocated and connected up at
    the end of the positioned (or allocated) EMSinters node's appropriate
    link-list.

    An additional flexibility provided is that any of the input arguments
    can be NULL (value). This provides the user with ability to use only
    a subset of the input. Wherever possible, output corresponding to a NULL
    argument is made more meaningful. For example: xyzintobject being NULL
    will cause a datatype of "EMSdata_null" to be output in the relevant
    field of the output. One restriction however applies. If an EMSinters
    pointer is non-NULL, it's corresponding "object" (a or b) should be
    meaningful. Else an invalid-argument error code is returned.
    One use of such a flexibility is that an intersection list for a single
    object (a or b) can be processed.

    UPDATE (NP 5/27/93): Now, we have an additional field in the EMSintobj
                         struct which is set to the types passed in. If the 
                         cvtype_a and cvtype_b parameters are passed in as NULL
                         then if it is an intersection CURVE, we set the type 
                         to "EMfreeform_curve" and if the intersection is a 
                         POINT (cv/cv or cv/sf intersection), we set the type
                         in the intobj to "EMpoint".(Note that when a new intobj
                         is malloced using EMintobj_malloc, the type is set by
                         default to "EMfreeform_curve").The "is_curve" parameter
                         is assumed to apply to BOTH intobjs "a" and "b", so if
                         the "cvtype_a" and "cvtype_b" parameters are both NULL,
                         then BOTH intobjs are considered curves or BOTH are 
                         considered points, depending on "is_curve". 
                         
  HISTORY

    SS  :  Long ago  :  Creation
    SS  :  10/22/89  :  Changed the fucntion type from "void" to "returning
			a pointer to EMSintobj"
    Janaka : 08/06/92 : Changed assignment to inclusive OR assignment for
                        assigning inters_props_a and inters_props_b.
    NP  :  05/27/93  :  Added code to fill the newly created "curve_type" field
                        of the EMSintobj struct. Since the "curve_type" is to be
                        input to the function, added two new parameters and 
                        changed the function name to "EMmakeintlist()".
                        See UPDATE above.
*/
  
#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "emsedgedef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

#define PT  0
#define CV  1

#define CONNECT_INTOBJ(intobj, newintobj, count)\
  {\
  count = 1; \
  if ((intobj))\
    {\
    count++; \
    temp_intobj = (intobj); \
    while (temp_intobj->next) \
      { \
      temp_intobj = temp_intobj->next; \
      count++; \
      } \
    temp_intobj->next = newintobj; \
    }\
  else \
    intobj = newintobj; \
  }


struct EMSintobj *EMmakeintlist (msg, inters_a, inters_b,
                               object_a, object_b, 
                               inters_moreinfo_a, inters_moreinfo_b,
                               inters_props_a, inters_props_b,
                               xyzintobject,
                               uvintobject_a, uvintobject_b,
                               reversed_a, reversed_b,
                               moreinfo_a, moreinfo_b,
                               props_a, props_b,
                               cvtype_a, cvtype_b,
                               is_curve, positioned)
IGRlong *msg;
struct EMSinters **inters_a, **inters_b;
IGRchar *inters_moreinfo_a, *inters_moreinfo_b;
IGRulong inters_props_a, inters_props_b;
struct GRid *object_a, *object_b;
struct EMSdataselect *xyzintobject, *uvintobject_a, *uvintobject_b;
IGRboolean reversed_a, reversed_b;
IGRchar *moreinfo_a, *moreinfo_b;
IGRuchar *cvtype_a, *cvtype_b;
IGRulong props_a, props_b;
IGRboolean is_curve, positioned;
{
  IGRboolean in_list;
  IGRint count;
  IGRlong msg_loc;
  struct EMSdataselect null_data;
  struct EMSinters *inters_a_ptr, *inters_b_ptr;
  struct EMSintobj *newintobj_a, *newintobj_b;
  struct EMSintobj *temp_intobj;
  struct EMSintobj *EMintobj_malloc();
  struct EMSinters *EMinters_malloc();

  *msg = EMS_S_Success;

  newintobj_a = NULL;
  newintobj_b = NULL;

  if (!inters_a && !inters_b)
    goto ret_end;

  inters_a_ptr = NULL;
  inters_b_ptr = NULL;
  if (!positioned)
    {
    if (inters_a)
      {
      EMerr_hndlr (!object_a, *msg, EMS_E_InvalidArg, ret_end);
      if (*inters_a)
        {
        /* 
         * Some intersections already exists.
         * Find if a node exists containing some other intersections
         * with object_a as "this_obj". If so, place the pointer to that
         * node in (*inters_a).
         * If not, create a node and return this in (*inters_a).
         */
  
        in_list = FALSE;
        inters_a_ptr = *inters_a;
        while (!(in_list = IF_EQ_OBJID (inters_a_ptr->this_obj.objid,
                                        object_a->objid)) &&
               inters_a_ptr->next)
          inters_a_ptr = inters_a_ptr->next;
  
        if (!in_list)
          {
          inters_a_ptr->next = EMinters_malloc (&msg_loc, 1);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          inters_a_ptr = inters_a_ptr->next;
          }
        }
      else
        {
        /* 
         * No previous intersections exist. Allocate node and
         * return that in inters_a.
         */
  
        *inters_a = EMinters_malloc (&msg_loc, 1);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        inters_a_ptr = *inters_a;
        }
      inters_a_ptr->this_obj = *object_a;
      if (inters_moreinfo_a)
        inters_a_ptr->more_info = inters_moreinfo_a;
      inters_a_ptr->props |= inters_props_a;
      }

    if (inters_b)
      {
      EMerr_hndlr (!object_b, *msg, EMS_E_InvalidArg, ret_end);
      if (*inters_b)
        {
        /* 
         * Some intersections already exists.
         * Find if a node exists containing some other intersections
         * with object_b as "this_obj". If so, place the pointer to that
         * node in inters_b.
         * If not, create a node and return this in inters_b.
         */
  
        in_list = FALSE;
        inters_b_ptr = *inters_b;
        while (!(in_list = IF_EQ_OBJID (inters_b_ptr->this_obj.objid,
                                        object_b->objid)) &&
               inters_b_ptr->next)
          inters_b_ptr = inters_b_ptr->next;
  
        if (!in_list)
          {
          inters_b_ptr->next = EMinters_malloc (&msg_loc, 1);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          inters_b_ptr = inters_b_ptr->next;
          }
        }
      else
        {
        /* 
         * No previous intersections exist. Allocate node and
         * return that in inters_b_ptr.
         */
  
        *inters_b = EMinters_malloc (&msg_loc, 1);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        inters_b_ptr = *inters_b;
        }
      inters_b_ptr->this_obj = *object_b;
      if (inters_moreinfo_b)
        inters_b_ptr->more_info = inters_moreinfo_b;
      inters_b_ptr->props |= inters_props_b;
      }
    }
  else
    {
    if (inters_a)
      inters_a_ptr = *inters_a;
    if (inters_b)
      inters_b_ptr = *inters_b;
    }

  if (inters_a)
    {
    newintobj_a = EMintobj_malloc (&msg_loc, 1);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }
  if (inters_b)
    {
    newintobj_b = EMintobj_malloc (&msg_loc, 1);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }

  null_data.datatype = EMSdata_null;
  if (newintobj_a)
    {
    newintobj_a->this_xyzintobj = xyzintobject ? *xyzintobject : null_data;
    newintobj_a->this_uvintobj = uvintobject_a ? *uvintobject_a : null_data;
    newintobj_a->reversed = reversed_a;
    newintobj_a->other_intobj_node = newintobj_b;
    newintobj_a->this_obj_node = inters_a_ptr;
    newintobj_a->more_info = moreinfo_a;
    newintobj_a->props = props_a;
    newintobj_a->curve_type = cvtype_a? *cvtype_a : 
                                        (is_curve? EMfreeform_curve : EMpoint);
    newintobj_a->classification = NULL;
    newintobj_a->coinced = NULL_OBJID;
    }
  if (newintobj_b)
    {
    newintobj_b->this_xyzintobj = xyzintobject ? *xyzintobject : null_data;
    newintobj_b->this_uvintobj = uvintobject_b ? *uvintobject_b : null_data;
    newintobj_b->reversed = reversed_b;
    newintobj_b->other_intobj_node = newintobj_a;
    newintobj_b->this_obj_node = inters_b_ptr;
    newintobj_b->more_info = moreinfo_b;
    newintobj_b->props = props_b;
    newintobj_b->curve_type = cvtype_b? *cvtype_b : 
                                        (is_curve? EMfreeform_curve : EMpoint);
    newintobj_b->classification = NULL;
    newintobj_b->coinced = NULL_OBJID;
    }

  switch (is_curve)
    {
    case CV:
      if (inters_a_ptr)
        {
        CONNECT_INTOBJ (inters_a_ptr->cvs, newintobj_a, count);
        inters_a_ptr->num_cvs = count;
        }
      if (inters_b_ptr)
        {
        CONNECT_INTOBJ (inters_b_ptr->cvs, newintobj_b, count);
        inters_b_ptr->num_cvs = count;
        }
      break;
    case PT:
      if (inters_a_ptr)
        {
        CONNECT_INTOBJ (inters_a_ptr->pts, newintobj_a, count);
        inters_a_ptr->num_pts = count;
        }
      if (inters_b_ptr)
        {
        CONNECT_INTOBJ (inters_b_ptr->pts, newintobj_b, count);
        inters_b_ptr->num_pts = count;
        }
      break;
    default:
      break;
    }

ret_end:
  if (!EMSerror (*msg))
    {
    if (!newintobj_a)
      return (newintobj_b);
    else
      return (newintobj_a);
    }
  else
    return (NULL);
}


