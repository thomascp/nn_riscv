`default_nettype none

module nnrv_id
(
i_clk,
i_rst,

i_if_instr,
i_if_pc,
o_if_jmp_stall,
o_if_jmp_pc,
o_if_hazard_stall,

o_exec_pc,
o_exec_op1,
o_exec_op2,
o_exec_type,
o_exec_rd_en,
o_exec_rd,
o_exec_ram_mask,
o_exec_sign,

o_reg_r1_en,
o_reg_r1,
i_reg_r1_reg,

o_reg_r2_en,
o_reg_r2,
i_reg_r2_reg,

i_exec_rd_en,
i_exec_rd_ready,
i_exec_rd,
i_exec_rd_reg,

i_mem_rd_en,
i_mem_rd_ready,
i_mem_rd,
i_mem_rd_reg
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

input wire [INSTR_WIDTH-1:0] i_if_instr;
input wire [XLEN-1:0] i_if_pc;
output wire o_if_jmp_stall;
output wire [XLEN-1:0] o_if_jmp_pc;
output wire o_if_hazard_stall;

output wire [XLEN-1:0] o_exec_pc;
output wire [XLEN-1:0] o_exec_op1;
output wire [XLEN-1:0] o_exec_op2;
output wire [3:0] o_exec_type;
output wire o_exec_rd_en;
output wire [4:0] o_exec_rd;
output wire [3:0] o_exec_ram_mask;
output wire o_exec_sign;

output wire o_reg_r1_en;
output wire [4:0] o_reg_r1;
input wire [XLEN-1:0] i_reg_r1_reg;

output wire o_reg_r2_en;
output wire [4:0] o_reg_r2;
input wire [XLEN-1:0] i_reg_r2_reg;

input wire i_exec_rd_en;
input wire i_exec_rd_ready;
input wire [4:0] i_exec_rd;
input wire [XLEN-1:0]i_exec_rd_reg;

input wire i_mem_rd_en;
input wire i_mem_rd_ready;
input wire [4:0] i_mem_rd;
input wire [XLEN-1:0]i_mem_rd_reg;

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

`define F3_BEQ          3'b000
`define F3_BNE          3'b001
`define F3_BLT          3'b100
`define F3_BGE          3'b101
`define F3_BLTU         3'b110
`define F3_BGEU         3'b111

`define F3_SB           3'b000
`define F3_SH           3'b001
`define F3_SW           3'b010

`define F3_LB           3'b000
`define F3_LH           3'b001
`define F3_LW           3'b010
`define F3_LBU          3'b100
`define F3_LHU          3'b101

`define OP_NOP          4'b0000
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
`define OP_JMP          4'b1011
`define OP_LOAD         4'b1100
`define OP_STORE        4'b1101

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
wire exec_hazard_stall;
wire exec_rd_rs1_ready;
wire exec_rd_rs2_ready;
wire mem_hazard_stall;
wire mem_rd_rs1_ready;
wire mem_rd_rs2_ready;
wire hazard_stall;

reg [XLEN-1:0] exec_op1 = {XLEN{1'b0}};
reg [XLEN-1:0] exec_op2 = {XLEN{1'b0}};
reg [3:0] exec_type = 4'b0;
reg exec_rd_en = 1'b0;
reg [4:0] exec_rd = 5'b0;
reg [XLEN-1:0] exec_pc = {XLEN{1'b0}};
reg [3:0] exec_ram_mask = 4'b0000;
reg exec_sign = 1'b0;

reg reg_r1_en = 1'b1;
reg reg_r2_en = 1'b1;

reg jmp_stall = 1'b0;
reg [XLEN-1:0] jmp_pc = {XLEN{1'b0}};

wire [XLEN-1:0] r1_reg;
wire [XLEN-1:0] r2_reg;

assign id_instr = (jmp_stall) ? `OP_INSTR_NOP : i_if_instr;

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
assign i_imm =  {{21{imm_sign}}, imm_30_25, imm_24_21, imm_20};
assign s_imm = {{21{imm_sign}}, imm_30_25, imm_11_8, imm_7};
assign b_imm = {{20{imm_sign}}, imm_7, imm_30_25, imm_11_8, 1'b0};
assign u_imm = {imm_sign, imm_30_20, imm_19_12, 12'b0};
assign j_imm = {{12{imm_sign}}, imm_19_12, imm_20, imm_30_25, imm_24_21, 1'b0};
assign shamt_5 = id_instr[24:20];

assign rs1_valid = (opcode == `JALR) || (opcode == `BRANCH) || (opcode == `LOAD)
                        || (opcode == `STORE) || (opcode == `OP) || (opcode == `OP_IMM);
assign rs2_valid = (opcode == `BRANCH) || (opcode == `STORE) || (opcode == `OP);

assign o_if_jmp_stall = jmp_stall;
assign o_if_jmp_pc = jmp_pc;

assign o_reg_r1_en = reg_r1_en;
assign o_reg_r2_en = reg_r2_en;
assign o_reg_r1 = rs1_idx;
assign o_reg_r2 = rs2_idx;

assign o_exec_op1 = exec_op1;
assign o_exec_op2 = exec_op2;
assign o_exec_type = exec_type;
assign o_exec_rd_en = exec_rd_en;
assign o_exec_rd = exec_rd;
assign o_exec_pc = exec_pc;
assign o_exec_ram_mask = exec_ram_mask;

assign o_exec_sign = exec_sign;

assign id_hazard_stall = (exec_rd_en) && (exec_rd != 0) &&
                (((rs1_valid) && (exec_rd == rs1_idx)) || ((rs2_valid) && (exec_rd == rs2_idx)));

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

assign r1_reg = (exec_rd_rs1_ready) ? i_exec_rd_reg : (mem_rd_rs1_ready) ? i_mem_rd_reg : i_reg_r1_reg;
assign r2_reg = (exec_rd_rs2_ready) ? i_exec_rd_reg : (mem_rd_rs2_ready) ? i_mem_rd_reg : i_reg_r2_reg;

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        exec_rd <= 5'b0;
        exec_op1 <= {XLEN{1'b0}};
        exec_op2 <= {XLEN{1'b0}};
        exec_type <= `OP_NOP;
        jmp_stall <= 1'b0;
        exec_rd_en <= 1'b0;
        exec_pc <= 0;
        jmp_pc <= 0;
        exec_ram_mask <= 0;
        exec_sign <= 0;
    end else if (hazard_stall) begin
        exec_rd <= 5'b0;
        exec_op1 <= {XLEN{1'b0}};
        exec_op2 <= {XLEN{1'b0}};
        exec_type <= `OP_NOP;
        jmp_stall <= 1'b0;
        exec_rd_en <= 1'b0;
        exec_pc <= 0;
        jmp_pc <= 0;
        exec_ram_mask <= 0;
        exec_sign <= 0;
    end else begin
        exec_rd <= rd_idx;
        exec_pc <= i_if_pc;
        case(opcode)
        `OP_IMM :   begin
                    jmp_stall <= 1'b0;
                    exec_op1 <= r1_reg;
                    exec_rd_en <= 1'b1;
                    case(funct3)
                    `F3_ADD_SUB: begin
                                exec_type <= `OP_ADD;
                                exec_op2 <= i_imm;
                                end
                    `F3_SLT:     begin
                                exec_type <= `OP_SLT;
                                exec_op2 <= i_imm;
                                end
                    `F3_SLTU:    begin
                                exec_type <= `OP_SLTU;
                                exec_op2 <= i_imm;
                                end
                    `F3_XOR:     begin
                                exec_type <= `OP_XOR;
                                exec_op2 <= i_imm;
                                end
                    `F3_OR:      begin
                                exec_type <= `OP_OR;
                                exec_op2 <= i_imm;
                                end
                    `F3_AND:     begin
                                exec_type <= `OP_AND;
                                exec_op2 <= i_imm;
                                end
                    `F3_SLL:     begin
                                exec_type <= `OP_SLL;
                                exec_op2 <= shamt_5;
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
                                exec_op2 <= shamt_5;
                                end
                    endcase
                    end
        `LUI      : begin
                    jmp_stall <= 1'b0;
                    exec_op1 <= r1_reg;
                    exec_op2 <= u_imm;
                    exec_type <= `OP_ADD;
                    exec_rd_en <= 1'b1;
                    end
        `AUIPC    : begin
                    jmp_stall <= 1'b0;
                    exec_op1 <= i_if_pc;
                    exec_op2 <= u_imm;
                    exec_type <= `OP_ADD;
                    exec_rd_en <= 1'b1;
                    end
        `OP       : begin
                    jmp_stall <= 1'b0;
                    exec_op1 <= r1_reg;
                    exec_op2 <= r2_reg;
                    exec_rd_en <= 1'b1;
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
        `JAL      : begin
                    jmp_stall <= 1'b1;
                    jmp_pc <= j_imm + i_if_pc;
                    exec_type <= `OP_JMP;
                    exec_rd_en <= 1'b1;
                    end
        `JALR     : begin
                    jmp_stall <= 1'b1;
                    jmp_pc <= j_imm + r1_reg;
                    exec_type <= `OP_JMP;
                    exec_rd_en <= 1'b1;
                    end
        `BRANCH   : begin
                    exec_type <= `OP_NOP;
                    exec_rd_en <= 1'b0;
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
                    exec_type <= `OP_LOAD;
                    exec_rd <= rd_idx;
                    exec_rd_en <= 1'b1;
                    exec_op2 <= r1_reg + i_imm;
                    case(funct3)
                    `F3_LB:     begin
                                exec_ram_mask <= 4'b0001;
                                exec_sign <= 1'b1;
                                end
                    `F3_LH:     begin
                                exec_ram_mask <= 4'b0011;
                                exec_sign <= 1'b1;
                                end
                    `F3_LW:     begin
                                exec_ram_mask <= 4'b1111;
                                exec_sign <= 1'b0;
                                end
                    `F3_LBU:    begin
                                exec_ram_mask <= 4'b0001;
                                exec_sign <= 1'b0;
                                end
                    `F3_LHU:    begin
                                exec_ram_mask <= 4'b0011;
                                exec_sign <= 1'b0;
                                end
                    default:    begin
                                exec_ram_mask <= 4'b1111;
                                exec_sign <= 1'b0;
                                end
                    endcase
                    end
        `STORE    : begin
                    jmp_stall <= 1'b0;
                    exec_type <= `OP_STORE;
                    exec_rd_en <= 1'b0;
                    exec_op1 <= r2_reg;
                    exec_op2 <= r1_reg + s_imm;
                    exec_sign <= 1'b0;
                    case(funct3)
                    `F3_SB:     begin
                                exec_ram_mask <= 4'b0001;
                                end
                    `F3_SH:     begin
                                exec_ram_mask <= 4'b0011;
                                end
                    `F3_SW:     begin
                                exec_ram_mask <= 4'b1111;
                                end
                    default:    begin
                                exec_ram_mask <= 4'b1111;
                                end
                    endcase
                    end
        default  :  begin
                    jmp_stall <= 1'b0;
                    exec_type <= `OP_NOP;
                    exec_rd_en <= 1'b0;
                    end
        endcase
    end
end

endmodule
