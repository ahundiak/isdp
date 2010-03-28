/*
 * Files where PCI global variables are declared ( thanks to PCIGLOBALS ) and
 * initialized.
 */

#define PCIGLOBALS
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include <malloc.h>
#include <string.h>
/*----------------------------------------------------------------------------*/
void GLOinit( F ) SysVfname F ; {

  register usage *s						;
  int		i						;
  void		NODreset(), FAOreset(), REGreset(), INSreset()	;

  PCI_G_externals = 0 ; 
  PCI_Set_current_line( 1 ) ;
  PCInlab	= 0					;
  PCInvar	= 0					;
  PCIerr	= FALSE					;
  PCI_G_var	= PCIdata->vartable			;
  PCI_G_adr	= (PCIpointer *) PCIdata->varvaltable	;
  PCI_G_typ	= PCIdata->vartypetable			;
  PCI_G_dim	= (short *)PCIdata->vardimtable		;
  PCI_G_sts	= PCIdata->varflagtable			;
  PCIseg.data   = PCIval( 0 )				;
  PCInvar	= 0					;
  PCInins	= 0					;
  PCIdata->nbf_entries	= 0				;
  PCIfcn	= EMPTY					;
  PCIgen	= TRUE					;

/* -- Reset data segment to 0.
   -- */
  memset( PCIseg.data, 0, MAXDATA )		;
  PCI_Set_current_file( strcpy( PCIfile, F ) )	;

  NODreset()		;
  FAOreset()		;
  REGreset() 		;
  INSreset()		;

  for( i = 0, s = PCI_G_used ; i < MAXVAR ; i++, s++ ) s->stat = VAR_IGNORE ;
  
}
/*----------------------------------------------------------------------------*/

