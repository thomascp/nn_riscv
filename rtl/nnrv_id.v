`default_nettype none

module nnrv_id
# (
parameter INSTR_WIDTH = 32,
parameter XLEN = 64,
parameter MASK_WIDTH = 8
)
(
input wire i_clk,
input wire i_rst,

input wire [INSTR_WIDTH-1:0] i_if_instr,
input wire [XLEN-1:0] i_if_pc,
output wire o_if_jmp_stall,
output wire [XLEN-1:0] o_if_jmp_pc,
output wire o_if_hazard_stall,

output wire [XLEN-1:0] o_exec_op1,
output wire [XLEN-1:0] o_exec_op2,
output wire [3:0] o_exec_type,
output wire o_exec_rd_en,
output wire [4:0] o_exec_rd,
output wire o_exec_rd_ready,
output wire [XLEN-1:0] o_exec_rd_reg,
output wire [MASK_WIDTH-1:0] o_exec_ram_mask,
output wire o_exec_sign,
output wire o_exec_op_32bit,

output wire o_reg_r1_en,
output wire [4:0] o_reg_r1,
input wire [XLEN-1:0] i_reg_r1_reg,

output wire o_reg_r2_en,
output wire [4:0] o_reg_r2,
input wire [XLEN-1:0] i_reg_r2_reg,

input wire i_exec_rd_en,
input wire i_exec_rd_ready,
input wire [4:0] i_exec_rd,
input wire [XLEN-1:0]i_exec_rd_reg,

input wire i_mem_rd_en,
input wire i_mem_rd_ready,
input wire [4:0] i_mem_rd,
input wire [XLEN-1:0]i_mem_rd_reg,

input wire i_mem_ram_stall
);

/* define */

`include "nnrv_defines.vh"

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
`define OP_IMM_32   7'b0011011
`define OP_32       7'b0111011

`define F3_ADD_SUB      3'b000
`define F3_SLT          3'b010
`define F3_SLTU         3'b011
`define F3_XOR          3'b100
`define F3_OR           3'b110
`define F3_AND          3'b111
`define F3_SLL          3'b001
`define F3_SRL_SRA      3'b101

`define F3_BEQ          3'b000
`define F3_BNE          3'b001
`define F3_BLT          3'b100
`define F3_BGE          3'b101
`define F3_BLTU         3'b110
`define F3_BGEU         3'b111

`define F3_SB           3'b000
`define F3_SH           3'b001
`define F3_SW           3'b010
`define F3_SD           3'b011

`define F3_LB           3'b000
`define F3_LH           3'b001
`define F3_LW           3'b010
`define F3_LD           3'b011
`define F3_LBU          3'b100
`define F3_LHU          3'b101
`define F3_LWU          3'b110

`define OP_INSTR_NOP        32'h00000013

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
wire [5:0] shamt_6;
wire [4:0] shamt_5;
wire [XLEN-1:0] i_imm;
wire [XLEN-1:0] s_imm;
wire [XLEN-1:0] b_imm;
wire [XLEN-1:0] u_imm;
wire [XLEN-1:0] j_imm;
wire [INSTR_WIDTH-1:0] id_instr;

wire rs1_valid;
wire rs2_valid;

wire id_hazard_stall;
wire id_rd_rs1_ready;
wire id_rd_rs2_ready;
wire exec_hazard_stall;
wire exec_rd_rs1_ready;
wire exec_rd_rs2_ready;
wire mem_hazard_stall;
wire mem_rd_rs1_ready;
wire mem_rd_rs2_ready;
wire hazard_stall;

reg [XLEN-1:0] op1 = {XLEN{1'b0}};
reg [XLEN-1:0] op2 = {XLEN{1'b0}};
reg [3:0] type = 4'b0;
reg rd_en = 1'b0;
reg [4:0] rd = 5'b0;
reg rd_ready = 1'b0;
reg [XLEN-1:0] rd_reg = {XLEN{1'b0}};
reg [MASK_WIDTH-1:0] ram_mask = 8'b00000000;
reg sign = 1'b0;

reg reg_r1_en = 1'b1;
reg reg_r2_en = 1'b1;

reg jmp_stall = 1'b0;
reg [XLEN-1:0] jmp_pc = {XLEN{1'b0}};

reg op_32bit = 1'b0;

wire [XLEN-1:0] r1_reg;
wire [XLEN-1:0] r2_reg;

assign id_instr = i_if_instr;

assign opcode = id_instr[6:0];
assign rd_idx = id_instr[11:7];
assign rs1_idx = id_instr[19:15];
assign rs2_idx = id_instr[24:20];
assign funct3 = id_instr[14:12];
assign funct7 = id_instr[31:25];
assign imm_30_25 = id_instr[30:25];
assign imm_24_21 = id_instr[24:21];
assign imm_11_8 = id_instr[11:8];
assign imm_19_12 = id_instr[19:12];
assign imm_30_20 = id_instr[30:20];
assign imm_sign = id_instr[31];
assign imm_7 = id_instr[7];
assign imm_20 = id_instr[20];
assign imm_30 = id_instr[30];
assign i_imm =  {{53{imm_sign}}, imm_30_25, imm_24_21, imm_20};
assign s_imm = {{53{imm_sign}}, imm_30_25, imm_11_8, imm_7};
assign b_imm = {{52{imm_sign}}, imm_7, imm_30_25, imm_11_8, 1'b0};
assign u_imm = {{33{imm_sign}}, imm_30_20, imm_19_12, 12'b0};
assign j_imm = {{44{imm_sign}}, imm_19_12, imm_20, imm_30_25, imm_24_21, 1'b0};
assign shamt_6 = id_instr[25:20];
assign shamt_5 = id_instr[24:20];

assign rs1_valid = (opcode == `JALR) || (opcode == `BRANCH) || (opcode == `LOAD) ||
                   (opcode == `STORE) || (opcode == `OP) || (opcode == `OP_IMM) ||
                   (opcode == `OP_32) || (opcode == `OP_IMM_32);
assign rs2_valid = (opcode == `BRANCH) || (opcode == `STORE) || (opcode == `OP) ||
                   (opcode == `OP_32);

assign o_if_jmp_stall = jmp_stall;
assign o_if_jmp_pc = jmp_pc;

assign o_reg_r1_en = reg_r1_en;
assign o_reg_r2_en = reg_r2_en;
assign o_reg_r1 = rs1_idx;
assign o_reg_r2 = rs2_idx;

assign o_exec_op1 = op1;
assign o_exec_op2 = op2;
assign o_exec_type = type;
assign o_exec_rd_en = rd_en;
assign o_exec_rd = rd;
assign o_exec_rd_ready = rd_ready;
assign o_exec_rd_reg = rd_reg;
assign o_exec_ram_mask = ram_mask;

assign o_exec_sign = sign;

assign o_exec_op_32bit = op_32bit;

assign id_hazard_stall = (rd_en) && (!rd_ready) && (rd != 0) &&
                (((rs1_valid) && (rd == rs1_idx)) || ((rs2_valid) && (rd == rs2_idx)));
assign id_rd_rs1_ready = (rd_en) && (rd_ready) && (rd != 0) && (rs1_valid) && (rd == rs1_idx);
assign id_rd_rs2_ready = (rd_en) && (rd_ready) && (rd != 0) && (rs2_valid) && (rd == rs2_idx);

assign exec_hazard_stall = (i_exec_rd_en) && (!i_exec_rd_ready) && (i_exec_rd != 0) &&
                (((rs1_valid) && (i_exec_rd == rs1_idx)) || ((rs2_valid) && (i_exec_rd == rs2_idx)));
assign exec_rd_rs1_ready = (i_exec_rd_en) && (i_exec_rd_ready) && (i_exec_rd != 0) && (rs1_valid) && (i_exec_rd == rs1_idx);
assign exec_rd_rs2_ready = (i_exec_rd_en) && (i_exec_rd_ready) && (i_exec_rd != 0) && (rs2_valid) && (i_exec_rd == rs2_idx);

assign mem_hazard_stall = (i_mem_rd_en) && (!i_mem_rd_ready) && (i_mem_rd != 0) &&
                (((rs1_valid) && (i_mem_rd == rs1_idx)) || ((rs2_valid) && (i_mem_rd == rs2_idx)));
assign mem_rd_rs1_ready = (i_mem_rd_en) && (i_mem_rd_ready) && (i_mem_rd != 0) && (rs1_valid) && (i_mem_rd == rs1_idx);
assign mem_rd_rs2_ready = (i_mem_rd_en) && (i_mem_rd_ready) && (i_mem_rd != 0) && (rs2_valid) && (i_mem_rd == rs2_idx);

assign hazard_stall = id_hazard_stall || exec_hazard_stall || mem_hazard_stall;
assign o_if_hazard_stall = hazard_stall;

assign r1_reg = (id_rd_rs1_ready)? rd_reg : (exec_rd_rs1_ready) ? i_exec_rd_reg : (mem_rd_rs1_ready) ? i_mem_rd_reg : i_reg_r1_reg;
assign r2_reg = (id_rd_rs2_ready) ? rd_reg : (exec_rd_rs2_ready) ? i_exec_rd_reg : (mem_rd_rs2_ready) ? i_mem_rd_reg : i_reg_r2_reg;

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst || jmp_stall || hazard_stall) begin
        /* move NOP to the post pipeline */
        rd_en <= 1'b0;
        type <= `OP_NOP;
        jmp_stall <= 1'b0;
        rd_ready <= 1'b0;
    end else if (i_mem_ram_stall) begin
        /* keep all as it is */
    end else begin
        rd <= rd_idx;
        case(opcode)
        `OP_IMM :   begin
                    jmp_stall <= 1'b0;
                    op1 <= r1_reg;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 0;
                    case(funct3)
                    `F3_ADD_SUB: begin
                                type <= `OP_ADD;
                                op2 <= i_imm;
                                end
                    `F3_SLT:     begin
                                type <= `OP_SLT;
                                op2 <= i_imm;
                                end
                    `F3_SLTU:    begin
                                type <= `OP_SLTU;
                                op2 <= i_imm;
                                end
                    `F3_XOR:     begin
                                type <= `OP_XOR;
                                op2 <= i_imm;
                                end
                    `F3_OR:      begin
                                type <= `OP_OR;
                                op2 <= i_imm;
                                end
                    `F3_AND:     begin
                                type <= `OP_AND;
                                op2 <= i_imm;
                                end
                    `F3_SLL:     begin
                                type <= `OP_SLL;
                                op2 <= shamt_6;
                                end
                    `F3_SRL_SRA: begin
                                case(imm_30)
                                1'b0:    begin
                                        type <= `OP_SRL;
                                        end
                                1'b1:    begin
                                        type <= `OP_SRA;
                                        end
                                endcase
                                op2 <= shamt_6;
                                end
                    endcase
                    end
        `OP_IMM_32: begin
                    jmp_stall <= 1'b0;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 1;
                    case(funct3)
                    `F3_ADD_SUB:begin
                                type <= `OP_ADD;
                                op1 <= r1_reg;
                                op2 <= i_imm;
                                end
                    `F3_SLL:    begin
                                type <= `OP_SLL;
                                op1 <= r1_reg;
                                op2 <= shamt_5;
                                end
                    `F3_SRL_SRA:begin
                                case(imm_30)
                                1'b0:   begin
                                        op1 <= {32'b0, r1_reg[31:0]};
                                        type <= `OP_SRL;
                                        end
                                1'b1:   begin
                                        op1 <= {{32{r1_reg[31]}}, r1_reg[31:0]};
                                        type <= `OP_SRA;
                                        end
                                endcase
                                op2 <= shamt_5;
                                end
                    endcase
                    end
        `LUI      : begin
                    jmp_stall <= 1'b0;
                    op1 <= 0;
                    op2 <= u_imm;
                    type <= `OP_ADD;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 0;
                    end
        `AUIPC    : begin
                    jmp_stall <= 1'b0;
                    op1 <= i_if_pc;
                    op2 <= u_imm;
                    type <= `OP_ADD;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 0;
                    end
        `OP       : begin
                    jmp_stall <= 1'b0;
                    op1 <= r1_reg;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 0;
                    case(funct3)
                    `F3_ADD_SUB:begin
                                op2 <= r2_reg;
                                case(imm_30)
                                1'b0:    begin
                                        type <= `OP_ADD;
                                        end
                                1'b1:    begin
                                        type <= `OP_SUB;
                                        end
                                endcase
                                end
                    `F3_SLT:    begin
                                op2 <= r2_reg;
                                type <= `OP_SLT;
                                end
                    `F3_SLTU:   begin
                                op2 <= r2_reg;
                                type <= `OP_SLTU;
                                end
                    `F3_XOR:    begin
                                op2 <= r2_reg;
                                type <= `OP_XOR;
                                end
                    `F3_OR:     begin
                                op2 <= r2_reg;
                                type <= `OP_OR;
                                end
                    `F3_AND:    begin
                                op2 <= r2_reg;
                                type <= `OP_AND;
                                end
                    `F3_SLL:    begin
                                op2 <= r2_reg[5:0];
                                type <= `OP_SLL;
                                end
                    `F3_SRL_SRA:begin
                                op2 <= r2_reg[5:0];
                                case(imm_30)
                                1'b0:    begin
                                        type <= `OP_SRL;
                                        end
                                1'b1:    begin
                                        type <= `OP_SRA;
                                        end
                                endcase
                                end
                    endcase
                    end
        `OP_32    : begin
                    jmp_stall <= 1'b0;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 1;
                    case(funct3)
                    `F3_ADD_SUB:begin
                                op1 <= r1_reg;
                                op2 <= r2_reg;
                                case(imm_30)
                                1'b0:   begin
                                        type <= `OP_ADD;
                                        end
                                1'b1:   begin
                                        type <= `OP_SUB;
                                        end
                                endcase
                                end
                    `F3_SLL:    begin
                                op1 <= r1_reg;
                                op2 <= r2_reg[4:0];
                                type <= `OP_SLL;
                                end
                    `F3_SRL_SRA:begin
                                op2 <= r2_reg[4:0];
                                case(imm_30)
                                1'b0:   begin
                                        op1 <= {32'd0, r1_reg[31:0]};
                                        type <= `OP_SRL;
                                        end
                                1'b1:   begin
                                        op1 <= {{32{r1_reg[31]}}, r1_reg[31:0]};
                                        type <= `OP_SRA;
                                        end
                                endcase
                                end
                    endcase
                    end
        `JAL      : begin
                    jmp_stall <= 1'b1;
                    jmp_pc <= j_imm + i_if_pc;
                    type <= `OP_JMP;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b1;
                    rd_reg <= i_if_pc + 4;
                    op_32bit <= 0;
                    end
        `JALR     : begin
                    jmp_stall <= 1'b1;
                    jmp_pc <= j_imm + r1_reg;
                    type <= `OP_JMP;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b1;
                    rd_reg <= i_if_pc + 4;
                    op_32bit <= 0;
                    end
        `BRANCH   : begin
                    type <= `OP_NOP;
                    rd_en <= 1'b0;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 0;
                    case(funct3)
                    `F3_BEQ:    begin
                                jmp_stall <= (r1_reg == r2_reg);
                                jmp_pc <= i_if_pc + b_imm;
                                end
                    `F3_BNE:    begin
                                jmp_stall <= (r1_reg != r2_reg);
                                jmp_pc <= i_if_pc + b_imm;
                                end
                    `F3_BLT:    begin
                                jmp_stall <= ($signed(r1_reg) < $signed(r2_reg));
                                jmp_pc <= i_if_pc + b_imm;
                                end
                    `F3_BGE:    begin
                                jmp_stall <= ($signed(r1_reg) >= $signed(r2_reg));
                                jmp_pc <= i_if_pc + b_imm;
                                end
                    `F3_BLTU:   begin
                                jmp_stall <= (r1_reg < r2_reg);
                                jmp_pc <= i_if_pc + b_imm;
                                end
                    `F3_BGEU:   begin
                                jmp_stall <= (r1_reg >= r2_reg);
                                jmp_pc <= i_if_pc + b_imm;
                                end
                    default:    begin
                                jmp_stall <= 1'b0;
                                jmp_pc <= 0;
                                end
                    endcase
                    end
        `LOAD     : begin
                    jmp_stall <= 1'b0;
                    type <= `OP_LOAD;
                    rd <= rd_idx;
                    rd_en <= 1'b1;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op2 <= r1_reg + i_imm;
                    op_32bit <= 0;
                    case(funct3)
                    `F3_LB:     begin
                                ram_mask <= 8'b00000001;
                                sign <= 1'b1;
                                end
                    `F3_LH:     begin
                                ram_mask <= 8'b00000011;
                                sign <= 1'b1;
                                end
                    `F3_LW:     begin
                                ram_mask <= 8'b00001111;
                                sign <= 1'b1;
                                end
                    `F3_LD:     begin
                                ram_mask <= 8'b11111111;
                                sign <= 1'b0;
                                end
                    `F3_LBU:    begin
                                ram_mask <= 8'b00000001;
                                sign <= 1'b0;
                                end
                    `F3_LHU:    begin
                                ram_mask <= 8'b00000011;
                                sign <= 1'b0;
                                end
                    `F3_LWU:    begin
                                ram_mask <= 8'b00001111;
                                sign <= 1'b0;
                                end
                    default:    begin
                                ram_mask <= 8'b00000000;
                                sign <= 1'b0;
                                end
                    endcase
                    end
        `STORE    : begin
                    jmp_stall <= 1'b0;
                    type <= `OP_STORE;
                    rd_en <= 1'b0;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op1 <= r2_reg;
                    op2 <= r1_reg + s_imm;
                    sign <= 1'b0;
                    op_32bit <= 0;
                    case(funct3)
                    `F3_SB:     begin
                                ram_mask <= 8'b00000001;
                                end
                    `F3_SH:     begin
                                ram_mask <= 8'b00000011;
                                end
                    `F3_SW:     begin
                                ram_mask <= 8'b00001111;
                                end
                    `F3_SD:     begin
                                ram_mask <= 8'b11111111;
                                end
                    default:    begin
                                ram_mask <= 8'b00000000;
                                end
                    endcase
                    end
        default  :  begin
                    jmp_stall <= 1'b0;
                    type <= `OP_NOP;
                    rd_en <= 1'b0;
                    rd_ready <= 1'b0;
                    rd_reg <= {XLEN{1'b0}};
                    op_32bit <= 0;
                    end
        endcase
    end
end

endmodule
