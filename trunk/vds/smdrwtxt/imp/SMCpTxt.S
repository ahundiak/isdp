/* $Id: SMCpTxt.S,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/imp / SMCpTxt.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCpTxt.S,v $
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
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
/*
/*  ABSTRACT
/*  This class defined a copy tand consume text
/*
/*---------------------------------------------------------------------------*/

class specification SMCpTxt (0:1) of SMAttMgr, VDSroot ;


override 	GRgetobjinfo; 
override 	NDdelete; /* unconsume the text_id */ 

override        ACmplace_from_def, ACconstruct_feet;

/*+mo
  Overriden Message
	VDgetObjDef from VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-mo*/

override VDgetObjDef;

override        SMWhoAreYou; /* Return the Main text_id type and sub_type */




message SMcreate( 	IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *text_id);

/*
/*   SMcreate:
/*
/*     This method fills all the parameters of the macro
/*     and place it.
/*
/*     Argument description:
/*     --------------------
/*
/*  IGRlong             *msg		O : Completion code.
/*  IGRint            	nb_att		I : nb attributes in the ACrg_coll
/*  struct ACrg_coll	*ACrg		I : the attributes 
/*  IGRshort           	*att_type	I : type of each attribute
/*  struct GRid		*text_id	I : the text_id 
/*
/*
/* ------------------------------------------------------------------ */


message SMModify( 	IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *text_id)	;

/*
/*   SMModify:
/*
/*     This method modifies the parameters of an existing macro.
/*     
/*     Argument description:
/*     --------------------
/*
/*  IGRlong             *msg		O : Completion code.
/*  IGRint            	nb_att		I : nb attributes in the ACrg_coll
/*  struct ACrg_coll	*ACrg		I : the attributes 
/*  IGRshort           	*att_type	I : type of each attribute
/*  struct GRid		*text_id	I : the text_id 
/*
/*
/* ------------------------------------------------------------------ */


message SMGetParameters( IGRlong *msg;IGRint *nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *text_id);

/*
/*   SMGetParameters:
/*
/*     This method get the parameters of an existing macro.
/*     A NULL pointer can be given if a parameter is not needed.
/*
/*     Argument description:
/*     --------------------
/*
/*  IGRlong             *msg		O : Completion code.
/*  IGRint            	*nb_att		O : nb attributes in the ACrg_coll
/*  struct ACrg_coll	*ACrg		O : the attributes 
/*  IGRshort           	*att_type	O : type of each attribute
/*  struct GRid		*text_id	O : the text_id 
/*
/*
/* ------------------------------------------------------------------ */



end specification SMCpTxt;



