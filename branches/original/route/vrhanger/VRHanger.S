/*---------------------------------------------------------------------------
/*  VRHanger.S
/*  Nov-29-90
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRHanger
/*
/*		SUBCLASS OF:	VRGeneric
/*
/*		NOTES:
/*
/*	* 09-DEC-91	1.4.3.14	
/*		Bruno
/*		- VRInitInstances method has been removed.
/*
/*
/*
/*---------------------------------------------------------------------------
/* */

class specification VRHanger (0:1) of VRGeneric;


  instance VRHanger
  {
  IGRdouble			dOrientation [3];
  struct 	tagVRSupAttr	VRSupAttr;
  IGRdouble			dFactor;
  };


/*--------------------------------------------------------------------------
/* */
override GRget_siblings;	/* to return the object it is attached to :
				   the correction or the component object */
override VRGetDefName;

override NDmove_to_root;

override ACgive_structure;

override VRGetMatrix;	/* Computed from Component matrix and Data Point */

override VRGetTopo;	/* KLUDGE for ISOGEN */

override VRGetNeighbors; /* To return the supported component Id */

override VRSetInstance;

override VRGetInstance;

override VRGetParams;

message VRGetAttributes (IGRlong *msg ; struct tagVRSupAttr *VRSupAttr );
/*---------------------------------------------------------------------------
/* VRGetAttributes
/*
/*      This message returns the support attributes
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg             O : MSSUC if success and MSFAIL if not.
/*
/* struct tagVRSupAttr *VRSupAttr        O : pointer to support attributes.
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */


end specification VRHanger;
