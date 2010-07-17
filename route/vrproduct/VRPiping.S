/*---------------------------------------------------------------------------
/*
/*  VRPiping.S
/*  Oct-22-90
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRPiping
/*
/*		SUBCLASS OF:	VRProduct
/*
/*		NOTES:
/*
/*
/*
/*---------------------------------------------------------------------------
/* */

class specification VRPiping (0:1) of VRProduct;

  instance VRPiping
  {
  };

/*--------------------------------------------------------------------------*/


override VRGetProduct;
override VRGetSpecComp, VRGetSearch;
override VRRetrieveTeeCode, VRRetrieveElbowCode, VRRetrieveGeneralCode;

override VRProdKey;

end specification VRPiping;
