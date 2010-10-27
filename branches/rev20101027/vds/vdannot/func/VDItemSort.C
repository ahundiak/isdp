/* $Id: VDItemSort.C,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/func/VDItemSort.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDItemSort.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/09/11  21:55:30  pinnacle
 * Replaced: vdannot/func/VDItemSort.C for:  by jwfrosch for vds.240
 *
 * Revision 1.1  1995/09/11  20:41:48  pinnacle
 * Created: vdannot/func/VDItemSort.C by jwfrosch for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include "VDitemNum.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VD_comp_ItemNumbers
(
  char		*ItemNum_1,
  char		*ItemNum_2
)
{
  int		 stat_1 = 0, stat_2 = 0;
  int		 Inum_1 = 0, Inum_2 = 0, nmx = 0, pfx = 0, sfx = 0;

  char		 Prefix_1	[VD_ITEMNUM_LEN],
		 Prefix_2	[VD_ITEMNUM_LEN],
		 Suffix_1	[VD_ITEMNUM_LEN],
		 Suffix_2	[VD_ITEMNUM_LEN];

  Prefix_1[0] = Prefix_2[0] = Suffix_1[0] = Suffix_2[0] = '\0';

  stat_1 = VD_parseItemNum ( ItemNum_1, Prefix_1, &Inum_1, Suffix_1 );
  stat_2 = VD_parseItemNum ( ItemNum_2, Prefix_2, &Inum_2, Suffix_2 );

  if ( stat_1 && stat_2 )
  {
    pfx = strcmp ( Prefix_1, Prefix_2 );
    sfx = strcmp ( Suffix_1, Suffix_2 );
    nmx = Inum_1 - Inum_2;

    if ( pfx )			/* Prefixes are different	*/
    {
      return ( pfx );
    }
    else			/* Prefixes are equal		*/
    {
      if ( nmx )		/* ItemNums are different	*/
      {
	return ( nmx );
      }
      else			/* ItemNums are equal; sort on Suffix	*/
      {
	return ( sfx );
      }
    }
  }
  else
  {
    return ( 0 );		/* DO NOTHING		*/
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
