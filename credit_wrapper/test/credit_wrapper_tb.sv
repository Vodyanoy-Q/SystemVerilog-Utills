`timescale 1ns/1ps
module top;
    // ==================== PARAMETERS ====================
    localparam CLK_PERIOD     = 10;
    localparam CREDIT         = 13;
    localparam UP_DATA_SIZE   = 8;
    localparam DOWN_DATA_SIZE = 16;
    localparam LATENCY        = 10;
    localparam MAX_QUEUE      = 32;

    // ==================== SIGNALS ====================
    logic clk;
    logic rst;
    logic [UP_DATA_SIZE - 1:0] up_data;
    logic                      up_valid;
    logic                      up_ready;
    logic [DOWN_DATA_SIZE - 1:0] down_data;
    logic                        down_valid;
    logic                        down_ready;
    logic [UP_DATA_SIZE - 1:0] pipeline_data_in;
    logic                      pipeline_valid_in;
    logic [DOWN_DATA_SIZE - 1:0] pipeline_data_out;
    logic                        pipeline_valid_out;

    // ==================== MODULES ====================
    credit_wrapper #(
        .CREDIT         ( CREDIT ),
        .UP_DATA_SIZE   ( UP_DATA_SIZE ),
        .DOWN_DATA_SIZE ( DOWN_DATA_SIZE )
    ) u_credit_wrapper (
        .clk                ( clk ),
        .rst                ( rst ),
        .up_data            ( up_data ),
        .up_valid           ( up_valid ),
        .up_ready           ( up_ready ),
        .down_data          ( down_data ),
        .down_valid         ( down_valid ),
        .down_ready         ( down_ready ),
        .pipeline_data_in   ( pipeline_data_in ),
        .pipeline_valid_in  ( pipeline_valid_in ),
        .pipeline_data_out  ( pipeline_data_out ),
        .pipeline_valid_out ( pipeline_valid_out )
    );

    test_pipeline # (
        .DATA_IN_WIDTH  ( UP_DATA_SIZE   ),
        .DATA_OUT_WIDTH ( DOWN_DATA_SIZE ),
        .LATENCY        ( LATENCY        )
    ) u_test_pipeline (
        .clk       ( clk                ),
        .rst       ( rst                ),
        .data_in   ( pipeline_data_in   ),
        .valid_in  ( pipeline_valid_in  ),
        .data_out  ( pipeline_data_out  ),
        .valid_out ( pipeline_valid_out )
    );

    // ==================== CLOCK ====================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ==================== DUMP ====================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
    end

    initial begin
        // ========== RESET ==========
        rst = 1;
        #(3 * CLK_PERIOD) rst = 0; 
        // ========== TEST 1 ==========
        @( posedge clk );
        down_ready = 0;
        up_valid = 1;
        for ( int i = 1; i < CREDIT * 10; i = i + 1) begin
            if ( i == CREDIT * 2)
                down_ready <= 0;
            else if ( i == CREDIT * 3) begin
                down_ready <= 1;
                up_valid   <= 0;
            end
            else if (i == CREDIT * 5)
                up_valid <= 1;

            up_data  <= i;
            @( posedge clk );
        end
        up_valid <= 0;
        @( posedge clk );
        #(30 * CLK_PERIOD);

        $finish;
    end
   
endmodule