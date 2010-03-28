/*
ABSTRACT
*/

class specification ACdb_info (0:0) of Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "msdef.h"

#include "ACdb_info.h"
#include "parametric.h"

instance ACdb_info
 {
  int 			  size_buffer;
  variable struct db_info db_info[0];
  variable char 	  buffer[0];
 };


message ACset_db_info(

long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
);
/*
   set my instance data
   set my serial_no 
*/


message ACget_db_info(

long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
);
/*
   get my instance data
*/

message ACget_db_info_and_def(

long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
struct GRid *macro_def;		/* my definition			*/
);
/*
   get my instance data and my macro definition
*/

message ACadd_to_dir();
/*
   should be renamed to ACset_serial_no ()
*/


message ACset_serial_no ();
/*
   create if not exist the expression ":file.dgn:serial_no"
   increment by one    the expression ":file.dgn:PDU:serial_no"
   update my instance data "serial_no"
*/

message ACput_serial_no(int serial_no);

/*
   Set the serial number of the element to the value passed in argument
*/


message ACcheckin_candidate (

IGRint CheckinType;		/* I  VDS_NORMAL_CHECKIN or VDS_FAST_CHECKIN */
IGRint *p_CheckinCandidate);	/* O  TRUE or FALSE depending from the fact
				/*    that the object is candidate or not 
				/*    for the checkin */
/*
   This method is used to know if an object wants or not to participate to the 
   checkin mecanism.
*/

message ACadd_to_list (

struct ACobj_info *p_obj_info;	/* I   list of objects in which to add my_id */
IGRint     	  size;    	/* I   size of the list		       	     */
IGRint            *p_count); 	/* I*O number of objects in the list	     */
/*
   if list is set to NULL, this method is only used to increment *p_count
   if list is not    NULL, this method adds my_id to the list of objects
			   if the list is not full
*/


message ACadd_to_list_1 (

struct ACobj_info_1 *p_obj_info_1; /* I list of objects in which to add my_id */
IGRint     	    size;    	   /* I   size of the list       	      */
IGRint              *p_count); 	   /* I*O number of objects in the list	      */
/*
  This is similar to the above message , except this accounts for the  
  the case when size_buffer = -1 . This will prevent unnecessary searching
  of macro occurrences which do not belong to 'FastCheckIn' group
*/


/* message ACget_objects_test (GRspacenum  osnum;
			    struct GRid ** p_obj_list;
 			    IGRint      *p_count);
**
   osnum     : (I) object space to look in
   p_obj_list: (O) array which stores the found elements
   p_count   : (O) number of found elements
** */

message ACgive_db_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env);

/* ABSTRACT
   Does just a NDmacro.ACgive_structure.
   This message is declared to give a change to sub class to override
   give structure for checkin only without pertubating the behaviour of assoc
*/


end specification ACdb_info;
