/* $Id: VDgbl.c,v 1.2 2002/05/10 19:34:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgbl.c
 *
 * Description:	Global static data
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDgbl.c,v $
 * Revision 1.2  2002/05/10 19:34:13  ahundiak
 * ah
 *
 * Revision 1.1  2001/03/11 18:34:04  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/11/01  ah      Creation
 * 05/10/02  ah      Add some more
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDgbl.h"

/* -----------------------------------------------
 * A problem with dynamically loading service packs
 * each time a drawing is retrieved is that static data
 * get's clobberred.
 *
 * Have not had time to research loading service packs only during
 * product startup and probably won't for this pload
 *
 * Each modules could alos store it's static data in a particular
 * files then suppress that file for service packs.  Kind of a pain
 * to manage
 *
 * The idea here is to have a global array of static data pointers
 * which can be used by the various modules.
 *
 * Only VDgbl.c need be removed from a service pack
 */

void *vdGblStaticData00;
void *vdGblStaticData01;
void *vdGblStaticData02;
void *vdGblStaticData03;
void *vdGblStaticData04;
void *vdGblStaticData05;
void *vdGblStaticData06;
void *vdGblStaticData07;
void *vdGblStaticData08;
void *vdGblStaticData09;

void *vdGblStaticData10;
void *vdGblStaticData11;
void *vdGblStaticData12;
void *vdGblStaticData13;
void *vdGblStaticData14;
void *vdGblStaticData15;
void *vdGblStaticData16;
void *vdGblStaticData17;
void *vdGblStaticData18;
void *vdGblStaticData19;

void *vdGblStaticData20;
void *vdGblStaticData21;
void *vdGblStaticData22;
void *vdGblStaticData23;
void *vdGblStaticData24;
void *vdGblStaticData25;
void *vdGblStaticData26;
void *vdGblStaticData27;
void *vdGblStaticData28;
void *vdGblStaticData29;


/* -----------------------------------------------
 * Init the stuff
 */
int VDgblInitStaticData(IGRint flag)
{
  int retFlag = 0;

  // Only process for initial startup
  if (flag != 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Just to be completely safe, clear the pointers
  vdGblStaticData00 = NULL;
  vdGblStaticData01 = NULL;
  vdGblStaticData02 = NULL;
  vdGblStaticData03 = NULL;
  vdGblStaticData04 = NULL;
  vdGblStaticData05 = NULL;
  vdGblStaticData06 = NULL;
  vdGblStaticData07 = NULL;
  vdGblStaticData08 = NULL;
  vdGblStaticData09 = NULL;

  vdGblStaticData10 = NULL;
  vdGblStaticData11 = NULL;
  vdGblStaticData12 = NULL;
  vdGblStaticData13 = NULL;
  vdGblStaticData14 = NULL;
  vdGblStaticData15 = NULL;
  vdGblStaticData16 = NULL;
  vdGblStaticData17 = NULL;
  vdGblStaticData18 = NULL;
  vdGblStaticData19 = NULL;

  vdGblStaticData20 = NULL;
  vdGblStaticData21 = NULL;
  vdGblStaticData22 = NULL;
  vdGblStaticData23 = NULL;
  vdGblStaticData24 = NULL;
  vdGblStaticData25 = NULL;
  vdGblStaticData26 = NULL;
  vdGblStaticData27 = NULL;
  vdGblStaticData28 = NULL;
  vdGblStaticData29 = NULL;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

 





