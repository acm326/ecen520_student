//////////////////////////////////////////////////////////////////////////////////
// seven_segment.sv
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module seven_segment_check(clk, rst, display_val, dp, blank, segments, dp_out, an_out, 
    new_value, output_display_val);

    input clk, rst;
    input [31:0] display_val;
    input [7:0] dp;
    input blank;
    input logic [6:0] segments;
    input logic dp_out;
    input logic [7:0] an_out;
    output logic new_value;
    output logic [31:0] output_display_val;
    //output logic [7:0] new_digit  = 8'h00;
    //output logic [55:0] display_segments; // 8 x 7 = 56
    //output logic [7:0] display_dp = 8'hxx;

    parameter int CLK_FREQUENCY = 100_000_000;   // 100 MHz
    parameter int MIN_SEGMENT_DISPLAY_US = 10_000;
    parameter int VERBOSE = 1;
    parameter int WARN_ON_SIMULTANEOUS_ANODES = 1;
    localparam int MIN_SEGMENT_CLOCKS = CLK_FREQUENCY / 1_000_000 * MIN_SEGMENT_DISPLAY_US;

    // Convert standard segment settings to the corresonding hex values
    function logic [3:0] segment_to_hex(input logic [6:0] segments);
        begin
            case(segments)

                7'b0000001: segment_to_hex = 4'b0000; // 0
                7'b1001111: segment_to_hex = 4'b0001; // 1
                7'b0010010: segment_to_hex = 4'b0010; // 2
                7'b0000110: segment_to_hex = 4'b0011; // 3
                7'b1001100: segment_to_hex = 4'b0100; // 4
                7'b0100100: segment_to_hex = 4'b0101; // 5
                7'b0100000: segment_to_hex = 4'b0110; // 6
                7'b0001111: segment_to_hex = 4'b0111; // 7
                7'b0000000: segment_to_hex = 4'b1000; // 8
                7'b0000100: segment_to_hex = 4'b1001; // 9
                7'b0001000: segment_to_hex = 4'b1010; // A
                7'b1100000: segment_to_hex = 4'b1011; // B
                7'b0110001: segment_to_hex = 4'b1100; // C
                7'b1000010: segment_to_hex = 4'b1101; // D
                7'b0110000: segment_to_hex = 4'b1110; // E
                7'b0111000: segment_to_hex = 4'b1111; // F
                default: segment_to_hex = 4'bxxxx; // 0
            endcase
        end
    endfunction

    // Check to see if more than one anode is being displayed at a time and give a warning
    logic error_last_cycle = 0;
    always_ff @(posedge clk) begin
        if (WARN_ON_SIMULTANEOUS_ANODES > 0) begin
            if (an_out != 8'hff && $countones(~an_out) > 1 && error_last_cycle == 0) begin
                $display("Warning: More than one anode is being displayed at a time: %b", an_out);
                error_last_cycle <= 1;
            end
            else
                error_last_cycle <= 0;
        end
    end

    // Keep track of the current segment and dp values (update when corresponding an_out is low)
    logic [6:0] display_segments[7:0]; // An array of 8 segments with each segment being 7 bits
    logic [7:0] display_dp; // An array of 8 dp values
    always_ff @(posedge clk) begin
        // Update those digits that are being displayed
        for (int i = 0; i < 8; i = i + 1) begin
            if (an_out[i] == 0) begin
                display_segments[i] <= segments;
                display_dp[i] <= dp[i];
                output_display_val[4*i +: 4] <= segment_to_hex(segments);
            end
        end
    end

    // Print the current value of the segments
    function void print_segments();
        byte segment_chars[8][7];
        byte digit_point[8];
        const byte SPACE = 8'h20;
        //const byte SPACE = 8'h2E;
        const byte DASH = 8'h2D;
        const byte BAR = 8'h7C;
        const byte DOT = 8'h2E;
        const byte UNDERSCORE = 8'h5F;
        automatic integer horizontal_segment_indecies[] = '{6,3,0};
        automatic integer vertical_segment_indecies[] = '{5,4,2,1};
        automatic string line1, line2,line3,line4,line5 = "";
        begin
            // Iterate over each digit to convert the segment values to its corresponding character
            for (int i = 0; i < 8; i = i + 1) begin
                //$display("Digit %0d %7b", i, display_segments[i]);
                // Horizontal characters are segments 6,3,0
                if (display_segments[i][0]==0) segment_chars[i][0] = UNDERSCORE;
                else segment_chars[i][0] = SPACE;
                if (display_segments[i][3]==0) segment_chars[i][3] = UNDERSCORE;
                else segment_chars[i][3] = SPACE;
                if (display_segments[i][6]==0) segment_chars[i][6] = UNDERSCORE;
                else segment_chars[i][6] = SPACE;
                // Vertical charactesra are segments 1,2,4,5
                if (display_segments[i][1]==0) segment_chars[i][1] = BAR;
                else segment_chars[i][1] = SPACE;
                if (display_segments[i][2]==0) segment_chars[i][2] = BAR;
                else segment_chars[i][2] = SPACE;
                if (display_segments[i][4]==0) segment_chars[i][4] = BAR;
                else segment_chars[i][4] = SPACE;
                if (display_segments[i][5]==0) segment_chars[i][5] = BAR;
                else segment_chars[i][5] = SPACE;
                // for (int j = 0; j < 7; j = j + 1)
                //     $display(" segment %0d=%c", j, segment_chars[i][j]);
                // Determine the digit point
                if (display_dp[i] == 1) digit_point[i] = DOT;
                else digit_point[i] = SPACE;
            end
            // Print the segments
            // Line 1 (top line) : S6SSS (underscores)
            // Line 2            : 105SS
            // Line 4            : 234DS
            for (int i = 7; i >= 0; i = i - 1)
                 line1 = {line1, SPACE,segment_chars[i][6], SPACE,SPACE,SPACE};
            for (int i = 7; i >= 0; i = i - 1)
                line2 = {line2, segment_chars[i][1], segment_chars[i][0],segment_chars[i][5],SPACE,SPACE};
            // for (int i = 0; i < 8; i = i + 1)
            //     line3 = {line3, SPACE,segment_chars[i][0], SPACE,SPACE};
            for (int i = 7; i >= 0; i = i - 1)
                line4 = {line4, segment_chars[i][2], segment_chars[i][3],segment_chars[i][4],digit_point[i],SPACE};
            // for (int i = 0; i < 8; i = i + 1)
            //     line5 = {line5, SPACE,segment_chars[i][3], SPACE,digit_point[i]};
            $display("%s", line1);
            $display("%s", line2);
            //$display("%s", line3);
            $display("%s", line4);
            //$display("%s", line5);
        end
    endfunction


    logic [7:0] an_out_d; // One clock cycle delay of an_out (used for detecting anode changes)
    logic [7:0] annode_collect; // Collect the anodes that are being displayed (to see if all have been displayed)
    integer anode_count = 0; // Count the number of clocks that a single anode is displayed
    //logic new_value;
    logic [7:0] new_digit;
    assign new_digit = (an_out ^ an_out_d) & an_out; // combinatinoal
    always_ff @(posedge clk) begin
        an_out_d <= an_out;
        new_value <= 0;
        anode_count <= anode_count + 1;
        // TODO: Check for blanking
        // See if we are transitioning from invalid annode to valid anode
        if (!(^an_out === 1'bX) && (^an_out_d === 1'bX)) begin
            // Starting a new display cycle
            $display("[%0tns] Valid Annode values", $time/1000);
            anode_count <= 0;
            annode_collect <= 8'h00;
        end
        // See if we are transitioning from one valid anode to another valid anode
        else if(an_out != an_out_d) begin
            if (anode_count > MIN_SEGMENT_CLOCKS + 2 || anode_count < MIN_SEGMENT_CLOCKS - 2 ) begin
                $display("[%0tns] Warning: Invalid number of segment clocks: %0d expecting %0d %h %h", $time/1000,
                    anode_count, MIN_SEGMENT_CLOCKS,an_out,an_out_d);
            end
            anode_count <= 0;
            annode_collect <= annode_collect | new_digit;
            if ((annode_collect | new_digit) == 8'hff) begin
                new_value <= 1;
                annode_collect <= 0;
                $display("[%0tns] New value:",$time/1000);
                print_segments();
            end
        end

    end


//   --  The segments are defined as follows:
//   --
//   --    ----A----
//   --    |       |
//   --    |       |
//   --    F       B
//   --    |       |
//   --    |       |
//   --    ----G----
//   --    |       |
//   --    |       |
//   --    E       C
//   --    |       |
//   --    |       |
//   --    ----D----
//   --
//   -- The seven segments are organized into a std_logic_Vector(6 downto 0)
//   -- where segments(6) corresponds to segment 'A' and segments(0) corresponds
//   -- to segment 'G'.
//   --
//   -- The segments are LOW asserted
//   --

endmodule