/* $Id: IGRdiri.I,v 1.1 2002/08/05 14:26:54 ramarao Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdutil/VDdumpGeom.I
 *
 * Description:
 *      This is the implementation file of the class IGRdir.  This class
 *      provides a layered naming capability with full support of the UNIX
 *	directory system user interface. It also supports the reference
 *      file attachments.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: IGRdiri.I,v $
 *      Revision 1.1  2002/08/05 14:26:54  ramarao
 *      Fixed TR# 6467.
 *
 *
 * History:
 * MM/DD/YY AUTHOR    DESCRIPTION
 * 08/05/02 Rama Rao  File Creation in VDS.
 * 11/17/10 ah        SOL10 Looks like it fixed a core dump
 * -------------------------------------------------------------------*/

class implementation IGRdir;

#include "OMerrordef.h"
#include "DIomac.h"

#define INCREMENT 64

DIadd_grid ( grids, count, info )
             DIgrid **grids					/* IN/OUT */;
             DIint  count					/* IN     */;
             DIgrid info					/* IN     */;
{
  if (count && (*grids) )
  {
    if (!((count + 1) % INCREMENT))
      DIrealloc ( *grids, DIgrid *, (count + INCREMENT) * sizeof ( DIgrid ) )
  }
  else
  {
    count = 0;
    DImalloc ( *grids, DIgrid *, INCREMENT * sizeof ( DIgrid ) )
  }

  (*grids) [count] = info;

  return DIR_S_SUCCESS;
}

end implementation IGRdir;
