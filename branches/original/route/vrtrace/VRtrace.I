class implementation ASnode;

#include "GM.h"
#include "GMndg.h"
#include "AS_status.h"
#include "nddef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "ACrg_collect.h"
#include "VRsize.h"

#define AS_DEBUG

from VRGeneric
  import
  VRGetTopo;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function VRget_connect                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRget_connect(p_object, p_md_env, pl_connect, p_nb_connect)

  struct GRid *p_object;      /* IN     Object to inquire                     */
  struct GRmd_env *p_md_env;  /* IN     Pointer to the module environment     */
  struct GRid **pl_connect;   /* OUT    List of connected objects             */
  int         *p_nb_connect;  /* OUT    Number of connected objects           */
  /*
  Description : Function to get the elements connected to a pipe
  Constraint  : none
  */ 
  /*.VRget_connect*/
  {
  int           status=OM_S_SUCCESS; /* Status returned by the function             */
  long          msg;           /* return code of the function                 */
  int           nb_obj;        /* return code of the function                 */
  short         nNeiCpNum[VRMAX_CONNEX];     /* temporary because GetTopo does not accept NULL */
  int           index;         /* Index for a loop                            */
  int           index1;        /* Index for a loop                            */
  struct GRid   *l_connect;    /* List of connected objects                   */
static
  struct GRid   buffer[VRMAX_CONNEX]; /* Buffer to store the data               */
  
  if(pl_connect)
    {
    if(!(*pl_connect))
      {
      /* Use the local buffer */
      *pl_connect = buffer;
    }/* end if */

    /*| Get the Control segment */

    nb_obj = VRMAX_CONNEX;
    status = om$send
              (msg = message VRGeneric.VRGetTopo(&msg,VRMAX_CONNEX,
						&nb_obj,
						NULL,NULL,
						*pl_connect,
						nNeiCpNum, p_md_env),
  	       senderid = NULL_OBJID,
	       targetid = p_object->objid,
               targetos = p_object->osnum);
    if( ! ( status & 1 ) ) return OM_S_SUCCESS;

    l_connect = *pl_connect;

    /*| To Avoid hidden info in the list  (objid (-1)) */

    for(index = 0, index1=0; index < nb_obj; index++) 
      if(!IF_NULL_OBJID(l_connect[index].objid))
        {
        l_connect[index1] = l_connect[index];
        index1++;
      }/* end if */
    *p_nb_connect = index1;

    /*" %d.%d has %d connections :\n",p_object->objid,p_object->osnum,*p_nb_connect*/
    /*^
    {int i;
    for(i=0;i<*p_nb_connect;i++)
      printf("%d.%d, ", l_connect[i].objid,l_connect[i].osnum);
    printf("\n");
    }
    */
  }/* end if */ 

  return(status);
}/* end VRget_connect */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    INTERNAL function VRget_allow_connect                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRget_allow_connect(p_object, p_info, pl_connect, p_nb_connect)

  struct GRid *p_object;      /* IN     Object to inquire                     */
  struct VRgrinfo *p_info;      /* IN     Information for the function          */
  struct GRid **pl_connect;   /* OUT    List of connected objects             */
  int         *p_nb_connect;  /* OUT    Number of connected objects           */
  /*
  Description : Get the connections that are not in the list of nodes to avoid
  Constraint  : none
  Note        : p_info is a structure of pointers.
                - the first argument of is a hcode pointer,
                - the second one is the module environment.
  */ 
  /*.VRget_allow_connect*/
  {
  int   status = GM_S_SUCCESS; /* Status returned by the function             */
  int         index_obj;         /* Index of the found object                 */

  if(!GMh_give_content(p_object,(struct GMhcode *)p_info->p_add,NULL,&index_obj))
    {
    /*" Get the connections of %d.%d\n",p_object->objid,p_object->osnum */

    status = VRget_connect(p_object,p_info->p_md_env,pl_connect,p_nb_connect);
    }
  else
    {
    /*" %d.%d is a node to avoid\n",p_object->objid,p_object->osnum */
    *p_nb_connect = 0;
  }/* end if */

  /*" %d.%d has %d connections :\n",p_object->objid,p_object->osnum,*p_nb_connect*/
  return(status);
}/* end VRget_allow_connect */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASnode;

