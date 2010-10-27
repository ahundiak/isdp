/* $Id: AStoggle.I,v 1.2 2002/06/03 19:18:36 ramarao Exp $  */

/*************************************************************************
 * I/VDS 	emsfixes
 *
 * File:        emsfixes/assoc/AStoggle.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: AStoggle.I,v $
 *      Revision 1.2  2002/06/03 19:18:36  ramarao
 *      Used a seperate flag ( CMPtoggle ) for recompute info.
 *
 *      Revision 1.1  2001/01/18 19:09:02  ramarao
 *      Merged Service Pack Files to 262 pload.
 *
# Revision 1.3  2000/10/23  20:08:34  pinnacle
# Replaced: vds/vdassoc/AStoggle.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/10/23  19:54:52  pinnacle
# Created: vds/vdassoc/AStoggle.I by jpulapar for Service Pack
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 10/23/00   Jayadev	   Creation date.
 *************************************************************************/

class implementation ACncpx;

#include <stdio.h>
#include <math.h>
#include "igrdef.h"
#include "igr.h"
#include "EMSmsgdef.h"
#include "AS_status.h"
#include "grdpbmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "expression.h"
#include "expmacros.h"
#include "acmacros.h"
#include "exmacros.h"

%safe
static 	IGRint		AStoggle_mtd = 0 ;
static 	IGRint		AStoggle_fnc = 0 ;
static 	IGRint		AStoggle_com = 0 ;
static  IGRint		CMPtoggle    = 0 ;
%endsafe

/*** Method Toggle for Assoc  ***/

void VDsetAStoggle_mth() 	{ AStoggle_mtd = 1 ; }
void VDresetAStoggle_mth()	{ AStoggle_mtd = 0 ; }
int  VDgetAStoggle_mth()	{ return AStoggle_mtd ; }

/*** Function toggle for Assoc ***/

void VDsetAStoggle_fnc()	{ AStoggle_fnc = 1 ; }
void VDresetAStoggle_fnc()	{ AStoggle_fnc = 0 ; }
int  VDgetAStoggle_fnc()	{ return AStoggle_fnc ; }

/*** Commands toggle for Assoc ***/

void VDsetAStoggle_com()	{ AStoggle_com = 1 ; }
void VDresetAStoggle_com()	{ AStoggle_com = 0 ; }
int  VDgetAStoggle_com()	{ return AStoggle_com ; }

/*** Flag for recompute debugging information ***/
void VDsetCMPtoggle()        { CMPtoggle = 1 ; }
void VDresetCMPtoggle()      { CMPtoggle = 0 ; }
int  VDgetCMPtoggle()        { return CMPtoggle ; }

/*** Control Routine ****/

void	VD_AStoggle_dbg_globals ( char	*argv)
{
  if ( argv )
  {
    if ( argv[0] == 'm' )
    {
      if ( AStoggle_mtd )
      {
	AStoggle_mtd = 0;
	UI_status ("ASSOC method DEBUG OFF");
      }
      else
      {
	AStoggle_mtd = 1;
	UI_status ("ASSOC method DEBUG ON");
      }
    }
    else if ( argv[0] == 'C' )
    {
      if ( CMPtoggle )
      {
	CMPtoggle = 0;
	UI_status ("ASSOC Compute DEBUG OFF");
      }
      else
      {
	CMPtoggle = 1;
	UI_status ("ASSOC Compute DEBUG ON");
      }
    }
    else if ( argv[0] == 'f' )
    {
      if ( AStoggle_fnc )
      {
	AStoggle_fnc = 0;
	UI_status ("ASSOC funct DEBUG OFF");
      }
      else
      {
	AStoggle_fnc = 1;
	UI_status ("ASSOC funct DEBUG ON");
      }
    }
    else if ( argv[0] == 'c' )
    {
      if ( AStoggle_com )
      {
	AStoggle_com = 0;
	UI_status ("ASSOC comment DEBUG OFF");
      }
      else
      {
	AStoggle_com = 1;
	UI_status ("ASSOC comment DEBUG ON");
      }
    }
    else
    {
      UI_status ("UNKNOWN ARGUMENT: only 'm / f / c' are valid");
    }
  }
  else
  {
    if ( AStoggle_mtd || AStoggle_fnc || AStoggle_com || CMPtoggle )
    {
      AStoggle_mtd = AStoggle_fnc = AStoggle_com = CMPtoggle = 0;
      UI_status ("ASSOC method / funct / comment / Compute DEBUG OFF");
    }
    else
    {
      AStoggle_mtd = 1;
      AStoggle_fnc = 1;
      AStoggle_com = 1;
      CMPtoggle    = 1;

      UI_status ("ASSOC method / funct / comment / Compute DEBUG ON");
    }
  }
}

end implementation ACncpx;
