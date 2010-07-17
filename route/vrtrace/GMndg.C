#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "GMdef.h"
#include "GM.h"
#include "GMndg.h"
#include "alloca.h"

#define AS_DEBUG

#define GM_ALL     0xffff /* All the elements of the graph                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMndg_activate                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMndg_activate(modulo, size, p_graph)

  int              modulo;    /* IN     Number of root objects                */
  int              size;      /* IN     Number of root objects                */
  struct GMndgraph *p_graph;  /* OUT    Graph to activate                     */
  /*
  Description : activate a non directed graph structure
  Constraint  : none
  */ 
  /*.GMndg_activate*/
  {
  unsigned short      key_size;       /* Size of the keys of the hcode                */
  extern int  GMgridcmp();    /* Function to compare the grids                */
  extern int  GMh_grid();     /* Function to hash a grid                      */
  short       attribute;      /* Attribute stored in the list                 */
  int         status;         /* Response of the function                     */
  
  /*| Activate the hcode */

  key_size = sizeof(struct GRid);
  status = GMh_activate(modulo,size,size,sizeof(attribute),key_size,
           GMgridcmp,NULL,GMh_grid,&p_graph->hcode);
  return(status);
}/* end GMndg_activate*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMndg_disactivate                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMndg_disactivate(p_graph)

  struct GMndgraph *p_graph;  /* OUT    Graph to disactivate                  */
  /*
  Description : disactivate a non directed graph structure
  Constraint  : the graph must be allocated before
  */ 
  /*.GMndg_disactivate*/
  {
  int         status;         /* Response of the function                     */
  
  /*| disactivate the hcode */

  status = GMh_disactivate(&p_graph->hcode);
  return(status);
}/* end GMndg_disactivate*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMndg_clear                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMndg_clear(p_graph)

  struct GMndgraph *p_graph;  /* OUT    Graph to clear                        */
  /*
  Description : clear a non directed graph structure
  Constraint  : the graph must be allocated before
  */ 
  /*.GMndg_clear*/
  {
  int         status;         /* Response of the function                     */
  
  /*| clear the hcode */

  status = GMh_clear(&p_graph->hcode);
  return(status);
}/* end GMndg_clear*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMndg_depth_first                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
GMndg_depth_first(p_graph, p_object)

  struct GMndgraph  *p_graph;    /* IN     Pointer to the graph               */
  struct GRid       *p_object;   /* IN     Pointer to the object to expand    */
  /*
  Description : Do a depth first research in a non directed graph
  Constraint  : The graph must be allocated before
  */ 
  /*.GMndg_depth_first*/
  {
  int response=GM_I_NEG_RESPONSE;/* Response of the function                  */
  int         status;            /* Return code of the function               */
  int         in_graph;          /* Flag = TRUE if the object is in the Graph */
  char        attribute;         /* Attribute stored in the list              */
  char        *p_attribute;      /* Pointer to an attribute                   */
  int         index_obj;         /* Index of the found object                 */
  int         index;             /* Index for a loop                          */
  struct GRid *l_connex=NULL;    /* List of the connexions                    */
  int         nb_connex=0;       /* Number of connexions in the list          */
 
  in_graph = GMh_give_content(p_object,&p_graph->hcode,&p_attribute,&index_obj);

  if(!in_graph)
    {
    /*" Get the connexions of %d.%d\n",p_object->objid,p_object->osnum*/
 
    l_connex = (struct GRid *)alloca(VRMAX_CONNEX*sizeof(struct GRid));
    if(!l_connex){status =  GM_E_NODYNMEM; gm$status();}

    status = p_graph->f_get_connex(p_object,p_graph->p_connex_info,&l_connex,&nb_connex);
    gm$status();

    /*" Put %d.%d in the search graph\n",p_object->objid,p_object->osnum*/

    attribute = GM_EXTERN;
    if(nb_connex <= 1)  attribute |= GM_LEAF;
    status    = GMh_add(p_object,&attribute,&p_graph->hcode);
    gm$status();

    /* added by momo */
    if( ! nb_connex ) return GM_S_SUCCESS;

    for(index=0; index < nb_connex; index++)
      {
      /*"Expand %d.%d\n",l_connex[index].objid,l_connex[index].osnum*/
     
      status = GMndg_depth_first(p_graph,&l_connex[index]);
      gm$status();
      if(status == GM_S_SUCCESS) response = GM_S_SUCCESS;
    }/* end for */

    if(response != GM_S_SUCCESS)
      {
      /*" Remove the object %d.%d from the List\n",p_object->objid,p_object->osnum*/

      status = GMh_remove(p_object,&p_graph->hcode);
      gm$status();
    }/*if(response)*/
    }
  else
    {
    /*" %d.%d is in the graph\n",p_object->objid,p_object->osnum*/

    attribute = *p_attribute;
    if(*p_attribute & GM_BODY) return(GM_S_SUCCESS);
  }/* end if(!in_graph)*/

  if(attribute & p_graph->type) response = GM_S_SUCCESS;

  if(response == GM_S_SUCCESS)
    {
    /*" ADD OBJECT --> %d.%d in the List\n",p_object->objid,p_object->osnum*/

    if(!in_graph)
      GMh_give_content(p_object,&p_graph->hcode,&p_attribute,&index_obj);
    *p_attribute |= GM_BODY; 
  }/* end if(response)*/
  return(response);

exception:
  return(status);
}/* end GMndg_depth_first */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMndg_getgraph                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMndg_getgraph(l_root, nb_root, f_get_connex, p_connex_info, p_graph)

  struct GRid      *l_root;   /* IN     List of the root's objects            */
  int              nb_root;   /* IN     Number of root objects                */
  int    (*f_get_connex)();   /* IN     Function to get the connexions        */
  char   *p_connex_info;      /* IN     Information for the function          */
  struct GMndgraph *p_graph;  /* IN/OUT Graph made                            */
  /*
  Description : Get the non directed graph included between the roots elements
                of the list (using a depth first research). 
  Constraint  : The graph must be allocated before
  */ 
  /*.GMndg_getgraph*/
  {
  short       attribute;      /* Attribute stored in the list                 */
  int         index0;         /* Index for a loop                             */
  int         status;         /* Response of the function                     */
 
  if(!f_get_connex){status=GM_F_BAD_FUNCT_ARG;gm$status();}
  p_graph->f_get_connex  = f_get_connex;
  p_graph->p_connex_info = p_connex_info;

  /*| Load the graph */

  if(nb_root == 1)
    {
    /*| Find all the elements of the graph */

    p_graph->type = GM_ALL;
    status = GMndg_depth_first(p_graph,l_root);
    gm$status();
    }
  else
    {
    p_graph->type = GM_TIP;
    attribute     = GM_TIP;
    status        = GMh_add(l_root,&attribute,&p_graph->hcode);
    gm$status();

    for(index0=1; index0<nb_root; index0++)
      {
      /*| Find the graph included between the roots */

      status = GMndg_depth_first(p_graph,&l_root[index0]);
      gm$status();
    }/* end for(index0)*/
  }/* end if(nb_root)*/

exception:
  return(status);
}/* end GMndg_getgraph*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
