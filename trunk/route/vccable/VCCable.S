/* $Id: VCCable.S,v 1.3 2002/05/10 22:13:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCable.S
 *
 * Description:
 *      Abstract class implementing general cable behaviour
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCable.S,v $
 *        Revision 1.3  2002/05/10 22:13:23  anand
 *        First set of bug fixes for sub-cable functionality. Attempts
 *        to fix merge issues, and some cpt issues. Fix for TR 6344.
 *
 *        Revision 1.2  2002/05/08 15:48:22  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:25  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.8  1998/04/02  20:06:10  pinnacle
# Replaced: vccable/VCCable.S for:  by azuurhou for route
#
# Revision 1.7  1998/03/31  07:09:04  pinnacle
# Replaced: vccable/VCCable.S for: TR 179800045 by aharihar for route
#
# Revision 1.6  1998/03/12  10:10:56  pinnacle
# Replaced: vccable/VCCable.S for: TR179800045 by aharihar for route
#
# Revision 1.5  1998/02/24  22:42:08  pinnacle
# Replaced: vccable/VCCable.S for:  by kddinov for route
#
# Revision 1.4  1998/02/21  18:38:18  pinnacle
# Replaced: vccable/VCCable.S for:  by kddinov for route
#
# Revision 1.3  1998/02/18  19:57:22  pinnacle
# Replaced: vccable/VCCable.S for:  by kddinov for route
#
# Revision 1.2  1997/12/08  09:31:12  pinnacle
# Replaced: vccable/VCCable.S for:  by apazhani for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.20  1997/12/08  08:43:26  pinnacle
# Replaced: vccable/VCCable.S for:  by apazhani for cabling
#
# Revision 1.19  1997/10/25  15:35:16  pinnacle
# Replaced: vccable/VCCable.S for:  by vc241 for cabling
#
# Revision 1.18  1997/07/31  19:53:02  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.17  1997/07/26  13:32:52  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.16  1997/07/22  14:54:00  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.15  1997/07/15  21:00:48  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.14  1997/05/07  14:27:06  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.13  1997/05/06  23:06:58  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.12  1997/04/28  22:09:12  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.11  1997/03/12  20:45:38  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.10  1997/01/31  17:58:52  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.9  1997/01/16  14:34:18  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.8  1996/11/21  21:25:42  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.7  1996/11/12  15:40:14  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.5  1996/10/25  14:01:02  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.4  1996/10/16  20:47:42  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.3  1996/10/14  21:52:48  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.2  1996/10/03  18:19:46  pinnacle
# Replaced: vccable/VCCable.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:45:54  pinnacle
# Created: vccable/VCCable.S by hverstee for cabling
#
 *
 * History:
 *	05/29/96	hv	Initial
 *	10/25/97	Alwin	Added the attributes "tail_length" and
 *				"estim_length"
 *	12/08/97	Alwin	Added Method VCInitSection
 *	Jan/98		KDD	VCGetCptOnTerm
 *	Feb/98		KDD	instance Offset, OffsetType, VCInitInstance
 *	12 Mar 98	Anand	Added 2 Methods:VCCSetOffset & VCCGetOffset
 *				to access the offset instance variables.
 *	27 Mar 98	Anand	Refined above 2 methods to accommodate
 *				expansion in future releases.
 *	04/02/98	adz	Change arguments VCCSetOffset/VCCGetOffset
 *	Mar 2002	Anand	Added message signatures for methods to support
 *				sub-cable/lead functionality.
 *
 *************************************************************************/


class specification VCCable (0:0) of /*GRlinestr,*/ VCCon, VCRoot;

#include "VRtracer.h"
#include "VCstructs2.h"

instance VCCable
{
  variable
  struct VCcab_connect    Connect_Data[0];  /*  connectivity   */

  variable
  struct VCCL_sectmap     Sect[0];          /* Control for sections  */

  variable
  struct VCCL_bendmap     Bend[0];          /* Overridden bend radii */


  variable  char	  Offset[0];	    /* pointer to VCOffset structure */
  IGRshort		  OffsetType;	    /* size of a single Offset data 
                                               packet sizeof(VCOffset) */
};

/*-----------------   FROM ASSOC --------------------------*/
/*C define my placement method */
override      NDplace;

/*C update my instance data accordingly */
override      NDparent_deleted;

/*C Returns the cable length */
override      ACgive_structure;

/*C define my method of recomputation */
override      ACconstruct_feet;

/*-----------------   FROM VDS ----------------------------*/
/*C Post connectivity tables    */
override      VDPostYourselfToDb;

/*-----------------   FROM VCRoot --------------------------*/
/*C return my instance */
override      VCSetInstance;
override      VCGetInstance;

/*C retrieve my cpt information */
override      VCGetMatrix;

/*C retrieve my neighbour's information( connectors)*/
override      VCGetTopology;
override      VCGetSupports;
override      VCGetCpts;

override      GRgetobjinfo;

override      VCDUMP;

/*-----------------   FROM VCCon --------------------------*/

/*C make and break connections */
override VCConnect;
override VCConDisc;
override VCConDscall;

override VCGetSignal;
override VCPutSignal;

override VCConList;

override VCGetThru;
override VCConGetTrace;

override VCGetCompart;

override VCGetInsPar; /* Override this method, to get the attribute specific
                         to CABLE object. Attributes are "tail_length and
                         estim_length" */

override VCInitInstance;	/* for "variable char" structures */

override VDgetObjDef;

/****************************************************************/
/*C Specific methods to cables */
/****************************************************************/

/*    get terminal at end         */

message VCCbTerm (IGRlong       *msg;
                  IGRshort       nEnd;      /* I  End indicator             */
           struct GRid          *Term);     /* O  Terminal at that end      */

/*    set/unset passthru flags    */

message VCCbPass (IGRlong       *msg;
                  IGRshort      *nCurr;     /*  O  current # of passthrus   */
           struct VCpos         *Cutpos);   /*  I  Passthru id (nolead=all) */

message VCCbCut  (IGRlong       *msg;
                  IGRshort      *nCurr;     /*  O  current # of passthrus   */
           struct VCpos         *Cutpos);   /*  I  Passthru id (nolead=all) */

/*    find parent coordinates and connection vectors   */

message VCCbparcor (IGRlong    *msg;
                    IGRshort    secno;
             struct GRid       *ParId;
                    IGRdouble  *Cin;
                    IGRdouble  *Vin;
                    IGRboolean *bIFree;
                    IGRdouble  *Cout;
                    IGRdouble  *Vout;
                    IGRboolean *bOFree;
             struct GRmd_env   *md_env);

/*     place break symbol            */

message VCCbPlaceBreak (IGRlong         *msg;
                        IGRdouble       *dCoord;
                        IGRdouble       *dPrev;
                        IGRint          *NumBrk;
                 struct GRid            *OutId;
                 struct GRvg_construct  *cnst_lis;
                 struct GRmd_env        *md_env);

/*     insert break in line          */

message    VCCbInsBrk (IGRlong        *msg;
                       IGRint          SecNum;
                       IGRint          VtxNum;
                       IGRdouble      *dCoord;    /*  coordinates            */
               struct  GRmd_env       *md_env);

/*     retrieve linestring coordinates    */

message VCCbLdLine (IGRlong     *msg;
                    IGRshort     strno;
             struct IGRpolyline *LineIn;
             struct GRmd_env    *md_env);

/*     autoconnect leads with matching signals    */

message VCCbAutoCon (IGRlong     *msg;
                     IGRshort     nCpt);

/*     modify dynamic connectpoint number at end (VCP reorg....)   */
message VCCbDynCpt  (IGRlong     *msg;
                     IGRshort     nCpt;      /*    my end      */
                     IGRshort     nDyn);     /*    new dynamic connectpoint  */

/*---------------------------------------------------------------------------
/* VCCbAttGuide
/*
/*     incorporate cable in guide
/*
/*  IGRlong          *msg         O - MSSUCC or MSFAIL
/*  struct GRid      *ConId       I - Guide GRid
/*  IGRint            iCFrom      I - starting parameter for conduit
/*  IGRint            iCTo        I - ending parameter for conduit
/*  IGRint            Vtx1        I - starting vertex for incorporation
/*  IGRint            Vtx2        I - ending vertex for incorporation
/*  IGRint            Sec         I - section number vertices are in
/*
/*---------------------------------------------------------------------------
/*  */

message  VCCbAttGuide (IGRlong       *msg;
                struct GRid          *ConId;
                       IGRint         iCFrom;
                       IGRint         iCTo;
                       IGRint         Vtx1;
                       IGRint         Vtx2;
                       IGRint         Sec);

/*---------------------------------------------------------------------------
/* VCCbAttRway 
/*
/*     incorporate cable in raceway section
/*
/*  IGRlong            *msg         O - MSSUCC or MSFAIL
/*  IGRshort            nNum        I - Number of raceway componnents
/*  struct VR_tracerec *ConId       I - Raceway trace table
/*  IGRint              Vtx1        I - starting vertex for incorporation
/*  IGRint              Vtx2        I - ending vertex for incorporation
/*  IGRint              Sec         I - section number vertices are in
/*
/*---------------------------------------------------------------------------
/*  */

message  VCCbAttRway  (IGRlong       *msg;
                       IGRshort       nNum;
                struct VR_tracerec   *ConId;
                       IGRint         Vtx1;
                       IGRint         Vtx2;
                       IGRint         Sec);


/*---------------------------------------------------------------------------
/* VCCbAttPoint
/*
/*     attach cable vertex to point source
/*
/*  IGRlong          *msg         O - MSSUCC or MSFAIL
/*  struct GRid      *PntId       I - Point GRid
/*  IGRint            Type        I - Point type (pt/cs or TERM)
/*  IGRint            Vtx         I - vertex for attachment
/*  IGRint            Sec         I - section number vertex is in
/*
/*---------------------------------------------------------------------------
/*  */

message  VCCbAttPoint   (IGRlong       *msg;
                  struct GRid          *PntId;
                         IGRint         Type;
                         IGRint         Vtx;
                         IGRint         Sec);

/*---------------------------------------------------------------------------
/* VCCbDetach
/*
/*     detach cable from point or conduit
/*
/*  IGRlong          *msg         O - MSSUCC or MSFAIL
/*  struct GRid      *PntId       I - Point GRid
/*
/*    NOTE:     in case PntId is a raceway component the entire raceway
/*              will be detached
/*---------------------------------------------------------------------------
/*  */

message  VCCbDetach     (IGRlong       *msg;
                  struct GRid          *PntId);

/*---------------------------------------------------------------------------
/* VCCbBendrGet
/*
/*     return bend radius at index   
/*
/*  IGRlong            *msg    O - MSSUCC or MSFAIL
/*  IGRint              Index  I - Index of vertex
/*  IGRint              Sec    I - Section number of vertex
/*  IGRdouble          *dBrad  O - Returned bend radius
/*
/*---------------------------------------------------------------------------
/*  */

message  VCCbBendrGet (IGRlong       *msg;
                       IGRint         Index;
                       IGRint         Sec;
                       IGRdouble     *dBrad);

/*---------------------------------------------------------------------------
/* VCCbBendrPut
/*
/*     store bend radius at index   
/*
/*  IGRlong            *msg    O - MSSUCC or MSFAIL
/*  IGRint              Index  I - Index of vertex
/*  IGRint              Sec    I - Section number of vertex
/*  IGRdouble           dBrad  I - Bend radius to store
/*
/*---------------------------------------------------------------------------
/*  */

message  VCCbBendrPut (IGRlong       *msg;
                       IGRint         Index;
                       IGRint         Sec;
                       IGRdouble      dBrad);

/*---------------------------------------------------------------------------
/* VCCbBendrClr
/*
/*     reset bend radius table  
/*
/*  IGRlong            *msg    O - MSSUCC or MSFAIL
/*
/*---------------------------------------------------------------------------
/*  */

message  VCCbBendrClr (IGRlong       *msg);

/*---------------------------------------------------------------------------
/* VCCbMerge
/*
/*      Extend myself with the topology of the specified other link,
/*      get all its dependancy and delete the specified link.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong         *msg        O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort         nEnd       I : which of my end should be linked (0 or 1).
/*
/* struct GRid     *pOtherId   I : Id of the link to be absorbed.
/*
/* IGRshort         nOtherEnd  I : end of the absorbed link which should be
/*                                  linked to my end.
/*
/* struct GRmd_env *md_env     I : module environment.
/*---------------------------------------------------------------------------
/* */

message VCCbMerge ( IGRlong     *msg;
                    IGRshort     nEnd;
             struct GRid        *pOtherId;
                    IGRshort     nOthersEnd;
             struct GRmd_env    *md_env);

/*---------------------------------------------------------------------------
/* VCCbSplit
/*
/*      Generate a new link from the split point to my end and shortened
/*      myself from my start point to the split point.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRdouble        *d3SplitPoint  I : coordinates of the split point.
/*
/* struct GRid        *pNewLink  O : Object id of the new link.
/*
/* struct GRmd_env      *md_env    I : module environment.
/*---------------------------------------------------------------------------
/* */

message VCCbSplit ( IGRlong       *msg;
                    IGRdouble     *d3SplitPoint;
             struct GRid          *pNewLink;
             struct GRmd_env      *md_env );

/****************************************************************************/
/*                                                                          */
/*D    METHOD NAME   -   VCCbTube                                           */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This method will construct tubes (skinning surfaces) of the         */
/*D     required diameter around the cable strings                          */
/*D                                                                         */
/*D  method     VCCbTube(  IGRlong         *msg;                            */
/*D                        IGRint           NumLines;                       */
/*D                 struct GRid            *LineGRid;                       */
/*D                        IGRint          *NumTubes;                       */
/*D                 struct GRid            *TubeGRid;                       */
/*D                 struct GRvg_construct  *cnst_lis;                       */
/*D                 struct GRmd_env        *md_env);                        */
/*D                                                                         */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D      *msg         O     error message                                   */
/*D       NumLines    I     Number of linestrings input                     */
/*D      *LineGRid    I     GRids of the polylines                          */
/*D      *NumTubes    O     Number of tube objects output                   */
/*D      *TubeGRid    O     GRids of the constructed tubes                  */
/*D      *cnst_lis    I     construction list                               */
/*D      *md_env      I     environment                                     */
/*D                                                                         */
/****************************************************************************/

message    VCCbTube(  IGRlong         *msg;
                      IGRint           NumLines;
               struct GRid            *LineGRid;
                      IGRint          *NumTubes;
               struct GRid            *TubeGRid;
               struct GRvg_construct  *cnst_lis;
               struct GRmd_env        *md_env);

/*      modify linestring section          */

message    VCCbModify (IGRlong        *msg;
                       IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                       IGRint          AdjType;   /*  adjustment type        */
                       IGRint          SecNum;    /*  section number         */
                       IGRint          VtxNum;    /*  vertex/segment number  */
                       IGRdouble      *dCoord;    /*  coordinates            */
               struct  GRmd_env       *md_env);

/*       find vertex/segment and section given coordinates    */

message    VCCbFind   (IGRlong        *msg;
                       IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                       IGRint         *AdjType;   /*  adjustment type        */
                       IGRint         *SecNum;    /*  section number         */
                       IGRint         *VtxNum;    /*  vertex/segment number  */
                       IGRdouble      *dCoord;    /*  coordinates            */
                       IGRint          DisCor;    /*  Normal on coordinates  */
                       IGRdouble      *dDynCor;   /*  coords for dynamics    */
                       IGRint         *EndPos;
               struct  GRmd_env       *md_env);

/*        return vertex coords given number and section       */

message    VCCbVertex (IGRlong        *msg;
                       IGRint          SecNum;    /*  section number         */
                       IGRint          VtxNum;    /*  vertex/segment number  */
                       IGRdouble      *dCoord;    /*  coordinates            */
               struct  GRmd_env       *md_env);

/*        initialize cable instance with connectivity tables   */

message    VCCbInitCon (IGRlong        *msg;
                        IGRboolean      bDisc);   /*  disconnect old */

message    VCCbInsConTab (IGRlong        *msg;
                          IGRshort       *nNum;
                   struct VCcab_connect **Connect);  /*  connectivity   */

/* This is wriiten to reset the section details once the Parent Terminal
gets deleted. Currently this works only if the Parent is Terminal it can be
extended to other Parents like Point, Guide's. Basically what it does is
set the type of a particlar section to FREE_VERTEX and reduces the
nVCTopo instance value by one. Alwin */
 
message VCCInitSection ( IGRlong     *msg;
                        struct GRid TerminalId );

/*--------------------------------------
# Jan 98 Kosta
* To get connect point of the cable and corresponding terminal.
*
* Depending on Term/Term.objid will either return the connect point on that 
* terminal, or the terminal on that point.
*-------------------------------------*/

message    VCGetCptOnTerm( IGRlong      *msg;
                           struct GRid  *Term;
                           IGRshort     *ConnPoint);
 
/* The following two messages is provided to set and get the offset of a
   cable wrt to a terminal object in the instance. - Anand (12th Mar '98) */
 
message    VCCSetOffset( void           *Offset;
                         IGRshort        nTermCount );
 
/* Note: The method will allocate space for OffsetVectors. IT IS THE CALLER'S
   RESPONSIBILITY TO FREE THE POINTER AFTER USE. - Anand (25th Mar '98)  */

message    VCCGetOffset( void		**OffsetVectors;
                         IGRshort       *nNbOffSets );


	      /*-----------------------------------------------*/
	      /* MESSAGES FOR HANDLING SUB-CABLES AND/OR LEADS */
	      /*-----------------------------------------------*/

/* methods for using the me->Data backdoor provided in VCRoot */
override      VCSetDataVLA, VCGetDataVLA, VCDataTypeSize;

override VCGetLayout;

message VCCSetCon_Data( IGRlong	*msg;
			IGRint	NbLeads;
			struct VCcab_connect *Connect_Data;
			IGRchar	(*LdNames)[VC_MAX_LEAD_ID] );

message VCAmIParCab( IGRlong		*msg;
		     IGRint		*nNumSubCab;
		     struct GRid	*SubCabIds );

message VCAmISubCab( IGRlong		  *msg;
		     IGRint		  *nWhichEnd;
		     struct GRid	  *ParId;
		     IGRint		  *NumLeads;
		     struct VCcab_connect *LeadInfo );

message VCSubCabTogSectMap( IGRlong	*msg );

/* Note: Do not call the below method directly (i.e., via om$send). Rather,
 * call it through the VC$SubCabLeadInfo macro. This performs the argument
 * checks that the method itself does not. Also, it is easier to call the OM
 * macro, only with the outputs you desire and not having to send everything
 * else as NULL (the Macro does that for you). See VCLead.h for details. */

message VCGetInfoSubCab( IGRlong		*msg;
			 struct VCCL_sectmap	Sect[2];
			 IGRdouble		Coord[6];
			 IGRint			*NumBegCab;
			 struct GRid		*BegCabId;
			 IGRint			*NumBegCabLds;
			 struct VCcab_connect	*BegCabLeads;
			 IGRint			*NumEndCab;
			 struct GRid		*EndCabId;
			 IGRint			*NumEndCabLds;
			 struct VCcab_connect	*EndCabLeads;
			 IGRint			*NumBegAvlblLds;
			 struct VCcab_connect	*BegAvlblLds;
			 IGRint			*NumEndAvlblLds;
			 struct VCcab_connect	*EndAvlblLds;
			 struct GRmd_env	*md_env );

end specification VCCable;

