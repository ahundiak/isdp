/*---------------------------------------------------------------------------
/*  VRNozHold.S
/*  May-06-92
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRNozHold
/*
/*		SUBCLASS OF:	ASnode
/*
/*		NOTES:  This object is substituted to a VRNozzle
/*			object when placed in a macro definition.
/*			It has the same templates than a nozzle
/*			N collections and 1 coordinate system.
/*
/*
/*---------------------------------------------------------------------------
/* */

class specification VRNozHold (0:1) of ASnode;

#include "ACattrib.h"
#include "ACrg_collect.h"


  instance VRNozHold
  {
	/* Product number */
	IGRint				Product;

	/* Geometric attributes */
		/* rotation angle around the X axis */
	IGRdouble			dAngle;

	/* Specific attributes */

		/* nozzle's tag number */
	IGRchar				szNumber[13];

		/* component notes */

	IGRchar				szNotes[30];

	/* Number of collections */
	IGRint				NbCollections;

	/* Number of attributes in each collections */
	variable IGRint			NbAttributes[0];

	/* Attributes list */
	variable struct ACrg_coll	Attributes[0];

	/* Coordinate system */
	IGRdouble			dMatrix[16];
  };


/*--------------------------------------------------------------------------
/* */

override 	ASreturn_go,		/* No graphics => returns the VRNozHold id */
		NDcompute_node,		/* Stores attributes from collections and
					   matrix from coordinate system */
		NDgive_structure,	/* Returns coordinate system's information */
		NDcopy,			/* Avoid the GRowner.GRcopy */
		NDmove_to_root,		/* Avoid treatment of graphics component */
		GRxform;		/* When I am moved to root, I must apply the
					   xform matrix to my matrix */

from GRvg inherit	GRgetsymb,	/* Make shure that the GRvg method is activated */
			GRputsymb,
			GRchgcolor,
			GRchgdp,
			GRchglevel,
			GRchgstyle,
			GRchgweight;


message VRGiveAttributes ( 	IGRlong *msg;
				IGRint CollectionsSize;IGRint AttributesSize;
				IGRint *NbCollections; IGRint NbAttributes[];
				struct ACrg_coll Attributes[] );
/*---------------------------------------------------------------------------
/* VRGiveAttributes
/*
/*      Returns the list of attributes used to define the nozzle.
/*	It also returns information on how these attributes were
/*	grouped into collections.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		*CollectionsSz	I : Size of the NbAttributes buffer.
/*
/* IGRint		*AttributesSize	I : Size of the Attributes buffer.
/*
/* IGRint		*NbCollections	 O : Number of collections containing
/* 					     these attributes.
/* IGRint		NbAttributes[]	 O : Number of attributes per collection.
/*
/* struct ACrg_coll	Attributes[]	 O : List of attributes.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetInstance ( 	IGRlong *msg; IGRint *Product;
				IGRchar szTagNumber[]; IGRchar szNotes[];
				IGRdouble *dAngle );
/*---------------------------------------------------------------------------
/* VRGetInstance
/*
/*      Returns the instance of the nozzle.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg             O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		*Product	 O : Returns the product number (VRdef.h).
/*
/* IGRchar		szTagNumber[]	 O : Address of a string of 13 characters.
/*
/* IGRchar		szNotes[]	 O : Address of a string of 30 characters.
/*
/* IGRdouble		*dAngle		 O : Rotation angle (radian).
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRSetInstance ( 	IGRlong *msg; IGRint Product;
				IGRchar *szTagNumber; IGRchar *szNotes;
				IGRdouble dAngle );
/*---------------------------------------------------------------------------
/* VRSetInstance
/*
/*      Returns the instance of the nozzle.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg             O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		Product	 	 I : Product number (VRdef.h).
/*
/* IGRchar		szTagNumber[]	 I : Max 13 characters.
/*
/* IGRchar		szNotes[]	 I : Max 30 characters.
/*
/* IGRdouble		dAngle		 I : Rotation angle (radian).
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

end specification VRNozHold;

