/***************************************************************************
 *
 *  ACdb_info: 
 *
 *  design date: 20 Oct 89.
 *  22 JUN 92  scw  Added static ANSI prototype
 *
 ***************************************************************************/

/*
 *  function:
 *
 *  Store the database information used at check-in time.
 *
 */

class implementation ACdb_info;

#include <stdio.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMparameters.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "ACcheckin.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"

#define AS_DEBUG 1

%safe
/*
 *  ANSI static prototype 
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static compar __((struct ACobj_info *p_obj_info1, 
                  struct ACobj_info *p_obj_info2));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


extern OM_p_OSD *OM_GA_OSDs;

from expression import NDgive_value;
from OMObjSpace import pass;
from ACcpx import find_macro;
from NDmacro import ACgive_structure;


method ACset_db_info(
long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
)
{
 long status;
 int size;
 int first_malloc;

 *msg = 0; 
 first_malloc= FALSE;


 if(me->size_buffer <= 0)
  {
    /*| Allocation of the vla struct db_info */
   status = om$vla_set_dimension(varray = me->db_info,
 				 size   = 1);
   as$status(action = RET_STATUS);
   first_malloc= TRUE;
  }
  

 if(db_info->quantity < 0) /* if quantity -ve don't allocate vla buffer */
   {
    me->db_info[0].quantity  = db_info->quantity ;
    me->db_info[0].serial_no = my_id ;
    me->size_buffer          = -1 ; 
   }

 else{
    me->db_info[0].s_catalog   = (short) strlen(db_info->catalog);
    me->db_info[0].s_part_num  = (short) strlen(db_info->part_num);
    me->db_info[0].s_revision  = (short) strlen(db_info->revision);
    me->db_info[0].s_usage     = (short) strlen(db_info->usage);

    size = me->db_info[0].s_catalog + me->db_info[0].s_part_num + 
    me->db_info[0].s_revision + me->db_info[0].s_usage + 4; /*4 end of string*/
    /*" size: %d\n", size */

    if(size > me->size_buffer)
     {
     /*" Allocation of the vla buffer, size: %d\n", size */
     status = om$vla_set_dimension(varray = me->buffer,
                                   size   = size); 
     as$status(action = RET_STATUS);
     me->size_buffer = size;
     }

   /* Set the data inside the vla */
   strcpy( me->buffer          		         , db_info->catalog);
   strcpy(&me->buffer[me->db_info[0].s_catalog + 1], db_info->part_num);
   strcpy(&me->buffer[me->db_info[0].s_part_num+
                      me->db_info[0].s_catalog + 2], db_info->revision);
   strcpy(&me->buffer[me->db_info[0].s_part_num+
                      me->db_info[0].s_catalog +
	              me->db_info[0].s_revision+ 3], db_info->usage);

    me->db_info[0].quantity  = db_info->quantity;
    me->db_info[0].serial_no = db_info->serial_no;

 if (first_malloc)
   {
    status= om$send (msg = message ACdb_info.ACset_serial_no (),
  	        targetid = my_id);
    as$status (action = RET_STATUS);
   }
 }/*end else*/

 *msg = 1;  
 return (OM_S_SUCCESS);
}

method ACget_db_info_and_def(
long             *msg;          /* complection code (O)                 */
struct ACdb_info *db_info;      /* data base information                */
struct GRid *macro_def;         /* my definition                        */
)
{
 int status;

 status = om$send(msg = message ACdb_info.ACget_db_info(msg,db_info),
		  targetid = my_id);
 as$status(action = RET_STATUS);

 status = om$send(msg = message ACcpx.find_macro(macro_def),
		  targetid = my_id);
 as$status();
 return(status);
}

method ACget_db_info(
long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
)
{
 *msg = 0; 

 if((me->size_buffer <=4) && (me->size_buffer != -1))
  {
   printf("ACget_db_info : No data base information available\n");
   return(OM_W_ABORT);
  }


 if(me->size_buffer == -1)
  {
   db_info->quantity  = me->db_info[0].quantity ;
   db_info->serial_no = me->db_info[0].serial_no;
  }
 else{
  if(me->size_buffer >= 4)
   {
    /* Get the data of the vla */
    strcpy(db_info->catalog , &me->buffer[0]);
    strcpy(db_info->part_num, &me->buffer[me->db_info[0].s_catalog +1]);
    strcpy(db_info->revision, &me->buffer[me->db_info[0].s_catalog +
         				  me->db_info[0].s_part_num+2]);
    strcpy(db_info->usage   , &me->buffer[me->db_info[0].s_catalog +
          				  me->db_info[0].s_part_num+
				          me->db_info[0].s_revision+3]);

    db_info->quantity  = me->db_info[0].quantity ;
    db_info->serial_no = me->db_info[0].serial_no;
   }  
  }
 
 *msg = 1;
 return (OM_S_SUCCESS);
}


method ACadd_to_dir ()
  {
   IGRint status;

   status= om$send (msg = message ACdb_info.ACset_serial_no (),
	       targetid = my_id);
   as$status (action = RET_STATUS); 

   return (OM_S_SUCCESS);
  }

method ACput_serial_no(int serial_no)
{
   if((me->size_buffer <= 4) && (me->size_buffer != -1)) return OM_W_ABORT;
   me->db_info[0].serial_no= serial_no;
   return OM_S_SUCCESS;
}


method ACset_serial_no ()
  {
   IGRchar	serial_name[80];/* name  of ":file.dgn:PDU:serial_no" */
   OM_S_OBJID 	serial_objid;	/* objid of ":file.dgn:PDU:serial_no" */
   IGRdouble 	serial_value;   /* value of ":file.dgn:PDU:serial_no" */
   OM_S_OBJID   objid;
   IGRint	status;
    
   if((me->size_buffer <= 4) && (me->size_buffer != -1))
     {
      status= OM_E_ABORT;
      return(status);
/* as$status(msg ="ACset_serial_no : No data base information avalaible", action = RET_STATUS);*/
     }

   /*| find previous value of serial_no :file.dgn:PDU:serial_no */

   serial_objid= NULL_OBJID;
   di$translate( objname = "PDU:serial_no", 
                 osnum   = OM_Gw_current_OS,
  	         p_objid = &serial_objid);

   if (serial_objid == NULL_OBJID)
     {
      objid= NULL_OBJID;
      di$translate (objname = "PDU", 
                    osnum   = OM_Gw_current_OS,
  	            p_objid = &objid);

      if (objid == NULL_OBJID)
        {
         status= 
         di$mkdir (dirname = "PDU",
	           osnum   = OM_Gw_current_OS);
	 if (!(status & 1))
           {
            di$report_error (sts = status);
	    return (OM_E_ABORT);
           }
        }

      status= 
      di$give_pathname (osnum    = OM_Gw_current_OS,
                        pathname = serial_name);
      if (!(status & 1))
        {
         di$report_error (sts = status);
	 return (OM_E_ABORT);
        }

      strcat (serial_name, ":PDU:serial_no"); 

      status= 
      exp$create (exp_name   = serial_name,
 	          exp_syntax = "1000",
		  p_exp_id   = &serial_objid,
		  osnum      = OM_Gw_current_OS);
      as$status (action = RET_STATUS);
     }

   status= 
   om$send (msg = message expression.NDgive_value (&serial_value),
       senderid = NULL_OBJID,
       targetid = serial_objid);
   as$status (action = RET_STATUS);
   /*^ printf ("previous serial_no= %lf \n", serial_value); */

   /* increment by one serial_no */

   serial_value= serial_value+ 1;

   /*| update my instance data */

   me->db_info[0].serial_no= serial_value;

   /*| update new value of serial_no :file.dgn:PDU:serial_no */

   sprintf (serial_name, "%lf", serial_value);

   status=
   exp$modify (exp_syntax = serial_name,
	       exp_id     = serial_objid,
	       osnum      = OM_Gw_current_OS);
   as$status (action = RET_STATUS);
 
   return (OM_S_SUCCESS); 
  }


method ACcheckin_candidate (IGRint CheckinType;
			    IGRint *p_CheckinCandidate)

/*.ACcheckin_candidate*/
  {
   *p_CheckinCandidate= FALSE;
   if ((CheckinType == VDS_NORMAL_CHECKIN &&  me->size_buffer > 4) 
   ||  (CheckinType == VDS_FAST_CHECKIN   &&  me->size_buffer == -1))
      *p_CheckinCandidate= TRUE;

   return (OM_S_SUCCESS);
  }

method ACadd_to_list (struct ACobj_info *p_obj_info;	
		      IGRint     	size;
		      IGRint     	*p_count) 

  {
   if (p_obj_info == NULL)
     {/*| only counting the objects */
      if (me->size_buffer > 4) 
         *p_count= *p_count+ 1;
     }
   else
     {/*| adding to the list */
      if (*p_count < size)
        {/*| the list is not full */
         if (me->size_buffer > 4)
           {/*| I go into the list */

            p_obj_info[*p_count].obj.objid= my_id;
            p_obj_info[*p_count].obj.osnum= OM_Gw_current_OS;
            p_obj_info[*p_count].serial_no= me->db_info[0].serial_no;
            *p_count= *p_count+ 1;
           }
         else
           {/*| I do not go into the list */ 
            ;
           }
        }
     }
  /*^
      printf ("*p_count= %d \n", *p_count);
   */

   return (OM_S_SUCCESS);
  }
   

method ACadd_to_list_1 (struct ACobj_info_1 *p_obj_info_1;
                      IGRint                size;
                      IGRint                *p_count)

  {
   /*| Start of ACadd_to_list_1 */
   if (p_obj_info_1 == NULL)
     {/*| only counting the objects */
      if (me->size_buffer == -1 )
          {/*"size_buffer is %d \n",me->size_buffer*/;
         *p_count= *p_count+ 1;
          }
          else{
   /*"FAILED:NOT type fastcheckin :size_buffer is %d \n",me->size_buffer*/;
          }
     }
   else
     {/*| adding my_self to the list */
      if (*p_count < size)
        {/*| the list is not full */
         if (me->size_buffer == -1 )
           {
            p_obj_info_1[*p_count].obj.objid= my_id;
            p_obj_info_1[*p_count].obj.osnum= OM_Gw_current_OS;
            p_obj_info_1[*p_count].serial_no= me->db_info[0].serial_no;
            p_obj_info_1[*p_count].quantity = me->db_info[0].quantity;
            *p_count= *p_count+ 1;
           }
        }
     }
  /*^
     printf ("*p_count= %d \n", *p_count);
   */

   return (OM_S_SUCCESS);
  }


/* method ACget_objects_test (GRspacenum  os_osnum;
			   struct GRid ** p_obj_list;
 			   IGRint      *p_count)
  {
   IGRint status;

   status= ACdb_info_get_objects (os_osnum, p_obj_list, p_count);
   as$status (action = RET_STATUS); 

   return (OM_S_SUCCESS);
  } */


IGRint ACdb_info_get_objects (os_osnum, p_obj_list, p_count)

GRspacenum   os_osnum;
struct  GRid **p_obj_list;
IGRint       *p_count;

/*.ACdb_info_get_objects*/
  {
   return (ACdb_info_get_specific_objects (os_osnum, p_obj_list, p_count,
	   VDS_NORMAL_CHECKIN));
  }


IGRint ACdb_info_get_objects_1 (os_osnum, p_obj_list, p_count)

GRspacenum   os_osnum;
struct  GRid **p_obj_list;
IGRint       *p_count;

/*.ACdb_info_get_objects*/
  {
   return (ACdb_info_get_specific_objects (os_osnum, p_obj_list, p_count,
	   VDS_FAST_CHECKIN));
  }


IGRint ACdb_info_get_specific_objects (os_osnum, p_obj_list, p_count, 
				       chk_flag)

GRspacenum   os_osnum;
struct  GRid **p_obj_list;
IGRint       *p_count;
IGRint       chk_flag;

/*.ACdb_info_get_specific_objects */  
  {
   struct ACobj_info		*p_obj_info; 
   int				status = OM_S_SUCCESS;
   int				count;
   int 				i;
   int    			compar ();
   char				*malloc ();
   void				qsort ();
   int 				max_obj, i_obj;
   GRclassid 			obj_class;
   struct ACdb_info 		db_info;
   IGRint			checkin_candidate;

   max_obj = OM_GA_OSDs[os_osnum]->CurSpaceMapSize;

   /* counting the objects to be checked in */

   *p_count= 0;

   for (i_obj= 0; i_obj< max_obj; i_obj= i_obj+ 1)
     {
      status = om$get_classid(objid = i_obj,
                              osnum = os_osnum,
                          p_classid = &obj_class);
      if (status&1 )
        { 
         status = om$is_ancestry_valid (subclassid   = obj_class,
					superclassid = OPP_ACdb_info_class_id);

         if (status == OM_S_SUCCESS)
	   {
            status= om$send (msg = message ACdb_info.ACcheckin_candidate
				          (chk_flag, &checkin_candidate),
	                senderid = NULL_OBJID,
		        targetid = i_obj,
		        targetos = os_osnum);
            if ((status&1) &&  (checkin_candidate == TRUE))
              {
               *p_count= *p_count+ 1;
              }
           }
        }
     }

   if (*p_count == 0) return (OM_S_SUCCESS);

   /*^
      printf ("*p_count= %d \n", *p_count);
   */

   /* collecting the list of the objects to be checked in */

   count= *p_count;

   p_obj_info= (struct ACobj_info *)malloc (count * sizeof (struct ACobj_info)); 
   if (p_obj_info == NULL)
     {
      as$status (msg = "p_obj_info : cannot malloc \n");
      return (OM_E_ABORT);
     }

   *p_obj_list= (struct GRid *)malloc (count * sizeof (struct GRid));
   if (*p_obj_list== NULL)
     {
      as$status (msg = "*p_obj_list : cannot malloc \n");
      return (OM_E_ABORT);
     }

   *p_count= 0;

   for (i_obj= 0; i_obj< max_obj; i_obj= i_obj+ 1)
     {
      status = om$get_classid(objid = i_obj,
                              osnum = os_osnum,
                          p_classid = &obj_class);
    
      if (status&1)
        { 
         status = om$is_ancestry_valid (subclassid   = obj_class,
					superclassid = OPP_ACdb_info_class_id);

         if (status == OM_S_SUCCESS)
	   {
            status= om$send (msg = message ACdb_info.ACcheckin_candidate
				          (chk_flag, &checkin_candidate),
	                senderid = NULL_OBJID,
		        targetid = i_obj,
		        targetos = os_osnum);
            if ((status&1) &&  (checkin_candidate == TRUE))
              {
	       p_obj_info [*p_count].obj.objid= i_obj;
	       p_obj_info [*p_count].obj.osnum= os_osnum;
	       p_obj_info [*p_count].serial_no= db_info.serial_no;
               *p_count= *p_count+ 1;
              }
           }
        }
     }

   /* sorting the objects by serial_no */

   /*^
      printf ("before qsort \n");
      for (i=0; i<count; i= i+1)
        {
         printf ("p_obj_info[%d].obj.objid %d \n", i, p_obj_info[i].obj.objid);
         printf ("p_obj_info[%d].obj.osnum %d \n", i, p_obj_info[i].obj.osnum);
         printf ("p_obj_info[%d].serial_no %d \n", i, p_obj_info[i].serial_no);
        }
   */

   qsort (p_obj_info, (unsigned)count, sizeof (struct ACobj_info), compar);

   /*^
      printf ("after  qsort \n");
      for (i=0; i<count; i= i+1)
        {
         printf ("p_obj_info[%d].obj.objid %d \n", i, p_obj_info[i].obj.objid);
         printf ("p_obj_info[%d].obj.osnum %d \n", i, p_obj_info[i].obj.osnum);
         printf ("p_obj_info[%d].serial_no %d \n", i, p_obj_info[i].serial_no);
        }
   */

   for (i=0; i< count; i= i+1)
     (*p_obj_list)[i]= p_obj_info[i].obj;
 
/*
   free (p_obj_info);
*/
   
   return (OM_S_SUCCESS);
  }


static compar (p_obj_info1, p_obj_info2)

struct ACobj_info *p_obj_info1;
struct ACobj_info *p_obj_info2;

/*.compar */
  {
   return (p_obj_info1->serial_no - p_obj_info2->serial_no);
  }

method ACgive_db_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
 IGRlong status;

 status = om$send(msg = message NDmacro.ACgive_structure(suc,direct_index,
                                                footname,ptr_rst,md_env),
                  targetid = my_id);
 return status;
}

end implementation ACdb_info;
