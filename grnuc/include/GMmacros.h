#ifndef GMmacros_include
#define   GMmacros_include

/*
  File dependencies :

  EXgrid.h
  GM.h
*/



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        Graph manager users macros                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$init_graph
         (
         nb_elmt  = 0,
         inc_elmt = 0,
         p_graph
         )
GMinit_graph(nb_elmt,nb_elmt,inc_elmt,p_graph)
#endomdef


/*
Abstract
--------

Initializes the graph structure (allocation of the needed memory) and sets the
internal fields to their default values.


Type           Argument     I/O   Description
----           --------     ---   -----------

int            nb_elmt       IN   Average number of elements in the graph

int            inc_elmt      IN   Increment number of elements (to increase
                                  the size of the graph if necessary)

struct GMgraph *p_graph    IN/OUT Initialized graph


Note
----

If the "nb_elmt" and "inc_elmt" arguments are not specified, the graph structure
is set to its default values


Return value
------------

GM_S_SUCCESS

GM_E_NODYNMEM    The function abort because there is no dynamic memory available

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$free_graph
         (
         p_graph
         )
GMremove_graph(p_graph)
#endomdef


/*
Abstract
--------

Free the allocated space of the graph


Type           Argument     I/O   Description
----           --------     ---   -----------

struct GMgraph *p_graph    IN/OUT Freed graph


Constraints
-----------

The graph must be initialized (by calling the "gm$init_graph" macro)


Return value
------------

GM_S_SUCCESS

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
         
#omdef gm$get_graph
         (
         ancestor_fct  = NULL,
         p_anc_arg     = (char *)NULL,
         successor_fct = (int (*)())NULL,
         p_suc_arg     = (char *)NULL,
         l_initial     = (struct GRid *)NULL,
         nb_initial    = 0,
         l_tip         = (struct GRid *)NULL,
         nb_tip        = 0,
         p_graph
         )
GMget_graph(l_initial,nb_initial,l_tip,nb_tip,ancestor_fct,p_anc_arg,\
            successor_fct,p_suc_arg,TRUE,p_graph)
#endomdef

/*
Abstract
--------

Creates a graph structure which contains an internal list of the objects
composing a subgraph of the general graph of dependency. This list is stored
by the graph manager to perform broadcast operations or to answer user requests.



Type           Argument     I/O   Description
----           --------     ---   -----------

int        (*ancestor_fct)() IN   (optional) user function to get the ancestors
                                  of an object.

char           *p_anc_arg    IN   (optional) pointer to additional information
                                  for the function ancestor_fct

int        (*successor_fct)()IN   user function to get the successors of an
                                  object.
char           *p_suc_arg    IN   (optional) pointer to additional information
                                  for the function successor_fct

struct GRid    *l_initial    IN   List of initial objects to get the graph

int            nb_initial    IN   Number of root objects in the list

struct GRid    *l_tip        IN   List of tip objects of the graph

int            nb_tip        IN   Number of tip objects in the list

struct GMgraph *p_graph    IN/OUT Created graph



The user must write the two functions with the same following interface:

  get_user_successors
    (
    struct GRid  *p_object        IN     Object to inquire
    char         *p_info          IN    (optional) pointer to additional info.
    char         **p_lobject;     OUT    Pointer to the list of objects
    int          *p_nb_obj;       OUT    Number of objects Return
    )

   The ojects of the graph are given an internal attribute which defines their 
   position in the selected graph. The possible types are defined in the file
  "gmdef.h". The pointer p_info is the value given by the corresponding 
   "p_suc_arg" argument of the macro. This function has to return ISO status
   values (at least (return_code &1) = 1 if success, 0 if failure ). If the
   object doesn't have successors, returns *p_nb_obj = 0. The list of objects
   is allocated using the 2.0 protocol that is:

   if(! **pl_object)
     {
     The caller does'nt want the list, in this case just fill *p_nb_obj 
     }
   else
     {
     if(! *pl_object)
       {
       The caller assigns *pl_object = NULL to notify that he does'nt know the
       size. In this case, the function allocate a static buffer, and returns
       it in *pl_object. WARNING: the caller has eventually to copy the buffer
       to allow recursive calls.
       }
     else
       {
       The caller knows the maximum size of the list, so he gives the array
       already allocated and checked. The function fills the array without
       checking.
     }


Constraints
-----------

The graph must be initialized (by calling the "gm$init_graph" macro)

Return value
------------

GM_S_SUCCESS

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

GM_F_BAD_FUNCT_ARG  The function abort: it received a bad input argument

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
         
#omdef gm$get_internal_graph
         (
         ancestor_fct  = NULL,
         p_anc_arg     = (char *)NULL,
         successor_fct = NULL,
         p_suc_arg     = (char *)NULL,
         l_initial     = (struct GRid *)NULL,
         nb_initial    = 0,
         p_graph
         )
GMinternal_graph(l_initial, nb_initial, ancestor_fct, p_anc_arg, \
                 successor_fct, p_suc_arg, p_graph)
#endomdef

/*
Abstract
--------

Creates a graph structure which contains an internal list of the objects
composing a subgraph of the general graph of dependency

Creates a graph structure containing the subgraph defined by the initial 
objects. This subgraph is the transitive closure defined between the objects
of the initial list. The stored structure is used by the graph manager to 
perform broadcast operations or to answer user requests.



Type           Argument     I/O   Description
----           --------     ---   -----------

int        (*ancestor_fct)() IN   user function to get the ancestors
                                  of an object.

char           *p_anc_arg    IN   pointer to additional information
                                  for the function ancestor_fct

int        (*successor_fct)()IN   user function to get the successors of an
                                  object.
char           *p_suc_arg    IN   (optional) pointer to additional information
                                  for the function successor_fct

struct GRid    *l_initial    IN   List of initial objects defining the graph

int            nb_initial    IN   Number of initial objects in the list

struct GMgraph *p_graph    IN/OUT Created graph



Constraints
-----------

The graph must be initialized (by calling the "gm$init_graph" macro)

Return value
------------

GM_S_SUCCESS

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

GM_F_BAD_FUNCT_ARG  The function abort: it received a bad input argument

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$broadcast_graph
         (
         select_fct   = NULL,
         p_sel_info   = (char *)NULL,
         broad_fct,
         p_broad_info = NULL,
         broad_mode   = GM_ORDER|GM_TRIGGER,
         p_graph,
         p_grsyst     = NULL,
         l_status     = NULL
         )

GMbroadcast_graph(select_fct,p_sel_info,broad_fct,p_broad_info,broad_mode,\
                  p_graph,p_grsyst,l_status)
#endomdef

/*
Abstract
--------

Broadcast a function to all the selected nodes of the ordered list of the graph


Type           Argument      I/O  Description
----           --------      ---  -----------
    
int          (*select_fct)()  IN  user function to select the subset of objects
                                  to broadcast to

char            *p_sel_info   IN  Pointer to additional arguments of the select 
                                  function

int           (*broad_fct)()  IN  user function to broadcast to the selected
                                  objects
char            *p_broad_info IN  Pointer to the arguments of the function to
                                  broadcast
char            broad_mode    IN  Mode to broadcast the function. These modes
                                  are defined in the file "gmdef.h"

struct GMgraph  *p_graph      IN  Graph broadcast

struct GMsyst   *p_grsyst  IN/OUT System of graph receiving the notifications
                                  of the eventual topology modifications. This
                                  argument is specified only if the broadcast
                                  is dynamic.

int             *pl_status    OUT List of status of the sick objects. If this
                                  argument is specified, the status of the sick
                                  objects are stored  during the broadcast.
                                  (this list is allocated by the user)
                                 

Note
----
  
The arguments of the "select_fct" function are:


user_select_function
  (
  struct GRid      *p_object;   IN     Pointer to the object to select	
  short            int_attr;    IN     Internal attribute
  char             *p_sel_info  IN     Pointer to additional users arguments
  )

These arguments, given by the graph manager to the user function, allow to
select (by Returning a value different from FALSE) or reject (by Returning
FALSE) an object with respect to the criteria of the user.

The arguments of the "broad_fct" function are:

user_broad_function
  (
  struct GRid      *target_obj;       IN Target object
  char             *p_broad_info      IN Pointer to additional users arguments
  )


To use the graph trigger during the broadcast operation, the user's broadcast
function have to Return the predefined values described in "gmdef.h"


Notes
-----

If the broadcast is done dynamically (using the "p_grsyst" argument) and you got
the graph using one of the "p_suc_arg" or "p_anc_arg" argument, you have to be
sure that the corresponding values are still defined during the broadcast. 
(During a dynamic broadcast, the graph may be rebuild using the arguments of
the gm$get_graph macro used previously)

Return value
------------

GM_S_SUCCESS

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

GM_F_BAD_FUNCT_ARG  The function abort: it received a bad input argument

GM_E_STOP_PROCESS   The function has been stopped by the gm$stop_broadcast fct

GM_W_SICK_OBJ	    There are sick objects in the graph

GM_E_EMPTY_GRAPH    The graph is empty

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$list_access_init
         (
         p_graph,
         p_desc
         )
GMlist_access_init(p_graph, p_desc)
#endomdef

/*
Abstract
--------

Initializes the access to the list of objects of the graph.


Type           Argument     I/O  Description
----           --------     ---  -----------

int          (*select_fct)() IN   user function to select the subset of objects
                                  from the graph (this fct is the user filter).
                                  If this argument is not specified, all the
                                  objects of the graph are Return.

int            *p_des        IN   Description of the type of access. The 
                                  content may be:
                                  GM_FROM_BEGIN The list is accessed from the
                                                first node of the graph
                                  GM_FROM_END   The list is accessed from the
                                                last node of the graph


Return value
------------

GM_S_SUCCESS

GM_F_BAD_FUNCT_ARG  The function abort: it received a bad input argument

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$list_access_previous
         (
         select_fct   = NULL,
         p_sel_info   = NULL,
         p_graph,
         p_desc,
         p_object
         )
GMaccess_element(p_graph,select_fct,p_sel_info, p_desc,FALSE,p_object)
#endomdef

/*
Abstract
--------

Returns the previous object of the graph which verify the function criteria.


Type           Argument     I/O  Description
----           --------     ---  -----------

int          (*select_fct)() IN   user function to select the subset of objects
                                  from the graph (this fct is the user filter).
                                  If this argument is not specified, all the
                                  objects of the graph can be accessed

char           *p_sel_info   IN   Pointer to additional arguments of the select 
                                  function

struct GMgraph *p_graph      IN   Graph from which the nodes are selected

int            *p_des        IN   Description of the type of access given by
                                  the gm$list_access_init primitive

struct GRid    *p_grid       OUT  object Returned


Note: DO NOT modify the content of "p_des argument", it may be used in a read
      only nature



Return value
------------

GM_S_SUCCESS                      An object is found

GM_I_NEG_RESPONSE                 The requested object does not exist

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$list_access_next
         (
         select_fct   = NULL,
         p_sel_info   = NULL,
         p_graph,
         p_desc,
         p_object
         )
GMaccess_element(p_graph,select_fct,p_sel_info, p_desc,TRUE,p_object)
#endomdef

/*
Abstract
--------

Returns the next object of the graph which verify the function criteria.


Type           Argument     I/O  Description
----           --------     ---  -----------

int          (*select_fct)() IN   user function to select the subset of objects
                                  from the graph (this fct is the user filter).
                                  If this argument is not specified, all the
                                  objects of the graph can be accessed

char           *p_sel_info   IN   Pointer to additional arguments of the select 
                                  function

struct GMgraph *p_graph      IN   Graph from which the nodes are selected

int            *p_des        IN   Description of the type of access given by
                                  the gm$list_access_init primitive

struct GRid    *p_grid       OUT  object Returned


Note: DO NOT modify the content of "p_des argument", it may be used in a read
      only nature


Return value
------------

GM_S_SUCCESS                      An object is found

GM_I_NEG_RESPONSE                 The requested object does not exist

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$get_loop_path
         (
         p_object,
         p_graph,
         pl_object=NULL,
         p_count=NULL
         )
GMget_loop_elmts(p_object, p_graph, pl_object, p_count)
#endomdef

/*
Abstract
--------

Given a loop object (attribute GM_LOOP inside the graph), returns all the 
loops elements belonging to the same loop.


Type           Argument     I/O   Description
----           --------     ---   -----------

struct GRid    *p_object    IN    Known object belonging to the loop

struct GMgraph *p_graph     IN    Graph to inquire

struct GRid    **pl_object IN/OUT Pointer to the list of loop objects

int            *p_count     OUT   Number of elements in this loop


Return value
------------

GM_S_SUCCESS        The loop is found

GM_I_NEG_RESPONSE   This object does'nt belong to a loop

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

Note
----

   if the object doesn't belong to a loop, returns *p_nb_obj = 0. The list of 
   objects is allocated using the 2.0 protocol:  see gm$get_graph explanation.


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$get_attr
         (
         nb_object,
         l_object,
         l_int_attr = NULL,
         p_graph
         )

GMget_type(l_object,nb_object,p_graph,l_int_attr)
#endomdef

/*
Abstract
--------

Given a list of objects (described by the parameters l_object and nb_object) 
and the graph to inquire, this macro Returns the corresponding internal
attributes (l_int_attr).



Type           Argument     I/O  Description
----           --------     ---  -----------

int            nb_objects   IN   Number of objects in request

struct GRid    *l_object    IN   List of objects in request

short          *l_int_attr  OUT  List of the corresponding internal attribute

struct GMgraph *p_graph     IN   Graph to inquire


Return value
------------

GM_S_SUCCESS

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$dep_exist
         (
         l_root,
         nb_root,
         l_tip,
         nb_tip,
         anc_fct,
         p_anc_arg  = NULL
         )
GMdep_exist(l_root,nb_root,l_tip,nb_tip,anc_fct,p_anc_arg)
#endomdef


/*
Abstract
--------

Given the list of root elements (specifying l_root and nb_root) and the list of
tip elements (l_tip and nb_tip), this macro Returns GM_S_SUCCESS if a 
dependency (successors ---> ancestors) described by the function exists, else
Return GM_I_NEG_RESPONSE.


Type         Argument       I/O  Description
----         --------       ---  -----------
    
struct GRid  *l_root;       IN     List of the root objects

int          nb_root;       IN     Number of root objects

struct GRid  *l_tip;        IN     List of the tip objects

int          nb_tip;        IN     Number of tip objects

int          (*anc_fct)();  IN     Function to get the ancestors


Return value
------------

GM_S_SUCCESS        The dependency exist

GM_I_NEG_RESPONSE   The dependency does not exist

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      Macro only used for dynamic graph                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$init_grsyst(p_grsyst)

GMsyst_activate(p_grsyst)

#endomdef

/*
Abstract
--------

This macro initializes the graph system structure (allocation of the needed
memory) and sets the internal fields to their default values.


Type              Argument       I/O   Description
----              --------       ---   -----------

struct GMsyst     *p_grsyst    IN/OUT  Initialized graph system


Return value
------------

GM_S_SUCCESS 

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$free_grsyst
         (
         p_grsyst
         )
GMsyst_remove(p_grsyst)
#endomdef


/*
Abstract
--------

This macro frees all the allocated memory of the graph system


Type              Argument       I/O   Description
----              --------       ---   -----------

struct GMsyst     *p_grsyst    IN/OUT  Removed graph system


Constraints
-----------

The graph system must be initialized (by calling the "gm$init_grsyst" macro)


Return value
------------

GM_S_SUCCESS

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$notify_grsyst
         (
         type,
         p_object,
         p_grsyst
         )
GMgraph_request(type,p_object,p_grsyst)
#endomdef

/*
Abstract
--------

Notifies to the graph system that a topology modification occurs. This
notification will be taking into account the attached graphs


Type            Argument     I/O  Description
----            --------     ---  -----------

char            type         IN   Type of the request (see "gmdyn.h")

struct GRid     *p_object    IN   Pointer to the modified object

struct GMsyst   *p_grsyst  IN/OUT Graph system to notify


Note
----

This modification is taken into acount only if a broadcast is in progress in a
dynamic mode.


Return value
------------

GM_S_SUCCESS

GM_E_NODYNMEM       The function abort: there is no dynamic memory available

GM_W_VAR_NOT_INIT   The graph system has not graphs in its list

GM_W_ELMT_NOT_FOUND The graph system does not exist

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$stop_broadcast
         (
         p_grsyst
         )

GMstop_broadcast(p_grsyst)

#endomdef

/*
Abstract
--------

This macro stops the broacast of all the graphs attached to the graph system.


Type              Argument       I/O   Description
----              --------       ---   -----------

struct GMsyst     *p_grsyst    IN/OUT  Graph system to notify


Return value
------------

GM_S_SUCCESS


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef gm$report_error
         (
         sts,
         buffer = NULL
         )
/*
GMreport_error(sts,buffer)
*/
#endomdef

/*
Abstract
--------

This macro interprets the return code of the batch and graph macros


Type              Argument       I/O   Description
----              --------       ---   -----------

int               sts            IN    status to interpret

char              *buffer        OUT   Buffer to fill with the message 


Return value
------------

GM_S_SUCCESS

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#endif
