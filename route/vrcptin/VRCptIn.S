/*---------------------------------------------------------------------------
/*
/*  VRCptIn.S
/*  18-Nov-91
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRCptIn
/*
/*		SUBCLASS OF:	VRGeneric.
/*
/*		NOTES: 	The VRCptIn object is used for routing ACCROSS
/*			reference files. It is connected as dependant
/*			of a pretendin object which ensure the inter_OS
/*			connection.
/*			It transfers all messages concerning the component
/*			to its component template.
/*
/*---------------------------------------------------------------------------
/* */

class specification VRCptIn (0:1) of VRGeneric;

	instance VRCptIn
	{
		/* -- Index on segment -- */

		IGRshort	nIndex;

		/* -- Component's connect point number -- */

		IGRshort	nCpNum;
	};


/*--------------------------------------------------------------------------*/
override
		/* -------------------------- */
		/* -- Associative behavior -- */
		/* -------------------------- */

		ASreturn_go,		/* Sent back to the ACpretendin */
		ACconstruct_feet,	/* No graphics created */
		NDmove_to_root,		/* Get deleted */
		VRGetDefName,


		/* ---------------------- */
		/* -- Instances access -- */
		/* ---------------------- */

		VRSetInstance,
		VRGetStatus,		/* Get status from real component */
		ACget_NV_rep,		/* Get rep from real component */
		GRgetsymb,		/* Get symb from real component */
		
		/* -------------------------- */
		/* -- Graph objects access -- */
		/* -------------------------- */

		VRGetIndex,		/* Index stored in my instances */
		VRConnect,		/* Only one segment can be connected */
		VRDisconnect,		/* needed to delete the dep. plane */
		VRChgSupport,		/* Only one segment can be changed */
		VRGetCptOnSup,		/* Only works with segments in the current
					   object space */
		VRGetSupOnCpt,		/* Only works with segments in the current
					   object space */

		/* ------------------------------------- */
		/* -- Network connections description -- */
		/* ------------------------------------- */

		VRGetCptGeom,		/* Send back to real component */
		VRSelectCptByGeom,	/* Send back to real component */
		VRGetNumberOfCpts,	/* Return only one cpt */
		VRGetCptProp;		/* Send back to real component */

/* MESSAGES WHICH STILL WORK */

/*
		VRGetConnDesc,		 one works in current object space 
		VRGetNeighbors,		????? ???
	NDplace			Will work with the override of VRSetInstance,
				VRGetDefName and ACconstruct feet.
	VRGetCorrections	Will only return one correction.
	VRGetCorOnCpt		Will work only for corrections in the current
				object space.
 	VRGetSupports 		Since the segments templates are the last
				me->nNbTopo ones.
	VRNotifyLengthModif 	Will work since VRGetSupports works.

	VRGetNextOnCpt		Will only work with segment in the current
				object space.
	VRGetOrientationDef;
*/

/* NEW MESSAGES */

/* Returns the connection point number */
message VRGetCptNum ( IGRshort *nCptNum );

/* MESSAGES WHICH SHOULD NOT GET CALLED */

reject 		VRGetParams,		/* No parameters for this component */
		VRGetCode,
		VREvaluate,
		VRSetStatus,
		VRSetCode,
		VRGetMatrix,
		VRGetFlow,
		VRSetFlow,
		VRIsGeometricAttr,
		VRGetHangers,
		VRChgParams,
		VRGetModel,
		VRGetErrGraphic,
		VRGetErrGeom,
		VRGetTopo,
		VRGetInstance,
		VRGetSysType,
		VRGetCompDesc,
		VRGetOrigCoor,
		VRGetPlanes,		/* Should always be sent to the reference component */
		VRGetPlanesOnCpt;	/* Should always be sent to the reference component */

end specification VRCptIn;
