
/* $Id:*/

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdproot /
 *
 * Description:
 *	The following DM2 queries are implemented.
 *
 *	1. VDPgetCtxTypeSubTypes
 *	2. VDPgetContexts
 *	3. VDPgetBWTContexts
 *	4. VDPgetESWBS
 *	5. VDPgetOccTemplate
 *	6. VDPpostObjectToDM2
 *      7. VDPprepareAsciiFile
 *	8. VDPreserveOccurrence
 *	9. VDPgetPlacementList
 *	10.VDPgetPMRWorkPackage
 *	11.VDPqueryListofZones
 *	12.VDPgetZoneContexts
 *	13.VDPgetCompContexts
 *	14.VDPgetCompAttr
 *	15.VDPgetShips
 *	16.VDPIsEquipReserved
 *	17.VDPCrePlFileRel
 *	18.VDPgetDBunits
 *  19.VDgetSrError
 *  20.VDDelEBOMsir
 *  21.VDpostPart2Sir
 *  22.VDaddPart4Sir
 *  23.SrDetectFileRev
 *  24.SrVDBaseRevise
 *  25.VDPUpdatePlacMdcReln
 *  26.VDPGetMdcobidFromRefPart
 *  27.VDPSetUid
 *  28.VDPGetPdmRevFormRefFile
 *  29.VDPWriteDiagramList
 * Dependencies:
 *
 * History:
 *      MM/DD/YY 	AUTHOR          DESCRIPTION
 *
 *      10/4/95  	MSM             creation
 *	8/20/96	 	MSM		Added VDPUpdateFileId()
					Added VDPIsFIleRevised()
 *	9/23/96		MRA		Added VDPIsEquipReserved()
 *					and VDPCrePlFileRel()
 *	10/03/96	MSM		Fixed TR#179603132
 *	10/22/96	msm		Changes for file revisioning.
 *					I'm trying to minimise the code changes
 *					in VDS. The revisioning thing kept 
 *					growing so the code is not clean..
 *					Will need to modify after the release
 *      11/05/96        Ravi		Added the VDprepareAsciiFile func.for
 *				 	Batch Posting.
 *      04/13/98        ah              Fixed syntax error in getOccTemplate after
 *                                      various undocumented and untested changes were made
*	05/11/98	Durga		Modified VDPprepareAsciiFile.
					In VDS25, the ESWBS is no longer
					asked for in the Default PM data form.
					Hence sending a dummy value of 0
					to the PME server.
 *
 *    Aug 07 98   Shailesh         Added new functions for SIR
 *                                 VDgetSrError    VDDelEBOMsir
 *                                 VDpostPart2Sir  VDaddPart4Sir
 *   Aug 13 98    Shailesh         Modified qty sent over to Sir
 *                                 area for plates, length for pipe, beam stiff
 *                                 nos for equip.
 *   Sep 03 98    Shailesh         TR # 179801619 increased mino[]
 *   Sep 30 98    Shailesh         Added VDaimGetpostyes()
 *                                 to show posting status in status bar.
 *   Sep 30 98    Shailesh         TR #:179801757 send only one sided area 
 *   Sep 15 98    Shailesh         Added 2 new error messages for 
 *                                 AIM - ISDP posting.
 *   Aug 27 99	  Shailesh	   New functions for CM AIM integration
 *   Feb 11 00	  Shailesh	   Reviewed memory management in SrDetectFileRev
 * -------------------------------------------------------------------*/
class implementation VDPRoot;


/*#define vaimDEBUG
#define vaimerrDEBUG*/


#include <stdio.h>
#include "string.h"

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "griomacros.h"
#include "VDtypedef.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "griodef.h"
#include "VDSutil.h"

#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"

#include "ACrg_collect.h"
#include "ACattrib.h"
#include "ACcheckin.h"

#include "msdef.h"

#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "vdparmacros.h"
#include "vdbmacros.h"

#include "VDPdm2.h"
#include "VDPtrTbl.h"
#include "VDPDatFrmDf.h"
#include "VDPEqpBuf.h"
#include "VDPdef.h"
#include "VDPzone.h"
#include "VDScheckdef.h"

#include "PDUstr.h"
#include "VDsa.h"

#include "FI.h"
#include "FEI.h"

#include "VDpdm.h"   // JTS MP CR 5522, for file_key and pdmInfo

#define FILE_PRINT      if (dm2_log) fprintf
#define PRINT_FILE      if (fPtr) fprintf

#define SIR_PRED_DATA ":SIRPredData"
#define CATALOG "catalog"
#define PART_NAME "part"
#define REVISION "revision"
#define VDP_GET_REV    121
extern int PDMGetPartInfoGivenFileName ();
extern int PDMInsertSirTable();
extern IGRint VDPReconnectDAD();
extern int VDPRestorePlacmts();
extern int SirVDUpdCMAttrs();
extern struct PDUrefresh	*refresh;
//extern struct SIRRefInfo *SIR_Diag_Info;
extern GRclassid        OPP_VDSroot_class_id;

extern int VDgetVdCollId();

from ACrg_collect import ACget_named_attribute,
			ACmod_list_attribute,
                        ACset_list_attribute,
			ACadd_list_attribute;

%safe
static struct SRPartStat	      *partcount = NULL;
static int	CumPartVar = 0;
static int	nberr = 17;
static int	posted_yes = 0;  // ssr 26 sep
static int	posted_no = 0;  // ssr 26 sep
static struct SRErrMsg VdSrErrMsg[] = {
{27, " An error occurred in AIM while posting. Contact your AIM administrator"},
{23, " An AIM internal error occured while posting. Contact your AIM. administrator"},
{24, " An error occured in AIM while creating. Contact your AIM administrator"},
{25, " An error occured in AIM while deleting. Contact your AIM administrator"},
{26, " An error occured in AIM while modifying. Contact your AIM administrator"},
{28, "Model Context Already Exists in SIR"},
{22, "ERROR in posting. Part unavailable in SIR Parts Catalog."},
{21,"Placement not found. Error occured in posting. Contact AIM administrator"},
{29, "Error occured in AIM while posting. Placement already exists in orphan state" },
{30, "ERROR Posted FSI does not have valid Diagram Placement"},
{31, "ERROR Trying to Post to a frozen or superseded Model Design Context"},
{32, "ERROR Trying to post to a frozen or superseded placement"},
{43, "ERROR Catalog Part is checked out; Could not post placement."},
{44, "ERROR Context selected is not related to Hull."},
{45, "ERROR Placement doesnot exist in AIM in the attached diagram File."},
{46, "ERROR Placement with this UID already exists in AIM."},
{44  , "ERROR Context is not related to the Hull."}
};
%endsafe

struct SRPartStat *VDaimGetPartCount()
{
  return partcount;
}

int VDaimGetCumPartVar()
{
  return CumPartVar;
}

int* VDaimGetpostyes()
{
  return &posted_yes;
}


int* VDaimGetpostno()
{
  return &posted_no;
}

/*+fi
  Internal function VDPgetCtxTypeSubTypes

  Abstract
  This function queries the proxy server which in turn queries the DM2 server
  for all the unique type subtypes from the database.

  Type code, subtype code, sub-type description and Class name are returned.

  Algorithm

-fi*/

int	VDPgetCtxTypeSubTypes(  long	*msg,
				int	*nbTST,
				struct VDPPlCtxTST	**TypST )
{
    int			i, inlen, code, index=0,
			outlen=0, dstat, mfail;
    char		inbuf[20];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    *nbTST = 0;
    *TypST = NULL;
    *msg = MSSUCC;

    for ( i=0; i<20; i++ )
    	inbuf[i]='\0';
    code = VDP_QUERY_CTXTYST;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));

    inlen += sizeof(int);
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );

    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	//printf("mfail = <%d>\n", mfail);
        return 0;
    }

    /* Read the output buffer */
    index = 0;
    memcpy( nbTST, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    if( *nbTST )
    {
	*TypST = _MALLOC( *nbTST, struct VDPPlCtxTST );
	if ( ! *TypST )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbTST; i++ )
    {
	/*memcpy((*TypST)[i].Type, &outbuf[index], 1) ; */
	(*TypST)[i].Type = (char)outbuf[index];

	index = index+2;  /* Here a string of length 2 is being sent instead of a char */

	memcpy(&(*TypST)[i].SubType, &outbuf[index], sizeof(int));
	index = index+sizeof(int);
	strcpy((*TypST)[i].SubTypeDesc, &outbuf[index]);
	index = index + strlen((*TypST)[i].SubTypeDesc) +1;
	strcpy((*TypST)[i].ClassName, &outbuf[index]);
	index = index + strlen((*TypST)[i].ClassName ) +1;
    }

   return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPgetContexts

  Abstract
  Given the Context Class name this function queries the DM2 server for all
  contexts for the given class.

  Context id, Context name and Context description are returned.

  Algorithm

-fi*/

int	VDPgetContexts( long	*msg,
			char	*ClassName,
			char	*ShipName,
			int	*nbCtx,
			struct	VDPNameDesc	**Contexts )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];
    *nbCtx = 0;
    *Contexts = NULL;
   *msg = MSSUCC;

    for ( i=0; i<100; i++ )
    	inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_PLCTX;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    __DBGpr_str ("ShipName ", ShipName );

    strcpy( &inbuf[index], ShipName );
    inlen = inlen + strlen( ShipName ) +1;
    index = inlen;

    /* Add the class name */

    strcpy( &inbuf[index], ClassName );
    inlen = inlen + strlen(ClassName) +1 ;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );

    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

    /* Read the output buffer */
    index = 0;
    memcpy( nbCtx, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    if( *nbCtx )
    {
	*Contexts = _MALLOC ( *nbCtx, struct VDPNameDesc );
	if ( *Contexts == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbCtx; i++ )
    {
	strcpy((*Contexts)[i].CtxId, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxId) +1;
	strcpy((*Contexts)[i].CtxName, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxName ) +1;
	strcpy((*Contexts)[i].CtxDesc, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxDesc ) +1;
    }

   return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPgetBWTContexts

  Abstract
  This function queries the DM2 server for all the Budget weight contexts

  Context id, Context name and Context description are returned.

  Algorithm

-fi*/

int	VDPgetBWTContexts( long		*msg,
			   char		*ShipName,
			   int		*nbCtx,
			   struct  VDPNameDesc	**Contexts )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    *nbCtx = 0;
    *Contexts = NULL;
    *msg = MSSUCC;

    for ( i=0; i<100; i++ )
    	inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_BWTCTX;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    strcpy( &inbuf[index], ShipName );
    inlen = inlen + strlen( ShipName ) +1;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

    /* Read the output buffer */
    index = 0;
    memcpy( nbCtx, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    if( *nbCtx )
    {
	*Contexts = _MALLOC ( *nbCtx, struct VDPNameDesc );
	if ( *Contexts == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbCtx; i++ )
    {
	strcpy((*Contexts)[i].CtxId, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxId) +1;
	strcpy((*Contexts)[i].CtxName, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxName ) +1;
	strcpy((*Contexts)[i].CtxDesc, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxDesc ) +1;
    }

   return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPgetESWBS

  Abstract
  This function queries the DM2 server for all the ESWBS numbers.
  ESWBS numbers and descriptions are returned.

  Algorithm

-fi*/

int	VDPgetESWBS( long	*msg,
		     int	*nbESWBS,
		     struct  VDPEswbs	**ESWBSLst )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[20];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    *nbESWBS = 0;
    *ESWBSLst = NULL;
    *msg = MSSUCC;

    for ( i=0; i<20; i++ )
    	inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_ESWBS;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    /* Read the output buffer */
    index = 0;
    memcpy( nbESWBS, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    if( *nbESWBS )
    {
	*ESWBSLst = _MALLOC ( *nbESWBS, struct VDPEswbs );
	if ( *ESWBSLst == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbESWBS; i++ )
    {
	strcpy((*ESWBSLst)[i].ESWBS, &outbuf[index]);
	index = index + strlen((*ESWBSLst)[i].ESWBS) +1;
	strcpy((*ESWBSLst)[i].ESWBS_Desc, &outbuf[index]);
	index = index + strlen((*ESWBSLst)[i].ESWBS_Desc ) +1;
    }

   return OM_S_SUCCESS;
}

/* This function returns the compartment attributes to be posted */

int	VDPgetOccTemplate( long	*msg,
			   char	*ClassName,
			   int		*nbAttr,
			   int		**AttrType,
		     	   struct  ACrg_coll	**Coll )
{
    SetProc ( VDPgetOccTemplate ); Begin

    *nbAttr = 9; //Added 3 more for frame,side and usage;
    *AttrType = NULL;
    *Coll = NULL;
    *msg = MSSUCC;

    __DBGpr_str("Class Name :", ClassName );
    *Coll = _MALLOC ( *nbAttr, struct ACrg_coll );
    if ( *Coll == NULL )
    {
	printf("Error in dynamic allocation of memory\n");
	return OM_E_NODYNMEM;
    }
    *AttrType = _MALLOC ( *nbAttr, int );
    if ( *AttrType == NULL )
    {
	printf("Error in dynamic allocation of memory\n");
	return OM_E_NODYNMEM;
    }

    strcpy((*Coll)[0].name, "cog_x" );
    (*Coll)[0].desc.type = AC_ATTRIB_DOUBLE;
    (*AttrType)[0] = AC_ATTRIB_DOUBLE;
    (*Coll)[0].desc.value.att_txt[0] = '\0';
    (*Coll)[0].desc.value.att_exp = 0;

    strcpy((*Coll)[1].name, "cog_y" );
    (*Coll)[1].desc.type = AC_ATTRIB_DOUBLE;
    (*AttrType)[1] = AC_ATTRIB_DOUBLE;
    (*Coll)[1].desc.value.att_txt[0] = '\0';
    (*Coll)[1].desc.value.att_exp = 0;

    strcpy((*Coll)[2].name, "cog_z" );
    (*Coll)[2].desc.type = AC_ATTRIB_DOUBLE;
    (*AttrType)[2] = AC_ATTRIB_DOUBLE;
    (*Coll)[2].desc.value.att_txt[0] = '\0';
    (*Coll)[2].desc.value.att_exp = 0;

    strcpy((*Coll)[3].name, "volume" );
    (*Coll)[3].desc.type = AC_ATTRIB_DOUBLE;
    (*AttrType)[3] = AC_ATTRIB_DOUBLE;
    (*Coll)[3].desc.value.att_txt[0] = '\0';
    (*Coll)[3].desc.value.att_exp = 0;

    strcpy((*Coll)[4].name, "floor_area" );
    (*Coll)[4].desc.type = AC_ATTRIB_DOUBLE;
    (*AttrType)[4] = AC_ATTRIB_DOUBLE;
    (*Coll)[4].desc.value.att_txt[0] = '\0';
    (*Coll)[4].desc.value.att_exp = 0;

// An extra attribute is added which is to be filled and sent to VDS
// This is for UOM in PME

	strcpy((*Coll)[5].name, "UnitMeasure" );  
	(*Coll)[5].desc.type = AC_ATTRIB_TEXT;
	(*AttrType)[5] = AC_ATTRIB_TEXT;           
	(*Coll)[5].desc.value.att_txt[0] = '\0';  
	(*Coll)[5].desc.value.att_exp = 0;    

	strcpy((*Coll)[6].name, "cnum_frame" );  
	(*Coll)[6].desc.type = AC_ATTRIB_TEXT;
	(*AttrType)[6] = AC_ATTRIB_TEXT;           
	(*Coll)[6].desc.value.att_txt[0] = '\0';  
	(*Coll)[6].desc.value.att_exp = 0;    

	strcpy((*Coll)[7].name, "cnum_side" );  
	(*Coll)[7].desc.type = AC_ATTRIB_TEXT;
	(*AttrType)[7] = AC_ATTRIB_TEXT;           
	(*Coll)[7].desc.value.att_txt[0] = '\0';  
	(*Coll)[7].desc.value.att_exp = 0;    


	strcpy((*Coll)[8].name, "cpt_use");  
	(*Coll)[8].desc.type = AC_ATTRIB_TEXT;
	(*AttrType)[8] = AC_ATTRIB_TEXT;           
	(*Coll)[8].desc.value.att_txt[0] = '\0';  
	(*Coll)[8].desc.value.att_exp = 0;    

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPgetOccTemplate1

  Abstract
  This function queries the DM2 server for each template type
  An ACrg_collect buffer is filled with names and datatypes.

-fi*/

int	VDPgetOccTemplate1( long	*msg,
			    char	*ClassName,
			    int		*nbAttr,
			    int		**AttrType,
		     	    struct  ACrg_coll	**Coll )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail, actualAttr;
    char		inbuf[20];
    char		*outbuf, *errmsg=0;
    char		DataType[20];
    char 		srerrmsg[70];

    SetProc ( VDPgetOccTemplate1 ); Begin

    *nbAttr = 0;
    *AttrType = NULL;
    *Coll = NULL;
    *msg = MSSUCC;
    outbuf = NULL;

    UI_status( "Getting Attribute Template");

    /*for ( i=0; i<20; i++ )
    	inbuf[i]='\0';*/

    __DBGpr_str("Class Name", ClassName );

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_OCC_TEMPLATE;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    strcpy( &inbuf[index], ClassName );
    inlen += strlen(ClassName) + 1;
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

   __DBGpr_int("VDPgetOccTemplate1.dstat:", dstat );
   __DBGpr_int("VDPgetOccTemplate1.mfail:", mfail );
   __DBGpr_str("VDPgetOccTemplate1.errmsg:", errmsg );

    /* Read the output buffer */
    index = 0;
    memcpy( nbAttr, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    __DBGpr_int( " nbAttr ", *nbAttr);

    actualAttr = 0;
    if( *nbAttr )
    {
	*Coll = _MALLOC ( *nbAttr, struct ACrg_coll );
	if ( *Coll == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
	*AttrType = _MALLOC ( *nbAttr, int );
	if ( *AttrType == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    //__DBGpr_int( " nbAttr ", *nbAttr);
    
	for ( i = 0; i < *nbAttr; i++ )
    {
	(*Coll)[actualAttr].desc.value.att_txt[0] = '\0';
	(*Coll)[actualAttr].desc.value.att_exp = 0;

	strcpy((*Coll)[actualAttr].name, &outbuf[index]);
	__DBGpr_str (" Attribute Name", (*Coll)[actualAttr].name );

	index = index + strlen((*Coll)[actualAttr].name) +1;
	strcpy ( DataType, &outbuf[index] );

	//__DBGpr_str ( "DataType ", DataType );

	if( !strcmp(DataType, "string" ))
	{
	    (*AttrType)[actualAttr] = AC_ATTRIB_TEXT;
	    (*Coll)[actualAttr++].desc.type = AC_ATTRIB_TEXT;
	}

/* For now comment; will see later 11/20/95
*/
	else if ( !strcmp(DataType, "long" ) || !strcmp(DataType, "integer"))
	{
	    (*AttrType)[actualAttr] = SM_ATTRIB_INT;
	    (*Coll)[actualAttr++].desc.type = AC_ATTRIB_DOUBLE;
	}

	else if (!strcmp(DataType, "float"))
	{
	    (*AttrType)[actualAttr] = AC_ATTRIB_DOUBLE;
	    (*Coll)[actualAttr++].desc.type = AC_ATTRIB_DOUBLE;
	}

	else	
	    __DBGpr_str ("Unknown Attribute type for ", DataType );

	index += strlen(DataType) +1;

	/* Next is the size of the attribute value */
	index = index + sizeof(int);

    }

    __DBGpr_int( " actualAttr ", actualAttr);

    if ( actualAttr < *nbAttr )
    {
	*nbAttr = actualAttr;
	*Coll = _REALLOC( *Coll, actualAttr, struct ACrg_coll );
	*AttrType = _REALLOC( *AttrType, actualAttr, int);
    }

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPpostObjectToDM2

  Abstract
  This function posts the Object information to the DM2 server. 

-fi*/

int	VDPpostObjectToDM2( long		*msg,
			    int			ObjType,
			    struct VDPtrObjList	TrRow,
		     	    int			nbAttr,
			    int			*AttrType,
		     	    struct  ACrg_coll	*Coll,
			    FILE 		*dm2_log )
{
    int			i, inlen, code, index=0, attrIndex, actualAttr,
			outlen, dstat, mfail;
    char		*inbuf=NULL;
    char		*outbuf, *errmsg=0;
    char		tmpstr[81], VDSobjid[10];
    OMuword		curOs;
    char		FileId[VDPOBID_LEN], ClassName[VDPCLASS_NAME_LEN];
    char		BdgCtx[VDPNAME_LEN], BdgCtxId[VDPOBID_LEN], 
			ESWBS[VDPESWBS_LEN], PlCtxId[VDPOBID_LEN], 
			PlCtx[VDPNAME_LEN];
    char                units[10];
    char 		srerrmsg[70];
    long		status = OM_S_SUCCESS;
    SetProc ( VDPpostObjectToDM2 ); Begin

    *msg = MSSUCC;
     units[0] = '\0';

    /* Approximately 80+25 per attribute */
    inbuf = _MALLOC ( 106 * nbAttr + 100, char );

    if ( inbuf == NULL )
    {
	UI_status ( "No Dynamic memory available" );
	return OM_E_ABORT; 
    }

    __DBGpr_int ( "ObjType", ObjType );

    ClassName[0] = '\0';

    if ( ObjType == -50 ) /* included in VDPcheckdef.h Later pass the class Name as the argument */
	strcpy( ClassName, "PmEquip");
    else
    if ( ObjType == COMPARTMENT_OBJ )
	strcpy( ClassName, "PmCmpmnt");
    else
    if ( ObjType == PIPING_OBJ )
	strcpy( ClassName, "PmPiping" );
    else
    if ( ObjType == HVAC_OBJ )
	strcpy( ClassName, "PmHVAC" );
    else
    if ( ObjType == RWAY_OBJ )
	strcpy( ClassName, "PmRway" );
    else
    if ( ObjType == STRUCT_BEAM_OBJ )
	strcpy( ClassName, "PmBeam" );
    else
    if ( ObjType == STRUCT_PLATE_OBJ )
	strcpy( ClassName, "PmPlate" );



/*
    The Item is deleted.
    else
	return OM_S_SUCCESS;
*/

    ex$get_cur_mod( osnum = &curOs );

    status = VDPGetFileId( msg, curOs, FileId );
    CheckRC (status, *msg);

    status = VDPGetBudgetCtxAndESWBS( msg, BdgCtx, BdgCtxId, ESWBS );
    CheckRC( status, *msg );

    status = VDPGetPlacementContext( msg, PlCtx, PlCtxId );
    CheckRC( status, *msg );


    /* Add the code to the beginning of the buffer */
    __DBGpr_int("Action Code", TrRow.ActionCode );

    if ( ObjType != COMPARTMENT_OBJ || TrRow.ActionCode == VDP_DELETE )
    {
	code = VDP_POST_OCCURRENCE;
	inlen = 0;
    }
    else
    {
	if( TrRow.ActionCode == VDP_DEL_COMP )
         code = VDP_MDEL_CMPMNT;            /* Delete Compartment 179603132 */
	else
         code = VDP_POST_CPMT_ATTR;         /* Post Compartment */

	inlen = 0;
    }
    __DBGpr_int( "Code : ", code );
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    if( ObjType != COMPARTMENT_OBJ )
    {
	memcpy( &inbuf[index], &(TrRow.ActionCode), sizeof(int));
	inlen += sizeof(int);
	index = inlen;
    }

    
    sprintf(VDSobjid,"%d\0", TrRow.VDSobjid );
    __DBGpr_str ( " VDS objid ", VDSobjid );

    strcpy( &inbuf[index], VDSobjid );
    inlen += strlen(VDSobjid) + 1;
    index = inlen;


    strcpy( &inbuf[index], FileId );
    inlen += strlen(FileId) +1;
    index = inlen;

    /* depending on the Object Type add the rest of the buffer */
    if(ObjType != COMPARTMENT_OBJ )
    {

    /* 
     * Later the Code in PME needs to be enhanced to take care of create, 
     * delete and Modify 
     */

      switch ( TrRow.ActionCode )
      {
	case VDP_FRPLLST :
	case VDP_MODIFY :
	    break;

	case VDP_CREATE :
	    strcpy( &inbuf[index], BdgCtxId );
	    inlen += strlen(BdgCtxId) +1;
	    index = inlen;

	    strcpy( &inbuf[index], PlCtxId );
	    inlen += strlen(PlCtxId) +1;
	    index = inlen;

	    strcpy( &inbuf[index], ESWBS );
	    inlen += strlen(ESWBS) +1;
	    index = inlen;
	    break;
	    
	case VDP_DELETE :
	    break;

	case VDP_REPLACE :
	default :
	    //printf("Not yet implemented\n");
	    _FREE( inbuf );

	    return OM_S_SUCCESS;
      }

      __DBGpr_str( "ClassName", ClassName );
      strcpy( &inbuf[index], ClassName );
      inlen += strlen(ClassName) +1;
      index = inlen;
    }


    if( TrRow.ActionCode != VDP_DELETE && TrRow.ActionCode != VDP_DEL_COMP )
    {

	memcpy( &inbuf[index], &nbAttr, sizeof(int));
	attrIndex = index;
	inlen += sizeof(int);
	index = inlen;

	actualAttr = nbAttr;

	for ( i =0; i < nbAttr; i++ )
	{
            /* Added by Meghani */
	    if ( Coll[i].desc.type == AC_ATTRIB_TEXT )
	    {
	        strcpy( &inbuf[index], Coll[i].name );
	        __DBGpr_str( "Attrib Name", Coll[i].name );

	        inlen += strlen(Coll[i].name) + 1;
	        index = inlen;
               if(!strcmp(Coll[i].name,"UnitMeasure"))
		  {
                   status = VDPgetDBunits(units);
                   strcpy(&inbuf[index],units);
                   inlen += strlen(units) + 1;
                   index = inlen;
                    __DBGpr_str(" Attribute Text :", units );
		   }


               else
                 {
                      strcpy( &inbuf[index], Coll[i].desc.value.att_txt );
                    __DBGpr_str(" Attribute Text :", Coll[i].desc.value.att_txt );
                      inlen += strlen(Coll[i].desc.value.att_txt ) + 1;
                      index = inlen; 
                 }
	    }
	    else if ( Coll[i].desc.type == AC_ATTRIB_DOUBLE )
	    {
	        strcpy( &inbuf[index], Coll[i].name );
	        __DBGpr_str( "Attrib Name", Coll[i].name );

	        inlen += strlen(Coll[i].name) + 1;
	        index = inlen;

	        sprintf( tmpstr,"%lf\0", Coll[i].desc.value.att_exp );
	        __DBGpr_str ( "Attrib Double :", tmpstr );
	        strcpy( &inbuf[index], tmpstr );
	        inlen += strlen(tmpstr) + 1;
	        index = inlen;
	    }
	    else if ( AttrType[i] == SM_ATTRIB_INT && 
		  Coll[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF )
	    {
	        strcpy( &inbuf[index], Coll[i].name );
	        __DBGpr_str( "Attrib Name", Coll[i].name );

	        inlen += strlen(Coll[i].name) + 1;
	        index = inlen;

	        sprintf( tmpstr,"%lf\0", Coll[i].desc.value.att_exp );
	        strtok ( tmpstr,".");
	        __DBGpr_str ( "Attrib Integer :", tmpstr );
	        strcpy( &inbuf[index], tmpstr );
	        inlen += strlen(tmpstr) + 1;
	        index = inlen;
	    }
	    else
	    {
	       actualAttr--;
	       __DBGpr_str(" Unknown Attribute Type for ", Coll[i].name );
	    }
	    __DBGpr_int( "\tIndex value ", index );
	}
           
	/* Copy the actual number of attr */
	memcpy( &inbuf[attrIndex], &actualAttr, sizeof(int));
    
}
/*    if(ObjType == COMPARTMENT_OBJ )
{
	for ( i =0; i < nbAttr; i++ )
	{
	    if ( Coll[i].desc.type == AC_ATTRIB_TEXT )
	    {
	        strcpy( &inbuf[index], Coll[i].name );
	        __DBGpr_str( "Attrib Name", Coll[i].name );

	        inlen += strlen(Coll[i].name) + 1;
	        index = inlen;
               if(!strcmp(Coll[i].name,"UnitMeasure")){
                   status = VDPgetDBunits(units);
                   strcpy(&inbuf[index],units);
                   inlen += strlen(units) + 1;
                   index = inlen;}
 SSR  fill in the values of UnitMeasure  for if(ObjType == COMPARTMENT_OBJ )
}
}
}*/

    __DBGpr_int( "Total length of inbuf", inlen );

    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if( mfail == 114 ) /* While attempting to delete a non PME item it returns
			  this mfail code. It is still successful. So continue
			  with a success */
    {
	return OM_S_SUCCESS;
    }
    else if(dstat || mfail) 
    {
	__DBGpr_int("dstat:", dstat );
	__DBGpr_int("mfail:", mfail );
	__DBGpr_str("errmsg:", errmsg );

	if(dstat == 12345 )
    	{
		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        	return OM_E_ABORT;
    	}

	if(!errmsg || (errmsg && !errmsg[0]))
	{
	  errmsg="No error msg but should be";
	  FILE_PRINT( dm2_log, "\t%s", errmsg );
	  //printf("\t%s", errmsg );
	}

	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	   UI_status( errmsg );

	_FREE( inbuf );
        return OM_E_ABORT;
    }

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    _FREE ( inbuf );
    End
    return OM_S_SUCCESS;
}
/*+fi
  Internal function VDPprepareAsciiFile 

  Abstract
  This function writes  the Object information to the ASCII file.

-fi*/

IGRint	VDPprepareAsciiFile( long		*msg,
			    int			ObjType,
			    struct VDPtrObjList	TrRow,
		     	    int			nbAttr,
			    int			*AttrType,
		     	    struct  ACrg_coll	*Coll,
			    FILE 		*fPtr )
{
    int			i, inlen, code, actualAttr;
    char		*inbuf=NULL;
    char		tmpstr[81], VDSobjid[10];
    OMuword		curOs;
    char		FileId[VDPOBID_LEN], ClassName[VDPCLASS_NAME_LEN];
    char		BdgCtx[VDPNAME_LEN], BdgCtxId[VDPOBID_LEN], 
			ESWBS[VDPESWBS_LEN], PlCtxId[VDPOBID_LEN], 
			PlCtx[VDPNAME_LEN];
    long		status = OM_S_SUCCESS;

    SetProc ( VDPprepareAsciiFile ); Begin

    *msg = MSSUCC;

    __DBGpr_int ( "ObjType", ObjType );

    ClassName[0] = '\0';

    if ( ObjType == -50 ) 
	strcpy( ClassName, "PmEquip");
    else
    if ( ObjType == COMPARTMENT_OBJ )
	strcpy( ClassName, "PmCmpmnt");
    else
    if ( ObjType == PIPING_OBJ )
	strcpy( ClassName, "PmPiping" );
    else
    if ( ObjType == HVAC_OBJ )
	strcpy( ClassName, "PmHVAC" );
    else
    if ( ObjType == RWAY_OBJ )
	strcpy( ClassName, "PmRway" );
    else
    if ( ObjType == STRUCT_BEAM_OBJ )
	strcpy( ClassName, "PmBeam" );
    else
    if ( ObjType == STRUCT_PLATE_OBJ )
	strcpy( ClassName, "PmPlate" );

    ex$get_cur_mod( osnum = &curOs );

    status = VDPGetFileId( msg, curOs, FileId );
    CheckRC (status, *msg);

    status = VDPGetBudgetCtxAndESWBS( msg, BdgCtx, BdgCtxId, ESWBS );
    CheckRC( status, *msg );

    status = VDPGetPlacementContext( msg, PlCtx, PlCtxId );
    CheckRC( status, *msg );


    /* Add the code to the beginning of the buffer */

    if ( ObjType != COMPARTMENT_OBJ || TrRow.ActionCode == VDP_DELETE )
    {
	code = VDP_POST_OCCURRENCE;
	inlen = 0;
    }
    else
    {
	if( TrRow.ActionCode == VDP_DEL_COMP )
         code = VDP_MDEL_CMPMNT;            /* Delete Compartment 179603132 */
	else
         code = VDP_POST_CPMT_ATTR;         /* Post Compartment */

	inlen = 0;
    }
    
    sprintf(tmpstr,"%d", code ); 
    strcat( tmpstr,"|" );
    PRINT_FILE( fPtr,"%s",tmpstr );

    if( ObjType != COMPARTMENT_OBJ )
    {
        sprintf(tmpstr,"%d", TrRow.ActionCode );
        strcat( tmpstr,"|" );
    	PRINT_FILE( fPtr,"%s",tmpstr );
    }

    sprintf(VDSobjid,"%d", TrRow.VDSobjid );
    __DBGpr_str ( " VDS objid ", VDSobjid );
    strcat( VDSobjid,"|" );
    PRINT_FILE( fPtr,"%s",VDSobjid );

    sprintf(tmpstr,"%s",FileId  );
    strcat( tmpstr,"|" );
    PRINT_FILE( fPtr,"%s",tmpstr );

    /* depending on the Object Type add the rest of the buffer */
    if(ObjType != COMPARTMENT_OBJ )
    {

    /* 
     * Later the Code in PME needs to be enhanced to take care of create, 
     * delete and Modify 
     */

      switch ( TrRow.ActionCode )
      {
	case VDP_FRPLLST :
	case VDP_MODIFY :
	    break;

	case VDP_CREATE :
            
    	    sprintf(tmpstr,"%s",BdgCtxId  );
            strcat( tmpstr,"|" );
            PRINT_FILE( fPtr,"%s",tmpstr );
            tmpstr[0]='\0';

    	    sprintf(tmpstr,"%s",PlCtxId   );
            strcat( tmpstr,"|" );
            PRINT_FILE( fPtr,"%s",tmpstr );
            tmpstr[0]='\0';

	    /* In VDS25, you no longer have ESWBS in the Default PM Data form. Hence send a dummy value of 0 to the PME server.  DKP 05/08/98 */

/*    	    sprintf(tmpstr,"%s",ESWBS   ); */
    	    sprintf(tmpstr,"%s","0"   );
            strcat( tmpstr,"|" );
            PRINT_FILE( fPtr,"%s",tmpstr );
            tmpstr[0]='\0';


	    break;
	    
	case VDP_DELETE :
	    break;

	case VDP_REPLACE :
	default :
	    //printf("Not yet implemented\n");
	    _FREE( inbuf );
	    return OM_S_SUCCESS;
      }

      __DBGpr_str( "ClassName", ClassName );
      sprintf(tmpstr,"%s",ClassName   );
      strcat( tmpstr,"|" );
      PRINT_FILE( fPtr,"%s",tmpstr );
      tmpstr[0]='\0';
    }


    if( TrRow.ActionCode != VDP_DELETE && TrRow.ActionCode != VDP_DEL_COMP)
    {
	actualAttr = nbAttr;
	/* First caluculate the Actual attributes */
	for ( i =0; i < nbAttr; i++ )
	{
	    if (!((Coll[i].desc.type == AC_ATTRIB_TEXT) ||
	         ( Coll[i].desc.type == AC_ATTRIB_DOUBLE )||
		 ( AttrType[i] == SM_ATTRIB_INT &&
                  Coll[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF )))
            {
		actualAttr--;
            }
        }
      	sprintf(tmpstr,"%d",actualAttr );
      	strcat( tmpstr,"|" );
      	PRINT_FILE( fPtr,"%s",tmpstr );
        tmpstr[0]='\0';
            

	actualAttr = nbAttr;
	for ( i =0; i < nbAttr; i++ )
	{
	    if (Coll[i].desc.type == AC_ATTRIB_TEXT) 
	    {
      		sprintf(tmpstr,"%s",Coll[i].name );
      		strcat( tmpstr,"|" );
      		PRINT_FILE( fPtr,"%s",tmpstr );
        	tmpstr[0]='\0';

	        __DBGpr_str( "Attrib Name", Coll[i].name );
      		sprintf(tmpstr,"%s", Coll[i].desc.value.att_txt );
                if( tmpstr[0] == '\0' || ! strcmp( tmpstr, "" ) )
		   strcpy( tmpstr, "NULL");
      		strcat( tmpstr,"|" );
      		PRINT_FILE( fPtr,"%s",tmpstr );
        	tmpstr[0]='\0';
	    }
	    else if ( Coll[i].desc.type == AC_ATTRIB_DOUBLE )
	    {
      		sprintf(tmpstr,"%s",Coll[i].name );
      		strcat( tmpstr,"|" );
      		PRINT_FILE( fPtr,"%s",tmpstr );
        	tmpstr[0]='\0';

      		sprintf(tmpstr,"%lf",Coll[i].desc.value.att_exp );
                if( tmpstr[0] == '\0' || ! strcmp( tmpstr, "" ) )
		   strcpy( tmpstr, "NULL");
      		strcat( tmpstr,"|" );
      		PRINT_FILE( fPtr,"%s",tmpstr );
        	tmpstr[0]='\0';
	    }
	    else if ( AttrType[i] == SM_ATTRIB_INT && 
		  Coll[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF )
	    {
      		sprintf(tmpstr,"%s",Coll[i].name );
      		strcat( tmpstr,"|" );
      		PRINT_FILE( fPtr,"%s",tmpstr );
        	tmpstr[0]='\0';

      		sprintf(tmpstr,"%lf",Coll[i].desc.value.att_exp );
	        strtok ( tmpstr,".");
                if( tmpstr[0] == '\0' || ! strcmp( tmpstr, "" ) )
		   strcpy( tmpstr, "NULL");
      		strcat( tmpstr,"|" );
      		PRINT_FILE( fPtr,"%s",tmpstr );
        	tmpstr[0]='\0';
	    }
	    else
	    {
	       actualAttr--;
	       __DBGpr_str(" Unknown Attribute Type for ", Coll[i].name );
	    }
	}
	/* Copy the actual number of attr */
    }
    PRINT_FILE( fPtr,"\n" );
         


    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPreserveOccurrence

  Abstract
  This function reserves the selected occurrence in the Placement List in 
  PME database.

-fi*/

IGRint	VDPreserveOccurrence (  long *msg,
				char	*PlCtxid,
				char	*Fileid,
				char	*PMobid,
				int	VDSobjid )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100],tmpstr[20];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    SetProc ( VDPreserveOccurrence ); Begin

    *msg = MSSUCC;

    for ( i=0; i<100; i++ ) inbuf[i]='\0';

    code = VDP_RESERVE_OCC;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    strcpy( &inbuf[index], PlCtxid );
    inlen += strlen(PMobid) + 1;
    index = inlen;
    strcpy( &inbuf[index], Fileid );
    inlen += strlen(PMobid) + 1;
    index = inlen;
    strcpy( &inbuf[index], PMobid );
    inlen += strlen(PMobid) + 1;
    index = inlen;
    tmpstr[0]='\0';
    sprintf(tmpstr,"%d",VDSobjid);
    strcpy( &inbuf[index], tmpstr );
    inlen += strlen(tmpstr) + 1;
    index = inlen;

    /* depending on the Action Code add the rest of the buffer */
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );

    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    End
    return OM_S_SUCCESS;
}
				
/*+fi
  Internal function VDPqueryFileId

  Abstract
  This function queries the PME database for a File Id given a Catalog,
  Partname and a Partrev.

-fi*/

IGRint	VDPqueryFileId (long 	*msg,
			char	*Catalog,
			char	*Partname,
			char	*Partrev,
			char	*FileId )	/* Output */
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100];
    char		*outbuf, *errmsg=0;
    char		FileName[257];
    char 		srerrmsg[70];

    SetProc ( VDPqueryFileId ); Begin

    *msg = MSSUCC;

    for ( i=0; i<100; i++ ) inbuf[i]='\0';

    code = VDP_QUERY_FILEID;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    strcpy( &inbuf[index], Catalog );
    inlen += strlen(Catalog) + 1;
    index = inlen;
    strcpy( &inbuf[index], Partname );
    inlen += strlen(Partname) + 1;
    index = inlen;
    strcpy( &inbuf[index], Partrev );
    inlen += strlen(Partrev) + 1;
    index = inlen;

    FileName[0] = '\0';

    if( !get_local_fname(Catalog, Partname, Partrev, FileName) )
    {
      UI_status( "Unable to get local( CheckOut ) file name from RDB" );
      return 0;
    } 

    strcpy( &inbuf[index], FileName );
    inlen += strlen(FileName) + 1;
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );

    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    /* The number of File Id's is returned */
    index = sizeof(int);
    strcpy( FileId, &outbuf[index] );
    index = strlen(FileId) + 1;

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPgetPlacementList

  Abstract
  This function queries the PME database for the Placement List.

-fi*/

IGRint VDPgetPlacementList( IGRlong	*msg, 
			    IGRchar	*PlCtxid,
			    IGRint	OccType,
			    IGRint	*nbOcc,
			    char	**PlList ) /* Output */
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100],
			ClassName[VDPCLASS_NAME_LEN];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    SetProc ( VDPgetPlacementList ); Begin

    *msg = MSSUCC;
    *PlList = NULL;

    for ( i=0; i<100; i++ ) inbuf[i]='\0';

    switch ( OccType )
    {
	case VDP_EQUIP :
	    strcpy ( ClassName, "PmEquip" );
	    break;
	default :
		//printf (" Not implemented \n");
		return OM_S_SUCCESS;
    }

    code = VDP_QUERY_PLLIST;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int); index = inlen;
    strcpy( &inbuf[index], PlCtxid );
    inlen += strlen(PlCtxid) + 1; index = inlen;
    strcpy( &inbuf[index], ClassName );
    inlen += strlen(ClassName)+ 1;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );

    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    } 

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    index = 0;
    memcpy( nbOcc, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    switch ( OccType )
    {
	case VDP_EQUIP :
	{
	    struct VDPpre_ld_eqp *ptr;

	  __DBGpr_int( "Nb Equipments ", *nbOcc );

	  if ( *nbOcc )
	  {
	    *PlList = _MALLOC ( *nbOcc * sizeof( struct VDPpre_ld_eqp ), IGRchar );
	    if (! *PlList )
	    {
		UI_status("Error in dynamic allocation of memory");
		return OM_E_NODYNMEM;
	    }
	    ptr = (struct VDPpre_ld_eqp *)(*PlList);
	    for (i=0; i < *nbOcc; i++ )
	    {
		strcpy( ptr[i].PMobid, &outbuf[index] );
		index += strlen(ptr[i].PMobid) +1;
		strcpy( ptr[i].Catalog, &outbuf[index] );
		index += strlen(ptr[i].Catalog) + 1;
		strcpy( ptr[i].PartNumber, &outbuf[index] );
		index += strlen(ptr[i].PartNumber) + 1;
		strcpy( ptr[i].PartRev, &outbuf[index] );
		index += strlen(ptr[i].PartRev) + 1;
		strcpy( ptr[i].Desc, &outbuf[index] );
		index += strlen(ptr[i].Desc) + 1;
		ptr[i].PlacedFlag = 'N';
	    }
	  }
	}
	break;
/*
	case VDP_PIPING :
		break;
	case VDP_HVAC :
		break;
	case VDP_RWAY :
		break;
	case VDP_BEAM :
		break;
	case VDP_PLATE :
		break;
*/
	default :
		printf ( "Unknown Occurence Type\n");
		break;

    }

    End
    return OM_S_SUCCESS;
}

/*+fi

    This function returns all the Work packages created in a PMR session 

-fi*/

IGRint	VDPgetPMRworkPackage( IGRlong		*msg,
			      IGRchar		*FileId,
			      IGRint		*nbWrkPkg,
			      struct VDPwrkPkg1	**WrkPkg )
{
    int			i,j, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100], tmpstr[20];
    char		*outbuf, *errmsg=0;
    IGRint		VDSobjid, nbNotes, NoteLen;
    char 		srerrmsg[70];

    SetProc ( VDPgetPMRworkPackage ); Begin

    *msg = MSSUCC;

    for ( i=0; i<100; i++ ) inbuf[i]='\0';

    code = VDP_QUERY_WRKPKG;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int); index = inlen;
    strcpy( &inbuf[index], FileId );
    inlen += strlen(FileId) + 1;
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );


   if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    /* Read the output buffer */
    index = 0;
    memcpy( nbWrkPkg, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    /* Allocate memory for the Work Packages */
    if( *nbWrkPkg )
    {
	*WrkPkg = _MALLOC ( *nbWrkPkg, struct VDPwrkPkg1 );
	if ( *WrkPkg == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i =0; i < *nbWrkPkg;  )
    {
	strcpy( tmpstr, &outbuf[index] );
	VDSobjid = atoi(tmpstr);
	__DBGpr_int(" VDS object Id ", VDSobjid );

	index = index + strlen(tmpstr) + 1;
	memcpy( &nbNotes, &outbuf[index], sizeof(int));
	index = index + sizeof(int);

	for( j = 0; j < nbNotes; j++, i++ )
	{
	    (*WrkPkg)[i].objid = VDSobjid;
	    NoteLen = strlen(&outbuf[index]) +1;

	    /* Allocate memory for the Actual Notes */
	    (*WrkPkg)[i].Notes = _MALLOC ( NoteLen, IGRchar );
	    strcpy( (*WrkPkg)[i].Notes, &outbuf[index] );
	    index = index + NoteLen ;
	}
    }

    End
    return OM_S_SUCCESS;
}

/*+fi

   This function returns all the zones available and those that belong to
   the current file

-fi*/

IGRint  VDPqueryListofZones (   IGRlong         *msg,
                                IGRchar         *FileId,
                                IGRint          *nbZones,
                                struct VDPzone  **Zones )
{
    int                 i, inlen, code, index=0;
    char                inbuf[100];
/*
    int                 outlen, dstat, mfail;
    char                *outbuf, *errmsg=0;
    char 		srerrmsg[70];
*/

    SetProc ( VDPqueryListofZones ); Begin

    *msg = MSSUCC;

    for ( i=0; i<100; i++ ) inbuf[i]='\0';

    code = VDP_QUERY_ZONES;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int); index = inlen;
    strcpy( &inbuf[index], FileId );
    inlen += strlen(FileId) + 1;
    index = inlen;


#ifdef LORICODE
    dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                        inbuf,
                                        &outlen,
                                        &outbuf,
                                        &mfail,
                                        &errmsg );
    
   if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }   

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    /* Read the output buffer */
    index = 0;
    memcpy( nbZones, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

#endif

    *nbZones = 2;

    /* Allocate memory for the Zones */
    if( *nbZones )
    {
        *Zones = _MALLOC ( *nbZones, struct VDPzone );
        if ( *Zones == NULL )
        {
            printf("Error in dynamic allocation of memory\n");
            return OM_E_NODYNMEM;
        }
    }

    for ( i =0; i < *nbZones; i++ )
    {
        /* Fill the structure with outbuf */
        (*Zones)[i].ZoneType = ZONE_TYPE_NOTDEF;
        (*Zones)[i].ZoneId.objid = NULL_OBJID;
        (*Zones)[i].ZoneCtx.Type = VDPTZONE_CODE;
        (*Zones)[i].ZoneCtx.SubType = 1;
        strcpy( (*Zones)[i].ZoneCtx.SubTypeDesc, "Fire Protect Zone" );
        strcpy( (*Zones)[i].ZoneCtx.Name, "Zone 00X" );
        sprintf( (*Zones)[i].ZoneCtx.CtxDesc, "Zone %d", i+1 );
        sprintf( (*Zones)[i].ZoneCtx.CtxId, "000%d", i+1 );
    }

    End
    return OM_S_SUCCESS;
}


/*+fi

    This function returns all the unplaced zone contexts given the class name
    for the zone.

-fi*/

int	VDPgetZoneContexts( long	*msg,
			    char	*ClassName,
			    int		*nbCtx,
			    struct	VDPNameDesc	**Contexts )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100];
    char		*outbuf, *errmsg=0;
    IGRlong		status;
    struct VDPShipDesc	ShipDesc;
    char 		srerrmsg[70];

    SetProc ( VDPgetZoneContexts ); Begin

    *nbCtx = 0;
    *Contexts = NULL;
    *msg = MSSUCC;

    for ( i=0; i<100; i++ )
    	inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_ZONES;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    status = VDPGetShipData( msg, &ShipDesc );
    CheckRC (status, *msg);
    strcpy( &inbuf[index], ShipDesc.ShipName );
    inlen = inlen + strlen( ShipDesc.ShipName )+1;
    index = inlen;

    /* Add the class name */

    strcpy( &inbuf[index], ClassName );
    inlen = inlen + strlen(ClassName) +1 ;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

    /* Read the output buffer */
    index = 0;
    memcpy( nbCtx, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    if( *nbCtx )
    {
	*Contexts = _MALLOC ( *nbCtx, struct VDPNameDesc );
	if ( *Contexts == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbCtx; i++ )
    {
	strcpy((*Contexts)[i].CtxId, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxId) +1;
	strcpy((*Contexts)[i].CtxName, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxName ) +1;
	strcpy((*Contexts)[i].CtxDesc, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CtxDesc ) +1;

	__DBGpr_str("Context name ", (*Contexts)[i].CtxName );
	__DBGpr_str("Context Desc ", (*Contexts)[i].CtxDesc );
    }

   End
   return OM_S_SUCCESS;
}

/*+fi

    This function returns all the unplaced compartment contexts

-fi*/

int	VDPgetCompContexts( long	*msg,
			    int		*nbCtx,
			    struct	VDPcomp	**Contexts )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[128];
    char		*outbuf, *errmsg=0;
    IGRlong		status;
    struct VDPShipDesc	ShipDesc;
    char 		srerrmsg[70];

    SetProc ( VDPgetCompContexts ); Begin

    *nbCtx = 0;
    *Contexts = NULL;
    *msg = MSSUCC;

    for ( i=0; i<128; i++ )
    	inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_CMPTS;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    status = VDPGetShipData( msg, &ShipDesc );
    CheckRC (status, *msg);
    strcpy( &inbuf[index], ShipDesc.ShipName );
    inlen = inlen + strlen( ShipDesc.ShipName ) + 1;
    index = inlen;

    __DBGpr_str(" ShipName ", ShipDesc.ShipName );

    /* Add the class name */

    strcpy( &inbuf[index], "PmCmpmnt" );
    inlen = inlen + strlen("PmCmpmnt") +1 ;
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

    /* Read the output buffer */
    index = 0;
    memcpy( nbCtx, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    if( *nbCtx )
    {
	*Contexts = _MALLOC ( *nbCtx, struct VDPcomp );
	if ( *Contexts == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbCtx; i++ )
    {
	strcpy((*Contexts)[i].CompObid, &outbuf[index]);
	index = index + strlen((*Contexts)[i].CompObid) +1;
	strcpy((*Contexts)[i].Name, &outbuf[index]);
	index = index + strlen((*Contexts)[i].Name ) +1;
	strcpy((*Contexts)[i].SSCSnum, &outbuf[index]);
	index = index + strlen((*Contexts)[i].SSCSnum ) +1;
	strcpy((*Contexts)[i].Description, &outbuf[index]);
	index = index + strlen((*Contexts)[i].Description ) +1;

	__DBGpr_str("Context name ", (*Contexts)[i].Name );
	__DBGpr_str("Context Desc ", (*Contexts)[i].Description );
    }

   End
   return OM_S_SUCCESS;
}

IGRint	VDPgetCompAttr( IGRlong			*msg, 
			IGRchar 		*CompObid, 
			IGRint			*nbAttr, 
			struct ACrg_coll	**Coll )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail, actualAttr;
    char		inbuf[70], tmpstr[50];
    char		*outbuf, *errmsg=0;
    char		DataType[20];
    int                 status;
    char                units[10];
    char 		srerrmsg[70];
    SetProc ( VDPgetCompAttr ); Begin

    *nbAttr = 0;
    *Coll = NULL;
    *msg = MSSUCC;
     units[0] = '\0';

    for ( i=0; i<70; i++ ) inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_CMPT_ATTR;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    strcpy( &inbuf[index], CompObid);
    inlen += strlen(CompObid) + 1;
    index = inlen;
    status = VDPgetDBunits(units);
    strcpy(&inbuf[index],units);
    inlen += strlen(units) + 1;
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }   
 
    __DBGpr_int("dstat:", dstat );
    __DBGpr_int("mfail:", mfail );
    __DBGpr_str("errmsg:", errmsg );

    /* Read the output buffer */
    index = 0;
    memcpy( nbAttr, &outbuf[index], sizeof(int));
    index = index + sizeof(int);

    __DBGpr_int ( "Number of Attributes", *nbAttr );
    actualAttr = 0;
    if( *nbAttr )
    {
	*Coll = _MALLOC ( *nbAttr, struct ACrg_coll );
	if ( *Coll == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

    for ( i = 0; i < *nbAttr; i++ )
    {
	strcpy((*Coll)[actualAttr].name, &outbuf[index]);
	__DBGpr_str (" Attribute Name ", (*Coll)[actualAttr].name );

	index = index + strlen((*Coll)[actualAttr].name) +1;
	strcpy ( DataType, &outbuf[index] );

	__DBGpr_str ( "DataType ", DataType );
	index += strlen(DataType) +1;

	if( !strcmp(DataType, "string" ))
	{
	    strcpy ((*Coll)[actualAttr].desc.value.att_txt, &outbuf[index] );
	    __DBGpr_str("String Value", (*Coll)[actualAttr].desc.value.att_txt);

	    index += strlen((*Coll)[actualAttr].desc.value.att_txt) +1;
	    (*Coll)[actualAttr++].desc.type = AC_ATTRIB_TEXT;
	}

	else if ( !strcmp(DataType, "long" ) || !strcmp(DataType, "integer"))
	{
	    strcpy( tmpstr, &outbuf[index] );
	    (*Coll)[actualAttr].desc.value.att_exp = (double)atoi(tmpstr);
	    (*Coll)[actualAttr++].desc.type = AC_ATTRIB_DOUBLE;
	    index += strlen(tmpstr) +1;
	    __DBGpr_str("Long Value", tmpstr );
	}

	else if (!strcmp(DataType, "float"))
	{
	    strcpy( tmpstr, &outbuf[index] );
	    (*Coll)[actualAttr].desc.value.att_exp = (double)atof(tmpstr);
	    (*Coll)[actualAttr++].desc.type = AC_ATTRIB_DOUBLE;
	    index += strlen(tmpstr) +1;
	    __DBGpr_str("Float Value", tmpstr );
	}

	else
	    __DBGpr_str ("Unknown Attribute type for ", DataType );

    }

    if ( actualAttr < *nbAttr )
    {
	*nbAttr = actualAttr;
	*Coll = _REALLOC( *Coll, actualAttr, struct ACrg_coll );
    }

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPgetShipIds

  Abstract
  This function queries the PME database and returns all the active Ships.

  Algorithm

-fi*/

int	VDPgetShips ( long	*msg,
			int	*nbShips,
			struct	VDPShipDesc	**Ships )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[20];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    SetProc ( VDPgetShips ); Begin

    *nbShips = 0;
    *Ships = NULL;
    *msg = MSSUCC;

    for ( i=0; i<20; i++ )
    	inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    code = VDP_QUERY_SHIPS;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* Query PME server */
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }

    index = 0;
    memcpy( nbShips, &outbuf[index], sizeof(int));
    index = index + sizeof(int);
    __DBGpr_int( "nbShips", *nbShips );

    if( *nbShips )
    {
	*Ships = _MALLOC ( *nbShips, struct VDPShipDesc );
	if ( *Ships == NULL )
	{
	    printf("Error in dynamic allocation of memory\n");
	    return OM_E_NODYNMEM;
	}
    }

/*
    strcpy((*Ships)[0].ShipId, "00001" );
    strcpy((*Ships)[0].ShipName, "ABCDEF-GHI" );
    strcpy((*Ships)[0].ShipDesc, "Entirely New Ship" );
*/

    for ( i = 0; i < *nbShips; i++ )
    {
	(*Ships)[i].ShipId[0] = '\0';
	(*Ships)[i].ShipName[0] = '\0';
	(*Ships)[i].ShipDesc[0] = '\0';

	strcpy((*Ships)[i].ShipId, &outbuf[index]);
	index = index + strlen((*Ships)[i].ShipId) +1;
	__DBGpr_str ("ShipId", (*Ships)[i].ShipId );
	strcpy((*Ships)[i].ShipName, &outbuf[index]);
	index = index + strlen((*Ships)[i].ShipName) +1;
	__DBGpr_str ("Ship Name ", (*Ships)[i].ShipName );
	strcpy((*Ships)[i].ShipDesc, &outbuf[index]);
	index = index + strlen((*Ships)[i].ShipDesc) +1;
	__DBGpr_str ("Ship Desc ", (*Ships)[i].ShipDesc );
    }

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPIsFileRevised

  Abstract
  This function queries the PME database to verify if the file is revised or
  not. If the file is revised it returns the new file, shipId, Budget Ctx and 
  placement context.

  Algorithm

-fi*/

int	VDPIsFileRevised ( long		*msg,	
			   char 	*OldFileId,
			   char		*NCatalog,  /* I */
			   char		*NPart,	    /* I */
			   char		*NRev,	    /* I */
			   int 		*fileState,
			   char		*NfileId,
			   char		*NshipId,
			   char		*NbwtCtxId,
			   char		*NplCtxId,
			   char		*NShipName )
{
    int			i, inlen, code, index=0,
			outlen=0, dstat, mfail;
    char		inbuf[256];
    char		*outbuf, *errmsg=0;
    char		BdgCtx[VDPNAME_LEN], BdgCtxId[VDPOBID_LEN], 
			ESWBS[VDPESWBS_LEN], PlCtxId[VDPOBID_LEN], 
			PlCtx[VDPNAME_LEN];
    struct VDPShipDesc	ShipDesc;
    char 		srerrmsg[70];
    long		status = OM_S_SUCCESS;
    

    SetProc ( VDPIsFileRevised ); Begin

    *msg = MSSUCC;
    *fileState = 0;

    for ( i=0; i<256; i++ ) inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */

    status = VDPGetBudgetCtxAndESWBS( msg, BdgCtx, BdgCtxId, ESWBS );
    CheckRC( status, *msg );

    status = VDPGetPlacementContext( msg, PlCtx, PlCtxId );
    CheckRC( status, *msg );

    status = VDPGetShipData( msg, &ShipDesc );
    CheckRC (status, *msg);

    code = VDP_IS_FILE_REVISED;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    strcpy( &inbuf[index], OldFileId );
    inlen += strlen(OldFileId) + 1;
    index = inlen;
    strcpy( &inbuf[index], BdgCtxId );
    inlen += strlen(BdgCtxId) + 1;
    index = inlen;
    strcpy( &inbuf[index], PlCtxId );
    inlen += strlen(PlCtxId) + 1;
    index = inlen;
    strcpy( &inbuf[index], ShipDesc.ShipId );
    inlen += strlen( ShipDesc.ShipId ) + 1;
    index = inlen;
    strcpy( &inbuf[index], NCatalog );
    inlen += strlen(NCatalog) + 1;
    index = inlen;
    strcpy( &inbuf[index], NPart );
    inlen += strlen(NPart) + 1;
    index = inlen;
    strcpy( &inbuf[index], NRev );
    inlen += strlen(NRev) + 1;
    index = inlen;

    /* Query PME server */
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if ( mfail == VDP_SUCCESSOR_EXISTS )
    {
	*fileState = VDP_PARENT_FILE_HAS_SUCCESSOR ;
	UI_status("Parent File is already revised" );
	return OM_S_SUCCESS;
    }
    else if (mfail == VDP_FILE_NEEDS_REVISED )
    {
	*fileState = VDP_FILE_REVISED;
	return OM_S_SUCCESS;
    }
    else if(dstat || mfail) 
    {
	if(dstat == 12345 )
        {
		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        	return 0;
    	}
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	return 0;
    }
    /* Read the output buffer */
    index = 0;
    memcpy( fileState, &outbuf[index], sizeof(int));
    index = index + sizeof(int);
    if ( *fileState == VDP_FILE_REVISED )
    {
	strcpy(NfileId, &outbuf[index]);
	index = index + strlen(NfileId) +1;
	strcpy(NshipId, &outbuf[index]);
	index = index + strlen(NshipId) +1;
	strcpy(NbwtCtxId, &outbuf[index]);
	index = index + strlen(NbwtCtxId) +1;
	strcpy(NplCtxId, &outbuf[index]);
	index = index + strlen(NplCtxId) +1;
	strcpy(NShipName, &outbuf[index]);
	*fileState = VDP_UPDATE_FILEDATA;
    }
    End
    return OM_S_SUCCESS;

}

/*+fi
  Internal function VDPupdateFileId

  Abstract
  This function updates the PME database for a File Id with a given  
  Catalog, Partname and a Partrev.

-fi*/

IGRint	VDPUpdateFileId (long 	*msg,
			char	*FileId,
			char	*Catalog,
			char	*Partname,
			char	*Partrev,
			char	*ShipName )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[256];
    char		*outbuf, *errmsg=0;
    char 		srerrmsg[70];

    SetProc ( VDPUpdateFileId ); Begin

    *msg = MSSUCC;

    for ( i=0; i<256; i++ ) inbuf[i]='\0';

    code = VDP_UPDATE_FILEID;
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;
    strcpy( &inbuf[index], FileId );
    inlen += strlen(FileId) + 1;
    index = inlen;
    strcpy( &inbuf[index], Catalog );
    inlen += strlen(Catalog) + 1;
    index = inlen;
    strcpy( &inbuf[index], Partname );
    inlen += strlen(Partname) + 1;
    index = inlen;
    strcpy( &inbuf[index], Partrev );
    inlen += strlen(Partrev) + 1;
    index = inlen;
    strcpy( &inbuf[index], ShipName );
    inlen += strlen(ShipName) + 1;
    index = inlen;
    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
	*msg = MSFAIL;
        return 0;
    }	
    
   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPIsEquipReserved

  Abstract
  This function queries the DM2 server to find out if the specified piece
  of equipment is reserved for VDS placement.

  Algorithm

  Return Value
    Returns TRUE        - if the equipment is reserved for placement.
    Returns FALSE       - if the equipment is not reserved for placement.
    Returns an errror   - if an error was encountered during the processing.
               value
-fi*/

 int VDPIsEquipReserved( long *msg,
			 char *EqpObid ) /* the PM OBID of the Equipment Item */
 {
    int  ii, inlen, code, idx=0,
         outlen=0, dstat, mfail,
         IsReserved = FALSE;
    char inbuf[80];
    char *outbuf, *errmsg=0;
    char 		srerrmsg[70];

    *msg = MSSUCC;

    /* Check if this eguip item is reserved for placement.*/
    for(ii=0; ii<80; ii++)
     inbuf[ii]='\0';

    code = VDP_IS_EQUIP_RESERVED;

    inlen = 0;
    idx = 0;
    memcpy( &inbuf[idx], &code, sizeof(int) );
    inlen += sizeof(int);

    idx = inlen;
    strcpy( &inbuf[idx], EqpObid );
    inlen += strlen(EqpObid) + 1;
    idx = inlen;

    dstat = POSTMAN_REQUEST_ON_CLIX( inlen, inbuf, &outlen, &outbuf,
                                     &mfail, &errmsg );

    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return dstat;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return dstat;
    }

    /* Read the output buffer */
    idx = 0;
    memcpy( &IsReserved, &outbuf[idx], sizeof(int));
    idx = idx + sizeof(int);

    if( IsReserved == TRUE )
     return TRUE;

    return FALSE;
 }

/*+fi
  Internal function VDPCrePlFileRel

  Abstract
  Given a PlacementList PmObid and a File PmObid, this function creates
  a relationship between the placement list and the file in PME.

  Returns OM_S_SUCCESS if sucessful, OM_E_ABORT otherwise.

  Algorithm

-fi*/

int VDPCrePlFileRel( long *msg,
		     char *CtxId,
		     char *FileId )
{
   IGRlong status = OM_S_SUCCESS;
   int     ii, inlen, code, index=0,
           outlen=0, dstat, mfail;
   char    inbuf[80];
   char    *outbuf, *errmsg=0;
    char 		srerrmsg[70];
/*
   OMuword curOs;
*/

   *msg = MSSUCC;

   for(ii=0; ii<80; ii++)
    inbuf[ii]='\0';

   code = VDP_CREATE_PLLIST_FILE_RELN;

   inlen = 0;
   index = 0;
   memcpy( &inbuf[index], &code, sizeof(int) );
   inlen += sizeof(int);
   index = inlen; /* added on Friday the 13th Sep 96 */

   strcpy( &inbuf[index], CtxId );
   inlen = inlen + strlen(CtxId) + 1;
   index = inlen;

   strcpy( &inbuf[index], FileId );
   inlen = inlen + strlen(FileId) + 1;
   index = inlen;
   dstat = POSTMAN_REQUEST_ON_CLIX( inlen, inbuf, &outlen, &outbuf, &mfail,
                                    &errmsg );
   if(mfail == 9219) /* It is a valid status */
      return OM_S_SUCCESS;

   else if( dstat || mfail )
   {
     if(dstat == 12345 )
     {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        status = OM_E_ABORT;
        return status;
     }
     if( !errmsg ||
         (errmsg && !errmsg[0]) )
      errmsg="No error msg but should be";
     if ( strlen(errmsg ) > 63 )
	errmsg[63] = '\0';

     UI_status( errmsg );
     status = OM_E_ABORT;
   }

   return status;
}

/* New function added by meghani for UOM  in PME 
   This function returns the units in active seed file
   ENG for english units
   MET for metric units  */ 


int VDPgetDBunits( char *DbUnits )
{ 
  long 		status;
  GRspacenum 	cur_os;
  char 		dir_name[DI_PATH_MAX];
  struct 	GRid UomSuper;
  IGRint  	eng_met; 

  SetProc( VDPquerydm2.VDPgetDBunits ); Begin

  status = OM_S_SUCCESS;
  ex$get_cur_mod(osnum=&cur_os);
  di$give_pathname(osnum=cur_os,pathname=dir_name);
  strcat(dir_name,":IGENOD:UOMsuper");
  UomSuper.objid = NULL_OBJID;

  status = di$translate( objname=dir_name,
			p_objid = &( UomSuper.objid ),
			p_osnum = &( UomSuper.osnum ));

  if(!(status&1) || UomSuper.objid == NULL_OBJID)
     printf("\n ERROR :: translating UOMSuper object ");

  DbUnits[0]='\0';

  status = co$unit_database_type( osnum	= UomSuper.osnum, 
				db_type = &eng_met );

      if(eng_met == GRIO_UNITS_ARE_METRIC) 
      	strcpy(DbUnits,"MET");

      if(eng_met == GRIO_UNITS_ARE_ENGLISH)
      	strcpy(DbUnits,"ENG");

    __DBGpr_str ("Database Unit ", DbUnits );
  End
  if(!status)
   return( 0 ) ;
  else
   return( 1 );
    
 }

int VDaddPart4SIR( IGRlong *msg, struct GRid part, FILE *dm2_log)

{
  IGRlong		status;
  struct GRmd_env	MdEnv;
  IGRchar		minoval[31], cageval[6], EqpPartNo[40];
  struct ACrg_coll      *Coll = NULL;
  IGRint		size = 0, ret_size= 0, i, changePartVar = 0;
  double		incrmnt = 1.0;
  IGRchar		class_name[80];
  OMuword		curos;
  IGRchar		*token=NULL;

  SetProc( VDPquerydm2.VDaddPart4SIR ); Begin 

  *msg = MSSUCC;

   UI_status("Collecting Parts to post to AIM");
   __DBGpr_int( " part ", part.objid);

      ex$get_cur_mod( osnum = &curos );

   status = om$get_classname( objid = part.objid,
				osnum = curos,
				classname = class_name );
   
   /*for ( i = 0; i < 20; i ++)
     compcodeval[i] = '\0';*/

   for ( i = 0; i < 31; i ++)
     minoval[i] = '\0';

   for ( i = 0; i < 6; i ++)
     cageval[i] = '\0';

    Coll = _MALLOC ( 8, struct ACrg_coll );

    if ( Coll == NULL )
    {
      UI_status("Error no dynamic memory");
      return OM_E_NODYNMEM;
    }
      __DBGpr_com ("Memory Allocated for Coll");

      strcpy( Coll[0].name, "mino");
     strcpy( Coll[1].name, "cage");
     strcpy( Coll[2].name, "eqp_partno");
     strcpy( Coll[3].name, "pipe_length");
     //strcpy( Coll[2].name, "comp_code");
     strcpy( Coll[4].name, "surface_area");
     strcpy( Coll[5].name, "duct_length");
     strcpy( Coll[6].name, "memb_cut_leng");
     strcpy( Coll[7].name, "trans_len");
     Coll[0].desc.value.att_txt[0] = '\0';
     Coll[1].desc.value.att_txt[0] = '\0';
     Coll[2].desc.value.att_txt[0] = '\0';
     Coll[3].desc.value.att_exp = 0.0;
     //Coll[2].desc.value.att_txt[0] = '\0';
     Coll[4].desc.value.att_exp = 0.0;
     Coll[5].desc.value.att_exp = 0.0;
     Coll[6].desc.value.att_exp = 0.0;
     Coll[7].desc.value.att_exp = 0.0;

      size = sizeof( struct GRmd_env ) ;

       gr$get_module_env(  msg    = msg,
			sizbuf = &size,
			buffer = &MdEnv,
	 		nret   = &ret_size );

    status = vd$review_params(   pMsg           = msg,
				pComponent      = &part,
				pMdEnv          = &MdEnv,
				pList           = Coll,
				NbParams        = 8 );

    __DBGpr_str( " class_name", class_name);
    if(strcmp(class_name, "VDequipment") &&
	strcmp(class_name, "VREquipment"))
    {
      if( strlen(Coll[0].desc.value.att_txt) == 0 )
      {
	__DBGpr_com( " MINO is Not defined ");
	return OM_E_ABORT;
      }
      if( strlen(Coll[1].desc.value.att_txt) == 0 )
      {
	__DBGpr_com( " Cage is Not Defined ");
	return OM_E_ABORT;
      }
    }
    else
    { 
      if( strlen(Coll[2].desc.value.att_txt) == 0 )
      {
	__DBGpr_com( " n_itemname is Not Defined ");
	return OM_E_ABORT;
      }
    }

     for( i = 0; i < 7; i ++)
     {
       if( !strcmp(Coll[i].name, "mino")){
       strcpy( minoval,  Coll[i].desc.value.att_txt );
       __DBGpr_str( " mino ", Coll[i].desc.value.att_txt);}

       if( !strcmp(Coll[i].name, "cage")){
       strcpy( cageval,  Coll[i].desc.value.att_txt );
       __DBGpr_str( " cageval ", cageval);}

       if( !strcmp(Coll[i].name, "eqp_partno")){
       strcpy( EqpPartNo,  Coll[i].desc.value.att_txt );
       __DBGpr_str( " eqppart_no ", Coll[i].desc.value.att_txt);}

       if( !strcmp(Coll[i].name, "pipe_length")){
          if(Coll[i].desc.value.att_exp != 0.0)
	     incrmnt = Coll[i].desc.value.att_exp;
       __DBGpr_dbl( " length ", Coll[i].desc.value.att_exp);}

       /*
       if( !strcmp(Coll[i].name, "comp_code")){
       strcpy( compcodeval,  Coll[i].desc.value.att_txt );
       __DBGpr_str( " compcodeval ", Coll[i].desc.value.att_txt);}
       */

       if( !strcmp(Coll[i].name, "surface_area")){
         if( Coll[i].desc.value.att_exp != 0.0 )
            //TR #:179801757  only one side area to be sent to SIR 
			incrmnt =  Coll[i].desc.value.att_exp/2.0; 
			
       __DBGpr_dbl( " area ", Coll[i].desc.value.att_exp);}

       if( !strcmp(Coll[i].name, "duct_length")){
         if( Coll[i].desc.value.att_exp != 0.0 )
             incrmnt =  Coll[i].desc.value.att_exp;
       __DBGpr_dbl( " duct length ", Coll[i].desc.value.att_exp);}

       if( !strcmp(Coll[i].name, "memb_cut_leng")){
         if( Coll[i].desc.value.att_exp != 0.0 )
             incrmnt =  Coll[i].desc.value.att_exp;
       __DBGpr_dbl( " beam length ", Coll[i].desc.value.att_exp);}

       if( !strcmp(Coll[i].name, "trans_len")){
         if( Coll[i].desc.value.att_exp != 0.0 )
             incrmnt =  Coll[i].desc.value.att_exp;
       __DBGpr_dbl( " HVAC length ", Coll[i].desc.value.att_exp);}
     }

     //CR#179900380
     if(!strcmp(class_name, "VDequipment") ||
	 !strcmp(class_name, "VREquipment"))
     {
       
       token = strtok(EqpPartNo, "-");
       if(token != NULL)
	 strcpy(cageval, token);

       token = strtok(NULL, "\n");
       if(token != NULL)
	 strcpy(minoval, token);
     }


     /* Convert the cage and mino to upper case */
     for(i=0; i<6; i++)
     {
        cageval[i] = toupper( cageval[i] );
     }

     for(i=0; i<31; i++)
     {
        minoval[i] = toupper( minoval[i] );
     }
     //CR#179900380
     
     if( partcount == NULL )
     {
       partcount = _MALLOC( 1, struct SRPartStat );
       if( partcount == NULL )
       {
	 UI_status( "Error no dynamic memory");
	 return OM_E_NODYNMEM;
       }
       strcpy(partcount[0].cage, cageval);
       strcpy(partcount[0].mino, minoval);
       partcount[0].qty = incrmnt;
       CumPartVar = 1;

     }

     else
     {
       for (i = 0; i < CumPartVar; i++)
       {
         if( (!strcmp( minoval, partcount[i].mino )) && 
		(!strcmp( cageval, partcount[i].cage )) )

	   {
             partcount[i].qty += incrmnt;
	     changePartVar = 1;
	     __DBGpr_dbl( " partcount ", partcount[i].qty);
	     __DBGpr_com( " part variety unchanged "); 
	   }

       }

	if ( changePartVar == 0 )
	{
	  CumPartVar++;
	  partcount = _REALLOC( partcount,
				CumPartVar, struct SRPartStat );
          if( partcount == NULL )
          {
	    UI_status( "Error no dynamic memory");
	    return OM_E_NODYNMEM;
          }

             strcpy( partcount[CumPartVar-1].mino, minoval);
             strcpy( partcount[CumPartVar-1].cage, cageval);
             partcount[CumPartVar-1].qty  = incrmnt;
	     __DBGpr_int( " part variety ", CumPartVar);
	     __DBGpr_dbl( " partcount ", partcount[CumPartVar-1].qty);
			
        }

     }

       for (i = 0; i < CumPartVar; i++)
       {
	     __DBGpr_int( " count ", i);
	     __DBGpr_dbl( " partcount ", partcount[i].qty);
	     __DBGpr_str( " cage ", partcount[i].cage);
	     __DBGpr_str( " mino ", partcount[i].mino);
       }

    wrapup :

    if(Coll)
      _FREE(Coll);

   End
    return OM_S_SUCCESS;

}


int VDpostPart2SIR( IGRlong *msg , FILE *dm2_log)

{
  IGRint	code, dstat;
  IGRchar	*inbuf = NULL;
  IGRint	index = 0, inlen = 0, outlen;
  IGRchar	*outbuf, *errmsg = 0, MdCxId[25];
  OMuword	curOs;
  IGRint	j = 0, CumPart, partindex = 0, partinlen = 0;
  IGRlong	status;
  IGRchar	srerrmsg[200], warn[210];
  IGRint	mfail =0;
  IGRdouble	prtqty;
  IGRint	*nopost=0, *yespost=0;

  SetProc( VDPquerydm2.VDpostPart2SIR ); Begin 

   *msg = MSSUCC;

   UI_status( " Posting Parts to AIM ");

   inbuf = _MALLOC ( 200, char );
   if( inbuf == NULL )
   {
     UI_status ( "No Dynamic memory available" );
     return OM_E_ABORT;
   }

   __DBGpr_int( " part variety ", CumPartVar);

   code = VDP_POST_PART;
   memcpy( &inbuf[index], &code, sizeof(int));
   inlen += sizeof(int);
   index = inlen;
   __DBGpr_int( "Code VDP_POST_PART: ", code );

   ex$get_cur_mod( osnum = &curOs );

   status = VDPGetMdCxId( msg, curOs, MdCxId);
   CheckRC (status, *msg);
   
   strcpy( &inbuf[index], MdCxId );
   inlen += strlen(MdCxId) +1;
   index = inlen;
   __DBGpr_str( " MdCxId ", MdCxId );  

   CumPart = 1;
   memcpy( &inbuf[index], &CumPart, sizeof(int) );
   inlen += sizeof(int);
   index = inlen; 
   partindex = index;
   partinlen = inlen;

   __DBGpr_int( " nbPart ", CumPartVar);

   for( j = 0; j < CumPartVar; j++)
   {
     strcpy( &inbuf[index], partcount[j].mino );
     inlen += strlen(partcount[j].mino) + 1;
     index = inlen;
     __DBGpr_str ( " mino ", partcount[j].mino );

     strcpy( &inbuf[index], partcount[j].cage );
     inlen += strlen(partcount[j].cage) + 1;
     index = inlen;
     __DBGpr_str ( " cage ", partcount[j].cage );

     prtqty = partcount[j].qty;
     memcpy( &inbuf[index], &prtqty, sizeof(double) );
     inlen += sizeof(double);
     index = inlen; 
     __DBGpr_dbl( " qty ", prtqty);

     __DBGpr_int( "Total length of inbuf", inlen );
   

     FILE_PRINT( dm2_log, "CAGE : %s\t\tMINO : %s\t\tQTY : %lf\n", 
				partcount[j].cage, 
				partcount[j].mino, 
				prtqty );

     //SSR 18May
     printf("CAGE : %s\t\tMINO : %s\t\tQTY : %lf\n", 
				partcount[j].cage, 
				partcount[j].mino, 
				prtqty );
     // SSR 11 MAY
     sprintf(warn, "CAGE:%s MINO:%s QTY:%lf", 
				partcount[j].cage, 
				partcount[j].mino, 
				prtqty );

     UI_status(warn);

     dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );

     __DBGpr_int("dstat:", dstat );
     __DBGpr_int("mfail:", mfail );
     if ( mfail )
     {
       status = VDgetSrError( mfail, srerrmsg );
       sprintf(warn,"%s\0", srerrmsg );
       UI_status( warn );
       FILE_PRINT( dm2_log, "\t%s\n", warn );
       printf("\t%s\n", warn );//SSR 18May
       
       nopost = VDaimGetpostno();
       *nopost+=1;
     }

     else if(dstat ) 
     {
	if(dstat == 12345 )
    	{
		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    	}
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	nopost = VDaimGetpostno();
	*nopost+=1;
     }

    else
    {
      yespost = VDaimGetpostyes();
      *yespost+=1;
    }


     index = partindex;
     inlen = partinlen;
     inbuf[index] = '\0';

   }


     _FREE( inbuf );

   if( partcount )
     _FREE( partcount );
 
   partcount = NULL;
   CumPartVar = 0;

   End
    return OM_S_SUCCESS;


}

int VDDelEBOMsir(  )
{
  IGRint	index = 0, inlen = 0, code, dstat, mfail =0, outlen;
  char		*outbuf, *errmsg = 0;
  char		inbuf[100],MdCxId[25] ;
  OMuword	curOs ;
  IGRlong	msg,status; 
    char 		srerrmsg[70];
  
  
  SetProc(VDPquerydm2.VDDelEBOMsir ); Begin 
  
  code = VDP_DELETE_EBOM_REL;
  memcpy( &inbuf[index], &code, sizeof(int) );
  inlen += sizeof(int);
  index = inlen; 
  __DBGpr_int( " code VDP_DELETE_EBOM_REL", code); 
  
  ex$get_cur_mod( osnum = &curOs ); 
  
  status = VDPGetMdCxId( &msg, curOs, MdCxId);
  
  CheckRC (status, msg); 
  
  strcpy( &inbuf[index], MdCxId );
  inlen += strlen(MdCxId) +1;
  index = inlen;
  __DBGpr_str( " MdCxId ", MdCxId);

  __DBGpr_int( "Total length of inbuf", inlen );

  UI_status(" Deleting EBOM relations in AIM");

  dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
      inbuf,
      &outlen,
      &outbuf,
      &mfail,
      &errmsg );


  if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        return 0;
    }


  __DBGpr_int("dstat:", dstat );
  __DBGpr_int("mfail:", mfail );
  __DBGpr_str("errmsg:", errmsg ); 

  End
  return OM_S_SUCCESS;


}


int VDgetSrError( int mfail, char *srerrmsg )
{
   int 		i; 
   
   for ( i = 0; i  < nberr; i++ )
   {
     if ( mfail == VdSrErrMsg[i].mfail )
     {
       strcpy(srerrmsg, VdSrErrMsg[i].errmsg);
       return OM_S_SUCCESS;

     }
   }

   strcpy( srerrmsg, " Some error occured while posting. contact AIM administrator");
   return OM_S_SUCCESS;

}


/* a function to find out whether a ISDP file is revised after last posting */

int SrDetectFileRev( FILE *dm2_log)
{
  OMuword	curOs;
  char		DirName[DI_PATH_MAX], CollName[DI_PATH_MAX], inbuf[50],
  		mdcobid[25], catalog[30], partid[30], revision[30], temp[25],
		ParentName[DI_PATH_MAX];
  struct GRid	CollId, DirId, EnabListId, trTblId;
  long		msg, status = OM_S_SUCCESS;
  struct ACrg_coll  modcoll;
  struct ACrg_coll modcollnew[50];
  int		code = 0, index=0, inlen=0, outlen=0, mfail, dstat, status1;
  char		*outbuf, *errmsg = 0, *filerev=NULL, *revmdcobid=NULL, *predmdcobid=NULL, *predcatalog=NULL, *predpartid=NULL, *predrevision=NULL;
  char  oldRev[15],ARsel[2], CMmng[2], DCCsel[2], Mdc[5], IsSuper[20];

  char     rev_catalog[40], rev_partid[40], rev_revision[40];
  
  char     IsMDCExists[5], IsCollExists[5], IsAIMMdcExists[5];
  char     curdir[DI_PATH_MAX];
  char 	   NewMdcRev[10];
  char	   searchst[512];
  char     **bufst;
  long     stat = 0;
  int	   num = 0;
  char     CtxType[20], CtxName[20],CtxID[25]; /* TLS 04-24-02 TR6236 - increased the buffer size */
  struct ACrg_coll  coll;
  char     MdcRev[15], CtxRev[15];
  DIchar   dir_name[DI_PATH_MAX];

  SetProc(VDPquerydm2.SrDetectFileRev); Begin 
  
  /* get default data collector*/
  ex$get_cur_mod( osnum = &curOs );

  status = VDPValidatePartInfo(refresh->act_catalog, refresh->act_partid,
                               refresh->act_revision, &IsMDCExists, 
			       &IsCollExists, &IsAIMMdcExists);
  //Added by Anjani, 19sept2000
  //To add the existing parts info to sirpdmtable
   searchst[0] = '\0';
  sprintf(searchst, "pdu_catalog = '%s' and pdu_part = '%s' and pdu_revision = '%s'", refresh->act_catalog, refresh->act_partid, refresh->act_revision); 

 __DBGpr_str("Searchst is", searchst);
   stat =
	vdb$RisSelect(select="mdc_rev,ctx_rev,ctx_name,ctx_type",
 			table_name = "SIR_PDM_TABLE", 
			where = searchst,
			numselect = 4,
			p_numrows = &num,
			p_buffer = &bufst);
        //printf("no. of rows found = %d\n", num);
	vdb$RisFreeBuffer( buffer = bufst, size = 2 * num );	
	if(num == 0)
	  status = PDMInsertSirTable(refresh->act_catalog,refresh->act_partid, refresh->act_revision);
  
  /*  Check If the Selected Part is a Bad Part  */
  
  if( !strcmp(IsMDCExists,"Y") && !strcmp(IsCollExists,"N") && 
     !strcmp(IsAIMMdcExists,"Y") )
  {
   status = VDPReconnectDAD();
   goto wrapup;
  }
  
  if(!strcmp(IsCollExists, "Y"))
  status = VDPGetMdCxId ( &msg, curOs, mdcobid );
  __DBGpr_str( "mdcobid", mdcobid );
  status = SrVDGetCMattrs(refresh->act_catalog, refresh->act_partid,
                       refresh->act_revision,
                       ARsel, CMmng, DCCsel, Mdc, IsSuper);
  code = VDP_GET_CUR_REV;
  status1 = VDPGetPartInfoGivenMDC(code, mdcobid, &rev_catalog, &rev_partid, 
                                   &rev_revision);

  __DBGpr_str( "refresh->act_catalog", refresh->act_catalog );
  __DBGpr_str( "refresh->act_partid", refresh->act_partid );
  __DBGpr_str( "rev_catalog", rev_catalog );
  __DBGpr_str( "rev_partid", rev_partid );

if( !strcmp(refresh->act_catalog, rev_catalog) && !strcmp(refresh->act_partid, 
                                                          rev_partid) )  
 {
  //Added by Anjani, 19sept2000
  //To add the existing parts info to sirpdmtable
  if(num == 0)
  {
    status = di$give_pathname( osnum = curOs, pathname = DirName );
     __CheckRC( status, 1,"di$give_pathname", wrapup );
     __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
    __DBGpr_obj ( "Collector Id ", CollId );
      
    strcpy( coll.name, SIR_CNTX_NAME );
    status = _VD_SEND_OBJN(CollId, ACrg_collect.ACget_named_attribute(&msg,&coll));
    CtxName[0]='\0';
    strcpy( CtxName, coll.desc.value.att_txt); 
    __DBGpr_str( "CtxName", CtxName );

    strcpy( coll.name, SIR_CNTX_TYP );
    status = _VD_SEND_OBJN(CollId, ACrg_collect.ACget_named_attribute(&msg,&coll));
    CtxType[0]='\0';
    strcpy( CtxType, coll.desc.value.att_txt);
    __DBGpr_str( "CtxType", CtxType );
    
    strcpy( coll.name, SIR_CNTX_ID );
    status = _VD_SEND_OBJN(CollId, ACrg_collect.ACget_named_attribute(&msg,&coll));
    CtxID[0]='\0';
    strcpy( CtxID, coll.desc.value.att_txt);
    __DBGpr_str( "CtxID", CtxID );

    code = VDP_GET_REV;
    MdcRev[0]='\0';
    CtxRev[0]='\0';
    status1 = VDPGetRevFromOBID(code, mdcobid, &MdcRev); 
    status1 = VDPGetRevFromOBID(code, CtxID, &CtxRev); 
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid, refresh->act_revision, "ctx_type", CtxType);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid, refresh->act_revision, "ctx_name", CtxName);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid, refresh->act_revision, "ctx_rev", CtxRev);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid, refresh->act_revision, "mdc_rev", MdcRev);
  }
  
    if(!strcmp(CMmng, "Y"))
    {
    /*Revision will be done from NFM via Copy Similar for CM enabled files
     * so go and just get mdcobid to update collector */
    __DBGpr_com("File is CM managed.");
    code = VDP_GET_MDCOBID;
    UI_status("Getting Revised MDC obid from AIM.");
    status = SrVDBaseRevise( code, mdcobid, &revmdcobid, NULL );
    if( status != OM_S_SUCCESS )
     {
      __DBGpr_com( " failed to get Revise MDCobid");
      UI_status("Failed to Get M D C obid.");
      goto wrapup;
     }
   }
   else
   {
    /* get the revision of this mdcobid from sir */
    __DBGpr_com("File is not CM managed.");

    /*get the actual file revision */
    if( refresh->act_revision[0] != '\0' )
    __DBGpr_str( "act_revision", refresh->act_revision );
     
     /*compare ISDP filerev and SIR filerev */
    if(!strcmp(refresh->act_revision, rev_revision))
    {
      __DBGpr_com("Revisions are same, no need to update collector.");
      goto wrapup;
    }
    /* revisions not same, revise mdc in SIR 
     * and get the new revised mdc obid*/
    __DBGpr_com("Revisions are not same");

    // TLS - 1st check to see if the MDC has already been revised in AIM
    code = VDP_GET_MDCOBID;
    UI_status("Getting Revised MDC obid from AIM.");
    status = SrVDBaseRevise( code, mdcobid, &revmdcobid, NULL );
    if( status != OM_S_SUCCESS )
    {
      __DBGpr_com( "No MDC exist for current file so revise it");
      UI_status("No MDC exist - Revising MDC");

      code = VDP_REVISION; 
      NewMdcRev[0]='\0';
      status = SrVDBaseRevise( code, mdcobid, &revmdcobid, &NewMdcRev );
      if( status != OM_S_SUCCESS )
      {
        __DBGpr_com( " failed in Revise ");
        UI_status("Failed to Revise M D C");
        goto wrapup;
      }
      FILE_PRINT ( dm2_log,
       "\nThis ISDP file was revised after previous posting; So MDC revised." );

  
      if(strlen(NewMdcRev) == 0)
      {
         printf("Error in getting revision of new Mdc\n");
      }

     status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid, refresh->act_revision, "mdc_rev", NewMdcRev);
    }
    else
    {
      //TLS - 03/26/01 - Make sure the SIR_PDM_TABLE is up to date

      code = VDP_GET_REV;
      MdcRev[0]='\0';
      status1 = VDPGetRevFromOBID(code, revmdcobid, &MdcRev); 
      status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid, refresh->act_revision, "mdc_rev", MdcRev);
    }

  }
   
    if(strlen(revmdcobid) == 0) 
    {
       printf("No obid of new Revised MDC\n");
       goto wrapup;
    }
    
     /* store the new mdcobid in default data collector */
     //modcoll = _MALLOC(1, struct ACrg_coll);
     strcpy( modcoll.name,SIR_MODCX_ID );
     modcoll.desc.type = AC_ATTRIB_TEXT;
     strcpy( modcoll.desc.value.att_txt, revmdcobid );
     __DBGpr_str( " mod mdcobid val", revmdcobid );

     status = di$give_pathname( osnum = curOs, pathname = DirName );
     __CheckRC( status, 1,"di$give_pathname", wrapup );
     __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
    __DBGpr_obj ( "Collector Id ", CollId );

    UI_status("Storing Revised MDC information in D A D.");
    status = om$send(msg = message ACrg_collect.ACmod_list_attribute(&msg,
	  		1, &modcoll),
		senderid = NULL_OBJID, 
		targetid = CollId.objid,
		targetos = CollId.osnum );
    
    __CheckRC( status, msg, "Failed modifying active collector", wrapup );
    FILE_PRINT ( dm2_log, "\nNew M D C obid <%s>", revmdcobid );
    __DBGpr_com( "Default data collector updated with new M D C obid ");

   }

/*  If the Part is Entirely New */
   else
   { 
      UI_status("It is Entirely a New Part");

      status = di$give_pathname( osnum = curOs, pathname = DirName );
     __CheckRC( status, 1,"di$give_pathname", wrapup );
     __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
     sprintf( ParentName,"%s%s", DirName, SIR_GLOBAL_DIR);
    __DBGpr_str( "Collector name", CollName );

       status = VDPGetTrTblId ( msg, &trTblId );
       CheckRC(status,1);
    /*   removing TransList ID    */
       
      if(trTblId.objid != NULL_OBJID)
           _VD_SEND_OBJN(trTblId, Root.delete(1));

	status = VDPGetEnabledListId ( msg, curOs, &EnabListId );
        CheckRC(status,1); 
    /*  removing EnableList ID  */
	
      if(EnabListId.objid != NULL_OBJID)
           _VD_SEND_OBJN(EnabListId, Root.delete(1));

      status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
    __DBGpr_obj ( "Collector Id ", CollId );
     /* removing Collector ID  */
      
      if(CollId.objid != NULL_OBJID)
      { 
         status = di$untranslate(       osnum = CollId.osnum,
                                        objid = CollId.objid,
	    			        objname = dir_name    );
         if(status != DIR_S_SUCCESS)
          {
           di$report_error(sts=status);
           printf("Failed to untranslate %s\n", dir_name);
          }
   
           _VD_SEND_OBJN(CollId, Root.delete(1)); 
      }

         status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
       __DBGpr_obj ( "Collector Id after deletion ", CollId );

        status = di$cd(dirname = ParentName);
        if(status != DIR_S_SUCCESS)
         {
          di$report_error(sts=status);
           printf("Failed to change to directory %s\n", ParentName);
         }

    status = di$untranslate(       osnum = CollId.osnum,
                                   objid = CollId.objid,
				   objname = dir_name    );
    
      status = di$rm_name(           regexp = dir_name  );

    if(status != DIR_S_SUCCESS)
      {
        di$report_error(sts=status);
        printf("Failed to remove directory %s\n", dir_name);
      }

	UI_status("Resetting UID on Placements ...");

	status = VDPResetUid(&msg);
	CheckRC(status, 1);

	UI_status("UID is reset on Placements");

   }


wrapup:
   status = OM_S_SUCCESS;
  //if(modcoll) _FREE(modcoll);
  End

  return status;

}


/* new function to talk with SIR.
 * this gets the current MDC revision, baselines a MDC, Revisese aMDC
 * OR baseline and ewvise a MDC
 * */
int SrVDBaseRevise( int code, char *obid, char **value, char *MdcRev)
{

  int 	index=0, inlen=0, dstat, mfail, outlen, i, nbItems =0;
  char 	inbuf[100], srerrmsg[70];
  char	*outbuf=NULL, *errmsg = NULL;
  char LpdDesc[50];
  static char LpdtempDesc[2];
  static char LpdValue[1];
  static char *lpdvalue[12];
  int count1=0, count2=0;
  int number=0, j=0;
  long	status = OM_S_SUCCESS;

  SetProc(VDPquerydm2.SrVDBaseRevise); Begin 

  /* TLS TR#  03/22/01 
   *     Added to make sure the HA is set to the correct File App for revised MDCs
   */

    
    __DBGpr_str( " Catalog ", refresh->act_catalog );
    __DBGpr_str( " Part ID ", refresh->act_partid );
    __DBGpr_str( " Revision ", refresh->act_revision );

    status = PDMReadHullApp(refresh->act_catalog, refresh->act_partid,
                         refresh->act_revision, lpdvalue);

    if(status == 1)
    {
       EX_error_box( FI_CURRENT_SCREEN,
                   "Hull Applicability is not set properly",
                                   "Contact Administrator");
       return OM_S_SUCCESS;
    }


    LpdtempDesc[0] = '\0';
    LpdDesc[0] = '\0';

    for(i=0;i<=11;i++)
    {
      LpdValue[0] = '\0';
      strncpy(LpdValue, lpdvalue[i], 1);

      if(!strcmp(LpdValue,""))
      {
         count2 = count2 + 1;
      }

      if(count2)
       {
          EX_error_box( FI_CURRENT_SCREEN, "Hull Applicability is not set properly",
                                       "Contact Administrator");
          return OM_S_SUCCESS;
       }

      if(!strcmp(LpdValue,"Y"))
      {

         number  = number + 1;
          sprintf(LpdtempDesc,"%d",j+17);

          if(number>1)
          {
            strcat(LpdDesc, ",");
          }
            strcat(LpdDesc, LpdtempDesc);
          if(!strcmp(LpdtempDesc, "28"))
             strcat(LpdDesc, "AF");

          //printf("File Applicability is %s\n", LpdDesc);

      }

     if(!strcmp(LpdValue,"N"))
     {
        count1 = count1 + 1;
     }


     if(count1 == 12)
     {
        EX_error_box( FI_CURRENT_SCREEN,
                       "Hull Applicability is not set properly",
                       "Contact Administrator");
        return OM_S_SUCCESS;
     }

     j++;
   }
  
   //printf("File Applicability is %s\n", LpdDesc);
   __DBGpr_str( " File Applicability ", LpdDesc );

  i = 0;
  inbuf[0] = '\0';

  switch( code )
  {
   case VDP_BASELINE:
       /* this will trigger a baseline MDC in SIR 
	* buffer is code-Cat-Part-Rev
	* No buffer from SIR*/
       memcpy( &inbuf[index], &code, sizeof(int));
       inlen += sizeof(int);
       index = inlen;
       __DBGpr_int( " VDP_BASELINE Code ", code ); 
       
       /*
       *strcpy( &inbuf[index], obid );
       *inlen = inlen + strlen( obid ) +1;
       *index = inlen; 
       * send cat-part-rev instead of mdcobid
       */

       strcpy( &inbuf[index], refresh->act_catalog );
       inlen = inlen + strlen( refresh->act_catalog ) +1;
       index = inlen; 
       __DBGpr_str( " Catalog ", refresh->act_catalog );
       
       strcpy( &inbuf[index], refresh->act_partid );
       inlen = inlen + strlen( refresh->act_partid ) +1;
       index = inlen; 
       __DBGpr_str( " Part ", refresh->act_partid );
       
       strcpy( &inbuf[index], obid );
       inlen = inlen + strlen( obid ) +1;
       index = inlen; 
       __DBGpr_str( " Revision ", obid );
       
       break;

   case VDP_REVISION:
       /* revise MDC in SIR 
	* buffer is code-mdcobid
	* sir send back new mdcobid*/
       memcpy( &inbuf[index], &code, sizeof(int));
       inlen += sizeof(int);
       index = inlen; 
       __DBGpr_int( " VDP_REVISION Code ", code ); 
       
       strcpy( &inbuf[index], obid );
       inlen = inlen + strlen( obid ) +1;
       index = inlen; 
       __DBGpr_str(" MdcObid ", obid );
       
       strcpy( &inbuf[index], refresh->act_revision );
       inlen = inlen + strlen( refresh->act_revision ) +1;
       index = inlen; 
       __DBGpr_str( " Revision ", refresh->act_revision );

       strcpy( &inbuf[index], refresh->act_description );
       inlen = inlen + strlen( refresh->act_description ) +1;
       index = inlen; 
       __DBGpr_str( " Description ", refresh->act_description );
       
       /* TLS Added for TR#   */
       strcpy( &inbuf[index], LpdDesc );
       inlen = inlen + strlen( LpdDesc ) +1;
       index = inlen; 
       __DBGpr_str( " File App  ", LpdDesc );
       //printf("File Applicability is %s\n", LpdDesc);

       break;

   //TLS - this is not being called ... 3/22/01
   case VDP_BASE_REVISE:
       /* this case will baseline and revise a MDC in SIR
	* buffer is prepared with code-mdcobid-currev
	* sir send back new mdcobid*/
       memcpy( &inbuf[index], &code, sizeof(int));
       inlen += sizeof(int);
       index = inlen;
       __DBGpr_int( " VDP_BASE_REVISE Code ", code ); 

       strcpy( &inbuf[index], obid );
       inlen = inlen + strlen( obid ) +1;
       index = inlen; 
       __DBGpr_str(" MdcObid ", obid );
       
       break;

   case VDP_GET_MDCOBID:
       /* Gicen a catalog part rev get the MDC obid from AIM */
       memcpy( &inbuf[index], &code, sizeof(int));
       inlen += sizeof(int);
       index = inlen;
       __DBGpr_int( "VDP_GET_MDCOBID Code ", code );

       strcpy( &inbuf[index], refresh->act_catalog );
       inlen = inlen + strlen( refresh->act_catalog ) +1;
       index = inlen; 
       __DBGpr_str( " Catalog ", refresh->act_catalog );
       
       strcpy( &inbuf[index], refresh->act_partid );
       inlen = inlen + strlen( refresh->act_partid ) +1;
       index = inlen; 
       __DBGpr_str( " Part ", refresh->act_partid );
       
       strcpy( &inbuf[index], refresh->act_revision );
       inlen = inlen + strlen( refresh->act_revision ) +1;
       index = inlen; 
       __DBGpr_str( "Rev ", refresh->act_revision );

       break;

   default:
       return OM_E_ABORT;
  }
       dstat = 0;
       mfail = 0;
       dstat = POSTMAN_REQUEST_ON_CLIX(   inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
       //printf("dstat =  %d\n", dstat);
       //printf("mfail =  %d\n", mfail);
       if( (dstat != 0) || (mfail != 0) )
       {
         if (mfail == 47 )
	   errmsg="NO MDC EXIST";
         else
         {
	   if(dstat == 12345 )
    	   {
		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
	 	return OM_E_ABORT;
           }
	   if(!errmsg || (errmsg && !errmsg[0]))
	     errmsg="No error msg but should be";
	   if ( strlen(errmsg ) > 63 )
	     errmsg[63] = '\0';
         }
	 UI_status( errmsg );

	 return OM_E_ABORT;
       } 
       
       if(outlen == 0) goto wrapup;

       index =0;
       /* get the number from buffer */
       memcpy( &nbItems, &outbuf[index], sizeof(int) );
       index = index + sizeof(int);
       /* outbuff will be NULL in case of baseline mdc
	* revise mdc and revise-baseline will get the modified mdcobid from
	* SIR
	* get currentt rev will get me the revision. */
       
       if(outbuf[0]!='\0')
       {
       
         __DBGpr_com("Allocating memory for Revision");
         __DBGpr_int("length", strlen(&outbuf[index]));

         *value = _MALLOC(strlen(&outbuf[index]), char);
	 if(*value) strcpy(*value, &outbuf[index] );
	 index = index + strlen(*value) + 1;

	 __DBGpr_str( " Rev from SIR ", *value);

	 if(MdcRev != NULL)
	 { 
            strcpy(MdcRev, &outbuf[index] );
	    index = index + strlen(MdcRev) + 1;
	    __DBGpr_str( " RevAttr from SIR ", MdcRev);
	 }

	// TLS - 03/26/01 - Need to reset status.  It was causing the
	// 		    the system to think there was an error.
        status = OM_S_SUCCESS;

       }

wrapup:
     
       End
       return status;
}

/* Function to update the MDC PLacement relations ship in AIM
* this can happen if the reference files get changed */

IGRint VDPUpdatePlacMdcReln( char *PlacUID, char *RefMdc )
{
  long status = OM_S_SUCCESS, msg;
  OMuword curOs;
  int 	index=0, inlen=0, dstat, mfail, outlen, code, i;
  char 	inbuf[50], Mdcobid[25];
  char	*outbuf, *errmsg = 0;
    char 		srerrmsg[70];
 
  SetProc(Vdpquerydm2.I. VDPUpdatePlacMdcReln ); Begin

  code = VDP_UPDATE_PLAC_MDC_RELN;

  __DBGpr_int("VDP_UPDATE_PLAC_MDC_RELN code", code );

  /* Get Current osnum*/
  ex$get_cur_mod( osnum = &curOs );

  /*Get Active File MDCOBID */
status = VDPGetMdCxId ( &msg, curOs, Mdcobid );
  __CheckRC( status, msg, "VDPGetMdCxId", wrapup);
  __DBGpr_str( "mdcobid", Mdcobid );

  /* Write the code into buffer */
   memcpy( &inbuf[index], &code, sizeof(int));
   inlen += sizeof(int);
   index = inlen;

   strcpy( &inbuf[index], Mdcobid );
   inlen = inlen + strlen( Mdcobid ) +1;
   index = inlen; 
       
   strcpy( &inbuf[index], PlacUID );
   inlen = inlen + strlen( PlacUID ) +1;
   index = inlen; 
       
   strcpy( &inbuf[index], RefMdc );
   inlen = inlen + strlen( RefMdc ) +1;
   index = inlen; 
       
   dstat = POSTMAN_REQUEST_ON_CLIX(   inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
   
   if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        status = mfail;
    }
    if(mfail != 0) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
	if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
        status = mfail;
    }

  wrapup:
    End
    return status;
}

/* read the MDCOBID of the given reference file from directory dtructure */

IGRint VDPGetMdcobidFromRefPart( char *RefFile , char **MdcObid)
{
  long status = OM_S_SUCCESS;
  OMuword              curOs;
  struct GRid          DirId, CollId;
  struct ACrg_coll     coll;
  IGRchar              DirName[DI_PATH_MAX], CollName[DI_PATH_MAX]; 
                       
  IGRchar	       RefMdcObid[25];		
  long msg;

  SetProc(VDPGetMdcobidFromRefPart); Begin

  ex$get_cur_mod( osnum = &curOs );

  /* get directory path name */
  status = di$give_pathname(  osnum           = curOs,
                                 pathname        = DirName );
  __CheckRC( status, 1, "di$give_pathname", wrapup );
  __DBGpr_str( "Path name", DirName );

  strcat(DirName, ":ref:");
  strcat(DirName, RefFile);
  strcat( DirName, SIR_GLOBAL_DIR );
  __DBGpr_str( "Path name", DirName );

  status = di$translate ( objname = DirName,
           p_objid = &DirId.objid,
           p_osnum = &DirId.osnum );

  if ( status != DIR_S_SUCCESS )
  {
    status = OM_E_ERROR;
    goto wrapup;
  }

  sprintf( CollName, "%s%s", DirName, SIR_REQ_DATA );
  __DBGpr_str( "Collector name", CollName );

  status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
  __DBGpr_obj( " Collector Id ", CollId );
  //coll = _MALLOC(1, struct ACrg_coll);
  strcpy( coll.name, SIR_MODCX_ID );
  status = _VD_SEND_OBJN(CollId, ACrg_collect.ACget_named_attribute(&msg,&coll));
  __CheckRC(status, msg, "Failed to get MDCOBID", wrapup);
  strcpy(RefMdcObid, coll.desc.value.att_txt);
  __DBGpr_str("The reference file mdcobid is", RefMdcObid);
  if(strlen(RefMdcObid))
  {
    *MdcObid = _MALLOC(strlen(RefMdcObid), char);
    strcpy(*MdcObid, RefMdcObid); 
    __DBGpr_str("mdcobid of ref files", *MdcObid);
  }

  wrapup:
    //if(coll) _FREE(coll);
    End
    return status;
}


/* VDPSetUid()
 * Creates and returns UID 
 * part-seqno
 * changed to file_key-seqno per JTS MP CR 5522, SAUBY 10/24/01
 * part is pdm part name seq no is stored in default data collector
 * after using current seqno increment it and write back into default
 * collector.
 *
 * */
IGRint  VDPSetUid(IGRchar **srobid )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRchar		DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
    IGRchar		GenUid[30];
    struct GRid		SrSeqCollId;
    struct ACrg_coll      SrSeqcoll;
    OMuword		curOs;
    int			SeqNo=0;
    long			msg; 

    TVDpdmInfo          pdmInfo;

    SetProc(VDPquerydm2.I.VDPSetUid); Begin
    ex$get_cur_mod( osnum = &curOs );

    /* Get default data collector id */
    status = di$give_pathname(  osnum           = curOs,
	    pathname        = DirName );
    __DBGpr_str( "Path name", DirName ); 

    sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
    __DBGpr_str( "Collector name", CollName ); 

    status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &SrSeqCollId );
    CheckRC( status, msg );

    if (SrSeqCollId.objid == NULL_OBJID )
    {
	UI_status("SIR Required Data not set");
	status = OM_E_ABORT;
	goto wrapup;
    }
    __DBGpr_obj ( "Collector Id ", SrSeqCollId ); 

    /* Get Sequence Number from the DAD Collector */
    //SrSeqcoll = _MALLOC(1, struct ACrg_coll);
    strcpy( SrSeqcoll.name, SIR_SEQ_NO );
    status = _VD_SEND_OBJN( SrSeqCollId, 
	    ACrg_collect.ACget_named_attribute( &msg, &SrSeqcoll ));
    if( msg == FALSE )
    {
	// SIR_SEQ_NO not exists, old file
	printf("\n Can not set UID. This file is not supported!");
	goto wrapup;
    }
    __DBGpr_str( "SIR_SEQ_ID", SrSeqcoll.desc.value.att_txt ); 

    /* Create the UID for the given Placement object */
    // SAUBY, JTS MP CR 5522, srobid is to be generated using file_key-seq no
    // get pdmInfo for curOS
    vdpdm$GetPdmInfo(osnum = curOs, pdmInfo = &pdmInfo);
    if (pdmInfo.filekey < 1) 
    {
	//TLS - 02-13-02 - TR#6016 Added this print statement and set the
        //		           status to bad so we know that we couldn't
	//			   get a filekey. 
	__DBGpr_com ("WE DO NOT HAVE A FILEKEY...");
        UI_status( "Failed to get Filekey...");
	status = OM_E_ABORT;
	goto wrapup;
    }
    
    __DBGpr_int ("The Filekey is", pdmInfo.filekey); 

    //strcpy(GenUid, refresh->act_partid);
    sprintf(GenUid,"%d",pdmInfo.filekey);
    strcat(GenUid, "-");
    strcat(GenUid, SrSeqcoll.desc.value.att_txt);
    strcat(GenUid,"-1");  // It is possible for filekey to = partno for legacy data.
                          // the -1 was added as a further prevention of duplicates.
			  // This can be changed at will if required later.  SAUBY 10/29/01
    __DBGpr_str ("The UID is", GenUid ); 

    /* Increment the seq no and write back to collector */
    SeqNo = atoi(SrSeqcoll.desc.value.att_txt);
    SeqNo=SeqNo+1;
    sprintf(SrSeqcoll.desc.value.att_txt, "%d" , SeqNo); 
    status = _VD_SEND_OBJN( SrSeqCollId, 
	    ACrg_collect.ACmod_list_attribute( &msg, 1, &SrSeqcoll ));
    __CheckRC(status, msg, "ACmod_list_attribute", wrapup );
    __DBGpr_str( "SIR_SEQ_ID", SrSeqcoll.desc.value.att_txt ); 

    //if(*srobid) _FREE(*srobid);
    *srobid = _MALLOC(strlen(GenUid) + 1, char);
    strcpy(*srobid, GenUid);
    //printf ("The UID is %s and copied to %s\n", GenUid, *srobid );

wrapup:
    //if(SrSeqcoll) _FREE(SrSeqcoll); 
    End
    return status;
}

/* VDPGetPdmRevFormRefFile()
 * Given a file name and part get its revision
 * This is the revision of attached part.
 * Probably not used any where. SSR 27Aug
 * */
int VDPGetPdmRevFormRefFile(char *PdmPart, char *RefFile, IGRchar **RefRev)
{

  IGRlong             status = OM_S_SUCCESS;
  IGRchar RefCat[128];
  IGRchar RefPart[128];
  IGRchar Rev[128];
  IGRchar RefFileName[128];

  SetProc(VDPquerydm2.I.VDPGetPdmRevFormRefFile);Begin
  RefCat[0]='\0';
  RefPart[0]='\0';
  Rev[0]='\0';

/* Get Reference File PDM Information */
  strcpy(RefFileName, RefFile);
  status = PDMGetPartInfoGivenFileName( RefFileName, RefCat, RefPart, Rev);

  if((strlen(RefCat)!=0)&&(strlen(RefPart)!=0)&&(strlen(Rev)!=0))
    printf("The values are %s, %s, %s \n", RefCat, RefPart, Rev);

  else
    __DBGpr_com("Failed to get ref pdm values");
/* Compare PdmPart value of the Reference file */
  if(strcmp(PdmPart, RefPart))
  {
    __DBGpr_str("RefPart is", RefPart);
    return 0;
  }
  
  //if(*RefRev) _FREE(*RefRev);
  *RefRev = _MALLOC(strlen(Rev), char); 
  strcpy(*RefRev, Rev);
  

  wrapup:
    End
    return 1;

}

/* VDPWriteDiagramList()
 * Read the global structture and write back into the directory system
 * global structure has the attached part info and MDCobid.
 * This is done at the end of posting process.
 * */
int VDPWriteDiagramList()
{

  long            msg, status = OM_S_SUCCESS;
  struct GRid     CollId, DirId;
  OMuword         curOs;
  char            DirName[DI_PATH_MAX], TmpDirName[DI_PATH_MAX],
                  CollName[DI_PATH_MAX]; 
  struct ACrg_coll coll, *RefColl;
  struct SIRRefInfo *SIR_Diag_Info = NULL;
  int nbRefSize=0, nbRefNo=0, i=0, nbDiagFiles=0;
  int GRefSize;

  SetProc(VDPquerydm2.I.VDPWriteDiagramList);Begin

  SIR_Diag_Info = (struct SIRRefInfo *)VDGetDiagInfo(); 
  GRefSize=VDgetRefSize();
	//Get the current osnum
  ex$get_cur_mod( osnum = &curOs );
  status = di$give_pathname( osnum = curOs,
      pathname   = DirName );
  __CheckRC( status, 1, "di$give_pathname", wrapup );
  __DBGpr_str( "Path name", DirName );
  strcat( DirName, SIR_GLOBAL_DIR );
  strcat( DirName, SIR_DIAG_LST );
	
  status = di$translate ( objname = DirName,
		p_objid = &DirId.objid,
		p_osnum = &DirId.osnum ) ;
  __DBGpr_obj( "Dir Id", DirId );
	
  if ( status != DIR_S_SUCCESS )
    goto    wrapup;
	
  strcpy(TmpDirName, DirName);
	
  __DBGpr_int("The Global Reference file size is", GRefSize);
  if(GRefSize == 0 )
  {
    __DBGpr_com("\n No Reference Attached.");
    goto step1;
  }

  for(nbDiagFiles = 0; nbDiagFiles<GRefSize; nbDiagFiles++ )
  {
    __DBGpr_str("2.SID_DIAG_INFO.PART %s", SIR_Diag_Info[nbDiagFiles].PdmPart );
    __DBGpr_str("2.SID_DIAG_INFO.REV %s", SIR_Diag_Info[nbDiagFiles].PdmRev );
    __DBGpr_str("2.SID_DIAG_INFO.MDCID %s", SIR_Diag_Info[nbDiagFiles].Mdcobid );
    __DBGpr_str("2.SID_DIAG_INFO.UPDREV %s", SIR_Diag_Info[nbDiagFiles].UpdRev );
    __DBGpr_str("2.SID_DIAG_INFO.UpdMDCID %s", SIR_Diag_Info[nbDiagFiles].UpdMdcobid );
    __DBGpr_int("SID_DIAG_INFO.UpdFlag %d", SIR_Diag_Info[nbDiagFiles].UpdFlag);
  }
  /* Write Each Reference file info into collector */
	
  for(nbRefNo = 0; nbRefNo<GRefSize; nbRefNo++ )
  {
    sprintf( CollName, "%s:File%d", TmpDirName, nbRefNo );
    __DBGpr_str( "Collector name", CollName );
	
    status = VDgetVdCollId ( &msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj( " Collector Id ", CollId );
	
    RefColl = _MALLOC ( 3, struct ACrg_coll );
    /* set up the coll values for SIR_REF_PART */
    strcpy( RefColl[0].name, SIR_REF_PART );
    RefColl[0].desc.type = AC_ATTRIB_TEXT;
    strcpy( RefColl[0].desc.value.att_txt, SIR_Diag_Info[nbRefNo].PdmPart );
		
    /* set up the coll values for SIR_REF_REV */
    strcpy( RefColl[1].name, SIR_REF_REV );
    RefColl[1].desc.type = AC_ATTRIB_TEXT;
    if(SIR_Diag_Info[nbRefNo].UpdFlag == 1)
      strcpy( RefColl[1].desc.value.att_txt, SIR_Diag_Info[nbRefNo].UpdRev );
    if(SIR_Diag_Info[nbRefNo].UpdFlag == 0)
      strcpy( RefColl[1].desc.value.att_txt, SIR_Diag_Info[nbRefNo].PdmRev );
		
    /* set up the coll values for SIR_REF_MDC */
    strcpy( RefColl[2].name, SIR_REF_MDC );
    RefColl[2].desc.type = AC_ATTRIB_TEXT;
    if(SIR_Diag_Info[nbRefNo].UpdFlag == 0)
      strcpy( RefColl[2].desc.value.att_txt, SIR_Diag_Info[nbRefNo].Mdcobid );
    if(SIR_Diag_Info[nbRefNo].UpdFlag == 1)
      strcpy( RefColl[2].desc.value.att_txt, SIR_Diag_Info[nbRefNo].UpdMdcobid );
		
    status = _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
			&msg,
			3,
			RefColl ) );
    __CheckRC( status, msg, "Failed to Write", wrapup );
		
  }//End of for loop

 step1:
  /* Write Ref File Size in the collector */
  //coll = _MALLOC ( 1, struct ACrg_coll );

  CollName[0] = '\0';
  sprintf( CollName, "%s:Files", DirName );
  __DBGpr_str( "Collector name", CollName );

  status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
  __DBGpr_obj( " Collector Id ", CollId );

  /* set up the coll values for SIR_REF_PART */
  strcpy( coll.name, SIR_REF_SIZE );
  coll.desc.type = AC_ATTRIB_DOUBLE;
  coll.desc.value.att_exp =  GRefSize;

  status = _VD_SEND_OBJN( CollId, ACrg_collect.ACmod_list_attribute(
                                    &msg,
                                    1,
                                    &coll ) );
  __CheckRC( status, msg, "Failed to modify size", wrapup );
  __DBGpr_int("The Size written in the collectore is", nbRefNo);

wrapup:
 //if(RefColl) _FREE(RefColl);
 //if(coll) _FREE(coll);
End
return status;

}

/* VDPValidatePartInfo()
 * This function is used to have the information about the following three
 * variables:
 * (1) IsMDCExists     :   	 Whether an MDC Exists in ISDP
 * (2) IsCollExists    :	 Whether a Collector Exists in ISDP
 * (3) IsAIMMDCExists  :	 Whether an MDC Exists in AIM
 *  Input              :         Catalog, Part, Revision
*/

int VDPValidatePartInfo(char *catalog, char *partid, char *revision, 
                        char *IsMDCExists, char *IsCollExists, 
			char *IsAIMMDCExists )
{
int              code = 0, num, stat_ris=0;
char             mdcobid[25], *revmdcobid=NULL, IsModlDCExists[5], 
                 p_incpartrptval[10], searchst[70], **bufst;
OMuword		 curOs, osnum;
IGRchar		 DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
struct GRid      CollId, DirId;
IGRlong          msg, status;

/*  Querying for MDC Exists Attribute from PDU Table  */
    
 sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'",
		     partid, revision);
     
   stat_ris =
       vdb$RisSelect(select="p_incpartrpt",
 			table_name = catalog, 
			where = searchst,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufst);

   if(stat_ris != 1 || num == 0)  
    goto label;
    
   stat_ris = vdb$RisExtractValue( nbrows = num,
                            nbcolumns = 1,
			    buffer = bufst,
			    row = 0,
			    column = 0,
			    value = p_incpartrptval);

   strcpy(IsModlDCExists, p_incpartrptval);

   if(!strcmp(IsModlDCExists,"Y"))
    strcpy(IsMDCExists,"Y");
   if(!strcmp(IsModlDCExists,"N"))
    strcpy(IsMDCExists,"N");
   
/*  Check for Collector Existence  */

    /* Check if the RG_Collector is already created */
     ex$get_cur_mod( osnum = &curOs );
     status = di$give_pathname( osnum = curOs, pathname = DirName );
     sprintf(CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
  
     CollId.objid = NULL_OBJID;

   /* Get the collector Id if it is already created */

     status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
 __DBGpr_obj("In VDPValidatePart fun CollId is", CollId);

     
  
    if(CollId.objid != NULL_OBJID)
	strcpy(IsCollExists,"Y");
    else
        strcpy(IsCollExists,"N");

/*  Getting MDC OBID From AIM Given Part Info  */
    code = VDP_GET_MDCOBID;
    UI_status("Getting Revised MDC obid from AIM.");
    status = SrVDBaseRevise( code, NULL, &revmdcobid, NULL );
    if( status != OM_S_SUCCESS )
    {
//      __DBGpr_com( " failed to get Revise MDCobid");
//      UI_status("Failed to Get M D C obid.");
      strcpy(IsAIMMDCExists,"N");
      goto label;
    }

     if( strlen(revmdcobid) == 0 )
     strcpy(IsAIMMDCExists,"N");
    else
     strcpy(IsAIMMDCExists,"Y");
    
label:
    return 0;

} 

/*  VDPGetPartInfoGivenMDC()
 *  This function returns the Catalog, Part and Revision of a part with the
 *  input of MDCOBID
*/  

int VDPGetPartInfoGivenMDC( int code, char *obid, char *value1, 
                            char *value2, char *value3)
{

  int 	index=0, inlen=0, dstat, mfail, outlen, i, nbItems =0;
  char 	inbuf[100], srerrmsg[70];
  char	*outbuf=NULL, *errmsg = 0;
  long	status = OM_S_SUCCESS;

  inbuf[0] = '\0';

       memcpy( &inbuf[index], &code, sizeof(int));
       inlen += sizeof(int);
       index = inlen;
       __DBGpr_int( " VDP_GET_CUR_REV Code ", code ); 
       
       strcpy( &inbuf[index], obid );
       inlen = inlen + strlen( obid ) +1;
       index = inlen; 
       __DBGpr_str(" MdcObid ", obid );

       dstat = POSTMAN_REQUEST_ON_CLIX(   inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
       if(dstat || mfail)
       {
         //printf("\n dstat %d, mfail %d", dstat, mfail);
	 if(!errmsg || (errmsg && !errmsg[0]))
	   errmsg="No error msg but should be";
	 if ( strlen(errmsg ) > 63 )
	   errmsg[63] = '\0';
	 UI_status( errmsg );
         if(dstat == 12345 )
         {
	   UI_status("AIM connection was reset by server.");
	   printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
           strcpy(srerrmsg, "AIM connection reset by server.");
           ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         }

	 return OM_E_ABORT;
       } 
       
       
       if(outlen == 0) 
       {
	printf("outlen is null\n");
	goto wrapup;
       }
       index = 0;
       /* get the number from buffer */
       memcpy( &nbItems, &outbuf[index], sizeof(int) );
       index = index + sizeof(int);

       if(outbuf[0]!='\0')
       {
       
         __DBGpr_com("Allocating memory for Revision");
         __DBGpr_int("length", strlen(&outbuf[index]));
	 if(value1) strcpy(value1, &outbuf[index] );
	 index = index + strlen(value1) + 1;
	 __DBGpr_str( " Catalog from SIR ", value1);

	 if(value2) strcpy(value2, &outbuf[index] );
	 index = index + strlen(value2) + 1;
	 __DBGpr_str( " Part from SIR ", value2);

	 if(value3) strcpy(value3, &outbuf[index] );
	 index = index + strlen(value3) + 1;
	 __DBGpr_str( " Revision from SIR ", value3);
	 
       }
       else
	printf("outbuffer is null\n");

wrapup:
       return status;
}

int VDPResetUid(IGRlong *msg)
{
  long        status = OM_S_SUCCESS;
  OMuword     curOs;
  struct      GRid            *list=NULL;
  struct      GRmd_env        MdEnv;
  struct      ACrg_coll       SridColl;
  TGRid       AttId;
  TGRobj_env  AttrObjEnv;

  int		  objcount=0,size,ret_size,objctr,FSI = -1;
  IGRchar     class_name[80],exp[20];
    SetProc(VDPquerydm2.I.VDPResetUid);Begin

	ex$get_cur_mod( osnum = &curOs );
  //Get Objects in the Object Space
  status = VDobjInActiveSpace (msg, &objcount, &list, OPP_VDSroot_class_id);
  CheckRC ( status, *msg );
  __DBGpr_int( "objcount", objcount);

  if (objcount == 0)
  {
    __DBGpr_com("No Objects in the Active Space.");
    goto wrapup;
  }

    for( objctr  = 0; objctr < objcount; objctr = objctr+1)
  {
    __DBGpr_int ( "object", list[objctr].objid );

    //Get Object Class Name
    status = om$get_classname( objid = list[objctr].objid,
                               osnum = list[objctr].osnum,
                               classname = class_name );

    __DBGpr_str( " class_name", class_name);

	//Check FSI and Uid for only FSI classes
    if( !strcmp(class_name, "VDequipment") ||
        !strcmp(class_name, "VREquipment") ||
        !strcmp(class_name, "VRPComp") ||
        !strcmp(class_name, "VRRComp") ||
        !strcmp(class_name, "VRHComp") )
    {
      //Prepare the expression for querying
      exp[0] = '\0';
      __DBGpr_str("classes are", class_name);
      if( !strcmp(class_name, "VDequipment") )
        strcpy( exp, "SA_EXP:FSI_equip" );
      if( !strcmp(class_name, "VREquipment") )
        strcpy( exp, "SA_EXP:FSI_equip" );
      if( !strcmp(class_name, "VRRComp") )
        strcpy( exp, "SA_EXP:FSI_rway" );
      if( !strcmp(class_name, "VRPComp") )
        strcpy( exp, "SA_EXP:FSI_pipe" );
      if( !strcmp(class_name, "VRHComp") )
        strcpy( exp, "SA_EXP:FSI_hvac" );

	  size = sizeof( struct GRmd_env );

      gr$get_module_env( msg = msg,
                         sizbuf = &size,
                         buffer = &MdEnv,
                         nret = &ret_size );

      /* Get FSI from Smart table */
      AttId.objid = list[objctr].objid;
      AttId.osnum = list[objctr].osnum;
      AttrObjEnv.obj_id = AttId;
      AttrObjEnv.mod_env = MdEnv;
      status = vdsa$GetStruct( objOE = &AttrObjEnv,
                               name = exp,
                               jnt = &FSI );
      __DBGpr_obj("Querying smart FSI for object",list[objctr]);
      __DBGpr_int("FSI value is", FSI);
      if(!status)
      {
        //FILE_PRINT( dm2_log, "\nNo entry of object %d found in database table <static_additional> for expression <%s>.", list[objctr].objid, exp);
        //printf("\nNo entry of object %d found in database table <static_additional>, for exression <%s>.", list[objctr].objid, exp );
        continue;
      }

        //Get the Uid attribute of the object
        strcpy( SridColl.name, "sirid" );
        SridColl.desc.type = AC_ATTRIB_TEXT;
        strcpy ( SridColl.desc.value.att_txt, "" );

        status = vd$review_params ( pMsg = msg,
                                    pComponent = &list[objctr],
                                    pMdEnv = &MdEnv,
                                    pList = &SridColl,
                                    NbParams = 1 );

        CheckRC (status, *msg);

		if(strlen(SridColl.desc.value.att_txt)>0)
        {
			printf("Resetting UID <%s> for [%d,%d] at %d\n", SridColl.desc.value.att_txt, 
									list[objctr].osnum, list[objctr].objid, objctr);

			strcpy( SridColl.desc.value.att_txt, "" );
            strcpy( SridColl.name, "sirid" );
            SridColl.desc.type = AC_ATTRIB_TEXT;

            status = VDmodUsrAttrs(msg,list[objctr],&MdEnv,1,&SridColl);

		}//Checking for UID
		else
		{

			printf("UID is NULL for [%d,%d] at %d\n",list[objctr].osnum, list[objctr].objid, objctr);
		}//Checking for UID

	  }//End of FSI class


	}//End of for loop

	__DBGpr_com("UID is reset for all objects");

wrapup:
	End
return status;
}
/* added by Anjani - Function to get MdcRev and Contxt Rev from AIM side */
// TLS - 03/26/01 - changed to VDPGetRevFromOBID 
int VDPGetRevFromOBID( int code, char *obid, char *Rev) 
{

  int 	index=0, inlen=0, dstat, mfail, outlen, nbItems =0;
  char 	inbuf[100];
  char	*outbuf=NULL, *errmsg = 0;
  long	status = OM_S_SUCCESS;
  char 		srerrmsg[70];

      inbuf[0] = '\0';

       __DBGpr_int( " Code ", code ); 
       __DBGpr_str(" Obid ", obid );

       memcpy( &inbuf[index], &code, sizeof(int));
       inlen += sizeof(int);
       index = inlen;
       
       strcpy( &inbuf[index], obid );
       inlen = inlen + strlen( obid ) +1;
       index = inlen; 
       __DBGpr_str(" Obid ", obid );

       dstat = POSTMAN_REQUEST_ON_CLIX(   inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
       if(dstat || mfail)
       {
         printf("\n dstat %d, mfail %d", dstat, mfail);
       } 
       if(dstat == 12345 )
       {
		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    	}
       
       if(outlen == 0) 
       {
	printf("outlen is null\n");
	goto wrapup;
       }
       index = 0;
       /* get the number from buffer */
       memcpy( &nbItems, &outbuf[index], sizeof(int) );
       index = index + sizeof(int);

       if(outbuf[0]!='\0')
       {
       
         __DBGpr_com("Allocating memory for Revision");
         __DBGpr_int("length", strlen(&outbuf[index]));
	 if(Rev) strcpy(Rev, &outbuf[index] );
	 index = index + strlen(Rev) + 1;
	 __DBGpr_str( " Rev is ", Rev);
         status = OM_S_SUCCESS;

       }
       else
	printf("outbuffer is null\n");

wrapup:
       return status;
}

end implementation VDPRoot;
