class implementation NDnode;

#include <sys/types.h>
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "GMmacros.h"
#include "nddef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "GMerrordef.h"
#include "igrtypedef.h"

/*  
  ND Functions to interface the graph manager
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           Function NDancestor                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDancestor(p_object, p_info, p_lanc, p_nb_anc)

  struct GRid *p_object;      /* IN     Object to inquire                     */
  char        *p_info;        /* IN     Pointer to additional info (unused)   */
  struct GRid **p_lanc;       /* OUT    List of ancestors                     */
  int         *p_nb_anc;      /* OUT    Number of objects returned            */
  /*
  Description: This function returns the list of ancestors elements of an
               object. It is used by the graph manager to traverse the dependent
               graph structure.
  Constraints: none.
  */
  /*.NDancestor*/
  {
  long           status;      /* Status returned by the functions             */
  int real_nb;
 
  status = om$send
               (msg = message NDnode.NDget_virtual_objects(ND_ROOT|ND_IN_BUF,
                              0,0,p_lanc,0,OM_K_MAXINT,&real_nb,p_nb_anc),
	        senderid = NULL_OBJID,
  	        targetid = p_object->objid,
	        targetos = p_object->osnum );
  return(status);
}/* end NDancestor*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          Function NDsuccessor                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDsuccessor(p_object, p_info, p_lsuc, p_nb_suc)

  struct GRid *p_object;      /* IN     Object to inquire                     */
  char        *p_info;        /* IN     Pointer to additional info (unused)   */
  struct GRid **p_lsuc;       /* OUT    List of successors                    */
  int         *p_nb_suc;      /* OUT    Number of objects returned            */
  /*
  Description: This function returns the list of elements depending upon an
               object. It is used by the graph manager to traverse the dependent
               graph structure.
  Constraints: none.
  */
  /*.NDsuccessor*/
  {
  long           status;      /* Status returned by the functions             */
  int real_nb;
 
  status = om$send
              (msg = message NDnode.NDget_virtual_objects(ND_CHILDREN|ND_IN_BUF,
                              0,0,p_lsuc,0,OM_K_MAXINT,&real_nb,p_nb_suc),
	        senderid = NULL_OBJID,
  	        targetid = p_object->objid,
	        targetos = p_object->osnum );
  return(status);
}/* end NDsuccessor*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          INTERNAL function NDacrej                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDacrej(p_object, int_attr, p_info)
  /*
  Description : select an object rejecting an internal attribute and
                accepting an other one.
  Constraint  : none
  */ 

  struct GRid      *p_object; /* IN     Pointer to the object to select       */
  short            int_attr;  /* IN     Internal attribute                    */
  short            p_info[];  /* IN     User information for the function     */
                              /* p_info[0]= acc_type, p_info[1]= rej_type     */
  {
  return((int_attr & p_info[0])&&(!(int_attr & p_info[1])));
}/* end NDacrej */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Function NDgm_send                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDgm_send(p_object, msg)
  /*
  Description: This function is written to send messages with the GMgraph
  Constraints: none.
  */
  struct GRid     *p_object;  /* IN     Target object                         */
  OM_S_MESSAGE *msg;          /* IN     Message to broadcast                  */
  /*.NDgm_send*/
  {
  return om$send(msg      = msg,
                 senderid = NULL_OBJID,
                 targetid = p_object->objid,
                 targetos = p_object->osnum);
}/* end NDgm_send*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Function NDget_comp_state                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDget_comp_state(l_object, nb_object, l_attr, p_graph)
  /*
  Description: This function return the NDnode status stored in the graph
               structure.
  Constraints: All the object must have been broadcasted before calling their
               state.
  */
  struct GRid     l_object[]; /* IN     List of objects to modify             */
  int             nb_object;  /* IN     Number of objects to modify           */
  int             l_attr[];   /* IN     List of corresponding status          */
  struct GMgraph  *p_graph;   /* IN     graph				      */
  /*.NDget_comp_state*/
{
  long           status;      /* Status returned by the functions             */
  int            ind;         /* Index for a loop                             */

  /*| Get the internal state */

  gm$get_attr ( nb_object = nb_object,
      l_object = l_object, l_int_attr = l_attr, p_graph = p_graph);
   
  /*| Convert it to the specific ND format */
  for(ind = 0; ind < nb_object; ind++)
  {
    l_attr[ind] = (l_attr[ind]&GM_BR_INFO) >> 12 ;
    if (l_attr[ind] == (MSSUCC&0xf)
       || !l_attr[ind]) l_attr[ind] = MSSUCC;
  }

exception:
  return OM_S_SUCCESS;
}/* end NDget_comp_state*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Function NDset_comp_state                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDset_comp_state(l_object, nb_object, l_attr, p_graph)
  /*
  Description: This function Set the list of ND return codes in the graph
               structure.
  Constraints: All the object must have been broadcasted before calling their
               state.
  */
  
  struct GRid     l_object[]; /* IN     List of objects to modify             */
  int             nb_object;  /* IN     Number of objects to modify           */
  int             l_attr[];   /* IN     List of corresponding status          */
  struct GMgraph  *p_graph;   /* IN     Graph */
  /*.NDset_comp_state*/
  {
  IGRushort         state;       /* return state of a parent                     */
  int            ind;         /* Index for a loop                             */
  struct GMelmt  *p_content;  /* Content of a temporary graph element        */
  int status=GM_S_SUCCESS;    /* Returned status of the function              */

  for(ind = 0; ind < nb_object; ind++)
   {
    state = l_attr[ind];
    state = (state <<12) & GM_BR_INFO;

    if(GMh_give_content(&(l_object[ind]), p_graph->p_hcode, &p_content, NULL))
      p_content->int_attr = (p_content->int_attr & ~GM_BR_INFO)  |state;
    else status=GM_W_ELMT_NOT_FOUND;
   }

  return (status);
}/* end NDset_comp_state*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function NDcvt_to_graph                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDcvt_to_graph(l_object, l_type, nb_object, p_graph)

  struct GRid    l_object[]; /* IN     List of objects of this graph          */
  int            l_type[];   /* IN     List of types for the objects          */
  int            nb_object;  /* IN     number of objects in this graph        */
  struct GMgraph *p_graph;   /* OUT    Identifier of the resultant graph      */

  /*
  Description : Build a structure GMgraph from a list of objects and their
                corresponding types.
  Constraint  : The graph must be initialized by the "GMinit_graph" function
  Restrictions: The structure is not completly initialized:
                - The parent list is not filled,
                
  */ 
  /*.NDcvt_to_graph */
  {
  struct GMhcode    *p_hcode; /* Pointer to the hcode table for the graph     */
  int               status;   /* Status returned by functions                 */
  IGRushort            index;    /* Index for a loop                             */
  IGRushort            size_lord;/* Size of the ordered list                     */
  struct GMelmt    content;   /* Content of a temporary graph element         */
  
  GMclear_graph(p_graph);

  p_hcode   = p_graph->p_hcode;
  size_lord = p_hcode->nb_max_elmt;
  p_graph->f_get_anc = NDancestor;
  p_graph->f_get_suc = NDsuccessor;

  /*----------------- */
  /*| Fill the hcode  */
  /*----------------- */
  status = OM_S_SUCCESS;
  for(index=0; (int)index < nb_object; index++)
    {
    /*" Add %d.%d in the graph\n",l_object[index].objid,l_object[index].osnum*/

    content.int_attr  = l_type[index];
    content.state     = 0;
    content.ind_parent= 0;
    content.nb_parent = 0;
    status = GMh_add(&l_object[index],&content,p_hcode);

    if(l_type[index] & GM_ROOT) (p_graph->nb_root)++;
    if(l_type[index] & GM_TIP)  (p_graph->nb_tip)++;
    gm$status();
  }/* end for */

  p_graph->nb_elmt = p_hcode->cur_elmt;

  /*------------------------*/  
  /*| Fill the ordered list */
  /*------------------------*/ 
  
  /*" there are %d elements in the graph\n",p_hcode->cur_elmt*/
  
  if((p_graph->l_ord_elmt)&&(size_lord < p_hcode->cur_elmt))
    {free(p_graph->l_ord_elmt); p_graph->l_ord_elmt = NULL;}
 
  if(!(p_graph->l_ord_elmt))
    {
    p_graph->l_ord_elmt=(IGRushort *)malloc((p_hcode->nb_max_elmt)*sizeof(IGRushort));
    if(!p_graph->l_ord_elmt){status=GM_E_NODYNMEM;gm$status();}
  }/* end if(size_lord)*/

  for(index = 0; index < p_hcode->cur_elmt;index++)
    {
    p_graph->l_ord_elmt[index]=index;
  }/* end for(index)*/

exception:
  return(status);
}/* end NDcvt_to_graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation NDnode;

