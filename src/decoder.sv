`default_nettype none
`include "def.sv"

module decoder
  (input wire         clk,
   input wire        rstn,
   input wire [31:0] pc,
   input wire        enabled,
  
   input wire [31:0] instr_raw,

   output wire        completed,
   output            instructions instr,
   output wire [4:0] rs1,
   output wire [4:0] rs2);
   

   // basic component
   // the location of immediate value may change
   wire [6:0]        funct7 = instr_raw[31:25];
   wire [4:0]        _rs2 = instr_raw[24:20];
   wire [4:0]        _rs1 = instr_raw[19:15];
   wire [2:0]        funct3 = instr_raw[14:12];
   wire [4:0]        _rd = instr_raw[11:7];
   wire [6:0]        opcode = instr_raw[6:0];
   
   // r, i, s, b, u, j
   // TODO: check here when you add new instructions
   // TODO!!!!!!!!!!!!!!!!!!!
   wire              r_type = (opcode == 7'b0110011 | opcode == 7'b1010011); 
   wire              i_type = (opcode == 7'b1100111 | opcode == 7'b0000011 | opcode == 7'b0010011 | opcode == 7'b0000111); 
   wire              s_type = (opcode == 7'b0100011 | opcode == 7'b0100111); 
   wire              b_type = (opcode == 7'b1100011); 
   wire              u_type = (opcode == 7'b0110111 | opcode == 7'b0010111);   
   wire              j_type = (opcode == 7'b1101111); 
   
   assign rs1 = (r_type || i_type || s_type || b_type) ? _rs1 : 5'b00000;
   assign rs2 = (r_type || s_type || b_type) ? _rs2 : 5'b00000;
   
   wire              _lui = (opcode == 7'b0110111);
   wire              _auipc =  (opcode == 7'b0010111);
   wire              _jal = (opcode == 7'b1101111);
   wire              _jalr =  (opcode == 7'b1100111);
   wire              _beq = (opcode == 7'b1100011) && (funct3 == 3'b000);
   wire              _bne =  (opcode == 7'b1100011) && (funct3 == 3'b001);
   wire              _blt =  (opcode == 7'b1100011) && (funct3 == 3'b100);
   wire              _bge = (opcode == 7'b1100011) && (funct3 == 3'b101);
   wire              _bltu = (opcode == 7'b1100011) && (funct3 == 3'b110);
   wire              _bgeu =  (opcode == 7'b1100011) && (funct3 == 3'b111);  
   wire              _lb =  (opcode == 7'b0000011) && (funct3 == 3'b000);
   wire              _lh =  (opcode == 7'b0000011) && (funct3 == 3'b001); 
   wire              _lw =  (opcode == 7'b0000011) && (funct3 == 3'b010);  
   wire              _lbu = (opcode == 7'b0000011) && (funct3 == 3'b100);  
   wire              _lhu =  (opcode == 7'b0000011) && (funct3 == 3'b101);      
   wire              _sb =  (opcode == 7'b0100011) && (funct3 == 3'b000);     
   wire              _sh =  (opcode == 7'b0100011) && (funct3 == 3'b001);
   wire              _sw = (opcode == 7'b0100011) && (funct3 == 3'b010);
   wire              _addi =  (opcode == 7'b0010011) && (funct3 == 3'b000);
   wire              _slti =  (opcode == 7'b0010011) && (funct3 == 3'b010);
   wire              _sltiu = (opcode == 7'b0010011) && (funct3 == 3'b011);
   wire              _xori = (opcode == 7'b0010011) && (funct3 == 3'b100);
   wire              _ori = (opcode == 7'b0010011) && (funct3 == 3'b110);
   wire              _andi = (opcode == 7'b0010011) && (funct3 == 3'b111);
   wire              _slli = (opcode == 7'b0010011) && (funct3 == 3'b001);
   wire              _srli = (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
   wire              _srai = (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);

   // arith others
   wire              _add = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
   wire              _sub = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
   wire              _sll = (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
   wire              _slt = (opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000000);
   wire              _sltu = (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000000);
   wire              _xor = (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000000);
   wire              _srl = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
   wire              _sra = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
   wire              _or =  (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000000);
   wire              _and = (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000000);

   /////////   
   // rv32m
   /////////
   wire              _mul = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000001);
   wire              _mulh = (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000001);
   wire              _mulhsu = (opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000001);
   wire              _mulhu = (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000001);
   wire              _div = (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000001);
   wire              _divu = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000001);
   wire              _rem = (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000001);
   wire              _remu = (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000001);

   /////////   
   // rv32f
   /////////
   wire              _flw = (opcode == 7'b0000111) && (funct3 == 3'b010);
   wire              _fsw = (opcode == 7'b0100111) && (funct3 == 3'b010);
   wire              _fadd = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
   wire              _fsub = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b0000100);
   wire              _fmul = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b0001000);
   wire              _fdiv = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b0001100);
   wire              _fsqrt = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b0101100) && (rs2 == 5'b0);
   wire              _fsgnj = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b0010000);
   wire              _fsgnjn = (opcode == 7'b1010011) && (funct3 == 3'b001) && (funct7 == 7'b0010000);
   wire              _fsgnjx = (opcode == 7'b1010011) && (funct3 == 3'b010) && (funct7 == 7'b0010000);         
   wire              _fcvtws = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b1100000) && (rs2 == 5'b00000);
   wire              _fmvxw = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b1110000) && (rs2 == 5'b00000);
   wire              _feq = (opcode == 7'b1010011) && (funct3 == 3'b010) && (funct7 == 7'b1010000);
   wire              _fle = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b1010000);
   wire              _fcvtsw = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b1101000) && (rs2 == 5'b00000);
   wire              _fmvwx = (opcode == 7'b1010011) && (funct3 == 3'b000) && (funct7 == 7'b1111000) && (rs2 == 5'b00000);

   wire              _writes_to_freg_as_rv32f = (_fsw
                                                 || _flw
                                                 || _fadd 
                                                 || _fsub
                                                 || _fmul
                                                 || _fdiv
                                                 || _fsqrt
                                                 || _fsgnj
                                                 || _fsgnjn
                                                 || _fsgnjx
                                                 || _fcvtsw
                                                 || _fmvwx);
   wire              _writes_to_reg_as_rv32f =  (_feq
                                                 || _fle
                                                 || _fcvtsw
                                                 || _fmvxw);

   wire              _uses_reg_as_rv32f = (_flw || _fsw || _fcvtsw || _fmvwx);
   wire              _uses_freg_as_rv32f = (_fadd 
                                            || _fsub
                                            || _fmul
                                            || _fdiv
                                            || _fsqrt
                                            || _fsgnj
                                            || _fsgnjn
                                            || _fsgnjx
                                            || _fcvtsw
                                            || _feq
                                            || _fle
                                            || _fmvxw);
   
   wire              _rv32f = (_fsw
                               || _flw
                               || _fadd 
                               || _fsub
                               || _fmul
                               || _fdiv
                               || _fsqrt
                               || _fsgnj
                               || _fsgnjn
                               || _fsgnjx
                               || _fcvtsw
                               || _fmvwx
                               || _feq
                               || _fle
                               || _fcvtsw
                               || _fmvxw);

   
   wire              _is_store = (_sb
                                  || _sh
                                  || _sw
                                  || _fsw);
   wire              _is_load = (_lb
                                 || _lh
                                 || _lw
                                 || _lbu
                                 || _lhu
                                 || _flw);
   
   wire              _is_conditional_jump = (_beq 
                                             || _bne 
                                             || _blt 
                                             || _bge 
                                             || _bltu 
                                             || _bgeu);
   

      reg _completed;
   assign completed = _completed & !enabled;
   
   always @(posedge clk) begin
      if (rstn) begin
         if (enabled) begin
            _completed <= 1;            
            
            /////////   
            // rv32i
            /////////   
            // lui, auipc
            instr.lui <= _lui;
            instr.auipc <= _auipc;         
            // jumps
            instr.jal <= _jal;         
            instr.jalr <= _jalr;         
            // conditional breaks
            instr.beq <= _beq;         
            instr.bne <= _bne;         
            instr.blt <= _blt;         
            instr.bge <= _bge;         
            instr.bltu <= _bltu;         
            instr.bgeu <= _bgeu;       
            // memory control
            instr.lb = _lb;         
            instr.lh = _lh;        
            instr.lw = _lw;       
            instr.lbu = _lbu;       
            instr.lhu = _lhu; 
            instr.sb = _sb;    
            instr.sh = _sh;         
            instr.sw = _sw;         

            // arith imm
            instr.addi <= _addi;
            instr.slti <= _slti;
            instr.sltiu <= _sltiu;
            instr.xori <= _xori;
            instr.ori <= _ori;
            instr.andi <= _andi;
            instr.slli <= _slli;
            instr.srli <= _srli;
            instr.srai <= _srai;

            // arith others
            instr.add <= _add;
            instr.sub <= _sub;
            instr.sll <= _sll;
            instr.slt <= _slt;
            instr.sltu <= _sltu;
            instr.i_xor <= _xor;
            instr.srl <= _srl;
            instr.sra <= _sra;
            instr.i_or <= _or;
            instr.i_and <= _and;

            /////////   
            // rv32m
            /////////
            instr.mul <= _mul;
            instr.mulh <= _mulh;
            instr.mulhsu <= _mulhsu;
            instr.mulhu <= _mulhu;
            instr.div <= _div;
            instr.divu <= _divu;
            instr.rem <= _rem;
            instr.remu <= _remu;

            /////////   
            // rv32f
            /////////
            instr.flw <= _flw;
            instr.fsw <= _fsw;
            instr.fadd <= _fadd;
            instr.fsub <= _fsub;
            instr.fmul <= _fmul;
            instr.fdiv <= _fdiv;
            instr.fsqrt <= _fsqrt;
            instr.fsgnj <= _fsgnj;
            instr.fsgnjn <= _fsgnjn;
            instr.fsgnjx <= _fsgnjx;
            instr.fcvtws <= _fcvtws;
            instr.fmvxw <= _fmvxw;
            instr.feq <= _feq;
            instr.fle <= _fle;
            instr.fcvtsw <= _fcvtsw;
            instr.fmvwx <= _fmvwx; 
            /////////   
            
            /////////   
            // rv32a
            /////////
            // TODO

            /////////   
            // rv32c
            /////////
            // TODO

            /////////   
            // other controls
            /////////            
            instr.rv32f <= _rv32f;
            instr.writes_to_freg_as_rv32f <= _writes_to_freg_as_rv32f;                        
            instr.writes_to_reg_as_rv32f <=  _writes_to_reg_as_rv32f;            
            instr.writes_to_reg <= !(_is_conditional_jump
                                     || _is_store
                                     || _writes_to_freg_as_rv32f);
            instr.uses_reg_as_rv32f <= _uses_reg_as_rv32f;            
            instr.uses_freg_as_rv32f <= _uses_freg_as_rv32f;
            instr.uses_reg <= !_rv32f || _uses_reg_as_rv32f;
            
            instr.is_store <= _is_store;                        
            instr.is_load <= _is_load;               
            instr.is_conditional_jump <=  _is_conditional_jump;            
            
            instr.rd <= (r_type || i_type || u_type || j_type) ? _rd : 5'b00000;
            instr.rs1 <= (r_type || i_type || s_type || b_type) ? _rs1 : 5'b00000;
            instr.rs2 <= (r_type || s_type || b_type) ? _rs2 : 5'b00000;
            
            instr.pc <= pc;
            
            // NOTE: this sign extention may have bugs; oops...
            instr.imm <= i_type ? (instr_raw[31] ? {~20'b0, instr_raw[31:20]}:
                                   {20'b0, instr_raw[31:20]}):
                         s_type ? (instr_raw[31] ? {~20'b0, instr_raw[31:25], instr_raw[11:7]}:
                                   {20'b0, instr_raw[31:25], instr_raw[11:7]}):
                         b_type ? (instr_raw[31] ? {~19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8], 1'b0}:
                                   {19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8], 1'b0}):
                         u_type ? {instr_raw[31:12], 12'b0} : 
                         j_type ? (instr_raw[31] ? {~11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21], 1'b0}:
                                   {11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21], 1'b0}):
                         32'b0;
         end
      end else begin // if (rstn)
         _completed <= 0;
      end      
   end
endmodule
`default_nettype wire
