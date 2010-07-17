
/* $Id: VCCon.S,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCCon.S
 *
 * Description:
 *	The abstract class VCCon declares all messages to be used to
 *      access internal connectivity that is stored as instance tables
 *      refining the connectivity expressed by channel links.
 *      The methods declared in this abstract class maintain and access
 *      these tables.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCon.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.8  1997/07/14  21:56:04  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.7  1997/01/23  23:26:42  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.6  1997/01/20  20:18:32  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.5  1996/10/25  13:45:42  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.4  1996/10/03  18:06:52  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/20  21:18:04  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/18  20:42:44  pinnacle
# Replaced: vcroot/VCCon.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:10:08  pinnacle
# Created: vcroot/VCCon.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCCon (0:0) of VCX;

instance VCCon
{
};

/*---------------------------------------------------------------------------*/
/*                     Internal Connection management                        */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
        message VCConnect

        connect my specified positions with the positions on the
        other object

      *msg;            I/O - return status
       num             I   - number of connections to make
      *ConId;          I   - Connection ID structs on myself
      *OConId;         I   - Connection ID structs on other object
      *OGrid           I   - GRid of other objects

*/

message VCConnect(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid);

/*---------------------------------------------------------------------------
        message VCConDisc

        disconnects a set of positions

      *msg;            I/O - return status
       num             I   - number of connections to break
      *ConId;          I   - Connection ID structs on myself
      *OConId;         I   - Connection ID structs on other object
      *OGrid           I   - GRid of other objects

*/

message VCConDisc(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid);

/*---------------------------------------------------------------------------
        message VCConDscall

        disconnects all leads of an object

      *msg;            I/O - return status
       nCpt            I   - my connectpoint   (ONLY FOR CABLE)

*/

message VCConDscall (IGRlong        *msg;
                     IGRshort        nCpt);

/*---------------------------------------------------------------------------*/
/*                     Signal name storage                                   */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
        message VCGetSignal

        return signal name stored for connect position

      *msg;            I/O - return status
      *ConId;          I   - Connection ID string
      *sigid;          O   - Signal name
*/

message VCGetSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid);
/*---------------------------------------------------------------------------
        message VCPutSignal

        store signal name for connect position

      *msg;            I/O - return status
      *ConId;          I   - Connection ID string
      *sigid;          I   - Signal name
*/

message VCPutSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid);
/*---------------------------------------------------------------------------
        message VCSetSignal

        store and propagate signal name for connect position

      *msg;            I/O - return status
      *ConId;          I   - Connection ID string
      *sigid;          I   - Signal name
*/

message VCSetSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid);

/*---------------------------------------------------------------------------*/
/*                     Internal Connection retrieval                         */
/*---------------------------------------------------------------------------*/

/*    message VCConList

        return the list of connections made on this component

      *msg ;           I/O - return status
       nCpt;           I   - Connect point number (cables only)
       nTrans          I   - Transition spec
      *nPos;           O   - Number of connections
      *PosTab;         O   - Connect positions on myself
      *PosOth;         O   - Connect positions on other
      *nStates         O   - Connect statusflags
      *PosGRid;        O   - Corresponding GRid table
                             (Object it connects to)
*/

message VCConList (IGRlong         *msg;
                   IGRshort         nCpt;
                   IGRshort         nTrans;
                   IGRshort        *nPos;
            struct VCpos           *PosTab;
            struct VCpos           *PosOth;
                   IGRshort        *nStates;
            struct GRid            *PosGRid);

/*---------------------------------------------------------------------------*/
/*    message VCConGet

        returns all item descriptions connecting to input
          (including internal thruconnect)

      *msg ;           I/O - return status
       TransFlags      I   - Transition bitflags to consider
      *PosIn;          I   - Connect position in
      *nItems          O   - Number of items out
      *PosOut;         O   - Connect positions on other
      *PosGRid;        O   - Corresponding GRids
                             (Object it connects to)
*/

message VCConGet  (IGRlong         *msg;
                   IGRint           TransFlags;
            struct VCpos           *PosIn;
                   IGRshort        *nItems;
            struct VCpos           *PosOut;
            struct GRid            *OutGRid);

/*---------------------------------------------------------------------------*/
/*    message VCPutTopo

        stores the complete connectivity topology for this component
         (positions , connecting items or open...)

      *msg ;           I/O - return status
       nTot;           I   - Number of elements input
      *PosTab;         O   - Connect positions table
*/

message VCPutTopo (IGRlong         *msg;
                   IGRshort         nTot;
            struct VCfullpos       *PosTab);

/*---------------------------------------------------------------------------*/
/*                  Network tracing                                          */
/*---------------------------------------------------------------------------*/


/*      message VCGetThru

        return the connected items for a trace

      *msg ;           I/O - return status
      *ConnIn;         I   - Conn id in (on myself)
      *ConnRef         I   - Conn id in (on connected item - this is the
                             connection we're NOT looking for)
      *nPos            O   - Number of output positions (possible fanout)
      *Conn;           O   - Output list
*/

message VCGetThru (IGRlong         *msg ;
            struct VC_contrace     *ConnIn;
            struct VC_contrace     *ConnRef;
                   IGRshort        *nPos;
            struct VC_contrace     *Conn);

/*---------------------------------------------------------------------------
        message VCConGetTrace

        return all connected items for a trace (signal)
        (scan two directions)

      *msg ;           I/O - return status
       TransFlags;     I   - Allowed transitions flags
      *ConId;          I   - Conn id in  (seed)
      *bBranched       O   - Indicator branched trace
      *nTrac;          O   - Number of entries in table
     **TracTab;        O   - Trace table
      *SigId;          O   - Signal ID
*/

message VCConGetTrace (IGRlong         *msg ;
                       IGRint           TransFlags;
                struct VC_contrace     *ConId;
                       IGRboolean      *bBranched;
                       IGRshort        *nTrac;
                struct VC_contrace    **TracTab;
                       IGRchar         *SigId);

/*---------------------------------------------------------------------------
        message VCConGetPtrc

        return all connected items for a trace (partial)
        (scan one direction)

      *msg ;           I/O - return status
       TransFlags;     I   - Allowed transitions flags
      *ConId;          I   - Conn id in  (start)
      *bBranched       O   - Indicator branched trace
      *nTrac;          O   - Number of entries in table
     **TracTab;        O   - Trace table
      *SigId;          O   - Signal ID
*/

message VCConGetPtrc  (IGRlong         *msg ;
                       IGRint           TransFlags;
                struct VC_contrace     *ConId;
                       IGRboolean      *bBranched;
                       IGRshort        *nTrac;
                struct VC_contrace    **TracTab;
                       IGRchar         *SigId);

/*---------------------------------------------------------------------------*/

end specification VCCon;

