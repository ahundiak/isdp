class implementation Root;
#include <stdio.h>
#include <malloc.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
/*#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h" */
#include "gr.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"
/*#include "FI.h" */
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "parametric.h"
#include "PDUerror.h"

/* TR# 13931 2351.	*/
#include <grdpbdef.h>
#include <grdpb.h>
#include "grdpbmacros.h"
#include <string.h>
#include <math.h>
#include <stdlib.h>

/* TR# 139420916. 12/July/94 - raj.	*/
#include "bsvalues.h"
#if defined (i386) && defined (__Sol2__)
#include "bsvalues_sn.h" /* Added for INTEL Solaris port - KCS -- 13/Sept/94 */
#endif
/* TR# 139424177 */
#include "msmacros.h"

#define DEBUG 0


extern char *strchr();
extern char  *getenv();
 
from expression import create ;
from expression import give_formula ;

static int sts;

char PDM_old_dir[DI_PATH_MAX];

extern OMuword OPP_expression_class_id ;

int OLD_parse_exp_and_get_value(formula)
char **formula  ;
{

	/* This function gets the value of the exp object 
	*/

	int  i;
        int status;
	char *st_temp , val[200] ;
	double a ;
	char **arg_list, type_obtained ;
	struct data_struct ret_val ;
	short int arg_num ;    
        char msg[80];
	void clear_mem ();

         status = PDUvalid_number(*formula, "F", msg);
         if (status == PDM_S_SUCCESS)
           return(1);

	/* removes leading blanks */
	for( i = 0 ; (*formula)[i] != '\0' && (*formula)[i] != '\n';i=i+1  ) 
        	if( (*formula)[i] != ' ' )
                	break;

	st_temp =  &(*formula)[i] ;

	remove_quotes(st_temp);

	_pdm_debug("st_temp: %s ", st_temp);

	sts = new_exp_Parse(st_temp,&ret_val,&arg_list,&arg_num,0,&type_obtained);

	if( ! ( sts&1))
		return(0);

	clear_mem(arg_list,arg_num);

/*	if( ret_val.unit_type != text_type ){  */
		a = ret_val.data.real ;

		sprintf(val,"%lf",a);   
/*	}
	else
		strcpy(val,ret_val.data.string);
*/

	_pdm_debug("value of expression : %s ",val);

	*formula = (char *)realloc((*formula), strlen(val) + 10 );
	strcpy(*formula,val);
	return(1);
}    

int parse_exp_and_get_value(formula)
char **formula  ;
{

	/* This function gets the value of the exp object 
	*/

	int  i;
	char *st_temp , val[200] ;
	double a ;
	void clear_mem ();

	/* 28430 fix - begin */
	IGRshort prevstate;
	IGRlong msg;
	int sts;

	/* TR# 139420916. 12/July/94 - raj. Expression PALeval to be deleted immediately.	*/
	int		save_nd_mode;

	sts = ms$onoff( msg = &msg, prevstate = &prevstate, type = MS_OFF );

	_pdm_debug("Enter parse_exp_and_get_value(): <%s>", *formula);
	
	/* removes leading blanks */
	for( i = 0 ; (*formula)[i] != '\0' && (*formula)[i] != '\n';i=i+1  ) 
        	if( (*formula)[i] != ' ' )
                	break;

	st_temp =  &(*formula)[i] ;

	remove_quotes(st_temp);

	_pdm_debug("st_temp: %s ", st_temp);

        /* TR# 139420916. 12/July/94 - raj. Expression PALeval to be deleted immediately.	*/
        /* Need the batch mode to be ND_IMMEDIATE so that the expressions
        are deleted immediately. Inquire the exising mode, save it to restore
	existing mode at the end of this PPL and set mode to ND_IMMEDIATE. */
      
        nd$mod_batch(request     = ND_INQ,
      		p_ret_mode  = &save_nd_mode);
      
        _pdm_debug("NDmode = %d", save_nd_mode);
      
        /* Set ND mode to immediate.	*/
        nd$mod_batch(request     = ND_SET,
      		req_mode   = ND_IMMEDIATE);
      
	if(!PALevaluate_syntax(st_temp, &a, NULL, NULL))
		return (0);

        /* TR# 139420916. 12/July/94 - raj. Restore nd mode.	*/
        /* Restore ND mode.	*/
        nd$mod_batch(request     = ND_SET,
      		req_mode   = save_nd_mode);

	sprintf(val,"%lf",a);   

	_pdm_debug("value of expression : %s ",val);

	*formula = (char *)realloc((*formula), strlen(val) + 10 );
	strcpy(*formula,val);

	_pdm_debug("Exit parse_exp_and_get_value(): <%s>", *formula);

	sts = ms$onoff( msg = &msg, prevstate = &prevstate, type = MS_ON );
	/* 28430 fix - end */

	return(1);
}    

remove_quotes(str)
char *str ;
{

	int i ;
	char *tmp ;

	if( str[0] != '"' ) return (0);

	tmp = (char *)malloc( strlen(str) + 1 );

	for( i = 1 ; str[i] != '"' && str[i] != '\0' ; i = i + 1 ) 

        	tmp[i-1] = str[i] ;

	tmp[i-1] = '\0' ;

	strcpy(str,tmp);

	free( tmp );

	return(1);
}

extern free_ptrs();

get_exp_objid_list(num_stat,temp_val,sel_grid,num_exp_objs) 
int num_stat , *num_exp_objs ;
char *temp_val[] ;
struct GRid sel_grid[];
{
	int ind , i, j , sts ;
	char *arry[60] ;

if( DEBUG ) 
	for( i = 0 ; i < num_stat ; i = i + 1 ) 
        	printf("in get_exp: %s %d \n", temp_val[i], strlen(temp_val[i]));

	parse_all_expr(num_stat,temp_val,num_exp_objs,arry);

	ind = num_stat + 1 ;

if ( DEBUG )
	printf("no. of exps from parsit: %d\n",*num_exp_objs );
          

	j = 0 ;

	for( i = 0 ; i < *num_exp_objs ; i = i + 1 ) {

		sel_grid[ind+j].objid = NULL_OBJID ;

		sts = exp$translate( exp_name = arry[i] , p_exp_id = &sel_grid[ind+j].objid );
if ( DEBUG )
		printf("exp id & name : %d %s\n", sel_grid[ind+j].objid, arry[i] );

		if ( sts & 1 ) j = j + 1 ;

		free(arry[i] );
	}

	*num_exp_objs = j ;

	free_ptrs();

	return(1);
}


set_directory(mod_env)
struct GRmd_env *mod_env ;
{

        char dir_name[DI_PATH_MAX] ;        

	if( !PDM_old_dir[0] ) /* Save the working dir name */
	{
		di$pwd ( dirname = dir_name );
		strcpy( PDM_old_dir, dir_name );
	}

        /* goto the main directory  */

        DIstmocpy(dir_name,"PDU","macro_parts",0,mod_env -> md_id.osnum);

/*
	printf("dir_name: %s\n", dir_name);
*/

        sts = di$cd(dirname = dir_name,osnum=mod_env -> md_id.osnum);

       
        if( sts != DIR_S_SUCCESS ) {   /* directory does not exist. Hence create */

	        DIstmocpy(dir_name,"PDU",0,mod_env -> md_id.osnum);
	        sts = di$cd(dirname = dir_name,osnum=mod_env -> md_id.osnum);

		if( sts != DIR_S_SUCCESS ){
			sts = di$mkdir(dirname = dir_name,osnum=mod_env -> md_id.osnum);

			if(sts != DIR_S_SUCCESS ) {
        	        	printf("mkdir failed\n");
                		return(0);
                	}

			/* change to the working directory */
           
			sts = di$cd(dirname = dir_name,osnum=mod_env -> md_id.osnum);
		}

		if( sts != DIR_S_SUCCESS ) {
                	printf("change directory failed\n");
                	return(0);
                }

	        DIstmocpy(dir_name,"PDU","macro_parts",0,mod_env -> md_id.osnum);

		sts = di$mkdir(dirname = dir_name,osnum=mod_env -> md_id.osnum);

		if(sts != DIR_S_SUCCESS ) {
                	printf("mkdir failed\n");
                	return(0);
                }

		/* change to the working directory */
           
		sts = di$cd(dirname = dir_name,osnum=mod_env -> md_id.osnum);

		if( sts != DIR_S_SUCCESS ) {
                	printf("change directory failed\n");
                	return(0);
                }
        }

        return(1);
}

/* This routine would reset back the CWD to PDM_old_dir */
 
reset_directory(mod_env)
struct GRmd_env *mod_env ;
{
/*
        char dir_name[DI_PATH_MAX] ;        
	char tmp[20];
	int len;
*/
	/* get the PWD 
	di$pwd ( dirname = dir_name );

	printf("CWD dir is :%s\n", dir_name);

	len = strlen( dir_name ) - strlen( "PDU:macro_parts:" );

	dir_name[len] = '\0';
	*/

	if( !PDM_old_dir[0] )  /* No previously set dirname */
		return( 1 );

/*
	printf("Resetting dir to :%s\n", PDM_old_dir);
*/

        sts = di$cd(dirname = PDM_old_dir,osnum=mod_env -> md_id.osnum);

       
	PDM_old_dir[0] = '\0';

        if( sts != DIR_S_SUCCESS ) {
        	printf("chdir back: failed\n");
                return(0);
	}

        return(1);
}


void clear_mem(arg_list,arg_num)
char **arg_list ;
short int arg_num ;
{
	int i ;

	if( arg_list) {

		for( i = 0 ; i < arg_num ; i++ ) 
        		if( arg_list[i] ) free( (char *)arg_list[i]);

		free(arg_list);
	}
}

get_text_exp_value(condition)
char **condition ;
{

	GRobjid tmp_objid ;
/* TR# 139420931. 13/July/94 - raj.	*/
/*	int osnum  ;	*/
	OMuword osnum  ;
	osnum = OM_Gw_current_OS;

	sts = exp$translate(exp_name = *condition , p_exp_id= &tmp_objid ,
				p_osnum = &osnum );


	if( sts & 1 ) { /* if text exp object */
		*condition = (char *)realloc((*condition),128);

		sts = om$send( msg = message expression.give_formula(*condition),
                        	               	senderid = tmp_objid,
                        	               	targetid = tmp_objid,
						targetos = osnum );

		remove_quotes(*condition);
		return(1);
	}

	return(0);
}

GetDefaultPlacementName(name)
char **name ;

{
	int  i = 0 ;
	char *objname ;
	GRobjid comp_objid ;

	comp_objid = NULL_OBJID ;

	PDUgetDefPlcmntName(name);

	objname = malloc( strlen (*name) + 5 );

	do {
		++i ; 
		sprintf(objname,"%s%d",(*name),i);

	        /* check whether object is already created */
        	sts = di$translate(objname=objname,
                             p_objid = &comp_objid);

	} while ( sts == DIR_S_SUCCESS );

	(*name) = realloc((*name), strlen(objname) + 1 );
	strcpy((*name),objname );

	free( objname );

	return(1);	
}

PALusage_id_unique(usageid)
char *usageid;
{
	int sts ;
	GRobjid comp_objid ;

        /* check whether object is already created */
       	sts = di$translate(objname=usageid,
                            p_objid = &comp_objid);

	if( sts == DIR_S_SUCCESS )
		return(0);

	return(1);
}

/*
 * TR# 13931 2351. Added the following function for expression syntax evaluation.
 */

/*
 * This function evaluates a given syntax and returns the value of the evaluated
 * syntax.
 * It calls function Parse_eqn() to validate the syntax and get the list of all
 * expression (variable) names in the syntax and their number. The function Prase_eqn()
 * CREATES variables in a given syntax if they do not exist, but leaves them un-defined.
 * So, this function evaluates each of these variables in the list from from Parse_eqn(),
 * to determine if they have values defined for them or not.
 * Returns 0, if any of the variables are un-defined.
 * Returns 1, and the value of the evaluated syntax if all the variables are pre-defined
 * and the syntax is valid.
 * 
 * 07/feb/94 - raj.
 * 
 */

PALevaluate_syntax(exp_syntax, expval, p_mod_env, p_osnum)
char	*exp_syntax;
double	*expval;
struct	GRmd_env *p_mod_env;
OMuword	*p_osnum;
{
	IGRlong	sts;
	char	**arg_list;
	short	arg_count;
	char	equation_str [DI_PATH_MAX], equation_str_cp [DI_PATH_MAX];
	char	exp_name[32], exp_name_1[32];
	int	ii;
	char	formula[DI_PATH_MAX];
	short	PALis_syntax_valid;
	long   NumberOfBytes, BytesReceived, msg;
	struct	GRmd_env mod_env;
	OMuword	osnum;
	int	ret;

	static int cnt = 0;
	IGRshort prevstate;		/* TR# 139424177 */

	_pdm_debug("\nEnter PALevaluate_syntax(): <%s>", exp_syntax);

	if (!strcmp(exp_syntax, ""))
	{
		_pdm_debug("NULL string for syntax", 0);
		return(0);
	}

	/* syntax should not contain an '=' sign.	*/	
	if ((strchr ( exp_syntax, '=' )) != NULL)
	{
		_pdm_debug("Invalid syntax. '=' in syntax", 0);
		return(0);
	}

	/* Get module environment only if it is not passed as an argument.	*/
	if (p_mod_env == NULL)
	{
	  NumberOfBytes = sizeof( mod_env );
	  gr$get_module_env(
			msg= &msg,
			sizbuf= &NumberOfBytes,
			buffer= &mod_env,
			nret= &BytesReceived );

	  osnum = mod_env.md_id.osnum;
        }
        else
        {
          mod_env = *p_mod_env;
          osnum = *p_osnum;
        }

	/* Construct syntax to be in format x=y+z	*/
	if (cnt >= OM_K_MAXINT)
		cnt = 0;
	sprintf(exp_name, "PALeval%d", cnt++);
	if (cnt >= OM_K_MAXINT)
		cnt = 0;
	sprintf(exp_name_1, "PALeval%d", cnt++);

	strcpy (equation_str, exp_syntax);
    
	if (exp_name && ((strchr ( exp_syntax, '=' )) == NULL))
	    if (strlen (exp_name))
	    {
		strcpy(equation_str, exp_name_1);
		strcpy(equation_str_cp, exp_name);
		strcat(equation_str, "=");
		strcat(equation_str_cp, "=");
		strcat(equation_str, exp_syntax);
		strcat(equation_str_cp, exp_syntax);
	    }

/*	strcpy(equation_str_cp, equation_str);	*/
	
	/* Call function Parse_eqn() to give the list of variables in the syntax.	*/
	arg_count = 0;

	/* TR# 139424177 31/Oct/95. Turn off output to status area. */
	ms$onoff( msg = &msg , prevstate = &prevstate, type = MS_OFF );
	sts = Parse_eqn ( equation_str_cp, &arg_list, &arg_count, &osnum);
	ms$onoff( msg = &msg, prevstate = &prevstate, type = MS_ON );

	if (sts != EXP_S_SUCCESS)
		return(0);

	/* Now that syntax is evaluated, delete the PALeval%d expression.	*/
	sts = exp$delete(exp_name = exp_name, p_md_env = &mod_env);
	if (sts != EXP_S_SUCCESS)
	{
		_pdm_debug("Unable to delete temporary expression '%s'", exp_name);
		return(-1);
	}
	
        /* Set ND mode to immediate.	*/
        nd$mod_batch(request     = ND_SET,
      		req_mode   = ND_IMMEDIATE);
      
	/* TR# 139420916. 12/July/94 - raj. Delete PALeval%d immediately.	*/
	nd$exec_batch();

	/* For each of the variables see if it has already been defined.	*/

	_pdm_debug("No. of variables in syntax = %d", arg_count - 1);

	PALis_syntax_valid = TRUE;

	/* First element is 'PALeval%d' start from 2nd element.	*/
	for (ii = 1; ii < arg_count; ii = ii + 1)
	{
		_pdm_debug("Variable name = <%s>", arg_list[ii]);
		if ((ret = PALis_expression_defined(arg_list[ii], &osnum, formula, expval)) != 1)
		{
		  /* -1 denotes expression with value defined but is of type text.	*/
		  if(ret != -1)
		  {
		    	/* If expression's value is un-defined only.	*/
			/* delete the expression created by Parse_eqn().	*/
			sts = exp$delete(exp_name = arg_list[ii], p_md_env = &mod_env);
	    		if (sts != EXP_S_SUCCESS)
			{
				_pdm_debug("Unable to delete temporary expression <%s>", arg_list[ii]);
				return(-1);
			}
			_pdm_debug("Deleted expression <%s> created by Parse_eqn()", arg_list[ii]);
                  }

                  /* Can not have text type epressions since this function is called for
                  evaluation of search criteria for numeric type attributes. Set to false. */

		  PALis_syntax_valid = FALSE;
		}
	}

	if (PALis_syntax_valid == FALSE)
		return (0);

	/* If all the variables in the syntax are pre-defined, then create
	a temporary variable to evaluate this syntax and come up  with a value.	*/

	/* TR# 139424177 31/Oct/95. Turn off output to status area. */
	ms$onoff( msg = &msg , prevstate = &prevstate, type = MS_OFF );
	sts = exp$create (exp_name = exp_name_1, exp_syntax = equation_str, type_rq = EXP_DOUBLE);
	ms$onoff( msg = &msg, prevstate = &prevstate, type = MS_ON );

	_pdm_debug("sts = %x\n", sts);

    	if (sts != EXP_S_SUCCESS)
	{
		_pdm_debug("Unable to create expression with syntax '%s'", equation_str);
		return(0);
	}

	if ((ret = PALis_expression_defined(exp_name_1, &osnum, formula, expval)) != 1)
	{
		_pdm_debug("PALeval%d is not defined or has no valid value", 0);
		return(0);
	}

	/* Now that syntax is evaluated, delete the PALeval%d expression.	*/
	sts = exp$delete(exp_name = exp_name_1, p_md_env = &mod_env);
	if (sts != EXP_S_SUCCESS)
	{
		_pdm_debug("Unable to delete temporary expression '%s'", exp_name_1);
		return(-1);
	}

	nd$exec_batch();
	
	_pdm_debug("Exit PALevaluate_syntax()\n", 0);
	return(1);

}


/*
 * This function takes an expression name and
 * Returns value of a defined expression, if it NON-TEXT type.
 * Returns -1 if defined expression is of TEXT type.
 * Returns  0 if value is un-defined.
 * 
 * 07/feb/94 - raj.
 * 
 */

PALis_expression_defined (exp_name, osnum, formula, expval)
char	*exp_name;
OMuword	*osnum;
char	formula[];
double	*expval;
{
	IGRlong		sts;
	OM_S_OBJID	exp_id;
	char		*ptr, *at_comma;

	_pdm_debug("Enter PALis_expression_defined(): exp_name = <%s>", exp_name);

	exp_id = NULL_OBJID;
	exp$translate( exp_name = exp_name, p_exp_id = &exp_id, p_osnum = osnum);
	_pdm_debug("id = %d", exp_id);

	sts = om$send ( msg = message expression.give_formula(formula),
			targetid = exp_id,
			senderid = exp_id,
			targetos = *osnum);

	if (!(sts&1))
		goto wrapup;

	if (!PALis_value(formula))
	{
		_pdm_debug("Variable <%s> is not defined", exp_name);
		return (0);
	}

	_pdm_debug("Formula = <%s>", formula);
	
	if (!strchr(formula, (int)'='))
	{
          /* unkknow format or text type format.	*/
          return(-1);
        }

	if(strchr(formula, (int)'[') && strchr(formula, (int)']'))
	{
	  /* only if formula is of format 'x = 5+5 [10]' or z = x+y [z, 10]	*/
	  ptr = strtok(formula, "[");
	  ptr = strtok(NULL, "]");

	  if (at_comma = strchr(ptr, (int)','))
	  {
	    /* It string inside has a comma in it. Go past comma.	*/
	    at_comma++;
	    ptr = at_comma;
          }
        }
        else if (strchr(formula, (int)'"'))
        {
          /* It's of text type.	*/
          return(-1);
        }
	else
	{
	  /* if formula is of 'x=10' format.	*/
          if (ptr =  strchr(formula, (int)'='))
          {
            /* Go past the comma.	*/
            ptr++;
          }
        }

	_pdm_debug("extracted from string = <%s>", ptr);

	*expval = atof(ptr);

	_pdm_debug("Exit PALis_expression_defined()", 0);

	return(1);

wrapup:
	_pdm_debug("Exit PALis_expression_defined(): at wrapup", 0);
	return (0);
}

/*
 * This function takes the output formula from expression.give_formula() and
 * parses it to find out if it is a defined value or un-defined value.
 * If the formula is of format 'x = ????' then the value is un-defined.
 * Else if formula is of format 'x=10' this means the value is defined.
 * 
 * 07/feb/94 - raj.
 * 
 */

PALis_value(formula)
char	*formula;
{
	if ((strchr(formula, (int)'?')) == NULL)
	{
	  /* '?' does not exist in string. Value defined strings do not have this char.	*/
          return(1);
        }
        else
        {
          /* '?' exists in string. Only un-defined string have this char.	*/
          return(0);
        }
}

end implementation Root;
