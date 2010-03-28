class specification CO_hilite (0:1) of COpara;

instance CO_hilite
  {
   struct GRid object;   /* object to hilite parents */
   struct GRid *list;    /* depency  */
  };

override wakeup, execute;

end specification CO_hilite;
