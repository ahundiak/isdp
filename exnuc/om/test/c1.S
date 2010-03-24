class specification c1 (1:0) of Root;

instance c1
{
     int     anum;
     variable char	ch[220];
};

message assign_a ( int num );

message inc_a();

message show_a();

message var_assign_char(int newsize);

message var_show_char();


end specification c1;
