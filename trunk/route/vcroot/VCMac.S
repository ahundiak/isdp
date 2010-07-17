
/* $Id: VCMac.S,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCMac.S
 *
 * Description:
 *
 *      Abstract class to define the behavior of a cabling macro based
 *      component.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCMac.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/07/14  21:59:34  pinnacle
# Created: vcroot/VCMac.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class specification VCMac (0:0) of VCRoot;

instance VCMac
{
  variable
  IGRdouble               dVCOffVal[0]; /*  offset values, depending
                                            on type spec          */
};

/*   MESSAGES            */

/*   Method returns parent equipment ID or NULL_OBJID if the parent is
     not Equipment .....                                                  */

message  VCGetEquipId (IGRlong  *msg;
                struct GRid     *EquipId);

message  VCGetEquipTag (IGRlong  *msg;
                        IGRchar  *EqTag;
                 struct GRmd_env *md_env);

/*   macro place                          */

message VCMacroPut (IGRlong    *msg ;
             struct GRid       *MacId;
             struct GRmd_env   *md_env);

/*   Get macro name                       */

message VCMmacname (IGRlong    *msg;
                    IGRchar    *szMacNam);

/************************************************************************/
/*    Following messages will adapt the macro template specifications
      for placement and embedded macro creation

      Isn't the macro system wonderful ??????                           */

/*    Change for placement ....... set bEmbed == TRUE for embedded
      macro creation                                                    */

message VCMchgup   (IGRlong    *msg;
                    IGRboolean  bEmbed;      /*   embedded creation     */
                    IGRint     *nREP;        /*   =1 if ~rep exists     */
                    IGRchar    *szMacNam;    /*   opt. macro name       */
             struct GRid       *MacDef);     /*   opt. macro def id     */

/*    Change back to regular state                                      */

message VCMchgdn   (IGRlong    *msg;
                    IGRchar    *szMacNam;    /*   opt. macro name       */
             struct GRid       *MacDef);     /*   opt. macro def id     */

/************************************************************************/

message VCMErrGraphic(IGRlong   *msg;
               struct GRid      *GraphicId;
               struct GRmd_env  *md_env);

/*   OVERRIDES for general assoc/graphics methods          */
/*             and some selected VC messages               */
/*             (for backshell and terminal)                */

override VCSetInstance;
override VCGetInstance;

override VCDUMP;

override NDcopy;
override NDupdate;

override ACconstruct_feet;
override ACgive_structure;

/*   implement flex move .....  */

override GRxform, GRmodify;

end specification VCMac;

