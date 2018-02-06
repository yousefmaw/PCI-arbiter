module SimpleInitiator (start,clk,REQ,GNT,FRAME,IRDY,I_AM_OWNER,GLOBAL_IRDY);
input wire clk,GNT,start;
input wire GLOBAL_IRDY;
output reg REQ = 1,FRAME = 1,I_AM_OWNER = 0,IRDY =1  ;

integer counter = 0;

wire IDLE ;
assign IDLE = FRAME & GLOBAL_IRDY ;

reg pipeline1 =1,pipeline2 =1,pipeline3 =1,pipeline4 =1,pipeline5 = 1 ;

always @(posedge clk)
begin
if(start & (GNT) & FRAME)
begin
	@(negedge clk)
	REQ<=0;
end
else if ((~GNT)  && IDLE & (~ REQ) )
begin
	@(negedge clk)
	REQ<=1;
	FRAME <= 0 ;
end
else if(~ pipeline4 && pipeline5)
begin
@(negedge clk)
FRAME <=1 ;
end


end

always @(posedge clk)
begin

if(~ pipeline1 && pipeline2)
begin
@(negedge clk)
IRDY <= 0;
end

else if (~ pipeline5)
begin
@(negedge clk)
IRDY <=1;
end

end


always @(posedge clk)
begin

 if ((~GNT)  && IDLE & (~ REQ) )
begin
	@(negedge clk)
	I_AM_OWNER<=1;
end
else if (~ pipeline5)
begin
@(negedge clk)
I_AM_OWNER<=0;
end

end


always @(posedge clk)
begin
pipeline1 <= FRAME ;
pipeline2 <= pipeline1;
pipeline3 <= pipeline2;
pipeline4 <= pipeline3;
pipeline5 <= pipeline4;


end


endmodule
module SpecializedMux(I_AM_OWNERS,IRDYS,FRAMES,GLOBAL_IRDY,GLOBAL_FRAME);

input [7:0] I_AM_OWNERS,IRDYS,FRAMES;
output wire GLOBAL_IRDY,GLOBAL_FRAME;

assign {GLOBAL_IRDY,GLOBAL_FRAME} = 
(I_AM_OWNERS[0]) ? {IRDYS[0],FRAMES[0]} :
(I_AM_OWNERS[1]) ? {IRDYS[1],FRAMES[1]} :
(I_AM_OWNERS[2]) ? {IRDYS[2],FRAMES[2]} :
(I_AM_OWNERS[3]) ? {IRDYS[3],FRAMES[3]} :
(I_AM_OWNERS[4]) ? {IRDYS[4],FRAMES[4]} :
(I_AM_OWNERS[5]) ? {IRDYS[5],FRAMES[5]} :
(I_AM_OWNERS[6]) ? {IRDYS[6],FRAMES[6]} :
(I_AM_OWNERS[7]) ? {IRDYS[7],FRAMES[7]} : {1'b1,1'b1};

endmodule
module arbiter (clk,req,gnt,frame,irdy,trdy);
input wire clk ,irdy,frame,trdy;
input wire [7:0] req;
output reg [7:0] gnt;
reg [7:0] fifo[7:0];
integer pointer;
reg lastframe;
reg trflag;
reg [7:0]lastreq;
initial
begin
lastframe=1'b1;
trflag = 1'b0 ;
gnt = 8'hff ;
pointer= 0;
lastreq = 8'hff ;
end
always@(posedge clk)
begin
if(lastframe && ~frame)
begin
trflag=1'b1;lastframe =frame;
end
end
if(trflag==1)
begin
@(negedge clk)
gnt=fifo[0]; pointer = pointer - 1;
fifo[0]=fifo[1];fifo[1]=fifo[2];fifo[2]=fifo[3];fifo[3]=fifo[4];fifo[4]=fifo[5];fifo[5]=fifo[6];fifo[6]=fifo[7];trflag=1'b0;
end

if (lastreq != req)
begin
@(negedge clk)
req=fifo[pointer];pointer = pointer + 1;

end

endmodule
module arbiterTB;

reg clk;
wire [7:0] GNT;
wire [7:0] FRAMES , IRDYS, I_AM_OWNERS;
wire GLOBAL_IRDY , GLOBAL_FRAME;
wire [7:0] REQ;
reg [7:0] STARTS = 8'h00;

always 
begin
#5
clk <= ~ clk;
end

initial 
begin
clk <= 0;
#20
STARTS[0] <= 1;
#20
STARTS[1] <= 1;
#20
STARTS[2] <= 1;
#20
STARTS[3] <= 1;
#200
STARTS[3] <= 0;
#20 
STARTS[5] <= 1;
STARTS[7] <= 1;
STARTS[1] <= 0;
STARTS[0] <= 0;
end

SpecializedMux myMux(I_AM_OWNERS,IRDYS,FRAMES,GLOBAL_IRDY,GLOBAL_FRAME);

arbiter A(clk,REQ,GNT,GLOBAL_FRAME,GLOBAL_IRDY, 1'b1);

SimpleInitiator simple0 (STARTS[0],clk,REQ[0],GNT[0],FRAMES[0],IRDYS[0],I_AM_OWNERS[0] , GLOBAL_IRDY);
SimpleInitiator simple1 (STARTS[1],clk,REQ[1],GNT[1],FRAMES[1],IRDYS[1],I_AM_OWNERS[1] , GLOBAL_IRDY);
SimpleInitiator simple2 (STARTS[2],clk,REQ[2],GNT[2],FRAMES[2],IRDYS[2],I_AM_OWNERS[2] , GLOBAL_IRDY);
SimpleInitiator simple3 (STARTS[3],clk,REQ[3],GNT[3],FRAMES[3],IRDYS[3],I_AM_OWNERS[3] , GLOBAL_IRDY);
SimpleInitiator simple4 (STARTS[4],clk,REQ[4],GNT[4],FRAMES[4],IRDYS[4],I_AM_OWNERS[4] , GLOBAL_IRDY);
SimpleInitiator simple5 (STARTS[5],clk,REQ[5],GNT[5],FRAMES[5],IRDYS[5],I_AM_OWNERS[5] , GLOBAL_IRDY);
SimpleInitiator simple6 (STARTS[6],clk,REQ[6],GNT[6],FRAMES[6],IRDYS[6],I_AM_OWNERS[6] , GLOBAL_IRDY);
SimpleInitiator simple7 (STARTS[7],clk,REQ[7],GNT[7],FRAMES[7],IRDYS[7],I_AM_OWNERS[7] , GLOBAL_IRDY);

endmodule