/*---------------------------------------------------------------------------
/*
/*  VRHvac.S
/*  Jan-22-91
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRHvac
/*
/*		SUBCLASS OF:	VRProduct
/*
/*		NOTES:
/*
/*
/*
/*---------------------------------------------------------------------------
/* */

class specification VRHvac (0:1) of VRProduct;

  instance VRHvac
  {
  };

/*--------------------------------------------------------------------------*/

override VRGetProduct;
override VRGetSpecComp, VRGetSearch;
override VRRetrieveTeeCode, VRRetrieveElbowCode, VRRetrieveGeneralCode;

override VRProdKey;

end specification VRHvac;
