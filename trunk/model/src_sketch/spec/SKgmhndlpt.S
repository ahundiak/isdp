class specification SKgmhndlpt (2:0) of GR3dpoint;

instance SKgmhndlpt
  {
  IGRint type;
  IGRint num_prim_pts;
  variable IGRpoint prim_pts[];
  IGRint num_sec_pts;
  variable IGRpoint sec_pts[];
  };

#ifndef BASE_EMS

message SKinit (IGRlong *msg; IGRushort opts;
                IGRint type;
                IGRint num_prim_pts; IGRpoint *prim_pts;
                IGRint num_sec_pts; IGRpoint *sec_pts);

message SKgetinst (IGRlong *msg;
                   IGRint *type;
                   IGRint *num_prim_pts; IGRdouble **prim_pts;
                   IGRint *num_sec_pts; IGRdouble **sec_pts);



override 
	GRgetobjinfo,
	GRdisyourself,
	GRplotyourself, /* prevent it from ploting            */
	GRformatele,    /* prevent it from converting to IGDS */
        GRadd_to_display_list;

#endif

end specification SKgmhndlpt;

