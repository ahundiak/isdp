#include <sys/types.h>
#include <stdio.h>
#include <alloca.h>
#include "OMminimum.h"
#include "EXgrid.h"
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "igrtypedef.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function GMsyst_activate                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsyst_activate(p_grsyst)

  struct GMsyst *p_grsyst;   /* OUT     Pointer to the system of graphs       */
  /*
  Description : Activate the system of graphs
  Constraint  : 
  */ 
  /*.GMsyst_activate */
  {
  int         status;         /* Status of the function                       */
  extern int  GMreq_equal();  /* Function to compare the requests             */
  extern int  GMmemcmp();     /* Function to compare the graphs               */
  int         size_cmpinfo;   /* Size of the information for the cmp function */
  
  /*| Initialize the list of the requests */
  
  status = GMl_activate(GM_REQ_SIZE,GM_REQ_SIZE,sizeof(struct GMmodif),
             GMreq_equal,NULL,NULL,&p_grsyst->requests);

  if(status==GM_S_SUCCESS)
    {
    /*| Initialize the list of graphs */
  
    size_cmpinfo = sizeof(char *);
    status = GMl_activate(DEFAULT_NB_GRAPH,DEFAULT_NB_GRAPH,size_cmpinfo,
               GMmemcmp,&size_cmpinfo,sizeof(size_cmpinfo),&p_grsyst->graphs);
  }/* if(status)*/
  return(status);
}/* GMsyst_activate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMsyst_clear                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsyst_clear(p_grsyst)

  struct GMsyst *p_grsyst;   /* OUT     Pointer to the system of graphs       */
  /*
  Description : Clear a Graph system :
  Constraint  : none
  */ 
  /*.GMsyst_clear */
  {
  int status = GM_S_SUCCESS; /* Status of the function                        */
  struct GMlist *l_graphs;   /* List of the graphs of the system              */

  /*| Clear the requests */
  
  GMl_clear(&p_grsyst->requests);
 
  /*| Remove the stacked graphs */
  
  l_graphs = &p_grsyst->graphs;
  GMl_last(l_graphs);
  while(GMl_count(l_graphs))
    {
    status = GMremove_graph(*(struct GMgraph *)GMl_current(l_graphs));
    gm$status();
  }/* while(GMl_count)*/

exception:
  return(status);
}/* GMsyst_clear */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMsyst_remove                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsyst_remove(p_grsyst)

  struct GMsyst *p_grsyst;   /* OUT     Pointer to the system of graphs       */
  /*
  Description : Remove a Graph system :
  Constraint  : none
  */ 
  /*.GMsyst_remove */
  {
  int status = GM_S_SUCCESS; /* Status of the function                        */
  struct GMlist  *l_graphs;  /* List of the graphs of the system              */

  /*| Remove the requests */
  
  status = GMl_disactivate(&p_grsyst->requests);
  gm$status();

  /*| Remove the stacked graphs */
  
  l_graphs = &p_grsyst->graphs;
  
  /*| Remove the connected graphs */

  GMl_last(l_graphs);
  while(GMl_count(l_graphs))
    {
    status = GMremove_graph(*(struct GMgraph *)GMl_current(l_graphs));
    gm$status();
  }/* while(GMl_count)*/

  /*| Remove the graph list */

  status = GMl_disactivate(l_graphs);
  gm$status();

exception:
  return(status);
}/* GMsyst_remove */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function GMattach_to_grsyst                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMattach_to_grsyst(p_graph, p_grsyst)

  struct GMgraph    *p_graph;    /* IN  Pointer to the graph to attach        */
  struct GMsyst     *p_grsyst;   /* OUT Pointer to the system of graphs       */
  /*
  Description : Attach a graph to the graph system
  Constraint  : none
  */ 
  /*.GMattach_to_grsyst*/
  {
  int status = GM_S_SUCCESS;  /* Status of the function                       */
  struct GMlist  *l_graphs;   /* List of the stacked graphs                   */

  if(p_grsyst)
    {
    l_graphs = &p_grsyst->graphs;

    /*| Get the current graph */

    if(GMl_count(l_graphs))
      {
      /*| Indicate the current graph that it is stacked */

      GMl_last(l_graphs);
      (*(struct GMgraph **)GMl_current(l_graphs))->p_broad->state|=GM_TEST_MODIFY;
    }/* if(GMl_count)*/

    /*" Attach the graph %u to the gr_syst %u\n",p_graph,p_grsyst*/

    status = GMl_add(&p_graph,&p_grsyst->graphs);
    p_graph->p_grsyst = (char *)p_grsyst;
  }/* if(p_grsyst)*/
  return(status);
}/* GMattach_to_grsyst*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function GMdetach_fr_grsyst                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMdetach_fr_grsyst(p_graph)

  struct GMgraph    *p_graph;    /* IN  Pointer to the graph to detach        */
  /*
  Description : detach a graph to the graph system
  Constraint  : none
  */ 
  /*.GMdetach_fr_grsyst*/
  {
  int status = GM_S_SUCCESS;  /* Status of the function                       */
  struct GMlist  *l_graphs;   /* List of the stacked graphs                   */

  if(p_graph->p_grsyst)
    {
    l_graphs = &((struct GMsyst *)p_graph->p_grsyst)->graphs;
    GMl_first(l_graphs);
    if(GMl_select(&p_graph,l_graphs))
      {
      /*" Detach the graph %u from the gr_syst %u\n",p_graph,p_graph->p_grsyst*/

      status = GMl_remove(l_graphs);
    }/* if(GMl_select)*/

    if(!GMl_count(l_graphs))
      {
      /*| Clear the requests list of the graph system */

      GMl_clear(&(((struct GMsyst *)p_graph->p_grsyst)->requests));
    }/* if(!GMl_count)*/
    p_graph->p_grsyst = NULL;
  }/* if(p_graph->p_grsyst)*/
  return(status);
}/* GMdetach_fr_grsyst*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMgraph_request                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMgraph_request(type, p_object, p_grsyst)
  /*
  Description : status = GMM_S_SUCCESS if the modified object is a modification 
                request for the graph system, in this case, push the request
                on the stack of requests and modify the state of the current
                broadcast graph.
  Constraint  : The graph_system must be activated
  */ 

  char              type;     /* IN     Type of the request                   */
  struct GRid       *p_object;/* IN     Pointer to the modified object        */
  struct GMsyst     *p_grsyst;/* OUT    Pointer to the system of graphs       */

  /*.GMgraph_request*/
  {
  IGRushort         ind_elmt;    /* Index of the element in the hcode            */
  int status=GM_W_ELMT_NOT_FOUND;/* Status of the function                    */
  struct GMlist  *l_graphs;   /* List of the stacked graphs                   */
  struct GMelmt  *p_content;  /* Attribute of this temporary element          */
  struct GMmodif request;     /* Request to add in the list                   */
  struct GMmodif *p_request;  /* Pointer to the Modified request              */
  struct GMgraph *p_graph;    /* Tempory graph tested                         */
  struct GMlist  *l_request;  /* List of the requests                         */

  if(p_grsyst)
    {
    l_graphs  = &p_grsyst->graphs;
    l_request = &p_grsyst->requests;

    /*| Get the current graph */

    if(GMl_count(l_graphs))
      {
      GMl_last(l_graphs);
      p_graph = *(struct GMgraph **)GMl_current(l_graphs);
      }
    else
      {
      status = GM_W_VAR_NOT_INIT;
      gm$status();
    }/* if(GMl_count)*/
  
    /*" Verify that %d.%d is in the current graph\n",p_object->objid,p_object->osnum*/

    if(GMh_give_content(p_object,p_graph->p_hcode,&p_content,&ind_elmt))
      {
      /*" The object %d.%d is in the graph system\n",p_object->objid,p_object->osnum*/
      p_graph->p_broad->state |= GM_MODIFY;
    }/* if(GMh_give_content)*/

    request.object = *p_object;
    GMl_first(l_request);
    if(GMl_select(&request,l_request))
      {
      /*" The element %d.%d is already in the list\n",p_object->objid,p_object->osnum*/

      p_request = (struct GMmodif *)GMl_current(l_request);
      p_request->type |= type;
      p_request->level = GMl_count(l_graphs);
      }
    else
      {
      /*" The element %d.%d is added in the list\n",p_object->objid,p_object->osnum*/

      request.type  = type;
      request.level = GMl_count(l_graphs);
      status = GMl_add(&request,l_request);
      gm$status();
    }/* if(GMl_select)*/
  }/* if(p_grsyst)*/

exception:
  return(status);
}/* GMgraph_request */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMredo_broadcast                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMredo_broadcast(p_graph)

  struct GMgraph    *p_graph; /* OUT    Pointer to the graph to rebroadcast   */
  /*
  Description : Update the graph with the modifications of the request list and
                restarts the broadcast.
   Constraint  : The graph must be in broadcast state and linked with a graph
                system
  */ 
  /*.GMredo_broadcast */
  {
  int status = GM_S_SUCCESS; /* Default status of the function                */
  struct GMbr_info *p_broad; /* Information about the current broadcast       */
  struct GMlist list_greq;   /* List of the request for the graph             */
  int           size_cmpinfo;/* Size of the information for the cmp function  */
  char          type;        /* type of modification to do on the graph       */
  extern int GMsel_nbroad(); /* Function to avoid the broadcast nodes         */
  int exception_type = NULL; /* Type of exception if degraded mode            */
  extern int  GMmemcmp();     /* Function to compare the graphs               */
 
  /*| Initialize the list of request for this graph */
  
  size_cmpinfo = sizeof(char *);
  status = GMl_activate(DEFAULT_NB_GRAPH,DEFAULT_NB_GRAPH,size_cmpinfo,
             GMmemcmp,&size_cmpinfo,sizeof(size_cmpinfo),&list_greq);
  gm$status();

  status = GManalyse_request(p_graph,&list_greq,&type);
  gm$status(type = EXCEPTION_1);

  if(type & GM_R_TOPOLOG)
    {
    status = GMredo_graph(&list_greq,p_graph);
    gm$status(type = EXCEPTION_1);
  }/* if(type & GM_R_TOPOLOG)*/

  /*| redo the broadcast in the graph */

  p_broad = p_graph->p_broad;
  status = GMbroadcast_graph(GMsel_nbroad,p_broad,p_broad->broad_fct,
           p_broad->p_broad_arg,p_broad->broad_mode,
           p_graph,(struct GMsyst *)p_graph->p_grsyst,NULL);
  p_graph->p_broad->state |= GM_ABORT_BROAD;

  /*| Disactivate the temporary graph request list*/

  GMl_disactivate(&list_greq);

exception:
  if(exception_type==EXCEPTION_1) GMl_disactivate(&list_greq);
  return(status);
}/* GMredo_broadcast */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GManalyse_request                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GManalyse_request(p_graph, l_greq, p_type)
  /*
  Description : Returns the type of modification necessary for the graph and
                the list of requests to be applied
  Constraint  : The graph must be connected to the graph system
                 and the list l_grep must be activated. 

  */ 

  struct GMgraph  *p_graph;   /* IN     Pointer to the graphs to analyze      */
  struct GMlist   *l_greq;    /* OUT    List of the requests for this graph   */
  char            *p_type;    /* OUT    Maximum level of modification         */

  /*.GManalyse_request*/
  {
  struct GMmodif *p_request;  /* Pointer to a request                         */
  struct GMlist  *l_request;  /* Pointer to the list of requests              */
  IGRushort         graph_level; /* Recursive level of the graph in the system   */
  struct GMsyst  *p_grsyst;   /* Pointer to the linked graph system           */
  IGRushort         ind_elmt;    /* Index of the element in the hcode            */
  struct GMelmt  *p_content;  /* Attribute of this temporary element          */
  int status = GM_S_SUCCESS;  /* Status of the function                       */

  p_grsyst    = (struct GMsyst *)p_graph->p_grsyst;
  *p_type     = GM_REQ_NULL;
  l_request   = &p_grsyst->requests;
  graph_level = GMl_count(&p_grsyst->graphs);

  for(GMl_first(l_request); !GMl_at_end(l_request); GMl_next(l_request))
    {
    p_request = (struct GMmodif *)GMl_current(l_request);
    if((p_request->level >= graph_level)&&
      GMh_give_content(&p_request->object,p_graph->p_hcode,&p_content,&ind_elmt))
      {
      /*" The object %d.%d needs to be updated in the graph\n",p_request->object.objid,p_request->object.osnum*/
      
      status = GMl_add(&p_request,l_greq);
      if(status)
        {
        (*p_type) |= p_request->type;
        p_request->level = graph_level-1;
        }
      else
        break;
    }/* if(p_request->level)*/
  }/* for(GMl_first)*/
  return(status);
}/* GManalyse_request */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function GMredo_graph                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMredo_graph(l_greq, p_graph)

  struct GMlist   *l_greq;    /* IN     List of the requests for this graph   */
  struct GMgraph  *p_graph;   /* OUT    Pointer to the graph to rebroadcast   */
  /*
  Description : Redo a new graph including the modifications of the request
                list 
  Constraint  : The graph must be in broadcast state and linked with a graph
                system
  */ 
  /*.GMredo_graph */
  {
  int status = GM_S_SUCCESS;  /* Default status of the function               */
  struct GMbr_info *p_broad;  /* Information about the current broadcast      */
  int            nb_root;     /* Number of roots of the new graph             */
  int            nb_tip=0;    /* Number of tips of the new graph              */
  struct GRid    *l_root=NULL;/* Root list of the new graph                   */
  struct GRid    *l_tip= NULL;/* Tip list of the new graph                    */
  struct GMgraph new_graph;   /* New graph to redo the broadcast              */
  struct GMgraph add_graph;   /* Additional modified graph                    */
  struct  GRid   *l_broad;    /* List of the nodes to broadcast               */
  struct  GRid   *l_trigger;  /* List of the nodes updating the trigger       */
  int            nb_el_list;  /* Number of elements in the list to broadcast  */
  int            index;       /* Index for a loop                             */
  struct GMmodif **pp_request;/* Pointer to a request                         */
  int            nb_elmt;     /* Number of elements in the list               */
  extern int     GMsel_and(); /* Function to get the broadcast nodes          */
  short          attr;        /* Attribute to select the nodes                */
  int exception_type = NULL;  /* Type of exception if degraded mode           */

  if(p_graph->nb_elmt == 0){status = GM_E_EMPTY_GRAPH;gm$status();}

  p_broad = p_graph->p_broad;
  status  = GMinit_graph(GMH_DEF_MODULO,GMH_DEF_SIZE,GMH_DEF_SIZE,&new_graph);
  gm$status();
  
  /* Redo eventually the root and tip list */

  l_root = (struct GRid *)alloca(p_graph->nb_root*sizeof(struct GRid));
  if(!l_root){status = GM_E_NODYNMEM;gm$status(type = EXCEPTION_1);}

  if(nb_tip)
    {
    l_tip = (struct GRid *)alloca(p_graph->nb_tip*sizeof(struct GRid));
    if(!l_tip){status = GM_E_NODYNMEM;gm$status(type = EXCEPTION_2);}
  }/* if(nb_tip)*/

  status = GMupdate_lists(p_graph,l_greq,&l_root,&nb_root,&l_tip,&nb_tip);
  gm$status(type = EXCEPTION_3);

  /*| get the new graph */

  status = GMget_graph(l_root,nb_root,l_tip,nb_tip,p_graph->f_get_anc,
                       p_graph->p_arg_anc,p_graph->f_get_suc,p_graph->p_arg_suc,
                       TRUE,&new_graph);
  gm$status(type = EXCEPTION_3);

  /*| Update the list of the broadcast objects */

  l_broad = (struct GRid *)alloca(p_graph->nb_elmt*sizeof(struct GRid));
  if(!l_broad){status = GM_E_NODYNMEM;gm$status(type = EXCEPTION_3);}

  attr = GM_BROAD;
  status = GMget_list(p_graph,GMsel_and,&attr,&l_broad,&nb_el_list);
  gm$status(type = EXCEPTION_4);
  GMmodify_state(l_broad,nb_el_list,NULL,NULL,attr,TRUE,&new_graph);

  if(p_broad->broad_mode & GM_TRIGGER)
    {
    /*| Update the trigger attributes */

    attr = GM_OR_STOP;
    l_trigger = NULL;
    status = GMget_list(p_graph,GMsel_and,&attr,&l_trigger,&nb_el_list);
    gm$status(type = EXCEPTION_4);
    GMmodify_state(l_trigger,nb_el_list,NULL,NULL,attr,TRUE,&new_graph);

    attr = GM_AND_STOP;
    l_trigger = NULL;
    status = GMget_list(p_graph,GMsel_and,&attr,&l_trigger,&nb_el_list);
    gm$status(type = EXCEPTION_4);
    GMmodify_state(l_trigger,nb_el_list,NULL,NULL,attr,TRUE,&new_graph);
  }/* if(p_broad->broad_mode)*/

  /*| update the attribute of the elements to rebroadcast */

  if(l_greq->nb_elmt > p_graph->nb_elmt)
    {
    /*" The number of elements to rebroacast is %d\n",l_greq->nb_elmt*/

    /*stackfree(l_broad);*/
    l_broad = (struct GRid *)alloca(l_greq->nb_elmt*sizeof(struct GRid));
    if(!l_broad){status = GM_E_NODYNMEM;gm$status(type = EXCEPTION_3);}
  }/* if(l_greq->nb_elmt)*/

  for(index=0,GMl_first(l_greq); !GMl_at_end(l_greq);GMl_next(l_greq))
    {
    pp_request = (struct GMmodif **) GMl_current(l_greq);
    if((*pp_request)->type & GM_R_TOPOLOG)
      {
      /*" The children of %d,%d must be recomputed\n",(*pp_request)->object.objid,(*pp_request)->object.osnum*/

      l_broad[index]= (*pp_request)->object;
      index++;
    }/* if((*pp_request)->type)*/
  }/* for(index)*/

  /*| Update the object to rebroadcast */

  status = GMinit_graph(NULL,NULL,NULL,&add_graph);
  gm$status(type = EXCEPTION_4);

  if((p_broad->broad_mode) & GM_ORDER)
    {
    status = GMget_graph(l_broad,index,NULL,NULL,p_graph->f_get_anc,
              p_graph->p_arg_anc,p_graph->f_get_suc,p_graph->p_arg_suc,
              FALSE,&add_graph);
    }
  else
    status = GMget_graph(NULL,NULL,l_broad,index,p_graph->f_get_anc,
              p_graph->p_arg_anc,p_graph->f_get_suc,p_graph->p_arg_suc,
              FALSE,&add_graph);
  /* if(p_broad->broad_mode)*/

  gm$status(type = EXCEPTION_5);
  /*stackfree(l_broad);*/

  l_broad = NULL;
  status = GMget_list(&add_graph,p_broad->select_fct,p_broad->p_select_arg,
           &l_broad,&nb_elmt);
  gm$status(type = EXCEPTION_5);

  GMmodify_state(l_broad,nb_elmt,NULL,NULL,GM_BROAD,FALSE,&new_graph);
  GMremove_graph(&add_graph);

  /*| Remove the old graph */

  new_graph.p_grsyst = p_graph->p_grsyst;
  GMremove_graph(p_graph);
  *p_graph           = new_graph;
  p_graph->p_broad   = p_broad;

  /*| remove the root and tip list */

  /*stackfree(l_root);*/

exception:
  switch(exception_type)
    {
    case EXCEPTION_5:
    GMremove_graph(&add_graph);

    case EXCEPTION_4:
    /*stackfree(l_broad);*/

    case EXCEPTION_3:
    /*if(l_tip != NULL)stackfree(l_tip);*/

    case EXCEPTION_2:
    /*stackfree(l_root);*/

    case EXCEPTION_1:
    GMremove_graph(&new_graph);
    break;

  }/* switch */
  return(status);
}/* GMredo_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMupdate_lists                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMupdate_lists(p_graph, l_greq, pl_root, p_nb_root, pl_tip, p_nb_tip)

  struct GMgraph *p_graph;    /* IN     Pointer to the system of graphs       */
  struct GMlist  *l_greq;     /* IN     List of the requests for this graph   */
  struct GRid    **pl_root;   /* OUT    Root list of the new graph            */
  int            *p_nb_root;  /* OUT    Number of roots of this list          */
  struct GRid    **pl_tip;    /* OUT    Root list of the new graph            */
  struct GRid    *p_nb_tip;   /* OUT    Number of tips of this list           */
  /*
  Description : Execute the batch operations
  Constraint  : the lists pl_tip, pl_root must be allocated before
  */ 
  /*.GMupdate_lists */
  {
  struct GMsel_list sel_list; /* To select the new lists in dynamic           */
  int status = GM_S_SUCCESS;  /* Default status of the function               */
  extern int GMsel_connect(); /* Function to select the new lists of the graph*/

  sel_list.l_greq   = l_greq;
  sel_list.int_attr = GM_INIT;

  /*" Retrieve the root list of the graph %d\n",p_graph */

  status = GMget_list(p_graph,GMsel_connect,&sel_list,pl_root,p_nb_root);
  gm$status();

  if(p_graph->nb_tip != 0)
    {
    /*" Retrieve the tip list of the graph %d\n",p_graph */

    sel_list.int_attr = GM_TIP;
    status = GMget_list(p_graph,GMsel_connect,&sel_list,pl_tip,p_nb_tip);
  }/* if(nb_tip)*/

exception:
  return(status);
}/* GMupdate_lists */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    INTERNAL function GMgraph_modified                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMgraph_modified(p_graph)
  /*
  Description : Returns TRUE if the graph is modified and update the state of
                the graph.
  Constraint  : The graph must be connected to the graph system
                 and the list l_grep must be activated. 
  */ 

  struct GMgraph  *p_graph;   /* IN     Pointer to the graphs to analyze      */

  /*.GMgraph_modified*/
  {
  struct GMmodif *p_request;  /* Pointer to a request                         */
  struct GMlist  *l_request;  /* Pointer to the list of requests              */
  IGRushort         graph_level; /* Recursive level of the graph in the system   */
  struct GMsyst  *p_grsyst;   /* Pointer to the linked graph system           */
  IGRushort         ind_elmt;    /* Index of the element in the hcode            */
  struct GMelmt  *p_content;  /* Attribute of this temporary element          */
  int    status = FALSE;      /* Status of the function                       */

  p_grsyst    = (struct GMsyst *)p_graph->p_grsyst;
  l_request   = &p_grsyst->requests;
  graph_level = GMl_count(&p_grsyst->graphs);

  for(GMl_first(l_request); !GMl_at_end(l_request); GMl_next(l_request))
    {
    /*" Test the request %d.%d \n",p_request->object.objid,p_request->object.osnum*/
    p_request = (struct GMmodif *)GMl_current(l_request);
    if((p_request->level >= graph_level)&&
      GMh_give_content(&p_request->object,p_graph->p_hcode,&p_content,&ind_elmt))
      {
      /*" The graph %u is modified\n",p_graph */
      
      status = TRUE;
      break;
    }/* if(p_request->level)*/
  }/* for(GMl_first)*/
  p_graph->p_broad->state &= ~GM_TEST_MODIFY;
  return(status);
}/* GMgraph_modified */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function GMstop_broadcast                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMstop_broadcast(p_grsyst)

  struct GMsyst *p_grsyst;   /* OUT     Pointer to the system of graphs       */
  /*
  Description : Stop the current broadcast of the graph system
  Constraint  : The graph system must be initialized by calling the 
                "GMsyst_activate function"
  Note        : the broadcast graph must be attach to a graph system
  */ 
  /*.GMstop_broadcast */
  {
  int   status;                     /* Status of the function                 */
  struct GMgraph *p_graph;          /* Pointer to the current graph           */
 
  /*| Get the current graph */

  status = GMget_cur_graph(p_grsyst, &p_graph);
  gm$status();

  /*| Notify it to stop */

  p_graph->p_broad->state|= GM_STOP_BROAD;
exception:
  return(status);
}/* GMstop_broadcast */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMget_cur_graph                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_cur_graph(p_grsyst, pp_graph)

  struct GMsyst  *p_grsyst;  /* IN      Pointer to the system of graphs       */
  struct GMgraph **pp_graph; /* OUT     Pointer to the current graph          */
  /*
  Description : Get the current graph connected to the graph system.
  Constraint  : The graph system must be initialized by calling the 
  Note        : the broadcast graph must be attach to a graph system
  */ 
  /*.GMget_cur_graph */
  {
  int status = GM_W_ELMT_NOT_FOUND; /* Status of the function                 */
  struct GMlist *l_graphs;          /* List of the graphs of the system       */
 
  l_graphs  = &p_grsyst->graphs;

  /*| Get the current graph */

  if(GMl_count(l_graphs))
    {
    /*| Get the last stacked graph */

    GMl_last(l_graphs);
    *pp_graph = (*(struct GMgraph **)GMl_current(l_graphs));
    status = GM_S_SUCCESS;
  }/* if*/
  return(status);
}/* GMget_cur_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function GMsel_connect                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsel_connect(p_object, int_attr, p_info)
  /*
  Description : select the internal attribute with "&" operator and which are
                not in the request list for a DELETE or a DISCONNECT operation
  Constraint  : none
  */ 

  struct GRid      *p_object; /* IN     Pointer to the object to select       */
  short            int_attr;  /* IN     Internal attribute                    */
  struct GMsel_list *p_info;  /* IN     User information for the function     */
  /*.GMsel_connect*/
  {
  struct GMmodif **pp_request;/* Pointer to the pointer of a request          */
  extern int     GMsel_and(); /* Function to select the object                */
  char           type;        /* Type of request for this object              */
  int            response;    /* Response of the function                     */
  struct GMlist  *l_greq;     /* List of the requests for this graph          */

  l_greq = p_info->l_greq;
  response = GMsel_and(p_object,int_attr,&p_info->int_attr);
  if(response)
    {
    for(GMl_first(l_greq); !GMl_at_end(l_greq); GMl_next(l_greq))
      {
      pp_request = (struct GMmodif **)GMl_current(l_greq);
      if(!GMgridcmp(p_object,&(*pp_request)->object,NULL))
        {
        type = (*pp_request)->type;
        if((type & GM_REQ_DISCONNECT)||(type & GM_REQ_DELETE))
          {
          response=FALSE;
          break;
        }/* if(type)*/
      }/* if !GMgridcmp*/
    }/* for(GMl_first)*/
  /*"%d.%d : SELECTED = %d\n",p_object->objid,p_object->osnum,response*/
  }/* if(response)*/
  return(response);
}/* GMsel_connect */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function GMsel_nbroad                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsel_nbroad(p_object, int_attr, p_info)
  /*
  Description : select the nodes currently broadcasted except these which are
                already broadcast
  Constraint  : none
  */ 

  struct GRid      *p_object; /* IN     Pointer to the object to select       */
  short            int_attr;  /* IN     Internal attribute                    */
  struct GMbr_info *p_info;   /* IN     User information for the function     */
  /*.GMsel_nbroad*/
  {
  return( (!(int_attr & GM_BROAD))  &&  ((!p_info->select_fct) ||
          p_info->select_fct(p_object,int_attr,p_info->p_select_arg)));
}/* GMsel_nbroad */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
