/*
  DESCRIPTION

    This class behaves as a point at a vertex of a profile, during locate.
    Mostly, only one point of this class is ever constructed and is revolved
    around to fit the particular vertex being located.

  HISTORY
   
    SS  :  10/13/91  :  Creation
*/

class specification SKdumpt (2:0) of GR3dpoint;


instance SKdumpt
  {
    /*
     * object id from where it is originated 
     */
    struct GRid origin_id;
  };


message SKget_origin_id( long *msg; struct GRid *origin_id );
message SKput_origin_id( long *msg; struct GRid *origin_id );

override 
  GRgetobjinfo;

end specification SKdumpt;


