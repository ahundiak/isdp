class specification HScnghsform (1:0) of CEO_LOCATE;




instance HScnghsform
{
	struct GRhesym	visible_symbology;
	struct GRhesym	hidden_symbology;
	IGRboolean	display_hidden_lines;
	};


message set_defaults ( long * sts );

override form_notification;

end specification HScnghsform;
