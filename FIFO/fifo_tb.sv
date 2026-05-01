`timescale 1ns/1ps

module tb_fifo;

    // ==================== PARAMETERS ====================
    parameter WIDTH = 8;
    parameter DEPTH = 8;

    // ==================== SIGNALS ====================
    reg                  clk;
    reg                  rst;
    reg                  push;
    reg                  pop;
    reg  [WIDTH-1:0]     write_data;
    wire [WIDTH-1:0]     read_data;
    wire                 is_empty;
    wire                 is_full;

    // ==================== DUT INSTANTIATION ====================
    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .write_data(write_data),
        .read_data(read_data),
        .is_empty(is_empty),
        .is_full(is_full)
    );

    // ==================== CLOCK GENERATION ====================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns period
    end

    // ==================== MAIN TESTBENCH ====================
  
    initial begin
        rst = 1;
        push = 0;
        pop = 0;
        #20 rst = 0;

        for (int i = 0; i < DEPTH; i = i + 1) begin
                @(posedge clk);
                push <= 1;
                write_data <= i;
                @(posedge clk);
                push <= 0;
        end

        for (int i = 0; i < DEPTH; i = i + 1) begin
                @(posedge clk);
                pop <= 1;
                $display ("%d", read_data);
                @(posedge clk);
                pop <= 0;
        end
        $display ("========================================");
        for (int i = 0; i < DEPTH; i = i + 1) begin
                @(posedge clk);
                pop <= 1;
                push <= 1;
                write_data <= i;
                #1 $display ("%d", read_data);
        end
        @(posedge clk);
        pop <= 0;
        push <= 0;

        $display ("========================================");
        for (int i = 0; i < DEPTH / 2; i = i + 1) begin
                @(posedge clk);
                push <= 1;
                write_data <= i;
                @(posedge clk);
                push <= 0;
        end
        for (int i = DEPTH / 2; i < DEPTH; i = i + 1) begin
                @(posedge clk);
                pop <= 1;
                #1 $display ("%d", read_data);
        end
        @(posedge clk);
        pop <= 0;

        #20 $finish;
    end

    // ==================== DUMP ====================
    initial begin
        $dumpvars(0, tb_fifo);
    end

endmodule