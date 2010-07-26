class specification exp_pm (0:1) of expression;

instance exp_pm
  { char type;  /* type of the expression SCALAR, DISTANCE or ANGLE */
  };

override 	create_type, NDcompute_node, modify, NDplace, NDprint,
		set_type, get_type, give_value_type, NDgive_structure;

end specification exp_pm;
