class specification HSactive (1:0) of CEO_LOCATE;




instance HSactive
{
	IGRlong accuracy;
	};


message get_dpb_props ( long * sts );

message display_current_value ( long * sts );

message set_dpb_props ( long * sts );

message process_accuracy_keyin ( long * sts );

end specification HSactive;
