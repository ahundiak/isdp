/*

Name
  exp_ovrdi.I

Description
   This file contains the methods that are overriden by expression.
Notes


 */

/*
   ABSTRACT :
   --------

   This file contains the methods that are overriden by expression.


   HISTORY :
   -------

   12/10/1987 : HGB - Design Date from a cupple of files.
   03/14/1988 : HGB - Support the new_id in copy_to_root
                      Define EXP_len_substitute & EXP_len_locate for
                      new syntax in CI (graph printer).
   03/25/1988 : HGB - No longer support syntax in returned structure
*/

class implementation expression;

#include <stdio.h>
#include <alloca.h>
#include <string.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "madef.h"
#include "AS_status.h"
#include "GMdef.h"
#include "GM.h"

#include "grdpbmacros.h"
#include "gocmacros.h"
#include "drawparam.h"

#define AS_DEBUG

extern GRclassid OPP_Gexp_class_id;
extern struct GRid    solve_var_grid;
extern IGRboolean in_cycle;

method ASreturn_go(struct GRid *go;short *mat_type;double *matrix)
{
  int msg;
  
  go->objid = my_id; go->osnum = OM_Gw_current_OS;

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&msg,matrix);

  return OM_S_SUCCESS;
}


/* --------------------------------------------------------------------------*/
/* Re-evaluates the expression because one or more parents changed. Overrides 
/* class NDnode's NDcompute_node.                                             
/*                                                                            
/* INPUT  : count , number of parents                                         
/*          parent, parent list                                               
/* RETURNS: OM_S_SUCCESS or an OM status if an OM routine should fail         
/* CALLERS: expression.modify, NDnode.NDchange_node                             
/* --------------------------------------------------------------------------*/
method NDcompute_node ( long *msg; int cn_type; int count ; struct GRid parent[]; 
                        struct GRmd_env *md_env )
{
  struct data_struct value;
  double fabs();
  
  extern struct GMgraph ND_graph;
  struct GRid *cyc_grid = (struct GRid *)alloca(sizeof(struct GRid) * MAX_NUM_EQN_VAR);
  int cyc_count, i;
  struct GRid my_grid;
  int iterlim;
  double itertol;
  long status;


  char original_str_value[64];
  char new_str_value[64];
  IGRboolean  original_val_error, new_val_error;
  IGRboolean do_recompute = FALSE;
  IGRboolean error_in_parent = FALSE;  
  char *EXPlocate();    

  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );
  
  
  if (me->state & ND_COMPUTE_OVER)
  {
	/*- expression belongs to a strong component, all the
	    expressions are solved and compute is not required
	    for each expression.
	*/

	*msg = ND_COMP_SUCC;
	GR_NOTIFY_LISTENERS(msg,msg,GR_GEOM_MODIFIED);

	/* clear the ND_COMPUTE_OVER flag */

	status =
	om$send (msg = message  NDnode.NDchg_state(ND_COMPUTE_OVER, 0),
       	      targetid = my_id);
	as$status(action = RET_STATUS);

	return OM_S_SUCCESS;
  }


  /*
   * Support for equational constraints: set global variable 
   * "solve_var_grid".
   */
  my_grid.osnum = OM_Gw_current_OS;
  my_grid.objid = my_id;

  solve_var_grid = my_grid;


  status = EQfind_loop_elmts ( my_grid, cyc_grid, &cyc_count );
  as$status(action = RET_STATUS);


  if (cyc_count)
  {
    if (cyc_count >= MAX_NUM_EQN_VAR)
    {
      Error_Text( EXP_MEM_FAIL, (int *) "to find cycle" ) ;
      return ND_COMP_FAIL;
    }
    /*
     *  Solve the Strong Component
     */
    in_cycle = TRUE;
    itertol = .0001;
    iterlim = 30;

    if (Eqn_compute_strong_component(cyc_count, cyc_grid, iterlim, itertol) == EXP_SUCCESS)
    {
      *msg = ND_COMP_SUCC;
      GR_NOTIFY_LISTENERS(msg,msg,GR_GEOM_MODIFIED);
    }
    else
    {
      /*| failure */
      *msg = ND_COMP_FAIL;
    }

      /* set the ND_COMPUTE_OVER bit for all members of the strong components */

      for (i = 0; i < cyc_count; i++)
      {

        if ((cyc_grid[i].objid != my_id) || (cyc_grid[i].osnum != OM_Gw_current_OS)) 
        {
	  status =
	  om$send (msg = message  NDnode.NDchg_state(ND_COMPUTE_OVER, ND_COMPUTE_OVER),
		targetid = cyc_grid[i].objid,
		targetos = cyc_grid[i].osnum);
	  as$status(action = RET_STATUS);
        }
      }

  }
  else
  {
    in_cycle = FALSE;

    error_in_parent = FALSE;
    for (i = 0; i < count; i++)
    {
      struct ret_struct info_struct;
      status = 
       om$send (msg = message NDnode.NDgive_structure (msg, 
                              &info_struct,
                              md_env),
                	   targetos = parent[i].osnum, 
                	   targetid = parent[i].objid);

      if ((info_struct.type & parameter_generic) && 
          (info_struct.var.root_pm_st.value == MAXDOUBLE))
      {
        error_in_parent = TRUE;
        break;        
      }
    }                       
   
  

    if ((!count) || (error_in_parent))
     {
      /* To avoid truncation, does not recompute value of root pm */
      *msg = ND_COMP_SAME;
     }

    else if(compute_Parse(count, parent, me->pretty_print, &value) == EXP_SUCCESS)
    {
      sprintf ( original_str_value, " [%g]", me->value);
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
      else if(!original_val_error && (fabs(me->value-value.data.real) > 1.e-10))
        do_recompute = TRUE;
  
     if(do_recompute)
      {
       /*| update value */
       me->value = value.data.real;
       *msg = ND_COMP_SUCC;
       GR_NOTIFY_LISTENERS(msg,msg,GR_GEOM_MODIFIED);
      }
     else
      {
       /*| same value */
       *msg = ND_COMP_SAME;
      }
  
      /*"expression value : %lf\n", me->value */
    }
    else
    {
      /*| failure */
      *msg = ND_COMP_FAIL;
    }
    
  }
  /*"completion code %d\n",*msg */
  return OM_S_SUCCESS;
}

/* ------------------------------------------------------------------------ */

method NDgive_structure (long *msg; struct  ret_struct *ptr_rst;
		 	 struct GRmd_env *md_env )
{
  *msg = MSSUCC;
  ptr_rst->type = double_type;
  ptr_rst->var.root_pm_st.value = me->value;

  return OM_S_SUCCESS;
}   

/* 
   NB connection to an expression in a reference file is not allowed for
   now, even if no context defined !!!!!
*/

method NDmake_source(long *msg; struct GRid *located_obj,*context;char *path;
                     GRspacenum as_osnum; struct GRid *as)
{
  long status;
  struct GRid my_grid,owner_grid;

/* jla 11-nov-92 fix dependent connection to expressions members of a macro  
   to be by pretend on the dependent channel of the macro occurence */ 

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  owner_grid.objid = NULL_OBJID;

  ASget_as_owner(&my_grid,&owner_grid);
  if(owner_grid.objid != NULL_OBJID)
   {
    /* assoc owner */
    status = om$send(msg = message NDnode.NDmake_source
                                   (msg,&my_grid,context,path,as_osnum,as),
                    targetid = owner_grid.objid,
                    targetos = owner_grid.osnum);
   }

  else if (as_osnum == OM_Gw_current_OS)
  {
    /* dependency in the same OS */
    status = om$send ( msg = message NDnode.NDmake_source
			      ( msg, located_obj, context, path, as_osnum, as ),
        mode = OM_e_wrt_message,
        targetid = my_id );
  }
  else
  {
    /* dependency in another OS */
    status = ASmake_source_from_go(msg,&my_grid,context,as_osnum,as);
  }

  return status;
}
   


/* ----------------------------------------------------------------------- */

method NDprint_root( struct GRmd_env  *md_env;
                     FILE       *stream )
{
  char	ident [80], my_name[EXP_MAX_LEN];
  struct GRid my_grid;

  as$printer_set_name ( prefix = "EXP", name = ident );
  if (strcmp ( ident, "" ) == 0) return OM_S_SUCCESS;

   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   asprinter_get_di_name(my_grid,my_name);
   asprinter_print_dir(my_name);

  fprintf( stream, "send expression.place ( \"%s\", \"%lf\" ) to %s;\n", 
           my_name, me->value, ident );
   
  return OM_S_SUCCESS ;
} 


short  EXP_len_locate( Pattern, Source , Start, Stop, length )
#define 	MARKER (char) 27
char 		*Pattern, *Source;
int  		Start, Stop, length;
/*.EXP_len_locate*/
{
  char          *P_S;
  short      lP, m, Found, *q;
  register int  i, j;
  register char *pP_S, *pC;

  P_S = (char *) malloc ( 2 * length + 1 );
  q   = (short *) malloc ( (2 * length + 1) * sizeof ( short ) );
  if ((P_S == NULL) || (q == NULL))
  {
    fprintf ( stderr, "EXP_len_locate : CAN'T malloc\n" );
    return 0;
  }

  lP = strlen( Pattern );
  if( Stop > ( i = strlen( Source ) ) ) Stop = i;
  m  = lP +  Stop - Start + 3;

  pP_S = P_S; 
  *pP_S++ = ' ';

  for( pC = Pattern; *pC; ++pC, ++pP_S)
    *pP_S = *pC ;

  *pP_S++ = MARKER ;

  for( i = Start - 1, pC = &Source[i] ; i < Stop ; ++pC, ++pP_S, i++ )
    *pP_S = *pC ;

  *pP_S   = '\0';

  Found = 0; 
  q[1] = 0; 
  q[2] = 1; 
  j = 1; 
  i = 2;
  while( i <= m && !Found )
  {
    register char c;

    c = P_S[i]; 
    P_S[0] = c;
    while( c != P_S[j] ) j = q[j];
    Found  = j == lP;
    q[++i] = ++j;
  }

  if (P_S)
    free ( P_S );
  if (q)
    free ( q );

  return ( Found ) ? i - 2*lP - 1 : 0 ;
} /* EXP_len_locate */


short  EXP_len_substitute( old_name, new_name, expr, subs_type, how_many_type, length )
char 	*old_name, *new_name, *expr;
int	subs_type, how_many_type, length;
/*.EXP_substitute */
{
  int   lon, lnn, lex, pos, start, done;
  char   *tmp;

  /*"expression : '%s', '%s' -> '%s'\n", expr, old_name, new_name */
  tmp = (char *) malloc ( length );
  if (tmp == NULL)
  {
    fprintf ( stderr, "EXP_len_locate : CAN'T malloc\n" );
    return EXP_E_ABORT;
  }

  /* valid caracter in new_name */
#define valid( c ) ( 'a' <= c && c <= 'z' || c == '$'  ||             \
                     '0' <= c && c <= '9' || c == '\'' || c == ':'  ||  \
                     'A' <= c && c <= 'Z' || c == '_'  || c == '\\'    )

  /* unvalid caracter in a name */
#define unvalid( c ) ( ('a' > c || c > 'z') && c != '$'  &&             \
                       ('0' > c || c > '9') && c != '\'' && c != ':'  &&  \
                       ('A' > c || c > 'Z') && c != '_'  && c != '\\'    )

  if(    old_name == 0 || *old_name == '\0'  || new_name == 0 
      || expr     == 0 || expr      == '\0' ) return EXP_INV_INPUT ;

  lon = strlen( old_name ) ;
  lnn = strlen( new_name ) ;
  lex = strlen( expr     ) ;

  if(    lon > length
      || lnn > length
      || lex > length ) return EXP_TOO_LONG ;

  done = 0;
  start = 1 ;
  while(    (( pos = EXP_len_locate( old_name, expr, start, lex, length ) ) != 0 )
      && (!((done == 1) && ( how_many_type == EXP_SUBST_FIRST))   ) )
  {
    pos = pos + start - 1 ;
    if( (subs_type == EXP_STRONG_SUBST)
        || (    ( pos == 1   ? 1 : unvalid( expr[pos-2] ))
        && ( pos >= lex - lon + 1 ? 1 : unvalid( expr[pos+lon-1] ))))
      if( lex - lon + lnn < length )
      {
        tmp[0] = '\0';
        strncpy( tmp, expr, pos - 1 );
        tmp[pos-1] = '\0';
        strcat ( tmp, new_name      );
        strcat ( tmp, &expr[pos-1+lon] );
        lex = lex - lon + lnn;
        strcpy( expr, tmp );
        start = pos + lnn + 1;
        done = 1;
      } /* if */
      else return EXP_TOO_LONG;
    else 
      start = pos + lon;
  } /* while */

  if (tmp)
    free ( tmp );

  return EXP_S_SUCCESS;
} /* EXP_len_substitute */



method NDprint ( struct GRmd_env *md_env; FILE *stream )
{
  int   size_formula;
  int      count,icount;
  long       status;
  char   ident [DI_PATH_MAX], 
  my_name[EXP_MAX_LEN], formula [1024],
  substitute[EXP_MAX_LEN],
  par_name[80], chan_index[80], indice[80];
  struct GRid *buffer;
  struct GRid my_grid;

  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  

  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );
  
  as$printer_set_name ( prefix = "EXP", name = ident );
  if (strcmp ( ident, "" ) == 0)  return OM_S_SUCCESS;

  size_formula = 1000;

  strcpy ( formula, me->pretty_print );

  status = om$send(msg =message NDnode.NDget_objects ( ND_ROOT|ND_IN_BUF, 
      NULL, NULL, &buffer, 0, OM_K_MAXINT,
      &count ),
      targetid = my_id);
  as$status(action = RET_STATUS);

  /*"count : %d\n", count */

  /*|set formula */
  for(icount=0; icount<count; icount++)
  {
    /*"parents [%d] : %d\n", icount, buffer [icount].objid */

    sprintf ( chan_index, "\\%d", icount);

    if (strlen ( formula ) >= size_formula)
    {
      fprintf( stream, "$$$EXPRESSION TOO LONG$$$" );
      break;
    }

    {
      /* get the name from the graph printer and initialize obj [icount] */
      as$printer_get_name( objid = buffer [icount].objid, name = par_name );
      fprintf( stream, "obj[%d]= &%s;\n", icount, par_name );

      if (icount)
        strcpy ( substitute, "\\\\\" );\nstrcat(str, ntoa((int) *obj[" );
      else
        strcpy ( substitute, "\" );\nstrcat(str,\"\\\\\");\nstrcat(str,ntoa((int) *obj[" );

      sprintf ( indice, "%d", icount );
      strcat ( substitute, indice );

      strcat ( substitute, "]));\nstrcat(str,\"" );

      /*"chan_index : '%s', substitute : '%s'\n", chan_index, substitute */
      /*"to be modified : '%s'\n", formula */
      EXP_len_substitute( chan_index, substitute, 
          formula, 
          EXP_SUBST, EXP_SUBST_ALL, size_formula );
      /*"result : '%s'\n", formula */
    }
  }

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  asprinter_get_di_name(my_grid,my_name);
  asprinter_print_dir(my_name);

  fprintf( stream, "strcpy(str,\"%s\");\n", formula );
  fprintf( stream, "send expression.place ( \"%s\", str ) to %s;\n\n", 
      my_name, ident );

  return OM_S_SUCCESS ;
} 

/* -----------------------------------------------------------------------*/

method NDplace ( struct GRas *assoc_list;struct GRmd_env *md_env;char *bspline )
{
  short 	rc;
  exp_data 	exp_struct;
  char 		syntax [EXP_MAX_LEN];
  long status;

  exp_struct = *((exp_data*)(assoc_list->as_attr));
  if (exp_struct.syntax [0] == '\0')
     sprintf ( syntax, "%lf", exp_struct.value );
  else
     strcpy ( syntax, exp_struct.syntax );

  status=om$send(msg=message expression.create( exp_struct.name, syntax, &rc ),
            	 targetid = my_id);
  as$status(action = RET_STATUS);

  /*"me->value : %lf (%s)\n", me->value, syntax */
  if(rc != EXP_SUCCESS) 
    fprintf(stderr, "expression.place rc is not EXP_SUCCESS\n");

  return OM_S_SUCCESS ;
}

/*-------------------------------------------------------------------------*/

method NDset_value( char *name; double val; struct GRmd_env *md_env; short *rc)
{ 
  long status;
  char syntax [EXP_MAX_LEN]; 

  sprintf ( syntax, "\\-1=%g", val );
  status = OM_SET_DIMENSION ( ME.expression->pretty_print,
    (strlen ( syntax ) + 1) * sizeof ( char ) );
  if (status & 1)
  {
    strcpy ( me->pretty_print, syntax );  
    me->value = val;
  }
  
  return status; 
} /* Method NDset_value */


/*---------------------------------------------------------------------------*/

method NDgive_value( double *val )
{
  *val = me->value;
  return EXP_S_SUCCESS;
}

/*-------------------------------------------------------------------------*/

method NDmove_to_root ( long *msg; struct GRid *src_grid; 
			struct GRmd_env *md_env )
{
  char syntax [EXP_MAX_LEN];
  long status;
  short rc;

  src_grid->osnum = OM_Gw_current_OS;
  src_grid->objid = my_id;

  sprintf( syntax, "%g", me->value);

  status = om$send ( msg = message expression.modify ( NULL, syntax, &rc ),
      targetid = my_id );
  return (status); 
}
/*-------------------------------------------------------------------------*/

method ACcopy_to_Groot ( long *msg; int cn_type;
			struct GRmd_env *obj_env, *new_env;
                        struct GRid *new_id )
{
  int status;
  OMuword osnum;
  short  rc;
  char tmp [EXP_MAX_LEN];

  /*"pretty print : '%s'\n", me->pretty_print */
  osnum = (new_env) ? new_env->md_id.osnum : OM_Gw_current_OS;

  status = om$construct(classid = OPP_Gexp_class_id,
			osnum   =  osnum,
			p_objid =  &(new_id->objid));
  as$status(action = RET_STATUS);
  sprintf( tmp, "%g", me->value);

  status = om$send(msg = message expression.create
		 ( NULL,tmp , &rc ),
                   targetid = new_id->objid,
		   targetos =  osnum);
  as$status(action = RET_STATUS);

  new_id->osnum = osnum;
  *msg = MSSUCC;
  return OM_S_SUCCESS;

}/*-------------------------------------------------------------------------*/

method NDcopy_to_root (long *msg; int cp_type;
		       struct GRmd_env *obj_env, *new_env;
                       struct GRid *new_id )
{
  OMuword osnum;

  osnum = (new_env) ? new_env->md_id.osnum : OM_Gw_current_OS;
  exp$create ( exp_name  = NULL, 
               exp_value = me->value, osnum = osnum,
               p_exp_id  = &(new_id->objid) );

  new_id->osnum = osnum;

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}
/*-------------------------------------------------------------------------*/

method NDdisplay (int dp_mode; enum GRdpmode mode; struct GRmd_env *md_env )
{
  /*^
  char formula [DI_PATH_MAX];
  long status;
  status = om$send (msg = message expression.list ( formula ),
		    targetid = my_id);
  as$status(action = RET_STATUS);

  printf ( "expression.NDdisplay : '%s' ( %d, %d )\n", 
           formula, OM_Gw_current_OS, my_id );
  */

  return OM_S_SUCCESS;
}


method NDparent_deleted ( long *msg; int count_deleted; struct GRid list_deleted [];
                          struct GRid *new_obj; struct GRmd_env *md_env)
{
  double parent_value=0.0;
  char back_index[20];
  char parent_value_str[EXP_MAX_LEN];
  int i;
  long status;
  int num_var;
  struct GRid var_grid[MAX_NUM_EQN_VAR];
  char syntax [EXP_MAX_LEN];
  short rc;
  int stat;

  *msg = MSSUCC;

  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send ( msg = message expression.convert_to_new_syntax (), targetid = my_id );
  
  /* get my roots */
  
   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,var_grid,MAX_NUM_EQN_VAR,
                                                       NULL, 0, MAX_NUM_EQN_VAR - 1,
   						       &num_var),
  		  targetid = my_id);
   as$status(action = RET_STATUS);
  
   if (num_var > MAX_NUM_EQN_VAR)
   {
     Error_Text( EXP_MEM_FAIL, (int *) "in variable deletion" ) ;
     return EXP_MEM_FAIL;
   }

  for( i = 0 ; i < num_var ; i++ )
  {
    if (is_parent_deleted (var_grid[i], count_deleted, list_deleted))
    {
      
      status=om$send(msg=message expression.NDgive_value(&parent_value),
                	   targetos = var_grid[i].osnum, 
                	   targetid = var_grid[i].objid);
      as$status(action = RET_STATUS);

      if (parent_value == MAXDOUBLE)
         parent_value = 0.0;
  
      sprintf(parent_value_str, "%g", parent_value);      
      sprintf(back_index, "\\%d", i);
  
      strcpy (syntax, me->pretty_print);
      status = EXPsubstitute( back_index, parent_value_str, syntax);
      as$status(action = RET_STATUS);
    
      stat = OM_SET_DIMENSION( ME.expression->pretty_print,
                               (strlen(syntax)+1) * sizeof (char));
      Error( stat, "DELETE OM_set_dim( me->pretty_print) error" ) ;
    
      strcpy(me->pretty_print, syntax);  
    
      status = om$send ( msg = message expression.DIget_edit_string (syntax ),
                         targetid = my_id );
      as$status(action = RET_STATUS);

      status = om$send ( msg = message expression.modify ( NULL, syntax, &rc ),
                         targetid = my_id );
      as$status(action = RET_STATUS);
      
    }
  }

  return OM_S_SUCCESS;
}


int is_parent_deleted (parent_grid, num_var, var_grid)
struct GRid parent_grid;
int num_var;
struct GRid var_grid[];
{
  int i;
  
  for (i = 0; i < num_var; i++)
    if ((var_grid[i].objid == parent_grid.objid) && (var_grid[i].osnum == parent_grid.osnum))
      return(TRUE);
      
  return (FALSE);
}

method GRchgcolor(long *msg; int unsigned *rgb_value; 
		  short unsigned *color)
{
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}


method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_attr)
{
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}


method GRchgstyle(long *msg;  char unsigned *style)
{
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}


method GRchgweight(long *msg; char unsigned *weight)
{
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}


method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
        *msg = MSSUCC;
	return(OM_S_SUCCESS);
}


method GRgetsymb(IGRlong *msg; struct GRsymbology *symb)
{

	*msg = MSSUCC;
	symb->display_attr.color = 0;
	symb->display_attr.weight = 0;
	symb->display_attr.style = 0;		
	symb->level = -1;

	return(OM_S_SUCCESS);
}

end implementation expression ;
