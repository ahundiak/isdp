/*
 * CI macros dealing with channels and their connected objects
 * Feb '88
 *
 * File dependency: none.
 */

#ifndef cichannel_include
#define cichannel_include



/************************* ci$get_channel_objects *****************************/
/*
   DESCRIPTION
  	Builds a list of objects that are on an object's channel specified
  	by its name.
  
   ARGUMENTS:
  	Type	Name	       I/0 Description
  	short	osnum		I  The object space number
  	GRobj	objid		I  The object id.
  	char	*channame:	I  The full channel name
  	short	osn_list[]	O  The list of object space numbers of the
  					connected objects.
  	GRobj	obj_list[]	O  The list of objec ids of the connected
  					objects.
  	int	*count		O  The number of connected objects.
  
   RETURN CODE
  	1 in case of success
  	An OM error code case of error ( OM error codes are defined in
	OMerrordef.h )
	
   NOTE: if "osnum" is not specified, the CURRENT object space will be taken.
  
   SAMPLE INVOCATION

		if( ci$get_channel_objects(
				objid		= obj,
		     		channame	= "Class_C.to_HSV",
				obj_list	= OutList,
				count		= &ObjNumber ) != 1 )
		{
			 write("Something went wrong somewhere\n");
			 goto ERROR_POINT;
		}
*/

#omdef ci$get_channel_objects(
				osnum		= -1,
				objid,
				channname,
				osn_list	= (short *)0,
				obj_list,
				count )

CIget_channel_objects(
				(osnum),
				(objid),
				(channname),
				(osn_list),
				(obj_list),
				(count) )
#endomdef

#endif
