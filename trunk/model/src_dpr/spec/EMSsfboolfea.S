/*
  ABSTRACT

  This is a class which represents surface boolean feature objects.


  HISTORY

  BL  06/21/90	Creation Date.
*/

class specification EMSsfboolfea (1:0) of EMSfeature, EMSsfboolean;

/*------------------ INSTANCE DATA SECTION -------------------*/

override  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  GRgetobjinfo,
  EMmatch,
  EMfixInGeomIds,
  EMgetsolidclass,
  EMpartial_delete_group_feature;

#endif

end specification EMSsfboolfea;

