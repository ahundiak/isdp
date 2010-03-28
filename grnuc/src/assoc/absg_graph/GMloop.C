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
/*                         function GMget_loop_elmts                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_loop_elmts(p_object, p_graph, pl_object, p_count)
  
  struct GRid    *p_object;  /* IN     Object to test the loops               */
  struct GMgraph *p_graph;   /* IN     Graph which contain the loop           */
  struct GRid    **pl_object;/* IN/OUT List of the loop objects               */
  int             *p_count;  /* OUT    Number of loop objects                 */
  /*
  Description : Returns the elements belonging to the same loop as an object.
                The loops are "strong components" that can include several
                nested loops.
  */ 
  /*.GMget_loop_elmts*/
  {
  struct GMgraph   tmp_graph;  /* Temporary graph to get the loops            */
  int              nb_elmt;    /* Number of objects in the loop               */
  struct GMelmt    *p_content; /* Content of a temporary graph element        */
  struct GMhcode   *p_hcode;   /* Pointer to the hcode table for the graph    */
  static struct GRid *l_obj=0; /* list of the indexes in the hcode            */
  static int       s_lobj = 0; /* Size of the list of indexes                 */
  IGRushort           *l_index=0; /* List of indexes for loop objects            */
  int status=GM_I_NEG_RESPONSE;/* Status returned by functions                */
  int              ind;        /* Index for a loop                            */
  int exception_type = NULL;   /* Type of exception if degraded mode          */
  extern int GMget_anc_loop(); /* Function to get the loop ancestors          */

  if(GMh_give_content(p_object,p_graph->p_hcode,&p_content,NULL)
  &&(p_content->int_attr & GM_LOOP))
    {
    /*| Initialize the temporay graph */

    nb_elmt = p_graph->nb_elmt;
    status = GMinit_graph(nb_elmt, nb_elmt, nb_elmt, &tmp_graph);
    gm$status();

    /*| Get the loop list */

    tmp_graph.f_get_suc = GMget_anc_loop;
    tmp_graph.p_arg_suc = (char *)p_graph;
    status = GMget_suc_gr(p_object,1,0,0,&tmp_graph,0);
    gm$status(type = EXCEPTION_1);

    /*| Get loop graph elements */

    p_hcode = tmp_graph.p_hcode;
    status = GMh_getlist(p_hcode, NULL, NULL, &l_index, p_count);
    gm$status(type = EXCEPTION_1);

    if(pl_object && (*p_count))
      {
      /*| Have to fill the list */

      if(!(*pl_object))
        {
        /*| The list is not given by the caller */

        status = GMajust_buf(*p_count*sizeof(struct GRid),&l_obj,&s_lobj);
        gm$status(type = EXCEPTION_1);
        *pl_object = l_obj;
      }/* if(!*pl_object)*/

      for(ind=0; ind<*p_count; ind++)
        (*pl_object)[ind] = *((struct GRid *)GMh_key(p_hcode,l_index[ind]));
    }/* if(pl_object)*/

    GMremove_graph(&tmp_graph);
    }
  else
    {
    /*| This element is not in a loop */

    if(p_count) *p_count = 0;
  }/* if */

exception:
  if(exception_type == EXCEPTION_1) GMremove_graph(&tmp_graph);
  return(status);
}/* GMget_loop_elmts */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMfind_loop                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMfind_loop(p_object, p_graph, p_response)

  struct GRid    *p_object;  /* IN     Object to test the loops               */
  struct GMgraph *p_graph;   /* IN     Graph which contain the loop           */
  int            *p_response;/* OUT    response of the function               */
  /*
  Description : Return TRUE if the object *p_object have his successors which
                are also ancestors. In this case mark all the objects of the
                loop(s) by the type GM_LOOP.
  */ 
  /*.GMfind_loop*/
  {
  struct GMgraph   tmp_graph;  /* Temporary graph to get the loops            */
  int              status;     /* Status returned by functions                */
  struct GRid      *p_obj;     /* Temporary object                            */
  IGRushort           *l_index=0; /* List of indexes for loop objects            */
  IGRushort           object_ind; /* Index of the beginning of the loop          */
  int              nb_elmt;    /* Number of objects in the loop               */
  struct GMelmt    *p_content; /* Content of a temporary graph element        */
  int              ind;        /* Index for a loop                            */
  int              nb_loop_el; /* Number of loop elements                     */
  int        GMget_anc_ingr(); /* Function to get the ancestors               */
  int exception_type = NULL;   /* Type of exception if degraded mode          */
  *p_response = FALSE;

  /*| Get the loop list */

  nb_elmt = p_graph->nb_elmt;
  status = GMinit_graph(nb_elmt, nb_elmt, nb_elmt, &tmp_graph);
  gm$status();

  status = GMget_loop_path(p_object,GMget_anc_ingr,p_graph,&tmp_graph);
  gm$status(type = EXCEPTION_1);

  /*| Get loop graph elements */

  status = GMh_getlist(tmp_graph.p_hcode, NULL, NULL, &l_index, &nb_elmt);
  gm$status(type = EXCEPTION_1);

  for(nb_loop_el=ind=0; ind<nb_elmt; ind++)
    {
    p_obj = (struct GRid *)GMh_key(tmp_graph.p_hcode,l_index[ind]);
    if(GMh_give_content(p_obj,p_graph->p_hcode,&p_content,NULL))
      {
      p_content->int_attr |= GM_LOOP;
      nb_loop_el++;
    }/*if(GMh_give_content)*/
  }/* for */

  if(nb_loop_el == 1)
    {
    /* Check if the object is looping on itself */

    GMh_give_content(p_object,p_graph->p_hcode,&p_content,&object_ind);
    l_index=0;
    GMget_int_anc( p_object, p_graph, &l_index, &nb_elmt);
    for ((*p_response)=FALSE, ind=0; ind < nb_elmt; ind++)
      if(object_ind == l_index[ind])
        {
        (*p_response) = TRUE;
        break;
      }

    if(!(*p_response)
    &&GMh_give_content(p_object,p_graph->p_hcode,&p_content,NULL))
      {
      /*| Only one element, It is not a loop */

      p_content->int_attr &= ~GM_LOOP;
      nb_loop_el = 0;
    }/* if */
  }

  GMremove_graph(&tmp_graph);
  *p_response = (nb_loop_el > 0);

exception:
  if(exception_type == EXCEPTION_1) GMremove_graph(&tmp_graph);
  return(status);
}/* GMfind_loop */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMget_loop_path                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_loop_path(p_object, f_get_anc, p_arg_anc, p_graph)

  struct GRid      *p_object; /* IN     Object to start the research          */
  int    (*f_get_anc)();      /* IN     Function to get the connexions        */
  char   *p_arg_anc;          /* IN     Information for the function          */
  struct GMgraph   *p_graph;  /* IN/OUT Graph made                            */
  /*
  Description : Search the loop paths in a graph between the nodes specified in
                l_initial list (using a depth first research). 
  Constraint  : The graph must be allocated before,
                nb_initial must be > 1.
  */ 
  /*.GMget_loop_path*/
  {
  struct GMelmt attribute;    /* Attribute stored in the list                 */
  int           status;       /* Response of the function                     */
  int           nb_connex=0;  /* Number of connexions in the list             */
  
  if(!f_get_anc){status=GM_F_BAD_FUNCT_ARG;gm$status();}
  status = f_get_anc(p_object,p_arg_anc,NULL,&nb_connex);
  if(!status) nb_connex =0;
  if(nb_connex)
    {
    /*| Load the graph */

    p_graph->f_get_anc = f_get_anc;
    p_graph->p_arg_anc = p_arg_anc;
    attribute.int_attr = GM_INIT;
    status = GMh_add(p_object,&attribute,p_graph->p_hcode);

    /*| Find the graph  */

    status = GMdepth_first(p_graph,p_object);
    gm$status();
  }/* if(nb_connex)*/

exception:
  return(status);
}/* GMget_loop_path*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMdepth_first                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMdepth_first(p_graph, p_object)

  struct GMgraph    *p_graph;    /* IN     Pointer to the graph               */
  struct GRid       *p_object;   /* IN     Pointer to the object to expand    */
  /*
  Description : Do a depth first research in a non directed graph
  Constraint  : The graph must be allocated before
  */ 
  /*.GMdepth_first*/
  {
  int         status;            /* Return code of the function               */
  int         in_graph;          /* Flag = TRUE if the object is in the Graph */
  struct GMelmt attribute;       /* Attribute stored in the list              */
  struct GMelmt *p_attribute;    /* Pointer to an attribute                   */
  int         index;             /* Index for a loop                          */
  struct GRid *l_connex=NULL;    /* List of the connexions                    */
  int         nb_connex=0;       /* Number of connexions in the list          */
  char        first_search=FALSE;/* Flag = TRUE if first search               */

  in_graph = GMh_give_content(p_object,p_graph->p_hcode,&p_attribute,NULL);

  if((!in_graph)
  ||(first_search=(p_attribute->int_attr&GM_INIT)&&(!(p_attribute->int_attr&GM_BODY))))
    {
    /*" Get the connexions of %d.%d\n",p_object->objid,p_object->osnum*/

    if(!first_search) attribute.int_attr=0;
    else attribute.int_attr = GM_INIT|GM_BODY;
    status = p_graph->f_get_anc(p_object,p_graph->p_arg_anc,NULL,&nb_connex);
    if(!status) nb_connex =0;

    if(nb_connex)
      {
      l_connex = (struct GRid *)alloca(nb_connex*sizeof(struct GRid));
      if(!l_connex){status =GM_E_NODYNMEM; gm$status();}
      status = p_graph->f_get_anc(p_object,p_graph->p_arg_anc,&l_connex,&nb_connex);
      gm$status();

      /*" Put %d.%d in the search graph\n",p_object->objid,p_object->osnum*/
      status = GMh_add(p_object,&attribute,p_graph->p_hcode);
      gm$status();

      for(index=0; index < nb_connex; index++)
        {
        /*"Expand %d.%d\n",l_connex[index].objid,l_connex[index].osnum*/
     
        status = GMdepth_first(p_graph,&l_connex[index]);

        switch(status)
          {
          case GM_S_SUCCESS:
          /* Body object encountered */
          if(GMh_give_content(p_object,p_graph->p_hcode,&p_attribute,NULL))
            p_attribute->int_attr |= GM_BODY;
          break;

          case GM_I_TAG:
          /* Non body object encountered */
          break;

          default:
          /* dead end */
          /*" Remove the object %d.%d from the List\n",l_connex[index].objid,l_connex[index].osnum*/

          GMh_remove(&l_connex[index],p_graph->p_hcode);
        }/* switch */

        /*| Update the status */

        if(GMh_give_content(p_object,p_graph->p_hcode,&p_attribute,NULL)
        &&(p_attribute->int_attr & GM_BODY))
          status = GM_S_SUCCESS;
        else status = GM_I_NEG_RESPONSE;
      }/* for */
      }
    else
      {
      status = GM_I_NEG_RESPONSE;
    }/*if(nb_connex)*/
    }
  else
    {
    /*" %d.%d is in the graph\n",p_object->objid,p_object->osnum*/

    if(p_attribute->int_attr & GM_BODY)
      status = GM_S_SUCCESS;
    else status = GM_I_TAG;
  }/* if(!in_graph)*/

exception:
  return(status);
}/* GMdepth_first */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function GMget_anc_loop                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_anc_loop(p_object, p_graph, pl_object, p_count)
  
  struct GRid    *p_object;   /* IN     Object to update                      */
  struct GMgraph *p_graph;    /* IN     Pointer to the graph                  */
  struct GRid    **pl_object; /* IN/OUT List of the ancestors objects         */
  int            *p_count;    /* OUT    Number of ancestor objects            */
 
  /*.GMget_anc_loop*/
  {
  /*
  Description : Returns the ancestor list of an object in a graph wich are also
                in a loop.(List of ancestors stored in the graph for this 
                object with GM_LOOP attribute).
  Constraint  : The graph must be allocated before.
  */ 
  int            ind0;         /* Index for a loop                            */
  int            ind1;         /* Index for a loop                            */
  int            status;       /* Returned status of the function             */
  struct GMelmt  *p_content;   /* Content of a temporary graph element        */
  struct GRid    *l_connex=0;  /* List of the connexions                      */
  
  status = GMget_anc_ingr(p_object, p_graph, &l_connex, p_count);
  gm$status();

  if((pl_object)&&(*pl_object))
    {
    /*| Fill the argument list */

    for(ind0=ind1=0; ind0 < *p_count; ind0++)
      {
      if(GMh_give_content(&(l_connex[ind0]),p_graph->p_hcode,&p_content,NULL)
      &&(p_content->int_attr & GM_LOOP))

      (*pl_object)[ind1++] = l_connex[ind0];
    }/* for(ind0)*/
    *p_count = ind1;
    }
  else
    {
    if(pl_object) *pl_object = l_connex;

    /*| Update the buffer */

    for(ind0=0; ind0 < *p_count;)
      {
      if(GMh_give_content(&(l_connex[ind0]),p_graph->p_hcode,&p_content,NULL)
      &&(!(p_content->int_attr & GM_LOOP)))
        {
        /*| This object is not a loop , remove it */

        (*p_count)--;
        for(ind1=ind0; ind1<*p_count; ind1++) l_connex[ind1]=l_connex[ind1+1];
        }
      else ind0++;
    }/* for(ind0)*/
  }/*if(pl_object)*/
  
exception:
  return(status);
}/* GMget_anc_loop*/ 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
