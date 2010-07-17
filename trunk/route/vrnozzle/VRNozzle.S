/*---------------------------------------------------------------------------
/*
/*---------------------------------------------------------------------------
/* */

class specification VRNozzle (0:1) of VRGeneric;


  instance VRNozzle
  {
		/* component's index on segment */

	IGRshort		nIndex[1];

		/* -- TOPOLOGY -- */

	IGRdouble		dSecAngle;	/* angle in radian */
  };


/*--------------------------------------------------------------------------
/* */

override GRgetobjinfo;
override GRxform;
override GRdelete;

override NDdelete;
override NDcopy;
override NDmove_to_root;
override ACgive_structure;
override ACconstruct_feet;

override VRGetInstance;
override VRSetInstance;
override VRGetSysType;
override VRGetIndex;
override VRGetMatrix;
override VRConnect;
override VRDisconnect;
override VRChgSupport;


message VRGetRefId ( IGRlong *msg; struct GRid *RefId );
/*--------------------------------------------------------------------------
/* VRGetRefId
/*		Returns the ID of the referential template of the nozzle.
/*
/*	Arguments description :
/*	---------------------
/*
/* IGRlong			*msg		O : MSSUCC if success and
/*						    MSFAIL if nozzle is
/*						    already connected to
/*						    a network.
/*
/* struct GRid			*RefId		O : pointer on referential
/*						    id structure.
/*
/* NOTE :
/*	This method has been implemented for the sketch command.
/*	IT MIGHT DISAPPEAR
/*
/*--------------------------------------------------------------------------
/* */

/* get the nozzle support and change its state */
message VRSetSoftConnection( IGRlong *msg );

end specification VRNozzle;
