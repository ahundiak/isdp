/*----

 COupdate

----*/

class implementation COupdate;

#include "msmacros.h"
#include "ASmessages.h"
#include "OMmacros.h"
#include "AS_status.h"
#include "grgs.h"
#include "msdef.h"
#include "coparadef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dpmacros.h"
#include "asbox.h"
#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DImacros.h"
#include <alloca.h>

#define AS_DEBUG 1



from NDnode     import ASreturn_go,NDdisplay,NDcompute_node;

extern GRclassid OPP_NDnode_class_id,
		 OPP_ASsourcein_class_id;

method init (int type; char *string_ptr )
{
 long status,msg;
 int n_main,i_main,n_ref,i_ref;
 GRspacenum main_osnum, ref_osnum, *osnums, *main_os;
 int i,nb;
 int size,size_vla;
 OM_S_TAG_CON_INFO *tag_info;
 OM_S_CHANNUM listener;

#define OM_TCf_version_mismatch 1

 status = om$get_channel_number(channame = "ASsource.listeners",
		                p_channum = &listener);
 as$status(action = RET_STATUS);

 status = om$send(msg = message COpara.init(type,string_ptr),
                   targetid = my_id,
                   mode = OM_e_wrt_message);
 as$status(action = RET_STATUS);

 /* Get reference file attached */
 
 status = GRget_sorted_nested_files
			     (&msg,&n_main,&osnums,me->ModuleInfo.md_id.osnum);
 if(!(status&msg&1) || n_main<1)
			    return OM_W_ABORT; /* should have at least myself */

 me->n_mismatched = 0;

 main_os = (GRspacenum *) alloca(n_main*sizeof(GRspacenum));
 if(!main_os) return OM_W_ABORT;
 for(i_main=0;i_main<n_main;i_main++) main_os[i_main] = osnums[i_main];

 /* get mismatched connection */

 size_vla = om$dimension_of(varray = me->mismatched);
 
 size = 100;
 tag_info = (OM_S_TAG_CON_INFO *) om$malloc
				      (size = size * sizeof(OM_S_TAG_CON_INFO));
 if(!tag_info) return OM_W_ABORT;


 for(i_main=n_main-1 ; i_main>=0 ; i_main--)   /* to have nested first */
 {
  main_osnum = main_os[i_main];
  status = GRget_sorted_nested_files (&msg,&n_ref,&osnums,main_osnum);
  /*^{int jla;
      printf("include ref for %d\n",main_osnum);
      for(jla=0;jla<n_ref;jla++) printf(" %d ",osnums[jla]);
      printf("\n");
     }
  */
  if(!(status&msg&1)) return OM_W_ABORT;
  for(i_ref = n_ref-1 ; i_ref>=0 ; i_ref--)
   {
    ref_osnum = osnums[i_ref];
    /*" main_os %d ref_os %d\n",main_osnum,ref_osnum */
    status = om$mismatched_connections(osnum = main_osnum,
				    tagged_osnum = ref_osnum,
				    p_count = (OMuint *)&nb,
				    p_tag_con_info = tag_info,
				    size = size);
   if(!(status&1)) { nb = 0; status = OM_S_SUCCESS;}
   /*" nb_mismatched %d\n",nb */

   if(nb>size) 
   {
    om$dealloc(ptr = tag_info);
    size = 100*(1+nb/100);
    tag_info =(OM_S_TAG_CON_INFO *) om$malloc
				      (size = size * sizeof(OM_S_TAG_CON_INFO));
    if(!tag_info) return OM_W_ABORT;
   
    status = om$mismatched_connections(osnum = me->ModuleInfo.md_id.osnum,
				    tagged_osnum = ref_osnum,
				    p_count = (OMuint *)&nb,
				    p_tag_con_info = tag_info,
				    size = size);
    as$status(action = GOTO_VALUE, value = wrapup);
   }

   /* Now store them in my instances */
   if(me->n_mismatched + nb > size_vla)
   {
    size_vla = 100 * (1 + (me->n_mismatched+nb)/100);
    status = om$vla_set_dimension(varray = me->mismatched,
				 size = size_vla);
    as$status(action = GOTO_VALUE, value = wrapup);
   }

   for(i=0;i<nb;i++)
   {
    if(   tag_info[i].chan.classid != listener.classid
       || tag_info[i].chan.number  != listener.number) continue;

    /* Temperary because the list of mismatched connection seems to be
       build at wake_up 
    */
    {
     OMuword his_version;
     OM_S_OBJID ref_obj;
     status = om$tag_to_objid(osnum = ref_osnum,
			    tag =   tag_info[i].tag,
			    p_objid = &ref_obj,
			    p_version = &his_version);
     as$status();
     /*"his_version %d my_version %d\n",his_version,tag_info[i].version */
     if(his_version == tag_info[i].version) continue; 
    }
    me->mismatched[me->n_mismatched].objid = tag_info[i].objid;
    me->mismatched[me->n_mismatched].osnum = main_osnum;
    me->n_mismatched++;
   }
  } /* on ref os */
 }  /* on main os */

wrapup :
 if(tag_info) om$dealloc(ptr = tag_info);

/*** loop on OS should end there */

 return status;
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{
 ex$message( msgnumb = AC_M_Updref);
 return( OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response; char *response_data; int  pos)
{

#define NUM_STATES  2
#define NUM_ACTIONS 4
#define NUM_TOKENS  3


enum possible_states { 	INITIAL,
		        HAV_OBJ
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_OBJ,
			REL,
			UPDATE_ALL
		       };

enum possible_entry {
		     PARENT,
		     NOENT
		    };

static IGRint TokenList[] =
 		      { RESET,
			GR_UNKNOWN_TYPE,
			LOC_PARENT
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS ***********************
   Old State  *   RESET     , UNKNOWN   , PARENT */

/* INITIAL    */ {INITIAL   , INITIAL   , HAV_OBJ },
/* HAV_OBJ    */ {INITIAL   , INITIAL   , INITIAL }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS ***********************
   Old State  *   RESET      , UNKNOWN   , PARENT  */

/* INITIAL    */ {UPDATE_ALL , LOC_OBJ   , REL      },
/* HAV_OBJ    */ {UPDATE_ALL , LOC_OBJ   , LOC_OBJ  }};
                                            
    IGRint      status;         /* routine return status */
    IGRint      size;           /* size of GRevent buffer (struct GRevent) */
    IGRlong     display_flag;   /* display flag for locate filter */
    IGRlong     input_mask;     /* mask for GRgetevent */
    IGRlong     locate_mask;    /* mask for GRgetevent */
    IGRlong     msg;      /* function return code */
    IGRint resp;
    struct GRevent grevent1, grevent2;     /* event returned by GRgetevent */
    struct GRid  located_obj;
    IGRint token = 0;
    struct ret_struct ret_str;
    enum possible_entry entry_required = NOENT;
    GRclassid obj_class;
    struct GRid  context;
    IGRint countb,icount,countr,nb_obj,i;
    struct GRid *obj_to_update,*l_root,go;
    IGRshort mat_type;
    IGRmatrix matrix;
    GRspacenum start_os;
    int nb,start,new_n;
   
    *response = TERMINATE;

    /*
     *  Initialization for locate
     */

    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
    input_mask  = GRm_DATA | GRm_RESET;
    display_flag = ELEM_HILIGHT | ALL_WINDOWS | LC_ERASE_LOC_ELEMENT;

    me->attr.owner_action = LC_RIGID_COMP
                          | LC_RIGID_OWNER | LC_FLEX_COMP
                          | LC_FLEX_OWNER  | LC_REF_OBJECTS
                          | LC_NO_REF_HEADER ;



    /*
     *  loop until exit condition occurs
     */

   do
    {
        switch (me->action)
        {       
	 case NIL:
           break;

	 case ERR  :
	   ex$message( msgnumb = AS_E_InvDefRest);
           break;

         case LOC_OBJ:

           /*
            *  hilite elements which are out of date
            */

	   dp$erase_hilite(msg = &msg);
	
	   /* Remove already updated elements */

	   for(i=0,new_n=0;i<me->n_mismatched;i++)
	    {
	     if(me->mismatched[i].objid != NULL_OBJID)
	      {
	       me->mismatched[new_n].objid = me->mismatched[i].objid;
	       me->mismatched[new_n].osnum = me->mismatched[i].osnum;
	       new_n += 1;
	      }
	    }
	   me->n_mismatched = new_n;

	   /* hilight their dependency per object space */
	
	   start = 0;
	   while(1)
	    {
	      if(start >= me->n_mismatched) break;
	      start_os = me->mismatched[start].osnum;
	      for(nb=0;
		  nb<me->n_mismatched-start &&
		  me->mismatched[nb+start].osnum == start_os;
		  nb++);

 	      status = nd$get_graph(p_root = me->mismatched+start,
		       		    nb_root = nb);

 	      status = nd$broadcast_graph(p_msg = message NDnode.NDdisplay
						(0,GRhhd,&me->ModuleInfo));
	      start = start+nb;
	    }

           /*
            *  Identify element to update
            */

	   if(me->n_mismatched)
	    {ex$message(msgnumb = AS_S_OutHig);
             ex$message(buff =  me->loc_prompt, msgnumb = AS_P_IdObUpdRsAt);}

	   else
	    {ex$message(buff =  me->loc_prompt, msgnumb = AS_P_IdObjtoUpdate);}
	    
           ex$message( buff = me->acc_prompt, msgnumb = AS_P_AccNextObj);
           entry_required = PARENT;
           break;


         case REL:
  
           /*
            *  store the information in the instance and put
            *  the accept point 
 	    */
 	    me->object = located_obj;

            entry_required = NOENT;
            me->action = LOC_OBJ;
            me->state = INITIAL;

            ASstart_fence(located_obj,me->ModuleInfo.md_id.osnum,&nb_obj,
			 &obj_to_update,&resp,response_data);

	    for(icount=0,countb=0;icount<nb_obj;icount++)
                 {
		  om$get_classid(osnum = obj_to_update[icount].osnum,
				 objid = obj_to_update[icount].objid,
				 p_classid = &obj_class);
		  if(om$is_ancestry_valid(subclassid=obj_class,
			     superclassid=OPP_NDnode_class_id)!=OM_S_SUCCESS)
							   	     continue;
		  obj_to_update[countb++] = obj_to_update[icount];
		 }
	    nb_obj = countb;
	      /*" %d object to update\n",nb_obj */

            /*| get corresponding roots */

	     if(nb_obj == 0) break;
             status = nd$get_graph(p_tip = obj_to_update,
				   nb_tip = nb_obj);
	     status = nd$get_list_in_graph(rej_type = ND_BODY,
					   buf_addr = &l_root,
					   p_count   = &countr);
	     /*"%d root\n",countr */

            /* free array if necessary */

	     ASend_fence();

      case UPDATE_ALL :
	     if(me->action == UPDATE_ALL)
	       {
		l_root = me->mismatched;
		countr = me->n_mismatched;
	       }

/*| wait batch for these elements */

             for(icount=0;icount<countr;icount++)
                 {
		  om$get_classid(osnum = l_root[icount].osnum,
				 objid = l_root[icount].objid,
				 p_classid = &obj_class);
		  if(om$is_ancestry_valid(subclassid=obj_class,
			  superclassid=OPP_ASsourcein_class_id)!=OM_S_SUCCESS)
								     continue;
		 
		  status = om$send(msg = message NDnode.ASreturn_go(&go,
					 	 &mat_type,matrix),
				   targetid = l_root[icount].objid,
				   targetos = l_root[icount].osnum);
	         if(status != OM_S_SUCCESS)
		   {
		    /*| delete */
		    nd$wait_batch(type = GR_DELETED,
				   l_object = &l_root[icount],
				   nb_obj   = 1);
		   }
		else 
		   {
		    OMuword  his_version,my_version;
		    if(me->n_mismatched)
		     {
		      /* This test is only done when mismatched connection
		 	 were found to have a chance to force update
		      */
		      int go_index;
  		      OM_S_OBJECT_LINKAGE go_link[2];


	               {/*INTENTIONAL BLOCK*/
                        OMuint count;
    		        GRclassid go_classid;

		        status = om$get_channel_objects
		                           (objid = l_root[icount].objid,
		                            osnum = l_root[icount].osnum,
	        		            p_chanselect = &AS_listeners,
					    list = go_link, size = 2,
					    count = &count);
		        as$status(action = RET_STATUS);
                        if(count<1) return (OM_W_ABORT);
			if (count == 1)
                        {
                          go_index = 0;
		        }
                        else if(count == 2)
                        {
			  extern OMuword OPP_GRcontext_class_id;
                          status=om$get_classid(osnum = go_link[0].osnum,
                          			objid = go_link[0].S_objid, 
                                                p_classid = &go_classid);
                          as$status(action = RET_STATUS);

                          if((om$is_ancestry_valid(subclassid = go_classid,
                                 superclassid = OPP_GRcontext_class_id) == 
                                 OM_S_SUCCESS)) 
                          {
                            go_index = 1;
                          }
                          else
                          {
			    go_index = 0;
                          }
                        }
                        else return OM_W_ABORT;
	               }

		      status = om$test_connection(osnum = l_root[icount].osnum,
					          objid = l_root[icount].objid,
					   p_chanselect = &AS_listeners,
				      tag_osnum = go_link[go_index].osnum,
				      tag_objid = go_link[go_index].S_objid,
				       p_tag_chanselect = &AS_notification,
					  p_tag_version = &his_version,
			          p_tag_connect_version = &my_version,
					     force_flag = TRUE); 
					 
		      as$status();
/*"obj %d %d my_version %d his_version %d\n",l_root[icount].objid,l_root[icount].osnum,my_version,his_version */
		      if(status&1 && my_version == his_version) continue;

		      if(me->action != UPDATE_ALL)
		      {
		       for(i=0;i<me->n_mismatched;i++)
			{
			 if(  me->mismatched[i].objid != l_root[icount].objid
			    ||me->mismatched[i].osnum != l_root[icount].osnum)
								   continue;
			 me->mismatched[i].objid = NULL_OBJID;
			 break;
			}
		       }
		     }
		    
		/*| update element itself to recomsume if necessery its root */
		     status = om$send(msg = message NDnode.NDcompute_node
					        (&msg,0,0,NULL,&me->ModuleInfo),
				      targetid = l_root[icount].objid,
				      targetos = l_root[icount].osnum);
		
		     /* update dependency */
                     nd$wait_batch(type = GR_GEOM_POSTED,
				   l_object = &l_root[icount],
				   nb_obj   = 1);
		   }
		}
/*| now exec batch with delete operation first */
	     NDdelete_batch();
             nd$exec_batch(defer_flag = ND_UNCONDITIONAL);
	     di$update_dir_form();
	     if(me->action == UPDATE_ALL)
	      {dp$erase_hilite(msg= &msg);
	       *response = TERMINATE;
	       return OM_S_SUCCESS;
	      }
             break;
        }

    /*"entry_required: %d\n", entry_required */
    switch (entry_required)
	{

    case PARENT :

	token = ASget_parent( &msg,TokenList, &grevent1, &grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt,
                       me->acc_prompt, me->reloc_prompt,
                       &me->attr, &me->locate_stack,
                       ~0,&located_obj,&context,&ret_str);
	break;


     case NOENT:

	break;
     
     default :
	return(0);  /* waiting something better .... */

	}  /* end switch entry_required  */

/* new action and new state */

    if( entry_required != NOENT)
     {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
     }
    /*"token : %d \n new_action : %d \n new_state : %d \n",token,me->action,me->state */

   }  while( TokenList[token] != GR_UNKNOWN_TYPE);   /* end do */

    *response = resp;
    return( 1);

}   /*  end execute  */

end implementation COupdate;



