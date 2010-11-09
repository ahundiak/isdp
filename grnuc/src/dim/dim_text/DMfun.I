class implementation DMtext;

#define AS_DEBUG 1

%safe
#include "exfi.h"
#include "math.h"
%endsafe

extern struct DMglobal DM_global;

#define ESC	27
#include "bsvalues.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dimglobal.h"
/*#include "DMtextp.h"*/


IGRint DMcompute_angular_text ( osnum,
                                dim_text,
                                dimn_val,
                                p_env,
				p_loc,
				p_misc,
				p_std)
	 OMuword  osnum;
	 struct DMtxt_str  *dim_text;
	 IGRdouble  dimn_val;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
	 struct DMmisc_param  *p_misc;
	 struct DMstd_param  *p_std;
/*.DMcompute_angular_text*/
{
	int dim_field_no, tol_field_no;
	int pm_flag;

	tol_field_no = FNUM_SINGLE_START + DM_DIM_OFFSET;

	dm$return_field_no( dim_type = FNUM_SINGLE_START,
			    field_no = &dim_field_no);  
			    

	switch(p_loc->tole_mode)
	{
	case TOLE_MODE_OFF:
	case TOLE_MODE_BOX:
	case TOLE_MODE_REF:
		DMadd_angular_field(osnum, dim_text, dim_field_no, dimn_val,
				      p_env, p_loc, p_misc);
			  break;
	case TOLE_MODE_UP_LOW:
		DMadd_angular_field(osnum, dim_text, dim_field_no, dimn_val,
				      p_env, p_loc, p_misc);

		DMget_plus_minus_flag(p_loc,&pm_flag,PRIMARY_UNIT);
		if( pm_flag){
			tol_field_no += DM_TOL_OFFSET;
			DMcompute_tol_middle(osnum, dim_text, tol_field_no,
					     p_std, p_env, p_loc, p_misc,
					     PRIMARY_UNIT, pm_flag);
		}
		else 	DMcompute_tol_up_low(dim_text, tol_field_no,
					p_std, p_env, p_loc,
					p_misc,PRIMARY_UNIT);
	
			break;
	case TOLE_MODE_MIDDLE:
			tol_field_no += DM_TOL_OFFSET;
		DMadd_angular_field(osnum, dim_text, dim_field_no, dimn_val,
				      p_env, p_loc, p_misc);

			DMcompute_tol_middle(osnum, dim_text, tol_field_no,
					     p_std, p_env, p_loc, p_misc,
					     PRIMARY_UNIT, FALSE);
		break;
	case TOLE_MODE_LIMITS:
			tol_field_no += 2* DM_TOL_OFFSET;
		DMcompute_ang_limits(osnum, dim_text,dimn_val,tol_field_no,
					p_std, p_env, p_loc, p_misc);
		break;
	default:
		printf(" Illegal tolerance mode");
		return(TRUE);
	}
	return(TRUE);
}

IGRint DMcompute_dim_text (osnum,
			   dim_text,
			   dim_type,
			   dimn_val,
			   p_env,
			   p_loc,
			   p_misc,
			   p_std,
			   mode)
	 OMuword  osnum;
	 struct DMtxt_str  *dim_text;
	 int  dim_type;
	 IGRdouble  dimn_val;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
	 struct DMmisc_param  *p_misc;
	 struct DMstd_param  *p_std;
	 int  mode;
/*.DMcompute_dim_text*/
{
	IGRint dim_field_no, tol_field_no, pm_flag;
	
	tol_field_no = dim_type + DM_DIM_OFFSET;

	dm$return_field_no( dim_type = dim_type, field_no = &dim_field_no);
	 
	if( p_loc->tole_mode == TOLE_MODE_OFF ||
	    p_loc->tole_mode == TOLE_MODE_BOX)
	{
        	DMadd_dimension_field(dim_text, dim_field_no, dimn_val,
				      p_env, p_loc, p_misc, mode);
	}
	else if(p_loc->tole_mode == TOLE_MODE_UP_LOW)
	{
		DMadd_dimension_field(dim_text, dim_field_no, dimn_val,
				      p_env, p_loc, p_misc, mode);

		DMget_plus_minus_flag(p_loc,&pm_flag,mode);
		if( pm_flag){
			tol_field_no += DM_TOL_OFFSET;
			DMcompute_tol_middle(osnum, dim_text, tol_field_no,
					     p_std, p_env, p_loc, p_misc,
					     mode, pm_flag);
		}
		else 		 
		   DMcompute_tol_up_low(dim_text, tol_field_no,
					p_std, p_env, p_loc,
					p_misc, mode);
		}
	else if( p_loc->tole_mode == TOLE_MODE_MIDDLE){
				
			DMadd_dimension_field(	dim_text, dim_field_no,
				      		dimn_val, p_env, p_loc,
						p_misc, mode);
	
			tol_field_no += DM_TOL_OFFSET;
			DMcompute_tol_middle(osnum, dim_text, tol_field_no,
					     p_std, p_env, p_loc, p_misc,
					     mode, FALSE);
	}
	else if(p_loc->tole_mode == TOLE_MODE_LIMITS)
	{
		tol_field_no += DM_TOL_OFFSET+ DM_TOL_OFFSET;

		DMcompute_tol_limits(dim_text, dimn_val, tol_field_no,
				     p_std, p_env, p_loc, p_misc,
				     mode);
	}
	else if (p_loc->tole_mode == TOLE_MODE_REF)
	{
		DMadd_dimension_field(dim_text,dim_field_no,
				      dimn_val,p_env,p_loc,
				      p_misc,mode);
	}
	else   printf("Illegal tolerance mode\n");
	
	return(TRUE);
}

#argsused
IGRint DMcompute_tol_up_low (dim_text,
			     field_no,
			     std_arr,
			     p_env,
			     p_loc,
			     p_misc,
			     type)
	 struct DMtxt_str  *dim_text;
	 int  field_no;
	 struct DMstd_param  *std_arr;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
	 struct DMmisc_param  *p_misc;
	 int  type;
/*.DMcompute_tol_up_low*/
{	
	IGRuchar *tol_value;
	double tol_size;
	double descent_r;
	int text_weight,dim_field_no;
	int msg;
	struct vfont_entry font_info;

	tol_size = p_env ->tol_size_r;
	text_weight = p_env->txt_weig;

        font$get_info(msg = &msg,
            font_num = &p_env->text_font,
            font_info = &font_info);

	descent_r = font_info.descent/ font_info.bodysize;

	/* the descent should be applied on the tol height text   */

	descent_r = descent_r* tol_size;

	
	if(p_env->dual_mode == DUAL_MODE_OFF)
		dim_field_no = FNUM_SINGLE_START+2;
	else if( type == PRIMARY_UNIT)
		dim_field_no = FNUM_DUAL_START +4;
	else    dim_field_no = FNUM_DUAL_MIDDLE +2;
	
	if(p_env->dim_stan == DIM_STAN_ANS)
	{
		DMtol_up_low_start_ansi(dim_text,dim_field_no,
				   field_no,std_arr,tol_size,
				   p_env->tol_weig, descent_r);
	}
	else
	{
		DMtol_up_low_start_iso(dim_text,dim_field_no,
				   field_no,std_arr,tol_size,
				   p_env->tol_weig, descent_r);
	}
		
	if( type == PRIMARY_UNIT)
		tol_value = p_loc->primary.tole_up;
	else	
		tol_value = p_loc->secondary.tole_up;

	DMadd_char_str(dim_text,(IGRuchar *) tol_value);

	if(p_env->dim_stan == DIM_STAN_ANS)
	{
		DMtol_up_low_center_ansi(dim_text,dim_field_no,
				    field_no+2,std_arr,
				    tol_size, descent_r);
	}
	else
	{
		DMtol_up_low_center_iso(dim_text,dim_field_no,
				    field_no+2,std_arr,
				    tol_size, descent_r);
	}

	if( type == PRIMARY_UNIT)
		tol_value = p_loc->primary.tole_low;
	else	
		tol_value = p_loc->secondary.tole_low;

	DMadd_char_str(dim_text,(IGRuchar *) tol_value);		
	if(p_env->dim_stan == DIM_STAN_ANS)
		DMtol_up_low_end_ansi(dim_text,field_no +4,std_arr,tol_size,text_weight,descent_r);
	else
		DMtol_up_low_end_iso(dim_text,field_no +4,std_arr,tol_size,text_weight,descent_r);

	return(TRUE);
}

IGRint DMcompute_tol_middle (osnum,
			     dim_text,
			     field_num,
			     std_arr,
			     p_env,
			     p_loc,
			     p_misc,
			     type,
			     pm_flag)
	 OMuword  osnum;
	 struct DMtxt_str  *dim_text;
	 int  field_num;
	 struct DMstd_param  *std_arr;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
	 struct DMmisc_param  *p_misc;
	 int  type;
	 int  pm_flag;
/*.DMcompute_tol_middle*/
{
	double tol_size;
	int dim_field_no;
	int text_weight, msg;
	IGRuchar *tol_value;
	struct vfont_entry font_info;
	struct DMsymbol_info *p_sym;

	tol_size = p_env ->tol_size_r;
	text_weight = p_env->txt_weig;

        font$get_info(msg = &msg,
            font_num = &p_env->text_font,
            font_info = &font_info);

	if(p_env->dual_mode == DUAL_MODE_OFF)
		dim_field_no = FNUM_SINGLE_START+2;
	else if( type == PRIMARY_UNIT)
		dim_field_no = FNUM_DUAL_START + 4 ;
	else    dim_field_no = FNUM_DUAL_MIDDLE +2 ;
	
	DMtol_middle_start(dim_text,field_num,dim_field_no,std_arr,
				tol_size, p_env->tol_weig);

	if( type == PRIMARY_UNIT)
		tol_value = (IGRuchar *)p_misc->pri_tole_sym;
	else 
		tol_value = (IGRuchar *)p_misc->sec_tole_sym;

	if( pm_flag)
	{
		if(type == PRIMARY_UNIT)
			tol_value = p_loc->primary.tole_up;
		else
			tol_value = p_loc->secondary.tole_up;

		p_sym = &DM_global.symbol_info[p_env->dim_stan][SYM_TYPE_PLUS_MINUS];
		DMadd_symbol_text(osnum,dim_text, p_sym,p_env->text_font);
		tol_value++;  /*  the first -/+ char should be striped  */
	}
	DMadd_char_str(dim_text,(IGRuchar *) tol_value);

	/* TR#20563, tolerance value fieldnumber is already field_num+1 so
	   closing escape sequences should have field_num+2. Since we 
	   increment internally the field number this field number is set
	   to field_num+1 
	*/

	DMtol_middle_end(dim_text, field_num+1, tol_size, text_weight);

	return(TRUE);
}

IGRint DMcompute_tol_limits (dim_text,
			     dimn_val,
			     tol_field_no,
			     p_std,
			     p_env,
			     p_loc,
			     p_misc,
			     type)
	 struct DMtxt_str  *dim_text;
	 IGRdouble  dimn_val;
	 int  tol_field_no;
	 struct DMstd_param  *p_std;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
	 struct DMmisc_param  *p_misc;
	 int  type;
/*.DMcompute_tol_limits*/
{
	int 	numeric[2], index; 
	double  tol_val[2],result_val[2];
	char 	*dim_override;
	int ref_field;
	char    mea_unit;
	struct DMloc_param np_loc;
	struct  measure_unit *unit_type,*unit;
	IGRuchar 	*lab_str,*sub_lab_str;


	DMtol_limit_start(dim_text,tol_field_no,p_std);
	dim_override = p_misc->dim_override;

	if( type == PRIMARY_UNIT){
		lab_str = p_loc->primary.label;
		sub_lab_str = p_loc->primary.sub_label;
		mea_unit = p_env->pri_unit;
		unit_type = &p_loc->primary;
	}
	else {
		lab_str = p_loc->secondary.label;
		sub_lab_str = p_loc->secondary.sub_label;
		mea_unit = p_env->sec_unit;
		unit_type = &p_loc->secondary;
	}

	numeric[0]= sscanf( (char *)unit_type->tole_up,"%lf",&tol_val[0]);
	numeric[1]= sscanf( (char *)unit_type->tole_low,"%lf",&tol_val[1]);
	if(numeric[0] > 0 && numeric[1] >0 )
	{
		result_val[0] = dimn_val + tol_val[0];
		result_val[1] = dimn_val + tol_val[1];
		np_loc = *p_loc;
		unit = 
		(type == PRIMARY_UNIT ? &np_loc.primary : &np_loc.secondary);
		DMcheck_limits_accuracy(result_val[0],result_val[1],unit);
	}

	for( index = 0; index<2; index++)
	{
		if(p_misc->mod_comp == MOD_COMP_STATIC)
			DMadd_char_str(dim_text,(IGRuchar *) p_misc->dim_override);
		else if( numeric[index]<= 0)
			DMadd_char_str(dim_text,(IGRuchar *) "?????");
		else{	/*  mod comp dynamic */
			DMcompute_dim_string(dim_text,&np_loc,p_env,
					     result_val[index], p_misc,type);
		}
		if(!index)
		{	
			/* note - change the macro  */
			ref_field = tol_field_no + 1;

			tol_field_no = tol_field_no+DM_TOL_OFFSET;
			DMtol_limit_center(dim_text,tol_field_no,
					   ref_field,p_std);
		}
	}

	DMtol_end(dim_text);
	return(TRUE);
}

IGRint DMcompute_ang_limits (osnum,
			     dim_text,
			     dimn_val,
			     tol_field_no,
			     p_std,
			     p_env,
			     p_loc,
			     p_misc)
	 OMuword  osnum;
	 struct DMtxt_str  *dim_text;
	 IGRdouble  dimn_val;
	 int  tol_field_no;
	 struct DMstd_param  *p_std;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
	 struct DMmisc_param  *p_misc ;
/*.DMcompute_ang_limits*/
{
	double tole_val[2];
	int numeric[2];
	int index, orig_end;
	double result_val[2],sca_factor;
	struct measure_unit unit;

	DMtol_limit_start(dim_text,tol_field_no,p_std);

	unit = p_loc->primary;
	unit.decacc = p_loc->angular.decacc;
	unit.fraacc = p_loc->angular.fraacc;

	sca_factor = (p_env->ang_unit == ANG_UNIT_RAD) ? 1:M_PI/180;

	numeric[0] = sscanf( (char *)unit.tole_up,"%lf",&tole_val[0]);
	numeric[1] = sscanf( (char *)unit.tole_low,"%lf",&tole_val[1]);

	if(numeric[0] >0 && numeric[1] >0)
	{
		result_val[0]= dimn_val + tole_val[0] * sca_factor;
		result_val[1]= dimn_val + tole_val[1] * sca_factor;
		DMcheck_limits_accuracy(result_val[0]/sca_factor,
					result_val[1]/sca_factor,&unit);
	}
	

	for( index = 0; index<2; index++)
	{
		if( p_misc->mod_comp == MOD_COMP_STATIC)
			DMadd_char_str(dim_text,(IGRuchar *) p_misc->dim_override);
		else if( numeric[index] <= 0)
			DMadd_char_str(dim_text,(IGRuchar *) "?????");
		else
			DMadd_angular_text(osnum, dim_text,&unit,
					   result_val[index],p_loc,p_env);
		if( !index)
		{
			orig_end = tol_field_no + 1;
			tol_field_no = tol_field_no+DM_TOL_OFFSET;
			DMtol_limit_center(dim_text,tol_field_no,
					   orig_end,p_std);
		}
	}
	DMtol_end(dim_text);
	return(TRUE);
}

IGRint DMadd_angular_text (osnum,
			   dim_text,
			   unit_type,
			   dimn_val,
			   p_loc,
			   p_env)
	 OMuword  osnum;
	 struct DMtxt_str  *dim_text;
	 struct measure_unit  *unit_type;
	 IGRdouble  dimn_val;
	 struct DMloc_param  *p_loc;
	 struct DMenv_param  *p_env;
/*.DMadd_angular_text*/
{
	int degree,minute,second;
	double fract;
	int acc_fact;
	char dim_str[50],ang_str[50];

	/*"ang unit:%d\n",p_env->ang_unit*/
	/*"acc_fact:%d\n",p_loc->angular.decacc*/
	/*"dimension value:%lf\n",dimn_val*/

	ang_str[0] = '\0';
	switch( p_env->ang_unit)
	{
	case ANG_UNIT_DEG_MIN_SEC:
		acc_fact = (p_loc->angular.decacc == DECI_ACC1 ? 1:10);
		dimn_val = dimn_val * 180.0 / M_PI;
		degree = (int)dimn_val;
		fract  = (dimn_val - (int)dimn_val ) * 60 ;
		minute = (int)(fract);
		second = (int)((fract - (int)fract) * 60);
		/*"deg:%ld\tmin:%ld\tsec:%ld\n",degree,minute,second*/
		if( p_loc->angular.ang_roff_unit == ANG_ROFF_UNIT_DEG)
		{
			degree = (((int)(dimn_val + 0.5*acc_fact))/acc_fact) * acc_fact;
			minute = 0;
			second = 0;
		}
		else if( p_loc->angular.ang_roff_unit == ANG_ROFF_UNIT_MIN)
		{
			minute = (((int)(fract + 0.5*acc_fact))/acc_fact) * acc_fact;
			sprintf(ang_str," %d\'",minute);
		}
		else{
			second = (((int)(second + 0.5*acc_fact))/acc_fact) * acc_fact;
			sprintf(ang_str," %d\' %d\"",minute,second);
		}
		sprintf(dim_str,"%d",degree);
		DMadd_char_str(dim_text,(IGRuchar *) dim_str);
	        DMadd_symbol_text(
			osnum,
			dim_text,
			&DM_global.symbol_info[p_env->dim_stan][SYM_TYPE_ANGULAR],
			p_env->text_font);
		DMadd_char_str(dim_text,(IGRuchar *) ang_str);
			break;

	case ANG_UNIT_DEG: dimn_val = dimn_val * 180.0 / M_PI;

		DMadd_format_string(FALSE, dim_text, FALSE, unit_type,
				    dimn_val,p_env,p_loc);

		DMadd_symbol_text(
			osnum,
			dim_text,
			&DM_global.symbol_info[p_env->dim_stan][SYM_TYPE_ANGULAR],
			p_env->text_font);
		break;
	case ANG_UNIT_RAD:	/*|active units are in radians */
		DMadd_format_string(FALSE, dim_text, FALSE, unit_type,
				    dimn_val,p_env,p_loc);
	}
	return(TRUE);
}

IGRint DMadd_char_str (dim_text,
		       tol_val)
	 struct DMtxt_str  *dim_text;
	 IGRuchar  *tol_val;
/*.DMadd_char_str*/
{
	int length;

	length =strlen( tol_val);
	memcpy(&dim_text->str[dim_text->length],tol_val,length);
	dim_text->length +=length;
	return(TRUE);
}

#argsused
IGRint DMcompute_dim_string (dim_text,
			     p_loc,
			     p_env,
			     dim_val,
			     p_misc,
			     mode)
	 struct DMtxt_str  *dim_text;
	 struct DMloc_param  *p_loc;
	 struct DMenv_param  *p_env;
	 IGRdouble  dim_val;
	 struct DMmisc_param  *p_misc;
	 int  mode;
/*.DMcompute_dim_string*/
{
	double xval=0.0;
	int dim_field_no;
	char mea_unit;
	struct measure_unit *unit_type;
	int feet;
	char ft_str[30];
	IGRuchar *label_str,*sub_label_str;
	
	dm$return_field_no( unit_mode = PRIMARY_UNIT,
				tole_mode = p_loc->tole_mode,
				dim_mode = p_env->dual_mode,
				field_no = &dim_field_no);

	/*"dim_field_no:%d\n",dim_field_no*/

	if( mode == PRIMARY_UNIT){
		label_str = p_loc->primary.label;
		unit_type = &p_loc->primary;
		mea_unit = p_env->pri_unit;
		sub_label_str= p_loc->primary.sub_label;
	}
	else {
		label_str = p_loc->secondary.label;
		unit_type = &p_loc->secondary;
		mea_unit = p_env->sec_unit;
		sub_label_str= p_loc->secondary.sub_label;
	}

	/*"label:%s\tsub label:%s\n",label_str,sub_label_str*/

	if(mea_unit == MEA_UNIT_FEET_INCHES)
	{
		/*|feet inches mode */

		if (p_loc->deci_frac == DECIMAL_MODE)
		{
			if (unit_type->decacc !=  DECI_ACC10)
			xval = dim_val +
				0.5 * pow(10.0, -(double)unit_type->decacc);
		}
		else
		{
			xval = dim_val + 1.0 / (1 << (unit_type->fraacc + 1));
		}

		if (xval >= (double)p_loc->max_sub)
		{  
			/*|feet mode */
			feet  = ((int) xval)/12;
			dim_val = dim_val - feet *12;
			if (dim_val < 0.0)
				dim_val = 0.0;

			if(feet)
			{
			   sprintf(ft_str,"%d",feet);
			   DMadd_char_str(dim_text,(IGRuchar *) ft_str);

			   if(strlen(label_str))  /*note- modify this */
			      DMadd_label_field(dim_text,dim_field_no + 1,
						(char *) label_str,LABEL_FIELD);
			}
		}
		else	feet = 0;

		DMadd_format_string(feet, dim_text, FALSE, unit_type, dim_val,
				    p_env,p_loc);
		if(strlen(sub_label_str))
			DMadd_label_field(dim_text,dim_field_no + 2,
					(char *) sub_label_str,LABEL_SUB_FIELD);
	}
	else{
		int metric;

		metric = ((mea_unit == MEA_UNIT_MM) || (mea_unit == MEA_UNIT_METERS));
		DMadd_format_string(FALSE, dim_text, metric, unit_type, dim_val,
				    p_env,p_loc);
		if(strlen(label_str))
	        	DMadd_label_field(dim_text,dim_field_no + 1,
		 			(char *) label_str,LABEL_SUB_FIELD);
	}
	return(TRUE);
}

IGRint DMadd_format_string (ftflag,
			    dim_text,
			    metric,
			    unit_type,
			    dim_val,
			    p_env,
			    p_loc)
	 IGRint  ftflag;
	 struct DMtxt_str  *dim_text;
	 int  metric;
	 struct measure_unit  *unit_type;
	 IGRdouble  dim_val;
	 struct DMenv_param  *p_env;
	 struct DMloc_param  *p_loc;
/*.DMadd_format_string*/
{

	int int_val,index;
	int accuracy, round_flag;
	struct DMsymbol_info frac_struct;
	char tmp_string[30];
	

	if ((p_loc->deci_frac == DECIMAL_MODE) || metric)
	{
		DMdeci_dimension(dim_val, unit_type, dim_text, p_loc);
	}
	else
	{  		
		/*|fraction mode*/
		index = 0;
		accuracy = (1 << unit_type->fraacc);

		DMget_frac_index( dim_val, &index, accuracy, &round_flag);
	
		int_val = (int)dim_val;
		if (round_flag)  
			int_val += 1;
		if(int_val || ftflag)
		{
			sprintf(tmp_string,"%ld",int_val);
			DMadd_char_str(dim_text,(IGRuchar *) tmp_string);
		}

		frac_struct.font_num = p_env->frac_font;

		if(index){
			frac_struct.font_char = 31 + index; /* frac part */
			DMadd_symbol_text(NULL, dim_text,
					&frac_struct,
					p_env->text_font);
			}
	}
	return(TRUE);
}

IGRint DMget_plus_minus_flag (p_loc,
			      pmflag,
			      mode)
	 struct DMloc_param  *p_loc;
	 int  *pmflag;
	 int  mode;
/*.DMget_plus_minus_flag*/
{
	IGRuchar *up,*low;
	
	*pmflag = 0;
	if(mode == PRIMARY_UNIT){
		up = p_loc->primary.tole_up;
		low = p_loc->primary.tole_low;
	}
	else{
		up = p_loc->secondary.tole_up;
		low = p_loc->secondary.tole_low;
	}
	if(up[0] == '+' && low[0] == '-')
		*pmflag = ( (strcmp( &up[1],&low[1])) ? 0:1); 
		
	return( TRUE);
}

IGRint DMget_frac_index ( dim_val,
			  index,
			  accuracy,
			  flag)
	 IGRdouble  dim_val;
	 int  *index;
	 int  accuracy;
	 int  *flag;
/*.DMget_frac_index*/
{
	IGRdouble decimal, frac;
	IGRint fraction;

	*flag = 0;
	decimal = dim_val - (int)dim_val;

	frac = decimal * accuracy;
	if (frac < 0.5)
	{
		*flag = 0;
		return(1);
	}
	else if (fabs(accuracy - frac) < 0.5)
	{
		*flag = 1;
		return(1);
	}

	fraction = (int)(frac + 0.5);

	if (fraction != 0)
	{
		while (!(fraction % 2))
		{
			fraction= fraction/2;
			accuracy= accuracy/2;
		}
	}

	if (fraction == 0) 
	{
		*index= 0;
	}
	else
	{
		switch (accuracy)
		{
			case 2 : *index= (fraction+1)/2     ; break;
			case 4 : *index= (fraction+1)/2 + 1 ; break;
			case 8 : *index= (fraction+1)/2 + 3 ; break;
			case 16: *index= (fraction+1)/2 + 7 ; break;
			case 32: *index= (fraction+1)/2 + 15; break;
			case 64: *index= (fraction+1)/2 + 31; break;
			default: *index= 0;
		}
	} 
	return(TRUE);
}

#argsused
IGRint DMdeci_dimension (dim_val,
			 unit_type,
			 dim_text,
			 p_loc)
	 IGRdouble  dim_val;
	 struct measure_unit  *unit_type;
	 struct DMtxt_str  *dim_text;
	 struct DMloc_param  *p_loc;
/*.DMdeci_dimension*/
{
	char dimn_char[80], dim_str[80];
	char format[10];
	int dim_str_len,acc;
	char accuracy;


	if( unit_type->decacc == DECI_ACC10 ||
	    unit_type->decacc == DECI_ACC1 )
	{
		acc = (unit_type->decacc == DECI_ACC1 ? 1:10 );
		sprintf(dimn_char,"%ld", ((int)(dim_val + 0.5*acc)/acc)*acc);
		DMadd_char_str(dim_text,(IGRuchar *) dimn_char);
	}
	else
	{
		accuracy = unit_type->decacc - DECI_ACC1;

		format[0] = '%';
		format[1] = '.';
		format[2] = accuracy + '0';
		format[3] = 'l';
		format[4] = 'f';
		format[5] = '\0';
                sprintf(dimn_char ,format,dim_val);

	/*    we check the seperator and replace it 
              with corresponding char */

		dim_str_len = strlen(dimn_char);
		if( unit_type->deci_char == TRUE && accuracy)
		{
			dimn_char[dim_str_len -1 -accuracy] = ',';
		}
	        DMsupress_digit(dimn_char,unit_type->leading,
			 unit_type->trailing,dim_str);

		if (dim_str[0] == '\0')
			strcpy(dim_str, "0");

		DMadd_char_str(dim_text,(IGRuchar *) dim_str);
	}
	return(TRUE);
}

IGRint DMsupress_digit (dim_str,
			leading,
			trailing,
			result_str)
	 char  *dim_str;
	 char  leading;
	 char  trailing;
	 char  *result_str;
/*.DMsupress_digit*/
{
        int i;

        if(!leading)
        {
                while( *dim_str)
                {
                        if( *dim_str == '0')
                                dim_str++;
                        else
                                break;
                }
        }
        strcpy( result_str, dim_str);
        if(!trailing)
        {
                i = strlen(result_str);
                while( result_str[i-1] == '0')
                {
                        result_str[i-1] = 0;
                        i--;
                }
                if( result_str[i-1] == '.' ||
                    result_str[i-1] == ',')
                        result_str[i-1] = 0;
        }
        return(TRUE);

}

IGRint DMmake_fields (string,
		      text_length,
		      dmfields)
	 IGRuchar  *string;
	 short  text_length;
	 struct DMfield_def  *dmfields;
/*.DMmake_fields*/
{
	int active_field, field_pos[50];
	int i, field_no;

	active_field = 0;
	for( i = 0 ; i< text_length;)
	{
		if( string[i] == ESC )
		{
			switch(string[i+1])
			{
			case 'H':
			case 'J':
			case 'j':
			case 'y':
			case 's':
			case 'v':
			case 'x':
			case 'h': 
			 	i = i + 10 ;
			 	break;
			case 'w':
			 	i = i + 3 ;
			 	break;	
			case 'E':
			  	active_field--;
			  	field_no = field_pos[active_field];
			  	dmfields[field_no].end_char = i+1;
				i+=2;
			  	break;
			case 'F':
				field_pos[active_field] = string[i+2];
				dmfields[string[i+2]].start_char = i;
				dmfields[string[i+2]].flag = string[i+3];
				active_field++;
				i+=4;
				break;
			case 'M':
				i += 20;
				break;
			case 'm':
				i+=19;
				break;
			
			case 'f':
				i += 4;
				break;
			case 'p':
				i += 3;
				break;
			
			case 10:
				i += 2;
				break;

			default:
				printf("unknown char:%d",string[i+1]);
				i+=1;
			}
		}
		else  i += 1;
	}
	return(TRUE);
}

IGRint DMget_prefix_suffix_val (string,
				dmfields,
				p_misc,
				 field_no)
	 IGRuchar  *string;
	 struct DMfield_def  *dmfields;
	 struct DMmisc_param  *p_misc;
	 int  field_no;
/*.DMget_prefix_suffix*/
{
	
	int field_pos;
	int i;
	char *pre_ptr;
	

	 field_pos = dmfields[field_no].start_char;

	 if( field_no == FNUM_PREFIX_START)
	 {
	   /* this is prefix so we need to skip by prefix  */
		p_misc->prefix_disp = DISP_ON;
	 	field_pos  += L_START ;
		pre_ptr = p_misc->prefix;
	 }
	 else   /* this is suffix field  so increment field by one*/
	 {
		field_no++;
		p_misc->suffix_disp = DISP_ON;
	 	field_pos = dmfields[field_no].start_char;
	 	field_pos  += L_START ;
		pre_ptr = p_misc->suffix;
	 }

	  i = field_pos ;
	  if(string[i] == ESC && string[i+1] == 'f' )
	  {
		memcpy(&p_misc->sixteen_bit_font,&string[i+2],2);
		i = i+ 4;
		while(string[i] != ESC && string[i+1] != 'f')
		{
			 *pre_ptr++ = string[i];
			 i++;
		}
			
	  }
	  else
	  {
		  while (string[i] != ESC || string[i+1] != 'E')
		  {
			 *pre_ptr++ = string[i];
			 i++;
		  }
	  }

	  *pre_ptr = '\0';
	  return(TRUE);
}

#argsused
IGRint DMget_dimn_string_val (string,
			      dm_fields,
			      p_misc,
			      p_loc,
			      p_env,
			      field_no,
			      flag)
	 IGRuchar  *string;
	 struct DMfield_def  *dm_fields;
	 struct DMmisc_param  *p_misc;
	 struct DMloc_param  *p_loc;
	 struct DMenv_param  *p_env;
	 int  field_no;
	 int  flag;

/*.DMget_dimn_string_val*/
{

	int dim_field_no , field_pos;
	int mod_comp,lab_pos;
	int i;
	char *pre_ptr, *tole_sym;
	int pri_unit, sec_unit;

	pri_unit = p_env->pri_unit;
	sec_unit = p_env->sec_unit;

	mod_comp = p_misc->mod_comp;
	pre_ptr =  p_misc->dim_override;

	if( flag == FNUM_DUAL_MIDDLE )
		tole_sym = p_misc->sec_tole_sym;
	else
		tole_sym = p_misc->pri_tole_sym;

	
	dm$return_field_no(dim_type = flag,
			   tole_mode = p_loc->tole_mode,
			   field_no = &lab_pos);

        dm$return_field_no( dim_type = flag,
                            field_no = &dim_field_no);


	/*"flag=%d, lab_pos=%d, mod_comp=%d\n", flag, lab_pos, mod_comp*/

	if (mod_comp == MOD_COMP_DYNAMIC)
	{
		/*| - MOD_COMP_DYNAMIC - */


		/*   If tolerance mode is tol mode sym( middle) tol value 
		     needsto be extracted
		*/

		if(p_loc->tole_mode == TOLE_MODE_MIDDLE)
		{
			lab_pos = flag + DM_DIM_OFFSET /*flag is same as dimtype*/
				  + DM_TOL_OFFSET;
			if((field_pos = dm_fields[lab_pos + 1].start_char))
			{
			/* TR#119420563, two fields share same field number 66.
			   when extracting the tolerance value make sure to 
			   check if end_char + 1 of previous field matches
			   start_char of current field */
			  if((dm_fields[lab_pos].end_char + 1) != field_pos)
			    {
			      field_pos = dm_fields[lab_pos].end_char+1;
			    }
			  i = field_pos + L_START;
			  while(string[i] != ESC)
			    *tole_sym++ = string[i++];
			  *tole_sym = '\0';
			}		
		 }
	}
	else
	{
		/*| - MOD_COMP_STATIC - */

		if(!dm_fields[dim_field_no].start_char)
		{
			/* dimension field does not exist at the location
			   so it should be limits with override option
			   no value can be retrieved.
			*/

			return(TRUE);
		}

		field_pos = dm_fields[dim_field_no].start_char;
		field_pos = field_pos + L_START;

		i = field_pos;

 		while( string[i] != ESC)
		{
		 	*pre_ptr++ = string[i];
		 	i++;
		}

		*pre_ptr = '\0';
	}

	return(TRUE);
}

IGRint DMfld_fil (string,
		  text_length,
		  display,
		  text_symb)                                         
	 IGRuchar  *string;
	 int  text_length;
	 struct IGRdisplay  *display;
	 struct GRdpb_text_symb  *text_symb;
/*.DMfld_fil*/
{
	int i ,msg;
	double h_val,v_val;
	struct vfont_entry font_info;
	IGRuchar t_field;
	int field_pos[50],field_no;
	int field_just[50];
	int field_addr[50];
        IGRshort short_value;

	field_no  = 0;
	font$get_info(msg = &msg,
	    font_num = &text_symb->Active_font,
	    font_info = &font_info);

	for( i = 0 ; i< text_length;)
	{
		if( string[i] == ESC )
		{

			switch(string[i+1])
			{
			case 'H':
			case 'J':
			case 'j':
			case 'y':
			case 's':
			case 'v':
			case 'x':
			case 'h': 
				i = i + 10 ;
				break;
			case 'w':
				i = i + 3 ;
				break;
			case 'E':

				field_no = field_no - 1;

				/* go thru only if field_no is valid
				   TR# 119524798 */

				if(field_just[field_no]==TRUE && field_no >= 0)
				{    
					h_val = 0.0 ;
					v_val = 0.0;
					t_field = string[field_pos[field_no] +2];
                                        short_value = text_length;
					GRjust_field(&msg,
					    string,
					    &short_value,
					    &t_field,
					    &font_info,
					    display,
					    &text_symb->Active_linespac,
					    &text_symb->Active_charspac,
					    &text_symb->Active_height,
					    &text_symb->Active_width,
					    &text_symb->Active_font,
					    &h_val,
					    &v_val);
                                        text_length = short_value;
					memcpy(&string[field_pos[field_no]+7],&h_val,8);
					memcpy(&string[field_pos[field_no]+15],&v_val,8);
				}
				i = i + 2 ;
				break;
			case 'F':
				field_pos[field_no ] = i;
				field_addr[field_no] = string[i+2];
				if( (string[i+4] == ESC) && (string[i+5] == 'm'))
				{
					h_val = 0.0 ; 
					v_val = 0.0;
					field_just[field_no] = TRUE;
					memcpy( &string[i+7],&h_val,8);
					memcpy(&string[i+15],&v_val,8);
				}
				else field_just[field_no] = FALSE;
				field_no = field_no +1;
				i = i+4;
				break;
			case 'M':
				memcpy(&h_val , &string[i+ 4],8);
				memcpy(&v_val , &string[i+12],8);
                                short_value = i;
				GRfld_ref_pt(&msg,
				    string,
				    &short_value,
				    &string[i+2],
				    &font_info,
				    display,
				    &text_symb->Active_linespac,
				    &text_symb->Active_charspac,
				    &text_symb->Active_height,
				    &text_symb->Active_width,
				    &text_symb->Active_font,
				    &string[i+3],
				    &h_val,
				    &v_val);
				memcpy(&string[i+ 4],&h_val,8);
				memcpy(&string[i+12],&v_val,8);
				i= i+20;
				break;
			case 'f':
				i = i +  4 ;
				break;
			case 'p':
				i = i +  3 ;
				break;
			case 'm':
				i = i +  19 ;
				break;
			default:
				i = i + 1 ;
			}
		}
		else  i = i + 1 ;
	}
	return(TRUE);
}

DMpreproc_presuf (dir,
		  str)
	 int  dir;
	 char  *str;
/*.DMpreproc_presuf*/
{
	int i, j, len;
	char buff[EXFI_STRLEN];

	/*"dir=%d, str=<%s>\n", dir, str*/

	if ((len = strlen(str)) > EXFI_STRLEN-1)
		len = EXFI_STRLEN-1;

	for (i=0, j=0; str[i] && i<EXFI_STRLEN;)
	{
		if (dir && (str[i] == ';'))
		{
			buff[j] = ESC;
			buff[j+1] = 10;
			i++;
			j += 2;
		}
		else if (!dir && (str[i] == ESC) && (str[i+1] == 10))
		{
			buff[j] = ';';
			i += 2; /* - ESC 10 - */
			j++;
		}
		else if (!dir && (str[i] == ESC) && (str[i+1] == 'H'))
		{
			i += 10; /* - ESC H - */
		}
		else if (str[i])
		{
			buff[j] = str[i];
			i++;
			j++;
		}
	}

	strncpy(str, buff, j);
	str[j] = '\0';

	/*"str=<%s>\n", str*/

	return(TRUE);
}
DMcheck_limits_accuracy (result1,
			 result2,
			 unit)
	 IGRdouble  result1;
	 IGRdouble  result2;
	 struct measure_unit  *unit;
/*.DMcheck_limits_accuracy*/
{
	char limits[2][32];
	int dots[2];
	int i,accuracy,n;
	char format[32];
	

	/* do this if the mode is decimal mode and measure unit 
	   is not feet inches and etc
	*/

	if( unit->decacc == DECI_ACC10 ||
	    unit->decacc == DECI_ACC1 )
	{	
		return (TRUE);
	}

	accuracy = unit->decacc - DECI_ACC1;

        format[0] = '%';
        format[1] = '.';
        format[2] = accuracy + '0';
        format[3] = 'l';
        format[4] = 'f';
        format[5] = '\0';

        sprintf(limits[0] ,format,result1);
        sprintf(limits[1] ,format,result2);

	dots[0] = dots[1] = 0;
	for( i = 0; i<2;i++)
	{
		n = strlen(limits[i]);
		while( n>0 && limits[i][--n] == '0');
		while( n>0 && limits[i][n--] != '.') dots[i]++;
	}

	if(!unit->trailing)
	{
		unit->trailing = 1;
		if(dots[0] > dots[1]) 
			unit->decacc = dots[0];
		else 
			unit->decacc = dots[1];
	}

	return(TRUE);
}
end implementation DMtext;
