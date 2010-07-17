/*---------------------------------------------------------------------------
/*
/*  VRRway.S
/*  Apr-17-91
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRRway
/*
/*		SUBCLASS OF:	VRProduct
/*
/*		NOTES:
/*
/*
/*
/*---------------------------------------------------------------------------
/* */

class specification VRRway (0:1) of VRProduct;

  instance VRRway
  {
  };

/*--------------------------------------------------------------------------*/


override VRGetProduct;
override VRGetSpecComp, VRGetSearch;
override VRRetrieveTeeCode, VRRetrieveElbowCode, VRRetrieveGeneralCode;

override VRProdKey;

end specification VRRway;
