class specification SendTime2 (1:0) of Root;

instance SendTime2
{
     channel {(rel_ordered,many_to_many)SendTime;}c1;
     channel {(rel_ordered,many_to_many)SendTime.c2;}c2;
};

end specification SendTime2;
