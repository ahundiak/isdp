
/* $Id: VCCtab.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCtab.S
 *
 * Description:
 *
 *  Class Specification for connectivity table load.
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCtab.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.1  1997/07/31  20:25:48  pinnacle
# Created: vccmdconn/VCCtab.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCCtab (1:0) of Root;

#include <stdio.h>
#include <string.h>
#include <float.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "asdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "acrepmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCCmdCON.h"
#include "VCparameters.h"

#include "VCproto.h"

instance VCCtab
{
  struct GRid     TBref;       /*C item being connected */
  struct GRid     TBmodel;     /*C DB cache id          */
  IGRint          iTBType;     /*C located elem type, possible elements are
                                 "FO equipment", "connector", "cable"        */
  IGRint          iTBprod;     /*   product                                  */

  IGRchar         szTBtag[VC_MAX_TAGNO]; /*  tag of refid                    */
  IGRchar         szTBeqt[VC_MAX_EQ_ID]; /*  tag of associated equipment     */

  IGRboolean      bICB;                  /*  two-sided terminal layout flag  */

  /*C instance to hold connection info (for modification purposes)           */

  IGRshort        nNumConTab;  /* number of connecttable entries  */
  IGRshort        nNumConEnt;  /* number of layout entries        */

  IGRshort        nMaxCnd;     /* candidate table size            */
  IGRshort        nMaxCon;     /* connect table size              */

  IGRshort        nCndNum;     /* current # of free leads         */

  struct VCcontab INITstr;     /* initialized struct              */
  struct VCcsgtab INITsig;     /* initialized struct              */
  struct VCpos    INITtrm;     /* initialized struct              */

  /****************************************************************/
  /*      Attached cables list                                    */

  variable
  struct GRid     CabTab[0];   /* GRid's of connected items       */

  variable
  IGRshort        nCPS[0];     /* Cpts of connected items         */

  /****************************************************************/
  /*      TABLES FOR CONNECTIONS                                  */

  variable
  struct VClayout PosTab[0];   /*   positions                     */

  /*     tables -- connected to.....                              */

  variable
  struct VCcontab ConTab1[0];  /*   first (single) side           */

  variable
  struct VCcsgtab ConSig1[0];  /*   signals first side            */

  variable
  struct VCcontab ConTab2[0];  /*   second (if double) side       */

  variable
  struct VCcsgtab ConSig2[0];  /*   signals second side           */

  /****************************************************************/
  /*      TABLE FOR CANDIDATES                                    */

  variable
  struct VCcontab  CndTab[0];  /*   unconnected leads             */

  variable
  struct VCcsgtab  CndSig[0];  /*   unconnected signals           */

};

message VCCtLoad   (IGRlong      *sts;
             struct GRid         *LoadId;        /*   load tables   */
             struct GRmd_env     *md_env);

message VCCtInsert (IGRshort      index);      /*   insert item   */

message VCCtClear  (IGRlong      *sts);

end specification VCCtab;

