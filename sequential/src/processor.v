module processor(
    input clk,
    input reset
);

wire [63:0] pc_out;
wire [63:0] pc_plus4;
wire [63:0] branch_target;
wire [63:0] pc_next;

wire [31:0] instruction;

wire Branch;
wire MemRead;
wire MemtoReg;
wire [1:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;

wire [63:0] read_data1;
wire [63:0] read_data2;
wire [63:0] write_data;

wire [63:0] imm_out;

wire [3:0] ALUControl;

wire [63:0] alu_input2;
wire [63:0] alu_result;
wire zero;

wire [63:0] mem_read_data;

wire branch_taken;

pc pc_inst(
    .clk(clk),
    .reset(reset),
    .pc_in(pc_next),
    .pc_out(pc_out)
);

assign pc_plus4 = pc_out + 64'd4;

instruction_mem imem(
    .addr(pc_out),
    .instr(instruction)
);

control control_unit(
    .opcode(instruction[6:0]),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);

register_file rf(
    .clk(clk),
    .reset(reset),
    .read_reg1(instruction[19:15]),
    .read_reg2(instruction[24:20]),
    .write_reg(instruction[11:7]),
    .write_data(write_data),
    .reg_write_en(RegWrite),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

imm_gen imm_block(
    .instruction(instruction),
    .imm_out(imm_out)
);

alu_control alu_ctrl(
    .ALUOp(ALUOp),
    .funct7(instruction[30]),
    .funct3(instruction[14:12]),
    .ALUControl(ALUControl)
);

alu_src_mux src_mux(
    .reg_data(read_data2),
    .imm_data(imm_out),
    .ALUSrc(ALUSrc),
    .alu_input2(alu_input2)
);

alu alu_inst(
    .input1(read_data1),
    .input2(alu_input2),
    .control_signal(ALUControl),
    .result(alu_result),
    .zero_flag(zero)
);

data_mem dmem(
    .clk(clk),
    .reset(reset),
    .address(alu_result),
    .write_data(read_data2),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .read_data(mem_read_data)
);

assign write_data = MemtoReg ? mem_read_data : alu_result;

assign branch_target = pc_out + imm_out;
assign branch_taken = Branch & zero;

pc_mux pc_selector(
    .pc_plus4(pc_plus4),
    .branch_target(branch_target),
    .pc_src(branch_taken),
    .next_pc(pc_next)
);

always @(posedge clk)
    $display("PC=%0d instruction=%h", pc_out, instruction);

endmodule