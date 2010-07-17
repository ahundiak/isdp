class specification VRCopySurf (1:0) of VDB_LOCATE;



#include	"growner.h"


instance VRCopySurf
{
	IGRdouble		dFromPnt[3];
	IGRdouble		dDestination[3];
  	IGRint			NumOfObjects;	/* number of located objects */
  	struct	GRobj_env	*LocatedObjects;  /* list of located objects */
};


override init;

override delete;

message VRFreeMemory ( );

message VRGetLocObjects ( long * sts );

message VRGetFromPnt ();

message VRGetDestnPnt ();

message VRCopyXform ( );

end specification VRCopySurf;
