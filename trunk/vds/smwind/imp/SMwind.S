/* $Id: SMwind.S,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/imp / SMwind.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMwind.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
/*---------------------------------------------------------------------------
/*  SMwind.S
/*  Chistian HERAUD
/*  15-Jul-92
/*
/*  Abstract
/*	Class defining special behavior for the wind area polygons.
/*
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification SMwind (0:1) of SMAttMgr, VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print WIND AREA at locate time */

override	SMWhoAreYou; /* Return the wind area polygon type and sub_type */

override	SMFillSfFile; /* Seasafe extraction */

override	NDmove_to_root; /* if a root line string have been deleted */

override        VDgetObjDef;    /* object specific information */


/*---------------------------------------------------------------------*/

message SMGetWindPlgs(IGRlong *msg; IGRint ListSize, *NbPlgs, *TtNumber; 
		      struct GRid *Plgs; struct GRmdenv_info *MdEnv);

/*
/*  SMGetWindPlgs:
/* 
/*  Return the list of feet polygons, 
/*
/*  The size must be allocated by the user (max volumes = SM_MAX_ALLOW_PLG).
/*  If NULL is passed for volume the TtNumber is returned.
/*
/*  About the feet, it is the graphic objects which are returned.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*  IGRint		ListSize	I : Size of Plgs, MdEnv (if theirs are
/*					    not NULL).
/*  IGRint		*NbPlgs		O : Number of returned elments
/*  IGRint		*TtNumber	O : Total number of elements.
/*  struct GRid		*Plgs		O : List of Polygons feet (can be 
/*					    NULL if not needed).
/*  struct GRmdenv_info *MdEnv		O : list of env  (can be 
/*					    NULL if not needed).
/*
/*  */
/*---------------------------------------------------------------------*/


message SMWindGetInfo(IGRlong *msg; IGRint *index; struct GRid *root;
                      IGRint *NbAtt; struct ACrg_coll *att);
/*
/*  SMWindGetInfo:
/* 
/*  Given the index (firts one is 0) of a polygon or the corresponding root, 
/*  fills the att structure.
/*  The att structure must be allocated be the used at SM_WIND_NB_MAX_ATTR.
/*  The one (ref_no or root) which is not given can be filled if not NULL.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*  IGRint              *index         I/O: root index (can be NULL or -1).
/*  struct GRid		*root	       I/O: root id (can be NULL or NULL_GRID).
/*  IGRint              *NbAtt          O : Number of attributes.
/*  struct ACrg_coll    *att            O : List of attributtes.
/*
/*  */


message SMWindAddPlg(IGRlong *msg; struct GRid *roots; IGRint NbAtt; 
                     struct ACrg_coll *att);

/*
/*  SMWindAddlg:
/* 
/*  Add a polygons to an exist object.
/*
/*  The objects to be added must already a source and a closed line string 
/*  or a polygon.
/*
/*  The list of attributes can be create by the function "SMWindFillPlg".
/*
/*  If the root already exit, modify the attributes.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*  struct GRid		*root		I : root id.
/*  IGRint               NbAtt          I : Number of attributes.
/*  struct ACrg_coll    *att            I : List of attributtes.
/*
/*  */
/*---------------------------------------------------------------------*/


message SMWindRemPlg(IGRlong *msg; struct GRid *root; IGRint *NbExist);

/*
/*  SMWindRemlg:
/* 
/*  Remove a polygons to an exist object.
/*
/*  NbExist gives the number of existing roots. if it is 0 the user can
/*  delete or not the object.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*  struct GRid		*root		I : Polygon id.
/*  IGRint              *NbExist        O : Number of existing graphic roots.
/*
/*  */
/*---------------------------------------------------------------------*/


end specification SMwind;
