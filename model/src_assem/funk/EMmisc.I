class implementation Root;

#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "OMminimum.h"
#include <exdef.h>
#include <ex.h>
#include "DIdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"

#define	EXTERN

#include "asmglobals.h"

#include "assemdef.h"
#include "assem.h"
 
from expression import create ;
from expression import give_formula ;

int EMinitialise()
{
	EMplacement_type = EM_VIEWALIGNED;
	strcpy( EMplacement_view, "top" );
	EMbackgrnd_part = 0;
	EMread_only_part = 0;

	return(1);
}

/* This function parses any equations with expressions and gets its value
*/

int get_realexp_val(formula)
char **formula  ;
{
int  i, sts;
char *st_temp , val[200] ;
double a ;
char **arg_list, type_obtained ;
struct data_struct ret_val ;
short int arg_num ;    
void clear_mem ();

	/* removes leading blanks */
	for( i = 0 ; (*formula)[i] != '\0' && (*formula)[i] != '\n';i=i+1  ) 
        	if( (*formula)[i] != ' ' )
                	break;

	st_temp =  &(*formula)[i] ;
	remove_quotes(st_temp);

	sts = new_exp_Parse(st_temp,&ret_val,&arg_list,&arg_num,0,&type_obtained);
	if( ! ( sts&1))
		return(0);

	clear_mem(arg_list,arg_num);

	a = ret_val.data.real ;

	sprintf(val,"%lf",a);   

	*formula = (char *)realloc((*formula), strlen(val) + 10 );
	strcpy(*formula,val);
	return(1);
}    

get_textexp_val(string)
char **string;
{
int sts;
GRobjid tmp_objid ;
int osnum  ;

	sts = exp$translate(exp_name = *string , p_exp_id= &tmp_objid ,
				p_osnum = &osnum );

	if( sts & 1 )  /* if text exp object */
	{
		*string = (char *)realloc((*string),128);

		sts = om$send( msg = message expression.give_formula(*string),
                        	               	senderid = tmp_objid,
                        	               	targetid = tmp_objid,
						targetos = osnum );
		remove_quotes(*string);
		return(1);
	}
	return(0);
}

void clear_mem(arg_list,arg_num)
char **arg_list ;
short int arg_num ;
{
int i ;

	if( arg_list) 
	{
		for( i = 0 ; i < arg_num ; i++ ) 
        		if( arg_list[i] )
				free( (char *)arg_list[i]);
		free(arg_list);
	}
}

remove_quotes(str)
char *str ;
{
int i ;
char *tmp ;

	if( !str || !(strlen(str) > 0) )
		return( 0 );

	if( str[0] != '"' ) return (0);

	tmp = (char *)malloc( strlen(str) + 1 );

	for( i = 1 ; str[i] != '"' && str[i] != '\0' ; i = i + 1 ) 
        	tmp[i-1] = str[i] ;

	tmp[i-1] = '\0' ;
	strcpy(str,tmp);
	free( tmp );

	return(1);
}

int fill_attr( atype, dtype, name, desc, valsyn, attr )
int atype, dtype;
char *name, *desc, *valsyn;
EMattr *attr;
{
	attr->info.type = atype;
	strcpy(attr->info.name,name);
	strcpy(attr->info.desc,desc);

	attr->value.type = dtype;
	if( valsyn && strlen(valsyn) )
	{
		strcpy(attr->value.syntax,valsyn);
		if( dtype == EM_STRING )
			strcpy(attr->value.data.s,valsyn);
		else if( dtype == EM_INTEGER )
			sscanf( valsyn,"%d", &attr->value.data.i);
		else if( dtype == EM_DOUBLE )
			sscanf( valsyn,"%lf", &attr->value.data.d);
	}
	else
	{
		strcpy(attr->value.syntax,"");
		if( dtype == EM_STRING )
			strcpy(attr->value.data.s,"");
		else if( dtype == EM_INTEGER )
			attr->value.data.i = 0;
		else if( dtype == EM_DOUBLE )
			attr->value.data.d = 0.0;
	}

    return(1);
}

EMrem_syntax_lhs( olsyntax, newsyntax )
IGRchar *olsyntax, *newsyntax;
{
IGRchar *ptr = NULL;

    if( olsyntax && !strlen (olsyntax) )
	return 0;

    if( !newsyntax )
	return 0;

    ptr = strchr( olsyntax, '=' ); /* look for '=' sign */

    if( ptr )                    /* if found */
    {
        while( (*ptr) && (*(++ptr) == ' ')); /* remove leading blanks */
        strcpy( newsyntax, ptr );
    }
    else                         /* simple text */
    {
        strcpy( newsyntax, "\"");
        strcat( newsyntax, olsyntax );
        strcat( newsyntax, "\"");
    }
    return( 1 );
}

/*
    This function would create a dummy expression with the given input_str,
    and get its formula in syntax. The dummy expression is deleted.
*/
EMget_syntax_from_input( input_str, syntax, exp_name )
IGRchar *input_str, *syntax, *exp_name;
{
struct GRid expid;
int    status;
char   loc_str[156], *ptr = NULL;

    if (!strcmp(input_str, "")) /* If syntax is "", no evaluation */
	return(0);

    if( input_str[0] == '\"' ) /* Text attribute */
        return(0);

    /* If syntax contains an '=' sign, return the lhs in exp_name and 
       evaluated syntax */	
    if ((ptr = strchr ( input_str, '=' )) != NULL)
    {
        if( exp_name )
            strncpy( exp_name, input_str, (ptr - input_str - 1) );

        strcpy( loc_str, input_str );
    }
    else
    {
        strcpy(loc_str,"EMdmyexp=");
        strcat(loc_str, input_str );
    }

    EMreduce_syntax( loc_str, NULL );
    status = exp$create( exp_syntax = loc_str,
                p_exp_id = &expid.objid,
                p_osnum = &expid.osnum );

    if( status & 1 )
    {
	status = om$send( msg = message expression.give_formula( loc_str ),
                        	               	senderid = expid.objid,
                        	               	targetid = expid.objid,
						targetos = expid.osnum );

	/* Delete the dummy expression */
      	status = om$send(msg = message  Root.delete(1),
                        targetos = expid.osnum,
                        targetid = expid.objid, 
	                senderid = NULL_OBJID );
    }
    EMrem_syntax_lhs( loc_str, syntax );
    strcpy( loc_str, syntax );

    ptr = NULL;
    if(( ptr = strtok(syntax, "[")) != NULL)
    {
        strcpy(syntax, ptr);
        if((ptr = strchr(loc_str, ',')) != NULL)
        {
            strcat(syntax,"[");
            strcat(syntax, ptr+2 );
        }
    }

    return( 1 );
}

EMevaluate_exp_syntax(exp_name, exp_syntax, expval, p_mod_env, p_osnum)
char	*exp_syntax, *exp_name;
IGRdouble	*expval;
struct	GRmd_env *p_mod_env;
OMuword	*p_osnum;
{
    IGRlong	sts;
    char	**arg_list, *ptr;
    short	arg_count;
    char	equation_str [DI_PATH_MAX], equation_str_cp [DI_PATH_MAX];
    char	loc_str[DI_PATH_MAX];
    int	        ii;
    struct	GRmd_env mod_env;
    struct      GRid     expid;
    OMuword	osnum;

    /* this function does not return the value */
    *expval = 0.;

    if (!strcmp(exp_syntax, "")) /* If syntax is "", no evaluation */
	return(1);

    /* If syntax contains an '=' sign, return the lhs in exp_name and 
       evaluated syntax */	
    if ((ptr = strchr ( exp_syntax, '=' )) != NULL)
    {
        if( exp_name )
            strncpy( exp_name, exp_syntax, (ptr - exp_syntax - 1) );

        sts = EMevaluate_exp_syntax((char *)NULL, ptr, (double *)NULL, p_mod_env, p_osnum );
        strcpy( exp_syntax, ptr );
	return( sts );
    }

    /* Get module environment only if it is not passed as an argument.	*/
    if (p_mod_env == NULL)
    {
	  gr$get_module_env( buffer= &mod_env );
    }
    else
    {
        mod_env = *p_mod_env;
        if( p_osnum )
            osnum = *p_osnum;
        else
            osnum = OM_Gw_current_OS;
    }

    /* Construct syntax to be in format x=y+z	*/
    strcpy(equation_str, "EMdmyexp");
    strcat(equation_str, "=");
    strcat(equation_str, exp_syntax);

    /* back it up */
    strcpy(equation_str_cp, equation_str);
	
    /* Call function Parse_eqn() to give the list of expressions in syntax.*/
    arg_count = 0;
    sts = Parse_eqn (equation_str, &arg_list, &arg_count, &osnum);

    if (sts != EXP_S_SUCCESS)
	return(0);

    /* Now that syntax is evaluated, delete the temp expression. */
    sts = exp$delete(exp_name = "EMdmyexp", p_md_env = &mod_env);
    if (sts != EXP_S_SUCCESS)
	return(0);

    /* See if each of the expressions found in the syntax are already defined */
    /* First element is 'EMdmyexp' start from 2nd element.	*/
    for (ii = 1; ii < arg_count; ii = ii + 1)
    {
	if (!EMvalid_exp_exists(arg_list[ii], &osnum))
	{
            /* If expression's value is un-defined,
	       delete the expression created by Parse_eqn().	*/
	    sts = exp$delete(exp_name = arg_list[ii], p_md_env = &mod_env);
	    if (sts != EXP_S_SUCCESS)
		return(0);
	}
    }
    /* Now create a temporary exp to evaluate the syntax */
    sts = exp$create ( exp_syntax = equation_str_cp,
                       p_exp_id   = &expid.objid,
                       p_osnum    = &expid.osnum );

    if (sts != EXP_S_SUCCESS)
	return(0);

    /* Get the new syntax from the expression */
    sts = om$send( msg = message expression.give_formula( loc_str ),
                       	               	senderid = expid.objid,
                       	               	targetid = expid.objid,
					targetos = expid.osnum );

    /* Now that syntax is evaluated, delete the temp expression */
    sts = exp$delete(exp_name = "EMdmyexp", p_md_env = &mod_env);
    if (sts != EXP_S_SUCCESS)
	return(0);

    /* Clean up the batch */
    nd$exec_batch();
	
    return(1);
}


/*
 * This function takes an expression name and
 * Returns true and value of expression, if defined, else returns 0.
 */

EMvalid_exp_exists(exp_name, osnum)
char	*exp_name;
OMuword	*osnum;
{
IGRlong		sts;
OM_S_OBJID	exp_id;
IGRchar         formula[DI_PATH_MAX];

    exp$translate( exp_name = exp_name, p_exp_id = &exp_id, p_osnum = osnum);

    sts = om$send ( msg = message expression.give_formula(formula),
			targetid = exp_id,
			senderid = exp_id,
			targetos = *osnum);

    if (!(sts&1))
	goto wrapup;

    /* '?' not found, exp is defined */
    if ((strchr(formula, (int)'?')) == NULL) 
        return(1);
wrapup:
	return (0);
}

end implementation Root;
