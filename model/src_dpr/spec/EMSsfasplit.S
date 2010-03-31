/*
  ABSTRACT

  This class represents splitting of the surface areas into maximum
  possible regions with a set of boundaries and putting the result on
  state tree. It is similar to its parent class in all repects except that
  instead to creating new holes by imposing boundaries, existing area are split
  in place. No new surfaces are created. The resultant areas obtained after
  spliting existing ones reside in the same loopset.

  
  HISTORY

  SM	14-Mar-89	Creation.
*/

class specification EMSsfasplit (1:0) of EMSsfimpbnd;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;

end specification EMSsfasplit;
