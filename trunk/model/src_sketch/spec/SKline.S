class specification SKline (2:0) of SKgeometry, GR3dlineseg;

from SKgeometry inherit
  GRdetplane, GRcopy, GRlocate, GRdelete, GRgetobjinfo, GRmksource, debug;

#ifndef BASE_EMS

override 
 GRrevparm,
 SKrecompute_yourself,
 NDnotify_disconnect /* we want to disconnect constraints when dimensions
                        are attached to some other profile */,
 NDnotify_connect /* we want to connect constraints when dimensions
                     are attached */,
 GRcpparallel;

#endif

end specification SKline;
