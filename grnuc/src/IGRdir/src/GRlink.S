/* #######################    APOGEE COMPILED   ######################## */
/*

  ABSTRACT :
  --------

     This class defines the link of a reference file.  It contains a 
  channel to the context object.


  HISTORY :
  -------

  08/30/1988 : HGB - Creation Date
*/

class specification GRlink ( 0:0 ) of DIlink;

 instance GRlink
 {
   /* the channel to the GRcontext */
   channel { (one_to_one, initial = 1, increment = 1) } to_context;
 };

end specification GRlink;


