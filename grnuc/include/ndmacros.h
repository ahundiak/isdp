#ifndef ndmacros_include
#define ndmacros_include
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* HISTORY : jla - dp dec-87 design date                                      */
/*           jla      nov-88 rel 1.2					      */
/*           jla - dp jul-91 rel 2.0					      */
/*									      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#include "GM.h"
#include "GMmacros.h"

extern  struct GMgraph ND_graph;        /* Global graph for the system        */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef nd$get_graph(p_root     = NULL,
		    nb_root    = 0,
                    p_initial  = NULL,
                    nb_initial = 0,
		    p_tip      = NULL,
		    nb_tip     = 0,
		    p_graph    = &ND_graph) 

#if om$specified(p_root)
#   if om$specified(p_initial)
#   omerror "nd$get_graph, p_root and p_initial are both specified"
#   endif
  NDget_graph((p_root),(nb_root),(p_tip),(nb_tip),NULL,(p_graph))
#else
  NDget_graph((p_initial),(nb_initial),(p_tip),(nb_tip),NULL,(p_graph))
#endif
#endomdef


/* ABSTRACT :

  This macro build a structure containing the list of objects composing a 
  sub-part of the graph of dependency. This list is searched and sorted as
  follow :
  - only p_initial are specified : the list contains all the elements depending
    upon p_initial elements.
  - only p_tip are specified : the list contains all the elements which p_tip
    elements depend upon.
  - both p_initial and p_tip are specified : the list contains elements 
    depending upon p_initial elements and which p_tip elements depends upon 
  
  This list can then be used by the other graph manager macro like
  nd$get_list_in_graph, nd$get_type, nd$broadcast_graph, nd$update_graph,
  nd$copy_graph.

  In the list, the objects of the selected graph have one or several of the 
  following attributes which define the position of the object in the graph 
  and build its "type". They are used to perform selection in further nd$macro
  call (nd$get_type or nd$broadcast for example)

  The possible attributes of objects are :

ND_INIT   Initial objects : these objects are in the  p_initial list specify in
	  the call

ND_ROOT   Root objects : these objects are root of the selected graph. They are
	  in the  p_initial list of the call and don't depend upon other 
          elements of the list

ND_TIP    Tip objects : these objects are in the p_tip list of the call 	 
ND_BODY   Body objects : these objects depends directly or indirecly
          upon ND_INIT elements.

ND_LEAF   leaf objects : These objects have no children in the selected 

ND_EXTERN Extern objects : These objects are roots of body objects, but 
          are not in the tip list, and don't depend upon ND_INIT elements.


 An object can have several simultaneous attributes. For example an object can
 be ND_INIT and ND_BODY if this object is present in the p_root list and if
 this object has roots in the selected graph.


data type  argument   I/O        description

GRid       *p_initial  I : pointer to initial list from which the sub graph is
			   searched and sorted

IGRint     nb_initial  I : number of objects in this list

GRid       *p_tip      I : pointer to list of tips (or exit point) of the sub 
			   graph, where searching the sub graph is stopped 

IGRint     nb_tip      I : number of tip objects

struct GMgraph p_graph O : structure containing the searched and sorted graph.
			  -If specified, this structure must be initialized
			   before by a gm$init_graph and free after use by a
			   gm$free_graph .
			  -If not specify the unique and global structure 
			   ND_graph is used.

  note : p_root and nb_root are TEMPORARY supported, they should be
         replaced by p_initial and nb_initial.



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef nd$get_internal_graph(p_initial,
		             nb_initial,
		             p_graph      = &ND_graph) 

NDinternal_graph((p_initial), (nb_initial), (p_graph))
#endomdef


/* ABSTRACT :

  Like nd$get_graph, This macro makes a list of the objects composing a 
  sub-part of the general graph of dependency.  The way to prune this graph
  is different : A unique list of elements p_initial is specified.
  The "internal closure" of this list is searched : It contains initial elements
  and elements which depend upon some initial elements and are parent of other.

  Thus, the searched graph contains :
  - initial elements with type ND_INIT coming from the list p_initial
    These elements can be ND_ROOT or ND_BODY depending if they have or not 
    roots in the selected graph
  - internal elements with type ND_BODY
  - extern elements : These elements are parents of ND_BODY elements but are
    not in the p_initial list and don't depend upon it.


  The p_graph structure built by this macro can then be used like the p_graph
  structure built by the macro nd$get_graph.



data type  argument I/O        description

GRid     *p_initial     I  : pointer to initial objects, from which the internal
                             transitive closure is seached

IGRint   nb_initial     I  : number of objects in this list.

struct GMgraph *p_graph O  : returned graph, same as nd$get_graph
  


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef nd$dep_exist(l_root  ,
                    nb_root ,
                    l_tip   ,
                    nb_tip  )
NDdep_exist((l_root),(nb_root),(l_tip),(nb_tip))
#endomdef

/* ABSTRACT :
   This macro returns TRUE if one of the element of the tip list depends upon
   of one element of the root list, else return FALSE.
   
   These dependence could be because a tip element is directly a child of
   a root element (direct dependency) or because because a tip element has 
   some roots that depend upon a root element.
   

  ARGUMENTS :

struct GRid   *l_root I;             List of the root objects
int           nb_root I;             Number of root objects
struct GRid   *l_tip  I;             List of the tip objects
int           nb_tip  I;             Number of tip objects

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 
#omdef nd$get_list_in_graph(acc_type = ~0,
                            rej_type = 0,
		            list     = (struct GRid *)NULL,
		            size     = 0,
		            p_count  = (int *)NULL,
			    buf_addr = (struct GRid **)NULL,
		    	    p_graph    = &ND_graph) 
#if om$specified(list) && om$specified(buf_addr)
#      omerror "nd$get_lis_in_graph, list AND buff_addr both specified"
#endif
NDget_list((acc_type), NULL ,(rej_type), NULL ,(p_graph),(p_count),(size),
	   (list),(buf_addr))
#endomdef
 
/* ABSTRACT
 
   This macro returns the objects which pass selection criteria after
   a nd$get_graph has been performed.

   These objects can be returned either in an array provided by caller (list)
   or in an internal buffer provided by the graph mananger (buf_addr). Its
   address is then returned by the macro. 

   Warning : This buffer will be reused by the graph manager in the next
   nd$get_list call or in another macro call such as nd$broadcast_graph.
 
data type  argument I/O        description

IGRint     acc_type  I : accepted type for object

IGRint     rej_type  I : rejected type for the object
		       
			 The elements returned should pass the following test
			 (type&acc_type) && !(type&rej_type)

GRid       *list    O : returned list of objects 

IGRint     size     I : size of list

IGRint     *p_count O : number of corresponding objects 

GRid     **buf_addr O : pointer to an internal list of p_count objects

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef nd$get_type(nb_obj   ,
		   p_object ,
		   p_type   ,
		   p_graph  = &ND_graph) 

NDget_type((p_object),(nb_obj), (p_type), (p_graph))

#endomdef

/* ABSTRACT
   After a nd$get_graph this macro returns the type of objects. The type of an 
   object (ND_ROOT, ND_TIP, ND_BODY, ND_LEAF, ND_EXTERN ...) defines its
   position in the graph of dependency selected by nd$get_graph. Possible
   attributes are listed within nd$get_graph description.

   If an object is not in the selected graph, its returned type is 0.

data type argument  I/O        description

GRid      p_object   I : list of objects to check type

IGRint    *p_type    O : returned list of corresponding type

IGRint    nb_obj     I : number of objects in p_object. Size of p_type

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef nd$broadcast_graph( acc_type  = ND_BODY,
                           rej_type  = 0,
                           p_msg     = NULL,
			   mode      = OM_e_wrt_object,
                           broad_fct = NULL,
                           p_broad_info = NULL,
			   order     = ND_ORDER,
		           p_graph   = &ND_graph) 
#if om$specified(p_msg) && om$specified(broad_fct)
#      omerror "nd$broadcast_gragm_broad_graph, p_msg AND p_fct both specified"
#endif
#if om$specified(p_msg)
NDbroadcast_graph((acc_type),NULL,(rej_type),NULL,(p_msg),(mode),(order),\
		  (p_graph))
#else
NDgm_broad_graph((acc_type),(rej_type),(broad_fct),(p_broad_info),(order),\
                 (p_graph))
#endif
#endomdef

/* ABSTRACT
   This macro sends a message to the components of the graph obtained by a 
   nd$get_graph if the type of element passes the selection criteria.
   (possible types for objects are listed in nd$get_graph description).

   The message is sent to each selected object even if one of them returns
   an error message.

data type  argument I/O        description

IGRint     acc_type  I : accepted type for object
IGRint     rej_type  I : rejected type for the object
			 The elements returned should pass the following test
			 (type&acc_type) && !(type&rej_type)

OM_S_MESSAGE     msg I : message to broadcast

OM_E_WRT_FLAG   mode I : mode used in the send message
			 OM_e_wrt_object or OM_e_wrt_message

IGRint          order I: Defines in which order the object will receive the 
			  message
			  -ND_ORDER in the graph of dependency order ( roots 
			   recive the message before dependent objects)
			  -ND_REVERSE in the reverse order (leaves first,
			   dependent objects receive message before roots)

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef nd$update_graph( cn_type    = 0,
		       root_compute = ND_UPT_ROOT,
		       md_env	  ,
		       p_graph    = &ND_graph)

NDupdate_graph((cn_type), (root_compute), (md_env) , (p_graph))
#endomdef

/*
ABSTRACT 

This macro updates the elements of a graph obtained by a NDget_graph call.

GRmd_env  *md_env  I : module environment
*/


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef nd$copy_graph(msg        = NULL,
		     cp_type    = 0,
		     p_root     = NULL,
		     nb_root    = 0,
		     p_tip      = NULL,
		     nb_tip     = 0,
		     type_graph = ND_CON_TIP_LIST | ND_CON_EXT_GRAPH,
		     from_info  = NULL,
		     to_info    = NULL,
		     p_graph    = &ND_graph,
		     p_clone	= NULL) 

NDcopy_graph((msg),(cp_type),(p_root),(nb_root),(p_tip),(nb_tip),
	     NULL,0,(type_graph), (from_info), (to_info) , (p_graph), (p_clone))
#endomdef

/*
ABSTRACT 

This macro copies the graph obtained by nd$get_graph to a new set of roots
and eventual tips. The different steps of the copy are :


  - perform the reconnections with the NDcopy message. Each clone object
    is reconnected to the roots of its original if they are not copied,
    reconnected to their respective clone if they are copied.

data type  argument I/O        description

IGRint     msg        O : completion code not yet implemented

IGRint     cp_type    I : purpose of copy.This argument is passed in the
			  NDcopy(to_root) message sent to object to be
   			  copied. The only specific cases are for now
		          - ND_TO_MACO copy to macro definition
		          - ND_FROM_MACRO copy from macro definition

IGRint     type_graph I : actions performed with extern and tip elements :

			   - action with tip objects 
                             ND_COPY_TIP : they are copied
			     ND_NO_COPY_TIP : they are not copied
			     ND_CON_TIP : they are not copied and are replaced
			       in the clone graph by the p_tip objects defined
			       in the nd$copy_graph call.

			   - action with extern objects :
                             ND_COPY_EXT : they are copied, and dependent
			        clone objects are reconnected to their clone.
                             ND_NO_COPY_EXT : they are not copied and  
				dependent clone objects are reconnected to
			        themselves.

GRid      *root       I : list of new roots

IGRint    nb_root     I : number of new roots. (For control only, same value
			  as the nb_root argument of the macro nd$get_graph)

GRid      *tip        I : list of new tips if necessary

IGRint    nb_tip      I : number of new tips (For control only, either 0 or
			  same value as the nb_tip argument of the macro 
			  nd$get_graph).

GRmd_env  *from_info  I : from module information

GRmd_env  *to_info    I : target module information

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef nd$copy_fence(p_object,
	      	     nb_original,
		     nb_clone,
	             p_fr_env,
	      	     p_to_env,
	      	     dynamics = FALSE,
	      	     xform    = FALSE)
NDcopy_fence((p_object),(nb_original),(nb_clone),(p_fr_env),(p_to_env),
	     (dynamics),(xform))
#endomdef

/*
ABSTRACT :
  Copy associative or non associative elements contained in a fence,
  maintaining associative relationship between copied elements.

data type  argument I/O        description

struct GRid *p_object I  list of element to copy
		      O  list of copied elements (the array of original elements
			 is reused to store clones)

int       nb_original I  numbers of elements to copy
int       *nb_clone   O  numbers of copied elements (less than nb_original
			 if we just return the root of the dependent graph)

GRmd_env   *p_fr_env  I  from and to module environment information
	   *p_to_env  I

int	   dynamics   I  the copy is for a dynamics operation
int 	   xform      I  the copy is for an xform operation (should be with
			 dynamics = TRUE)
*/




        


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef nd$mod_batch(request     = ND_SET,
                    req_mode    = ND_TRANSACTION,
                    p_ret_mode  = NULL)
#if om$equal(request,ND_SET)
  NDput_mod_batch((req_mode))
#else if om$equal(request,ND_INQ)
  NDget_mod_batch((p_ret_mode))
#endif  
#endomdef

/* ABSTRACT

   This macro defines or inquires about the operating mode of the graph
   manager for batch operation :

   - ND_IMMEDIATE is the default mode. The update of dependency is done
     immediately, even in dynamics.

   - ND_TRANSACTION updates at the end of a "transaction". At that time, the
     gaph manager receives notification by the exec at the next wait_for_input
     entry. For the user this mode means that the update is not done in
     dynamics, and is done when the final and real value  of the modified
     object is given.

   - ND_DEFER updates only  at explicit request using nd$exec_batch macro.



       nd$mod_batch(request     = ND_SET,
                    req_mode    = ND_TRANSACTION,
                    p_ret_mode  = NULL)

data type  argument I/O        description

IGRint     request   I : type of request
			  - ND_SET set the batch mode to request_mode
			  - ND_INQ return the batch mode in p_ret_mode

IGRint  request_mode I : request batch mode if request = ND_SET

IGRint  *p_ret_mode  I : current mode if request = ND_INQ
   get or define the batch mode of the graph manager according to the
   following values

   - ND_IMMEDIATE. Update immediately dependency.

   - ND_TRANSACTION . The update is done at end of each "transaction".
     A transaction is what appends between to user input. Such a mode
     allows to update the dependency in non dynamics only. Default mode
     at the run time init.

   - ND_DEFER. Update done only when explicit request using ND$batch_exec
     primitive.

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef nd$mod_graph(request     = ND_SET,
                    req_mode    = ND_BROAD_COP | ND_CONN_COP |
				  ND_NO_BROAD_DEL,
                    p_ret_mode  = NULL)
 ND_mod_graph(request,req_mode,p_ret_mode)
#endomdef

#omdef nd$mod_broadcast(request     = ND_SET,
                    	req_mode    = ND_BROAD_COP | ND_CONN_COP |
				  	ND_NO_BROAD_DEL,
                    	p_ret_mode  = NULL)
 ND_mod_graph(request,req_mode,p_ret_mode)
#endomdef

/* ABSTRACT
  This macro defines or inquires about the operating mode of the graph
   manager for copy and delete :


  ND_BROAD_COP    : objects depending upon copied objects are also copied
or
  ND_NO_BROAD_COP : only selected objects are copied


  ND_CONN_COP     : non body objects of the copied graph are reconnected to
 		    the roots of the corresponding object in the original
		    graph
or
  ND_NO_CONN_COP  : non body objects of the copied graph are not reconnected
   		    and are transformed to non associative.


  ND_BROAD_DEL    : objects depending upon deleted objects are also deleted
or
  ND_NO_BROAD_DEL : only selected objects are deleted. Their children are
		    transformed to non associative elements.



  nd$mod_broadcast(request     = ND_SET,
               req_mode    = ND_BROAD_COP | ND_CONN_COP | ND_NO_BROAD_DEL,
               p_ret_mode  = NULL)


data type  argument  I/O        description
IGRint   request      I : type of request
			    ND_SET modifies the active batch mode 
			    ND_INQ returns the active batch mode in p_ret_mod

IGRint   request_mode I : request batch mode if request = ND_SET
			    (only modified value needs to be specified)

IGRint   p_ret_mode   O : obtained mode if request = ND_SET
			  or current mode if request = ND_INQ

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef nd$exec_batch( mode = ND_DISP_ROOT | ND_DISP_BODY,
		      defer_flag = ND_CONDITIONAL )

NDexec_batch(mode, defer_flag )

#endomdef

/* ABSTRACT
     In deffer mode of batch , performs copy modification and delete (in this
     order). 
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef nd$wait_batch(type,
		     l_object    = NULL,
		     l_obj_info  = NULL,
		     nb_obj      = 0)

NDwait_batch((type),(struct GRmd_env *)NULL,(struct GRmd_env *)NULL,
	     (l_object),(char **)NULL,(struct GRid *)NULL,
             (char **)(l_obj_info),(nb_obj))
#endomdef

/* ABSTRACT

     This macro informs the graph manager that objects of the graph are 
     performing copy, update or delete operation using the following value for
     the argument type :

     object modified : ND_POSTED  = GR_GEOM_POSTED
     object deleted  : ND_DELETED = GR_DELETED
   


     The graph manager stores this information and depending upon the mode
     selected with the macro nd$batch_mode will perform the update
     of dependency

	- before first display even in dynamics (ND_IMMEDIATE)
	- before the next wait_for_input (ND_TRANSACTION)
	- at user request (ND_DEFER)

data type      argument I/O        description
IGRint          type       I  : type of operation

IGRint         nb_obj      I  : number of objects in p_object

GRid           *l_object   I  : array of objects 

char           *l_obj_info I  : array of clone objects, only used for 
				copy notifycation
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#endif
