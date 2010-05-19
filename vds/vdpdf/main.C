/* $Id: main.C,v 1.1 2001/01/11 19:42:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdpdf/main.C
 *
 * Description: Executable
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: main.C,v $
 *      Revision 1.1  2001/01/11 19:42:21  art
 *      sp merge
 *
 * Revision 1.1  2000/08/05  16:51:38  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/31/00  ah      Creation
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDpdf.h"

main(int argc, char *argv[])
{
  IGRchar pdfFileName1[128];
  IGRchar pdfFileName2[128];
  IGRchar difFileName [128];
  
  // Defaults
  strcpy(pdfFileName1,"spades1.pdf");
  strcpy(pdfFileName2,"spades3.pdf");
  strcpy(difFileName, "spades.dif");

  // Check from args
  if (argc > 1) strcpy(pdfFileName1,argv[1]);
  if (argc > 2) strcpy(pdfFileName2,argv[2]);
  if (argc > 3) strcpy(difFileName, argv[3]);
  
  // And do it
  VDpdfDiffFiles(pdfFileName1,pdfFileName2,difFileName);

}
