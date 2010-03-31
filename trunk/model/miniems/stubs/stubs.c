#include <stdio.h>
#include "OMminimum.h"

/*
 * These are needed since we do not bring in the following classes,
 * but GRreffile.S and IGEcolor2.S define channels to these classes
 * and hence these class ids have to be defined somewhere.
 */

 OMuword OPP_GRcontext_class_id = 65535;
 OMuword OPP_APPcolor2_class_id = 65535;
 OMuword OPP_IGEcolsup_class_id = 65535;
 OMuword OPP_IGEuserramp_class_id = 65535;

/*
 * Stub declaration for this global flag that pervades the Model universe.
 * Setting it TRUE, implies that where a dual behavior (of old and new) is
 * coded, miniEMS will choose the new behaviour.
 */

short WANT_POST220_BEHAVIOR=1;
OM_S_OBJID current_creator;

/*
 * For some reason, EXNUC uses this function to throw up errors. An old,
 * near-defunct function no doubt.
 */

EX_error_box()
{
  fprintf (stderr, "EX_error_box - stub hit\n"); 
}

/* This file contains stubs for the Btree functionality that is not available
   on NT
*/

tdelete()
{
   printf("Stub Hit for _tdelete()\n");
}

tfind()
{
   printf("Stub Hit for _tfind()\n");
}

tsearch()
{
   printf("Stub Hit for _tsearch()\n");
}

twalk()
{
   printf("Stub Hit for _twalk()\n");
}

