class specification SendTime (1:0) of Root;

instance SendTime
{
     channel {(rel_ordered,many_to_many)SendTime2;} c1;
     channel {(rel_ordered,many_to_many)SendTime2.c2;} c2;
};

message dummy();
message dummy5(int a, b, c; short d; int e;);
message dummy10(int a, b, c; short d, e, f; int g, h, i, j;);

end specification SendTime;
