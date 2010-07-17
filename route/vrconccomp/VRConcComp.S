/*---------------------------------------------------------------------------
/*
/*  VRConcComp.S
/*  Mar-28-91
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRConcComp
/*
/*		SUBCLASS OF:	VRGeneric, VRconc
/*
/*		NOTES:
/*
/*
/*	* 09-DEC-91	1.4.3.14	
/*		Bruno
/*		- VRInitInstances method has been removed.
/*
/*      * 21-NOV-93     2.3.
/*              Lori
/*              - override VRVerifyTopology
/*
/*---------------------------------------------------------------------------
/* */

class specification VRConcComp (0:1) of VRconc, VRGeneric;

  instance VRConcComp
  {
		/* component's index on segment */

	IGRshort		nIndex[VR_MAX_INST_CPTS];

		/* -- TOPOLOGY -- */

	IGRshort		nOrienToPlanes[VR_MAX_INST_CPTS*3];
	IGRdouble		dAngleToCommon;

	IGRshort nConsIndex[(VR_MAX_INST_CPTS-1) *3];
					 /* list of planes index matching
					 /* constrains between Cpti planes and
					 /* Cpt0 planes
					 /**/
  };

/*--------------------------------------------------------------------------*/
override 
GRlocate_owner,
NDmove_to_root,
NDchange_connect,
ACgive_structure,
VRGetSysType,
VRSetInstance,
VRGetInstance,
VRConnect,
VRDisconnect,
VRGetMatrix,
VRGetIndex,
VRGetPlanesOnCpt,
VRget_nb_constrain,
VRget_constrain,
VRGetPlanes,
VRChgSupport,
VRVerifyTopology;

from VRconc inherit NDget_virtual_objects;

message VRAddPlanes(	IGRlong			*msg;
			IGRint			NbTopo;
			struct GRid 		*TopoIds;
			IGRshort		*ConstList;
			struct GRmd_env		*md_env );


/*---------------------------------------------------------------------------
/* VRAddPlanes
/*
/*      After having evaluated a component ( VRGeneric.VREvaluate ) VRAddPlanes
/*	creates component planes and update the Constrain list
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		TopoIdsSize	I : Buffer size.
/*
/* struct GRid		*TopoIds	I/O: Full template list initialised with
/*					     the known template ids at the right
/*					     index and NULL_OBJID at the missing
/*					     templates indexes. The built templates
/*					     Ids will be substituted to the NULL_OBJIDs.
/* IGRint		*ConstList	I :  List of index indicate for eatch
/*					     Cpti ( i>0 ) witch plane is
/*					     constrained with witch Cpt0 planes.
/* struct GRmd_env	*md_env		I : module env.
/* 
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

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

/*  The same approach is used for the constraints index, for which I    */
/*  have used the nOrienToPlanes array of which only element 0 was      */
/*  used......                                                          */

message VRGetMECI (IGRlong  *msg ;     /* retrieve instance cptindex    */
                   IGRshort  nCI;      /* arrayindex (cptno)            */
                   IGRshort *nVCI);    /* indexvalue                    */

message VRSetMECI (IGRlong  *msg ;     /* store instance cptindex       */
                   IGRshort  nCI;      /* arrayindex (cptno)            */
                   IGRshort  nVCI);    /* indexvalue                    */

/************************************************************************/


end specification VRConcComp;

