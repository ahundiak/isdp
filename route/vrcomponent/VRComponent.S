/*---------------------------------------------------------------------------
/*
/*  VRComponent.S
/*  Oct-22-90
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRComponent
/*
/*		SUBCLASS OF:	VRGeneric
/*
/*		NOTES:
/*
/*
/*
/*	* 09-DEC-91	1.4.3.14	
/*		Bruno
/*		- VRInitInstances method has been removed.
/*
/*	* 31-MAR-94	2.3.0.3
/*		Manyam
/*		- override NDdelete so as to inform corrections
/* 		  even if the component is deleted as a single entity(	
/*		  not a member of graph )
/*         
/*      * 21-NOV-94     2.3.
/*		Lori
/*	        - override VRVerifyTopology
/*
/*---------------------------------------------------------------------------
/* */

class specification VRComponent (0:1) of VRGeneric;


  instance VRComponent
  {
		/* component's index on segment */

	IGRshort			nIndex[VR_MAX_INST_CPTS];

		/* -- TOPOLOGY -- */

	struct VRCompOrientation 	Orientation;

	struct VRCompDescriptor 	Desc;

  };


/*--------------------------------------------------------------------------*/

override 	GRlocate_owner,

		ACgive_structure,/* in the case of correction component, get foot from
				   correction object */
		GRdelete,
		NDmove_to_root,
		NDdelete,	/* need to update the correction's instance data*/
		ACcheckin_candidate,	/* Just to avoid the Dangling to be Checked In */
		VRGetInstance,
		VRSetInstance,
		VRGetSysType,
		VRGetHangers,		/* correction components should ask their
				 	  owner for the hangers */
		VRGetCorrections,	/* correction components should return their 
				 	  owner */
		VRGetIndex,
		VRGetOrientationDef,
		VRGetMatrix,		/* Compute matrix using segment's info */
		VRGetCode,		/* Handle Automatic selection of component
					AABBCC code from user defined tables */
		VRSetCode,		/* Handle Automatic component
					AABBCC code override */
		VRGetNumberOfCpts,
		VRGetNeighbors,
		VRChgSupport,
		VRGetPlanesOnCpt,
		VRConnect,
		VRDisconnect,
		VDGetCenterLine,
		VRVerifyTopology;        

override        ACgive_db_structure;    /* just to adjust matrix for post
                                           of correction components   */

message VRReplace( struct GRas *assoc_list; struct GRmd_env *md_env;
		    char *go_cnst_lis );
/*---------------------------------------------------------------------------
/* VRReplace
/*
/*      Changes the whole component keeping the same object and dependancies.
/*
/*      Argument description : ( idem NDplace )
/*      --------------------
/*
/*  struct GRas 	*assoc_list 	I : structure with associative
/*					    information as described in
/*					    parametric.h. This structure
/*					    contains a pointer (as_attr)
/*					    which must be set to a VRGenInfo
/*					    structure containing specific
/*					    information.
/*
/* struct GRmd_env	*md_env		I : module environnement information.
/*
/* char			*go_cns_lis	I : Only the symbology field is used.
/*
/*
/* NOTE : TO BE USED VERY CAREFULLY ( ONLY BY THE I/ROUTE TEAM ).
/*---------------------------------------------------------------------------
/* */


message VRGetAngle ( IGRlong *msg ; IGRdouble *dAngle ;
			 struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetAngle
/*
/*      This message computes and returns the angle between the
/*	primary and secondary topologic templates
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRdouble		*dAngle  	O : Angle between Primary
/*					    and Secondary axes.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetPipeExtensions ( IGRlong *msg ; IGRdouble *dCptsCoor; struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRGetPipeExtensions
/*
/*      This message returns the connect points of the adjacent
/*	components.
/*	This message is dedicated to the cache management.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRdouble		*dCptsCoor  	O : Adjacent connect points
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRSetOrientationDef ( IGRlong *msg ; struct GRid PrimaryId; IGRdouble *dPrimary; struct GRid SecondaryId; IGRdouble *dSecondary );

/************************************************************************/
/*  to allow more than the maximum of five connectpoints the            */
/*  indexarray needs to be extended. Therefore these two methods are    */
/*  introduced to store and retrieve these indexvalues in a             */
/*  transparent way                                                     */

message VRGetMEIX (IGRlong  *msg ;     /* retrieve instance cptindex    */
                   IGRshort  nIX;      /* arrayindex (cptno)            */
                   IGRshort *nVIX);    /* indexvalue                    */

message VRSetMEIX (IGRlong  *msg ;     /* store instance cptindex       */
                   IGRshort  nIX;      /* arrayindex (cptno)            */
                   IGRshort  nVIX);    /* indexvalue                    */
/************************************************************************/

end specification VRComponent;

