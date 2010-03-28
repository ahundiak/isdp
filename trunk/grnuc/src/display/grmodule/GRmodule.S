class specification GRmodule (1:0) of  IGEdisplay , module;

#ifdef SUNOS5
%undef sleep
#endif


instance GRmodule 
 {
  struct DPfnt_os_tbl *fnt_os_tbl_ptr;
 };

override DPdisbyoid, DPdisbybuf, DPupdate, DPerase_hilite;

override mod_init,wake_up, sleep;


message GRmdaddwrng (IGRlong        *msg;
                     IGRdouble      *range;
                     GRobjid        *objid);

message GRmdnbrwrng (IGRlong        *msg;
                     IGRdouble      *range;
                     GRobjid        *nbrid);

message GRmdremwrng (IGRlong        *msg;
                     IGRdouble      *range;
                     GRobjid        *rem_objid);


message GRmdremove  (IGRlong        *msg;
                     IGRdouble      *range;
                     GRobjid        *rem_objid);

message GRadd_fnt (IGRlong        *msg; 
                   IGRshort       virt_font_no;
		   IGRint	  font_id;
		   IGRdouble	  body_size;
		   IGRdouble	  decent;
		   IGRint	  flags);


message GRadd_fnt_tbl (IGRlong     *msg;        
                       IGRshort    fst_char_fnt;
		       IGRshort	   fst_frac_fnt;
		       IGRshort	   fst_16bit_fnt);


message GRchg_fst_fnt (IGRlong    *msg;
                       IGRshort   fst_char_fnt;
		       IGRshort	  fst_frac_fnt;
		       IGRshort	  fst_16bit_fnt);

message GRdel_fnt (IGRlong     *msg; 
                   IGRshort    virt_font_no);

message GRdel_fnt_tbl (IGRlong     *msg);

message GRmdinfntptr (IGRlong              *msg;
                      struct DPfnt_os_tbl  **fnt_ptr);


end specification GRmodule;
