class specification AScircle (0:1) of GRcircle, ASconic;

/*
ABSTRACT :
         The abstract class AScircle is the parent class for all the parametric
         circles with associations build into the design as constraints.


HISTORY : 
        c.Heraud  jul_87 : design date.
        jla       mar-87 : union class.
       momo       fev-89 : add ASpoststr method
*/


instance AScircle
{
   IGRchar r_signe; 
};

override GRvg;
override GRnotify;
override ASpoststr;

end specification AScircle;
