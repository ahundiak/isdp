#ifndef expmacros
#define expmacros

/*--------------------------------------------------------------------------*/
/*
/*	Name:			expmacros.h
/*	Author:			sf
/*	Creation Date:		sept-31-87
/*	Operating System(s):	Unix SYSV, v2
/*
/*	Abstract:
/*	---------
/*	
/*	This files defines the following macro related to expression :
/*
/*		exp$create ( exp_name, exp_id, exp_syntax )
/*		exp$delete ( exp_name, exp_id)
/*		exp$modify ( exp_name, exp_id)
/*		exp$tranbslate( exp_name, exp_id)
/*
/*	Delete and modify use either name or objid to locate 
/*	the expression.
/*
/*	Type of the macro parameters :
/*	------------------------------
/*
/* 		exp_name	char*
/*		exp_value	double
/*		p_exp_id	OM_S_OBJID*
/*		osnum		OMuword
/*		p_md_env	struct GRmd_env*
/*		type_req	char
/*		p_type_ob	char*
/*		
/*	Error Codes :
/*	-------------
/*
/*	The error codes returned by the expression sub-system
/*	are defined in the expression.h file.
/*	success is EXP_S_SUCCESS.
/*
/*	Dependance :
/*	------------
/*
/*	This file depends on the following file :
/*		expression.h
/*
/*	Revision History:   
/*	-----------------
/*		Oct-07-1987 - SF
/*		Dec-16-1987 - HGB
/*
/*--------------------------------------------------------------------------*/




/*--------------------------------------------------------------------------*/
/* This macro is used to create an expression
/* It can be 
/* - a double value (a = 20 , b = 2*a +5)
/* - a text expression (tt = "toto")
/*--------------------------------------------------------------------------*/
#omdef exp$create ( exp_name = NULL, 
                    exp_syntax ^ exp_value, 
                    p_exp_id = NULL, 
		    osnum = OM_Gw_current_OS, 
		    p_osnum = NULL, 
		    type_rq = EXP_DOUBLE )
#if om$specified( exp_syntax )
  EXP_create ( (exp_name), (exp_syntax), (p_exp_id) , 
	       (osnum), (p_osnum), (type_rq), NULL)
#elif om$specified( exp_value )  
  EXP_create_double ( (exp_name), ( exp_value ), (p_exp_id) , 
		      (osnum), (p_osnum), EXP_DOUBLE , NULL)
#endif
#endomdef
/* 
   Data Type  	Argument     I/O    Description
  
   exp_name     char *       I      name of the expression.

   exp_syntax   char * 	     I      syntax of the expression.

   exp_value    double       I      value of the expression.

   p_exp_id     OM_S_OBJID * O      Identifier of the created expression.

   osnum        OMuword      I      Osnum of the expression.

   p_osnum      OMuword *    O      Osnum of the created expression.

   type_rq      char         I      Type of the expressionmto create.
				    - EXP_DOUBLE : a double value
				    - EXP_TEXT   : a text string (ignore if
						   exp_value is defined)
*/

/*--------------------------------------------------------------------------*/
/* This macro is used to suppres an expression
/*--------------------------------------------------------------------------*/
#omdef exp$delete ( exp_name ^ exp_id, 
                    osnum = OM_Gw_current_OS, p_osnum = NULL, p_md_env )
#if om$specified( exp_name )
  EXP_delete_by_name ( (exp_name), (p_md_env), (p_osnum) )
#elif om$specified( exp_id )  
  EXP_delete_by_objid ( (exp_id), (osnum), (p_md_env) )
#endif
#endomdef

/*--------------------------------------------------------------------------*/
/* This macro is used to modify an expression
/*--------------------------------------------------------------------------*/
#omdef exp$modify ( exp_name ^ exp_id, 
                    osnum = OM_Gw_current_OS, p_osnum = NULL, exp_syntax )
#if om$specified( exp_name )
  EXP_modify_by_name ( (exp_name), (exp_syntax), (p_osnum) )
#elif om$specified( exp_id )  
  EXP_modify_by_objid ( (exp_id), (osnum), (exp_syntax) )
#endif
#endomdef

/*--------------------------------------------------------------------------*/
/* This macro is used to translate an exp name in its objid
/*--------------------------------------------------------------------------*/
#omdef exp$translate( exp_name, p_exp_id, p_osnum = NULL )
  EXP_translate_exp( (exp_name), (p_exp_id), (p_osnum) )
#endomdef

/*--------------------------------------------------------------------------*/
/* This macro is used to evaluate an expression without creating it
/*--------------------------------------------------------------------------*/
#omdef exp$evaluate( exp_syntax, p_exp_value )
  EXP_evaluate((exp_syntax), (p_exp_value))
#endomdef

#endif

