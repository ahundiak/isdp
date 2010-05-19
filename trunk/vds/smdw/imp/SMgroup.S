/* $Id: SMgroup.S,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/imp / SMgroup.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMgroup.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.2  1994/11/11  22:15:34  pinnacle
# Replaced:  smdw/imp/*.S r#
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
/*---------------------------------------------------------------------------
/*  SMdw.S
/*  Chistian HERAUD
/*  5-June-1992
/*
/*  Abstract:
/*	Class defining the group (and sub_group) object.
/*
/*  The sub_groups and theirs attributes are attributes of the group 
/*  collection.
/*
/*  History:
/*
/*---------------------------------------------------------------------------*/

class specification SMgroup (0:1) of SMmgr, ACrg_collect ;

#include "ACattrib.h"
#include "ACrg_collect.h"

override GRgetobjinfo;	/* Object name at locate time			*/


override SMWhoAreYou; 	/* Return the dead weight type 			*/

override SMFillSfFile;	/* Seasafe output print				*/

override SMFillRpFile;	/* Reports output print				*/

override SMGetAtt;	/* Get attribute values				*/

override SMSetAtt;	/* Set attribute values				*/

override SMGetAttType;	/* Get attribute values	depending on type  	*/

override SMAddAtt;	/* Add new attributes				*/


message SMGetSbGrp(IGRlong *msg; IGRint SizeList, *NbSubGroup; IGRchar *names[]);

/*
/*  SMGetSbGrp:
/* 
/*    Return the sub-groups names. The "names" argument must be allocated
/*  by the caller IGRchar names[SizeList][PATH_MAX], a NULL 
/*  value can be sent, it means that nothing will be returned.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*
/*  IGRint		SizeList	I : Size of names (SM_MAX_SUB_GRP)
/*
/*  IGRint		*NBSubGroup	O : Total Number of sub group.
/*
/*  IGRchar		*name[]		O : array of sub group names (can be NULL).
/*
/*  */
/*---------------------------------------------------------------------*/


message SMGetSbInfo(IGRlong *msg; IGRchar *SubGrpName; IGRint SizeList, *NbAtt;
		   struct ACrg_coll *att; IGRshort type);
/*
/*  SMGetSbInfo:
/* 
/*    For a sub-group name, retuns the attributes. The type allow to select
/*  the returned attributes.
/*
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*
/*  IGRchar		*SubGrpName	I : Sub group name.
/*
/*  IGRint		SizeList	I : Size of att (SM_MAX_SUB_GRP_ATT-1)
/*
/*  IGRint		*NBAtt		O : Total Number of sub group attributes.
/*
/*  struct ACrg_coll 	*att		O : Attributes array (can be NULL).
/*
/*   IGRshort		type		I : Attribute types (see SMdef.h 
/*					    can be set to NULL).
/*
/*  */
/*---------------------------------------------------------------------*/




message SMGetSgrpId(IGRlong *msg; IGRchar *SubGrpName; struct GRid *foot; 
		    IGRshort *mat_type; IGRdouble *mat);
/*
/*  SMGetSgrId:
/* 
/*    For a sub-group name, retuns the foot id, the matrix and matrix type. 
/*    msg = MSSUCC if a cooresponding sub-group have been found.
/*
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*
/*  IGRchar		*SubGrpName	I : Sub group name.
/*
/*  struct GRid		*foot		O : Corresponding foot id.
/*
/*  IGRshort		*mat_type	O : matrix type (can be NULL).
/*
/*  IGRdouble		*matrix		O : matrix (can be NULL).
/*
/*  */
/*---------------------------------------------------------------------*/

end specification SMgroup;

