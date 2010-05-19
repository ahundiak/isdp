/* $Id: SMSectCol.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMSectCol.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSectCol.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
/*	CH  : 15 Jul 91	  creation date.
/*
/* */

class implementation SMsection;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "ACattrib.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "SMcomp_def.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;

extern	GRclassid	OPP_SMcoll_class_id;

#define AS_DEBUG

#define SM_SECT_NB_MAX_ATTR  15	/* 8 + SM_MAX_SECT_PART */

/************************************************************************/
/*
/* SMSectInitCol:
/*
/*       Create the collection for the section.
/* 	 It also adds the minimum requested attributes inside. 
/*
/*
/************************************************************************/

SMSectInitCol(SectDynCol, mod_env)
struct GRid	 *SectDynCol;	    /* Dynamic collect for the section   (O) */
struct GRmd_env  *mod_env;	    /* Current module env		 (I) */
{
 int 			nb_attr;
 long			msg, sts;
 struct	ACrg_coll	att[SM_SECT_NB_MAX_ATTR];

 /* Creating of the collection objects  */
 
 if(SectDynCol != NULL)
  {
   SectDynCol->osnum = mod_env->md_id.osnum;
   sts = om$construct(classid = OPP_SMcoll_class_id,
                      osnum   = SectDynCol->osnum,
                      p_objid = &SectDynCol->objid );
   as$status(sts = sts, action = RET_STATUS);

   sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
                                                  ND_DEL_NO_CH | ND_WAIT_DEL),
			senderid = NULL_OBJID,
                        targetid = SectDynCol->objid,
                        targetos = SectDynCol->osnum );
   as$status(sts = sts, action = RET_STATUS);

   /* Add the minimum attributes for the section attribute collection */
   nb_attr = 0;
   strcpy(att[nb_attr].name, "mode");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = SM_SECT_SGL;
   nb_attr++;

   strcpy(att[nb_attr].name, "axis");
   att[nb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy(att[nb_attr].desc.value.att_txt,"x");
   nb_attr++;

   strcpy(att[nb_attr].name, "end_offset");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = 0.1;  /* Percent of section spaces */ 
   nb_attr++;


   /* Attribute for the automatic mode */
   /* RelAbs   : Specify if the minimun distance between two sections is
   /*	         relative (% of the length) or not.
   /* MinDstSct: Minimum distance between two sections.
   /* MinToInst: % of the area difference from which a new section is added.
   /* MaxToSup : %  of the area difference from which a section is removed.
   /* */

   strcpy(att[nb_attr].name, "RelAbs");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = SM_SECT_REL_DATA; 
   nb_attr++;

   strcpy(att[nb_attr].name, "MinDstSct");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = 3;  
   nb_attr++;

   strcpy(att[nb_attr].name, "MinToInst");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = 0.5;
   nb_attr++;

   strcpy(att[nb_attr].name, "MaxToSup");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = 0.01;
   nb_attr++;


   /* Attribute for the none automatic mode */
   /* NbPart : Number of part
   /* For(i=0; i< SM_MAX_SECT_PART; i++)
   /* 	FrDx   : Distance on the axis (relative to "From frame number")
   /* 	ToDx   : Distance on the axis (relative to "To frame number")
   /* 	NbSect : Number of sections.
   /*
   /*   Inc    : The computed increment (distance between two curves.
   /*	NbCrv  : The total number of curves for the part.
   /*   X1     : Coordinate of the first section.
   /*   X2     : Coordinate of the last section.
   /*
   /* Only one part definition is initialized 
   /* */

   strcpy(att[nb_attr].name, "NbPart");
   att[nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[nb_attr].desc.value.att_exp = 1;
   nb_attr++;

   SMSectFillPart(&nb_attr, att, 0, 0, 0, 3, 0, 0, 0, 0);

   sts = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                nb_attr,
                                                att),
			senderid = NULL_OBJID,
                        targetid = SectDynCol->objid,
                        targetos = SectDynCol->osnum );
   as$status(sts = sts, action = RET_STATUS);
   if(!(msg &1)) return OM_W_ABORT;
  }

 return 1;
}


/************************************************************************/
/*
/* SMSectFillPart:
/*
/*       Fill the attribute structure.
/*
/*
/************************************************************************/

SMSectFillPart(nb_attr, att, index, FrDx, ToDx, NbSect, Inc, NbCrv, X1, X2)
IGRint			*nb_attr;	/* Number of attribute   (I/O) */
IGRint			index;		/* index of the part     (I)   */
struct	ACrg_coll	*att;		/* Attibute structure    (I/O) */
IGRdouble               FrDx, ToDx, Inc, X1, X2; /* Values       (I)   */
IGRint                  NbSect, NbCrv;           /* Values       (I)   */
{
 sprintf(att[*nb_attr].name, "FrDx_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = FrDx;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "ToDx_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = ToDx;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "NbSect_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = (IGRdouble) NbSect;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "Inc_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = Inc;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "NbCrv_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = (IGRdouble) NbCrv;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "X1_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = X1;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "X2_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = X2;
 *nb_attr = *nb_attr + 1;

 return 1;
}


/**************************************************************************/
/*
/*  Fill the collection with the corresponding values given by Info
/*
/**************************************************************************/

SMSectFillColl(Info, NbAtt, att)
struct SMSectInfo   *Info;      /* gather all the needed info       (I) */
IGRint              *NbAtt;     /* I size of the array, O nb attributes */
struct ACrg_coll    *att;       /* Attributes array                 (I) */
{
 IGRint         MaxAtt, i, NbSect, NbCrv;
 IGRdouble      FrDx, ToDx, Inc, X1, X2;

 MaxAtt = *NbAtt;

 *NbAtt = 0;
 if(MaxAtt <= *NbAtt) return 0;

 strcpy(att[*NbAtt].name, "mode");
 att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
 att[*NbAtt].desc.value.att_exp = (IGRdouble) Info->mode;
 (*NbAtt)++;

 if(MaxAtt <= *NbAtt) return 0;
 strcpy(att[*NbAtt].name, "axis");
 att[*NbAtt].desc.type = AC_ATTRIB_TEXT;
 att[*NbAtt].desc.value.att_txt[0] = Info->axis;
 att[*NbAtt].desc.value.att_txt[1] = '\0';
 (*NbAtt)++;

 if(MaxAtt <= *NbAtt) return 0;
 strcpy(att[*NbAtt].name, "end_offset");
 att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
 att[*NbAtt].desc.value.att_exp = Info->EndOffset;
 (*NbAtt)++;

 if(MaxAtt <= *NbAtt) return 0;
 strcpy(att[*NbAtt].name, "NbPart");
 att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
 att[*NbAtt].desc.value.att_exp = Info->NbPart;
 (*NbAtt)++;

 
 if(Info->mode == SM_SECT_AUTO) 
  {
   /* Attribute for the automatic mode */
   /* RelAbs   : Specify if the minimun distance between two sections is
   /*	         relative (% of the length) or not.
   /* MinDstSct: Minimum distance between two sections.
   /* MinToInst: % of the area difference from which a new section is added.
   /* MaxToSup : %  of the area difference from which a section is removed.
   /* */

   if(MaxAtt <= *NbAtt) return 0;
   strcpy(att[*NbAtt].name, "RelAbs");
   att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
   att[*NbAtt].desc.value.att_exp = (IGRdouble) Info->att.oto.RelAbs;
   (*NbAtt)++;

   if(MaxAtt <= *NbAtt) return 0;
   strcpy(att[*NbAtt].name, "MinDstSct");
   att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
   att[*NbAtt].desc.value.att_exp = (IGRdouble) Info->att.oto.MinDstSct;
   (*NbAtt)++;

   if(MaxAtt <= *NbAtt) return 0;
   strcpy(att[*NbAtt].name, "MinToInst");
   att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
   att[*NbAtt].desc.value.att_exp = (IGRdouble) Info->att.oto.MinToInst;
   (*NbAtt)++;

   if(MaxAtt <= *NbAtt) return 0;
   strcpy(att[*NbAtt].name, "MaxToSup");
   att[*NbAtt].desc.type = AC_ATTRIB_DOUBLE;
   att[*NbAtt].desc.value.att_exp =(IGRdouble) Info->att.oto.MaxToSup;
   (*NbAtt)++;
  }


 /* Attribute for the none automatic mode */
 /* NbPart : Number of part
 /* For(i=0; i< SM_MAX_SECT_PART; i++)
 /* 	FrDx   : Distance on the axis (relative to "From frame number")
 /* 	ToDx   : Distance on the axis (relative to "To frame number")
 /* 	NbSect : Number of sections.
 /*
 /*   Inc    : The computed increment (distance between two curves.
 /*	NbCrv  : The total number of curves for the part.
 /*   X1     : Coordinate of the first section.
 /*   X2     : Coordinate of the last section.
 /*
 /* Only one part definition is initialized 
 /* */

 if(*NbAtt + SM_MAX_SECT_PART * Info->NbPart > MaxAtt) return 0;
 for(i=0;i<Info->NbPart;i++)
  {
   Inc    = 0;
   NbCrv  = 0;
   X1     = 0;
   X2     = 0;
   FrDx   = 0;
   ToDx   = 0;
   NbSect = 0;

   if(Info->mode == SM_SECT_SGL)
    {
     NbSect = Info->att.sgl.NbSect;
    }
   else if(Info->mode == SM_SECT_USER)
    {
     FrDx   = Info->att.usr[i].FrDx;
     ToDx   = Info->att.usr[i].ToDx;
     NbSect = Info->att.usr[i].NbSect;
    }
   SMSectFillPart(NbAtt, att, i, FrDx, ToDx, NbSect, Inc, NbCrv, X1, X2);
  }

 return 1;
}
end implementation SMsection;
 

