/*
   ABSTRACT :
   --------

 Temp class giving to_own channel to place holder 
*/


class specification ACpl_hold(0:1) of GRconnector  ;

override   	    GRdisyourself;
override   	    GRaddwrng,GRremwrng;
override   	    GRdelete,GRcopy;
override 	    GRchgprops,GRgetprops;
override 	    GRlnproject;
override 	    GRxform;

override 	unknown;

end specification ACpl_hold;
