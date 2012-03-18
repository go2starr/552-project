//NOR2 Gate for use in these modules
module nor2 (in1,in2,out);
input in1,in2;
output out;
assign out = ~(in1 | in2);
endmodule

