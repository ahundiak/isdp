class specification ASarc (0:1) of GRcirarc,ASconic;

/*
ABSTRACT :
         The abstract class ASarc is the parent class for all the parametric
         circular arcs with associations build into the design as constraints


HISTORY : 
          ch       10-jul-86 : design
         jla       10-mar-87 : union class
        momo       06-fev-89 : add ASpoststr method;
*/


instance ASarc
{
 IGRchar r_signe;  /*  signe of the radius to accept negative value */
};

override GRvg;
override GRnotify;
override ASpoststr;

end specification ASarc;
