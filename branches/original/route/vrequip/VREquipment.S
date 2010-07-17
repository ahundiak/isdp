/*
/*---------------------------------------------------------------------------
/*  VRequipment.S
/*  Author : K. Barbette
/*  20-January-1993
/*
/*  Abstract
/*	New class for occurence of equipment.
/*
/*		Equipment support two parameters box in templates following
/*		by graphics templates.
/*		Equipment manage the relation with the data base and the
/*		graphic who it represent in dgn file.
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification VREquipment (0:1) of VRGeneric, VRProduct;


  instance VREquipment
  {
	variable	IGRchar		EquipNo[];
  };


/*--------------------------------------------------------------------------
/* */
message	VRPlaceNozzleFeet( IGRlong *ret; IGRint *NbNozzle; 
			   struct  GRid *NozzleIds;
			   struct GRmd_env *md_env);

message	VRGetRefId ( IGRlong *msg; struct GRid *RefId );

message	VRUpdateDynAttr ( IGRlong *msg; struct GRmd_env *md_env );

message VRReplace ( 	IGRlong 		*msg; 
			struct GRid 		NewEquip; 
			struct GRmd_env 	*md_env );

override	VRGetInstance;
override	VRSetInstance;
override	VREvaluate;
override	VRGetDefName;
override	VRGetSysType;
override	GRgetobjinfo;
override	ACgive_structure;
override 	VRGetSearch;
override 	VRGetMatrix;
override	VRGetSpecComp;
override	ACset_NV_rep;
override	GRgetattr;
override	GRputattr;
override	GRdelete;

end specification VREquipment;
