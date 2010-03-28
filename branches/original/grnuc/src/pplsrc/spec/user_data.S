/*
  user_data.S
  Etienne BEEKER
  21 March 88

  This class is made to keep an arbitrary buffer
  of data in a vla
*/
class specification user_data (0:0) of Root;

instance user_data 
{
 int 		size;		/* size of the array */
 variable char	data[];		/* data itself */
};

message set_data( int size; char *data );
/* to fill the array
 * is better called only once, otherwise the allocated memory
 * is lost 
 * instead of reusing the object, delete it and create a new one
 * or use message update
 */

message get_data( int *size; char **data );
/* to get the data from the array
 * size: IN: the size the user wants to copy
 *	     if size == 0, then a pointer assignment is done 
	     if size != 0, then a memory copy is done
 *	 OUT: the size really copied
 * data: IN: if points on NULL, the size of the vla is returned in size
 *	     ( in this case size must not be 0, otherwise the 
 *	       pointer asigmnet is done )
 */

message update_data( int size; char *data );
/* to update the data of the object
 * check the size for verification
 */

end specification user_data;
