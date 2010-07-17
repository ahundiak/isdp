
/* $Id: VCGuide.S,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide / VCGuide.S
 *
 * Description:
 *   instantiated class for the general cable conduit class.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCGuide.S,v $
 *        Revision 1.2  2002/05/08 15:48:24  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *        Initial import to CVS
 *
# Revision 1.2  2000/03/15  21:55:06  pinnacle
# Replaced: vcguide/VCGuide.S for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/24  22:43:22  pinnacle
# Replaced: vcguide/VCGuide.S for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.7  1997/05/22  13:52:28  pinnacle
# Replaced: vcguide/VCGuide.S for:  by hverstee for cabling
#
# Revision 1.6  1997/03/06  23:03:32  pinnacle
# Replaced: vcguide/VCGuide.S for:  by hverstee for cabling
#
# Revision 1.5  1996/11/25  17:38:08  pinnacle
# Replaced: vcguide/VCGuide.S for:  by hverstee for cabling
#
# Revision 1.4  1996/10/09  21:57:10  pinnacle
# Replaced: vcguide/VCGuide.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:07:14  pinnacle
# Replaced: vcguide/VCGuide.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  16:02:06  pinnacle
# Replaced: vcguide/VCGuide.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:41:40  pinnacle
# Created: vcguide/VCGuide.S by hverstee for cabling
#
 *
 * History:
 *   05/29/96   hv    Initial
 *   03/15/00   law   CR179901086 - Allow guide vertex moves and inserts
 *
 *************************************************************************/

class specification VCGuide (0:0) of VCRoot;

instance VCGuide
{
  /*   adjustable sizes of conduit (round/rectangular)  - NO DB....*/
  IGRdouble    dSize1;
  IGRdouble    dSize2;

  variable IGRdouble  dBendRad[0];   /*  override string bends?   */
};

/*C define my placement method */
override  NDchildren_deleted;
override  NDplace;
override  NDdelete;
override  GRdelete;

override  VCGetModel;

/*C Returns the guide length */
override  ACgive_structure;

/*C define my method of recomputation */
override  ACconstruct_feet;

/*C return my instance */
override  VCSetInstance;
override  VCGetInstance;

override  VCGetMatrix;
override  VCSetTagNo;

override  GRgetobjinfo;

override  VCGetCptGeom;
override  VCGetCptCoord;

override  VCCmpDef;

override VCDUMP;

override VDPostYourselfToDb;

/* methods for using the me->Data backdoor provided in VCRoot */
override      VCSetDataVLA, VCGetDataVLA, VCDataTypeSize;

/*************************************************************************
*C redirect these messages to my parent ??
override  GRmodify;
override  GRxform;
override  GRcopy;
override  GRdelvertex;
override  GRinsvertex;
override  GRmoveseg;
override GRsegfind, GRremovepts, GRputpolyline;
override GRptalong, GRendpoint, GRmidpoint, GRperbis,
         GRptextend, GRdisextend, GRsplit, GRtotlength, GRgenabsg,
         GRgeomprops, GRgetgeom, GRprojpt, GRptdis, GRgetattr, 
         GRgetsymb, GRcenter, GRdynmod, GRapprojpt, GRlocate,
         GRgetsize, GRgetprops, GRgethprops, GRgetrang;

including the spline messages
*****************************************************************************/

/*    no more GR inherit 
override  GRlnproject; 
override  GRptproject;
override  GRendpts; 
override  GRvtadjseg;
override  GRgetpolyline;
*/

override VDgetObjDef;

message   VCGd_GetGRid(  IGRlong         *msg;
                  struct GRid            *LineGRid;
                  struct GRmd_env        *md_env);

/*      VCGd_GetGRid
/*
/*       Retrieve the GRid of the parent string/spline
/*
/*       msg        O      error message
/*       LineGRid   O      GRid
/*       md_env     I      Environment
*/

/*     retrieve linestring coordinates    */

message VCGdLdLine (IGRlong     *msg;
                    IGRshort     strno;
             struct IGRpolyline *LineIn;
             struct GRmd_env    *md_env;
                    IGRchar     *linattr);


/*      modify linestring section          */

message    VCGdModify (IGRlong        *msg;
                       IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                       IGRint          AdjType;   /*  adjustment type        */
                       IGRint          SecNum;    /*  section number         */
                       IGRint          VtxNum;    /*  vertex/segment number  */
                       IGRdouble      *dCoord;    /*  coordinates            */
               struct  GRmd_env       *md_env;
                       IGRchar        *modattr);

/*       find vertex/segment and section given coordinates    */

message    VCGdFind   (IGRlong        *msg;
                       IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                       IGRint         *AdjType;   /*  adjustment type        */
                       IGRint         *SecNum;    /*  section number         */
                       IGRint         *VtxNum;    /*  vertex/segment number  */
                       IGRdouble      *dCoord;    /*  coordinates            */
                       IGRint          DisCor;    /*  Normal on coordinates  */
                       IGRdouble      *dDynCor;   /*  coords for dynamics    */
                       IGRint         *EndPos;
               struct  GRmd_env       *md_env;
                       IGRchar        *fndattr);
/*        return vertex coords given number and section       */

message    VCGdVertex (IGRlong        *msg;
                       IGRint          SecNum;    /*  section number         */
                       IGRint          VtxNum;    /*  vertex/segment number  */
                       IGRdouble      *dCoord;    /*  coordinates            */
               struct  GRmd_env       *md_env;
                       IGRchar        *vrtxattr);



end specification VCGuide;
