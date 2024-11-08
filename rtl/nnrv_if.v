`default_nettype none

module nnrv_if
# (
parameter DATA_WIDTH = 64,
parameter INSTR_WIDTH = 32,
parameter MASK_WIDTH = DATA_WIDTH >> 3,
parameter XLEN = 64
)
(
input wire i_clk,
input wire i_rst,

output wire [XLEN-1:0] o_ram_rd_addr,
output reg o_ram_rd_en,
output reg [MASK_WIDTH-1:0] o_ram_rd_mask,
input wire i_ram_rd_ready,
input wire [DATA_WIDTH-1:0] i_ram_rd_data,

output wire [INSTR_WIDTH-1:0] o_id_instr,
output wire [XLEN-1:0] o_id_cur_pc,
input wire i_id_jmp_stall,
input wire [XLEN-1:0] i_id_jmp_pc,
input wire i_id_hazard_stall,

input wire i_mem_ram_stall
);

/* define */

`define OP_INSTR_NOP        32'h00000013

/* local */

reg [XLEN-1:0] pc = {XLEN{1'b0}};
reg [INSTR_WIDTH-1:0] instr = {INSTR_WIDTH{1'b0}};

reg [XLEN-1:0] cur_pc = {XLEN{1'b0}};

assign o_ram_rd_addr = (i_id_jmp_stall) ? i_id_jmp_pc : pc;
assign o_id_instr = instr;
assign o_id_cur_pc = cur_pc;

initial begin
    o_ram_rd_en = 1'b1;
    o_ram_rd_mask = 8'b11111111;
end

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        pc <= {XLEN{1'b0}};
        cur_pc <= {XLEN{1'b0}};
        instr <= `OP_INSTR_NOP;
    end else if (i_id_jmp_stall) begin
        /* 
            when jmp_stall,
            assign i_id_jmp_pc to o_ram_rd_addr, so can get instr when next posedge,
            so cur_pc is the i_id_jmp_pc, pc is i_id_jmp_pc + 4.
        */
        pc <= i_id_jmp_pc + 4;
        cur_pc <= i_id_jmp_pc;
        instr <= (i_id_jmp_pc[2:0] == 3'b000) ?
            i_ram_rd_data[31 : 0] :
            i_ram_rd_data[63 : 32];
    end else if (!i_ram_rd_ready) begin
        /* 
            when instr ram is not ready,
            don't change pc, cur_pc, wait for ready signal,
            but send NOP to the pipeline.
        */
        pc <= pc;
        cur_pc <= cur_pc;
        instr <= `OP_INSTR_NOP;
    end else if (i_id_hazard_stall || i_mem_ram_stall) begin
        /* 
            when stall,
            don't change pc, cur_pc,
            don't change instr, hazard stall use instr to produce hazard signal.
        */
        pc <= pc;
        cur_pc <= cur_pc;
        instr <= instr;
    end else begin
        /* normal +4 next pc */
        pc <= pc + 4;
        cur_pc <= pc;
        instr <= (pc[2:0] == 3'b000) ?
            i_ram_rd_data[31 : 0] :
            i_ram_rd_data[63 : 32];
    end
end

endmodule
