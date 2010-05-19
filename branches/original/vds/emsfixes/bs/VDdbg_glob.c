/*
 * Global variable for controlling execution of BSPMATH data reduction
 *	function : BSr_approxs()
 *	if (VDcv_reduce == 0)   ==>>   NO  execution (DEFAULT)
 *	if (VDcv_reduce == 1)   ==>>   YES execution
 */

int VDcv_reduce;

void VDcv_reduce_dumm()
{
  VDcv_reduce = 0;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              GLOBAL VARIABLE                               */
/*                                                                            */
/* This variable is used in file: emsfixes/grnuc/GMigraph.C and is defined    */
/* here to prevent conflicts when dynamic loading (for debugging) is required */
/*                   refer to TR 179901121 & 179901009                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int toggle_GMloop;          /* Toggle can be set/unset by PPL: ci=toggle_loop */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*
 * debug variables
 *	define debug here - should be passed in from environment
 */

int VDmethod;
int VDfunct;
int VDcomment;

int 	__lvl__ ;		/* current  indentation level */
int	__prev__;		/* previous indentation level */
/*
int VDsymbCmdMethod;
int VDsymbCmdFunct;
int VDsymbCmdComment;
*/

#define	DEF_VDMETHOD	0x00000001;
#define	DEF_VDFUNCT	0x00000010;
#define	DEF_VDCOMMENT	0x00000100;

void	VDtoggle_dbg_globals
(
  char	*argv
)
{
  if ( argv )
  {
    if ( argv[0] == 'm' )
    {
      if ( VDmethod )
      {
	VDmethod = 0;
	UI_status ("VDmethod DEBUG OFF");
      }
      else
      {
	VDmethod = DEF_VDMETHOD;
	UI_status ("VDmethod DEBUG ON");
      }
    }
    else if ( argv[0] == 'f' )
    {
      if ( VDfunct )
      {
	VDfunct = 0;
	UI_status ("VDfunct DEBUG OFF");
      }
      else
      {
	VDfunct = DEF_VDFUNCT;
	UI_status ("VDfunct DEBUG ON");
      }
    }
    else if ( argv[0] == 'c' )
    {
      if ( VDcomment )
      {
	VDcomment = 0;
	UI_status ("VDcomment DEBUG OFF");
      }
      else
      {
	VDcomment = DEF_VDCOMMENT;
	UI_status ("VDcomment DEBUG ON");
      }
    }
    else
    {
      UI_status ("UNKNOWN ARGUMENT: only 'm / f / c' are valid");
    }
  }
  else
  {
    if ( VDmethod || VDfunct || VDcomment )
    {
      VDmethod = VDfunct = VDcomment = 0;
      UI_status ("VDmethod / VDfunct / VDcomment DEBUG OFF");
    }
    else
    {
      VDmethod  = DEF_VDMETHOD;
      VDfunct   = DEF_VDFUNCT;
      VDcomment = DEF_VDCOMMENT;
      UI_status ("VDmethod / VDfunct / VDcomment DEBUG ON");
    }
  }
}
