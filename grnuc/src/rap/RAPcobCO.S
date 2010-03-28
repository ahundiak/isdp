class specification RAPcobCO (1:0) of CEO_LOCATE;






override init;

message does_listener_exist ( long * sts );

message remove_last_command ( long * sts );

message have_filename (int *sts;  int  file_flag);

message stop_record ( long * sts );

end specification RAPcobCO;
