
/*----

    CLASS NAME:  COparaext
    SUBCLASS OF: COpara

    Abstract:  This Command Object extends a segment to an object point

 CHANGE HISTORY:


	jla  : 13-jan-87  design date 

---- */



class specification COparaext (0:1) of COpara;


instance COparaext
{
struct GRid list_id[3];          /* parent objid */
struct GRid context[3];          /* context of the objects */
IGRdouble   point[4];            /* point near extremity to extend */
GRclassid as_classid;            /* Classid of associativity */
};

override wakeup, execute;

end specification COparaext;
