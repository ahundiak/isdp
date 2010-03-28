#include <sys/types.h>
#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "EXgrid.h"
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "GMmacros.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "igrtypedef.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMinit_graph                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMinit_graph(modulo, nb_elmt, step_size, p_graph)

  int            modulo;      /* IN       Modulo de la selection du hcode     */
  int            nb_elmt;     /* IN       Default number of elements          */
  int            step_size;   /* IN       Increment number of elements        */
  struct GMgraph *p_graph;    /* OUT      Identifier of the resultant graph   */

  /*
  Description : Initializes a graph :
                allocate memory for the the hcode table and initialize its 
                values,
                initialize the current list to NULL,

  Constraint  : modulo    > 1
                nb_elmt   > 1
                step_size > 1
  */ 
  /*.GMinit_graph */
  {
   IGRushort      key_size;      /* Size of the keys of the hcode                */
  int response=GM_E_NODYNMEM; /* Response of the function                     */
  extern int  GMgridcmp();    /* Function to compare the grids                */
  extern int  GMh_grid();     /* Function to hash a grid                      */

  p_graph->p_hcode = (struct GMhcode *)malloc(sizeof(struct GMhcode));
  if(p_graph->p_hcode)
    {
    /*| Build the hcode table */ 

    key_size = sizeof(struct GRid);
    if(GMh_activate(modulo,nb_elmt,step_size,sizeof(struct GMelmt),key_size,
       GMgridcmp,NULL,GMh_grid,p_graph->p_hcode) == GM_S_SUCCESS)
      {
      /*| Initialize the lists */

      p_graph->l_ord_elmt = NULL;
      p_graph->l_parent   = NULL;
      p_graph->p_broad    = NULL;
      p_graph->nb_root    = 0;
      p_graph->nb_tip     = 0;
      p_graph->nb_elmt    = 0;
      p_graph->s_lparent  = 0;
      p_graph->f_get_anc  = NULL;
      p_graph->p_arg_anc  = NULL;
      p_graph->f_get_suc  = NULL;
      p_graph->p_arg_suc  = NULL;
      p_graph->p_grsyst   = NULL;
      response = GM_S_SUCCESS;
    }/* if(GMh_activate)*/
  }/* if(p_graph->p_hcode)*/
  return(response);
}/* GMinit_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMremove_graph                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMremove_graph(p_graph)

  struct GMgraph *p_graph;    /* OUT    Identifier of the resultant graph     */

  /*
  Description : Remove a graph :
                desactivate the hcode table,
                free memory for the hcode table,
                free memory for the sorted list
  */ 
  /*.GMremove_graph */
  {
  GMclear_graph(p_graph);

  /*" Disactivate the hcode table of the graph %d\n",p_graph*/ 

  GMh_disactivate(p_graph->p_hcode);
  
  /*| Free the hcode table */
  
  free(p_graph->p_hcode);

  if(p_graph->l_ord_elmt != NULL)
    {
    /*| Free the sorted list */

    free(p_graph->l_ord_elmt);
    p_graph->l_ord_elmt = NULL;
  }/* if(p_graph->l_ord_elmt)*/

  if(p_graph->l_parent != NULL)
    {
    /*| Free the parent list */

    free(p_graph->l_parent);
    p_graph->l_parent = NULL;
  }/* if(p_graph->l_parent)*/

  return(GM_S_SUCCESS);
}/* GMremove_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMclear_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMclear_graph(p_graph)
                 
  struct GMgraph *p_graph;    /* OUT    Identifier of the resultant graph     */

  /*
  Description : Clear a graph :
                clear the hcode table, free the sorted list, clear the parent
                list, and update the fields of the graph structure.
  */ 
  /*.GMclear_graph */
  {
  /*| Clear the hcode table of the graph*/

  GMh_clear(p_graph->p_hcode);
 
  /*| Update the fields of the graph structure */

  p_graph->nb_root    = 0;
  p_graph->nb_tip     = 0;
  p_graph->p_broad    = NULL;
  p_graph->f_get_anc  = NULL;
  p_graph->p_arg_anc  = NULL;
  p_graph->f_get_suc  = NULL;
  p_graph->p_arg_suc  = NULL;
  return(GM_S_SUCCESS);
}/* GMclear_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMget_graph                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_graph(l_root,nb_root,l_tip,nb_tip,f_get_anc,p_arg_anc,f_get_suc,p_arg_suc,sort,p_graph)

  struct GRid    *l_root;    /* IN     List of the root objects               */
  int            nb_root;    /* IN     Number of root objects                 */
  struct GRid    *l_tip;     /* IN     List of the tip objects                */
  int            nb_tip;     /* IN     Number of tip objects                  */
  int         (*f_get_anc)();/* IN     Function to get the ancestors          */
  char           *p_arg_anc; /* IN     Argument for the function f_get_anc    */
  int         (*f_get_suc)();/* IN     Function to get the successors         */
  char           *p_arg_suc; /* IN     Argument for the function f_get_suc    */
  char           sort;       /* IN     Flag=TRUE for an sorted graph         */
  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */

  /*
  Description : Get the children graph of the root list and father of the tip
                list
  Constraint  : The graph must be initialized by the "GMinit_graph" function
  */ 
  /*.GMget_graph */
  {
  struct GMhcode    *p_hcode; /* Pointer to the hcode table for the graph     */
  int               status;   /* Status returned by functions                 */
  int               ind0;     /* Index for a loop                             */
  IGRushort            size_lord;/* Size of the sorted list                      */

  /* Clean the duplicate objects in the lists */

  GMcompress_list(l_root, &nb_root);
  GMcompress_list(l_tip, &nb_tip);

  GMclear_graph(p_graph);

  p_hcode = p_graph->p_hcode;
  size_lord = p_hcode->nb_max_elmt;
  p_graph->f_get_anc = f_get_anc;
  p_graph->p_arg_anc = p_arg_anc;
  p_graph->f_get_suc = f_get_suc;
  p_graph->p_arg_suc = p_arg_suc;
  p_graph->nb_root   = nb_root;
  p_graph->nb_tip    = nb_tip;

  /*----------------- */
  /*| Catch the graph */
  /*----------------- */

  if(f_get_anc == NULL)
    {
    status = GMcatch_suc(l_root,nb_root,l_tip,nb_tip,p_graph);
    }
  else
    {
  if(f_get_suc != NULL)
    {
    status = GMcatch_down(l_root,nb_root,l_tip,nb_tip,p_graph);
    }
  else
    {
    status = GMcatch_up(l_root,nb_root,l_tip,nb_tip,p_graph);
    }
  }/* if(f_get_suc)*/
  gm$status();

  /*| Set the GM_ROOT flag */

  status = GMroot_flag(p_graph);
  gm$status();
 
  if(nb_tip > 0)
    {
    /*| Find the minimal graph  */

    status = GMmin_flag(l_tip,nb_tip,p_graph);
    gm$status();
  }/* if(nb_tip) */
  
  /*------------------------*/  
  /*| Fill the sorted list */
  /*------------------------*/ 
  
  /*" there are %d elements in the graph\n",p_hcode->cur_elmt*/
  
  if((p_graph->l_ord_elmt)&&(size_lord < p_hcode->nb_max_elmt))
    free(p_graph->l_ord_elmt);
 
  if((size_lord < p_hcode->nb_max_elmt)||!(p_graph->l_ord_elmt))
    {
    p_graph->l_ord_elmt=(IGRushort *)malloc((p_hcode->nb_max_elmt)*sizeof(IGRushort));
    if(!p_graph->l_ord_elmt){status=GM_E_NODYNMEM;gm$status();}
  }/* if(size_lord)*/

  if(sort)
    {
    status = GMordinate(p_graph);
    gm$status();
    }
  else
    {
    for(ind0 = 0; ind0 < (int)p_hcode->cur_elmt;ind0++)
      {
      p_graph->l_ord_elmt[ind0]=ind0;
    }/* for(ind0)*/
  }/* if(sort)*/

  p_graph->nb_elmt = p_hcode->cur_elmt;

exception:
  return(status);
}/* GMget_graph */
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          Function GMinternal_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMinternal_graph(l_obj, nb_obj, f_get_anc, p_arg_anc, f_get_suc, p_arg_suc, p_graph)

  struct GRid    *l_obj;      /* IN     List of objects to get the set        */
  int            nb_obj;      /* IN     Number of objects in this list        */
  int         (*f_get_anc)(); /* IN     Function to get the ancestors         */
  char           *p_arg_anc;  /* IN     Argument for the function f_get_anc   */
  int         (*f_get_suc)(); /* IN     Function to get the successors        */
  char           *p_arg_suc;  /* IN     Argument for the function f_get_suc   */
  struct GMgraph *p_graph;    /* IN/OUT Returned graph                        */
  /*
  Description: For a list of elements returns the subgraph with internal
               elements information.
  Constraints: The graph returned must be initialzed before (calling
               gm$init_graph).
  */
  /*.GMinternal_graph*/
  {
  long           status;      /* Status returned by the functions             */
  struct GMgraph tmp_graph;   /* Temporary graph                              */
  IGRushort         ind0;        /* Index for a loop                             */
  IGRushort         ind1;        /* Index of the element in the graph            */
  IGRushort         ind2;        /* Index for a loop                             */
  IGRushort         ind3;        /* Index of the element in the graph            */
  IGRushort         ind4;        /* Index for a loop                             */
  struct GMhcode *p_hcode;    /* Pointer to the hcode structure               */
  struct GRid    *l_parent;   /* List of parents of an object                 */
  int            nb_parent;   /* Number of parents for an object              */
  struct GRid    *p_object;   /* Object to test                               */
  struct GRid    *p_cmp_obj;  /* Temporary object to compare                  */
  char           correct;     /* Flag = TRUE if belongs to the graph          */
  int exception_type = NULL;  /* Type of exception if degraded mode           */
  extern int GMget_anc_ingr();/* Function to get the ancestors                */

  /*| Search reverse graph */

  status = gm$init_graph( p_graph = &tmp_graph);
  gm$status();
  status = gm$get_graph
             (ancestor_fct = f_get_anc, p_anc_arg = p_arg_anc,
              l_tip        = l_obj,     nb_tip    = nb_obj,
              p_graph      = &tmp_graph);
  gm$status();

  /*| Search direct graph */

  status = gm$get_graph
             (ancestor_fct  = GMget_anc_ingr, p_anc_arg  = (char *)&tmp_graph,
              successor_fct = f_get_suc,      p_suc_arg  = p_arg_suc,
              l_initial     = l_obj,          nb_initial = nb_obj,
              p_graph       = p_graph);
  gm$status();

  p_hcode  = p_graph->p_hcode;
  for(ind0=0; ind0<p_graph->nb_elmt;) 
    {
    ind1 = p_graph->l_ord_elmt[ind0];
    if(GMh_give_content(GMh_key(p_hcode,ind1),tmp_graph.p_hcode,NULL,NULL))
      {
      /* This element is MINIMAL */

      ((struct GMelmt *)GMh_content(p_hcode,ind1))->int_attr |= GM_MINIMAL;
      ind0++;
      }
    else
      {
      /* Remove this element from the graph */

      GMh_remove(GMh_key(p_hcode,ind1),p_hcode);
      (p_graph->nb_elmt)--;
      for(ind1=ind0; ind1<p_graph->nb_elmt;ind1++)
        p_graph->l_ord_elmt[ind1]= p_graph->l_ord_elmt[ind1+1];
    }/* if */
  }/* for */

  /* Remove wrong extern objects */

  for(ind0=0; ind0<p_graph->nb_elmt;) 
    {
    ind1 = p_graph->l_ord_elmt[ind0];
    p_object = (struct GRid *)GMh_key(p_hcode,ind1);

    /*" Test if %d.%d is correct\n",p_object->objid,p_object->osnum*/

    correct = TRUE;
    if(!(((struct GMelmt *)GMh_content(p_hcode,ind1))->int_attr & GM_INIT))
      {
      for(ind2=0;(ind2<p_graph->nb_elmt); ind2++) 
        {
        correct=FALSE;
        ind3 = p_graph->l_ord_elmt[ind2];
        p_cmp_obj = (struct GRid *)GMh_key(p_hcode,ind3);
        l_parent = NULL;

        status = GMget_anc_ingr(p_cmp_obj, p_graph, &l_parent, &nb_parent);
        gm$status(type = EXCEPTION_1);

        for(ind4=0; (int)ind4 < nb_parent; ind4++) 
          {
          if(!GMgridcmp(p_object,&l_parent[ind4],NULL)
            &&(((struct GMelmt *)GMh_content(p_hcode,ind3))->int_attr & GM_BODY))
            {
            correct = TRUE;
            break;
          }
        }/* for(ind4)*/
      if(correct) break;
      }/* for */
    }/* if! */

    if(!correct) 
      {
      /* Remove this element from the graph */

      GMh_remove(p_object,p_hcode);
      (p_graph->nb_elmt)--;
      for(ind1=ind0; ind1<p_graph->nb_elmt;ind1++)
        p_graph->l_ord_elmt[ind1]= p_graph->l_ord_elmt[ind1+1];
      }
    else ind0++;
  }/* for(ind0)*/
 
  gm$free_graph(p_graph = &tmp_graph);

exception:
  if(exception_type == EXCEPTION_1) gm$free_graph(p_graph = &tmp_graph);
  return (status);
}/* GMinternal_graph*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMbroadcast_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMbroadcast_graph(sel_fct, p_sel_arg, broad_fct, p_broad_arg, broad_mode,
                  p_graph, p_grsyst, l_status)
  /*
  Description : Broadcast a message whith mode in the list of the graph
  */ 
  int         (*sel_fct)();   /* IN     Function to select the objects        */
  char        *p_sel_arg;     /* IN     Arguments of select function          */
  int         (*broad_fct)(); /* IN     Function to broadcast                 */
  char        *p_broad_arg;   /* IN     Arguments of the broadcast function   */
  char        broad_mode;     /* IN     Broadcast mode                        */
  struct GMgraph *p_graph;    /* OUT    Pointer to the graph to broadcast     */
  struct GMsyst  *p_grsyst;   /* OUT    Pointer to the graph system (optional)*/
  int            *l_status;   /* OUT    List of the status of the sick nodes  */

  /*.GMbroadcast_graph */
  {
  struct GMhcode    *p_hcode;  /* Pointer to the hcode table for the graph    */
  int               index0;    /* Index for a loop                            */
  IGRushort            index1;    /* Index for a loop                            */
  struct GMelmt     *p_content;/* Content of a temporary graph element        */
  struct GRid       *p_object; /* GRid of a temporary graph element           */
  struct GMbr_info  c_broad;   /* Current broadcast information               */
  struct GMbr_info  *p_obroad; /* Previous broadcast information              */
  int    status = GM_S_SUCCESS;/* Status of the function                      */
  extern int    GMloop_cmp();  /* Function to compare the loops               */
  char   sick_status = FALSE;  /* Status to know if a node is sick or not     */
  int           nb_status=0;   /* Number of status in the status list         */

  status = GMattach_to_grsyst(p_graph, p_grsyst);
  gm$status();

  p_obroad             = p_graph->p_broad;
  p_graph->p_broad     = &c_broad;
  c_broad.select_fct   = sel_fct;
  c_broad.p_select_arg = p_sel_arg;
  c_broad.broad_fct    = broad_fct;
  c_broad.broad_mode   = broad_mode;
  c_broad.p_broad_arg  = p_broad_arg;
  c_broad.state        = GM_CONTINUE;
 
  p_hcode = p_graph->p_hcode;
  if(broad_mode & GM_ORDER)
    {
    /*| Broadcast the message in ORDER to the list */

    for(index0=0;(index0<(int)p_graph->nb_elmt)&&(c_broad.state==GM_CONTINUE);index0++) 
      {
      /*| Find the element */

      index1 = p_graph->l_ord_elmt[index0];
      p_content = (struct GMelmt *)GMh_content(p_hcode,index1);
      p_object  = (struct GRid *)GMh_key(p_hcode,index1);

      if((!sel_fct) || sel_fct(p_object,p_content->int_attr,p_sel_arg))
        {
        if(broad_mode & GM_TRIGGER)
          {
          status = GMtrigger(p_object,p_content,broad_fct,p_broad_arg,p_graph,l_status,&nb_status);
          if(nb_status) sick_status = TRUE;
          }
        else
          {
          status = broad_fct(p_object,p_broad_arg);
          p_content->int_attr |= GM_BROAD;
          if(!(status&1)) sick_status = TRUE;
        }/* if(broad_mode)*/

        if((c_broad.state != GM_CONTINUE)&&(!(c_broad.state & GM_ABORT_BROAD)))
          {
          if(c_broad.state & GM_TEST_MODIFY)
            {
            /*| Test if the graph has been modified*/

            if(GMgraph_modified(p_graph))
              c_broad.state |= GM_MODIFY;
          }/* if(c_broad.state)*/

          if(c_broad.state & GM_MODIFY)
            {
            /*" The graph %d is dynamically modified\n",p_graph */

            status = GMredo_broadcast(p_graph);
            gm$status();
          }/* if(c_broad.state)*/
        }/* if(c_broad.state)*/
      }/* if (!sel_fct)*/
    }/* for(index0)*/
    }
  else
    {
    /*| Broadcast the message in REVERSE to the list */

    for(index0 = p_graph->nb_elmt-1;(index0 >=0)&&(c_broad.state == GM_CONTINUE);index0--) 
      {
      index1    = p_graph->l_ord_elmt[index0];
      p_content = (struct GMelmt *)GMh_content(p_hcode,index1);
      p_object  = (struct GRid *)GMh_key(p_hcode,index1);

      if((!sel_fct) || sel_fct(p_object,p_content->int_attr,p_sel_arg))
        {
        status = broad_fct(p_object,p_broad_arg);
        p_content->int_attr |= GM_BROAD;
        if(!(status&1)) sick_status = TRUE;

        if((c_broad.state != GM_CONTINUE)&&(!(c_broad.state & GM_ABORT_BROAD)))
          {
          if(c_broad.state & GM_TEST_MODIFY)
            {
            /*| Test if the reverse graph has been modified*/

            if(GMgraph_modified(p_graph))
              c_broad.state |= GM_MODIFY;
          }/* if(c_broad.state)*/

          if(c_broad.state & GM_MODIFY)
            {
            /*" The graph %d is dynamically modified\n",p_graph */

            status = GMredo_broadcast(p_graph);
            gm$status();
          }/* if(c_broad.state)*/
        }/* if(c_broad.state)*/
      }/* if (!sel_fct)*/
    }/* for(index0)*/
  }/* if(broad_mode) */

  if(c_broad.state == GM_CONTINUE)
    {
    GMmodify_state(NULL,NULL,NULL,NULL,GM_BR_INFO,FALSE,p_graph);
    }
  else if(c_broad.state == GM_STOP_BROAD)
    {
    status = GM_E_STOP_PROCESS;
  }/* if(c_broad.state) */
 
  p_graph->p_broad = p_obroad;
  status = GMdetach_fr_grsyst(p_graph);

exception:

  if(sick_status) status = GM_W_SICK_OBJ;
  return(status);
}/* GMbroadcast_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMduplicate_graph                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMduplicate_graph(p_graph, p_dup_graph)
  /*
  Description : duplicate a graph in an other
  */ 
                 
  struct GMgraph *p_graph;    /* IN     Graph to duplicate                    */
  struct GMgraph *p_dup_graph;/* OUT    Copy of this graph                    */

  /*.GMduplicate_graph */
  {
  int            status;       /* Status of the function                      */
  int exception_type = NULL;   /* Type of exception if degraded mode          */

  /*| Duplicate the fields of the graph */

  *p_dup_graph           = *p_graph;
  p_dup_graph->p_broad   = NULL;

  /*| Copy the hcode table */ 

  p_dup_graph->p_hcode = (struct GMhcode *)malloc(sizeof(struct GMhcode));
  if(!p_dup_graph->p_hcode){status=GM_E_NODYNMEM;gm$status();}

  status = GMh_duplicate(p_graph->p_hcode,p_dup_graph->p_hcode);
  gm$status(type = EXCEPTION_1);

  /*| Copy the sorted list */

  p_dup_graph->l_ord_elmt = (IGRushort *)malloc(p_graph->nb_elmt*sizeof(IGRushort));
  if(!p_dup_graph->l_ord_elmt){status=GM_E_NODYNMEM;gm$status(type=EXCEPTION_1);}
  memcpy(p_dup_graph->l_ord_elmt,p_graph->l_ord_elmt,p_graph->nb_elmt*sizeof(IGRushort));

  /*| Copy the parents list */

  p_dup_graph->l_parent = (IGRushort *)malloc(p_graph->s_lparent*sizeof(IGRushort));
  if(!p_dup_graph->l_parent){status=GM_E_NODYNMEM;gm$status(type=EXCEPTION_2);}
  memcpy(p_dup_graph->l_parent,p_graph->l_parent,p_graph->nb_elmt*sizeof(IGRushort));

exception:
  switch(exception_type)
    {
    case EXCEPTION_2:
    free(p_dup_graph->l_ord_elmt);

    case EXCEPTION_1:
    free(p_dup_graph->p_hcode);
  }/* switch */
  return(GM_S_SUCCESS);
}/* GMduplicate_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMdep_exist                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMdep_exist(l_root, nb_root, l_tip, nb_tip, f_get_anc, p_arg_anc)

  struct GRid *l_root;       /* IN     List of the root objects               */
  int         nb_root;       /* IN     Number of root objects                 */
  struct GRid *l_tip;        /* IN     List of the tip objects                */
  int         nb_tip;        /* IN     Number of tip objects                  */
  int         (*f_get_anc)();/* IN     Function to get the ancestors          */
  char        *p_arg_anc;    /* IN     Argument for the function f_get_anc    */
  /*
  Description : Return TRUE if one of the element of the tip list is a
                successor of one element of the root list
  */ 
  /*.GMdep_exist*/
  {
  int             index0;    /* Index for a loop                              */
  int             index1;    /* Index for a loop                              */
  int             status;    /* Status returned by the function f_get_anc     */
  int             response;  /* Response of the function                      */
  struct GMhcode   hcode;    /* Pointer to the hcode table for the graph      */
  struct GRid  *p_key_elmt;  /* Key of a temporary element                    */
  short           *p_attr;   /* Attribute of this temporary element           */
  short           attr_elmt; /* Attribute of this temporary element           */
  IGRushort          ind_elmt;  /* Number of elements in the graph               */
  int             nb_temp;   /* Number of element in the list l_temp          */
  struct GRid     *l_temp;   /* List of temporary nodes                       */
  IGRushort          key_size;  /* Size of the keys of the hcode                 */
  extern int     GMgridcmp();/* Function to compare the keys                  */
  extern int     GMh_grid(); /* Function to hash a grid                       */
  int exception_type = NULL; /* Type of exception if degraded mode            */

  key_size = sizeof(struct GRid);
  if((nb_tip <= 0)||(nb_root <= 0)){status = GM_I_NEG_RESPONSE;gm$status();}
  if(GMh_activate(GMH_DEF_MODULO,GMH_DEF_SIZE,GMH_DEF_SIZE,sizeof(IGRushort),
    key_size,GMgridcmp,NULL,GMh_grid,&hcode) == GM_S_SUCCESS)
    {
    response = GM_I_NEG_RESPONSE;

    /*| ---------------------- */  
    /*| Load the root elements */
    /*| ---------------------- */ 
  
    for(index0=0; index0 < nb_root; index0++)
      {
      /*" Load the root element %d.%d in the graph\n",l_root[index0].objid,l_root[index0].osnum */
    
      attr_elmt = GM_ROOT;
      if(IF_NULL_OBJID(l_root[index0].objid)) continue;
      status = GMh_add(&l_root[index0],&attr_elmt,&hcode);
      gm$status(type = EXCEPTION_1);
    }/* for(index0)*/
    
    /*| --------------------- */  
    /*| Load the tip elements */
    /*| --------------------- */  

    for(index0=0; index0 < nb_tip; index0++)
      {
      if(IF_NULL_OBJID(l_tip[index0].objid)) continue;
      if(!GMh_give_content(&l_tip[index0],&hcode,&p_attr,&ind_elmt))
        {
        /*" Add the tip %d.%d in the graph\n",l_tip[index0].objid,l_tip[index0].osnum */
        
        attr_elmt = GM_TIP;
        status = GMh_add(&l_tip[index0],&attr_elmt,&hcode);
        gm$status(type = EXCEPTION_1);
        }
      else
        {
        if((*p_attr) & GM_ROOT)
          {
          response = GM_S_SUCCESS;
          break;
        }/* if(*p_attr)*/
      }/* if(!GMh_give_content)*/
    }/* for(index0)*/

    /*| ---------------- */  
    /*| Expand the graph */
    /*| ---------------- */  

    for(index0=nb_root; (response!=GM_S_SUCCESS)&&(index0<(int)hcode.cur_elmt); index0++)
      {
      p_key_elmt = (struct GRid *)GMh_key(&hcode,index0);

      /*" Try to expand the element %d.%d\n",p_key_elmt->objid,p_key_elmt->osnum */

      status = f_get_anc(p_key_elmt,p_arg_anc,&l_temp,&nb_temp);
      if(!(status&1)) nb_temp =0;

      for(index1=0; index1 < nb_temp; index1++)
        {
        if(!GMh_give_content(&l_temp[index1],&hcode,&p_attr,&ind_elmt))
          {   
          /*" Add the ancestor %d.%d in the graph\n",l_temp[index1].objid,l_temp[index1].osnum*/

          attr_elmt = GM_BODY;
          status = GMh_add(&l_temp[index1],&attr_elmt,&hcode);
          gm$status(type = EXCEPTION_1);
          }
        else
          {
          if((*p_attr) & GM_ROOT)
            {
            /*" %d.%d is an ancestor of the tip list\n",l_temp[index1].objid,l_temp[index1].osnum */

            response = GM_S_SUCCESS;
            break;
          }/* if(*p_attr)*/
        }/* if(!GMh_give_content)*/
      }/* for(index1)*/
    }/* for(index0)*/

    /*| Disactivate the list */
      
    GMh_disactivate(&hcode);
    status = response;
    }
  else
    {
    status=GM_E_NODYNMEM;
  }/* if(GMh_activate)*/

exception:
  if(exception_type == EXCEPTION_1) GMh_disactivate(&hcode);

  return(status);
}/* GMdep_exist */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMget_type                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_type(l_object, nb_object, p_graph, l_attr)

  struct GRid    *l_object;   /* IN     List of the objects of the graph      */
  int            nb_object;   /* IN     Number of objects in the list         */
  struct GMgraph *p_graph;    /* IN     Identifier of the resultant graph     */
  int            *l_attr;     /* OUT    List of the attributes of the object  */

  /*
  Description : Get the attributes of the objects in l_object
  */ 
  /*.GMget_type */
  {
  int            index;      /* Index for a loop                              */
  struct GMelmt  *p_content; /* Content of the element                        */
  IGRushort         ind_elmt;   /* Number of elements in the graph               */
  int response =GM_S_SUCCESS;/* Response of the function                      */
  struct GMhcode *p_hcode;   /* Pointer to the hcode table for the graph      */
  
  p_hcode = p_graph->p_hcode;
   
  for(index=0; index < nb_object; index++)
    {
    /*" Get the attribute of %d.%d\n",l_object[index].objid,l_object[index].osnum */

    if(GMh_give_content(&l_object[index],p_hcode,&p_content,&ind_elmt))
      {
      l_attr[index] = p_content->int_attr;
      }
    else
      {
      /*" The object %d.%d is not in the current graph\n",l_object[index].objid,l_object[index].osnum*/
  
      l_attr[index] = GM_NULL_ATTR;
      response = FALSE;
     }/* if(GMh_give_content)*/
  }/* for(index)*/
  return(response);
}/* GMget_type */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       function GMlist_access_init                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMlist_access_init(p_graph, p_desc)
  /*
  Description : Initialize the access to the list of objects
  Constraints : p_desc can have only 2 values: GM_FROM_BEGIN, GM_FROM_END.
  */ 

  struct GMgraph *p_graph;    /* IN     Identifier of the resultant graph     */
  int            *p_desc;     /* IN     Indication of the start index         */
  {
  int status = GM_S_SUCCESS;  /* Status returned by functions                 */

  if(*p_desc == GM_FROM_BEGIN)
    *p_desc = -1;
  else if(*p_desc == GM_FROM_END)
    *p_desc = p_graph->nb_elmt;
  else
    {
    /*| Bad argument */

    *p_desc = -1;
    status = GM_F_BAD_FUNCT_ARG;
  }/* if(*p_desc)*/ 
  return(status); 
}/* GMlist_access_init*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function GMaccess_element                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMaccess_element(p_graph, select_fctu, p_sel_argu, p_desc, forward, p_object)

  struct GMgraph *p_graph;    /* IN     Identifier of the resultant graph     */
  int        (*select_fctu)();/* IN     User function to select the node      */
  char           *p_sel_argu; /* IN     Arguments of the previous function    */
  int            *p_desc;     /* IN     Indication of the start index         */
  char           forward;     /* IN     FLAG=TRUE if forward research         */
  struct GRid    *p_object;   /* OUT    Returned object                       */

  /*
  Description : If the flag forward = TRUE returns the next object of the
                ordinate list
                If the flag forward=FALSE then returns the previous object of
                the ordinate list of the graph verifying the select_fctu
                criteria.
                If the asked object doesn't exist, returns the status 
                GM_I_NEG_RESPONSE
  Constraints : p_desc must be initialized before calling GMlist_acces_init
  */ 
  /*.GMaccess_element*/
  {
  int               index0;    /* Index for a loop                            */
  IGRushort            index1;    /* Index for an indirection                    */
  int               index_obj; /* Index of the returned object                */
  struct GMelmt     *p_content;/* Content of a temporary graph element        */
  struct GRid       *p_gr_obj; /* Pointer to a temporary graph object         */
  struct GMhcode    *p_hcode;  /* Pointer to the hcode table for the graph    */
  int  status = GM_S_SUCCESS;  /* Return code of a function                   */

  p_hcode = p_graph->p_hcode;

  if(forward)
    {
    /*| Forward search */

    for(index0=*p_desc+1,index_obj=*p_desc;index0 < (int)p_graph->nb_elmt;index0++) 
      {
      index1    = p_graph->l_ord_elmt[index0];
      p_content = (struct GMelmt *)GMh_content(p_hcode,index1);
      p_gr_obj  = (struct GRid *)GMh_key(p_hcode,index1);

      if((!select_fctu) || select_fctu(p_object,p_content->int_attr,p_sel_argu))
        {
        /*" The object %d.%d is selected\n",p_gr_obj->objid,p_gr_obj->osnum*/
 
        *p_object = *p_gr_obj;
        index_obj = index0;
        break;
      }/* if(!select_fctu) */
    }/* for(index0)*/
    }
  else
    {
    /*| Backward search */

    for(index0=*p_desc-1,index_obj=*p_desc;index0 >= 0;index0--) 
      {
      index1    = p_graph->l_ord_elmt[index0];
      p_content = (struct GMelmt *)GMh_content(p_hcode,index1);
      p_gr_obj  = (struct GRid *)GMh_key(p_hcode,index1);
 
      if((!select_fctu) || select_fctu(p_object,p_content->int_attr,p_sel_argu))
        {
        /*" The object %d.%d is selected\n",p_gr_obj->objid,p_gr_obj->osnum*/
 
        *p_object = *p_gr_obj;
        index_obj = index0;
        break;
      }/* if(!select_fctu) */
    }/* for(index0)*/
  }/* if(forward)*/

  if(index_obj == *p_desc)
    status = GM_I_NEG_RESPONSE;
  else
    *p_desc = index0;
 
  return(status);
}/* GMaccess_element*/
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
