
class implementation ASextseg;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
/*
   The ASextseg.place method stores in my intance the nb of parents and the
   type of the modif (extend and which extremity is to extend). it will
   control the type of the parent. the ASmodlin.place method will perform 
   the compute and creation of new graphic objects.
*/
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
  IGRlong msg;
  struct ret_struct pardef1,pardef2,pardef3;

  IGRpoint vect;
  IGRdouble d0,d1;
  IGRdouble *snap;
  IGRint change_ext;

  /*^
  {
  IGRint i;
  printf("ASextseg.place entry %d parents\n",asso_lis->num_parents);
  for(i=0 ; i<asso_lis->num_parents ; i++)
  printf(" %d ", (asso_lis->parents+i)->objid);
  printf("\n");
  }
  */

  snap   = (IGRdouble *) asso_lis->as_attr;

  if (asso_lis->num_parents != 2 && asso_lis->num_parents != 3) return(OM_W_ABORT);

  /* original line and extend point definition */

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&pardef1,md_env) ,
              targetid = asso_lis->parents->objid);
  as$status(action = RET_STATUS);

  if (!(pardef1.type & line_generic)) 
    {
    /*| point1 : invalid type*/
    return(OM_W_ABORT);
  }

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&pardef2,md_env) ,
              targetid = (asso_lis->parents+1)->objid);
  as$status(action = RET_STATUS);


  if (!(pardef2.type & point_generic)) 
    {
    /*| second point invalid type*/
    return(OM_W_ABORT);
  }

  /* Which extremity has to be changed */

  v_sub(pardef1.var.line_st.p0,snap,vect);
  d0 = v_dot(vect,vect);
  v_sub(pardef1.var.line_st.p1,snap,vect);
  d1 = v_dot(vect,vect);

  if(d1>d0) change_ext = 0;
  else      change_ext = 1;

  /* 
  Is there a trackpoint ? In this case the extremity to change is relative
  to the extend track point orientation versus line orientation
  */

  if (asso_lis->num_parents == 2) 
    {
    ME.ASmodlin->typ_mod[0] = change_ext;
    ME.ASmodlin->par_mod[0] = 1;
    }
  else
    {
     IGRdouble scal1;
     IGRvector v1, v2;

     status = om$send
                (msg   = message NDnode.NDgive_structure(&msg,&pardef3,md_env) ,
                 targetid = (asso_lis->parents+2)->objid);
     as$status(action = RET_STATUS);

    if (!(pardef3.type & point_generic)) 
      {
      /*| track point invalid type*/
      return(OM_W_ABORT);
      }
   v_sub(pardef3.var.point_st.pt, pardef2.var.point_st.pt,v1);
   v_sub(pardef1.var.line_st.p1,pardef1.var.line_st.p0,v2);
   scal1 = v_dot(v1,v2);

   if( scal1 < 0 )
     ME.ASmodlin->typ_mod[0] = 1-change_ext ;
   else
     ME.ASmodlin->typ_mod[0] = change_ext ;
   ME.ASmodlin->par_mod[0] = 2;
   
  }

  ME.ASmodlin->nmodif = 1;
  status = om$send
             (msg      = message ASmodlin.NDplace(asso_lis, md_env,go_cnst_lis),
              mode     = OM_e_wrt_message,
              targetid = my_id);
  as$status(action = RET_STATUS);
  return(1);
}/* end method NDplace */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

end implementation ASextseg;
