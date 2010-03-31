/*
  ABSTRACT

  This class represents composite surfaces that result from revolving
  a curve about an axis.


  HISTORY

  14 October 87   AIC     Creation Date.
  dhm    8/9/88   Overrode GRgetsfsize and GRloadform.
  msm    5/22/91  Removed the override for GRloadform.
                  Overrode GRreport, GRreport_defaults, GRupdate_gadgets.
*/

class specification EMSrevcompsf (1:0) of EMSswcompsf;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/
 
#ifndef BASE_EMS

override
  EMoffset,
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMget_params;

#endif

end specification EMSrevcompsf;
