/* $Id: VDden.c,v 1.3 2001/01/11 16:34:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDden.c
 *
 * Description:	Density
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDden.c,v $
 * Revision 1.3  2001/01/11 16:34:30  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:57  art
 * s merge
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:11:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/11/01  16:23:54  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/01/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

VDASSERT_FFN("vdah/VDden.c");

/* ------------------------------------------------------------------------
 * The standard struct density routine VSextractDensityFromRDB makes 2 queries
 * to the material table.  There does not appear to be any caching.  It really
 * slows certain processing down.
 *
 * Furthermore, during development, it's often desireable not to have to login
 * to the database just for soemthing liek this.
 *
 * This routine is a quick and dirty means of getting density for struct.
 * The material lpd table was unloaded on 01 Nov 2000 and the values hard coded
 * in.  If this works out ok, then spend the time to make a proper cache later on.
 */
IGRstat VDdenGetDensity(IGRchar   *material, 
			IGRchar   *grade, 
			IGRdouble *density, 
			IGRchar   *unit)
{
  VDASSERT_FN("VDdenGetDensity");
  IGRstat retFlag = 1;
  
  // Arg check
  VDASSERTW(unit);    *unit = 'M';
  VDASSERTW(density); *density = 0.0;
  VDASSERTW(material);
  VDASSERTW(grade);

  // STEEL
  if (!strcmp(material,"STEEL")) {
    // Ignore grade lot's of them
    *density = 7847.7;
    goto wrapup;
  }

  // STAINLESS STEEL
  if (!strcmp(material,"STN STL")) {

    // One special grade
    if (!strcmp(grade,"BAR GRATING")) {
      *density = 990.0;
      goto wrapup;
    }
    
    // Ignore other grades
    *density = 7847.7;
    goto wrapup;
  }

  // ALUMINUM
  if (!strcmp(material,"ALUMINUM")) {
    // Ignore grade 5086 5456 6061-T6 
    *density = 2709.5;
    goto wrapup;
  }

  // COMPOSITE
  if (!strcmp(material,"COMPOSITE")) {

    if (!strcmp(grade,"GRP"))             *density =    1.12;
    if (!strcmp(grade,"GRP/BALSA"))       *density =  144.00;
    if (!strcmp(grade,"L-BAND H100"))     *density =   96.00;
    if (!strcmp(grade,"N/A"))             *density = 1000.00;
    if (!strcmp(grade,"NA"))              *density = 1000.00;
    if (!strcmp(grade,"SBAND/GRP/AIREX")) *density =  144.00;
    if (!strcmp(grade,"SBAND/GRP/BALSA")) *density =  144.00;

    if (*density > .01) goto wrapup;
  }

  // EXPANDED METAL
  if (!strcmp(material,"EXPANDED METAL")) {
    // Ignore grade
    *density = 1565.2;
    goto wrapup;
  }
  // FIBERGLASS
  if (!strcmp(material,"FIBERGLASS")) {
    // Ignore grade
    *density = 493.4;
    goto wrapup;
  }
  // GALVANIZED
  if (!strcmp(material,"GALVANIZED")) {
    // Ignore grade
    *density =    0.0; // ???
    *density = 7847.7;
    goto wrapup;
  }

  // MONEL
  if (!strcmp(material,"MONEL")) {
    // Ignore grade
    *density = 8825.16;
    goto wrapup;
  }

  // PHENOLIC
  if (!strcmp(material,"PHENOLIC")) {
    // Ignore grade
    *density = 1270.0;
    goto wrapup;
  }
      
 
  // Not found
  retFlag = 0;
  
 wrapup:

  // Allow unit to be a success flag as well
  if (!(retFlag & 1)) {
    if (unit) *unit = 0;
  }
  
  return retFlag;
}







