/*

Name
  GRvardebug.I

Description
  Debug method of GRvar class
  
Notes

 */

class implementation GRvar;

#include <stdio.h>
#include "grimport.h"
#include "OMmacros.h"


static void print_contents ( var_def )
  struct GRIOvar_def *var_def;
{

  switch ( var_def->type )
  {
    case GRIO_VAR_FLOAT  : 
    {
      printf ( "var_def.type     = GRIO_VAR_FLOAT\n" );
      printf ( "var_def.contents = %g\n", var_def->contents.fvalue );
      break;
    }

    case GRIO_VAR_INT    : 
    {
      printf ( "var_def->type = GRIO_VAR_INT\n" );
      printf ( "var_def.contents = %d\n", var_def->contents.ivalue );
      break;
    }
    case GRIO_VAR_STRING :
    {
      printf ( "var_def.type     = GRIO_VAR_STRING\n" );
      printf ( "var_def.contents = \"%s\"\n", var_def->contents.string );
      break;
    }

    case GRIO_VAR_POINT  :
    {
      printf ( "var_def.type     = GRIO_VAR_POINT\n" );
      printf ( "var_def.contents = [ %g, %g, %g ]\n", 
	       var_def->contents.point[0],
	       var_def->contents.point[1],
	       var_def->contents.point[2] );
      break;
    }

    default              :
    { 
      printf ( "WARNING! Corrupted variable contents!  No such type <%d>\n",
               var_def->type );
    }
  }
}


method debug ( )
{
  int  
    status = OM_S_SUCCESS,
    var_list_count   = -1,
    alias_list_count = -1,
    ii;
  
  status = om$send( mode = OM_e_wrt_message,
                    msg = message GRunit.debug(),
                    targetid = my_id );

  /*
   * Non VLA instance data
   */
  printf ( "I think I have %d variables.\n", me->num_variables );
  printf ( "I think I have %d aliases.\n", me->num_alias );
  
  /*
   * get vla info and display it in a neat table format
   */
  var_list_count   = om$dimension_of ( varray = me->var_list );
  alias_list_count = om$dimension_of ( varray = me->alias_list ); 

  printf ( "True me->alias_list size = %d\n", alias_list_count );
  printf ( "True me->var_list   size = %d\n", var_list_count );

  /*
   * does the size we save match the true size?  This is a bad design (we should
   * use om$dimension_of() to get the size each time, instead of saving it! This
   * is where things can go bad wrong.
   */
  if ( alias_list_count != me->num_alias )
  {
    printf ( "WARNING!  ALIAS LIST COUNT DOES NOT JIVE WITH ACTUAL VLA SIZE!\n" );
  } 
  if ( var_list_count != me->num_variables )
  {
    printf ( "WARNING!  VARIABLE LIST COUNT DOES NOT JIVE WITH ACTUAL VLA SIZE!\n" );
  } 
  
  if ( var_list_count != alias_list_count )
  {
    printf ( "WARNING!  A serious problem exists!\n" );
    printf ( "The two VLA's should be the same size!\n" );

    if ( var_list_count > alias_list_count )
    {
      printf ( "%d aliases missing.\n", ( var_list_count - alias_list_count ) );
    }
    else
    {
      printf ( "%d aliases w/o content.\n", (alias_list_count-var_list_count) );
    }
  } 
  
  /*
   * validation of aliases and contents 
   */
  for ( ii = 0; ( ii < alias_list_count && ii < var_list_count ); ii++ )
  {
    printf ( "\n" ); /* seperate table entries */
    printf ( "me->alias_list[%d].alias = %s\n", ii, me->alias_list[ii].alias );
    printf ( "me->alias_list[%d].index = %d\n", ii, me->alias_list[ii].index );

    if ( me->alias_list[ii].index > ( var_list_count - 1 ) )
    {
      printf ( "WARNING: THIS INDEX IS OUT OF RANGE!\n" );
    }
    else
    {
      print_contents ( &me->var_list[ (me->alias_list[ii].index) ] );
    }
  }
  
  return OM_S_SUCCESS;
}

end implementation GRvar;
