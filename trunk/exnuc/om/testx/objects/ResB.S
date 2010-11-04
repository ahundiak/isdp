class specification ResB (1:0) of Root;

instance ResB
{
     int         bnum;

     channel {(rel_ordered,many_to_many)ResA.acb;}bca;
     channel {(rel_ordered,many_to_many)C;}bcs;
     channel {A;}bcca;
};

override unknown;

message assign_b ( int num );

message inc_b();

message show_b();

message add_one ( int *i; OM_S_OBJID *b_objid );


end specification ResB;
