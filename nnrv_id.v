`default_nettype none

module nnrv_id
(
i_clk,
i_rst,

i_if_instr,

o_exec_op1,
o_exec_op2,
o_exec_type,
o_exec_rd,

o_reg_r1_en,
o_reg_r1,
i_reg_r1_reg,

o_reg_r2_en,
o_reg_r2,
i_reg_r2_reg
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

input wire [INSTR_WIDTH-1:0] i_if_instr;
output wire [XLEN-1:0] o_exec_op1;
output wire [XLEN-1:0] o_exec_op2;
output wire [3:0] o_exec_type;
output wire [4:0] o_exec_rd;

output wire o_reg_r1_en;
output wire [4:0] o_reg_r1;
input wire [XLEN-1:0] i_reg_r1_reg;

output wire o_reg_r2_en;
output wire [4:0] o_reg_r2;
input wire [XLEN-1:0] i_reg_r2_reg;

/* define */

`define OP_IMM      7'b0010011
`define LUI         7'b0110111
`define AUIPC       7'b0010111
`define OP          7'b0110011
`define JAL         7'b1101111
`define JALR        7'b1100111
`define BRANCH      7'b1100011
`define LOAD        7'b0000011
`define STORE       7'b0100011
`define MISC_MEM    7'b0001111
`define SYSTEM      7'b1110011

`define F3_ADD_SUB      3'b000
`define F3_SLT          3'b010
`define F3_SLTU         3'b011
`define F3_XOR          3'b100
`define F3_OR           3'b110
`define F3_AND          3'b111
`define F3_SLL          3'b001
`define F3_SRL_SRA      3'b101


`define OP_ADD          4'b0001
`define OP_SUB          4'b0010
`define OP_SLT          4'b0011
`define OP_SLTU         4'b0100
`define OP_XOR          4'b0101
`define OP_OR           4'b0110
`define OP_AND          4'b0111
`define OP_SLL          4'b1000
`define OP_SRL          4'b1001
`define OP_SRA          4'b1010

/* local */

wire [6:0] opcode;
wire [4:0] rd_idx;
wire [4:0] rs1_idx;
wire [4:0] rs2_idx;
wire [2:0] funct3;
wire [6:0] funct7;
wire [5:0] imm_30_25;
wire [3:0] imm_24_21;
wire [3:0] imm_11_8;
wire [7:0] imm_19_12;
wire [10:0] imm_30_20;
wire imm_30;
wire imm_20;
wire imm_7;
wire imm_sign;
wire shamt_5;
wire [XLEN-1:0] i_imm;
wire [XLEN-1:0] s_imm;
wire [XLEN-1:0] b_imm;
wire [XLEN-1:0] u_imm;
wire [XLEN-1:0] j_imm;

reg [XLEN-1:0] exec_op1 = {XLEN{1'b0}};
reg [XLEN-1:0] exec_op2 = {XLEN{1'b0}};
reg [3:0] exec_type = 4'b0;
reg [4:0] exec_rd = 5'b0;

reg reg_r1_en = 1'b1;
reg reg_r2_en = 1'b1;

assign opcode = i_if_instr[6:0];
assign rd_idx = i_if_instr[11:7];
assign rs1_idx = i_if_instr[19:15];
assign rs2_idx = i_if_instr[24:20];
assign funct3 = i_if_instr[14:12];
assign funct7 = i_if_instr[31:25];
assign imm_30_25 = i_if_instr[30:25];
assign imm_24_21 = i_if_instr[24:21];
assign imm_11_8 = i_if_instr[11:8];
assign imm_19_12 = i_if_instr[19:12];
assign imm_30_20 = i_if_instr[30:20];
assign imm_sign = i_if_instr[31];
assign imm_7 = i_if_instr[7];
assign imm_20 = i_if_instr[20];
assign imm_30 = i_if_instr[30];
assign i_imm =  {{21{imm_sign}}, imm_30_25, imm_24_21, imm_20};
assign s_imm = {{21{imm_sign}}, imm_30_25, imm_11_8, imm_7};
assign b_imm = {{20{imm_sign}}, imm_7, imm_30_25, imm_11_8, 1'b0};
assign u_imm = {imm_sign, imm_30_20, imm_19_12, 12'b0};
assign j_imm = {{12{imm_sign}}, imm_19_12, imm_20, imm_30_25, imm_24_21, 1'b0};
assign shamt_5 = i_if_instr[24:20];

assign o_reg_r1_en = reg_r1_en;
assign o_reg_r2_en = reg_r2_en;
assign o_reg_r1 = rs1_idx;
assign o_reg_r2 = rs2_idx;

assign o_exec_op1 = exec_op1;
assign o_exec_op2 = exec_op2;
assign o_exec_type = exec_type;
assign o_exec_rd = exec_rd;

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        exec_rd <= 5'b0;
        exec_op1 <= {XLEN{1'b0}};
        exec_op2 <= {XLEN{1'b0}};
        exec_type <= 4'b0;
    end else begin
        exec_rd <= rd_idx;
        case(opcode)
        `OP_IMM :    begin
                    exec_op1 <= i_reg_r1_reg;
                    exec_op2 <= i_imm;
                    case(funct3)
                    `F3_ADD_SUB: begin
                                exec_type <= `OP_ADD;
                                end
                    `F3_SLT:     begin
                                exec_type <= `OP_SLT;
                                end
                    `F3_SLTU:    begin
                                exec_type <= `OP_SLTU;
                                end
                    `F3_XOR:     begin
                                exec_type <= `OP_XOR;
                                end
                    `F3_OR:      begin
                                exec_type <= `OP_OR;
                                end
                    `F3_AND:     begin
                                exec_type <= `OP_AND;
                                end
                    `F3_SLL:     begin
                                exec_type <= `OP_SLL;
                                end
                    `F3_SRL_SRA: begin
                                case(imm_30)
                                1'b0:    begin
                                        exec_type <= `OP_SRL;
                                        end
                                1'b1:    begin
                                        exec_type <= `OP_SRA;
                                        end
                                endcase
                                end
                    endcase
                    end
        `LUI      :  begin
                    end
        `AUIPC    :  begin
                    end
        `OP       :  begin
                    exec_op1 <= i_reg_r1_reg;
                    exec_op2 <= i_reg_r2_reg;
                    case(funct3)
                    `F3_ADD_SUB: begin
                                case(imm_30)
                                1'b0:    begin
                                        exec_type <= `OP_ADD;
                                        end
                                1'b1:    begin
                                        exec_type <= `OP_SUB;
                                        end
                                endcase
                                end
                    `F3_SLT:     begin
                                exec_type <= `OP_SLT;
                                end
                    `F3_SLTU:    begin
                                exec_type <= `OP_SLTU;
                                end
                    `F3_XOR:     begin
                                exec_type <= `OP_XOR;
                                end
                    `F3_OR:      begin
                                exec_type <= `OP_OR;
                                end
                    `F3_AND:     begin
                                exec_type <= `OP_AND;
                                end
                    `F3_SLL:     begin
                                exec_type <= `OP_SLL;
                                end
                    `F3_SRL_SRA: begin
                                case(imm_30)
                                1'b0:    begin
                                        exec_type <= `OP_SRL;
                                        end
                                1'b1:    begin
                                        exec_type <= `OP_SRA;
                                        end
                                endcase
                                end
                    endcase
                    end
        `JAL      :  begin
                    end
        `JALR     :  begin
                    end
        `BRANCH   :  begin
                    end
        `LOAD     :  begin
                    end
        `STORE    :  begin
                    end
        endcase
    end
end

endmodule
