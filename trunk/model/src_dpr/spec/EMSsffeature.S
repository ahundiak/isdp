/*
  ABSTRACT

  This is a class which represents the new surface boolean feature objects
  implemented for Phoenix. 

 
  HISTORY

  NP  06/23/93	Creation.
*/

class specification EMSsffeature (1:0) of EMSsfboolfea;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsffeature
{
  IGRulong props;  
};

override  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  GRgetobjinfo,
  EMgetsolidclass,
  EMgetInGeomIds, 
  EMconstruct_associative,
  EMdeactivate,
  EMdim,
  EMdimparam;

#endif

end specification EMSsffeature;

