	
/*
ABSTRACT : 
         The abstract class ASref is the parent class for all the parametric
         local coordinate system with associations build into the design as
         constraints

          The user can connect any regular element to this local coordinate
          system. These elements will stay at the same local coordinate if the
          local coordinate system  moves.
       



CHANGE HISTORY
	
  jla          22 nov  86 : design date
  D.Payannet   15 mar  87 : Use of coordonate system as graphic image
*/


class specification ASref (0:1) of ASgencs;

override GRvg;
 override GRnotify;
override GRgencs;

end specification ASref;
