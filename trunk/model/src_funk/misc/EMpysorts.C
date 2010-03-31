/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

EMsortpyptsl (EMmsg, polyinters, dim, toginfo, partolbasis, loopdata,
               ingeom, options, noint)
IGRlong *EMmsg;
struct EMSpypoint **polyinters;
IGRint dim;
IGRint *toginfo;
struct EMSpartolbasis *partolbasis;
struct EMSdataselect *loopdata;
struct EMSdataselect *ingeom;
IGRushort options;
IGRint *noint;
{
 IGRlong  msg_loc;
 IGRdouble uvlentol;
 IGRint num_bdrys;
 IGRboolean addatstart, addatend;
 struct EMSpypoint *addpy[2];
 struct EMSpypoint *pyptr, *pyend, *nxptr;
  extern  void     EMpypoint_free ();
 void     EMmkpybdrysl ();
 void     EMsortpypts ();
 
 *EMmsg = EMS_S_Success;

 pyptr = NULL;
 pyend = NULL;
 addpy[0] = NULL;
 addpy[1] = NULL;
 *noint = 0;

 EFextract_par (BSTOLLENVEC, partolbasis->tol, &uvlentol, &msg_loc);

 EMsortpypts (&msg_loc, polyinters,dim,toginfo,&uvlentol);
 EMerr_hndlr (EMSerror (msg_loc), *EMmsg, msg_loc, wrapup);

 EMmkpybdrysl(&msg_loc,ingeom,polyinters,loopdata,options,
              partolbasis, &num_bdrys, NULL, &addpy[0],
              &addpy[1]);
 EMerr_hndlr (EMSerror (msg_loc), *EMmsg, msg_loc, wrapup);

 addatstart = (addpy[0] ? TRUE : FALSE);
 addatend = (addpy[1] ? TRUE : FALSE);
 if (addatstart ^ addatend)
   *noint = (num_bdrys - 1) * 2 + 1;
 else if (addatstart && addatend)
   *noint = (num_bdrys - 2) * 2 + 2;
 else
   *noint = num_bdrys * 2;

 if (addpy[0])
 {
  *polyinters = addpy[0]->next;
  EMpypoint_free (addpy[0],1);
 }
 
 if (addpy[1])
 {
  pyptr = (*polyinters);
  nxptr = pyptr->next;
  while (nxptr->next && (nxptr->span_inx >= 0))
  {
     pyptr = pyptr->next;
     nxptr = nxptr->next;
  }

  pyptr->next = nxptr->next;
  EMpypoint_free (nxptr, 1);
 }

wrapup:
 return;
}
