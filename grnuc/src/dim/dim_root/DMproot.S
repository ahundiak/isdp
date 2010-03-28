class specification DMproot(2:0) of ASnode;

message change_copy(
	IGRint *msg;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env);

override ASreturn_go;
override NDcopy, NDcopy_to_root;

end specification DMproot;
