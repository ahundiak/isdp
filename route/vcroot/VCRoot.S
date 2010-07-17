
/* $Id: VCRoot.S,v 1.2 2002/05/08 15:48:25 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCRoot.S
 *
 * Description:
 *      The abstract class VCRoot declares all methods for placement
 *      and maintenance of the associative cabling components.
 *
 * Dependencies:     $VDS/VDSroot.S
 *
 * Revision History:
 *        $Log: VCRoot.S,v $
 *        Revision 1.2  2002/05/08 15:48:25  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/02/24  21:31:34  pinnacle
# Replaced: vcroot/VCRoot.S for:  by kddinov for route
#
# Revision 1.5  1998/02/21  19:08:16  pinnacle
# Replaced: vcroot/VCRoot.S for:  by kddinov for route
#
# Revision 1.4  1998/02/18  19:52:22  pinnacle
# Replaced: vcroot/VCRoot.S for:  by kddinov for route
#
# Revision 1.3  1997/12/12  20:43:42  pinnacle
# Replaced: vcroot/VCRoot.S for:  by kddinov for route
#
# Revision 1.13  1997/12/12  20:47:06  pinnacle
# Replaced: vcroot/VCRoot.S for:  by kddinov for cabling
#
# Revision 1.12  1997/12/11  20:43:02  pinnacle
# Replaced: vcroot/VCRoot.S for:  by kddinov for cabling
#
# Revision 1.11  1997/07/31  19:47:22  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.10  1997/07/14  21:57:44  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.9  1997/05/19  13:03:02  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.8  1997/05/10  14:00:46  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.7  1997/03/06  22:29:08  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.6  1997/01/20  20:17:28  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.5  1996/11/12  15:28:02  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.4  1996/10/25  13:46:00  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.3  1996/10/16  20:37:50  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  21:55:00  pinnacle
# Replaced: vcroot/VCRoot.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:12:56  pinnacle
# Created: vcroot/VCRoot.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *	 Feb/98 	KDD	    new instance data expander Data.
 *				    VCInitInstance to initialize "variable char"
 *	 Feb/98		KDD	    override VDputAttrDrivenSymb.
 *
 *************************************************************************/

class specification VCRoot (0:1) of VCDB, VDSroot;

#include "VCparameters.h"
#include "VCstructs2.h"

#include "bserr.h"
#include "bstypes.h"
#include "bsvalues.h"
#include "bsparameters.h"

instance VCRoot
{
  IGRint      nVCType;               /*  Type flag       */
  IGRint      nVCStat;               /*  status flag     */

  IGRshort    nVCTopo;               /* number of templates ( topology )   */
  IGRshort    nVCAttr;               /* number of templates ( attributes ) */

  IGRboolean  bVCMtoFlg;             /*  mto flag        */

  variable
  IGRchar     szVCCode[0];           /*  component code  */

  variable
  IGRchar     szVCTagNo[0];          /*  tag number      */

  variable
  struct VCEXpan      EXPAND[0];     /*  emergency expander       */


  variable char		Data[0];     /* flexible emergency expander */

  IGRshort		DataType;    /* size of a single packet for Data */
     				     /* number of data packets = 
				        om$dimension_of(me->Data)/me->DataType*/

};

/***************************** OVERRIDES ************************************/

/*       For GR..... */
override GRgetobjinfo;     /* to display Component's info when identified   */
override GRxform;          /* Component can move if not attached to network */
override GRget_matrix;     /* Service macro operations from EMS             */

/*       For ND..... */
override NDcopy;           /*    NO COPY.... */
override NDdelete;
override NDget_objects;    /* return NO dependant object when in dynamics */
override NDupdate;         /* check which template has been recomputed and
                              tells the correction which type of compute is
                              needed */

/*       For AC..... */
override ACgive_structure;       /* must seek for attributes in the templates */
override ACgive_db_structure;    /* return the static attributes */
override ACreturn_foot;          /* to return feet belonging to collections
                                    templates */

/*       For VDS.....    */
override VDSgetCompDesc;         /* No equivalent, only ROUTE            */
override VDGetModel;             /* revert to VCGetModel                 */
override VDputAttrDrivenSymb;	 /* Set the attribute driven symbology   */

override VDSmodUsrAttributes;    /* to modify user attributes            */
override VDSgetUsrAttributes;    /* to get user attributes               */
override VDgetParameters;        /* returns the list of all parameters
                                    for the object                       */
override VDgetObjDef;

/*       For VCDB     -- redirect to cache object  */

override VCGpAnum;
override VCGetPos;
override VCGetLayout;
override VCGetModules;

/**************************** NEW MESSAGES **********************************/

/*----------------- 12-97 KDD
*  PARAMETERS:
*
* IGRint             *pNbAttrs	- number of attributes returned
*
* struct ACrg_coll   **pAttr	- address of the pointer to ACrg_collect
*				  method allocates memory that user must _FREE()
*				  may be NULL.
*
* struct GRmd_env    *pMdEnv	- module env (not used)
-----------------*/
message VCgetSysAttributes(  IGRlong            *msg ;
                             IGRint             *pNbAttrs;
                             struct ACrg_coll   **pAttr;
                             struct GRmd_env    *pMdEnv );

/*----------------- 12-97 KDD
*  PARAMETERS:
*
* IGRint             pNbAttrs  - number of imput attributes.
*
* struct ACrg_coll   *pAttr    - pointer to ACrg_collect attribute location.
*                                 method allocates memory that user must _FREE()
*                                 may be NULL.
*
* struct GRmd_env    *pMdEnv    - module env (not used)
-----------------*/
message VCmodSysAttributes(  IGRlong            *msg;
                             IGRint             NbAttr;
                             struct ACrg_coll  *pAttributes;
                             struct GRmd_env   *pMdEnv  );

/* -- Information -- */

message VCGetMtoFlag (IGRboolean   *bMTO;
                      IGRchar      *szMTO);  /* Returns mto flag   */

message VCSetMtoFlag (IGRboolean    bMTO);   /* Sets mto flag      */

message VCGetType (IGRint   *TypeValue);     /* Returns type value */

message VCSetType (IGRint   TypeMask;
                   IGRint   TypeValue);      /* Sets type value    */

message VCGetStatus (IGRint   *StatusValue); /* Returns status value */

message VCSetStatus (IGRint   StatusMask;
                     IGRint   StatusValue);  /* Sets status value    */

message VCGetCode (IGRchar *szCode);         /* Returns component code  */

message VCSetCode (IGRchar *szCode);         /* Sets coponent code  */

message VCGetInstance (IGRlong   *msg;
                struct VCGenInfo *Instance); /* Returns instance variables */

message VCSetInstance (IGRlong   *msg;
                struct VCGenInfo *Instance); /* Sets instance variables */

message VCGetProduct  (IGRint    *Prodno;
                       IGRchar   *ProdNam);  /* Product number and/or name  */

message VCGetTagNo    (IGRchar   *szTag);    /* Tag number                  */

message VCSetTagNo    (IGRchar   *szTag);    /* Tag number                  */

message VCGetRep      (IGRshort  *nRep;
                       IGRchar   *szRep);    /* Representation              */

message VCParent      (IGRlong   *msg;
                       IGRshort   iParno;    /*   parent number             */
                struct GRid      *Par;       /* Get real parent in ref. file */
                struct GRmd_env  *pr_env);   /*   parents environment       */

message VCChildren    (IGRlong   *msg;
                       IGRshort  *nTotchild; /*  total # of children        */
                       IGRshort  *nRefchild; /*  # of ref. children         */
                struct GRid      *Children); /*  array of child GRids       */

/***************************************************************************/

/* --   component directory system    -- */

/*    defines directory name   */

message VCCmpDef (IGRlong    *msg;
                  CHARPTR    *pCHR);

message VCCmpDir (IGRlong    *msg;
                  CHARPTR    *pCHR;
                  IGRchar    *szRES);

/*    saves name in directory   */

message VCCmpSet   (IGRlong    *msg);

/*    deletes name from directory   */

message VCCmpDel   (IGRlong    *msg);

/*    gets name from directory (if present, checks if name not desired)  */

message VCCmpGet   (IGRlong    *msg;
                    IGRchar    *szName);

/***************************************************************************/

/*    returns attribute collection ID's   */

message VCGetParams( IGRlong   *msg;
                     IGRshort  *nNbPar;
              struct GRid      *ParamId);

/*     replaces one attribute collection     */

message VCChgParam  (IGRlong   *msg;
                     IGRshort   nIndex;
              struct GRid      *UserParamId);

/*     retrieves all actual instance parameters       */

message VCGetInsPar (IGRlong   *msg;
                     IGRshort  *nNbPar;
              struct ACrg_coll *Coll);      /* Collection data              */

/*     retrieves all actual system parameters       */

message VCGetSysPar (IGRlong   *msg;
              struct GRid      *CollId;     /* Collection ID                */
                     IGRshort  *nNbChild;   /* Number of elements sharing   */
                     IGRshort  *nNbPar;     /* Actual number of parameters  */
              struct ACrg_coll *Coll);      /* Collection data              */

/*     retrieves all actual user parameters         */

message VCGetUsrPar (IGRlong   *msg;
              struct GRid      *CollId;     /* Collection ID                */
                     IGRshort  *nNbChild;   /* Number of elements sharing   */
                     IGRshort  *nNbPar;     /* Actual number of parameters  */
              struct ACrg_coll *Coll);      /* Collection data              */

/*    returns DB cache ID    */

message VCGetModel( IGRlong   *msg;
             struct GRid      *ModelId);

/***************************************************************************/
/*       Following messages are implemented only for the                   */
/*       specific elements on a lower level.                               */
/***************************************************************************/

/***************************************************************************/
/*                       TOPOLOGY                                          */
/***************************************************************************/

/*     returns all connected elements with their connectpoints */
/*     (excluding attributes)                                  */

/*     returns connection table       */

message VCGetTopology (IGRlong   *msg;
                       IGRshort   nCpt;    /*I   my CPT or ALL             */
                       IGRshort  *nTerms;  /*O   number output             */
                struct GRid      *ConId;   /*O   list of GRids             */
                       IGRshort  *nConCp;  /*O   list of cpts on GRids     */
                       IGRshort  *nMyCp;   /*O   list of cpts on me        */
                       IGRshort  *nPass);  /*O   list of passthru counters */

/*     returns support ID's (guides/equipment)        */

message VCGetSupports (IGRlong   *msg;
                       IGRshort  *nNbSupps;
                struct GRid      *SuppIds);

/***************************************************************************/
/*                    geometry and connectpoint handling                   */
/*                     See also VCP class for terminals                    */
/***************************************************************************/

/*    returns matrixes at specified cpt (default, overridden per case)     */

message VCGetMatrix( IGRlong     *msg;
                     IGRshort     nCpt;
                     IGRdouble   *dRefMatrix;
              struct GRmd_env    *md_env);

message VCBaseMat  ( IGRlong     *msg;
                     IGRshort     nCpt;
                     IGRdouble   *dRefMatrix;
              struct GRmd_env    *md_env);

message VCTransMat ( IGRlong     *msg;
                     IGRshort     nCpt;
                     IGRdouble   *dRefMatrix;
              struct GRmd_env    *md_env);

message VCGetNumberOfCpts (IGRlong     *msg ;
                           IGRshort    *NbCpts);

message VCGetCptCoord (IGRlong      *msg;
                       IGRshort      nCpNum;
                       IGRdouble    *dCptCoor;
                struct GRmd_env     *md_env);

message VCGetCptVec   (IGRlong      *msg;
                       IGRshort      nCpNum;
                       IGRdouble    *dCptVec;
                       IGRboolean   *bFree;
                struct GRmd_env     *md_env);

message VCGetCptGeom (IGRlong      *msg;
                      IGRshort      nCpNum;
                      IGRdouble    *dCptCoor;
                      IGRdouble    *dConAxis;
                      IGRdouble    *dOrientation; 
                      IGRboolean   *bFree;
               struct GRmd_env     *md_env);

/*     selects closest connectpoint on target   */

message VCSelectCpt (IGRlong    *msg ;
                     IGRdouble  *dTentative;
                     IGRshort   *nCpNum;
                     IGRdouble  *dConPos;
                     IGRdouble  *dConVect; 
                     IGRboolean *bFree;
              struct GRmd_env   *md_env);

/*     get combination of connectpoints     */

message VCGetCpts   (IGRlong    *msg;
              struct GRid       *RefId;
                     IGRshort   *nRefCp;
                     IGRshort   *nMyCp;
                     IGRshort   *nPass);

/***************************************************************************/

/*     get compartment ID's (link to SM)    */

message VCGetCompart (IGRlong    *msg;
                      IGRshort   *nNum;
               struct GRid       *Compart;
               struct GRmd_env   *md_env);

/*      for debugging, dump instance data    */

message VCDUMP (IGRlong    *msg);

/***************************************************************************/

/*     objext expander                       */

message VCGetExpand (IGRlong    *msg;
                     IGRshort    iWhich;   /*  Expand index or -1 (all)    */
                     IGRshort   *noret;    /*  number returned             */
              struct VCEXpan    *ExRec);   /*  output buffer               */

message VCPutExpand (IGRlong    *msg;
                     IGRshort    iWhich;   /*  Expand index or -1 (next)   */
                     IGRshort   *noret;    /*  Returned index              */
              struct VCEXpan    *ExRec);   /*  input record                */


message VCInitInstance (IGRlong *msg);     /* to initalize variable char data*/

	    /*--------------------------------------------------*/
	    /* Generic methods to access the back-door me->Data */
	    /*--------------------------------------------------*/
message VCSetDataVLA( void	*InstanceAttr;
		      IGRint	NbInstAttr;
		      IGRshort	DataType );
message VCGetDataVLA( void	*InstanceAttr;
		      IGRint	*NbInstAttr;
		      IGRshort	*DataType );
message VCDataTypeSize( IGRint	*Size );

end specification VCRoot;

