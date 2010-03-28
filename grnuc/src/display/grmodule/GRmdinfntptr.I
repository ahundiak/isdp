class implementation GRmodule;

method  GRmdinfntptr (IGRlong 	        *rc;
	       struct DPfnt_os_tbl	**fnt_ptr)

{
    *rc = MSSUCC;
    *fnt_ptr = ME.GRmodule->fnt_os_tbl_ptr;
    return (OM_S_SUCCESS);
}
end implementation GRmodule;
