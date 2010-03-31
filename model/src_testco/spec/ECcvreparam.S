/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION
    
    This command locates a sequence of writable, orphan, curves (GRbspline)
    for manipulation of it's parameterization. The user manpulates 
    equi-parameter points on this sequence of curves in order to obtain
    a grid with desirable characteristics. The parameterization of the curves
    is adjusted to follow this grid pattern. Even a single curve can be
    manipulated this way. An option to first parameterize the curves by
    arc-length is available.

  NOTES

    The curves located are modified, but not by shape. If a non-free-form
    curve is to be re-paramterized, it changes class to a free-form.

  HISTORY

    SS  :  4/20/89
*/

class specification ECcvreparam (1:2) of ECelements;

#define DEFAULT_NUMPTS_PER_CV	5

instance ECcvreparam
  {
  IGRboolean parbylen;
  IGRint numpts_per_cv;
  IGRboolean incomplete_inxprocess;
  IGRint proc_cvinx, proc_ptinx;
  IGRboolean ptdata_valid;
  variable IGRdouble pts[][3];
  variable IGRboolean ptaltered[];
  };

override init, execute, get_locate_criteria;

message data_init (IGRlong *msg);

message ptdata_modify (IGRlong *msg; enum EMSuser_responses *useract;
                       struct GRevent *lastevent; 
                       IGRint *response; IGRchar *response_data);

message cvdata_modify (IGRlong *msg);

end specification ECcvreparam;
