/*
  ABSTRACT

  This class of owner geometries consists of entities which relate
  other graphic objects.  This class implies that the subclasses share
  a common channel which relates the owner object to one or more other
  graphics objects.

  This class forms a grouping with the following properties:

  1)  It is not nested; it will be flattened as it is added to
      another group.
  2)  It is not a member of the R-tree.
  3)  It can be a member of a B-tree.
  4)  Forms a flexible association for channels.
  5)  It forms a logical grouping.
  6)  It allows it members to be modified.

  HISTORY

  Gray Winn               Design and Coding Date.
  Gray Winn   09/17/87    Upgrade to 1.1 under new owner subclassing
  mrm         01/13/89    override GRadd_to_active_owner
*/

class specification GRgrgrp (1:0) of GRflxown;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/


#ifndef BASE_EMS

/*
Description
        Finds the union between two graphic groups and puts the results
        into a third graphic group (result_gg_id = my_gg_id union gg_id).

Arguments
        IGRlong *msg                    return code
        struct GRid *gg_id              graphic group
        struct GRid *result_gg_id       result graphic group

Notes
        If the third graphic group object id is the same as one of the graphic
        group object ids that the operation is being performed upon, the 
        contents of that group are replaced with the results from the operation.
*/
message GRunion 
(
  IGRlong *msg;
  struct GRid *gg_id;
  struct GRid *result_gg_id
);

/*
Description
        Finds the intersection between two graphic groups and puts the
        results into a third graphic group
        (result_gg_id = my_gg_id intersection gg_id).

Arguments
        IGRlong *msg                    return code
        struct GRid *gg_id              graphic group
        struct GRid *result_gg_id       result graphic group

Notes
        If the third graphic group object id is the same as one of the graphic
        group object ids that the operation is being performed upon, the 
        contents of that group are replaced with the results from the operation.
*/
message GRintersection 
(
  IGRlong *msg;
  struct GRid *gg_id;
  struct GRid *result_gg_id
);

/*
Description
        Finds the difference between two graphic groups and puts the results
        into a third graphic group (result_gg_id = my_gg_id difference gg_id).
   
Arguments
        IGRlong *msg                    return code
        struct GRid *gg_id              graphic group
        struct GRid *result_gg_id       result graphic group

Notes
        If the third graphic group object id is the same as one of the graphic
        group object ids that the operation is being performed upon, the 
        contents of that group are replaced with the results from the operation.
*/
message GRdifference 
(
  IGRlong *msg;
  struct GRid *gg_id; 
  struct GRid *result_gg_id
);

override 
  GRflexconn,             
  GRrigidconn,            
  GRadd_to_active_owner,
  GRgetobjinfo,
  GRconstruct,            
  GRanalyze_element;

#endif

end specification GRgrgrp;
