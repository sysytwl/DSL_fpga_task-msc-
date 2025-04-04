module decoder(
  input clk,
  input reset,

  input [7:0] instruction,

  //alu
  input condition_result,
  output reg [3:0] opcode,

  //program counter
  output reg [2:0] counter_cmd,

  //registers
  output reg [2:0] reg_control_a,
  output reg [2:0] reg_control_b,

  //irs
  input irs_signal,
  input irs_running,

  //instruction bus
  output reg instruction_bus_data_2_data_bus_addr,

  //data bus
  output reg data_write_en
);



/*------------------------------------------------------------------------------
|    No.|    Name   |            Explain                |     Machine code     | 
|     0 | MOVa addr | Read from memory to A             | 0000 0000  xxxx xxxx |
|     1 | MOVb addr | Read from memory to B             | 0000 0001  xxxx xxxx |
|     2 | sbA addr  | Write to memory from A            | 0000 0010  xxxx xxxx |
|     3 | sbB addr  | Write to memory from B            | 0000 0011  xxxx xxxx |
|     4 | OpA       | ALU Op, and save result in reg A  | xxxx 0100            |
|     5 | OpB       | ALU Op, and save result in reg B  | xxxx 0101            |
| added | Op Addr   | ALU Op, and save result to memory | xxxx 1111  xxxx xxxx |
|     6 |beq bne blt| if A (== or < or > B) GoTo ADDR   | xxxx 0110  xxxx xxxx |
|     7 | JAL addr  | Goto ADDR                         | 0000 0111  xxxx xxxx |
|     8 | NOP       | Go to IDLE                        | 0000 1000            |
|     9 | Halt      | NOP and wait for interrupt        | 0000 1101            |
|    10 | Call addr | Function call                     | 0000 1001  xxxx xxxx |
|    11 | Ret       | Return from function call         | 0000 1010            |
|    12 | lbA       | Dereference A                     | 0000 1011            |
|    13 | lbB       | Dereference B                     | 0000 1100            |
------------------------------------------------------------------------------*/



localparam [3:0] MOVa = 4'b0000,
                 MOVb = 4'b0001,
                 sbA = 4'b0010,
                 sbB = 4'b0011,
                 OpA = 4'b0100,
                 OpB = 4'b0101,
                 OpMem = 4'b1110,
                 CJAL = 4'b0110,
                 JAL = 4'b0111,
                 NOP = 4'b1000,
                 Halt = 4'b1101,
                 Call = 4'b1001,
                 Ret = 4'b1010,
                 lbA = 4'b1011,
                 lbB = 4'b1100;

reg [1:0] cycle_counter;
reg cycle_counter_increase;
always @(posedge clk or posedge reset) begin
  if(reset || ~cycle_counter_increase)begin
    cycle_counter <= 0;
  end
  else begin
    cycle_counter <= cycle_counter + 1;
  end
end

reg [3:0] current_instruction;
reg [3:0] current_opcode;
always @(posedge clk or posedge reset)begin
  if (reset) begin
    current_instruction <= NOP;
    current_opcode <= 4'hF;
  end
  else if (cycle_counter == 0) begin
    current_instruction <= instruction[3:0];
    current_opcode <= instruction[7:4];
  end
end

always @(*) begin
  if (reset)begin
    counter_cmd <= 0;
    opcode <= 4'hF;
    reg_control_a <= 0;
    reg_control_b <= 0;
    data_write_en <= 0;
    instruction_bus_data_2_data_bus_addr <= 0;
    cycle_counter_increase <= 0;
  end
  else if(irs_signal && cycle_counter==0 && ~irs_running) begin //Interrupt Request, not inside other operation, irs is not running
    opcode <= 4'hF; //pc_save/pc_irs(set to addr)
    counter_cmd <= 4;
    reg_control_a <= 0;
    reg_control_b <= 0;
    data_write_en <= 0;
    instruction_bus_data_2_data_bus_addr <= 0;
    cycle_counter_increase <= 0;
  end
  else begin
    case ((cycle_counter == 0) ? instruction[3:0] : current_instruction)
      NOP: begin
        opcode <= 4'hF;

        counter_cmd <= 1;

        reg_control_a <= 0;
        reg_control_b <= 0;

        data_write_en <= 0;

        instruction_bus_data_2_data_bus_addr <= 0;

        cycle_counter_increase <= 0;
      end

      Halt: begin
        opcode <= 4'hF;

        counter_cmd <= 0;

        reg_control_a <= 0;
        reg_control_b <= 0;

        data_write_en <= 0;

        instruction_bus_data_2_data_bus_addr <= 0;

        cycle_counter_increase <= 0;
      end

      MOVa: begin
        case (cycle_counter)
          0: begin //program counter increase
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //IBDO_DBAI
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 1;

            cycle_counter_increase <= 1;
          end

          2: begin //RAI PCE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 1;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end

          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      MOVb: begin
        case (cycle_counter)
          0: begin //program counter increase
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //IBDO_DBAI
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 1;

            cycle_counter_increase <= 1;
          end

          2: begin //RBI PCE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 1;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end

          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      sbA: begin
        case (cycle_counter)
          0: begin //PCE RAO
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 2;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //PCE IBDO_DBAI DBWE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 1;
            instruction_bus_data_2_data_bus_addr <= 1;

            cycle_counter_increase <= 0;
          end
          
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      sbB: begin
        case (cycle_counter)
          0: begin //PCE RBO
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 2;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //PCE IBDO_DBAI DBWE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 1;
            instruction_bus_data_2_data_bus_addr <= 1;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      OpA: begin
        case (cycle_counter)
          0: begin //RAO RBO
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 3;
            reg_control_b <= 3;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //opcode
            opcode <= current_opcode;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          2: begin //PCE RAI
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 1;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      OpB: begin
        case (cycle_counter)
          0: begin //RAO RBO
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 3;
            reg_control_b <= 3;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //opcode
            opcode <= current_opcode;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          2: begin //PCE RBI
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 1;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      OpMem: begin
        case (cycle_counter)
          0: begin //RAO RBO
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 3;
            reg_control_b <= 3;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //opcode PCE
            opcode <= current_opcode;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          2: begin //IB2DB DBWE PCE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 1;

            data_write_en <= 1;
            instruction_bus_data_2_data_bus_addr <= 1;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      CJAL: begin
        case (cycle_counter)
          0: begin //RAO RBO
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 3;
            reg_control_b <= 3;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //opcode PCE
            opcode <= current_opcode;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          2: begin //PCI?
            opcode <= 4'hF;

            if (condition_result) begin //true jump
              counter_cmd <= 2;
            end
            else begin
              counter_cmd <= 1;
            end

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      JAL: begin
        case (cycle_counter)
          0: begin //PCE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //PCIn
            opcode <= 4'hF;

            counter_cmd <= 2;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      Call: begin
        case (cycle_counter)
          0: begin //PCE
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin //PCI/PCS
            opcode <= 4'hF;

            counter_cmd <= 5;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase 
      end

      Ret: begin //PCset2save
        opcode <= 4'hF;

        counter_cmd <= 3;

        reg_control_a <= 0;
        reg_control_b <= 0;

        data_write_en <= 0;
        instruction_bus_data_2_data_bus_addr <= 0;

        cycle_counter_increase <= 0;
      end

      lbA: begin
        case (cycle_counter)
          0: begin //RAO2BUS 
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 4;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          2: begin //RAI PCI
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 1;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      lbB: begin
        case (cycle_counter)
          0: begin //RBO2BUS 
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 4;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          1: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 1;
          end

          2: begin //RBI PCI
            opcode <= 4'hF;

            counter_cmd <= 1;

            reg_control_a <= 0;
            reg_control_b <= 1;

            data_write_en <= 0;
            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
                    
          default: begin
            opcode <= 4'hF;

            counter_cmd <= 0;

            reg_control_a <= 0;
            reg_control_b <= 0;

            data_write_en <= 0;

            instruction_bus_data_2_data_bus_addr <= 0;

            cycle_counter_increase <= 0;
          end
        endcase
      end

      default: begin
        opcode <= 4'hF;

        counter_cmd <= 0;

        reg_control_a <= 0;
        reg_control_b <= 0;

        data_write_en <= 0;

        instruction_bus_data_2_data_bus_addr <= 0;

        cycle_counter_increase <= 0;
      end
    endcase 
  end



end 

endmodule