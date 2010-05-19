
class implementation NDnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "batch.h"
#define AS_DEBUG

#if 0
method NDnotify_connect(struct GRid new_connected)
{
 long status;
 extern struct ext_list NDdelete;
 struct GRid my_grid;
 int index;
 char my_state;


 status = om$send(msg = message NDnode.NDget_state(&my_state),
		  targetid = my_id);
 as$status();
 
/* 
   remove the element from delete batch if it is there and print
   a warning message 
*/

 if(my_state & ND_DEL_NO_CH || my_state & ND_DONT_MVRT)
  {
   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;

   index = NDin_buffer(my_grid,&NDdelete);
   if(index>=0)
   {
    printf
   ("WARNING connection to the element %d %d. This element is support only \n",
     my_id,OM_Gw_current_OS);
  printf("and could have been already deleted after children or parent disconnection\n");
  NDdelete.list_id[index].objid = NULL_OBJID;
   }
  }
 
 return(OM_S_SUCCESS);
}

/*
   if my state is erase if no child and if after disconnection no child remain
   erase my_self and change my state to non displayable */
method NDnotify_disconnect(struct GRid previous_connected)
{
struct GRid child,my_grid;
IGRchar my_state;
long status;
int num;

 status = om$send(msg = message NDnode.NDget_state(&my_state),
		  targetid = my_id);
 as$status();


if(!(my_state & ND_DEL_NO_CH)) return(OM_S_SUCCESS);

/*| This element is support only */

status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN ,
					 &child,1,0,0,OM_K_MAXINT,&num),
	         targetid = my_id);
if(num > 1) return OM_S_SUCCESS;
if(num >0 &&
   (child.objid != previous_connected.objid || 
    child.osnum != previous_connected.osnum)) return OM_S_SUCCESS;


/*| The only dependent of the element are deleted --> delete the element */

my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;
status = nd$wait_batch(type = GR_DELETED,
		       l_object = &my_grid,
		       nb_obj = 1);
 return(OM_S_SUCCESS);
}
#endif

method NDsleep(struct GRmd_env *md_env)
{
IGRint status;
IGRint nb_mac;
IGRchar el_state;
struct GRid my_grid;
int count;

 int traceFlag = 0;
 
/*^
  char cl_name[OM_K_MAXCLASS_LEN];
  om$get_classname(objid = my_id,
		    classname = cl_name);
  printf(" %d %d --> %s\n",my_id,OM_Gw_current_OS,cl_name);
*/
 if (traceFlag) {  
   printf(">>> NDnode.NDsleep %d,%d\n",OM_Gw_current_OS,my_id);
 }
 
  status = om$send(msg = message NDnode.NDget_state(&el_state),
		  targetid = my_id);
  as$status();

  if(!(el_state & ND_DEL_NO_CH)) {
    if (traceFlag) {  
      printf("<<< NDnode.NDsleep %d,%d NO ND_DEL_NO_CH\n",OM_Gw_current_OS,my_id);
    }
 
   return(OM_S_SUCCESS);
  }

  //printf("Getting Children Count\n");
  
  status = om$send(msg = message NDnode.NDget_objects
				(ND_CHILDREN,NULL,0,NULL,0,OM_K_MAXINT,&count),
		   targetid = my_id);
  if(count) {
    if (traceFlag) {  
      printf("<<< NDnode.NDsleep %d,%d HAVE CHILDREN\n",OM_Gw_current_OS,my_id);
    }
    return OM_S_SUCCESS;
  }
  
/*| delete myself */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status = nd$wait_batch(type = GR_DELETED,
			 l_object = &my_grid,
			 nb_obj = 1);
 if (traceFlag) {  
   printf("<<< NDnode.NDsleep %d,%d Deleted Myself\n",OM_Gw_current_OS,my_id);
 }
 
   return(OM_S_SUCCESS);
   
}
end implementation NDnode;

