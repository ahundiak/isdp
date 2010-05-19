/* $Id: exp_util.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / exp_util.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: exp_util.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

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
/*            Method create
/*            Method list
/*            Method make_orphan
/*--------------------------------------------------------------------------*/
class implementation expression;

/* from interface import wakeup; */

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
#include "exmacros.h"
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

#define AS_DEBUG

extern char       *malloc();
extern void       Error_Text(), free(), Discard();

method create( 	char       *name; 
		char       *syntax; 
		IGRshort   *rc) 
{ 
  int           stat;
  IGRlong       status, sts;
  OM_S_OBJID    objid;
  char          **arg_list, back_index[20], 
		wkg_syntax[EXP_MAX_LEN];
  IGRshort      arg_num;
  struct	data_struct value;
  char		type_obtained;
  struct GRid   *arg_grid;

  /*|default initialization for instance data */
  me->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  me->value = 0.0;
  OM_SET_DIMENSION( me->pretty_print, 4 * sizeof ( char ) );
  strcpy ( me->pretty_print, "0.0" );

  arg_grid = NULL;
  arg_list = NULL;

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
  if(syntax==NULL)
  {
      *rc = EXP_INV_INPUT;
      Error_Text( EXP_INV_INPUT, "" );
      return (OM_S_SUCCESS);
  }
  else
    strcpy(wkg_syntax, syntax);

  /* Parse expression (syntax at this point is without chan index)
  ---------------------------------------------------------------- */
  *rc = new_exp_Parse( wkg_syntax, &value, &arg_list, &arg_num, 
			0, &type_obtained);

  if((*rc == EXP_SUCCESS ) )
  {
    me->value = value.data.real;
     
    if( arg_num > 0 )
    {
      int  i, j,k;

      /*| Check existence of rhs expressions */
      arg_grid=(struct GRid *)malloc( (arg_num * sizeof( struct GRid )));

      if( arg_grid == NULL )
      { 
        fprintf(stderr, "expression.create can't malloc \"arg_grid\".\n");
        return(OM_W_ABORT);
      }

      for(i = 0; i < arg_num && *rc == EXP_SUCCESS; i++)
      {
        *rc = exp$translate ( exp_name = arg_list[i],
                              p_exp_id = &arg_grid[i].objid,
                              p_osnum =  &arg_grid[i].osnum );
        if( *rc == EXP_NOT_FOUND )
        { 
          *rc = EXP_UNDEF_RHS;
          Error_Text( EXP_UNDEF_RHS, (int *) arg_list[i] );
        }
       else
        {
	 struct GRid root, my_grid;
         OMuword     cur_osnum;

         /*
          * 09/30/92 - JSD - We need to make sure that the rhs object is in the
          * current object space; otherwise, the creation is not valid.
          * An invalid creation means that we are either trying to create an
          * expression in an attached reference file or trying to modify an
          * expression in an attached reference file with a non-constant value.
          */

         ex$get_cur_mod ( osnum = &cur_osnum );

         if ( OM_Gw_current_OS != cur_osnum )
         {
           status = GRcheckref( &sts, NULL, NULL, NULL, &OM_Gw_current_OS );
           if ( sts == MSSUCC )
           {
             *rc = EXP_INV_REF_FILE;
             Error_Text( EXP_INV_REF_FILE, "" );
             return(OM_S_SUCCESS);
           }
         }

         /*
          * 09/30/92 - JSD - END
          */

	 /*| Check if no loop in the graph */
	 root = arg_grid[i];
	 my_grid.objid = my_id;
	 my_grid.osnum = OM_Gw_current_OS;

         if(nd$dep_exist(nb_root = 1, l_root = &my_grid,
	                 nb_tip  = 1, l_tip  = &root))
	  {
	   /*| Loop in the graph */
	   *rc = EXP_E_LOOP;
           Error_Text( EXP_E_LOOP, (int *) arg_list[i] );
	  }
        }
      }

      /* 
       * we need to tranform to the internal format 
       * ( a + b + c )*a   -----> (\1 + \2 + \3)*\1
       * which the universal representation of expressions
       * stored in their instances.
       */

/* modif jla june 91
  - the shit before did not work for
    expression like a + b +a +c  ----> \0 + \1 + \0 + \3
  - memory fault on apogee compiler
*/


      for( i = 0, j = 0; i < arg_num ; i++ )
      { 
        sprintf(back_index, "\\%d", j);
        /* be sure to get a new one */
	if(*arg_list[i] == '\0') continue;
        EXPsubstitute( arg_list[i], back_index, wkg_syntax);
        j++;
	for(k=i+1;k<arg_num;k++) 
         {
	  if(strcmp(arg_list[i],arg_list[k]) == 0) *arg_list[k] = '\0';
         }
      }
      /*"final result : '%s'\n", wkg_syntax */

      if(*rc == EXP_SUCCESS )
      {
        struct GRid *list_grid;
        IGRint i;

        list_grid = (struct GRid *) malloc ( arg_num * sizeof ( struct GRid ) );
        if (list_grid == NULL)
        {
          fprintf ( stderr, "expression.create : CAN'T malloc\n" );
          return OM_W_ABORT;
        }
 
        /*"number of objects : %d\n", arg_num */
        for (i=0; i < arg_num; i++ )
        {
          list_grid[i] = arg_grid [i];
     	  as$make_source ( go_grid = list_grid [i],
	                   as_os = OM_Gw_current_OS,
			   as_grid = &list_grid [i] );
        }

       { struct GRid nul_grid;
        nul_grid.objid = NULL_OBJID;
        status = om$send(msg = message NDnode.NDconnect
				( arg_num, list_grid, nul_grid, ND_NEW),
                 	 targetid = my_id);
	as$status(action = RET_STATUS);
       }
        free ( list_grid );
      }
    }

    stat = OM_SET_DIMENSION( ME.expression->pretty_print,
                             ( strlen( wkg_syntax ) + 1 ) * sizeof( char ) ) ;
    Error( stat, "expression.create OM_set_dim( me->pretty_print) error" ) ;

    strcpy( me->pretty_print, wkg_syntax) ;
    /*"in pretty print : '%s'\n", me->pretty_print */

    if(*rc == EXP_SUCCESS )
    { 
      if((name!=NULL) && (strcmp(name, "")!=0) )
      {  
        /*|add the expression to the directory sub-system */
	stat = di$add_name( objname = name, objid   = my_id );
	if(stat!=DIR_S_SUCCESS) 
	{
	  *rc= EXP_INV_NAME;
          UI_status("invalid name"); 
	}
      }
    } /* if all rhs variables exist then ... */
  } /* if Parse = EXP_SUCCESS then ... */

  /* Collect garbage
  --------------- */
  Discard( arg_list, arg_num ); 
  if (arg_grid)
    free( ( char * ) arg_grid );

  return( OM_S_SUCCESS ) ;
}
end implementation expression ;
