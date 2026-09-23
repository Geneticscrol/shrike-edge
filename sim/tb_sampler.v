`timescale 1ns/1ps
module tb_sampler;
    reg clk=0, rst_n=0, din=0, arm=0;
    always #10 clk=~clk;
    wire armed, ready;
    wire [15:0] width, period;
    pulse_sampler dut(.clk(clk),.rst_n(rst_n),.en(1'b1),.din(din),.arm(arm),.soft_rst(1'b0),
        .armed(armed),.ready(ready),.width(width),.period(period));
    task clocks; input integer n; integer k; begin for(k=0;k<n;k=k+1) @(posedge clk); end endtask
    initial begin
        clocks(5); rst_n=1; clocks(4); arm=1; clocks(1); arm=0; clocks(10);
        din=1; clocks(20); din=0; clocks(30); din=1; clocks(5);
        if(!ready) begin $display("FAIL ready"); $finish(1); end
        if(width<16||width>24||period<45||period>55) begin $display("FAIL meas"); $finish(1); end
        $display("PASS tb_sampler"); $finish(0);
    end
endmodule
