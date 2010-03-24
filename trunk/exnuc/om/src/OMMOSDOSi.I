class 	implementation	OMMOSDOS;


#include 	"OMobjectcomm.h"

/* the master object space dierctory OS does not allow itself to be deleted */

method	delete (int flag)
{
  return (OM_E_MOSDOS_OS);
}

/* the Master OS object space directory OS does not pass messages. Yet */


end	implementation	OMMOSDOS;
