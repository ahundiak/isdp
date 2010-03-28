/*
  user_data.I
  Etienne BEEKER
  21 March 88

  This class is made to keep an arbitrary buffer
  of data in a vla
*/

class implementation user_data;

#	include "OMminimum.h"
#	include "OMmacros.h"
#	include "codef.h"

method set_data( int size; char *data )
/*
 * to fill the array
 * is better called only once, otherwise the allocated memory
 * is lost 
 * instead of reusing the object, delete it and create a new one
 * or use message update
 */
{
  int status;

  status = om$vla_set_dimension(varray= me->data,
				size = size);
  if(COERROR(status)){
	printf("ERROR: user_data.set_data -> vla inst\n");
  } else {
	if (data) memcpy(me->data, data, size);
	me->size = size;
  }

  return 1;
}

method get_data( int *size; char **data )
/*
 * to get the data from the array
 * size: IN: the size the user wants to copy
 *	     if size == 0, then a pointer assignment is done 
	     if size != 0, then a memory copy is done
 *	 OUT: the size really copied
 * data: IN: if points on NULL, the size of the vla is returned in size
 *	     ( in this case size must not be 0, otherwise the 
 *	       pointer asignment is done )
 */
{
  if( *data == NULL && *size != 0 ){
 	*size = me->size;
	return 1;
  }
  if( *size == 0 ){
	*data = me->data;
	return 1;
  }
  if( *size > me->size )
 	*size = me->size;
  memcpy(*data, me->data, *size);
  return 1;
}

method update_data( int size; char *data )
/*
 * to update the data of the object
 * check the size for verification
 */
{
  if( size != me->size ){
	printf("user_data.update_data: bad size given\n");
	return 0;
  }

  memcpy(me->data, data, size);
  return 1;
}
 
end implementation user_data;

