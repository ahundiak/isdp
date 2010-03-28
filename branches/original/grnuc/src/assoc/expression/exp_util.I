/*

Name
  exp_util.I

Description
 Expressions are mathematical  expressions with which parameters and vari- 
 ables are evaluated. They depend upon other parameters and variables. An  
 occurence of a parameter or a variable  on both sides of the equal  sign  
 is not permitted.                                                         

Notes


 */

/*###########################################################################
/*
/*                    class expression implementation file                   
/*                                                                           
/* Expressions are mathematical  expressions with which parameters and vari- 
/* ables are evaluated. They depend upon other parameters and variables. An  
/* occurence of a parameter or a variable  on both sides of the equal  sign  
/* is not permitted.                                                         
/* Date 3 September (revised 	HGB 11/08/1986)                                 
/*				S.F. May 26 87
/*###########################################################################
/*
/*   Contains :
/*
/*            Method give_formula
/*            Function EXPBuildFormula
/*            Method create
/*            Method list
/*            Method make_orphan
/*            Method init_expr_var
/*--------------------------------------------------------------------------*/
class implementation expression;

/* from interface import wakeup; */

#include <tools.h>
#include <stdio.h> 
#include <string.h> 
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMindex.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "gocmacros.h"
%safe
#include "math.h"
%endsafe
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "drawparam.h"

#include "actparam.h"

#define AS_DEBUG

static IGRboolean aflag;
static GRspacenum osn;

extern char       *malloc();
extern void       Error_Text(), free(), Discard();
extern void 	  Modify_Syntax();

/*------------------------------------------------------------------------
 | Returns the  formula in a understandable format
 | a conversion take place from the universal format
 |   \123 + \345 - 234  to  a + :dir1:b - c
 |
 | OUTPUT : char   *formula, string containing the formula. 
 |	    formula is an array of size EXP_MAX_LEN
 |
 | HISTORY: ????    creation
 |          jhw     fixed problem where syntax that was too long caused abort
\*-------------------------------------------------------------------------*/
method give_formula ( char *formula )
{ 
  char my_name [DI_PATH_MAX];
  int  EXPBuildFormula ( char *, OM_S_OBJID, char *, double , char * );
  
  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );

  di$untranslate ( objid = my_id, objname = my_name );
  EXPBuildFormula ( my_name, my_id, me->pretty_print, me->value, formula );
  
  return EXP_S_SUCCESS;
}


/*

Name
  EXPBuildFormula

Abstract
  Builds a formula using a name, an id, a pretty_print and a value

Synopsis
  EXPBuildFormula ( char *my_name, OM_S_OBJID my_id, char *pretty_print, 
                    double expression_value, char *formula )

Description

Return Value
  EXP_S_SUCCESS
  
Keywords
  associative,directory,equation

History
  12/22/93 : henry bequet : created

 */
EXPBuildFormula ( char *my_name, OM_S_OBJID my_id, char *pretty_print, 
                  double expression_value, char *formula )
{
  char *ptr, value [DI_PATH_MAX];
  int  ok, nb_parents, status;
  char double_value[64];
  char *EXPlocate();
  IGRboolean is_error, is_too_long = FALSE;

  *formula = '\0';
  sprintf ( double_value, " [%g]", expression_value );
  if (EXPlocate( "nan", double_value))
    is_error = TRUE;
  else
    is_error = FALSE;
  
  di$split ( pathname = my_name, name = my_name );
  if (pretty_print [0])
  {
    /*
     * No need to display matching if we have only no parents
     */
    status = om$send ( msg = message NDnode.NDget_objects ( ND_ROOT, NULL, 0, NULL, 0,
        OM_K_MAXINT, &nb_parents ), targetid = my_id );
    as$status ( action = RET_STATUS );
    if (nb_parents)
      if (is_error)
        sprintf ( value, " [%s, error]", my_name );        
      else
      {
        if (expression_value != MAXDOUBLE)
          sprintf ( value, " [%s, %g]", my_name, expression_value );
        else
          sprintf ( value, " [%s, ????]", my_name );        
      }
    else
      if (is_error)
        sprintf ( value, " [error]");
      else 
      {
        if (expression_value != MAXDOUBLE)
          sprintf ( value, " [%g]", expression_value );
        else
          sprintf ( value, " [????]");
      }
    if (strlen ( pretty_print ) < ( EXP_MAX_LEN - strlen ( value )))
      EXP_universal_to_named ( OM_Gw_current_OS, my_id, pretty_print, 
        formula, REL_TO_CREAT_DIR );
    else
      is_too_long = TRUE;

    if (!is_too_long)
    {
        /*
         * If I have only digits in my syntax then there is no need to 
         * display (i.e. duplicate) my value
         */
        for (ptr = formula; *ptr != '='; ptr++)
          if (!(((*ptr >= '0') && (*ptr <= '9')) || (*ptr == '.')))
            break;
        if (*ptr == '=')
          ok = 1;
        else
        {
            *(ptr = strchr ( formula, '=' )) = '\0';
            ok = !strcmp ( formula, my_name );
            *ptr = '=';
        }
        
        if (ok)  
        {
            for (ptr++; *ptr; ptr++)
              if (!(((*ptr >= '0') && (*ptr <= '9')) || (*ptr == '.')))
                break;
            if (!*ptr)
              *value = '\0';
        }
    }
    else
    {
        ex$message(buff = formula, msgnumb = AS_S_Syntax_long);
    }
  
    strcat ( formula, value );
  }
  else
    sprintf ( formula, "%s = ????", my_name );
  
  return EXP_S_SUCCESS;
} 


method create (	char *name; char *syntax; short *rc ) 
{ 
  char       wkg1_syntax[DI_PATH_MAX],wkg_syntax [DI_PATH_MAX];
  int        status = OM_S_SUCCESS;
  GRobjid    tmp_objid;
  GRspacenum tmp_osnum;

  *rc = EXP_SUCCESS;
    

  if (!strchr ( syntax, '=' ))
    if (name)
    {
      if (*name)
      {
        aflag = pwIsActivationOn();
        if (aflag)
        {
           char path[]="usr";
           osn = pwGetActiveOs();
           status = di$add_name ( objid = my_id, 
                                  path = path,
                                  objname = name , 
                                  osnum = osn);
        }
        else
        {
           status = di$add_name ( objid = my_id, objname = name );
        }
        if (status == DIR_E_NAME_DUP)
          if (di$translate ( objname = name, p_objid = &tmp_objid, p_osnum = &tmp_osnum ) & 1)
            if ((tmp_objid == my_id) && (tmp_osnum == OM_Gw_current_OS))
              status = 1;
        if (status & 1)
          sprintf ( wkg_syntax, "%s=%s", name, syntax );
      }
      else
        {
	Modify_Syntax(syntax,wkg1_syntax);
        sprintf ( wkg_syntax, "\\-%lu=%s", my_id, wkg1_syntax );
        }
    }
    else
      sprintf ( wkg_syntax, "\\-%lu=%s", my_id, syntax );
  else
    strcpy ( wkg_syntax, syntax );
  
  if (status & 1)
    status = exp$create ( exp_syntax = wkg_syntax );

  *rc = status;
  return (OM_S_SUCCESS);
}


/* ---------------------------------------------------------------------------
/* This method returns the name and value of the expression
/*
/* dist=sqrt(x*x+y*y+z*z)                                            [123.34]
/* or if the expression is degraded:                                         
/* dist=sqrt(x*x+y*y+z*z)                                          [degraded]
/*                                                                           
/* UPDATE : char   *formula, string array containing the formula.            
/* RETURNS: EXP_S_SUCCESS or an OM status if an OM routine should fail        
/* ---------------------------------------------------------------------------*/
method list ( 	char *formula )
{
  char		my_name[EXP_MAX_LEN];
  char		my_formula[EXP_MAX_LEN];
  IGRint 	rc;
  struct ret_struct  rst;
  IGRlong status,msg;
  int len;

  formula[0] = '\0';
  my_name [0] = '\0';
 
  rc = EXP_rec_untranslate(my_id , OM_Gw_current_OS , my_name);
  if((rc!=DIR_S_SUCCESS)&&(rc!=DIR_W_NAME_NOT_FOUND))
    di$report_error(sts = rc);
  /*" name after untranslate : %s\n", my_name */
  
  if(!strcmp(my_name, ""))
    sprintf(my_name, "\\%d", my_id);

  status=om$send (msg = message NDnode.NDgive_structure (&msg, &rst, NULL ),
            	  targetid = my_id);
  as$status(action = RET_STATUS);

  if (rst.type & parameter_generic)
  {
    if (rst.type == double_type)
    {
      status = om$send (msg = message expression.give_formula( my_formula ),
            		targetid = my_id);
      as$status(action = RET_STATUS);

/* All this shit to be sure to not have a to long formula */

      len = strlen(my_formula);
      if(len > EXP_MAX_LEN-4)
       {
        my_formula[EXP_MAX_LEN-4] = '\0';
	len = EXP_MAX_LEN-4;
       }
      my_name[EXP_MAX_LEN-len-4] = '\0';
     

      sprintf(formula, "%s , %s", my_name, my_formula);
    }
    else
      sprintf(formula, "%s = unknown ??", my_name);
  }
  return(EXP_S_SUCCESS);
} /* Method list */

/*---------------------------------------------------------------------------*\
 | Modifies  an  expression : checks that  the new  one is valid ( as regards |
 | syntax and existence of variables on the rhs ) then disconnects  from  the |
 | former channels and make new connections.                                  |
 |                                                                            |
 | INPUT  : new_expr, pointer to string containing new expression             |
 |          rc      , address of Return code ( see expression.S for values )  |
 | RETURNS: EXP_S_SUCCESS or an OM status if an OM routine should fail        |
\*---------------------------------------------------------------------------*/
method modify ( char *name; char *syntax; short  *rc )
{
  long        status;
  char        save_pretty_print [EXP_MAX_LEN]; 
  IGRboolean  cycle_formed;
  struct GRid match_list[1], my_grid; 
  int num_matched;
  double original_value;
  struct GRid parent_grid[MAX_NUM_EQN_VAR];
  int num_parent;
  int num_var;
  struct GRid var_grid[MAX_NUM_EQN_VAR];
  int stat;


  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );


  strcpy( save_pretty_print, ME.expression->pretty_print);

  /* get the roots */
  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,parent_grid,MAX_NUM_EQN_VAR,
                                                   NULL, 0, MAX_NUM_EQN_VAR - 1,
                                                   &num_parent),
                 targetid = my_id);
  as$status(action = RET_STATUS);
  
  if (num_parent > MAX_NUM_EQN_VAR)
  {
    Error_Text( EXP_MEM_FAIL, (int *) "to modify" ) ;
    return EXP_MEM_FAIL;
  }

  if (num_parent > 0)
  {
    /* calling make_orphan */
    status = om$send(msg = message expression.make_orphan(),
                     targetid = my_id);
    as$status(action = RET_STATUS);
  }

  original_value = me->value;  
  status = om$send ( msg = message expression.init_expr_var (),
      targetid = my_id );
  as$status(action = RET_STATUS);

  me->value = original_value;

  status = om$send ( msg = message expression.create ( name, syntax, rc ),
                                     targetid = my_id );
  as$status(action = RET_STATUS);
                                       
  if (!((*rc) & 1))
  { 
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    num_matched = 0;
    status = om$send(msg = message expression.match(my_grid, num_parent, parent_grid,
                  save_pretty_print, FALSE, 
  	          &cycle_formed, match_list, &num_matched), targetid = my_id);
  }
  else if (me->pretty_print[0] == '\0') /* If now the equation is matched to */
  {                                     /* some other variable */
    me->value = MAXDOUBLE;
        
    if (original_value != MAXDOUBLE)
    {
      /* get my children */
      status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,var_grid,MAX_NUM_EQN_VAR,
                                                           NULL, 0, 3,
       						       &num_var),
      		  targetid = my_id);
      as$status(action = RET_STATUS);
    
      if (num_var > 0)
      {
        status = om$send(msg = message expression.NDchange_node( NULL ),
                     	       targetid = my_id);
        as$status(action = RET_STATUS);
        GR_NOTIFY_LISTENERS(&stat,&stat,GR_GEOM_MODIFIED);
      }  
    }  
      
  }


  return (EXP_S_SUCCESS); 

} /* Method modify */


/*---------------------------------------------------------------------------*/
/* this Method will disconnect all the parents with a parameter type 
/*---------------------------------------------------------------------------*/
method make_orphan ()
{
  long status;

/*  int count,i;
/*  struct GRid *list;
/*  struct ret_struct  rst;
/*  IGRlong status,msg;
/*
/*  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
/*					 NULL,0,&list,0,OM_K_MAXINT,&count),
/*		   targetid = my_id);
/*  as$status(action = RET_STATUS);
/*
/*  for (i = 0; i < count; i++)
/*  {
/*    status = om$send(msg = message NDnode.NDgive_structure(&msg, &rst, NULL ),
/*              	     targetid = list[i].objid,
/*              	     targetos = list[i].osnum);
/*    as$status(action = RET_STATUS);
/*    if (rst.type & parameter_generic)
/*    {
/*     status = om$send(msg = message NDnode.NDdisconnect(1,&list[i]),
/*		      targetid = my_id);
/*     as$status(action = RET_STATUS);
/*    }
/*  }
/*******/

  status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
		   targetid = my_id);
     as$status(action = RET_STATUS);
  return ( EXP_S_SUCCESS );
}


method DIgive_output ( char *formula )
{
  char my_name [DI_PATH_MAX];
  
  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );

  strcpy ( my_name, formula );
  EXPBuildFormula ( my_name, my_id, me->pretty_print, me->value, formula );
  
  return EXP_S_SUCCESS;
}


end implementation expression ;
