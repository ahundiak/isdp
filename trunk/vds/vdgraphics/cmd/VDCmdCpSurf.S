class specification VDCmdCpSurf (1:0) of VDS_LOCATE;



/*+cmd
  Command Object Class VDCmdCpSurf

  Superclass
      VDS_LOCATE

  Abstract
      Command object for "Copy Component Surfaces"

  Methods
      <Name>		<Public/Private>	<Description>
      
       VDFreeMemory	Private			Free memory
       VDGetLocObjects  Public			Gets the located objects and
						stores the info in the instance
						data
       VDGetFromPnt	Public			Gets the From Pnt and stores it
						in the instance data.
       VDGetDestnPnt	Public			Gets the Destination Pnt and
						stores it in the instance data
       VDCopyXform	Private			Copies and Xforms the objects
						identified.
	
  Overridden Methods
     <Name>		<Description>

      init		Initialize my instance data also.
      delete		Free any memory that has been allocated by COB

-cmd*/

#include	"growner.h"


instance VDCmdCpSurf
{
	IGRdouble		dFromPnt[3];
	IGRdouble		dDestination[3];
  	IGRint			NumOfObjects;	/* number of located objects */
  	struct	GRobj_env	*LocatedObjects;  /* list of located objects */
};


override init;

override delete;

message VDFreeMemory ( long * sts );

message VDGetLocObjects ( long * sts );

message VDGetFromPnt ( long * sts );

message VDGetDestnPnt ( long * sts );

message VDCopyXform ( long * sts );

end specification VDCmdCpSurf;
