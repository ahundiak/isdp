/* $Id: batch.I,v 1.4.4.1 2003/01/03 17:30:36 anand Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	 vds/emsfixes/grnuc/batch.I
 *
 * Description:  Copied from grnuc/src/assoc/node/batch.I
 *               Batch graph manager
 * Dependencies:
 *
 * Revision History:
 * $Log: batch.I,v $
 * Revision 1.4.4.1  2003/01/03 17:30:36  anand
 * For TR 7319 (suppress ACpretend errors in backscreen) -
 * "Crucial" TR (high priority) etcetera.
 *
 * Revision 1.4  2001/09/07 15:14:19  ramarao
 * Implemented CR# 5346.
 *
 * Revision 1.3  2001/01/13 00:23:50  hans
 * SP16 modifications
 *
 * Revision 1.2  2001/01/13 00:05:30  hans
 * SP16 modifications
 *
# Revision 1.2  2000/10/12  15:21:14  pinnacle
# Replaced: vds/emsfixes/grnuc/batch.I for:  by rchennup for Service Pack
#
# Revision 1.1  1999/10/11  15:47:58  pinnacle
# tr179900871
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/11/99  ah      TR179900871 Better error message when compute fails
 * -------------------------------------------------------------------*/

class implementation NDnode;
/*
  Implementation of the  batch mode of the graph manager
*/
#include <FI.h>
#include "GMdef.h"
#include "nddef.h"
#include "GMmacros.h"
#include "ndmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "batch.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "GMerrordef.h"
#include "AS_status.h"
#include "madef.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "exdef.h"
#include "exmacros.h"
#include "ASmessages.h"
#include "msdef.h"
#include "msmacros.h"
#include "comisc.h"

#include <alloca.h>

from ACdiowner import ACcreate,ACadd_component_with_name;
extern GRclassid OPP_ACdiowner_class_id;

#define NULL_INDEX  0xffff   /* The null index                                */
#define STEP_SIZE  10        /* Step to allocate memory                       */
#define AS_DEBUG

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function NDget_mod_batch                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDget_mod_batch(p_mode)

  int           *p_mode;      /* OUT    Current mode of the batch             */
  /*.NDget_mod_batch*/
  {
  extern char NDactive_mode;
  (*p_mode) = (int)NDactive_mode;
  return 1;
}/* end NDget_mod_batch */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function NDput_mod_batch                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDput_mod_batch(mode)

  int           mode;         /* IN     New current mode of the batch         */
  /*.NDput_mod_batch*/
  {
   IGRlong msg;
   IGRboolean cp_mode;
   IGRlong NumberOfBytes;
   extern char NDactive_mode;

/*" store the new mode of batch %d\n",mode */

  if(mode == ND_TRANSACTION ||
     mode == ND_IMMEDIATE   ||
     mode == ND_DEFER         ) NDactive_mode = mode;


/* set mode for dynamics */

   if(mode == ND_IMMEDIATE) cp_mode = 1;
   else			    cp_mode = 0;


/*"put_dynamcis_copy with flag = %d\n",cp_mode */

   NumberOfBytes = sizeof(IGRboolean);
   gr$put_dynamics_copy_flag(msg = &msg,
			     sizbuf = &NumberOfBytes,
			     buffer = &cp_mode);

/* update if necessary waiting objects */

  if(NDactive_mode == ND_IMMEDIATE) nd$exec_batch();
  return 1;
}/* end NDput_mod_batch */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDwait_batch                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#argsused
NDwait_batch(type, p_fr_env, p_to_env,
	     l_object, l_name, l_clone,  l_info , nb_obj)

  int              type;      /* IN     Type of operation of the message      */
  struct  GRmd_env *p_fr_env; /* IN     Pointer to the "from" environment     */
  struct  GRmd_env *p_to_env; /* IN     Pointer to the "to" environment       */
  struct  GRid     *l_object; /* IN     List of the objects which wait batch  */
  char             **l_name;  /* IN     List of additionnal name	      */
  struct  GRid     *l_clone;  /* IN     List of corresponding clone for copy  */
  char             **l_info;  /* IN     List of additionnal info per object   */
			      /*	- matrix for xform .....	      */
  int              nb_obj;    /* IN     Number of objects in the list         */

  /*.NDwait_batch*/
  {
  int    status;   /* Status returned by om                        */
  int    index,index1; /* Index for a loop                         */
  IGRint *cn_flag;

  extern struct ext_list  NDmodif,NDdelete;
  extern int    *NDmodif_flag;

/*" wait %d object prem %d %d\n",nb_obj, l_object[0].objid,l_object[0].osnum */
  switch(type)
    {

    case GR_GEOM_POSTED :
      /*| geom posted */

      /* let the user know that an explicit update is needed */
      nd$mod_batch(request = ND_INQ, p_ret_mode = &status);
      if (status == ND_DEFER)
          GRdelay_button(GR_DELAY_PENDING);

      /* Define eventually the new size */

      status = NDdef_size(nb_obj,&NDmodif,&NDmodif_flag,sizeof(int),0);
      cn_flag = (int *)l_info;

      for(index = 0; index < nb_obj; index++)
        {
         if(NDin_buffer(l_object[index],&NDmodif) == -1)
          {
	   if(l_info != NULL) NDmodif_flag[NDmodif.nb_obj] = cn_flag[index];
	   else		      NDmodif_flag[NDmodif.nb_obj] = 0;
           NDmodif.list_id[NDmodif.nb_obj++] = l_object[index];
	  /*"obj %d cn_type %d nb_obj %d\n",NDmodif.list_id[NDmodif.nb_obj-1].objid,NDmodif_flag[NDmodif.nb_obj-1],NDmodif.nb_obj */
          }
        }
      /* "%d waiting \n",NDmodif.nb_obj */
      break;

    case GR_DELETED :
      /*| object deleted */

      /* Define eventually the new size */

      status = NDdef_size(nb_obj,&NDdelete,NULL,0,0);

      /* Fill the listes of the delete batch */

      for(index = 0; index < nb_obj; index++)
        {
        if(NDin_buffer(l_object[index],&NDdelete) == -1)
         {
          NDdelete.list_id[NDdelete.nb_obj++] = l_object[index];
         }
        }

      /* supress the element from modify list and copy list */

     for(index=0 ; index<nb_obj ; index++)
       {
        index1 = NDin_buffer(l_object[index],&NDmodif);
        if(index1 != -1)
	    {
/*"remove --> %d \n",index1*/
	     NDmodif.list_id[index1].objid= NULL_OBJID;
	     /*| obj. suppress from modif */
	    }
       }

      break;
     }
  return(TRUE);
}/* end NDwait_batch */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDexec_batch                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*
 * Description : Execute the batch operations
 * Constraint  :
 */
NDexec_batch(mode, defer_flag )
IGRint mode;
IGRint defer_flag;
/*.NDexec_batch */
{
   IGRint ret_mode;
   extern IGRboolean ASbroadcast_in_progress;

   if(ASbroadcast_in_progress) return(OM_S_SUCCESS);

   nd$mod_batch(request     =  ND_INQ,
                p_ret_mode  = &ret_mode );

   if ( defer_flag == ND_UNCONDITIONAL || ret_mode != ND_DEFER )
   {
     /*| Execute the modify operations */

     NDmodify_batch(mode);

     /*| Execute the delete operations */

     NDdelete_batch();

     /*
      * Update the directory command form (if present)
      */
     DIupdate_form ();

     /* clear the update flag */
     GRdelay_button(ret_mode == ND_DEFER ? GR_DELAY_ON : GR_DELAY_OFF);
   }
  return(TRUE);
}/* end NDexec_batch */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    INTERNAL function NDmodify_batch                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#define MAX_FOIS 30
#argsused
NDmodify_batch(mode)
IGRint mode;
/*.NDmodify_batch*/
  {
  long msg,status;
  int i;
  extern struct  ext_list  NDmodif;
  extern int     *NDmodif_flag;

  extern int NDnb_start_modif;
  extern int (*NDstart_modif[] ) ();

  extern int NDnb_end_modif;
  extern int (*NDend_modif[] ) ();

  extern IGRboolean dynamics_in_progress;
  extern IGRboolean NDtell_user;
  extern IGRboolean IGEstop();
  extern int ems_do_print_error_messages;
  IGRboolean stopped =FALSE;
  int global_failure = 0;
  char error_dir_name[256];
  GRspacenum  cur_os;
  struct GRid error_dir_id;

  int            desc;        /* Description of the query                     */
  short          type;        /* Type of elements to select                   */
  extern int     GMsel_and(); /* Function to select internal types            */
  struct GRid    object;      /* Object to update                             */

  static struct GRmd_env  md_env= {{0,(OM_S_OBJID)-1},  /* md_id */
                                   {MAIDMX,  /* matrix_type */
			            {1,0,0,0, /* matrix */
			             0,1,0,0,
			             0,0,1,0,
			             0,0,0,1}}};

  int ifois;
  int NDmodif_initial;
  if(NDmodif.nb_obj == 0) return(OM_S_SUCCESS);

  ex$get_cur_mod ( osnum = &cur_os );

  for(i=0 ; i<NDnb_start_modif ; i++) (NDstart_modif[i])();

  /* several updates could be necessary due to restart broadcast or
     notification accross reference file 				  */

  for(ifois = 0; ifois <MAX_FOIS ; ifois++)
    {
    if(NDmodif.nb_obj == 0) return(OM_S_SUCCESS);

    NDcompress_list(NDmodif.nb_obj,NDmodif.list_id,NDmodif_flag,sizeof(int),
		 &NDmodif_initial);

    if(NDmodif_initial== 0)
      {NDmodif.nb_obj= 0;return(OM_S_SUCCESS);}

    if(stopped) return OM_S_SUCCESS;

/* Sort per object space */

    NDsort_per_OS(NDmodif_initial,NDmodif.list_id,NDmodif_flag,sizeof(int),
	         &NDmodif_initial);

/* Get md_env to use */

    md_env.md_id.osnum = NDmodif.list_id[0].osnum;
    if(dynamics_in_progress)
      {
      md_env.md_id.objid = NULL_OBJID;
      }
    else
      {
      ex$get_modid(mod_osnum = md_env.md_id.osnum,
       		   mod_id    =&md_env.md_id.objid);
    }/* end if(dynamics)*/

/* Update dependent graph */

/* get it */
    status = nd$get_graph
               (p_root  = NDmodif.list_id,
                nb_root = NDmodif_initial);
    if(status != GM_S_SUCCESS) {NDmodif.nb_obj = 0;}
    as$status(action = RET_STATUS);

/* initialise compute flag */
      NDset_comp_state(NDmodif.list_id,NDmodif_initial,NDmodif_flag,&ND_graph);

/* update graph */

/*
 * The following global variable has been defined to suppress the needless
 * scroll of error messages if a node fails during recomputation.
 * Prasad 03/14/92
 */

    ems_do_print_error_messages=0;
    msg = nd$update_graph(root_compute = ND_VAR_UPT,
			  md_env = &md_env);
    ems_do_print_error_messages=1;

/* Now what remains in the broadcast list ? */

    if(msg == ND_COMP_STOPPED)
    {
     ex$message(msgnumb = AS_I_StopUpd);
     nd$mod_batch(request = ND_SET,req_mode = ND_DEFER);
    }

    if(msg != ND_COMP_REST)
    {
       /* remove from the compute list of already computed element */

      for(i=0 ; i< (int)NDmodif_initial ; i++) NDmodif.list_id[i].objid=NULL_OBJID;

      desc = GM_FROM_BEGIN;
      gm$list_access_init( p_graph = &ND_graph,p_desc = &desc);

      global_failure = 0;
      type=ND_BODY|ND_ROOT;
      while(gm$list_access_next
           (select_fct   = GMsel_and,
            p_sel_info   = &type,
            p_graph      = &ND_graph,
            p_desc       = &desc,
           p_object      = &object)== GM_S_SUCCESS)
       {
	NDget_comp_state(&object,1,&msg,&ND_graph);
	if(msg == ND_COMP_OUT_OF_DATE)
	 {
          nd$mod_batch(request = ND_SET,req_mode = ND_DEFER);
	  nd$wait_batch(type = GR_GEOM_POSTED,
			nb_obj = 1,
			l_object = &object);
	 }
        else if(!(msg&1))
	 {
           char obj_class[40];
/*
 * Added the output of classname of the entity which failed
 * Prasad 03/14/92
 */
          obj_class[0] = '\0';
          status = om$get_classname(objid = object.objid,
                                    osnum = object.osnum,
                                    classname = obj_class);

/*
 * 09/30/92 - JSD - Do not print the line if the objid is not valid
 *                  This is for TR 119220065 at Henry's request
 *                  It has something to do with delay update of
 *                  associative elements being on and merging profiles
 */
	  /* TR179900871 Add osnum to the error message in case object is in
	   * a reference file
	   */

          if ( OM_Gf_verbose_warning && (status&1) ) {
	    if( object.osnum == cur_os )
	      printf("IN CURRENT FILE: COMPUTE of %d,%d failed, %s \n",
					object.osnum,object.objid, obj_class);
	    else
	      printf("REFERENCE FILE : COMPUTE of %d,%d failed, %s \n",
				       object.osnum, object.objid, obj_class);
	  }

	  /* Name the element in error in an ERROR directory */
          if(NDtell_user && !dynamics_in_progress)
	   {
	    if(!global_failure)
	      NDcreate_failure_dir(object.osnum,error_dir_name,&error_dir_id);
	    global_failure += 1;
	    if(error_dir_id.objid != NULL_OBJID)
	      NDname_error(&object,&error_dir_id);
	   }
	 }
       }
    }
    /*"%d elements added in batch in compute\n",NDmodif.nb_obj-NDmodif_initial*/
  }/* end for*/

  for(i=0; i<NDnb_end_modif; i++) (NDend_modif[i])();

  if(global_failure && NDtell_user)
   {
    char *c,*strrchr();

    c = strrchr(error_dir_name,':');
    if(c) c++;
    else c = error_dir_name;
    ex$message(msgnumb=AS_I_ElemNam,type = "%s",var = c);
   }


  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    INTERNAL function NDdelete_batch                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/***************************************************************************
History
	DLB 	10/03/91	Call NDcompress_list with *short instead
				of *int.  THIS IS A SUN PORT RELATED PROBLEM.

	Sudha	05/23/94	Purify fix. Initialize object array after
				om$malloc()
****************************************************************************/

NDdelete_batch()
  /*.NDdelete_batch */

  {
  IGRint i,msg,status;
  struct GRid new_obj;
  IGRint idel,iobj,nb_obj,nb,index;
  int end_delete,ifois, kont;
  static struct GRid *list, *object = NULL;
  static int obj_size = 0;
  extern  IGRboolean ASbroadcast_in_progress;
  extern struct  ext_list  NDdelete;
  IGRboolean save_broad;

  static struct GRmd_env  md_env= {{0,(OM_S_OBJID)-1},  /* md_id */
                                   {MAIDMX,  /* matrix_type */
			            {1,0,0,0, /* matrix */
			             0,1,0,0,
			             0,0,1,0,
			             0,0,0,1}}};

  if(NDdelete.nb_obj == 0) return(OM_S_SUCCESS);


/*"%d obj to delete first %d\n",NDdelete.nb_obj,NDdelete.list_id[0].objid */


 save_broad = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;

/* This loop is used when the delete, move_to_root, or disconnect method of an
   object performs a "wait_delete" on another object.
*/

for(ifois = 0 ; ifois<10 ; ifois++)
{
 /* Remove already delete elements */
 { /*SUN PORT RELATED FIX *short instead of *int - Dave Brann 10/3/91*/
   int dlb_nb_obj;

   NDcompress_list(NDdelete.nb_obj,NDdelete.list_id,NULL,0,&dlb_nb_obj);
   NDdelete.nb_obj = dlb_nb_obj;
 }

 if(NDdelete.nb_obj == 0) break;
 end_delete = NDdelete.nb_obj;


/* get the list of dependent objects that must be notified */

 nb_obj = 0;
 for(idel=0;idel<end_delete;idel++)
  {
     status=om$send(msg=message NDnode.NDget_objects(
				 ND_CHILDREN | ND_IN_BUF,
		    		 NULL,0,&list,0,OM_K_MAXINT,&nb),
		    senderid = NULL_OBJID,
		    targetid = NDdelete.list_id[idel].objid,
		    targetos = NDdelete.list_id[idel].osnum);
     if(!(status&1)) nb = 0;
     /*"%d object\n",nb */

     if(nb_obj + nb>obj_size)
       {
        if(obj_size) om$dealloc(ptr = object);

        obj_size = nb_obj + nb + 10;
        object = (struct GRid *) om$malloc
				        (size = obj_size*sizeof(struct GRid));
        if(object == NULL) return (OM_W_ABORT);

	/* purify fix */
        for ( kont = 0; kont < obj_size; kont ++ )
	   object[kont].objid = NULL_OBJID;

       }

     for(iobj=0;iobj<nb;iobj++)
        {
         index = NDin_buffer(list[iobj],&NDdelete);
	 if(index >= 0 && index < end_delete)
          { /*" child %d also deleted\n",list[iobj].objid */ continue;}
	 for(i=0;i<nb_obj;i++)
	  {if(  object[i].objid == list[iobj].objid
	      &&object[i].osnum == list[iobj].osnum)
	      {/*" child %d already found\n",list[iobj].objid */ break;}
	  }
	 if(i<nb_obj) continue;
	 object[nb_obj++] = list[iobj];
	}
  }


/* Send them the "parent_deleted" message */

 for(iobj=0;iobj<nb_obj; iobj++)
      {
       md_env.md_id.osnum = object[iobj].osnum;
       ex$get_modid(mod_osnum = md_env.md_id.osnum,
    		    mod_id    = &md_env.md_id.objid);
       status=om$send(msg = message NDnode.NDparent_deleted ((IGRlong *)&msg,
				  end_delete,NDdelete.list_id,&new_obj,&md_env),
		    senderid = NULL_OBJID,
	            targetid = object[iobj].objid,
		    targetos = object[iobj].osnum);
       /*"%d %d parent_deleted\n", object[iobj].objid,object[iobj].objid*/
       if(status == OM_S_SUCCESS) {/*"%d %d O\n",new_obj.objid,new_obj.osnum*/}
       else 			  {/*| FAILED\n*/}
      }

/* get the list of root objects that must be notified */

 nb_obj = 0;
 for(idel=0;idel<end_delete;idel++)
  {
     status=om$send(msg=message NDnode.NDget_objects(
				 ND_ROOT | ND_IN_BUF,
		    		 NULL,0,&list,0,OM_K_MAXINT,&nb),
		    senderid = NULL_OBJID,
		    targetid = NDdelete.list_id[idel].objid,
		    targetos = NDdelete.list_id[idel].osnum);
     if(!(status&1)) nb = 0;
     /*"%d root\n",nb */

     if(nb + nb_obj>obj_size)
       {
        if(obj_size) om$dealloc(ptr = object);

        obj_size = nb + nb_obj + 10;
        object = (struct GRid *) om$malloc(size = obj_size*sizeof(struct GRid));
        if(object == NULL) return (OM_W_ABORT);

	/* purify fix */
        for ( kont = 0; kont < obj_size; kont ++ )
	   object[kont].objid = NULL_OBJID;
       }

     for(iobj=0;iobj<nb;iobj++)
        {
         index = NDin_buffer(list[iobj],&NDdelete);
	 if(index >= 0 && index < end_delete)
          { /*" parent %d also deleted\n",list[iobj].objid */ continue;}
	 for(i=0;i<nb_obj;i++)
	  {if(  object[i].objid == list[iobj].objid
	      &&object[i].osnum == list[iobj].osnum)
	      {/*" object %d already found\n",list[iobj].objid */ break;}
	  }
	 if(i<nb_obj) continue;
	 object[nb_obj++] = list[iobj];
	}
  }


/* Send them the "children_deleted" message */

 for(iobj=0;iobj<nb_obj; iobj++)
      {
       /* Purify fix, changed md_env.md_id.osnum to object[iobj].osnum from
	  NDdelete.list_id[iobj].osnum */

       md_env.md_id.osnum = object[iobj].osnum;
       ex$get_modid(mod_osnum = md_env.md_id.osnum,
    		    mod_id    = &md_env.md_id.objid);

       status=om$send(msg = message NDnode.NDchildren_deleted ((IGRlong *)&msg,
				  end_delete,NDdelete.list_id,&new_obj,&md_env),
		    senderid = NULL_OBJID,
	            targetid = object[iobj].objid,
		    targetos = object[iobj].osnum);
       /*"%d %d children_deleted\n", object[iobj].objid,object[iobj].objid*/
       if(status == OM_S_SUCCESS) {/*"%d %d O\n",new_obj.objid,new_obj.osnum*/}
       else 			  {/*| FAILED\n*/}
      }

/*| now delete the elements themselves*/

  for(idel=0;idel<end_delete;idel++)
    {
/*"delete %d %d\n",NDdelete.list_id[idel].objid,NDdelete.list_id[idel].osnum */
     md_env.md_id.osnum = NDdelete.list_id[idel].osnum;
     ex$get_modid(mod_osnum = md_env.md_id.osnum,
    		  mod_id     =&md_env.md_id.objid);

     om$send(msg = message NDnode.NDdelete(&md_env),
	     senderid = NULL_OBJID,
	     targetid = NDdelete.list_id[idel].objid,
	     targetos = NDdelete.list_id[idel].osnum);
     NDdelete.list_id[idel].objid = NULL_OBJID;
    }
}


  /*| Remove the delete list */
  NDdelete.nb_obj = 0;
  ASbroadcast_in_progress = save_broad;
  return(TRUE);
}/* end NDdelete_batch */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     INTERNAL function NDin_buffer                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDin_buffer(object, p_buff)

  struct  GRid     object;    /* IN     Object to test                        */
  struct ext_list  *p_buff;   /* IN     Buffer to look for                    */

  /*.NDin_buffer*/
  {
   int index;
   index = NDin_buffer_var(object, p_buff,0);
   return(index);
  }

NDin_buffer_var(object, p_buff, starting_index)

  struct  GRid     object;    /* IN     Object to test                        */
  struct ext_list  *p_buff;   /* IN     Buffer to look for                    */
  int starting_index;         /* IN     index to start search		      */

  /*.NDin_buffer_var*/
  {
  int index;     /* Index for a loop                             */

  for(index = starting_index; index < p_buff->nb_obj; index++)
   {
  /*" compare %d et %d\n",p_buff->list_id[index].objid,object.objid */
    if(IF_EQ_OBJID(p_buff->list_id[index].objid ,  object.objid) &&
                  (p_buff->list_id[index].osnum == object.osnum)) return(index);
   }

  /*| object not in list */
  return(-1);
}/* end NDin_buffer_var */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     INTERNAL function NDdef_size                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDdef_size(nb_obj,p_buff,p_add_info,size_of_add_info,size_of_name)

  int              nb_obj;    /* IN     Number of objects to add in the buffer*/
  struct ext_list  *p_buff;   /* IN/OUT Buffer to redefine size               */
  char          **p_add_info; /* additionnal information array                */
  int       size_of_add_info; /* size */
  int       size_of_name;     /* size of added name 			      */


  /*.NDdef_size */
  {
  int               new_size; /* New size of the buffer                       */

  new_size = (p_buff->nb_obj + nb_obj);

  if(p_buff->size < new_size)
   {
    new_size = ((new_size / STEP_SIZE) + 1) * STEP_SIZE;
    if(new_size >= NULL_INDEX) return(FALSE);

    /* alllocate size for list of objects */
    if(p_buff->list_id == NULL)
      {
       /*"alloc de %d\n",new_size */
       p_buff->list_id = (struct GRid *)malloc(new_size*sizeof(struct GRid));
      }
    else
      {

       /*"realloc de %d\n",new_size */
    /* allocate size for additionnal information */
       p_buff->list_id = (struct GRid *)
			  realloc(p_buff->list_id,new_size*sizeof(struct GRid));
      }

    if(size_of_add_info != 0 && p_add_info != NULL)
     {
      if(*p_add_info == NULL)
      {
       /*"alloc de %d\n",new_size */
       *p_add_info = om$malloc(size = new_size*size_of_add_info);
      }
      else
      {
       /*"realloc de %d\n",new_size */
       *p_add_info = om$realloc(size = new_size*size_of_add_info,
			        ptr = *p_add_info);
      }
      p_buff->list_inf = *p_add_info;
    }

    /* allocate size for name */
    if(size_of_name != 0)
     {
      if(p_buff->list_name == NULL)
      {
       /*"alloc de %d\n",new_size */
       p_buff->list_name = om$malloc(size = new_size*size_of_name);
      }
      else
      {
       /*"realloc de %d\n",new_size */
       p_buff->list_name = om$realloc(size = new_size*size_of_name,
				      ptr  = p_buff->list_name);
      }
     }


    p_buff->size = new_size;
    p_buff->size_inf = size_of_add_info;
    p_buff->size_name = size_of_name;

   }
  return(TRUE);
}/* end NDdef_size */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function NDcompress_list                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDcompress_list(nb_in,list1,list2,sizeof2,nb_out)
int nb_in,*nb_out;
struct GRid *list1;
char *list2;
int sizeof2;
/*.NDcompress_list*/
{
int i,iout;
/*"supress the null objid in list1 and compress it nb_in = %d\n",nb_in */

iout = 0;
for(i=0;i<(int)nb_in;i++)
   {
    if(!IF_EQ_OBJID(list1[i].objid,NULL_OBJID))
       {list1[iout].objid = list1[i].objid;
        list1[iout].osnum = list1[i].osnum;
 	if(iout<i) list1[i].objid = NULL_OBJID;

	if(list2!=NULL)
          {OM_BLOCK_MOVE(&list2[i*sizeof2],&list2[iout*sizeof2],sizeof2);}
	iout++;
       }
   }
*nb_out = iout;
return OM_S_SUCCESS;
}


NDsort_per_OS(nb_in,list1,list2,sizeof2,nb_out)
int nb_in,*nb_out;
struct GRid *list1;
char *list2;
int sizeof2;
/*.NDsort_per_OS*/
{
IGRint i,j,n_os,i_os;
GRspacenum work_os,*osnums;
static char *tmp_list2;
struct GRid tmp_list1;
struct GRid mod;
long msg;

/* make sure that the objects are sorted per osnum */

work_os = list1[0].osnum;

for(i=0;i<(int)nb_in;i++) if(list1[i].osnum != work_os) break;

if ( i>= (int)nb_in) {/*| everything in the same OS */
                 *nb_out = nb_in; return OM_S_SUCCESS; }

/*| Get the order of the reference file */

ex$get_cur_mod(id = &mod.objid, osnum = &mod.osnum);
GRget_sorted_nested_files (&msg,&n_os,&osnums,mod.osnum);

  /*^{int jla;
      printf("include ref \n");
      for(jla=0;jla<n_os;jla++) printf(" %d ",osnums[jla]);
      printf("\n");
     }
  */

/*| Search which OS must be updated first */

for(i_os=n_os-1 ; i_os >=0 ;i_os--)
 {
  for(i=0;i<(int)nb_in;i++) if(list1[i].osnum == osnums[i_os]) break;
  if(i<(int)nb_in) break;
  /*"no object in os %d waiting update\n",osnums[i_os] */
 }
work_os = list1[i].osnum;

/*"Updating in os %d\n",work_os */

if(sizeof2 > 0) tmp_list2 = (char *) alloca(sizeof2);

if(!tmp_list2) return OM_W_ABORT;

i = 0;
j = nb_in - 1;
do
 {
  while (i<=j)
    { /*"test %d same\n",i*/
      if(list1[i].osnum == work_os) i++; else break;}

  /*| mismatched OS found */

  while (i<=j)
    { /*" test %d different\n",j*/
      if(list1[j].osnum != work_os) j--; else break;}

  if(i<j)
   {
    /*" permutation  i %d j %d\n",i,j*/
    tmp_list1 = list1[i];
    list1[i]  = list1[j];
    list1[j]  = tmp_list1;
    if(list2!=NULL)
     {
      OM_BLOCK_MOVE(list2+i*sizeof2,tmp_list2      ,sizeof2);
      OM_BLOCK_MOVE(list2+j*sizeof2,list2+i*sizeof2,sizeof2);
      OM_BLOCK_MOVE(tmp_list2,list2+j*sizeof2,sizeof2);
     }
    i++;
    j--;
   }
 } while(i<=j);

 /*"final i %d final j %d\n",i,j */
 *nb_out = i;

  /*^{int jla;
      printf("nb_out = %d\n",*nb_out);
      for(jla=0;jla<*nb_out;jla++)
			  printf(" %d %d ",list1[jla].objid,list1[jla].osnum);
      printf("\n");
      printf("still waiting\n");
      for(jla=*nb_out;jla<nb_in;jla++)
			  printf(" %d %d ",list1[jla].objid,list1[jla].osnum);
      printf("\n");
     }
   */
return 1;
}

ND_mod_graph(request,req_mode,p_ret_mode)
IGRint request,req_mode,*p_ret_mode;
/*.ND_mod_graph*/
{
 extern char NDgraph_mode;

/*"request %d req_mode %d\n",request,req_mode*/

switch(request)
{
 case ND_INQ :
  if(p_ret_mode != NULL) *p_ret_mode = NDgraph_mode;
  break;
 case ND_SET :
  /*" req_mode = %d\n",req_mode */

  if(req_mode & ND_BROAD_COP)
     NDgraph_mode = (NDgraph_mode & ~ND_NO_BROAD_COP) | ND_BROAD_COP;
  if(req_mode & ND_NO_BROAD_COP)
     NDgraph_mode = (NDgraph_mode & ~ND_BROAD_COP) | ND_NO_BROAD_COP;

  if(req_mode & ND_CONN_COP)
     NDgraph_mode = (NDgraph_mode & ~ND_NO_CONN_COP) | ND_CONN_COP;
  if(req_mode & ND_NO_CONN_COP)
     UI_status("Option not available");
/*     NDgraph_mode = (NDgraph_mode & ~ND_CONN_COP) | ND_NO_CONN_COP; */

  if(req_mode & ND_BROAD_DEL)
     NDgraph_mode = (NDgraph_mode & ~ND_NO_BROAD_DEL) | ND_BROAD_DEL;
  if(req_mode & ND_NO_BROAD_DEL)
     NDgraph_mode = (NDgraph_mode & ~ND_BROAD_DEL) | ND_NO_BROAD_DEL;

  if(p_ret_mode != NULL) *p_ret_mode = NDgraph_mode;
  break;
 default :
  printf("unknown request in nd$mod_graph call\n");
  break;
}
/*"NDgraph_mode --> %x \n",NDgraph_mode */
return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDis_waiting                             */
/* Is an object waiting in a batch queue ? 				      */
/* return eventually pointer to associated name and info		      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDis_waiting(type, starting_index , l_object,
	     waiting_index, waiting_name, waiting_info, nb_obj)

  int           type;      /* I  Type of queue inquired		      	      */
  int  starting_index;     /* I  Start index to perform partial search	      */
  struct  GRid  *l_object; /* I  List of the objects 			      */
  int   *waiting_index;    /* O  returned index in waiting list		      */
  char  **waiting_name;    /* O  returned name if any  			      */
  char  **waiting_info;    /* O  returned information if any  		      */
  int 		nb_obj;    /* I  number of objects in l_object 		      */

  /*.NDis_waiting*/
  {
   int i_obj,found,index;
   struct ext_list *active_list;


   /* get pointer to batch list */

   NDget_batch_list(type,&active_list);
   if(active_list == NULL) return (FALSE);
   found = FALSE;

   if(starting_index <0) starting_index = 0;


   /* loop on object to return information about */

   for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
    { /*"is %d %d waiting\n",l_object[i_obj].objid,l_object[i_obj].osnum */
      index = NDin_buffer_var(l_object[i_obj],active_list,starting_index);
      if(index != -1)
	{
	 /*| found */
	 found = TRUE;
	 if(waiting_name != NULL && active_list->list_name != NULL)
	    waiting_name[i_obj] = active_list->list_name +
			    index*active_list->size_name;

	 if(waiting_info != NULL && active_list->list_inf  != NULL)
	    waiting_info[i_obj] = active_list->list_inf +
			    index*active_list->size_inf;
	}
      if(waiting_index != NULL) waiting_index[i_obj] = index;
   }
   return (found);
  }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* function NDget_batch_list			                              */
/* get address of the batch list corresponding to a specific queue	      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


NDget_batch_list(type,active_list)
  int                 type;      /* I  Type of queue */
  struct ext_list **active_list; /* corresponding queue address */

  /*.NDget_batch_list */
  {
   extern struct  ext_list  NDmodif, NDdelete;
   *active_list = NULL;

      switch (type)
        {

	 case GR_GEOM_POSTED :				/*| POSTED */
	 *active_list = &NDmodif;
	 break;

	 case GR_DELETED :				/*| DELETED */
	 *active_list = &NDdelete;
	 break;
	}

   if(*active_list == NULL) return (OM_W_ABORT);
   else			    return (OM_S_SUCCESS);
  }

#define ND_MAX_FUN 5

 NDadd_start_modif(user_func)
 int (*user_func) ();
/*.NDadd_start_modif*/
{
 extern int NDnb_start_modif;
 extern int (*NDstart_modif[] ) ();
 int i;
 /* Verify if not already there */
 for(i=0 ; i<NDnb_start_modif ; i++)
  { if(NDstart_modif[i] == user_func)/*|already there*/ return 0;}

 /* is there slot available */

 if(NDnb_start_modif < ND_MAX_FUN)
  { NDstart_modif[NDnb_start_modif++] = user_func; }
 return 1;
}

 NDadd_end_modif(user_func)
 int (*user_func) ();
/*.NDadd_end_modif*/
{
 extern int NDnb_end_modif;
 extern int (*NDend_modif[] ) ();
 int i;
 /* Verify if not already there */
 for(i=0 ; i<NDnb_end_modif ; i++)
  { if(NDend_modif[i] == user_func)/*|already there*/ return 0;}

 /* is there slot available */

 if(NDnb_end_modif < ND_MAX_FUN)
  { NDend_modif[NDnb_end_modif++] = user_func; }
 return 1;
}

NDcreate_failure_dir(osnum,error_dir_name,error_dir_id)
GRspacenum osnum;
char *error_dir_name;
struct GRid *error_dir_id;
{
 long status,loc_msg;
 int i;
 char pathname[80];
 di$give_pathname(osnum = osnum,
		  pathname = pathname);
/* Create a directory to name element in error */
 error_dir_id->objid = NULL_OBJID;
 i = 0;
 for(i=0;i<1000;i++)
  {
   sprintf(error_dir_name,"%s:usr:ERROR%d",pathname,i);
   status = di$translate(osnum = osnum,
			 p_objid = &error_dir_id->objid,
			 objname = error_dir_name);
   if(!(status&1)) break;
  }
 if(i<1000)
  {
   error_dir_id->osnum = osnum;
   status = om$construct(msg = message ACdiowner.ACcreate
						      (&loc_msg,error_dir_name),
			 classid = OPP_ACdiowner_class_id,
			 osnum = osnum,
			 p_objid = &error_dir_id->objid);
   if(status&loc_msg&1) return OM_S_SUCCESS;
  }

 return OM_W_ABORT;


}

NDname_error(objid,error_dir_id)
 struct GRid *objid;
 struct GRid *error_dir_id;
{
 char error_obj_name[256];
 long status,loc_msg;

/* NAME RELATIVE TO OSNUM DOES NOT WORK FOR MACRO */

 sprintf(error_obj_name,"error%d",objid->objid);
 status = om$send(msg = message ACdiowner.ACadd_component_with_name(&loc_msg,
				objid,error_obj_name),
		  senderid = NULL_OBJID,
		  targetid = error_dir_id->objid,
		  targetos = error_dir_id->osnum);
 return OM_S_SUCCESS;

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDremove_from_batch_list                 */
/* If the object is waiting in a batch queue, remove it.		      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDremove_from_batch_list(obj_grid, ptr_is_removed)
struct GRid obj_grid;  /* GRid to be removed from the batch que */
IGRboolean *ptr_is_removed; /* TRUE, if removed from the list */
{

  int index;
  struct ext_list *active_list;
  int new_nb_obj;

  *ptr_is_removed = FALSE;

  /* get pointer to batch list */
  NDget_batch_list(GR_GEOM_POSTED,&active_list);
  if(active_list == NULL)
    return (OM_S_SUCCESS);

  /* find obj_grid to remove */

  index = NDin_buffer_var(obj_grid,active_list,0);
  if(index != -1)
  {
    active_list->list_id[index].objid  = NULL_OBJID;
    *ptr_is_removed = TRUE;
  }

  NDcompress_list(active_list->nb_obj, active_list->list_id,
                  (char *)NULL, 0, &new_nb_obj);

  return (OM_S_SUCCESS);
}


end implementation NDnode;
