`default_nettype none

module nnrv_reg
(
i_clk,
i_rst,

i_r1_en,
i_r1,
i_r2_en,
i_r2,

i_w_en,
i_w,
i_w_reg,

o_r1_reg,
o_r2_reg
);

/* parameter */

parameter XLEN = 32;
parameter REG_NUM = 32;

/* port */

input wire i_clk;
input wire i_rst;

input wire i_r1_en;
input wire [4:0] i_r1;
input wire i_r2_en;
input wire [4:0] i_r2;

input wire i_w_en;
input wire [4:0] i_w;
input wire [XLEN-1:0] i_w_reg;

output wire [XLEN-1:0] o_r1_reg;
output wire [XLEN-1:0] o_r2_reg;

/* define */


/* local */

reg [XLEN-1:0] regs [0:REG_NUM-1];

assign o_r1_reg = (i_r1_en) ? regs[i_r1] : {XLEN{1'b0}};
assign o_r2_reg = (i_r2_en) ? regs[i_r2] : {XLEN{1'b0}};

integer i;
initial
begin
    for (i = 0; i < REG_NUM; i = i + 1) begin
        regs[i] <= {XLEN{1'b0}};
    end
end

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        for (i = 0; i < REG_NUM; i = i + 1) begin
            regs[i] <= {XLEN{1'b0}};
        end
    end else if (i_w_en && i_w) begin
            regs[i_w] <= i_w_reg;
    end
end

endmodule
