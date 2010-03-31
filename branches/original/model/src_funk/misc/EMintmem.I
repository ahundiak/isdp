class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "madef.h"
#include "exmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsedgedef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from GRgraphics import GRdelete;

struct EMSinters *EMinters_malloc (msg, num)
IGRlong *msg;
IGRint num;
{
  IGRint i;
  struct EMSinters *inters_ptr, *temp_ptr;

  *msg = EMS_I_DynamicMemoryAllocated;

  inters_ptr = (struct EMSinters *) om$malloc (size = sizeof
                (struct EMSinters));
  EMerr_hndlr (! inters_ptr, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

  inters_ptr->next = NULL;
  inters_ptr->num_pts = 0;
  inters_ptr->pts = NULL;
  inters_ptr->num_cvs = 0;
  inters_ptr->cvs = NULL;
  inters_ptr->more_info = NULL;
  inters_ptr->coinc_info_list = NULL;
  inters_ptr->num_coincs = NULL;
  inters_ptr->props = 0;

  temp_ptr = inters_ptr;
  for (i=1; i<num; i++)    
    {
    temp_ptr->next = (struct EMSinters *) om$malloc (size = sizeof
                      (struct EMSinters));
    EMerr_hndlr (! temp_ptr, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

    temp_ptr->next->next = NULL;
    temp_ptr->next->num_pts = 0;
    temp_ptr->next->pts = NULL;
    temp_ptr->next->num_cvs = 0;
    temp_ptr->next->cvs = NULL;
    temp_ptr->next->more_info = NULL;
    temp_ptr->next->coinc_info_list = NULL;
    temp_ptr->next->num_coincs = NULL;
    temp_ptr->next->props = 0;

    temp_ptr = temp_ptr->next;
    }

ret_end:
  return (inters_ptr);
}
  


/*
 * The number of nodes freed in the linked
 * list, starting from "inters", is "num". To
 * free the entire list, specify either NULL or
 * MAXINT or the exact number of elements in the
 * list.
 */

void EMinters_free (inters, num)
struct EMSinters *inters;
IGRint num;
{
  IGRboolean flag;
  struct EMSinters *temp_inters;
  void EMintobj_free();

  if (inters)
    {
    flag = (num ? TRUE : FALSE);
    while ((flag ? num-- : TRUE) && inters)
      {
      EMintobj_free (inters->pts, NULL);
      EMintobj_free (inters->cvs, NULL);
      temp_inters = inters->next;
      free (inters);
      inters = temp_inters;
      }
    }
}

/*
 5/27/93  NP  : Added initialization of "curve_type" to "EMfreeform_curve".
 02/24/94 Sanjay : Added initialization of coinced and classification fields
                   which are being introduced for Pathway.
*/

struct EMSintobj *EMintobj_malloc (msg, num)
IGRlong *msg;
IGRint num;
{
  IGRint i;
  struct EMSintobj *intobj_ptr, *temp_ptr;

  *msg = EMS_I_DynamicMemoryAllocated;

  intobj_ptr = (struct EMSintobj *) om$malloc (size = sizeof
                (struct EMSintobj));
  EMerr_hndlr (!intobj_ptr, *msg, EMS_E_NoDynamicMemory, ret_end);

  intobj_ptr->this_xyzintobj.datatype = EMSdata_null;
  intobj_ptr->this_uvintobj.datatype = EMSdata_null;
  intobj_ptr->reversed = FALSE;
  intobj_ptr->props = NULL;
  intobj_ptr->this_obj_node = NULL;
  intobj_ptr->other_intobj_node = NULL;
  intobj_ptr->more_info = NULL;
  intobj_ptr->fwd = NULL;
  intobj_ptr->bwd = NULL;
  intobj_ptr->next = NULL;
  intobj_ptr->curve_type = EMfreeform_curve;
  intobj_ptr->classification = (IGRuint) 0;
  intobj_ptr->coinced = NULL_OBJID;
 
  temp_ptr = intobj_ptr;
  for (i=1; i<num; i++)
    {
    temp_ptr->next = (struct EMSintobj *) om$malloc (size = sizeof 
                  (struct EMSintobj));
    EMerr_hndlr (!temp_ptr->next, *msg, EMS_E_NoDynamicMemory, ret_end);

    temp_ptr->next->this_xyzintobj.datatype = EMSdata_null;
    temp_ptr->next->this_uvintobj.datatype = EMSdata_null;
    temp_ptr->next->reversed = FALSE;
    temp_ptr->next->props = NULL;
    temp_ptr->next->this_obj_node = NULL;
    temp_ptr->next->other_intobj_node = NULL;
    temp_ptr->next->more_info = NULL;
    temp_ptr->next->fwd = NULL;
    temp_ptr->next->bwd = NULL;
    temp_ptr->next->next = NULL;
    temp_ptr->next->curve_type = EMfreeform_curve;
    temp_ptr->next->classification = (IGRuint) 0;
    temp_ptr->next->coinced = NULL_OBJID;
    temp_ptr = temp_ptr->next;
    }

ret_end:
  return (intobj_ptr);
}

/*
5/27/93  NP  Added parameter "cvtype" to reflect the addition of a new field
             to the struct. If NULL, type is set to "EMfreeform_curve". 
             Also, changed the name of the function from "EMmkintobj" to 
             "EMmakeintobj" to reflect the change.
*/


struct EMSintobj *EMmakeintobj (msg, this_xyzintobj, this_uvintobj, 
                                is_reversed, props,
                                this_obj_node, other_intobj_node,
                                more_info, fwd, bwd, next_intobj,cvtype,
                                newintobj)
IGRlong *msg;
struct EMSdataselect *this_xyzintobj, *this_uvintobj;
IGRboolean is_reversed;
IGRulong props;
struct EMSinters *this_obj_node;
struct EMSintobj *other_intobj_node;
IGRchar *more_info;
IGRuchar *cvtype;
struct EMSintobj *fwd,*bwd,*next_intobj,**newintobj;
{
  IGRlong msg_loc;
  struct EMSintobj *p_intobj;
  struct EMSintobj *EMintobj_malloc();

  *msg = EMS_S_Success;

  p_intobj = NULL;
  p_intobj = *newintobj = EMintobj_malloc (&msg_loc, 1);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

  if (this_xyzintobj)
    OM_BLOCK_MOVE (this_xyzintobj, &p_intobj->this_xyzintobj,
     sizeof (struct EMSdataselect));  
  if (this_uvintobj)
    OM_BLOCK_MOVE (this_uvintobj, &p_intobj->this_uvintobj,
     sizeof (struct EMSdataselect));  
  p_intobj->reversed = is_reversed;
  p_intobj->props = props;
  p_intobj->this_obj_node = this_obj_node;
  p_intobj->other_intobj_node = other_intobj_node;
  p_intobj->more_info = more_info;
  p_intobj->fwd = fwd;
  p_intobj->bwd = bwd;
  p_intobj->next = next_intobj;
  p_intobj->curve_type = cvtype? *cvtype : EMfreeform_curve;
 
ret_end:
  if (EMSerror (*msg))
    return (NULL);
  else
    return (p_intobj);
}

/*
 * The number of nodes freed in the linked
 * list, starting from "intobj", is "num". To
 * free the entire list, specify either NULL or
 * MAXINT or the exact number of elements in the
 * list.
 */

void EMintobj_free (intobj, num)
struct EMSintobj *intobj;
IGRint num;
{
  IGRboolean flag;
  IGRshort i;
  struct EMSintobj *temp_intobj, *cont_intobj, *other_intobj;

  if (intobj)
    {
    flag = (num ? TRUE : FALSE);
    while ((flag ? num-- : TRUE) && intobj)
      {
      temp_intobj = intobj->next;

      for (i=0; i<2; i++)
        {
        cont_intobj = (i==0 ? intobj->fwd : intobj->bwd);
        if (cont_intobj)
          {
          if (cont_intobj->fwd == intobj)
            cont_intobj->fwd = NULL;
          if (cont_intobj->bwd == intobj)
            cont_intobj->bwd = NULL;
          }
        }

      /* Set the pointer on the other side which points to this node as NULL
         since this memory is being freed.
         SM 09/25/92.
      */
      other_intobj = intobj->other_intobj_node;
      if(other_intobj && (other_intobj->other_intobj_node == intobj))
       other_intobj->other_intobj_node = NULL;  /* other node pointing
                                                   to this node.
                                                */
      free (intobj);
      intobj = temp_intobj; 
      }
    }
}



/*
 * This function is different from EMinters_free in that it frees/deallocates/
 * deletes the actual intersection data - the curve-objects, point-objects,
 * curve-buffers, point-buffers, etc. The nodes in the linked-list are NOT
 * deallocated. To deallocate these one would use EMinters_free. Also, only the
 * intersection data directly associated with this list is freed. (The list
 * contains references to intersection data belonging to another similar
 * list, but that is left untouched. Example: the field
 * "other_intobj_node"). The real work is done by the lower level function
 * EMintobj_data_free. Please see the documentation for that function
 * below. It best describes the characteristics of this operation. 
 * The actual number of nodes processed is dependent on the argument -
 * "num". Only "num" number of nodes are processed in the linked list.
 * If the list terminates before "num" nodes, processing terminates,
 * having processed all the nodes. Also, if "num" is NULL, it is assumed that
 * the entire list is to be processed.
 */

void EMinters_data_free (msg, inters_list, num, func_free_inters_moreinfo, 
			 func_free_moreinfo)
IGRlong *msg;
struct EMSinters *inters_list;
IGRint num;
void (*func_free_moreinfo)(), (*func_free_inters_moreinfo)();
{
  IGRboolean flag;
  IGRlong msg_loc;
  void EMintobj_data_free();
  struct EMSintobj *this_intobj = NULL;
  struct EMSinters *other_inters = NULL;

  *msg = EMS_S_Success;

  if (inters_list)
    {
    flag = (num ? TRUE : FALSE);
    while ((flag ? num-- : TRUE) && inters_list)
      {
       this_intobj = (struct EMSintobj *) inters_list->cvs;
       while(this_intobj)
        {
         if(!this_intobj->other_intobj_node)
          {
	   this_intobj = this_intobj->next;
	   continue;
	  }

	 other_inters = NULL;
	 if(this_intobj->other_intobj_node)
	  other_inters = this_intobj->other_intobj_node->this_obj_node;
	 if(other_inters)
	  {
	   other_inters->coinc_info_list = NULL;
	   other_inters->num_coincs = NULL;
	  }
	 this_intobj = this_intobj->next;
        }

/**************/
      if(inters_list->coinc_info_list)
        {
          om$dealloc (ptr = inters_list->coinc_info_list[0]);
          om$dealloc (ptr = inters_list->coinc_info_list[1]);
          inters_list->coinc_info_list = NULL;
          om$dealloc (ptr = inters_list->num_coincs);
          inters_list->num_coincs = NULL;
        }
/**************/

      if (inters_list->pts)
        {
        EMintobj_data_free (&msg_loc, inters_list->pts, MAXINT,
         func_free_moreinfo);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        }
      if (inters_list->cvs)
        {
        EMintobj_data_free (&msg_loc, inters_list->cvs, MAXINT,
         func_free_moreinfo);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        }
      if(inters_list->more_info)
        {
        if (func_free_inters_moreinfo)
          (*func_free_inters_moreinfo)(inters_list->more_info, NULL);
        else
          om$dealloc (ptr = inters_list->more_info);
        inters_list->more_info = NULL; 
	}
      inters_list = inters_list->next;
      }
    }
ret_end:;
}


/*
 * This function is different from EMintobj_free in that it 
 * frees/deallocates/deletes the true intersection data - the point-data
 * and curve-data. The nodes in the linked are NOT deallocated.
 * To do this one would use EMintobj_free. Also, only the
 * intersection data directly associated with this list is freed. (The list
 * contains references to intersection data belonging to another similar
 * list, but that is left untouched. Example: the field
 * "other_intobj_node").
 *
 * There are broadly two different types of intersection data for every
 * EMSinters-node: i) Point intersections and ii) Curve intersections.
 * There could be any number of each of these for a given node.
 * Every point intersection could potentially have three pieces of data:
 * i) xyz-data, ii) uv-data and iii) user-specific data in the "more_info'
 * field. Again, each such data piece could be one of several types,
 * designated in the enumerated type - EMSdatatype. Every piece of data
 * is handled differently in this function and this handling is listed
 * below: (Those not listed are not currently handled and will result in
 *         an error message being returned)
 *
 * Points and curves:
 *   xyz-data:
 *     1) EMSdata_object - GRgraphics.GRdelete message sent to it.
 *     2) EMSdata_poly3d - om$dealloc on the IGRpolyline structure,
 *                         om$dealloc on the points field.
 *     3) EMSdata_curve3d - om$dealloc on the IGRbsp_curve structure,
 *                          and the poles, weights, knots and bdrys.
 *   uv-data:
 *     1) EMSdata_object - Root.delete (OM_e_wrt_object) message sent to it.
 *     2) EMSdata_poly2d - om$dealloc on the IGRpolyline structure,
 *                         om$dealloc on the points field.
 *     3) EMSdata_curve3d - om$dealloc on the IGRbsp_curve structure,
 *                          and the poles, weights, knots and bdrys.
 *   more_info:
 *     1) User supplied function is called, with this pointer as the single
 *        argument. If the pointer to the user supplied function is NULL,
 *        om$dealloc is called on the "more_info" field (if this field
 *        is non-NULL).
 * The actual number of nodes processed is dependent on the argument -
 * "num". Only "num" number of nodes are processed in the linked list.
 * If the list terminates before "num" nodes, processing terminates,
 * having processed all the nodes. Also, if "num" is NULL, it is assumed that
 * the entire list is to be processed.
 *
 *  History
		SS	??		Creation 
		SM	28-Sep-87	added code to dealloc xyz data in form
					of 3d curves.
		SM	10-Oct-87	Modified to call 
					EMdataselect_data_free().
 */

void EMintobj_data_free (msg, intobj_list, num, func_free_moreinfo)
IGRlong *msg;
struct EMSintobj *intobj_list;
IGRint num;
void (*func_free_moreinfo)();
{
  IGRboolean flag;
  IGRint stat_OM;
  IGRlong msg_loc;
  void EMdataselect_data_free();
  IGRboolean EMis_same_dataselect();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (intobj_list)
    {
    flag = (num ? TRUE : FALSE);
    while ((flag ? num-- : TRUE) && intobj_list)
      {
      EMdataselect_data_free (&msg_loc, &intobj_list->this_uvintobj, 1);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

      if (intobj_list->other_intobj_node )
      {
         if( EMis_same_dataselect (&intobj_list->this_xyzintobj, 
                &intobj_list->other_intobj_node->this_xyzintobj ) )
            intobj_list->other_intobj_node->this_xyzintobj.datatype = 
               EMSdata_null;

         EMdataselect_data_free (&msg_loc, &intobj_list->this_xyzintobj, 1);
         EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      }
      else
      {
         EMdataselect_data_free (&msg_loc, &intobj_list->this_xyzintobj, 1);
         EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      }

      if (intobj_list->more_info)
        {
        if (func_free_moreinfo)
          (*func_free_moreinfo)(intobj_list->more_info, NULL);
        else
          om$dealloc (ptr = intobj_list->more_info);
        intobj_list->more_info = NULL; 
        }

      intobj_list = intobj_list->next;
      }
    }

ret_end:;
  EMWRAPUP (*msg, stat_OM, "EMintobj_data_free");
  if (EMSerror (stat_OM))
    *msg = EMS_E_OMerror;
}

/*
 * This function is the one that should be used when
 * allocating memory for elements of the linked list
 * made up of EMSsfintedpar(s).
 * The "next" pointer is set to NULL;
 */

struct EMSsfintedpar *EMsfintedpar_malloc (msg, num)
IGRlong *msg;
IGRint num;
{
  IGRint i;
  struct EMSsfintedpar *ipptr, *temp_ptr;

  *msg = EMS_S_DynamicMemoryAllocated;

  ipptr = (struct EMSsfintedpar *) malloc (sizeof (struct EMSsfintedpar));
  EMerr_hndlr (!ipptr, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

  ipptr->edgeid = NULL_OBJID;
  ipptr->info = NULL;
  ipptr->next = NULL;
 
  temp_ptr = ipptr;
  for (i=1; i<num; i++)
    {
    temp_ptr->next = (struct EMSsfintedpar *) malloc (sizeof
             (struct EMSsfintedpar));
    EMerr_hndlr (!temp_ptr->next, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

    temp_ptr->next->edgeid = NULL_OBJID;
    temp_ptr->next->info = NULL;
    temp_ptr->next->next = NULL;

    temp_ptr = temp_ptr->next;
    }

ret_end:
  return (ipptr);
}


/*
 * This function should be used to free memory allocated
 * to the linked list - "iparms". The linked list is expected
 * to be NULL-terminated. 
 * The actual number of nodes processed is dependent on the argument -
 * "num". Only "num" number of nodes are processed in the linked list.
 * If the list terminates before "num" nodes, processing terminates,
 * having processed all the nodes. Also, if "num" is NULL, it is assumed that
 * the entire list is to be processed.
 */

void EMsfintedpar_free (iparms, num)
struct EMSsfintedpar *iparms;
IGRint num;
{
  IGRboolean flag;
  struct EMSsfintedpar *temp_ipptr;;

  if (iparms)
    {
    flag = (num ? TRUE : FALSE);
    while ((flag ? num-- : TRUE) && iparms)
      {
      temp_ipptr = iparms->next;
      free (iparms);
      iparms = temp_ipptr;
      }
    }
}


end implementation Root;
