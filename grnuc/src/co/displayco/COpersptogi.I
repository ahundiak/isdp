class implementation COTogPerBh;



#include "dpcodef.h"
#include "dpcomacros.h"
#include "grmessage.h"

%safe
#include "DPcodpbi.h"
%endsafe


#define _start 0

method toggle_perspective_flags ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRushort pflag;

	dp$codpb_get_persp_flags( persp_flags= &pflag );
	pflag = pflag ^ PERSP_CHANGE_ANGLE;
	if ( pflag & PERSP_CHANGE_ANGLE )
	{
	   ex$message( msgnumb = GR_I_ChangeAngle );
	}
	else
	{
	   ex$message( msgnumb = GR_I_ChangeEyept );
	}

	dp$codpb_set_persp_flags ( 
		persp_flags = pflag);
	quit:
  return OM_S_SUCCESS;
}

end implementation COTogPerBh;
