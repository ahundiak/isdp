class implementation ACpretdef;

#include "ASmacroi.h"

#include "macro.h"
#include "madef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#define AS_DEBUG

from ACmacro_defn import ACfind_map;


/* ========================================================================= */
method  ACload_map_ptr()
{
int status;
OMuint cnt,i;
OM_S_OBJID wobj;
OMuword 		osn;
GRclassid 		target_cl;

  status = om$get_channel_count(objid 		= my_id,
		       		p_chanselect 	= &ND_children,
				count 		= &(cnt) );
  as$status( );
  for(i=0;i<cnt;i++)
    {
    status = om$get_objid_at_index(objid = my_id,
                                  p_chanselect = &ND_children,
                                  index = i,
                                  objidaddr = &wobj,
				  osnumaddr = &osn);
      as$status( );

    om$get_classid(objid=wobj,p_classid = &target_cl);
    if(om$is_ancestry_valid(subclassid =target_cl ,
                      superclassid = OPP_ACmacro_defn_class_id) == OM_S_SUCCESS)
      {
      status = om$send(msg = message ACmacro_defn.ACfind_map(&(me->map_ptr)),
		       targetid = wobj);
      as$status( action = RET_STATUS );
      /*" found at %d ptr %d\n",i,me->map_ptr   */
      } 
    }

return(1);
}

/* ========================================================================= */
method ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix)
{
int status,msg;

   if(!me->map_ptr)
    {
     status = om$send(msg = message ACpretdef.ACload_map_ptr(),
		       targetid = my_id);
     as$status( action = RET_STATUS );
    }
  /*"pretdef, father %d ind %d \n",me->map_ptr[me->index].objid,me->index*/
    if(me->map_ptr)
      *father = me->map_ptr[me->index];
    else
      return(0);

  /* context now */

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&msg,matrix);

return(1);
}

/* ========================================================================= */
 
method ACsconnect(struct stemp *dtemp;int *count)
{
  int 	status;

  /*^
    printf(" ACpretend.connect  entry %s %d \n",
	dtemp[*count].down_scan,dtemp[*count].back );
  */

  status = om$vla_set_dimension( varray = me->down_scan, 
				 size = strlen(dtemp[*count].down_scan)+1 );

  strcpy(me->down_scan, dtemp[*count].down_scan);
  me->direct_index = dtemp[*count].direct_index;
  me->index = dtemp[*count].back;

  *count += 1;
  return(1);
} 
#define MAX_CHAR 80

method NDprint( struct GRmd_env *md_env ; FILE *stream)
{
  int 			status;
  
  status = om$send(msg = message NDnode.NDprint_root(md_env, stream),
		   targetid = my_id );
  as$status( action = RET_STATUS ); 
  return(1);
}

/* ========================================================================= */

method NDsleep (struct GRmd_env *md_env)
{
 int status;
   me->map_ptr=0;
   status = om$send(msg = message NDnodein.NDsleep(md_env),
		    mode = OM_e_wrt_message,
                    targetid = my_id);
   return(OM_S_SUCCESS);
}

method NDcopy_to_root( IGRlong *msg; int cp_type;
                       struct GRmd_env *fr_env, *to_env;
                       struct GRid *newobjid)
{
 long status;
 status = om$construct_and_copy(object = me,
                                osnum  = to_env->md_id.osnum,
                                p_objid = &newobjid->objid);
 newobjid->osnum = to_env->md_id.osnum;
 if(status&1) *msg = MSSUCC; 
 else	      *msg = MSFAIL;

 return status;
}
  


end implementation ACpretdef;
