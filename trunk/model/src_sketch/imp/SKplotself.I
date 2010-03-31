/*
 *  Overriding GRplotyourself and GRformatele so that geometric contraints 
 *  will not plot or convert to IGDS as GR3dpoints. 
 *
 *  Created:  02/03/92 SRH
 */

class implementation SKgmhndlpt;

method GRplotyourself(IGRlong *msg;
                      struct GRmd_env *md_env;
                      IGRchar *dgn_buf;
                      IGRchar *bs_buf; 
                      IGRchar *ele_buf; 
                      IGRint *ele_size; 
                      IGRint *file_des; 
                      IGRdouble *max_overflow; 
                      struct GRid *id_info; 
                      IGRdouble *scale_factor)
{
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

method  GRformatele ( IGRlong *msg;
                      struct GRmd_env *md_env; 
		      IGRchar *dgn_buf;
		      IGRchar *bs_buf;
		      IGRchar *ele_buf;
		      IGRint *ele_size; 
		      IGRint *file_des;
		      IGRdouble *max_overflow;
		      IGRdouble *scale_factor )
{
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

end implementation SKgmhndlpt;
