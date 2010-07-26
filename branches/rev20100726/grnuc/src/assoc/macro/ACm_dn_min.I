class implementation ACmacro_defn;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "ASmacroi.h"
#include "macro.h"
#include "asbox.h"
#include  <alloca.h>

#define AS_DEBUG

from ACpretdef import ACsconnect;

/* ========================================================================= */

method ACbuild_min_macro(		
	int *suc, prop;	char *macro_name;
        int tot_up;     struct GRid *tlist;     struct sup *xdup;
        int tot_temp;   struct stemp *xdtemp;
	int feet_num;	struct myfeet *feet;	struct GRid *feet_list;
        struct GRid macro_hdr;			struct GRmd_env *md_env )
{
  int			i,i1,j,j1;
  struct ret_struct  	pardef;
  IGRlong 		msg,status;
  struct GRmd_env fr_env,to_env;
  int cntt;
  char classname[OM_K_MAXCLASS_LEN];
  struct GRid new_root;
  struct GRid *entry,     *entry_max,     *template, *clone_list;
  int       nb_entry,   nb_entry_max;
  struct NDcp_struct copy_list;
  int el_type;
  int union_msg;
  int tmp_edit;
  int nb_body;
  int 	 pos, num_graphic;
  struct NDcp_list *all_cp_list = NULL ,*body_cp_list = NULL;
  int real_tot_up,real_tot_temp,real_feet_num;


/* Some initialization */

  *suc=0; status = OM_W_ABORT;
  tmp_edit = FALSE;

  to_env = *md_env;
  to_env.md_id.osnum = OM_Gw_current_OS;
  to_env.md_id.objid = NULL_OBJID;

  fr_env = *md_env;
  fr_env.md_id.osnum = tlist[0].osnum;
  fr_env.md_id.objid = NULL_OBJID;


  me->prop = prop;
  me->comp_struct=0;
  me->map_struct=0;
  me->go_struct=0;
  me->symbol_macro.objid=NULL_OBJID;
  strcpy( me->macro_name, macro_name );

  entry = (struct GRid *) alloca((feet_num+tot_temp)*sizeof(struct GRid));
  template = (struct GRid *) alloca(tot_temp*sizeof(struct GRid));
  copy_list.list = NULL;

  if(!entry || !template ) goto wrapup;

  /* Remove template with blank name which are template with fix value */

  for(real_tot_temp = tot_temp;
      real_tot_temp >0 && xdtemp[real_tot_temp-1].name[0] == '\0';
      real_tot_temp--);

  for(real_tot_up = tot_up;
      real_tot_up >0 && xdup[real_tot_up-1].prompt[0] == '\0';
      real_tot_up--);

  status = om$send(msg =  message ACmacro_defn.ACtake_template(real_tot_up,xdup,
							real_tot_temp,xdtemp),
   		   targetid= my_id );
  as$status(action = GOTO_VALUE, value = wrapup);

/* initialize map_struct to point to definition object
   map_struct must point to the real definition object and not to
   entry modified by move_to_tmp_clone 
*/

  status = om$vla_set_dimension(varray = me->inst_save,
                                size = tot_up * sizeof( struct GRid ));
  if(!(status&1)) return OM_W_ABORT;
  me->map_struct = me->inst_save;
 
  OM_BLOCK_MOVE(tlist,me->map_struct,tot_up*sizeof(struct GRid));


/*| cumulate template and feet in the same array */

  nb_entry = 0;
  for(i=0;i<tot_temp;i++)
  {
   entry[nb_entry++] = tlist[i];
  }

  for(i=0;i< feet_num;i++)
   {
    entry[nb_entry++] = feet_list[i];
   }

/*
  Find now the minimal graph which will become the construction.
  Its elements are :
  - the templates
  - the feet
  - all the elements between the template and the feet
  - all the roots necessary to make the non template elements
    associative (extern)
*/

 status = nd$get_internal_graph(p_initial  = entry,
		       		nb_initial = nb_entry);
 as$status(action = GOTO_VALUE; value = wrapup);

/*
   Verify if the template list is really root of the dependent graph.
   If not the case, edit the graph 
*/
 for(i=0;i<tot_temp;i++)
  {
   nd$get_type(nb_obj = 1,
	       p_object = tlist+i,
	       p_type = &el_type);
   if(el_type&ND_BODY)
    {
     tmp_edit = TRUE;
     status = om$send(msg = message NDnode.NDcopy_to_tmp_root
				(&msg,0,&fr_env,&fr_env,&new_root),
		      targetid = tlist[i].objid,
		      targetos = tlist[i].osnum);
     if(!(msg&1)) status = OM_W_ABORT;
     as$status(action = GOTO_VALUE; value = wrapup);
     entry[i] = new_root;
     status = om$send(msg = message NDnode.NDmove_to_tmp_clone(&msg,&new_root),
                     targetid = tlist[i].objid,
                     targetos = tlist[i].osnum);
     as$status(action = GOTO_VALUE; value = wrapup);
    }
  }

 if(tmp_edit)
   nd$get_internal_graph(p_initial  = entry,
		         nb_initial = nb_entry);



/*
   Send become macro to know which type of macro is valid 
   Count hwo many elements will receive copy_graph to malloc array
*/

   nd$get_list_in_graph(buf_addr = &entry_max,
			p_count   = &nb_entry_max);
   union_msg = ND_DROP_MAC | ND_SYMB_MAC | ND_CONS_MAC;

   for (i=0; i<nb_entry_max;i++)
    {
     nd$get_type(nb_obj = 1,
	       p_object = entry_max+i,
	       p_type = &el_type);
     status=om$send(msg = message NDmacro.ACbecome_macro
							(&msg, el_type, md_env),
   		      targetid = entry_max[i].objid,
		      targetos = entry_max[i].osnum );
     /*" %d %d return %x\n",entry_max[i].objid,entry_max[i].osnum,msg */

     if(!(msg) || (msg&ND_SYMB_MAC && !(msg&ND_CONS_MAC)))
        { om$get_classname(objid = entry_max[i].objid,
			   osnum = entry_max[i].osnum,
			   classname = classname);
          printf("Invalid Macro definition because of object %d %d class %s",
	         entry_max[i].objid,entry_max[i].osnum,classname);
        }
     union_msg = union_msg & msg;
    }

   if(!(union_msg)) goto wrapup;
   if(!(union_msg&ND_DROP_MAC)) me->prop |= ACno_drop;
   if(!(union_msg&ND_CONS_MAC)) me->prop |= ACno_construct;
   if(!(union_msg&ND_SYMB_MAC)) me->prop |= ACno_symbol;
	
   /*"union_msg %d prop %d\n",union_msg,me->prop */


/* Create pretends for template object */

   cntt = 0;
   for (i=0; i<tot_temp;i++)
    {
     if(i<real_tot_temp)
     {
     status = om$construct( classid = OPP_ACpretdef_class_id,
                            osnum   =   OM_Gw_current_OS,
                            p_objid = &template[i].objid);
     template[i].osnum = OM_Gw_current_OS;
     as$status( action = GOTO_VALUE, value = wrapup );

     status = om$send (msg = message ACpretdef.ACsconnect(me->xdtemp, &cntt), 
		      targetid = template[i].objid);
     as$status( action = GOTO_VALUE, value = wrapup );
     

     status = om$send( msg = message Root.connect(ND_children,OM_K_MAXINT,
			  my_id,OM_Gw_current_OS,AC_template_chns, OM_K_MAXINT),
		      targetid = template[i].objid);
     as$status( action = GOTO_VALUE, value = wrapup );
     }
     else template[i].objid = NULL_OBJID;
    }

/* Copy now the dependent graph */

  status = nd$copy_graph(nb_root = tot_temp,
			 cp_type = ND_TO_MACRO,
			 type_graph = ND_COPY_EXT,
			 p_root  = template,
			 p_clone = &copy_list,
			 from_info = &fr_env, 
			 to_info = &to_env );
  as$status(action = GOTO_VALUE, value = wrapup);

/* Connect now template with fixed value */

   for(j=real_tot_temp;j<tot_temp;j++)
    {
     for(i=0;i<copy_list.nb_obj;i++)
      {

/*
 * If a body element becomes a root then a local edit is done on the
 * graph. At that time we need the compare the copy_list.original
 * with the objids stored in the entry array and not in tlist
 * pp 07/13/92
 */
       if(copy_list.list[i].original == entry[j].objid)
	{
         status = om$send( msg = message Root.connect(ND_children,OM_K_MAXINT,
			  my_id,OM_Gw_current_OS,AC_template_chns, OM_K_MAXINT),
		      targetid = copy_list.list[i].clone);
         as$status( action = GOTO_VALUE, value = wrapup );
	 break;
        }
      }
     }

 

/* If elements have been added during copy graph mechanism, take them as
   macro body.  The "template" objid could also have been changed during copy 
*/  

  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,template,tot_temp,
						NULL,0,OM_K_MAXINT,&j),
		   targetid = my_id);
  if(j != tot_temp) goto wrapup;
 
  status = nd$get_graph(nb_root = tot_temp,
			p_root = template);
 
  status = nd$get_list_in_graph(acc_type = ND_BODY,
				p_count = &nb_body,
				buf_addr = &clone_list);

  all_cp_list = copy_list.list;
  body_cp_list = (struct NDcp_list *)
		        om$malloc(size= (nb_body) * sizeof(struct NDcp_list));
  if(!body_cp_list) goto wrapup;

  j=0;i=0;
  for(i1=0;i1<nb_body;i1++)
   {
    if(clone_list[i1].objid == my_id) continue;
    body_cp_list[i].clone    = clone_list[i1].objid;
    body_cp_list[i].original = NULL_OBJID;   /* for added elements */
    body_cp_list[i].position = ND_BODY;

    for(j1=0;j1<copy_list.nb_obj;j1++,j++)
     {
      if(j>=copy_list.nb_obj) j=0;
      if(body_cp_list[i].clone == all_cp_list[j].clone)
	{body_cp_list[i].original = all_cp_list[j].original; break;}
     }
    i++;
   }
  /*
     nb_body-1 because macro definition also depends upon copied templates 
     but is not in the body of the macro 
  */ 
  nb_body = nb_body-1;
  if(i != nb_body) goto wrapup;


/* Store objid of the members of the macro */

  status = om$vla_set_dimension(varray	= me->others,
				size	= nb_body );
  as$status(action = GOTO; value = wrapup);

  for(i=0;i<nb_body;i++)
   { me->others[i] = body_cp_list[i].clone; }


/*| Now store the feet info */ 

    for(real_feet_num = feet_num;
	real_feet_num >0 && feet[real_feet_num-1].name[0] == '\0'; 
	real_feet_num--);

    status = om$vla_set_dimension(varray= me->myfeet,
                                  size = real_feet_num );
    as$status(action = GOTO_VALUE, value = wrapup);

    me->feet_num= real_feet_num;

    num_graphic=0;
    for(i=0;i< real_feet_num;i++)
    {
     /* general info */
     me->myfeet[i]=feet[i];
     status = om$send(msg =  message NDnode.NDgive_structure( &msg,  
							&pardef, md_env ), 
		       targetid = feet_list[i].objid,
		       targetos = feet_list[i].osnum);
     as$status(action = GOTO_VALUE, value = wrapup);

     me->myfeet[i].prop=pardef.type;

     /* is the foot in template list */

     for(pos=0;pos< tot_temp;pos++)
      { if(feet_list[i].objid == tlist[pos].objid) break; }

     if(pos < tot_temp)
      {
       /*| Feet is in template */
        me->myfeet[i].pos=pos;
        me->myfeet[i].chan = feet_in_template;
      }
     else
      {
       /* Try to find it in feet list */
       for(pos=0;pos<nb_body;pos++)
        {
         if(feet_list[i].objid == body_cp_list[pos].original) break;
        }

       if(pos >= nb_body)
         {
	  printf("ACmacro_defn unable to find foot in macro\n");
          *suc=0; goto wrapup;
         }

       /* Feet is in body */
       me->myfeet[i].chan= feet_in_graphic | pos << 2;/*macro_defn index trick*/
       me->myfeet[i].pos=num_graphic;
       num_graphic=num_graphic + 1;
       status = OM_S_SUCCESS;
      }
    }
  *suc = 1;
  
wrapup:

  if(all_cp_list) om$dealloc(ptr = all_cp_list);
  if(body_cp_list) om$dealloc(ptr = body_cp_list);
  if(tmp_edit)
  {
   for(i=0;i<tot_temp;i++)
    {
     if(tlist[i].objid == entry[i].objid) continue;
     status = om$send(msg = message NDnode.NDmove_to_tmp_clone (&msg,tlist+i),
                     targetid = entry[i].objid,
                     targetos = entry[i].osnum);
     as$status();
     status = om$send(msg = message NDnode.NDdelete(&fr_env),
		      targetid = entry[i].objid,
		      targetos = entry[i].osnum);
     as$status();
    }
  }
  
  return( status );
}/* build_ACmacro_defn */

end implementation ACmacro_defn;

