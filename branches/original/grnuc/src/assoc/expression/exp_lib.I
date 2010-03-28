/*

Name
  exp_lib.I

Description
  Assorted routines to support expressions.

Notes


 */

class implementation expression;
/*--------------------------------------------------------------------------*/
/*
/*                      ==================================
/*                   ===     GENERAL PURPOSE ROUTINES     ===
/*                      ==================================
/*
/* Contains :
/*
/*	EXP_create
/*	EXP_delete
/*	EXP_modify
/*	Discard
/*	EXP_strip
/*	EXPlocate
/*	EXPsubstitute
/*	EXP_universal_to_named
/*	EXP_named_to_universal
/*	EXP_gen_name
/*	EXP_gen_suffixed_name
/*	Modify_Syntax()
/*
/*--------------------------------------------------------------------------*/



#include "string.h"
/* #include "OMobjid.h" */
#include <OMminimum.h>
#include <OMmacros.h>
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include <stdio.h> 
#include <alloca.h>
%safe
#include <math.h> 
%endsafe
#include "exmacros.h"
#include "AS_status.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "expression.h"
#include "expmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "asbox.h"
#include "ASmessages.h"
#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"
#include <ctype.h>
#include "msmacros.h"
#include "referr.h"

#include "actparam.h"

#define AS_DEBUG 1
#define DEBUG 0
extern  char 		*malloc(), *realloc();
extern  GRclassid  OPP_expression_class_id,
		   OPP_ACpretend_class_id,
		   OPP_ACpl_hold_class_id,
		   OPP_ASsource_class_id,
		   OPP_text_exp_class_id;

extern int (*AStranslate) ();

from ACpretend import ACgive_downscan;

static IGRboolean aflag;
static GRspacenum osn;



/*--------------------------------------------------------------------------*/
/* This function does the construction of an expression
/*--------------------------------------------------------------------------*/
#argsused
EXP_create_double ( exp_name, exp_value, p_objid , osnum, p_osnum, 
		    type_rq, p_type_ob )
char		*exp_name;
double		exp_value;
OM_S_OBJID	*p_objid;
char		type_rq, *p_type_ob;
OMuword		osnum, *p_osnum;
/*.EXP_create_double*/
{
  char syntax[200];
  short rc;
  IGRlong status;
  GRclassid class_id;

  if (type_rq == EXP_TEXT)
     return (EXP_E_ABORT);

  class_id = OPP_expression_class_id;
  
  status = om$construct(classid = class_id, osnum = osnum,
	                p_objid =  p_objid);
  as$status(action = RET_STATUS);

  sprintf ( syntax, "%g", exp_value );


  status = om$send ( msg = message expression.init_expr_var (),
                   senderid = NULL_OBJID,
                   targetid =  *(p_objid),
                   targetos = osnum);
  as$status(action = RET_STATUS);
  
  status = om$send(msg = message expression.create( exp_name, syntax, &rc ), 
                   senderid = NULL_OBJID,
                   targetid =  *(p_objid),
                   targetos = osnum);
  if(!(status&rc&1))
  {  
     om$send(msg = message  Root.delete(1), senderid = NULL_OBJID,
     targetid =  *(p_objid), targetos = osnum);
     rc = EXP_E_ABORT;
  }
  else
      if (p_osnum) *p_osnum =  osnum;
  
  return(rc);  
}

/*--------------------------------------------------------------------------*/
/* This function does the construction of an expression
/*--------------------------------------------------------------------------*/
#argsused
EXP_create ( exp_name, exp_syntax, p_objid , osnum, p_osnum,
		    type_rq, p_type_ob )
char		*exp_name, *exp_syntax;
OM_S_OBJID	*p_objid;
char		type_rq, *p_type_ob;
OMuword		osnum, *p_osnum;
/*.EXP_create*/
{
  IGRlong status;
  char **arg_list;
  short arg_count;
  struct GRid eqn_list [MAX_VISIT_EQN];
  struct GRid match_grid;
  int eqn_count;
  void Discard();
  int stat;
  IGRchar full_name[DI_PATH_MAX], rel_dir_name[DI_PATH_MAX];
  char equation_str [DI_PATH_MAX], expr1[DI_PATH_MAX];
  IGRboolean equal_sign;
  short rc;
  GRclassid class_id;
  IGRlong msg;
  IGRchar dirname[DI_PATH_MAX];
  extern   void Error_Text();



  if (type_rq == EXP_TEXT)
  {
    if (exp_name)
    {
      if (exp_name[0] != ':')
      {
        /* build a full path and then get the osnum for that path */
        di$pwd ( p_osnum = &osnum, dirname = dirname );
        DIstrcat ( dirname, exp_name );
        di$give_osnum ( pathname = dirname, p_osnum  = &osnum );
      }
      else
      {
        /* get the osnum for the full path */
        di$give_osnum ( pathname = exp_name, p_osnum  = &osnum );
      }
    }
  
    /*
     * if this is a reference file object, exit 
     */
  


    GRcheckref(&msg,NULL,NULL,NULL,&osnum);
 
    msg = GRNOTREFFILE;
    
  
    if (msg == GRNOTREFFILE)
    {
      if (p_osnum) *p_osnum = osnum;
  
      class_id = OPP_text_exp_class_id;
  
      status = om$construct(classid = class_id,
  			  osnum = osnum,
  			  p_objid =  p_objid);
      as$status(action = RET_STATUS);
  
      EXP_gen_name(expr1, *(p_objid), (exp_name));
  
      status = om$send(msg = message expression.create( expr1, (exp_syntax), &rc ), 
  		     senderid = NULL_OBJID,
  		     targetid =  *(p_objid),
  		     targetos = osnum);
      if(!(status&rc&1))
        { om$send(msg = message  Root.delete(1), 
  	        senderid = NULL_OBJID,
  	        targetid =  *(p_objid),
  	        targetos = osnum);
          rc = EXP_E_ABORT;
        }
    }
    else
    {
      rc = EXP_INV_REF_FILE;
      Error_Text( EXP_INV_REF_FILE, "" );
    }
    return(rc);
  }
  else
  {

    if (!exp_name &&  (!strchr ( exp_syntax, '=' )))
    {
      class_id = OPP_expression_class_id;
      

      status = om$construct(classid = class_id, osnum = osnum,
    	                p_objid =  p_objid);
      as$status(action = RET_STATUS);
    
      status = om$send ( msg = message expression.init_expr_var (),
                       senderid = NULL_OBJID,
                       targetid =  *(p_objid),
                       targetos = osnum);
      as$status(action = RET_STATUS);
    
    
      status = om$send(msg = message expression.create( exp_name, exp_syntax, &rc ), 
                       senderid = NULL_OBJID,
                       targetid =  *(p_objid),
                       targetos = osnum);
      if(!(status&rc&1))
      {  
         om$send(msg = message  Root.delete(1), senderid = NULL_OBJID,
         targetid =  *(p_objid), targetos = osnum);
         rc = EXP_E_ABORT;
      }
      else
          if (p_osnum) *p_osnum =  osnum;
          
      return(rc);
    }
  
  
  
    /*
     * The osnum must come back from the parsing because we need to know
     * in what space we are creating the expression.
     */
  
  
    strcpy (equation_str, exp_syntax);
    equal_sign = TRUE;
    
    if (exp_name &&  (!strchr ( exp_syntax, '=' )))
      if (strlen (exp_name))
      {
        strcpy(equation_str, exp_name);
        strcat(equation_str, "=");
        strcat(equation_str, exp_syntax);
        equal_sign = FALSE;
      }
    
    status = Parse_eqn ( equation_str, &arg_list, &arg_count, &osnum );

    if (status != EXP_S_SUCCESS) return(status);
  
    eqn_count = 0;
    match_grid.objid = NULL_OBJID;
      
    status = Match_eqn ( equation_str, osnum, &match_grid, eqn_list, &eqn_count );
    if (status != EXP_S_SUCCESS) return(status);    
  
    if (p_objid)
      *p_objid = match_grid.objid;
  
    if (exp_name && (match_grid.objid != NULL_OBJID) && equal_sign)
    {
      stat = EXP_rec_untranslate( match_grid.objid , match_grid.osnum, full_name);
      if((stat!=DIR_S_SUCCESS)&&(stat!=DIR_W_NAME_NOT_FOUND))
        di$report_error(sts = stat);
      
      if(full_name[0] != '\0') 
       {
        di$split(pathname = full_name, name = exp_name, dirname = rel_dir_name);
       }
      
    }
    
    if (p_osnum) *p_osnum = match_grid.osnum;
  
    Discard(arg_list, arg_count); 
  
    return match_grid.objid != NULL_OBJID ? EXP_S_SUCCESS : EXP_E_ABORT;
  }  
}  

/*------------------------------------------------------------------------*/
/* This function delete an expression
/*------------------------------------------------------------------------*/
EXP_delete_by_name ( exp_name , md_env, p_osnum )
char		*exp_name;
struct GRmd_env *md_env;
OMuword         *p_osnum;
/*.EXP_delete_by_name*/
{
  OM_S_OBJID	exp_id;	
  OMuword       osnum;

  /*" exp_name'%s'\n ", exp_name*/

  if( exp$translate( exp_name = (exp_name), 
                     p_exp_id = &exp_id, p_osnum = &osnum )
      == EXP_NOT_FOUND )
    return( EXP_NOT_FOUND );

  if (p_osnum)
    *p_osnum = osnum;

  return(EXP_delete_by_objid ( exp_id, osnum, md_env ) );
}

/*------------------------------------------------------------------------*/
#argsused
EXP_delete_by_objid ( exp_id, osnum, md_env )
OM_S_OBJID	exp_id;
OMuword         osnum;
struct GRmd_env *md_env;
/*.EXP_delete_by_objid*/
{
  struct GRid my_grid;

  my_grid.objid = exp_id;
  my_grid.osnum = osnum;

  nd$wait_batch ( type      = GR_DELETED,
                  nb_obj    = 1,
                  l_object  = &my_grid );

  return EXP_SUCCESS;
}	            


/*------------------------------------------------------------------------*/
/* This macro is used to modify an expression
/*------------------------------------------------------------------------*/
EXP_modify_by_name( exp_name, exp_syntax, p_osnum )
char		*exp_name, *exp_syntax;
OMuword         *p_osnum;
/*.EXP_modify_by_name*/
{
  OM_S_OBJID	exp_id;	
  OMuword       osnum;

  if( exp$translate( exp_name = (exp_name), 
      p_exp_id = &exp_id, p_osnum = &osnum )
      == EXP_NOT_FOUND )
    return( EXP_NOT_FOUND );

  if (p_osnum)
    *p_osnum = osnum;

  return(EXP_modify_by_objid ( exp_id, osnum, exp_syntax ) );
}
/*------------------------------------------------------------------------*/
EXP_modify_by_objid( exp_id, osnum, exp_syntax )
OM_S_OBJID		exp_id;
OMuword                 osnum;
char			*exp_syntax;
/*.EXP_modify_by_objid*/
{
  IGRshort	rc;	
  IGRlong status;

  /*|send modify */
  status = om$send(msg = message expression.modify("", exp_syntax, &rc),
                   senderid = NULL_OBJID,
		   targetid =  exp_id,
		   targetos =  osnum);
  if (rc == EXP_SUCCESS)
    as$status(action = RET_STATUS);

  return rc;
}

/*---------------------------------------------------------------------------*\
 | Frees the memory allocated to store					      |
 |                                                                            |
 | INPUT  : arg_list, string array to free                                    |
 |          arg_num , number of strings in array                              |
 | CALLERS: expression.create, expression.modify, expression.clone_init       |
\*---------------------------------------------------------------------------*/
void Discard( arg_list, arg_num )
char      **arg_list;
IGRshort  arg_num;
/*.Discard*/
{ 
  int i ;

  if(arg_list) 
  {
    for( i = 0 ; i < arg_num ; i++ ) 
      if(arg_list[i]) free( ( char * ) arg_list[i] ) ;
    free( ( char * ) arg_list );
  }
} /* Discard */

/*---------------------------------------------------------------------------*/
/* take off all blanks from a string
/*---------------------------------------------------------------------------*/
void EXP_strip( string )
char *string ;
/*.EXP_strip*/
{ 
  register char *s ;

  s = string ;
  if( s != 0 && *s != '\0' )
  {
    while( *s && *s == ' ' ) s++ ;
    strcpy( string, s );
    while( *s && *s != ' ' ) s++ ;
    *s = '\0';
  }
} /* EXP_strip */

/*---------------------------------------------------------------------------*/
/*  extract the lhs part from a affectation
/*  " :a:b = x + 1" ---> ":a:b"
/*---------------------------------------------------------------------------*/
EXP_extract_lhs_rhs(exp, lhs, rhs)
char 	*exp, 
	*lhs, 
	*rhs;
/*.EXP_extract_lhs_rhs*/
{
  int i, length;
  
  /* look for "= */
  for (i = 0, length = strlen ( exp); (i < length) && (exp[i] != '='); i++);

  if (i == length)
  {
    /* no "=" in input */
    lhs[0] = '\0';
    strcpy(rhs, exp);
  }
  else
  {
    strncpy (lhs, exp, i);
    lhs[i]='\0';
    strcpy ( rhs, &(exp[i+1]) );
  }
  EXP_strip(lhs);
              
 return 1;
}

/*---------------------------------------------------------------------------*/
/*  extract the string between the first " and the last '"'
/*  ' "tout baigne "  '  --> 'tout baigne '
/*---------------------------------------------------------------------------*/
int EXP_extract_string(full_string, extrd_string)
char 	*full_string, 
	*extrd_string;
/*.EXP_extract_string*/
{
  int first, last, length;
  

  length = strlen(full_string);

  /*"extract string of %s\n",full_string */

  /* look for first '"' if any */
  for(first = 0; (first < length) && (full_string[first] == ' '); first++);
  if(full_string[first] == '"')
    {
     /*"first %d look for last cote\n",first */
     for(last = length - 1; (last >= 0) && (full_string[last] == ' '); last--);

     if(full_string[last] == '"')
      {
       strncpy ( extrd_string, &full_string[first+1], (last - first -1 ));
       extrd_string[last - first -1 ]='\0';
       return(EXP_SUCCESS);
      }
     else
      {
       return(EXP_SYNTAX_ERROR);
      }
    }
  else
    {
     /* no '"' in input we take the whole string */
     strcpy(extrd_string, full_string);
     return(EXP_SUCCESS);
    }
}

/*----------------------------------------------------------------------------*\
 | Looks  for an occurence of the string Pattern in the string Source between |
 | Returns  the pointer to the first occurence of the string if found and 0   |
 | otherwise.                                                                 |
\*----------------------------------------------------------------------------*/
char *EXPlocate( Pattern, Source)
char 		*Pattern, *Source;
/*.EXPlocate*/
{ 
 char *cp,        /* char in Pattern */
      *cs, *csp;  /* char in Source  */

 cs = Source;
 while(*cs != '\0')
  {
   csp = cs;
   cp  = Pattern;
   while(1)
    {
     if(*cp  == '\0') return cs; /* end of pattern --> found */
     if(*cp  != *csp) break;     /* string different         */
     if(*csp == '\0') break;     /* end of string  --> not found */
     csp++; cp++;
    }
   cs++;
  }

 /*| Pattern not found */
 return 0;

}

/*----------------------------------------------------------------------------*\
 | Replaces "old_name" by "new_name" in "expr", for instance:            
 |                                                                       
 | EXP_substitute( "a", "b", expr),
 | if expr = "a*beta-4" will Return expr = "b*beta-4".
 |
 | Names to be changed can consists of alphas, digits, "$", "_" and "'". 
 |                                                                       
 | "expr" is supposed to have a length of at most EXP_MAX_LENGTH.        
 |                          
 | Return codes:                                  
 |
 |     EXP_INV_INPUT : one of the args is a null pointer or points to '\0' 
 |     EXP_TOO_LONG  : max length EXP_MAX_LEN is exceeded during substitution
 |     EXP_SUCCESS   : operation completed successfully                      
 |     ( The EXP_...'s are #define'd in "expression.h"    
 |
\*----------------------------------------------------------------------------*/

IGRshort  EXPsubstitute( old_name, new_name, expr)
char 	*old_name, *new_name, *expr;
/*.EXPsubstitute */
{
  unsigned int 	lon, lnn, lex, len, index;
  char  *pos,*old_pos;
  char 	tmp[EXP_MAX_LEN+1];
  char *EXPlocate();
  char *tmpptr;
  int   stop;

  /*"expr %s, old_name %s new name %s\n", expr, old_name, new_name */

  if(    old_name == 0 || *old_name == '\0'  || new_name == 0
      || expr     == 0 || expr      == '\0' ) return( EXP_INV_INPUT ) ;

  lon = strlen( old_name ) ;
  lnn = strlen( new_name ) ;
  lex = strlen( expr     ) ;

  if( lex > EXP_MAX_LEN ) return( EXP_TOO_LONG ) ;

  old_pos = expr;
  tmp[0] = '\0';
  index = 0;
  stop = FALSE;
  while(1)
  {
   pos = EXPlocate( old_name, old_pos);
   if(pos)
   {
     /*
      * Find the pattern in the source string.  Mark the position in "pos".
      * Use "tmpptr" to mark the character before and after "pos".
      * If "tmpptr" is in [a-zA-Z0-9$_] then "pos" is not a valid expression.
      * If "tmpptr" is NOT in [a-zA-Z0-9$_] then "pos" is a valid expression.
      * If "pos" is a valid expression, then replace old_name with new_name.
      * If "pos" is NOT a valid expression, then do NOT replace old_name.
      * NOTE : isalnum returns non zero if TRUE and zero if FALSE.
      *        "stop" is TRUE  for invalid expressions.
      *        "stop" is FALSE for   valid expressions.
      */

     if ( old_name[0] != '\\' )
     { /*
        * If old_name starts with '\\', we are trying to put the name back in
        * place for the index number; therefore, do not check to see if valid
        */

       if ( pos == expr )
       { /*
          * If "pos" is the start of the source string,
          * then no need to check the character before "pos"
          */

         tmpptr = pos + lon;
         if ( isalnum(*tmpptr) || (*tmpptr == '$') || (*tmpptr == '_') )
           stop = TRUE;
       }
       else if ( pos == expr + lex )
       { /*
          * If "pos" is the end of the source string,
          * then no need to check the character after "pos"
          */

         tmpptr = pos - 1;
         if ( isalnum(*tmpptr) || (*tmpptr == '$') || (*tmpptr == '_') )
           stop = TRUE;
       }
       else
       {
         /*
          * If "pos" is in the middle of the source string,
          * then check the character before and after "pos"
          */

         tmpptr = pos - 1;
         if ( isalnum(*tmpptr) || (*tmpptr == '$') || (*tmpptr == ':') || (*tmpptr == '_') )
           stop = TRUE;

         if ( ! stop )
         {
           tmpptr = pos + lon;
           if ( isalnum(*tmpptr) || (*tmpptr == '$') || (*tmpptr == '_') )
             stop = TRUE;
         }
       }
     }

     if ( stop )
     { /*
        * "pos" is an invalid expression; do NOT replace old_name
        */

       len = (pos-old_pos)+lon;
       if(index+lnn+len > EXP_MAX_LEN) return EXP_TOO_LONG;
       strncpy(tmp+index,old_pos,len);
       index += len;
       tmp[index] = '\0';
       old_pos = pos + lon;
       stop = FALSE;
     }
     else
     { /*
        * "pos" is a valid expression; replace old_name with new_name
	*/

       len = pos-old_pos;
       if(index+lnn+len > EXP_MAX_LEN) return EXP_TOO_LONG;
       OM_BLOCK_MOVE(old_pos, tmp+index, len);
       OM_BLOCK_MOVE(new_name,tmp+index+len, lnn);
       index += len + lnn;
       tmp[index] = '\0';
       old_pos = pos + lon;
     }
   }
   else
   {
     /* old name not found, copy waht remains of expression */
     if(strlen(old_pos) + index > EXP_MAX_LEN) return EXP_TOO_LONG;
     strcat (tmp, old_pos);
     break;
   }
  }

  strcpy(expr,tmp);
 /*"output %s\n",expr */
  return(EXP_S_SUCCESS);
}

/*---------------------------------------------------------------------------*\
/*
/* EXP_translate_exp : 
/*	look for a named object and check that it is an expression
/*
/*   	return : 
/*		EXP_SUCCESS if found
/*		EXP_INV_INPUT if exist but if not expression subclass
/*		EXP_NOT_FOUND otherwise
/*
/*---------------------------------------------------------------------------*/
EXP_translate_exp(expr1, expr_id, p_osnum )
char 		*expr1;
OM_S_OBJID 	*expr_id;
OMuword         *p_osnum;
/*.EXP_translate_exp*/
{   
  IGRint 	stat;
  OMuword       cur_osnum;

  *expr_id  = NULL_OBJID;

  aflag = pwIsActivationOn();
  if (aflag)
  {
     cur_osnum = pwGetActiveOs();
  }
  else
  {
     ex$get_cur_mod ( osnum = &cur_osnum );
  } 
 
  /*  we treat the case of \objid */
  if (expr1[0] == '\\') 
  {
    if (expr1[1] != '-')
      fprintf( stderr, "In EXP_translate_exp, bad identifier\n" );

    sscanf(&expr1[2], "%d", expr_id);
    /*"expr_id : %d\n", *expr_id */
    {
      long status;
      long msg;
      struct ret_struct  rst;

      /*|send give_structure */
      status = om$send(msg=message NDnode.NDgive_structure(&msg, &rst, NULL ),
                       senderid = NULL_OBJID,
		       targetid =  *expr_id,
		       targetos =  cur_osnum);
      as$status();

      if (!(rst.type & parameter_generic) || !(status&1))
      {
        /*|structure is NOT legal */
	*expr_id = NULL_OBJID;
        return( EXP_NOT_FOUND );
      }
    }

    /*|good expression.has been found */
    if (p_osnum)
      *p_osnum = cur_osnum;

    return EXP_S_SUCCESS;
  }

  if(AStranslate)
   {
    /*| Call of AStranslate, good luck ... */
    stat = AStranslate( expr1, expr_id, p_osnum, NULL);
   }
  else
   {
        aflag = pwIsActivationOn();
        if (aflag)
        {
           osn = pwGetActiveOs();

           stat = di$translate( objname = expr1, osnum = osn,p_objid = expr_id, p_osnum = p_osnum );
        }
        else
        {
            stat = di$translate( objname = expr1, p_objid = expr_id, p_osnum = p_osnum );
        }
    }

    if(stat != DIR_S_SUCCESS)
    { 
        char expr2[DI_PATH_MAX];
        /*| try stupid user name*/
        di$cvt_name_from_input(u_path = expr1,
        		       s_path = expr2);
        stat=di$translate( objname = expr2, p_objid = expr_id, p_osnum = p_osnum );
    }

    if((stat!=DIR_S_SUCCESS) && (stat!=DIR_W_NAME_NOT_FOUND))
    {
        di$report_error(sts = stat);
        return(EXP_NOT_FOUND);
    }

    if (!(IF_NULL_OBJID ( *expr_id )))
        return(EXP_SUCCESS);
    else
        return(EXP_NOT_FOUND);
} 


/*----------------------------------------------------------------------
/*									
/* transform  "\123 +\234 +\345"  into	"a +b +c"			
/*
/* input  : 
/*	formula  : a string containing the formula		
/*      rel_flag : 
/*	  REL_TO_GPTR_PREFIX means that the expression 
/*		   name must be given relative to GPTR_common_prefix
/*	  REL_TO_CREAT_DIR means that the expression 
/*		   name must be given relative to the creation directory
/*		       
/* output : trans_formula received the transformed string( it must be
/*		dimensioned at EXP_MAX_LEN at entering).	
/*								
/* returned value :
/*	EXP_S_SUCCESS if ok
/*	EXP_E_ABORT if any problem
/*
/*----------------------------------------------------------------------*/
int EXP_universal_to_named(os_num, exp_id, formula, trans_formula, rel_flag)
OMuword		os_num;
OM_S_OBJID	exp_id;
char		*formula, *trans_formula;
int		rel_flag;
/* EXP_universal_to_named */
{
    int     	nbparents;
    IGRint        i,stat;
    IGRlong status;
    IGRchar       exp_name[EXP_MAX_LEN], my_name[EXP_MAX_LEN],
	back_index[10],
	rel_dir_name[DI_PATH_MAX];
	

    struct GRid *buffer,*parent,*aparent, /* list of parents */
      _parent[20];

    /*"exp_id: %d\n", exp_id  */
    /*"rel_flag: %d\n", rel_flag */

    /* Initialization */
    aparent = NULL;

    strcpy(trans_formula, formula);

    if( rel_flag==REL_TO_CREAT_DIR)
    {
        my_name [0] = '\0';
        stat = EXP_rec_untranslate(exp_id,os_num,my_name);
        if (stat != DIR_S_SUCCESS)
        {
            if (stat == DIR_W_NAME_NOT_FOUND)
                sprintf ( exp_name, "\\%d", exp_id );
            else
                di$report_error( sts = stat );
            rel_dir_name [0] = '\0';
        }
        else
        {
            di$split(pathname = my_name, name = exp_name, dirname = rel_dir_name);
            strcat(rel_dir_name,":");
        }

        strcpy(back_index, "\\-1");

        if(EXPsubstitute( back_index, exp_name, trans_formula) != EXP_SUCCESS)
        {
            fprintf( stderr, "bad substitution\n" );
            goto error;
        }
    }
    else
    {     
        fprintf(stderr," EXP_universal_to_named error : unknown rel_flag\n");
        return(EXP_E_ABORT);
    }


    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
			      NULL,0,&buffer,0,OM_K_MAXINT,&nbparents),
                   senderid = NULL_OBJID,
	           targetid = exp_id);
    as$status(action = RET_STATUS);

    /* Copy from tmp buffer */
    if(nbparents>20)
    {
        aparent = (struct GRid *) om$malloc(size = nbparents*sizeof(struct GRid));
        if(aparent == NULL) return (OM_W_ABORT);
        parent = aparent;
    }
    else
    {
        parent = _parent;
    }

    for( i = 0 ; i < nbparents ; i++ ) parent[i]=buffer[i];

    for( i = 0 ; i < nbparents ; i++ )
    {
        long              msg;
        struct ret_struct rs;
        struct GRmd_env   md_env;

        md_env.md_id.objid = NULL_OBJID;
        md_env.md_env.matrix_type = MAIDMX;
        MAidmx ( &msg,  md_env.md_env.matrix );
        rs.type = 0x0;
        om$send(msg = message NDnode.NDgive_structure(&msg, &rs, &md_env),
	     senderid = NULL_OBJID,
	     targetid = parent[i].objid,
	     targetos = parent[i].osnum);
        if(rs.type & parameter_generic)  
        {
            exp_name [0] = '\0';
            stat = EXP_rec_untranslate(parent[i].objid,parent[i].osnum,exp_name);
            if(( stat != DIR_S_SUCCESS)&&( stat != DIR_W_NAME_NOT_FOUND))
            di$report_error( sts = stat );

            /*"name after untranslate: %s\n", exp_name */
            if(exp_name[0] != '\0')
            {
                char cur_dir [DI_PATH_MAX], dir_tmp [DI_PATH_MAX];

                /*" exp_name %s\n", exp_name */

                /*
                 * 03/11/92 - Jimmy Dodd - Changed from EXPsubstitute to di$split
                 */
                di$pwd ( dirname = cur_dir );
                di$split(pathname = exp_name, name = rel_dir_name, dirname = dir_tmp);
                if (!strcmp ( dir_tmp, cur_dir ))
                  strcpy(exp_name, rel_dir_name);
                /*
                  Replaced object id again by channel id.
                 */
                sprintf(back_index, "\\%d", i);    	
                DIConvertToShortPath(exp_name);
                if(EXPsubstitute( back_index, exp_name, trans_formula) != EXP_SUCCESS)
                {
                  fprintf( stderr, "bad substitution\n" );
                  goto error;
                }
                /*"trans_formula : '%s'\n", trans_formula */
            }
        }
    }
    /*" new formula %s\n", trans_formula */

    if(aparent != NULL) om$dealloc(ptr = aparent);
    return( EXP_S_SUCCESS );

error :
    if(aparent != NULL) om$dealloc(ptr = aparent);
    return (OM_W_ABORT);
}

/*---------------------------------------------------------------------------*/
#argsused
int EXP_named_to_universal(os_num, exp_id, formula, trans_formula)
OMuword		os_num;
OM_S_OBJID	exp_id;
char		*formula, *trans_formula;
{
   return( EXP_S_SUCCESS );
}

/*---------------------------------------------------------------------------*/

EXP_gen_name(gnd_name, exp_id, old_name)
char		*gnd_name, *old_name;
OM_S_OBJID	exp_id;
/*.EXP_gen_name*/
{
  if (old_name != NULL) 
    if (old_name [0] != '\0') 
      strcpy( gnd_name, old_name); 
    else 
      sprintf ( gnd_name, "xp%d", exp_id ); 
  else
    strcpy( gnd_name, ""); 
  return 1;
}

/* -------------------------------------------------------------------------*/

int EXP_gen_suffixed_name(new_name, old_name) 
char	*new_name, *old_name;
/*.EXP_gen_suffixed_name*/
{ 
  short int  ln, i, j; 
  OM_S_OBJID dummid; 

  strcpy(new_name, old_name); 
  ln = strlen( old_name ); 
  if(ln==0) { strcpy(new_name, "X"); ln=1;} 

  for (i=ln-1; i>=0; i--) 
  if(new_name[i] == '_') break; 

  j=0; 

  if ((i == -1) || (i != ln-1 ))
    i = ln; 
  else 
  if (scanf( &new_name[i+1], "%d", &j))  j=0; 

  new_name[i+1] = '\0'; 
  do 
  { 
    sprintf ( &new_name[i], "_%d", i++); 
  } 
  while(  exp$translate(exp_name = new_name, 
        		p_exp_id = &dummid,
        		p_osnum  = (GRspacenum *)NULL) != EXP_NOT_FOUND ); 
  return(1);
}

/*
-----------------------------------------------------------------------
- Error_Text
------------
Type   : void
Input  : ErrNum  , code of the error ( int )
	Data_ptr, pointer to ... ( int * )

Error_Text is  used by Parse  and  Evaluate to  output the  error messages.  The
purpose of the argument ptr is to  pass additionnal information of variable data
type by casting. Error_Text  prepares  the  error  message and  then  calls  the
user function set by the user to output them ( see below ).

Thouh Error_Text is mostly dedicated to  internal use, it  may be called by the
user to produce ready-made messages in the following cases:

- if you have a = b + ... and then b = ... a ...
Error_Text( EXP_RECUR_DEF )

- if an id ( var_name ) in the right-hand side has not been defined
Error_Text( EXP_UNDEF_RHS, ( int * ) var_name )

- if you do not want a variable to be deleted
Error_Text( DEL_IMPOSSIBLE )

- if a variable has been defined before
Error_Text( EXP_ALREADY_EXISTS )


- Error_Function
----------------

Type   : void
Input  : user_fct, user supplied output function ( void (*user_fct)() )

Sets the user defined function called by Error_Text for the output of the error
messages. This function must be of type void and have two arguments, the first
of type char * which will point to the error message, the second of type short
int which will contain the error code, for instance:

static int rc ;

void user_fct( msg, errcode )

char      *msg    ;
short int errcode ;

{ ....
  printf( "ERROR: %s\n", msg ) ;
  rc = errcode                 ;
  ...
}

Sample call : Error_Function( user_fct ) ;

If no function is provided, no messages will be output.

Possible values for errcode :

EXP_INV_INPUT      : invalid input string ( null string or null pointer )
EXP_INV_CHAR       : invalid character in expression
EXP_TOO_LONG       : input string length exceed EXP_MAX_LEN
EXP_MEM_FAIL       : memory allocation failure       
EXP_ALREADY_EXISTS : left hand-side already exists
EXP_SYNTAX_ERROR   : syntax error detected
EXP_ACOS_DOM_ERR   : argument domain error in acos function
EXP_ARG_NUM_ERR    : wrong argument count
EXP_ASIN_DOM_ERR   : argument domain error in asin function
EXP_ATAN2_DOM_ERR  : argument domain error in atan2 function
EXP_CONV_ERR       :
EXP_COS_RNG_ERR    : range error for cos function
EXP_DEL_IMPOSSIBLE : variable not removable
EXP_EVAL_ERR       : evaluation error
EXP_EXP_RNG_ERR    : range error for exp function
EXP_INV_CHAR       : invalid character in expression
EXP_LOG_DOM_ERR    : argument domain error in log function
EXP_OVERFLOW       : overflow
EXP_POW_DOM_ERR    : argument domain error in pow function
EXP_POW_RNG_ERR    : range error for pow function
EXP_RECUR_DEF      : left hand-side depends upon itself
EXP_SIN_RNG_ERR    : range error for sin function
EXP_SQRT_DOM_ERR   : argument domain error in sqrt function
EXP_TAN_RNG_ERR    : range error for tan function
EXP_UNDEF_RHS      : undefined variable in right hand-side
EXP_UNDERFLOW      : underflow
EXP_ZERO_DIVIDE    : division by zero
------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*\
| Multiple occurences of an entery in the list "arglist" are reduced to one. |
| It is then verified that  the lhs does  not appear in  the rhs, i.e.  that |
| "arglist[0]" points to a string different from the other "arglist[i]",i>0. |
| INPUT  : arglist , string array of arguments.                              |
|          ArgCount, pointer to number of arguments ( rhs + lhs )            |
| OUTPUT : arglist , new argument list                                       |
|          ArgCount, new number of arguments                                 |
| RETURNS:                                                                   |
|         - EXP_SUCCESS   if it completed successfully                       |
|         - EXP_RECUR_DEF if the lhs is also in the rhs                      |
|         - EXP_MEM_FAIL  if memory allocation failed                        |
\*----------------------------------------------------------------------------*/
short int Compress_ArgList( arglist, ArgCount )
char       **arglist;
short int  *ArgCount;
/*.Compress_ArgList*/
{ 
  register int  i, j, k, l;
  register char *Id;
  short    int  Narg, Oarg;
  extern   void Error_Text();

  Oarg = Narg = *ArgCount ; i = 1 ;
  while( i < Narg )
  { 
    Id = arglist[i] ; k = ++i ;
    for( j = k ; j < Narg ; j++ ) 
    if( strcmp( Id, arglist[j] ) != 0 )
    {
      l = strlen( arglist[j] ) ;
      arglist[k] = realloc( arglist[k], ( l + 1 )  * sizeof( char ) ) ;
      if( arglist[k] == NULL )
      { Error_Text( EXP_MEM_FAIL, (int *) "in parsing." ) ;
        return( EXP_MEM_FAIL );
      }
      strcpy( arglist[k], arglist[j] ) ; k++  ;
    }
    else  
    ( *ArgCount )--;
    Narg = *ArgCount ;
  } /* while */

  /* Free superflous space
  -----------------------*/
  if( Narg < Oarg )
  for( i = Narg ; i < Oarg ; i++ )
  free( ( char * ) arglist[i] ) ;

  return( EXP_SUCCESS ) ;
} /* Compress_ArgList */

/*----------------------------------------------------------------------------*\
| Adds a string  of "string_length"  characters at "string_index" ( supposed |
| to be the bottom index + 1 ) in "array".                                   |
|                                                                            |
| INPUT  : array        , string array to be extended                        |
|          string_index , index of last position + 1                         |
|          string_length, length of the string to be added                   |
| RETURNS: pointer to new string array if succefull, and  NULL if the memory |
|          memory allocation failed.                                         |
\*----------------------------------------------------------------------------*/
char **Add_String( array, string_index, string_length )
char **array;
int  string_index, string_length ;
{ 
  char **a ; 

  a = ( char ** ) realloc( ( char ** ) array               ,
        		   string_index * sizeof( char * ) ) ; 

  if( a == NULL ) return( a ) ;

  a[string_index-1] = ( char * ) malloc( string_length * sizeof( char ) ) ;

  if( a[string_index-1] == NULL ) return( ( char ** ) 0 ) ;

  return( a ) ;
}

/*--------------------------------------------------------------
/* Pointer to user-supplied function to output error messages
/* ------------------------------------------------------------ */
%safe
static void (*Error_Msg)() = 0;
%endsafe

/*--------------------------------------------------------------------------*\
| Sets the error message output function.                                  |
\*--------------------------------------------------------------------------*/
void Error_Function( user_fct )
void (*user_fct)() ;
{ 
  Error_Msg = user_fct ; 
}

/*----------------------------------------------------------------------------*\
| Error message procedure. ErrNum < 0 for syntax errors , > 0 for evaluation |
| errors. Data_pt is a pointer to pass additional information.               |
\*----------------------------------------------------------------------------*/
void Error_Text( ErrNum  ,
        	 Data_pt )
int ErrNum, *Data_pt ;
{ 
  char ErrMess[EXP_MAX_LEN+1] ;

  /* No function to output messages supplied : exit
  if( Error_Msg == 0 ) return ;
  ---------------------------------------------- */

  if( ErrNum <= 0 )
  switch( ErrNum )
  { case   0 : ex$message(buff = ErrMess, msgnumb = AS_S_syntax_error);
        break;
  case  -1 : ;
  case  -2 : ex$message (buff = ErrMess, msgnumb = AS_S_begin_var_id);
        break;
  case  -3 : ;
  case  -4 : ;
  case  -5 : ;
  case  -6 : ;
  case  -7 : ex$message(buff = ErrMess, msgnumb = AS_S_syntax_error);
        break;
  case  -8 : ex$message(buff = ErrMess, msgnumb = AS_S_Funct_id);
        break;
  case  -9 : ex$message(buff = ErrMess, msgnumb = AS_S_Bad_arg_list);
        break;
  case -10 : ex$message(buff = ErrMess, msgnumb = AS_S_Arg_separate);
        break;
  case -11 : ex$message(buff = ErrMess, msgnumb = AS_S_Id_begin_ltr);
        break;
  case -12 : ex$message(buff = ErrMess, msgnumb = AS_S_Parm_id_begin);
        break;

  case -13 : ex$message(buff = ErrMess, msgnumb = AS_S_illegal_id_char,  type="%c",
						 var = `*( (char *) Data_pt)`);
						 
        break;

  case -14 : ex$message(buff = ErrMess, msgnumb = AS_S_Constant_bad);
        break;

  case -15 :
  case -16 : ex$message(buff = ErrMess, msgnumb = AS_S_Const_illegal, type="%c",
						 var = `*( (char *) Data_pt)`);
        break;

  case -17 : ex$message(buff = ErrMess, msgnumb = AS_S_decimal_illegal,  type="%c",
						 var = `*( (char *) Data_pt)`);
        break;

  case -18 : ex$message(buff = ErrMess, msgnumb = AS_S_Exponent_bad);
        break;
  case -19 : ex$message(buff = ErrMess, msgnumb = AS_S_Exponent_begin);
        break;
  case -20 : ex$message(buff = ErrMess, msgnumb = AS_S_Expon_illegal, type="%c",
						 var = `*( (char *) Data_pt)`);
        break;

  case -21 : ex$message(buff = ErrMess, msgnumb = AS_S_Constant_follow);
        break;
  case -22 : ex$message(buff = ErrMess, msgnumb = AS_S_Unknown_funct);
        break;
  case -23 : ex$message(buff = ErrMess, msgnumb = AS_S_plus_minus);
        break;
  case -24 : ex$message(buff = ErrMess, msgnumb = AS_S_mult_divide);
        break ;
  case -25 : ex$message(buff = ErrMess, msgnumb = AS_S_syntax_error);
        break;
  }
  else
  switch( ErrNum )
  { case EXP_INV_CHAR      :
        	     ex$message(buff = ErrMess, msgnumb = AS_S_Invalid_char,  
			type = "%c%o",
			var = `*( (char *) Data_pt ), *( (char *) Data_pt )`);
		      break;

    case EXP_INV_INPUT     :  ex$message(buff = ErrMess, msgnumb = AS_S_Invalid_input);
		      break;
    case EXP_TOO_LONG      :
	     ex$message(buff = ErrMess, msgnumb = AS_S_Exp_too_long, type = "%d",  
			var = `EXP_MAX_LEN`);
		      break;
    case EXP_MEM_FAIL      :
	     ex$message(buff = ErrMess, msgnumb = AS_S_Exp_mem_fail, type = "%s",
		      var = `(char *) Data_pt`);
		      break;
    case EXP_ARG_NUM_ERR   :
	     ex$message(buff = ErrMess, msgnumb = AS_S_Arg_num_err);
		      break;
		      
    case EXP_RECUR_DEF     :  ex$message(buff = ErrMess, msgnumb = AS_S_Recur_def);
		      break;
		      
    case EXP_UNDEF_RHS     :  ex$message(buff = ErrMess, msgnumb = AS_S_Undef_rhs,
				 type = "%s", var = `(char *) Data_pt`);
		      break;

    case EXP_CONV_ERR      :  ex$message(buff = ErrMess, msgnumb = AS_S_Invalid_const);
		      break;
		      
    case EXP_SQRT_DOM_ERR  :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Sqrt_dom_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;
    case EXP_POW_DOM_ERR   :  
	      ex$message(buff = ErrMess, msgnumb = AS_S_Pow_dom_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;
    case EXP_POW_RNG_ERR   :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Pow_rng_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_ASIN_DOM_ERR  : 
	      ex$message(buff = ErrMess, msgnumb = AS_S_Asin_dom_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_ACOS_DOM_ERR  :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Acos_dom_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_ATAN2_DOM_ERR :  
    ex$message(buff = ErrMess, msgnumb = AS_S_Atan2_dom_err,
	       type = "%le%le",
	       var = `*( (double *) Data_pt ), *( (double *) ( Data_pt + 1 ))`);
    break;
    case EXP_LOG_DOM_ERR   :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Log_dom_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_EXP_RNG_ERR   : 
	      ex$message(buff = ErrMess, msgnumb = AS_S_Exp_rng_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;
    case EXP_COS_RNG_ERR   :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Cos_rng_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_SIN_RNG_ERR   :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Sin_rng_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_TAN_RNG_ERR   :
	      ex$message(buff = ErrMess, msgnumb = AS_S_Tan_rng_err, 
			 type = "%le",
			 var = `*( (double *) Data_pt )`);
	      break;

    case EXP_EVAL_ERROR    :  ex$message(buff = ErrMess, msgnumb = AS_S_Eval_error); 
		      break;
		      
    case EXP_ZERO_DIVIDE   :  ex$message(buff = ErrMess, msgnumb = AS_S_Zero_divide);
		      break;
		      
    case EXP_UNDERFLOW     :
	     ex$message(buff = ErrMess, msgnumb = AS_S_Underflow,
			type = "%.0lf", 
			var = `*( (double *) Data_pt )`);                                
	     break;
    case EXP_OVERFLOW      :
	     ex$message(buff = ErrMess, msgnumb = AS_S_Overflow,
			type = "%.0lf", 
			var = `*( (double *) Data_pt )`);                                
	     break;

    case EXP_DEL_IMPOSSIBLE:  
 ex$message(buff = ErrMess, msgnumb = AS_S_Del_impossible); 
		      break;
		      
    case EXP_ALREADY_EXISTS:
 ex$message(buff = ErrMess, msgnumb = AS_S_Already_exists); 
		      break;
		      
    case EXP_E_LOOP:  ex$message(buff = ErrMess, msgnumb = AS_S_Loop); 
	    break;
		     
    case EXP_INV_REF_FILE: ex$message(buff=ErrMess,msgnumb=AS_S_new_expr_ref); 
	    break;

    default : printf("Error number : %d\n", ErrNum );
  }

  if( ErrNum < 0 ) ErrNum = EXP_SYNTAX_ERROR;

  /*(*Error_Msg)( ErrMess, ( short int ) ErrNum  */

  UI_status ( ErrMess );

} /* Error_Text */        

/*---------------------------------------------------------------------------*\
/*
/* EXP_find_exp : look for a named object and check that it is an expression
/*   *rc = EXP_SUCCESS if found and EXP_NOT_FOUND otherwise
/*
/*---------------------------------------------------------------------------*/
EXP_find_exp(expr1, expr_id, owner_id, rc)
char 		*expr1;
OM_S_OBJID 	*expr_id, *owner_id;
IGRshort 	*rc;
/*.EXP_find_exp*/
{   
  IGRint 	stat;
  OMuword       ob_classid, cur_osnum;

  fprintf(stderr, "****************************************************\n");
  fprintf(stderr, "***** call to EXP_find_exp should desepear and *****\n");
  fprintf(stderr, "***** be replaced by the macro exp$translate   *****\n");
  fprintf(stderr, "***** which is defined in expmacros.h          *****\n");
  fprintf(stderr, "****************************************************\n");

  *owner_id = NULL_OBJID;
  *expr_id  = NULL_OBJID;

  aflag = pwIsActivationOn();
  if (aflag)
  {
    cur_osnum = pwGetActiveOs();
  }
  else
  {
    ex$get_cur_mod(osnum = &cur_osnum);
  }

  /*  we treat the case of \objid */
  if(expr1[0] == '\\')
  {
    sscanf(&expr1[1], "%d", expr_id);
    if(om$is_objid_valid(objid = *expr_id, osnum = cur_osnum) != OM_S_SUCCESS)
    {
      *rc = EXP_NOT_FOUND;
      return(EXP_NOT_FOUND);
    }
    om$get_classid( objid = *expr_id, 
        	    p_classid = &ob_classid );
    if(om$is_ancestry_valid ( subclassid = ob_classid,
        		      superclassname = "expression" ) != OM_S_SUCCESS)
    {
      *rc = EXP_INV_INPUT;
      return(EXP_INV_INPUT);
    }
    *rc = EXP_SUCCESS;
    return(EXP_S_SUCCESS);
  }

  if (aflag)
  {
    stat = di$translate( objname = expr1,osnum = cur_osnum, p_objid = expr_id );
  }
  else
  {
    stat = di$translate( objname = expr1, p_objid = expr_id );
  }
  if((stat!=DIR_S_SUCCESS) && (stat!=DIR_W_NAME_NOT_FOUND))
    di$report_error(sts = stat);

  if(stat == DIR_W_NAME_NOT_FOUND)
    *expr_id = NULL_OBJID;

  if (!(IF_NULL_OBJID ( *expr_id )))
    *rc = EXP_SUCCESS;
  else
    *rc = EXP_NOT_FOUND;

 return EXP_S_SUCCESS;
} /* EXP_find_exp */

/* 
   get the name of an expression
   there are 3 differents ways to get the name of an expression

-  regular expression : di$untranslate

-  pretend : the name is the concatenation of the macro name and the 
             corresponding foot name

-  expression in a new macro or in a directory : The name must be asked to
             the owner.

BECAUSE THE MESSAGE GRgetname is not declared high enought, it is not
understand by these different classes. It is the reason why we test the classid
to do different treatment.

Another solution would be to declare the message in the different classes
and to send it with a "make message"
*/

EXP_rec_untranslate(objid,osnum,name)
OM_S_OBJID objid;
GRspacenum osnum;
char *name;
/*.EXP_rec_untranslate*/
{
 struct GRid tmp_grid,owner;
 int status,sts,msg;
 int len;
 char loc_name[DI_PATH_MAX];
 OM_S_MESSAGE mess;
 struct 
      {int *succ;struct GRid *go_obj; char *footname;} tmp;
 GRclassid classid;

/* initialze loc_name */
 loc_name [0] = '\0';

 /* Perform if necessary a recursive untranslate */
 tmp_grid.objid = objid;
 tmp_grid.osnum = osnum;
 
 /*" initial %d\n",objid */
/* status = om$send(msg = message NDnode.ASreturn_go(&tmp_grid,NULL,NULL),
/* 		  senderid = NULL_OBJID,
/*		  targetid = objid,
/*		  targetos = osnum);
/* if(!(status&1))
/*   {
/*    tmp_grid.objid = objid;
/*    tmp_grid.osnum = osnum;
/*   }
/******/

 status = om$get_classid( objid = objid,
			  osnum = osnum,
			  p_classid = &classid);

 if(om$is_ancestry_valid(superclassid = OPP_ACpretend_class_id,
			 subclassid = classid) == OM_S_SUCCESS)
  {
   /*| The object is a pretend */
   /*| Get the macro and its name */
   status = DIR_W_NAME_NOT_FOUND; 
   sts = om$get_objid_at_index(objid     = objid,
                           osnum          = osnum,
                           p_chanselect   = &ND_father,
                           index          = 0,
                           osnumaddr      = &owner.osnum,
                           objidaddr      = &owner.objid);
   if(sts&1)
    {
     status = di$untranslate(objid = owner.objid,
                             osnum = owner.osnum,
                             objname = name);
     if(status == DIR_S_SUCCESS)
       {
	len = strlen(name);
	name[len]=':';
        sts=om$send(msg = message ACpretend.ACgive_downscan(name+len+1),
		      senderid = NULL_OBJID,
		      targetid = objid,
		      targetos = osnum);
        if(!(sts&1)) status = DIR_W_NAME_NOT_FOUND;
       }
    }

  }
  else 
  {
    status = om$get_objid_at_index ( objid     = objid,
      osnum 	     = osnum,
      p_chanselect   = &AS_to_owner,
      index          = 0,
      osnumaddr      = &owner.osnum,
      objidaddr      = &owner.objid );
    /*
     * Make sure the owner is not a save set
     */
    if (status == OM_S_SUCCESS)
    {
      extern GRclassid OPP_GRsvset_class_id;
      GRclassid        classid;
      
      status = om$get_classid ( objid = owner.objid,
        osnum = osnum, p_classid = &classid );
      if (om$is_ancestry_valid(superclassid = OPP_GRsvset_class_id,
            subclassid = classid) == OM_S_SUCCESS)
        status = OM_W_ABORT;
    }
    
    if (status == OM_S_SUCCESS)
    {
      /* The object is in a macro or is an associative attribute */
    
      owner.objid = objid;
      owner.osnum = osnum;
      status = DIR_W_NAME_NOT_FOUND;
      while(1)
      {
        /*| get and translate its owner */
        sts = om$get_objid_at_index( objid     = owner.objid,
            osnum     = owner.osnum,
            p_chanselect   = &AS_to_owner,
            index          = 0,
            osnumaddr      = &owner.osnum,
            objidaddr      = &owner.objid);
        if(!(sts&1)) break;
        status = di$untranslate(objid = owner.objid, 
            osnum = owner.osnum,
            objname = name);
        if(status != DIR_S_SUCCESS) continue;
    
        /*| Get the name of the element in the owner */
    
        tmp.footname = &loc_name[1];
        tmp.go_obj = &tmp_grid;
        tmp.succ = &msg;
        status = om$get_classid( objid = owner.objid,
            osnum = owner.osnum,
            p_classid = &classid);
        status = om$make_message( classid = classid,
            methodname = "ACgive_path",
            size = sizeof(tmp),
            p_arglist = &tmp,
            p_msg = &mess);
        if ( !(status & 1) )
	         break;
    
        status = om$send(msg = &mess,   
            targetid = owner.objid,
            targetos = owner.osnum,
            senderid = NULL_OBJID);
        if(status & msg&1)
        {
          loc_name[0]=':';
          /*"name %s loc_nane %s\n",name,loc_name*/
          strcat(name,loc_name);
          status = DIR_S_SUCCESS;
        }
        else
        {
          status = DIR_W_NAME_NOT_FOUND;
        }
      }
    }
    else
    {
      status = om$get_classid( objid = objid,
          osnum = osnum,
          p_classid = &classid);
      if(om$is_ancestry_valid(superclassid = OPP_ASsource_class_id,
          subclassid = classid) == OM_S_SUCCESS)
      {
        OM_S_OBJECT_LINKAGE    list [1];
        OMuint                 count;
        extern OM_S_CHANSELECT AS_listeners;
        /*
          * We get the child of the ASsource
          */
    
        om$get_channel_objects ( objid = objid, 
            osnum = osnum,
            p_chanselect = &AS_listeners, 
            list = list,
            size = 1,
            count = &count );
        osnum = list [0].osnum;
        objid = list [0].S_objid;
      }
    
      /*" %d %d is a regular expression\n",objid,osnum */
      status = di$untranslate(objid = objid, 
          osnum = osnum,
          objname = name);
      /*"name %s\n",name */
    }
  }
 
  if(status != DIR_S_SUCCESS)
  {
   name[0] = '\0';
  } 
  
  return(status);
}

/* modifies the syntax given by the user to suit the new requirements
*/
void Modify_Syntax(in_syntax,mod_syntax)
IGRchar *in_syntax;
IGRchar *mod_syntax;
{

 while (*in_syntax != '\0')
   {
   if(*in_syntax == '\\')
     {
     *mod_syntax++ = *in_syntax++;
     *mod_syntax++ = '-';
     } 
   else
     *mod_syntax++ = *in_syntax++;
   }
  *mod_syntax='\0';
      
}
end implementation expression;
