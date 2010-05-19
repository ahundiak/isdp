/* $Id: par.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vdannot/dim/par.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: par.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/01/10  14:56:06  pinnacle
# Created: vdannot/dim/par.I by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

from DMsuper import set_dim_stan;

#argsused
IGRint DMsplit_senv (par_senv,
                     par_env,
                     par_loc,
		     par_misc)
		     /*(

	 struct DMsenv_param  *par_senv,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc
	)
	*/
struct DMsenv_param *par_senv;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
/*.DMsplit_senv*/
{
	IGRint status;

	if (par_env)
	{
		status =
		dm$get_dim_param(type = DM_ENV_PARAM, p_data = (char *) par_env);
		dm$status(action = RET_STATUS);

		par_env->attach_pt = par_senv->attach_pt;
		par_env->stk_spacing = par_senv->stk_spacing;
		par_env->stk_orie	= par_senv->stk_orie;
		par_env->stk_dir	= par_senv->stk_dir;

		par_env->dim_colr	= par_senv->dim_colr;
		par_env->dim_weig	= par_senv->dim_weig;
		par_env->txt_weig	= par_senv->txt_weig;
		par_env->ter_type	=
		par_env->ter_type0	= par_senv->ter_type;
		par_env->dim_layr	= par_senv->dim_layr;
		par_env->text_font	= par_senv->text_font;
		par_env->frac_font	= par_senv->frac_font;
		par_env->txt_heig	= par_senv->txt_heig;
		par_env->txt_widt	= par_senv->txt_widt;
		par_env->ter_heig_r	= par_senv->ter_heig_r;
		par_env->ter_widt_r	= par_senv->ter_widt_r;
		par_env->txt_yoff_r	= par_senv->txt_yoff_r;
		par_env->dim_stan	= par_senv->dim_stan;

		/* Kludge added for including unit in senv
		   parameter object. The unit is stored in
		   ter_disp(which is not used), in the latter
		   version a new parameter for unit must
		   created. */
		   
		par_env->pri_unit 	= 
		par_env->sec_unit 	= par_senv->ter_disp;
	}

	if (par_misc)
	{
		status =
		dm$get_dim_param(type = DM_MISC_PARAM, p_data = (char *) par_misc);
		dm$status(action = RET_STATUS);

		par_misc->std_param.dm_car_spac = par_senv->car_spac;
		par_misc->std_param.dm_lin_spac = par_senv->lin_spac;
	}

	return(OM_S_SUCCESS);
}

#argsused
IGRint DMmerge_senv (par_senv,
		     par_env,
		     par_loc,
		     par_misc
		     )
		     /*(
	 struct DMsenv_param  *par_senv,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc
	)
	*/
struct DMsenv_param *par_senv;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
/*.DMmerge_senv*/
{
	if (par_env)
	{
        par_senv->attach_pt = par_env->attach_pt;
        par_senv->stk_spacing = par_env->stk_spacing;
        par_senv->stk_orie   = par_env->stk_orie;
        par_senv->stk_dir    = par_env->stk_dir;

		par_senv->dim_colr	= par_env->dim_colr;
		par_senv->dim_weig	= par_env->dim_weig;
		par_senv->txt_weig	= par_env->txt_weig;
		par_senv->ter_type	= par_env->ter_type0;
		par_senv->dim_layr	= par_env->dim_layr;
		par_senv->text_font	= par_env->text_font;
		par_senv->frac_font	= par_env->frac_font;
		par_senv->txt_heig	= par_env->txt_heig;
		par_senv->txt_widt	= par_env->txt_widt;
		par_senv->ter_heig_r	= par_env->ter_heig_r;
		par_senv->ter_widt_r	= par_env->ter_widt_r;
		par_senv->txt_yoff_r	= par_env->txt_yoff_r;
		par_senv->dim_stan	= par_env->dim_stan;

		/* Kludge added for including unit in senv
		   parameter object. The unit is stored in
		   ter_disp(which is not used), in the latter
		   version a new parameter for unit must
		   created. */
		   
		
		par_senv->ter_disp 	= par_env->pri_unit;
	}

	if (par_misc)
	{
		par_senv->car_spac = par_misc->std_param.dm_car_spac;
		par_senv->lin_spac = par_misc->std_param.dm_lin_spac;
	}

	return(OM_S_SUCCESS);
}

IGRint DMdefault_dim_stan ()
/*(
	 void
	)
	*/
/*.DMdefault_dim_stan*/
{
	IGRint status, dim_stan;
	IGRlong long_rc;
	char buffer[96];
	IGRshort flag, num_defaults;
	struct GRmd_env md_env;

	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);

	flag = 0;
        status = GRget_default_units( &long_rc, "UOM_DISTANCE",
                                      md_env.md_id.osnum, &flag,
                                      &num_defaults,
                                      (GRIOalias_name *)buffer );
	dm$status(action = RET_VALUE, value = DIM_STAN_ANS);

	switch (buffer[0])
	{
		case 'k':	/* k -> km(s) or kilometer(s) */

		dim_stan = DIM_STAN_ISO;
		break;

		case 'c':	/* c -> cn .. or chain(s) */
				/* !ch -> cm or centimeter(s) */
		if (buffer[1] != 'h')
		{
			dim_stan = DIM_STAN_ISO;
			break;
		}

		case 'm':

		if (buffer[1] == 'm' ||	/* .. alias = mm		*/
		    buffer[1] == 'e' ||	/* .. alias = me(ter(s))	*/
		    buffer[1] == '0' ||	/* .. alias = m			*/
		    buffer[3] == 'l'  ) /* .. alias = m(il)l(imeter(s))	*/
		{
			dim_stan = DIM_STAN_ISO;
			break;
		}

		default:

		dim_stan = DIM_STAN_ANS;
		break;
	}

	return(dim_stan);
}

IGRint DMtxt_conv_fact (flag,
			conv_factor,
			units)
			/*(
	 IGRboolean  flag,
	 IGRdouble  *conv_factor,
	 IGRchar  units
	)
	*/
IGRboolean flag;
IGRdouble *conv_factor;
IGRchar units;
/*.DMconv_txt_units*/
{
	extern struct DMglobal DM_global;

	if (flag == CONV_TO_FILE_UNITS)
		*conv_factor = 1/DM_global.conv_factor[units];
	else	*conv_factor = DM_global.conv_factor[units];
	return(TRUE);
}

int DMset_dim_stan (msg,stan)
/*(
	 int  *msg,
	 int  stan
	)
*/
int *msg;
int stan;
/*.DMset_dim_stan*/
{
	int status;
	struct GRid dim_super;

	*msg = DIM_S_SUCCESS;

	status =
	dm$get_cur_super(p_grid = &dim_super);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsuper.set_dim_stan(msg, stan),
		targetid = dim_super.objid,
		targetos = dim_super.osnum,
		senderid = NULL_OBJID);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMget_param_info (type,size,index)
/*(
	 IGRint  type,
	 IGRint  *size,
	 IGRint  *index
	)
*/
IGRint type;
IGRint *size;
IGRint *index;
/*.DMget_param_info*/
{
	switch(type)
	{
		case DM_ENV_PARAM:

		if (index) *index = DIM_ROOT_ENV;
		if (size)  *size = sizeof(struct DMenv_param);
		break;

		case DM_LOC_PARAM:

		if (index) *index = DIM_ROOT_LOC;
		if (size)  *size = sizeof(struct DMloc_param);
		break;

		case DM_MISC_PARAM:

		if (size)  *size = sizeof(struct DMmisc_param);
		if (index) *index = -1;
		break;

		case DM_SENV_PARAM:

		if (size)  *size = sizeof(struct DMsenv_param);
		if (index) *index = DIM_ROOT_SENV;
		break;

		case DM_GLOB_PARAM:

		if (size)  *size = sizeof(struct DMglobal_param);
		if (index) *index = -1;
		break;

		case DM_WELD_PARAM:

		if (size)  *size = sizeof(struct DMweld_param);
		if (index) *index = -1;
		break;

		default:

		printf("get_param_info: ERROR type=%d\n", type);
		return(FALSE);
	}

	return(TRUE);
}

IGRint DMclean_data (type,data)
/*(
	 IGRint  type,
	 char  *data
	)
	*/
IGRint type;
char *data;
{
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMmisc_param *par_misc;
	struct DMsenv_param *par_senv;
	struct DMweld_param *par_weld;

	switch (type)
	{
		case DM_ENV_PARAM:
		par_env = (struct DMenv_param *)data;
		clear_dbl(par_env->future_double, ENV_FUTURE_DBL_SIZE);
		clear_chr(par_env->future_char, ENV_FUTURE_CHR_SIZE);
		break;

		case DM_LOC_PARAM:
		par_loc = (struct DMloc_param *)data;
		clear_dbl(par_loc->future_double, LOC_FUTURE_DBL_SIZE);
		clear_chr(par_loc->future_char, LOC_FUTURE_CHR_SIZE);
		break;

		case DM_MISC_PARAM:
		par_misc = (struct DMmisc_param *)data;
		clear_dbl(par_misc->future_double, MSC_FUTURE_DBL_SIZE);
		clear_dbl(par_misc->std_param.future_double, GAP_FUTURE_DBL_SIZE);
		clear_chr(par_misc->future_char, MSC_FUTURE_CHR_SIZE);
		break;

		case DM_SENV_PARAM:
		par_senv = (struct DMsenv_param *)data;
		clear_dbl(par_senv->future_double, SENV_FUTURE_DBL_SIZE);
		clear_chr(par_senv->future_char, SENV_FUTURE_CHR_SIZE);
		break;

		case DM_WELD_PARAM:
		par_weld = (struct DMweld_param *)data;
		clear_chr(par_weld->future_char, WELD_FUTURE_CHR_SIZE);
		break;

		case DM_GLOB_PARAM:
		break;

		default:
		printf("ERROR: Invalid param type %d\n", type);
		return(OM_E_ABORT);
	}

	return(TRUE);
}

end implementation DMroot;


