class implementation NDnode;

#include "igrtypedef.h"
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "AS_status.h"
#include "GMerrordef.h"
#include "GMmacros.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "alloca.h"
#include "godef.h"

#define AS_DEBUG

extern  int    NDgm_send();             /* Function to send messages          */
extern  int    NDgm_update();           /* Function to update the nodes       */
extern  int    NDacrej();               /* Function to select the nodes       */
extern  int    NDancestor();            /* Function to get the ancestors      */
extern  int    NDsuccessor();           /* Function to get the successors     */

from GRgraphics import GRgetprops, GRcopy;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDinit_graph                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDinit_graph(p_graph, modulo, nb_elmt, step_size )
                 
  struct GMgraph *p_graph;    /* IN/OUT Identifier of the resultant graph     */
  int          modulo;        /* IN       Modulo de la selection du h_code    */
  int          nb_elmt;       /* IN       Default number of elements          */
  int          step_size;     /* IN       Increment number of elements        */

  /*
  Description : Initialize a graph :
                allocate memory for the the hcode table and initialize its 
                values,
                initialize the current list to NULL,

  Constraint  : modulo    > 1
                nb_elmt   > 1
                step_size > 1
  */ 

  /*.NDinit_graph */
  {
   int i;
   static char NDgraph_init = FALSE;
   extern struct GMgraph ND_graph;

   

   i = nb_elmt;

  /* KLUDGE FOR JLA */ 

  if(p_graph == &ND_graph)
    {
    if(NDgraph_init)
      return(FALSE);
    else
     NDgraph_init = TRUE;
  }

  return gm$init_graph(nb_elmt = modulo,inc_elmt = step_size,p_graph = p_graph);
}/* end NDinit_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDremove_graph                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDremove_graph(p_graph)
                 
  struct GMgraph *p_graph;   /* IN/OUT Identifier of the resultant graph     */

  /*
  Description : Remove a graph :
                desactivate the hcode table,
                desallocate memory for the hcode table,
                desallocate memory for the ordered list
  */ 
  /*.NDremove_graph */
  {
  return gm$free_graph(p_graph = p_graph);
}/* end NDremove_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    INTERNAL function NDclear_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDclear_graph(p_graph)
                 
  struct GMgraph *p_graph;    /* IN/OUT Identifier of the resultant graph     */

  /*
  Description : Clear a graph :
  */ 
  /*.NDclear_graph */
  {
  return GMclear_graph(p_graph);
}/* end NDclear_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDget_graph                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDget_graph(l_initial, nb_initial, l_tip, nb_tip, type_select ,p_graph)

  struct GRid   *l_initial;  /* IN     List of the root objects               */
  int    nb_initial;         /* IN     Number of root objects                 */
  struct GRid   *l_tip;      /* IN     List of the tip objects                */
  int    nb_tip;             /* IN     Number of tip objects                  */
  int    type_select;        /* IN     Type of the selected graph             */
  struct GMgraph  *p_graph;  /* IN/OUT Identifier of the resultant graph      */

  /*
  Description : Get the children graph of the root list and father of the tip
                list
  Constraint  :
  */ 
  /*.NDget_graph */
  {
   int i;
  /* to get rid of warning */
  i = type_select;

  if(nb_initial)
    return gm$get_graph
             (
             ancestor_fct  = NDancestor,
             successor_fct = NDsuccessor,
             l_initial     = l_initial,
             nb_initial    = nb_initial,
             l_tip         = l_tip,
             nb_tip        = nb_tip,
             p_graph       = p_graph);
  else return gm$get_graph
             (
             ancestor_fct  = NDancestor,
             l_initial     = l_initial,
             nb_initial    = nb_initial,
             l_tip         = l_tip,
             nb_tip        = nb_tip,
             p_graph       = p_graph);
}/* end NDget_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          Function NDinternal_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDinternal_graph(l_initial, nb_initial, p_graph)

  struct GRid    l_initial[]; /* IN     List of objects to get the set        */
  int            nb_initial;  /* IN     Number of objects in this list        */
  struct GMgraph *p_graph;    /* IN/OUT Returned graph                        */
  /*
  Description: For a list of elements returns the subgraph with internal
               elements information.
  Constraints: The graph returned must be initialzed before (calling
               gm$init_graph).
  */
  /*.NDinternal_graph*/
  {
  return gm$get_internal_graph
           (ancestor_fct  = NDancestor, successor_fct = NDsuccessor,
            l_initial     = l_initial,  nb_initial    = nb_initial,
            p_graph       = p_graph);
}/* end NDinternal_graph*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDget_list                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDget_list(accept_type, ex_acc, reject_type, ex_rej, p_graph, p_nb_elmt, size, l_elmt, p_list)

  int          accept_type;   /* IN     Accepted type of the list to return   */
  int          ex_acc;        /* IN     obsolete			      */
  int          reject_type;   /* IN     Rejected type of the list to return   */
  int          ex_rej;        /* IN     obsolete			      */
  struct GMgraph *p_graph;    /* IN     Identifier of the resultant graph     */
  int          *p_nb_elmt;    /* IN/OUT Number of elements in this list       */
  int          size;          /* IN     Size of the list of elements          */
  struct GRid  *l_elmt;       /* IN/OUT List of the elements                  */
  struct GRid  **p_list;      /* OUT    Pointer to the List of the elements   */

  /*
  Description : get the specified list in the graph, if the list l_elmt is 
                NULL, fill the default buffer p_list
  */ 
  /*.NDget_list */
  {
  int               status;   /* Status returned by function                  */
  short  gmtype[2];           /* mask for selection                           */
  int i;
  /* just to get rid of warning */
  i = ex_acc; i = ex_rej;

  gmtype[0] = accept_type;
  gmtype[1] = reject_type;

  if(l_elmt)
    {
    /* The array is allocated by the user */

    struct GRid  *p_tmp = l_elmt;
    *p_nb_elmt = size;
    status = GMget_list(p_graph, NDacrej, gmtype, &p_tmp, p_nb_elmt);
    }
  else
    {
    /* The Buffer is specified */
    
    if(p_list) *p_list = NULL;
    status = GMget_list(p_graph, NDacrej, gmtype, p_list, p_nb_elmt);
  }/* end if */
  return status;
}/* end NDget_list */
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function NDbroadcast_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDbroadcast_graph(accept_type, ex_acc, reject_type, ex_rej, msg, mode, order, p_graph)

  /*
  Description : Broadcast a message whith mode in the list of the graph
  */ 
  int          accept_type;   /* IN     Accepted type of the list to return   */
  int          ex_acc;        /* IN     Exclusive accept. for the accept type */
  int          reject_type;   /* IN     Rejected type of the list to return   */
  int          ex_rej;        /* IN     Exclusive accept. for the reject type */
  OM_S_MESSAGE *msg;          /* IN     Message to broadcast                  */
  OM_E_WRT_FLAG mode;         /* IN     Mode to send the message              */
  int          order;         /* IN     Order to broadcast the message        */
  struct GMgraph *p_graph;    /* IN/OUT Identifier of the resultant graph     */

  /*.NDbroadcast_graph */
  {
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean save_br;
  short  gmtype[2];           /* Mask for selection                           */
  int               status;   /* Status returned by function                  */
  int i;
  i = ex_acc; i = ex_rej; i = mode;

  save_br = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

  gmtype[0] = accept_type;
  gmtype[1] = reject_type;
  status = gm$broadcast_graph
             (select_fct = NDacrej  , p_sel_info   = gmtype,
              broad_fct  = NDgm_send, p_broad_info = msg,
              broad_mode = order,     p_graph      = p_graph);

  ASbroadcast_in_progress = save_br;
  return(status);
}/* end NDbroadcast_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDgm_broad_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDgm_broad_graph(accept_type,reject_type, broad_fct, p_broad_arg, broad_mode,
                 p_graph )
  /*
  Description : Broadcast a function whith mode in the list of the graph
  */ 
  int          accept_type;   /* IN     Accepted type of the list to return   */
  int          reject_type;   /* IN     Rejected type of the list to return   */
  int         (*broad_fct)(); /* IN     Function to broadcast                 */
  char        *p_broad_arg;   /* IN     Arguments of the broadcast function   */
  char        broad_mode;     /* IN     Broadcast mode                        */
  struct GMgraph *p_graph;    /* OUT    Pointer to the graph to broadcast     */

  /*.NDgm_broad_graph */
  {
  short  gmtype[2];           /* Mask for selection                           */
  int               status;   /* Status returned by function                  */
  extern IGRboolean ASbroadcast_in_progress;

  ASbroadcast_in_progress = TRUE;

  gmtype[0] = accept_type;
  gmtype[1] = reject_type;
  status = gm$broadcast_graph
             (select_fct = NDacrej  ,  p_sel_info   = gmtype,
              broad_fct  = broad_fct,  p_broad_info = p_broad_arg,
              broad_mode = broad_mode ,p_graph      = p_graph);

  ASbroadcast_in_progress = FALSE;
  return(status);
}/* end NDgm_broad_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function NDdep_exist                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDdep_exist(l_root, nb_root, l_tip, nb_tip)

  struct GRid   *l_root;     /* IN     List of the root objects               */
  int    nb_root;            /* IN     Number of root objects                 */
  struct GRid   *l_tip;      /* IN     List of the tip objects                */
  int    nb_tip;             /* IN     Number of tip objects                  */
  /*
  Description : Return TRUE if one of the element of the tip list is a
                successor of one element of the root list
  */ 
  /*.NDdep_exist*/
  {
  return (gm$dep_exist(l_root = l_root, nb_root = nb_root,
                      l_tip  = l_tip,  nb_tip  = nb_tip,
                      anc_fct = NDancestor) == GM_S_SUCCESS);
}/* end NDdep_exist */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDget_type                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDget_type(l_object, nb_object, l_attr, p_graph)
  struct GRid  *l_object;     /* IN     List of the objects of the graph      */
  int          nb_object;     /* IN     Number of objects in the list         */
  int          *l_attr;       /* OUT    List of the attributes of the object  */
  struct  GMgraph *p_graph;   /* IN     Identifier of the resultant graph     */

  /*
  Description : Get the attributes of the objects in l_object
  */ 
  /*.NDget_type */
  {
  return gm$get_attr(nb_object  = nb_object, l_object = l_object,
                     l_int_attr = l_attr,    p_graph  = p_graph);
}/* end NDget_type */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function NDcopy_graph                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDcopy_graph(p_msg, cp_type, l_root, nb_root, l_tip, nb_tip, l_ext, nb_ext,
	     type_select, p_from_info, p_to_info, p_graph,p_copy)

  long          *p_msg;        /* OUT    completion code                      */
  int           cp_type;       /* IN     Flag for the copy message            */
  struct GRid   *l_root;       /* IN     List of the new root objects         */
  int    nb_root;              /* IN     Number of new root objects           */
  struct GRid   *l_tip;        /* IN     List of the new tip objects          */
  int    nb_tip;               /* IN     Number of new tip objects            */
  struct GRid   *l_ext;        /* IN     List of the new extern objects       */
  int    nb_ext;               /* IN     Number of new extern objects         */
  int    type_select;          /* IN     Type of the selected graph           */
  struct GRmd_env *p_from_info;/* IN     Graphic information of the graph cop.*/
  struct GRmd_env *p_to_info;  /* IN     Graphic information of the new graph */
  struct GMgraph  *p_graph;    /* IN     Pointer to the graph to copy         */
  struct NDcp_struct *p_copy;  /* OUT    list of copied arguments	      */
  /*
  Description : copy a graph 
  Constraint  :
  */ 
  /*.NDcopy_graph */
  {
  IGRushort index0,index1,index2,index3;  /* Index for a loop                */
  long             status;    /* Status returned by om                        */
  struct GMelmt    *p_content;/* Content of a temporary graph element         */
  struct GRid      new_grid;  /* New GRid of the new object                   */
  int       *l_parent = NULL; /* List of the parents of a node                */
  struct GMhcode   *p_hcode;  /* Pointer to the hcode table for the graph     */
  long             loc_msg;   /* to have compatibility with previous call     */
                              /* without msg in the arguments list            */
  struct NDcp_list *l_copy;   /* Clone list                                 */
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean ASbr_save;
  struct GRid *real_parent;
  int nb_real;
  int max_parent;

/* Init */
  if(p_msg == NULL) p_msg = &loc_msg;
  l_copy = NULL;
   
  ASbr_save = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

/* Test if the copy is possible */

  /*| Test if the 2 list are dependant */
  
  if( nb_tip &&
      nd$dep_exist(l_root = l_tip ,nb_root = nb_tip,
		   l_tip  = l_root,nb_tip  = nb_root)) goto ERROR;
  
    /*| Every thing OK for copy */

    l_copy = (struct NDcp_list *)
			    malloc((p_graph->nb_elmt)*sizeof(struct NDcp_list));
    if(l_copy == NULL)
     {
        printf("malloc failed\n");
        goto ERROR;
     }
    p_hcode = p_graph->p_hcode;

/* Initialise list of original and clone */
    
    max_parent = 0;
    for (index0=0;index0<p_graph->nb_elmt;index0++)
     {
      index1 = p_graph->l_ord_elmt[index0];
      l_copy[index0].clone = NULL_OBJID;
      l_copy[index0].original = ((struct GRid *)GMh_key(p_hcode,index1))->objid;
      p_content = (struct GMelmt *)GMh_content(p_hcode,index1);
      l_copy[index0].position = p_content->int_attr;
      max_parent = max_parent > (int)p_content->nb_parent ?
					      max_parent : p_content->nb_parent;
     }

/* Load in clone list what was passed as argument */

/* tip */
 
    if(type_select & ND_CON_TIP_LIST)
     {
      index2 = 0;
      for (index0=0;index0<p_graph->nb_elmt;index0++)
      {
       if(!(l_copy[index0].position&ND_TIP)) continue;
       l_copy[index0].clone =l_tip[index2].objid;
       index2++;
      }
      if(index2 != nb_tip)
	{printf("error in copy_graph\n %d tip expected, %d passed in argument\n"
		,index2,nb_tip);
	 goto ERROR;
	}
     }

/* extern */
    if(nb_ext)
     {
      index2 = 0;
      for (index0=0;index0<p_graph->nb_elmt;index0++)
      {
       if(!(l_copy[index0].position&ND_EXTERN)) continue;
       l_copy[index0].clone =l_ext[index2].objid;
       index2++;
      }
      if(index2 != nb_ext) 
       {printf
	   ("error in copy_graph\n %d extern expected, %d passed in argument\n"
	    ,index2,nb_ext);
	 goto ERROR;
	}
     }

/* root */

    if(nb_root)
     {
      index2 = 0;
      for (index0=0;index0<p_graph->nb_elmt;index0++)
      {
       if(l_copy[index0].position&(ND_BODY|ND_EXTERN)) continue;
       l_copy[index0].clone =l_root[index2].objid;
       index2++;
      }
      if(index2 != nb_root)
       {printf
	   ("error in copy_graph\n %d root expected, %d passed in argument\n"
	    ,index2,nb_root);
	 goto ERROR;
       }
     }


/* now copy object or take them from argument */


    for (index1=0;index1<p_graph->nb_elmt;index1++)
      {
       /* dont copy tip, even if nullobjid */ 
       if(  (l_copy[index1].position & ND_TIP)
	  &&(type_select&ND_CON_TIP_LIST)
	  &&(l_copy[index1].clone == NULL_OBJID)) continue;

          status  = om$send(msg = message NDnode.NDcopy_graph(p_msg,cp_type,
					p_from_info,p_to_info,
					l_copy,p_graph->nb_elmt,
	    			        index1),
	         	    senderid = NULL_OBJID,
			    targetid = l_copy[index1].original,
			    targetos = p_from_info->md_id.osnum);
          as$status(action = GOTO_VALUE, value = ERROR);
      }

/*" Connect the parents. Max parent is %d\n",max_parent */

    if(!max_parent) {/*| nothing to reconnect */ goto SUCCESS;}

    new_grid.osnum      = p_to_info->md_id.osnum;
    l_parent = (int *) alloca(max_parent*sizeof(int));

    for (index0=0;index0<p_graph->nb_elmt;index0++)
      {
      if(IF_NULL_OBJID(l_copy[index0].clone)) continue;

/*
   Real parent of the object can be a sub-set of parents used during sort and
   search graph
*/
      if(l_copy[index0].position&ND_BODY) 
       {
        status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
				NULL,0,&real_parent,0,OM_K_MAXINT,&nb_real),
                       senderid = NULL_OBJID,
                       targetid = l_copy[index0].original,
		       targetos = p_from_info->md_id.osnum);
        as$status(action = GOTO_VALUE, value = ERROR);
       }
      else
       {
         nb_real = 0;
       }
      for(index2 = 0; (int)index2 < nb_real; index2++)
       {
        for(index3 = 0; index3 < p_graph->nb_elmt; index3++)
         {
	  if(real_parent[index2].objid == l_copy[index3].original) break;
         }
	if(index3 >= p_graph->nb_elmt) return OM_W_ABORT;
	l_parent[index2] = index3;
       }

      /*" Connect the parents of %d\n",l_copy[index1].clone */

      status = om$send (msg = message NDnode.NDconnect_graph (p_msg,cp_type,
					p_from_info,p_to_info,
					l_copy,p_graph->nb_elmt,
      					nb_real,
               				l_parent,
				        index0),
                      senderid = NULL_OBJID,
                      targetid = l_copy[index0].original,
		      targetos = p_from_info->md_id.osnum);
      as$status(action = GOTO_VALUE, value = ERROR);
    }/* end for(index0 = 0; index0 < nb_elmt; index0++) */

   SUCCESS :
   ASbroadcast_in_progress = ASbr_save;
   if(p_copy) 
    {
     p_copy->list = l_copy;
     p_copy->nb_obj = p_graph->nb_elmt;
    }
   else
    {
     om$dealloc(ptr = l_copy);
    }
   return(OM_S_SUCCESS);

  ERROR :
  ASbroadcast_in_progress = ASbr_save;
  if(l_copy) om$dealloc(ptr = l_copy);
  if(p_copy)
    { p_copy->nb_obj = 0;
      p_copy->list = NULL;}
  return OM_W_ABORT;
}/* end NDcopy_graph */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function NDget_current_graph                       */
/* This function returns the graph currently used by NDupdaqte_graph          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
%safe
static struct GMgraph *NDcurrent_graph = 0;
%endsafe
struct GMgraph *NDget_broadcast_graph ()
{
  return NDcurrent_graph;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function NDupdate_graph                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDupdate_graph(cn_type, root_compute, p_env, p_graph )
int cn_type;
int root_compute;
struct GRmd_env *p_env;
struct GMgraph *p_graph;

/*.NDupdate_graph */
{
 long status,loc_msg;
  static int            s_lanc=0;    /* Size of the ancestor list             */
  static struct GRid    *l_anc=0;    /* List of ancestors                     */
  static int            *l_state=0;  /* List of status                        */
  int            nb_anc=0;    /* Number of ancestors                          */
  int            desc;        /* Description of the query                     */
  short          type;        /* Type of elements to select                   */
  extern int     GMsel_and(); /* Function to select internal types            */
  struct GRid    object;      /* Object to update                             */
  struct GRid    new_id;      /* New object id after update                   */
  int el_type, int_cn_type;
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean save_br;
  int j;
  struct GRid null_grid;
  int stopped = FALSE;
  long return_code;
  int to_compute = 0;

  save_br = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;
  NDcurrent_graph = p_graph;
  null_grid.objid = NULL_OBJID;

/* Update elements of the dependent graph */

    return_code = MSSUCC;
    desc = GM_FROM_BEGIN;
    gm$list_access_init( p_graph = p_graph,p_desc = &desc);


    type=ND_BODY|ND_ROOT|ND_EXTERN; 
    while(gm$list_access_next
           (select_fct   = GMsel_and,
            p_sel_info   = &type,
            p_graph      = p_graph,
            p_desc       = &desc,
           p_object      = &object)== GM_S_SUCCESS)
      {
  
      /*
       * 03/18/92 - JSD - need to ignore NULL_OBJID objects
       */

      if ( object.objid == NULL_OBJID ) continue;

      nd$get_type(nb_obj   = 1,
	          p_object = &object,
		  p_type   = &el_type,
		  p_graph  = p_graph);

/* MOMO 11-05-92
/* begin of the modif.
/* the state for extern object was not initialized. It should be to have
/* dependent receive ND_COMP_SAME as state of parent which are extern.
/**/

      if(el_type == ND_EXTERN)
       {
        loc_msg = ND_COMP_SAME;
        status = NDset_comp_state(&object,1,&loc_msg,p_graph);
	continue;
       }

      /*" Get parents of %d.%d\n", object.objid,object.osnum*/

      status = om$send
		 (msg      = message NDnode.NDget_objects
                             (ND_ROOT,l_anc,s_lanc,NULL,0,OM_K_MAXINT,&nb_anc),
    	          senderid = NULL_OBJID,
		  targetid = object.objid,
		  targetos = object.osnum);
      if(!(status&1)) continue;

/*
 * 09/30/92 - JSD - This is for TR 119220065 at Henry's request
 *                  It has something to do with delay update of
 *                  associative elements being on and merging profiles.
 *                  This message can fail and still be in a valid state.
 *    as$status();
 */


      /* Save the buffer */

      if(nb_anc > s_lanc)
        {
        /* realloc the lists */
        s_lanc = 10*(1 + nb_anc/10);
        if(l_anc) { free(l_anc); free(l_state);}
        l_anc = (struct GRid *)malloc(s_lanc*sizeof(struct GRid));
        l_state = (int *)malloc(s_lanc*sizeof(int));
        if(!l_anc || !l_state){status=GM_E_NODYNMEM;as$status();}
  
        status = om$send
		   (msg      = message NDnode.NDget_objects
                    (ND_ROOT,l_anc,s_lanc,NULL,0,OM_K_MAXINT,&nb_anc),
    	            senderid = NULL_OBJID,
		    targetid = object.objid,
		    targetos = object.osnum);
        as$status();
        if(!(status&1)) continue;
          /*" Get state of the element %d %d\n",object.objid,object.osnum*/
	}

      /*| Get the corresponding states */

      int_cn_type = cn_type;
      if(el_type & ND_BODY)
       {
	 int_cn_type = cn_type;
	 to_compute = 1;
	 status = NDget_comp_state(l_anc,nb_anc,l_state,p_graph);
        }
      else
        {
	 if(root_compute & ND_DONT_UPT_ROOT) to_compute = 0;
	 else if(root_compute & ND_UPT_ROOT) to_compute = 1;
	 else if(root_compute & ND_VAR_UPT)
	  {
           status = NDget_comp_state(&object, 1, &el_type,p_graph);
	   if(el_type  == ND_COMP ||
	      el_type  == ND_COMP_XF) 
	    {
              to_compute = 1;
	      if(el_type == ND_COMP_XF) int_cn_type |= el_type;
	    }
	  }
	 
	 /*
	  * KLUDGE: if the element is a profile, ALWAYS compute. We need to
	  * do this because when delay is on and constraints are added to a
	  * profile, there are no parents since the profile appears as one
	  * node to the associative graph.
	  */
	 if (!to_compute)
	 {
           GRclassid ClassId, SKmgrClassId;
           int       status;
           
           status = om$get_classid ( classname = "SKmgr", 
             p_classid = &SKmgrClassId );
           if (status & 1)
           {  
             status = om$get_classid ( osnum = object.osnum, 
               objid = object.objid, p_classid = &ClassId );
             if (status & 1)
             {
 
               status = om$is_ancestry_valid ( superclassid = SKmgrClassId,
                 subclassid = ClassId );  
               if (status == OM_S_SUCCESS) to_compute = 1;
             }
           }
         }
         
	 if(to_compute)
	   for(j=0;j<nb_anc;j++) l_state[j] = ND_COMP_SUCC;
	}
      /* end if */

      if(!stopped)
       {
        stopped = IGEstop();
        if(stopped)
	         {int_cn_type = ND_COMP_STOPPED; return_code = ND_COMP_STOPPED;}
       }

      if(to_compute)
       {
/*^{ int ijla;
   printf("%d %d computed with cn_type %x\nHis parents and state\n",
         object.objid,object.osnum,cn_type);
   for(ijla=0;ijla<nb_anc;ijla++)
   printf("%d %d state %x\n",l_anc[ijla].objid,l_anc[ijla].osnum,l_state[ijla]);
  }
*/
       if(ASMget_splitpart() == TRUE)
        {
          IGRshort obj_props;
          GRclassid ClassId, EMSSurfClassId;
          IGRshort recompute;
           
           status = om$get_classid ( classname = "EMSsurface", 
               p_classid = &EMSSurfClassId );

           status = om$get_classid ( osnum = object.osnum, 
               objid = object.objid, p_classid = &ClassId );
 
           status = om$is_ancestry_valid ( superclassid = EMSSurfClassId,
                                           subclassid = ClassId );  
           if (status == OM_S_SUCCESS)
            {
             status = om$send(msg = message GRgraphics.GRgetprops(&loc_msg,
                                                        &obj_props),
                              senderid = NULL_OBJID,
                              targetid = object.objid,
                              targetos = object.osnum);

             if((el_type & ND_ROOT) 
                &&(!(obj_props & GRIS_ASSOCIATIVE)))
              {
                 /*** don't update the node ****/
                 recompute = 0;
              }
             else
                 recompute = 1;
            }
           else
                recompute = 1;

            if(recompute)
             {
                 status=om$send(msg = message NDnode.NDupdate
                           ((IGRint *)&loc_msg,int_cn_type,nb_anc,l_anc,l_state,
				         &null_grid,&new_id,p_env),
                                senderid = NULL_OBJID,
	                        targetid = object.objid,
                                targetos = object.osnum);
             }
        }
      else
        {
        status=om$send(msg = message NDnode.NDupdate
                    ((IGRint *)&loc_msg,int_cn_type,nb_anc,l_anc,l_state,
				         &null_grid,&new_id,p_env),
                     senderid = NULL_OBJID,
	             targetid = object.objid,
                     targetos = object.osnum);
        }
/*"ret stat %x msg %x new_id %d %d\n",status,loc_msg,new_id.objid,new_id.osnum*/
        if(loc_msg == ND_COMP_REST) { return_code = ND_COMP_REST; break;}
        else if(!(loc_msg &1 )) return_code = loc_msg;

        if(GMgridcmp(&new_id,&object))
         {
          /* Update the new grid in the graph */
          status = GMreplace_grid(&object, &new_id, p_graph);
          as$status();
         }
	}
      else
	{
	 /*" %d %d not computed\n",object.objid,object.osnum*/
	  loc_msg = MSSUCC;
	  new_id = object;
	}

      /*| Store the state in the graph */

      if((el_type&ND_ROOT) && (loc_msg == ND_COMP_SAME)) loc_msg = ND_COMP_SUCC;
      status = NDset_comp_state(&new_id,1,&loc_msg,p_graph);
      as$status();
    } /* end while */
   
    ASbroadcast_in_progress = save_br;
    NDcurrent_graph = NULL;
    return return_code;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation NDnode;
