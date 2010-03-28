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
/*                        INTERNAL function GMcatch_suc                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMcatch_suc(l_root, nb_root, l_tip, nb_tip, p_graph)

  struct GRid    *l_root;    /* IN     List of the root objects               */
  int            nb_root;    /* IN     Number of root objects                 */
  struct GRid    *l_tip;     /* IN     List of the tip objects                */
  int            nb_tip;     /* IN     Number of tip objects                  */
  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */
  /*
  Description : Catch a graph from the root list to the tip list
  Constraint  : none
  */ 
  /*.GMcatch_suc */
  {
  struct GMhcode     *p_hcode;/* Pointer to the hcode table for the graph     */
  struct GManc_pair  obj_anc; /* Pair of index ( object <---> ancestor )      */
  int              s_obj_anc; /* Size of this structure                       */
  struct GMlist    l_suc;     /* List of the pairs of index                   */
  struct GMelmt    *p_content;/* Content of a temporary graph element         */
  IGRushort           index0;    /* Index for a loop                             */
  int              nb_temp;   /* Number of element in the ancestor list       */
  int              ind_parent;/* index of the parents in the list l_parent    */
  extern int       GMmemcmp();/* Function to compare the grids                */
  int              status;    /* Status returned by functions                 */
  int exception_type = NULL;  /* Type of exception if degraded mode           */
  int              nb_parent; /* Number of parents in the list                */

  if(nb_root == 0) {status = GM_F_BAD_FUNCT_ARG;gm$status();}

  /*| Activate the list of successors */

  p_hcode = p_graph->p_hcode;
  s_obj_anc = sizeof(obj_anc);
  status = GMl_activate(GMH_DEF_SIZE,GMH_DEF_SIZE,sizeof(obj_anc),
           GMmemcmp,&s_obj_anc,sizeof(s_obj_anc),&l_suc);
  gm$status();

  /*-------------------------- */ 
  /*| Fill the successor graph */
  /*-------------------------- */ 

  status = GMget_suc_gr(l_root,nb_root,l_tip,nb_tip,p_graph,&l_suc);
  gm$status(type = EXCEPTION_1);

  /*----------------------- */ 
  /*| Fill the parents list */
  /*----------------------- */ 
 
  /*" The graph has %d elements\n", p_graph->nb_elmt*/

  ind_parent = 0;
  if(nb_parent = GMl_count(&l_suc))
    {
    if((p_graph->l_parent)&&(p_graph->s_lparent < nb_parent))
      free(p_graph->l_parent);
 
    if((p_graph->s_lparent < nb_parent)||!(p_graph->l_parent))
      {
      p_graph->l_parent = (IGRushort *)malloc(nb_parent*sizeof(IGRushort));
      if(!p_graph->l_parent){status=GM_E_NODYNMEM;gm$status(type = EXCEPTION_1);}
      p_graph->s_lparent = nb_parent;
    }/* if(size_lord)*/

    for(index0=0; index0 < p_graph->nb_elmt; index0++)
      {
      p_content = (struct GMelmt *)GMh_content(p_hcode,index0);

      if(p_content->int_attr & GM_BODY)
        {
        /*" Fill %d.%d parent's field\n",((struct GRid *)GMh_key(p_hcode,index0))->objid,((struct GRid *)GMh_key(p_hcode,index0))->osnum*/

        p_content->ind_parent = (IGRushort) ind_parent;
        for(GMl_first(&l_suc),nb_temp=0;!GMl_at_end(&l_suc);GMl_next(&l_suc))
          {
          if(((struct GManc_pair *)GMl_current(&l_suc))->key_index == index0)
            {
            p_graph->l_parent[ind_parent]=((struct GManc_pair *)GMl_current(&l_suc))->anc_index;
        /*" -->%d.%d\n",((struct GRid *)GMh_key(p_hcode,p_graph->l_parent[ind_parent]))->objid,((struct GRid *)GMh_key(p_hcode,p_graph->l_parent[ind_parent]))->osnum*/
            ind_parent++;nb_temp++; 
          }/* if(struct GManc_pair)*/
          p_content->nb_parent  = (IGRushort) nb_temp;
        }/* for(GMl_first)*/
      }/* if(p_content)*/
    }/* for(index0) */
  }/* if(!GMl_count)*/
  GMl_disactivate(&l_suc);

exception:
  if(exception_type == EXCEPTION_1) GMl_disactivate(&l_suc);

  return(status);
}/* GMcatch_suc */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMcatch_down                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMcatch_down(l_root, nb_root, l_tip, nb_tip, p_graph)

  struct GRid    *l_root;    /* IN     List of the root objects               */
  int            nb_root;    /* IN     Number of root objects                 */
  struct GRid    *l_tip;     /* IN     List of the tip objects                */
  int            nb_tip;     /* IN     Number of tip objects                  */
  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */
  /*
  Description : Catch a graph from the root list to the tip list
  Constraint  : none
  */ 
  /*.GMcatch_down */
  {
  struct GMhcode   *p_hcode;  /* Pointer to the hcode table for the graph     */
  struct GMelmt    content;   /* Content of a temporary graph element         */
  struct GMelmt    *p_content;/* Content of a temporary graph element         */
  struct GRid      *p_object; /* GRid of a temporary graph element            */
  IGRushort           index0;    /* Index for a loop                             */
  IGRushort           index1;    /* Index for a loop                             */
  IGRushort           index_elmt;/* Number of elements in the graph              */
  int              nb_temp;   /* Number of element in the list l_temp         */
  struct GRid      *l_temp;   /* List of temporary nodes                      */
  int    status =  FALSE;     /* Status returned by functions                 */
  int              ind_parent;/* index of the parents in the list l_parent    */
  int              new_size;  /* New size of the array l_parent               */
   
  if(nb_root == 0) {status = GM_F_BAD_FUNCT_ARG;gm$status();}
  p_hcode = p_graph->p_hcode;

  /*-------------------------- */ 
  /*| Fill the successor graph */
  /*-------------------------- */ 

  status = GMget_suc_gr(l_root,nb_root,l_tip,nb_tip,p_graph,NULL);
  gm$status();

  /*----------------------- */  
  /*| Fill the parents list */
  /*----------------------- */ 
 
  /*" The graph has %d elements\n", p_graph->nb_elmt*/

  ind_parent = 0;
 
  if(!(p_graph->l_parent))
    {
    p_graph->s_lparent = (p_graph->nb_elmt+1)*AV_NB_PAR; 

    /*" The size of l_parent = %d\n", p_graph->s_lparent */

    p_graph->l_parent = (IGRushort *)malloc(p_graph->s_lparent*sizeof(IGRushort));
    if(!p_graph->l_parent){status=GM_E_NODYNMEM;gm$status();}
  }/* if*/

  for(index0=0; index0 < p_graph->nb_elmt; index0++)
    {
    p_object  = (struct GRid *)GMh_key(p_hcode,index0);
    p_content = (struct GMelmt *)GMh_content(p_hcode,index0);

    if(p_content->int_attr & GM_BODY)
      {
      /*" Fill the field parents of %d.%d\n",p_object->objid,p_object->osnum */

      l_temp = NULL;
      status = p_graph->f_get_anc(p_object,p_graph->p_arg_anc,&l_temp,&nb_temp);
      if(!(status&1)){ nb_temp =0; status = GM_I_NEG_RESPONSE;}

      p_content->nb_parent  = (IGRushort) nb_temp;
      p_content->ind_parent = (IGRushort) ind_parent;

      /* add eventually a root parent */
      
      for(index1=0; (int)index1 < nb_temp; index1++)
        {
        if(ind_parent == p_graph->s_lparent)
          {
          /*| Reallocate memory for the parents */
          
          new_size = (p_graph->s_lparent)*FACTOR;
          p_graph->l_parent = (IGRushort *)realloc(p_graph->l_parent,new_size*sizeof(IGRushort)); 
          if(!p_graph->l_parent){status=GM_E_NODYNMEM;gm$status();}
          p_graph->s_lparent = new_size;
        }/* if(ind_parent)*/

        if(!GMh_give_content(&l_temp[index1],p_hcode,&p_content,&index_elmt))
          {   
          /*" Add the Extern node %d.%d in the graph\n",l_temp[index1].objid,l_temp[index1].osnum*/
          
          content.int_attr  = GM_EXTERN;
          content.state     = GM_MIN_LEVEL;
          content.ind_parent= GM_UNKNOWN;
          content.nb_parent = 0;
          p_graph->l_parent[ind_parent]= p_hcode->cur_elmt;
          status = GMh_add(&l_temp[index1],&content,p_hcode);
          gm$status();
          }
        else
          {
          p_graph->l_parent[ind_parent]= index_elmt; 
        }/* if(!GMh_give_content)*/
        ind_parent = ind_parent+1; 
      }/* for(index1)*/
    }/* if(p_content)*/
  }/* for(index0) */

exception:
  return(status);
}/* GMcatch_down */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMcatch_up                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMcatch_up(l_root, nb_root, l_tip, nb_tip, p_graph)

  struct GRid    *l_root;    /* IN     List of the root objects               */
  int            nb_root;    /* IN     Number of root objects                 */
  struct GRid    *l_tip;     /* IN     List of the tip objects                */
  int            nb_tip;     /* IN     Number of tip objects                  */
  struct GMgraph *p_graph;   /* IN/OUT Identifier of the resultant graph      */

  /*
  Description : Catch a graph from the tip list to the root elements
  Constraint  : none
  */ 
  /*.GMcatch_up */
  {
  struct GMhcode   *p_hcode;    /* Pointer to the hcode table of the graph    */
  struct GMelmt    content;     /* Content of a temporary graph element       */
  struct GMelmt    *p_content;  /* Content of a temporary graph element       */
  struct GRid      *p_object;   /* GRid of a temporary graph element          */
  IGRushort           index0;      /* Index for a loop                           */
  IGRushort           index1;      /* Index for a loop                           */
  IGRushort           index_elmt;  /* Number of elements in the graph            */
  int              nb_temp;     /* Number of element in the list l_temp       */
  struct GRid      *l_temp;     /* List of temporary nodes                    */
  int              ind_parent;  /* index of the parents in the list l_parent  */
  int              new_size;    /* New size of the array l_parent             */
  int status=GM_F_BAD_FUNCT_ARG;/* Status returned by fct                     */
   
  if(!nb_tip) return status;
  p_hcode = p_graph->p_hcode;

  /*| ---------------------- */  
  /*| Load the root elements */
  /*| ---------------------- */  
  
  for(index0=0; (int)index0 < nb_root; index0++)
    {
    /*" Add the root %d.%d in the graph\n",l_root[index0].objid,l_root[index0].osnum*/
            
    content.state      = GM_UNKNOWN;
    content.int_attr   = GM_INIT;
    content.nb_parent  = 0;
    status = GMh_add(&l_root[index0],&content,p_hcode);
    gm$status();
  }/* for(index0) */

  /*| --------------------- */  
  /*| Load the tip elements */
  /*| --------------------- */  
  
  for(index0=0; (int)index0 < nb_tip; index0++)
    {
    /*" Add the tip %d.%d in the graph\n",l_tip[index0].objid,l_tip[index0].osnum*/
            
    content.state      = GM_UNKNOWN;
    content.int_attr   = GM_TIP;
    content.nb_parent  = 0;
    status = GMh_add(&l_tip[index0],&content,p_hcode);
    gm$status();
  }/* for(index0) */

  /*| --------------------- */  
  /*| Fill the parents list */
  /*| --------------------- */ 
  
  ind_parent      = 0;
  if(!(p_graph->l_parent))
    {
    p_graph->s_lparent = (AV_NB_PAR*GMH_DEF_SIZE); 

    /*" The size of l_parent = %d\n", p_graph->s_lparent */
    p_graph->l_parent = (IGRushort *)malloc(p_graph->s_lparent*sizeof(IGRushort)); 
    if(!p_graph->l_parent){status=GM_E_NODYNMEM;gm$status();}
  }/* if */

  for(index0=nb_root; index0 < p_hcode->cur_elmt; index0++)
    {
    p_object  = (struct GRid *)GMh_key(p_hcode,index0);
    p_content = (struct GMelmt *)GMh_content(p_hcode,index0);
    p_graph->nb_elmt = index0;

    /*" Fill the field parents of %d.%d\n",p_object->objid,p_object->osnum */

    l_temp = NULL;
    status = p_graph->f_get_anc(p_object,p_graph->p_arg_anc,&l_temp,&nb_temp);
    if(!(status&1)){nb_temp =0; status = GM_I_NEG_RESPONSE;}

    p_content->nb_parent  = (IGRushort) nb_temp;
    p_content->ind_parent = (IGRushort) ind_parent;

    if (nb_temp == 0)
      {
      p_content->int_attr |= GM_EXTERN;
      }
    else
      p_content->int_attr |= GM_BODY;
    /* if (nb_temp) */

    /*| add eventually the parents */
      
    for(index1=0; (int)index1 < nb_temp; index1++)
      {
      if(ind_parent == p_graph->s_lparent)
        {
        /*| Reallocate memory for the parents */
          
        new_size = (p_graph->s_lparent)*FACTOR;
        p_graph->l_parent = (IGRushort *)realloc(p_graph->l_parent,new_size*sizeof(IGRushort)); 
        if(!p_graph->l_parent){status=GM_E_NODYNMEM;gm$status();}
        p_graph->s_lparent = new_size;
      }/* if(ind_parent)*/

      if(!GMh_give_content(&l_temp[index1],p_hcode,&p_content,&index_elmt))
        {   
        /*" Add the node %d.%d in the graph\n",l_temp[index1].objid,l_temp[index1].osnum*/
          
        content.int_attr  = GM_NULL_ATTR;
        content.state     = GM_UNKNOWN;
        content.ind_parent= GM_UNKNOWN;
        content.nb_parent = 0;
        p_graph->l_parent[ind_parent]= p_hcode->cur_elmt;
        status = GMh_add(&l_temp[index1],&content,p_hcode);
        gm$status();
        }
      else
        {
        p_graph->l_parent[ind_parent]= index_elmt; 
      }/* if(!GMh_give_content)*/
      ind_parent = ind_parent+1; 
    }/* for(index1)*/
  }/* for(index0)*/
  p_graph->nb_elmt = p_hcode->cur_elmt;

exception:
  return(status);
}/* GMcatch_up */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     INTERNAL function GMmodify_state                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMmodify_state(l_object, nb_object, select_fct, p_info, state, flag, p_graph)

  struct GRid    *l_object;   /* IN     List of objects to update             */
  int            nb_object;   /* IN     Number of objects in the list         */
  int         (*select_fct)();/* IN     Function to select the objects        */
  char           *p_info;     /* IN     Information for the select function   */
  short          state;       /* IN     State to modify on these objects      */
  char           flag;        /* IN     Flag to inverse the state             */
  struct GMgraph *p_graph;    /* OUT    Identifier of the graph               */
  /*
  Description : If the flag = TRUE, add the attibute state on the objects in
                the graph, else if the flag = FALSE erase the attribute state
  */ 
  /*.GMmodify_state */
  {
  IGRushort           index;     /* Index for a loop                             */
  struct GMhcode  *p_hcode;   /* Pointer to the hcode table for the graph     */
  struct GMelmt   *p_content; /* Content of a temporary graph element         */
  IGRushort           index_elmt;/* Returned index of the GMhcode                */

  p_hcode = p_graph->p_hcode;
  if(l_object)
    {
    for(index=0; (int)index < nb_object; index++)
      {
      if(GMh_give_content(&l_object[index],p_hcode,&p_content,&index_elmt))
        {
        if(flag)   
          {
          /*" Put the state %d on %d.%d\n",state,l_object[index].objid,l_object[index].osnum*/
          p_content->int_attr |= state;
          }
        else
          {
          /*" Erase the state %d on %d.%d\n",state,l_object[index].objid,l_object[index].osnum*/
          p_content->int_attr &= ~state;
        }/* if(flag)*/
      }/* if(!GMh_give_content)*/
    }/* for(index=0)*/
    }
  else
    {
    for(index=0; index < p_graph->nb_elmt; index++) 
      {
      p_content         = (struct GMelmt *)GMh_content(p_hcode,index);
      /*" Test %d.%d\n",((struct GRid *)GMh_key(p_hcode,index))->objid,((struct GRid *)GMh_key(p_hcode,index))->osnum*/

      if(!select_fct || select_fct(GMh_key(p_hcode,index),p_content->int_attr,p_info))
        {
        if(flag)   
          {
          /*" Put the state %d on %d.%d\n",state,((struct GRid *)GMh_key(p_hcode,index))->objid,((struct GRid *)GMh_key(p_hcode,index))->osnum*/
          p_content->int_attr |= state;
          }
        else
          {
          /*" Erase the state %d on %d.%d\n",state,((struct GRid *)GMh_key(p_hcode,index))->objid,((struct GRid *)GMh_key(p_hcode,index))->osnum*/
          p_content->int_attr &= ~state;
        }/* if(flag)*/
      }/* if(!select_fct)*/
    }/* for(index)*/
  }/* if(l_object)*/
  return(GM_S_SUCCESS); 
}/* GMmodify_state */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMmin_flag                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMmin_flag(l_tip, nb_tip, p_graph)

  struct GRid    *l_tip;     /* IN     List of the tip objects                */
  int            nb_tip;     /* IN     Number of tip objects                  */
  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */

  /*
  Description : Update the attibute flag GM_MINIMUM for the elements in
                the minimum graph
  Constraint  : nb_tip !=0, l_tip !=NULL
  */ 
  /*.GMmin_flag */
  {
  struct GMhcode   *p_hcode;  /* Temporary pointer to the hcode table         */
  struct GMelmt    *p_content;/* Content of a temporary graph element         */
  IGRushort           index0;    /* Index for a loop                             */
  IGRushort           index1;    /* Index for a loop                             */
  IGRushort           nb_l_min;  /* Number of objects in the minimum list        */
  IGRushort           *l_min;    /* Temporary list of the minimum objects        */
  IGRushort           index_tip; /* Index of the tip element in the hcode table  */
  IGRushort           index_elmt;/* Number of elements in the graph              */
  IGRushort           ind_parent;/* Index maximum in the array of parents        */
  int  status = GM_S_SUCCESS; /* status of the function                       */
  
  p_hcode = p_graph->p_hcode;

  /*| Fill the minimum list with the tip list */
  
  l_min = (IGRushort *)alloca(p_graph->nb_elmt*sizeof(IGRushort));
  if(!l_min){status=GM_E_NODYNMEM;gm$status();}

  for(index0=0; ((int)index0 < nb_tip)&&(status); index0++)
    {
    if(GMh_give_content(&l_tip[index0],p_hcode,&p_content,&index_tip))
      {
      l_min[index0] = index_tip;
      p_content->int_attr |= GM_MINIMAL;
      }
    else
      {
      status = FALSE;
    }/* if(GMh_give_content)*/
  }/* for(index0)*/

  if(status)
    nb_l_min = nb_tip;
  else
    nb_l_min = 0;

  /*| Fill the minimum list and update the flags */

  for(index0=0; index0 < nb_l_min;index0++)
    {
    /*" Find the parents of %d\n",((struct GRid *)GMh_key(p_hcode,l_min[index0]))->objid*/

    p_content = (struct GMelmt *)GMh_content(p_hcode,l_min[index0]);
    ind_parent = p_content->ind_parent+p_content->nb_parent;

    for(index1=p_content->ind_parent; index1<ind_parent; index1++)
      {
      index_elmt = p_graph->l_parent[index1];
      p_content = (struct GMelmt *)GMh_content(p_hcode,index_elmt);
      /*" Parent %d \n",((struct GRid *)GMh_key(p_hcode,index_elmt))->objid*/

      if(!(p_content->int_attr & GM_MINIMAL))
        {
        /*" The element %d is in the minimum graph\n",((struct GRid *)GMh_key(p_hcode,index_elmt))->objid*/

        if(p_content->int_attr & GM_BODY)
          {
          l_min[nb_l_min] = index_elmt;
          nb_l_min++;
        }/* if(p_content)*/
        p_content->int_attr |= GM_MINIMAL;
      }/* if */
    }/* for(index1) */
  }/* for(index0)*/
exception:

  return(status);
}/* GMmin_flag */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMroot_flag                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMroot_flag(p_graph)

  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */

  /*
  Description : Update the attibute flag GM_ROOT. GM_ROOT is a GM_INIT element
                that is not GM_BODY.
  Constraint  : none
  */ 
  /*.GMroot_flag */
  {
  struct GMhcode   *p_hcode;  /* Temporary pointer to the hcode table         */
  struct GMelmt    *p_content;/* Content of a temporary graph element         */
  IGRushort           nb_elmt;   /* Number of elements in the graph              */
  IGRushort           index0;    /* Index for a loop                             */
  
  p_hcode = p_graph->p_hcode;
  nb_elmt = p_hcode->cur_elmt;

  for(index0=0; index0 < nb_elmt; index0++)
    {
    p_content = (struct GMelmt *)GMh_content(p_hcode,index0);
    if((p_content->int_attr & GM_INIT)&&(!(p_content->int_attr & GM_BODY)))
      p_content->int_attr |= GM_ROOT;
  }/* for(index0)*/
  return(GM_S_SUCCESS);
}/* GMroot_flag */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                   INTERNAL function GMcompute_level                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMcompute_level(p_elmt, p_graph)

  struct GMelmt     *p_elmt; /* IN     Element to compute the level           */
  struct GMgraph    *p_graph;/* OUT    Pointer to the graph                   */

  /*
  Description : Computes the level of the element in the graph :
                if the level is computed return TRUE else return FALSE 
  Constraint  :
  */ 
  /*.GMcompute_level */
  {
  IGRushort  level;              /* Current level of a node                      */
  IGRushort  index0;             /* Index for a loop                             */
  int     response = FALSE;   /* Response of the function                     */
  struct GMelmt    *p_content;/* Content of a temporary graph element         */
  struct GMhcode   *p_hcode;  /* temporary pointer to the hcode table         */
     
  p_hcode = p_graph->p_hcode;
  
  if(p_elmt->state == GM_UNKNOWN)
    {
    if(p_elmt->nb_parent != 0)
      {
      /* Try to compute the level */

      p_content = (struct GMelmt *)GMh_content(p_hcode,p_graph->l_parent[p_elmt->ind_parent]);
      if(p_content->int_attr & GM_LOOP) level = GM_MIN_LEVEL;
      else level = p_content->state;

      for(index0=1; (index0 < p_elmt->nb_parent)&&(level != GM_UNKNOWN);index0++)
        {
        p_content = (struct GMelmt *)GMh_content(p_hcode,p_graph->l_parent[p_elmt->ind_parent+index0]);
        if(p_content->int_attr & GM_LOOP) continue;
        if(p_content->state >level) level = p_content->state;
      }/* for(index0)*/
   
      if(level != GM_UNKNOWN)
        {
        /*" The level is %d \n",(level+1) */
      
        level++;
        p_elmt->state = level;
        response = TRUE;
      }/* if(level)*/
      }
    else
      {
      p_elmt->state = GM_MIN_LEVEL;
      response = TRUE;
    }/* if(p_elmt->nb_parent) */
  }/* if(p_elmt->state) */
  return(response);
}/* GMcompute_level */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMget_int_anc                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_int_anc( p_object, p_graph, p_list, p_nb_elmt)
 
  struct GRid    *p_object;   /* IN     Object to get its parents             */
  struct GMgraph *p_graph;    /* IN     Identifier of the graph               */
  IGRushort         **p_list;    /* OUT    Pointer to the List of the ancestors  */
  int            *p_nb_elmt;  /* OUT    Number of ancestors of the object     */
  /*
  Description : Get the ancestors of an object throw the graph structure
  Constraint  : The graph must be get completly by the get_graph function
  */ 
  /*.GMget_int_anc */
  {
  static IGRushort    *l_anc = 0; /* List of the ancestors of the object         */
  static int       s_lanc = 0; /* Size of the list of ancestors               */
  int    status = GM_S_SUCCESS;/* Returned status of the function             */
  int               index0;    /* Index for a loop                            */
  unsigned  short   ind_elmt;  /* Index of the element in the hcode           */
  struct GMelmt     *p_content;/* Content of a temporary graph element        */

  if(GMh_give_content(p_object,p_graph->p_hcode,&p_content,&ind_elmt))
    {
    /*" Find the ancestors of %d.%d\n",p_object->objid,p_object->osnum*/

    *p_nb_elmt = p_content->nb_parent;

    if(p_list && (*p_nb_elmt))
      {
      /*| Have to fill the ancestor list */

      if(!(*p_list))
        {
        /*| The list is not given by the caller */

        status = GMajust_buf(*p_nb_elmt*sizeof(IGRushort),&l_anc,&s_lanc);
        gm$status();
        *p_list = l_anc;
      }/* if(!*p_list)*/

      for(index0=0; index0 < *p_nb_elmt; index0++)
        {
        (*p_list)[index0] = p_graph->l_parent[p_content->ind_parent+index0];
        /*" Load the element %d,%d in the parents list\n",((struct GRid *)GMh_key(p_graph->p_hcode,(*p_list)[index0]))->objid,((struct GRid *)GMh_key(p_graph->p_hcode,(*p_list)[index0]))->osnum*/
      }/* for(index0) */
    }/* if(p_list)*/
    }
  else
    {
    /*" %d.%d not found\n",p_object->objid,p_object->osnum*/
    status   = GM_W_ELMT_NOT_FOUND;
    *p_nb_elmt = 0;
  }/* if(GMh_give_content)*/

exception:
  return(status);
}/* GMget_int_anc */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function GMtrigger                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMtrigger(p_object,p_content,broad_fct,p_broad_arg,p_graph,l_status,p_nb_status)
  /*
  Description : Broadcast the function to the object if the trigger is O.K.
                and update the resulting state of the object
  Constraint  : The state of the objects of the graph must be initialized
                (currently used only during the GMbroadcast function) the list
                 l_status must be allocated or == NULL
  */ 
  struct GRid    *p_object;    /* IN     Object to broadcast                  */
  struct GMelmt  *p_content;   /* IN     Content of the object to broadcast   */
  int           (*broad_fct)();/* IN     Function to broadcast                */
  char           *p_broad_arg; /* IN     Arguments of the broadcast function  */
  struct GMgraph *p_graph;     /* OUT    Identifier of the graph              */
  int            *l_status;    /* OUT    List of the status of the sick obj   */
  int            *p_nb_status; /* OUT    Number of status in the list l_status*/
  /*.GMtrigger*/
  {
  IGRushort           *l_anc=NULL;/* List of the ancestors of the object         */
  IGRushort           *l_ancestor;/* Copy of this list (just a buffer)           */
  int              nb_anc;     /* Number of ancestors in this list            */
  int              index0;     /* Index for a loop                            */
  IGRushort           state;      /* State of the parent to test                 */
  IGRushort resp = GM_NULL_ATTR;  /* State of the node                           */
  struct GMhcode   *p_hcode;   /* Pointer to the hcode table for the graph    */
  int    status = GM_S_SUCCESS;/* Status returned by functions                */
  char             and_stop;   /* Flag = TRUE if the GM_AND_STOP is possible  */

  p_hcode  = p_graph->p_hcode;

  /*----------------------*/
  /*" Compute the trigger of %d.%d\n",p_object->objid,p_object->osnum*/
  /*----------------------*/

  /*| Get its parents */

  if(GMget_int_anc(p_object,p_graph,&l_anc,&nb_anc) == GM_S_SUCCESS)
    {
    l_ancestor = (IGRushort *)alloca(nb_anc*sizeof(IGRushort));
    if(!l_ancestor){status=GM_E_NODYNMEM;gm$status();}
    memcpy(l_ancestor,l_anc,nb_anc*sizeof(IGRushort));

    for(index0=0,and_stop=TRUE; index0 < nb_anc; index0++)
      {
      state=((struct GMelmt *)GMh_content(p_hcode,l_ancestor[index0]))->int_attr;
      /*" state [%d]=%d\n",index0,state*/

      if(and_stop && (!(state & GM_AND_STOP)))
        {
        /*| The GM_AND_STOP is not active */

        and_stop = FALSE;
      }/* if(and_stop)*/

      if(state & GM_OR_STOP)
        {
        /*| The GM_OR_STOP is active for one parent */

        resp = GM_OR_STOP;
        break;
      }/* if(state)*/
    }/* for(index0)*/
    if(nb_anc && and_stop) resp = GM_AND_STOP;

    if(resp == GM_NULL_ATTR)
      {
      /*----------------------------*/
      /*" Broacast the fct to %d.%d\n",p_object->objid,p_object->osnum*/
      /*----------------------------*/

      status = broad_fct(p_object,p_broad_arg);
      p_content->int_attr |= GM_BROAD;
      if(!(status&1))
        {
        /*| The broadcast function aborted*/
      
        p_content->int_attr |= (GM_SICK|GM_OR_STOP);
        if(l_status)
          {
          /*" Fill the status %d\n",status */
          l_status[*p_nb_status]=status;
        }/* if(l_status)*/
        (*p_nb_status)++;
      }/* if(!status)*/

      /*| Update the state resulting of the broadcast function*/

      if(GMmess_index(status) & GM_IOR_STOP) p_content->int_attr |= GM_OR_STOP;
      if(GMmess_index(status) & GM_IAND_STOP)p_content->int_attr |= GM_AND_STOP;
      }
    else
      {
      /*| Update the state resulting of the trigger */

      if(resp & GM_OR_STOP)
        {
        p_content->int_attr |= GM_OR_STOP;
        status |= GM_I_OR_STOP;
      }/* if */

      if(resp & GM_AND_STOP)
        {
        p_content->int_attr |= GM_AND_STOP;
        status |= GM_I_AND_STOP;
      }/* if */
    }/* if(resp)*/
  }/* if(GMget_int_anc)*/
exception:
  return(status);
}/* GMtrigger */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                  INTERNAL function GMget_suc_gr                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_suc_gr(l_root, nb_root, l_tip, nb_tip, p_graph, l_anc)

  struct GRid    *l_root;    /* IN     List of the root objects               */
  int            nb_root;    /* IN     Number of root objects                 */
  struct GRid    *l_tip;     /* IN     List of the tip objects                */
  int            nb_tip;     /* IN     Number of tip objects                  */
  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */
  struct GMlist  *l_anc;     /* OUT    List of ancestors if f_get_anc not def.*/
  /*
  Description : Catch a graph from the root list to the tip list
  Constraint  : none
  */ 
  /*.GMget_suc_gr */
  {
  struct GMhcode    *p_hcode;   /* Pointer to the hcode table for the graph   */
  struct GManc_pair obj_anc;    /* Pair of index ( object <---> ancestor )    */
  struct GMelmt     content;    /* Content of a temporary graph element       */
  struct GMelmt     *p_content; /* Content of a temporary graph element       */
  struct GRid       *p_object;  /* GRid of a temporary graph element          */
  IGRushort            index0;     /* Index for a loop                           */
  IGRushort            index1;     /* Index for a loop                           */
  IGRushort            index_elmt; /* Number of elements in the graph            */
  struct GRid       *l_temp;    /* List of temporary nodes                    */
  int               nb_temp;    /* Number of element in the ancestor list     */
  int status=GM_F_BAD_FUNCT_ARG;/* Status returned by the function            */

  if(nb_root == 0) return status;
  p_hcode = p_graph->p_hcode;

  /*----------------------- */  
  /*| Load the tip elements */
  /*----------------------- */  
  
  for(index0=0; (int)index0 < nb_tip; index0++)
    {
    /*" Add the tip %d.%d in the graph\n",l_tip[index0].objid,l_tip[index0].osnum*/
           
    content.state      = GM_UNKNOWN;
    content.int_attr   = GM_TIP;
    content.nb_parent  = 0;
    status = GMh_add(&l_tip[index0],&content,p_hcode);
    gm$status();
 }/* for(index0)*/

  /*------------------------ */  
  /*| Load the root elements */
  /*------------------------ */  
  
  for(index0=0; (int)index0 < nb_root; index0++)
    {
    if(GMh_give_content(&l_root[index0],p_hcode,&p_content,&index_elmt))
      {
      /*" The element %d.%d is also a tip\n",l_root[index0].objid,l_root[index0].osnum */

      p_content->int_attr |= GM_INIT;
      }
    else
      {
      /*" Load the root %d.%d in the graph\n",l_root[index0].objid,l_root[index0].osnum */
    
      content.ind_parent = GM_UNKNOWN;
      content.nb_parent  = 0;
      content.state      = GM_UNKNOWN;
      content.int_attr   = GM_INIT;
      status = GMh_add(&l_root[index0],&content,p_hcode);
      gm$status();
    }/* if(h_give_elmt) */
  }/* for(index0) */

  /*-------------------------- */  
  /*| Load the closed elements */
  /*-------------------------- */  

  for(index0=0; index0 < p_hcode->cur_elmt; index0++)
    {
    p_object  = (struct GRid *)GMh_key(p_hcode,index0);
    p_content = (struct GMelmt *)GMh_content(p_hcode,index0);
    p_graph->nb_elmt = index0;

    l_temp = NULL;
    status = p_graph->f_get_suc(p_object,p_graph->p_arg_suc,&l_temp,&nb_temp);
    if(!(status&1)){nb_temp =0; status = GM_I_NEG_RESPONSE;}

    /*" The element %d.%d has %d succcessors\n",p_object->objid,p_object->osnum,nb_temp */

    if(nb_temp ==0)
      {
      /*" The element %d.%d is a leaf\n",p_object->objid,p_object->osnum*/
        
      p_content->int_attr |= GM_LEAF;
      }
    else
      {
      for(index1=0; (int)index1 < nb_temp; index1++)
        {
        /*" The successor %d.%d \n",l_temp[index1].objid,l_temp[index1].osnum*/

        if(!GMh_give_content(&l_temp[index1],p_hcode,&p_content,&index_elmt))
          {   
          /*" Add the successor %d.%d in the graph\n",l_temp[index1].objid,l_temp[index1].osnum*/

          content.int_attr = GM_BODY;
          content.state    = GM_UNKNOWN;
          status = GMh_add(&l_temp[index1],&content,p_hcode);
          gm$status();
          status = GMh_give_content(&l_temp[index1],p_hcode,&p_content,&index_elmt);
          gm$status();
          }
        else
          {
          /*" The element %d.%d is also a body\n",l_temp[index1].objid,l_temp[index1].osnum*/

          p_content->int_attr |= GM_BODY;
        }/* if(!GMh_give_content) */

        if(l_anc)
          {
          /*| Add the pair in the list */

          obj_anc.key_index = index_elmt;
          obj_anc.anc_index = index0;
          status = GMl_add(&obj_anc,l_anc);
          gm$status();
        }/* if(l_anc)*/
      }/* for(index1)*/
    }/* if(nb_temp)*/
  }/* for(index0)*/
  p_graph->nb_elmt = p_hcode->cur_elmt;

exception:
  return(status);
}/* GMget_suc_gr*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          INTERNAL function GMordinate                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMordinate(p_graph)
  /*
  Description : Fill the ordinate list of the graph
  Constraint  : The graph must be completely defined. i.e. all the objects must
                be taken and the variable p_graph->nb_elmt must
                 - be = number of objects - extern objects
                 - or be = number of objects
  */ 
  struct GMgraph   *p_graph;  /* OUT    Identifier of the resultant graph     */
  /*.GMordinate */
  {
  struct GMhcode *p_hcode;    /* Pointer to the hcode table of the graph      */
  struct GRid    *p_object;   /* GRid of a temporary graph element            */
  struct GMelmt  *p_content;  /* Content of a temporary graph element         */
  IGRushort         index0;      /* Index for a loop                             */
  IGRushort         index1;      /* Index for a loop                             */
  IGRushort         index2;      /* Index for a loop                             */
  short          rej_type;    /* Type to reject during the selection          */
  int            is_in_loop;  /* Flag = TRUE if the object is in a loop       */
  int status = GM_S_SUCCESS;  /* Status returned by functions                 */

  /*| Load the EXTERN elements */
  
  p_hcode = p_graph->p_hcode;
  for(index0 = p_graph->nb_elmt,index1=0; index0 < p_hcode->cur_elmt;index0++)
    {
    p_graph->l_ord_elmt[index1]=index0;
    index1++;
  }/* for(index0)*/
  index0 = index1;

  /*| Load the BODY elements */
  
  rej_type = GM_EXTERN|GM_ROOT|GM_LEAF|GM_LOOP;
  for(; index0 < p_hcode->cur_elmt;)
    {
    index2 = index0;
    for(index1=0; index1 < p_graph->nb_elmt; index1++)
      {
      if(GMcompute_level((struct GMelmt *)GMh_content(p_hcode,index1),p_graph))
        {
        /*" Add the element %d.%d \n",((struct GRid *)GMh_key(p_hcode,index1))->objid,((struct GRid *)GMh_key(p_hcode,index1))->osnum */
           
        p_graph->l_ord_elmt[index0]=index1;
        index0++;
      }/* if(GMcompute_level)*/
    }/* for(index1) */

    if(index2 == index0)
      {
      /*| there is a loop in the graph */
     
      for(index1=0; index1 < p_graph->nb_elmt; index1++)
        {
        p_object = (struct GRid *)GMh_key(p_hcode,index1);
        p_content = (struct GMelmt *)GMh_content(p_hcode,index1);
        if(!(p_content->int_attr & rej_type))
          {
          status = GMfind_loop(p_object, p_graph, &is_in_loop);
          if(is_in_loop)
            {
            break;
          }/* if is_in_loop */
        }/* if(!(p_content->int_attr))*/
      }/* for(index1)*/
    }/* if(index2) */
  }/* for(;index0)*/

  return(status);
}/* GMordinate */
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMget_list                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_list(p_graph, select_fctu, p_sel_argu, p_list, p_nb_elmt)

  struct GMgraph *p_graph;    /* IN     Identifier of the resultant graph     */
  int        (*select_fctu)();/* IN     User function to select the node      */
  char           *p_sel_argu; /* IN     Arguments of the previous function    */
  struct GRid    *p_list[];   /* OUT    Pointer to the List of the elements   */
  int            *p_nb_elmt;  /* OUT    Number of elements in this list       */

  /*
  Description : get the specified list in the graph, if the list l_elmt is 
                NULL, fill the default buffer p_list
  */ 
  /*.GMget_list */
  {
  IGRushort            index0;    /* Index for a loop                            */
  IGRushort            index1;    /* Index for a loop                            */
  IGRushort            index2;    /* Index for a loop                            */
  struct GMelmt     *p_content;/* Content of a temporary graph element        */
  struct GRid       *p_object; /* GRid of a temporary graph element           */
  struct GMhcode    *p_hcode;  /* Pointer to the hcode table for the graph    */
  int  status = GM_S_SUCCESS;  /* Return code of a function                   */

  static
  struct GRid *l_buffer = NULL;/* Default buffer for the list of GRid         */
  static int  s_buffer = 0;    /* Size of the internal buffer                 */

  if(p_list && !(*p_list))
    {
    /*| The list is not given by the caller */

    status = GMajust_buf(p_graph->nb_elmt*sizeof(struct GRid),&l_buffer,&s_buffer);
    gm$status();
  }/* if(!*p_list)*/

  /*| Fill the Buffer list */

  p_hcode = p_graph->p_hcode;
  for(index0=0,index1=0;index0 < p_graph->nb_elmt;index0++) 
    {
    index2    = p_graph->l_ord_elmt[index0];
    p_content = (struct GMelmt *)GMh_content(p_hcode,index2);
    p_object  = (struct GRid *)GMh_key(p_hcode,index2);

    if((!select_fctu) || select_fctu(p_object,p_content->int_attr,p_sel_argu))
      {
      if(p_list)
        {
        if(*p_list)
          {
          if(*p_nb_elmt > (int)index1) (*p_list)[index1] = *p_object;
          }
        else l_buffer[index1] = *p_object;
      }/* if*/
      index1++;
    }/* if(!select_fctu) */
  }/* for(index0)*/
 
  if(p_list && !(*p_list)) (*p_list) = l_buffer;
  if(p_nb_elmt != NULL) *p_nb_elmt = (int)index1;
  /*" The list has %d elements\n",*p_nb_elmt*/ 

exception:
  return(status);
}/* GMget_list */
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMajust_buf                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

 GMajust_buf( new_size, pl_buff, p_sbuff)

  int            new_size;    /* IN     New size for the buffer               */
  char           **pl_buff;   /* IN/OUT Buffer to check                       */
  int            *p_sbuff;    /* IN/OUT Size of the buffer to check           */
  /*
  Description : Check if the buffer has a sufficient size and reallocate a 
                bigger memory if necessary.
  Constraint  : The buffer must be =0 during initialization.

  */ 
  /*.GMajust_buf */
  {
  int  status = GM_S_SUCCESS;  /* Return code of a function                   */

  if((*pl_buff)&&(*p_sbuff < new_size))
    {
    free((*pl_buff));
    (*pl_buff) = NULL;
  }/* if */

  if(!(*pl_buff))
    {
    /*| Malloc the list of ancestors */

    *p_sbuff = new_size;
    *pl_buff = (char *)malloc(*p_sbuff);
    if(!(*pl_buff)){status=GM_E_NODYNMEM;gm$status();}
  }/* if((*pl_buff))*/

exception:
  return(status);
}/* GMajust_buf */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


