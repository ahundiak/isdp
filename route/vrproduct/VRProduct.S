/*---------------------------------------------------------------------------
/*
/*  VRProduct.S
/*  Oct-22-90
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRProduct
/*
/*		SUBCLASS OF:	Root
/*
/*		NOTES: This class declares all messages interfacing
/*		       a VROUTE component occurrence in the design
/*		       file and the its product's specifications.
/*
/*
/*
/*---------------------------------------------------------------------------
/* */

class specification VRProduct (0:1) of Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "msdef.h"
#include "parametric.h"
#include "macro.h"
#include "AS_status.h"
#include "VRdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
/*--------------------------------------------------------------------------*/

  instance VRProduct
  {
  };
/*--------------------------------------------------------------------------*/

message VRGetProduct ( 	IGRshort *pnProduct;
			IGRchar	 *pc3Product );
/*---------------------------------------------------------------------------
/* VRGetProduct
/*
/*      This message returns the component's product number or string.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRshort		*pnProduct	O : if specified, returns the product's
/*					    number (defined in vrdef.h).
/* IGRchar		*pc3Product	O : if specified, returns the product's
/*					    bigram ( 2 letters ).
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */


message VRGetSearch ( 	IGRlong *msg;
			struct GRid *PbId;
			IGRint ListSize;
			IGRint *NbParams;
			struct VRSelectAttr *ParamList;
			IGRchar *szSearch;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetSearch
/*
/*      This message returns the component's model search string and
/*	(optional) the list of parameters used to build it.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		PbId		I : Parameters box for dynamic
/*					    selection criteria.
/* IGRint		ListSize	I : Size of the ParamList buffer.
/*
/* IGRint		*NbParams	O : Number of parameters returned in
/*					    the list.
/* struct VRSelectAttr	*ParamList	O : Description of each parameter used
/*					    to build the search string.
/* IGRchar		*szSearch	O : Pointer to search string
/*					    ( szSearch [ VR_SEARCH_LENGTH ] )
/* struct GRmd_env	*md_env		I : Pointer on object's module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */


message VRGetSpecComp ( IGRlong *msg;
			IGRint NbParams ;
			struct VRSelectAttr *ParamList;
			struct GRid *CacheId;
			struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* VRGetSpecComp
/*
/*      Builds and returns the component's attributes cache. It gets
/*	the attributes' values from the product's specs.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O  : MSSUC if success and MSFAIL if not.
/*
/* IGRint		NbParams	I  : Number of parameters in ParamList.
/*
/* struct VRSelectAttr	*ParamList	I  : Pointer to search list of parameters
/*					     used to access the database.
/* struct GRid		*CacheId	O  : returned cache id.
/*
/* struct GRmd_env	*md_env		I  : Pointer on working module env where
/*					     the cache will be built.
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRRetrieveTeeCode ( IGRlong *msg; IGRdouble dAngle; IGRchar *szAABBCC;
				struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* VRRetrieveTeeCode
/*
/*      This message returns the Tee's AABBCC code retrieved from 
/*      selection characteristics of the component.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong         *msg           O : MSSUC if success, MSFAIL otherwise.
/*
/* IGRdouble       dAngle         I : Angle between Primary and Secondary axis.
/*
/* IGRchar         *szAABBCC      O : AABBCC code corresponding to component
/*
/* struct GRmd_env	*md_env		I : Pointer on object's module env.
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRRetrieveElbowCode ( IGRlong *msg; IGRdouble dAngle; 
			    IGRshort *nRotationType; IGRchar *szAABBCC;
				struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* VRRetrieveElbowCode
/*
/*      This message returns the Elbow's AABBCC code retrieved from
/*      selection characteristics of the component.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong         *msg           O : MSSUC if success, MSFAIL otherwise.
/*
/* IGRdouble       dAngle         I : Angle between Primary and Secondary axis.
/*
/* IGRshort       *nRotationType  I : rotation type along component's width
/*                                    depth or neither one, for change of
/*                                    direction or branch components.
/*
/* IGRchar         *szAABBCC      O : AABBCC code corresponding to component
/*
/* struct GRmd_env	*md_env		I : Pointer on object's module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRRetrieveGeneralCode ( IGRlong *msg; IGRshort nItemNum;
				IGRchar *szAABBCC;
				struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* VRRetrieveGeneralCode
/*
/*      This message returns the component's AABBCC code retrieved from
/*      the item number.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong         *msg           O : MSSUC if success, MSFAIL otherwise.
/*
/* IGRshort        nItemNum       I : Item number taken as input.
/* 
/* IGRchar         *szAABBCC      O : AABBCC code corresponding to component
/*
/* struct GRmd_env	*md_env		I : Pointer on object's module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

/*   collect pertinent information      */

message VRProdKey  (IGRlong   *msg;
                    IGRchar   *szSpecNam;      /*  spec/class name   */
                    IGRchar   *szAABBCC;       /*  compcode          */
                    IGRshort  *nOption;        /*  option code       */
                    IGRshort  *nShape;         /*  shape code        */
                    IGRdouble *dSiz1a;         /*  width1/dia1       */
                    IGRdouble *dSiz1b;         /*  depth1            */
                    IGRdouble *dSiz2a;         /*  width2/dia2       */
                    IGRdouble *dSiz2b;         /*  depth2            */
             struct GRmd_env  *md_env );

reject VRProdKey;

reject VRGetProduct, VRGetSpecComp, VRGetSearch;
reject VRRetrieveTeeCode, VRRetrieveElbowCode, VRRetrieveGeneralCode;

end specification VRProduct;
