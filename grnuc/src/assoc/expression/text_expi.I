 class implementation text_exp ;

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
#include "asmacros.h"
#include "AS_status.h"
#include "gocmacros.h"

#define AS_DEBUG 1

extern GRclassid OPP_text_exp_class_id;
extern GRclassid OPP_Gtext_exp_class_id;

/*--------------------------------------------------------------------------*/

int EXP_text_exp_build(expr_name, expr_syntax, osnum, expr_id )
IGRchar       *expr_name, *expr_syntax;
GRspacenum    osnum;
GRobjid       *expr_id;
/*.EXP_text_exp_build */
{
  IGRshort  	rc; 
  IGRlong       status;
  char 		expr1 [EXP_MAX_LEN];
  char 		expr_string[EXP_MAX_LEN];

  status = om$construct(classid = OPP_text_exp_class_id,
			osnum = osnum,
			p_objid = expr_id);
  as$status(action = RET_STATUS);

  EXP_gen_name(expr1, *expr_id, expr_name);

  if(  EXP_extract_string(expr_syntax, expr_string)!= EXP_S_SUCCESS)
    return(EXP_E_SYNTAX_ERROR);

  status = om$send(msg = message text_exp.create ( expr1, expr_string, &rc),
                   senderid = NULL_OBJID,
		   targetid = *expr_id, 
		   targetos = osnum);
  as$status(action = RET_STATUS);

  return(rc);
} /* EXP_text_exp_build */

/*--------------------------------------------------------------------------*/

method create( 	char *name; 
		char *syntax;
               	IGRshort  *rc) 
{ 
  int           stat;
  OM_S_OBJID    objid;
  extern void   Error_Text();

  /*"syntax : '%s'\n", syntax */
  me->value = 0.0;
  me->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  OM_SET_DIMENSION( me->pretty_print, 1 );
  me->pretty_print [0] = '\0';

  if((name!=NULL) && (strcmp(name,"")!=0) )
  {
    /* Check that this new entry doesn't already exist
    -------------------------------------------------- */
    stat = di$translate( objname = name, 
		         p_objid  = &objid);
    if(stat == DIR_S_SUCCESS)
    { 
      *rc = EXP_ALREADY_EXISTS;
      Error_Text( EXP_ALREADY_EXISTS, "" );
      return (OM_S_SUCCESS);
    }
  }
  stat = OM_SET_DIMENSION( ME.expression->pretty_print,
                        ( strlen(syntax) + 1 ) * sizeof( char ) ) ;
  Error( stat, "text_exp.create OM_set_dim( me->pretty_print) error" ) ;
  strcpy(ME.expression->pretty_print, syntax);

  if(name!=NULL)
    if(strcmp(name,"")!=0)
    {
        stat = di$add_name( objname = name, objid   = my_id );
	if(stat!=DIR_S_SUCCESS)
	  di$report_error(sts = stat);
    }
  *rc = EXP_SUCCESS;
  return( OM_S_SUCCESS ) ;
} /* Method create */

/*--------------------------------------------------------------------------*/

method NDplace( struct GRas *assoc_list; struct GRmd_env *md_env; char *bspline)
{

  IGRlong status;
  IGRshort 	rc;
  exp_data 	exp_struct;
  char 		syntax [EXP_MAX_LEN];

  exp_struct = *((exp_data*)(assoc_list->as_attr));

  if (exp_struct.syntax [0] == '\0')
     sprintf ( syntax, "%lf", exp_struct.value );
  else
     strcpy ( syntax, exp_struct.syntax );

  status = om$send(msg = message text_exp.create( exp_struct.name, syntax, &rc),
            	   targetid = my_id);
  as$status(action = RET_STATUS);

  if(rc != EXP_SUCCESS) 
    fprintf(stderr, "text_exp.place rc is not EXP_SUCCESS\n");
  return(OM_S_SUCCESS) ;
} /* Method place */

/*---------------------------------------------------------------------------*/

method modify( char      *name;
	       char	 *syntax;
               IGRshort  *rc)
{ 
  int         stat;
  IGRlong     status;

  stat = OM_SET_DIMENSION( ME.expression->pretty_print,
                           ( 1 + strlen( syntax ) ) * sizeof( char ) );
  Error( stat, "expression.modify OM_set_dimension( pretty_print) error" );

  strcpy( ME.expression->pretty_print, syntax );

  status = om$send(msg = message expression.NDchange_node(NULL ),
               	     targetid = my_id);
  as$status(action = RET_STATUS);

  GR_NOTIFY_LISTENERS(&stat,&status,GR_GEOM_MODIFIED);
  *rc = EXP_S_SUCCESS;
  return( EXP_S_SUCCESS )   ;
} /* Method modify */

/*---------------------------------------------------------------------------*/

method NDcompute_node( IGRlong *msg; IGRint cn_type;
		       int count ; struct GRid parent[];
		       struct GRmd_env *md_env )
{
  *msg = MSSUCC;
  return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------*/

method NDgive_structure (IGRlong *msg; struct ret_struct  *ptr_rst;
			 struct GRmd_env *md_env )
/* this Method is used to enquire about this parameter */
{
  *msg = MSSUCC;
  ptr_rst->type = text_type;

  /** The text_string field in struct ret_struct is a char array of 80.
   ** If pretty_print is greater than 80, strcpy might cause a crash.
   ** Avoiding it by strncpy and strcat-ing a terminator since strncpy
   ** doesn't do it if bytes being copied is less than string2.
   ** TR#119601402
   **/

  if (strlen(ME.expression->pretty_print) < 80)
  {
     strcpy(ptr_rst->var.text_st.text_string, ME.expression->pretty_print);
  }
  else
  {
     strncpy(ptr_rst->var.text_st.text_string, ME.expression->pretty_print,79);
     ptr_rst->var.text_st.text_string[79] = '\0';
  }

  /*"text_type : %d, type : %d\n", text_type, ptr_rst->type */
  /*"pretty_print : '%s', string : '%s'\n", me->pretty_print, ptr_rst->var.text_st.text_string */  
  return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------*/

method give_formula( char *formula )
{ 
  formula[0] = '\0';
  sprintf(formula, "\"%s\"", ME.expression->pretty_print);
  return( EXP_S_SUCCESS );
} 
/*---------------------------------------------------------------------------*/

method list ( 	char *formula )
{
  char		my_name[EXP_MAX_LEN],my_formula[EXP_MAX_LEN],*dummy_formula;
  IGRint 	rc;
  int len;


  formula[0] = '\0';
  my_name [0] = '\0';
/*  rc = di$untranslate(objid = my_id, objname = my_name);
/****/
  rc = EXP_rec_untranslate(my_id , OM_Gw_current_OS , my_name);
  if((rc!=DIR_S_SUCCESS)&&(rc!=DIR_W_NAME_NOT_FOUND))
    di$report_error(sts = rc);
  
  if(!strcmp(my_name, "")) sprintf(my_name, "\\%d", my_id);

  /* All this shit to be sure to not have a to long formula */

      len = strlen(me->pretty_print);
      if(len > EXP_MAX_LEN-4)
       {
	strncpy(my_formula,me->pretty_print,EXP_MAX_LEN);
        my_formula[EXP_MAX_LEN-4] = '\0';
        len = EXP_MAX_LEN-4;
	dummy_formula = my_formula;
       }
      else
       {
	dummy_formula = me->pretty_print;
       }

      my_name[EXP_MAX_LEN-len-4] = '\0';

  
  sprintf(formula, "%s = \"%s\"", my_name, dummy_formula);

  return(EXP_S_SUCCESS);
} 

/*---------------------------------------------------------------------------*/

method NDprint_root ( struct GRmd_env  *md_env;
                    FILE       *stream    )
{
  char 		ident [80];
  char 		my_name[EXP_MAX_LEN];
  struct GRid   my_grid;

  as$printer_set_name ( prefix = "EXP", name = ident );
  if (strcmp ( ident, "" ) == 0) return ( OM_S_SUCCESS );
  
   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   asprinter_get_di_name(my_grid,my_name);
   asprinter_print_dir(my_name);

  fprintf( stream, "send text_exp.place ( \"%s\", \"%s\" ) to %s;\n", 
           my_name, ME.expression->pretty_print, ident );

  return( OM_S_SUCCESS ) ;
}



method NDmove_to_root ( IGRlong *msg; struct GRid *src_grid; 
			struct GRmd_env *md_env )
{
  /*|I am already a root */
  return OM_S_SUCCESS;
}



method ACcopy_to_Groot ( IGRlong *msg; IGRint cn_type;
			struct GRmd_env *obj_env, *new_env;
                        struct GRid *new_id )
{
  IGRint status;
  OMuword osnum;
  short  rc;

  /*"pretty print : '%s'\n", me->pretty_print */
  osnum = (new_env) ? new_env->md_id.osnum : OM_Gw_current_OS;

  status = om$construct(classid = OPP_Gtext_exp_class_id,
			osnum   =  osnum,
			p_objid =  &(new_id->objid));
  as$status(action = RET_STATUS);

  status = om$send(msg = message text_exp.create( NULL, me->pretty_print, &rc ),
                   targetid = new_id->objid,
		   targetos =  osnum);
  as$status(action = RET_STATUS);

  new_id->osnum = osnum;
  *msg = MSSUCC;
  return OM_S_SUCCESS;


}

method NDcopy_to_root ( IGRlong *msg; IGRint cn_type;
			struct GRmd_env *obj_env, *new_env;
                        struct GRid *new_id )
{
  IGRint status;
  OMuword osnum;
  short  rc;

  /*"pretty print : '%s'\n", me->pretty_print */
  osnum = (new_env) ? new_env->md_id.osnum : OM_Gw_current_OS;

  status = om$construct(classid = OPP_text_exp_class_id,
			osnum   =  osnum,
			p_objid =  &(new_id->objid));
  as$status(action = RET_STATUS);

  status = om$send(msg = message text_exp.create( NULL, me->pretty_print, &rc ),
                   targetid = new_id->objid,
		   targetos =  osnum);
  as$status(action = RET_STATUS);

  new_id->osnum = osnum;

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


method DIgive_output ( 	char *formula )
{
  char		my_formula[EXP_MAX_LEN];
  IGRlong status;
  int name_len;

  status = om$send (msg = message expression.give_formula( my_formula ),
            	    targetid = my_id);
  if(!(status&1)) return(OM_W_ABORT);

  name_len = strlen(formula);
  if(name_len + strlen(my_formula)+ 4 < DI_PATH_MAX)
    { strcpy(&formula[name_len]," = ");
      strcpy(&formula[name_len+3],my_formula);
      return (OM_S_SUCCESS);
    }
  else return(OM_W_ABORT);
    
} /* Method DIgive_output */



method DIget_edit_string ( char *string )
/*
 * The purpose of this method is to support the directory command form
 * as an edit capability. This message will be sent by the form when
 * the form wants to give the user an editable string.
 */
{
   IGRlong status;
   char my_name [DI_PATH_MAX];    
    
   *my_name = '\0';

   status = di$untranslate ( objid = my_id, objname = my_name );
   if (status &1)
     di$split ( pathname = my_name, name = string );
   else
     *string = '\0';    

   
  status = om$send (msg = message text_exp.DIgive_output(string),
            	    targetid = my_id);
  if(!(status&1)) return(OM_W_ABORT);
  
  return OM_S_SUCCESS;
}


method DIput_edit_string ( char *string )
{
  char *s;
  char exp_name [DI_PATH_MAX], exp_syntax [DI_PATH_MAX];
  
  EXP_extract_lhs_rhs (string, exp_name, exp_syntax );
  
  s = exp_syntax;
  
  if( s != 0 && *s != '\0' )
    while( *s && *s == ' ' ) s++ ;

  strcpy(exp_syntax, s);
  

  if(EXP_extract_string(exp_syntax, string)!= EXP_S_SUCCESS)
    return(EXP_E_SYNTAX_ERROR);

  return exp$modify ( exp_id = my_id, exp_syntax = string);
}

method convert_to_new_syntax ()
{
  return OM_S_SUCCESS;
}


end implementation text_exp ;
