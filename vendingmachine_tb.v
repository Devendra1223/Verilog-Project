`timescale 1ns/1ns
`include "FSM_examples.v"

module vending_machine_tb;

    // Testbench signals for the Vending Machine
    reg clk;
    reg reset;
    reg [7:0] insert_cash;
    reg [7:0] item_price;
    reg item_available;
    reg select_item;
    reg cancel;
    wire [7:0] dispensed_item;
    wire [7:0] dispensed_change;
    wire error;

    // Instantiate the vending machine module (DUT - Design Under Test)
    vending_machine_meal dut (
        .clk(clk),
        .reset(reset),
        .insert_cash(insert_cash),
        .item_price(item_price),
        .item_available(item_available),
        .select_item(select_item),
        .cancel(cancel),
        .dispensed_item(dispensed_item),
        .dispensed_change(dispensed_change),
        .error(error)
    );

    // Clock generation (50 MHz clock)
    always #10 clk = ~clk;

    // VCD file for waveform viewing
    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        insert_cash = 0;
        item_price = 30; // Set a standard price
        item_available = 0;
        select_item = 0;
        cancel = 0;
        #20 reset = 0; // Release reset

        // Test Case 1: Successful purchase with change
        $display("--- Test Case 1: Successful Purchase ---");
        #10 insert_cash = 50;
        item_available = 1;
        #10 select_item = 1;
        #20 select_item = 0; // De-assert select
        #40;
        if (dispensed_item == 1 && dispensed_change == 20)
            $display("Test Case 1 Passed: Item dispensed, change is 20.");
        else
            $display("Test Case 1 Failed. Item: %d, Change: %d", dispensed_item, dispensed_change);
        
        // Reset between tests
        #10 reset = 1; #20 reset = 0;

        // Test Case 2: Insufficient cash
        $display("--- Test Case 2: Insufficient Cash ---");
        #10 insert_cash = 20;
        item_available = 1;
        #10 select_item = 1;
        #20 select_item = 0;
        #40;
        if (error == 1 && dispensed_change == 20)
            $display("Test Case 2 Passed: Error triggered, cash returned.");
        else
            $display("Test Case 2 Failed. Error: %b, Change: %d", error, dispensed_change);

        // Reset between tests
        #10 reset = 1; #20 reset = 0;

        // Test Case 3: User cancels transaction
        $display("--- Test Case 3: User Cancellation ---");
        #10 insert_cash = 40;
        #10 cancel = 1;
        #20 cancel = 0;
        #40;
        if (dispensed_change == 40)
            $display("Test Case 3 Passed: Transaction cancelled, cash returned.");
        else
            $display("Test Case 3 Failed. Change: %d", dispensed_change);

        // Reset between tests
        #10 reset = 1; #20 reset = 0;

        // Test Case 4: Item unavailable
        $display("--- Test Case 4: Item Unavailable ---");
        #10 insert_cash = 50;
        item_available = 0; // Item is not available
        #10 select_item = 1;
        #20 select_item = 0;
        #40;
        if (error == 1 && dispensed_change == 50)
            $display("Test Case 4 Passed: Error triggered, cash returned.");
        else
            $display("Test Case 4 Failed. Error: %b, Change: %d", error, dispensed_change);

        #20 $finish;
    end
endmodule
