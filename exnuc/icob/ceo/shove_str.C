
/* shove_str.C -- String handling function which shoves a string      */
/*		  into a pre-calloced array ( maybe after re-allocing */
/*		  more room for it ).                                 */

#include <stdio.h>
#include <COBmacros.h>		/*** need this for _bugprint	***/
#include <COBint.h>		/*** REALLOC- & FREE- #defines	***/

#ifdef DEBUG
#include <COB_DBflags.h>
#endif

#ifdef DMALLOC
#  define DEBUG_CHECK	 debug_check();
#else
#  define DEBUG_CHECK
#endif

/********  use this when compiling with -g option **************
#omdef  _bugprint (bflag=COBtrace, str, var = NULL )
if (bflag) fprintf (stderr, str, var);
#endomdef
****************************************************************/


/*** Returns NULL if there was no memory available, or	***/
/***   ptr to address where string was stored		***/
char * COB_shove_str ( string, str_ptr_array, str_ptr_indices,
		    str_ptr_index, str_ptr_array_size )
  char  * string;
  char ** str_ptr_array[];
  int   * str_ptr_indices[];
  int   * str_ptr_index;
  int   * str_ptr_array_size;
{
  int		ii;
  int  		string_length;
  char	      * ch = NULL;
  extern char * realloc();
  extern char * calloc();
  extern char * memcpy();

  _bugprint(bflag = read_debug, str =
	"+COB_shove_str:  str_ptr_array_size = %d\n",
	var = `*str_ptr_array_size` );
  DEBUG_CHECK;
  _bugprint(bflag = read_debug, str =
	"str_ptr_indices[*str_ptr_index=%d]=%d out of %d chars\n",
	var = `*str_ptr_index, (*str_ptr_indices)[*str_ptr_index], FREE_STR_LINE_LENGTH` );

  string_length = strlen ( string ) + 1;

  _bugprint(bflag = read_debug, str =
	"string='%s', str_len=%d\n",
	var = `string, string_length` );


	/*** see if there's room to insert the string in the	***/
	/***   current str_ptr_array[] line			***/
  if (  ( (*str_ptr_indices)[*str_ptr_index] + string_length ) >
						FREE_STR_LINE_LENGTH )
    {	/*** There's not enough room on the current line; ***/
	/***   see if there's another line available ***/
	if ( *str_ptr_index + 1 >=  *str_ptr_array_size )
	  {
	    _bugprint(bflag = 1, str =
		"*****REALLOC'ing str_ptr_array=0x%x to size %d\n",
	    var = `*str_ptr_array, (*str_ptr_array_size + REALLOC_ADD_STR_LINES)` );

		/*** There are no more lines;		***/
	   	/***   realloc the array to get more	***/
	    *str_ptr_array   = (char **)realloc ( *str_ptr_array,
				( *str_ptr_array_size +
					REALLOC_ADD_STR_LINES ) *
						sizeof(char *) );
	    _bugprint(bflag = 1, str = "  NEW str_ptr_array=0x%x\n",
		    var = `*str_ptr_array` );

	    _bugprint(bflag = 1, str =
		"*****REALLOC'ing str_ptr_indices=0x%x to size %d\n",
	    var = `*str_ptr_indices, (*str_ptr_array_size + REALLOC_ADD_STR_LINES)` );

		/*** Resize the index array too		***/
	    *str_ptr_indices = (int *)realloc ( *str_ptr_indices,
				( *str_ptr_array_size +
					REALLOC_ADD_STR_LINES ) *
						sizeof(char *) );
	    _bugprint(bflag = 1, str = "  NEW str_ptr_indices=0x%x\n",
		    var = `*str_ptr_indices` );

	    if ( ! *str_ptr_array  || ! *str_ptr_indices )
		goto quit;

		/*** NULL out the memory ***/
	    for ( ii = *str_ptr_array_size;
		  ii < *str_ptr_array_size + REALLOC_ADD_STR_LINES ;
								ii++ )
	      {
		(*str_ptr_array)[ii] = NULL;
	      }

	    for ( ii = *str_ptr_array_size;
		  ii < *str_ptr_array_size + REALLOC_ADD_STR_LINES ;
								ii++ )
	      {
		(*str_ptr_array)[ii] = calloc ( 1,
					FREE_STR_LINE_LENGTH ); 

		_bugprint(bflag = 1, str =
		  "Calloc'ed str_ptr_array[%d]=0x%x\n",
		  var = `ii, (*str_ptr_array)[ii]` );

		(*str_ptr_indices)[ii] = 0;

		if ( ! (*str_ptr_array)[ii] )
		  {
		    goto quit;
		  }
	      }
	    *str_ptr_array_size = *str_ptr_array_size +
						REALLOC_ADD_STR_LINES;
	  }

	(*str_ptr_index)++;

	_bugprint(bflag = read_debug, str =
	  "***** NO ROOM ON LINE: Incremented str_ptr_index to %d\n",
	  var =`*str_ptr_index` );

    }

  ch= &((*str_ptr_array)[*str_ptr_index][(*str_ptr_indices)[*str_ptr_index]]),

  memcpy ( ch, string, string_length );

  (*str_ptr_indices)[*str_ptr_index] += string_length;

  _bugprint(bflag = read_debug, str =
    "NEW str_ptr_indices[*str_ptr_index=%d]=%d out of %d chars\n",
    var = `*str_ptr_index, (*str_ptr_indices)[*str_ptr_index],FREE_STR_LINE_LENGTH` );

quit:
  _bugprint(bflag = read_debug, str =
    "-COB_shove_str:  Returning 0x%x = '%s'\n", var = `ch, ch` );
  DEBUG_CHECK;

  return ( ch );
}

