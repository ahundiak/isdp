/*
   ABSTRACT

  Class to store symbology of a foot element
*/

class specification ACsymb_hold (0:1) of NDnodein,GRvg;


override            GRdisyourself;
override            GRaddwrng,GRremwrng;
override            GRdelete,GRcopy;
override            GRchgprops,GRgetprops;
override            GRlnproject;
override            GRxform;
reject 	    GRgetrang;

end specification ACsymb_hold;
