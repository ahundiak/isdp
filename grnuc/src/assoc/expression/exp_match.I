/*

Name
  exp_match.I

Description
  This file has the new methods and new routines for equational constraints.

Notes


 */

/*
###########################################################################
/*
/* This file has the new methods and new routines for equational constraints.
/* 
/*
/*  Initial revision: Kapil Singh
/*
/*
/*--------------------------------------------------------------------------*/
class implementation expression;

/*  */

#include <tools.h>
#include <stdio.h> 
#include <alloca.h>
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
#include "exmacros.h"
%safe
#include "math.h"
%endsafe
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "referr.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "drawparam.h"
#include "GMmacros.h"

#include "actparam.h"


#define AS_DEBUG

static IGRboolean aflag;

extern char       *malloc();
extern void       Error_Text(), free(), Discard();
extern struct GRid    solve_var_grid;
extern            IGRboolean in_cycle;


extern  short 	int Compress_ArgList();

extern	char 	*input_stream; /* keyboard line simulation */
extern	int 	input_index;   /* keyboard line simulation */



extern char		G_parse_type;	/* tell if it is the first parse or 	*/
				/* a compute parse with the internal format */

extern int 		NO_more_eval;	/* an evaluation has failed no use to go on */
extern short	int 	G_id_count; 	/* number of identifier found or given */
extern char		**G_id_list;	/* list of identifier   */ 
extern  char 	**Add_String ();

/*
 *  This function does the following:
 *  
 *  (1) Checks the syntax of the equation entered by the User.
 *  (2) Extracts the variables in the expression.
 *  (3) Creates storage for variables if there is no assigned storage.
 *
 */


/*

Name
  Parse_eqn

Abstract

 *  This function does the following:
 *  
 *  (1) Checks the syntax of the equation entered by the User.
 *  (2) Extracts the variables in the expression.
 *  (3) Creates storage for variables if there is no assigned storage.

Synopsis
  char 		*syntax;     IN the equation enetered by the User
  char		***pid_list; OUT the identifiers in the eqn
  short int	*pid_count;  OUT the # of identifiers in the eqn
  GRspacenum    *p_osnum;    OUT the osnum in which the expression is created

Description
  YACC is used to parse the equation

Return Value
  returns error code on syntax error
  
Notes

Index

Keywords
  equation,parsing

History
  03/04/93 : Kapil Singh : created

 */
int Parse_eqn ( syntax, pid_list, pid_count, p_osnum )
  char 		*syntax;
  char		***pid_list;
  short int     *pid_count;
  GRspacenum    *p_osnum;
{

  OM_S_OBJID    *arg_objid;
  char		new_name[EXP_MAX_LEN];
  char 		dirname[DI_PATH_MAX];  
  char 		exp_name[DI_PATH_MAX];  
  
  OMuword	cur_mod_osnum;
  IGRlong	status;
  GRclassid 	class_id;
  int 		i;  
  char  	back_index[20];
  IGRlong 	msg;
  int num_var;
  struct GRid var_grid[MAX_NUM_EQN_VAR];
  char full_var_name[DI_PATH_MAX];
  char		**tmp_id_list;
  short int	        tmp_id_count;
  int 		var_cnt;
  
  G_parse_type = FIRST_PARSE;
  NO_more_eval = 0; 		/* we start with good intentions */
  G_id_count = 0;		/* going to be determined	*/
  num_var = 0;
  
  G_id_list  = (char **)malloc(sizeof(char *));
  if(G_id_list == NULL)
  {
    Error_Text ( EXP_MEM_FAIL, (int *)"for parsing_1");
    return(EXP_MEM_FAIL);
  }

  tmp_id_list  = (char **)malloc(sizeof(char *));
  if(tmp_id_list == NULL)
  {
    Error_Text ( EXP_MEM_FAIL, (int *)"for parsing_19");
    return(EXP_MEM_FAIL);
  }

  if (syntax)
    input_stream = syntax;
  else
  {
    Error_Text( EXP_INV_INPUT, "" );
    return(EXP_SYNTAX_ERROR);
  }
  
  input_index=0;

  /* call yacc and Returns its result */

  if(expyparse ())
  {
    return(EXP_SYNTAX_ERROR);
  }

/*
 * Make a temporary copy of the G_id_list since it is global
 * and Parse_eqn() can be called within Parse_eqn() from as$make_source().
 */
  for (var_cnt = 0; var_cnt < G_id_count; var_cnt++)
  {
    tmp_id_list = Add_String( tmp_id_list, var_cnt+1, 
                             (strlen(G_id_list [var_cnt])+1) );
    strcpy(*(tmp_id_list + var_cnt), G_id_list [var_cnt]);
  }
  tmp_id_count = G_id_count;       


  *pid_count = G_id_count;
  *pid_list = G_id_list ;

  if (tmp_id_count == 0) 
  {
    Error_Text( EXP_INV_INPUT, "" );
    return( EXP_SYNTAX_ERROR);    
  }

  /* Check existence of variables */
  arg_objid=(OM_S_OBJID *)malloc( tmp_id_count * sizeof(OM_S_OBJID));

  if( arg_objid == NULL )
  { fprintf(stderr, "Parse_eqn can't malloc \"arg_objid\".\n"); return(OM_W_ABORT); }

  aflag = pwIsActivationOn();
  if (aflag)
  {
     cur_mod_osnum = pwGetActiveOs();
  }
  else
  {
     ex$get_cur_mod ( osnum = &cur_mod_osnum );
  }
  /*
   * We make the assumption that we can only create an expression in the
   * current module->will have to be re-visited for macro libraries.
   */

  for (i = 0; i < tmp_id_count; i++)
    if (tmp_id_list [i] [0] != '\\')
    {
      GRspacenum osnum;

      *p_osnum = cur_mod_osnum;
        
      strcpy(full_var_name, tmp_id_list [i]);
      
      if((tmp_id_list [i][0]) == '$')
        DIConvertToLongPath(full_var_name);
  
      status = exp$translate ( exp_name = full_var_name,
          p_osnum = &osnum, p_exp_id = &arg_objid [i] );

      if (status == EXP_NOT_FOUND)
      { 
         /* check for reference file */
        
        strcpy(exp_name, full_var_name);
    
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
    
        /*
         * if this is a reference file object, exit 
         */
      
/***** Commented for RFA

        GRcheckref(&msg,NULL,NULL,NULL,&osnum);
      
        if ((msg != GRNOTREFFILE) && (osnum != cur_mod_osnum))
        {
          ex$message(msgnumb = AS_S_new_expr_ref);

          for( i = 0 ; i < num_var ; i++ )
          {
            status = om$send(msg = message Root.delete ( 1 ),
            		     senderid = NULL_OBJID,
                    	     targetid = var_grid[i].objid,
                    	     targetos = cur_mod_osnum);
            as$status(action = RET_STATUS);
          }
          return(EXP_INV_NAME);
        }
*****************/
  
        class_id = OPP_expression_class_id;
   
        status = om$construct(classid = class_id,
                              osnum = cur_mod_osnum,
                              p_objid =  &arg_objid[i]);
        as$status(action = RET_STATUS);
        
        if (num_var >= MAX_NUM_EQN_VAR)
        {
          Error_Text( EXP_MEM_FAIL, (int *) "for parsing_2" ) ;
          return EXP_MEM_FAIL;
        }
        
        var_grid[num_var].objid = arg_objid[i];
        var_grid[num_var].osnum = cur_mod_osnum;
    
        num_var++;
  
        EXP_gen_name(new_name, arg_objid[i], full_var_name);
  
        /* add the expression to the directory sub-system */
        status = di$add_name( objname = new_name, objid   = arg_objid[i] );
        if(status !=DIR_S_SUCCESS) 
        {
          ex$message(msgnumb = AS_S_InvNam);
          return(EXP_INV_NAME);
        }
        
        status = om$send(msg = message expression.init_expr_var(),
        		     senderid = NULL_OBJID,
                	     targetid = arg_objid[i],
                	     targetos = cur_mod_osnum);
        as$status(action = RET_STATUS);
        ex$message ( msgnumb = AS_S_EqnCrea, type = "%s", var = `new_name` );  
      }
      else
      {
        struct GRid grid;
        
        grid.osnum = osnum;
        grid.objid = arg_objid [i];
 
        GRcheckref(&msg,NULL,NULL,NULL,&osnum);

        if ((msg != GRNOTREFFILE) && (osnum != cur_mod_osnum) && (tmp_id_count ==1))
          *p_osnum = osnum;
        else if ((msg == GRNOTREFFILE) && (tmp_id_count ==1))
          *p_osnum = osnum;
        else 
        {
          as$make_source ( go_grid = grid, as_os = cur_mod_osnum,
              as_grid = &grid );
          arg_objid [i] = grid.objid;
        }
      }
  
      sprintf ( back_index, "\\-%lu", arg_objid [i] );
      EXPsubstitute ( tmp_id_list [i], back_index, syntax );
    }
    else
    {
      if (tmp_id_list [i] [1] != '-')
      {
        ex$message(msgnumb = AS_S_InvNam);
        return(EXP_INV_NAME);
      }

/*
THE NEXT FEW LINES CODE HAVE BEEN COMMENTED OUT

      sscanf(&(G_id_list [i] [2]), "%d", &eqn_id);
      if(om$is_objid_valid(objid = eqn_id, osnum =   *p_osnum) != OM_S_SUCCESS)
      {
        ex$message(msgnumb = AS_S_InvNam);
        return(EXP_INV_NAME);
      }
 
      om$get_classid( objid = eqn_id, osnum =   *p_osnum,
                      p_classid = &ob_classid );
      if(om$is_ancestry_valid ( subclassid = ob_classid,
  			      superclassid = OPP_expression_class_id ) != OM_S_SUCCESS)
      {

        return(EXP_INV_NAME);
      }
*/
    }
  

  /* Collect garbage */
  if (arg_objid)
    free ( ( char * ) arg_objid );


  Discard(tmp_id_list,tmp_id_count);
 
  return EXP_SUCCESS;

}

/*

Name
  Match_eqn

Abstract
 *  The following routine Match_eqn() finds a matching for a new expression.*
 *  The matching algorithm used is a Depth First Search Type algorithm.   *
 *  The traversal of equations and variables also yields the equations    *
 *  which comprise the overconstrained set.                               *

Synopsis
char *exp_syntax; IN the expr syntax
GRspacenum osnum; IN The osnum we can do the match in
struct GRid *pmatch_grid; OUT the Grid matched to the equation
struct GRid eqn_list [];  OUT The GRIDs re-matched so far
int *peqn_count;  OUT the number of equations re-matched so far 

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
int Match_eqn (exp_syntax, osnum, pmatch_grid, eqn_list, peqn_count)
char *exp_syntax;
GRspacenum osnum	/* The osnum we can do the match in 		IN  */;
struct GRid *pmatch_grid;
struct GRid eqn_list [];
int *peqn_count;
{
  IGRboolean    match_found, cycle_formed;
  IGRlong	status;
  struct GRid match_list [MAX_VISIT_EQN];
  int num_matched;
  struct GRid curr_var_grid;
  
  num_matched = 0;
  match_found = FALSE;
  cycle_formed = FALSE;
  pmatch_grid->objid = NULL_OBJID;

  curr_var_grid.osnum = osnum;
  curr_var_grid.objid = NULL_OBJID;
  
  status = find_underconstr_var (curr_var_grid, exp_syntax, &match_found, &cycle_formed, 
                                eqn_list, peqn_count, match_list, &num_matched);
  if (status & 1)
  {  
    if (cycle_formed)
    {
      ex$message(msgnumb = AS_S_GMLoop);      
    }
    else if (!match_found)
    {
      ex$message(msgnumb = AS_S_Overconstr_eqn);

      DIhilite_lines ( eqn_list, *peqn_count ); 

    }
    else if ((match_found) && (!cycle_formed))
      *pmatch_grid = match_list[num_matched - 1];
  }  

  status = reset_eqn(eqn_list, peqn_count);
  return status;
}


/*

Name
  reset_eqn

Abstract
 The following routine reset_eqn() resets the visited flag 
 in the expression object

Synopsis
struct GRid eqn_list []; IN the equations to be reset
int *peqn_count;  IN the # of equations to be reset

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
int reset_eqn (eqn_list, peqn_count)
struct GRid eqn_list [];
int *peqn_count;
{
  IGRlong	status;
  int 		counter;
  
  for (counter = 0; counter < *peqn_count; counter++)
  {
    status = om$send (msg = message  NDnode.NDchg_state ( ND_VISITED, 0 ),
	              senderid = NULL_OBJID,
  	              targetos = eqn_list[counter].osnum,
        	      targetid = eqn_list[counter].objid );
    as$status(action = RET_STATUS);
  }
    
  return EXP_S_SUCCESS;
}

/*

Name
  find_underconstr_var

Abstract
  Find a underconstrained variable for the new eqn

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
int find_underconstr_var (curr_var_grid, exp_syntax, pmatch_found, pcycle_formed, 
                          eqn_list, peqn_count, match_list, pnum_matched)
struct GRid curr_var_grid;   /* the eqn is currently matched to this var */
char *exp_syntax;
IGRboolean *pmatch_found;
IGRboolean *pcycle_formed;
struct GRid eqn_list[]; 
int *peqn_count;
struct GRid match_list[]; 
int *pnum_matched;
{
  char 		*pstr;
  int  		stat;
  long 		status;
  IGRboolean	is_matched;
  struct GRid	var_grid, null_grid;
  struct GRid parent_grid[MAX_NUM_EQN_VAR];
  int num_parent;
                    
  *pmatch_found = FALSE;      
  pstr = exp_syntax;
  stat = EXP_S_SUCCESS;

  if (curr_var_grid.objid != NULL_OBJID)
  {
    /* get the "curr_var_grid" roots */
    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,parent_grid,MAX_NUM_EQN_VAR,
                                                     NULL, 0, MAX_NUM_EQN_VAR - 1,
                                                     &num_parent),
  		   senderid = NULL_OBJID,
       		   targetos = curr_var_grid.osnum,
                   targetid = curr_var_grid.objid );
    as$status(action = RET_STATUS);
    
    if (num_parent > MAX_NUM_EQN_VAR)
    {
      Error_Text( EXP_MEM_FAIL, (int *) "for matching_1" ) ;
      return EXP_MEM_FAIL;
    }
  
    if (num_parent > 0)
    {
      /* calling make_orphan */
      status = om$send(msg = message expression.make_orphan(),
    		   senderid = NULL_OBJID,
      		   targetos = curr_var_grid.osnum,
                   targetid = curr_var_grid.objid );
      as$status(action = RET_STATUS);
    } 
  
  }
      
  while ((stat == EXP_S_SUCCESS) && !(*pmatch_found))
  {
     stat = get_eqn_var ( curr_var_grid, num_parent, parent_grid, &pstr, 1, &var_grid );
     if (stat == EXP_S_SUCCESS)
     {
       status = om$send(msg = message expression.is_var_matched ( &is_matched ),
           senderid = NULL_OBJID, targetos = var_grid.osnum, targetid = var_grid.objid );
       as$status(action = RET_STATUS);
       
        if (!is_matched)
        {
  	  status = om$send(msg = message expression.match (curr_var_grid,  
  	                           num_parent, parent_grid,exp_syntax, 
  	                           FALSE, pcycle_formed, match_list, pnum_matched), 
		   senderid = NULL_OBJID,
      		   targetos = var_grid.osnum,
                   targetid = var_grid.objid );
          as$status(action = RET_STATUS);
          
          *pmatch_found = TRUE;

	  if (*pcycle_formed)
	  {
            status = reset_match(match_list, pnum_matched);
            as$status(action = RET_STATUS);
          }
        }
     }
  }

  pstr = exp_syntax;  
  stat = EXP_S_SUCCESS;

  while ((stat == EXP_S_SUCCESS) && !(*pmatch_found))
  {
     stat = get_eqn_var ( curr_var_grid,  num_parent, parent_grid, &pstr, 1, &var_grid );
     if (stat == EXP_S_SUCCESS)
     {
        status = om$send(msg = message expression.find_match(pmatch_found, 
                               pcycle_formed, eqn_list, peqn_count,
                               match_list, pnum_matched),
                               senderid = NULL_OBJID,
      		               targetos = var_grid.osnum,
                	       targetid = var_grid.objid);
        as$status(action = RET_STATUS);
        if ((*pmatch_found) && !(*pcycle_formed))
        {
  	  status = om$send(msg = message expression.match (curr_var_grid, 
  	                            num_parent, parent_grid, exp_syntax, 
  	                           FALSE, pcycle_formed, match_list, pnum_matched), 
		           senderid = NULL_OBJID,
      		           targetos = var_grid.osnum,
                           targetid = var_grid.objid );
          as$status(action = RET_STATUS);
	  if (*pcycle_formed)
	  {
            status = reset_match(match_list, pnum_matched);
            as$status(action = RET_STATUS);
          }
        }
     }    
  }

  if (((*pcycle_formed) || !(*pmatch_found)) && (curr_var_grid.objid != NULL_OBJID))
  {
    null_grid.objid = NULL_OBJID;
    status = om$send(msg = message NDnode.NDconnect
                           (num_parent, parent_grid, null_grid, ND_NEW),
    		   senderid = NULL_OBJID,
      		   targetos = curr_var_grid.osnum,
                   targetid = curr_var_grid.objid );
      as$status(action = RET_STATUS);

    as$status(action = RET_STATUS);
  }  
  
  return EXP_S_SUCCESS;
}



/*

Name
  get_eqn_var

Abstract
 Gets the next variable in the equation 
 
Synopsis
  
  struct GRid curr_var_grid; IN  the equation is currently matched to this variable 
  int num_parent;            IN  the number of parents
  struct GRid parent_grid[]; IN  the parent list
  char **ppeqn_string;       IN equation string to search and reset 
  int        skip_source     IN We want to skip the source objects (matching)IN  ;  
  struct GRid *p_grid;       OUT GRid of variable that was found 
  
Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
int get_eqn_var (curr_var_grid,  num_parent, parent_grid, ppeqn_string, skip_source, p_grid )
struct GRid curr_var_grid;/* the equation is currently matched to this variable */
int num_parent;
struct GRid parent_grid[];
char **ppeqn_string;      /* equation string to search and reset */
int        skip_source	  /* We want to skip the source objects (matching)IN  */;  
struct GRid *p_grid;      /* GRid of variable that was found */
{
  IGRlong	status;  
  IGRboolean found;
  char back_index[30];
  int i;
  GRclassid classid;
  extern GRclassid OPP_ASsource_class_id;
  IGRboolean is_objid;
  int chan_index;
  
  found = FALSE;
  is_objid = FALSE;

  while (!found)
  {
    /* Only accept local references */
    if (**ppeqn_string == '\\')
      found = TRUE;
    else if (**ppeqn_string == '\0')
    {
      p_grid->objid = NULL_OBJID;
      return EXP_NOT_FOUND;
    }
    else
    {
      ++(*ppeqn_string);
      if (skip_source)
      {
        status = skip_ifcomp_function(ppeqn_string);
        as$status(action = RET_STATUS);       
        status = skip_C_conditional(ppeqn_string);
        as$status(action = RET_STATUS);       
        status = skip_if_then_else(ppeqn_string);
        as$status(action = RET_STATUS);               
      }  
    }

  }

  if (found)
  {
    i = 0;
    ++(*ppeqn_string);
    if (**ppeqn_string == '-')
    {
      is_objid = TRUE;
      ++(*ppeqn_string);
    }

    while ((**ppeqn_string >= '0') && (**ppeqn_string <= '9'))
    {
      back_index[i] = **ppeqn_string;
      ++i;
      ++(*ppeqn_string);
    }
    back_index [i] = '\0';
    if (is_objid)
    {
      p_grid->osnum = curr_var_grid.osnum;
      if (curr_var_grid.objid == NULL_OBJID)
        sscanf ( back_index, "%lu", &(p_grid->objid) );
      else if (strcmp(back_index, "1") == 0)
        p_grid->objid = curr_var_grid.objid;
      else
        sscanf ( back_index, "%lu", &(p_grid->objid) );
    }
    else
    {
      sscanf (back_index, "%d", &chan_index);      
      *p_grid = parent_grid[chan_index];          
    }
  
  
    if (skip_source)
    {
      if (om$get_classid ( objid = p_grid->objid, osnum = p_grid->osnum, 
              p_classid = &classid ) & 1)
        if ( om$is_ancestry_valid ( superclassid = OPP_ASsource_class_id,
            subclassid = classid ) == OM_S_SUCCESS)
        {
          /*
           * We don't want to match against a variable in a different space
           */
          p_grid->objid = NULL_OBJID;
          return get_eqn_var( curr_var_grid,  num_parent, parent_grid, 
                               ppeqn_string, skip_source, p_grid );
        }
    }
  }

  return EXP_S_SUCCESS;
}

/*

Name
  reset_match

Abstract
  reset to previous matching for equations matched so far

Synopsis
struct GRid match_list[];  IN the # of eqns matched so far
int *pnum_matched;         IN the eqns matched so far

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
int reset_match(match_list, pnum_matched)
struct GRid match_list[]; 
int *pnum_matched;
{
  IGRlong	status;
  int 		counter;
  char		exp_syntax[EXP_MAX_LEN];
  char		exp_syntax_2[EXP_MAX_LEN];  
  struct GRid	curr_var_grid;
  struct GRid	curr_var_grid_2;  
  struct GRid parent_grid[MAX_NUM_EQN_VAR];
  struct GRid parent_grid_2[MAX_NUM_EQN_VAR];  
  int num_parent, i;
  int num_parent_2;  

/*
 * printf("beginning of reset_match *********************\n\n");
 */
/*
 FIprint_lines();
*/
  if (*pnum_matched)
  {
    status = om$send (msg = message  expression.give_syntax(exp_syntax_2),
	              senderid = NULL_OBJID,
  	              targetos = match_list[0].osnum,
        	      targetid = match_list[0].objid );
    as$status(action = RET_STATUS);

    curr_var_grid_2 = match_list[0];
                      
    if (curr_var_grid_2.objid != NULL_OBJID)
    {
      /* get the "curr_var_grid" roots */
      status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,parent_grid_2,MAX_NUM_EQN_VAR,
                                                       NULL, 0, MAX_NUM_EQN_VAR - 1,
       						       &num_parent_2),
         		     senderid = NULL_OBJID,
         		     targetos = curr_var_grid_2.osnum,
                             targetid = curr_var_grid_2.objid );
      as$status(action = RET_STATUS);
      
      if (num_parent_2 > MAX_NUM_EQN_VAR)
      {
        Error_Text( EXP_MEM_FAIL, (int *) "for matching_3" ) ;
        return EXP_MEM_FAIL;
      }
    }
  }

  for (counter = 0; counter < (*pnum_matched - 1); counter++)
  {

    strcpy (exp_syntax, exp_syntax_2);
    curr_var_grid = curr_var_grid_2;
    num_parent = num_parent_2;
    for (i = 0; i < num_parent_2; i++)
      parent_grid[i] = parent_grid_2[i];
    
    status = om$send (msg = message  expression.give_syntax(exp_syntax_2),
	              senderid = NULL_OBJID,
  	              targetos = match_list[counter + 1].osnum,
        	      targetid = match_list[counter + 1].objid );
    as$status(action = RET_STATUS);

    curr_var_grid_2 = match_list[counter + 1];
                      
    if (curr_var_grid_2.objid != NULL_OBJID)
    {
      /* get the "curr_var_grid" roots */
      status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,parent_grid_2,MAX_NUM_EQN_VAR,
                                                       NULL, 0, MAX_NUM_EQN_VAR - 1,
       						       &num_parent_2),
         		     senderid = NULL_OBJID,
         		     targetos = curr_var_grid_2.osnum,
                             targetid = curr_var_grid_2.objid );
      as$status(action = RET_STATUS);
      
      if (num_parent_2 > MAX_NUM_EQN_VAR)
      {
        Error_Text( EXP_MEM_FAIL, (int *) "for matching_4" ) ;
        return EXP_MEM_FAIL;
      }
    }
  
    status = om$send(msg = message expression.match (curr_var_grid, 
                           num_parent, parent_grid, exp_syntax, 
                           TRUE, NULL, NULL, NULL), 
                           senderid = NULL_OBJID,
		           targetos = match_list[counter + 1].osnum,
                           targetid = match_list[counter + 1].objid);
    as$status(action = RET_STATUS);
       
  }
  if (*pnum_matched)
  {
    status = om$send(msg = message expression.init_expr_var(),
  		     senderid = NULL_OBJID,
                       targetos = match_list[0].osnum,
                       targetid = match_list[0].objid );
    as$status(action = RET_STATUS);
  }  

/*
 * printf("end of reset_match---------\n\n");
 */
/*
FIprint_lines();
*/
  return EXP_S_SUCCESS;
}

/*

Name
  find_match

Abstract

 * The following method is called to visit variables matched
 * to existing equations in a depth first recursive manner‚ 

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
method find_match(IGRboolean *pmatch_found; IGRboolean *pcycle_formed;
                  struct GRid eqn_list[]; int *peqn_count;
                  struct GRid match_list[]; int *pnum_matched)

{
  char 		exp_syntax[EXP_MAX_LEN];  
  IGRlong	status;  
  struct GRid 		my_grid;
    
  if (me->state & ND_VISITED)
  {
    return(EXP_S_SUCCESS);
  }

  status = om$send(msg = message expression.visit_eqn (eqn_list, peqn_count),
          	   targetid = my_id);
  as$status(action = RET_STATUS);

  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );

  strcpy(exp_syntax, me->pretty_print);

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  
  status = find_underconstr_var (my_grid, exp_syntax, pmatch_found, pcycle_formed, 
                                 eqn_list, peqn_count, match_list, pnum_matched);
  as$status(action = RET_STATUS);

  return EXP_S_SUCCESS;
}



/*

Name
  init_expr_var

Abstract
 * The method 'init_expr_var()' initiallizes the newly created instance
 * of the expression object.


Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
method init_expr_var()
{
  
  /*|default initialization for instance data */
  me->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  me->value = MAXDOUBLE;
  me->pretty_print[0] = '\0';
  return(EXP_S_SUCCESS);
}

/*

Name
  visit_eqn

Abstract

*   This method marks an equation as visited during traversal
*   to find matching.


Synopsis
struct GRid eqn_list[];  IN the # of eqns matched so far
int *peqn_count;         IN the eqns matched so far

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
method visit_eqn ( struct GRid eqn_list[]; int *peqn_count)
{
     
  if (*peqn_count >= MAX_VISIT_EQN)
  { 
    Error_Text( EXP_MEM_FAIL, (int *) "for matching_5" ) ;
    return( EXP_MEM_FAIL );
  }
  eqn_list[*peqn_count].objid = my_id;
  eqn_list[*peqn_count].osnum = OM_Gw_current_OS;
  (*peqn_count)++;

  me->state |= ND_VISITED;
  
  return(EXP_S_SUCCESS); 
}

/*

Name
  is_var_matched

Abstract

 * Returns TRUE, if a variable is matched to an expression.

Synopsis
IGRboolean *ptr_is_matched; OUT TRUE if variable is already matched

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created

 */
method is_var_matched (IGRboolean *ptr_is_matched)
{
  if (me->pretty_print[0] == '\0')
    *ptr_is_matched = FALSE;
  else
    *ptr_is_matched = TRUE;
  return(EXP_S_SUCCESS); 
}

/*

Name
  match

Abstract

 *  The following method is used to assign a matching between
 *  a variable and an expression. The Associative graph is 
 *  updated to reflect this new matching.

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  03/04/93 : Kapil Singh : created
  05/08/95 : Satish.K    : Added check for loops not found in strong 
			   components. TR#119525145
			   Prevented user from placing such expression.

 */
method match(struct GRid curr_var_grid; 
             int num_parent; struct GRid parent_grid[]; 
             char *exp_syntax; 
             IGRboolean from_reset_match; IGRboolean *pcycle_formed;
             struct GRid match_list[]; int *pnum_matched)
{
  IGRlong status;
  int stat;
  int num_var;
  struct GRid var_grid[MAX_NUM_EQN_VAR];
  struct GRid null_grid;
  char 		*pstr, *var_first_occur = NULL;
  IGRboolean 	seen_matched_var;
  struct	data_struct value;
  double 	original_var_value;
  struct GRid   parent, my_grid;
  int     	i;
  char          back_index[20], objid_str[20], matchid_str[20];
  int var_count;
  extern struct GMgraph ND_graph;
  struct GRid *cyc_grid = (struct GRid *)alloca(sizeof(struct GRid) * MAX_NUM_EQN_VAR);

  int cyc_count;
  IGRboolean cyc_exist;

  char original_str_value[64];
  char new_str_value[64];
  IGRboolean  original_val_error, new_val_error;
  IGRboolean do_recompute = FALSE;
  char *EXPlocate();    
  IGRboolean error_in_parent = FALSE;    
  IGRlong msg;
  struct GRmd_env md_env;
  IGRint bytes_in, bytes_out;
  
  cyc_exist = FALSE;
  bytes_in = sizeof (struct GRmd_env);

  gr$get_module_env(
     msg = &msg,
     sizbuf = &bytes_in,
     buffer = &md_env,
     nret = &bytes_out);

  if (!from_reset_match)
  {
    /*
     *  Add to the match list
     */
     if (*pnum_matched >= MAX_VISIT_EQN)
     { 
       Error_Text( EXP_MEM_FAIL, (int *) "for matching_6" ) ;
       return( EXP_MEM_FAIL );
     }
     match_list[(*pnum_matched)].objid = my_id; 
     match_list[(*pnum_matched)].osnum = OM_Gw_current_OS;
     (*pnum_matched)++;
  }  

  
  if (curr_var_grid.objid != NULL_OBJID)
  {
    strcpy(matchid_str, "\\-1");  
    sprintf(objid_str, "\\-%lu", curr_var_grid.objid);  
    EXPsubstitute(matchid_str, objid_str, exp_syntax);

    for( i = 0 ; i < num_parent ; i++ )
    {
      sprintf(objid_str, "\\-%lu", parent_grid[i].objid);
      sprintf(back_index, "\\%d", i);
      EXPsubstitute(back_index, objid_str, exp_syntax);
    }
  }
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  seen_matched_var = FALSE;
  pstr = exp_syntax;
  num_var = 0;
  stat = EXP_S_SUCCESS;

  while (stat == EXP_S_SUCCESS)
  {
    stat = get_eqn_var ( curr_var_grid, num_parent, parent_grid, &pstr, 0, &parent );
    if ((stat == EXP_S_SUCCESS) && (parent.objid == my_id) && 
        (parent.osnum == OM_Gw_current_OS) && (seen_matched_var == FALSE))
    {        
      seen_matched_var = TRUE;
      var_first_occur = pstr;
    }
    else if ((stat == EXP_S_SUCCESS))
    {
      if (num_var >= MAX_NUM_EQN_VAR)
      {
        Error_Text( EXP_MEM_FAIL, (int *) "for matching_7" ) ;
        return EXP_MEM_FAIL;
      }
      
      var_grid[num_var].objid = parent.objid;
      var_grid[num_var].osnum = parent.osnum;
  
      num_var++;
    }
  }

 /* calling make_orphan */
  status = om$send(msg = message expression.make_orphan(),
             	   targetid = my_id);
  as$status(action = RET_STATUS);

  null_grid.objid = NULL_OBJID;
  status = om$send(msg = message NDnode.NDconnect
                         (num_var, var_grid, null_grid, ND_NEW),
         	         targetid = my_id);
  as$status(action = RET_STATUS);
  

 for (var_count = 0; var_count < num_var; var_count++)
  {
    /* If not called from Reset_match(), Check in there is a loop in the graph */
    if (!from_reset_match)
      if(nd$dep_exist(nb_root = 1, l_root = &my_grid,
                      nb_tip  = 1, l_tip  = &var_grid[var_count]))
      { 
        /* There is a loop in the graph */ 

        GRclassid  ob_classid;

        cyc_exist = TRUE;


        status = EQfind_loop_elmts ( my_grid, cyc_grid, &cyc_count );
        as$status(action = RET_STATUS);
       
 
        if (cyc_count >= MAX_NUM_EQN_VAR)
        {
          Error_Text( EXP_MEM_FAIL, (int *) "to find cycle" ) ;
          return ND_COMP_FAIL;
        }
    
         for (i = 0; i < cyc_count; i++)
         {
           om$get_classid( objid = cyc_grid[i].objid, osnum = cyc_grid[i].osnum,
                           p_classid = &ob_classid );
           if(om$is_ancestry_valid ( subclassid = ob_classid,
		      superclassid = OPP_expression_class_id ) != OM_S_SUCCESS)
           {
             *pcycle_formed = TRUE;             
              
             /* calling make_orphan */
             status = om$send(msg = message expression.make_orphan(),
                         	   targetid = my_id);
             as$status(action = RET_STATUS);
           
             return EXP_S_SUCCESS; 
           }
         }
/** TR#119525145 **/
	if (cyc_count == 0)
	{
       	   om$get_classid( objid = var_grid[var_count].objid, 
			   osnum = var_grid[var_count].osnum,
                           p_classid = &ob_classid );
           if(om$is_ancestry_valid ( subclassid = ob_classid,
                      superclassid = OPP_expression_class_id ) == OM_S_SUCCESS)
           {
             *pcycle_formed = TRUE;
 
             /* calling make_orphan */
             status = om$send(msg = message expression.make_orphan(),
                                   targetid = my_id);
             as$status(action = RET_STATUS);
 
             return EXP_S_SUCCESS;
           }
	}
      }
   }

  /* get my roots */
   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,var_grid,MAX_NUM_EQN_VAR,
                                                       NULL, 0, MAX_NUM_EQN_VAR - 1,
   						       &num_var),
  		  targetid = my_id);
   as$status(action = RET_STATUS);
  
   if (num_var > MAX_NUM_EQN_VAR)
   {
     Error_Text( EXP_MEM_FAIL, (int *) "for matching_8" ) ;
     return EXP_MEM_FAIL;
   }

  sprintf(objid_str, "\\-%lu", my_id);
  strcpy(matchid_str, "\\-1");  
  
  for( i = 0 ; i < num_var ; i++ )
  {
    if (var_grid[i].objid == my_id)
    {
      sprintf(back_index, "\\%d", i);
      EXPsubstitute(objid_str, back_index, var_first_occur);
    }
  }
  EXPsubstitute(objid_str, matchid_str, exp_syntax);      

  for( i = 0 ; i < num_var ; i++ )
  {
    if (var_grid[i].objid != my_id)
    {
      sprintf(objid_str, "\\-%lu", var_grid[i].objid);
      sprintf(back_index, "\\%d", i);
      EXPsubstitute(objid_str, back_index, exp_syntax);
    }
  }

  stat = OM_SET_DIMENSION( ME.expression->pretty_print,
                           (strlen(exp_syntax)+1) * sizeof (char));
  Error( stat, "MATCH OM_set_dim( me->pretty_print) error" ) ;

  strcpy(me->pretty_print, exp_syntax);  

  solve_var_grid.osnum = OM_Gw_current_OS;  
  solve_var_grid.objid = my_id;
  in_cycle = FALSE;

  original_var_value = me->value;

  if ((strlen(me->pretty_print)) && (!cyc_exist))
  {
    error_in_parent = FALSE;
    for (i = 0; i < num_var; i++)
    {
      struct ret_struct info_struct;
      status = 
       om$send (msg = message NDnode.NDgive_structure (&msg, 
                              &info_struct,
                              &md_env),
                	   targetos = var_grid[i].osnum, 
                	   targetid = var_grid[i].objid);

      if ((info_struct.type & parameter_generic) && 
          (info_struct.var.root_pm_st.value == MAXDOUBLE))
      {
        error_in_parent = TRUE;
        break;        
      }
    }                       
   
    if (!error_in_parent)
    {
      status = compute_Parse(num_var, var_grid, me->pretty_print, &value);
      as$status();
      if (status & 1) 
         me->value = value.data.real;
    }
  }
  else
    value.data.real = original_var_value;
  
  
  sprintf ( original_str_value, " [%g]", original_var_value);
  if (EXPlocate( "nan", original_str_value))
    original_val_error = TRUE;
  else
    original_val_error = FALSE;

  
  sprintf ( new_str_value, " [%g]", value.data.real);
  if (EXPlocate( "nan", new_str_value))
    new_val_error = TRUE;
  else
    new_val_error = FALSE;

  do_recompute = FALSE;
  
  if (original_val_error != new_val_error) 
    do_recompute = TRUE;
  else if(!original_val_error && (fabs(original_var_value-value.data.real) > 1.e-10))
    do_recompute = TRUE;

  if (do_recompute || cyc_exist)
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
    }  
    GR_NOTIFY_LISTENERS(&stat,&stat,GR_GEOM_MODIFIED);
  }  

  return EXP_S_SUCCESS;  
}

/*

Name
  give_syntax

Abstract

 * This method gets the syntax for an expression.

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation

History
  03/04/93 : Kapil Singh : created

 */
method give_syntax (char *exp_syntax)
{
  strcpy (exp_syntax, me->pretty_print);

  return(EXP_S_SUCCESS); 
}

/*

Name
  put_syntax

Abstract
 * This method puts the syntax for an expression.

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation

History
  03/04/93 : Kapil Singh : created

 */
method put_syntax (char *exp_syntax)
{
  int stat;
  
  stat = OM_SET_DIMENSION( ME.expression->pretty_print,
                           (strlen(exp_syntax)+1) * sizeof (char));
  Error( stat, "PUT_SYNTAX OM_set_dim( me->pretty_print) error" ) ;

  strcpy(me->pretty_print, exp_syntax);

  return(EXP_S_SUCCESS); 
}
/*

Name
  put_value

Abstract
 * This method puts the new value for a vatriable.


Synopsis

Description

Return Value

Notes

Index

Keywords
  equation

History
  03/04/93 : Kapil Singh : created

 */
method put_value (double value)
{
  
  me->value = value;

  return(EXP_S_SUCCESS); 
}



end implementation expression ;
