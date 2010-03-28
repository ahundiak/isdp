class implementation COpara;

#include "coparamac.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "exmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "growner.h"
#include "madef.h"
#include "OMmacros.h"

from GRgraphics import GRdisplay;
extern GRclassid OPP_GRgrset_class_id;


/*
   Function to return the array of GRid corresponding to
   the objects contained in a fence and in the present environnement 
   This function performs the required space allocation. Free to
   be preformed using ASend_fence
*/  


%safe
static IGRchar *ptr = NULL;
static struct GRobj_env direct_el;
%endsafe

/* ASstart_fence is kept for existing call. Future developement must be
   done by modification of the function ASstart_var_fence and of the
   macro as$start_fence
*/

ASstart_fence(set_grid,osnum,nb_obj,p_obj,response,response_data)
struct GRid set_grid;     /* GRid of the graphic set */
GRspacenum osnum;         /* osnum where to select object */
IGRint *nb_obj;		  /* number of objects in the fence */
struct GRid **p_obj;      /* pointer to list of obj in the fence */
IGRlong *response;
IGRchar *response_data;
{
 long status;
 status = as$start_fence(set = &set_grid,
		osnum    = osnum,
		nb_obj   = nb_obj,
		p_obj    = p_obj,
		response = response,
		response_data = response_data);
 return status;
}

ASstart_var_fence(set_grid,set_env,osnum,nb_obj,p_obj,p_obj_info,response,
		  response_data,make_source,type_generic,macro_name)
struct GRid *set_grid;     /* GRid of the graphic set */
struct GRmd_env *set_env;  /* md_env env of the graphic set */
GRspacenum osnum;         /* osnum where to select object */
IGRint *nb_obj;		  /* number of objects in the fence */
struct GRid **p_obj;      /* pointer to list of obj in the fence */
struct GRobj_env **p_obj_info; /* pointer to list of obj in the fence */
IGRlong *response;
IGRchar *response_data;
int make_source,type_generic;
char *macro_name;

/*.ASstart_var_fence */
{
  struct GRobj_env *if_obj;
  struct GRid clipping_grid;
  struct GRid *l_obj;
  GRclassid obj_class;
  IGRlong msg,status;
  IGRint count,icount,countb,size_ob;
  struct GRevent grevent;
  static IGRint TokenList[] =
                        {
                         DATA  ,
                         RESET,
                         GR_UNKNOWN_TYPE
                         };
  IGRint  token,size;
  IGRlong input_mask;
  struct GRid cur_mod;
  enum GRdpmode display = GRhd;
  char dummy_name[2];

  if(p_obj && p_obj_info) return OM_W_ABORT;

  ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
  size = sizeof(struct GRevent);
  input_mask = GRm_DATA | GRm_RESET | GRm_MOVE_ON;
  *nb_obj = 0;

  om$get_classid( osnum = set_grid->osnum, objid = set_grid->objid,
		  p_classid = &obj_class);

  if(om$is_ancestry_valid( subclassid=obj_class,
                           superclassid=OPP_GRgrset_class_id) == OM_S_SUCCESS)
   {

/*| get clipping polygone */

    gr$gsget_fence(msg = &msg,fence_id = &clipping_grid);
    if(msg != MSSUCC) clipping_grid.objid = NULL_OBJID;

/* Get eligible objects and hilight them if necessary */
    
    count = 0;
    status = gr$gsinqcount(msg = &msg,
			   count = &count,
			   senderid = NULL_OBJID,
			   object_id = set_grid);
			
    if(msg != MSSUCC) status = OM_W_ABORT;
    as$status(action = RET_STATUS);

    size_ob = count * sizeof(struct GRobj_env);
    ptr = om$malloc( size =  size_ob);
    if_obj = (struct GRobj_env *) ptr;
    if(if_obj == NULL) return(OM_W_ABORT);
    l_obj  = (struct GRid *) if_obj;
    if(p_obj) *p_obj = l_obj;
    if(p_obj_info) *p_obj_info = if_obj;

    status = gr$gsget_objects(msg = &msg,
			       array = if_obj,
			       size = size_ob,
			       count = &count,
			       from_obj = 0,
			       to_obj  = count -1,
			       senderid = NULL_OBJID,
			       object_id = set_grid);
    as$status(action = RET_STATUS);

    if(response) dp$erase_hilite(msg = &status);

    for(icount=0,countb=0;icount<count;icount++)
     {
      /* verify osnum */
       if(osnum && osnum != if_obj[icount].obj_id.osnum)continue;

      /* verify if the object is not the clipping polygone */
       if(IF_EQ_OBJID(if_obj[icount].obj_id.objid ,  clipping_grid.objid) &&
	              if_obj[icount].obj_id.osnum == clipping_grid.osnum)
								 continue;
      /* verify the type of the object */
       if(type_generic != ~0 || macro_name)
	{
	 if(!macro_name)
	  {
	   strcpy(dummy_name,"*"); macro_name = dummy_name;
	  }
	 status = NDctl_parent_type(&msg,type_generic,macro_name,
				    &if_obj[icount].obj_id,
				    &if_obj[icount].mod_env);
	 if(!(msg&1)) continue;
	}

       if_obj[countb++] = if_obj[icount];
       if(response) status = om$send(msg = message GRgraphics.GRdisplay(&msg,
				     &if_obj[icount].mod_env.md_env.matrix_type,
				     if_obj[icount].mod_env.md_env.matrix,
				     &display,
				     &cur_mod),
			       senderid = NULL_OBJID,
			       targetid = if_obj[icount].obj_id.objid,
			       targetos = if_obj[icount].obj_id.osnum);
         
      }
     *nb_obj = countb;
     /*" %d object in fence in current OS\n",*nb_obj */

/* ask user for accept/reject */
     if(*nb_obj && response )
      {
       ex$message(msgnumb = AS_P_AccFen);
       token = GRget_token(&msg,TokenList,&input_mask,&grevent,&size,
                           response,response_data);
       dp$erase_hilite(msg = &status);

       if(*response != DATA) *nb_obj = 0;
      }
   
/* return located object and make source if required */
      for(icount=0;icount<*nb_obj;icount++)
       {
	if(make_source)
	 {
	  as$make_source(go_grid = if_obj[icount].obj_id,
			 mod_env = &if_obj[icount].mod_env,
			 as_os = mod.osnum,
			 as_grid = &if_obj[icount].obj_id);
	 }
	if(p_obj)
	 {
          l_obj[icount].objid = if_obj[icount].obj_id.objid;
          l_obj[icount].osnum = if_obj[icount].obj_id.osnum;
	 }
       }
    }
   else
    {
     /*| Object directly located */
     ptr = NULL;
     if(!osnum || osnum == set_grid->osnum) 
	{if(set_env)
	  {
	    direct_el.mod_env = *set_env;
	  }
	 else
	  {
	   direct_el.mod_env.md_id.osnum = set_grid->osnum;
	   direct_el.mod_env.md_id.objid = NULL_OBJID;
	   direct_el.mod_env.md_env.matrix_type = MAIDMX;
	   MAidmx(&msg,direct_el.mod_env.md_env.matrix);
	  }

	 if(make_source)
	  {
	   as$make_source(go_grid = *set_grid,
			  mod_env = &direct_el.mod_env,
			  as_os = mod_osnum,
			  as_grid = &direct_el);
	  }
	 else
	  {
	   direct_el.obj_id=*set_grid;
	  }
	if(p_obj) *p_obj = &direct_el.obj_id;
	if(p_obj_info) *p_obj_info = &direct_el;
	*nb_obj =1;
       }
     else
	{*nb_obj = 0;}
    }
  return OM_S_SUCCESS;
 }

ASend_fence()
 {
  if(ptr != NULL)
   {
    /*| dealloc ptr */
    om$dealloc(ptr = ptr);
    ptr = NULL;
   }
 return 1;
 }
end implementation COpara;
