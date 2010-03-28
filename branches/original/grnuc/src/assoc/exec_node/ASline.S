

class specification ASline (0:1) of GRlineseg,ASlinear;

/*\
ABSTRACT :
         The abstract class ASline is the parent class for all the parametric
         line with associations build into the design as constraints

         Method and instances defined in this class will allow the use of 
         the regular extend command. For example, a segment by 2 points can
         be given 2 offsets d0 and d1 to make it extend beyond or inside
	 its definition  points .

CHANGE HISTORY:
	
        jla       Oct-86 : design date
	ch        Jan-87 : offset
	jla       Mar-87 : union class
       momo       fev-89 : add the poststr method
\*/


instance ASline
  { IGRdouble d0,d1; /* offset of the line  */
		     /* positive outside    */
		     /* negative inside     */
  };

override GRvg;

message ASpostab
    (IGRlong *msg ;                  /* out return code                 */
      struct GRmd_env *md_env;       /* in current module environnement */
      struct ret_struct *linedef);   /* in geometry without extend      */
/*\
DESCRIPTION PRIVATE
Method called by compute_node to update the graphic object taking my
offset into account.
\*/


message ASchildlinext (IGRdouble d0, d1;
		       IGRvector old_v0,new_vo;
     		       struct GRmd_env *md_env);
/*\
ABSTRACT PRIVATE
When an associative line is extended, performs reverse extension 
on its parallel
IN d0       : offet increment for start point, positive to external
IN d1       : offet increment for end   point, positive to external
IN old_v0   : unit vector of line before extends
IN new_v0   : unit vector of line after extends
IN md_env   : module environment information
\*/

message ASlinext (IGRdouble d0, d1;
     		  struct GRmd_env *md_env);
/*\
ABSTRACT

this method increments the offsets d0,d1 of the element. It has no action
on depending elements.

ARGUMENTS

IN d0       : offet increment for start point, positive to external
IN d1       : offet increment for end   point, positive to external
IN md_env   : module environment information
\*/


message ASgetlinext(IGRdouble *d0,*d1);

/*\
ABSTRACT

this method returns the extends value of the target associative line

ARGUMENTS

OUT d0     : offset for start point
OUT d1     : offset for end   point
*/

override GRptextend,GRdisextend;
override ASpoststr;

/*\
MOTIVATION

GRptextend,GRdisextend : intercept the graphic message to update the offsets of
                 the associative line and the offsets of its parallel.
\*/

end specification ASline;
