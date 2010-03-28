
class implementation ASdelseg;

#include "OMmacros.h"
#include "AS_status.h"
#define AS_DEBUG

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDplace                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace 
  (
  struct GRas *asso_lis;         /* IN/OUT Information about the associativity*/
  struct GRmd_env *md_env;      /* IN     Information about the environment  */
  IGRchar *go_cnst_lis           /* IN/OUT Information about the graphic obj  */
  )
  {
  IGRlong   status;              /* Status returned by om                     */



  /*^
  {
  IGRint i_count;
  printf("asso_lis->num_parents = %d\nparent \n",asso_lis->num_parents);
  for (i_count=0 ; i_count<asso_lis->num_parents ; i_count++)
    printf("id :%d\n ",(asso_lis->parents+i_count)->objid);
  }*/
    
  if(asso_lis->num_parents!=3)return(OM_W_ABORT);

  /*
  Just store in my instance the modification type  and control the type
  of my parents. ASmodlin.place will perform all the work.
  */
  
  ME.ASmodlin->nmodif = 1;
  ME.ASmodlin->typ_mod[0] = -1;
  ME.ASmodlin->par_mod[0] =  2;

  status = om$send
             (msg      = message ASmodlin.NDplace(asso_lis,md_env,go_cnst_lis),
              targetid = my_id,
              mode     = OM_e_wrt_message);
  as$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
}/* end method NDplace */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASdelseg;
