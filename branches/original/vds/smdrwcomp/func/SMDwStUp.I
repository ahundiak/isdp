/* $Id: SMDwStUp.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwcomp/func / SMDwStUp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMDwStUp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/21  22:14:22  pinnacle
# Replaced: smdrwcomp/func/SMDwStUp.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH    : 16 Oct 92	  creation date.
/*	Raju  : 28 May 93	  Added FLOOR and ATTRIBUTE options.
/* */

class implementation Root;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"



#include "SMDwDef.h"


#include "AS_status.h"

#define AS_DEBUG


from    ACrg_collect    import  ACget_named_attribute, ACset_list_attribute;
from    GRvg		import	GRputname;
/*
 *  SMSetDwPr:
 *
 *  Set/Modify the drawing parameters. 
 *
 *  It creates or updates an ACrg_collection with all the information.
 *  The name of this collection must be "<file_name>:SMDrwParam"
 *
 */

SMSetDwPr(CrPlane, PlaneSymb, CrCont, ContSymb, CrContLn, ContLnSymb,
	  CrCog, CogSymb, CrName, NameSymb, ExtType, ExtSymb, CollId)
IGRboolean		CrPlane;	/* True if plane wanted		(I) */
struct SMDwSymb		*PlaneSymb;	/* Plane symbology		(I) */
IGRboolean		CrCont;		/* True if contour wanted	(I) */
struct SMDwSymb		*ContSymb;	/* Contour symbology		(I) */
IGRboolean		CrContLn;	/* True if contour + lines 	(I) */
struct SMDwSymb		*ContLnSymb;	/* Lines symbology		(I) */
IGRboolean		CrCog;		/* True if cog wanted		(I) */
struct SMDwSymb		*CogSymb;	/* Cog symbology		(I) */
IGRboolean		CrName;		/* True if name wanted		(I) */
struct SMDwSymb		*NameSymb;	/* Name symbology		(I) */
IGRboolean		ExtType;	/* TRUE if extraction type is
					   specified by user		(I) */
struct SMDwSymb		*ExtSymb;	/* Extraction option		(I) */
struct GRid		*CollId;	/* Collection Id (can be NULL)  (O) */
{
 IGRlong		status, loc_msg;
 IGRchar 		CollName[81];
 struct GRid		module, MyCollId;
 struct ACrg_coll	att[SMMAXCOLDIM];
 IGRint			ind, NbCrt;

 /* Look if already existing */
 VDSget_filename(CollName);
 strcat(CollName, SMDwCollName);

 status = di$translate(objname = CollName,
              p_objid = &MyCollId.objid,
              p_osnum = &MyCollId.osnum);
 if(!(status&1))
  {
   /* The collection does not exit, create it */

   ex$get_cur_mod(id = &module.objid, osnum = &module.osnum);
   
   MyCollId.osnum = module.osnum;
   status = om$construct(classid = OPP_ACrg_collect_class_id,
                         osnum   = MyCollId.osnum,
                         p_objid = &MyCollId.objid );
   if(!(status & 1)) return 0;

   /* Add a name */
   status = om$send(msg = message GRvg.GRputname(&loc_msg, CollName),
			senderid = NULL_OBJID,
                        targetid = MyCollId.objid,
                        targetos = MyCollId.osnum);
   if(!(status & loc_msg & 1)) return 0;
  }

 /* Create expression */
 ind = 0;
 if(!(SMDwDefAtt("Plane" , CrPlane , PlaneSymb , &att[ind], &NbCrt) & 1)) return 0;
 ind += NbCrt;
 if(!(SMDwDefAtt("Cont"  , CrCont  , ContSymb  , &att[ind], &NbCrt) & 1)) return 0;
 ind += NbCrt;
 if(!(SMDwDefAtt("ContLn", CrContLn, ContLnSymb, &att[ind], &NbCrt) & 1)) return 0;
 ind += NbCrt;
 if(!(SMDwDefAtt("Cog"   , CrCog   , CogSymb   , &att[ind], &NbCrt) & 1)) return 0;
 ind += NbCrt;
 if(!(SMDwDefAtt("Name"  , CrName  , NameSymb  , &att[ind], &NbCrt) & 1)) return 0;
 ind += NbCrt;
 if(!(SMDwDefAtt("Extract"  , ExtType , ExtSymb , &att[ind], &NbCrt) & 1)) return 0;
 ind += NbCrt;
 
 
 status = om$send(msg = message ACrg_collect.ACset_list_attribute(&loc_msg,
 							ind, att),
				senderid = NULL_OBJID,
				targetid = MyCollId.objid,
				targetos = MyCollId.osnum);
 if(!(status & loc_msg & 1)) return 0;

 if(CollId) *CollId = MyCollId;

 return 1; 
}

/*
 *  SMGetDwPr:
 *
 *  Get the drawing parameters. 
 *
 *
 */

SMGetDwPr(CrPlane, PlaneSymb, CrCont, ContSymb, CrContLn, ContLnSymb,
	  CrCog, CogSymb, CrName, NameSymb, ExtType, ExtSymb, CollId)
IGRboolean		*CrPlane;	/* True if plane wanted		(O) */
struct SMDwSymb		*PlaneSymb;	/* Plane symbology		(O) */
IGRboolean		*CrCont;	/* True if contour wanted	(O) */
struct SMDwSymb		*ContSymb;	/* Contour symbology		(O) */
IGRboolean		*CrContLn;	/* True if contour + lines 	(O) */
struct SMDwSymb		*ContLnSymb;	/* Lines symbology		(O) */
IGRboolean		*CrCog;		/* True if cog wanted		(O) */
struct SMDwSymb		*CogSymb;	/* Cog symbology		(O) */
IGRboolean		*CrName;	/* True if name wanted		(O) */
struct SMDwSymb		*NameSymb;	/* Name symbology		(O) */
IGRboolean		*ExtType;	/* TRUE if extraction type is specified
					   by user			(I) */
struct SMDwSymb		*ExtSymb;	/* Type of extraction		(O) */
struct GRid		*CollId;	/* Collection Id (can be NULL)  (I) */
{
 IGRlong		status;
 IGRchar 		CollName[81];
 struct GRid		MyCollId;

 if(CollId == NULL)
  {
   /* Look if already existing */
   VDSget_filename(CollName);
   strcat(CollName, SMDwCollName);

   status = di$translate(objname = CollName,
              p_objid = &MyCollId.objid,
              p_osnum = &MyCollId.osnum);
   if(!(status&1))
    {
     /* The collection does not exit, return default value */
     *CrPlane  = FALSE;
     *CrCont   = TRUE;
     ContSymb->options = SMDWCLOBJ | SMDWLVOBJ | SMDWWTOBJ | SMDWSTOBJ;
     *CrContLn = FALSE;
     *CrCog    = FALSE;
     *CrName   = TRUE;
     NameSymb->options = SMDWCLOBJ | SMDWLVOBJ | SMDWWTOBJ | SMDWSTOBJ 
			| SMDWATTOBJ | SMDWATTOBJ;
     *ExtType = FALSE;

     return 1;
    }
  }
 else 
  {
   MyCollId = *CollId;
  }

 /* Fill info */
 if(!(SMDwExtColInf("Plane" , CrPlane , PlaneSymb , &MyCollId) & 1)) return 0;
 if(!(SMDwExtColInf("Cont"  , CrCont  , ContSymb  , &MyCollId) & 1)) return 0;
 if(!(SMDwExtColInf("ContLn", CrContLn, ContLnSymb, &MyCollId) & 1)) return 0;
 if(!(SMDwExtColInf("Cog"   , CrCog   , CogSymb   , &MyCollId) & 1)) return 0;
 if(!(SMDwExtColInf("Name"  , CrName  , NameSymb  , &MyCollId) & 1)) return 0;
 if(!(SMDwExtColInf("Extract" , ExtType, ExtSymb  , &MyCollId) & 1)) return 0;

 return 1; 
}

/*
 * SMDwDefAtt: 
 *
 *  Fill the ACrg_coll structure to store the info.
 */

SMDwDefAtt(name , CrObj , ObjSymb , att, NbCrt)
IGRchar		  *name;	/* Prefix Name			(I)  */
IGRboolean	  CrObj; 	/* TRUE if wanted		(I)  */
struct SMDwSymb	  *ObjSymb;	/* Object symbology		(I)  */
struct ACrg_coll  att[];	/* Array to fill	       (I/O) */
IGRint		  *NbCrt;	/* Number of coll created	(O)  */
{
 *NbCrt = 0;


 if(CrObj != TRUE) goto wrapup;

 /* Create a collection only if extraction is wanted */
 
 /*
  *    <name>Op  for Option.
  *    <name>Lv  for layer.   Create collection only when user.
  *    <name>Cl  for color.   Create collection only when user.
  *    <name>Wt  for weight.  Create collection only when user.
  *    <name>St  for style.   Create collection only when user.
  *    <name>Clt for contour line. Create collection only when user.
  *   
  */

 strcpy(att[0].name, name);
 strcat(att[0].name, "Op");
 
 att[0].desc.type 	   = AC_ATTRIB_DOUBLE;
 att[0].desc.value.att_exp = (IGRdouble) ObjSymb->options;
 (*NbCrt)++;
 if ( !strcmp(name,"Extract") )   /* No symbology for Extract type */
	return 1;

 /* Color */
 if(ObjSymb->options & SMDWCLUSR)
  {
   /* Create one coll */
   strcpy(att[*NbCrt].name, name);
   strcat(att[*NbCrt].name, "Cl");
   att[*NbCrt].desc.type 	  = AC_ATTRIB_DOUBLE;
   att[*NbCrt].desc.value.att_exp = (IGRdouble) ObjSymb->symb.display_attr.color;
   (*NbCrt)++;
  }
  
 /* Level */
 if(ObjSymb->options & SMDWLVUSR)
  {
   /* Create one coll */
   strcpy(att[*NbCrt].name, name);
   strcat(att[*NbCrt].name, "Lv");
   att[*NbCrt].desc.type 	  = AC_ATTRIB_DOUBLE;
   att[*NbCrt].desc.value.att_exp = (IGRdouble) ObjSymb->symb.level;
   (*NbCrt)++;
  }
  
 /* Weight */
 if(ObjSymb->options & SMDWWTUSR)
  {
   /* Create one coll */
   strcpy(att[*NbCrt].name, name);
   strcat(att[*NbCrt].name, "Wt");
   att[*NbCrt].desc.type 	     = AC_ATTRIB_TEXT;
   att[*NbCrt].desc.value.att_txt[0] = ObjSymb->symb.display_attr.weight;
   att[*NbCrt].desc.value.att_txt[1] = '\0';
   (*NbCrt)++;
  }
  
 /* Style */
 if(ObjSymb->options & SMDWSTUSR)
  {
   /* Create one coll */
   strcpy(att[*NbCrt].name, name);
   strcat(att[*NbCrt].name, "St");
   att[*NbCrt].desc.type 	     = AC_ATTRIB_TEXT;
   att[*NbCrt].desc.value.att_txt[0] = ObjSymb->symb.display_attr.style;
   att[*NbCrt].desc.value.att_txt[1] = '\0';
   (*NbCrt)++;
  }

 if(strncmp(name, "ContLn", 6) == 0)
  {
   /* Special treatement for Contour lines */
   if(ObjSymb->options & SMDWCTLNUSR || ObjSymb->options & SMDWCTLNMM)
    {
     /* Create one coll */
     strcpy(att[*NbCrt].name, name);
     strcat(att[*NbCrt].name, "Ctl");
     att[*NbCrt].desc.type 	    = AC_ATTRIB_DOUBLE;
     att[*NbCrt].desc.value.att_exp = (IGRdouble) ObjSymb->lens;
     (*NbCrt)++;
    }

   if(ObjSymb->options & SMDWCTLNMM )
    {
     /* Create one coll */
     strcpy(att[*NbCrt].name, name);
     strcat(att[*NbCrt].name, "CtMl");
     att[*NbCrt].desc.type 	    = AC_ATTRIB_DOUBLE;
     att[*NbCrt].desc.value.att_exp = (IGRdouble) ObjSymb->MaxLens;
     (*NbCrt)++;
    }
  }

 if(strncmp(name, "Name", 4) == 0)
  {
   /* Special treatement for Text */
   if(ObjSymb->options & SMDWTXUSR)
    {
     /* Create one coll */
     strcpy(att[*NbCrt].name, name);
     strcat(att[*NbCrt].name, "Jt");
     att[*NbCrt].desc.type 	    = AC_ATTRIB_DOUBLE;
     att[*NbCrt].desc.value.att_exp = (IGRdouble) ObjSymb->TextJust;
     (*NbCrt)++;
    }
   /* Special treatement for Attribute Name */
   if(ObjSymb->options & SMDWATTUSR)
    {
     /* Create one coll */
     strcpy(att[*NbCrt].name, name);
     strcat(att[*NbCrt].name, "Att");
     att[*NbCrt].desc.type 	    = AC_ATTRIB_TEXT;
     strcpy ( att[*NbCrt].desc.value.att_txt, ObjSymb->AttName );
     (*NbCrt)++;
    }
  }

wrapup:     
 return 1;

}




/*
 * SMDwExtColInf: 
 *
 *  Fill the ACrg_coll structure to store the info.
 */

SMDwExtColInf(name , CrObj , ObjSymb , CollId)
IGRchar		  *name;	/* Prefix Name			(O)  */
IGRboolean	  *CrObj; 	/* TRUE if wanted 		(O)  */
struct SMDwSymb	  *ObjSymb;	/* Object symbology		(O)  */
struct GRid	  *CollId;	/* Collection Id		(I)  */
{
 IGRlong		status, loc_msg;
 struct ACrg_coll  	att;

 strcpy(att.name, name);
 strcat(att.name, "Op");
 
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
 if(!(status & 1)) return 0;

 if(!(loc_msg & 1))
  {
   /* Do not extract this object */
   *CrObj = FALSE;
   return 1;
  }

 *CrObj = TRUE;

 if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
 ObjSymb->options = (IGRint) att.desc.value.att_exp;
 
 if ( !strcmp(name,"Extract") )		/* No. symbology for Extract type */
	return 1;

 /* Color */
 if(ObjSymb->options & SMDWCLUSR)
  {
   /* Get info */
   strcpy(att.name, name);
   strcat(att.name, "Cl");

   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
   if(!(status & 1 & loc_msg)) return 0;

   if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
   ObjSymb->symb.display_attr.color = (short unsigned)att.desc.value.att_exp;
  }
  
 /* Level */
 if(ObjSymb->options & SMDWLVUSR)
  {
   /* Get Info */
   strcpy(att.name, name);
   strcat(att.name, "Lv");

   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
   if(!(status & 1 & loc_msg)) return 0;

   if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
   ObjSymb->symb.level = (IGRshort) att.desc.value.att_exp;
  }
  
 /* Weight */
 if(ObjSymb->options & SMDWWTUSR)
  {
   /* Get Info */
   strcpy(att.name, name);
   strcat(att.name, "Wt");

   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
   if(!(status & 1 & loc_msg)) return 0;

   if(att.desc.type != AC_ATTRIB_TEXT) return 0;
   ObjSymb->symb.display_attr.weight = (IGRuchar) att.desc.value.att_txt[0];
  }
  
 /* Style */
 if(ObjSymb->options & SMDWSTUSR)
  {
   /* Get Info */
   strcpy(att.name, name);
   strcat(att.name, "St");

   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
   if(!(status & 1 & loc_msg)) return 0;

   if(att.desc.type != AC_ATTRIB_TEXT) return 0;
   ObjSymb->symb.display_attr.style = (IGRuchar) att.desc.value.att_txt[0];
  }

 if(strncmp(name, "ContLn", 6) == 0)
  {
   /* Special treatement for Contour lines */
   if(ObjSymb->options & SMDWCTLNUSR || ObjSymb->options & SMDWCTLNMM)
    {
     /* Get Info */
     strcpy(att.name, name);
     strcat(att.name, "Ctl");

     status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
     if(!(status & 1 & loc_msg)) return 0;

     if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
     ObjSymb->lens = att.desc.value.att_exp;
    }

   if(ObjSymb->options & SMDWCTLNMM )
    {
     /* Min & max length defined */
     strcpy(att.name, name);
     strcat(att.name, "CtMl");

     status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
     if(!(status & 1 & loc_msg)) return 0;

     if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
     ObjSymb->MaxLens = att.desc.value.att_exp;
    }
  }

 if(strncmp(name, "Name", 4) == 0)
  {
   /* Special treatement for Text */
   if(ObjSymb->options & SMDWTXUSR)
    {
     /* Create one coll */
     strcpy(att.name, name);
     strcat(att.name, "Jt");

     status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
     if(!(status & 1 & loc_msg)) return 0;

     if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
     ObjSymb->TextJust = (IGRshort) att.desc.value.att_exp;
    }

   if(ObjSymb->options & SMDWATTUSR)
    {
     /* Create one coll */
     strcpy(att.name, name);
     strcat(att.name, "Att");

     status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
								     &att),
 				senderid = NULL_OBJID,
				targetid = CollId->objid,
				targetos = CollId->osnum);
     if(!(status & 1 & loc_msg)) return 0;

     if(att.desc.type != AC_ATTRIB_TEXT ) return 0;
     strcpy( ObjSymb->AttName, att.desc.value.att_txt );
    }
   else
     ObjSymb->AttName[0] = '\0';
  }


 return 1;
}


/*
 * SMCrvSymb:
 *
 *  Convert the symbology info into real symbologie.
 *
 */

SMCrvSymb(SMObjSymb, CurSymb, ObjSymb, MySymb)
struct SMDwSymb		*SMObjSymb;	/* Sman Symbology info 		(I) */
struct GRsymbology 	*CurSymb;	/* Current symbology		(I) */
struct GRsymbology 	*ObjSymb;	/* Object symbology		(I) */
struct GRsymbology 	*MySymb;	/* Real symbology		(O) */
{

 /* Level */
 if(SMObjSymb->options & SMDWLVUSR)
  {
   MySymb->level = SMObjSymb->symb.level;
  }
 else if(SMObjSymb->options & SMDWLVACT)
  {
   MySymb->level = CurSymb->level;
  }
  else if(SMObjSymb->options & SMDWLVOBJ)
  {
   MySymb->level = ObjSymb->level;
  }
 else 
  {
   printf("Warning, bad opyion for level, take the active one\n");
   MySymb->level = CurSymb->level;
  }   

 /* Color */
 if(SMObjSymb->options & SMDWCLUSR)
  {
   MySymb->display_attr.color = SMObjSymb->symb.display_attr.color;
  }
 else if(SMObjSymb->options & SMDWCLACT)
  {
   MySymb->display_attr.color = CurSymb->display_attr.color;
  }
 else if(SMObjSymb->options & SMDWCLOBJ)
  {
   MySymb->display_attr.color = ObjSymb->display_attr.color;
  }
 else 
  {
   printf("Warning, bad opyion for color, take the active one\n");
   MySymb->display_attr.color = CurSymb->display_attr.color;
  }   
 
 /* Weight */
 if(SMObjSymb->options & SMDWWTUSR)
  {
   MySymb->display_attr.weight = SMObjSymb->symb.display_attr.weight;
  }
 else if(SMObjSymb->options & SMDWWTACT)
  {
   MySymb->display_attr.weight = CurSymb->display_attr.weight;
  }
 else if(SMObjSymb->options & SMDWWTOBJ)
  {
   MySymb->display_attr.weight = ObjSymb->display_attr.weight;
  }
 else 
  {
   printf("Warning, bad opyion for weight, take the active one\n");
   MySymb->display_attr.weight = CurSymb->display_attr.weight;
  }   

 /* Style */
 if(SMObjSymb->options & SMDWSTUSR)
  {
   MySymb->display_attr.style = SMObjSymb->symb.display_attr.style;
  }
 else if(SMObjSymb->options & SMDWSTACT)
  {
   MySymb->display_attr.style = CurSymb->display_attr.style;
  }
 else if(SMObjSymb->options & SMDWSTOBJ)
  {
   MySymb->display_attr.style = ObjSymb->display_attr.style;
  }
 else 
  {
   printf("Warning, bad opyion for style, take the active one\n");
   MySymb->display_attr.style = CurSymb->display_attr.style;
  }   
 return 1;
}

end implementation Root;

