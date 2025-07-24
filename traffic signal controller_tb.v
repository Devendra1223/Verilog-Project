`timescale 1ns/1ns
`include "FSM_examples.v"

module traffic_controller_tb;

    // Testbench signals for the Traffic Controller
    reg CAR_ON_CNTRY_RD;
    reg CLOCK;
    reg CLEAR;
    wire [1:0] MAIN_SIG;
    wire [1:0] CNTRY_SIG;

    // Instantiate Traffic Signal Controller (DUT)
    sig_control dut (
        .hwy(MAIN_SIG), 
        .cntry(CNTRY_SIG), 
        .X(CAR_ON_CNTRY_RD), 
        .clock(CLOCK), 
        .clear(CLEAR)
    );

    // Clock generation
    initial CLOCK = 0;
    always #5 CLOCK = ~CLOCK; // 100 MHz clock

    // VCD file for waveform viewing
    initial begin
        $dumpfile("traffic_controller.vcd");
        $dumpvars(0, traffic_controller_tb);
    end

    // Monitor to display signal changes
    initial begin
        $monitor("Time=%0t | HWY Signal=%d | CNTRY Signal=%d | Car Present=%b", 
                  $time, MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD);
    end

    // Test sequence
    initial begin
        // 1. Initial Reset
        CLEAR = 1;
        CAR_ON_CNTRY_RD = 0;
        #20 CLEAR = 0; // Release reset, system starts in S0
        $display("--- System Running, Highway Green ---");
        
        // 2. Wait for a while with no car
        #100;
        
        // 3. Car arrives on country road
        $display("--- Car Arrives on Country Road ---");
        CAR_ON_CNTRY_RD = 1;
        
        // 4. Wait for the cycle to give country road a green light
        #200;
        
        // 5. Car leaves the country road
        $display("--- Car Leaves Country Road ---");
        CAR_ON_CNTRY_RD = 0;
        
        // 6. Wait for the cycle to return to highway green
        #200;
        
        // 7. Another car arrives
        $display("--- Another Car Arrives ---");
        CAR_ON_CNTRY_RD = 1;
        #200;

        $finish;
    end
endmodule
