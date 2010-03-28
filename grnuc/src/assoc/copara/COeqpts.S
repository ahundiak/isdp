/*----

    Abstract:  This Command Object creates and displays equidistant points
	       between 2 equisting objects points This points can be on
	       a defined support

 CHANGE HISTORY:


	S.Frezefond : 20-jul-86 design
        jla           03-nov-86 associative implementation
	jla           20-mar-86 support implementation

---- */

class specification COeqpts (0:1) of COpara;


instance COeqpts
{
   struct GRid list_id[3];
   struct GRid context[3];
   IGRint num_id;
   IGRboolean closed;
};

override wakeup, execute;

end specification COeqpts;
