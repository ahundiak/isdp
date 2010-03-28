#include <sys/types.h>
#include <stdio.h>
#include "EXgrid.h"
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "igrtypedef.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          INTERNAL function GMsel_and                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsel_and(p_object, int_attr, p_info)
  /*
  Description : select the internal attribute with "&" operator
  Constraint  : none
  */ 

  struct GRid      *p_object; /* IN     Pointer to the object to select       */
  short            int_attr;  /* IN     Internal attribute                    */
  short            *p_info;   /* IN     User information for the function     */
  {
  return(int_attr & (*p_info));
}/* GMsel_and */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         INTERNAL function GMsel_nand                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMsel_nand(p_object, int_attr, p_info)
  /*
  Description : select the internal attribute with "!&" operator
  Constraint  : none
  */ 

  struct GRid      *p_object; /* IN     Pointer to the object to select       */
  short            int_attr;  /* IN     Internal attribute                    */
  short            *p_info;   /* IN     User information for the function     */
  {
  return(!(int_attr & (*p_info)));
}/* GMsel_nand */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function GMcmp_grid                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMgridcmp(p_ext_key, p_int_key, p_user_info)

  struct GRid   *p_ext_key;   /* IN     Key of the external element to compare*/
  struct GRid   *p_int_key;   /* IN     Key of the internal element to compare*/
  char          *p_user_info; /* IN     Additional information                */
  {
  int           result;       /* Result of the function                       */

  if(result = p_ext_key->objid-p_int_key->objid)
    return result;
  else
    return (p_ext_key->osnum-p_int_key->osnum);
}/* GMgridcmp */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         INTERNAL function GMmemcmp                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMmemcmp(p_ext_key,p_int_key,p_user_info)

  int           *p_ext_key;   /* IN     Key of the external element to compare*/
  int           *p_int_key;   /* IN     Key of the internal element to compare*/
  char          *p_user_info; /* IN     Additional information                */
  {
  return(memcmp(p_ext_key,p_int_key,(int)*p_user_info));
}/* GMmemcmp*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function h_grid                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_grid(p_key)
  /*
  Description : Compute the index of a grid in the head list
  */
  struct GRid      *p_key;    /* IN       Pointer to the Key of the element   */
  /*.h_grid*/
  {
  return(p_key->objid);
}/* h_grid */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMreq_equal                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMreq_equal(p_request_1, p_request_2, p_user_info)

  struct GMmodif *p_request_1;/* IN     request_1 to compare with request_2   */
  struct GMmodif *p_request_2;/* IN     request_2 to compare with request_1   */
  char         *p_user_info;  /* IN     Additional information                */
  /*.GMreq_equal*/
  {
  return(GMgridcmp(&p_request_1->object,&p_request_2->object,(char *)NULL));
}/* GMreq_equal */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         INTERNAL function GMorient                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMorient(p_object, p_graph, l_succ, p_nb_succ)

  struct GRid    *p_object;   /* IN     Object to analyse                     */
  struct GMgraph *p_graph;    /* IN     Identifier of the constructed graph   */
  struct GRid    *l_succ;     /* IN/OUT List of the successors of the object  */
  int            *p_nb_succ;  /* IN/OUT Number of successors in the list      */
  /*
  Description : Give an arbitrary orientation to a non directed graph using the
                following principle: Remove from the list of successors the 
                objects that are already direct ancestors
  Constraint  : Currently implemented just for the trees
                for general cases we have to test that the object in the graph
                has been expanded(current_pointer). To do that change the loop 
                indexes of the breadth fisrst research to a graph inused index
                ----> p_graph->nb_elmt
  */
  /*.GMorient */
  {
  struct GMhcode *p_hcode;    /* Pointer to the hcode table for the graph     */
  struct GMelmt  *p_content;  /* Content of a temporary graph element         */
  IGRushort         index;       /* Index for a loop                             */
  IGRushort         index_elmt;  /* index of the element in the hcode table      */

  /*" Orient the connexions of %d.%d \n",p_object->objid,p_object->osnum*/
 
  p_hcode = p_graph->p_hcode;
  for(index=0; (int)index<*p_nb_succ;)
    {
    if(GMh_give_content(&l_succ[index],p_hcode,&p_content,&index_elmt)
      &&(index_elmt < p_graph->nb_elmt))
      {   
      /*" Remove %d.%d to orient the graph\n",l_succ[index].objid,l_succ[index].osnum*/

      (*p_nb_succ)--;
      memcpy(&l_succ[index],&l_succ[index+1],(*p_nb_succ-index)*sizeof(struct GRid));
      }
    else
      {
      index++;
    }/* if */
  }/* for (index)*/
  return(GM_S_SUCCESS);
}/* GMorient */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       function GMget_anc_ingr                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_anc_ingr(p_object, p_graph, pl_object, p_count)
  
  struct GRid     *p_object;  /* IN     Object to update                      */
  struct GMgraph  *p_graph;   /* IN     Pointer to the graph                  */
  struct GRid     **pl_object;/* IN/OUT List of the ancestors objects         */
  int             *p_count;   /* OUT    Number of ancestor objects            */
 
  /*.GMget_anc_ingr*/
  {
  /*
  Description : Returns the ancestor list of an object in a graph
                (List of ancestors stored in the graph for this object).
  Constraint  : The graph must be allocated before.
  */ 
  int            index;        /* Index for a loop                            */
  struct GMhcode *p_hcode;     /* Pointer to the hcode table for the graph    */
  IGRushort         *l_index=0;   /* list of the ancestors indexes in the graph  */
  static struct GRid *l_anc=0; /* list of the ancestors in the graph          */
  static int     s_lanc = 0;   /* Size of the list of ancestors               */
  int   status = GM_S_SUCCESS; /* Returned status of the function             */

  status = GMget_int_anc(p_object,p_graph,&l_index,p_count);
  if(!(status&1)){*p_count=0; status = GM_I_NEG_RESPONSE;}

  if(pl_object && (*p_count))
    {
    /*| Have to fill the ancestor list */

    if(!(*pl_object))
      {
      /*| The list is not given by the caller */

      status = GMajust_buf(*p_count*sizeof(struct GRid),&l_anc,&s_lanc);
      gm$status()
      *pl_object = l_anc;
    }/* if(!*pl_object)*/

    p_hcode = p_graph->p_hcode;
    for(index = 0; index < *p_count; index++)
      (*pl_object)[index] = *((struct GRid *)GMh_key(p_hcode,l_index[index]));
  }/* if(pl_object)*/

exception:
  return(status);
}/* GMget_anc_ingr*/ 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       function GMreplace_grid                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMreplace_grid(p_object, p_nobject, p_graph)
  
  struct GRid     *p_object;  /* IN     Object to replace                     */
  struct GRid     *p_nobject; /* IN     New identifier of the object          */
  struct GMgraph  *p_graph;   /* IN/OUT Pointer to the graph                  */
 
  /*.GMreplace_grid*/
  {
  /*
  Description : Change an object by an other one in the graph manager structure
  Constraint  : The graph must be taken before.
  */ 
  int status=GM_W_ELMT_NOT_FOUND; /* Returned status of the function          */
  struct GMelmt *p_content; /* Element contained in the graph structure       */

  if(GMh_give_content(p_object, p_graph->p_hcode, &p_content, NULL))
    {
    status = GMh_remove(p_object,p_graph->p_hcode);
    gm$status()
    status = GMh_add(p_nobject,p_content,p_graph->p_hcode);
  }/* if */
exception:
  return(status);
}/* GMreplace_grid*/ 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       function GMcompress_list                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMcompress_list(l_object, p_nbobj)
  
  struct GRid     *l_object;  /* IN/OUT List of Objects to compress           */
  int             *p_nbobj;   /* IN/OUT Number of objects in the list         */
 
  /*.GMcompress_list*/
  {
  /*
  Description : Compress a List of objects, removing the duplicated one
  Constraint  : nove
  */ 
  int status=GM_S_SUCCESS;  /* Returned status of the function          */
  int	new_end = 0;	    /* last valid index 			*/
  int	i, j;

	for( i=0; i< *p_nbobj; i++ ){

		for( j=0; j<new_end; j++ )
			if( l_object[i].objid == l_object[j].objid &&
				l_object[i].osnum == l_object[j].osnum ) break;

		if( j==new_end ) l_object[new_end++] = l_object[i];
	}

	*p_nbobj = new_end;
	/*" new_end : %d\n", new_end */

exception:
  return(status);
}/* GMcompress_list*/ 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

