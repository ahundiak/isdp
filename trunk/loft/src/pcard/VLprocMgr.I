class implementation VLlocateCmd;

#include "AS_status.h"
#include "FI.h"
#include "DIdef.h"

static	Form	VLprocForm;
static	int	VLprocXPos;
static	int	VLprocXIncre;
static	int	VLprocDVal;
static	int	VLprocDIncre;
static	int	VLprocMgrCount;

static	int	VLprocFActive;
static	char	*pVLprocFText;
static	int	VLprocSmsg;
static	char	*pVLprocSUserText;
static	char	VLprocSText[DI_PATH_MAX];

#define	VL_PC_X_INCRE	-120
#define VL_PC_X_MAX	1060
#define	VL_PC_X_MIN	110

long	VLprocMgrInit()
{

	VLprocMgrCount	= 0;

	FIf_new( 4, "VLprocess", NULL, &VLprocForm );

	VLprocFActive	= 1;
	VLprocXPos	= VL_PC_X_MAX;
	VLprocXIncre	= VL_PC_X_INCRE;
	VLprocDVal	= 0;
	VLprocDIncre	= 1;
	VLprocSmsg	= 0;
	
	pVLprocFText		= NULL;
	pVLprocSUserText	= NULL;
	VLprocSText[0]		= '\0';

return	MSSUCC;
}

long	VLprocMgrClose()
{
	if( VLprocFActive )	FIf_delete(  VLprocForm );
	VLprocFActive		= 0;
	pVLprocFText		= NULL;
	VLprocSmsg		= 0;
	pVLprocSUserText	= NULL;
	VLprocMgrCount		= 0;

return	MSSUCC;
}

long	VLprocSetFText( char *userFText )
{
	pVLprocFText	= userFText;

return	MSSUCC;
}

long	VLprocSetSText( int msgNumber, char *msgArg ) 
{
	VLprocSmsg		= msgNumber;
	pVLprocSUserText	= msgArg;

return	MSSUCC;
}

long	VLprocMgrPulse()
{
int	i;

	// process form
	if( VLprocFActive ){

		FIf_erase( VLprocForm );

		if( VLprocMgrCount )VLprocXPos += VLprocXIncre;
		if( VLprocXPos < VL_PC_X_MIN ){
			VLprocXPos	= VL_PC_X_MIN;
			VLprocXIncre	*= -1;
		}
		if( VLprocXPos > VL_PC_X_MAX ){
			VLprocXPos	= VL_PC_X_MAX;
			VLprocXIncre	*= -1;
		}

		FIf_set_location( VLprocForm, VLprocXPos, 0 );

		if( VLprocMgrCount )VLprocDVal += VLprocDIncre;
		FIg_set_value( VLprocForm, 11, (double)VLprocDVal );

		FIg_set_text( VLprocForm, 14, pVLprocFText );

//		FIf_display( VLprocForm );
	}

	// status field
	if( VLprocSmsg ){
		strcpy( VLprocSText, "..." );
		for( i=0; i<VLprocMgrCount; i++ ) strcat( VLprocSText, "." );
		if( pVLprocSUserText ) strcat( VLprocSText, pVLprocSUserText );

		ex$message(	 msgnumb	= VLprocSmsg,
				type		= "%s",
                	       	var		= `VLprocSText`);
	}

	VLprocMgrCount++;

return	MSSUCC;
}

end implementation VLlocateCmd;

